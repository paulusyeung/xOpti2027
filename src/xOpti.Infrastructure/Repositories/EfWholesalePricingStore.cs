using Microsoft.EntityFrameworkCore;
using xOpti.Application.Pipeline;
using xOpti.Application.Wholesale;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfWholesalePricingStore(XOptiDbContext context) : IWholesalePricingStore
{
    public async Task<WholesalePriceListDto> PublishAsync(
        PublishWholesalePriceListInput input, string? actor, CancellationToken ct)
    {
        var code = input.Code?.Trim().ToUpperInvariant();
        if (string.IsNullOrWhiteSpace(code))
            throw Validation("Code", "required", "A price-list code is required.");
        if (string.IsNullOrWhiteSpace(input.Name))
            throw Validation("Name", "required", "A price-list name is required.");
        if (input.Items.Count == 0)
            throw Validation("Items", "required", "At least one price-list item is required.");
        if (input.Items.Any(item => string.IsNullOrWhiteSpace(item.Sku)))
            throw Validation("Sku", "required", "Every price-list item requires a SKU.");
        if (input.Items.Any(item => item.Price < 0))
            throw Validation("Price", "range", "Price-list prices cannot be negative.");
        var duplicates = input.Items
            .GroupBy(item => item.Sku.Trim(), StringComparer.OrdinalIgnoreCase)
            .Where(group => group.Count() > 1)
            .Select(group => group.Key)
            .ToList();
        if (duplicates.Count > 0)
            throw Validation("Sku", "duplicate",
                $"Duplicate price-list SKUs: {string.Join(", ", duplicates)}.");

        await context.WholesalePriceLists
            .Where(row => row.Code == code && row.IsCurrent)
            .ExecuteUpdateAsync(setter => setter.SetProperty(row => row.IsCurrent, false), ct);
        var version = (await context.WholesalePriceLists
            .Where(row => row.Code == code)
            .MaxAsync(row => (int?)row.Version, ct) ?? 0) + 1;
        var list = new WholesalePriceList
        {
            Code = code,
            Name = input.Name.Trim(),
            Version = version,
            IsCurrent = true,
            CreatedAt = DateTimeOffset.UtcNow,
            CreatedBy = actor,
        };
        context.WholesalePriceLists.Add(list);
        await context.SaveChangesAsync(ct);
        foreach (var item in input.Items)
        {
            context.WholesalePriceListItems.Add(new WholesalePriceListItem
            {
                PriceListId = list.Id,
                Sku = item.Sku.Trim(),
                Price = Money.From(decimal.Round(item.Price, 4)),
            });
        }
        await context.SaveChangesAsync(ct);
        return (await MapAsync(list, ct))!;
    }

    public async Task<WholesalePriceListDto?> GetCurrentAsync(string code, CancellationToken ct)
    {
        var normalized = code?.Trim().ToUpperInvariant();
        var list = await context.WholesalePriceLists.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Code == normalized && row.IsCurrent, ct);
        return list is null ? null : await MapAsync(list, ct);
    }

    public async Task<IReadOnlyList<WholesalePriceListDto>> ListCurrentAsync(CancellationToken ct)
    {
        var lists = await context.WholesalePriceLists.AsNoTracking()
            .Where(row => row.IsCurrent)
            .OrderBy(row => row.Code)
            .ToListAsync(ct);
        var result = new List<WholesalePriceListDto>(lists.Count);
        foreach (var list in lists) result.Add((await MapAsync(list, ct))!);
        return result;
    }

    public async Task<int> ImportLegacyGradesAsync(string? actor, CancellationToken ct)
    {
        var created = 0;
        foreach (var grade in new[] { "A", "B", "C" })
        {
            if (await context.WholesalePriceLists
                    .AnyAsync(row => row.Code == grade && row.IsCurrent, ct))
            {
                continue;
            }

            var prices = await context.WholesalePrices.AsNoTracking()
                .Where(row => row.Sku != string.Empty)
                .ToListAsync(ct);
            var items = prices
                .Select(row => new
                {
                    row.Sku,
                    Price = grade switch
                    {
                        "A" => row.GradeA,
                        "B" => row.GradeB,
                        _ => row.GradeC,
                    },
                })
                .Where(row => row.Price is not null)
                .Select(row => new WholesalePriceItemInput(row.Sku, row.Price!.Value))
                .ToList();
            if (items.Count == 0) continue;

            await PublishAsync(new PublishWholesalePriceListInput(
                grade, $"Legacy wholesale grade {grade}", items), actor, ct);
            created++;
        }
        return created;
    }

    public async Task<WholesalePriceQuoteDto> QuoteAsync(int customerId, string sku,
        decimal? requestedUnitPrice, string? overrideReason, bool canOverride,
        string? actor, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(sku))
            throw Validation("Sku", "required", "A SKU is required.");
        var account = await context.WholesaleAccounts.AsNoTracking()
            .SingleOrDefaultAsync(row => row.CustomerId == customerId, ct);
        if (account is null || !account.IsWholesale)
            throw Validation("CustomerId", "not-wholesale",
                "The customer does not have a wholesale account with terms.");
        if (account.CreditHold)
            throw Validation("CustomerId", "credit-hold",
                "The wholesale account is on credit hold; posting is blocked.");
        if (string.IsNullOrWhiteSpace(account.PriceGrade))
            throw Validation("PriceGrade", "missing",
                "The wholesale account has no assigned price list.");

        var list = await context.WholesalePriceLists.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Code == account.PriceGrade && row.IsCurrent, ct);
        if (list is null)
            throw Validation("PriceList", "missing",
                $"No current price list exists for grade {account.PriceGrade}.");
        var item = await context.WholesalePriceListItems.AsNoTracking()
            .SingleOrDefaultAsync(row => row.PriceListId == list.Id && row.Sku == sku, ct);
        if (item is null)
            throw Validation("Sku", "no-price",
                $"SKU {sku} is not on price list {list.Code} v{list.Version}.");

        var listPrice = item.Price.Amount;
        var applied = requestedUnitPrice is null
            ? listPrice
            : decimal.Round(requestedUnitPrice.Value, 4);
        var isOverride = requestedUnitPrice is not null && applied != listPrice;
        if (isOverride)
        {
            if (!canOverride)
                throw Validation("UnitPrice", "price-override-denied",
                    "Changing a wholesale price requires the price-override permission.");
            if (string.IsNullOrWhiteSpace(overrideReason))
                throw Validation("OverrideReason", "required",
                    "A reason is required when overriding a wholesale price.");
        }
        else
        {
            applied = listPrice;
        }

        return new WholesalePriceQuoteDto(customerId, sku.Trim(), list.Code, list.Version,
            listPrice, applied, isOverride, isOverride ? overrideReason!.Trim() : null,
            isOverride ? actor : null);
    }

    public async Task RecordDocumentLineAsync(string txNumber, double rowNo,
        WholesalePriceQuoteDto quote, CancellationToken ct)
    {
        var row = await context.WholesaleDocumentLines
            .SingleOrDefaultAsync(item => item.TxNumber == txNumber && item.RowNo == rowNo, ct);
        if (row is null)
        {
            row = new WholesaleDocumentLine
            {
                TxNumber = txNumber,
                RowNo = rowNo,
                CreatedAt = DateTimeOffset.UtcNow,
            };
            context.WholesaleDocumentLines.Add(row);
        }
        row.PriceListCode = quote.PriceListCode;
        row.PriceListVersion = quote.PriceListVersion;
        row.ListUnitPrice = Money.From(quote.ListUnitPrice);
        row.AppliedUnitPrice = Money.From(quote.AppliedUnitPrice);
        row.IsOverride = quote.IsOverride;
        row.OverrideReason = quote.OverrideReason;
        row.OverrideBy = quote.OverrideBy;
        await context.SaveChangesAsync(ct);
    }

    public async Task<IReadOnlyList<WholesaleDocumentLineDto>> GetDocumentLinesAsync(
        string txNumber, CancellationToken ct) =>
        await context.WholesaleDocumentLines.AsNoTracking()
            .Where(row => row.TxNumber == txNumber)
            .OrderBy(row => row.RowNo)
            .Select(row => new WholesaleDocumentLineDto(row.TxNumber, row.RowNo,
                row.PriceListCode, row.PriceListVersion, row.ListUnitPrice.Amount,
                row.AppliedUnitPrice.Amount, row.IsOverride, row.OverrideReason,
                row.OverrideBy, row.CreatedAt))
            .ToListAsync(ct);

    private async Task<WholesalePriceListDto?> MapAsync(WholesalePriceList list,
        CancellationToken ct)
    {
        var items = await context.WholesalePriceListItems.AsNoTracking()
            .Where(row => row.PriceListId == list.Id)
            .OrderBy(row => row.Sku)
            .Select(row => new WholesalePriceItemDto(row.Sku, row.Price.Amount))
            .ToListAsync(ct);
        return new WholesalePriceListDto(list.Id, list.Code, list.Name, list.Version,
            list.IsCurrent, list.CreatedAt, items);
    }

    private static ValidationFailedException Validation(string field, string code,
        string message) => new(new[] { new ValidationFieldError(field, code, message) });
}

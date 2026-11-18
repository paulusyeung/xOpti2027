using Microsoft.EntityFrameworkCore;
using xOpti.Application.Payments;
using xOpti.Application.Pipeline;
using xOpti.Application.Wholesale;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfWholesaleInvoiceStore(XOptiDbContext context) : IWholesaleInvoiceStore
{
    public Task<bool> CustomerExistsAsync(int customerId, CancellationToken ct) =>
        context.Customers.AnyAsync(row => row.Id == customerId, ct);

    public async Task<IReadOnlyList<string>> MissingSkusAsync(
        IEnumerable<string> skus, CancellationToken ct)
    {
        var requested = skus.Distinct(StringComparer.OrdinalIgnoreCase).ToList();
        var found = await context.InventoryItems.Where(row => requested.Contains(row.Sku))
            .Select(row => row.Sku).ToListAsync(ct);
        var known = found.ToHashSet(StringComparer.OrdinalIgnoreCase);
        return requested.Where(sku => !known.Contains(sku)).ToList();
    }

    public async Task<(double GstRate, double PstRate)> TaxRatesAsync(CancellationToken ct)
    {
        var preference = await context.Preferences.AsNoTracking()
            .OrderBy(row => row.SerialNumber).FirstOrDefaultAsync(ct);
        return (preference?.TaxARate ?? 0, preference?.TaxBRate ?? 0);
    }

    public async Task<IReadOnlyList<PaymentMethodDto>> PaymentMethodsAsync(CancellationToken ct) =>
        await context.PaymentMethods.AsNoTracking()
            .OrderBy(row => row.PaymentCode)
            .Select(row => new PaymentMethodDto(
                row.PaymentCode, row.PaymentNameShort, row.PaymentNameLong))
            .ToListAsync(ct);

    public async Task<(string? TermsCode, int TermsDays)> AccountTermsAsync(
        int customerId, CancellationToken ct) =>
        await context.WholesaleAccounts.AsNoTracking()
            .Where(row => row.CustomerId == customerId)
            .Select(row => new ValueTuple<string?, int>(row.TermsCode, row.TermsDays))
            .SingleOrDefaultAsync(ct);

    public async Task CreateAsync(WholesaleInvoicePosting posting, CancellationToken ct)
    {
        context.TxHeaders.Add(Header(posting));
        AddLines(posting);
        AddSalePerson(posting);
        AddMetadata(posting);
        AddTenders(posting);
        AddPriceSnapshots(posting);
        AddBackorders(posting);
        await context.SaveChangesAsync(ct);
    }

    public async Task UpdateAsync(WholesaleInvoicePosting posting, CancellationToken ct)
    {
        var header = await context.TxHeaders.SingleOrDefaultAsync(row =>
            row.TxNumber == posting.TxNumber
            && row.TxType == TransactionType.WholesaleInvoice, ct)
            ?? throw Validation("TxNumber", "not-found", "Wholesale invoice was not found.");
        if (header.Status != "0")
            throw Validation("TxNumber", "not-editable", "Only draft wholesale invoices can be updated.");

        header.CustomerId = posting.CustomerId;
        header.TotalSale = Money.From(posting.TotalSale);
        header.TaxA = Money.From(posting.TaxA);
        header.TaxB = Money.From(posting.TaxB);
        header.GrossSale = Money.From(posting.TotalSale + posting.TaxA + posting.TaxB);
        header.TotalAmount = Money.From(posting.TotalAmount);
        header.TotalQty = posting.TotalQty;
        header.ThisPaid = Money.From(0m);
        header.Particulars = "Wholesale invoice";

        var oldDetails = await context.TxDetails
            .Where(row => row.TxNumber == posting.TxNumber).ToListAsync(ct);
        context.TxDetails.RemoveRange(oldDetails);
        var oldTenders = await context.WholesaleTenders
            .Where(row => row.TxNumber == posting.TxNumber).ToListAsync(ct);
        context.WholesaleTenders.RemoveRange(oldTenders);
        var oldSnapshots = await context.WholesaleDocumentLines
            .Where(row => row.TxNumber == posting.TxNumber).ToListAsync(ct);
        context.WholesaleDocumentLines.RemoveRange(oldSnapshots);
        var oldSalePeople = await context.TxSalePersons
            .Where(row => row.TxNumber == posting.TxNumber).ToListAsync(ct);
        context.TxSalePersons.RemoveRange(oldSalePeople);
        var oldBackorders = await context.WholesaleBackorders
            .Where(row => row.OriginalTxNumber == posting.TxNumber).ToListAsync(ct);
        context.WholesaleBackorders.RemoveRange(oldBackorders);

        AddLines(posting);
        AddSalePerson(posting);
        AddTenders(posting);
        AddPriceSnapshots(posting);
        AddBackorders(posting);

        var document = await context.WholesaleDocuments
            .SingleOrDefaultAsync(row => row.TxNumber == posting.TxNumber, ct);
        if (document is null)
        {
            AddMetadata(posting);
        }
        else
        {
            ApplyMetadata(document, posting);
            document.UpdatedAt = DateTimeOffset.UtcNow;
            document.UpdatedBy = posting.Actor;
        }
        await context.SaveChangesAsync(ct);
    }

    public Task<string> NextControlNumberAsync(CancellationToken ct) =>
        ControlNumberSequencer.NextAsync(context, ct);

    public async Task PostAsync(string txNumber, IReadOnlyList<WholesaleTenderInput> tenders,
        string controlNumber, DateTimeOffset now, string branchCode, string? actor,
        CancellationToken ct)
    {
        await context.Database.ExecuteSqlInterpolatedAsync(
            $"SELECT 1 FROM public.tx_header WHERE tx_number = {txNumber} FOR UPDATE", ct);
        var header = await context.TxHeaders.SingleOrDefaultAsync(row =>
            row.TxNumber == txNumber && row.TxType == TransactionType.WholesaleInvoice, ct)
            ?? throw Validation("TxNumber", "not-found", "Wholesale invoice was not found.");
        var document = await context.WholesaleDocuments.SingleOrDefaultAsync(row =>
            row.TxNumber == txNumber, ct)
            ?? throw Validation("TxNumber", "not-found", "Wholesale invoice metadata was not found.");
        if (document.Status != "draft" || header.Status != "0")
            throw Validation("TxNumber", "not-draft", "Only draft wholesale invoices can be posted.");

        var details = await context.TxDetails.Where(row => row.TxNumber == txNumber)
            .OrderBy(row => row.RowNo).ToListAsync(ct);
        if (details.Count == 0)
            throw Validation("Lines", "required", "A wholesale invoice requires at least one line.");

        foreach (var detail in details)
        {
            var cost = await InventoryPosting.ConsumeAsync(context, detail.Sku, detail.Qty,
                txNumber, now, branchCode, ct);
            detail.ControlNumber = controlNumber;
            detail.UnitCost = Money.From(detail.Qty == 0 ? 0m
                : decimal.Round(cost / detail.Qty, 4));
            header.TotalCost = Money.From(decimal.Round(
                header.TotalCost.Amount + cost, 4));
        }

        var oldTenders = await context.WholesaleTenders
            .Where(row => row.TxNumber == txNumber).ToListAsync(ct);
        context.WholesaleTenders.RemoveRange(oldTenders);
        var paymentLine = 1;
        foreach (var tender in tenders)
        {
            context.TxPayments.Add(new TxPayment
            {
                TxNumber = txNumber,
                PaymentLineNo = paymentLine++,
                Type = tender.Method[..1].ToUpperInvariant(),
                AmountTender = Money.From(tender.Amount),
                EqAmount = Money.From(tender.Amount),
                TotalThisPay = Money.From(tender.Amount),
                AuthorizationCode = tender.Reference,
            });
        }

        var paid = decimal.Round(tenders.Sum(row => row.Amount), 4);
        header.ControlNumber = controlNumber;
        header.ThisPaid = Money.From(paid);
        var backorders = await context.WholesaleBackorders
            .Where(row => row.OriginalTxNumber == txNumber).ToListAsync(ct);
        foreach (var backorder in backorders) backorder.Status = "open";

        document.Status = "posted";
        document.PostedAt = now;
        document.PostedBy = actor;
        document.UpdatedAt = now;
        document.UpdatedBy = actor;
        await context.SaveChangesAsync(ct);
    }

    public async Task<WholesaleInvoiceDto?> GetAsync(string txNumber, CancellationToken ct)
    {
        var header = await context.TxHeaders.AsNoTracking().SingleOrDefaultAsync(row =>
            row.TxNumber == txNumber && row.TxType == TransactionType.WholesaleInvoice, ct);
        if (header is null) return null;
        return await MapAsync(header, ct);
    }

    public async Task<IReadOnlyList<WholesaleInvoiceDto>> ListAsync(
        int? customerId, string? status, string? afterTxNumber, int limit, CancellationToken ct)
    {
        var query = context.TxHeaders.AsNoTracking()
            .Where(row => row.TxType == TransactionType.WholesaleInvoice);
        if (customerId is not null) query = query.Where(row => row.CustomerId == customerId);
        if (!string.IsNullOrEmpty(afterTxNumber))
            query = query.Where(row => row.TxNumber.CompareTo(afterTxNumber) > 0);
        if (!string.IsNullOrWhiteSpace(status))
        {
            var normalized = status.Trim().ToLowerInvariant();
            if (normalized == "draft")
            {
                query = query.Where(row => context.WholesaleDocuments.Any(document =>
                    document.TxNumber == row.TxNumber && document.Status == "draft"));
            }
            else if (normalized == "posted")
            {
                query = query.Where(row => !context.WholesaleDocuments.Any(document =>
                    document.TxNumber == row.TxNumber && document.Status == "draft"));
            }
            else
            {
                query = query.Where(row => context.WholesaleDocuments.Any(document =>
                    document.TxNumber == row.TxNumber && document.Status == normalized));
            }
        }

        var headers = await query.OrderBy(row => row.TxNumber).Take(limit).ToListAsync(ct);
        var result = new List<WholesaleInvoiceDto>(headers.Count);
        foreach (var header in headers) result.Add(await MapAsync(header, ct));
        return result;
    }

    private async Task<WholesaleInvoiceDto> MapAsync(TxHeader header, CancellationToken ct)
    {
        var document = await context.WholesaleDocuments.AsNoTracking()
            .SingleOrDefaultAsync(row => row.TxNumber == header.TxNumber, ct);
        var customerName = await context.Customers.AsNoTracking()
            .Where(row => row.Id == header.CustomerId).Select(row => row.FullName)
            .SingleOrDefaultAsync(ct);
        var staff = await context.TxSalePersons.AsNoTracking()
            .Where(row => row.TxNumber == header.TxNumber)
            .OrderBy(row => row.SalesRowNo).Select(row => row.StaffCode)
            .FirstOrDefaultAsync(ct);
        var details = await context.TxDetails.AsNoTracking()
            .Where(row => row.TxNumber == header.TxNumber)
            .OrderBy(row => row.RowNo).ToListAsync(ct);
        var snapshots = await context.WholesaleDocumentLines.AsNoTracking()
            .Where(row => row.TxNumber == header.TxNumber)
            .ToDictionaryAsync(row => row.RowNo, ct);
        var backorderQuantities = await context.WholesaleBackorders.AsNoTracking()
            .Where(row => row.OriginalTxNumber == header.TxNumber)
            .ToDictionaryAsync(row => row.OriginalRowNo, row => row.RemainingQuantity, ct);
        var lines = details.Select(row =>
        {
            snapshots.TryGetValue(row.RowNo, out var snapshot);
            return new WholesaleInvoiceLineDto((int)row.RowNo, row.Sku, row.Remarks, row.Qty,
                row.UnitAmount.Amount, row.MarkDownAmount.Amount, row.Amount.Amount,
                snapshot?.TaxA.Amount ?? 0m, snapshot?.TaxB.Amount ?? 0m, row.TaxCode,
                snapshot?.PriceListCode, snapshot?.PriceListVersion,
                snapshot?.ListUnitPrice.Amount ?? row.UnitAmount.Amount,
                snapshot?.IsOverride ?? false, snapshot?.OverrideReason,
                backorderQuantities.GetValueOrDefault((int)row.RowNo));
        }).ToList();

        IReadOnlyList<WholesaleTenderInput> tenders;
        if (document is { Status: "draft" })
        {
            tenders = await context.WholesaleTenders.AsNoTracking()
                .Where(row => row.TxNumber == header.TxNumber).OrderBy(row => row.LineNo)
                .Select(row => new WholesaleTenderInput(row.Method, row.Amount.Amount,
                    row.Reference)).ToListAsync(ct);
        }
        else
        {
            tenders = await context.TxPayments.AsNoTracking()
                .Where(row => row.TxNumber == header.TxNumber && row.Type != "D")
                .OrderBy(row => row.PaymentLineNo)
                .Select(row => new WholesaleTenderInput(row.Type, row.TotalThisPay.Amount,
                    row.AuthorizationCode)).ToListAsync(ct);
        }

        var status = document?.Status ?? "posted";
        return new WholesaleInvoiceDto(header.TxNumber, header.CustomerId, customerName, staff,
            status, header.DateOfEntry, document?.TermsCode, document?.TermsDays ?? 0,
            document?.DueDate, document?.ShippingMethod, document?.ShipToName,
            document?.ShipToAddress, document?.ShippingInstructions,
            document?.PurchaseOrderNumber, header.TotalSale.Amount, header.TaxA.Amount,
            header.TaxB.Amount, header.TotalAmount.Amount,
            decimal.Round(tenders.Sum(row => row.Amount), 4), header.TotalQty,
            document?.PostedAt, document?.PostedBy, lines, tenders);
    }

    public async Task<IReadOnlyList<WholesaleBackorderDto>> GetBackordersAsync(
        string txNumber, CancellationToken ct) =>
        await context.WholesaleBackorders.AsNoTracking()
            .Where(row => row.OriginalTxNumber == txNumber)
            .OrderBy(row => row.OriginalRowNo)
            .Select(row => new WholesaleBackorderDto(row.Id, row.OriginalTxNumber,
                row.OriginalRowNo, row.CustomerId, row.Sku, row.OrderedQuantity,
                row.ShippedQuantity, row.RemainingQuantity, row.Status, row.CreatedAt,
                row.FulfilledByTxNumber, row.FulfilledAt))
            .ToListAsync(ct);

    private TxHeader Header(WholesaleInvoicePosting posting) => new()
    {
        TxNumber = posting.TxNumber,
        ControlNumber = string.Empty,
        TxType = TransactionType.WholesaleInvoice,
        DateOfEntry = posting.DateOfEntry,
        DateOfCreation = posting.DateOfEntry,
        CustomerId = posting.CustomerId,
        Particulars = "Wholesale invoice",
        TotalSale = Money.From(posting.TotalSale),
        TaxA = Money.From(posting.TaxA),
        TaxB = Money.From(posting.TaxB),
        GrossSale = Money.From(decimal.Round(posting.TotalSale + posting.TaxA + posting.TaxB, 4)),
        TotalAmount = Money.From(posting.TotalAmount),
        TotalQty = posting.TotalQty,
        ThisPaid = Money.From(0m),
        Status = "0",
    };

    private void AddLines(WholesaleInvoicePosting posting)
    {
        var rowNo = 1;
        foreach (var line in posting.Lines)
        {
            context.TxDetails.Add(new TxDetail
            {
                ControlNumber = string.Empty,
                TxType = TransactionType.WholesaleInvoice,
                TxNumber = posting.TxNumber,
                DateOfEntry = posting.DateOfEntry,
                RowNo = rowNo++,
                Sku = line.Sku,
                Qty = line.Quantity,
                UnitAmount = Money.From(line.UnitAmount),
                UnitCost = Money.From(0m),
                MarkDownAmount = Money.From(line.DiscountAmount),
                Amount = Money.From(line.Amount),
                TaxCode = line.TaxCode,
                Remarks = line.Description,
            });
        }
    }

    private void AddSalePerson(WholesaleInvoicePosting posting)
    {
        if (string.IsNullOrWhiteSpace(posting.StaffCode)) return;
        context.TxSalePersons.Add(new TxSalePerson
        {
            TxNumber = posting.TxNumber,
            SalesRowNo = 1,
            StaffCode = posting.StaffCode,
        });
    }

    private void AddMetadata(WholesaleInvoicePosting posting)
    {
        var document = new WholesaleDocument
        {
            TxNumber = posting.TxNumber,
            Kind = "invoice",
            Status = "draft",
            CreatedAt = DateTimeOffset.UtcNow,
            CreatedBy = posting.Actor,
        };
        ApplyMetadata(document, posting);
        context.WholesaleDocuments.Add(document);
    }

    private static void ApplyMetadata(WholesaleDocument document, WholesaleInvoicePosting posting)
    {
        document.TermsCode = posting.TermsCode;
        document.TermsDays = posting.TermsDays;
        document.DueDate = posting.Shipping.DueDate;
        document.ShippingMethod = posting.Shipping.ShippingMethod;
        document.ShipToName = posting.Shipping.ShipToName;
        document.ShipToAddress = posting.Shipping.ShipToAddress;
        document.ShippingInstructions = posting.Shipping.ShippingInstructions;
        document.PurchaseOrderNumber = posting.Shipping.PurchaseOrderNumber;
    }

    private void AddTenders(WholesaleInvoicePosting posting)
    {
        var lineNo = 1;
        foreach (var tender in posting.Tenders)
        {
            context.WholesaleTenders.Add(new WholesaleTender
            {
                TxNumber = posting.TxNumber,
                LineNo = lineNo++,
                Method = tender.Method,
                Amount = Money.From(tender.Amount),
                Reference = tender.Reference,
            });
        }
    }

    private void AddPriceSnapshots(WholesaleInvoicePosting posting)
    {
        var rowNo = 1;
        foreach (var line in posting.Lines)
        {
            context.WholesaleDocumentLines.Add(new WholesaleDocumentLine
            {
                TxNumber = posting.TxNumber,
                RowNo = rowNo++,
                PriceListCode = line.PriceListCode,
                PriceListVersion = line.PriceListVersion,
                ListUnitPrice = Money.From(line.ListUnitPrice),
                AppliedUnitPrice = Money.From(line.UnitAmount),
                TaxA = Money.From(line.TaxA),
                TaxB = Money.From(line.TaxB),
                IsOverride = line.IsOverride,
                OverrideReason = line.OverrideReason,
                OverrideBy = line.IsOverride ? posting.Actor : null,
                CreatedAt = DateTimeOffset.UtcNow,
            });
        }
    }

    private void AddBackorders(WholesaleInvoicePosting posting)
    {
        var rowNo = 1;
        foreach (var line in posting.Lines)
        {
            if (line.BackorderQuantity <= 0)
            {
                rowNo++;
                continue;
            }
            context.WholesaleBackorders.Add(new WholesaleBackorder
            {
                OriginalTxNumber = posting.TxNumber,
                OriginalRowNo = rowNo++,
                CustomerId = posting.CustomerId,
                Sku = line.Sku,
                OrderedQuantity = line.Quantity + line.BackorderQuantity,
                ShippedQuantity = line.Quantity,
                RemainingQuantity = line.BackorderQuantity,
                Status = "draft",
                CreatedAt = DateTimeOffset.UtcNow,
            });
        }
    }

    private static ValidationFailedException Validation(string field, string code,
        string message) => new(new[] { new ValidationFieldError(field, code, message) });
}

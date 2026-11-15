using Microsoft.EntityFrameworkCore;
using xOpti.Application.Ports;
using xOpti.Application.Sales.Documents;
using xOpti.Application.Sales.OrderEntry;
using xOpti.Domain.Rules;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfOrderStore(
    XOptiDbContext context,
    ISalesDocumentStore documents,
    IControlNumberAllocator allocator) : IOrderStore
{
    public Task<bool> CustomerExistsAsync(int customerId, CancellationToken ct) =>
        context.Customers.AnyAsync(row => row.Id == customerId, ct);

    public async Task<IReadOnlyList<CustomerLookupDto>> SearchCustomersAsync(
        string? search, int limit, CancellationToken ct)
    {
        var query = context.Customers.AsNoTracking();
        var term = search?.Trim() ?? string.Empty;
        if (term.Length > 0)
        {
            var pattern = $"%{term}%";
            if (int.TryParse(term, out var id))
            {
                query = query.Where(row => row.Id == id
                    || EF.Functions.ILike(row.FullName ?? string.Empty, pattern)
                    || EF.Functions.ILike(row.VipCode ?? string.Empty, pattern));
            }
            else
            {
                query = query.Where(row =>
                    EF.Functions.ILike(row.FullName ?? string.Empty, pattern)
                    || EF.Functions.ILike(row.VipCode ?? string.Empty, pattern));
            }
        }

        return await query.OrderBy(row => row.FullName).ThenBy(row => row.Id).Take(limit)
            .Select(row => new CustomerLookupDto(row.Id, row.FullName, row.VipCode))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<SalesItemLookupDto>> SearchItemsAsync(
        string? search, int limit, CancellationToken ct)
    {
        var query = context.InventoryItems.AsNoTracking();
        var term = search?.Trim() ?? string.Empty;
        if (term.Length > 0)
        {
            var pattern = $"%{term}%";
            query = query.Where(row => EF.Functions.ILike(row.Sku, pattern)
                || EF.Functions.ILike(row.Name ?? string.Empty, pattern));
        }

        return await query.OrderBy(row => row.Sku).Take(limit)
            .Select(row => new SalesItemLookupDto(
                row.Sku, row.Name,
                context.RetailPrices.Where(price => price.Sku == row.Sku)
                    .Select(price => price.RetailPriceValue).FirstOrDefault(),
                context.Categories.Where(category =>
                        category.DepartmentCode == row.DepartmentCode
                        && category.ClassCode == row.ClassCode
                        && category.CategoryCode == row.CategoryCode)
                    .Select(category => category.TaxMethod).FirstOrDefault(),
                row.QtyTotalOnHand))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<string>> MissingSkusAsync(IEnumerable<string> skus, CancellationToken ct)
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

    public Task<string> NextControlNumberAsync(CancellationToken ct) =>
        ControlNumberSequencer.NextAsync(context, ct);

    public async Task CreateAsync(OrderPosting posting, CancellationToken ct)
    {
        context.TxHeaders.Add(Header(posting, TransactionType.SalesOrder, "0"));
        AddLinesAndDeposit(posting, TransactionType.SalesOrder);
        AddSalePerson(posting);
        await context.SaveChangesAsync(ct);
    }

    public async Task UpdateAsync(OrderPosting posting, CancellationToken ct)
    {
        var header = await context.TxHeaders.SingleAsync(row => row.TxNumber == posting.TxNumber, ct);
        header.CustomerId = posting.CustomerId;
        header.TotalSale = Money.From(posting.TotalSale);
        header.TaxA = Money.From(posting.TaxA);
        header.TaxB = Money.From(posting.TaxB);
        header.GrossSale = Money.From(posting.GrossSale);
        header.TotalAmount = Money.From(posting.GrossSale);
        header.TotalQty = posting.TotalQty;
        header.ThisPaid = Money.From(posting.Paid);

        var oldDetails = await context.TxDetails.Where(row => row.TxNumber == posting.TxNumber).ToListAsync(ct);
        context.TxDetails.RemoveRange(oldDetails);
        var oldDeposits = await context.TxPayments.Where(row =>
            row.TxNumber == posting.TxNumber && row.Type == "D").ToListAsync(ct);
        context.TxPayments.RemoveRange(oldDeposits);
        AddLinesAndDeposit(posting, TransactionType.SalesOrder);
        await context.SaveChangesAsync(ct);
    }

    public async Task CancelAsync(string txNumber, string reason, string? actor, CancellationToken ct)
    {
        var header = await context.TxHeaders.SingleAsync(row => row.TxNumber == txNumber, ct);
        header.Status = "2";
        await context.SaveChangesAsync(ct);
    }

    public Task<SalesDocumentDto?> GetOrderAsync(string txNumber, CancellationToken ct) =>
        documents.GetAsync(txNumber, ct);

    public async Task<IReadOnlyList<SalesDocumentDto>> PageOrdersAsync(
        int? customerId, string? status, string? afterTxNumber, int limit, CancellationToken ct)
    {
        var query = context.TxHeaders.AsNoTracking().Where(row => row.TxType == TransactionType.SalesOrder);
        if (customerId is not null) query = query.Where(row => row.CustomerId == customerId);
        if (!string.IsNullOrWhiteSpace(status)) query = query.Where(row => row.Status == status.Trim());
        if (!string.IsNullOrEmpty(afterTxNumber))
            query = query.Where(row => row.TxNumber.CompareTo(afterTxNumber) > 0);

        var numbers = await query.OrderBy(row => row.TxNumber).Take(limit)
            .Select(row => row.TxNumber).ToListAsync(ct);
        var results = new List<SalesDocumentDto>();
        foreach (var number in numbers)
        {
            var document = await documents.GetAsync(number, ct);
            if (document is not null) results.Add(document);
        }
        return results;
    }

    public async Task<SalesDocumentDto?> GetInvoiceAsync(string invoiceNumber, CancellationToken ct) =>
        await documents.GetAsync(invoiceNumber, ct);

    public async Task<ConversionOutcome?> ConvertAsync(
        string txNumber, IReadOnlyList<TenderInput> tenders, string? actor, CancellationToken ct)
    {
        var order = await context.TxHeaders.AsNoTracking().SingleOrDefaultAsync(row => row.TxNumber == txNumber, ct);
        if (order is null || order.TxType != TransactionType.SalesOrder || order.Status != "0") return null;

        var lines = await context.TxDetails.AsNoTracking().Where(row => row.TxNumber == txNumber)
            .OrderBy(row => row.RowNo).ToListAsync(ct);
        var depositAmounts = await context.TxPayments.AsNoTracking()
            .Where(row => row.TxNumber == txNumber && row.Type == "D")
            .Select(row => row.AmountTender.Amount)
            .ToListAsync(ct);
        var deposit = depositAmounts.Sum();
        var tenderTotal = tenders.Sum(row => row.Amount);
        if (decimal.Round(deposit + tenderTotal, 4) < decimal.Round(order.TotalAmount.Amount, 4))
            return null;

        var invoiceNumber = await allocator.AllocateAsync(TransactionType.RetailInvoice, ct);
        var control = await NextControlNumberAsync(ct);
        var now = DateTimeOffset.UtcNow;

        context.TxHeaders.Add(new TxHeader
        {
            TxNumber = invoiceNumber.Value, ControlNumber = control, TxType = TransactionType.RetailInvoice,
            DateOfEntry = now, DateOfCreation = now, CustomerId = order.CustomerId,
            RefNumber = txNumber, Particulars = "Order conversion",
            TotalSale = order.TotalSale, TotalCost = order.TotalCost, TaxA = order.TaxA, TaxB = order.TaxB,
            GrossSale = order.GrossSale, TotalAmount = order.TotalAmount, TotalQty = order.TotalQty,
            ThisPaid = Money.From(deposit + tenderTotal), Status = "0",
        });

        var rowNo = 1;
        var totalCost = 0m;
        foreach (var line in lines)
        {
            var lineCost = await ConsumeAsync(line.Sku, line.Qty, invoiceNumber.Value, now, ct);
            totalCost += lineCost;
            context.TxDetails.Add(new TxDetail
            {
                ControlNumber = control, TxType = TransactionType.RetailInvoice, TxNumber = invoiceNumber.Value,
                DateOfEntry = now, RowNo = rowNo++, Sku = line.Sku, Qty = line.Qty,
                UnitAmount = line.UnitAmount,
                UnitCost = Money.From(line.Qty == 0 ? 0m : decimal.Round(lineCost / line.Qty, 4)),
                MarkDownAmount = line.MarkDownAmount, Amount = line.Amount,
                TaxCode = line.TaxCode, Remarks = line.Remarks,
            });
        }

        var paymentLine = 1;
        if (deposit > 0)
        {
            context.TxPayments.Add(new TxPayment
            {
                TxNumber = invoiceNumber.Value, PaymentLineNo = paymentLine++, Type = "D",
                AmountTender = Money.From(deposit), TotalThisPay = Money.From(deposit),
            });
        }
        foreach (var tender in tenders)
        {
            context.TxPayments.Add(new TxPayment
            {
                TxNumber = invoiceNumber.Value, PaymentLineNo = paymentLine++, Type = tender.Method[..1],
                AmountTender = Money.From(tender.Amount), TotalThisPay = Money.From(tender.Amount),
                AuthorizationCode = tender.Reference,
            });
        }

        var orderHeader = await context.TxHeaders.SingleAsync(row => row.TxNumber == txNumber, ct);
        orderHeader.Status = "3";
        orderHeader.RefNumber = invoiceNumber.Value;
        await context.SaveChangesAsync(ct);

        return new ConversionOutcome(invoiceNumber.Value, lines.Sum(row => row.Qty), totalCost);
    }

    private async Task<decimal> ConsumeAsync(
        string sku, int quantity, string issueDocument, DateTimeOffset now, CancellationToken ct)
    {
        var inventory = await context.InventoryItems.SingleAsync(row => row.Sku == sku, ct);
        var code = await (from item in context.InventoryItems.AsNoTracking()
                          join category in context.Categories.AsNoTracking()
                              on new { item.DepartmentCode, item.ClassCode, item.CategoryCode }
                              equals new { category.DepartmentCode, category.ClassCode, category.CategoryCode }
                          where item.Sku == sku
                          select category.CostingMethod).SingleOrDefaultAsync(ct);
        var method = code?.Trim() switch
        {
            "2" => CategoryCostingMethod.Lifo,
            "3" => CategoryCostingMethod.Average,
            _ => CategoryCostingMethod.Fifo,
        };

        var lots = await context.LotRecords.Where(row => row.Sku == sku && row.QtyOnHand > 0)
            .OrderBy(row => row.DateReceived).ThenBy(row => row.LotNo).ToListAsync(ct);
        var layers = lots.Select((lot, index) => CostLayer.Create(lot.LotNo, lot.DateReceived, index,
            lot.UnitAmountPurchased, Quantity.From(lot.QtyOnHand)).Value).ToList();
        var result = CostingPolicy.Issue(layers, issueDocument, Quantity.From(quantity), method,
            inventory.AverageCost);
        if (!result.IsSuccess)
        {
            throw new InvalidOperationException(result.Error);
        }

        foreach (var consumption in result.Value.Consumptions)
        {
            var lot = lots.Single(row => row.LotNo == consumption.SourceDocument);
            lot.QtyOnHand -= (int)consumption.Quantity.Value;
            lot.QtyUsed += (int)consumption.Quantity.Value;
        }

        var deficitQuantity = (int)result.Value.DeficitQuantity.Value;
        if (deficitQuantity > 0)
        {
            context.LotRecords.Add(new InvtLotRecord
            {
                Sku = sku, LotNo = "DEF" + issueDocument[^7..], DateReceived = now,
                SupplierCode = string.Empty, QtyPurchased = 0, QtyUsed = 0,
                QtyOnHand = -deficitQuantity, UnitAmountPurchased = inventory.AverageCost,
                TotalAmountPurchased = Money.From(decimal.Round(
                    inventory.AverageCost.Amount * deficitQuantity, 4)),
            });
        }

        inventory.QtyTotalOnHand -= quantity;
        inventory.DateLastIssued = now;
        var branch = await context.BranchInventory.SingleOrDefaultAsync(row =>
            row.BranchCode == "01" && row.Sku == sku, ct);
        if (branch is not null) branch.QtyOnHand -= quantity;
        return result.Value.TotalCost.Amount;
    }

    private TxHeader Header(OrderPosting posting, TransactionType type, string status) => new()
    {
        TxNumber = posting.TxNumber, ControlNumber = posting.ControlNumber, TxType = type,
        DateOfEntry = posting.DateOfEntry, DateOfCreation = posting.DateOfEntry,
        CustomerId = posting.CustomerId, Particulars = "Sale order",
        TotalSale = Money.From(posting.TotalSale), TaxA = Money.From(posting.TaxA),
        TaxB = Money.From(posting.TaxB), GrossSale = Money.From(posting.GrossSale),
        TotalAmount = Money.From(posting.GrossSale), TotalQty = posting.TotalQty,
        ThisPaid = Money.From(posting.Paid), Status = status,
    };

    private void AddLinesAndDeposit(OrderPosting posting, TransactionType type)
    {
        var rowNo = 1;
        foreach (var line in posting.Lines)
        {
            context.TxDetails.Add(new TxDetail
            {
                ControlNumber = posting.ControlNumber, TxType = type, TxNumber = posting.TxNumber,
                DateOfEntry = posting.DateOfEntry, RowNo = rowNo++, Sku = line.Sku, Qty = line.Quantity,
                UnitAmount = Money.From(line.UnitAmount), MarkDownAmount = Money.From(line.DiscountAmount),
                Amount = Money.From(line.Amount), TaxCode = line.TaxCode,
            });
        }

        if (posting.Paid > 0)
        {
            context.TxPayments.Add(new TxPayment
            {
                TxNumber = posting.TxNumber, PaymentLineNo = 1, Type = "D",
                AmountTender = Money.From(posting.Paid), TotalThisPay = Money.From(posting.Paid),
            });
        }
    }

    private void AddSalePerson(OrderPosting posting) =>
        context.TxSalePersons.Add(new TxSalePerson
        {
            TxNumber = posting.TxNumber, SalesRowNo = 1, StaffCode = posting.StaffCode,
        });
}

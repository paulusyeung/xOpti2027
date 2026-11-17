using Microsoft.EntityFrameworkCore;
using xOpti.Application.Pipeline;
using xOpti.Application.Sales;
using xOpti.Application.Sales.Documents;
using xOpti.Application.Sales.Retail;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfRetailSaleStore(
    XOptiDbContext context,
    ISalesDocumentStore documents) : IRetailSaleStore
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

    public async Task<IReadOnlyDictionary<string, decimal?>> RetailPricesAsync(
        IEnumerable<string> skus, CancellationToken ct)
    {
        var requested = skus.Distinct(StringComparer.OrdinalIgnoreCase).ToList();
        var rows = await context.RetailPrices.AsNoTracking()
            .Where(price => requested.Contains(price.Sku))
            .Select(price => new { price.Sku, price.RetailPriceValue })
            .ToListAsync(ct);
        var prices = requested.ToDictionary(
            sku => sku, _ => (decimal?)null, StringComparer.OrdinalIgnoreCase);
        foreach (var row in rows) prices[row.Sku] = row.RetailPriceValue;
        return prices;
    }

    public async Task<(double GstRate, double PstRate)> TaxRatesAsync(CancellationToken ct)
    {
        var preference = await context.Preferences.AsNoTracking()
            .OrderBy(row => row.SerialNumber).FirstOrDefaultAsync(ct);
        return (preference?.TaxARate ?? 0, preference?.TaxBRate ?? 0);
    }

    public async Task<IReadOnlyList<xOpti.Application.Payments.PaymentMethodDto>> PaymentMethodsAsync(
        CancellationToken ct) =>
        await context.PaymentMethods.AsNoTracking()
            .OrderBy(row => row.PaymentCode)
            .Select(row => new xOpti.Application.Payments.PaymentMethodDto(
                row.PaymentCode, row.PaymentNameShort, row.PaymentNameLong))
            .ToListAsync(ct);

    public Task<string> NextControlNumberAsync(CancellationToken ct) =>
        ControlNumberSequencer.NextAsync(context, ct);

    public Task<SalesDocumentDto?> GetDocumentAsync(string txNumber, CancellationToken ct) =>
        documents.GetAsync(txNumber, ct);

    public async Task PostInvoiceAsync(RetailInvoicePosting posting, CancellationToken ct)
    {
        var now = posting.DateOfEntry;
        var branchCode = await SessionBranchAsync(posting.SessionId, ct);
        var header = new TxHeader
        {
            TxNumber = posting.TxNumber, ControlNumber = posting.ControlNumber,
            TxType = TransactionType.RetailInvoice, DateOfEntry = now, DateOfCreation = now,
            CustomerId = posting.CustomerId, Particulars = "Retail sale",
            TotalSale = Money.From(posting.TotalSale), TaxA = Money.From(posting.TaxA),
            TaxB = Money.From(posting.TaxB), GrossSale = Money.From(posting.GrossSale),
            TotalAmount = Money.From(posting.GrossSale),
            TotalQty = posting.Lines.Sum(line => line.Quantity),
            Status = "0",
        };
        context.TxHeaders.Add(header);

        await AddSaleLinesAsync(posting.TxNumber, posting.ControlNumber, now,
            posting.Lines, branchCode, ct);

        var (appliedTotal, change) = AddSaleTenders(
            posting.TxNumber, posting.GrossSale, posting.Tenders, 1);
        header.ThisPaid = Money.From(appliedTotal);
        header.Change = Money.From(change);
        context.TxSalePersons.Add(new TxSalePerson
        {
            TxNumber = posting.TxNumber, SalesRowNo = 1, StaffCode = posting.StaffCode,
        });
        await LinkSessionAsync(posting.SessionId, posting.TxNumber, "RC", now, ct);
        await context.SaveChangesAsync(ct);
    }

    public async Task<RefundableInvoiceDto?> GetRefundableAsync(
        string invoiceNumber, CancellationToken ct)
    {
        var header = await context.TxHeaders.AsNoTracking().SingleOrDefaultAsync(row =>
            row.TxNumber == invoiceNumber && row.TxType == TransactionType.RetailInvoice, ct);
        if (header is null) return null;

        var customerName = await context.Customers.AsNoTracking()
            .Where(row => row.Id == header.CustomerId).Select(row => row.FullName)
            .SingleOrDefaultAsync(ct);
        var details = await context.TxDetails.AsNoTracking()
            .Where(row => row.TxNumber == invoiceNumber)
            .OrderBy(row => row.RowNo).ToListAsync(ct);
        var links = await context.SalesRefundLines.AsNoTracking()
            .Where(row => row.OriginalTxNumber == invoiceNumber).ToListAsync(ct);
        var refundedQty = links.GroupBy(row => (int)row.OriginalRowNo)
            .ToDictionary(group => group.Key, group => group.Sum(row => row.Quantity));

        var lines = new List<RefundableLineDto>(details.Count);
        var taxARemaining = header.TaxA.Amount;
        var taxBRemaining = header.TaxB.Amount;
        for (var index = 0; index < details.Count; index++)
        {
            var detail = details[index];
            var refunded = refundedQty.GetValueOrDefault((int)detail.RowNo);
            var last = index == details.Count - 1;
            var amount = detail.Amount.Amount;
            var taxA = last || header.TotalSale.Amount == 0
                ? taxARemaining
                : decimal.Round(header.TaxA.Amount * amount / header.TotalSale.Amount, 2);
            var taxB = last || header.TotalSale.Amount == 0
                ? taxBRemaining
                : decimal.Round(header.TaxB.Amount * amount / header.TotalSale.Amount, 2);
            taxARemaining = decimal.Round(taxARemaining - taxA, 4);
            taxBRemaining = decimal.Round(taxBRemaining - taxB, 4);

            lines.Add(new RefundableLineDto((int)detail.RowNo, detail.Sku, detail.Qty,
                refunded, Math.Max(0, detail.Qty - refunded), detail.UnitAmount.Amount,
                detail.MarkDownAmount.Amount, amount, taxA, taxB, detail.TaxCode));
        }

        var payments = await context.TxPayments.AsNoTracking()
            .Where(row => row.TxNumber == invoiceNumber)
            .OrderBy(row => row.PaymentLineNo).ToListAsync(ct);
        var refundedByPayment = (await context.SalesRefundTenders.AsNoTracking()
                .Where(row => row.OriginalTxNumber == invoiceNumber).ToListAsync(ct))
            .GroupBy(row => row.OriginalPaymentLineNo)
            .ToDictionary(group => group.Key, group => group.Sum(row => row.Amount));
        var tenders = payments.Select(payment =>
        {
            var applied = payment.TotalThisPay.Amount;
            var refunded = refundedByPayment.GetValueOrDefault(payment.PaymentLineNo);
            return new RefundableTenderDto(payment.PaymentLineNo, payment.Type, applied,
                refunded, Math.Max(0m, applied - refunded), payment.AuthorizationCode);
        }).ToList();

        return new RefundableInvoiceDto(header.TxNumber, header.CustomerId, customerName,
            header.DateOfEntry, header.TotalSale.Amount, header.TaxA.Amount, header.TaxB.Amount,
            header.TotalAmount.Amount, links.Sum(row => row.TaxA), links.Sum(row => row.TaxB),
            lines, tenders);
    }

    public async Task PostRefundAsync(RefundPosting posting, CancellationToken ct)
    {
        var now = posting.DateOfEntry;
        var branchCode = await SessionBranchAsync(posting.SessionId, ct);
        var refundHeader = new TxHeader
        {
            TxNumber = posting.TxNumber, ControlNumber = posting.ControlNumber,
            TxType = TransactionType.RetailRefund, DateOfEntry = now, DateOfCreation = now,
            CustomerId = posting.CustomerId, Particulars = "Refund/exchange",
            TrackingNumber = posting.OriginalTxNumber,
            TotalSale = Money.From(posting.TotalSale), TaxA = Money.From(posting.TaxA),
            TaxB = Money.From(posting.TaxB), GrossSale = Money.From(posting.GrossSale),
            TotalAmount = Money.From(posting.GrossSale),
            TotalQty = posting.TotalQty,
            Status = "0",
        };
        context.TxHeaders.Add(refundHeader);

        var originalCosts = await context.TxDetails.AsNoTracking()
            .Where(row => row.TxNumber == posting.OriginalTxNumber)
            .Select(row => new { row.RowNo, row.UnitCost })
            .ToListAsync(ct);
        var rowNo = 1;
        foreach (var line in posting.RefundLines)
        {
            var cost = originalCosts.FirstOrDefault(row => (int)row.RowNo == line.OriginalRowNo)
                ?.UnitCost ?? Money.Zero;
            context.TxDetails.Add(new TxDetail
            {
                ControlNumber = posting.ControlNumber, TxType = TransactionType.RetailRefund,
                TxNumber = posting.TxNumber, DateOfEntry = now, RowNo = rowNo,
                Sku = line.Sku, Qty = -line.Quantity, UnitAmount = Money.From(line.UnitAmount),
                UnitCost = cost, MarkDownAmount = Money.From(line.DiscountAmount),
                Amount = Money.From(-line.Amount), TaxCode = line.TaxCode,
            });
            context.SalesRefundLines.Add(new SalesRefundLine
            {
                RefundTxNumber = posting.TxNumber, RefundRowNo = rowNo,
                OriginalTxNumber = posting.OriginalTxNumber, OriginalRowNo = line.OriginalRowNo,
                Quantity = line.Quantity, Restocked = line.Restock,
                TaxA = line.TaxA, TaxB = line.TaxB,
            });

            if (line.Restock)
                await InventoryPosting.RestockAsync(context, line.Sku, line.Quantity,
                    cost.Amount, posting.TxNumber, now, branchCode, ct);
            rowNo++;
        }

        foreach (var replacement in posting.ReplacementLines)
        {
            var cost = await InventoryPosting.ConsumeAsync(context, replacement.Sku,
                replacement.Quantity, posting.TxNumber, now, branchCode, ct);
            context.TxDetails.Add(new TxDetail
            {
                ControlNumber = posting.ControlNumber, TxType = TransactionType.RetailRefund,
                TxNumber = posting.TxNumber, DateOfEntry = now, RowNo = rowNo,
                Sku = replacement.Sku, Qty = replacement.Quantity,
                UnitAmount = Money.From(replacement.UnitAmount),
                UnitCost = Money.From(replacement.Quantity == 0
                    ? 0m
                    : decimal.Round(cost / replacement.Quantity, 4)),
                MarkDownAmount = Money.From(replacement.DiscountAmount),
                Amount = Money.From(replacement.Amount), TaxCode = replacement.TaxCode,
            });
            rowNo++;
        }

        var paymentLine = 1;
        var refundedTendered = 0m;
        foreach (var tender in posting.RefundTenders)
        {
            var method = tender.Method.Trim();
            context.TxPayments.Add(new TxPayment
            {
                TxNumber = posting.TxNumber, PaymentLineNo = paymentLine, Type = method[..1],
                AmountTender = Money.From(-tender.Amount), EqAmount = Money.From(-tender.Amount),
                TotalThisPay = Money.From(-tender.Amount), AuthorizationCode = tender.Reference,
            });
            context.SalesRefundTenders.Add(new SalesRefundTender
            {
                RefundTxNumber = posting.TxNumber, PaymentLineNo = paymentLine,
                OriginalTxNumber = posting.OriginalTxNumber,
                OriginalPaymentLineNo = tender.OriginalPaymentLineNo ?? 0,
                Amount = tender.Amount, Method = method[..1],
            });
            refundedTendered += tender.Amount;
            paymentLine++;
        }

        var (saleApplied, change) = AddSaleTenders(
            posting.TxNumber, Math.Max(0m, posting.TotalSale), posting.SaleTenders, paymentLine);
        refundHeader.ThisPaid = Money.From(decimal.Round(saleApplied - refundedTendered, 4));
        refundHeader.Change = Money.From(change);

        context.TxSalePersons.Add(new TxSalePerson
        {
            TxNumber = posting.TxNumber, SalesRowNo = 1, StaffCode = posting.StaffCode,
        });

        if (posting.FullyRefunded)
        {
            var original = await context.TxHeaders.SingleAsync(
                row => row.TxNumber == posting.OriginalTxNumber, ct);
            original.Status = "1";
        }
        await LinkSessionAsync(posting.SessionId, posting.TxNumber, "RS", now, ct);
        await context.SaveChangesAsync(ct);
    }

    private async Task AddSaleLinesAsync(
        string txNumber, string controlNumber, DateTimeOffset now,
        IReadOnlyList<PricedLine> lines, string branchCode, CancellationToken ct)
    {
        var rowNo = 1;
        foreach (var line in lines)
        {
            var cost = await InventoryPosting.ConsumeAsync(
                context, line.Sku, line.Quantity, txNumber, now, branchCode, ct);
            context.TxDetails.Add(new TxDetail
            {
                ControlNumber = controlNumber, TxType = TransactionType.RetailInvoice,
                TxNumber = txNumber, DateOfEntry = now, RowNo = rowNo++,
                Sku = line.Sku, Qty = line.Quantity, UnitAmount = Money.From(line.UnitAmount),
                UnitCost = Money.From(line.Quantity == 0
                    ? 0m
                    : decimal.Round(cost / line.Quantity, 4)),
                MarkDownAmount = Money.From(line.DiscountAmount),
                Amount = Money.From(line.Amount), TaxCode = line.TaxCode,
            });
        }
    }

    private async Task<string> SessionBranchAsync(long? sessionId, CancellationToken ct)
    {
        if (sessionId is null) return "01";
        var session = await context.CashSessions.AsNoTracking().SingleOrDefaultAsync(row =>
            row.Id == sessionId && row.Status == "open", ct);
        return session?.BranchCode
            ?? throw Validation("SessionId", "not-open",
                "The drawer session is not open; resume or open a session before posting.");
    }

    private async Task LinkSessionAsync(long? sessionId, string txNumber, string txType,
        DateTimeOffset now, CancellationToken ct)
    {
        if (sessionId is null) return;
        var open = await context.CashSessions.AnyAsync(row =>
            row.Id == sessionId && row.Status == "open", ct);
        if (!open)
            throw Validation("SessionId", "not-open",
                "The drawer session is not open; resume or open a session before posting.");
        context.CashSessionTransactions.Add(new CashSessionTransaction
        {
            SessionId = sessionId.Value, TxNumber = txNumber, TxType = txType, OccurredAt = now,
        });
    }

    private (decimal Applied, decimal Change) AddSaleTenders(
        string txNumber, decimal total, IReadOnlyList<RetailTenderInput> tenders, int startLine)
    {
        var remaining = decimal.Round(total, 4);
        var appliedTotal = 0m;
        var change = 0m;
        var paymentLine = startLine;
        foreach (var tender in tenders)
        {
            var method = tender.Method.Trim();
            if (method.Length == 0)
                throw Validation("Tenders", "method", "A tender method is required.");
            if (remaining <= 0)
                throw Validation("Tenders", "already-paid",
                    "The document is already fully tendered; remove the extra payment.");

            var amount = decimal.Round(tender.Amount, 4);
            var isCash = string.Equals(method[..1], "C", StringComparison.OrdinalIgnoreCase);
            var applied = amount;
            if (amount > remaining)
            {
                if (!isCash)
                    throw Validation("Tenders", "over-tender",
                        $"A {method[..1]} tender cannot exceed the remaining balance {remaining:0.00}.");
                applied = remaining;
                change += amount - remaining;
            }

            context.TxPayments.Add(new TxPayment
            {
                TxNumber = txNumber, PaymentLineNo = paymentLine++, Type = method[..1],
                AmountTender = Money.From(amount), EqAmount = Money.From(applied),
                TotalThisPay = Money.From(applied), AuthorizationCode = tender.Reference,
            });
            appliedTotal += applied;
            remaining = decimal.Round(remaining - applied, 4);
        }

        if (remaining != 0)
            throw Validation("Tenders", "unpaid",
                $"Tenders are short by {remaining:0.00}; the document was not posted.");
        return (decimal.Round(appliedTotal, 4), decimal.Round(change, 4));
    }

    private static ValidationFailedException Validation(string field, string code, string message) =>
        new(new[] { new ValidationFieldError(field, code, message) });
}

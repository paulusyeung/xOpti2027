using Microsoft.EntityFrameworkCore;
using xOpti.Application.Payments;
using xOpti.Application.Pipeline;
using xOpti.Application.Wholesale;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfWholesaleReturnStore(XOptiDbContext context) : IWholesaleReturnStore
{
    public async Task<WholesaleReturnableInvoiceDto?> GetReturnableAsync(
        string invoiceNumber, string? excludeReturnTxNumber, CancellationToken ct)
    {
        var header = await context.TxHeaders.AsNoTracking().SingleOrDefaultAsync(row =>
            row.TxNumber == invoiceNumber && row.TxType == TransactionType.WholesaleInvoice, ct);
        if (header is null) return null;
        var document = await context.WholesaleDocuments.AsNoTracking()
            .SingleOrDefaultAsync(row => row.TxNumber == invoiceNumber, ct);
        if (document is not null && document.Status != "posted") return null;

        var customerName = await context.Customers.AsNoTracking()
            .Where(row => row.Id == header.CustomerId).Select(row => row.FullName)
            .SingleOrDefaultAsync(ct);
        var details = await context.TxDetails.AsNoTracking()
            .Where(row => row.TxNumber == invoiceNumber).OrderBy(row => row.RowNo)
            .ToListAsync(ct);
        var snapshots = await context.WholesaleDocumentLines.AsNoTracking()
            .Where(row => row.TxNumber == invoiceNumber)
            .ToDictionaryAsync(row => row.RowNo, ct);
        var prior = await (from line in context.WholesaleReturnLines.AsNoTracking()
                           join doc in context.WholesaleDocuments.AsNoTracking()
                               on line.ReturnTxNumber equals doc.TxNumber
                           where line.OriginalInvoiceNumber == invoiceNumber
                               && doc.Status != "voided"
                               && (excludeReturnTxNumber == null
                                   || line.ReturnTxNumber != excludeReturnTxNumber)
                           select new
                           {
                               line.OriginalRowNo,
                               line.Quantity,
                               Amount = line.Amount.Amount,
                               line.TaxA,
                               line.TaxB,
                           }).ToListAsync(ct);

        var lines = new List<WholesaleReturnableLineDto>(details.Count);
        foreach (var detail in details)
        {
            var rowNo = (int)detail.RowNo;
            var snapshot = snapshots.GetValueOrDefault(detail.RowNo);
            var taxA = snapshot?.TaxA.Amount ?? (header.TotalSale.Amount == 0
                ? 0m
                : decimal.Round(header.TaxA.Amount * detail.Amount.Amount
                    / header.TotalSale.Amount, 4));
            var taxB = snapshot?.TaxB.Amount ?? (header.TotalSale.Amount == 0
                ? 0m
                : decimal.Round(header.TaxB.Amount * detail.Amount.Amount
                    / header.TotalSale.Amount, 4));
            var returned = prior.Where(row => row.OriginalRowNo == rowNo).ToList();
            var returnedQty = returned.Sum(row => row.Quantity);
            var returnedAmount = returned.Sum(row => Math.Abs(row.Amount));
            var returnedTaxA = returned.Sum(row => Math.Abs(row.TaxA.Amount));
            var returnedTaxB = returned.Sum(row => Math.Abs(row.TaxB.Amount));
            var availableQty = Math.Max(0, detail.Qty - returnedQty);
            var availableNet = Math.Max(0m, detail.Amount.Amount - returnedAmount);
            var availableTaxA = Math.Max(0m, taxA - returnedTaxA);
            var availableTaxB = Math.Max(0m, taxB - returnedTaxB);
            lines.Add(new WholesaleReturnableLineDto(rowNo, detail.Sku, detail.Qty,
                returnedQty, availableQty, detail.UnitAmount.Amount, detail.UnitCost.Amount,
                detail.MarkDownAmount.Amount, detail.Amount.Amount, taxA, taxB,
                decimal.Round(availableNet + availableTaxA + availableTaxB, 4),
                detail.TaxCode));
        }

        return new WholesaleReturnableInvoiceDto(header.TxNumber, header.CustomerId,
            customerName, header.DateOfEntry, header.TotalSale.Amount, header.TaxA.Amount,
            header.TaxB.Amount, header.TotalAmount.Amount, document?.TermsCode,
            document?.TermsDays ?? 0, lines);
    }

    public async Task<IReadOnlyList<PaymentMethodDto>> PaymentMethodsAsync(CancellationToken ct) =>
        await context.PaymentMethods.AsNoTracking()
            .OrderBy(row => row.PaymentCode)
            .Select(row => new PaymentMethodDto(
                row.PaymentCode, row.PaymentNameShort, row.PaymentNameLong))
            .ToListAsync(ct);

    public Task LockOriginalInvoiceAsync(string invoiceNumber, CancellationToken ct) =>
        context.Database.ExecuteSqlInterpolatedAsync(
            $"SELECT 1 FROM public.tx_header WHERE tx_number = {invoiceNumber} FOR UPDATE", ct);

    public Task<string> NextControlNumberAsync(CancellationToken ct) =>
        ControlNumberSequencer.NextAsync(context, ct);

    public async Task CreateAsync(WholesaleReturnPosting posting, CancellationToken ct)
    {
        context.TxHeaders.Add(Header(posting));
        AddDetails(posting);
        AddReturnLines(posting);
        AddSalePerson(posting);
        AddMetadata(posting);
        AddTenders(posting);
        await context.SaveChangesAsync(ct);
    }

    public async Task UpdateAsync(WholesaleReturnPosting posting, CancellationToken ct)
    {
        await context.Database.ExecuteSqlInterpolatedAsync(
            $"SELECT 1 FROM public.tx_header WHERE tx_number = {posting.TxNumber} FOR UPDATE", ct);
        var header = await context.TxHeaders.SingleOrDefaultAsync(row =>
            row.TxNumber == posting.TxNumber && row.TxType == TransactionType.WholesaleReturn, ct)
            ?? throw Validation("TxNumber", "not-found", "Wholesale return was not found.");
        if (header.Status != "0")
            throw Validation("TxNumber", "not-editable", "Only draft wholesale returns can be updated.");

        var document = await context.WholesaleDocuments
            .SingleOrDefaultAsync(row => row.TxNumber == posting.TxNumber, ct);
        if (document is { Status: not "draft" })
            throw Validation("TxNumber", "not-editable", "Only draft wholesale returns can be updated.");

        header.CustomerId = posting.CustomerId;
        header.TrackingNumber = posting.OriginalInvoiceNumber;
        header.TotalSale = Money.From(posting.TotalSale);
        header.TaxA = Money.From(posting.TaxA);
        header.TaxB = Money.From(posting.TaxB);
        header.GrossSale = Money.From(posting.TotalAmount);
        header.TotalAmount = Money.From(posting.TotalAmount);
        header.TotalQty = posting.TotalQty;
        header.ThisPaid = Money.From(0m);

        var oldDetails = await context.TxDetails
            .Where(row => row.TxNumber == posting.TxNumber).ToListAsync(ct);
        context.TxDetails.RemoveRange(oldDetails);
        var oldLines = await context.WholesaleReturnLines
            .Where(row => row.ReturnTxNumber == posting.TxNumber).ToListAsync(ct);
        context.WholesaleReturnLines.RemoveRange(oldLines);
        var oldTenders = await context.WholesaleTenders
            .Where(row => row.TxNumber == posting.TxNumber).ToListAsync(ct);
        context.WholesaleTenders.RemoveRange(oldTenders);
        var oldSalePeople = await context.TxSalePersons
            .Where(row => row.TxNumber == posting.TxNumber).ToListAsync(ct);
        context.TxSalePersons.RemoveRange(oldSalePeople);

        AddDetails(posting);
        AddReturnLines(posting);
        AddSalePerson(posting);
        AddTenders(posting);
        if (document is null)
        {
            AddMetadata(posting);
        }
        else
        {
            document.OriginalInvoiceNumber = posting.OriginalInvoiceNumber;
            document.TermsCode = posting.TermsCode;
            document.TermsDays = posting.TermsDays;
            document.UpdatedAt = DateTimeOffset.UtcNow;
            document.UpdatedBy = posting.Actor;
        }
        await context.SaveChangesAsync(ct);
    }

    public async Task PostAsync(string txNumber, IReadOnlyList<WholesaleTenderInput> tenders,
        string controlNumber, DateTimeOffset now, string branchCode, string? actor,
        CancellationToken ct)
    {
        await context.Database.ExecuteSqlInterpolatedAsync(
            $"SELECT 1 FROM public.tx_header WHERE tx_number = {txNumber} FOR UPDATE", ct);
        var header = await context.TxHeaders.SingleOrDefaultAsync(row =>
            row.TxNumber == txNumber && row.TxType == TransactionType.WholesaleReturn, ct)
            ?? throw Validation("TxNumber", "not-found", "Wholesale return was not found.");
        var document = await context.WholesaleDocuments.SingleOrDefaultAsync(row =>
            row.TxNumber == txNumber, ct)
            ?? throw Validation("TxNumber", "not-found", "Wholesale return metadata was not found.");
        if (document.Status != "draft" || header.Status != "0")
            throw Validation("TxNumber", "not-draft", "Only draft wholesale returns can be posted.");

        var lines = await context.WholesaleReturnLines
            .Where(row => row.ReturnTxNumber == txNumber)
            .OrderBy(row => row.ReturnRowNo).ToListAsync(ct);
        if (lines.Count == 0)
            throw Validation("Lines", "required", "A wholesale return requires at least one line.");

        var details = await context.TxDetails.Where(row => row.TxNumber == txNumber)
            .OrderBy(row => row.RowNo).ToListAsync(ct);
        foreach (var line in lines)
        {
            if (!line.Restock) continue;
            await InventoryPosting.RestockAsync(context, line.Sku, line.Quantity,
                line.UnitCost.Amount, txNumber, now, branchCode, ct);
        }
        foreach (var detail in details)
        {
            detail.ControlNumber = controlNumber;
            var line = lines.Single(row => row.ReturnRowNo == (int)detail.RowNo);
            detail.UnitCost = line.UnitCost;
        }

        var draftTenders = await context.WholesaleTenders
            .Where(row => row.TxNumber == txNumber).OrderBy(row => row.LineNo).ToListAsync(ct);
        context.WholesaleTenders.RemoveRange(draftTenders);
        var paymentLine = 1;
        var refunded = 0m;
        foreach (var tender in tenders)
        {
            context.TxPayments.Add(new TxPayment
            {
                TxNumber = txNumber,
                PaymentLineNo = paymentLine++,
                Type = tender.Method[..1].ToUpperInvariant(),
                AmountTender = Money.From(-tender.Amount),
                EqAmount = Money.From(-tender.Amount),
                TotalThisPay = Money.From(-tender.Amount),
                AuthorizationCode = tender.Reference,
            });
            refunded += tender.Amount;
        }

        header.ControlNumber = controlNumber;
        header.ThisPaid = Money.From(decimal.Round(-refunded, 4));
        document.Status = "posted";
        document.PostedAt = now;
        document.PostedBy = actor;
        document.UpdatedAt = now;
        document.UpdatedBy = actor;
        await context.SaveChangesAsync(ct);
    }

    public async Task<WholesaleReturnDto?> GetAsync(string txNumber, CancellationToken ct)
    {
        var header = await context.TxHeaders.AsNoTracking().SingleOrDefaultAsync(row =>
            row.TxNumber == txNumber && row.TxType == TransactionType.WholesaleReturn, ct);
        if (header is null) return null;
        var document = await context.WholesaleDocuments.AsNoTracking()
            .SingleOrDefaultAsync(row => row.TxNumber == txNumber, ct);
        var customerName = await context.Customers.AsNoTracking()
            .Where(row => row.Id == header.CustomerId).Select(row => row.FullName)
            .SingleOrDefaultAsync(ct);
        var staff = await context.TxSalePersons.AsNoTracking()
            .Where(row => row.TxNumber == txNumber).OrderBy(row => row.SalesRowNo)
            .Select(row => row.StaffCode).FirstOrDefaultAsync(ct);
        var lines = await context.WholesaleReturnLines.AsNoTracking()
            .Where(row => row.ReturnTxNumber == txNumber).OrderBy(row => row.ReturnRowNo)
            .Select(row => new WholesaleReturnLineDto(row.ReturnRowNo, row.OriginalRowNo,
                row.Sku, row.Quantity, row.UnitAmount.Amount, row.UnitCost.Amount,
                row.DiscountAmount.Amount, row.Amount.Amount, row.TaxA.Amount,
                row.TaxB.Amount, row.TaxCode, row.Restock, row.DispositionReason))
            .ToListAsync(ct);

        IReadOnlyList<WholesaleTenderInput> tenders;
        if (document is { Status: "draft" })
        {
            tenders = await context.WholesaleTenders.AsNoTracking()
                .Where(row => row.TxNumber == txNumber).OrderBy(row => row.LineNo)
                .Select(row => new WholesaleTenderInput(row.Method, row.Amount.Amount,
                    row.Reference)).ToListAsync(ct);
        }
        else
        {
            tenders = await context.TxPayments.AsNoTracking()
                .Where(row => row.TxNumber == txNumber && row.Type != "D")
                .OrderBy(row => row.PaymentLineNo)
                .Select(row => new WholesaleTenderInput(row.Type,
                    Math.Abs(row.TotalThisPay.Amount), row.AuthorizationCode)).ToListAsync(ct);
        }

        return new WholesaleReturnDto(txNumber,
            document?.OriginalInvoiceNumber ?? header.TrackingNumber ?? string.Empty,
            header.CustomerId, customerName, staff, document?.Status ?? "posted",
            header.DateOfEntry, document?.TermsCode, document?.TermsDays ?? 0,
            header.TotalSale.Amount, header.TaxA.Amount, header.TaxB.Amount,
            header.TotalAmount.Amount, decimal.Round(tenders.Sum(row => row.Amount), 4),
            document?.PostedAt, document?.PostedBy, lines, tenders);
    }

    public async Task<IReadOnlyList<WholesaleReturnDto>> ListAsync(
        int? customerId, string? status, string? afterTxNumber, int limit, CancellationToken ct)
    {
        var query = context.TxHeaders.AsNoTracking()
            .Where(row => row.TxType == TransactionType.WholesaleReturn);
        if (customerId is not null) query = query.Where(row => row.CustomerId == customerId);
        if (!string.IsNullOrEmpty(afterTxNumber))
            query = query.Where(row => row.TxNumber.CompareTo(afterTxNumber) > 0);
        if (!string.IsNullOrWhiteSpace(status))
        {
            var normalized = status.Trim().ToLowerInvariant();
            query = query.Where(row => context.WholesaleDocuments.Any(document =>
                document.TxNumber == row.TxNumber && document.Status == normalized));
        }

        var headers = await query.OrderBy(row => row.TxNumber).Take(limit).ToListAsync(ct);
        var results = new List<WholesaleReturnDto>(headers.Count);
        foreach (var header in headers)
        {
            var result = await GetAsync(header.TxNumber, ct);
            if (result is not null) results.Add(result);
        }
        return results;
    }

    private TxHeader Header(WholesaleReturnPosting posting) => new()
    {
        TxNumber = posting.TxNumber,
        ControlNumber = string.Empty,
        TxType = TransactionType.WholesaleReturn,
        DateOfEntry = posting.DateOfEntry,
        DateOfCreation = posting.DateOfEntry,
        CustomerId = posting.CustomerId,
        TrackingNumber = posting.OriginalInvoiceNumber,
        Particulars = "Wholesale return",
        TotalSale = Money.From(posting.TotalSale),
        TaxA = Money.From(posting.TaxA),
        TaxB = Money.From(posting.TaxB),
        GrossSale = Money.From(posting.TotalAmount),
        TotalAmount = Money.From(posting.TotalAmount),
        TotalQty = posting.TotalQty,
        ThisPaid = Money.From(0m),
        Status = "0",
    };

    private void AddDetails(WholesaleReturnPosting posting)
    {
        var rowNo = 1;
        foreach (var line in posting.Lines)
        {
            context.TxDetails.Add(new TxDetail
            {
                ControlNumber = string.Empty,
                TxType = TransactionType.WholesaleReturn,
                TxNumber = posting.TxNumber,
                DateOfEntry = posting.DateOfEntry,
                RowNo = rowNo++,
                Sku = line.Sku,
                Qty = -line.Quantity,
                UnitAmount = Money.From(line.UnitAmount),
                UnitCost = Money.From(line.UnitCost),
                MarkDownAmount = Money.From(line.DiscountAmount),
                Amount = Money.From(line.Amount),
                TaxCode = line.TaxCode,
            });
        }
    }

    private void AddReturnLines(WholesaleReturnPosting posting)
    {
        foreach (var line in posting.Lines)
        {
            context.WholesaleReturnLines.Add(new WholesaleReturnLine
            {
                ReturnTxNumber = posting.TxNumber,
                ReturnRowNo = line.RowNo,
                OriginalInvoiceNumber = posting.OriginalInvoiceNumber,
                OriginalRowNo = line.OriginalRowNo,
                Sku = line.Sku,
                Quantity = line.Quantity,
                UnitAmount = Money.From(line.UnitAmount),
                UnitCost = Money.From(line.UnitCost),
                DiscountAmount = Money.From(line.DiscountAmount),
                Amount = Money.From(line.Amount),
                TaxA = Money.From(line.TaxA),
                TaxB = Money.From(line.TaxB),
                TaxCode = line.TaxCode,
                Restock = line.Restock,
                DispositionReason = line.DispositionReason,
                CreatedAt = DateTimeOffset.UtcNow,
            });
        }
    }

    private void AddSalePerson(WholesaleReturnPosting posting)
    {
        if (string.IsNullOrWhiteSpace(posting.StaffCode)) return;
        context.TxSalePersons.Add(new TxSalePerson
        {
            TxNumber = posting.TxNumber,
            SalesRowNo = 1,
            StaffCode = posting.StaffCode,
        });
    }

    private void AddMetadata(WholesaleReturnPosting posting)
    {
        context.WholesaleDocuments.Add(new WholesaleDocument
        {
            TxNumber = posting.TxNumber,
            Kind = "return",
            Status = "draft",
            OriginalInvoiceNumber = posting.OriginalInvoiceNumber,
            TermsCode = posting.TermsCode,
            TermsDays = posting.TermsDays,
            CreatedAt = DateTimeOffset.UtcNow,
            CreatedBy = posting.Actor,
        });
    }

    private void AddTenders(WholesaleReturnPosting posting)
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

    private static ValidationFailedException Validation(string field, string code,
        string message) => new(new[] { new ValidationFieldError(field, code, message) });
}

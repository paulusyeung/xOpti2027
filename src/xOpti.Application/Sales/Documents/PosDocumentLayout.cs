using System.Globalization;

namespace xOpti.Application.Sales.Documents;

/// <summary>
/// Canonical text plan for POS documents. The PDF renderer draws these values
/// and the golden test pins this plan, so layout changes are intentional.
/// </summary>
public static class PosDocumentLayout
{
    public static IReadOnlyList<string> Build(PosDocumentRenderDto document)
    {
        var lines = new List<string> { "xOpti", document.Title };
        if (document.Duplicate) lines.Add("DUPLICATE COPY — REPRINT");
        lines.Add($"Document {document.TxNumber}");
        if (!string.IsNullOrWhiteSpace(document.OriginalTxNumber))
            lines.Add($"Original {document.OriginalTxNumber}");
        lines.Add($"Date {document.DateOfEntry:yyyy-MM-dd HH:mm}");
        if (!string.IsNullOrWhiteSpace(document.CustomerName))
            lines.Add($"Customer {document.CustomerName} (#{document.CustomerId})");
        if (!string.IsNullOrWhiteSpace(document.StaffCode))
            lines.Add($"Staff {document.StaffCode}");

        foreach (var line in document.Lines)
        {
            lines.Add($"{line.Sku} {line.Name} x{line.Qty} @{Money(line.UnitAmount)} = {Money(line.Amount)}");
        }
        lines.Add($"Subtotal {Money(document.Subtotal)}");
        lines.Add($"GST {Money(document.TaxA)}");
        lines.Add($"PST {Money(document.TaxB)}");
        lines.Add($"Total {Money(document.Total)}");
        lines.Add($"Paid {Money(document.Paid)}");
        if (document.Change != 0) lines.Add($"Change {Money(document.Change)}");

        foreach (var tender in document.Tenders)
        {
            lines.Add($"Tender {tender.Type} {Money(tender.AppliedAmount)}"
                + (string.IsNullOrWhiteSpace(tender.Reference)
                    ? string.Empty
                    : $" ref {tender.Reference}"));
        }

        foreach (var optical in document.OpticalLines ?? Array.Empty<string>())
            lines.Add($"Optical: {optical}");
        foreach (var barcode in document.Barcodes) lines.Add($"*{barcode}*");
        lines.Add(document.Duplicate ? "DUPLICATE · xOpti POS" : "CUSTOMER COPY · xOpti POS");
        return lines;
    }

    private static string Money(decimal value) =>
        value.ToString("0.00", CultureInfo.InvariantCulture);
}

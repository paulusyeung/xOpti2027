using xOpti.Application.Customers;
using xOpti.Application.Sales.Documents;
using xOpti.Application.Wholesale;

namespace xOpti.Application.Reporting;

/// <summary>
/// Reporting port for approved document layouts. Implementations render the
/// supplied projection without re-reading posting data.
/// </summary>
public interface IReportRenderer
{
    RenderedDocument RenderPackingList(WholesalePackingListDto document, bool duplicate);

    RenderedDocument RenderWholesaleStatement(WholesaleStatementDto statement, bool duplicate);

    RenderedDocument RenderReport(ReportDocument document);

    RenderedDocument RenderCustomerStatement(CustomerStatementDto statement, bool duplicate);

    RenderedDocument RenderBarCodeTags(BarCodeTagDocument document);
}

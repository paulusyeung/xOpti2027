namespace xOpti.Application.Reporting;

public interface IReportDataStore
{
    Task<ReportDataPage> QueryAsync(
        ReportReadModelDefinition definition,
        int rowCap,
        ReportParameterValues parameters,
        CancellationToken ct);
}

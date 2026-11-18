using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Wholesale;

public sealed record ListWholesalePriceListsQuery
    : IQuery<IReadOnlyList<WholesalePriceListDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record PublishWholesalePriceListCommand(
    PublishWholesalePriceListInput Input, string Reason)
    : ICommand<WholesalePriceListDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.MasterDataMaintain };
}

public sealed record ImportLegacyWholesalePricesCommand(string Reason)
    : ICommand<int>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.MasterDataMaintain };
}

public sealed record GetWholesalePriceQuoteQuery(
    int CustomerId, string Sku, decimal? UnitPrice, string? OverrideReason)
    : IQuery<WholesalePriceQuoteDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record GetWholesaleDocumentLinesQuery(string TxNumber)
    : IQuery<IReadOnlyList<WholesaleDocumentLineDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed class PublishWholesalePriceListCommandValidator
    : AbstractValidator<PublishWholesalePriceListCommand>
{
    public PublishWholesalePriceListCommandValidator()
    {
        RuleFor(x => x.Input.Code).NotEmpty().MaximumLength(20);
        RuleFor(x => x.Input.Name).NotEmpty().MaximumLength(120);
        RuleFor(x => x.Input.Items).NotEmpty();
        RuleForEach(x => x.Input.Items).ChildRules(item =>
        {
            item.RuleFor(x => x.Sku).NotEmpty().MaximumLength(13);
            item.RuleFor(x => x.Price).GreaterThanOrEqualTo(0);
        });
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class ImportLegacyWholesalePricesCommandValidator
    : AbstractValidator<ImportLegacyWholesalePricesCommand>
{
    public ImportLegacyWholesalePricesCommandValidator()
    {
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class GetWholesalePriceQuoteQueryValidator
    : AbstractValidator<GetWholesalePriceQuoteQuery>
{
    public GetWholesalePriceQuoteQueryValidator()
    {
        RuleFor(x => x.CustomerId).GreaterThan(0);
        RuleFor(x => x.Sku).NotEmpty().MaximumLength(13);
        RuleFor(x => x.UnitPrice).GreaterThanOrEqualTo(0).When(x => x.UnitPrice is not null);
        RuleFor(x => x.OverrideReason).MaximumLength(500);
    }
}

public sealed class ListWholesalePriceListsHandler(IWholesalePricingStore store)
    : IRequestHandler<ListWholesalePriceListsQuery, IReadOnlyList<WholesalePriceListDto>>
{
    public Task<IReadOnlyList<WholesalePriceListDto>> Handle(
        ListWholesalePriceListsQuery request, CancellationToken ct) =>
        store.ListCurrentAsync(ct);
}

public sealed class PublishWholesalePriceListHandler(
    IUnitOfWork unitOfWork, IWholesalePricingStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<PublishWholesalePriceListCommand, WholesalePriceListDto>
{
    public Task<WholesalePriceListDto> Handle(
        PublishWholesalePriceListCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var list = await store.PublishAsync(request.Input, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("wholesale.price-list.publish",
                "WholesalePriceList", list.Id.ToString(),
                JsonSerializer.Serialize(new
                {
                    list.Code,
                    list.Version,
                    items = list.Items.Count,
                    request.Reason,
                })), token);
            return list;
        }, ct);
}

public sealed class ImportLegacyWholesalePricesHandler(
    IUnitOfWork unitOfWork, IWholesalePricingStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<ImportLegacyWholesalePricesCommand, int>
{
    public Task<int> Handle(ImportLegacyWholesalePricesCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var created = await store.ImportLegacyGradesAsync(principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("wholesale.price-list.import",
                "WholesalePriceList", "legacy-grades",
                JsonSerializer.Serialize(new { created, request.Reason })), token);
            return created;
        }, ct);
}

public sealed class GetWholesalePriceQuoteHandler(
    IWholesalePricingStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<GetWholesalePriceQuoteQuery, WholesalePriceQuoteDto>
{
    public async Task<WholesalePriceQuoteDto> Handle(
        GetWholesalePriceQuoteQuery request, CancellationToken ct)
    {
        var quote = await store.QuoteAsync(request.CustomerId, request.Sku,
            request.UnitPrice, request.OverrideReason,
            principal.HasPermission(PermissionNames.SalesPriceOverride),
            principal.UserId, ct);
        if (quote.IsOverride)
        {
            await audit.RecordAsync(new AuditRecord("wholesale.price.override",
                "WholesalePriceQuote", $"{quote.CustomerId}:{quote.Sku}",
                JsonSerializer.Serialize(new
                {
                    quote.PriceListCode,
                    quote.PriceListVersion,
                    quote.ListUnitPrice,
                    quote.AppliedUnitPrice,
                    quote.OverrideReason,
                })), ct);
        }
        return quote;
    }
}

public sealed class GetWholesaleDocumentLinesHandler(IWholesalePricingStore store)
    : IRequestHandler<GetWholesaleDocumentLinesQuery, IReadOnlyList<WholesaleDocumentLineDto>>
{
    public Task<IReadOnlyList<WholesaleDocumentLineDto>> Handle(
        GetWholesaleDocumentLinesQuery request, CancellationToken ct) =>
        store.GetDocumentLinesAsync(request.TxNumber, ct);
}

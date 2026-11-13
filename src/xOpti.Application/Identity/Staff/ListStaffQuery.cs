using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Ports;

namespace xOpti.Application.Identity.Staff;

/// <summary>
/// Keyset list of staff accounts, ordered by username. PII is projected per
/// caller; callers without <c>staff:pii</c> receive the directory without
/// contact details.
/// </summary>
public sealed record ListStaffQuery(string? Cursor, int PageSize)
    : IQuery<PagedResult<StaffAccountDto>>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };

    public string? AfterUserName => Cursor is null ? null : KeysetCursor.Decode(Cursor);
}

public sealed class ListStaffQueryValidator : AbstractValidator<ListStaffQuery>
{
    public ListStaffQueryValidator()
    {
        RuleFor(x => x.PageSize).InclusiveBetween(1, 200);
    }
}

public sealed class ListStaffHandler(IStaffAccountStore store, ICurrentPrincipal principal)
    : IRequestHandler<ListStaffQuery, PagedResult<StaffAccountDto>>
{
    public async Task<PagedResult<StaffAccountDto>> Handle(
        ListStaffQuery request,
        CancellationToken cancellationToken)
    {
        var rows = await store.GetPageAfterAsync(
            request.AfterUserName,
            request.PageSize + 1,
            cancellationToken);

        var hasMore = rows.Count > request.PageSize;
        var page = hasMore ? rows.Take(request.PageSize).ToList() : rows.ToList();
        var nextCursor = hasMore ? KeysetCursor.Encode(page[^1].UserName) : null;

        var items = page.Select(account => StaffProjection.ToDto(account, principal)).ToList();
        return new PagedResult<StaffAccountDto>(items, nextCursor);
    }
}

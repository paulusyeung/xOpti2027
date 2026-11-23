using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;

namespace xOpti.Application.Identity.Staff;

/// <summary>
/// A staff member as stored in the migrated legacy <c>public.staff</c> table.
/// Contact details and password material are intentionally excluded.
/// </summary>
public sealed record LegacyStaffDto(
    string Code,
    string? FirstName,
    string? LastName,
    string? JobTitle,
    string? JobTitleName);

/// <summary>Read-only, keyset-ordered view of the legacy staff directory.</summary>
public interface ILegacyStaffDirectory
{
    Task<IReadOnlyList<LegacyStaffDto>> PageAsync(
        string? search,
        string? afterCode,
        int limit,
        CancellationToken cancellationToken);
}

public sealed record ListLegacyStaffQuery(string? Search, string? Cursor, int PageSize)
    : IQuery<PagedResult<LegacyStaffDto>>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };

    public string? AfterCode => Cursor is null ? null : KeysetCursor.Decode(Cursor);
}

public sealed class ListLegacyStaffQueryValidator : AbstractValidator<ListLegacyStaffQuery>
{
    public ListLegacyStaffQueryValidator()
    {
        RuleFor(x => x.PageSize).InclusiveBetween(1, 200);
        RuleFor(x => x.Search).MaximumLength(60);
    }
}

public sealed class ListLegacyStaffHandler(ILegacyStaffDirectory directory)
    : IRequestHandler<ListLegacyStaffQuery, PagedResult<LegacyStaffDto>>
{
    public async Task<PagedResult<LegacyStaffDto>> Handle(
        ListLegacyStaffQuery request,
        CancellationToken cancellationToken)
    {
        var rows = await directory.PageAsync(
            request.Search, request.AfterCode, request.PageSize + 1, cancellationToken);
        var hasMore = rows.Count > request.PageSize;
        var page = hasMore ? rows.Take(request.PageSize).ToList() : rows.ToList();
        var nextCursor = hasMore ? KeysetCursor.Encode(page[^1].Code) : null;
        return new PagedResult<LegacyStaffDto>(page, nextCursor);
    }
}

using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;

namespace xOpti.Application.Reference;

/// <summary>The migrated reference tables exposed by read-only administration.</summary>
public enum ReferenceKind
{
    City,
    Province,
    Country,
    Department,
    Class,
    Category,
    Brand,
    Material,
    TaxMethod,
    PaymentMethod,
}

/// <summary>
/// One reference row. <see cref="Key"/> is the stable natural key (composite
/// keys use '/'); <see cref="Parent"/> carries the owning department/region when
/// the table has one. No cost or PII fields are present here.
/// </summary>
public sealed record ReferenceItemDto(
    string Kind,
    string Key,
    string Name,
    string? Parent = null,
    string? Detail = null);

public sealed record ListReferencesQuery(
    ReferenceKind Kind,
    string? Search,
    string? Cursor,
    int PageSize)
    : IQuery<PagedResult<ReferenceItemDto>>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };

    public string? AfterKey => Cursor is null ? null : KeysetCursor.Decode(Cursor);
}

public sealed class ListReferencesQueryValidator : AbstractValidator<ListReferencesQuery>
{
    public ListReferencesQueryValidator()
    {
        RuleFor(x => x.Kind).IsInEnum();
        RuleFor(x => x.PageSize).InclusiveBetween(1, 200);
        RuleFor(x => x.Search).MaximumLength(60);
    }
}

public sealed class ListReferencesHandler(IReferenceDirectory directory)
    : IRequestHandler<ListReferencesQuery, PagedResult<ReferenceItemDto>>
{
    public async Task<PagedResult<ReferenceItemDto>> Handle(
        ListReferencesQuery request,
        CancellationToken cancellationToken)
    {
        var rows = await directory.PageAsync(
            request.Kind,
            request.Search,
            request.AfterKey,
            request.PageSize + 1,
            cancellationToken);

        var hasMore = rows.Count > request.PageSize;
        var page = hasMore ? rows.Take(request.PageSize).ToList() : rows.ToList();
        var nextCursor = hasMore ? KeysetCursor.Encode(page[^1].Key) : null;

        return new PagedResult<ReferenceItemDto>(page, nextCursor);
    }
}

/// <summary>Case-insensitive, keyset-ordered read access to reference tables.</summary>
public interface IReferenceDirectory
{
    Task<IReadOnlyList<ReferenceItemDto>> PageAsync(
        ReferenceKind kind,
        string? search,
        string? afterKey,
        int limit,
        CancellationToken cancellationToken);
}

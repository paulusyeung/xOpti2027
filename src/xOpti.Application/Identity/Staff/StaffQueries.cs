using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Ports;

namespace xOpti.Application.Identity.Staff;

/// <summary>Reads one staff account by identity id.</summary>
public sealed record GetStaffQuery(string UserId)
    : IQuery<StaffAccountDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class GetStaffQueryValidator : AbstractValidator<GetStaffQuery>
{
    public GetStaffQueryValidator()
    {
        RuleFor(x => x.UserId).NotEmpty();
    }
}

public sealed class GetStaffHandler(IStaffAccountStore store, ICurrentPrincipal principal)
    : IRequestHandler<GetStaffQuery, StaffAccountDto>
{
    public async Task<StaffAccountDto> Handle(GetStaffQuery request, CancellationToken cancellationToken)
    {
        var account = await store.FindByIdAsync(request.UserId, cancellationToken)
            ?? throw new DomainRuleException($"Staff account '{request.UserId}' was not found.");
        return StaffProjection.ToDto(account, principal);
    }
}

/// <summary>Roles, their permissions, and the level rules from the versioned matrix.</summary>
public sealed record GetRolesQuery : IQuery<RoleCatalogueDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed record RoleCatalogueDto(
    string Version,
    bool Signed,
    string? SignedBy,
    string? ApprovedOn,
    IReadOnlyList<LevelRuleDto> LevelRules,
    IReadOnlyList<RoleGrantDto> Roles,
    IReadOnlyList<string> UnassignedPermissions,
    IReadOnlyList<string> ParityGaps);

public sealed record LevelRuleDto(int MinLevel, string Role);

public sealed record RoleGrantDto(string Role, IReadOnlyList<string> Permissions);

public sealed class GetRolesHandler(IRoleCatalogue catalogue)
    : IRequestHandler<GetRolesQuery, RoleCatalogueDto>
{
    public Task<RoleCatalogueDto> Handle(GetRolesQuery request, CancellationToken cancellationToken)
    {
        var result = new RoleCatalogueDto(
            catalogue.Version,
            catalogue.Signed,
            catalogue.SignedBy,
            catalogue.ApprovedOn,
            catalogue.LevelRules.Select(rule => new LevelRuleDto(rule.MinLevel, rule.Role)).ToList(),
            catalogue.KnownRoles
                .Select(role => new RoleGrantDto(role, catalogue.PermissionsForRole(role)))
                .ToList(),
            catalogue.UnassignedPermissions,
            catalogue.ParityGaps);

        return Task.FromResult(result);
    }
}

/// <summary>The closed permission vocabulary and which roles hold each permission.</summary>
public sealed record GetPermissionsQuery : IQuery<PermissionCatalogueDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed record PermissionCatalogueDto(
    IReadOnlyList<PermissionGrantDto> Permissions,
    IReadOnlyList<string> UnassignedPermissions);

public sealed record PermissionGrantDto(string Permission, IReadOnlyList<string> Roles);

public sealed class GetPermissionsHandler(IRoleCatalogue catalogue)
    : IRequestHandler<GetPermissionsQuery, PermissionCatalogueDto>
{
    public Task<PermissionCatalogueDto> Handle(GetPermissionsQuery request, CancellationToken cancellationToken)
    {
        var permissions = catalogue.AllPermissions
            .Select(permission => new PermissionGrantDto(
                permission,
                catalogue.KnownRoles
                    .Where(role => catalogue.PermissionsForRole(role).Contains(permission))
                    .ToList()))
            .ToList();

        return Task.FromResult(new PermissionCatalogueDto(permissions, catalogue.UnassignedPermissions));
    }
}

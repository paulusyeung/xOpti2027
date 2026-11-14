using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Identity.ListBranches;
using xOpti.Application.Identity.Staff;
using xOpti.Application.Inventory.Catalogue;
using xOpti.Application.Inventory.GetInventorySummary;
using xOpti.Application.Reference;
using xOpti.Application.Common;
using xOpti.Application.Identity.ListBranches;
using xOpti.Application.Identity.UpdateBranchName;
using xOpti.Application.Sales.HoldSale;
using xOpti.Api.Middleware;

namespace xOpti.Api.Endpoints;

public static class Endpoints
{
    public static void MapAuthEndpoints(this WebApplication app)
    {
        var auth = app.MapGroup("/api/v1/auth");

        auth.MapGet("/csrf-token", (IAntiforgery antiforgery, HttpContext http) =>
        {
            var tokens = antiforgery.GetAndStoreTokens(http);
            return Results.Ok(new { token = tokens.RequestToken });
        }).AllowAnonymous().ExcludeFromDescription();

        auth.MapPost("/sign-in", async (
            SignInRequest request,
            SignInManager<xOpti.Infrastructure.Identity.XoptiUser> signInManager,
            UserManager<xOpti.Infrastructure.Identity.XoptiUser> users) =>
        {
            var user = string.IsNullOrWhiteSpace(request.Username)
                ? null
                : await users.FindByNameAsync(request.Username!);

            // Uniform failure shape whether the user is missing, locked out,
            // or the password is wrong: never reveal account existence.
            if (user is null || user.Disabled)
            {
                return InvalidCredentials();
            }

            if (user.ResetRequired)
            {
                return Results.Problem(new ProblemDetails
                {
                    Type = Problems.ResetRequired,
                    Title = "Password reset required",
                    Status = StatusCodes.Status403Forbidden,
                    Detail = "This account is not activated; complete the administrator-issued password reset first.",
                });
            }

            var result = await signInManager.PasswordSignInAsync(
                user, request.Password ?? string.Empty, isPersistent: false, lockoutOnFailure: true);

            if (result.Succeeded)
            {
                return Results.Ok(new { username = user.UserName, displayName = user.DisplayName });
            }

            return InvalidCredentials();
        }).AllowAnonymous();

        auth.MapPost("/reset-password", async (
            CompleteResetRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new CompletePasswordResetCommand(request.Username, request.Token, request.NewPassword),
                cancellationToken);
            return Results.Ok(result);
        })
        .AllowAnonymous()
        .Produces<PasswordResetCompletedDto>();

        auth.MapPost("/sign-out", async (
            SignInManager<xOpti.Infrastructure.Identity.XoptiUser> signInManager) =>
        {
            await signInManager.SignOutAsync();
            return Results.NoContent();
        });

        // Read-only session identity for the SPA shell (permission-driven navigation).
        // Returns no tokens or secret material; the API remains the authority for
        // every permission check.
        auth.MapGet("/me", async (
            ClaimsPrincipal principal,
            UserManager<xOpti.Infrastructure.Identity.XoptiUser> users) =>
        {
            var user = await users.GetUserAsync(principal);
            if (user is null)
            {
                return Results.Problem(new ProblemDetails
                {
                    Type = Problems.Unauthenticated,
                    Title = "Unauthorized",
                    Status = StatusCodes.Status401Unauthorized,
                    Detail = "No valid session.",
                });
            }

            var permissions = principal
                .FindAll(xOpti.Infrastructure.ClaimsCurrentPrincipal.PermissionClaimType)
                .Select(claim => claim.Value)
                .Distinct(StringComparer.Ordinal)
                .OrderBy(value => value, StringComparer.Ordinal)
                .ToArray();

            var branch = principal.FindFirstValue(xOpti.Infrastructure.ClaimsCurrentPrincipal.BranchClaimType);
            return Results.Ok(new CurrentUserResponse(
                user.UserName ?? string.Empty, user.DisplayName, branch, permissions));
        })
        .RequireAuthorization()
        .Produces<CurrentUserResponse>(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status401Unauthorized);

        static IResult InvalidCredentials() => Results.Problem(new ProblemDetails
        {
            Type = Problems.Unauthenticated,
            Title = "Invalid credentials",
            Status = StatusCodes.Status401Unauthorized,
            Detail = "The username or password is incorrect.",
        });
    }

    public static void MapXOptiApiVersioned(this WebApplication app)
    {
        var versionSet = app.NewApiVersionSet()
            .HasApiVersion(new Asp.Versioning.ApiVersion(1, 0))
            .ReportApiVersions()
            .Build();

        // Literal /api/v1 prefix so the OpenAPI contract carries stable paths;
        // the version set reports v1. New versions mount /api/v2 alongside.
        var v1 = app.MapGroup("/api/v1")
            .WithApiVersionSet(versionSet);

        v1.MapGet("/branches", async (
            string? cursor,
            int? pageSize,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ListBranchesQuery(cursor, pageSize ?? 20), cancellationToken);
            return Results.Json(result);
        })
        .Produces<PagedResult<BranchDto>>();

        v1.MapGet("/admin/staff/{id}", async (
            string id,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetStaffQuery(id), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<StaffAccountDto>();

        v1.MapPost("/admin/staff", async (
            CreateStaffRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new CreateStaffCommand(request.UserName, request.DisplayName, request.Role, request.BranchCode, request.Reason),
                cancellationToken);
            return Results.Created($"/api/v1/admin/staff/{result.Account.Id}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<StaffCredentialsDto>(StatusCodes.Status201Created);

        v1.MapPost("/admin/staff/{id}/disable", async (
            string id,
            ReasonRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new DisableStaffCommand(id, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<StaffAccountDto>();

        v1.MapPost("/admin/staff/{id}/enable", async (
            string id,
            ReasonRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new EnableStaffCommand(id, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<StaffAccountDto>();

        v1.MapPost("/admin/staff/{id}/force-reset", async (
            string id,
            ReasonRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ForceStaffResetCommand(id, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<StaffCredentialsDto>();

        v1.MapPut("/admin/staff/{id}/role", async (
            string id,
            ChangeRoleRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ChangeStaffRoleCommand(id, request.Role, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<StaffAccountDto>();

        v1.MapPut("/admin/staff/{id}/branch", async (
            string id,
            SetBranchRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new SetStaffBranchCommand(id, request.BranchCode, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<StaffAccountDto>();

        v1.MapGet("/admin/skus", async (
            string? search, string? cursor, int? pageSize,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListCatalogueQuery(search, cursor, pageSize ?? 50), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<PagedResult<CatalogueItemDto>>();

        v1.MapGet("/admin/skus/{sku}", async (
            string sku, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetSkuQuery(sku), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<CatalogueItemDto>();

        v1.MapPost("/admin/skus", async (
            CreateSkuRequest request, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new CreateSkuCommand(
                request.Sku, request.Name, request.DepartmentCode, request.ClassCode, request.CategoryCode,
                request.SupplierCode, request.BrandCode, request.MaterialCode, request.LotTracked,
                request.RetailPriceFlag, request.WholesalePriceFlag, request.Reason), cancellationToken);
            return Results.Created($"/api/v1/admin/skus/{result.Sku}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<CatalogueItemDto>(StatusCodes.Status201Created);

        v1.MapPut("/admin/skus/{sku}", async (
            string sku, UpdateSkuRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new UpdateSkuCommand(
                sku, request.Name, request.DepartmentCode, request.ClassCode, request.CategoryCode,
                request.SupplierCode, request.BrandCode, request.MaterialCode, request.LotTracked,
                request.RetailPriceFlag, request.WholesalePriceFlag, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<CatalogueItemDto>();

        v1.MapPost("/admin/skus/{sku}/retire", async (
            string sku, RetireSkuRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new RetireSkuCommand(sku, request.Reason, request.ConfirmOnHand), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<CatalogueItemDto>();

        v1.MapGet("/admin/skus/{sku}/prices", async (
            string sku, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetSkuPricesQuery(sku), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<SkuPricesDto>();

        v1.MapPut("/admin/skus/{sku}/prices", async (
            string sku, SetPricesRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new SetSkuPricesCommand(
                sku, request.RetailPrice, request.LeastSellingPrice, request.RetailMarkdownAmount,
                request.RetailMarkdownPercent, request.SuggestedRetailPrice,
                request.GradeA, request.GradeB, request.GradeC, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<SkuPricesDto>();

        v1.MapPost("/admin/skus/{sku}/barcode", async (
            string sku, ReasonRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GenerateBarcodeTagCommand(sku, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<BarcodeTagDto>();

        v1.MapGet("/admin/skus/{sku}/barcode", async (
            string sku, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ReprintBarcodeTagCommand(sku), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<BarcodeTagDto>();

        v1.MapGet("/admin/suppliers", async (
            string? search, string? cursor, int? pageSize,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListSuppliersQuery(search, cursor, pageSize ?? 50), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<PagedResult<SupplierDto>>();

        v1.MapPost("/admin/suppliers", async (
            CreateSupplierRequest request, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new CreateSupplierCommand(
                request.SupplierCode, request.Name, request.CityCode, request.Province,
                request.Country, request.Phone, request.ContactPerson, request.CreditLimit,
                request.PaymentTerms, request.Reason), cancellationToken);
            return Results.Created($"/api/v1/admin/suppliers/{result.SupplierCode}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<SupplierDto>(StatusCodes.Status201Created);

        v1.MapGet("/admin/suppliers/{code}/contacts", async (
            string code, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ListSupplierContactsQuery(code), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<IReadOnlyList<SupplierContactDto>>();

        v1.MapPost("/admin/suppliers/{code}/contacts", async (
            string code, CreateContactRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new CreateSupplierContactCommand(
                code, request.FirstName, request.Initial, request.LastName,
                request.JobTitle, request.Phone, request.Reason), cancellationToken);
            return Results.Created($"/api/v1/admin/suppliers/{code}/contacts", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<SupplierContactDto>(StatusCodes.Status201Created);

        v1.MapGet("/admin/doctors", async (
            string? search, string? cursor, int? pageSize,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListDoctorsQuery(search, cursor, pageSize ?? 50), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<PagedResult<DoctorDto>>();

        v1.MapPost("/admin/doctors", async (
            CreateDoctorRequest request, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new CreateDoctorCommand(
                request.Name, request.Address, request.CityCode, request.Province,
                request.Country, request.Phone, request.PostalCode, request.Reason), cancellationToken);
            return Results.Created($"/api/v1/admin/doctors/{result.Id}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<DoctorDto>(StatusCodes.Status201Created);

        v1.MapPost("/admin/branches/{code}/deactivate", async (
            string code, DeactivateBranchRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new DeactivateBranchCommand(code, request.Reason, request.TargetBranchCode), cancellationToken);
            return Results.Ok(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<bool>();

        v1.MapGet("/admin/reference/{kind}", async (
            ReferenceKind kind,
            string? search,
            string? cursor,
            int? pageSize,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListReferencesQuery(kind, search, cursor, pageSize ?? 50), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<PagedResult<ReferenceItemDto>>();

        v1.MapPost("/admin/reference/{kind}", async (
            ReferenceKind kind,
            ReferenceMutationRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new CreateReferenceCommand(request.ToMutation(kind), request.Reason), cancellationToken);
            return Results.Created($"/api/v1/admin/reference/{kind}/{result.Key}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<ReferenceItemDto>(StatusCodes.Status201Created);

        v1.MapPut("/admin/reference/{kind}", async (
            ReferenceKind kind,
            ReferenceMutationRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new UpdateReferenceCommand(request.ToMutation(kind), request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<ReferenceItemDto>();

        v1.MapPost("/admin/reference/{kind}/retire", async (
            ReferenceKind kind,
            RetireReferenceRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new RetireReferenceCommand(kind, request.Key, request.Reason, request.ConfirmReferenced),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<ReferenceItemDto>();

        v1.MapGet("/admin/roles", async (IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetRolesQuery(), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<RoleCatalogueDto>();

        v1.MapGet("/admin/permissions", async (IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetPermissionsQuery(), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<PermissionCatalogueDto>();

        v1.MapGet("/admin/staff", async (
            string? cursor,
            int? pageSize,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ListStaffQuery(cursor, pageSize ?? 50), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<PagedResult<StaffAccountDto>>();

        v1.MapGet("/inventory/{sku}", async (
            string sku,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetInventorySummaryQuery(sku), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}");

        v1.MapPatch("/branches/{branchCode}", async (
            string branchCode,
            RenameBranchRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new UpdateBranchNameCommand(branchCode, request.Name, request.ExpectedCurrentName), cancellationToken);
            return Results.Json(result);
        })
        .Produces<BranchDto>();

        // Financial reference endpoint: idempotency key enforced by filter,
        // forwarded to the command; replay/conflict semantics live in the
        // Application pipeline.
        v1.MapPost("/sales/holds", async (
            HttpContext http,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new HoldSaleCommand(key), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .AddEndpointFilter<IdempotencyKeyFilter>();
    }

    public static void MapXOptiHealth(this WebApplication app)
    {
        app.MapHealthChecks("/api/health/live", new HealthCheckOptions
        {
            Predicate = registration => registration.Tags.Contains("live"),
            ResponseWriter = (http, report) => http.Response.WriteAsync(report.Status.ToString()),
        }).AllowAnonymous();

        app.MapHealthChecks("/api/health/ready", new HealthCheckOptions
        {
            Predicate = registration => registration.Tags.Contains("ready"),
            ResponseWriter = (http, report) => http.Response.WriteAsync(report.Status.ToString()),
        }).AllowAnonymous();
    }
}

public sealed record SignInRequest(string? Username, string? Password);

public sealed record CompleteResetRequest(string Username, string Token, string NewPassword);

public sealed record CreateStaffRequest(
    string UserName,
    string? DisplayName,
    string Role,
    string? BranchCode,
    string Reason);

public sealed record ReasonRequest(string Reason);

public sealed record ReferenceMutationRequest(
    string Key,
    string Name,
    string? Parent,
    bool? SummaryFlag,
    string? CostingMethod,
    string? InventoryMethod,
    string? TaxMethod,
    string? PaymentNameShort,
    double? ExchangeRate,
    string Reason)
{
    public ReferenceMutation ToMutation(ReferenceKind kind) => new(
        kind, Key, Name, Parent, SummaryFlag, CostingMethod, InventoryMethod, TaxMethod,
        PaymentNameShort, ExchangeRate);
}

public sealed record RetireReferenceRequest(string Key, string Reason, bool ConfirmReferenced);

public sealed record CreateSupplierRequest(
    string SupplierCode, string Name, int? CityCode, string? Province, string? Country,
    string? Phone, string? ContactPerson, decimal? CreditLimit, string? PaymentTerms, string Reason);

public sealed record CreateContactRequest(
    string FirstName, string? Initial, string LastName, string? JobTitle, string? Phone, string Reason);

public sealed record CreateDoctorRequest(
    string Name, string? Address, int? CityCode, string? Province, string? Country,
    string? Phone, string? PostalCode, string Reason);

public sealed record DeactivateBranchRequest(string Reason, string? TargetBranchCode);

public sealed record CreateSkuRequest(
    string Sku, string Name, string DepartmentCode, string ClassCode, string CategoryCode,
    string SupplierCode, string BrandCode, string? MaterialCode,
    bool LotTracked, bool RetailPriceFlag, bool WholesalePriceFlag, string Reason);

public sealed record UpdateSkuRequest(
    string Name, string DepartmentCode, string ClassCode, string CategoryCode,
    string SupplierCode, string BrandCode, string? MaterialCode,
    bool LotTracked, bool RetailPriceFlag, bool WholesalePriceFlag, string Reason);

public sealed record RetireSkuRequest(string Reason, bool ConfirmOnHand);

public sealed record SetPricesRequest(
    decimal? RetailPrice, decimal? LeastSellingPrice, decimal? RetailMarkdownAmount,
    double? RetailMarkdownPercent, decimal? SuggestedRetailPrice,
    decimal? GradeA, decimal? GradeB, decimal? GradeC, string Reason);

public sealed record ChangeRoleRequest(string Role, string Reason);

public sealed record SetBranchRequest(string? BranchCode, string Reason);

public sealed record CurrentUserResponse(
    string Username,
    string? DisplayName,
    string? Branch,
    IReadOnlyList<string> Permissions);

public sealed record RenameBranchRequest(string Name, string? ExpectedCurrentName = null);

/// <summary>Requires the Idempotency-Key header on financial endpoints.</summary>
public sealed class IdempotencyKeyFilter : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(
        EndpointFilterInvocationContext context,
        EndpointFilterDelegate next)
    {
        var http = context.HttpContext;
        var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();

        if (string.IsNullOrWhiteSpace(key))
        {
            return Results.Problem(new ProblemDetails
            {
                Type = Problems.IdempotencyKeyRequired,
                Title = "Idempotency key required",
                Status = StatusCodes.Status400BadRequest,
                Detail = "This endpoint requires an Idempotency-Key header.",
            });
        }

        return await next(context);
    }
}

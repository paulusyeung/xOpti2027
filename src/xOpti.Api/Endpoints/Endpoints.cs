using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using xOpti.Application.Authorization;
using xOpti.Application.Analytics;
using xOpti.Application.Cash;
using xOpti.Application.Claims;
using xOpti.Application.Customers;
using xOpti.Application.Common;
using xOpti.Application.Identity.ListBranches;
using xOpti.Application.Identity.Staff;
using xOpti.Application.Inventory.AdjustStock;
using xOpti.Application.Inventory.Availability;
using xOpti.Application.Inventory.Documents;
using xOpti.Application.Inventory.IssueStock;
using xOpti.Application.Inventory.Reconciliation;
using xOpti.Application.Inventory.Summaries;
using xOpti.Application.Inventory.StockTake;
using xOpti.Application.Inventory.TransferStock;
using xOpti.Application.Inventory.Catalogue;
using xOpti.Application.Inventory.Valuation;
using xOpti.Application.Purchasing.ReceiveStock;
using xOpti.Application.Purchasing.RejectStock;
using xOpti.Application.Purchasing.SupplierDocuments;
using xOpti.Application.Inventory.GetInventorySummary;
using xOpti.Application.Reference;
using xOpti.Application.Sales.Documents;
using xOpti.Application.Sales.OrderEntry;
using xOpti.Application.Optical;
using xOpti.Application.Payments;
using xOpti.Application.Reporting;
using xOpti.Application.Wholesale;
using xOpti.Application.Prescriptions;
using xOpti.Application.Sales.Retail;
using xOpti.Application.Settings;
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
            UserManager<xOpti.Infrastructure.Identity.XoptiUser> users,
            xOpti.Application.Identity.ILegacyStaffAuthenticator legacyStaff,
            CancellationToken cancellationToken) =>
        {
            // Legacy staff authentication is the production path: staff_code +
            // staff.password, with job_title mapped to the approved app role.
            var staff = await legacyStaff.AuthenticateAsync(
                request.Username ?? string.Empty, request.Password ?? string.Empty,
                cancellationToken);
            if (staff is not null)
            {
                if (staff.Role is null)
                {
                    return InvalidCredentials();
                }

                var staffUser = await users.FindByNameAsync(staff.StaffCode);
                if (staffUser is null)
                {
                    staffUser = new xOpti.Infrastructure.Identity.XoptiUser
                    {
                        UserName = staff.StaffCode,
                        DisplayName = staff.DisplayName,
                        LegacyLevel = staff.SecurityLevel,
                        ResetRequired = false,
                        EmailConfirmed = false,
                    };
                    var created = await users.CreateAsync(staffUser);
                    if (!created.Succeeded)
                    {
                        return InvalidCredentials();
                    }
                }

                if (staffUser.Disabled)
                {
                    return InvalidCredentials();
                }

                staffUser.DisplayName = staff.DisplayName;
                staffUser.LegacyLevel = staff.SecurityLevel;
                staffUser.ResetRequired = false;
                var updated = await users.UpdateAsync(staffUser);
                if (!updated.Succeeded)
                {
                    return InvalidCredentials();
                }

                var roles = await users.GetRolesAsync(staffUser);
                foreach (var existing in roles.Where(role => role != staff.Role))
                {
                    await users.RemoveFromRoleAsync(staffUser, existing);
                }
                if (!roles.Contains(staff.Role))
                {
                    var added = await users.AddToRoleAsync(staffUser, staff.Role);
                    if (!added.Succeeded)
                    {
                        return InvalidCredentials();
                    }
                }

                await signInManager.SignInAsync(staffUser, isPersistent: false);
                return Results.Ok(new
                {
                    username = staffUser.UserName,
                    displayName = staffUser.DisplayName,
                });
            }

            // Non-staff application accounts (administrative/reset accounts)
            // continue to use the Identity password path.
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

        v1.MapPost("/admin/import", async (
            ImportRequest request, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ImportMasterDataCommand(request.Kind, request.Csv, request.DryRun, request.Reason),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<ImportResultDto>();

        v1.MapGet("/admin/preferences", async (
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetPreferencesQuery(), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<PreferenceSettingsDto>();

        v1.MapPut("/admin/preferences", async (
            UpdatePreferencesRequest request, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new UpdatePreferencesCommand(
                request.ProductName, request.UserName, request.UserAddress, request.OwnerName,
                request.OwnerAddress, request.GstNumber, request.PstNumber,
                request.TaxARate, request.TaxBRate, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<PreferencesDto>();

        v1.MapGet("/inventory/{sku}/valuation", async (
            string sku, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetInventoryValuationQuery(sku), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<InventoryValuationDto>();

        v1.MapGet("/inventory/{sku}/availability", async (
            string sku, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetSkuAvailabilityQuery(sku), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<SkuAvailabilityDto>();

        v1.MapGet("/inventory/{sku}/movements", async (
            string sku, string? cursor, int? pageSize,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListSkuMovementsQuery(sku, cursor, pageSize ?? 50), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<PagedResult<MovementDto>>();

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

        v1.MapGet("/purchasing/documents/{txNumber}", async (
            string txNumber, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetSupplierDocumentQuery(txNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryReceive}")
        .Produces<SupplierDocumentDto>();

        v1.MapGet("/purchasing/suppliers/{code}/activity", async (
            string code, DateOnly from, DateOnly to, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetSupplierActivityQuery(code, from, to), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryReceive}")
        .Produces<SupplierActivityDto>();

        v1.MapGet("/wholesale/invoices/{txNumber}/packing-list", async (
            string txNumber, bool? includePrices, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetWholesalePackingListQuery(
                txNumber, includePrices ?? false), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<WholesalePackingListDto>();

        v1.MapPost("/wholesale/invoices/{txNumber}/packing-list/prints", async (
            string txNumber, WholesalePackingListPrintRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new PrintWholesalePackingListCommand(
                txNumber, request.IncludePrices, request.Reprint, request.TerminalCode,
                request.Reason), cancellationToken);
            return Results.File(result.Content, result.ContentType, result.FileName);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}");

        v1.MapGet("/wholesale/customers/{customerId:int}/balance", async (
            int customerId, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetWholesaleBalanceQuery(customerId), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<WholesaleBalanceDto>();

        v1.MapGet("/wholesale/customers/{customerId:int}/statement", async (
            int customerId, DateOnly from, DateOnly to, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetWholesaleStatementQuery(customerId, from, to), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<WholesaleStatementDto>();

        v1.MapGet("/wholesale/customers/{customerId:int}/statement/render", async (
            int customerId, DateOnly from, DateOnly to, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetWholesaleStatementRenderQuery(customerId, from, to), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<WholesaleStatementRenderDto>();

        v1.MapPost("/wholesale/customers/{customerId:int}/statement/prints", async (
            int customerId, WholesaleStatementPrintRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new PrintWholesaleStatementCommand(
                customerId, request.From, request.To, request.Reprint,
                request.TerminalCode, request.Reason), cancellationToken);
            return Results.File(result.Content, result.ContentType, result.FileName);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}");

        v1.MapGet("/wholesale/invoices/{txNumber}/returnable", async (
            string txNumber, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetWholesaleReturnableQuery(txNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<WholesaleReturnableInvoiceDto>();

        v1.MapGet("/wholesale/returns/{txNumber}/render", async (
            string txNumber, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetWholesaleReturnRenderQuery(txNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<WholesaleReturnRenderDto>();

        v1.MapPost("/wholesale/returns/{txNumber}/prints", async (
            string txNumber, WholesaleReturnPrintRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new PrintWholesaleReturnCommand(
                txNumber, request.Reprint, request.TerminalCode, request.Reason),
                cancellationToken);
            return Results.File(result.Content, result.ContentType, result.FileName);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}");

        v1.MapGet("/wholesale/returns", async (
            int? customerId, string? status, string? cursor, int? pageSize,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ListWholesaleReturnsQuery(
                customerId, status, cursor, pageSize ?? 25), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<PagedResult<WholesaleReturnDto>>();

        v1.MapGet("/wholesale/returns/{txNumber}", async (
            string txNumber, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetWholesaleReturnQuery(txNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<WholesaleReturnDto>();

        v1.MapPost("/wholesale/returns", async (
            HttpContext http, WholesaleReturnWriteRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new CreateWholesaleReturnCommand(
                request.OriginalInvoiceNumber, request.StaffCode, request.Lines,
                request.Tenders, request.Reason, key), cancellationToken);
            return Results.Created($"/api/v1/wholesale/returns/{result.TxNumber}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<WholesaleReturnDto>(StatusCodes.Status201Created);

        v1.MapPut("/wholesale/returns/{txNumber}", async (
            string txNumber, WholesaleReturnWriteRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new UpdateWholesaleReturnCommand(
                txNumber, request.OriginalInvoiceNumber, request.StaffCode, request.Lines,
                request.Tenders, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<WholesaleReturnDto>();

        v1.MapPost("/wholesale/returns/{txNumber}/post", async (
            string txNumber, HttpContext http, WholesaleReturnPostRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new PostWholesaleReturnCommand(
                txNumber, request.Tenders, request.Reason, key), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<WholesaleReturnDto>();

        v1.MapGet("/wholesale/invoices", async (
            int? customerId, string? status, string? cursor, int? pageSize,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ListWholesaleInvoicesQuery(
                customerId, status, cursor, pageSize ?? 25), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<PagedResult<WholesaleInvoiceDto>>();

        v1.MapGet("/wholesale/invoices/{txNumber}", async (
            string txNumber, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetWholesaleInvoiceQuery(txNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<WholesaleInvoiceDto>();

        v1.MapPost("/wholesale/invoices", async (
            HttpContext http, WholesaleInvoiceWriteRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new CreateWholesaleInvoiceCommand(
                request.CustomerId, request.StaffCode, request.Lines, request.Tenders,
                request.Shipping, request.Reason, key), cancellationToken);
            return Results.Created($"/api/v1/wholesale/invoices/{result.TxNumber}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<WholesaleInvoiceDto>(StatusCodes.Status201Created);

        v1.MapGet("/wholesale/invoices/{txNumber}/backorders", async (
            string txNumber, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetWholesaleBackordersQuery(txNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<IReadOnlyList<WholesaleBackorderDto>>();

        v1.MapGet("/wholesale/invoices/{txNumber}/render", async (
            string txNumber, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetWholesaleInvoiceRenderQuery(txNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<WholesaleInvoiceRenderDto>();

        v1.MapPost("/wholesale/invoices/{txNumber}/prints", async (
            string txNumber, WholesaleInvoicePrintRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new PrintWholesaleInvoiceCommand(
                txNumber, request.Reprint, request.TerminalCode, request.Reason),
                cancellationToken);
            return Results.File(result.Content, result.ContentType, result.FileName);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}");

        v1.MapPost("/wholesale/invoices/{txNumber}/post", async (
            string txNumber, HttpContext http, WholesaleInvoicePostRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new PostWholesaleInvoiceCommand(
                txNumber, request.Tenders, request.Reason, key), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<WholesaleInvoiceDto>();

        v1.MapPut("/wholesale/invoices/{txNumber}", async (
            string txNumber, WholesaleInvoiceWriteRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new UpdateWholesaleInvoiceCommand(
                txNumber, request.CustomerId, request.StaffCode, request.Lines,
                request.Tenders, request.Shipping, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<WholesaleInvoiceDto>();

        v1.MapGet("/wholesale/price-lists", async (
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListWholesalePriceListsQuery(), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<IReadOnlyList<WholesalePriceListDto>>();

        v1.MapPost("/wholesale/price-lists", async (
            PublishWholesalePriceListRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new PublishWholesalePriceListCommand(request.Input, request.Reason),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<WholesalePriceListDto>();

        v1.MapPost("/wholesale/price-lists/import-legacy", async (
            ReasonRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ImportLegacyWholesalePricesCommand(request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<int>();

        v1.MapGet("/wholesale/customers/{customerId:int}/price", async (
            int customerId, string sku, decimal? unitPrice, string? overrideReason,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetWholesalePriceQuoteQuery(
                customerId, sku, unitPrice, overrideReason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<WholesalePriceQuoteDto>();

        v1.MapGet("/wholesale/documents/{txNumber}/lines", async (
            string txNumber, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetWholesaleDocumentLinesQuery(txNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<IReadOnlyList<WholesaleDocumentLineDto>>();

        v1.MapPost("/reports/refresh", async (
            ReasonRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new RefreshReportingReadModelsCommand(request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<bool>();

        v1.MapGet("/reports", async (
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ListReportsQuery(), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<IReadOnlyList<ReportCatalogueDto>>();

        v1.MapGet("/reports/{reportId}", async (
            string reportId, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetReportMetadataQuery(reportId), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<ReportCatalogueDto>();

        v1.MapPost("/reports/{reportId}/preview", async (
            string reportId, ReportParameterRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new PreviewReportQuery(
                reportId, request.Parameters), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<ReportPreviewDto>();

        v1.MapPost("/reports/{reportId}/print", async (
            string reportId, ReportPrintRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GenerateReportCommand(
                reportId, request.Parameters, request.Duplicate, request.TerminalCode,
                request.Reason), cancellationToken);
            return Results.File(result.Content, result.ContentType, result.FileName);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}");

        v1.MapPost("/reports/{reportId}/export", async (
            string reportId, ReportExportRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ExportReportCommand(
                reportId, request.Parameters, request.Reason), cancellationToken);
            return Results.File(result.Content, result.ContentType, result.FileName);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}");

        v1.MapGet("/analytics/views", async (
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListAnalyticsViewsQuery(), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<IReadOnlyList<AnalyticsViewDefinition>>();

        v1.MapGet("/analytics/views/{viewKey}", async (
            string viewKey, string? from, string? to, string? branch, string? staff,
            string? department, string? classCode, string? category,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetAnalyticsFeedQuery(
                viewKey, from, to, branch, staff, department, classCode, category),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<AnalyticsFeedDto>();

        v1.MapGet("/analytics/views/{viewKey}/export", async (
            string viewKey, string? from, string? to, string? branch, string? staff,
            string? department, string? classCode, string? category, string? reason,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ExportAnalyticsFeedQuery(
                viewKey, from, to, branch, staff, department, classCode, category,
                reason ?? "analytics export"), cancellationToken);
            return Results.File(result.Content, result.ContentType, result.FileName);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}");

        v1.MapGet("/analytics/saved", async (
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListSavedAnalyticsViewsQuery(), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<IReadOnlyList<AnalyticsViewDto>>();

        v1.MapGet("/analytics/saved/{id:long}", async (
            long id, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetSavedAnalyticsViewQuery(id), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<AnalyticsViewDto>();

        v1.MapPost("/analytics/saved", async (
            SaveAnalyticsViewRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new SaveAnalyticsViewCommand(
                request.ViewKey, request.Name, request.IsShared, request.ConfigJson,
                request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<AnalyticsViewDto>();

        v1.MapDelete("/analytics/saved/{id:long}", async (
            long id, string? reason, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new DeleteAnalyticsViewCommand(
                id, reason ?? "delete saved view"), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<bool>();

        v1.MapGet("/wholesale/accounts/{customerId:int}", async (
            int customerId, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetWholesaleAccountQuery(customerId), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.WholesaleInvoicePost}")
        .Produces<WholesaleAccountDto>();

        v1.MapPut("/wholesale/accounts/{customerId:int}", async (
            int customerId, WholesaleAccountWriteRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new SaveWholesaleAccountCommand(
                customerId, request.Input, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<WholesaleAccountDto>();

        v1.MapGet("/claims/plans", async (
            bool? currentOnly, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListInsurancePlansQuery(currentOnly ?? true), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<IReadOnlyList<PlanDto>>();

        v1.MapPost("/claims/plans", async (
            CreateInsurancePlanRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new CreateInsurancePlanCommand(
                new CreatePlanInput(request.PlanCode, request.Name, request.PayerName,
                    request.Rules), request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<PlanDto>();

        v1.MapGet("/claims/members", async (
            int customerId, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetInsuranceMembersQuery(customerId), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<IReadOnlyList<MemberDto>>();

        v1.MapPost("/claims/members", async (
            AssignInsuranceMemberRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new AssignInsuranceMemberCommand(
                request.CustomerId, request.PlanId, request.MemberNumber, request.GroupNumber,
                request.EffectiveFrom, request.EffectiveTo, request.EligibilityNote,
                request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<MemberDto>();

        v1.MapPost("/claims", async (
            CreateClaimRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new CreateClaimCommand(
                new CreateClaimInput(request.InvoiceTxNumber, request.MemberId,
                    request.InvoiceRowNumbers), request.Reason), cancellationToken);
            return Results.Created($"/api/v1/claims/{result.Id}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<ClaimDto>(StatusCodes.Status201Created);

        v1.MapGet("/claims", async (
            string? invoiceTxNumber, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListClaimsQuery(invoiceTxNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<IReadOnlyList<ClaimDto>>();

        v1.MapGet("/claims/reconciliation", async (
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetClaimReconciliationQuery(), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<IReadOnlyList<ClaimReconciliationDto>>();

        v1.MapGet("/claims/{claimId:long}/receipt", async (
            long claimId, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetClaimReceiptQuery(claimId), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<ClaimReceiptDto>();

        v1.MapPost("/claims/{claimId:long}/receipt/prints", async (
            long claimId, ClaimReceiptPrintRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new PrintClaimReceiptCommand(
                claimId, request.Reprint, request.TerminalCode, request.Reason),
                cancellationToken);
            return Results.File(result.Content, result.ContentType, result.FileName);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}");

        v1.MapGet("/claims/rbic", async (
            DateOnly from, DateOnly to, string? reason, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ExportRbicCommand(
                from, to, reason ?? "RBIC export"), cancellationToken);
            return Results.File(result.Content, result.ContentType, result.FileName);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}");

        v1.MapGet("/claims/{claimId:long}", async (
            long claimId, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetClaimQuery(claimId), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<ClaimDto>();

        v1.MapPost("/claims/{claimId:long}/adjudicate", async (
            long claimId, AdjudicateClaimRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new AdjudicateClaimCommand(
                claimId, request.ApprovedAmount, request.Reason, request.Reference,
                request.Note), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<ClaimDto>();

        v1.MapPost("/claims/{claimId:long}/reject", async (
            long claimId, ReasonRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new RejectClaimCommand(claimId, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<ClaimDto>();

        v1.MapPost("/claims/{claimId:long}/resubmit", async (
            long claimId, ResubmitClaimRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ResubmitClaimCommand(
                claimId, request.Reason, request.Reference), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<ClaimDto>();

        v1.MapPost("/claims/{claimId:long}/payments", async (
            long claimId, ClaimPaymentRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new AddClaimPaymentCommand(
                claimId, request.Amount, request.Method, request.Reference, request.Reason),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<ClaimDto>();

        v1.MapGet("/customers", async (
            string? search, string? cursor, int? pageSize, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new SearchCustomersQuery(search, cursor, pageSize ?? 25), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<PagedResult<CustomerSummaryDto>>();

        v1.MapGet("/customers/duplicates", async (
            string? fullName, string? phone, string? email, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new FindCustomerDuplicatesQuery(fullName, phone, email), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<IReadOnlyList<CustomerDuplicateDto>>();

        v1.MapGet("/customers/{customerId:int}", async (
            int customerId, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetCustomerQuery(customerId), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<CustomerViewDto>();

        v1.MapPost("/customers", async (
            CustomerWriteRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new CreateCustomerCommand(
                request.Input, request.ConfirmDuplicate, request.Reason), cancellationToken);
            return Results.Created($"/api/v1/customers/{result.Customer.Id}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<CustomerViewDto>(StatusCodes.Status201Created);

        v1.MapPut("/customers/{customerId:int}", async (
            int customerId, CustomerWriteRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new UpdateCustomerCommand(
                customerId, request.Input, request.ConfirmDuplicate, request.Reason),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<CustomerViewDto>();

        v1.MapGet("/customers/{customerId:int}/prescriptions", async (
            int customerId, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetPrescriptionHistoryQuery(customerId), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.PrescriptionView}")
        .Produces<PrescriptionHistoryDto>();

        v1.MapPost("/customers/{customerId:int}/prescriptions/spectacle", async (
            int customerId, SpectaclePrescriptionRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new SaveSpectaclePrescriptionCommand(
                customerId, new SpectaclePrescriptionInput(request.IssuedOn, request.PrescriberId,
                    new SpectacleEyeValues(request.Right.Sphere, request.Right.Cylinder,
                        request.Right.Axis, request.Right.Add, request.Right.Prism,
                        request.Right.Base, request.Right.Pd),
                    new SpectacleEyeValues(request.Left.Sphere, request.Left.Cylinder,
                        request.Left.Axis, request.Left.Add, request.Left.Prism,
                        request.Left.Base, request.Left.Pd),
                    request.Notes), request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.PrescriptionEnter}")
        .Produces<PrescriptionHistoryDto>();

        v1.MapPost("/customers/{customerId:int}/prescriptions/contact", async (
            int customerId, ContactLensPrescriptionRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new SaveContactLensPrescriptionCommand(
                customerId, new ContactLensPrescriptionInput(request.IssuedOn, request.PrescriberId,
                    request.Brand, request.BaseCurve, request.Diameter, request.RightPower,
                    request.RightCylinder, request.RightAxis, request.LeftPower,
                    request.LeftCylinder, request.LeftAxis, request.ReplacementSchedule,
                    request.Notes), request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.PrescriptionEnter}")
        .Produces<PrescriptionHistoryDto>();

        v1.MapPost("/customers/{customerId:int}/prescriptions/verify", async (
            int customerId, VerifyPrescriptionRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new VerifyPrescriptionCommand(
                customerId, request.Type, request.VersionId, request.Note, request.Reason),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.PrescriptionEnter}")
        .Produces<PrescriptionHistoryDto>();

        v1.MapPost("/customers/{customerId:int}/medical-notes", async (
            int customerId, MedicalNoteRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new AddMedicalNoteCommand(customerId, request.Note, request.Reason),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.PrescriptionEnter}")
        .Produces<PrescriptionHistoryDto>();

        v1.MapPost("/customers/{customerId:int}/attachments", async (
            int customerId, HttpRequest http, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            if (!http.HasFormContentType)
                return Results.BadRequest("A multipart attachment upload is required.");
            var form = await http.ReadFormAsync(cancellationToken);
            var file = form.Files.GetFile("file");
            if (file is null) return Results.BadRequest("A file is required.");
            using var stream = new MemoryStream();
            await file.CopyToAsync(stream, cancellationToken);
            var result = await dispatcher.DispatchAsync(new UploadPatientAttachmentCommand(
                customerId, form["kind"].ToString(), form["prescriptionType"].ToString(),
                long.TryParse(form["versionId"], out var versionId) ? versionId : null,
                file.FileName, file.ContentType, stream.ToArray(),
                form["reason"].ToString()), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.PrescriptionEnter}")
        .Produces<PrescriptionHistoryDto>();

        v1.MapGet("/customers/attachments/{attachmentId:long}", async (
            long attachmentId, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetPatientAttachmentQuery(attachmentId), cancellationToken);
            return Results.File(result.Content, result.Metadata.ContentType,
                result.Metadata.FileName);
        })
        .RequireAuthorization($"perm:{PermissionNames.PrescriptionView}");

        v1.MapGet("/customers/{customerId:int}/account", async (
            int customerId, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetCustomerAccountQuery(customerId), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<CustomerBalanceDto>();

        v1.MapGet("/customers/{customerId:int}/history", async (
            int customerId, DateOnly? from, DateOnly? to, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetCustomerHistoryQuery(customerId, from, to), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<CustomerHistoryDto>();

        v1.MapGet("/customers/{customerId:int}/statement", async (
            int customerId, DateOnly from, DateOnly to, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetCustomerStatementQuery(customerId, from, to), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<CustomerStatementDto>();

        v1.MapPost("/customers/merge", async (
            MergeCustomersRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new MergeCustomersCommand(
                request.SourceId, request.TargetId, request.Phone, request.Email,
                request.FullName, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.MasterDataMaintain}")
        .Produces<CustomerViewDto>();

        v1.MapGet("/cash/sessions/open", async (
            string branchCode, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListOpenCashSessionsQuery(branchCode), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces<IReadOnlyList<CashSessionDto>>();

        v1.MapGet("/cash/sessions", async (
            string branchCode, DateOnly businessDate, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListCashSessionsQuery(branchCode, businessDate), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces<IReadOnlyList<CashSessionDto>>();

        v1.MapGet("/cash/sessions/{sessionId:long}", async (
            long sessionId, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetCashSessionQuery(sessionId), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces<CashSessionDetailDto>();

        v1.MapGet("/cash/sessions/{sessionId:long}/count-context", async (
            long sessionId, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetCashCountContextQuery(sessionId), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces<CashCountContextDto>();

        v1.MapPost("/cash/sessions", async (
            OpenCashSessionRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new OpenCashSessionCommand(
                request.BranchCode, request.TerminalCode, request.OpeningFloat, request.Reason),
                cancellationToken);
            return Results.Created($"/api/v1/cash/sessions/{result.Id}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces<CashSessionDto>(StatusCodes.Status201Created);

        v1.MapPost("/cash/sessions/{sessionId:long}/suspend", async (
            long sessionId, ReasonRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new SuspendCashSessionCommand(sessionId, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces<CashSessionDto>();

        v1.MapPost("/cash/sessions/{sessionId:long}/resume", async (
            long sessionId, ReasonRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ResumeCashSessionCommand(sessionId, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces<CashSessionDto>();

        v1.MapPost("/cash/sessions/{sessionId:long}/close", async (
            long sessionId, CloseCashSessionRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new CloseCashSessionCommand(
                sessionId, request.CountedCash, request.VarianceReason, request.Reason),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces<CashSessionDto>();

        v1.MapPost("/cash/sessions/{sessionId:long}/counts", async (
            long sessionId, CashCountRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new RecordCashCountCommand(
                sessionId, request.Kind, request.Amount, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces<CashSessionDetailDto>();

        v1.MapPost("/cash/sessions/{sessionId:long}/movements", async (
            long sessionId, CashMovementRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new RecordCashMovementCommand(
                sessionId, request.Kind, request.Amount, request.Reason,
                request.DestinationReference), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces<CashSessionDetailDto>();

        v1.MapGet("/cash/journal", async (
            string branchCode, DateOnly businessDate, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetCashJournalQuery(branchCode, businessDate), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<CashJournalDto>();

        v1.MapPost("/cash/daily-closes", async (
            FinalizeDailyCloseRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new FinalizeDailyCloseCommand(
                request.BranchCode, request.BusinessDate, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.ReportFinancial}")
        .Produces<CashJournalDto>();

        v1.MapGet("/sales/payment-methods", async (
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ListPaymentMethodsQuery(), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces<IReadOnlyList<PaymentMethodDto>>();

        v1.MapPost("/sales/invoices", async (
            HttpContext http, PostRetailInvoiceRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new PostRetailInvoiceCommand(
                request.CustomerId, request.StaffCode,
                request.Lines.Select(line => new RetailLineInput(line.Sku, line.Quantity,
                    line.UnitAmount, line.DiscountAmount, line.TaxCode)).ToList(),
                request.Tenders.Select(tender => new RetailTenderInput(
                    tender.Method, tender.Amount, tender.Reference, tender.OriginalPaymentLineNo)).ToList(),
                request.SessionId, request.Reason, key), cancellationToken);
            return Results.Created($"/api/v1/sales/documents/{result.TxNumber}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<SalesDocumentDto>(StatusCodes.Status201Created);

        v1.MapGet("/sales/invoices/{txNumber}/refundable", async (
            string txNumber, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetRefundableInvoiceQuery(txNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces<RefundableInvoiceDto>();

        v1.MapPost("/sales/refunds", async (
            HttpContext http, PostRetailRefundRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new PostRetailRefundCommand(
                request.OriginalTxNumber, request.StaffCode,
                request.Lines.Select(line => new RefundLineInput(
                    line.OriginalRowNo, line.Quantity, line.Restock)).ToList(),
                request.Replacements.Select(line => new RetailLineInput(line.Sku, line.Quantity,
                    line.UnitAmount, line.DiscountAmount, line.TaxCode)).ToList(),
                request.RefundTenders.Select(tender => new RetailTenderInput(
                    tender.Method, tender.Amount, tender.Reference, tender.OriginalPaymentLineNo)).ToList(),
                request.SaleTenders.Select(tender => new RetailTenderInput(
                    tender.Method, tender.Amount, tender.Reference)).ToList(),
                request.SessionId, request.Reason, key), cancellationToken);
            return Results.Created($"/api/v1/sales/documents/{result.TxNumber}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<SalesDocumentDto>(StatusCodes.Status201Created);

        v1.MapPost("/sales/orders", async (
            HttpContext http, CreateOrderRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new CreateOrderCommand(
                request.CustomerId, request.StaffCode, request.Lines.Select(line => new OrderLineInput(line.Sku, line.Quantity, line.UnitAmount, line.TaxCode, line.DiscountAmount)).ToList(),
                request.DepositAmount, request.Reason, key), cancellationToken);
            return Results.Created($"/api/v1/sales/orders/{result.TxNumber}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<SalesDocumentDto>(StatusCodes.Status201Created);

        v1.MapPut("/sales/orders/{txNumber}", async (
            string txNumber, UpdateOrderRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new UpdateOrderCommand(
                txNumber, request.CustomerId, request.StaffCode,
                request.Lines.Select(line => new OrderLineInput(line.Sku, line.Quantity, line.UnitAmount, line.TaxCode, line.DiscountAmount)).ToList(), request.DepositAmount, request.Reason),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<SalesDocumentDto>();

        v1.MapGet("/sales/orders/{txNumber}/optical", async (
            string txNumber, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new GetOpticalOrderQuery(txNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<OpticalOrderDto>();

        v1.MapPut("/sales/orders/{txNumber}/optical", async (
            string txNumber, SaveOpticalOrderRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new SaveOpticalOrderCommand(
                txNumber, request.Frames, request.Lenses, request.Contacts, request.Reason),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<OpticalOrderDto>();

        v1.MapPost("/sales/orders/{txNumber}/optical/status", async (
            string txNumber, OpticalStatusRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new RecordOpticalStatusCommand(
                txNumber, request.Status, request.Reference, request.Notes, request.Reason),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<OpticalOrderDto>();

        v1.MapPost("/sales/orders/{txNumber}/deposits", async (
            HttpContext http, string txNumber, AddOrderDepositRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new AddOrderDepositCommand(
                txNumber, request.Amount, request.Method, request.Reference, request.Reason, key),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<SalesDocumentDto>();

        v1.MapPost("/sales/orders/{txNumber}/cancel", async (
            string txNumber, ReasonRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new CancelOrderCommand(txNumber, request.Reason), cancellationToken);
            return Results.Ok(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<bool>();

        v1.MapPost("/sales/orders/{txNumber}/convert", async (
            HttpContext http, string txNumber, ConvertOrderRequest request,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new ConvertOrderCommand(
                txNumber, request.Tenders.Select(row => new TenderInput(row.Method, row.Amount, row.Reference)).ToList(),
                request.SessionId, request.Reason, key), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<SalesDocumentDto>();

        v1.MapGet("/sales/orders", async (
            int? customerId, string? status, string? cursor, int? pageSize,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListOrdersQuery(customerId, status, cursor, pageSize ?? 25), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<PagedResult<SalesDocumentDto>>();

        v1.MapGet("/sales/customers", async (
            string? search, int? limit, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new SearchPosCustomersQuery(search, limit ?? 20), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<IReadOnlyList<CustomerLookupDto>>();

        v1.MapGet("/sales/items", async (
            string? search, int? limit, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new SearchPosItemsQuery(search, limit ?? 20), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<IReadOnlyList<SalesItemLookupDto>>();

        v1.MapGet("/sales/order-entry/context", async (
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetPosContextQuery(), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<PosContextDto>();

        v1.MapPost("/sales/documents/{txNumber}/prints", async (
            string txNumber, PrintDocumentRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new PrintPosDocumentCommand(
                txNumber, request.Reprint, request.Format, request.TerminalCode, request.Reason),
                cancellationToken);
            return Results.File(result.Content, result.ContentType, result.FileName);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .Produces(StatusCodes.Status200OK, contentType: "application/pdf");

        v1.MapGet("/sales/documents/{txNumber}", async (
            string txNumber, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetSalesDocumentQuery(txNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<SalesDocumentDto>();

        v1.MapGet("/sales/documents", async (
            int? customerId, string? status, string? cursor, int? pageSize,
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ListSalesDocumentsQuery(customerId, status, cursor, pageSize ?? 25), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesOrderCreate}")
        .Produces<PagedResult<SalesDocumentDto>>();

        v1.MapPost("/inventory/issues", async (
            HttpContext http,
            IssueStockRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new IssueStockCommand(
                request.Sku, request.BranchCode, request.Quantity, request.Reason, key), cancellationToken);
            return Results.Created($"/api/v1/inventory/issues/{result.TxNumber}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<IssueStockResult>(StatusCodes.Status201Created);

        v1.MapGet("/inventory/summaries", async (
            DateOnly from, DateOnly to, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetInventorySummariesQuery(from, to), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<InventorySummariesDto>();

        v1.MapGet("/inventory/reconciliation", async (
            IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetInventoryReconciliationQuery(), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<InventoryReconciliationDto>();

        v1.MapPost("/inventory/stock-takes", async (
            CreateStockTakeRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new CreateStockTakeCommand(request.Name, request.BranchCode, request.Reason),
                cancellationToken);
            return Results.Created($"/api/v1/inventory/stock-takes/{result.Id}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<StockTakeDto>(StatusCodes.Status201Created);

        v1.MapPost("/inventory/stock-takes/{id}/counts", async (
            int id, ImportCountsRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ImportStockTakeCountsCommand(id, request.Csv, request.DryRun, request.Reason),
                cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<ImportStockTakeCountsResult>();

        v1.MapGet("/inventory/stock-takes/{id}/variances", async (
            int id, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetStockTakeVariancesQuery(id), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<StockTakeVarianceDto>();

        v1.MapPost("/inventory/stock-takes/{id}/approve", async (
            int id, ApproveStockTakeRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new ApproveStockTakeCommand(id, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<StockTakeVarianceDto>();

        v1.MapPost("/inventory/stock-takes/{id}/post", async (
            int id, PostStockTakeRequest request, IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new PostStockTakeVariancesCommand(id, request.Reason), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<PostStockTakeVariancesResult>();

        v1.MapGet("/inventory/documents/{txNumber}", async (
            string txNumber, IRequestDispatcher dispatcher, CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new GetStockDocumentQuery(txNumber), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .Produces<StockDocumentDto>();

        v1.MapPost("/inventory/transfers", async (
            HttpContext http,
            TransferStockRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new TransferStockCommand(
                request.Sku, request.FromBranch, request.ToBranch,
                request.Quantity, request.Reason, key), cancellationToken);
            return Results.Created($"/api/v1/inventory/transfers/{result.TransferId}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<TransferStockResult>(StatusCodes.Status201Created);

        v1.MapPost("/inventory/adjustments", async (
            HttpContext http,
            AdjustStockRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new AdjustStockCommand(
                request.Sku, request.BranchCode, request.QuantityDelta,
                request.ReasonCode, request.Reason, request.AllowNegative, key), cancellationToken);
            return Results.Created($"/api/v1/inventory/adjustments/{result.TxNumber}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryAdjust}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<AdjustStockResult>(StatusCodes.Status201Created);

        v1.MapPost("/purchasing/receipts", async (
            HttpContext http,
            ReceiveStockRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var lines = request.Lines.Select(line => new ReceiveStockLine(
                line.Sku, line.LotNo, line.Quantity, line.UnitCost,
                line.GstAmount, line.PstAmount, line.TaxCode)).ToList();
            var result = await dispatcher.DispatchAsync(
                new ReceiveStockCommand(request.SupplierCode, request.BranchCode, lines, key, request.Reason),
                cancellationToken);
            return Results.Created($"/api/v1/purchasing/receipts/{result.TxNumber}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryReceive}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<ReceiveStockResult>(StatusCodes.Status201Created);

        v1.MapPost("/purchasing/rejections", async (
            HttpContext http,
            RejectStockRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var lines = request.Lines.Select(line => new RejectStockLine(
                line.Sku, line.LotNo, line.Quantity, line.UnitCost,
                line.GstAmount, line.PstAmount, line.TaxCode)).ToList();
            var result = await dispatcher.DispatchAsync(
                new RejectStockCommand(request.SupplierCode, request.BranchCode,
                    request.OriginalTxNumber, lines, key, request.Reason), cancellationToken);
            return Results.Created($"/api/v1/purchasing/rejections/{result.TxNumber}", result);
        })
        .RequireAuthorization($"perm:{PermissionNames.InventoryReceive}")
        .AddEndpointFilter<IdempotencyKeyFilter>()
        .Produces<RejectStockResult>(StatusCodes.Status201Created);

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

public sealed record ApproveStockTakeRequest(string Reason);

public sealed record PostStockTakeRequest(string Reason);

public sealed record ImportCountsRequest(string Csv, bool DryRun, string Reason);

public sealed record WholesaleInvoicePrintRequest(
    bool Reprint, string? TerminalCode, string Reason);

public sealed record WholesaleInvoicePostRequest(
    IReadOnlyList<WholesaleTenderInput>? Tenders, string Reason);

public sealed record WholesalePackingListPrintRequest(
    bool IncludePrices, bool Reprint, string? TerminalCode, string Reason);

public sealed record WholesaleStatementPrintRequest(
    DateOnly From, DateOnly To, bool Reprint, string? TerminalCode, string Reason);

public sealed record WholesaleReturnPrintRequest(
    bool Reprint, string? TerminalCode, string Reason);

public sealed record WholesaleReturnWriteRequest(
    string OriginalInvoiceNumber, string StaffCode,
    IReadOnlyList<WholesaleReturnLineInput> Lines, IReadOnlyList<WholesaleTenderInput> Tenders,
    string Reason);

public sealed record WholesaleReturnPostRequest(
    IReadOnlyList<WholesaleTenderInput>? Tenders, string Reason);

public sealed record WholesaleInvoiceWriteRequest(
    int CustomerId, string StaffCode, IReadOnlyList<WholesaleLineInput> Lines,
    IReadOnlyList<WholesaleTenderInput> Tenders, WholesaleShippingInput Shipping,
    string Reason);

public sealed record PublishWholesalePriceListRequest(
    PublishWholesalePriceListInput Input, string Reason);

public sealed record ReportParameterRequest(
    IReadOnlyDictionary<string, string?> Parameters);

public sealed record ReportPrintRequest(
    IReadOnlyDictionary<string, string?> Parameters, bool Duplicate,
    string? TerminalCode, string Reason);

public sealed record ReportExportRequest(
    IReadOnlyDictionary<string, string?> Parameters, string Reason);

public sealed record SaveAnalyticsViewRequest(
    string ViewKey, string Name, bool IsShared, string ConfigJson, string Reason);

public sealed record WholesaleAccountWriteRequest(
    WholesaleAccountInput Input, string Reason);

public sealed record ClaimReceiptPrintRequest(
    bool Reprint, string? TerminalCode, string Reason);

public sealed record CreateInsurancePlanRequest(
    string PlanCode, string Name, string PayerName,
    IReadOnlyList<CoverageRuleInput> Rules, string Reason);

public sealed record AssignInsuranceMemberRequest(
    int CustomerId, long PlanId, string MemberNumber, string? GroupNumber,
    DateOnly EffectiveFrom, DateOnly? EffectiveTo, string? EligibilityNote, string Reason);

public sealed record CreateClaimRequest(
    string InvoiceTxNumber, long MemberId, IReadOnlyList<int> InvoiceRowNumbers, string Reason);

public sealed record AdjudicateClaimRequest(
    decimal ApprovedAmount, string Reason, string? Reference, string? Note);

public sealed record ResubmitClaimRequest(string Reason, string? Reference);

public sealed record ClaimPaymentRequest(
    decimal Amount, string Method, string? Reference, string Reason);

public sealed record SaveOpticalOrderRequest(
    IReadOnlyList<FrameDetailInput> Frames, IReadOnlyList<LensDetailInput> Lenses,
    IReadOnlyList<ContactDetailInput> Contacts, string Reason);

public sealed record OpticalStatusRequest(
    string Status, string? Reference, string? Notes, string Reason);

public sealed record SpectacleEyeRequest(
    decimal? Sphere, decimal? Cylinder, int? Axis, decimal? Add, decimal? Prism,
    decimal? Base, decimal? Pd);

public sealed record SpectaclePrescriptionRequest(
    DateTimeOffset IssuedOn, int? PrescriberId, SpectacleEyeRequest Right,
    SpectacleEyeRequest Left, string? Notes, string Reason);

public sealed record ContactLensPrescriptionRequest(
    DateTimeOffset IssuedOn, int? PrescriberId, string? Brand, decimal? BaseCurve,
    decimal? Diameter, decimal? RightPower, decimal? RightCylinder, int? RightAxis,
    decimal? LeftPower, decimal? LeftCylinder, int? LeftAxis,
    string? ReplacementSchedule, string? Notes, string Reason);

public sealed record VerifyPrescriptionRequest(
    string Type, long VersionId, string? Note, string Reason);

public sealed record MedicalNoteRequest(string Note, string Reason);

public sealed record CustomerWriteRequest(
    CustomerInput Input, bool ConfirmDuplicate, string Reason);

public sealed record MergeCustomersRequest(
    int SourceId, int TargetId, string? Phone, string? Email, string? FullName, string Reason);

public sealed record PrintDocumentRequest(
    bool Reprint, string Format, string? TerminalCode, string Reason);

public sealed record OpenCashSessionRequest(
    string BranchCode, string TerminalCode, decimal OpeningFloat, string Reason);

public sealed record CloseCashSessionRequest(
    decimal CountedCash, string? VarianceReason, string Reason);

public sealed record CashCountRequest(string Kind, decimal Amount, string? Reason);

public sealed record CashMovementRequest(
    string Kind, decimal Amount, string Reason, string? DestinationReference);

public sealed record FinalizeDailyCloseRequest(
    string BranchCode, DateOnly BusinessDate, string Reason);

public sealed record AddOrderDepositRequest(
    decimal Amount, string Method, string? Reference, string Reason);

public sealed record RetailLineRequest(
    string Sku, int Quantity, decimal UnitAmount, decimal DiscountAmount, string TaxCode);

public sealed record RetailTenderRequest(
    string Method, decimal Amount, string? Reference, double? OriginalPaymentLineNo = null);

public sealed record PostRetailInvoiceRequest(
    int CustomerId, string StaffCode, IReadOnlyList<RetailLineRequest> Lines,
    IReadOnlyList<RetailTenderRequest> Tenders, long? SessionId, string Reason);

public sealed record RefundLineRequest(int OriginalRowNo, int Quantity, bool Restock);

public sealed record PostRetailRefundRequest(
    string OriginalTxNumber, string StaffCode, IReadOnlyList<RefundLineRequest> Lines,
    IReadOnlyList<RetailLineRequest> Replacements, IReadOnlyList<RetailTenderRequest> RefundTenders,
    IReadOnlyList<RetailTenderRequest> SaleTenders, long? SessionId, string Reason);

public sealed record OrderLineRequest(
    string Sku, int Quantity, decimal? UnitAmount, string TaxCode, decimal DiscountAmount);

public sealed record CreateOrderRequest(
    int CustomerId, string StaffCode, IReadOnlyList<OrderLineRequest> Lines,
    decimal DepositAmount, string Reason);

public sealed record UpdateOrderRequest(
    int CustomerId, string StaffCode, IReadOnlyList<OrderLineRequest> Lines,
    decimal DepositAmount, string Reason);

public sealed record ConvertOrderRequest(
    IReadOnlyList<TenderRequest> Tenders, long? SessionId, string Reason);

public sealed record TenderRequest(string Method, decimal Amount, string? Reference);

public sealed record IssueStockRequest(string Sku, string BranchCode, int Quantity, string Reason);

public sealed record CreateStockTakeRequest(string Name, string? BranchCode, string Reason);

public sealed record TransferStockRequest(
    string Sku, string FromBranch, string ToBranch, int Quantity, string Reason);

public sealed record AdjustStockRequest(
    string Sku, string BranchCode, int QuantityDelta,
    string ReasonCode, string Reason, bool AllowNegative);

public sealed record RejectStockLineRequest(
    string Sku, string LotNo, int Quantity, decimal UnitCost,
    decimal GstAmount, decimal PstAmount, string TaxCode);

public sealed record RejectStockRequest(
    string SupplierCode, string BranchCode, string? OriginalTxNumber,
    string Reason, IReadOnlyList<RejectStockLineRequest> Lines);

public sealed record ReceiveStockLineRequest(
    string Sku, string LotNo, int Quantity, decimal UnitCost,
    decimal GstAmount, decimal PstAmount, string TaxCode);

public sealed record ReceiveStockRequest(
    string SupplierCode, string BranchCode, string Reason,
    IReadOnlyList<ReceiveStockLineRequest> Lines);

public sealed record CreateSkuRequest(
    string Sku, string Name, string DepartmentCode, string ClassCode, string CategoryCode,
    string SupplierCode, string BrandCode, string? MaterialCode,
    bool LotTracked, bool RetailPriceFlag, bool WholesalePriceFlag, string Reason);

public sealed record UpdateSkuRequest(
    string Name, string DepartmentCode, string ClassCode, string CategoryCode,
    string SupplierCode, string BrandCode, string? MaterialCode,
    bool LotTracked, bool RetailPriceFlag, bool WholesalePriceFlag, string Reason);

public sealed record RetireSkuRequest(string Reason, bool ConfirmOnHand);

public sealed record ImportRequest(ImportKind Kind, string Csv, bool DryRun, string Reason);

public sealed record UpdatePreferencesRequest(
    string ProductName, string UserName, string? UserAddress, string OwnerName, string? OwnerAddress,
    string? GstNumber, string? PstNumber, double TaxARate, double TaxBRate, string Reason);

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

using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Inventory.Catalogue;

public sealed record CatalogueItemDto(
    string Sku,
    string? Name,
    string DepartmentCode,
    string ClassCode,
    string CategoryCode,
    string SupplierCode,
    string BrandCode,
    string? MaterialCode,
    bool LotTracked,
    bool RetailPriceFlag,
    bool WholesalePriceFlag,
    int QtyOnHand);

public sealed record SkuPricesDto(
    string Sku,
    decimal? RetailPrice,
    decimal? LeastSellingPrice,
    decimal? RetailMarkdownAmount,
    double? RetailMarkdownPercent,
    decimal? SuggestedRetailPrice,
    decimal? GradeA,
    decimal? GradeB,
    decimal? GradeC);

public sealed record BarcodeTagDto(string Barcode, string Sku, string LabelText, bool Reprint);

public interface ICatalogueStore
{
    Task<CatalogueItemDto?> FindAsync(string sku, CancellationToken ct);

    /// <summary>Selection lookup: null when the SKU is retired (history still uses FindAsync).</summary>
    Task<CatalogueItemDto?> FindForSelectionAsync(string sku, CancellationToken ct);
    Task<IReadOnlyList<CatalogueItemDto>> PageAsync(string? search, string? afterSku, int limit, CancellationToken ct);
    Task<bool> SkuExistsAsync(string sku, CancellationToken ct);
    Task<bool> CategoryExistsAsync(string department, string @class, string category, CancellationToken ct);
    Task<bool> SupplierExistsAsync(string code, CancellationToken ct);
    Task<bool> BrandExistsAsync(string code, CancellationToken ct);
    Task CreateAsync(CatalogueItemDto item, CancellationToken ct);
    Task UpdateAsync(CatalogueItemDto item, CancellationToken ct);
    Task RetireAsync(string sku, string reason, string? actor, CancellationToken ct);
    Task<SkuPricesDto> GetPricesAsync(string sku, CancellationToken ct);
    Task SetPricesAsync(SkuPricesDto prices, CancellationToken ct);
    Task<BarcodeTagDto?> FindTagAsync(string sku, CancellationToken ct);
    Task<BarcodeTagDto> CreateTagAsync(string sku, CancellationToken ct);
}

public sealed record ListCatalogueQuery(string? Search, string? Cursor, int PageSize)
    : IQuery<PagedResult<CatalogueItemDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
    public string? AfterSku => Cursor is null ? null : KeysetCursor.Decode(Cursor);
}

public sealed class ListCatalogueHandler(ICatalogueStore store)
    : IRequestHandler<ListCatalogueQuery, PagedResult<CatalogueItemDto>>
{
    public async Task<PagedResult<CatalogueItemDto>> Handle(ListCatalogueQuery request, CancellationToken ct)
    {
        var rows = await store.PageAsync(request.Search, request.AfterSku, request.PageSize + 1, ct);
        var hasMore = rows.Count > request.PageSize;
        var page = hasMore ? rows.Take(request.PageSize).ToList() : rows.ToList();
        return new PagedResult<CatalogueItemDto>(page,
            hasMore ? KeysetCursor.Encode(page[^1].Sku) : null);
    }
}

public sealed record GetSkuQuery(string Sku) : IQuery<CatalogueItemDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed class GetSkuHandler(ICatalogueStore store) : IRequestHandler<GetSkuQuery, CatalogueItemDto>
{
    public async Task<CatalogueItemDto> Handle(GetSkuQuery request, CancellationToken ct) =>
        await store.FindAsync(request.Sku, ct)
        ?? throw new ValidationFailedException(new[]
        {
            new ValidationFieldError("Sku", "not-found", $"SKU '{request.Sku}' was not found."),
        });
}

public sealed record GetSkuPricesQuery(string Sku) : IQuery<SkuPricesDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed class GetSkuPricesHandler(ICatalogueStore store) : IRequestHandler<GetSkuPricesQuery, SkuPricesDto>
{
    public Task<SkuPricesDto> Handle(GetSkuPricesQuery request, CancellationToken ct) =>
        store.GetPricesAsync(request.Sku, ct);
}

public sealed record CreateSkuCommand(
    string Sku, string Name, string DepartmentCode, string ClassCode, string CategoryCode,
    string SupplierCode, string BrandCode, string? MaterialCode,
    bool LotTracked, bool RetailPriceFlag, bool WholesalePriceFlag, string Reason)
    : ICommand<CatalogueItemDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed record UpdateSkuCommand(
    string Sku, string Name, string DepartmentCode, string ClassCode, string CategoryCode,
    string SupplierCode, string BrandCode, string? MaterialCode,
    bool LotTracked, bool RetailPriceFlag, bool WholesalePriceFlag, string Reason)
    : ICommand<CatalogueItemDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed record RetireSkuCommand(string Sku, string Reason, bool ConfirmOnHand)
    : ICommand<CatalogueItemDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed record SetSkuPricesCommand(
    string Sku, decimal? RetailPrice, decimal? LeastSellingPrice,
    decimal? RetailMarkdownAmount, double? RetailMarkdownPercent,
    decimal? SuggestedRetailPrice, decimal? GradeA, decimal? GradeB, decimal? GradeC,
    string Reason)
    : ICommand<SkuPricesDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed record GenerateBarcodeTagCommand(string Sku, string Reason)
    : ICommand<BarcodeTagDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed record ReprintBarcodeTagCommand(string Sku)
    : IQuery<BarcodeTagDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed class SkuCommandValidator : AbstractValidator<CreateSkuCommand>
{
    public SkuCommandValidator()
    {
        RuleFor(x => x.Sku).NotEmpty().MaximumLength(13);
        RuleFor(x => x.Name).NotEmpty().MaximumLength(60);
        RuleFor(x => x.DepartmentCode).NotEmpty().MaximumLength(2);
        RuleFor(x => x.ClassCode).NotEmpty().MaximumLength(2);
        RuleFor(x => x.CategoryCode).NotEmpty().MaximumLength(2);
        RuleFor(x => x.SupplierCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.BrandCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class UpdateSkuCommandValidator : AbstractValidator<UpdateSkuCommand>
{
    public UpdateSkuCommandValidator()
    {
        RuleFor(x => x.Sku).NotEmpty();
        RuleFor(x => x.Name).NotEmpty().MaximumLength(60);
        RuleFor(x => x.DepartmentCode).NotEmpty().MaximumLength(2);
        RuleFor(x => x.ClassCode).NotEmpty().MaximumLength(2);
        RuleFor(x => x.CategoryCode).NotEmpty().MaximumLength(2);
        RuleFor(x => x.SupplierCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.BrandCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class RetireSkuCommandValidator : AbstractValidator<RetireSkuCommand>
{
    public RetireSkuCommandValidator()
    {
        RuleFor(x => x.Sku).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class SetSkuPricesCommandValidator : AbstractValidator<SetSkuPricesCommand>
{
    public SetSkuPricesCommandValidator()
    {
        RuleFor(x => x.Sku).NotEmpty();
        RuleFor(x => x.RetailPrice).Must(IsFourDecimal)
            .WithMessage("Prices allow at most four decimal places and cannot be negative.");
        RuleFor(x => x.LeastSellingPrice).Must(IsFourDecimal)
            .WithMessage("Prices allow at most four decimal places and cannot be negative.");
        RuleFor(x => x.RetailMarkdownAmount).Must(IsFourDecimal)
            .WithMessage("Prices allow at most four decimal places and cannot be negative.");
        RuleFor(x => x.SuggestedRetailPrice).Must(IsFourDecimal)
            .WithMessage("Prices allow at most four decimal places and cannot be negative.");
        RuleFor(x => x.GradeA).Must(IsFourDecimal)
            .WithMessage("Prices allow at most four decimal places and cannot be negative.");
        RuleFor(x => x.GradeB).Must(IsFourDecimal)
            .WithMessage("Prices allow at most four decimal places and cannot be negative.");
        RuleFor(x => x.GradeC).Must(IsFourDecimal)
            .WithMessage("Prices allow at most four decimal places and cannot be negative.");
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }

    private static bool IsFourDecimal(decimal? value) =>
        value is null || (value >= 0 && decimal.Round(value.Value, 4) == value.Value);
}

public sealed class GenerateBarcodeTagCommandValidator : AbstractValidator<GenerateBarcodeTagCommand>
{
    public GenerateBarcodeTagCommandValidator()
    {
        RuleFor(x => x.Sku).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CreateSkuHandler(
    IUnitOfWork unitOfWork, ICatalogueStore store, IAuditRecorder audit)
    : IRequestHandler<CreateSkuCommand, CatalogueItemDto>
{
    public Task<CatalogueItemDto> Handle(CreateSkuCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var sku = request.Sku.Trim();
            if (await store.SkuExistsAsync(sku, token) || await store.SkuExistsAsync(sku.ToUpperInvariant(), token))
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Sku", "duplicate", $"SKU '{sku}' already exists."),
                });
            }

            if (!await store.CategoryExistsAsync(request.DepartmentCode, request.ClassCode, request.CategoryCode, token))
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("CategoryCode", "not-found",
                        "The department/class/category combination does not exist."),
                });
            }

            if (!await store.SupplierExistsAsync(request.SupplierCode, token))
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("SupplierCode", "not-found", "Supplier was not found."),
                });
            }

            if (!await store.BrandExistsAsync(request.BrandCode, token))
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("BrandCode", "not-found", "Brand was not found."),
                });
            }

            var item = new CatalogueItemDto(sku, request.Name, request.DepartmentCode, request.ClassCode,
                request.CategoryCode, request.SupplierCode, request.BrandCode, request.MaterialCode,
                request.LotTracked, request.RetailPriceFlag, request.WholesalePriceFlag, 0);
            await store.CreateAsync(item, token);
            await audit.RecordAsync(new AuditRecord("sku.create", "Inventory", sku,
                JsonSerializer.Serialize(new { reason = request.Reason, after = item })), token);
            return item;
        }, ct);
}

public sealed class UpdateSkuHandler(
    IUnitOfWork unitOfWork, ICatalogueStore store, IAuditRecorder audit)
    : IRequestHandler<UpdateSkuCommand, CatalogueItemDto>
{
    public Task<CatalogueItemDto> Handle(UpdateSkuCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var existing = await store.FindAsync(request.Sku, token)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Sku", "not-found", $"SKU '{request.Sku}' was not found."),
                });

            var updated = existing with
            {
                Name = request.Name,
                DepartmentCode = request.DepartmentCode,
                ClassCode = request.ClassCode,
                CategoryCode = request.CategoryCode,
                SupplierCode = request.SupplierCode,
                BrandCode = request.BrandCode,
                MaterialCode = request.MaterialCode,
                LotTracked = request.LotTracked,
                RetailPriceFlag = request.RetailPriceFlag,
                WholesalePriceFlag = request.WholesalePriceFlag,
            };
            await store.UpdateAsync(updated, token);
            await audit.RecordAsync(new AuditRecord("sku.update", "Inventory", request.Sku,
                JsonSerializer.Serialize(new { reason = request.Reason, before = existing, after = updated })), token);
            return updated;
        }, ct);
}

public sealed class RetireSkuHandler(
    IUnitOfWork unitOfWork, ICatalogueStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<RetireSkuCommand, CatalogueItemDto>
{
    public Task<CatalogueItemDto> Handle(RetireSkuCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var existing = await store.FindAsync(request.Sku, token)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Sku", "not-found", $"SKU '{request.Sku}' was not found."),
                });

            if (existing.QtyOnHand != 0 && !request.ConfirmOnHand)
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("ConfirmOnHand", "on-hand",
                        $"SKU '{request.Sku}' still has {existing.QtyOnHand} on hand; confirm retirement explicitly."),
                });
            }

            await store.RetireAsync(request.Sku, request.Reason, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("sku.retire", "Inventory", request.Sku,
                JsonSerializer.Serialize(new { reason = request.Reason, before = existing })), token);
            return existing;
        }, ct);
}

public sealed class SetSkuPricesHandler(
    IUnitOfWork unitOfWork, ICatalogueStore store, IAuditRecorder audit)
    : IRequestHandler<SetSkuPricesCommand, SkuPricesDto>
{
    public Task<SkuPricesDto> Handle(SetSkuPricesCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            if (await store.FindAsync(request.Sku, token) is null)
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Sku", "not-found", $"SKU '{request.Sku}' was not found."),
                });
            }

            var before = await store.GetPricesAsync(request.Sku, token);
            var after = new SkuPricesDto(request.Sku, request.RetailPrice, request.LeastSellingPrice,
                request.RetailMarkdownAmount, request.RetailMarkdownPercent, request.SuggestedRetailPrice,
                request.GradeA, request.GradeB, request.GradeC);
            await store.SetPricesAsync(after, token);
            await audit.RecordAsync(new AuditRecord("sku.price-change", "Inventory", request.Sku,
                JsonSerializer.Serialize(new { reason = request.Reason, before, after })), token);
            return after;
        }, ct);
}

public sealed class GenerateBarcodeTagHandler(
    IUnitOfWork unitOfWork, ICatalogueStore store, IAuditRecorder audit)
    : IRequestHandler<GenerateBarcodeTagCommand, BarcodeTagDto>
{
    public Task<BarcodeTagDto> Handle(GenerateBarcodeTagCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            if (await store.FindAsync(request.Sku, token) is null)
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Sku", "not-found", $"SKU '{request.Sku}' was not found."),
                });
            }

            if (await store.FindTagAsync(request.Sku, token) is not null)
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Sku", "duplicate",
                        $"A barcode already exists for SKU '{request.Sku}'; reprint it instead."),
                });
            }

            var tag = await store.CreateTagAsync(request.Sku, token);
            await audit.RecordAsync(new AuditRecord("barcode.generate", "BarCode", tag.Barcode,
                JsonSerializer.Serialize(new { reason = request.Reason, tag })), token);
            return tag;
        }, ct);
}

public sealed class ReprintBarcodeTagHandler(ICatalogueStore store)
    : IRequestHandler<ReprintBarcodeTagCommand, BarcodeTagDto>
{
    public async Task<BarcodeTagDto> Handle(ReprintBarcodeTagCommand request, CancellationToken ct)
    {
        var tag = await store.FindTagAsync(request.Sku, ct)
            ?? throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("Sku", "not-found", $"No barcode tag exists for SKU '{request.Sku}'."),
            });
        return tag with { Reprint = true };
    }
}

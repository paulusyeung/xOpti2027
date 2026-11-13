using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Reference;

public sealed record SupplierDto(
    string SupplierCode, string? Name, int? CityCode, string? Province, string? Country,
    string? Phone, string? ContactPerson, decimal? CreditLimit, string? PaymentTerms);

public sealed record DoctorDto(
    int Id, string? Name, string? Address, int? CityCode, string? Province, string? Country,
    string? Phone, string? PostalCode);

public sealed record SupplierContactDto(
    string SupplierCode, string FirstName, string Initial, string LastName,
    string? FullName, string? JobTitle, string? Phone, string? Mobile);

public interface IPartyDirectory
{
    Task<IReadOnlyList<SupplierDto>> PageSuppliersAsync(string? search, string? afterKey, int limit, CancellationToken ct);
    Task<IReadOnlyList<DoctorDto>> PageDoctorsAsync(string? search, string? afterKey, int limit, CancellationToken ct);
    Task<IReadOnlyList<SupplierContactDto>> ContactsAsync(string supplierCode, CancellationToken ct);
    Task<bool> SupplierExistsAsync(string code, CancellationToken ct);
    Task<bool> ContactExistsAsync(string code, string first, string initial, string last, CancellationToken ct);
    Task CreateSupplierAsync(SupplierDto supplier, CancellationToken ct);
    Task CreateDoctorAsync(DoctorDto doctor, CancellationToken ct);
    Task CreateContactAsync(SupplierContactDto contact, CancellationToken ct);
    Task<int> NextDoctorIdAsync(CancellationToken ct);
    Task<bool> BranchExistsAsync(string code, CancellationToken ct);
    Task<int> BranchCountAsync(CancellationToken ct);
    Task<int> StaffScopedToBranchAsync(string code, CancellationToken ct);
    Task<int> BranchInventoryRowsAsync(string code, CancellationToken ct);
    Task RetireBranchAsync(string code, string reason, string? actor, CancellationToken ct);
}

public sealed record ListSuppliersQuery(string? Search, string? Cursor, int PageSize)
    : IQuery<PagedResult<SupplierDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
    public string? AfterKey => Cursor is null ? null : KeysetCursor.Decode(Cursor);
}

public sealed record ListDoctorsQuery(string? Search, string? Cursor, int PageSize)
    : IQuery<PagedResult<DoctorDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
    public string? AfterKey => Cursor is null ? null : KeysetCursor.Decode(Cursor);
}

public sealed record ListSupplierContactsQuery(string SupplierCode)
    : IQuery<IReadOnlyList<SupplierContactDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class ListSuppliersHandler(IPartyDirectory directory)
    : IRequestHandler<ListSuppliersQuery, PagedResult<SupplierDto>>
{
    public async Task<PagedResult<SupplierDto>> Handle(ListSuppliersQuery request, CancellationToken ct)
    {
        var rows = await directory.PageSuppliersAsync(request.Search, request.AfterKey, request.PageSize + 1, ct);
        var hasMore = rows.Count > request.PageSize;
        var page = hasMore ? rows.Take(request.PageSize).ToList() : rows.ToList();
        return new PagedResult<SupplierDto>(page,
            hasMore ? KeysetCursor.Encode(page[^1].SupplierCode) : null);
    }
}

public sealed class ListDoctorsHandler(IPartyDirectory directory)
    : IRequestHandler<ListDoctorsQuery, PagedResult<DoctorDto>>
{
    public async Task<PagedResult<DoctorDto>> Handle(ListDoctorsQuery request, CancellationToken ct)
    {
        var rows = await directory.PageDoctorsAsync(request.Search, request.AfterKey, request.PageSize + 1, ct);
        var hasMore = rows.Count > request.PageSize;
        var page = hasMore ? rows.Take(request.PageSize).ToList() : rows.ToList();
        return new PagedResult<DoctorDto>(page,
            hasMore ? KeysetCursor.Encode(page[^1].Id.ToString()) : null);
    }
}

public sealed class ListSupplierContactsHandler(IPartyDirectory directory)
    : IRequestHandler<ListSupplierContactsQuery, IReadOnlyList<SupplierContactDto>>
{
    public Task<IReadOnlyList<SupplierContactDto>> Handle(ListSupplierContactsQuery request, CancellationToken ct) =>
        directory.ContactsAsync(request.SupplierCode, ct);
}

public sealed record CreateSupplierCommand(
    string SupplierCode, string Name, int? CityCode, string? Province, string? Country,
    string? Phone, string? ContactPerson, decimal? CreditLimit, string? PaymentTerms, string Reason)
    : ICommand<SupplierDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed record CreateDoctorCommand(
    string Name, string? Address, int? CityCode, string? Province, string? Country,
    string? Phone, string? PostalCode, string Reason)
    : ICommand<DoctorDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed record CreateSupplierContactCommand(
    string SupplierCode, string FirstName, string? Initial, string LastName,
    string? JobTitle, string? Phone, string Reason)
    : ICommand<SupplierContactDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed record DeactivateBranchCommand(string BranchCode, string Reason, string? TargetBranchCode)
    : ICommand<bool>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class CreateSupplierCommandValidator : AbstractValidator<CreateSupplierCommand>
{
    public CreateSupplierCommandValidator()
    {
        RuleFor(x => x.SupplierCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.Name).NotEmpty().MaximumLength(50);
        RuleFor(x => x.PaymentTerms).MaximumLength(10);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CreateDoctorCommandValidator : AbstractValidator<CreateDoctorCommand>
{
    public CreateDoctorCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(40);
        RuleFor(x => x.Address).MaximumLength(128);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CreateSupplierContactCommandValidator : AbstractValidator<CreateSupplierContactCommand>
{
    public CreateSupplierContactCommandValidator()
    {
        RuleFor(x => x.SupplierCode).NotEmpty();
        RuleFor(x => x.FirstName).NotEmpty().MaximumLength(20);
        RuleFor(x => x.Initial).MaximumLength(2);
        RuleFor(x => x.LastName).NotEmpty().MaximumLength(20);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class DeactivateBranchCommandValidator : AbstractValidator<DeactivateBranchCommand>
{
    public DeactivateBranchCommandValidator()
    {
        RuleFor(x => x.BranchCode).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CreateSupplierHandler(
    IUnitOfWork unitOfWork, IPartyDirectory directory, IAuditRecorder audit)
    : IRequestHandler<CreateSupplierCommand, SupplierDto>
{
    public Task<SupplierDto> Handle(CreateSupplierCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            if (await directory.SupplierExistsAsync(request.SupplierCode, token))
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("SupplierCode", "duplicate",
                        $"Supplier code '{request.SupplierCode}' already exists."),
                });
            }

            var supplier = new SupplierDto(request.SupplierCode, request.Name, request.CityCode,
                request.Province, request.Country, request.Phone, request.ContactPerson,
                request.CreditLimit, request.PaymentTerms);
            await directory.CreateSupplierAsync(supplier, token);
            await audit.RecordAsync(new AuditRecord("supplier.create", "Supplier", supplier.SupplierCode,
                JsonSerializer.Serialize(new { reason = request.Reason, after = supplier })), token);
            return supplier;
        }, ct);
}

public sealed class CreateDoctorHandler(
    IUnitOfWork unitOfWork, IPartyDirectory directory, IAuditRecorder audit)
    : IRequestHandler<CreateDoctorCommand, DoctorDto>
{
    public Task<DoctorDto> Handle(CreateDoctorCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var doctor = new DoctorDto(await directory.NextDoctorIdAsync(token), request.Name,
                request.Address, request.CityCode, request.Province, request.Country, request.Phone,
                request.PostalCode);
            await directory.CreateDoctorAsync(doctor, token);
            await audit.RecordAsync(new AuditRecord("doctor.create", "Doctor", doctor.Id.ToString(),
                JsonSerializer.Serialize(new { reason = request.Reason, after = doctor })), token);
            return doctor;
        }, ct);
}

public sealed class CreateSupplierContactHandler(
    IUnitOfWork unitOfWork, IPartyDirectory directory, IAuditRecorder audit)
    : IRequestHandler<CreateSupplierContactCommand, SupplierContactDto>
{
    public Task<SupplierContactDto> Handle(CreateSupplierContactCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            if (!await directory.SupplierExistsAsync(request.SupplierCode, token))
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("SupplierCode", "not-found",
                        $"Supplier '{request.SupplierCode}' was not found."),
                });
            }

            var initial = request.Initial ?? string.Empty;
            if (await directory.ContactExistsAsync(request.SupplierCode, request.FirstName, initial, request.LastName, token))
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("LastName", "duplicate",
                        "A contact with this name already exists for the supplier."),
                });
            }

            var contact = new SupplierContactDto(request.SupplierCode, request.FirstName, initial,
                request.LastName, $"{request.FirstName} {request.LastName}".Trim(), request.JobTitle,
                request.Phone, null);
            await directory.CreateContactAsync(contact, token);
            await audit.RecordAsync(new AuditRecord("supplier.contact.create", "Supplier", request.SupplierCode,
                JsonSerializer.Serialize(new { reason = request.Reason, after = contact })), token);
            return contact;
        }, ct);
}

public sealed class DeactivateBranchHandler(
    IUnitOfWork unitOfWork, IPartyDirectory directory, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<DeactivateBranchCommand, bool>
{
    public Task<bool> Handle(DeactivateBranchCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            if (!await directory.BranchExistsAsync(request.BranchCode, token))
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("BranchCode", "not-found",
                        $"Branch '{request.BranchCode}' was not found."),
                });
            }

            if (await directory.BranchCountAsync(token) <= 1)
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("BranchCode", "last-branch",
                        "The last active branch cannot be deactivated."),
                });
            }

            var staff = await directory.StaffScopedToBranchAsync(request.BranchCode, token);
            var inventory = await directory.BranchInventoryRowsAsync(request.BranchCode, token);
            if (staff + inventory > 0)
            {
                if (string.IsNullOrWhiteSpace(request.TargetBranchCode))
                {
                    throw new ValidationFailedException(new[]
                    {
                        new ValidationFieldError("TargetBranchCode", "required",
                            $"Branch '{request.BranchCode}' still owns {staff} staff and {inventory} inventory rows; supply a target branch or record a closure decision."),
                    });
                }

                if (request.TargetBranchCode == request.BranchCode
                    || !await directory.BranchExistsAsync(request.TargetBranchCode, token))
                {
                    throw new ValidationFailedException(new[]
                    {
                        new ValidationFieldError("TargetBranchCode", "invalid",
                            "The target branch must exist and differ from the deactivated branch."),
                    });
                }
            }

            await directory.RetireBranchAsync(request.BranchCode, request.Reason, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("branch.deactivate", "Branch", request.BranchCode,
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason, staff, inventory, target = request.TargetBranchCode,
                })), token);
            return true;
        }, ct);
}

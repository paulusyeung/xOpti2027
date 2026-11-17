using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Customers;

public sealed record CreateCustomerCommand(
    CustomerInput Input, bool ConfirmDuplicate, string Reason)
    : ICommand<CustomerViewDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed record UpdateCustomerCommand(
    int CustomerId, CustomerInput Input, bool ConfirmDuplicate, string Reason)
    : ICommand<CustomerViewDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed record GetCustomerQuery(int CustomerId)
    : IQuery<CustomerViewDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed record SearchCustomersQuery(string? Search, string? Cursor, int PageSize)
    : IQuery<PagedResult<CustomerSummaryDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };

    public int? AfterId => Cursor is null || !int.TryParse(KeysetCursor.Decode(Cursor), out var id)
        ? null : id;
}

public sealed record FindCustomerDuplicatesQuery(string? FullName, string? Phone, string? Email)
    : IQuery<IReadOnlyList<CustomerDuplicateDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed record GetCustomerAccountQuery(int CustomerId)
    : IQuery<CustomerBalanceDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed record GetCustomerHistoryQuery(int CustomerId, DateOnly? From, DateOnly? To)
    : IQuery<CustomerHistoryDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed record GetCustomerStatementQuery(int CustomerId, DateOnly From, DateOnly To)
    : IQuery<CustomerStatementDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record MergeCustomersCommand(
    int SourceId, int TargetId, string? Phone, string? Email, string? FullName, string Reason)
    : ICommand<CustomerViewDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class CustomerInputValidator : AbstractValidator<CustomerInput>
{
    public CustomerInputValidator()
    {
        RuleFor(x => x.FullName).MaximumLength(40);
        RuleFor(x => x.FirstName).MaximumLength(20);
        RuleFor(x => x.LastName).MaximumLength(20);
        RuleFor(x => x.Email).MaximumLength(128);
        RuleFor(x => x.HomePhone).MaximumLength(12);
        RuleFor(x => x.Cellular).MaximumLength(15);
        RuleFor(x => x.CreditLimit).GreaterThanOrEqualTo(0);
        RuleFor(x => x.VipMarkDownPct).GreaterThanOrEqualTo(0);
        RuleFor(x => x)
            .Must(x => !string.IsNullOrWhiteSpace(x.FullName)
                || !string.IsNullOrWhiteSpace(x.FirstName)
                || !string.IsNullOrWhiteSpace(x.LastName))
            .WithMessage("A customer name is required.");
    }
}

public sealed class CreateCustomerCommandValidator : AbstractValidator<CreateCustomerCommand>
{
    public CreateCustomerCommandValidator()
    {
        RuleFor(x => x.Input).SetValidator(new CustomerInputValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class UpdateCustomerCommandValidator : AbstractValidator<UpdateCustomerCommand>
{
    public UpdateCustomerCommandValidator()
    {
        RuleFor(x => x.CustomerId).GreaterThan(0);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class MergeCustomersCommandValidator : AbstractValidator<MergeCustomersCommand>
{
    public MergeCustomersCommandValidator()
    {
        RuleFor(x => x.SourceId).GreaterThan(0);
        RuleFor(x => x.TargetId).GreaterThan(0);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CreateCustomerHandler(
    IUnitOfWork unitOfWork, ICustomerStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<CreateCustomerCommand, CustomerViewDto>
{
    public Task<CustomerViewDto> Handle(CreateCustomerCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var duplicates = await store.FindDuplicatesAsync(request.Input, null, token);
            if (duplicates.Count > 0 && !request.ConfirmDuplicate)
                throw DuplicateWarning(duplicates);
            var id = await store.CreateAsync(request.Input, token);
            await audit.RecordAsync(new AuditRecord("customer.create", "Customer", id.ToString(),
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason,
                    duplicateConfirmed = duplicates.Count > 0,
                })), token);
            var customer = await store.GetAsync(id, token) ?? throw new InvalidOperationException();
            return new CustomerViewDto(customer.MaskPii(principal), null);
        }, ct);

    internal static ValidationFailedException DuplicateWarning(
        IReadOnlyList<CustomerDuplicateDto> duplicates) =>
        new(new[]
        {
            new ValidationFieldError("Duplicate", "duplicate-candidate",
                "Possible duplicate customer(s): "
                + string.Join(", ", duplicates.Select(row => row.Id))
                + ". Review duplicates and resubmit with confirmation or merge."),
        });
}

public sealed class UpdateCustomerHandler(
    IUnitOfWork unitOfWork, ICustomerStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<UpdateCustomerCommand, CustomerViewDto>
{
    public Task<CustomerViewDto> Handle(UpdateCustomerCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var canonical = await store.ResolveCanonicalIdAsync(request.CustomerId, token)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("CustomerId", "not-found", "Customer was not found."),
                });
            var existing = await store.GetAsync(canonical, token)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("CustomerId", "not-found", "Customer was not found."),
                });
            // Without customer:pii, protected fields are preserved from the stored
            // customer and cannot be overwritten with masked values.
            var effective = principal.HasPermission(PermissionNames.CustomerPii)
                ? request.Input
                : request.Input with
                {
                    Salutation = existing.Salutation,
                    FirstName = existing.FirstName,
                    Initial = existing.Initial,
                    LastName = existing.LastName,
                    FullName = existing.FullName,
                    Birthday = existing.Birthday,
                    HomeAddress = existing.HomeAddress,
                    HomeCity = existing.HomeCity,
                    HomeProvince = existing.HomeProvince,
                    HomePostalCode = existing.HomePostalCode,
                    HomeCountry = existing.HomeCountry,
                    HomePhone = existing.HomePhone,
                    HomeFax = existing.HomeFax,
                    Cellular = existing.Cellular,
                    Email = existing.Email,
                    BizCompanyName = existing.BizCompanyName,
                    BizJobTitle = existing.BizJobTitle,
                    BizAddress = existing.BizAddress,
                    BizCity = existing.BizCity,
                    BizProvince = existing.BizProvince,
                    BizPostalCode = existing.BizPostalCode,
                    BizCountry = existing.BizCountry,
                    BizPhone = existing.BizPhone,
                    BizFax = existing.BizFax,
                    Remarks = existing.Remarks,
                };
            var duplicates = await store.FindDuplicatesAsync(
                effective, canonical, token);
            if (duplicates.Count > 0 && !request.ConfirmDuplicate)
                throw CreateCustomerHandler.DuplicateWarning(duplicates);
            await store.UpdateAsync(canonical, effective, token);
            await audit.RecordAsync(new AuditRecord("customer.update", "Customer",
                canonical.ToString(), JsonSerializer.Serialize(new
                {
                    reason = request.Reason,
                    fields = ChangedFieldNames(request.Input),
                    duplicateConfirmed = duplicates.Count > 0,
                })), token);
            var customer = await store.GetAsync(canonical, token) ?? throw new InvalidOperationException();
            return new CustomerViewDto(customer.MaskPii(principal),
                request.CustomerId == canonical ? null : request.CustomerId);
        }, ct);

    private static IReadOnlyList<string> ChangedFieldNames(CustomerInput input) => new[]
    {
        nameof(input.FullName), nameof(input.HomePhone), nameof(input.Cellular),
        nameof(input.Email), nameof(input.HomeAddress), nameof(input.BizCompanyName),
        nameof(input.CreditLimit),
    };
}

public sealed class GetCustomerHandler(ICustomerStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<GetCustomerQuery, CustomerViewDto>
{
    public async Task<CustomerViewDto> Handle(GetCustomerQuery request, CancellationToken ct)
    {
        var canonical = await store.ResolveCanonicalIdAsync(request.CustomerId, ct);
        var customer = canonical is null ? null : await store.GetAsync(canonical.Value, ct);
        if (customer is null)
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("CustomerId", "not-found", "Customer was not found."),
            });

        var permitted = principal.HasPermission(PermissionNames.CustomerPii);
        await audit.RecordAsync(new AuditRecord(
            permitted ? "customer.pii.access" : "customer.pii.denied", "Customer",
            canonical!.Value.ToString(),
            JsonSerializer.Serialize(new
            {
                fields = permitted ? PiiFields : Array.Empty<string>(),
                requestedId = request.CustomerId,
            })), ct);
        return new CustomerViewDto(customer.MaskPii(principal),
            request.CustomerId == canonical ? null : request.CustomerId);
    }

    private static readonly string[] PiiFields =
    {
        "name", "birthday", "homeAddress", "homePhone", "cellular", "email",
        "business", "remarks",
    };
}

public sealed class SearchCustomersHandler(ICustomerStore store, ICurrentPrincipal principal)
    : IRequestHandler<SearchCustomersQuery, PagedResult<CustomerSummaryDto>>
{
    public async Task<PagedResult<CustomerSummaryDto>> Handle(
        SearchCustomersQuery request, CancellationToken ct)
    {
        var limit = Math.Clamp(request.PageSize, 1, 100);
        var (items, hasMore) = await store.SearchAsync(
            request.Search, request.AfterId, limit, ct);
        var page = items.ToList().MaskPii(principal);
        return new PagedResult<CustomerSummaryDto>(page,
            hasMore ? KeysetCursor.Encode(page[^1].Id.ToString()) : null);
    }
}

public sealed class FindCustomerDuplicatesHandler(ICustomerStore store, ICurrentPrincipal principal)
    : IRequestHandler<FindCustomerDuplicatesQuery, IReadOnlyList<CustomerDuplicateDto>>
{
    public async Task<IReadOnlyList<CustomerDuplicateDto>> Handle(
        FindCustomerDuplicatesQuery request, CancellationToken ct)
    {
        var input = new CustomerInput(request.FullName, null, null, null, null, request.FullName,
            null, null, 0, null, null, null, request.Phone, null, request.Phone, request.Email,
            null, null, null, 0, null, null, null, null, null, 0, null, 0, null, null, null);
        var rows = await store.FindDuplicatesAsync(input, null, ct);
        return rows.MaskPii(principal);
    }
}

public sealed class GetCustomerAccountHandler(ICustomerStore store)
    : IRequestHandler<GetCustomerAccountQuery, CustomerBalanceDto>
{
    public async Task<CustomerBalanceDto> Handle(
        GetCustomerAccountQuery request, CancellationToken ct)
    {
        var canonical = await store.ResolveCanonicalIdAsync(request.CustomerId, ct)
            ?? throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("CustomerId", "not-found", "Customer was not found."),
            });
        return await store.GetBalanceAsync(canonical, ct)
            ?? throw new InvalidOperationException();
    }
}

public sealed class GetCustomerHistoryHandler(ICustomerStore store)
    : IRequestHandler<GetCustomerHistoryQuery, CustomerHistoryDto>
{
    public async Task<CustomerHistoryDto> Handle(
        GetCustomerHistoryQuery request, CancellationToken ct)
    {
        var canonical = await store.ResolveCanonicalIdAsync(request.CustomerId, ct)
            ?? throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("CustomerId", "not-found", "Customer was not found."),
            });
        var ids = await store.ResolveGroupIdsAsync(canonical, ct);
        var items = await store.GetHistoryAsync(ids, request.From, request.To, ct);
        return new CustomerHistoryDto(canonical, items);
    }
}

public sealed class GetCustomerStatementHandler(ICustomerStore store)
    : IRequestHandler<GetCustomerStatementQuery, CustomerStatementDto>
{
    public async Task<CustomerStatementDto> Handle(
        GetCustomerStatementQuery request, CancellationToken ct)
    {
        if (request.From > request.To)
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("From", "range", "From must not be after To."),
            });
        var canonical = await store.ResolveCanonicalIdAsync(request.CustomerId, ct)
            ?? throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("CustomerId", "not-found", "Customer was not found."),
            });
        var ids = await store.ResolveGroupIdsAsync(canonical, ct);
        var all = await store.GetHistoryAsync(ids, null, request.To, ct);
        var start = new DateTimeOffset(request.From.ToDateTime(TimeOnly.MinValue), TimeSpan.Zero);
        var before = all.Where(row => row.DateOfEntry < start).ToList();
        var period = all.Where(row => row.DateOfEntry >= start).ToList();

        static decimal Charges(IEnumerable<CustomerPurchaseDto> rows) =>
            decimal.Round(rows.Where(row => row.TxType == "RC").Sum(row => row.TotalAmount), 4);
        static decimal Refunds(IEnumerable<CustomerPurchaseDto> rows) =>
            decimal.Round(rows.Where(row => row.TxType == "RS").Sum(row => row.TotalAmount), 4);
        static decimal Payments(IEnumerable<CustomerPurchaseDto> rows) =>
            decimal.Round(rows.Sum(row => row.Paid), 4);

        var opening = decimal.Round(Charges(before) + Refunds(before) - Payments(before), 4);
        var charges = Charges(period);
        var refunds = Refunds(period);
        var payments = Payments(period);
        return new CustomerStatementDto(canonical, request.From, request.To, opening,
            charges, payments, refunds,
            decimal.Round(opening + charges + refunds - payments, 4), period);
    }
}

public sealed class MergeCustomersHandler(
    IUnitOfWork unitOfWork, ICustomerStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<MergeCustomersCommand, CustomerViewDto>
{
    public Task<CustomerViewDto> Handle(MergeCustomersCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var target = await store.ResolveCanonicalIdAsync(request.TargetId, token)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TargetId", "not-found", "Target customer was not found."),
                });
            await store.MergeAsync(request.SourceId, target, request.Phone, request.Email,
                request.FullName, request.Reason, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("customer.merge", "Customer",
                target.ToString(), JsonSerializer.Serialize(new
                {
                    source = request.SourceId,
                    target,
                    request.Reason,
                    choices = new { request.Phone, request.Email, request.FullName },
                })), token);
            var customer = await store.GetAsync(target, token) ?? throw new InvalidOperationException();
            return new CustomerViewDto(customer.MaskPii(principal), request.SourceId);
        }, ct);
}

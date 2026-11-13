using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Reference;

/// <summary>Typed reference mutation payload; only fields for the chosen kind are used.</summary>
public sealed record ReferenceMutation(
    ReferenceKind Kind,
    string Key,
    string Name,
    string? Parent = null,
    bool? SummaryFlag = null,
    string? CostingMethod = null,
    string? InventoryMethod = null,
    string? TaxMethod = null,
    string? PaymentNameShort = null,
    double? ExchangeRate = null);

public sealed record ReferenceRecord(
    ReferenceKind Kind,
    string Key,
    string Name,
    string? Parent,
    bool? SummaryFlag,
    string? CostingMethod,
    string? InventoryMethod,
    string? TaxMethod,
    string? PaymentNameShort,
    double? ExchangeRate);

public interface IReferenceWriter
{
    Task<ReferenceRecord?> FindAsync(ReferenceKind kind, string key, CancellationToken cancellationToken);

    Task<bool> ExistsAsync(ReferenceKind kind, string key, CancellationToken cancellationToken);

    Task<int> CountReferencesAsync(ReferenceKind kind, string key, CancellationToken cancellationToken);

    Task CreateAsync(ReferenceMutation mutation, CancellationToken cancellationToken);

    Task UpdateAsync(ReferenceMutation mutation, CancellationToken cancellationToken);

    Task RetireAsync(
        ReferenceKind kind,
        string key,
        string reason,
        string? actor,
        CancellationToken cancellationToken);
}

public sealed record CreateReferenceCommand(ReferenceMutation Input, string Reason)
    : ICommand<ReferenceItemDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed record UpdateReferenceCommand(ReferenceMutation Input, string Reason)
    : ICommand<ReferenceItemDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed record RetireReferenceCommand(
    ReferenceKind Kind,
    string Key,
    string Reason,
    bool ConfirmReferenced)
    : ICommand<ReferenceItemDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class ReferenceMutationValidator : AbstractValidator<ReferenceMutation>
{
    public ReferenceMutationValidator()
    {
        RuleFor(x => x.Key).NotEmpty().MaximumLength(40);
        RuleFor(x => x.Name).NotEmpty().MaximumLength(60);
        RuleFor(x => x.Parent).MaximumLength(20);

        When(x => x.Kind is ReferenceKind.City or ReferenceKind.Province or ReferenceKind.Country, () =>
            RuleFor(x => x.Name).MaximumLength(26));
        When(x => x.Kind is ReferenceKind.Department or ReferenceKind.Class or ReferenceKind.Category, () =>
            RuleFor(x => x.Name).MaximumLength(30));
        When(x => x.Kind is ReferenceKind.Brand or ReferenceKind.Material, () =>
            RuleFor(x => x.Name).MaximumLength(40));
        When(x => x.Kind is ReferenceKind.TaxMethod or ReferenceKind.PaymentMethod, () =>
            RuleFor(x => x.Name).MaximumLength(20));

        When(x => x.Kind == ReferenceKind.City, () =>
            RuleFor(x => x.Key).Must(key => int.TryParse(key, out _)).WithMessage("City key must be numeric."));

        When(x => x.Kind == ReferenceKind.Class, () =>
            RuleFor(x => x.Key).Must(key => key.Split('/').Length == 2)
                .WithMessage("Class key must be department/class."));

        When(x => x.Kind == ReferenceKind.Category, () =>
        {
            RuleFor(x => x.Key).Must(key => key.Split('/').Length == 3)
                .WithMessage("Category key must be department/class/category.");
            RuleFor(x => x.CostingMethod).NotEmpty();
            RuleFor(x => x.InventoryMethod).NotEmpty();
            RuleFor(x => x.TaxMethod).NotEmpty();
        });

        When(x => x.Kind == ReferenceKind.PaymentMethod, () =>
        {
            RuleFor(x => x.PaymentNameShort).NotEmpty().MaximumLength(3);
            RuleFor(x => x.ExchangeRate).GreaterThanOrEqualTo(0);
        });
    }
}

public sealed class CreateReferenceCommandValidator : AbstractValidator<CreateReferenceCommand>
{
    public CreateReferenceCommandValidator()
    {
        RuleFor(x => x.Input).NotNull().SetValidator(new ReferenceMutationValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class UpdateReferenceCommandValidator : AbstractValidator<UpdateReferenceCommand>
{
    public UpdateReferenceCommandValidator()
    {
        RuleFor(x => x.Input).NotNull().SetValidator(new ReferenceMutationValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class RetireReferenceCommandValidator : AbstractValidator<RetireReferenceCommand>
{
    public RetireReferenceCommandValidator()
    {
        RuleFor(x => x.Key).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CreateReferenceHandler(
    IUnitOfWork unitOfWork,
    IReferenceWriter writer,
    IAuditRecorder audit)
    : IRequestHandler<CreateReferenceCommand, ReferenceItemDto>
{
    public Task<ReferenceItemDto> Handle(CreateReferenceCommand request, CancellationToken cancellationToken) =>
        unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            if (await writer.ExistsAsync(request.Input.Kind, request.Input.Key, ct))
            {
                throw Duplicate(request.Input.Kind, request.Input.Key);
            }

            await writer.CreateAsync(request.Input, ct);
            await audit.RecordAsync(new AuditRecord(
                "reference.create",
                $"Reference:{request.Input.Kind}",
                request.Input.Key,
                Details(request.Reason, before: null, after: request.Input)), ct);

            return ToItem(request.Input);
        }, cancellationToken);

    internal static ValidationFailedException Duplicate(ReferenceKind kind, string key) =>
        new(new[]
        {
            new ValidationFieldError("Key", "duplicate", $"{kind} key '{key}' already exists."),
        });

    internal static string Details(string reason, ReferenceMutation? before, ReferenceMutation? after) =>
        JsonSerializer.Serialize(new { reason, before, after });

    internal static ReferenceItemDto ToItem(ReferenceMutation mutation) =>
        new(
            mutation.Kind.ToString(),
            mutation.Key,
            mutation.Name,
            mutation.Parent,
            mutation.Kind == ReferenceKind.Category
                ? $"costing {mutation.CostingMethod}, inventory {mutation.InventoryMethod}, tax {mutation.TaxMethod}"
                : null);
}

public sealed class UpdateReferenceHandler(
    IUnitOfWork unitOfWork,
    IReferenceWriter writer,
    IAuditRecorder audit)
    : IRequestHandler<UpdateReferenceCommand, ReferenceItemDto>
{
    public Task<ReferenceItemDto> Handle(UpdateReferenceCommand request, CancellationToken cancellationToken) =>
        unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            var existing = await writer.FindAsync(request.Input.Kind, request.Input.Key, ct)
                ?? throw new DomainRuleException(
                    $"{request.Input.Kind} key '{request.Input.Key}' was not found.");

            await writer.UpdateAsync(request.Input, ct);
            await audit.RecordAsync(new AuditRecord(
                "reference.update",
                $"Reference:{request.Input.Kind}",
                request.Input.Key,
                CreateReferenceHandler.Details(request.Reason, ToMutation(existing), request.Input)), ct);

            return CreateReferenceHandler.ToItem(request.Input);
        }, cancellationToken);

    private static ReferenceMutation ToMutation(ReferenceRecord record) =>
        new(record.Kind, record.Key, record.Name, record.Parent, record.SummaryFlag,
            record.CostingMethod, record.InventoryMethod, record.TaxMethod,
            record.PaymentNameShort, record.ExchangeRate);
}

public sealed class RetireReferenceHandler(
    IUnitOfWork unitOfWork,
    IReferenceWriter writer,
    IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<RetireReferenceCommand, ReferenceItemDto>
{
    public Task<ReferenceItemDto> Handle(RetireReferenceCommand request, CancellationToken cancellationToken) =>
        unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            var existing = await writer.FindAsync(request.Kind, request.Key, ct)
                ?? throw new DomainRuleException($"{request.Kind} key '{request.Key}' was not found.");

            var references = await writer.CountReferencesAsync(request.Kind, request.Key, ct);
            if (references > 0 && !request.ConfirmReferenced)
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError(
                        "ConfirmReferenced",
                        "referenced",
                        $"{request.Kind} '{request.Key}' is referenced by {references} record(s); confirm retirement explicitly."),
                });
            }

            await writer.RetireAsync(request.Kind, request.Key, request.Reason, principal.UserId, ct);
            await audit.RecordAsync(new AuditRecord(
                "reference.retire",
                $"Reference:{request.Kind}",
                request.Key,
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason,
                    references,
                    before = ToMutation(existing),
                    after = (object?)null,
                })), ct);

            return CreateReferenceHandler.ToItem(ToMutation(existing));
        }, cancellationToken);

    private static ReferenceMutation ToMutation(ReferenceRecord record) =>
        new(record.Kind, record.Key, record.Name, record.Parent, record.SummaryFlag,
            record.CostingMethod, record.InventoryMethod, record.TaxMethod,
            record.PaymentNameShort, record.ExchangeRate);
}

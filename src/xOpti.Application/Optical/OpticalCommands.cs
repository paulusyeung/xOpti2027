using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Optical;

public sealed record GetOpticalOrderQuery(string TxNumber)
    : IQuery<OpticalOrderDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed record SaveOpticalOrderCommand(
    string TxNumber, IReadOnlyList<FrameDetailInput> Frames,
    IReadOnlyList<LensDetailInput> Lenses, IReadOnlyList<ContactDetailInput> Contacts,
    string Reason)
    : ICommand<OpticalOrderDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed record RecordOpticalStatusCommand(
    string TxNumber, string Status, string? Reference, string? Notes, string Reason)
    : ICommand<OpticalOrderDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed class FrameDetailValidator : AbstractValidator<FrameDetailInput>
{
    public FrameDetailValidator()
    {
        RuleFor(x => x.LineNumber).GreaterThan(0);
        RuleFor(x => x.Mode).NotEmpty().MaximumLength(30);
        RuleFor(x => x.EyeSize).NotEmpty().MaximumLength(6);
        RuleFor(x => x.Bridge).GreaterThan(0).When(x => x.Bridge is not null);
        RuleFor(x => x.Temple).GreaterThan(0).When(x => x.Temple is not null);
    }
}

public sealed class LensDetailValidator : AbstractValidator<LensDetailInput>
{
    public LensDetailValidator()
    {
        RuleFor(x => x.LineNumber).GreaterThan(0);
        RuleFor(x => x.Right.Sphere).NotNull();
        RuleFor(x => x.Right.Cylinder).NotNull();
        RuleFor(x => x.Right.Axis).NotNull().InclusiveBetween(0, 180);
        RuleFor(x => x.Left.Sphere).NotNull();
        RuleFor(x => x.Left.Cylinder).NotNull();
        RuleFor(x => x.Left.Axis).NotNull().InclusiveBetween(0, 180);
    }
}

public sealed class ContactDetailValidator : AbstractValidator<ContactDetailInput>
{
    public ContactDetailValidator()
    {
        RuleFor(x => x.LineNumber).GreaterThan(0);
        RuleFor(x => x.Right.Sphere).NotNull();
        RuleFor(x => x.Right.Cylinder).NotNull();
        RuleFor(x => x.Right.Axis).NotNull().InclusiveBetween(0, 180);
        RuleFor(x => x.Left.Sphere).NotNull();
        RuleFor(x => x.Left.Cylinder).NotNull();
        RuleFor(x => x.Left.Axis).NotNull().InclusiveBetween(0, 180);
    }
}

public sealed class SaveOpticalOrderCommandValidator : AbstractValidator<SaveOpticalOrderCommand>
{
    public SaveOpticalOrderCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty().MaximumLength(10);
        RuleForEach(x => x.Frames).SetValidator(new FrameDetailValidator());
        RuleForEach(x => x.Lenses).SetValidator(new LensDetailValidator());
        RuleForEach(x => x.Contacts).SetValidator(new ContactDetailValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class RecordOpticalStatusCommandValidator : AbstractValidator<RecordOpticalStatusCommand>
{
    public RecordOpticalStatusCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty();
        RuleFor(x => x.Status).Must(status =>
            status is "ordered" or "received" or "dispensed");
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class GetOpticalOrderHandler(IOpticalOrderStore store)
    : IRequestHandler<GetOpticalOrderQuery, OpticalOrderDto>
{
    public async Task<OpticalOrderDto> Handle(GetOpticalOrderQuery request, CancellationToken ct) =>
        await store.GetAsync(request.TxNumber, ct)
        ?? throw new ValidationFailedException(new[]
        {
            new ValidationFieldError("TxNumber", "not-found", "Sale order was not found."),
        });
}

public sealed class SaveOpticalOrderHandler(
    IUnitOfWork unitOfWork, IOpticalOrderStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<SaveOpticalOrderCommand, OpticalOrderDto>
{
    public Task<OpticalOrderDto> Handle(SaveOpticalOrderCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            await store.SaveAsync(request.TxNumber, request.Frames, request.Lenses,
                request.Contacts, request.Reason, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("optical.details.save", "TxHeader",
                request.TxNumber, JsonSerializer.Serialize(new
                {
                    frames = request.Frames.Count, lenses = request.Lenses.Count,
                    contacts = request.Contacts.Count, request.Reason,
                })), token);
            return await store.GetAsync(request.TxNumber, token)
                ?? throw new InvalidOperationException();
        }, ct);
}

public sealed class RecordOpticalStatusHandler(
    IUnitOfWork unitOfWork, IOpticalOrderStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<RecordOpticalStatusCommand, OpticalOrderDto>
{
    public Task<OpticalOrderDto> Handle(RecordOpticalStatusCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            await store.RecordStatusAsync(request.TxNumber, request.Status, request.Reference,
                request.Notes, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("optical.status", "TxHeader",
                request.TxNumber, JsonSerializer.Serialize(new
                {
                    status = request.Status, request.Reference, request.Notes,
                    request.Reason,
                })), token);
            return await store.GetAsync(request.TxNumber, token)
                ?? throw new InvalidOperationException();
        }, ct);
}

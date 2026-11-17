using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Prescriptions;

public sealed record GetPrescriptionHistoryQuery(int CustomerId)
    : IQuery<PrescriptionHistoryDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.PrescriptionView };
}

public sealed record SaveSpectaclePrescriptionCommand(
    int CustomerId, SpectaclePrescriptionInput Input, string Reason)
    : ICommand<PrescriptionHistoryDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.PrescriptionEnter };
}

public sealed record SaveContactLensPrescriptionCommand(
    int CustomerId, ContactLensPrescriptionInput Input, string Reason)
    : ICommand<PrescriptionHistoryDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.PrescriptionEnter };
}

public sealed record VerifyPrescriptionCommand(
    int CustomerId, string Type, long VersionId, string? Note, string Reason)
    : ICommand<PrescriptionHistoryDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.PrescriptionEnter };
}

public sealed record AddMedicalNoteCommand(int CustomerId, string Note, string Reason)
    : ICommand<PrescriptionHistoryDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.PrescriptionEnter };
}

public sealed record UploadPatientAttachmentCommand(
    int CustomerId, string Kind, string? PrescriptionType, long? PrescriptionVersionId,
    string FileName, string ContentType, byte[] Content, string Reason)
    : ICommand<PrescriptionHistoryDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.PrescriptionEnter };
}

public sealed record GetPatientAttachmentQuery(long AttachmentId)
    : IQuery<PatientAttachmentContent>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.PrescriptionView };
}

public sealed class SpectacleEyeValidator : AbstractValidator<SpectacleEyeValues>
{
    public SpectacleEyeValidator()
    {
        RuleFor(x => x.Sphere).NotNull().InclusiveBetween(-30m, 30m);
        RuleFor(x => x.Cylinder).NotNull().InclusiveBetween(-15m, 15m);
        RuleFor(x => x.Axis).NotNull().InclusiveBetween(0, 180);
        RuleFor(x => x.Add).InclusiveBetween(0m, 10m).When(x => x.Add is not null);
        RuleFor(x => x.Prism).InclusiveBetween(-20m, 20m).When(x => x.Prism is not null);
        RuleFor(x => x.Base).InclusiveBetween(0m, 360m).When(x => x.Base is not null);
        RuleFor(x => x.Pd).InclusiveBetween(0m, 100m).When(x => x.Pd is not null);
    }
}

public sealed class SaveSpectaclePrescriptionCommandValidator
    : AbstractValidator<SaveSpectaclePrescriptionCommand>
{
    public SaveSpectaclePrescriptionCommandValidator()
    {
        RuleFor(x => x.CustomerId).GreaterThan(0);
        RuleFor(x => x.Input.Right).SetValidator(new SpectacleEyeValidator());
        RuleFor(x => x.Input.Left).SetValidator(new SpectacleEyeValidator());
        RuleFor(x => x.Input.IssuedOn).NotEqual(default(DateTimeOffset));
        RuleFor(x => x.Input.Notes).MaximumLength(2000);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class SaveContactLensPrescriptionCommandValidator
    : AbstractValidator<SaveContactLensPrescriptionCommand>
{
    public SaveContactLensPrescriptionCommandValidator()
    {
        RuleFor(x => x.CustomerId).GreaterThan(0);
        RuleFor(x => x.Input.IssuedOn).NotEqual(default(DateTimeOffset));
        RuleFor(x => x.Input.Brand).MaximumLength(80);
        RuleFor(x => x.Input.BaseCurve).InclusiveBetween(7m, 10m).When(x => x.Input.BaseCurve is not null);
        RuleFor(x => x.Input.Diameter).InclusiveBetween(12m, 16m).When(x => x.Input.Diameter is not null);
        RuleFor(x => x.Input.RightPower).InclusiveBetween(-20m, 20m).When(x => x.Input.RightPower is not null);
        RuleFor(x => x.Input.LeftPower).InclusiveBetween(-20m, 20m).When(x => x.Input.LeftPower is not null);
        RuleFor(x => x.Input.RightCylinder).InclusiveBetween(-10m, 10m)
            .When(x => x.Input.RightCylinder is not null);
        RuleFor(x => x.Input.LeftCylinder).InclusiveBetween(-10m, 10m)
            .When(x => x.Input.LeftCylinder is not null);
        RuleFor(x => x.Input.RightAxis).InclusiveBetween(0, 180).When(x => x.Input.RightAxis is not null);
        RuleFor(x => x.Input.LeftAxis).InclusiveBetween(0, 180).When(x => x.Input.LeftAxis is not null);
        RuleFor(x => x.Input.ReplacementSchedule).MaximumLength(40);
        RuleFor(x => x.Input.Notes).MaximumLength(2000);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class GetPrescriptionHistoryHandler(IPrescriptionStore store, IAuditRecorder audit)
    : IRequestHandler<GetPrescriptionHistoryQuery, PrescriptionHistoryDto>
{
    public async Task<PrescriptionHistoryDto> Handle(
        GetPrescriptionHistoryQuery request, CancellationToken ct)
    {
        var history = await store.GetHistoryAsync(request.CustomerId, ct);
        await audit.RecordAsync(new AuditRecord("prescription.view", "Customer",
            request.CustomerId.ToString(), JsonSerializer.Serialize(new
            {
                spectacle = history.Spectacle.Count,
                contact = history.Contact.Count,
                attachments = history.Attachments.Count,
            })), ct);
        return history;
    }
}

public sealed class SaveSpectaclePrescriptionHandler(
    IUnitOfWork unitOfWork, IPrescriptionStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<SaveSpectaclePrescriptionCommand, PrescriptionHistoryDto>
{
    public Task<PrescriptionHistoryDto> Handle(
        SaveSpectaclePrescriptionCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var id = await store.SaveSpectacleAsync(request.CustomerId, request.Input,
                request.Reason, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("prescription.spectacle.save", "Customer",
                request.CustomerId.ToString(), JsonSerializer.Serialize(new
                {
                    versionId = id, reason = request.Reason,
                    issuedOn = request.Input.IssuedOn,
                })), token);
            return await store.GetHistoryAsync(request.CustomerId, token);
        }, ct);
}

public sealed class SaveContactLensPrescriptionHandler(
    IUnitOfWork unitOfWork, IPrescriptionStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<SaveContactLensPrescriptionCommand, PrescriptionHistoryDto>
{
    public Task<PrescriptionHistoryDto> Handle(
        SaveContactLensPrescriptionCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var id = await store.SaveContactLensAsync(request.CustomerId, request.Input,
                request.Reason, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("prescription.contact.save", "Customer",
                request.CustomerId.ToString(), JsonSerializer.Serialize(new
                {
                    versionId = id, reason = request.Reason,
                    issuedOn = request.Input.IssuedOn,
                })), token);
            return await store.GetHistoryAsync(request.CustomerId, token);
        }, ct);
}

public sealed class VerifyPrescriptionHandler(
    IUnitOfWork unitOfWork, IPrescriptionStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<VerifyPrescriptionCommand, PrescriptionHistoryDto>
{
    public Task<PrescriptionHistoryDto> Handle(
        VerifyPrescriptionCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            if (request.Type is not ("spectacle" or "contact"))
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Type", "invalid", "Type must be spectacle or contact."),
                });
            await store.VerifyAsync(request.CustomerId, request.Type, request.VersionId,
                request.Note, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("prescription.verify", "Customer",
                request.CustomerId.ToString(), JsonSerializer.Serialize(new
                {
                    request.Type, request.VersionId, request.Reason, request.Note,
                })), token);
            return await store.GetHistoryAsync(request.CustomerId, token);
        }, ct);
}

public sealed class AddMedicalNoteHandler(
    IUnitOfWork unitOfWork, IPrescriptionStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<AddMedicalNoteCommand, PrescriptionHistoryDto>
{
    public Task<PrescriptionHistoryDto> Handle(AddMedicalNoteCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var id = await store.AddMedicalNoteAsync(request.CustomerId, request.Note,
                principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("prescription.medical-note", "Customer",
                request.CustomerId.ToString(), JsonSerializer.Serialize(new
                {
                    noteId = id, reason = request.Reason,
                })), token);
            return await store.GetHistoryAsync(request.CustomerId, token);
        }, ct);
}

public sealed class UploadPatientAttachmentHandler(
    IUnitOfWork unitOfWork, IPrescriptionStore store, IPrescriptionPolicy policy,
    IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<UploadPatientAttachmentCommand, PrescriptionHistoryDto>
{
    public Task<PrescriptionHistoryDto> Handle(
        UploadPatientAttachmentCommand request, CancellationToken ct)
    {
        if (request.Content.LongLength > policy.MaxAttachmentBytes)
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("Content", "too-large",
                    $"Attachment exceeds the {policy.MaxAttachmentBytes} byte limit."),
            });
        if (!policy.AllowedAttachmentContentTypes.Contains(request.ContentType))
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("ContentType", "unsupported",
                    "Attachment type must be PDF, JPEG, or PNG."),
            });

        return unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var id = await store.AddAttachmentAsync(request.CustomerId, request.Kind,
                request.PrescriptionType, request.PrescriptionVersionId, request.FileName,
                request.ContentType, request.Content, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("prescription.attachment.upload", "Customer",
                request.CustomerId.ToString(), JsonSerializer.Serialize(new
                {
                    attachmentId = id, request.Kind, request.ContentType,
                    request.FileName, request.Reason,
                })), token);
            return await store.GetHistoryAsync(request.CustomerId, token);
        }, ct);
    }
}

public sealed class GetPatientAttachmentHandler(
    IPrescriptionStore store, IAuditRecorder audit)
    : IRequestHandler<GetPatientAttachmentQuery, PatientAttachmentContent>
{
    public async Task<PatientAttachmentContent> Handle(
        GetPatientAttachmentQuery request, CancellationToken ct)
    {
        var content = await store.ReadAttachmentAsync(request.AttachmentId, ct)
            ?? throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("AttachmentId", "not-found", "Attachment was not found."),
            });
        await audit.RecordAsync(new AuditRecord("prescription.attachment.access", "Customer",
            content.Metadata.CustomerId.ToString(), JsonSerializer.Serialize(new
            {
                attachmentId = request.AttachmentId,
                content.Metadata.FileName,
            })), ct);
        return content;
    }
}

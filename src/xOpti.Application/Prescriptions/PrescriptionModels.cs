using xOpti.Application.Customers;

namespace xOpti.Application.Prescriptions;

public sealed record SpectacleEyeValues(
    decimal? Sphere, decimal? Cylinder, int? Axis, decimal? Add, decimal? Prism,
    decimal? Base, decimal? Pd);

public sealed record SpectaclePrescriptionInput(
    DateTimeOffset IssuedOn, int? PrescriberId, SpectacleEyeValues Right,
    SpectacleEyeValues Left, string? Notes);

public sealed record ContactLensPrescriptionInput(
    DateTimeOffset IssuedOn, int? PrescriberId, string? Brand, decimal? BaseCurve,
    decimal? Diameter, decimal? RightPower, decimal? RightCylinder, int? RightAxis,
    decimal? LeftPower, decimal? LeftCylinder, int? LeftAxis,
    string? ReplacementSchedule, string? Notes);

public sealed record SpectacleVersionDto(
    long Id, int CustomerId, int VersionNumber, string Source, DateTimeOffset IssuedOn,
    int? PrescriberId, SpectacleEyeValues Right, SpectacleEyeValues Left, string? Notes,
    string Reason, bool IsCurrent, DateTimeOffset? VerifiedAt, string? VerifiedBy,
    string? VerificationNote);

public sealed record ContactVersionDto(
    long Id, int CustomerId, int VersionNumber, string Source, DateTimeOffset IssuedOn,
    int? PrescriberId, string? Brand, decimal? BaseCurve, decimal? Diameter,
    decimal? RightPower, decimal? RightCylinder, int? RightAxis, decimal? LeftPower,
    decimal? LeftCylinder, int? LeftAxis, string? ReplacementSchedule, string? Notes,
    string Reason, bool IsCurrent, DateTimeOffset? VerifiedAt, string? VerifiedBy,
    string? VerificationNote);

public sealed record MedicalNoteDto(
    long Id, int CustomerId, string Note, DateTimeOffset RecordedAt, string? RecordedBy);

public sealed record PatientAttachmentDto(
    long Id, int CustomerId, string Kind, string? PrescriptionType, long? PrescriptionVersionId,
    string FileName, string ContentType, long Size, DateTimeOffset UploadedAt, string? UploadedBy);

public sealed record PatientAttachmentContent(PatientAttachmentDto Metadata, byte[] Content);

public sealed record PrescriptionHistoryDto(
    int CustomerId, CustomerMedicalDto? Medical,
    IReadOnlyList<SpectacleVersionDto> Spectacle,
    IReadOnlyList<ContactVersionDto> Contact,
    IReadOnlyList<MedicalNoteDto> MedicalNotes,
    IReadOnlyList<PatientAttachmentDto> Attachments);

public interface IPrescriptionStore
{
    Task<PrescriptionHistoryDto> GetHistoryAsync(int customerId, CancellationToken ct);
    Task<long> SaveSpectacleAsync(int customerId, SpectaclePrescriptionInput input,
        string reason, string? actor, CancellationToken ct);
    Task<long> SaveContactLensAsync(int customerId, ContactLensPrescriptionInput input,
        string reason, string? actor, CancellationToken ct);
    Task VerifyAsync(int customerId, string type, long versionId, string? note,
        string? actor, CancellationToken ct);
    Task<bool> HasVerifiedCurrentAsync(int customerId, string type, CancellationToken ct);
    Task<long> AddMedicalNoteAsync(int customerId, string note, string? actor, CancellationToken ct);
    Task<long> AddAttachmentAsync(int customerId, string kind, string? prescriptionType,
        long? versionId, string fileName, string contentType, byte[] content,
        string? actor, CancellationToken ct);
    Task<PatientAttachmentContent?> ReadAttachmentAsync(long attachmentId, CancellationToken ct);
}

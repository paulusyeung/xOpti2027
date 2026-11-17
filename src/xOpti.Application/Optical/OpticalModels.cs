namespace xOpti.Application.Optical;

public sealed record OpticalEyeValues(
    decimal? Sphere, decimal? Cylinder, int? Axis, decimal? Pd, decimal? Add,
    decimal? Prism, decimal? Base, decimal? SegHeight, decimal? Oc, decimal? Vd);

public sealed record FrameDetailInput(
    int LineNumber, bool Supply, bool Enclosed, bool Follow, bool Lenses,
    string? Mode, string? Color, string? EyeSize, int? Bridge, int? Temple,
    string? R1, string? R2, string? R3, string? A, string? B, string? SpecialInstruction);

public sealed record LensDetailInput(
    int LineNumber, long? PrescriptionVersionId, OpticalEyeValues Right,
    OpticalEyeValues Left, string? RightStyle, string? LeftStyle, string? Type,
    string? Hardening, string? Material, string? Coating, string? Tint, string? Others,
    bool HardCoat, bool ArCoat, bool Uv);

public sealed record ContactDetailInput(
    int LineNumber, long? PrescriptionVersionId, OpticalEyeValues Right,
    OpticalEyeValues Left, string? History, string? Medical, string? Allergy,
    string? Reason, string? Evaluation, string? Test, string? SpecialInstruction);

public sealed record FrameDetailDto(
    int LineNumber, bool Supply, bool Enclosed, bool Follow, bool Lenses, string? Mode,
    string? Color, string? EyeSize, int Bridge, int Temple, string? R1, string? R2,
    string? R3, string? A, string? B, string? SpecialInstruction);

public sealed record LensDetailDto(
    int LineNumber, long? PrescriptionVersionId, OpticalEyeValues Right,
    OpticalEyeValues Left, string? RightStyle, string? LeftStyle, string? Type,
    string? Hardening, string? Material, string? Coating, string? Tint, string? Others,
    bool HardCoat, bool ArCoat, bool Uv);

public sealed record ContactDetailDto(
    int LineNumber, long? PrescriptionVersionId, OpticalEyeValues Right,
    OpticalEyeValues Left, string? History, string? Medical, string? Allergy,
    string? Reason, string? Evaluation, string? Test, string? SpecialInstruction);

public sealed record OpticalEventDto(
    long Id, string Status, DateTimeOffset OccurredAt, string? Actor,
    string? Reference, string? Notes);

public sealed record OpticalOrderDto(
    string TxNumber, int CustomerId, string? CustomerName, string? OrderStatus,
    IReadOnlyList<FrameDetailDto> Frames, IReadOnlyList<LensDetailDto> Lenses,
    IReadOnlyList<ContactDetailDto> Contacts, IReadOnlyList<OpticalEventDto> Events,
    string Status);

public interface IOpticalOrderStore
{
    Task<OpticalOrderDto?> GetAsync(string txNumber, CancellationToken ct);
    Task SaveAsync(string txNumber, IReadOnlyList<FrameDetailInput> frames,
        IReadOnlyList<LensDetailInput> lenses, IReadOnlyList<ContactDetailInput> contacts,
        string reason, string? actor, CancellationToken ct);
    Task RecordStatusAsync(string txNumber, string status, string? reference,
        string? notes, string? actor, CancellationToken ct);
    Task<IReadOnlyList<string>> ConversionIssuesAsync(
        string txNumber, bool requireVerifiedPrescription, CancellationToken ct);
}

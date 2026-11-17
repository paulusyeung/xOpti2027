namespace xOpti.Infrastructure.Persistence.Entities;

public class SpectaclePrescriptionVersion
{
    public long Id { get; set; }
    public int CustomerId { get; set; }
    public int VersionNumber { get; set; }
    public DateTimeOffset IssuedOn { get; set; }
    public int? PrescriberId { get; set; }
    public decimal? RightSphere { get; set; }
    public decimal? RightCylinder { get; set; }
    public int? RightAxis { get; set; }
    public decimal? RightAdd { get; set; }
    public decimal? RightPrism { get; set; }
    public decimal? RightBase { get; set; }
    public decimal? RightPd { get; set; }
    public decimal? LeftSphere { get; set; }
    public decimal? LeftCylinder { get; set; }
    public int? LeftAxis { get; set; }
    public decimal? LeftAdd { get; set; }
    public decimal? LeftPrism { get; set; }
    public decimal? LeftBase { get; set; }
    public decimal? LeftPd { get; set; }
    public string? Notes { get; set; }
    public string Reason { get; set; } = string.Empty;
    public DateTimeOffset CreatedAt { get; set; }
    public string? CreatedBy { get; set; }
    public bool IsCurrent { get; set; }
    public DateTimeOffset? VerifiedAt { get; set; }
    public string? VerifiedBy { get; set; }
    public string? VerificationNote { get; set; }
}

public class ContactLensPrescriptionVersion
{
    public long Id { get; set; }
    public int CustomerId { get; set; }
    public int VersionNumber { get; set; }
    public DateTimeOffset IssuedOn { get; set; }
    public int? PrescriberId { get; set; }
    public string? Brand { get; set; }
    public decimal? BaseCurve { get; set; }
    public decimal? Diameter { get; set; }
    public decimal? RightPower { get; set; }
    public decimal? RightCylinder { get; set; }
    public int? RightAxis { get; set; }
    public decimal? LeftPower { get; set; }
    public decimal? LeftCylinder { get; set; }
    public int? LeftAxis { get; set; }
    public string? ReplacementSchedule { get; set; }
    public string? Notes { get; set; }
    public string Reason { get; set; } = string.Empty;
    public DateTimeOffset CreatedAt { get; set; }
    public string? CreatedBy { get; set; }
    public bool IsCurrent { get; set; }
    public DateTimeOffset? VerifiedAt { get; set; }
    public string? VerifiedBy { get; set; }
    public string? VerificationNote { get; set; }
}

public class MedicalNote
{
    public long Id { get; set; }
    public int CustomerId { get; set; }
    public string Note { get; set; } = string.Empty;
    public DateTimeOffset RecordedAt { get; set; }
    public string? RecordedBy { get; set; }
}

public class PatientAttachment
{
    public long Id { get; set; }
    public int CustomerId { get; set; }
    public string Kind { get; set; } = string.Empty;
    public string? PrescriptionType { get; set; }
    public long? PrescriptionVersionId { get; set; }
    public string FileName { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
    public long Size { get; set; }
    public string StorageKey { get; set; } = string.Empty;
    public DateTimeOffset UploadedAt { get; set; }
    public string? UploadedBy { get; set; }
}

namespace xOpti.Application.Ports;

public interface IPrescriptionPolicy
{
    bool RequireVerificationBeforeOrder { get; }
    long MaxAttachmentBytes { get; }
    IReadOnlyCollection<string> AllowedAttachmentContentTypes { get; }
}

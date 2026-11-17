using xOpti.Application.Ports;

namespace xOpti.Infrastructure;

public sealed class PrescriptionPolicy(InfrastructureOptions options) : IPrescriptionPolicy
{
    public bool RequireVerificationBeforeOrder => options.RequirePrescriptionVerification;

    public long MaxAttachmentBytes => options.PrescriptionAttachmentMaxBytes;

    public IReadOnlyCollection<string> AllowedAttachmentContentTypes { get; } =
        new[] { "application/pdf", "image/jpeg", "image/png" };
}

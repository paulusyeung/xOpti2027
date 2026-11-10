using xOpti.Domain.Common;

namespace xOpti.Domain.Values;

/// <summary>
/// Attribution and soft-delete invariants carried by auditable records:
/// created/last-modified user and branch must be present; deletion requires
/// a reason code.
/// </summary>
public sealed record AuditInfo
{
    public string CreatedUser { get; }

    public string CreatedBranch { get; }

    public DateTimeOffset CreatedAt { get; }

    public string? ModifiedUser { get; init; }

    public string? ModifiedBranch { get; init; }

    public DateTimeOffset? ModifiedAt { get; init; }

    public bool IsDeleted { get; init; }

    public string? DeleteReasonCode { get; init; }

    private AuditInfo(
        string createdUser,
        string createdBranch,
        DateTimeOffset createdAt,
        string? modifiedUser,
        string? modifiedBranch,
        DateTimeOffset? modifiedAt,
        bool isDeleted,
        string? deleteReasonCode)
    {
        CreatedUser = createdUser;
        CreatedBranch = createdBranch;
        CreatedAt = createdAt;
        ModifiedUser = modifiedUser;
        ModifiedBranch = modifiedBranch;
        ModifiedAt = modifiedAt;
        IsDeleted = isDeleted;
        DeleteReasonCode = deleteReasonCode;
    }

    public static Result<AuditInfo> Create(string? user, string? branch, DateTimeOffset now)
    {
        if (string.IsNullOrWhiteSpace(user))
        {
            return Result<AuditInfo>.Failure("Created user attribution is required.");
        }

        if (string.IsNullOrWhiteSpace(branch))
        {
            return Result<AuditInfo>.Failure("Created branch attribution is required.");
        }

        return Result<AuditInfo>.Success(new AuditInfo(
            user.Trim(), branch.Trim(), now, null, null, null, false, null));
    }

    public Result<AuditInfo> WithModification(string? user, string? branch, DateTimeOffset now)
    {
        if (string.IsNullOrWhiteSpace(user))
        {
            return Result<AuditInfo>.Failure("Modified user attribution is required.");
        }

        if (string.IsNullOrWhiteSpace(branch))
        {
            return Result<AuditInfo>.Failure("Modified branch attribution is required.");
        }

        return Result<AuditInfo>.Success(this with
        {
            ModifiedUser = user.Trim(),
            ModifiedBranch = branch.Trim(),
            ModifiedAt = now,
        });
    }

    public Result<AuditInfo> MarkDeleted(string? reasonCode, string? user, string? branch, DateTimeOffset now)
    {
        if (string.IsNullOrWhiteSpace(reasonCode))
        {
            return Result<AuditInfo>.Failure("Soft delete requires a reason code.");
        }

        return WithModification(user, branch, now).Map(info => info with
        {
            IsDeleted = true,
            DeleteReasonCode = reasonCode.Trim(),
        });
    }
}

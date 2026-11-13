using FluentValidation;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Identity.Staff;

/// <summary>
/// Completes a forced first sign-in reset. Anonymous by design (the token is
/// the credential), non-enumerating, and audited as a security event.
/// </summary>
public sealed record CompletePasswordResetCommand(string UserName, string Token, string NewPassword)
    : ICommand<PasswordResetCompletedDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => Array.Empty<string>();
}

public sealed record PasswordResetCompletedDto(string UserName);

public sealed class CompletePasswordResetCommandValidator : AbstractValidator<CompletePasswordResetCommand>
{
    public CompletePasswordResetCommandValidator()
    {
        RuleFor(x => x.UserName).NotEmpty().MaximumLength(64);
        RuleFor(x => x.Token).NotEmpty();
        RuleFor(x => x.NewPassword).NotEmpty().MinimumLength(10).MaximumLength(128);
    }
}

public sealed class CompletePasswordResetHandler(
    IUnitOfWork unitOfWork,
    IStaffAccountStore store,
    IAuditRecorder audit)
    : IRequestHandler<CompletePasswordResetCommand, PasswordResetCompletedDto>
{
    public Task<PasswordResetCompletedDto> Handle(
        CompletePasswordResetCommand request,
        CancellationToken cancellationToken) =>
        unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            var outcome = await store.CompletePasswordResetAsync(
                request.UserName, request.Token, request.NewPassword, ct);

            if (!outcome.Succeeded && outcome.TokenInvalid)
            {
                // Same message for an unknown account and a bad/expired token.
                throw new DomainRuleException("The reset link is invalid or has expired.");
            }

            if (!outcome.Succeeded)
            {
                throw new ValidationFailedException(outcome.Errors
                    .Select(error => new ValidationFieldError("NewPassword", error.Code, error.Description))
                    .ToList());
            }

            await audit.RecordAsync(new AuditRecord(
                "staff.password-reset-completed",
                "StaffAccount",
                request.UserName,
                null), ct);

            return new PasswordResetCompletedDto(request.UserName);
        }, cancellationToken);
}

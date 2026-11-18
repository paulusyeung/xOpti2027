using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Wholesale;

public sealed record GetWholesaleAccountQuery(int CustomerId)
    : IQuery<WholesaleAccountDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record SaveWholesaleAccountCommand(
    int CustomerId, WholesaleAccountInput Input, string Reason)
    : ICommand<WholesaleAccountDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.MasterDataMaintain };
}

public sealed class WholesaleAccountInputValidator : AbstractValidator<WholesaleAccountInput>
{
    private static readonly string[] Grades = { "A", "B", "C" };

    public WholesaleAccountInputValidator()
    {
        RuleFor(x => x.PriceGrade)
            .NotEmpty()
            .Must(grade => Grades.Contains(grade?.Trim().ToUpperInvariant()))
            .WithMessage("Price grade must be A, B, or C.");
        RuleFor(x => x.TermsCode).NotEmpty().MaximumLength(20);
        RuleFor(x => x.TermsDays).InclusiveBetween(0, 365);
        RuleFor(x => x.CreditLimit).GreaterThanOrEqualTo(0);
        RuleFor(x => x.TaxTreatment).NotEmpty().MaximumLength(20);
        RuleFor(x => x.RepresentativeStaffCode).MaximumLength(4);
        RuleFor(x => x.Notes).MaximumLength(1000);
    }
}

public sealed class SaveWholesaleAccountCommandValidator
    : AbstractValidator<SaveWholesaleAccountCommand>
{
    public SaveWholesaleAccountCommandValidator()
    {
        RuleFor(x => x.CustomerId).GreaterThan(0);
        RuleFor(x => x.Input).SetValidator(new WholesaleAccountInputValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class GetWholesaleAccountHandler(IWholesaleAccountStore store)
    : IRequestHandler<GetWholesaleAccountQuery, WholesaleAccountDto>
{
    public async Task<WholesaleAccountDto> Handle(
        GetWholesaleAccountQuery request, CancellationToken ct) =>
        await store.GetAsync(request.CustomerId, ct)
        ?? throw new ValidationFailedException(new[]
        {
            new ValidationFieldError("CustomerId", "not-wholesale",
                "The customer does not have a wholesale account."),
        });
}

public sealed class SaveWholesaleAccountHandler(
    IUnitOfWork unitOfWork, IWholesaleAccountStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<SaveWholesaleAccountCommand, WholesaleAccountDto>
{
    public Task<WholesaleAccountDto> Handle(
        SaveWholesaleAccountCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var account = await store.SaveAsync(request.CustomerId, request.Input,
                principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("wholesale.account.save",
                "WholesaleAccount", request.CustomerId.ToString(),
                JsonSerializer.Serialize(new
                {
                    account.PriceGrade,
                    account.TermsCode,
                    account.TermsDays,
                    account.CreditLimit,
                    account.TaxTreatment,
                    account.RepresentativeStaffCode,
                    account.CreditHold,
                    request.Reason,
                })), token);
            return account;
        }, ct);
}

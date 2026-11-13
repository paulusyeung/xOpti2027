using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Ports;

namespace xOpti.Application.Identity.Staff;

/// <summary>Creates a staff account without a password; the response carries a reset token.</summary>
public sealed record CreateStaffCommand(
    string UserName,
    string? DisplayName,
    string Role,
    string? BranchCode,
    string Reason)
    : ICommand<StaffCredentialsDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class CreateStaffCommandValidator : AbstractValidator<CreateStaffCommand>
{
    public CreateStaffCommandValidator(IRoleCatalogue roles)
    {
        RuleFor(x => x.UserName).NotEmpty().MaximumLength(64)
            .Matches("^[A-Za-z0-9._-]+$").WithMessage("Username may contain letters, digits, '.', '_' and '-' only.");
        RuleFor(x => x.DisplayName).MaximumLength(100);
        RuleFor(x => x.Role).NotEmpty()
            .Must(roles.Exists).WithMessage("Role is not part of the approved permission matrix.");
        RuleFor(x => x.BranchCode).MaximumLength(3);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CreateStaffHandler(
    IUnitOfWork unitOfWork,
    IStaffAccountStore store,
    IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<CreateStaffCommand, StaffCredentialsDto>
{
    public Task<StaffCredentialsDto> Handle(CreateStaffCommand request, CancellationToken cancellationToken) =>
        unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            if (await store.UserNameExistsAsync(request.UserName, ct))
            {
                throw new DomainRuleException($"A staff account '{request.UserName}' already exists.");
            }

            if (!string.IsNullOrWhiteSpace(request.BranchCode) && !await store.BranchExistsAsync(request.BranchCode, ct))
            {
                throw new DomainRuleException($"Branch '{request.BranchCode}' was not found.");
            }

            var (account, token) = await store.CreateAsync(
                new NewStaffAccount(request.UserName, request.DisplayName, request.Role, request.BranchCode), ct);

            await audit.RecordAsync(new AuditRecord(
                "staff.create",
                "StaffAccount",
                account.UserName,
                StaffAuditDetails.Build(request.Reason, before: null, after: account)), ct);

            return new StaffCredentialsDto(StaffProjection.ToDto(account, principal), token);
        }, cancellationToken);
}

/// <summary>Disables an account and invalidates its sessions.</summary>
public sealed record DisableStaffCommand(string UserId, string Reason)
    : ICommand<StaffAccountDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class DisableStaffCommandValidator : AbstractValidator<DisableStaffCommand>
{
    public DisableStaffCommandValidator()
    {
        RuleFor(x => x.UserId).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class DisableStaffHandler(
    IUnitOfWork unitOfWork,
    IStaffAccountStore store,
    IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<DisableStaffCommand, StaffAccountDto>
{
    public Task<StaffAccountDto> Handle(DisableStaffCommand request, CancellationToken cancellationToken) =>
        unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            var account = await store.FindByIdAsync(request.UserId, ct)
                ?? throw new DomainRuleException($"Staff account '{request.UserId}' was not found.");
            var updated = await store.SetDisabledAsync(account, true, ct);

            await audit.RecordAsync(new AuditRecord(
                "staff.disable",
                "StaffAccount",
                updated.UserName,
                StaffAuditDetails.Build(request.Reason, account, updated)), ct);

            return StaffProjection.ToDto(updated, principal);
        }, cancellationToken);
}

/// <summary>Re-enables a disabled account and clears failed-attempt lockout.</summary>
public sealed record EnableStaffCommand(string UserId, string Reason)
    : ICommand<StaffAccountDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class EnableStaffCommandValidator : AbstractValidator<EnableStaffCommand>
{
    public EnableStaffCommandValidator()
    {
        RuleFor(x => x.UserId).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class EnableStaffHandler(
    IUnitOfWork unitOfWork,
    IStaffAccountStore store,
    IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<EnableStaffCommand, StaffAccountDto>
{
    public Task<StaffAccountDto> Handle(EnableStaffCommand request, CancellationToken cancellationToken) =>
        unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            var account = await store.FindByIdAsync(request.UserId, ct)
                ?? throw new DomainRuleException($"Staff account '{request.UserId}' was not found.");
            var updated = await store.SetDisabledAsync(account, false, ct);

            await audit.RecordAsync(new AuditRecord(
                "staff.enable",
                "StaffAccount",
                updated.UserName,
                StaffAuditDetails.Build(request.Reason, account, updated)), ct);

            return StaffProjection.ToDto(updated, principal);
        }, cancellationToken);
}

/// <summary>Forces a password reset and returns the administrator-issued token.</summary>
public sealed record ForceStaffResetCommand(string UserId, string Reason)
    : ICommand<StaffCredentialsDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class ForceStaffResetCommandValidator : AbstractValidator<ForceStaffResetCommand>
{
    public ForceStaffResetCommandValidator()
    {
        RuleFor(x => x.UserId).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class ForceStaffResetHandler(
    IUnitOfWork unitOfWork,
    IStaffAccountStore store,
    IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<ForceStaffResetCommand, StaffCredentialsDto>
{
    public Task<StaffCredentialsDto> Handle(ForceStaffResetCommand request, CancellationToken cancellationToken) =>
        unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            var account = await store.FindByIdAsync(request.UserId, ct)
                ?? throw new DomainRuleException($"Staff account '{request.UserId}' was not found.");
            var (updated, token) = await store.ForceResetAsync(account, ct);

            await audit.RecordAsync(new AuditRecord(
                "staff.force-reset",
                "StaffAccount",
                updated.UserName,
                StaffAuditDetails.Build(request.Reason, account, updated)), ct);

            return new StaffCredentialsDto(StaffProjection.ToDto(updated, principal), token);
        }, cancellationToken);
}

/// <summary>Replaces the account's role with one from the approved matrix.</summary>
public sealed record ChangeStaffRoleCommand(string UserId, string Role, string Reason)
    : ICommand<StaffAccountDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class ChangeStaffRoleCommandValidator : AbstractValidator<ChangeStaffRoleCommand>
{
    public ChangeStaffRoleCommandValidator(IRoleCatalogue roles)
    {
        RuleFor(x => x.UserId).NotEmpty();
        RuleFor(x => x.Role).NotEmpty()
            .Must(roles.Exists).WithMessage("Role is not part of the approved permission matrix.");
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class ChangeStaffRoleHandler(
    IUnitOfWork unitOfWork,
    IStaffAccountStore store,
    IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<ChangeStaffRoleCommand, StaffAccountDto>
{
    public Task<StaffAccountDto> Handle(ChangeStaffRoleCommand request, CancellationToken cancellationToken) =>
        unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            var account = await store.FindByIdAsync(request.UserId, ct)
                ?? throw new DomainRuleException($"Staff account '{request.UserId}' was not found.");
            var updated = await store.SetRoleAsync(account, request.Role, ct);

            await audit.RecordAsync(new AuditRecord(
                "staff.role-change",
                "StaffAccount",
                updated.UserName,
                StaffAuditDetails.Build(request.Reason, account, updated)), ct);

            return StaffProjection.ToDto(updated, principal);
        }, cancellationToken);
}

/// <summary>Sets the account's default branch (the branch claim it receives at sign-in).</summary>
public sealed record SetStaffBranchCommand(string UserId, string? BranchCode, string Reason)
    : ICommand<StaffAccountDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class SetStaffBranchCommandValidator : AbstractValidator<SetStaffBranchCommand>
{
    public SetStaffBranchCommandValidator()
    {
        RuleFor(x => x.UserId).NotEmpty();
        RuleFor(x => x.BranchCode).MaximumLength(3);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class SetStaffBranchHandler(
    IUnitOfWork unitOfWork,
    IStaffAccountStore store,
    IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<SetStaffBranchCommand, StaffAccountDto>
{
    public Task<StaffAccountDto> Handle(SetStaffBranchCommand request, CancellationToken cancellationToken) =>
        unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            var account = await store.FindByIdAsync(request.UserId, ct)
                ?? throw new DomainRuleException($"Staff account '{request.UserId}' was not found.");

            if (!string.IsNullOrWhiteSpace(request.BranchCode) && !await store.BranchExistsAsync(request.BranchCode, ct))
            {
                throw new DomainRuleException($"Branch '{request.BranchCode}' was not found.");
            }

            var updated = await store.SetBranchAsync(account, request.BranchCode, ct);

            await audit.RecordAsync(new AuditRecord(
                "staff.branch-scope",
                "StaffAccount",
                updated.UserName,
                StaffAuditDetails.Build(request.Reason, account, updated)), ct);

            return StaffProjection.ToDto(updated, principal);
        }, cancellationToken);
}

internal static class StaffAuditDetails
{
    /// <summary>One allow-listed audit payload: reason plus before/after access state.</summary>
    public static string Build(string reason, StaffAccount? before, StaffAccount? after)
    {
        object? beforeSnapshot = before is null ? null : Snapshot(before);
        object? afterSnapshot = after is null ? null : Snapshot(after);
        return JsonSerializer.Serialize(new { reason, before = beforeSnapshot, after = afterSnapshot });
    }

    private static JsonElement Snapshot(StaffAccount account)
    {
        using var document = JsonDocument.Parse(StaffProjection.AuditSnapshot(account));
        return document.RootElement.Clone();
    }
}

using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Ports;

namespace xOpti.Application.Settings;

public sealed record PreferencesDto(
    string SerialNumber,
    string Platform,
    string ProductName,
    string UserName,
    string? UserAddress,
    string OwnerName,
    string? OwnerAddress,
    string? GstNumber,
    string? PstNumber,
    double TaxARate,
    double TaxBRate,
    int NextInvoiceNumber,
    int NextInvtControlNumber);

public sealed record CounterDto(string Prefix, int NextNumber, string Description, string? Value);

public sealed record PreferenceSettingsDto(
    PreferencesDto Preferences,
    IReadOnlyList<CounterDto> Counters,
    IReadOnlyList<string> RequiredFamilies,
    IReadOnlyList<string> MissingFamilies);

public static class RequiredTransactionFamilies
{
    public static readonly IReadOnlyList<string> All = new[]
    {
        "RC", "RS", "SR", "RJ", "SJ", "WC", "WR", "SA", "LA", "PR", "QT", "TN", "TU",
    };
}

public interface IPreferencesStore
{
    Task<PreferencesDto> GetAsync(CancellationToken ct);
    Task UpdateAsync(PreferencesDto preferences, CancellationToken ct);
    Task<IReadOnlyList<CounterDto>> GetCountersAsync(CancellationToken ct);
}

public sealed record GetPreferencesQuery : IQuery<PreferenceSettingsDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class GetPreferencesHandler(IPreferencesStore store)
    : IRequestHandler<GetPreferencesQuery, PreferenceSettingsDto>
{
    public async Task<PreferenceSettingsDto> Handle(GetPreferencesQuery request, CancellationToken ct)
    {
        var preferences = await store.GetAsync(ct);
        var counters = await store.GetCountersAsync(ct);
        var present = counters.Select(counter => counter.Prefix).ToHashSet(StringComparer.OrdinalIgnoreCase);
        var missing = RequiredTransactionFamilies.All
            .Where(family => !present.Contains(family))
            .ToList();

        return new PreferenceSettingsDto(preferences, counters, RequiredTransactionFamilies.All, missing);
    }
}

public sealed record UpdatePreferencesCommand(
    string ProductName,
    string UserName,
    string? UserAddress,
    string OwnerName,
    string? OwnerAddress,
    string? GstNumber,
    string? PstNumber,
    double TaxARate,
    double TaxBRate,
    string Reason)
    : ICommand<PreferencesDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class UpdatePreferencesCommandValidator : AbstractValidator<UpdatePreferencesCommand>
{
    public UpdatePreferencesCommandValidator()
    {
        RuleFor(x => x.ProductName).NotEmpty().MaximumLength(128);
        RuleFor(x => x.UserName).NotEmpty().MaximumLength(40);
        RuleFor(x => x.OwnerName).NotEmpty().MaximumLength(40);
        RuleFor(x => x.UserAddress).MaximumLength(128);
        RuleFor(x => x.OwnerAddress).MaximumLength(128);
        RuleFor(x => x.GstNumber).MaximumLength(10);
        RuleFor(x => x.PstNumber).MaximumLength(10);
        RuleFor(x => x.TaxARate).InclusiveBetween(0, 100);
        RuleFor(x => x.TaxBRate).InclusiveBetween(0, 100);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class UpdatePreferencesHandler(
    IUnitOfWork unitOfWork,
    IPreferencesStore store,
    IAuditRecorder audit)
    : IRequestHandler<UpdatePreferencesCommand, PreferencesDto>
{
    public Task<PreferencesDto> Handle(UpdatePreferencesCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var before = await store.GetAsync(token);
            var after = before with
            {
                ProductName = request.ProductName,
                UserName = request.UserName,
                UserAddress = request.UserAddress,
                OwnerName = request.OwnerName,
                OwnerAddress = request.OwnerAddress,
                GstNumber = request.GstNumber,
                PstNumber = request.PstNumber,
                TaxARate = request.TaxARate,
                TaxBRate = request.TaxBRate,
            };

            // Counters are read-only here: required families cannot be removed and
            // next-number values are only advanced by posting.
            await store.UpdateAsync(after, token);
            await audit.RecordAsync(new AuditRecord("preference.update", "Preference", after.SerialNumber,
                JsonSerializer.Serialize(new { reason = request.Reason, before, after })), token);
            return after;
        }, ct);
}

namespace xOpti.Application.Tests.Support;

public sealed record DualGuardCommand(string? IdemKey, string Permission)
    : xOpti.Application.Common.ICommand<string>,
      xOpti.Application.Common.IRequiresIdempotencyKey,
      xOpti.Application.Common.IHasPermissions
{
    public string? IdempotencyKey => IdemKey;

    public IReadOnlyList<string> RequiredPermissions => new[] { Permission };
}

public sealed class DualGuardCommandHandler(FakeExecutionLog log)
    : xOpti.Application.Common.IRequestHandler<DualGuardCommand, string>
{
    public Task<string> Handle(DualGuardCommand request, CancellationToken cancellationToken)
    {
        log.CommandsExecuted++;
        return Task.FromResult("dual");
    }
}

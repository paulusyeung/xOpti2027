using xOpti.Application.Common;
using xOpti.Application.Identity.ListBranches;
using xOpti.Application.Ports;

namespace xOpti.Application.Identity.UpdateBranchName;

/// <summary>
/// Reference concurrency-sensitive write: renames a branch. Two concurrent
/// updates must surface the persistence layer's concurrency conflict (409 at
/// the HTTP edge), never a silent overwrite.
/// </summary>
public sealed record UpdateBranchNameCommand(string BranchCode, string NewName, string? ExpectedCurrentName = null)
    : ICommand<BranchDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => Array.Empty<string>();
}

public sealed class UpdateBranchNameHandler(
    IUnitOfWork unitOfWork,
    IBranchRepository branches) : IRequestHandler<UpdateBranchNameCommand, BranchDto>
{
    public async Task<BranchDto> Handle(UpdateBranchNameCommand request, CancellationToken cancellationToken)
    {
        return await unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            var branch = await branches.FindByCodeAsync(request.BranchCode, ct)
                ?? throw new DomainRuleException($"Branch '{request.BranchCode}' was not found.");

            var renamed = await branches.RenameAsync(branch, request.NewName, request.ExpectedCurrentName, ct);
            return new BranchDto(renamed.BranchCode, renamed.Name, renamed.City);
        }, cancellationToken);
    }
}

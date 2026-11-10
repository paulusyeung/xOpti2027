using xOpti.Application.Common;
using xOpti.Application.Ports;

namespace xOpti.Application.Pipeline;

/// <summary>
/// Wraps command execution in one explicit transaction: commit on success,
/// rollback on any failure. Queries pass through untouched.
/// </summary>
public sealed class TransactionBehavior<TRequest, TResponse>(IUnitOfWork unitOfWork)
    : IBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    public Task<TResponse> Handle(
        TRequest request,
        CancellationToken cancellationToken,
        RequestHandlerDelegate<TResponse> next)
    {
        if (!IsCommand(typeof(TRequest)))
        {
            return next();
        }

        return unitOfWork.ExecuteInTransactionAsync(_ => next(), cancellationToken);
    }

    private static bool IsCommand(Type requestType) =>
        requestType.GetInterfaces()
            .Any(i => i.IsGenericType && i.GetGenericTypeDefinition() == typeof(ICommand<>));
}

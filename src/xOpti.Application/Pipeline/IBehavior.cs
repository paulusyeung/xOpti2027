using xOpti.Application.Common;

namespace xOpti.Application.Pipeline;

public delegate Task<TResponse> RequestHandlerDelegate<TResponse>();

/// <summary>
/// A pipeline step around a handler. Behaviors run in the order registered by
/// <c>AddXOptiApplication</c>: permission, validation, idempotency, transaction.
/// </summary>
public interface IBehavior<in TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    Task<TResponse> Handle(TRequest request, CancellationToken cancellationToken, RequestHandlerDelegate<TResponse> next);
}

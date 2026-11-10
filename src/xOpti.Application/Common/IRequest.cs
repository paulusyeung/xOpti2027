namespace xOpti.Application.Common;

/// <summary>Base marker for all dispatchable requests (commands and queries).</summary>
public interface IRequest<out TResponse>;

/// <summary>A write request. Executed inside one explicit transaction by TransactionBehavior.</summary>
public interface ICommand<out TResponse> : IRequest<TResponse>;

/// <summary>A read request. Not transactional by default.</summary>
public interface IQuery<out TResponse> : IRequest<TResponse>;

public interface IRequestHandler<in TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    Task<TResponse> Handle(TRequest request, CancellationToken cancellationToken);
}

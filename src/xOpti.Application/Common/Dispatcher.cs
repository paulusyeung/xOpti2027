using System.Collections;
using System.Reflection;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Application.Pipeline;

namespace xOpti.Application.Common;

/// <summary>Single entry point for executing commands and queries.</summary>
public interface IRequestDispatcher
{
    Task<TResponse> DispatchAsync<TResponse>(IRequest<TResponse> request, CancellationToken cancellationToken = default);

    Task<object?> DispatchAsync(object request, CancellationToken cancellationToken = default);
}

/// <summary>
/// Resolves the registered handler plus its behavior chain (permission →
/// validation → idempotency → transaction → handler) and propagates the
/// cancellation token end to end.
/// </summary>
public sealed class Dispatcher : IRequestDispatcher
{
    private readonly IServiceProvider _services;

    public Dispatcher(IServiceProvider services)
    {
        _services = services;
    }

    public async Task<TResponse> DispatchAsync<TResponse>(IRequest<TResponse> request, CancellationToken cancellationToken = default)
    {
        var result = await DispatchAsync((object)request, cancellationToken);
        return (TResponse)result!;
    }

    public Task<object?> DispatchAsync(object request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        var requestType = request.GetType();
        var requestInterface = requestType
            .GetInterfaces()
            .FirstOrDefault(i => i.IsGenericType && i.GetGenericTypeDefinition() == typeof(IRequest<>));

        if (requestInterface is null)
        {
            throw new UnsupportedRequestException(requestType);
        }

        var responseType = requestInterface.GetGenericArguments()[0];
        var handlerType = typeof(IRequestHandler<,>).MakeGenericType(requestType, responseType);

        if (_services.GetService(handlerType) is null)
        {
            throw new UnsupportedRequestException(requestType);
        }

        var behaviorType = typeof(IBehavior<,>).MakeGenericType(requestType, responseType);
        var behaviorsCollectionType = typeof(IEnumerable<>).MakeGenericType(behaviorType);
        var behaviors = _services.GetService(behaviorsCollectionType) is IEnumerable enumerable
            ? enumerable.Cast<object>().ToList()
            : new List<object>();

        var runMethod = typeof(Dispatcher)
            .GetMethod(nameof(RunAsync), BindingFlags.NonPublic | BindingFlags.Instance)!
            .MakeGenericMethod(requestType, responseType);

        return (Task<object?>)runMethod.Invoke(this, new object[] { request, behaviors, cancellationToken })!;
    }

    private async Task<object?> RunAsync<TRequest, TResponse>(
        TRequest request,
        IReadOnlyList<object> behaviors,
        CancellationToken cancellationToken)
        where TRequest : IRequest<TResponse>
    {
        var handler = (IRequestHandler<TRequest, TResponse>)_services.GetRequiredService(typeof(IRequestHandler<TRequest, TResponse>));

        RequestHandlerDelegate<TResponse> next = () => handler.Handle(request, cancellationToken);

        // Registered order = outermost first; wrap in reverse so behavior[0] runs outermost.
        for (var i = behaviors.Count - 1; i >= 0; i--)
        {
            var behavior = (IBehavior<TRequest, TResponse>)behaviors[i];
            var inner = next;
            next = () => behavior.Handle(request, cancellationToken, inner);
        }

        return await next();
    }
}

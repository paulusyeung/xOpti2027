using xOpti.Application.Common;
using xOpti.Application.Ports;

namespace xOpti.Application.Pipeline;

/// <summary>
/// For commands carrying an idempotency key (sales, invoices, payments):
/// reserves the key atomically BEFORE the transaction opens, replays a prior
/// committed result without executing, conflicts with an in-flight duplicate,
/// stores the outcome after success, and releases the reservation on failure.
/// </summary>
public sealed class IdempotencyBehavior<TRequest, TResponse>(IIdempotencyStore store)
    : IBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    public async Task<TResponse> Handle(
        TRequest request,
        CancellationToken cancellationToken,
        RequestHandlerDelegate<TResponse> next)
    {
        if (request is not IRequiresIdempotencyKey keyed)
        {
            return await next();
        }

        var key = keyed.IdempotencyKey;
        if (string.IsNullOrWhiteSpace(key))
        {
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError(
                    nameof(keyed.IdempotencyKey),
                    "required",
                    "An idempotency key is required for this write."),
            });
        }

        var reservation = await store.TryAcquireAsync(key, cancellationToken);

        switch (reservation.Outcome)
        {
            case IdempotencyAcquisition.Replayed:
                return (TResponse)reservation.CachedResult!;

            case IdempotencyAcquisition.InProgress:
                throw new IdempotencyConflictException(key);
        }

        try
        {
            var result = await next();
            await store.SaveResultAsync(key, result!, cancellationToken);
            return result;
        }
        catch
        {
            await store.ReleaseAsync(key, cancellationToken);
            throw;
        }
    }
}

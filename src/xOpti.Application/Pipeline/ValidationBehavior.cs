using FluentValidation;
using xOpti.Application.Common;

namespace xOpti.Application.Pipeline;

/// <summary>
/// Runs all registered FluentValidation validators for the request before the
/// handler (and before the transaction) executes. Field errors are surfaced
/// in a structured form.
/// </summary>
public sealed class ValidationBehavior<TRequest, TResponse>(IEnumerable<IValidator<TRequest>> validators)
    : IBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    public async Task<TResponse> Handle(
        TRequest request,
        CancellationToken cancellationToken,
        RequestHandlerDelegate<TResponse> next)
    {
        if (!validators.Any())
        {
            return await next();
        }

        var failures = new List<ValidationFieldError>();
        foreach (var validator in validators)
        {
            var result = await validator.ValidateAsync(request, cancellationToken);
            if (!result.IsValid)
            {
                failures.AddRange(result.Errors.Select(f =>
                    new ValidationFieldError(f.PropertyName, f.ErrorCode ?? "invalid", f.ErrorMessage)));
            }
        }

        if (failures.Count > 0)
        {
            throw new ValidationFailedException(failures);
        }

        return await next();
    }
}

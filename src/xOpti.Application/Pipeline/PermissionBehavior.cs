using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Ports;

namespace xOpti.Application.Pipeline;

/// <summary>
/// Outermost behavior: denies requests whose declared permissions the current
/// principal lacks, before validation or any other work runs.
/// </summary>
public sealed class PermissionBehavior<TRequest, TResponse>(ICurrentPrincipal principal)
    : IBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    public Task<TResponse> Handle(
        TRequest request,
        CancellationToken cancellationToken,
        RequestHandlerDelegate<TResponse> next)
    {
        if (request is IHasPermissions guarded)
        {
            foreach (var permission in guarded.RequiredPermissions)
            {
                if (!principal.HasPermission(permission))
                {
                    throw new AuthorizationFailedException(permission, typeof(TRequest).Name);
                }
            }
        }

        return next();
    }
}

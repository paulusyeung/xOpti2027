using System.Reflection;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;

namespace xOpti.Application;

public static class ApplicationServiceCollectionExtensions
{
    /// <summary>
    /// Registers the dispatcher, every handler/validator in the assembly, and
    /// the behavior chain in its FIXED order:
    /// permission → validation → idempotency → transaction → handler.
    /// Permission runs first because it is cheap and must not leak validation
    /// detail to unauthorized callers; idempotency reserves the key before the
    /// transaction opens so replays never reopen work.
    /// </summary>
    public static IServiceCollection AddXOptiApplication(this IServiceCollection services)
    {
        // Registration order == execution order (outermost first). These are
        // additive on purpose: all four must resolve as the enumerable chain.
        services.AddTransient(typeof(IBehavior<,>), typeof(PermissionBehavior<,>));
        services.AddTransient(typeof(IBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddTransient(typeof(IBehavior<,>), typeof(IdempotencyBehavior<,>));
        services.AddTransient(typeof(IBehavior<,>), typeof(TransactionBehavior<,>));

        services.TryAddTransient<IRequestDispatcher, Dispatcher>();

        RegisterHandlers(services);
        RegisterValidators(services);

        return services;
    }

    private static void RegisterHandlers(IServiceCollection services)
    {
        var handlerOpen = typeof(IRequestHandler<,>);

        foreach (var type in ExportedTypes().Where(t => t is { IsAbstract: false, IsInterface: false }))
        {
            foreach (var iface in type.GetInterfaces()
                         .Where(i => i.IsGenericType && i.GetGenericTypeDefinition() == handlerOpen))
            {
                services.AddTransient(iface, type);
            }
        }
    }

    private static void RegisterValidators(IServiceCollection services)
    {
        var validatorOpen = typeof(IValidator<>);

        foreach (var type in ExportedTypes().Where(t => t is { IsAbstract: false, IsInterface: false }))
        {
            var implements = type.GetInterfaces()
                .Any(i => i.IsGenericType && i.GetGenericTypeDefinition() == validatorOpen);

            if (!implements)
            {
                continue;
            }

            foreach (var iface in type.GetInterfaces()
                         .Where(i => i.IsGenericType && i.GetGenericTypeDefinition() == validatorOpen))
            {
                services.AddTransient(iface, type);
            }
        }
    }

    private static IEnumerable<Type?> ExportedTypes() =>
        typeof(ApplicationServiceCollectionExtensions).Assembly.GetExportedTypes().ToList();
}

using System.Reflection;
using xOpti.Application.Ports;

namespace xOpti.Application.Tests.Ports;

public class PortContractTests
{
    private static readonly Type[] Ports =
    {
        typeof(IUnitOfWork),
        typeof(IClock),
        typeof(ICurrentPrincipal),
        typeof(IAuditRecorder),
        typeof(IControlNumberAllocator),
        typeof(IIdempotencyStore),
    };

    [Theory]
    [MemberData(nameof(PortTypes))]
    public void PortSignaturesUseOnlyDomainOrFrameworkTypes(Type port)
    {
        var allowedAssemblies = new[]
        {
            typeof(IUnitOfWork).Assembly,          // xOpti.Application
            typeof(xOpti.Domain.Values.Money).Assembly, // xOpti.Domain
            typeof(object).Assembly,               // System.Private.CoreLib / BCL
            typeof(Task).Assembly,                 // System.Threading.Tasks / runtime
        };

        var methodTypes = port.GetMethods()
            .SelectMany(m => m.GetParameters().Select(p => p.ParameterType)
                .Concat(new[] { m.ReturnType }))
            .SelectMany(Flatten);

        foreach (var type in methodTypes)
        {
            var asm = type.Assembly;
            Assert.Contains(asm, allowedAssemblies);
        }
    }

    [Theory]
    [InlineData(typeof(IUnitOfWork))]
    [InlineData(typeof(IAuditRecorder))]
    [InlineData(typeof(IControlNumberAllocator))]
    [InlineData(typeof(IIdempotencyStore))]
    public void AsyncPortMethodsAcceptCancellationToken(Type port)
    {
        var asyncMethods = port.GetMethods()
            .Where(m => m.ReturnType == typeof(Task) || (m.ReturnType.IsGenericType && m.ReturnType.GetGenericTypeDefinition() == typeof(Task<>)));

        foreach (var method in asyncMethods)
        {
            Assert.Contains(method.GetParameters(), p => p.ParameterType == typeof(CancellationToken));
        }
    }

    [Fact]
    public void IdempotencyStoreHasReservationAndSaveContracts()
    {
        var store = typeof(IIdempotencyStore);
        var acquire = store.GetMethod("TryAcquireAsync")!;
        Assert.NotNull(acquire);
        Assert.Equal(typeof(Task<IdempotencyReservation>), acquire.ReturnType);
        Assert.Equal(typeof(string), acquire.GetParameters()[0].ParameterType);
        Assert.Equal(typeof(CancellationToken), acquire.GetParameters()[1].ParameterType);

        var save = store.GetMethod("SaveResultAsync")!;
        Assert.NotNull(save);
        Assert.Equal(typeof(string), save.GetParameters()[0].ParameterType);
        Assert.Equal(typeof(CancellationToken), save.GetParameters()[2].ParameterType);

        Assert.NotNull(store.GetMethod("ReleaseAsync"));
    }

    [Fact]
    public void RepositoryPortsExposeNoPersistenceTypes()
    {
        var repo = typeof(xOpti.Application.Identity.ListBranches.IBranchRepository);

        var signatureTypes = repo.GetMethods()
            .SelectMany(m => m.GetParameters().Select(p => p.ParameterType).Concat(new[] { m.ReturnType }))
            .SelectMany(Flatten)
            .ToList();

        foreach (var type in signatureTypes)
        {
            var name = type.FullName ?? string.Empty;
            Assert.False(name.Contains("EntityFrameworkCore", StringComparison.OrdinalIgnoreCase));
            Assert.False(name.Contains("Npgsql", StringComparison.OrdinalIgnoreCase));
        }
    }

    public static TheoryData<Type> PortTypes() => new(Ports);

    private static IEnumerable<Type> Flatten(Type type)
    {
        yield return type;
        if (type.IsGenericType)
        {
            foreach (var arg in type.GetGenericArguments())
            {
                foreach (var nested in Flatten(arg))
                {
                    yield return nested;
                }
            }
        }
    }
}

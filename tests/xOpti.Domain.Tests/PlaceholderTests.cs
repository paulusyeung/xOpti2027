namespace xOpti.Domain.Tests;

public class PlaceholderTests
{
    [Fact]
    public void DomainAssemblyLoads()
    {
        Assert.NotNull(typeof(xOpti.Domain.Common.Result).Assembly);
    }
}

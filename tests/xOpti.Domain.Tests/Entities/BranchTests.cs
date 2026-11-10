using xOpti.Domain.Entities;

namespace xOpti.Domain.Tests.Entities;

public class BranchTests
{
    [Fact]
    public void Create_validates_and_trims()
    {
        var ok = Branch.Create(" 01 ", " Richmond ", null);
        Assert.True(ok.IsSuccess);
        Assert.Equal("01", ok.Value.BranchCode);
        Assert.Equal("Richmond", ok.Value.Name);

        Assert.False(Branch.Create(null, "Richmond").IsSuccess);
        Assert.False(Branch.Create("01", "  ").IsSuccess);
    }

    [Fact]
    public void Value_equality()
    {
        Assert.Equal(new Branch("01", "Richmond"), new Branch("01", "Richmond"));
    }
}

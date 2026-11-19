using xOpti.Application.Identity;

namespace xOpti.Infrastructure.Tests;

public class LegacyStaffRoleMapTests
{
    [Theory]
    [InlineData("101", "admin")]
    [InlineData("300", "manager")]
    [InlineData("302", "manager")]
    [InlineData("303", "manager")]
    [InlineData("200", "optician")]
    [InlineData("202", "optician")]
    [InlineData("100", "clerk")]
    [InlineData("102", "clerk")]
    [InlineData("", null)]
    [InlineData("999", null)]
    public void JobTitleCodes_MapToApprovedRoles(string code, string? expected)
    {
        Assert.Equal(expected, LegacyStaffRoleMap.RoleFor(code));
    }
}

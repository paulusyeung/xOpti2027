using System.Security.Cryptography;
using xOpti.Application.Authorization;
using xOpti.Infrastructure.Identity;

namespace xOpti.Infrastructure.Tests;

/// <summary>
/// The runtime authorization matrix is a versioned file, not a code switch.
/// These tests assert the approved vocabulary, explicit denial, and the link
/// back to the parity baseline it was generated from.
/// </summary>
public class PermissionMatrixTests
{
    private static string RepoRoot()
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);
        while (directory is not null && !File.Exists(Path.Combine(directory.FullName, "xOpti.sln")))
        {
            directory = directory.Parent;
        }

        return directory!.FullName;
    }

    private static string MatrixPath() =>
        Path.Combine(RepoRoot(), "src", "xOpti.Infrastructure", "Identity", PermissionMatrix.FileName);

    [Fact]
    public void Matrix_AssignsEveryApprovedPermission_ToAtLeastOneRole()
    {
        var matrix = PermissionMatrix.Load(MatrixPath());

        var assigned = matrix.KnownRoles
            .SelectMany(matrix.PermissionsForRole)
            .ToHashSet(StringComparer.Ordinal);
        var unassigned = matrix.UnassignedPermissions
            .Select(entry => entry.Permission)
            .ToHashSet(StringComparer.Ordinal);

        // Every approved permission is either granted to a role or recorded as
        // deliberately unassigned with a parity reason (customer:pii today).
        Assert.Equal(PermissionNames.All.OrderBy(x => x), assigned.Concat(unassigned).OrderBy(x => x));
        Assert.DoesNotContain(PermissionNames.CustomerPii, assigned);
        Assert.Contains(PermissionNames.CustomerPii, unassigned);
        Assert.All(matrix.UnassignedPermissions, entry => Assert.False(string.IsNullOrWhiteSpace(entry.Reason)));
    }

    [Fact]
    public void Matrix_IsExplicitlyProvisional_UntilTask32SignsIt()
    {
        var matrix = PermissionMatrix.Load(MatrixPath());

        // Deliberate guard: flipping this requires the signed matrix and the
        // 3.2 approval committed alongside it.
        Assert.False(matrix.Signed);
        Assert.Equal("establish-production-baseline", matrix.Baseline.Change);
        Assert.Equal("3.2", matrix.Baseline.SignOffTask);
        Assert.NotEmpty(matrix.ParityGaps);
    }

    [Fact]
    public void Matrix_BaselineChecksum_MatchesTheParityCatalogue()
    {
        var matrix = PermissionMatrix.Load(MatrixPath());
        var catalogue = Path.Combine(RepoRoot(), "docs", "parity", "permissions.csv");
        if (!File.Exists(catalogue))
        {
            return; // published builds do not ship the parity artefacts
        }

        var actual = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(catalogue))).ToLowerInvariant();
        Assert.Equal(matrix.Baseline.ChecksumSha256, actual);
    }

    [Theory]
    [InlineData(7, RolePermissionMatrix.Admin)]
    [InlineData(9, RolePermissionMatrix.Admin)]
    [InlineData(6, RolePermissionMatrix.Manager)]
    [InlineData(5, RolePermissionMatrix.Manager)]
    [InlineData(4, RolePermissionMatrix.Optician)]
    [InlineData(3, RolePermissionMatrix.Optician)]
    [InlineData(2, RolePermissionMatrix.Clerk)]
    [InlineData(1, RolePermissionMatrix.Clerk)]
    public void RoleForLevel_MapsApprovedLevels(int level, string expectedRole)
    {
        var matrix = PermissionMatrix.Load(MatrixPath());

        Assert.Equal(expectedRole, matrix.RoleForLevel(level));
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    [InlineData(int.MinValue)]
    public void RoleForLevel_UnmappedLevels_AreDefaultDeny(int level)
    {
        var matrix = PermissionMatrix.Load(MatrixPath());

        Assert.Null(matrix.RoleForLevel(level));
        Assert.Empty(matrix.PermissionsFor(new[] { matrix.RoleForLevel(level) ?? "unmapped" }));
    }

    [Fact]
    public void UnknownRole_GrantsNothing()
    {
        var matrix = PermissionMatrix.Load(MatrixPath());

        Assert.Empty(matrix.PermissionsFor(new[] { "unmapped-role" }));
        Assert.Empty(matrix.PermissionsForRole("unmapped-role"));
        Assert.False(matrix.IsKnownRole("unmapped-role"));
    }

    [Fact]
    public void Load_RejectsAnUnapprovedPermission()
    {
        var temporary = Path.Combine(Path.GetTempPath(), $"matrix-{Guid.NewGuid():N}.json");
        var json = File.ReadAllText(MatrixPath()).Replace(
            "\"sales:order-create\"", "\"sales:approve-everything\"", StringComparison.Ordinal);
        File.WriteAllText(temporary, json);
        try
        {
            var error = Assert.Throws<InvalidOperationException>(() => PermissionMatrix.Load(temporary));
            Assert.Contains("unknown permissions", error.Message);
        }
        finally
        {
            File.Delete(temporary);
        }
    }

    [Fact]
    public void StaticFacade_ReadsTheVersionedFile()
    {
        Assert.False(RolePermissionMatrix.Current.Signed);
        Assert.Contains(PermissionNames.CostView, RolePermissionMatrix.PermissionsForRole(RolePermissionMatrix.Manager));
        Assert.DoesNotContain(PermissionNames.CostView, RolePermissionMatrix.PermissionsForRole(RolePermissionMatrix.Clerk));
        Assert.Null(RolePermissionMatrix.RoleForLevel(0));
    }
}

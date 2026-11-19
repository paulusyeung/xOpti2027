using xOpti.Migrations;

namespace xOpti.Migrations.Tests;

public class CutoverGateTests
{
    private static MigrationConfig Config(string? hash, int? tables = 70) => new()
    {
        SynergyMdbPath = "source.mdb",
        TargetConnectionString = "Host=unused",
        ReportsDirectory = "reports",
        RepositoryRoot = ".",
        ExpectedSourceSha256 = hash,
        ExpectedSourceTables = tables,
    };

    [Fact]
    public void SourceBaseline_AcceptsApprovedFingerprint()
    {
        var source = new SourceFingerprint("source.mdb", new string('a', 64), 70);
        SourceBaseline.Verify(source, Config(new string('a', 64)), allowMissing: false);
    }

    [Fact]
    public void SourceBaseline_RejectsChecksumAndTableMismatch()
    {
        var source = new SourceFingerprint("source.mdb", new string('a', 64), 70);
        Assert.Throws<MigrationException>(() =>
            SourceBaseline.Verify(source, Config(new string('b', 64)), allowMissing: false));
        Assert.Throws<MigrationException>(() =>
            SourceBaseline.Verify(source, Config(new string('a', 64), 69), allowMissing: false));
    }

    [Fact]
    public void SourceBaseline_RequiresApprovalOutsideDryRun()
    {
        var source = new SourceFingerprint("source.mdb", new string('a', 64), 70);
        Assert.Throws<MigrationException>(() =>
            SourceBaseline.Verify(source, Config(null), allowMissing: false));
        SourceBaseline.Verify(source, Config(null), allowMissing: true);
    }

    [Theory]
    [InlineData("source-verify")]
    [InlineData("stage-reload")]
    [InlineData("gate")]
    [InlineData("final-sync")]
    [InlineData("post-sync")]
    public void CommandLine_RecognisesCutoverCommands(string command)
    {
        var options = CommandLine.Parse([command, "--dry-run"]);
        Assert.Equal(command, options.Command);
        Assert.True(options.DryRun);
    }
}

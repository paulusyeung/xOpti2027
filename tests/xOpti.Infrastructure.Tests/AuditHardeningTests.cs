using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using xOpti.Application.Ports;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Persistence.Entities;
using xOpti.Infrastructure.Platform;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class AuditHardeningTests(PostgresFixture fixture)
{
    private static ICurrentPrincipal Principal(string userId, string branch)
    {
        var identity = new ClaimsIdentity(
            new[]
            {
                new Claim(ClaimTypes.NameIdentifier, userId),
                new Claim(ClaimsCurrentPrincipal.BranchClaimType, branch),
            },
            "test");
        return new ClaimsCurrentPrincipal(new ClaimsPrincipal(identity));
    }

    [Fact]
    public async Task AuditEntry_RecordsActorBranchTargetAndDetails()
    {
        await using var context = fixture.NewContext();
        var recorder = new DbAuditRecorder(context, new SystemClock(), Principal("user-42", "02"));

        await recorder.RecordAsync(
            new AuditRecord("staff.disable", "StaffAccount", "target.user", "{\"reason\":\"left\"}"),
            CancellationToken.None);

        var entry = await context.AuditLogs.AsNoTracking()
            .OrderByDescending(row => row.Id)
            .FirstAsync(row => row.EntityId == "target.user");

        Assert.Equal("user-42", entry.ActorUserId);
        Assert.Equal("02", entry.ActorBranch);
        Assert.Equal("staff.disable", entry.Action);
        Assert.Equal("StaffAccount", entry.EntityType);
        Assert.Contains("left", entry.Details);
    }

    [Fact]
    public async Task AuditRows_CannotBeUpdatedOrDeleted()
    {
        long auditId;
        await using (var context = fixture.NewContext())
        {
            var recorder = new DbAuditRecorder(context, new SystemClock(), Principal("user-42", "02"));
            await recorder.RecordAsync(
                new AuditRecord("security.probe", "StaffAccount", "append-only-probe", null),
                CancellationToken.None);
            auditId = await context.AuditLogs.AsNoTracking()
                .Where(row => row.EntityId == "append-only-probe")
                .Select(row => row.Id)
                .SingleAsync();
        }

        await using var connection = new Npgsql.NpgsqlConnection(fixture.ConnectionString);
        await connection.OpenAsync();

        await using (var update = connection.CreateCommand())
        {
            update.CommandText = "UPDATE platform.audit_log SET action = 'tampered' WHERE id = @id";
            update.Parameters.AddWithValue("id", auditId);
            var error = await Assert.ThrowsAsync<Npgsql.PostgresException>(() => update.ExecuteNonQueryAsync());
            Assert.Contains("append-only", error.MessageText);
        }

        await using (var delete = connection.CreateCommand())
        {
            delete.CommandText = "DELETE FROM platform.audit_log WHERE id = @id";
            delete.Parameters.AddWithValue("id", auditId);
            var error = await Assert.ThrowsAsync<Npgsql.PostgresException>(() => delete.ExecuteNonQueryAsync());
            Assert.Contains("append-only", error.MessageText);
        }
    }
}

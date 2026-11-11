using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

/// <summary>
/// Opt-in bootstrap for a manually migrated smoke database. Runs only when
/// XOPTI_SMOKE_CONNECTION is set; otherwise it is a no-op so normal test runs are unaffected.
/// Example: XOPTI_SMOKE_CONNECTION="Host=...;Database=...;..." dotnet test --filter SmokeSeed
/// </summary>
public sealed class SmokeSeedTests
{
    [Fact]
    public async Task SmokeSeed_AppliesReferenceDataAndAccounts_WhenConnectionProvided()
    {
        var connection = Environment.GetEnvironmentVariable("XOPTI_SMOKE_CONNECTION");
        if (string.IsNullOrWhiteSpace(connection))
        {
            return;
        }

        await SeedData.ApplyAsync(connection);
    }
}

using System.Text.Json;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Application;
using xOpti.Application.Common;
using xOpti.Application.Identity.ListBranches;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Application.Tests.Support;
using xOpti.Domain.Entities;

namespace xOpti.Application.Tests.QueryConventions;

public class PagedResultSerializationTests
{
    [Fact]
    public void PagedResult_HasItemsAndOpaqueCursor_Only()
    {
        var result = new PagedResult<int>(new[] { 1, 2, 3 }, KeysetCursor.Encode("3"));

        var json = JsonSerializer.Serialize(result);

        using var doc = JsonDocument.Parse(json);
        var props = doc.RootElement.EnumerateObject().Select(p => p.Name.ToLowerInvariant()).ToList();

        Assert.Contains("items", props);
        Assert.Contains("nextcursor", props);
        Assert.DoesNotContain("offset", props);
        Assert.DoesNotContain("skip", props);
        Assert.DoesNotContain("pagenumber", props);
        Assert.DoesNotContain("page", props);
        Assert.DoesNotContain("totalcount", props);
        Assert.DoesNotContain("total", props);
    }

    [Fact]
    public void Cursor_IsOpaqueButRoundTrips()
    {
        var encoded = KeysetCursor.Encode("00042");
        Assert.DoesNotContain("00042", encoded);
        Assert.Equal("00042", KeysetCursor.Decode(encoded));
    }
}

internal sealed class InMemoryBranchRepository : IBranchRepository
{
    private readonly List<Branch> _all;
    private readonly object _gate = new();

    public InMemoryBranchRepository(IEnumerable<Branch> initial)
    {
        _all = initial.OrderBy(b => b.BranchCode, StringComparer.Ordinal).ToList();
    }

    public void Insert(Branch branch)
    {
        lock (_gate)
        {
            _all.Add(branch);
            _all.Sort((a, b) => string.CompareOrdinal(a.BranchCode, b.BranchCode));
        }
    }

    public Task<IReadOnlyList<Branch>> GetPageAfterAsync(string? afterBranchCode, int limit, CancellationToken cancellationToken)
    {
        lock (_gate)
        {
            IReadOnlyList<Branch> page = afterBranchCode is null
                ? _all.Take(limit).ToList()
                : _all.Where(b => string.CompareOrdinal(b.BranchCode, afterBranchCode) > 0).Take(limit).ToList();
            return Task.FromResult(page);
        }
    }

    public Task<Branch?> FindByCodeAsync(string branchCode, CancellationToken cancellationToken)
    {
        lock (_gate)
        {
            return Task.FromResult(_all.FirstOrDefault(b => b.BranchCode == branchCode));
        }
    }

    public Task<Branch> RenameAsync(Branch branch, string newName, string? expectedCurrentName, CancellationToken cancellationToken)
    {
        lock (_gate)
        {
            var index = _all.FindIndex(b => b.BranchCode == branch.BranchCode);
            if (index < 0)
            {
                throw new InvalidOperationException($"Branch '{branch.BranchCode}' not found.");
            }

            if (expectedCurrentName is not null && _all[index].Name != expectedCurrentName)
            {
                throw new InvalidOperationException("Concurrency conflict: current name changed.");
            }

            var renamed = _all[index] with { Name = newName };
            _all[index] = renamed;
            return Task.FromResult(renamed);
        }
    }
}

public class ListBranchesSliceTests
{
    private static ServiceProvider BuildProvider(InMemoryBranchRepository repo)
    {
        var services = new ServiceCollection();
        services.AddXOptiApplication();
        services.AddScoped<ICurrentPrincipal>(_ => new FakePrincipal());
        services.AddSingleton<IUnitOfWork>(new FakeUnitOfWork());
        services.AddSingleton<IIdempotencyStore>(new FakeIdempotencyStore());
        services.AddSingleton<IBranchRepository>(repo);
        services.AddTransient<IValidator<ListBranchesQuery>, ListBranchesQueryValidator>();
        return services.BuildServiceProvider();
    }

    private static Branch B(string code, string name) => Branch.Create(code, name).Value;

    [Fact]
    public async Task FullTraversal_EveryBranchAppearsExactlyOnce()
    {
        var repo = new InMemoryBranchRepository(Enumerable.Range(1, 7).Select(i => B($"0{i}", $"Branch {i}")));
        var dispatcher = BuildProvider(repo).GetRequiredService<IRequestDispatcher>();

        var seen = new List<string>();
        string? cursor = null;
        var pages = 0;

        while (true)
        {
            var page = await dispatcher.DispatchAsync(new ListBranchesQuery(cursor, 3));
            seen.AddRange(page.Items.Select(i => i.BranchCode));
            cursor = page.NextCursor;
            pages++;
            if (cursor is null)
            {
                break;
            }

            Assert.True(pages < 10, "pagination did not terminate");
        }

        Assert.Equal(3, pages);
        Assert.Equal(7, seen.Count);
        Assert.Equal(seen.Count, seen.Distinct().Count());
        Assert.Equal(seen.OrderBy(c => c, StringComparer.Ordinal).ToList(), seen);
    }

    [Fact]
    public async Task CursorContinuation_AfterConcurrentInsert_NoRepeatsNoGaps()
    {
        var repo = new InMemoryBranchRepository(new[] { B("01", "One"), B("03", "Three"), B("05", "Five"), B("07", "Seven") });
        var dispatcher = BuildProvider(repo).GetRequiredService<IRequestDispatcher>();

        var firstPage = await dispatcher.DispatchAsync(new ListBranchesQuery(null, 2));
        Assert.Equal(new[] { "01", "03" }, firstPage.Items.Select(i => i.BranchCode));
        Assert.NotNull(firstPage.NextCursor);

        // Concurrent inserts both behind and ahead of the cursor.
        repo.Insert(B("02", "Two"));
        repo.Insert(B("09", "Nine"));

        var secondPage = await dispatcher.DispatchAsync(new ListBranchesQuery(firstPage.NextCursor, 2));
        Assert.Equal(new[] { "05", "07" }, secondPage.Items.Select(i => i.BranchCode));

        var thirdPage = await dispatcher.DispatchAsync(new ListBranchesQuery(secondPage.NextCursor, 2));
        Assert.Equal(new[] { "09" }, thirdPage.Items.Select(i => i.BranchCode));
        Assert.Null(thirdPage.NextCursor);
    }

    [Fact]
    public async Task Validator_RejectsBadPageSize()
    {
        var repo = new InMemoryBranchRepository(new[] { B("01", "One") });
        var dispatcher = BuildProvider(repo).GetRequiredService<IRequestDispatcher>();

        var error = await Assert.ThrowsAsync<ValidationFailedException>(() =>
            dispatcher.DispatchAsync(new ListBranchesQuery(null, 0)));

        Assert.Equal("PageSize", error.Errors[0].Field);
    }

    [Fact]
    public async Task Validator_RejectsCorruptCursor()
    {
        var repo = new InMemoryBranchRepository(new[] { B("01", "One") });
        var dispatcher = BuildProvider(repo).GetRequiredService<IRequestDispatcher>();

        await Assert.ThrowsAsync<ValidationFailedException>(() =>
            dispatcher.DispatchAsync(new ListBranchesQuery("not-base64!!", 2)));
    }
}

using System.Data.Common;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Npgsql;
using xOpti.Application.Ports;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure;

/// <summary>
/// Race-safe legacy control-number allocation. Increments the
/// pref_tx_number counter row with SELECT ... FOR UPDATE so the row lock is
/// held for the enclosing transaction; rollbacks roll back the counter too.
/// </summary>
public sealed class PostgresControlNumberAllocator(XOptiDbContext context) : IControlNumberAllocator
{
    public async Task<ControlNumber> AllocateAsync(TransactionType family, CancellationToken cancellationToken)
    {
        var prefix = family.ToLegacyCode();

        var ownsTransaction = context.Database.CurrentTransaction is null;
        await using var tx = ownsTransaction
            ? await context.Database.BeginTransactionAsync(cancellationToken)
            : null;

        var connection = context.Database.GetDbConnection();
        if (connection.State != System.Data.ConnectionState.Open)
        {
            await connection.OpenAsync(cancellationToken);
        }

        var transaction = context.Database.CurrentTransaction?.GetDbTransaction();

        await using (var select = connection.CreateCommand())
        {
            select.Transaction = transaction;
            select.CommandText = "SELECT tx_next_number FROM public.pref_tx_number WHERE tx_prefix = @p FOR UPDATE";
            select.Parameters.Add(new NpgsqlParameter("p", prefix));
            var current = (int)(await select.ExecuteScalarAsync(cancellationToken))!;
            var next = current + 1;

            await using (var update = connection.CreateCommand())
            {
                update.Transaction = transaction;
                update.CommandText = "UPDATE public.pref_tx_number SET tx_next_number = @next WHERE tx_prefix = @p";
                update.Parameters.Add(new NpgsqlParameter("next", next));
                update.Parameters.Add(new NpgsqlParameter("p", prefix));
                await update.ExecuteNonQueryAsync(cancellationToken);
            }

            if (ownsTransaction)
            {
                await tx!.CommitAsync(cancellationToken);
            }

            return ControlNumber.Create(family, next);
        }
    }
}

/// <summary>Claims-based adapter for the application principal port.</summary>
public sealed class ClaimsCurrentPrincipal(ClaimsPrincipal principal) : ICurrentPrincipal
{
    public const string PermissionClaimType = "xopti:permission";

    public const string BranchClaimType = "xopti:branch";

    public string? UserId => principal.FindFirstValue(ClaimTypes.NameIdentifier);

    public string? BranchCode => principal.FindFirstValue(BranchClaimType);

    public bool HasPermission(string permission) =>
        principal.HasClaim(PermissionClaimType, permission);
}

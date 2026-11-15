using System.Data;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.EntityFrameworkCore;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

/// <summary>Atomically advances the inventory control counter and returns the assigned number.</summary>
public static class ControlNumberSequencer
{
    public static async Task<string> NextAsync(XOptiDbContext context, CancellationToken ct)
    {
        var connection = context.Database.GetDbConnection();
        if (connection.State != ConnectionState.Open)
        {
            await connection.OpenAsync(ct);
        }

        await using var command = connection.CreateCommand();
        command.Transaction = context.Database.CurrentTransaction?.GetDbTransaction();
        command.CommandText = """
            UPDATE public.preference
            SET next_invt_control_number = next_invt_control_number + 1
            WHERE serial_number = (
                SELECT serial_number FROM public.preference ORDER BY serial_number LIMIT 1)
            RETURNING next_invt_control_number
            """;
        var result = await command.ExecuteScalarAsync(ct);
        if (result is null or DBNull)
        {
            return "00000001";
        }

        return (Convert.ToInt32(result) - 1).ToString("D8");
    }
}

using Npgsql;
using Microsoft.EntityFrameworkCore;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class PersistenceRoundtripTests(PostgresFixture fixture)
{
    private async Task InsertHeaderAsync(string txNumber)
    {
        await using var conn = new Npgsql.NpgsqlConnection(fixture.ConnectionString);
        await conn.OpenAsync();
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = """
            INSERT INTO public.tx_header
                (tx_number, control_number, tx_type, date_of_entry,
                 total_cost, total_sale, tax_a, tax_b, tax_c, other_charges, gross_sale,
                 sales_discount, total_amount, total_qty, previous_paid, this_paid, change,
                 print_counter, payment_link, sales_person_link, status)
            VALUES
                (@n, @n, 'RC', '2000-01-01 12:00:00',
                 0, 0, 0, 0, 0, 0, 0, 0, 1234.5678, 0, 0, 0, 0, 0, 0, 0, NULL)
            ON CONFLICT (tx_number) DO NOTHING
            """;
        cmd.Parameters.AddWithValue("n", txNumber);
        await cmd.ExecuteNonQueryAsync();
    }

    [Fact]
    public async Task MoneyRoundTripsAtFourDecimals()
    {
        var key = "RT" + Guid.NewGuid().ToString("N")[..8];
        await using (var ctx = fixture.NewContext())
        {
            ctx.TxHeaders.Add(new TxHeader
            {
                TxNumber = key,
                ControlNumber = key,
                TxType = TransactionType.RetailInvoice,
                DateOfEntry = DateTimeOffset.UtcNow,
                TotalAmount = Money.From(1234.5678m),
                TaxA = Money.From(0.3066m),
            });
            await ctx.SaveChangesAsync();
        }

        await using var ctx2 = fixture.NewContext();
        var loaded = await ctx2.TxHeaders.SingleAsync(h => h.TxNumber == key);

        Assert.Equal(Money.From(1234.5678m), loaded.TotalAmount);
        Assert.Equal(Money.From(0.3066m), loaded.TaxA);
    }

    [Fact]
    public async Task DstBoundaryTimestamp_RoundTripsExactInstant()
    {
        // America/Toronto DST spring-forward: 2026-03-08 02:00 local. Pick one
        // instant on each side of the switch with different local offsets.
        var beforeSwitch = new DateTimeOffset(2026, 3, 8, 1, 30, 0, TimeSpan.FromHours(-5));
        var afterSwitch = new DateTimeOffset(2026, 3, 8, 3, 30, 0, TimeSpan.FromHours(-4));

        var key = "RT" + Guid.NewGuid().ToString("N")[..8];
        await using (var ctx = fixture.NewContext())
        {
            ctx.TxHeaders.Add(new TxHeader
            {
                TxNumber = key,
                ControlNumber = key,
                TxType = TransactionType.RetailInvoice,
                DateOfEntry = beforeSwitch,
                DateOfCreation = afterSwitch,
            });
            await ctx.SaveChangesAsync();
        }

        await using var ctx2 = fixture.NewContext();
        var loaded = await ctx2.TxHeaders.SingleAsync(h => h.TxNumber == key);

        Assert.Equal(beforeSwitch.UtcTicks, loaded.DateOfEntry.UtcTicks);
        Assert.Equal(afterSwitch.UtcTicks, loaded.DateOfCreation!.Value.UtcTicks);
    }

    [Fact]
    public async Task LegacyControlNumberKey_PreservedOnWrite()
    {
        await InsertHeaderAsync("RC09999001");

        await using (var ctx = fixture.NewContext())
        {
            var header = await ctx.TxHeaders.SingleAsync(h => h.TxNumber == "RC09999001");
            header.TotalSale = Money.From(50m);
            await ctx.SaveChangesAsync();
        }

        await using var ctx2 = fixture.NewContext();
        var still = await ctx2.TxHeaders.SingleAsync(h => h.TxNumber == "RC09999001");
        Assert.Equal("RC09999001", still.TxNumber);
        Assert.Equal("RC09999001", still.ControlNumber);
    }

    [Fact]
    public async Task EnumMappedToLegacyCode_StoredAsTwoLetterCode()
    {
        var key = "RT" + Guid.NewGuid().ToString("N")[..8];
        await using (var ctx = fixture.NewContext())
        {
            ctx.TxHeaders.Add(new TxHeader
            {
                TxNumber = key,
                ControlNumber = key,
                TxType = TransactionType.StockReceived,
                DateOfEntry = DateTimeOffset.UtcNow,
            });
            await ctx.SaveChangesAsync();
        }

        await using var conn = new Npgsql.NpgsqlConnection(fixture.ConnectionString);
        await conn.OpenAsync();
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT tx_type FROM public.tx_header WHERE tx_number = @k";
        cmd.Parameters.AddWithValue("k", key);
        var txType = (string)(await cmd.ExecuteScalarAsync())!;

        Assert.Equal("SR", txType);
    }
}

[Collection("postgres")]
public class ConcurrencyTests(PostgresFixture fixture)
{
    private async Task EnsureSkuAsync(string sku)
    {
        await using var conn = new Npgsql.NpgsqlConnection(fixture.ConnectionString);
        await conn.OpenAsync();
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = """
            INSERT INTO public.inventory
                (department_code, class_code, category_code, supplier_code, brand_code,
                 sku, name, average_cost, re_order_level, re_order_qty, qty_total_on_hand,
                 qty_sale_order, qty_purchase_order, qty_holded, qty_in_transit,
                 kit_set_flag, retail_price_flag, whole_sale_price_flag, inventory_lot_flag)
            VALUES ('01','01','01','0001','0001', @sku, 'Concurrency Fixture', 0, 0, 0, 10, 0, 0, 0, 0,
                    false, false, false, false)
            ON CONFLICT (sku) DO NOTHING
            """;
        cmd.Parameters.AddWithValue("sku", sku);
        await cmd.ExecuteNonQueryAsync();
    }

    [Fact]
    public async Task XminToken_SecondWriterLosesRace()
    {
        var sku = "1" + Guid.NewGuid().ToString("N")[..12];
        await EnsureSkuAsync(sku);

        await using var first = fixture.NewContext();
        await using var second = fixture.NewContext();

        var a = await first.InventoryItems.SingleAsync(i => i.Sku == sku);
        var b = await second.InventoryItems.SingleAsync(i => i.Sku == sku);

        a.QtyTotalOnHand = 7;
        await first.SaveChangesAsync();

        b.QtyTotalOnHand = 5;
        await Assert.ThrowsAsync<DbUpdateConcurrencyException>(() => second.SaveChangesAsync());

        await using var verify = fixture.NewContext();
        var stored = await verify.InventoryItems.SingleAsync(i => i.Sku == sku);
        Assert.Equal(7, stored.QtyTotalOnHand);
    }
}

[Collection("postgres")]
public class UnitOfWorkTests(PostgresFixture fixture)
{
    [Fact]
    public async Task FailureRollsBack_Everything()
    {
        await using var ctx = fixture.NewContext();
        var uow = new xOpti.Infrastructure.EfUnitOfWork(ctx);
        var key = "UW" + Guid.NewGuid().ToString("N")[..8];

        await Assert.ThrowsAsync<InvalidOperationException>(async () =>
            await uow.ExecuteInTransactionAsync<int>(async ct =>
            {
                ctx.TxHeaders.Add(new TxHeader
                {
                    TxNumber = key,
                    ControlNumber = key,
                    TxType = TransactionType.RetailInvoice,
                    DateOfEntry = DateTimeOffset.UtcNow,
                });
                await ctx.SaveChangesAsync(ct);
                throw new InvalidOperationException("boom after the write landed");
            }, CancellationToken.None));

        await using var verify = fixture.NewContext();
        Assert.False(await verify.TxHeaders.AnyAsync(h => h.TxNumber == key));
    }

    [Fact]
    public async Task TwoAggregates_SecondFailureCommitsNothing()
    {
        await using var ctx = fixture.NewContext();
        var uow = new xOpti.Infrastructure.EfUnitOfWork(ctx);
        var key = "UW" + Guid.NewGuid().ToString("N")[..8];

        await Assert.ThrowsAsync<Npgsql.PostgresException>(async () =>
            await uow.ExecuteInTransactionAsync<int>(async ct =>
            {
                ctx.TxHeaders.Add(new TxHeader
                {
                    TxNumber = key,
                    ControlNumber = key,
                    TxType = TransactionType.RetailInvoice,
                    DateOfEntry = DateTimeOffset.UtcNow,
                });
                await ctx.SaveChangesAsync(ct);

                // Second aggregate fails validation in the database: raw insert
                // violates the primary key of the first row written above.
                await ctx.Database.ExecuteSqlRawAsync(
                    "INSERT INTO public.tx_header (tx_number, control_number, tx_type, date_of_entry) VALUES (@p1, @p1, 'RC', now())",
                    new object[] { new NpgsqlParameter("p1", key) },
                    ct);
                return 1;
            }, CancellationToken.None));

        await using var verify = fixture.NewContext();
        Assert.False(await verify.TxHeaders.AnyAsync(h => h.TxNumber == key));
    }

    [Fact]
    public async Task AmbientTransaction_IsHonoredWithoutReopen()
    {
        await using var ctx = fixture.NewContext();
        await using var ambient = await ctx.Database.BeginTransactionAsync();
        var uow = new xOpti.Infrastructure.EfUnitOfWork(ctx);

        var txIdBefore = ctx.Database.CurrentTransaction!.TransactionId;
        await uow.ExecuteInTransactionAsync<int>(async ct =>
        {
            Assert.Equal(txIdBefore, ctx.Database.CurrentTransaction!.TransactionId);
            return 42;
        }, CancellationToken.None);

        Assert.Equal(txIdBefore, ctx.Database.CurrentTransaction!.TransactionId);
    }
}

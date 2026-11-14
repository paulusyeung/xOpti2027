using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using xOpti.Application.Purchasing.ReceiveStock;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class ReceiptStoreDiagnostics(PostgresFixture fixture)
{
    [Fact]
    public async Task PostReceipt_Directly_SurfacesPersistenceErrors()
    {
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlRawAsync("""
                INSERT INTO public.supplier (supplier_code, supplier_name)
                VALUES ('0001', 'Diagnostic Supplier') ON CONFLICT (supplier_code) DO NOTHING;
                INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                    supplier_code, brand_code, name, qty_total_on_hand,
                    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                VALUES ('DIAG0001', '01', '01', '01', '0001', '0001', 'Diag', 0, false, false, false)
                ON CONFLICT (sku) DO NOTHING;
                INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                    user_name, owner_name, branch_number, pst_number, gst_number,
                    next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
                VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 50, 1, 1, 1)
                ON CONFLICT (serial_number) DO NOTHING;
                """);
        }

        var services = new ServiceCollection();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = fixture.ConnectionString });
        await using var provider = services.BuildServiceProvider();
        using var scope = provider.CreateScope();
        var store = scope.ServiceProvider.GetRequiredService<IReceiptStore>();

        await store.PostAsync(new ReceiptPosting(
            "SR99990001", "00000101", "0001", "01",
            new[] { new ReceiveStockLine("DIAG0001", "DIAG-LOT", 1, 4.3650m, 0m, 0m, "N") },
            4.3650m, 0m, 1), CancellationToken.None);
    }
}

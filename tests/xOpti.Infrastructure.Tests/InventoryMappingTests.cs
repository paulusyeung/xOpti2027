using Microsoft.EntityFrameworkCore;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence.Entities;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class InventoryMappingTests(PostgresFixture fixture)
{
    [Fact]
    public async Task InventoryLotStockTakeAndSupplierSummary_RoundTripPrecisionAndKeys()
    {
        var sku = "6" + Guid.NewGuid().ToString("N")[..8];
        const string supplier = "Z001";
        const string lotNo = "LOT-RT-1";
        const int headerId = 900001;

        await using (var write = fixture.NewContext())
        {
            write.InventoryItems.Add(new Inventory
            {
                Sku = sku,
                Name = "Round Trip Frame",
                DepartmentCode = "01",
                ClassCode = "01",
                CategoryCode = "01",
                SupplierCode = supplier,
                BrandCode = "0001",
                AverageCost = Money.From(7.7142m),
                QtyTotalOnHand = 10,
                InventoryLotFlag = true,
            });
            write.LotRecords.Add(new InvtLotRecord
            {
                Sku = sku,
                LotNo = lotNo,
                DateReceived = new DateTimeOffset(2026, 11, 1, 0, 0, 0, TimeSpan.Zero),
                SupplierCode = supplier,
                QtyPurchased = 10,
                QtyUsed = 2,
                QtyOnHand = 8,
                UnitAmountPurchased = Money.From(4.3650m),
                TotalAmountPurchased = Money.From(43.6500m),
            });
            write.BranchInventory.Add(new BranchInventory
            {
                BranchCode = "01", Sku = sku, QtyOnHand = 8,
            });
            write.StockTakeHeaders.Add(new InvtSTHeader
            {
                Id = headerId, Name = "Mapping round trip", Status = 1,
                DateOfCreation = new DateTime(2026, 11, 1, 8, 0, 0),
            });
            write.StockTakeDetails.Add(new InvtSTDetail
            {
                HeaderId = headerId, Sku = sku, ComputerQty = 8,
                PhysicalQty = 7, DiffQty = -1, AverageCost = 7.7142m,
            });
            write.StockTakeImports.Add(new InvtSTImport { HeaderId = headerId, Sku = sku, Qty = 7, Status = 1 });
            write.SupplierSummaries.Add(new SupplierSummary
            {
                SupplierCode = supplier, Year = 2026, Month = 11,
                FirstDateOfMonth = new DateTime(2026, 11, 1),
                QtyPurchased = 10, AmountPurchased = 123.4567m,
                QtyRejected = 2, AmountRejected = 8.7300m,
            });
            await write.SaveChangesAsync();
        }

        await using (var read = fixture.NewContext())
        {
            var inventory = await read.InventoryItems.AsNoTracking().SingleAsync(row => row.Sku == sku);
            Assert.Equal(7.7142m, inventory.AverageCost.Amount);
            Assert.Equal(10, inventory.QtyTotalOnHand);
            Assert.Equal(supplier, inventory.SupplierCode);

            var lot = await read.LotRecords.AsNoTracking().SingleAsync(row => row.Sku == sku && row.LotNo == lotNo);
            Assert.Equal(4.3650m, lot.UnitAmountPurchased.Amount);
            Assert.Equal(43.6500m, lot.TotalAmountPurchased.Amount);
            Assert.Equal(10, lot.QtyPurchased);
            Assert.Equal(8, lot.QtyOnHand);

            var branch = await read.BranchInventory.AsNoTracking()
                .SingleAsync(row => row.BranchCode == "01" && row.Sku == sku);
            Assert.Equal(8, branch.QtyOnHand);

            var detail = await read.StockTakeDetails.AsNoTracking()
                .SingleAsync(row => row.HeaderId == headerId && row.Sku == sku);
            Assert.Equal(8, detail.ComputerQty);
            Assert.Equal(-1, detail.DiffQty);
            Assert.Equal(7.7142m, detail.AverageCost);

            var import = await read.StockTakeImports.AsNoTracking()
                .SingleAsync(row => row.HeaderId == headerId && row.Sku == sku);
            Assert.Equal(7, import.Qty);

            var summary = await read.SupplierSummaries.AsNoTracking().SingleAsync(row =>
                row.SupplierCode == supplier && row.Year == 2026 && row.Month == 11);
            Assert.Equal(123.4567m, summary.AmountPurchased);
            Assert.Equal(8.7300m, summary.AmountRejected);
            Assert.Equal(10, summary.QtyPurchased);
        }
    }
}

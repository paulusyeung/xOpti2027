using Microsoft.EntityFrameworkCore;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence.Entities;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class PosMappingTests(PostgresFixture fixture)
{
    [Fact]
    public async Task PosTransactionTables_RoundTripValuesAndLegacyIdentifiers()
    {
        var tx = "RC" + Guid.NewGuid().ToString("N")[..8];
        var control = "00039999";
        var date = new DateTimeOffset(2026, 11, 10, 12, 0, 0, TimeSpan.Zero);

        await using (var write = fixture.NewContext())
        {
            write.TxHeaders.Add(new TxHeader
            {
                TxNumber = tx, ControlNumber = control, TxType = TransactionType.RetailInvoice,
                DateOfEntry = date, DateOfCreation = date,
                TotalSale = Money.From(100.1234m), TotalCost = Money.From(60.0000m),
                TaxA = Money.From(5.0062m), TaxB = Money.From(7.0086m),
                GrossSale = Money.From(112.1382m), TotalAmount = Money.From(112.1382m),
                SalesDiscount = Money.From(1.2345m), TotalQty = 2, Status = "0",
            });
            write.TxDetails.Add(new TxDetail
            {
                ControlNumber = control, TxType = TransactionType.RetailInvoice, TxNumber = tx,
                DateOfEntry = date, RowNo = 1, Sku = "30110359", Qty = 2,
                UnitAmount = Money.From(50.0617m), UnitCost = Money.From(30.0000m),
                Amount = Money.From(100.1234m), TaxCode = "B",
            });
            write.TxPayments.Add(new TxPayment
            {
                TxNumber = tx, PaymentLineNo = 1, Type = "C",
                AmountTender = Money.From(120.0000m), EqAmount = Money.From(120.0000m),
                TotalThisPay = Money.From(112.1382m), AuthorizationCode = "AUTH-1",
            });
            write.TxSalePersons.Add(new TxSalePerson { TxNumber = tx, SalesRowNo = 1, StaffCode = "0007" });
            write.TxSOrderAdds.Add(new TxSOrderAdd
            {
                TxNumber = tx, LineNumber = 1, Supplier = "0001", Brand = "0002", Model = "M1",
            });
            write.TxSOrderExtras.Add(new TxSOrderExtra
            {
                TxNumber = tx, Redo = false, Warranty = true, Mail = false, Msd = false, Remarks = 3,
            });
            await write.SaveChangesAsync();
        }

        await using var read = fixture.NewContext();
        var header = await read.TxHeaders.AsNoTracking().SingleAsync(row => row.TxNumber == tx);
        Assert.Equal(control, header.ControlNumber);
        Assert.Equal(TransactionType.RetailInvoice, header.TxType);
        Assert.Equal(100.1234m, header.TotalSale.Amount);
        Assert.Equal(1.2345m, header.SalesDiscount.Amount);
        Assert.Equal(date, header.DateOfEntry);

        var detail = await read.TxDetails.AsNoTracking().SingleAsync(row => row.TxNumber == tx);
        Assert.Equal("30110359", detail.Sku);
        Assert.Equal(50.0617m, detail.UnitAmount.Amount);
        Assert.Equal(2, detail.Qty);

        var payment = await read.TxPayments.AsNoTracking().SingleAsync(row => row.TxNumber == tx);
        Assert.Equal("AUTH-1", payment.AuthorizationCode);
        Assert.Equal(120.0000m, payment.AmountTender.Amount);
        Assert.Equal(112.1382m, payment.TotalThisPay.Amount);

        var seller = await read.TxSalePersons.AsNoTracking().SingleAsync(row => row.TxNumber == tx);
        Assert.Equal("0007", seller.StaffCode);
        var orderExtra = await read.TxSOrderExtras.AsNoTracking().SingleAsync(row => row.TxNumber == tx);
        Assert.True(orderExtra.Warranty);
        Assert.Equal(3, orderExtra.Remarks);
        var orderAdd = await read.TxSOrderAdds.AsNoTracking().SingleAsync(row => row.TxNumber == tx);
        Assert.Equal("M1", orderAdd.Model);
    }
}

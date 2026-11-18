using Microsoft.EntityFrameworkCore;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class WholesaleMappingTests(PostgresFixture fixture)
{
    [Fact]
    public async Task WholesaleAccountTermsRepresentativeAndPriceTable_RoundTripPrecisely()
    {
        const int customerId = 977001;
        const string sku = "WS9770010001";
        const string txNumber = "WC97700101";
        var createdAt = new DateTimeOffset(2026, 3, 4, 5, 6, 7, TimeSpan.Zero);

        await using (var context = fixture.NewContext())
        {
            context.Customers.Add(new Customer
            {
                Id = customerId,
                VipCode = "WS1",
                FirstName = "Wholesale",
                LastName = "Buyer",
                FullName = "Wholesale Buyer",
                HomePhone = "6045550177",
                Email = "wholesale@example.test",
                CreditLimit = Money.From(15000.1234m),
                PaymentTerms = "NET30",
            });
            context.CustomerAccounts.Add(new CustomerAccount
            {
                CustomerId = customerId,
                TtlAmtPurchased = Money.From(123456.7891m),
                TtlAmtRefund = Money.From(2345.6789m),
                YtdAmtPurchased = Money.From(4567.8901m),
                YtdAmtRefund = Money.From(123.4567m),
                LastPurchaseDate = createdAt,
            });
            context.WholesalePrices.Add(new WholesalePrice
            {
                Sku = sku,
                SuggestedRetailPrice = 99.9999m,
                GradeA = 71.1111m,
                GradeB = 72.2222m,
                GradeC = 73.3333m,
            });
            context.TxSalePersons.Add(new TxSalePerson
            {
                TxNumber = txNumber,
                SalesRowNo = 1,
                StaffCode = "0042",
            });
            context.WholesaleAccounts.Add(new WholesaleAccount
            {
                CustomerId = customerId,
                IsWholesale = true,
                PriceGrade = "B",
                TermsCode = "NET30",
                TermsDays = 30,
                CreditLimit = Money.From(98765.4321m),
                TaxTreatment = "EXEMPT",
                RepresentativeStaffCode = "0042",
                CreditHold = false,
                Notes = "legacy wholesale account",
                CreatedAt = createdAt,
                CreatedBy = "import",
            });
            await context.SaveChangesAsync();
        }

        await using (var verify = fixture.NewContext())
        {
            var customer = await verify.Customers.AsNoTracking()
                .SingleAsync(row => row.Id == customerId);
            Assert.Equal("Wholesale Buyer", customer.FullName);
            Assert.Equal("NET30", customer.PaymentTerms);
            Assert.Equal(15000.1234m, customer.CreditLimit.Amount);

            var account = await verify.CustomerAccounts.AsNoTracking()
                .SingleAsync(row => row.CustomerId == customerId);
            Assert.Equal(123456.7891m, account.TtlAmtPurchased.Amount);
            Assert.Equal(2345.6789m, account.TtlAmtRefund.Amount);
            Assert.Equal(createdAt, account.LastPurchaseDate);

            var price = await verify.WholesalePrices.AsNoTracking()
                .SingleAsync(row => row.Sku == sku);
            Assert.Equal(99.9999m, price.SuggestedRetailPrice);
            Assert.Equal(71.1111m, price.GradeA);
            Assert.Equal(72.2222m, price.GradeB);
            Assert.Equal(73.3333m, price.GradeC);

            var salePerson = await verify.TxSalePersons.AsNoTracking()
                .SingleAsync(row => row.TxNumber == txNumber && row.SalesRowNo == 1);
            Assert.Equal("0042", salePerson.StaffCode);

            var wholesale = await verify.WholesaleAccounts.AsNoTracking()
                .SingleAsync(row => row.CustomerId == customerId);
            Assert.True(wholesale.IsWholesale);
            Assert.Equal("B", wholesale.PriceGrade);
            Assert.Equal("NET30", wholesale.TermsCode);
            Assert.Equal(30, wholesale.TermsDays);
            Assert.Equal(98765.4321m, wholesale.CreditLimit.Amount);
            Assert.Equal("EXEMPT", wholesale.TaxTreatment);
            Assert.Equal("0042", wholesale.RepresentativeStaffCode);
            Assert.Equal(createdAt, wholesale.CreatedAt);
            Assert.Equal("legacy wholesale account", wholesale.Notes);
        }
    }
}

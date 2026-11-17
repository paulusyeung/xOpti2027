using Microsoft.EntityFrameworkCore;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class CustomerMappingTests(PostgresFixture fixture)
{
    [Fact]
    public async Task CustomerClinicalAndPrescriptionRows_RoundTripWithLegacyIdentifiers()
    {
        const int id = 987654;
        var birthday = new DateTimeOffset(1980, 5, 6, 0, 0, 0, TimeSpan.Zero);
        var issued = new DateTimeOffset(2026, 2, 3, 0, 0, 0, TimeSpan.Zero);

        await using (var context = fixture.NewContext())
        {
            context.Customers.Add(new Customer
            {
                Id = id, VipCode = "V987", FirstName = "Ada", LastName = "Lens",
                FullName = "Ada Lens", Salutation = "Ms", Birthday = birthday,
                HomeAddress = "1 Main St", HomeCity = 1, HomeProvince = "BC",
                HomePostalCode = "V6B1A1", HomeCountry = "CA", HomePhone = "6045550100",
                Cellular = "6045550199", Email = "ada@example.test",
                BizCompanyName = "Optics", BizCity = 2, BizPhone = "6045550111",
                CreditLimit = Money.From(250m), PaymentTerms = "30", VipMarkDownPct = 5,
                SummaryFlag = true, AccountingFlag = false, Remarks = "legacy note",
            });
            context.CustomerAccounts.Add(new CustomerAccount
            {
                CustomerId = id, JointDate = birthday, TtlAmtPurchased = Money.From(100m),
                TtlAmtRefund = Money.From(5m), YtdAmtPurchased = Money.From(20m),
                YtdAmtRefund = Money.From(1m), LastPurchaseDate = issued,
            });
            context.CustomerMedicals.Add(new CustomerMedical
            {
                CustomerId = id, InsMaturityDate = issued, CareCardNo = "1234567890",
                CareCardValidPeriod = "2027", CareCardType = "MSP",
                PrescriptionLensFlag = true, PrescriptionContactFlag = false,
            });
            context.CustomerPresLenses.Add(new CustomerPresLens
            {
                CustomerId = id, IssuedOn = issued, IssuedByDr = 42,
                RightSphere = 1.25, RightCylinder = -0.5, RightAxis = 90,
                RightPdDist = 32, RightPdNear = 30, RightPrism = 1, RightAdd = 2,
                RightPupil = 4, LeftSphere = -1.75, LeftCylinder = -1.25, LeftAxis = 85,
                LeftPdDist = 31, LeftPdNear = 29, LeftPrism = 0.5, LeftAdd = 2,
                LeftPupil = 4.5,
            });
            context.CustomerPresContacts.Add(new CustomerPresContact
            {
                CustomerId = id, IssuedOn = issued, IssuedByDr = 42,
                RightSphere = 0.5, RightCylinder = -0.75, RightAxis = 10,
                RightKReadingV = 42, RightKReadingH = 43, RightPalp = 12,
                RightCorn = 11, RightPupil = 4, LeftSphere = 0.75,
                LeftCylinder = -0.5, LeftAxis = 170, LeftKReadingV = 41,
                LeftKReadingH = 42, LeftPalp = 11, LeftCorn = 10, LeftPupil = 4,
                History = "history", Medical = "medical", Allergy = "none",
                Reason = "exam", Evaluation = "stable", Test = "visual",
            });
            await context.SaveChangesAsync();
        }

        await using (var verify = fixture.NewContext())
        {
            var customer = await verify.Customers.AsNoTracking().SingleAsync(row => row.Id == id);
            Assert.Equal("V987", customer.VipCode);
            Assert.Equal("Ada", customer.FirstName);
            Assert.Equal("Lens", customer.LastName);
            Assert.Equal(birthday, customer.Birthday);
            Assert.Equal("6045550100", customer.HomePhone);
            Assert.Equal(250m, customer.CreditLimit.Amount);
            Assert.Equal("legacy note", customer.Remarks);

            var account = await verify.CustomerAccounts.AsNoTracking().SingleAsync(row => row.CustomerId == id);
            Assert.Equal(100m, account.TtlAmtPurchased.Amount);
            Assert.Equal(issued, account.LastPurchaseDate);

            var medical = await verify.CustomerMedicals.AsNoTracking().SingleAsync(row => row.CustomerId == id);
            Assert.Equal("1234567890", medical.CareCardNo);
            Assert.True(medical.PrescriptionLensFlag);
            Assert.False(medical.PrescriptionContactFlag);

            var lens = await verify.CustomerPresLenses.AsNoTracking().SingleAsync(row => row.CustomerId == id);
            Assert.Equal(1.25, lens.RightSphere);
            Assert.Equal(-1.75, lens.LeftSphere);
            Assert.Equal(90, lens.RightAxis);
            Assert.Equal(issued, lens.IssuedOn);

            var contact = await verify.CustomerPresContacts.AsNoTracking().SingleAsync(row => row.CustomerId == id);
            Assert.Equal(0.5, contact.RightSphere);
            Assert.Equal(170, contact.LeftAxis);
            Assert.Equal("medical", contact.Medical);
        }
    }
}

public class CustomerPiiDtoTests
{
    [Fact]
    public void WithoutPii_RemovesProtectedIdentityAndContactFields()
    {
        var dto = new xOpti.Application.Customers.CustomerDetailDto(
            1, "V1", "Ms", "Ada", "A", "Lens", "Ada Lens",
            DateTimeOffset.UtcNow, "1 Main", 1, "BC", "V6B", "CA", "6045550100",
            "6045550101", "6045550199", "ada@example.test", "Optics", "Owner",
            "2 Work", 2, "BC", "V6B", "CA", "6045550111", "6045550112",
            100m, "30", 5, true, false, "note");

        var masked = dto.WithoutPii();

        Assert.Equal("***", masked.FirstName);
        Assert.Equal("***", masked.LastName);
        Assert.Equal("***", masked.FullName);
        Assert.Null(masked.HomePhone);
        Assert.Null(masked.Email);
        Assert.Null(masked.HomeAddress);
        Assert.Null(masked.Birthday);
        Assert.Null(masked.Remarks);
    }
}

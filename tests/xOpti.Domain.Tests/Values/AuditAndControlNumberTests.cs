using xOpti.Domain.Values;

namespace xOpti.Domain.Tests.Values;

public class AuditInfoTests
{
    [Fact]
    public void Creation_requires_user_and_branch_attribution()
    {
        var ok = AuditInfo.Create("cashier1", "richmond", DateTimeOffset.UnixEpoch);
        Assert.True(ok.IsSuccess);
        Assert.Equal("cashier1", ok.Value.CreatedUser);
        Assert.Equal("richmond", ok.Value.CreatedBranch);
        Assert.False(ok.Value.IsDeleted);

        Assert.False(AuditInfo.Create(null, "richmond", DateTimeOffset.UnixEpoch).IsSuccess);
        Assert.False(AuditInfo.Create("cashier1", "  ", DateTimeOffset.UnixEpoch).IsSuccess);
    }

    [Fact]
    public void Soft_delete_requires_reason_code()
    {
        var info = AuditInfo.Create("manager", "richmond", DateTimeOffset.UnixEpoch).Value;

        var failure = info.MarkDeleted(null, "manager", "richmond", DateTimeOffset.UnixEpoch);
        Assert.False(failure.IsSuccess);
        Assert.Contains("reason code", failure.Error);

        var ok = info.MarkDeleted("DUP-ENTRY", "manager", "richmond", DateTimeOffset.UnixEpoch);
        Assert.True(ok.IsSuccess);
        Assert.True(ok.Value.IsDeleted);
        Assert.Equal("DUP-ENTRY", ok.Value.DeleteReasonCode);
        Assert.Equal("manager", ok.Value.ModifiedUser);
        Assert.Equal(info, info);
    }

    [Fact]
    public void Modification_updates_attribution_without_touching_creation()
    {
        var info = AuditInfo.Create("a", "b1", DateTimeOffset.UnixEpoch).Value;
        var later = DateTimeOffset.UnixEpoch.AddHours(5);

        var modified = info.WithModification("c", "b2", later);
        Assert.True(modified.IsSuccess);
        Assert.Equal("a", modified.Value.CreatedUser);
        Assert.Equal("c", modified.Value.ModifiedUser);
        Assert.Equal(later, modified.Value.ModifiedAt);

        Assert.False(info.WithModification("", "b2", later).IsSuccess);
    }
}

public class ControlNumberMonotonicityTests
{
    private static ControlNumber Cn(string value)
    {
        Assert.True(ControlNumber.TryParse(value, out var parsed));
        return parsed;
    }

    [Fact]
    public void Sequence_is_strictly_increasing_within_family()
    {
        var first = Cn("RC00000001");
        var second = Cn("RC00000002");

        Assert.True(second.Follows(first));
        Assert.False(first.Follows(second));
        Assert.False(second.Follows(second));

        Assert.True(Cn("RC00000100").Follows(second));
    }

    [Fact]
    public void Cross_family_sequences_are_independent()
    {
        var rc = Cn("RC00000005");
        var wc = Cn("WC00000005");

        Assert.False(rc.Follows(wc));
        Assert.False(wc.Follows(rc));

        var comparison = ControlNumber.CompareWithinFamily(rc, wc);
        Assert.False(comparison.IsSuccess);
        Assert.Contains("across families", comparison.Error);
    }

    [Fact]
    public void CompareWithinFamily_returns_signs_for_same_family()
    {
        Assert.Equal(0, ControlNumber.CompareWithinFamily(Cn("RC00000001"), Cn("RC00000001")).Value);
        Assert.True(ControlNumber.CompareWithinFamily(Cn("SR00000010"), Cn("SR00000009")).Value > 0);
        Assert.True(ControlNumber.CompareWithinFamily(Cn("SR00000009"), Cn("SR00000010")).Value < 0);
    }

    [Fact]
    public void Create_formats_prefixed_value_and_rejects_non_positive_sequence()
    {
        var cn = ControlNumber.Create(TransactionType.WholesaleInvoice, 42);
        Assert.Equal("WC00000042", cn.Value);
        Assert.Equal(TransactionType.WholesaleInvoice, cn.Family);

        Assert.Throws<ArgumentOutOfRangeException>(() => ControlNumber.Create(TransactionType.RetailInvoice, 0));
    }
}

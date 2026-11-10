namespace xOpti.Domain.Values;

/// <summary>
/// Prescription lens parameters for one eye (legacy customer_pres_lens shape:
/// sphere/cylinder/axis plus optional add).
/// </summary>
public sealed record RxLens
{
    public decimal Sphere { get; }

    public decimal Cylinder { get; }

    public int Axis { get; }

    public decimal? Add { get; }

    public RxPower Power { get; }

    private RxLens(decimal sphere, decimal cylinder, int axis, decimal? add, RxPower power)
    {
        Sphere = sphere;
        Cylinder = cylinder;
        Axis = axis;
        Add = add;
        Power = power;
    }

    public static Common.Result<RxLens> Create(
        RxPower power,
        decimal sphere,
        decimal cylinder,
        int axis,
        decimal? add = null)
    {
        if (sphere is < -30m or > 30m)
        {
            return Common.Result<RxLens>.Failure($"Sphere {sphere} for {power} eye is outside [-30, +30].");
        }

        if (cylinder is < -20m or > 20m)
        {
            return Common.Result<RxLens>.Failure($"Cylinder {cylinder} for {power} eye is outside [-20, +20].");
        }

        if (axis is < 0 or > 180)
        {
            return Common.Result<RxLens>.Failure($"Axis {axis} for {power} eye is outside [0, 180].");
        }

        if (add is < 0m or > 6m)
        {
            return Common.Result<RxLens>.Failure($"Add {add} for {power} eye is outside [0, +6].");
        }

        return Common.Result<RxLens>.Success(new RxLens(sphere, cylinder, axis, add, power));
    }
}

public enum RxPower
{
    Right,
    Left,
}

/// <summary>
/// Paired prescription for a customer visit.
/// </summary>
public sealed record Rx
{
    public RxLens Right { get; }

    public RxLens Left { get; }

    public DateTimeOffset IssuedOn { get; }

    public int? IssuedByDoctorId { get; }

    private Rx(RxLens right, RxLens left, DateTimeOffset issuedOn, int? issuedByDoctorId)
    {
        Right = right;
        Left = left;
        IssuedOn = issuedOn;
        IssuedByDoctorId = issuedByDoctorId;
    }

    public static Common.Result<Rx> Create(RxLens right, RxLens left, DateTimeOffset issuedOn, int? issuedByDoctorId = null)
    {
        if (right.Power != RxPower.Right || left.Power != RxPower.Left)
        {
            return Common.Result<Rx>.Failure("Rx requires one right and one left lens parameter set.");
        }

        return Common.Result<Rx>.Success(new Rx(right, left, issuedOn, issuedByDoctorId));
    }
}

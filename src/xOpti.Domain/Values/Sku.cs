namespace xOpti.Domain.Values;

/// <summary>
/// Stock keeping unit identifier (legacy inventory.sku, varchar(13)).
/// </summary>
public readonly record struct Sku
{
    public const int MaxLength = 13;

    public string Value { get; }

    private Sku(string value)
    {
        Value = value;
    }

    public static Common.Result<Sku> Create(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw))
        {
            return Common.Result<Sku>.Failure("SKU is required.");
        }

        var trimmed = raw.Trim();
        if (trimmed.Length > MaxLength)
        {
            return Common.Result<Sku>.Failure($"SKU '{trimmed}' exceeds {MaxLength} characters.");
        }

        return Common.Result<Sku>.Success(new Sku(trimmed));
    }

    public override string ToString() => Value;
}

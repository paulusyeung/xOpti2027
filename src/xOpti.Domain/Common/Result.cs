namespace xOpti.Domain.Common;

/// <summary>
/// Minimal Result type used by domain factories for validation failures.
/// </summary>
public class Result
{
    public bool IsSuccess { get; }
    public string Error { get; }

    protected Result(bool isSuccess, string error)
    {
        IsSuccess = isSuccess;
        Error = error;
    }

    public static Result Success() => new(true, string.Empty);
    public static Result Failure(string error) => new(false, error);
}

public sealed class Result<T> : Result
{
    public T Value { get; }

    private Result(bool isSuccess, T value, string error)
        : base(isSuccess, error)
    {
        Value = value;
    }

    public static Result<T> Success(T value) => new(true, value, string.Empty);
    public static new Result<T> Failure(string error) => new(false, default!, error);

    public Result<TTarget> Map<TTarget>(Func<T, TTarget> selector) =>
        IsSuccess ? Result<TTarget>.Success(selector(Value)) : Result<TTarget>.Failure(Error);
}

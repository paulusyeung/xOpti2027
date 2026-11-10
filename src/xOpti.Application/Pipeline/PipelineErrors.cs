namespace xOpti.Application.Pipeline;

/// <summary>A single structured validation failure.</summary>
public sealed record ValidationFieldError(string Field, string Code, string Message);

/// <summary>Request failed validation before the handler ran.</summary>
public sealed class ValidationFailedException(IReadOnlyList<ValidationFieldError> Errors)
    : Exception("Request validation failed.")
{
    public IReadOnlyList<ValidationFieldError> Errors { get; } = Errors;
}

/// <summary>The principal lacks a permission required by the request.</summary>
public sealed class AuthorizationFailedException(string permission, string requestType)
    : Exception($"Missing permission '{permission}' for '{requestType}'.")
{
    public string Permission { get; } = permission;

    public string RequestType { get; } = requestType;
}

/// <summary>No handler is registered for the request type.</summary>
public sealed class UnsupportedRequestException(Type requestType)
    : Exception($"No handler is registered for request type '{requestType.FullName}'.")
{
    public Type RequestType { get; } = requestType;
}

/// <summary>
/// Another submission with the same idempotency key is still executing.
/// </summary>
public sealed class IdempotencyConflictException(string key)
    : Exception($"Idempotency key '{key}' is currently in progress.")
{
    public string Key { get; } = key;
}

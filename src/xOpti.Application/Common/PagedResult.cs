namespace xOpti.Application.Common;

/// <summary>
/// A keyset-paged page: items in stable key order plus an opaque cursor for
/// the next page. There is deliberately no offset, page number, or total count.
/// </summary>
public sealed record PagedResult<T>(IReadOnlyList<T> Items, string? NextCursor);

/// <summary>
/// Opaque keyset cursor. The payload is the last returned stable key; callers
/// treat the encoded value as a black box. Base64 with URL-safe alphabet and
/// no padding so cursors are query-string friendly.
/// </summary>
public static class KeysetCursor
{
    public static string Encode(string lastKey) =>
        System.Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(lastKey))
            .TrimEnd('=').Replace('+', '-').Replace('/', '_');

    public static string Decode(string cursor)
    {
        var padded = cursor.Replace('-', '+').Replace('_', '/');
        padded = padded.PadRight(padded.Length + (4 - padded.Length % 4) % 4, '=');
        return System.Text.Encoding.UTF8.GetString(System.Convert.FromBase64String(padded));
    }
}

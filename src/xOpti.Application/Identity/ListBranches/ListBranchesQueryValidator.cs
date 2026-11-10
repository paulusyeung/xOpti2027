using FluentValidation;

namespace xOpti.Application.Identity.ListBranches;

public sealed class ListBranchesQueryValidator : AbstractValidator<ListBranchesQuery>
{
    public const int MaxPageSize = 100;

    public ListBranchesQueryValidator()
    {
        RuleFor(x => x.PageSize)
            .InclusiveBetween(1, MaxPageSize)
            .WithMessage($"PageSize must be between 1 and {MaxPageSize}.");

        RuleFor(x => x.Cursor)
            .Must(BeDecodable)
            .When(x => x.Cursor is not null)
            .WithMessage("Cursor is not a valid continuation token.");
    }

    private static bool BeDecodable(string? cursor)
    {
        if (cursor is null)
        {
            return true;
        }

        try
        {
            xOpti.Application.Common.KeysetCursor.Decode(cursor);
            return true;
        }
        catch (FormatException)
        {
            return false;
        }
    }
}

using Microsoft.EntityFrameworkCore;
using xOpti.Application.Optical;
using xOpti.Application.Pipeline;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfOpticalOrderStore(XOptiDbContext context) : IOpticalOrderStore
{
    private static readonly string[] StatusOrder =
        { "entered", "ordered", "received", "dispensed" };

    public async Task<OpticalOrderDto?> GetAsync(string txNumber, CancellationToken ct)
    {
        var header = await context.TxHeaders.AsNoTracking()
            .SingleOrDefaultAsync(row => row.TxNumber == txNumber
                && row.TxType == xOpti.Domain.Values.TransactionType.SalesOrder, ct);
        if (header is null) return null;
        var customerName = await context.Customers.AsNoTracking()
            .Where(row => row.Id == header.CustomerId).Select(row => row.FullName)
            .SingleOrDefaultAsync(ct);
        var rx = await context.OpticalOrderPrescriptions.AsNoTracking()
            .Where(row => row.TxNumber == txNumber).ToListAsync(ct);
        var frames = await context.TxSOrderFrames.AsNoTracking()
            .Where(row => row.TxNumber == txNumber).OrderBy(row => row.LineNumber).ToListAsync(ct);
        var lenses = await context.TxSOrderLenses.AsNoTracking()
            .Where(row => row.TxNumber == txNumber).OrderBy(row => row.LineNumber).ToListAsync(ct);
        var contacts = await context.TxSOrderConts.AsNoTracking()
            .Where(row => row.TxNumber == txNumber).OrderBy(row => row.LineNumber).ToListAsync(ct);
        var events = await context.OpticalOrderEvents.AsNoTracking()
            .Where(row => row.TxNumber == txNumber).OrderBy(row => row.OccurredAt)
            .Select(row => new OpticalEventDto(row.Id, row.Status, row.OccurredAt,
                row.Actor, row.Reference, row.Notes)).ToListAsync(ct);

        return new OpticalOrderDto(txNumber, header.CustomerId, customerName, header.Status,
            frames.Select(row => new FrameDetailDto((int)row.LineNumber, row.Supply ?? false,
                row.Enclosed ?? false, row.Follow ?? false, row.Lenses ?? false, row.Mode,
                row.Color, row.EyeSize, row.Bridge, row.Temple, row.R1, row.R2, row.R3,
                row.A, row.B, row.SpecialInstruction)).ToList(),
            lenses.Select(row => new LensDetailDto((int)row.LineNumber,
                rx.FirstOrDefault(link => link.LineNumber == row.LineNumber
                    && link.PrescriptionType == "spectacle")?.PrescriptionVersionId,
                Eye(row.RightSphere, row.RightCylinder, row.RightAxis, row.RightPdDist,
                    row.RightAdd, row.RightPrism, row.RightBase, row.RightSegHt,
                    row.RightOc, row.RightVd),
                Eye(row.LeftSphere, row.LeftCylinder, row.LeftAxis, row.LeftPdDist,
                    row.LeftAdd, row.LeftPrism, row.LeftBase, row.LeftSegHt,
                    row.LeftOc, row.LeftVd),
                row.RightStyle, row.LeftStyle, row.Type, row.Hardening, row.Material,
                row.Coating, row.Tint, row.Others, row.HardCoat ?? false,
                row.ArCoat ?? false, row.Uv ?? false)).ToList(),
            contacts.Select(row => new ContactDetailDto((int)row.LineNumber,
                rx.FirstOrDefault(link => link.LineNumber == row.LineNumber
                    && link.PrescriptionType == "contact")?.PrescriptionVersionId,
                Eye(row.RightSphere, row.RightCylinder, row.RightAxis, null, null, null,
                    null, null, null, null),
                Eye(row.LeftSphere, row.LeftCylinder, row.LeftAxis, null, null, null,
                    null, null, null, null),
                row.History, row.Medical, row.Allergy, row.Reason, row.Evaluation,
                row.Test, row.SpecialInstruction)).ToList(),
            events, events.LastOrDefault()?.Status ?? "entered");
    }

    public async Task SaveAsync(string txNumber, IReadOnlyList<FrameDetailInput> frames,
        IReadOnlyList<LensDetailInput> lenses, IReadOnlyList<ContactDetailInput> contacts,
        string reason, string? actor, CancellationToken ct)
    {
        var header = await context.TxHeaders.SingleOrDefaultAsync(row =>
            row.TxNumber == txNumber && row.TxType == xOpti.Domain.Values.TransactionType.SalesOrder, ct)
            ?? throw Validation("TxNumber", "not-found", "Sale order was not found.");
        if (header.Status != "0")
            throw Validation("TxNumber", "not-open", "Only open sale orders can change optical details.");

        var oldFrames = await context.TxSOrderFrames.Where(row => row.TxNumber == txNumber).ToListAsync(ct);
        var oldLenses = await context.TxSOrderLenses.Where(row => row.TxNumber == txNumber).ToListAsync(ct);
        var oldContacts = await context.TxSOrderConts.Where(row => row.TxNumber == txNumber).ToListAsync(ct);
        var oldLinks = await context.OpticalOrderPrescriptions
            .Where(row => row.TxNumber == txNumber).ToListAsync(ct);
        context.TxSOrderFrames.RemoveRange(oldFrames);
        context.TxSOrderLenses.RemoveRange(oldLenses);
        context.TxSOrderConts.RemoveRange(oldContacts);
        context.OpticalOrderPrescriptions.RemoveRange(oldLinks);

        foreach (var frame in frames)
        {
            context.TxSOrderFrames.Add(new TxSOrderFrame
            {
                TxNumber = txNumber, LineNumber = frame.LineNumber, Supply = frame.Supply,
                Enclosed = frame.Enclosed, Follow = frame.Follow, Lenses = frame.Lenses,
                Mode = frame.Mode, Color = frame.Color, EyeSize = frame.EyeSize,
                Bridge = frame.Bridge ?? 0, Temple = frame.Temple ?? 0, R1 = frame.R1,
                R2 = frame.R2, R3 = frame.R3, A = frame.A, B = frame.B,
                SpecialInstruction = frame.SpecialInstruction,
            });
        }
        foreach (var lens in lenses)
        {
            context.TxSOrderLenses.Add(new TxSOrderLens
            {
                TxNumber = txNumber, LineNumber = lens.LineNumber,
                RightSphere = (double)(lens.Right.Sphere ?? 0),
                RightCylinder = (double)(lens.Right.Cylinder ?? 0),
                RightAxis = lens.Right.Axis ?? 0,
                RightPdDist = (double)(lens.Right.Pd ?? 0),
                RightPrism = (double)(lens.Right.Prism ?? 0),
                RightAdd = (double)(lens.Right.Add ?? 0),
                RightSegHt = (double)(lens.Right.SegHeight ?? 0),
                RightOc = (double)(lens.Right.Oc ?? 0),
                RightBase = (double)(lens.Right.Base ?? 0),
                RightVd = (double)(lens.Right.Vd ?? 0),
                RightStyle = lens.RightStyle,
                LeftSphere = (double)(lens.Left.Sphere ?? 0),
                LeftCylinder = (double)(lens.Left.Cylinder ?? 0),
                LeftAxis = lens.Left.Axis ?? 0,
                LeftPdDist = (double)(lens.Left.Pd ?? 0),
                LeftPrism = (double)(lens.Left.Prism ?? 0),
                LeftAdd = (double)(lens.Left.Add ?? 0),
                LeftSegHt = (double)(lens.Left.SegHeight ?? 0),
                LeftOc = (double)(lens.Left.Oc ?? 0),
                LeftBase = (double)(lens.Left.Base ?? 0),
                LeftVd = (double)(lens.Left.Vd ?? 0),
                LeftStyle = lens.LeftStyle, Type = lens.Type, Hardening = lens.Hardening,
                Material = lens.Material, Coating = lens.Coating, Tint = lens.Tint,
                Others = lens.Others, HardCoat = lens.HardCoat, ArCoat = lens.ArCoat,
                Uv = lens.Uv,
            });
            AddLink(txNumber, header.CustomerId, lens.LineNumber, "spectacle",
                lens.PrescriptionVersionId);
        }
        foreach (var contact in contacts)
        {
            context.TxSOrderConts.Add(new TxSOrderCont
            {
                TxNumber = txNumber, LineNumber = contact.LineNumber,
                RightSphere = (double)(contact.Right.Sphere ?? 0),
                RightCylinder = (double)(contact.Right.Cylinder ?? 0),
                RightAxis = contact.Right.Axis ?? 0,
                LeftSphere = (double)(contact.Left.Sphere ?? 0),
                LeftCylinder = (double)(contact.Left.Cylinder ?? 0),
                LeftAxis = contact.Left.Axis ?? 0,
                History = contact.History, Medical = contact.Medical, Allergy = contact.Allergy,
                Reason = contact.Reason, Evaluation = contact.Evaluation, Test = contact.Test,
                SpecialInstruction = contact.SpecialInstruction,
            });
            AddLink(txNumber, header.CustomerId, contact.LineNumber, "contact",
                contact.PrescriptionVersionId);
        }
        if (!await context.OpticalOrderEvents.AnyAsync(row => row.TxNumber == txNumber, ct))
        {
            context.OpticalOrderEvents.Add(new OpticalOrderEvent
            {
                TxNumber = txNumber, Status = "entered", OccurredAt = DateTimeOffset.UtcNow,
                Actor = actor, Notes = reason,
            });
        }
        await context.SaveChangesAsync(ct);
    }

    public async Task RecordStatusAsync(string txNumber, string status, string? reference,
        string? notes, string? actor, CancellationToken ct)
    {
        if (!StatusOrder.Contains(status))
            throw Validation("Status", "invalid", "Optical status is not valid.");
        var events = await context.OpticalOrderEvents.Where(row => row.TxNumber == txNumber)
            .OrderBy(row => row.OccurredAt).ToListAsync(ct);
        var currentIndex = events.Count == 0 ? -1 : Array.IndexOf(StatusOrder, events[^1].Status);
        var nextIndex = Array.IndexOf(StatusOrder, status);
        if (nextIndex != currentIndex + 1)
            throw Validation("Status", "sequence",
                $"Optical status must advance from {StatusOrder[Math.Max(0, currentIndex)]} to the next step.");
        context.OpticalOrderEvents.Add(new OpticalOrderEvent
        {
            TxNumber = txNumber, Status = status, OccurredAt = DateTimeOffset.UtcNow,
            Actor = actor, Reference = reference, Notes = notes,
        });
        await context.SaveChangesAsync(ct);
    }

    public async Task<IReadOnlyList<string>> ConversionIssuesAsync(
        string txNumber, bool requireVerifiedPrescription, CancellationToken ct)
    {
        var issues = new List<string>();
        var lenses = await context.TxSOrderLenses.AsNoTracking()
            .Where(row => row.TxNumber == txNumber).ToListAsync(ct);
        var contacts = await context.TxSOrderConts.AsNoTracking()
            .Where(row => row.TxNumber == txNumber).ToListAsync(ct);
        var links = await context.OpticalOrderPrescriptions.AsNoTracking()
            .Where(row => row.TxNumber == txNumber).ToListAsync(ct);
        foreach (var line in lenses.Select(row => (int)row.LineNumber)
                     .Concat(contacts.Select(row => (int)row.LineNumber)))
        {
            if (links.All(link => (int)link.LineNumber != line))
                issues.Add($"Optical line {line} has no prescription version reference.");
        }
        if (requireVerifiedPrescription)
        {
            foreach (var link in links)
            {
                var verified = link.PrescriptionType == "contact"
                    ? await context.ContactLensPrescriptionVersions.AnyAsync(row =>
                        row.Id == link.PrescriptionVersionId && row.VerifiedAt != null, ct)
                    : await context.SpectaclePrescriptionVersions.AnyAsync(row =>
                        row.Id == link.PrescriptionVersionId && row.VerifiedAt != null, ct);
                if (!verified)
                    issues.Add($"Prescription version {link.PrescriptionVersionId} is not verified.");
            }
        }
        foreach (var lens in lenses)
        {
            if (lens.RightAxis is < 0 or > 180 || lens.LeftAxis is < 0 or > 180)
                issues.Add($"Lens line {(int)lens.LineNumber} has an invalid axis.");
        }
        return issues;
    }

    private void AddLink(string txNumber, int customerId, int lineNumber, string type, long? versionId)
    {
        if (versionId is null) return;
        context.OpticalOrderPrescriptions.Add(new OpticalOrderPrescription
        {
            TxNumber = txNumber, LineNumber = lineNumber, CustomerId = customerId,
            PrescriptionType = type, PrescriptionVersionId = versionId.Value,
        });
    }

    private static ValidationFailedException Validation(string field, string code, string message) =>
        new(new[] { new ValidationFieldError(field, code, message) });

    private static OpticalEyeValues Eye(double sphere, double cylinder, int axis, double? pd,
        double? add, double? prism, double? @base, double? segHeight, double? oc, double? vd) =>
        new((decimal)sphere, (decimal)cylinder, axis, pd is null ? null : (decimal)pd,
            add is null ? null : (decimal)add, prism is null ? null : (decimal)prism,
            @base is null ? null : (decimal)@base,
            segHeight is null ? null : (decimal)segHeight,
            oc is null ? null : (decimal)oc, vd is null ? null : (decimal)vd);
}

using Microsoft.EntityFrameworkCore;
using xOpti.Application.Customers;
using xOpti.Application.Prescriptions;
using xOpti.Infrastructure.Documents;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfPrescriptionStore(
    XOptiDbContext context, IFileStorage fileStorage) : IPrescriptionStore
{
    public async Task<PrescriptionHistoryDto> GetHistoryAsync(int customerId, CancellationToken ct)
    {
        var medical = await context.CustomerMedicals.AsNoTracking()
            .SingleOrDefaultAsync(row => row.CustomerId == customerId, ct);
        var spectacle = await context.SpectaclePrescriptionVersions.AsNoTracking()
            .Where(row => row.CustomerId == customerId).OrderBy(row => row.VersionNumber)
            .ToListAsync(ct);
        var contact = await context.ContactLensPrescriptionVersions.AsNoTracking()
            .Where(row => row.CustomerId == customerId).OrderBy(row => row.VersionNumber)
            .ToListAsync(ct);
        var legacyLens = await context.CustomerPresLenses.AsNoTracking()
            .SingleOrDefaultAsync(row => row.CustomerId == customerId, ct);
        var legacyContact = await context.CustomerPresContacts.AsNoTracking()
            .SingleOrDefaultAsync(row => row.CustomerId == customerId, ct);
        var notes = await context.MedicalNotes.AsNoTracking()
            .Where(row => row.CustomerId == customerId).OrderBy(row => row.RecordedAt)
            .Select(row => new MedicalNoteDto(row.Id, row.CustomerId, row.Note,
                row.RecordedAt, row.RecordedBy)).ToListAsync(ct);
        var attachments = await context.PatientAttachments.AsNoTracking()
            .Where(row => row.CustomerId == customerId).OrderBy(row => row.UploadedAt)
            .Select(row => new PatientAttachmentDto(row.Id, row.CustomerId, row.Kind,
                row.PrescriptionType, row.PrescriptionVersionId, row.FileName,
                row.ContentType, row.Size, row.UploadedAt, row.UploadedBy)).ToListAsync(ct);

        var spectacleDtos = spectacle.Select(row => new SpectacleVersionDto(
            row.Id, row.CustomerId, row.VersionNumber, "app", row.IssuedOn, row.PrescriberId,
            new SpectacleEyeValues(row.RightSphere, row.RightCylinder, row.RightAxis,
                row.RightAdd, row.RightPrism, row.RightBase, row.RightPd),
            new SpectacleEyeValues(row.LeftSphere, row.LeftCylinder, row.LeftAxis,
                row.LeftAdd, row.LeftPrism, row.LeftBase, row.LeftPd),
            row.Notes, row.Reason, row.IsCurrent, row.VerifiedAt, row.VerifiedBy,
            row.VerificationNote)).ToList();
        if (legacyLens is not null && spectacleDtos.Count == 0)
        {
            spectacleDtos.Add(new SpectacleVersionDto(0, customerId, 0, "legacy",
                legacyLens.IssuedOn ?? DateTimeOffset.MinValue, legacyLens.IssuedByDr,
                new SpectacleEyeValues((decimal)legacyLens.RightSphere, (decimal)legacyLens.RightCylinder,
                    legacyLens.RightAxis, (decimal)legacyLens.RightAdd, (decimal)legacyLens.RightPrism,
                    null, (decimal)legacyLens.RightPdDist),
                new SpectacleEyeValues((decimal)legacyLens.LeftSphere, (decimal)legacyLens.LeftCylinder,
                    legacyLens.LeftAxis, (decimal)legacyLens.LeftAdd, (decimal)legacyLens.LeftPrism,
                    null, (decimal)legacyLens.LeftPdDist),
                null, "Migrated legacy prescription", true, null, null, null));
        }

        var contactDtos = contact.Select(row => new ContactVersionDto(
            row.Id, row.CustomerId, row.VersionNumber, "app", row.IssuedOn, row.PrescriberId,
            row.Brand, row.BaseCurve, row.Diameter, row.RightPower, row.RightCylinder,
            row.RightAxis, row.LeftPower, row.LeftCylinder, row.LeftAxis,
            row.ReplacementSchedule, row.Notes, row.Reason, row.IsCurrent,
            row.VerifiedAt, row.VerifiedBy, row.VerificationNote)).ToList();
        if (legacyContact is not null && contactDtos.Count == 0)
        {
            contactDtos.Add(new ContactVersionDto(0, customerId, 0, "legacy",
                legacyContact.IssuedOn ?? DateTimeOffset.MinValue, legacyContact.IssuedByDr,
                null, null, null,
                (decimal)legacyContact.RightSphere, (decimal)legacyContact.RightCylinder,
                legacyContact.RightAxis, (decimal)legacyContact.LeftSphere,
                (decimal)legacyContact.LeftCylinder, legacyContact.LeftAxis,
                null, legacyContact.Medical, "Migrated legacy prescription", true,
                null, null, null));
        }

        return new PrescriptionHistoryDto(customerId, medical is null ? null : new CustomerMedicalDto(
            medical.CustomerId, medical.InsMaturityDate, medical.CareCardNo,
            medical.CareCardValidPeriod, medical.CareCardType,
            medical.PrescriptionLensFlag, medical.PrescriptionContactFlag),
            spectacleDtos, contactDtos, notes, attachments);
    }

    public async Task<long> SaveSpectacleAsync(int customerId, SpectaclePrescriptionInput input,
        string reason, string? actor, CancellationToken ct)
    {
        await EnsureCustomerAsync(customerId, ct);
        await context.SpectaclePrescriptionVersions
            .Where(row => row.CustomerId == customerId && row.IsCurrent)
            .ExecuteUpdateAsync(setter => setter.SetProperty(row => row.IsCurrent, false), ct);
        var version = (await context.SpectaclePrescriptionVersions
            .Where(row => row.CustomerId == customerId)
            .MaxAsync(row => (int?)row.VersionNumber, ct) ?? 0) + 1;
        var entity = new SpectaclePrescriptionVersion
        {
            CustomerId = customerId, VersionNumber = version, IssuedOn = input.IssuedOn,
            PrescriberId = input.PrescriberId,
            RightSphere = input.Right.Sphere, RightCylinder = input.Right.Cylinder,
            RightAxis = input.Right.Axis, RightAdd = input.Right.Add,
            RightPrism = input.Right.Prism, RightBase = input.Right.Base, RightPd = input.Right.Pd,
            LeftSphere = input.Left.Sphere, LeftCylinder = input.Left.Cylinder,
            LeftAxis = input.Left.Axis, LeftAdd = input.Left.Add,
            LeftPrism = input.Left.Prism, LeftBase = input.Left.Base, LeftPd = input.Left.Pd,
            Notes = input.Notes, Reason = reason, CreatedAt = DateTimeOffset.UtcNow,
            CreatedBy = actor, IsCurrent = true,
        };
        context.SpectaclePrescriptionVersions.Add(entity);
        await context.SaveChangesAsync(ct);
        return entity.Id;
    }

    public async Task<long> SaveContactLensAsync(int customerId,
        ContactLensPrescriptionInput input, string reason, string? actor, CancellationToken ct)
    {
        await EnsureCustomerAsync(customerId, ct);
        await context.ContactLensPrescriptionVersions
            .Where(row => row.CustomerId == customerId && row.IsCurrent)
            .ExecuteUpdateAsync(setter => setter.SetProperty(row => row.IsCurrent, false), ct);
        var version = (await context.ContactLensPrescriptionVersions
            .Where(row => row.CustomerId == customerId)
            .MaxAsync(row => (int?)row.VersionNumber, ct) ?? 0) + 1;
        var entity = new ContactLensPrescriptionVersion
        {
            CustomerId = customerId, VersionNumber = version, IssuedOn = input.IssuedOn,
            PrescriberId = input.PrescriberId, Brand = input.Brand,
            BaseCurve = input.BaseCurve, Diameter = input.Diameter,
            RightPower = input.RightPower, RightCylinder = input.RightCylinder,
            RightAxis = input.RightAxis, LeftPower = input.LeftPower,
            LeftCylinder = input.LeftCylinder, LeftAxis = input.LeftAxis,
            ReplacementSchedule = input.ReplacementSchedule, Notes = input.Notes,
            Reason = reason, CreatedAt = DateTimeOffset.UtcNow, CreatedBy = actor,
            IsCurrent = true,
        };
        context.ContactLensPrescriptionVersions.Add(entity);
        await context.SaveChangesAsync(ct);
        return entity.Id;
    }

    public async Task VerifyAsync(int customerId, string type, long versionId, string? note,
        string? actor, CancellationToken ct)
    {
        var now = DateTimeOffset.UtcNow;
        if (type == "spectacle")
        {
            var row = await context.SpectaclePrescriptionVersions
                .SingleOrDefaultAsync(item => item.Id == versionId && item.CustomerId == customerId, ct)
                ?? throw new InvalidOperationException("Spectacle prescription version was not found.");
            row.VerifiedAt = now; row.VerifiedBy = actor; row.VerificationNote = note;
        }
        else if (type == "contact")
        {
            var row = await context.ContactLensPrescriptionVersions
                .SingleOrDefaultAsync(item => item.Id == versionId && item.CustomerId == customerId, ct)
                ?? throw new InvalidOperationException("Contact-lens prescription version was not found.");
            row.VerifiedAt = now; row.VerifiedBy = actor; row.VerificationNote = note;
        }
        else
        {
            throw new InvalidOperationException("Prescription type must be spectacle or contact.");
        }
        await context.SaveChangesAsync(ct);
    }

    public async Task<bool> HasVerifiedCurrentAsync(int customerId, string type, CancellationToken ct) =>
        type == "contact"
            ? await context.ContactLensPrescriptionVersions.AnyAsync(row =>
                row.CustomerId == customerId && row.IsCurrent && row.VerifiedAt != null, ct)
            : await context.SpectaclePrescriptionVersions.AnyAsync(row =>
                row.CustomerId == customerId && row.IsCurrent && row.VerifiedAt != null, ct);

    public async Task<long> AddMedicalNoteAsync(int customerId, string note,
        string? actor, CancellationToken ct)
    {
        await EnsureCustomerAsync(customerId, ct);
        var entity = new MedicalNote
        {
            CustomerId = customerId, Note = note, RecordedAt = DateTimeOffset.UtcNow,
            RecordedBy = actor,
        };
        context.MedicalNotes.Add(entity);
        await context.SaveChangesAsync(ct);
        return entity.Id;
    }

    public async Task<long> AddAttachmentAsync(int customerId, string kind,
        string? prescriptionType, long? versionId, string fileName, string contentType,
        byte[] content, string? actor, CancellationToken ct)
    {
        await EnsureCustomerAsync(customerId, ct);
        var extension = Path.GetExtension(fileName);
        var key = $"customers/{customerId}/attachments/{Guid.NewGuid():N}{extension}";
        var storedKey = fileStorage.Save(key, content, contentType);
        var entity = new PatientAttachment
        {
            CustomerId = customerId, Kind = kind, PrescriptionType = prescriptionType,
            PrescriptionVersionId = versionId, FileName = Path.GetFileName(fileName),
            ContentType = contentType, Size = content.LongLength, StorageKey = storedKey,
            UploadedAt = DateTimeOffset.UtcNow, UploadedBy = actor,
        };
        context.PatientAttachments.Add(entity);
        await context.SaveChangesAsync(ct);
        return entity.Id;
    }

    public async Task<PatientAttachmentContent?> ReadAttachmentAsync(
        long attachmentId, CancellationToken ct)
    {
        var row = await context.PatientAttachments.AsNoTracking()
            .SingleOrDefaultAsync(item => item.Id == attachmentId, ct);
        if (row is null || !fileStorage.TryRead(row.StorageKey, out var content)) return null;
        return new PatientAttachmentContent(new PatientAttachmentDto(row.Id, row.CustomerId,
            row.Kind, row.PrescriptionType, row.PrescriptionVersionId, row.FileName,
            row.ContentType, row.Size, row.UploadedAt, row.UploadedBy), content);
    }

    private async Task EnsureCustomerAsync(int customerId, CancellationToken ct)
    {
        if (!await context.Customers.AnyAsync(row => row.Id == customerId, ct))
            throw new InvalidOperationException("Customer was not found.");
    }
}

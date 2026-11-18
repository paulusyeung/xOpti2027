using Microsoft.EntityFrameworkCore;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Persistence;

/// <summary>App-owned tables (included in EF migrations, additive-only).</summary>
public static class PlatformMapping
{
    public static void Configure(ModelBuilder mb)
    {
        mb.Entity<WholesaleDocument>(e =>
        {
            e.ToTable("wholesale_document", "platform");
            e.HasKey(x => x.TxNumber);
            e.Property(x => x.TxNumber).HasMaxLength(10);
            e.Property(x => x.Kind).HasMaxLength(10).IsRequired();
            e.HasIndex(x => x.Kind);
            e.Property(x => x.Status).HasMaxLength(16).IsRequired();
            e.HasIndex(x => x.Status);
            e.Property(x => x.TermsCode).HasMaxLength(20);
            e.Property(x => x.TermsDays).IsRequired();
            e.Property(x => x.DueDate);
            e.Property(x => x.ShippingMethod).HasMaxLength(60);
            e.Property(x => x.ShipToName).HasMaxLength(120);
            e.Property(x => x.ShipToAddress).HasMaxLength(500);
            e.Property(x => x.ShippingInstructions).HasMaxLength(1000);
            e.Property(x => x.PurchaseOrderNumber).HasMaxLength(40);
            e.Property(x => x.OriginalInvoiceNumber).HasMaxLength(10);
            e.HasIndex(x => x.OriginalInvoiceNumber);
            e.Property(x => x.CreatedAt);
            e.Property(x => x.CreatedBy).HasMaxLength(64);
            e.Property(x => x.UpdatedAt);
            e.Property(x => x.UpdatedBy).HasMaxLength(64);
            e.Property(x => x.PostedAt);
            e.Property(x => x.PostedBy).HasMaxLength(64);
            e.Property(x => x.VoidedAt);
            e.Property(x => x.VoidedBy).HasMaxLength(64);
            e.Property(x => x.VoidReason).HasMaxLength(500);
        });

        mb.Entity<WholesaleReturnLine>(e =>
        {
            e.ToTable("wholesale_return_line", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.ReturnTxNumber).HasMaxLength(10).IsRequired();
            e.HasIndex(x => new { x.ReturnTxNumber, x.ReturnRowNo }).IsUnique();
            e.Property(x => x.ReturnRowNo).IsRequired();
            e.Property(x => x.OriginalInvoiceNumber).HasMaxLength(10).IsRequired();
            e.HasIndex(x => new { x.OriginalInvoiceNumber, x.OriginalRowNo });
            e.Property(x => x.OriginalRowNo).IsRequired();
            e.Property(x => x.Sku).HasMaxLength(13).IsRequired();
            e.Property(x => x.Quantity).IsRequired();
            e.Property(x => x.UnitAmount).HasConversion(Converters.MoneyDecimal).HasPrecision(19, 4);
            e.Property(x => x.UnitCost).HasConversion(Converters.MoneyDecimal).HasPrecision(19, 4);
            e.Property(x => x.DiscountAmount).HasConversion(Converters.MoneyDecimal)
                .HasPrecision(19, 4);
            e.Property(x => x.Amount).HasConversion(Converters.MoneyDecimal).HasPrecision(19, 4);
            e.Property(x => x.TaxA).HasConversion(Converters.MoneyDecimal).HasPrecision(19, 4);
            e.Property(x => x.TaxB).HasConversion(Converters.MoneyDecimal).HasPrecision(19, 4);
            e.Property(x => x.TaxCode).HasMaxLength(1);
            e.Property(x => x.Restock).IsRequired();
            e.Property(x => x.DispositionReason).HasMaxLength(500);
            e.Property(x => x.CreatedAt);
        });

        mb.Entity<WholesaleBackorder>(e =>
        {
            e.ToTable("wholesale_backorder", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.OriginalTxNumber).HasMaxLength(10).IsRequired();
            e.Property(x => x.OriginalRowNo).IsRequired();
            e.HasIndex(x => new { x.OriginalTxNumber, x.OriginalRowNo }).IsUnique();
            e.Property(x => x.CustomerId).IsRequired();
            e.HasIndex(x => x.CustomerId);
            e.Property(x => x.Sku).HasMaxLength(13).IsRequired();
            e.Property(x => x.OrderedQuantity).IsRequired();
            e.Property(x => x.ShippedQuantity).IsRequired();
            e.Property(x => x.RemainingQuantity).IsRequired();
            e.Property(x => x.Status).HasMaxLength(16).IsRequired();
            e.HasIndex(x => x.Status);
            e.Property(x => x.CreatedAt);
            e.Property(x => x.FulfilledByTxNumber).HasMaxLength(10);
            e.Property(x => x.FulfilledAt);
        });

        mb.Entity<WholesaleTender>(e =>
        {
            e.ToTable("wholesale_tender", "platform");
            e.HasKey(x => new { x.TxNumber, x.LineNo });
            e.Property(x => x.TxNumber).HasMaxLength(10);
            e.Property(x => x.LineNo);
            e.Property(x => x.Method).HasMaxLength(2).IsRequired();
            e.Property(x => x.Amount).HasConversion(Converters.MoneyDecimal)
                .HasPrecision(19, 4);
            e.Property(x => x.Reference).HasMaxLength(10);
        });

        mb.Entity<WholesalePriceList>(e =>
        {
            e.ToTable("wholesale_price_list", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.Code).HasMaxLength(20).IsRequired();
            e.Property(x => x.Name).HasMaxLength(120).IsRequired();
            e.Property(x => x.Version).IsRequired();
            e.HasIndex(x => new { x.Code, x.Version }).IsUnique();
            e.HasIndex(x => new { x.Code, x.IsCurrent })
                .HasFilter("is_current = true").IsUnique();
            e.Property(x => x.IsCurrent).IsRequired();
            e.Property(x => x.CreatedAt);
            e.Property(x => x.CreatedBy).HasMaxLength(64);
        });

        mb.Entity<WholesalePriceListItem>(e =>
        {
            e.ToTable("wholesale_price_list_item", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.PriceListId).IsRequired();
            e.HasIndex(x => new { x.PriceListId, x.Sku }).IsUnique();
            e.Property(x => x.Sku).HasMaxLength(13).IsRequired();
            e.Property(x => x.Price).HasConversion(Converters.MoneyDecimal)
                .HasPrecision(19, 4);
        });

        mb.Entity<WholesaleDocumentLine>(e =>
        {
            e.ToTable("wholesale_document_line", "platform");
            e.HasKey(x => new { x.TxNumber, x.RowNo });
            e.Property(x => x.TxNumber).HasMaxLength(10);
            e.Property(x => x.RowNo);
            e.Property(x => x.PriceListCode).HasMaxLength(20).IsRequired();
            e.Property(x => x.PriceListVersion).IsRequired();
            e.Property(x => x.ListUnitPrice).HasConversion(Converters.MoneyDecimal)
                .HasPrecision(19, 4);
            e.Property(x => x.AppliedUnitPrice).HasConversion(Converters.MoneyDecimal)
                .HasPrecision(19, 4);
            e.Property(x => x.TaxA).HasConversion(Converters.MoneyDecimal).HasPrecision(19, 4);
            e.Property(x => x.TaxB).HasConversion(Converters.MoneyDecimal).HasPrecision(19, 4);
            e.Property(x => x.IsOverride).IsRequired();
            e.Property(x => x.OverrideReason).HasMaxLength(500);
            e.Property(x => x.OverrideBy).HasMaxLength(64);
            e.Property(x => x.CreatedAt);
        });

        mb.Entity<WholesaleAccount>(e =>
        {
            e.ToTable("wholesale_account", "platform");
            e.HasKey(x => x.CustomerId);
            e.Property(x => x.CustomerId).ValueGeneratedNever();
            e.Property(x => x.IsWholesale).IsRequired();
            e.Property(x => x.PriceGrade).HasMaxLength(1);
            e.Property(x => x.TermsCode).HasMaxLength(20);
            e.Property(x => x.TermsDays).IsRequired();
            e.Property(x => x.CreditLimit).HasConversion(Converters.MoneyDecimal)
                .HasPrecision(19, 4);
            e.Property(x => x.TaxTreatment).HasMaxLength(20);
            e.Property(x => x.RepresentativeStaffCode).HasMaxLength(4);
            e.HasIndex(x => x.RepresentativeStaffCode);
            e.Property(x => x.CreditHold).IsRequired();
            e.Property(x => x.Notes).HasMaxLength(1000);
            e.Property(x => x.CreatedAt);
            e.Property(x => x.CreatedBy).HasMaxLength(64);
            e.Property(x => x.UpdatedAt);
            e.Property(x => x.UpdatedBy).HasMaxLength(64);
        });

        mb.Entity<AuditLog>(e =>
        {
            e.ToTable("audit_log", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.OccurredAt);
            e.Property(x => x.Details).HasMaxLength(4000);
            e.Property(x => x.Action).HasMaxLength(64).IsRequired();
            e.Property(x => x.EntityType).HasMaxLength(128).IsRequired();
            e.Property(x => x.EntityId).HasMaxLength(64).IsRequired();
            e.Property(x => x.ActorUserId).HasMaxLength(64);
            e.Property(x => x.ActorBranch).HasMaxLength(3);
        });

        mb.Entity<SchemaBaseline>(e =>
        {
            e.ToTable("schema_baseline", "platform");
            e.HasKey(x => x.Id);
            // Single-row table: the id is supplied by the bootstrap, not a sequence.
            e.Property(x => x.Id).ValueGeneratedNever();
            e.Property(x => x.Version).HasMaxLength(64).IsRequired();
            e.Property(x => x.Checksum).HasMaxLength(64).IsRequired();
            e.Property(x => x.AppliedAt);
            e.Property(x => x.AppliedBy).HasMaxLength(128).IsRequired();
        });

        mb.Entity<CashSession>(e =>
        {
            e.ToTable("cash_session", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.BranchCode).HasMaxLength(3).IsRequired();
            e.Property(x => x.TerminalCode).HasMaxLength(20).IsRequired();
            e.Property(x => x.BusinessDate).IsRequired();
            e.Property(x => x.Status).HasMaxLength(16).IsRequired();
            e.Property(x => x.OpenedAt);
            e.Property(x => x.OpenedBy).HasMaxLength(64);
            e.Property(x => x.OpeningFloat).HasPrecision(12, 4);
            e.Property(x => x.SuspendedAt);
            e.Property(x => x.ClosedAt);
            e.Property(x => x.ClosedBy).HasMaxLength(64);
            e.Property(x => x.ExpectedCash).HasPrecision(12, 4);
            e.Property(x => x.CountedCash).HasPrecision(12, 4);
            e.Property(x => x.Variance).HasPrecision(12, 4);
            e.Property(x => x.VarianceReason).HasMaxLength(500);
        });

        mb.Entity<CashCount>(e =>
        {
            e.ToTable("cash_count", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.Kind).HasMaxLength(16).IsRequired();
            e.Property(x => x.Amount).HasPrecision(12, 4);
            e.Property(x => x.CountedAt);
            e.Property(x => x.CountedBy).HasMaxLength(64);
            e.Property(x => x.Variance).HasPrecision(12, 4);
            e.Property(x => x.Reason).HasMaxLength(500);
        });

        mb.Entity<CashMovement>(e =>
        {
            e.ToTable("cash_movement", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.Kind).HasMaxLength(16).IsRequired();
            e.Property(x => x.Amount).HasPrecision(12, 4);
            e.Property(x => x.Reason).HasMaxLength(500).IsRequired();
            e.Property(x => x.OccurredAt);
            e.Property(x => x.Actor).HasMaxLength(64);
            e.Property(x => x.DestinationReference).HasMaxLength(128);
        });

        mb.Entity<SpectaclePrescriptionVersion>(e =>
        {
            e.ToTable("rx_spectacle_version", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.CustomerId).IsRequired();
            e.Property(x => x.VersionNumber).IsRequired();
            e.HasIndex(x => new { x.CustomerId, x.VersionNumber }).IsUnique();
            e.HasIndex(x => new { x.CustomerId, x.IsCurrent })
                .HasFilter("is_current = true").IsUnique();
            e.Property(x => x.IssuedOn);
            e.Property(x => x.PrescriberId);
            foreach (var name in new[]
                     {
                         nameof(SpectaclePrescriptionVersion.RightSphere),
                         nameof(SpectaclePrescriptionVersion.RightCylinder),
                         nameof(SpectaclePrescriptionVersion.RightAdd),
                         nameof(SpectaclePrescriptionVersion.RightPrism),
                         nameof(SpectaclePrescriptionVersion.RightBase),
                         nameof(SpectaclePrescriptionVersion.RightPd),
                         nameof(SpectaclePrescriptionVersion.LeftSphere),
                         nameof(SpectaclePrescriptionVersion.LeftCylinder),
                         nameof(SpectaclePrescriptionVersion.LeftAdd),
                         nameof(SpectaclePrescriptionVersion.LeftPrism),
                         nameof(SpectaclePrescriptionVersion.LeftBase),
                         nameof(SpectaclePrescriptionVersion.LeftPd),
                     })
            {
                e.Property<decimal?>(name).HasPrecision(8, 4);
            }
            e.Property(x => x.Notes).HasMaxLength(2000);
            e.Property(x => x.Reason).HasMaxLength(500).IsRequired();
            e.Property(x => x.CreatedAt);
            e.Property(x => x.CreatedBy).HasMaxLength(64);
            e.Property(x => x.IsCurrent);
            e.Property(x => x.VerifiedAt);
            e.Property(x => x.VerifiedBy).HasMaxLength(64);
            e.Property(x => x.VerificationNote).HasMaxLength(500);
        });

        mb.Entity<ContactLensPrescriptionVersion>(e =>
        {
            e.ToTable("rx_contact_version", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.CustomerId).IsRequired();
            e.Property(x => x.VersionNumber).IsRequired();
            e.HasIndex(x => new { x.CustomerId, x.VersionNumber }).IsUnique();
            e.HasIndex(x => new { x.CustomerId, x.IsCurrent })
                .HasFilter("is_current = true").IsUnique();
            e.Property(x => x.IssuedOn);
            e.Property(x => x.PrescriberId);
            e.Property(x => x.Brand).HasMaxLength(80);
            foreach (var name in new[]
                     {
                         nameof(ContactLensPrescriptionVersion.BaseCurve),
                         nameof(ContactLensPrescriptionVersion.Diameter),
                         nameof(ContactLensPrescriptionVersion.RightPower),
                         nameof(ContactLensPrescriptionVersion.RightCylinder),
                         nameof(ContactLensPrescriptionVersion.LeftPower),
                         nameof(ContactLensPrescriptionVersion.LeftCylinder),
                     })
            {
                e.Property<decimal?>(name).HasPrecision(8, 4);
            }
            e.Property(x => x.ReplacementSchedule).HasMaxLength(40);
            e.Property(x => x.Notes).HasMaxLength(2000);
            e.Property(x => x.Reason).HasMaxLength(500).IsRequired();
            e.Property(x => x.CreatedAt);
            e.Property(x => x.CreatedBy).HasMaxLength(64);
            e.Property(x => x.IsCurrent);
            e.Property(x => x.VerifiedAt);
            e.Property(x => x.VerifiedBy).HasMaxLength(64);
            e.Property(x => x.VerificationNote).HasMaxLength(500);
        });

        mb.Entity<InsurancePlan>(e =>
        {
            e.ToTable("insurance_plan", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.PlanCode).HasMaxLength(40).IsRequired();
            e.HasIndex(x => new { x.PlanCode, x.Version }).IsUnique();
            e.HasIndex(x => new { x.PlanCode, x.IsCurrent }).HasFilter("is_current = true").IsUnique();
            e.Property(x => x.Version).IsRequired();
            e.Property(x => x.Name).HasMaxLength(120).IsRequired();
            e.Property(x => x.PayerName).HasMaxLength(120).IsRequired();
            e.Property(x => x.IsCurrent);
            e.Property(x => x.IsActive);
            e.Property(x => x.CreatedAt);
            e.Property(x => x.CreatedBy).HasMaxLength(64);
        });

        mb.Entity<CoverageRule>(e =>
        {
            e.ToTable("coverage_rule", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.PlanId).IsRequired();
            e.HasIndex(x => x.PlanId);
            e.Property(x => x.CategoryCode).HasMaxLength(20);
            e.Property(x => x.Sku).HasMaxLength(13);
            e.Property(x => x.CoveragePercent).HasPrecision(7, 4);
            e.Property(x => x.AnnualMaximum).HasPrecision(19, 4);
            e.Property(x => x.RequiresPreauthorization);
        });

        mb.Entity<InsuranceMember>(e =>
        {
            e.ToTable("insurance_member", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.CustomerId).IsRequired();
            e.HasIndex(x => x.CustomerId);
            e.Property(x => x.PlanId).IsRequired();
            e.Property(x => x.MemberNumber).HasMaxLength(60).IsRequired();
            e.Property(x => x.GroupNumber).HasMaxLength(60);
            e.Property(x => x.EffectiveFrom);
            e.Property(x => x.EffectiveTo);
            e.Property(x => x.EligibilityNote).HasMaxLength(500);
            e.Property(x => x.IsActive);
            e.Property(x => x.CreatedAt);
            e.Property(x => x.CreatedBy).HasMaxLength(64);
        });

        mb.Entity<InsuranceClaim>(e =>
        {
            e.ToTable("claim", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.ClaimNumber).HasMaxLength(30).IsRequired();
            e.HasIndex(x => x.ClaimNumber).IsUnique();
            e.HasIndex(x => x.InvoiceTxNumber);
            e.Property(x => x.InvoiceTxNumber).HasMaxLength(10).IsRequired();
            e.Property(x => x.CustomerId).IsRequired();
            e.Property(x => x.PlanId).IsRequired();
            e.Property(x => x.PlanVersion).IsRequired();
            e.Property(x => x.MemberId).IsRequired();
            e.Property(x => x.Status).HasMaxLength(30).IsRequired();
            e.Property(x => x.CreatedAt);
            e.Property(x => x.CreatedBy).HasMaxLength(64);
            foreach (var name in new[]
                     {
                         nameof(InsuranceClaim.TotalBilled), nameof(InsuranceClaim.CoveredAmount),
                         nameof(InsuranceClaim.PatientAmount), nameof(InsuranceClaim.ApprovedAmount),
                         nameof(InsuranceClaim.AdjustmentAmount), nameof(InsuranceClaim.PaidAmount),
                     })
            {
                e.Property<decimal>(name).HasPrecision(19, 4);
            }
            e.Property(x => x.RejectionReason).HasMaxLength(500);
            e.Property(x => x.ResubmissionOf);
        });

        mb.Entity<ClaimLine>(e =>
        {
            e.ToTable("claim_line", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.ClaimId).IsRequired();
            e.HasIndex(x => x.ClaimId);
            e.Property(x => x.LineNumber).IsRequired();
            e.Property(x => x.InvoiceRowNo).IsRequired();
            e.Property(x => x.Sku).HasMaxLength(13).IsRequired();
            e.Property(x => x.BilledAmount).HasPrecision(19, 4);
            e.Property(x => x.Eligible);
            e.Property(x => x.CoveragePercent).HasPrecision(7, 4);
            e.Property(x => x.CoveredAmount).HasPrecision(19, 4);
            e.Property(x => x.PatientAmount).HasPrecision(19, 4);
            e.Property(x => x.IneligibleReason).HasMaxLength(300);
        });

        mb.Entity<ClaimEvent>(e =>
        {
            e.ToTable("claim_event", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.ClaimId).IsRequired();
            e.HasIndex(x => new { x.ClaimId, x.OccurredAt });
            e.Property(x => x.EventType).HasMaxLength(40).IsRequired();
            e.Property(x => x.Status).HasMaxLength(30);
            e.Property(x => x.Amount).HasPrecision(19, 4);
            e.Property(x => x.Reason).HasMaxLength(500);
            e.Property(x => x.Reference).HasMaxLength(100);
            e.Property(x => x.OccurredAt);
            e.Property(x => x.Actor).HasMaxLength(64);
        });

        mb.Entity<ClaimPayment>(e =>
        {
            e.ToTable("claim_payment", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.ClaimId).IsRequired();
            e.HasIndex(x => x.ClaimId);
            e.Property(x => x.Amount).HasPrecision(19, 4);
            e.Property(x => x.Method).HasMaxLength(20).IsRequired();
            e.Property(x => x.Reference).HasMaxLength(100);
            e.Property(x => x.ReceivedAt);
            e.Property(x => x.Actor).HasMaxLength(64);
        });

        mb.Entity<OpticalOrderEvent>(e =>
        {
            e.ToTable("optical_order_event", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.TxNumber).HasMaxLength(10).IsRequired();
            e.HasIndex(x => new { x.TxNumber, x.OccurredAt });
            e.Property(x => x.Status).HasMaxLength(20).IsRequired();
            e.Property(x => x.OccurredAt);
            e.Property(x => x.Actor).HasMaxLength(64);
            e.Property(x => x.Reference).HasMaxLength(80);
            e.Property(x => x.Notes).HasMaxLength(1000);
        });

        mb.Entity<OpticalOrderPrescription>(e =>
        {
            e.ToTable("optical_order_rx", "platform");
            e.HasKey(x => new { x.TxNumber, x.LineNumber });
            e.Property(x => x.TxNumber).HasMaxLength(10).IsRequired();
            e.Property(x => x.LineNumber);
            e.Property(x => x.CustomerId).IsRequired();
            e.Property(x => x.PrescriptionType).HasMaxLength(20).IsRequired();
            e.Property(x => x.PrescriptionVersionId).IsRequired();
        });

        mb.Entity<MedicalNote>(e =>
        {
            e.ToTable("medical_note", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.CustomerId).IsRequired();
            e.HasIndex(x => x.CustomerId);
            e.Property(x => x.Note).HasMaxLength(4000).IsRequired();
            e.Property(x => x.RecordedAt);
            e.Property(x => x.RecordedBy).HasMaxLength(64);
        });

        mb.Entity<PatientAttachment>(e =>
        {
            e.ToTable("patient_attachment", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.CustomerId).IsRequired();
            e.HasIndex(x => x.CustomerId);
            e.Property(x => x.Kind).HasMaxLength(40).IsRequired();
            e.Property(x => x.PrescriptionType).HasMaxLength(20);
            e.Property(x => x.PrescriptionVersionId);
            e.Property(x => x.FileName).HasMaxLength(255).IsRequired();
            e.Property(x => x.ContentType).HasMaxLength(100).IsRequired();
            e.Property(x => x.Size);
            e.Property(x => x.StorageKey).HasMaxLength(255).IsRequired();
            e.Property(x => x.UploadedAt);
            e.Property(x => x.UploadedBy).HasMaxLength(64);
        });

        mb.Entity<CustomerAlias>(e =>
        {
            e.ToTable("customer_alias", "platform");
            e.HasKey(x => x.AliasId);
            e.Property(x => x.AliasId).ValueGeneratedNever();
            e.Property(x => x.CanonicalId).IsRequired();
            e.HasIndex(x => x.CanonicalId);
            e.Property(x => x.MergedAt);
            e.Property(x => x.MergedBy).HasMaxLength(64);
            e.Property(x => x.Reason).HasMaxLength(500).IsRequired();
        });

        mb.Entity<CashSessionTransaction>(e =>
        {
            e.ToTable("cash_session_tx", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.SessionId).IsRequired();
            e.Property(x => x.TxNumber).HasMaxLength(10).IsRequired();
            e.HasIndex(x => x.TxNumber).IsUnique();
            e.Property(x => x.TxType).HasMaxLength(2).IsRequired();
            e.Property(x => x.OccurredAt);
        });

        mb.Entity<CashDailyClose>(e =>
        {
            e.ToTable("cash_daily_close", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.BranchCode).HasMaxLength(3).IsRequired();
            e.Property(x => x.BusinessDate).IsRequired();
            e.HasIndex(x => new { x.BranchCode, x.BusinessDate }).IsUnique();
            e.Property(x => x.Status).HasMaxLength(16).IsRequired();
            e.Property(x => x.FinalizedAt);
            e.Property(x => x.FinalizedBy).HasMaxLength(64);
            e.Property(x => x.Reason).HasMaxLength(500).IsRequired();
            foreach (var property in new[]
                     {
                         nameof(CashDailyClose.TotalSales), nameof(CashDailyClose.TotalRefunds),
                         nameof(CashDailyClose.TaxA), nameof(CashDailyClose.TaxB),
                         nameof(CashDailyClose.CashTenders), nameof(CashDailyClose.CardTenders),
                         nameof(CashDailyClose.OtherTenders), nameof(CashDailyClose.PaidIn),
                         nameof(CashDailyClose.PaidOut), nameof(CashDailyClose.Pickups),
                         nameof(CashDailyClose.Deposits), nameof(CashDailyClose.ExpectedCash),
                         nameof(CashDailyClose.CountedCash), nameof(CashDailyClose.Variance),
                     })
            {
                e.Property<decimal>(property).HasPrecision(19, 4);
            }
            e.Property(x => x.SnapshotJson).HasColumnType("text").IsRequired();
        });

        mb.Entity<SalesRefundLine>(e =>
        {
            e.ToTable("sales_refund_line", "platform");
            e.HasKey(x => new { x.RefundTxNumber, x.RefundRowNo });
            e.Property(x => x.RefundTxNumber).HasMaxLength(10).IsRequired();
            e.Property(x => x.RefundRowNo);
            e.Property(x => x.OriginalTxNumber).HasMaxLength(10).IsRequired();
            e.Property(x => x.OriginalRowNo);
            e.Property(x => x.Quantity).IsRequired();
            e.Property(x => x.Restocked).IsRequired();
            e.Property(x => x.TaxA).HasPrecision(19, 4).IsRequired();
            e.Property(x => x.TaxB).HasPrecision(19, 4).IsRequired();
        });

        mb.Entity<SalesRefundTender>(e =>
        {
            e.ToTable("sales_refund_tender", "platform");
            e.HasKey(x => new { x.RefundTxNumber, x.PaymentLineNo });
            e.Property(x => x.RefundTxNumber).HasMaxLength(10).IsRequired();
            e.Property(x => x.PaymentLineNo);
            e.Property(x => x.OriginalTxNumber).HasMaxLength(10).IsRequired();
            e.Property(x => x.OriginalPaymentLineNo);
            e.Property(x => x.Amount).HasPrecision(19, 4).IsRequired();
            e.Property(x => x.Method).HasMaxLength(1).IsRequired();
        });

        mb.Entity<EntityRetirement>(e =>
        {
            e.ToTable("entity_retirement", "platform");
            e.HasKey(x => new { x.EntityType, x.EntityKey });
            e.Property(x => x.EntityType).HasMaxLength(32);
            e.Property(x => x.EntityKey).HasMaxLength(40);
            e.Property(x => x.Reason).HasMaxLength(500).IsRequired();
            e.Property(x => x.RetiredBy).HasMaxLength(64);
            e.Property(x => x.RetiredAt);
        });

        mb.Entity<IdempotencyRecord>(e =>
        {
            e.ToTable("idempotency_record", "platform");
            e.HasKey(x => x.Key);
            e.Property(x => x.Key).HasMaxLength(128);
            e.Property(x => x.Status).HasMaxLength(16);
            e.Property(x => x.ResultType).HasMaxLength(256);
        });
    }
}

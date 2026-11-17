namespace xOpti.Infrastructure.Persistence.Entities;

public class TxSalePerson
{
    public string TxNumber { get; set; } = string.Empty;
    public double SalesRowNo { get; set; }
    public string StaffCode { get; set; } = string.Empty;
}

public class TxSOrderAdd
{
    public string TxNumber { get; set; } = string.Empty;
    public double LineNumber { get; set; }
    public string? Supplier { get; set; }
    public string? Brand { get; set; }
    public string? Model { get; set; }
}

public class TxSOrderExtra
{
    public string TxNumber { get; set; } = string.Empty;
    public bool? Redo { get; set; }
    public bool? Warranty { get; set; }
    public bool? Mail { get; set; }
    public bool? Msd { get; set; }
    public int? Remarks { get; set; }
}

/// <summary>App-owned link from a refund line to the original invoice line.</summary>
public class SalesRefundLine
{
    public string RefundTxNumber { get; set; } = string.Empty;

    public double RefundRowNo { get; set; }

    public string OriginalTxNumber { get; set; } = string.Empty;

    public double OriginalRowNo { get; set; }

    public int Quantity { get; set; }

    public bool Restocked { get; set; }

    public decimal TaxA { get; set; }

    public decimal TaxB { get; set; }
}

/// <summary>App-owned link from a refund tender to the original payment line.</summary>
public class SalesRefundTender
{
    public string RefundTxNumber { get; set; } = string.Empty;

    public double PaymentLineNo { get; set; }

    public string OriginalTxNumber { get; set; } = string.Empty;

    public double OriginalPaymentLineNo { get; set; }

    public decimal Amount { get; set; }

    public string Method { get; set; } = string.Empty;
}

public class TxSOrderCont
{
    public string TxNumber { get; set; } = string.Empty;
    public double LineNumber { get; set; }
    public DateTimeOffset? IssuedOn { get; set; }
    public int IssuedBy { get; set; }
    public double RightSphere { get; set; }
    public double RightCylinder { get; set; }
    public int RightAxis { get; set; }
    public double RightKReadingV { get; set; }
    public double RightKReadingH { get; set; }
    public double RightPalp { get; set; }
    public double RightCorn { get; set; }
    public double RightPupil { get; set; }
    public double LeftSphere { get; set; }
    public double LeftCylinder { get; set; }
    public int LeftAxis { get; set; }
    public double LeftKReadingV { get; set; }
    public double LeftKReadingH { get; set; }
    public double LeftPalp { get; set; }
    public double LeftCorn { get; set; }
    public double LeftPupil { get; set; }
    public string? History { get; set; }
    public string? Medical { get; set; }
    public string? Allergy { get; set; }
    public string? Reason { get; set; }
    public string? Evaluation { get; set; }
    public string? Test { get; set; }
    public string? SpecialInstruction { get; set; }
}

public class TxSOrderFrame
{
    public string TxNumber { get; set; } = string.Empty;
    public double LineNumber { get; set; }
    public bool? Supply { get; set; }
    public bool? Enclosed { get; set; }
    public bool? Follow { get; set; }
    public bool? Lenses { get; set; }
    public string? Mode { get; set; }
    public string? Color { get; set; }
    public string? EyeSize { get; set; }
    public int Bridge { get; set; }
    public int Temple { get; set; }
    public string? R1 { get; set; }
    public string? R2 { get; set; }
    public string? R3 { get; set; }
    public string? A { get; set; }
    public string? B { get; set; }
    public string? SpecialInstruction { get; set; }
}

public class TxSOrderLens
{
    public string TxNumber { get; set; } = string.Empty;
    public double LineNumber { get; set; }
    public DateTimeOffset? IssuedOn { get; set; }
    public int IssuedBy { get; set; }
    public double RightSphere { get; set; }
    public double RightCylinder { get; set; }
    public int RightAxis { get; set; }
    public double RightPdDist { get; set; }
    public double RightPdNear { get; set; }
    public double RightPrism { get; set; }
    public double RightAdd { get; set; }
    public double RightPupil { get; set; }
    public string? RightStyle { get; set; }
    public double RightSegHt { get; set; }
    public double RightOc { get; set; }
    public double RightBase { get; set; }
    public double RightVd { get; set; }
    public double LeftSphere { get; set; }
    public double LeftCylinder { get; set; }
    public int LeftAxis { get; set; }
    public double LeftPdDist { get; set; }
    public double LeftPdNear { get; set; }
    public double LeftPrism { get; set; }
    public double LeftAdd { get; set; }
    public double LeftPupil { get; set; }
    public string? LeftStyle { get; set; }
    public double LeftSegHt { get; set; }
    public double LeftOc { get; set; }
    public double LeftBase { get; set; }
    public double LeftVd { get; set; }
    public string? Type { get; set; }
    public string? Hardening { get; set; }
    public string? Material { get; set; }
    public string? Coating { get; set; }
    public string? Tint { get; set; }
    public string? Others { get; set; }
    public bool? HardCoat { get; set; }
    public bool? ArCoat { get; set; }
    public bool? Uv { get; set; }
}

public class OpticalOrderEvent
{
    public long Id { get; set; }
    public string TxNumber { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTimeOffset OccurredAt { get; set; }
    public string? Actor { get; set; }
    public string? Reference { get; set; }
    public string? Notes { get; set; }
}

public class OpticalOrderPrescription
{
    public string TxNumber { get; set; } = string.Empty;
    public double LineNumber { get; set; }
    public int CustomerId { get; set; }
    public string PrescriptionType { get; set; } = string.Empty;
    public long PrescriptionVersionId { get; set; }
}

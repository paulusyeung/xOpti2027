VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Begin VB.Form frmUtilCheckTable 
   Caption         =   "Check Table Integrity"
   ClientHeight    =   5085
   ClientLeft      =   2625
   ClientTop       =   2625
   ClientWidth     =   9105
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5085
   ScaleWidth      =   9105
   Begin Threed.SSFrame SSFrame1 
      Height          =   2775
      Left            =   3480
      TabIndex        =   0
      Top             =   600
      Width           =   4815
      _ExtentX        =   8493
      _ExtentY        =   4895
      _Version        =   131074
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Select Which Table to Check"
      Begin VB.CheckBox chkPayment 
         Caption         =   "Payment"
         Height          =   255
         Left            =   3360
         TabIndex        =   9
         Tag             =   "2"
         Top             =   660
         Width           =   1095
      End
      Begin VB.CheckBox chkBranch 
         Caption         =   "Branch"
         Height          =   255
         Left            =   3360
         TabIndex        =   8
         Tag             =   "3"
         Top             =   360
         Width           =   975
      End
      Begin VB.CheckBox chkStaff 
         Caption         =   "Staff"
         Height          =   255
         Left            =   1920
         TabIndex        =   7
         Tag             =   "2"
         Top             =   960
         Width           =   855
      End
      Begin VB.CheckBox chkSupplier 
         Caption         =   "Supplier"
         Height          =   255
         Left            =   1920
         TabIndex        =   6
         Tag             =   "3"
         Top             =   660
         Width           =   975
      End
      Begin VB.CheckBox chkCustomer 
         Caption         =   "Customer"
         Height          =   255
         Left            =   1920
         TabIndex        =   5
         Tag             =   "5"
         Top             =   360
         Width           =   1095
      End
      Begin VB.CheckBox chkInventory 
         Caption         =   "Inventory"
         ForeColor       =   &H00000000&
         Height          =   255
         Left            =   240
         TabIndex        =   4
         Tag             =   "5"
         Top             =   1260
         Width           =   1095
      End
      Begin VB.CheckBox chkCategory 
         Caption         =   "Category"
         Height          =   255
         Left            =   240
         TabIndex        =   3
         Tag             =   "2"
         Top             =   960
         Width           =   1095
      End
      Begin VB.CheckBox chkClass 
         Caption         =   "Class"
         Height          =   255
         Left            =   240
         TabIndex        =   2
         Tag             =   "2"
         Top             =   660
         Width           =   1095
      End
      Begin VB.CheckBox chkDept 
         Caption         =   "Department"
         Height          =   255
         Left            =   240
         TabIndex        =   1
         Tag             =   "2"
         Top             =   360
         Width           =   1215
      End
      Begin Threed.SSCommand cmdCancel 
         Height          =   375
         Left            =   3600
         TabIndex        =   12
         Top             =   2220
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   661
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "&Cancel"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdOK 
         Height          =   375
         Left            =   2400
         TabIndex        =   11
         Top             =   2220
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   661
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "&OK"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdReset 
         Height          =   375
         Left            =   1200
         TabIndex        =   10
         Top             =   2220
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   661
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "&Reset"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin Threed.SSFrame fraProgress 
      Height          =   1515
      Left            =   840
      TabIndex        =   13
      Top             =   3480
      Visible         =   0   'False
      Width           =   7455
      _ExtentX        =   13150
      _ExtentY        =   2672
      _Version        =   131074
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Progress"
      Begin MSComCtlLib.ProgressBar pbrCurrentTable 
         Height          =   315
         Left            =   2880
         TabIndex        =   23
         Top             =   1140
         Width           =   4335
         _ExtentX        =   7646
         _ExtentY        =   556
         _Version        =   327682
         BorderStyle     =   1
         Appearance      =   1
      End
      Begin MSComCtlLib.ProgressBar pbrOverall 
         Height          =   315
         Left            =   2880
         TabIndex        =   22
         Top             =   540
         Width           =   4335
         _ExtentX        =   7646
         _ExtentY        =   556
         _Version        =   327682
         BorderStyle     =   1
         Appearance      =   1
      End
      Begin VB.TextBox txtOperation 
         Height          =   285
         Left            =   120
         Locked          =   -1  'True
         TabIndex        =   17
         TabStop         =   0   'False
         Top             =   540
         Width           =   1935
      End
      Begin VB.TextBox txtTableName 
         Height          =   285
         Left            =   120
         Locked          =   -1  'True
         TabIndex        =   16
         TabStop         =   0   'False
         Top             =   1140
         Width           =   1935
      End
      Begin VB.Label Label6 
         Caption         =   "Overall"
         Height          =   255
         Left            =   2880
         TabIndex        =   21
         Top             =   300
         Width           =   615
      End
      Begin VB.Label Label5 
         Caption         =   "Current Table"
         Height          =   255
         Left            =   2880
         TabIndex        =   20
         Top             =   900
         Width           =   1095
      End
      Begin VB.Label Label1 
         Caption         =   "Table Name"
         Height          =   255
         Left            =   120
         TabIndex        =   14
         Top             =   900
         Width           =   975
      End
      Begin VB.Label Label4 
         Caption         =   "Operation"
         Height          =   255
         Left            =   120
         TabIndex        =   15
         Top             =   300
         Width           =   735
      End
   End
   Begin Threed.SSPanel SSPanel1 
      Height          =   2835
      Left            =   840
      TabIndex        =   18
      Top             =   600
      Width           =   2535
      _ExtentX        =   4471
      _ExtentY        =   5001
      _Version        =   131074
      ForeColor       =   0
      BackColor       =   255
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Warning"
      BevelOuter      =   1
      BevelInner      =   1
      Alignment       =   6
      Begin VB.TextBox Text5 
         Appearance      =   0  'Flat
         BackColor       =   &H000000FF&
         BorderStyle     =   0  'None
         Height          =   2175
         Left            =   240
         Locked          =   -1  'True
         MultiLine       =   -1  'True
         TabIndex        =   19
         TabStop         =   0   'False
         Text            =   "frmUtilCheckTable.frx":0000
         Top             =   360
         Width           =   2055
      End
   End
End
Attribute VB_Name = "frmUtilCheckTable"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim intOverallPasses As Integer
Dim sngOverallFinished As Single
Private Sub cmdCancel_Click()
    Unload Me
End Sub


Private Sub cmdOK_Click()
    
    ' Atleast one of the check boxes was selected,
    '  otherwise terminate OK.
    GetOverallPasses
    If intOverallPasses = 0 Then
        MsgBox "You haven't select any Table." & Chr$(13) & _
               "Please make your selection."
        Exit Sub
    End If

    ' Disable command buttoms
    cmdReset.Enabled = False
    cmdOK.Enabled = False
    cmdCancel.Enabled = False
    ' Show progress panel
    fraProgress.Visible = True
    fraProgress.Refresh
    '
    Screen.MousePointer = vbHourglass
    GoCheckTable
    Screen.MousePointer = vbDefault
    '
    MsgBox "Done!" & Chr$(13) & _
           "Thanks for waiting."
    ' Hide progress panel
    fraProgress.Visible = False
    ' Enable command buttons
    cmdReset.Enabled = True
    cmdOK.Enabled = True
    cmdCancel.Enabled = True
    ' Reset selected items
    Call cmdReset_Click

End Sub

Private Sub cmdReset_Click()
    Dim i As Integer
    For i = 0 To (Me.Count - 1)
        If TypeOf Me.Controls(i) Is CheckBox Then
            Me.Controls(i).Value = False
        End If
    Next i
End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
End Sub







Private Sub GoCheckTable()
    sngOverallFinished = 0
    If chkDept.Value Then GoCheck_Dept
    If chkClass.Value Then GoCheck_Class
    If chkCategory.Value Then GoCheck_Category
    If chkInventory.Value Then GoCheck_Inventory
    If chkCustomer.Value Then GoCheck_Customer
    If chkSupplier.Value Then GoCheck_Supplier
    If chkStaff.Value Then GoCheck_Staff
    If chkBranch.Value Then GoCheck_Branch
    If chkPayment.Value Then GoCheck_Payment
End Sub

Private Sub GoCheck_Dept()

End Sub

Private Sub GoCheck_Class()

End Sub

Private Sub GoCheck_Category()

End Sub

'------------------------------
' Procedure:  GoCheck_Customer
' Purpose:    TBD
' Params:
' Returns:    N/A
'------------------------------
Private Sub GoCheck_Customer()
    Dim myDB As Database
    Dim Cus, CusAccount, CusMedical, CusPresLens, CusPresCont As Recordset
    Dim strTarget As String
    Dim sngTimePerLoop As Single
    Dim sngMicroTime As Single
    Dim intTotalUnits As Integer
    Dim intPercentPosition As Integer
    
    intTotalUnits = (chkCustomer.Tag - 1) * 2
    sngTimePerLoop = ((chkCustomer.Tag / intOverallPasses * 100) / intTotalUnits)
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set Cus = myDB.OpenRecordset("Customer", dbOpenDynaset, dbDenyWrite)    ' Open table
    Set CusAccount = myDB.OpenRecordset("CustomerAccounts", dbOpenDynaset, dbDenyWrite)
    Set CusMedical = myDB.OpenRecordset("CustomerMedical", dbOpenDynaset, dbDenyWrite)
    Set CusPresLens = myDB.OpenRecordset("CustomerPresLens", dbOpenDynaset, dbDenyWrite)
    Set CusPresCont = myDB.OpenRecordset("CustomerPresContact", dbOpenDynaset, dbDenyWrite)
    
    ' Remove Orphan Records: CusAccount
    txtOperation.Text = "Remove Orphan"
    txtOperation.Refresh
    If CusAccount.RecordCount > 0 Then
        txtTableName = "CustomerAccount"
        txtTableName.Refresh
        CusAccount.MoveLast
        sngMicroTime = sngTimePerLoop / CusAccount.RecordCount
        CusAccount.MoveFirst
        Do Until CusAccount.EOF
            strTarget = "ID = " & CusAccount!CustomerID
            Cus.FindFirst strTarget
            If Cus.NoMatch Then CusAccount.Delete
            intPercentPosition = ofx_CInt(CusAccount.PercentPosition)
            Call ShowProgress(sngMicroTime, intPercentPosition)
            CusAccount.MoveNext
        Loop
    End If
    ' Remove Orphan Records: CusMedical
    If CusMedical.RecordCount > 0 Then
        txtTableName = "CustomerMedical"
        txtTableName.Refresh
        CusMedical.MoveLast
        sngMicroTime = sngTimePerLoop / CusMedical.RecordCount
        CusMedical.MoveFirst
        Do Until CusMedical.EOF
            strTarget = "ID = " & CusMedical!CustomerID
            Cus.FindFirst strTarget
            If Cus.NoMatch Then CusMedical.Delete
            intPercentPosition = ofx_CInt(CusMedical.PercentPosition)
            Call ShowProgress(sngMicroTime, intPercentPosition)
            CusMedical.MoveNext
        Loop
    End If
    ' Remove Orphan Records: CusPresLens
    If CusPresLens.RecordCount > 0 Then
        txtTableName = "CustomerPresLens"
        txtTableName.Refresh
        CusPresLens.MoveLast
        sngMicroTime = sngTimePerLoop / CusPresLens.RecordCount
        CusPresLens.MoveFirst
        Do Until CusPresLens.EOF
            strTarget = "ID = " & CusPresLens!CustomerID
            Cus.FindFirst strTarget
            If Cus.NoMatch Then CusPresLens.Delete
            intPercentPosition = ofx_CInt(CusPresLens.PercentPosition)
            Call ShowProgress(sngMicroTime, intPercentPosition)
            CusPresLens.MoveNext
        Loop
    End If
    ' Remove Orphan Records: CusPresCont
    If CusMedical.RecordCount > 0 Then
        txtTableName = "CustomerPresContact"
        txtTableName.Refresh
        CusPresCont.MoveLast
        sngMicroTime = sngTimePerLoop / CusPresCont.RecordCount
        CusPresCont.MoveFirst
        Do Until CusPresCont.EOF
            strTarget = "ID = " & CusPresCont!CustomerID
            Cus.FindFirst strTarget
            If Cus.NoMatch Then CusPresCont.Delete
            intPercentPosition = ofx_CInt(CusPresCont.PercentPosition)
            Call ShowProgress(sngMicroTime, intPercentPosition)
            CusPresCont.MoveNext
        Loop
    End If
    '
    ' Create Child Records: CusAccount
    txtOperation.Text = "Missing Child"
    txtOperation.Refresh
    Cus.MoveFirst
    Cus.MoveLast
    sngMicroTime = sngTimePerLoop / Cus.RecordCount
    '
    txtTableName = "CustomerAccount"
    txtTableName.Refresh
    Cus.MoveFirst
    Do Until Cus.EOF
        strTarget = "CustomerID = " & Cus!ID
        CusAccount.FindFirst strTarget
        If CusAccount.NoMatch Then
            CusAccount.AddNew
            CusAccount!CustomerID = Cus!ID
            CusAccount!JointDate = Date
            CusAccount.Update
        End If
        intPercentPosition = ofx_CInt(Cus.PercentPosition)
        Call ShowProgress(sngMicroTime, intPercentPosition)
        Cus.MoveNext
    Loop
    ' Create Child Records: CusPresLens
    txtTableName = "CustomerPresLens"
    txtTableName.Refresh
    Cus.MoveFirst
    Do Until Cus.EOF
        strTarget = "CustomerID = " & Cus!ID
        CusPresLens.FindFirst strTarget
        If CusPresLens.NoMatch Then
            CusPresLens.AddNew
            CusPresLens!CustomerID = Cus!ID
            CusPresLens.Update
        End If
        intPercentPosition = ofx_CInt(Cus.PercentPosition)
        Call ShowProgress(sngMicroTime, intPercentPosition)
        Cus.MoveNext
    Loop
    ' Create Child Records: CusPresContact
    txtTableName = "CustomerPresContact"
    txtTableName.Refresh
    Cus.MoveFirst
    Do Until Cus.EOF
        strTarget = "CustomerID = " & Cus!ID
        CusPresCont.FindFirst strTarget
        If CusPresCont.NoMatch Then
            CusPresCont.AddNew
            CusPresCont!CustomerID = Cus!ID
            CusPresCont.Update
        End If
        intPercentPosition = ofx_CInt(Cus.PercentPosition)
        Call ShowProgress(sngMicroTime, intPercentPosition)
        Cus.MoveNext
    Loop
    ' Create Child Records: CusMedical
    txtTableName = "CustomerMedical"
    txtTableName.Refresh
    Cus.MoveFirst
    Do Until Cus.EOF
        strTarget = "CustomerID = " & Cus!ID
        CusMedical.FindFirst strTarget
        If CusMedical.NoMatch Then
            CusMedical.AddNew
            CusMedical!CustomerID = Cus!ID
            CusMedical.Update
        End If
        intPercentPosition = ofx_CInt(Cus.PercentPosition)
        Call ShowProgress(sngMicroTime, intPercentPosition)
        Cus.MoveNext
    Loop
    
    CusPresCont.Close
    CusPresLens.Close
    CusMedical.Close
    CusAccount.Close
    Cus.Close
    myDB.Close

End Sub

'------------------------------
' Procedure:  GoCheck_Supplier
' Purpose:    TBD
' Params:
' Returns:    N/A
'------------------------------
Private Sub GoCheck_Supplier()

    ' TODO: Your code here

End Sub

Private Sub GoCheck_Staff()

End Sub

Private Sub GoCheck_Branch()

End Sub

Private Sub GoCheck_Payment()

End Sub

Private Sub GoCheck_Inventory()
    Dim myDB As Database
    Dim UtilCheckLog As Recordset
    Dim Invt, InvtLotRecord, InvtSummary, InvtRetailPrice As Recordset
    Dim strTarget, strControlNumber As String
    Dim sngTimePerLoop As Single
    Dim sngMicroTime As Single
    Dim intTotalUnits As Integer
    Dim intPercentPosition As Integer
    Dim dtmVDate As Date
    
    intTotalUnits = (chkInventory.Tag - 1) * 2
    sngTimePerLoop = ((chkInventory.Tag / intOverallPasses * 100) / intTotalUnits)
    dtmVDate = "01/01/97"
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set UtilCheckLog = myDB.OpenRecordset("UtilCheckLog", dbOpenDynaset, dbDenyWrite)   ' Open table
    Set Invt = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbDenyWrite)    ' Open table
    Set InvtLotRecord = myDB.OpenRecordset("InvtLotRecord", dbOpenDynaset, dbDenyWrite)
    Set InvtSummary = myDB.OpenRecordset("InvtSummary", dbOpenDynaset, dbDenyWrite)
    Set InvtRetailPrice = myDB.OpenRecordset("RetailPrice", dbOpenDynaset, dbDenyWrite)
    
    ' Remove Orphan Records: InvtLotRecord
    txtOperation.Text = "Remove Orphan"
    txtOperation.Refresh
    If InvtLotRecord.RecordCount > 0 Then
        txtTableName = "InvtLotRecord"
        txtTableName.Refresh
        InvtLotRecord.MoveLast
        sngMicroTime = sngTimePerLoop / InvtLotRecord.RecordCount
        InvtLotRecord.MoveFirst
        Do Until InvtLotRecord.EOF
            strTarget = "SKU = '" & InvtLotRecord!SKU & "'"
            Invt.FindFirst strTarget
            If Invt.NoMatch Then
                ' Write Log
                With UtilCheckLog
                    .AddNew
                    !DateOfLog = Now
                    !ParentTable = "Inventory"
                    !ParentKey = InvtLotRecord!SKU
                    !Remarks = "Removed from InvtLotRecord"
                    .Update
                End With
                ' Remove record
                InvtLotRecord.Delete
            Else
                intPercentPosition = ofx_CInt(InvtLotRecord.PercentPosition)
                Call ShowProgress(sngMicroTime, intPercentPosition)
            End If
            InvtLotRecord.MoveNext
        Loop
    End If
    ' Remove Orphan Records: InvtSummary
    If InvtSummary.RecordCount > 0 Then
        txtTableName = "InvtSummary"
        txtTableName.Refresh
        InvtSummary.MoveLast
        sngMicroTime = sngTimePerLoop / InvtSummary.RecordCount
        InvtSummary.MoveFirst
        Do Until InvtSummary.EOF
            strTarget = "SKU = '" & InvtSummary!SKU & "'"
            Invt.FindFirst strTarget
            If Invt.NoMatch Then
                ' Write Log
                With UtilCheckLog
                    .AddNew
                    !DateOfLog = Now
                    !ParentTable = "Inventory"
                    !ParentKey = InvtSummary!SKU
                    !Remarks = "Removed from InvtSummary"
                    .Update
                End With
                ' Remove record
                InvtSummary.Delete
            Else
                intPercentPosition = ofx_CInt(InvtSummary.PercentPosition)
                Call ShowProgress(sngMicroTime, intPercentPosition)
            End If
            InvtSummary.MoveNext
        Loop
    End If
    ' Remove Orphan Records: InvtRetailPrice
    If InvtRetailPrice.RecordCount > 0 Then
        txtTableName = "RetailPrice"
        txtTableName.Refresh
        InvtRetailPrice.MoveLast
        sngMicroTime = sngTimePerLoop / InvtRetailPrice.RecordCount
        InvtRetailPrice.MoveFirst
        Do Until InvtRetailPrice.EOF
            strTarget = "SKU = '" & InvtRetailPrice!SKU & "'"
            Invt.FindFirst strTarget
            If Invt.NoMatch Then
                ' Write Log
                With UtilCheckLog
                    .AddNew
                    !DateOfLog = Now
                    !ParentTable = "Inventory"
                    !ParentKey = InvtRetailPrice!SKU
                    !Remarks = "Removed from RetailPrice"
                    .Update
                End With
                ' Remove record
                InvtRetailPrice.Delete
            Else
                intPercentPosition = ofx_CInt(InvtRetailPrice.PercentPosition)
                Call ShowProgress(sngMicroTime, intPercentPosition)
            End If
            InvtRetailPrice.MoveNext
        Loop
    End If
    '
    ' Create Child Records: InvtLotRecord
    txtOperation.Text = "Missing Child"
    txtOperation.Refresh
    Invt.MoveFirst
    Invt.MoveLast
    sngMicroTime = sngTimePerLoop / Invt.RecordCount
    '
    txtTableName = "InvtLotRecord"
    txtTableName.Refresh
    Invt.MoveFirst
    Do Until Invt.EOF
        strTarget = "SKU = '" & Invt!SKU & "'"
        With InvtLotRecord
            .FindFirst strTarget
            If .NoMatch Then
                ' Write Log
                UtilCheckLog.AddNew
                UtilCheckLog!DateOfLog = Now
                UtilCheckLog!ParentTable = "Inventory"
                UtilCheckLog!ParentKey = Invt!SKU
                UtilCheckLog!Remarks = "Created to InvtLotRecord"
                UtilCheckLog.Update
                ' Create record
                strControlNumber = GetNextControlNumber
                .AddNew
                !SKU = Invt!SKU
                !LotNo = strControlNumber
                !DateReceived = dtmVDate
                !SupplierCode = "ZZ"
                !QtyPurchased = Invt!QtyTotalOnhand
                !QtyOnHand = Invt!QtyTotalOnhand
                !UnitAmountPurchased = Invt!AverageCost
                !TotalAmountPurchased = Invt!AverageCost * Invt!QtyTotalOnhand
                .Update
            End If
        End With
        intPercentPosition = ofx_CInt(Invt.PercentPosition)
        Call ShowProgress(sngMicroTime, intPercentPosition)
        Invt.MoveNext
    Loop
    ' Create Child Records: InvtRetailPrice
    txtTableName = "RetailPrice"
    txtTableName.Refresh
    Invt.MoveFirst
    Do Until Invt.EOF
        strTarget = "SKU = '" & Invt!SKU & "'"
        With InvtRetailPrice
            .FindFirst strTarget
            If .NoMatch Then
                ' Write Log
                UtilCheckLog.AddNew
                UtilCheckLog!DateOfLog = Now
                UtilCheckLog!ParentTable = "Inventory"
                UtilCheckLog!ParentKey = Invt!SKU
                UtilCheckLog!Remarks = "Created to RetailPrice"
                UtilCheckLog.Update
                ' Create record
                .AddNew
                !SKU = Invt!SKU
                .Update
            End If
        End With
        intPercentPosition = ofx_CInt(Invt.PercentPosition)
        Call ShowProgress(sngMicroTime, intPercentPosition)
        Invt.MoveNext
    Loop
    ' Create Child Records: InvtSummary
    txtTableName = "InvtSummary"
    txtTableName.Refresh
    Invt.MoveFirst
    Do Until Invt.EOF
        strTarget = "SKU = '" & Invt!SKU & "' And "
        strTarget = strTarget & "Year = " & Year(dtmVDate) & " And "
        strTarget = strTarget & "Month = " & Month(dtmVDate)
        With InvtSummary
            .FindFirst strTarget
            If .NoMatch Then
                ' Write Log
                UtilCheckLog.AddNew
                UtilCheckLog!DateOfLog = Now
                UtilCheckLog!ParentTable = "Inventory"
                UtilCheckLog!ParentKey = Invt!SKU
                UtilCheckLog!Remarks = "Created to InvtSummary"
                UtilCheckLog.Update
                ' Create record
                .AddNew
                !SKU = Invt!SKU
                !Year = Year(dtmVDate)
                !Month = Month(dtmVDate)
                !FirstDateOfMonth = DateSerial(Year(dtmVDate), Month(dtmVDate), 1)
                !qtyCD = Invt!QtyTotalOnhand
                !AmtCD = Invt!QtyTotalOnhand * Invt!AverageCost
                !QtyPurchased = Invt!QtyTotalOnhand
                !AmtPurchased = Invt!QtyTotalOnhand * Invt!AverageCost
                .Update
            End If
        End With
        intPercentPosition = ofx_CInt(Invt.PercentPosition)
        Call ShowProgress(sngMicroTime, intPercentPosition)
        Invt.MoveNext
    Loop
    
    InvtRetailPrice.Close
    InvtSummary.Close
    InvtLotRecord.Close
    Invt.Close
    UtilCheckLog.Close
    myDB.Close
End Sub




Private Sub GetOverallPasses()

    Dim i As Integer
    intOverallPasses = 0
    For i = 0 To (Me.Count - 1)
        If TypeOf Me.Controls(i) Is CheckBox Then
            If Me.Controls(i).Value Then
                intOverallPasses = intOverallPasses + ofx_CInt(Me.Controls(i).Tag)
            End If
        End If
    Next i

End Sub

Private Sub ShowProgress(myUnitTime As Single, myPercentPosition As Integer)

    sngOverallFinished = sngOverallFinished + myUnitTime
    pbrCurrentTable.Value = myPercentPosition
    pbrOverall.Value = ofx_CInt(sngOverallFinished)
End Sub

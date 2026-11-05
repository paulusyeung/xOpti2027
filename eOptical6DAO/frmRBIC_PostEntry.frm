VERSION 5.00
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#1.0#0"; "THREED32.OCX"
Begin VB.Form frmRBIC_PostEntry 
   Caption         =   "ReBuild Cost - Post WorkBook"
   ClientHeight    =   1980
   ClientLeft      =   2115
   ClientTop       =   3120
   ClientWidth     =   8085
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1980
   ScaleWidth      =   8085
   Begin VB.Data dtcInvtSummary 
      Caption         =   "InvtSummary"
      Connect         =   "Access"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   3360
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT * FROM InvtSummary WHERE InvtSummary.FirstDateOfMonth=#1/1/97#"
      Top             =   1620
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcTxDetails 
      Caption         =   "TxDetails"
      Connect         =   "Access"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   1800
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT * FROM TxDetails WHERE TxDetails.DateOfEntry >= #97/6/1#"
      Top             =   1620
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcInventory 
      Caption         =   "Inventory Query"
      Connect         =   "Access"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   1800
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT * FROM [Inventory Query] ORDER BY Inventory.SKU"
      Top             =   1380
      Visible         =   0   'False
      Width           =   1140
   End
   Begin Threed.SSFrame fraLevel 
      Height          =   1455
      Left            =   240
      TabIndex        =   0
      Top             =   240
      Width           =   2775
      _Version        =   65536
      _ExtentX        =   4895
      _ExtentY        =   2566
      _StockProps     =   14
      Caption         =   "Select Level"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Begin VB.Data dtcRebuildCost 
         Caption         =   "ReBuildCost"
         Connect         =   "Access"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   315
         Left            =   1560
         Options         =   0
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "ReBuildCost"
         Top             =   900
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.OptionButton optLevelThree 
         Caption         =   "Level Three"
         Height          =   315
         Left            =   120
         TabIndex        =   3
         Top             =   1020
         Width           =   1215
      End
      Begin VB.OptionButton optLevelTwo 
         Caption         =   "Level Two"
         Height          =   315
         Left            =   120
         TabIndex        =   2
         Top             =   660
         Width           =   1215
      End
      Begin VB.OptionButton optLevelOne 
         Caption         =   "Level One"
         Height          =   255
         Left            =   120
         TabIndex        =   1
         Top             =   300
         Width           =   1215
      End
      Begin Threed.SSCommand cmdStart 
         Height          =   375
         Left            =   1800
         TabIndex        =   4
         Top             =   240
         Width           =   855
         _Version        =   65536
         _ExtentX        =   1508
         _ExtentY        =   661
         _StockProps     =   78
         Caption         =   "Start"
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin Threed.SSFrame fraInfo 
      Height          =   1455
      Left            =   3120
      TabIndex        =   5
      Top             =   240
      Width           =   4695
      _Version        =   65536
      _ExtentX        =   8281
      _ExtentY        =   2566
      _StockProps     =   14
      Caption         =   "Current Process Information"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Enabled         =   0   'False
      Begin Threed.SSFrame fraTime 
         Height          =   1035
         Left            =   120
         TabIndex        =   6
         Top             =   300
         Width           =   1935
         _Version        =   65536
         _ExtentX        =   3413
         _ExtentY        =   1826
         _StockProps     =   14
         Caption         =   "Time"
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Begin MSMask.MaskEdBox mskEstimateTime 
            Height          =   255
            Left            =   840
            TabIndex        =   13
            Top             =   660
            Width           =   975
            _ExtentX        =   1720
            _ExtentY        =   450
            _Version        =   327680
            Format          =   "hh:mm AM/PM"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskStartTime 
            Height          =   255
            Left            =   840
            TabIndex        =   12
            Top             =   300
            Width           =   975
            _ExtentX        =   1720
            _ExtentY        =   450
            _Version        =   327680
            Format          =   "hh:mm AM/PM"
            PromptChar      =   "_"
         End
         Begin VB.Label Label2 
            Caption         =   "Estimate"
            Height          =   255
            Left            =   120
            TabIndex        =   9
            Top             =   660
            Width           =   615
         End
         Begin VB.Label Label1 
            Caption         =   "Start"
            Height          =   255
            Left            =   120
            TabIndex        =   8
            Top             =   300
            Width           =   495
         End
      End
      Begin Threed.SSFrame fraCurrentResult 
         Height          =   1035
         Left            =   2280
         TabIndex        =   7
         Top             =   300
         Width           =   2295
         _Version        =   65536
         _ExtentX        =   4048
         _ExtentY        =   1826
         _StockProps     =   14
         Caption         =   "Current Result"
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Begin VB.TextBox txtErrorLog 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   1080
            MultiLine       =   -1  'True
            TabIndex        =   15
            Top             =   660
            Width           =   1095
         End
         Begin VB.TextBox txtRecordLog 
            Height          =   315
            Left            =   1080
            TabIndex        =   14
            Top             =   300
            Width           =   1095
         End
         Begin VB.Label Label4 
            Caption         =   "Error Log"
            Height          =   255
            Left            =   120
            TabIndex        =   11
            Top             =   660
            Width           =   735
         End
         Begin VB.Label Label3 
            Caption         =   "Record Log"
            Height          =   255
            Left            =   120
            TabIndex        =   10
            Top             =   300
            Width           =   855
         End
      End
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   195
      Left            =   7560
      TabIndex        =   16
      Top             =   1740
      Width           =   255
      _Version        =   65536
      _ExtentX        =   450
      _ExtentY        =   344
      _StockProps     =   78
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmRBIC_PostEntry"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdStart_Click()
    Call StartPoint
End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)

End Sub



Private Sub StartPoint()
    If optLevelOne.Value Then Call CopyCostToLSP
    If optLevelTwo.Value Then Call PostToInventory
    If optLevelThree.Value Then Call PostToTxDetails
End Sub

' Copy the AverageCost to LeastSellingPrice
Private Sub CopyCostToLSP()
    Dim PauseTime As Integer
    Dim Start As Long
    Dim TotalRecord As Long
    
    Screen.MousePointer = vbHourglass
    ' Set variables
    PauseTime = 0                       ' Set duration.
    With dtcRebuildCost.Recordset       ' Set total record.
        .MoveFirst
        .MoveLast
        TotalRecord = .RecordCount
    End With
    
    ' Display process info
    fraInfo.Enabled = True
    mskStartTime = Time
    mskEstimateTime = TimeSerial( _
                      (Hour(Time) + TotalRecord * PauseTime / 60 / 60), _
                      Minute(Time), Second(Time))
    txtErrorLog.Text = "0"
    fraInfo.Refresh
    
    With dtcInventory.Recordset
        .MoveFirst
        Do
            txtRecordLog.Text = !SKU
            fraInfo.Refresh
            .Edit
            !LeastSellingPrice = !AverageCost
            .Update
            .MoveNext
            Start = Timer                       ' Set start time.
            Do While Timer < Start + PauseTime  ' Sleep
                DoEvents                        ' Yield to other processes.
            Loop
        Loop Until .EOF
    End With
    Screen.MousePointer = vbDefault
    MsgBox "Level One Finished"
End Sub

Private Sub ShowTime()
    Dim TotalRecord As Long
    
    dtcRebuildCost.Recordset.MoveFirst
    dtcRebuildCost.Recordset.MoveLast
    TotalRecord = dtcRebuildCost.Recordset.RecordCount
    
    mskStartTime = Time
    mskEstimateTime = Time + (TotalRecord * 15 / 60 / 60)
End Sub

Private Sub PostToInventory()
    Dim strTarget As String
    Dim PauseTime As Integer
    Dim Start As Long
    Dim TotalRecord As Long
    
    Screen.MousePointer = vbHourglass
    ' Set variables
    PauseTime = 2                       ' Set duration.
    With dtcRebuildCost.Recordset       ' Set total record.
        .MoveFirst
        .MoveLast
        TotalRecord = .RecordCount
    End With
    
    ' Display process info
    fraInfo.Enabled = True
    mskStartTime = Time
    mskEstimateTime = TimeSerial( _
                      (Hour(Time) + TotalRecord * PauseTime / 60 / 60), _
                      Minute(Time), Second(Time))
    txtErrorLog.Text = "0"
    fraInfo.Refresh
    
    With dtcRebuildCost.Recordset
        .MoveFirst
        Do
            txtRecordLog.Text = !SKU
            fraInfo.Refresh
            strTarget = "SKU = '" & !SKU & "'"
            dtcInventory.Recordset.FindFirst strTarget
            If Not dtcInventory.Recordset.NoMatch And _
                dtcInventory.Recordset!SupplierCode = "21" Then
                dtcInventory.Recordset.Edit
                dtcInventory.Recordset.AverageCost = !AverageCost
                dtcInventory.Recordset.LeastSellingPrice = !LSP
                dtcInventory.Recordset.Update
            End If
            .MoveNext
            Start = Timer                       ' Set start time.
            Do While Timer < Start + PauseTime  ' Sleep
                DoEvents                        ' Yield to other processes.
            Loop
        Loop Until .EOF
    End With
    Screen.MousePointer = vbDefault
    MsgBox "Level Two Finished"
End Sub


Private Sub PostToTxDetails()
    Dim strTarget As String
    Dim PauseTime As Integer
    Dim Start As Long
    Dim TotalRecord As Long
    
    Screen.MousePointer = vbHourglass
    ' Set variables
    PauseTime = 0                       ' Set duration.
    With dtcTxDetails.Recordset       ' Set total record.
        .MoveFirst
        .MoveLast
        TotalRecord = .RecordCount
    End With
    
    ' Display process info
    fraInfo.Enabled = True
    mskStartTime = Time
    mskEstimateTime = TimeSerial( _
                      (Hour(Time) + TotalRecord * PauseTime / 60 / 60), _
                      Minute(Time), Second(Time))
    txtErrorLog.Text = "0"
    fraInfo.Refresh
    
    With dtcTxDetails.Recordset
        .MoveFirst
        Do
            Select Case !TxType
                Case "RC", "RS", "SA"
                    txtRecordLog.Text = !SKU
                    fraInfo.Refresh
                    strTarget = "SKU = '" & !SKU & "'"
                    dtcInventory.Recordset.FindFirst strTarget
                    If Not dtcInventory.Recordset.NoMatch Then
                        .Edit
                        Select Case dtcInventory.Recordset!SupplierCode
                            Case "21"   ' Hongkong Optical
                                !UnitCost = dtcInventory.Recordset.AverageCost
                                !UnitLSP = dtcInventory.Recordset.LeastSellingPrice
                            Case Else
                                !UnitCost = dtcInventory.Recordset.AverageCost
                                !UnitLSP = dtcInventory.Recordset.LeastSellingPrice
                        End Select
                        .Update
                    End If
                Case Else
                    ' Do nothing
            End Select
            .MoveNext
            Start = Timer                       ' Set start time.
            Do While Timer < Start + PauseTime  ' Sleep
                DoEvents                        ' Yield to other processes.
            Loop
        Loop Until .EOF
    End With
    Screen.MousePointer = vbDefault
    MsgBox "Level Three Finished"
End Sub

Private Sub CreateOpenning()
    Dim PauseTime As Integer
    Dim Start As Long
    Dim TotalRecord As Long
    Dim strTarget As String
    Dim intRow As Long
    Dim TotalQty As Long
    Dim TotalAmount As Currency
    
    Screen.MousePointer = vbHourglass
    ' Set variables
    intRow = 0
    TotalQty = 0
    TotalAmount = 0
    PauseTime = 0                       ' Set duration.
    With dtcInvtSummary.Recordset       ' Set total record.
        .MoveFirst
        .MoveLast
        TotalRecord = .RecordCount
    End With
    
    ' Display process info
    fraInfo.Enabled = True
    mskStartTime = Time
    mskEstimateTime = TimeSerial( _
                      (Hour(Time) + TotalRecord * PauseTime / 60 / 60), _
                      Minute(Time), Second(Time))
    txtErrorLog.Text = "0"
    fraInfo.Refresh
    
    With dtcInvtSummary.Recordset
        .MoveFirst
        Do
            intRow = intRow + 1
            txtRecordLog.Text = !SKU
            fraInfo.Refresh
            strTarget = "SKU = '" & !SKU & "'"
            dtcInventory.Recordset.FindFirst strTarget
            '
            dtcTxDetails.Recordset.AddNew
            dtcTxDetails.Recordset!ControlNumber = 0
            dtcTxDetails.Recordset!TxType = "RC"
            dtcTxDetails.Recordset!TxNumber = "RC00000000"
            dtcTxDetails.Recordset!DateOfEntry = #1/1/97#
            dtcTxDetails.Recordset!RowNo = intRow
            dtcTxDetails.Recordset!SKU = !SKU
            dtcTxDetails.Recordset!Qty = dtcInvtSummary.Recordset!QtySold
            If dtcInvtSummary.Recordset!QtySold = 0 Or dtcInvtSummary.Recordset!AmtSold = 0 Then
            Else
            dtcTxDetails.Recordset!UnitAmount = (dtcInvtSummary.Recordset!AmtSold / dtcInvtSummary.Recordset!QtySold)
            End If
            dtcTxDetails.Recordset!UnitCost = dtcInventory.Recordset!AverageCost
            dtcTxDetails.Recordset!UnitLSP = dtcInventory.Recordset!LeastSellingPrice
            dtcTxDetails.Recordset!MarkDownPercent = 0
            dtcTxDetails.Recordset!MarkDownAmount = 0
            dtcTxDetails.Recordset!Amount = dtcInvtSummary.Recordset!AmtSold
            dtcTxDetails.Recordset!TaxCode = "N"
            dtcTxDetails.Recordset.Update
            '
            TotalQty = TotalQty + dtcInvtSummary.Recordset!QtySold
            TotalAmount = TotalAmount + dtcInvtSummary.Recordset!AmtSold
            .MoveNext
        Loop Until .EOF
    End With
    Screen.MousePointer = vbDefault
    MsgBox "Total Qty = " & TotalQty & Chr$(13) & _
           "Total Amt = " & TotalAmount
End Sub

Private Sub SSCommand1_Click()
    Call CreateOpenning
End Sub



VERSION 5.00
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmRptSRbySupplier 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Stock Recievd (by Supplier)"
   ClientHeight    =   3120
   ClientLeft      =   840
   ClientTop       =   1665
   ClientWidth     =   6645
   Icon            =   "frmRptSRbySupplier.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3120
   ScaleWidth      =   6645
   ShowInTaskbar   =   0   'False
   Begin Threed.SSFrame frmReportLayout 
      Height          =   675
      Left            =   120
      TabIndex        =   17
      Top             =   1500
      Width           =   6375
      _ExtentX        =   11245
      _ExtentY        =   1191
      _Version        =   131074
      Caption         =   "Select Detail Report or Summary Report"
      Begin Threed.SSOption optSummaryReport 
         Height          =   255
         Left            =   2040
         TabIndex        =   6
         Top             =   240
         Width           =   1515
         _ExtentX        =   2672
         _ExtentY        =   450
         _Version        =   131074
         Caption         =   "Summary Report"
         Value           =   -1
      End
      Begin Threed.SSOption optDetailReport 
         Height          =   255
         Left            =   120
         TabIndex        =   5
         Top             =   240
         Width           =   1335
         _ExtentX        =   2355
         _ExtentY        =   450
         _Version        =   131074
         Caption         =   "Detail Report"
      End
   End
   Begin VB.Frame fraAskDateRange 
      Caption         =   " Select Date Range "
      Height          =   1335
      Left            =   3540
      TabIndex        =   12
      Top             =   120
      Width           =   2955
      Begin SSCalendarWidgets_A.SSDateCombo SSDateTo 
         Height          =   375
         Left            =   600
         TabIndex        =   4
         Top             =   840
         Width           =   2235
         _Version        =   65543
         _ExtentX        =   3942
         _ExtentY        =   661
         _StockProps     =   93
         BeginProperty DropDownFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         MinDate         =   "1996/1/1"
         MaxDate         =   "2100/12/31"
         Format          =   "MMMM DD, YYYY"
      End
      Begin SSCalendarWidgets_A.SSDateCombo SSDateFrom 
         Height          =   375
         Left            =   600
         TabIndex        =   3
         Top             =   360
         Width           =   2235
         _Version        =   65543
         _ExtentX        =   3942
         _ExtentY        =   661
         _StockProps     =   93
         BeginProperty DropDownFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         MinDate         =   "1996/1/1"
         MaxDate         =   "2100/12/31"
         Format          =   "MMMM DD, YYYY"
      End
      Begin VB.Label Label2 
         Caption         =   "From:"
         Height          =   375
         Left            =   120
         TabIndex        =   13
         Top             =   360
         Width           =   495
      End
      Begin VB.Label Label4 
         Caption         =   "To:"
         Height          =   375
         Left            =   120
         TabIndex        =   14
         Top             =   840
         Width           =   495
      End
   End
   Begin VB.CommandButton cmdPrnSetup 
      Caption         =   "&Setup"
      Height          =   375
      Left            =   5160
      TabIndex        =   10
      Top             =   2460
      Width           =   1200
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "&Exit"
      Height          =   375
      Left            =   3180
      TabIndex        =   9
      Top             =   2460
      Width           =   1200
   End
   Begin VB.CommandButton cmdReset 
      Caption         =   "&Reset"
      Height          =   375
      Left            =   1740
      TabIndex        =   8
      Top             =   2460
      Width           =   1200
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK "
      Height          =   375
      Left            =   300
      TabIndex        =   7
      Top             =   2460
      Width           =   1200
   End
   Begin VB.Frame fraPrinter 
      Caption         =   "Printer "
      Height          =   735
      Left            =   5040
      TabIndex        =   16
      Top             =   2220
      Width           =   1455
   End
   Begin VB.Frame fraCommand 
      Caption         =   "Command"
      Height          =   735
      Left            =   120
      TabIndex        =   15
      Top             =   2220
      Width           =   4395
   End
   Begin VB.Frame fraSelectSupplier 
      Caption         =   "Select Supplier(s)"
      Height          =   1335
      Left            =   120
      TabIndex        =   11
      Top             =   120
      Width           =   3315
      Begin MSDBCtls.DBCombo dboSupplier 
         Bindings        =   "frmRptSRbySupplier.frx":068A
         DataSource      =   "dtcSupplier"
         Height          =   315
         Left            =   120
         TabIndex        =   2
         Top             =   900
         Width           =   3135
         _ExtentX        =   5530
         _ExtentY        =   556
         _Version        =   393216
         ListField       =   "SupplierName"
         BoundColumn     =   "SupplierCode"
         Text            =   ""
      End
      Begin VB.Data dtcSupplier 
         Caption         =   "Supplier"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   375
         Left            =   1140
         Options         =   0
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT * FROM Supplier ORDER BY SupplierName"
         Top             =   300
         Visible         =   0   'False
         Width           =   1575
      End
      Begin VB.OptionButton optSelSupplier 
         Caption         =   "Selected"
         Height          =   255
         Left            =   120
         TabIndex        =   1
         Top             =   600
         Value           =   -1  'True
         Width           =   1335
      End
      Begin VB.OptionButton optAllSupplier 
         Caption         =   "All"
         Height          =   255
         Left            =   120
         TabIndex        =   0
         Top             =   300
         Width           =   1335
      End
   End
End
Attribute VB_Name = "frmRptSRbySupplier"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private Sub cmdExit_Click()
    On Error GoTo cmdExit_Click_Err
    Call ofx_CloseForm(frmRptSRbySupplier)
cmdExit_Click_Exit:         ' SDVB autocode
    On Error Resume Next    ' SDVB autocode
    Exit Sub                ' SDVB autocode
cmdExit_Click_Err:          ' SDVB autocode
    MsgBox Error            ' SDVB autocode
    Resume cmdExit_Click_Exit
End Sub

Private Sub cmdPrnSetup_Click()

    On Error GoTo cmdPrnSetup_Click_Err

    frmCtlCrw.CommonDialog1.Flags = &H40  'force the printers setup dialog box
    frmCtlCrw.CommonDialog1.Action = 5    'run the printer setup

cmdPrnSetup_Click_Exit:   ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdPrnSetup_Click_Err:    ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdPrnSetup_Click_Exit

End Sub




Private Sub cmdOK_Click()

    On Error GoTo cmdOK_Click_Err
     
     
    Dim DateFrom As Date
    Dim DateTo As Date
   
    DateFrom = Me.SSDateFrom.Date
    DateTo = Me.SSDateTo.Date
     
    
    If DateFrom > DateTo Then
        Me.SSDateFrom.Date = DateTo
        Me.SSDateTo.Date = DateFrom
        DateFrom = Me.SSDateFrom.Date
        DateTo = Me.SSDateTo.Date
        frmRptSRbySupplier.Refresh
    End If
        
    If DateFrom > Date Then
            Beep
            MsgBox " Greater than current date ", 0, "Validation Error"
            Me.SSDateFrom.SetFocus
            Exit Sub
     End If
    
    Screen.MousePointer = vbArrowHourglass
    ' Set report file
    If optSummaryReport Then
        CrwRptName = "Stock Received (By Supplier) Summary"
        Call SetRptFileName(CrwRptName, 0)
    End If
    
    '   Set Formula
    frmCtlCrw.CrystalReport1.Formulas(0) = "AskDateFrom =" & _
                "Date(" & (Year(Me.SSDateFrom)) & "," & _
                    (Month(Me.SSDateFrom)) & "," & _
                    (Day(Me.SSDateFrom)) & ")"
    frmCtlCrw.CrystalReport1.Formulas(1) = "AskDateTo =" & _
                "Date(" & (Year(Me.SSDateTo)) & "," & _
                    (Month(Me.SSDateTo)) & "," & _
                    (Day(Me.SSDateTo)) & ")"
    frmCtlCrw.CrystalReport1.Formulas(4) = "AskSuppName =" & dboSupplier.Text

    frmCtlCrw.CrystalReport1.SelectionFormula = "{TxHeader.DateOfEntry} in {@AskDateFrom} to {@AskDateTo}"

    If optSelSupplier Then
        frmCtlCrw.CrystalReport1.SelectionFormula = _
        frmCtlCrw.CrystalReport1.SelectionFormula & " AND {TxHeader.SupplierCode}='" & dboSupplier.BoundText & "'" & _
            " AND ({TxHeader.TxType} = 'SR')"
    Else
        frmCtlCrw.CrystalReport1.SelectionFormula = _
        frmCtlCrw.CrystalReport1.SelectionFormula & " AND ({TxHeader.TxType} = 'SR')"
    End If
    Call ofx_CloseForm(frmRptSRbySupplier)
    Call PrintIt

cmdOK_Click_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdOK_Click_Err:          ' SDVB autocode
    Screen.MousePointer = vbDefault
    MsgBox Error          ' SDVB autocode
    Resume cmdOK_Click_Exit

End Sub


Private Sub cmdReset_Click()

    On Error GoTo cmdReset_Click_Err
  
    Screen.MousePointer = vbDefault
    optAllSupplier = True
    optAllSupplier.SetFocus

cmdReset_Click_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdReset_Click_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdReset_Click_Exit

End Sub

Private Sub Form_Load()

    On Error GoTo Form_Load_Err
  
    Call ofx_CenterForm(Me)
    Screen.MousePointer = vbDefault
    Me.Caption = CrwRptName
'    optAllSupplier = True
    SSDateFrom.MaxDate = Date
    SSDateTo.MaxDate = Date

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub

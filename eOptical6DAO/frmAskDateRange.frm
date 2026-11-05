VERSION 5.00
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmAskDateRange 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "frmAskDateRange"
   ClientHeight    =   3675
   ClientLeft      =   585
   ClientTop       =   900
   ClientWidth     =   7095
   Icon            =   "frmAskDateRange.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3675
   ScaleWidth      =   7095
   ShowInTaskbar   =   0   'False
   Begin VB.Frame Frame3 
      Caption         =   "Printer"
      Height          =   735
      Left            =   5160
      TabIndex        =   8
      Top             =   2640
      Width           =   1455
      Begin VB.CommandButton cmdPrnSetup 
         Caption         =   "&Setup"
         Height          =   330
         Left            =   120
         TabIndex        =   6
         Top             =   240
         Width           =   1200
      End
   End
   Begin VB.Frame frame2 
      Caption         =   "Command"
      Height          =   735
      Left            =   480
      TabIndex        =   7
      Top             =   2640
      Width           =   4335
      Begin VB.CommandButton cmdExit 
         Caption         =   "&Exit"
         Height          =   330
         Left            =   3000
         TabIndex        =   5
         Top             =   240
         Width           =   1200
      End
      Begin VB.CommandButton cmdReset 
         Caption         =   "&Reset"
         Height          =   330
         Left            =   1560
         TabIndex        =   4
         Top             =   240
         Width           =   1200
      End
      Begin VB.CommandButton cmdOK 
         Caption         =   "&OK"
         Height          =   330
         Left            =   120
         TabIndex        =   3
         Top             =   240
         Width           =   1200
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Select Date Range"
      Height          =   1695
      Left            =   480
      TabIndex        =   0
      Top             =   360
      Width           =   6135
      Begin SSCalendarWidgets_A.SSDateCombo ssDateTo 
         Height          =   330
         Left            =   2400
         TabIndex        =   2
         Top             =   1080
         Width           =   2400
         _Version        =   65543
         _ExtentX        =   4233
         _ExtentY        =   582
         _StockProps     =   93
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
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
      End
      Begin SSCalendarWidgets_A.SSDateCombo ssDateFrom 
         Height          =   330
         Left            =   2400
         TabIndex        =   1
         Top             =   360
         Width           =   2400
         _Version        =   65543
         _ExtentX        =   4233
         _ExtentY        =   582
         _StockProps     =   93
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
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
      End
      Begin VB.Label Label2 
         Caption         =   "To Date:"
         Height          =   255
         Left            =   1200
         TabIndex        =   10
         Top             =   1080
         Width           =   855
      End
      Begin VB.Label Label1 
         Caption         =   "From Date:"
         Height          =   255
         Left            =   1200
         TabIndex        =   9
         Top             =   360
         Width           =   855
      End
   End
End
Attribute VB_Name = "frmAskDateRange"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private Sub cmdExit_Click()

    On Error GoTo cmdExit_Click_Err
    Unload Me
cmdExit_Click_Exit:       ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdExit_Click_Err:        ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdExit_Click_Exit

End Sub


Private Sub cmdOK_Click()

    On Error GoTo cmdOK_Click_Err
    
    Screen.MousePointer = vbArrowHourglass
    
    Dim DateFrom As Date
    Dim DateTo As Date
   
    DateFrom = Me.SSDateFrom.Date
    DateTo = Me.SSDateTo.Date
     
    If DateFrom > DateTo Then
        Me.SSDateFrom.Date = DateTo
        Me.SSDateTo.Date = DateFrom
        DateFrom = Me.SSDateFrom.Date
        DateTo = Me.SSDateTo.Date
        frmAskDateRange.Refresh
    End If
    '   Set formulas
    frmCtlCrw.CrystalReport1.Formulas(0) = "AskDateFrom = " & _
            "Date(" & (Year(DateFrom)) & "," & _
                    (Month(DateFrom)) & "," & _
                    (Day(DateFrom)) & ")"
    frmCtlCrw.CrystalReport1.Formulas(1) = "AskDateTo = " & _
            "Date(" & (Year(DateTo)) & "," & _
                    (Month(DateTo)) & "," & _
                    (Day(DateTo)) & ")"
    frmCtlCrw.CrystalReport1.SelectionFormula = _
            "({TxHeader.DateOfEntry} IN Date(" & _
             (Year(DateFrom)) & "," & _
             (Month(DateFrom)) & "," & _
             (Day(DateFrom)) & ")"
    frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " TO Date(" & (Year(DateTo)) & "," & _
                          (Month(DateTo)) & "," & _
                          (Day(DateTo)) & "))"
    
    '   Daily Cash Receipts
    If CrwRptName = "Daily Cash Receipts" Then
         frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
             " AND ({TxHeader.TxType} IN 'RCRSSA')"             ' 20030725 removed WC
        ' and {TxHeader.ThisPaid}<>0;
    '   Invoice List (By Date)
    ElseIf CrwRptName = "Invoice List (By Date)" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType} = 'RC')"
    ' Daily Sales List (Sales Report)
    ElseIf CrwRptName = "Sales Report" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
                "AND ({TxHeader.TxType}='RC' or " & _
                "({TxHeader.TxType}='RS' AND {TxHeader.RefNumber} like 'RC*'))"
    '   Orders in Progress
     ElseIf CrwRptName = "Orders in Progress" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType} = 'SA' AND {TxHeader.Status} = '1')"
    '   Outstanding Orders on hand
     ElseIf CrwRptName = "Outstanding Orders on hand" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType} = 'SA' AND {TxHeader.Status} = '1')"
    '   Orders Summary (By Date)
     ElseIf CrwRptName = "Orders Report (By Date)" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType} = 'SA')"
    '   Payment Summary (Receipts Report)
     ElseIf CrwRptName = "Receipts Report" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType} IN 'LARCRSSA')"
    '       and {TxHeader.ThisPaid}<>0;
    '   Payment Summary
     ElseIf CrwRptName = "Payment Summary" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType} IN 'LARCRSSAWC')"
    '       and {TxHeader.ThisPaid}<>0;
    ElseIf CrwRptName = "Stock Adjustment" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType} = 'SJ')"
    ElseIf CrwRptName = "Stock Received" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType} = 'SR')"
    ElseIf CrwRptName = "Stock Rejected" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType} = 'RJ')"
    End If
    'MsgBox frmCtlCrw.CrystalReport1.SelectionFormula
    Screen.MousePointer = vbHourglass
    Unload Me
    frmCtlCrw.CrystalReport1.Action = 1
    Screen.MousePointer = vbDefault
cmdOK_Click_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub
cmdOK_Click_Err:          ' SDVB autocode
    Screen.MousePointer = vbDefault
    MsgBox Error          ' SDVB autocode
    Resume cmdOK_Click_Exit

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


Private Sub cmdReset_Click()

    On Error GoTo cdmReset_Click_Err
    
    Screen.MousePointer = vbDefault
' 20030725 Set to same day, requested by customer
    ' Set start date 30 days ago today
'    Me.SSDateFrom.Date = (CurrentDate - 30)
    Me.SSDateFrom.Date = CurrentDate
    Me.SSDateTo.Date = CurrentDate
  
    Me.SSDateFrom.SetFocus

cdmReset_Click_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cdmReset_Click_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cdmReset_Click_Exit

End Sub


Private Sub Form_Load()
    On Error GoTo Form_Load_Err

    Call ofx_CenterForm(Me)
    Screen.MousePointer = vbDefault
    Me.Caption = CrwRptName
    Me.Icon = LoadPicture(SynergyIcon)
 
' 20030725 Set to same day, requested by customer
    '   Set start date 30 days ago today
'    Me.SSDateFrom.Date = Format((CurrentDate - 30), "MM/DD/YYYY")

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub


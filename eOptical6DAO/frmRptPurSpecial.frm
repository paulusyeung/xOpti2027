VERSION 5.00
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmRptPurSpecial 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Special Purchase Reports"
   ClientHeight    =   2565
   ClientLeft      =   840
   ClientTop       =   1665
   ClientWidth     =   6645
   Icon            =   "frmRptPurSpecial.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   2565
   ScaleWidth      =   6645
   ShowInTaskbar   =   0   'False
   Begin VB.Frame fraAskDateRange 
      Caption         =   " Purchase Details Date Range "
      Height          =   1335
      Left            =   3240
      TabIndex        =   9
      Top             =   120
      Width           =   3375
      Begin SSCalendarWidgets_A.SSDateCombo SSDateTo 
         Height          =   375
         Left            =   600
         TabIndex        =   3
         Top             =   840
         Width           =   2655
         _Version        =   65543
         _ExtentX        =   4683
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
         TabIndex        =   2
         Top             =   360
         Width           =   2655
         _Version        =   65543
         _ExtentX        =   4683
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
         TabIndex        =   10
         Top             =   360
         Width           =   495
      End
      Begin VB.Label Label4 
         Caption         =   "To:"
         Height          =   375
         Left            =   120
         TabIndex        =   11
         Top             =   840
         Width           =   495
      End
   End
   Begin VB.CommandButton cmdPrnSetup 
      Caption         =   "&Setup"
      Height          =   375
      Left            =   5040
      TabIndex        =   7
      Top             =   1800
      Width           =   1200
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "&Exit"
      Height          =   375
      Left            =   3240
      TabIndex        =   6
      Top             =   1800
      Width           =   1200
   End
   Begin VB.CommandButton cmdReset 
      Caption         =   "&Reset"
      Height          =   375
      Left            =   1800
      TabIndex        =   5
      Top             =   1800
      Width           =   1200
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK "
      Height          =   375
      Left            =   360
      TabIndex        =   4
      Top             =   1800
      Width           =   1200
   End
   Begin VB.Frame fraPrinter 
      Caption         =   "Printer "
      Height          =   735
      Left            =   4920
      TabIndex        =   13
      Top             =   1560
      Width           =   1455
   End
   Begin VB.Frame fraCommand 
      Caption         =   "Command"
      Height          =   735
      Left            =   240
      TabIndex        =   12
      Top             =   1560
      Width           =   4335
   End
   Begin VB.Frame fraAskLOCAL 
      Caption         =   " Including LOCAL Category "
      Height          =   1335
      Left            =   240
      TabIndex        =   8
      Top             =   120
      Width           =   2900
      Begin VB.OptionButton OptXclLocal 
         Caption         =   "No"
         Height          =   255
         Left            =   240
         TabIndex        =   1
         Top             =   780
         Width           =   850
      End
      Begin VB.OptionButton OptInclLocal 
         Caption         =   "Yes"
         Height          =   255
         Index           =   0
         Left            =   240
         TabIndex        =   0
         Top             =   420
         Width           =   850
      End
   End
End
Attribute VB_Name = "frmRptPurSpecial"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private Sub cmdExit_Click()
    On Error GoTo cmdExit_Click_Err
    Call ofx_CloseForm(frmRptPurSpecial)
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
        frmRptPurSpecial.Refresh
    End If
        
    If DateFrom > Date Then
            Beep
            MsgBox " Greater than current date ", 0, "Validation Error"
            Me.SSDateFrom.SetFocus
            Exit Sub
     End If
    
    Screen.MousePointer = vbArrowHourglass
      '   Set Formula
    frmCtlCrw.CrystalReport1.Formulas(0) = "AskDateFrom =" & _
                "Date(" & (Year(Me.SSDateFrom)) & "," & _
                    (Month(Me.SSDateFrom)) & "," & _
                    (Day(Me.SSDateFrom)) & ")"
    frmCtlCrw.CrystalReport1.Formulas(1) = "AskDateTo =" & _
                "Date(" & (Year(Me.SSDateTo)) & "," & _
                    (Month(Me.SSDateTo)) & "," & _
                    (Day(Me.SSDateTo)) & ")"
    frmCtlCrw.CrystalReport1.Formulas(4) = "AskXDispCost =" & pyUserHasCostLevel
    
    frmCtlCrw.CrystalReport1.SelectionFormula = "{RptPurSpecial.DateOfEntry} in {@AskDateFrom} to {@AskDateTo}"
    
    If optAllSupplier Then _
        frmCtlCrw.CrystalReport1.SelectionFormula = _
         frmCtlCrw.CrystalReport1.SelectionFormula & " AND {RptPurSpecial.categorycode}<>'12'"
    Call ofx_CloseForm(frmRptPurSpecial)
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
    optAllSupplier = True
    SSDateFrom.MaxDate = Date
    SSDateTo.MaxDate = Date

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub











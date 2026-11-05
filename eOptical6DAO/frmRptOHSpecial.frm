VERSION 5.00
Begin VB.Form frmRptOHSpecial 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Special On Hand Analysis"
   ClientHeight    =   2565
   ClientLeft      =   1245
   ClientTop       =   4890
   ClientWidth     =   6645
   Icon            =   "frmRptOHSpecial.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   2565
   ScaleWidth      =   6645
   ShowInTaskbar   =   0   'False
   Begin VB.Frame fraAskLSP 
      Caption         =   " Including LSP Cost "
      Height          =   1335
      Left            =   3480
      TabIndex        =   3
      Top             =   120
      Width           =   2900
      Begin VB.OptionButton OptXclLSP 
         Caption         =   "No"
         Height          =   255
         Left            =   240
         TabIndex        =   5
         Top             =   780
         Width           =   850
      End
      Begin VB.OptionButton OptInclLSP 
         Caption         =   "Yes"
         Height          =   255
         Left            =   240
         TabIndex        =   4
         Top             =   420
         Width           =   850
      End
   End
   Begin VB.CommandButton cmdPrnSetup 
      Caption         =   "&Setup"
      Height          =   375
      Left            =   5040
      TabIndex        =   11
      Top             =   1800
      Width           =   1200
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "&Exit"
      Height          =   375
      Left            =   3240
      TabIndex        =   9
      Top             =   1800
      Width           =   1200
   End
   Begin VB.CommandButton cmdReset 
      Caption         =   "&Reset"
      Height          =   375
      Left            =   1800
      TabIndex        =   8
      Top             =   1800
      Width           =   1200
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK "
      Height          =   375
      Left            =   360
      TabIndex        =   7
      Top             =   1800
      Width           =   1200
   End
   Begin VB.Frame fraPrinter 
      Caption         =   "Printer "
      Height          =   735
      Left            =   4920
      TabIndex        =   10
      Top             =   1560
      Width           =   1455
   End
   Begin VB.Frame fraCommand 
      Caption         =   "Command"
      Height          =   735
      Left            =   240
      TabIndex        =   6
      Top             =   1560
      Width           =   4335
   End
   Begin VB.Frame fraAskLOCAL 
      Caption         =   " Including LOCAL Category "
      Height          =   1335
      Left            =   240
      TabIndex        =   0
      Top             =   120
      Width           =   2900
      Begin VB.OptionButton OptXclLocal 
         Caption         =   "No"
         Height          =   255
         Left            =   240
         TabIndex        =   2
         Top             =   780
         Width           =   850
      End
      Begin VB.OptionButton OptInclLocal 
         Caption         =   "Yes"
         Height          =   255
         Index           =   0
         Left            =   240
         TabIndex        =   1
         Top             =   420
         Width           =   850
      End
   End
End
Attribute VB_Name = "frmRptOHSpecial"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private Sub cmdExit_Click()
    On Error GoTo cmdExit_Click_Err
    Call ofx_CloseForm(frmRptOHSpecial)
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
   
    Screen.MousePointer = vbArrowHourglass
    frmCtlCrw.CrystalReport1.Formulas(0) = "AskNoCost =" & Not (pyUserHasCostLevel)
    If pyUserHasCostLevel Then
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskNoLSP =" & OptXclLSP
    Else
        frmCtlCrw.CrystalReport1.Formulas(1) = True
    End If
    If optAllSupplier Then
        frmCtlCrw.CrystalReport1.SelectionFormula = "{Category.CategoryCode}<>'12'"
    Else
        frmCtlCrw.CrystalReport1.SelectionFormula = ""
    End If
    Call ofx_CloseForm(frmRptOHSpecial)
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
    OptXclLSP = True
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
    If pyUserHasCostLevel Then
        fraAskLSP.Visible = True
    Else
        fraAskLSP.Visible = False
    End If
    
    optAllSupplier = True
    OptXclLSP = True
    

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub










Private Sub txtDays_KeyPress(KeyAscii As Integer)

    On Error GoTo txtDays_KeyPress_Err

    KeyAscii = KeyNumbers(KeyAscii)

txtDays_KeyPress_Exit:    ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
txtDays_KeyPress_Err:     ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume txtDays_KeyPress_Exit

End Sub



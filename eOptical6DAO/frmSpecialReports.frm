VERSION 5.00
Begin VB.Form frmSpecialReports 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Special Reports"
   ClientHeight    =   4350
   ClientLeft      =   1485
   ClientTop       =   2070
   ClientWidth     =   6510
   Icon            =   "frmSpecialReports.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4350
   ScaleWidth      =   6510
   Begin VB.ComboBox cboRptName 
      Height          =   315
      Left            =   1800
      Sorted          =   -1  'True
      TabIndex        =   0
      Text            =   "combo1"
      Top             =   960
      Width           =   4200
   End
   Begin VB.Frame frmReport 
      Caption         =   "Report Selection:"
      Height          =   3735
      Left            =   240
      TabIndex        =   1
      Top             =   360
      Width           =   6015
      Begin VB.CommandButton cmdPrnSetup 
         Caption         =   "&Setup"
         Height          =   330
         Left            =   4500
         TabIndex        =   7
         Top             =   3000
         Width           =   1200
      End
      Begin VB.CommandButton cmdOK 
         Caption         =   "&OK"
         Height          =   330
         Left            =   240
         TabIndex        =   3
         Top             =   3000
         Width           =   1200
      End
      Begin VB.CommandButton cmdExit 
         Caption         =   "&Exit"
         Height          =   330
         Left            =   2880
         TabIndex        =   5
         Top             =   3000
         Width           =   1200
      End
      Begin VB.CommandButton cmdReset 
         Caption         =   "&Reset"
         Height          =   330
         Left            =   1560
         TabIndex        =   4
         Top             =   3000
         Width           =   1200
      End
      Begin VB.Frame Frame1 
         Caption         =   "Command"
         Height          =   735
         Left            =   120
         TabIndex        =   6
         Top             =   2760
         Width           =   4095
      End
      Begin VB.Frame Frame2 
         Caption         =   "Printer"
         Height          =   735
         Left            =   4320
         TabIndex        =   8
         Top             =   2760
         Width           =   1575
      End
      Begin VB.Label lblRptName 
         Caption         =   "Report Name:"
         Height          =   315
         Left            =   240
         TabIndex        =   2
         Top             =   600
         Width           =   1335
      End
   End
End
Attribute VB_Name = "frmSpecialReports"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


Private Sub cmdExit_Click()

    On Error GoTo cmdExit_Click_Err
    ' close the report
    frmCtlCrw.CrystalReport1.ReportFileName = ""    ' to null
    frmCtlCrw.CrystalReport1.Destination = 0        ' to Window
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
    Screen.MousePointer = vbDefault
    
    Screen.MousePointer = vbHourglass
    If Me.cboRptName = "Bar Code Tag" Then
        If SetRptFileName(Me.cboRptName.Text, 0) Then
            CrwRptName = Me.cboRptName
            frmAskTxNumber.Show vbModal
        End If
    ElseIf Me.cboRptName = "Claims Receipt" Then
        Call PrintClaimReceipt(0, 0)
    ElseIf Me.cboRptName = "Invoice" Then
        Call PrintInvoice(0, 0)
    ElseIf Me.cboRptName = "Order" Then
        Call PrintOrder(0, 0)
    ElseIf Me.cboRptName = "Prescription - By Customer" Then
        frmRxCustomer.Show
    ElseIf Me.cboRptName = "Prescription - By Order/Invoice Number" Then
        Call PrintRxTxNum(0, 0)
    ElseIf Me.cboRptName = "Stock Adjustment" Then
        Call PrintStockTrans("SJ", 0, 0)
    ElseIf Me.cboRptName = "Stock Received" Then
        Call PrintStockTrans("SR", 0, 0)
    ElseIf Me.cboRptName = "Stock Rejected" Then
        Call PrintStockTrans("RJ", 0, 0)
    Else
        'All other code listing
        If SetRptFileName(Me.cboRptName.Text, 0) Then frmCtlCrw.CrystalReport1.Action = 1
    End If
cmdOK_Click_Exit:          ' SDVB autocode
    Screen.MousePointer = vbDefault
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdOK_Click_Err:          ' SDVB autocode
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

    On Error GoTo cmdReset_Click_Err

    Me.cboRptName.Text = Me.cboRptName.list(0)
    Me.cboRptName.SetFocus

cmdReset_Click_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdReset_Click_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdReset_Click_Exit

End Sub


Private Sub Form_Load()

    On Error GoTo Form_Load_Err
    
    Screen.MousePointer = vbDefault
    Me.Icon = LoadPicture(SynergyIcon)

    Call ofx_CenterForm(Me)
    '
    ' load dropdown list
    Me.cboRptName.AddItem "Bar Code Tag"
    Me.cboRptName.AddItem "Claims Receipt"
    Me.cboRptName.AddItem "Invoice"
    Me.cboRptName.AddItem "Order"
    Me.cboRptName.AddItem "Prescription - By Customer"
    Me.cboRptName.AddItem "Prescription - By Order/Invoice Number"
    Me.cboRptName.AddItem "Stock Adjustment"
    Me.cboRptName.AddItem "Stock Received"
    Me.cboRptName.AddItem "Stock Rejected"
    Me.cboRptName.AddItem "Stock Take Report"
    '
    ' set first list member
    Me.cboRptName.Text = Me.cboRptName.list(0)

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub


Private Sub Form_Unload(Cancel As Integer)

    On Error GoTo Form_Unload_Err

    cmdExit_Click

Form_Unload_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Unload_Err:          ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Unload_Exit

End Sub



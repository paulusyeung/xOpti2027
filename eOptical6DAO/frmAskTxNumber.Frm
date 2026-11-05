VERSION 5.00
Begin VB.Form frmAskTxNumber 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Ask Transaction Number"
   ClientHeight    =   3450
   ClientLeft      =   2865
   ClientTop       =   1020
   ClientWidth     =   6345
   Icon            =   "frmAskTxNumber.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3450
   ScaleWidth      =   6345
   ShowInTaskbar   =   0   'False
   Begin VB.Frame Frame4 
      Caption         =   "Printer"
      Height          =   735
      Left            =   4560
      TabIndex        =   12
      Top             =   2280
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
   Begin VB.CommandButton cmdExit 
      Caption         =   "&Exit"
      Height          =   330
      Left            =   3000
      TabIndex        =   5
      Top             =   2520
      Width           =   1200
   End
   Begin VB.CommandButton cmdReset 
      Caption         =   "&Reset"
      Height          =   330
      Left            =   1680
      TabIndex        =   4
      Top             =   2520
      Width           =   1200
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   330
      Left            =   360
      TabIndex        =   3
      Top             =   2520
      Width           =   1200
   End
   Begin VB.Frame fraTxNumber 
      Caption         =   "Transaction Number"
      Height          =   1695
      Left            =   240
      TabIndex        =   0
      Top             =   240
      Width           =   5790
      Begin VB.TextBox txtTxNumberTo 
         Height          =   330
         Left            =   2450
         TabIndex        =   2
         Text            =   "99999999"
         Top             =   1000
         Width           =   1400
      End
      Begin VB.TextBox txtTxNumberFrom 
         Height          =   330
         Left            =   2450
         TabIndex        =   1
         Text            =   "1"
         Top             =   400
         Width           =   1400
      End
      Begin VB.TextBox txtTxPrefixFrom 
         Enabled         =   0   'False
         Height          =   330
         Left            =   2000
         TabIndex        =   7
         Text            =   "Tx"
         Top             =   400
         Width           =   440
      End
      Begin VB.TextBox txtTxPrefixTo 
         Enabled         =   0   'False
         Height          =   330
         Left            =   2000
         TabIndex        =   8
         Text            =   "Tx"
         Top             =   1000
         Width           =   440
      End
      Begin VB.Label Label1 
         Caption         =   "From:"
         Height          =   255
         Left            =   1500
         TabIndex        =   10
         Top             =   400
         Width           =   495
      End
      Begin VB.Label Label2 
         Caption         =   "To:"
         Height          =   255
         Left            =   1500
         TabIndex        =   9
         Top             =   1000
         Width           =   495
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   "Command"
      Height          =   735
      Left            =   240
      TabIndex        =   11
      Top             =   2280
      Width           =   4095
   End
End
Attribute VB_Name = "frmAskTxNumber"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

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
    
    Dim tmpStr As String
    Dim MaxNumber As Double
    
    MaxNumber = 99999999
 
    
    If InRange(Me.txtTxNumberFrom, "Number", MaxNumber, 1, True) Then
        If InRange(Me.txtTxNumberTo, "Number", MaxNumber, 1, True) Then
            If Val(txtTxNumberFrom) > Val(txtTxNumberTo) Then
                tmpStr = txtTxNumberFrom
                txtTxNumberFrom = txtTxNumberTo
                txtTxNumberTo = tmpStr
            End If
            If Me.fraTxNumber.Caption = "Order Number" Then
                tmpStr = Trim(txtTxNumberFrom)
                txtTxNumberFrom = tmpStr
                tmpStr = Trim(txtTxNumberTo)
                txtTxNumberTo = tmpStr
            Else
                tmpStr = "00000000" & txtTxNumberFrom
                txtTxNumberFrom = Right(tmpStr, 8)
                tmpStr = "00000000" & txtTxNumberTo
                txtTxNumberTo = Right(tmpStr, 8)
            End If
 
            frmAskTxNumber.Refresh
            '   Set Formula
            frmCtlCrw.CrystalReport1.Formulas(0) = "AskTxNumberFrom = '" & _
                        Me.txtTxPrefixFrom & Me.txtTxNumberFrom.Text & "'"
            frmCtlCrw.CrystalReport1.Formulas(1) = "AskTxNumberTo = '" & _
                        Me.txtTxPrefixTo & Me.txtTxNumberTo.Text & "'"
            If Me.fraTxNumber.Caption = "Bar Code Tag" Then
            '   Bar Code Tag
              frmCtlCrw.CrystalReport1.SelectionFormula = "{BarCodePool.TxNumber} " & _
                "IN '" & Me.txtTxPrefixFrom & Me.txtTxNumberFrom.Text & "' " & _
                "TO '" & Me.txtTxPrefixTo & Me.txtTxNumberTo.Text & "'"
            '   Wholesales
            ElseIf Me.fraTxNumber.Caption = "Wholesales Number" Then
              frmCtlCrw.CrystalReport1.SelectionFormula = "({TxHeader.TxNumber} " & _
                "IN '" & Me.txtTxPrefixFrom & Me.txtTxNumberFrom.Text & "' " & _
                "TO '" & Me.txtTxPrefixTo & Me.txtTxNumberTo.Text & "')"
            Else
            '   Invoice or Order
              frmCtlCrw.CrystalReport1.SelectionFormula = "({TxHeader.TxType} = " & _
                "'" & Me.txtTxPrefixFrom & "' AND ({TxHeader.TxNumber} " & _
                "IN '" & Me.txtTxPrefixFrom & Me.txtTxNumberFrom.Text & "' " & _
                "TO '" & Me.txtTxPrefixTo & Me.txtTxNumberTo.Text & "'))"
            End If
            'MsgBox frmCtlCrw.crystalreport1.SelectionFormula
            Screen.MousePointer = vbHourglass
            Unload Me
            frmCtlCrw.CrystalReport1.Action = 1
            Screen.MousePointer = vbDefault
        Else    '   TxNumberTo out of range
            Me.txtTxNumberTo.SetFocus
            Exit Sub
        End If
    Else    '   TxNumberFrom out of range
        Me.txtTxNumberFrom.SetFocus
    End If

cmdOK_Click_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
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
   On Error GoTo cmdReset_Click_Err

    Me.txtTxNumberFrom = "1"
    Me.txtTxNumberTo = "99999999"
    Me.txtTxNumberFrom.SetFocus

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
    Me.Icon = LoadPicture(SynergyIcon)
    
    If Me.Caption Like "Invoice*" Then
        Me.fraTxNumber.Caption = "Invoice Number"
        Me.txtTxPrefixFrom = "RC"
        Me.txtTxPrefixTo = "RC"
        Me.txtTxNumberTo = "99999999"
    ElseIf Me.Caption Like "Order*" Then
        Me.fraTxNumber.Caption = "Order Number"
        Me.txtTxPrefixFrom = "SA"
        Me.txtTxPrefixTo = "SA"
        Me.txtTxNumberTo = "99999999"
    ElseIf Me.Caption Like "Wholesales*" Then
        Me.fraTxNumber.Caption = "Wholesales Number"
        Me.txtTxPrefixFrom = "WC"
        Me.txtTxPrefixTo = "WR"
        Me.txtTxNumberTo = "99999999"
    Else                                ' Bar Code Tag
        Me.fraTxNumber.Caption = "Bar Code Tag"
        Me.txtTxPrefixFrom = "SR"
        Me.txtTxPrefixTo = "SR"
        Me.txtTxNumberTo = "99999999"
   End If
Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub

Private Sub txtTxNumberFrom_Click()

    On Error GoTo txtTxNumberFrom_Click_Err

    SendKeys "{home}+{end}", True

txtTxNumberFrom_Click_Exit:  ' SDVB autocode
    On Error Resume Next     ' SDVB autocode
    Exit Sub                 ' SDVB autocode
txtTxNumberFrom_Click_Err:   ' SDVB autocode
    MsgBox Error             ' SDVB autocode
    Resume txtTxNumberFrom_Click_Exit

End Sub

Private Sub txtTxNumberFrom_GotFocus()

    On Error GoTo txtTxNumberFrom_GotFocus_Err

    SendKeys "{home}+{end}", True

txtTxNumberFrom_GotFocus_Exit:  ' SDVB autocode
    On Error Resume Next        ' SDVB autocode
    Exit Sub                    ' SDVB autocode
txtTxNumberFrom_GotFocus_Err:   ' SDVB autocode
    MsgBox Error                ' SDVB autocode
    Resume txtTxNumberFrom_GotFocus_Exit

End Sub


Private Sub txtTxNumberFrom_KeyPress(KeyAscii As Integer)

    On Error GoTo txtTxNumberFrom_KeyPress_Err

    KeyAscii = KeyNumbers(KeyAscii)

txtTxNumberFrom_KeyPress_Exit:  ' SDVB autocode
    On Error Resume Next        ' SDVB autocode
    Exit Sub                    ' SDVB autocode
txtTxNumberFrom_KeyPress_Err:   ' SDVB autocode
    MsgBox Error                ' SDVB autocode
    Resume txtTxNumberFrom_KeyPress_Exit

End Sub



Private Sub txtTxNumberTo_Click()

    On Error GoTo txtTxNumberTo_Click_Err

    SendKeys "{home}+{end}", True

txtTxNumberTo_Click_Exit:  ' SDVB autocode
    On Error Resume Next   ' SDVB autocode
    Exit Sub               ' SDVB autocode
txtTxNumberTo_Click_Err:   ' SDVB autocode
    MsgBox Error           ' SDVB autocode
    Resume txtTxNumberTo_Click_Exit

End Sub

Private Sub txtTxNumberTo_GotFocus()

    On Error GoTo txtTxNumberTo_GotFocus_Err

    SendKeys "{home}+{end}", True

txtTxNumberTo_GotFocus_Exit:  ' SDVB autocode
    On Error Resume Next      ' SDVB autocode
    Exit Sub                  ' SDVB autocode
txtTxNumberTo_GotFocus_Err:   ' SDVB autocode
    MsgBox Error              ' SDVB autocode
    Resume txtTxNumberTo_GotFocus_Exit

End Sub

Private Sub txtTxNumberTo_KeyPress(KeyAscii As Integer)

    On Error GoTo txtTxNumberTo_KeyPress_Err

    KeyAscii = KeyNumbers(KeyAscii)

txtTxNumberTo_KeyPress_Exit:  ' SDVB autocode
    On Error Resume Next      ' SDVB autocode
    Exit Sub                  ' SDVB autocode
txtTxNumberTo_KeyPress_Err:   ' SDVB autocode
    MsgBox Error              ' SDVB autocode
    Resume txtTxNumberTo_KeyPress_Exit

End Sub



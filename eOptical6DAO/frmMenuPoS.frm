VERSION 5.00
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Begin VB.Form frmMenuPoS 
   BorderStyle     =   0  'None
   Caption         =   "Point-of-Service"
   ClientHeight    =   3585
   ClientLeft      =   3135
   ClientTop       =   3150
   ClientWidth     =   6180
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3585
   ScaleWidth      =   6180
   ShowInTaskbar   =   0   'False
   Begin Threed.SSCommand SSCommand4 
      Height          =   1575
      Left            =   4200
      TabIndex        =   4
      Top             =   1860
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Re-Print Claim Form"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   1575
      Left            =   2160
      TabIndex        =   3
      Top             =   1860
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Re-Print Invoice"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   1575
      Left            =   120
      TabIndex        =   2
      Top             =   1860
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Re-Print Order"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdDailyClosing 
      Height          =   1575
      Left            =   2160
      TabIndex        =   1
      Top             =   120
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Daily Closing"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   1575
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Order Entry"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmMenuPoS"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdDailyClosing_Click()
    Dim strReportName As String
    
    
    Screen.MousePointer = vbHourglass
    strReportName = "Daily Cash Receipts"
       
    If SetRptFileName(strReportName, 0) Then
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskDateFrom = " & _
            "Date(" & (Year(Now)) & "," & _
                    (Month(Now)) & "," & _
                    (Day(Now)) & ")"
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskDateTo = " & _
            "Date(" & (Year(Now)) & "," & _
                    (Month(Now)) & "," & _
                    (Day(Now)) & ")"
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            "({TxHeader.DateOfEntry} IN Date(" & _
             (Year(Now)) & "," & _
             (Month(Now)) & "," & _
             (Day(Now)) & ")"
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " TO Date(" & (Year(Now)) & "," & _
                          (Month(Now)) & "," & _
                          (Day(Now)) & "))"
    
        frmCtlCrw.CrystalReport1.SelectionFormula = _
        frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType} IN 'RCRSSA')"        ' 20030725 Excluded WC in RCRSSAWC
        frmCtlCrw.CrystalReport1.Action = 1
        Screen.MousePointer = vbDefault
    End If

        
    strReportName = "Sales Return Journal"
    Screen.MousePointer = vbHourglass
       
    If SetRptFileName(strReportName, 0) Then
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskDateFrom = " & _
            "Date(" & (Year(Now)) & "," & _
                    (Month(Now)) & "," & _
                    (Day(Now)) & ")"
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskDateTo = " & _
            "Date(" & (Year(Now)) & "," & _
                    (Month(Now)) & "," & _
                    (Day(Now)) & ")"
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            "({TxHeader.DateOfEntry} IN Date(" & _
             (Year(Now)) & "," & _
             (Month(Now)) & "," & _
             (Day(Now)) & ")"
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " TO Date(" & (Year(Now)) & "," & _
                          (Month(Now)) & "," & _
                          (Day(Now)) & "))"
    
        frmCtlCrw.CrystalReport1.SelectionFormula = _
        frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType}='RS')"
        frmCtlCrw.CrystalReport1.Action = 1
        Screen.MousePointer = vbDefault
    End If
    
' 20030725 Changed to a new report
'    strReportName = "Payment Summary"
    strReportName = "Receipts Report"
    Screen.MousePointer = vbHourglass
       
    If SetRptFileName(strReportName, 0) Then
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskDateFrom = " & _
            "Date(" & (Year(Now)) & "," & _
                    (Month(Now)) & "," & _
                    (Day(Now)) & ")"
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskDateTo = " & _
            "Date(" & (Year(Now)) & "," & _
                    (Month(Now)) & "," & _
                    (Day(Now)) & ")"
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            "({TxHeader.DateOfEntry} IN Date(" & _
             (Year(Now)) & "," & _
             (Month(Now)) & "," & _
             (Day(Now)) & ")"
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " TO Date(" & (Year(Now)) & "," & _
                          (Month(Now)) & "," & _
                          (Day(Now)) & "))"
    
        frmCtlCrw.CrystalReport1.SelectionFormula = _
        frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType} IN 'LARCRSSA')"        ' Old report uses LARCRSSAWC
        frmCtlCrw.CrystalReport1.Action = 1
        Screen.MousePointer = vbDefault
    End If
    
' 20030725 Changed to a new report
'    strReportName = "Orders Summary (By Date)"
    strReportName = "Orders Report (By Date)"
    Screen.MousePointer = vbHourglass
       
    If SetRptFileName(strReportName, 0) Then
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskDateFrom = " & _
            "Date(" & (Year(Now)) & "," & _
                    (Month(Now)) & "," & _
                    (Day(Now)) & ")"
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskDateTo = " & _
            "Date(" & (Year(Now)) & "," & _
                    (Month(Now)) & "," & _
                    (Day(Now)) & ")"
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            "({TxHeader.DateOfEntry} IN Date(" & _
             (Year(Now)) & "," & _
             (Month(Now)) & "," & _
             (Day(Now)) & ")"
        frmCtlCrw.CrystalReport1.SelectionFormula = _
            frmCtlCrw.CrystalReport1.SelectionFormula & _
            " TO Date(" & (Year(Now)) & "," & _
                          (Month(Now)) & "," & _
                          (Day(Now)) & "))"
    
        frmCtlCrw.CrystalReport1.SelectionFormula = _
        frmCtlCrw.CrystalReport1.SelectionFormula & _
            " AND ({TxHeader.TxType}='SA')"
        frmCtlCrw.CrystalReport1.Action = 1
        Screen.MousePointer = vbDefault
    End If

End Sub

Private Sub cmdDailyClosing_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub SSCommand1_Click()
    Screen.MousePointer = vbHourglass
    frmSalesOrder.Show
End Sub


Private Sub SSCommand1_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand2_Click()
    Call PrintOrder(0, 0)
End Sub


Private Sub SSCommand2_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand3_Click()
    Call PrintInvoice(0, 0)
End Sub


Private Sub SSCommand3_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand4_Click()
       Call PrintClaimReceipt(0, 0)
End Sub


Private Sub SSCommand4_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

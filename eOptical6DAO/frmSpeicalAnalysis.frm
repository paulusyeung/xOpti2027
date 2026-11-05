VERSION 5.00
Begin VB.Form frmSpecialAnalysis 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "frmSpecialAnalysis"
   ClientHeight    =   6375
   ClientLeft      =   2775
   ClientTop       =   3075
   ClientWidth     =   6180
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6375
   ScaleWidth      =   6180
   ShowInTaskbar   =   0   'False
   Begin VB.Frame fraAvaCost 
      Caption         =   "Available Cost:"
      Height          =   2295
      Left            =   0
      TabIndex        =   17
      Top             =   3120
      Visible         =   0   'False
      Width           =   6135
      Begin VB.CheckBox chkCost 
         Height          =   255
         Index           =   1
         Left            =   1700
         TabIndex        =   19
         Top             =   480
         Value           =   1  'Checked
         Visible         =   0   'False
         Width           =   1400
      End
      Begin VB.CheckBox chkCost 
         Height          =   255
         Index           =   0
         Left            =   240
         TabIndex        =   18
         Top             =   480
         Value           =   1  'Checked
         Visible         =   0   'False
         Width           =   1400
      End
   End
   Begin VB.CheckBox chkCat 
      Height          =   255
      Index           =   3
      Left            =   4520
      TabIndex        =   10
      Top             =   960
      Value           =   1  'Checked
      Visible         =   0   'False
      Width           =   1400
   End
   Begin VB.CheckBox chkCat 
      Height          =   255
      Index           =   2
      Left            =   3120
      TabIndex        =   9
      Top             =   960
      Value           =   1  'Checked
      Visible         =   0   'False
      Width           =   1400
   End
   Begin VB.CheckBox chkCat 
      Height          =   255
      Index           =   1
      Left            =   1700
      TabIndex        =   8
      Top             =   960
      Value           =   1  'Checked
      Visible         =   0   'False
      Width           =   1400
   End
   Begin VB.Frame fraPrinter 
      Caption         =   "Printer"
      Height          =   735
      Left            =   4680
      TabIndex        =   6
      Top             =   5520
      Width           =   1455
      Begin VB.CommandButton cmdPrnSetup 
         Caption         =   "&Setup"
         Height          =   375
         Left            =   120
         TabIndex        =   3
         Top             =   240
         Width           =   1200
      End
   End
   Begin VB.Frame fraCommand 
      Caption         =   "Command"
      Height          =   735
      Left            =   0
      TabIndex        =   5
      Top             =   5520
      Width           =   4575
      Begin VB.CommandButton cmdExit 
         Caption         =   "&Exit"
         Height          =   375
         Left            =   3120
         TabIndex        =   2
         Top             =   240
         Width           =   1200
      End
      Begin VB.CommandButton cmdReset 
         Caption         =   "&Reset"
         Height          =   375
         Left            =   1680
         TabIndex        =   1
         Top             =   240
         Width           =   1200
      End
      Begin VB.CommandButton cmdOK 
         Caption         =   "&OK"
         Height          =   375
         Left            =   240
         TabIndex        =   0
         Top             =   240
         Width           =   1200
      End
   End
   Begin VB.Frame fraAvaCategory 
      Caption         =   "Available Category:"
      Height          =   2775
      Left            =   0
      TabIndex        =   4
      Top             =   120
      Width           =   6135
      Begin VB.CheckBox chkCat 
         Height          =   255
         Index           =   9
         Left            =   1700
         TabIndex        =   16
         Top             =   1800
         Value           =   1  'Checked
         Visible         =   0   'False
         Width           =   1400
      End
      Begin VB.CheckBox chkCat 
         Height          =   255
         Index           =   8
         Left            =   240
         TabIndex        =   15
         Top             =   1800
         Value           =   1  'Checked
         Visible         =   0   'False
         Width           =   1400
      End
      Begin VB.CheckBox chkCat 
         Height          =   255
         Index           =   7
         Left            =   4520
         TabIndex        =   14
         Top             =   1320
         Value           =   1  'Checked
         Visible         =   0   'False
         Width           =   1400
      End
      Begin VB.CheckBox chkCat 
         Height          =   255
         Index           =   6
         Left            =   3110
         TabIndex        =   13
         Top             =   1320
         Value           =   1  'Checked
         Visible         =   0   'False
         Width           =   1400
      End
      Begin VB.CheckBox chkCat 
         Height          =   255
         Index           =   5
         Left            =   1700
         TabIndex        =   12
         Top             =   1320
         Value           =   1  'Checked
         Visible         =   0   'False
         Width           =   1400
      End
      Begin VB.CheckBox chkCat 
         Height          =   255
         Index           =   4
         Left            =   240
         TabIndex        =   11
         Top             =   1320
         Value           =   1  'Checked
         Visible         =   0   'False
         Width           =   1400
      End
      Begin VB.CheckBox chkCat 
         Height          =   255
         Index           =   0
         Left            =   240
         TabIndex        =   7
         Top             =   840
         Value           =   1  'Checked
         Visible         =   0   'False
         Width           =   1400
      End
   End
End
Attribute VB_Name = "frmSpecialAnalysis"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Const intMaxCategory As Integer = 10
Dim intAvaCategory As Integer


Private Function Ava_CategoryName() As Integer
    
    Dim i As Integer
    Dim myDB As Database
    Dim TargetRS, SourceRS As Recordset
    Dim PriCriteria, SecCriteria As String
    
    ' Get Available Category List
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")
    PriCriteria = "Select distinct CategoryCode from [RptBrandAnalysis] order by CategoryCode"
    Set TargetRS = myDB.OpenRecordset("Category", dbOpenDynaset, dbReadOnly)
    Set SourceRS = myDB.OpenRecordset(PriCriteria, dbOpenDynaset, dbReadOnly)
  
    Screen.MousePointer = vbHourglass
    
    For i = 0 To 9
        chkCat(i).Visible = False
    Next
    
    i = -1
    Do While Not SourceRS.EOF
        SecCriteria = "CategoryCode=" & SourceRS!CategoryCode
        TargetRS.FindFirst SecCriteria
        If Not TargetRS.NoMatch Then
            i = i + 1
            chkCat(i).Caption = TargetRS!Categoryname
            chkCat(i).Visible = True
        End If
        SourceRS.MoveNext
    Loop
    
    TargetRS.Close
    SourceRS.Close                      ' Close table.
    myDB.Close                          ' Close database.
    Screen.MousePointer = vbDefault
    
    Ava_CategoryName = i
End Function

Private Sub cmdExit_Click()

    On Error GoTo cmdExit_Click_Err
    Call ofx_CloseForm(frmSpecialAnalysis)

cmdExit_Click_Exit:       ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdExit_Click_Err:        ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdExit_Click_Exit

End Sub


Private Sub cmdOK_Click()

    On Error GoTo cmdOK_Click_Err
    
        
    If optDeptAll Then  ' Reset full choice
        Me.txtFromDept.Text = "*"
        Me.txtDeptFrom.Text = "*"
        Me.txtFromClass.Text = "*"
        Me.txtClassFrom.Text = "*"
        Me.txtFromCat.Text = "*"
        Me.txtCatFrom.Text = "*"
    End If
    If CrwRptName = "Inventory Ledger" Then
    
        If ssDateFrom.Date > Date Then
            Beep
            MsgBox "Greater than current date", 0, "Validation Error"
            Me.ssDateFrom.SetFocus
            Exit Sub
        End If
    End If
    
    Screen.MousePointer = vbArrowHourglass
      '   Set Formula
    frmCtlCrw.CrystalReport1.Formulas(0) = "AskCat = '" & Me.txtFromCat.Text & "'"
    frmCtlCrw.CrystalReport1.Formulas(1) = "AskClass = '" & Me.txtFromClass.Text & "'"
    frmCtlCrw.CrystalReport1.Formulas(2) = "AskDept = '" & Me.txtFromDept.Text & "'"
    frmCtlCrw.CrystalReport1.Formulas(3) = "AskXcludeZeroQty =" & Me.optExcludeZeroQty
    
    frmCtlCrw.CrystalReport1.SelectionFormula = "{Inventory.DepartmentCode} like {@AskDept}" & _
        " and {Inventory.ClassCode} like {@AskClass} and {Inventory.CategoryCode} like {@AskCat}"
  
    If CrwRptName = "Inventory Ledger" Then
      frmCtlCrw.CrystalReport1.Formulas(3) = "AskLedgerDateFrom = " & _
            "Date(" & (Year(Me.ssDateFrom)) & "," & _
                    (Month(Me.ssDateFrom)) & "," & _
                    (Day(Me.ssDateFrom)) & ")"
      frmCtlCrw.CrystalReport1.Formulas(4) = "AskXcludeZeroQty =" & Me.optExcludeZeroQty
      frmCtlCrw.CrystalReport1.SelectionFormula = frmCtlCrw.CrystalReport1.SelectionFormula & _
                " and {@XQualify}"
    End If
    
    If CrwRptName = "Insufficient Stock Listing" Then
      frmCtlCrw.CrystalReport1.SelectionFormula = frmCtlCrw.CrystalReport1.SelectionFormula & _
                " and {@XQualify}"
    End If
    
    If optExcludeZeroQty = True Then
      frmCtlCrw.CrystalReport1.SelectionFormula = frmCtlCrw.CrystalReport1.SelectionFormula & _
                " and {Inventory.QtyTotalOnHand} <> 0 "
    End If

    Call ofx_CloseForm(frmSpecialAnalysis)
    Call PrintIt

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
    Dim strSQL As String
    On Error GoTo cmdReset_Click_Err
    
    Me.txtFromDept.Text = "*"
    Me.txtDeptFrom.Text = "*"
    Me.txtFromClass.Text = "*"
    Me.txtClassFrom.Text = "*"
    Me.txtFromCat.Text = "*"
    Me.txtCatFrom.Text = "*"
    Me.ssDateFrom.Date = CurrentDate
    Me.optDeptAll = True
    Me.optExcludeZeroQty = False

    strSQL = "SELECT distinct ClassName, ClassCode FROM Class " & _
               " ORDER BY ClassName"
    dtcFileClass.RecordSource = strSQL
    dtcFileClass.Refresh
    dtcFileClass.UpdateControls
    
    strSQL = "SELECT distinct CategoryName," & _
             "CategoryCode FROM Category " & _
             " ORDER BY CategoryName"
    dtcFileCategory.RecordSource = strSQL
    dtcFileCategory.Refresh
    dtcFileCategory.UpdateControls
      
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
    Me.Caption = CrwRptName
    Me.Icon = LoadPicture(SynergyIcon)
    
    intAvaCategory = Ava_CategoryName
    
    If IsSecurityEnabled Then
        If IsCostOK(pyUserSLevel) Then
            fraavacost.Visible = True
        End If
    Else
        fraavacost.Visible = False
    End If
    

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit
End Sub










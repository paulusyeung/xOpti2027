VERSION 5.00
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmInventoryChoice 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "frmInventoryChoice"
   ClientHeight    =   7575
   ClientLeft      =   2550
   ClientTop       =   1065
   ClientWidth     =   6660
   Icon            =   "frmInventoryChoice.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   7575
   ScaleWidth      =   6660
   ShowInTaskbar   =   0   'False
   Begin VB.CheckBox chkLEDate 
      Caption         =   "Select Last Recevied Date <="
      Height          =   195
      Left            =   720
      TabIndex        =   5
      Top             =   6120
      Width           =   2595
   End
   Begin VB.OptionButton optExcludeZeroQty 
      Alignment       =   1  'Right Justify
      Caption         =   "Excluding items with zero balance"
      Height          =   375
      Left            =   480
      TabIndex        =   26
      Top             =   5520
      Width           =   3015
   End
   Begin VB.Frame Frame2 
      Caption         =   "Class Selection:"
      Height          =   1695
      Left            =   240
      TabIndex        =   21
      Top             =   1920
      Width           =   6135
      Begin VB.TextBox txtClassFrom 
         Height          =   330
         Left            =   3000
         TabIndex        =   3
         Text            =   " *"
         Top             =   600
         Width           =   2500
      End
      Begin VB.Data dtcFileClass 
         Caption         =   "Class"
         Connect         =   "Access 2000;"
         DatabaseName    =   ""
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   240
         Options         =   0
         ReadOnly        =   -1  'True
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT distinct ClassCode, ClassName from Class order by ClassName"
         Top             =   1320
         Visible         =   0   'False
         Width           =   5280
      End
      Begin VB.TextBox txtFromClass 
         Enabled         =   0   'False
         Height          =   330
         Left            =   5520
         TabIndex        =   22
         Text            =   " *"
         Top             =   600
         Visible         =   0   'False
         Width           =   500
      End
      Begin MSDBCtls.DBList dbListClass 
         Bindings        =   "frmInventoryChoice.frx":068A
         DataField       =   "classcode"
         DataSource      =   "dtcFileClass"
         Height          =   1035
         Left            =   240
         TabIndex        =   24
         Top             =   240
         Width           =   1800
         _ExtentX        =   3175
         _ExtentY        =   1826
         _Version        =   393216
         BackColor       =   -2147483643
         ForeColor       =   -2147483640
         ListField       =   "classname"
         BoundColumn     =   "classcode"
      End
      Begin VB.Label Label3 
         Caption         =   "Select:"
         Height          =   255
         Left            =   2400
         TabIndex        =   23
         Top             =   600
         Width           =   600
      End
   End
   Begin VB.Frame Frame5 
      Caption         =   "Printer"
      Height          =   735
      Left            =   4920
      TabIndex        =   18
      Top             =   6600
      Width           =   1455
      Begin VB.CommandButton cmdPrnSetup 
         Caption         =   "&Setup"
         Height          =   330
         Left            =   120
         TabIndex        =   10
         Top             =   240
         Width           =   1200
      End
   End
   Begin VB.Frame Frame4 
      Caption         =   "Command"
      Height          =   735
      Left            =   240
      TabIndex        =   17
      Top             =   6600
      Width           =   4575
      Begin VB.CommandButton cmdExit 
         Caption         =   "&Exit"
         Height          =   330
         Left            =   3120
         TabIndex        =   9
         Top             =   240
         Width           =   1200
      End
      Begin VB.CommandButton cmdReset 
         Caption         =   "&Reset"
         Height          =   330
         Left            =   1680
         TabIndex        =   8
         Top             =   240
         Width           =   1200
      End
      Begin VB.CommandButton cmdOK 
         Caption         =   "&OK"
         Height          =   330
         Left            =   240
         TabIndex        =   7
         Top             =   240
         Width           =   1200
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   "Category Selection:"
      Height          =   1695
      Left            =   240
      TabIndex        =   14
      Top             =   3720
      Width           =   6135
      Begin VB.TextBox txtFromCat 
         Enabled         =   0   'False
         Height          =   330
         Left            =   5520
         TabIndex        =   20
         Text            =   " *"
         Top             =   600
         Visible         =   0   'False
         Width           =   500
      End
      Begin VB.Data dtcFileCategory 
         Caption         =   "Category"
         Connect         =   "Access 2000;"
         DatabaseName    =   ""
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   240
         Options         =   0
         ReadOnly        =   -1  'True
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "select distinct CategoryCode, CategoryName from Category order by CategoryName"
         Top             =   1320
         Visible         =   0   'False
         Width           =   5280
      End
      Begin VB.TextBox txtCatFrom 
         Height          =   330
         Left            =   3000
         TabIndex        =   4
         Text            =   " *"
         Top             =   600
         Width           =   2500
      End
      Begin MSDBCtls.DBList dbListCategory 
         Bindings        =   "frmInventoryChoice.frx":06A5
         DataField       =   "categorycode"
         DataSource      =   "dtcFileCategory"
         Height          =   1035
         Left            =   240
         TabIndex        =   15
         Top             =   240
         Width           =   1800
         _ExtentX        =   3175
         _ExtentY        =   1826
         _Version        =   393216
         BackColor       =   -2147483643
         ForeColor       =   -2147483640
         ListField       =   "categoryname"
         BoundColumn     =   "categorycode"
      End
      Begin VB.Label Label5 
         Caption         =   "Select:"
         Height          =   255
         Left            =   2400
         TabIndex        =   16
         Top             =   600
         Width           =   600
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Department Selection:"
      Height          =   1695
      Left            =   240
      TabIndex        =   11
      Top             =   120
      Width           =   6135
      Begin VB.TextBox txtFromDept 
         Enabled         =   0   'False
         Height          =   330
         Left            =   5520
         TabIndex        =   19
         Text            =   " *"
         Top             =   720
         Visible         =   0   'False
         Width           =   500
      End
      Begin VB.Data dtcFileDepartment 
         Caption         =   "Department"
         Connect         =   "Access 2000;"
         DatabaseName    =   ""
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   240
         Options         =   0
         ReadOnly        =   -1  'True
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "Department"
         Top             =   1320
         Visible         =   0   'False
         Width           =   5280
      End
      Begin VB.OptionButton optDeptSelect 
         Caption         =   "Select"
         Height          =   315
         Left            =   4080
         TabIndex        =   1
         Top             =   240
         Width           =   975
      End
      Begin VB.OptionButton optDeptAll 
         Caption         =   "All"
         Height          =   315
         Left            =   2280
         TabIndex        =   0
         Top             =   240
         Value           =   -1  'True
         Width           =   975
      End
      Begin VB.TextBox txtDeptFrom 
         Height          =   330
         Left            =   3000
         TabIndex        =   2
         Text            =   " *"
         Top             =   720
         Width           =   2500
      End
      Begin MSDBCtls.DBList dbListDepartment 
         Bindings        =   "frmInventoryChoice.frx":06C3
         DataField       =   "departmentCode"
         DataSource      =   "dtcFileDepartment"
         Height          =   1035
         Left            =   240
         TabIndex        =   12
         Top             =   240
         Width           =   1800
         _ExtentX        =   3175
         _ExtentY        =   1826
         _Version        =   393216
         MatchEntry      =   -1  'True
         BackColor       =   -2147483643
         ForeColor       =   -2147483640
         ListField       =   "departmentName"
         BoundColumn     =   "departmentCode"
      End
      Begin VB.Label Label1 
         Caption         =   "Select:"
         Height          =   255
         Left            =   2400
         TabIndex        =   13
         Top             =   720
         Width           =   600
      End
   End
   Begin SSCalendarWidgets_A.SSDateCombo SSDateFrom 
      Height          =   330
      Left            =   3480
      TabIndex        =   6
      Top             =   6075
      Visible         =   0   'False
      Width           =   2895
      _Version        =   65543
      _ExtentX        =   5106
      _ExtentY        =   582
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
      Format          =   "MMMM DD, YYYY"
   End
   Begin VB.Label Label2 
      Caption         =   "Ledger details on or after date:"
      Height          =   330
      Left            =   720
      TabIndex        =   25
      Top             =   6075
      Visible         =   0   'False
      Width           =   2415
   End
End
Attribute VB_Name = "frmInventoryChoice"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub chkLEDate_Click()
    SSDateFrom.Enabled = chkLEDate.Value
End Sub

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
    
        
    If optDeptAll Then  ' Reset full choice
        Me.txtFromDept = "*"
        Me.txtDeptFrom = "*"
        Me.txtFromClass = "*"
        Me.txtClassFrom = "*"
        Me.txtFromCat = "*"
        Me.txtCatFrom = "*"
    End If
    If CrwRptName = "Inventory Ledger" Then
    
        If SSDateFrom.Date > Date Then
            Beep
            MsgBox "Greater than current date", 0, "Validation Error"
            Me.SSDateFrom.SetFocus
            Exit Sub
        End If
    End If
    
    Screen.MousePointer = vbArrowHourglass
      '   Set Formula
    frmCtlCrw.CrystalReport1.Formulas(0) = "AskCat = '" & Me.txtFromCat & "'"
    frmCtlCrw.CrystalReport1.Formulas(1) = "AskClass = '" & Me.txtFromClass & "'"
    frmCtlCrw.CrystalReport1.Formulas(2) = "AskDept = '" & Me.txtFromDept & "'"
    frmCtlCrw.CrystalReport1.Formulas(3) = "AskXcludeZeroQty =" & Me.optExcludeZeroQty
    
    frmCtlCrw.CrystalReport1.SelectionFormula = "{Inventory.DepartmentCode} like {@AskDept}" & _
        " and {Inventory.ClassCode} like {@AskClass} and {Inventory.CategoryCode} like {@AskCat}"
  
    If CrwRptName = "Inventory Ledger" Then
      frmCtlCrw.CrystalReport1.Formulas(3) = "AskLedgerDateFrom = " & _
            "Date(" & (Year(Me.SSDateFrom)) & "," & _
                    (Month(Me.SSDateFrom)) & "," & _
                    (Day(Me.SSDateFrom)) & ")"
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

    If chkLEDate.Value Then
      frmCtlCrw.CrystalReport1.SelectionFormula = frmCtlCrw.CrystalReport1.SelectionFormula & _
                " and {Inventory.DateLastReceived} <= " & _
                "Date(" & (Year(SSDateFrom)) & "," & _
                    (Month(SSDateFrom)) & "," & _
                    (Day(SSDateFrom)) & ")"
    End If

    Call ofx_CloseForm(frmInventoryChoice)
    Call PrintIt
'    Screen.MousePointer = vbHourglass
'    Unload Me
'    frmCtlCrw.CrystalReport1.Action = 1
    Screen.MousePointer = vbDefault

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

    Me.txtFromDept = "*"
    Me.txtDeptFrom = "*"
    Me.txtFromClass = "*"
    Me.txtClassFrom = "*"
    Me.txtFromCat = "*"
    Me.txtCatFrom = "*"
    Me.SSDateFrom.Date = CurrentDate
    Me.optDeptAll = True
    Dim strSQL As String
      strSQL = "SELECT distinct ClassCode, ClassName FROM Class " & _
               " ORDER BY ClassName"
    dtcFileClass.RecordSource = strSQL
    dtcFileClass.Refresh
    dtcFileClass.UpdateControls
      strSQL = "SELECT distinct CategoryCode," & _
             "CategoryName FROM Category " & _
             " ORDER BY CategoryName"
    dtcFileCategory.RecordSource = strSQL
    dtcFileCategory.Refresh
    dtcFileCategory.UpdateControls
    Me.optDeptAll.SetFocus
    

cmdReset_Click_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdReset_Click_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdReset_Click_Exit

End Sub


Private Sub dbListCategory_Click()
     Call txtCatFrom_Click
End Sub

Private Sub dbListClass_Click()
     Call txtClassFrom_Click
End Sub

Private Sub dbListDepartment_Click()
    Call txtDeptFrom_Click
End Sub

Private Sub Form_Load()
   On Error GoTo Form_Load_Err

    Call ofx_CenterForm(Me)
    Me.Caption = CrwRptName
    Me.Icon = LoadPicture(SynergyIcon)
    
    SSDateFrom.MaxDate = Date
    
    If IsSecurityEnabled Then
        If IsCostOK(pyUserSLevel) Then
            optExcludeZeroQty.Enabled = True
            optExcludeZeroQty = False
        End If
    Else
        optExcludeZeroQty.Enabled = True
        optExcludeZeroQty = False
    End If
    
    If CrwRptName = "Inventory Ledger" Then
        Me.Label2.Visible = True
        Me.SSDateFrom.Visible = True
    Else
        Me.Label2.Visible = False
        Me.SSDateFrom.Visible = False
    End If
    
    If CrwRptName = "Insufficient Stock Listing" Then
        optExcludeZeroQty.Enabled = False
    End If
    
    If CrwRptName = "Cost and Margin of Goods Sold" Then
        optExcludeZeroQty.Enabled = False
    End If
    
    If ((CrwRptName = "Inventory Listing (By LSP)") Or (CrwRptName = "Inventory Listing (Short)")) Then
        chkLEDate.Visible = True
        SSDateFrom.Visible = True
        SSDateFrom.Enabled = False
    End If
    
    Me.dtcFileDepartment.DatabaseName = sDBName
    Me.dtcFileClass.DatabaseName = sDBName
    Me.dtcFileCategory.DatabaseName = sDBName
    
    Screen.MousePointer = vbDefault
  
    

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit
End Sub


Private Sub optDeptAll_Click()

    On Error GoTo optDeptAll_Click_Err

' removed on 2004-04-1
'    cmdReset_Click
    
    ' replaced by these 2004-04-1
    optDeptAll.Value = True
    Me.txtFromDept = "*"
    Me.txtDeptFrom = "*"
    Me.txtFromClass = "*"
    Me.txtClassFrom = "*"
    Me.txtFromCat = "*"
    Me.txtCatFrom = "*"

optDeptAll_Click_Exit:    ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
optDeptAll_Click_Err:     ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume optDeptAll_Click_Exit

End Sub

Private Sub txtCatFrom_Click()

    On Error GoTo txtCatFrom_Click_Err

  If (Trim(txtDeptFrom) = "*" And Trim(txtClassFrom) <> "*") Then
' If enabled, would cause "invalid procedure call" when Form Loaded
'        cmdOK.SetFocus
        Exit Sub
    Else
        If dtcFileCategory.Recordset.RecordCount > 0 Then
            txtCatFrom = dbListCategory.Text
            txtFromCat = dbListCategory.BoundText
        End If
    End If

txtCatFrom_Click_Exit:    ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
txtCatFrom_Click_Err:     ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume txtCatFrom_Click_Exit

End Sub

Private Sub txtCatFrom_DblClick()
    txtCatFrom.Text = "*"
End Sub

Private Sub txtClassFrom_Click()

    On Error GoTo txtClassFrom_Click_Err

    optDeptAll = False
    optDeptSelect = True
    If dtcFileClass.Recordset.RecordCount > 0 Then
        txtClassFrom = dbListClass.Text
        txtFromClass = dbListClass.BoundText
    End If
    txtCatFrom = "*"
    txtFromCat = "*"
    Dim strSQL As String
         strSQL = "SELECT distinct CategoryCode," & _
             "CategoryName FROM Category " & _
             "WHERE DepartmentCode = '" & txtFromDept & _
             "' AND ClassCode = '" & txtFromClass & _
             "' ORDER BY CategoryName"


    dtcFileCategory.RecordSource = strSQL
    dtcFileCategory.Refresh
    dtcFileCategory.UpdateControls
' If enabled, would cause "invalid procedure call" when Form Loaded
'    If Trim(txtDeptFrom) = "*" Then
'        cmdOK.SetFocus
'    End If


txtClassFrom_Click_Exit:  ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
txtClassFrom_Click_Err:   ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume txtClassFrom_Click_Exit

End Sub


Private Sub txtClassFrom_DblClick()
    txtClassFrom.Text = "*"
End Sub

Private Sub txtDeptFrom_Click()

    On Error GoTo txtDeptFrom_Click_Err


    optDeptAll = False
    optDeptSelect = True
    If dtcFileDepartment.Recordset.RecordCount > 0 Then
        txtDeptFrom = dbListDepartment.Text
        txtFromDept = dbListDepartment.BoundText
    End If
    txtClassFrom = "*"
    txtFromClass = "*"
    txtCatFrom = "*"
    txtFromCat = "*"
    Dim strSQL As String
      strSQL = "SELECT distinct ClassCode, ClassName FROM Class " & _
                "WHERE Department = '" & txtFromDept & _
                "' ORDER BY ClassName"
    dtcFileClass.RecordSource = strSQL
    dtcFileClass.Refresh
    dtcFileClass.UpdateControls
      strSQL = "SELECT distinct CategoryCode," & _
             "CategoryName FROM Category " & _
             "WHERE DepartmentCode = '" & txtFromDept & _
             "' ORDER BY CategoryName"
             
'             "' AND ClassCode = '" & txtFromClass & _
 '            "' ORDER BY CategoryName"
    dtcFileCategory.RecordSource = strSQL
    dtcFileCategory.Refresh
    dtcFileCategory.UpdateControls
    

txtDeptFrom_Click_Exit:   ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
txtDeptFrom_Click_Err:    ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume txtDeptFrom_Click_Exit

End Sub


Private Sub txtDeptFrom_DblClick()
    txtDeptFrom.Text = "*"
End Sub

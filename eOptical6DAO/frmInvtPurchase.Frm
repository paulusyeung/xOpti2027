VERSION 5.00
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmInvtPurchase 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "frmInvtPurchase"
   ClientHeight    =   6990
   ClientLeft      =   8970
   ClientTop       =   3990
   ClientWidth     =   6180
   Icon            =   "frmInvtPurchase.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6990
   ScaleWidth      =   6180
   ShowInTaskbar   =   0   'False
   Begin VB.Frame Frame6 
      Caption         =   " Purchase Details Date Range "
      Height          =   1455
      Left            =   0
      TabIndex        =   14
      Top             =   4560
      Width           =   6135
      Begin SSCalendarWidgets_A.SSDateCombo SSDateTo 
         Height          =   375
         Left            =   2200
         TabIndex        =   18
         Top             =   880
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
         Left            =   2200
         TabIndex        =   16
         Top             =   400
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
      Begin VB.Label Label4 
         Caption         =   "To:"
         Height          =   375
         Left            =   1560
         TabIndex        =   17
         Top             =   885
         Width           =   490
      End
      Begin VB.Label Label2 
         Caption         =   "From:"
         Height          =   375
         Left            =   1560
         TabIndex        =   15
         Top             =   400
         Width           =   490
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   " Class Selection: "
      Height          =   1335
      Left            =   0
      TabIndex        =   6
      Top             =   1680
      Width           =   6135
      Begin VB.TextBox txtClassFrom 
         Height          =   330
         Left            =   3000
         TabIndex        =   8
         Text            =   " *"
         Top             =   600
         Width           =   2500
      End
      Begin VB.Data dtcFileClass 
         Caption         =   "Class"
         Connect         =   "Access"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   2160
         Options         =   0
         ReadOnly        =   -1  'True
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT distinct ClassName, ClassCode from Class order by ClassName"
         Top             =   960
         Visible         =   0   'False
         Width           =   3855
      End
      Begin VB.TextBox txtFromClass 
         Enabled         =   0   'False
         Height          =   330
         Left            =   5520
         TabIndex        =   9
         Text            =   " *"
         Top             =   600
         Visible         =   0   'False
         Width           =   500
      End
      Begin MSDBCtls.DBList dbListClass 
         Bindings        =   "frmInvtPurchase.frx":068A
         DataField       =   "classcode"
         DataSource      =   "dtcFileClass"
         Height          =   1035
         Left            =   240
         TabIndex        =   7
         Top             =   240
         Width           =   1800
         _ExtentX        =   3175
         _ExtentY        =   1826
         _Version        =   393216
         MatchEntry      =   -1  'True
         BackColor       =   -2147483643
         ForeColor       =   -2147483640
         ListField       =   "classname"
         BoundColumn     =   "classcode"
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
      End
      Begin VB.Label Label3 
         Caption         =   "Select:"
         Height          =   255
         Left            =   2400
         TabIndex        =   27
         Top             =   600
         Width           =   600
      End
   End
   Begin VB.Frame Frame5 
      Caption         =   " Printer "
      Height          =   735
      Left            =   4680
      TabIndex        =   23
      Top             =   6120
      Width           =   1455
      Begin VB.CommandButton cmdPrnSetup 
         Caption         =   "&Setup"
         Height          =   375
         Left            =   120
         TabIndex        =   24
         Top             =   240
         Width           =   1200
      End
   End
   Begin VB.Frame Frame4 
      Caption         =   " Command "
      Height          =   735
      Left            =   0
      TabIndex        =   19
      Top             =   6120
      Width           =   4575
      Begin VB.CommandButton cmdExit 
         Caption         =   "&Exit"
         Height          =   375
         Left            =   3120
         TabIndex        =   22
         Top             =   240
         Width           =   1200
      End
      Begin VB.CommandButton cmdReset 
         Caption         =   "&Reset"
         Height          =   375
         Left            =   1680
         TabIndex        =   21
         Top             =   240
         Width           =   1200
      End
      Begin VB.CommandButton cmdOK 
         Caption         =   "&OK"
         Height          =   375
         Left            =   240
         TabIndex        =   20
         Top             =   240
         Width           =   1200
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   " Category Selection: "
      Height          =   1335
      Left            =   0
      TabIndex        =   10
      Top             =   3120
      Width           =   6135
      Begin VB.TextBox txtFromCat 
         Enabled         =   0   'False
         Height          =   330
         Left            =   5520
         TabIndex        =   13
         Text            =   " *"
         Top             =   600
         Visible         =   0   'False
         Width           =   500
      End
      Begin VB.Data dtcFileCategory 
         Caption         =   "Category"
         Connect         =   "Access"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   2160
         Options         =   0
         ReadOnly        =   -1  'True
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "select distinct CategoryName, CategoryCode from Category order by CategoryName"
         Top             =   960
         Visible         =   0   'False
         Width           =   3840
      End
      Begin VB.TextBox txtCatFrom 
         Height          =   330
         Left            =   3000
         TabIndex        =   12
         Text            =   " *"
         Top             =   600
         Width           =   2500
      End
      Begin MSDBCtls.DBList dbListCategory 
         Bindings        =   "frmInvtPurchase.frx":06A5
         DataField       =   "categorycode"
         DataSource      =   "dtcFileCategory"
         Height          =   1035
         Left            =   240
         TabIndex        =   11
         Top             =   240
         Width           =   1800
         _ExtentX        =   3175
         _ExtentY        =   1826
         _Version        =   393216
         MatchEntry      =   -1  'True
         BackColor       =   -2147483643
         ForeColor       =   -2147483640
         ListField       =   "categoryname"
         BoundColumn     =   "categorycode"
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
      End
      Begin VB.Label Label5 
         Caption         =   "Select:"
         Height          =   255
         Left            =   2400
         TabIndex        =   26
         Top             =   600
         Width           =   600
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   " Department Selection: "
      Height          =   1455
      Left            =   0
      TabIndex        =   0
      Top             =   120
      Width           =   6135
      Begin VB.TextBox txtFromDept 
         Enabled         =   0   'False
         Height          =   330
         Left            =   5520
         TabIndex        =   5
         Text            =   " *"
         Top             =   600
         Visible         =   0   'False
         Width           =   500
      End
      Begin VB.Data dtcFileDepartment 
         Caption         =   "Sales Department Only"
         Connect         =   "Access"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   2160
         Options         =   0
         ReadOnly        =   -1  'True
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "RptSalesDeptOnly"
         Top             =   960
         Visible         =   0   'False
         Width           =   3840
      End
      Begin VB.OptionButton optDeptSelect 
         Caption         =   "Select"
         Height          =   315
         Left            =   4080
         TabIndex        =   2
         Top             =   240
         Width           =   975
      End
      Begin VB.OptionButton optDeptAll 
         Caption         =   "All"
         Height          =   315
         Left            =   2280
         TabIndex        =   1
         Top             =   240
         Value           =   -1  'True
         Width           =   975
      End
      Begin VB.TextBox txtDeptFrom 
         Height          =   330
         Left            =   3000
         TabIndex        =   4
         Text            =   " *"
         Top             =   600
         Width           =   2500
      End
      Begin MSDBCtls.DBList dbListDepartment 
         Bindings        =   "frmInvtPurchase.frx":06C3
         DataField       =   "departmentCode"
         DataSource      =   "dtcFileDepartment"
         Height          =   1035
         Left            =   240
         TabIndex        =   3
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
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
      End
      Begin VB.Label Label1 
         Caption         =   "Select:"
         Height          =   255
         Left            =   2400
         TabIndex        =   25
         Top             =   600
         Width           =   600
      End
   End
End
Attribute VB_Name = "frmInvtPurchase"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdExit_Click()

    On Error GoTo cmdExit_Click_Err
    Call ofx_CloseForm(frmInvtPurchase)

cmdExit_Click_Exit:       ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdExit_Click_Err:        ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdExit_Click_Exit

End Sub


Private Sub cmdOK_Click()

    On Error GoTo cmdOK_Click_Err
    
    Dim DateFrom As Date
    Dim DateTo As Date
   
    DateFrom = Me.ssDateFrom.Date
    DateTo = Me.ssDateTo.Date
     
    
    If DateFrom > DateTo Then
        'Call ofx_Swap(Me.ssDateFrom.Date, Me.ssDateTo.Date)
        'Call ofx_Swap(DateFrom, DateTo)
        Me.ssDateFrom.Date = DateTo
        Me.ssDateTo.Date = DateFrom
        DateFrom = Me.ssDateFrom.Date
        DateTo = Me.ssDateTo.Date
        frmInvtPurchase.Refresh
    End If
        
    If optDeptAll Then  ' Reset full choice
        Me.txtFromDept.Text = "*"
        Me.txtDeptFrom.Text = "*"
        Me.txtFromClass.Text = "*"
        Me.txtClassFrom.Text = "*"
        Me.txtFromCat.Text = "*"
        Me.txtCatFrom.Text = "*"
    End If
    If CrwRptName = "Inventory Purchase" Then
    
        If DateFrom > Date Then
            Beep
            MsgBox " Greater than current date ", 0, "Validation Error"
            Me.ssDateFrom.SetFocus
            Exit Sub
        End If
    End If
    
    Screen.MousePointer = vbArrowHourglass
      '   Set Formula
    frmCtlCrw.CrystalReport1.Formulas(0) = "AskCat = '" & Me.txtCatFrom.Text & "'"
    frmCtlCrw.CrystalReport1.Formulas(1) = "AskClass = '" & Me.txtClassFrom.Text & "'"
    frmCtlCrw.CrystalReport1.Formulas(2) = "AskDateFrom =" & _
                "Date(" & (Year(Me.ssDateFrom)) & "," & _
                    (Month(Me.ssDateFrom)) & "," & _
                    (Day(Me.ssDateFrom)) & ")"
    frmCtlCrw.CrystalReport1.Formulas(3) = "AskDateTo =" & _
                "Date(" & (Year(Me.ssDateTo)) & "," & _
                    (Month(Me.ssDateTo)) & "," & _
                    (Day(Me.ssDateTo)) & ")"
    frmCtlCrw.CrystalReport1.Formulas(4) = "AskDept = '" & Me.txtDeptFrom.Text & "'"
    frmCtlCrw.CrystalReport1.Formulas(7) = "AskXDispCost =" & pyUserHasCostLevel
    
    'frmCtlCrw.CrystalReport1.SelectionFormula = "{RptInvtPurchase.DepartmentName} like {@AskDept}" & _
    '    " and {RptInvtPurchase.ClassName} like {@AskClass} and {RptInvtPurchase.CategoryName} like {@AskCat}"
    If Me.txtDeptFrom <> "*" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = "{RptInvtPurchase.DepartmentName} like {@AskDept}"
    End If
    
    If Me.txtClassFrom <> "*" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = frmCtlCrw.CrystalReport1.SelectionFormula & _
            " and {RptInvtPurchase.ClassName} like {@AskClass}"
    End If
    
    If Me.txtCatFrom <> "*" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = frmCtlCrw.CrystalReport1.SelectionFormula & _
            "  and {RptInvtPurchase.CategoryName} like {@AskCat}"
    End If
    
    If frmCtlCrw.CrystalReport1.SelectionFormula <> "" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = frmCtlCrw.CrystalReport1.SelectionFormula & _
        " and {RptInvtPurchase.DateOfEntry} in {@AskDateFrom} to {@AskDateTo}"
    Else
        frmCtlCrw.CrystalReport1.SelectionFormula = "{RptInvtPurchase.DateOfEntry} in {@AskDateFrom} to {@AskDateTo}"
    End If
    
    'MsgBox frmCtlCrw.CrystalReport1.SelectionFormula
    Call ofx_CloseForm(frmInvtPurchase)
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
    Me.ssDateTo.Date = CurrentDate
    Me.optDeptAll = True

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



Private Sub dbListCategory_DblClick()

    On Error GoTo dbListCategory_DblClick_Err

      Call txtCatFrom_Click

dbListCategory_DblClick_Exit:                                ' SDVB autocode
    On Error Resume Next                                     ' SDVB autocode
    Exit Sub                                                 ' SDVB autocode
dbListCategory_DblClick_Err:                                 ' SDVB autocode
    Call ofx_GenericError("dbListCategory_DblClick()", Err)  ' SDVB autocode
    Resume dbListCategory_DblClick_Exit

End Sub



Private Sub dbListClass_DblClick()

    On Error GoTo dbListClass_DblClick_Err

      Call txtClassFrom_Click

dbListClass_DblClick_Exit:                                ' SDVB autocode
    On Error Resume Next                                  ' SDVB autocode
    Exit Sub                                              ' SDVB autocode
dbListClass_DblClick_Err:                                 ' SDVB autocode
    Call ofx_GenericError("dbListClass_DblClick()", Err)  ' SDVB autocode
    Resume dbListClass_DblClick_Exit

End Sub



Private Sub dbListDepartment_DblClick()

    On Error GoTo dbListDepartment_DblClick_Err

    Call txtDeptFrom_Click

dbListDepartment_DblClick_Exit:                                ' SDVB autocode
    On Error Resume Next                                       ' SDVB autocode
    Exit Sub                                                   ' SDVB autocode
dbListDepartment_DblClick_Err:                                 ' SDVB autocode
    Call ofx_GenericError("dbListDepartment_DblClick()", Err)  ' SDVB autocode
    Resume dbListDepartment_DblClick_Exit

End Sub


Private Sub Form_Load()
   On Error GoTo Form_Load_Err

    Call ofx_CenterForm(Me)
    Me.Caption = CrwRptName
    Me.Icon = LoadPicture(SynergyIcon)
    
    Me.dtcFileDepartment.DatabaseName = sDBName
'    dtcFileDepartment.Recordset.MoveLast
    Me.dtcFileClass.DatabaseName = sDBName
'    dtcFileClass.Recordset.MoveLast
    Me.dtcFileCategory.DatabaseName = sDBName
'    dtcFileCategory.Recordset.MoveLast
    
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

    cmdReset_Click

optDeptAll_Click_Exit:    ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
optDeptAll_Click_Err:     ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume optDeptAll_Click_Exit

End Sub



Private Sub txtCatFrom_Click()

    On Error GoTo txtCatFrom_Click_Err
    Dim strSQL As String
    
    If (Trim(txtDeptFrom.Text) = "*" And Trim(txtClassFrom.Text) <> "*") Then
'        cmdOK.SetFocus
        Exit Sub
    Else
        If dtcFileCategory.Recordset.RecordCount <> 0 Then
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


Private Sub txtClassFrom_Click()

    On Error GoTo txtClassFrom_Click_Err
    Dim strSQL As String
    
    optDeptAll = False
    optDeptSelect = True
    
    If dtcFileClass.Recordset.RecordCount <> 0 Then
        txtClassFrom.Text = dbListClass.Text
        txtFromClass.Text = dbListClass.BoundText
    End If
    
    txtCatFrom = "*"
    txtFromCat = "*"
    
    strSQL = "SELECT distinct CategoryName," & _
             "CategoryCode FROM Category " & _
             "WHERE DepartmentCode = '" & Trim(txtFromDept.Text) & _
             "' AND ClassCode = '" & Trim(txtFromClass.Text) & _
             "' ORDER BY CategoryName"

    dtcFileCategory.RecordSource = strSQL
    dtcFileCategory.Refresh
    dtcFileCategory.UpdateControls
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


Private Sub txtDeptFrom_Click()

    On Error GoTo txtDeptFrom_Click_Err
    
    Dim strSQL As String

    optDeptAll = False
    optDeptSelect = True
    
    If dtcFileDepartment.Recordset.RecordCount <> 0 Then
        txtDeptFrom.Text = dbListDepartment.Text
        txtFromDept.Text = dbListDepartment.BoundText
    End If
    
    txtClassFrom = "*"
    txtFromClass = "*"
    txtCatFrom = "*"
    txtFromCat = "*"
    
    strSQL = "SELECT distinct ClassName, ClassCode FROM Class " & _
                "WHERE Department = '" & Trim(txtFromDept.Text) & _
                "' ORDER BY ClassName"
    
    dtcFileClass.RecordSource = strSQL
    dtcFileClass.Refresh
    dtcFileClass.UpdateControls
    
    strSQL = "SELECT distinct CategoryName," & _
             "CategoryCode FROM Category " & _
             "WHERE DepartmentCode = '" & Trim(txtFromDept.Text) & _
             "' ORDER BY CategoryName"
'             "' AND ClassCode = '" & txtFromClass.text & _
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



VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmCategory 
   Caption         =   "Category"
   ClientHeight    =   6585
   ClientLeft      =   2985
   ClientTop       =   1935
   ClientWidth     =   8940
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6585
   ScaleWidth      =   8940
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Bindings        =   "frmCategory.frx":0000
      Height          =   2175
      Left            =   120
      OleObjectBlob   =   "frmCategory.frx":001A
      TabIndex        =   12
      TabStop         =   0   'False
      Top             =   4320
      Width           =   7815
   End
   Begin VB.Timer tmrClearDBComboHiLite 
      Interval        =   100
      Left            =   4560
      Top             =   2520
   End
   Begin VB.TextBox txtLastClassCode 
      Height          =   285
      Left            =   6360
      TabIndex        =   27
      TabStop         =   0   'False
      Top             =   1470
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.TextBox txtLastClassName 
      Height          =   285
      Left            =   5040
      TabIndex        =   26
      TabStop         =   0   'False
      Top             =   1470
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.TextBox txtLastDeptCode 
      Height          =   285
      Left            =   6360
      TabIndex        =   25
      TabStop         =   0   'False
      Top             =   1140
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.TextBox txtLastDeptName 
      Height          =   285
      Left            =   5040
      TabIndex        =   24
      TabStop         =   0   'False
      Top             =   1140
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.TextBox txtCategoryName 
      DataField       =   "CategoryName"
      DataSource      =   "dtcCategory"
      Height          =   285
      Left            =   1560
      TabIndex        =   2
      Top             =   2100
      Width           =   2415
   End
   Begin VB.Data dtcTaxMethod 
      Caption         =   "TaxMethod"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   375
      Left            =   6360
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "TaxMethod"
      Top             =   3000
      Visible         =   0   'False
      Width           =   2415
   End
   Begin VB.Data dtcInventoryMethod 
      Caption         =   "InventoryMethod"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   375
      Left            =   6360
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "InvtMethod"
      Top             =   2640
      Visible         =   0   'False
      Width           =   2415
   End
   Begin VB.Data dtcCostingMethod 
      Caption         =   "CostingMethod"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   375
      Left            =   6360
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "CostingMethod"
      Top             =   2280
      Visible         =   0   'False
      Width           =   2415
   End
   Begin VB.Data dtcClass 
      Caption         =   "Class"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   375
      Left            =   6840
      Options         =   0
      ReadOnly        =   -1  'True
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT DISTINCT ClassCode, ClassName FROM Class ORDER BY ClassName ASC"
      Top             =   1800
      Visible         =   0   'False
      Width           =   1935
   End
   Begin VB.Data dtcDepartment 
      Caption         =   "Department"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   375
      Left            =   6840
      Options         =   0
      ReadOnly        =   -1  'True
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Department"
      Top             =   1440
      Visible         =   0   'False
      Width           =   1935
   End
   Begin VB.Data dtcCategory 
      Caption         =   "Category"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   6840
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   1080
      Visible         =   0   'False
      Width           =   1935
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   13
      Top             =   0
      Width           =   8940
      _Version        =   131073
      _ExtentX        =   15769
      _ExtentY        =   1906
      _StockProps     =   69
      BackColor       =   12632256
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      FloatingCaption =   "SSToolbar1"
      AlreadyCreated  =   -1  'True
      Outline         =   0   'False
      BackColorHelp   =   12648447
      ToolsetNumBtnStates=   3
      BtnGroupSpacing =   4
      BtnSpacing      =   0
      Btns            =   9
      ToolsetPicture  =   "frmCategory.frx":3917
      BC              =   9
      BtnToolNum(0)   =   0
      BtnPlaceHolder(0)=   0   'False
      BtnToolNum(1)   =   1
      BtnPlaceHolder(1)=   0   'False
      BtnToolNum(2)   =   2
      BtnPlaceHolder(2)=   0   'False
      BtnToolNum(3)   =   3
      BtnPlaceHolder(3)=   0   'False
      BtnToolNum(4)   =   4
      BtnPlaceHolder(4)=   0   'False
      BtnToolNum(5)   =   5
      BtnPlaceHolder(5)=   0   'False
      BtnToolNum(6)   =   6
      BtnPlaceHolder(6)=   0   'False
      BtnToolNum(7)   =   7
      BtnPlaceHolder(7)=   0   'False
      BtnToolNum(8)   =   8
      BtnPlaceHolder(8)=   0   'False
      ToolsetNumTools =   9
      ToolsetToolID(0)=   "ID_Add"
      ToolsetToolHelp(0)=   "Add Record"
      ToolsetToolMnemonic(0)=   "a"
      ToolsetToolGroup(0)=   1
      ToolsetToolID(1)=   "ID_Delete"
      ToolsetToolHelp(1)=   "Delete Record"
      ToolsetToolMnemonic(1)=   "d"
      ToolsetToolGroup(1)=   1
      ToolsetToolID(2)=   "ID_Undo"
      ToolsetToolHelp(2)=   "Undo Edit"
      ToolsetToolMnemonic(2)=   "u"
      ToolsetToolGroup(2)=   1
      ToolsetToolID(3)=   "ID_Save"
      ToolsetToolHelp(3)=   "Save Record"
      ToolsetToolMnemonic(3)=   "s"
      ToolsetToolGroup(3)=   1
      ToolsetToolID(4)=   "ID_First"
      ToolsetToolHelp(4)=   "First Record"
      ToolsetToolMnemonic(4)=   "f"
      ToolsetToolGroup(4)=   2
      ToolsetToolID(5)=   "ID_Previous"
      ToolsetToolHelp(5)=   "Previous Record"
      ToolsetToolMnemonic(5)=   "p"
      ToolsetToolGroup(5)=   2
      ToolsetToolID(6)=   "ID_Next"
      ToolsetToolHelp(6)=   "Next Record"
      ToolsetToolMnemonic(6)=   "n"
      ToolsetToolGroup(6)=   2
      ToolsetToolID(7)=   "ID_Last"
      ToolsetToolHelp(7)=   "Last Record"
      ToolsetToolMnemonic(7)=   "l"
      ToolsetToolGroup(7)=   2
      ToolsetToolID(8)=   "ID_Exit"
      ToolsetToolHelp(8)=   "Exit Task"
      ToolsetToolMnemonic(8)=   "x"
      ToolsetToolGroup(8)=   3
      MouseIcon       =   "frmCategory.frx":111A9
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   30
      Left            =   120
      TabIndex        =   21
      Top             =   3600
      Width           =   8655
      _ExtentX        =   15266
      _ExtentY        =   53
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
      Caption         =   "SSFrame1"
   End
   Begin MSDBCtls.DBCombo dbcSelClass 
      Bindings        =   "frmCategory.frx":111C5
      Height          =   315
      Left            =   2880
      TabIndex        =   20
      TabStop         =   0   'False
      Top             =   3960
      Width           =   1695
      _ExtentX        =   2990
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "ClassName"
      BoundColumn     =   "ClassCode"
      Text            =   "dbcSelClass"
   End
   Begin MSDBCtls.DBCombo dbcSelDepartment 
      Bindings        =   "frmCategory.frx":111DC
      Height          =   315
      Left            =   480
      TabIndex        =   19
      TabStop         =   0   'False
      Top             =   3960
      Width           =   1575
      _ExtentX        =   2778
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "DepartmentName"
      BoundColumn     =   "DepartmentCode"
      Text            =   "dbcSelDepartment"
   End
   Begin MSMask.MaskEdBox mskCategoryCode 
      DataField       =   "CategoryCode"
      DataSource      =   "dtcCategory"
      Height          =   255
      Left            =   1560
      TabIndex        =   1
      Top             =   1800
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   450
      _Version        =   393216
      PromptInclude   =   0   'False
      MaxLength       =   2
      Mask            =   "##"
      PromptChar      =   "_"
   End
   Begin MSDBCtls.DBCombo dbcDepartment 
      Bindings        =   "frmCategory.frx":111F8
      DataField       =   "DepartmentCode"
      DataSource      =   "dtcCategory"
      Height          =   315
      Left            =   1560
      TabIndex        =   14
      Top             =   1080
      Width           =   2415
      _ExtentX        =   4260
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "DepartmentName"
      BoundColumn     =   "DepartmentCode"
      Text            =   "dbcDepartment"
   End
   Begin MSDBCtls.DBCombo dbcTaxMethod 
      Bindings        =   "frmCategory.frx":11214
      DataField       =   "TaxMethod"
      DataSource      =   "dtcCategory"
      Height          =   315
      Left            =   1560
      TabIndex        =   5
      Top             =   3180
      Width           =   2415
      _ExtentX        =   4260
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "TaxName"
      BoundColumn     =   "TaxCode"
      Text            =   "dbcTaxMethod"
   End
   Begin MSDBCtls.DBCombo dbcInvetnoryMethod 
      Bindings        =   "frmCategory.frx":1122F
      DataField       =   "InventoryMethod"
      DataSource      =   "dtcCategory"
      Height          =   315
      Left            =   1560
      TabIndex        =   4
      Top             =   2820
      Width           =   2415
      _ExtentX        =   4260
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "InvtMethodName"
      BoundColumn     =   "InvtMethodCode"
      Text            =   "dbcInvetnoryMethod"
   End
   Begin MSDBCtls.DBCombo dbcCostingMethod 
      Bindings        =   "frmCategory.frx":11250
      DataField       =   "CostingMethod"
      DataSource      =   "dtcCategory"
      Height          =   315
      Left            =   1560
      TabIndex        =   3
      Top             =   2460
      Width           =   2415
      _ExtentX        =   4260
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "CostingName"
      BoundColumn     =   "CostingCode"
      Text            =   "dbcCostingMethod"
   End
   Begin MSDBCtls.DBCombo dbcClass 
      Bindings        =   "frmCategory.frx":1126F
      DataField       =   "ClassCode"
      DataSource      =   "dtcCategory"
      Height          =   315
      Left            =   1560
      TabIndex        =   16
      Top             =   1440
      Width           =   2415
      _ExtentX        =   4260
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "ClassName"
      BoundColumn     =   "ClassCode"
      Text            =   "dbcClass"
   End
   Begin Threed.SSRibbon cmdLockDept 
      Height          =   315
      Left            =   3960
      TabIndex        =   29
      Top             =   1080
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   556
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmCategory.frx":11286
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmCategory.frx":117E8
   End
   Begin Threed.SSRibbon cmdLockClass 
      Height          =   315
      Left            =   3960
      TabIndex        =   28
      Top             =   1440
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   556
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmCategory.frx":11D3A
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmCategory.frx":1229C
      GroupNumber     =   2
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   345
      Left            =   2520
      TabIndex        =   18
      TabStop         =   0   'False
      Top             =   3960
      Width           =   345
      _ExtentX        =   609
      _ExtentY        =   609
      _Version        =   131074
      PictureFrames   =   1
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Picture         =   "frmCategory.frx":127EE
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   345
      Left            =   120
      TabIndex        =   17
      TabStop         =   0   'False
      Top             =   3960
      Width           =   345
      _ExtentX        =   609
      _ExtentY        =   609
      _Version        =   131074
      PictureFrames   =   1
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Picture         =   "frmCategory.frx":12D94
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   315
      Left            =   4320
      TabIndex        =   15
      TabStop         =   0   'False
      Top             =   1440
      Width           =   360
      _ExtentX        =   635
      _ExtentY        =   556
      _Version        =   131074
      PictureFrames   =   1
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Picture         =   "frmCategory.frx":1333A
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin VB.Label Label2 
      Caption         =   "Class"
      Height          =   255
      Left            =   2520
      TabIndex        =   23
      Top             =   3720
      Width           =   495
   End
   Begin VB.Label Label1 
      Caption         =   "Department"
      Height          =   255
      Left            =   120
      TabIndex        =   22
      Top             =   3720
      Width           =   975
   End
   Begin VB.Label lblLabels 
      Caption         =   "TaxMethod:"
      Height          =   255
      Index           =   6
      Left            =   120
      TabIndex        =   11
      Top             =   3180
      Width           =   1215
   End
   Begin VB.Label lblLabels 
      Caption         =   "Inventory Method:"
      Height          =   255
      Index           =   5
      Left            =   120
      TabIndex        =   10
      Top             =   2820
      Width           =   1335
   End
   Begin VB.Label lblLabels 
      Caption         =   "Costing Method:"
      Height          =   255
      Index           =   4
      Left            =   120
      TabIndex        =   9
      Top             =   2460
      Width           =   1215
   End
   Begin VB.Label lblLabels 
      Caption         =   "Category Name:"
      Height          =   255
      Index           =   3
      Left            =   120
      TabIndex        =   8
      Top             =   2100
      Width           =   1215
   End
   Begin VB.Label lblLabels 
      Caption         =   "Category Code:"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   7
      Top             =   1785
      Width           =   1215
   End
   Begin VB.Label lblLabels 
      Caption         =   "ClassCode:"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   6
      Top             =   1440
      Width           =   1215
   End
   Begin VB.Label lblLabels 
      Caption         =   "Department:"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   0
      Top             =   1080
      Width           =   975
   End
End
Attribute VB_Name = "frmCategory"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False












Private Sub cmdLockClass_Click(Value As Integer)
    Select Case Value
    Case True   ' Lock the Class Info
        ' Set button background color to white
        cmdLockClass.BackColor = &HFFFFFF
        ' Lock the last Class Code & Class Name
        txtLastClassName.Text = dbcClass.Text
        txtLastClassCode.Text = dbcClass.BoundText
        ' Disable the dbcClass
        dbcClass.Enabled = False
    Case False  ' Unlock the Class Info
        ' Set button background color to gray
        cmdLockClass.BackColor = &HC0C0C0      ' Gray
        ' Enable the dbcClass
        dbcClass.Enabled = True
    End Select
End Sub


Private Sub cmdLockDept_Click(Value As Integer)
    Select Case Value
    Case True   ' Lock the Dept Info
        ' Set button background color to white
        cmdLockDept.BackColor = &HFFFFFF
        ' Lock the last Dept Code & Dept Name
        txtLastDeptName.Text = dbcDepartment.Text
        txtLastDeptCode.Text = dbcDepartment.BoundText
        ' Disable dbcDepartment
        dbcDepartment.Enabled = False
    Case False  ' Unlock the Dept Info
        ' Set button background color to gray
        cmdLockDept.BackColor = &HC0C0C0
        ' Enable dbcDepartment
        dbcDepartment.Enabled = True
    End Select

End Sub

Private Sub dbcDepartment_Click(intArea As Integer)
    ' When Dept was selected,
    ' Class DBCombo contains only those with the same Dept Code
    If intArea = dbcAreaList Then
        Dim strSQL As String
        strSQL = "SELECT * FROM Class " _
            & "WHERE Department = '" & dbcDepartment.BoundText & "' " _
            & "ORDER BY ClassName"
        dtcClass.RecordSource = strSQL
        dtcClass.Refresh
        dtcClass.UpdateControls
    End If

End Sub

Private Sub dbcSelClass_Click(intArea As Integer)

    On Error GoTo dbcSelClass_Click_Err

    If intArea = dbcAreaList Then
        Dim strSQL As String
        
        strSQL = "SELECT * FROM Category " _
            & "WHERE ClassCode = '" & dbcSelClass.BoundText & "' " _
            & "AND DepartmentCode = '" & dbcSelDepartment.BoundText & "' " _
            & "ORDER BY DepartmentCode, CategoryCode"
        dtcCategory.RecordSource = strSQL
        dtcCategory.Refresh
        dtcCategory.UpdateControls
    End If

dbcSelClass_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                 ' Tutorial Autocode
    Exit Sub                                             ' Tutorial Autocode
dbcSelClass_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelClass_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelClass_Click_Exit

End Sub

Private Sub dbcSelDepartment_Click(intArea As Integer)

    On Error GoTo dbcSelDepartment_Click_Err

    If intArea = dbcAreaList Then
        dbcSelClass.Text = ""   ' Set selected class to null
        Dim strSQL As String
        ' Sync Class DAO Contents
        strSQL = "SELECT DISTINCT ClassCode, ClassName FROM Class " & _
                 "WHERE Department = '" & dbcSelDepartment.BoundText & "' " & _
                 "ORDER BY ClassName"
        dtcClass.RecordSource = strSQL
        dtcClass.Refresh
        dtcClass.UpdateControls
        ' Sync Category DAO Contents
        strSQL = "SELECT * FROM Category " & _
                 "WHERE DepartmentCode = '" & dbcSelDepartment.BoundText & "' " & _
                 "ORDER BY DepartmentCode, ClassCode, CategoryCode"
        dtcCategory.RecordSource = strSQL
        dtcCategory.Refresh
        dtcCategory.UpdateControls
    End If

dbcSelDepartment_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                 ' Tutorial Autocode
    Exit Sub                                             ' Tutorial Autocode
dbcSelDepartment_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelDepartment_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelDepartment_Click_Exit

End Sub

Private Sub Form_Activate()

    On Error GoTo Form_Activate_Err

    Screen.MousePointer = vbDefault
    
    ' Initialize the dbcDepartment
    dbcSelDepartment.SetFocus
    SendKeys "{F4}{Enter}", True
    Call dbcSelDepartment_Click(2)
    
    ' Goto dbcSelDepartment
    dbcSelDepartment.SetFocus

Form_Activate_Exit:                                ' Tutorial Autocode
    On Error Resume Next                           ' Tutorial Autocode
    Exit Sub                                       ' Tutorial Autocode
Form_Activate_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("Form_Activate()", Err)  ' Tutorial Autocode
    Resume Form_Activate_Exit



End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)

End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub mskCategoryCode_GotFocus()
    Call AutoSelect(mskCategoryCode)    ' Auto-select the whole window
End Sub

Private Sub SSCommand1_Click()
    frmClass.Show vbModal
    dtcClass.Refresh
    dtcClass.UpdateControls
End Sub


Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

'    On Error GoTo SSToolbar1_Click_Err

    Select Case ToolID
        Case "ID_Add"
            Call DoAdd
        Case "ID_Delete"
            'this may produce an error if you delete the last
            'record or the only record in the recordset
            dtcCategory.Recordset.Delete
            dtcCategory.Recordset.MoveNext
        Case "ID_Undo"
            'this is really only needed for multi user apps
            dtcCategory.Refresh
        Case "ID_Save"
            ' If new record, auto-fill the department code
            ' If IsNull(dtcCategory.Recordset("ClassCode")) Or _
            '     dtcCategory.Recordset("ClassCode") = "" Then
            '     dtcCategory.Recordset("DepartmentCode") = dtcClass.Recordset("Department")
            '     dtcCategory.Recordset("ClassCode") = dbcClass.BoundText
            ' End If
            txtLastDeptName.Text = dbcDepartment.Text
            txtLastDeptCode.Text = dbcDepartment.BoundText
            txtLastClassName.Text = dbcClass.Text
            txtLastClassCode.Text = dbcClass.BoundText
            dtcCategory.UpdateRecord
            dtcCategory.Recordset.Bookmark = dtcCategory.Recordset.LastModified
            dtcCategory.UpdateControls
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            dtcCategory.Recordset.MoveFirst
        Case "ID_Next"
            dtcCategory.Recordset.MoveNext
            ' Prevent the Blank Record
            If dtcCategory.Recordset.EOF Then
                Beep
                dtcCategory.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcCategory.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcCategory.Recordset.BOF Then
                Beep
                dtcCategory.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcCategory.Recordset.MoveLast
    End Select

SSToolbar1_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSToolbar1_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSToolbar1_Click()", Err)  ' Tutorial Autocode
    Resume SSToolbar1_Click_Exit


End Sub


Private Sub tmrClearDBComboHiLite_Timer()
    Call ClearDBComboHiLite(Me)
End Sub

Private Sub txtCategoryName_GotFocus()
    Call AutoSelect(txtCategoryName)    ' Auto-select the whole window
End Sub





Private Sub DoAdd()
    With dtcCategory.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    dtcCategory.Recordset.AddNew
    If cmdLockDept.Value Then
        dbcDepartment.Text = txtLastDeptName.Text
        dbcDepartment.BoundText = txtLastDeptCode.Text
    End If
    If cmdLockClass.Value Then
        dbcClass.Text = txtLastClassName.Text
        dbcClass.BoundText = txtLastClassCode
    End If
    ' Set focus
    If dbcDepartment.Enabled And dbcClass.Enabled Then
        dbcDepartment.SetFocus
    ElseIf dbcClass.Enabled Then
        dbcClass.SetFocus
    ElseIf dbcDepartment.Enabled Then
        dbcDepartment.SetFocus
    Else
        mskCategoryCode.SetFocus
    End If
End Sub


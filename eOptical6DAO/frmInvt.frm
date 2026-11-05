VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmInvt 
   Caption         =   "Inventory"
   ClientHeight    =   7200
   ClientLeft      =   450
   ClientTop       =   1005
   ClientWidth     =   11295
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   7200
   ScaleWidth      =   11295
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Bindings        =   "frmInvt.frx":0000
      Height          =   2175
      Left            =   120
      OleObjectBlob   =   "frmInvt.frx":001B
      TabIndex        =   37
      TabStop         =   0   'False
      Top             =   4920
      Width           =   11055
   End
   Begin VB.Timer tmrClearDBComboHiLite 
      Interval        =   100
      Left            =   3960
      Top             =   3000
   End
   Begin VB.Data dtcSelSupplier 
      Caption         =   "SelSupplier"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   6360
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT SupplierCode, SupplierName FROM Supplier ORDER BY SupplierName"
      Top             =   4380
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcSelBrand 
      Caption         =   "SelBrand"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   8400
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT * FROM Brand ORDER BY BrandDescription"
      Top             =   4380
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.TextBox txtSelModel 
      Height          =   285
      Left            =   9600
      MaxLength       =   30
      TabIndex        =   79
      Top             =   4560
      Width           =   1215
   End
   Begin VB.TextBox txtReorderQty 
      DataField       =   "ReOrderQty"
      DataSource      =   "dtcInventory"
      Height          =   285
      Left            =   8640
      TabIndex        =   22
      Top             =   3840
      Width           =   375
   End
   Begin VB.TextBox txtReorderLevel 
      DataField       =   "ReOrderLevel"
      DataSource      =   "dtcInventory"
      Height          =   285
      Left            =   8640
      TabIndex        =   21
      Top             =   3480
      Width           =   375
   End
   Begin VB.TextBox txtBaseCurve 
      DataField       =   "BaseCurve"
      DataSource      =   "dtcInventory"
      Height          =   285
      Left            =   5640
      TabIndex        =   15
      Top             =   3720
      Width           =   615
   End
   Begin VB.TextBox txtDiameter 
      DataField       =   "Diameter"
      DataSource      =   "dtcInventory"
      Height          =   285
      Left            =   5640
      TabIndex        =   14
      Top             =   3360
      Width           =   615
   End
   Begin VB.TextBox txtCylinder 
      DataField       =   "Cylinder"
      DataSource      =   "dtcInventory"
      Height          =   285
      Left            =   5640
      TabIndex        =   13
      Top             =   3000
      Width           =   615
   End
   Begin VB.TextBox txtSphere 
      DataField       =   "Sphere"
      DataSource      =   "dtcInventory"
      Height          =   285
      Left            =   5640
      TabIndex        =   12
      Top             =   2640
      Width           =   615
   End
   Begin VB.TextBox txtTemple 
      DataField       =   "Temple"
      DataSource      =   "dtcInventory"
      Height          =   285
      Left            =   5640
      MaxLength       =   4
      TabIndex        =   11
      Top             =   2280
      Width           =   615
   End
   Begin VB.TextBox txtBridge 
      BackColor       =   &H00FFFFFF&
      DataField       =   "Bridge"
      DataSource      =   "dtcInventory"
      Height          =   285
      Left            =   5640
      MaxLength       =   4
      TabIndex        =   10
      Top             =   1920
      Width           =   615
   End
   Begin VB.TextBox txtLastBrandCode 
      Height          =   285
      Left            =   5040
      TabIndex        =   76
      Text            =   "LastBrandCode"
      Top             =   3960
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.TextBox txtLastBrandName 
      Height          =   285
      Left            =   3720
      TabIndex        =   75
      Text            =   "LastBrandName"
      Top             =   3960
      Visible         =   0   'False
      Width           =   1335
   End
   Begin VB.TextBox txtLastSupplierCode 
      Height          =   285
      Left            =   3240
      TabIndex        =   73
      Text            =   "LastSupplierCode"
      Top             =   3960
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.TextBox txtLastSupplierName 
      Height          =   285
      Left            =   1920
      TabIndex        =   72
      Text            =   "LastSupplierName"
      Top             =   3900
      Visible         =   0   'False
      Width           =   1335
   End
   Begin VB.TextBox txtLastCategoryCode 
      Height          =   285
      Left            =   3240
      TabIndex        =   71
      Text            =   "LatCategoryCode"
      Top             =   3720
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.TextBox txtLastCategoryName 
      Height          =   285
      Left            =   1920
      TabIndex        =   70
      Text            =   "LastCategoryName"
      Top             =   3720
      Visible         =   0   'False
      Width           =   1335
   End
   Begin VB.TextBox txtLastClassCode 
      Height          =   285
      Left            =   1440
      TabIndex        =   69
      Text            =   "LastClassCode"
      Top             =   3900
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.TextBox txtLastClassName 
      Height          =   285
      Left            =   120
      TabIndex        =   68
      Text            =   "LastClassName"
      Top             =   3900
      Visible         =   0   'False
      Width           =   1335
   End
   Begin VB.TextBox txtLastDeptCode 
      Height          =   285
      Left            =   1440
      TabIndex        =   67
      Text            =   "LastDeptCode"
      Top             =   3720
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.TextBox txtLastDeptName 
      Height          =   285
      Left            =   120
      TabIndex        =   66
      Text            =   "LastDeptName"
      Top             =   3720
      Visible         =   0   'False
      Width           =   1335
   End
   Begin VB.TextBox txtModel 
      DataField       =   "Model"
      DataSource      =   "dtcInventory"
      Height          =   285
      Left            =   1200
      MaxLength       =   30
      TabIndex        =   6
      Top             =   3000
      Width           =   2415
   End
   Begin VB.Data dtcRetailPrice 
      Caption         =   "RetailPrice"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   9480
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   2280
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcMaterial 
      Caption         =   "Material"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   9480
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Material"
      Top             =   3960
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcBrand 
      Caption         =   "Brand"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   9480
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT BrandCode, BrandDescription FROM Brand ORDER BY BrandDescription"
      Top             =   3000
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcSupplier 
      Caption         =   "Supplier"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   9480
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT SupplierCode, SupplierName FROM Supplier ORDER BY SupplierName"
      Top             =   3720
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcCategory 
      Caption         =   "Category"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   9480
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT DISTINCT CategoryCode, CategoryName FROM Category ORDER BY CAtegoryName"
      Top             =   3480
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcClass 
      Caption         =   "Class"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   9480
      Options         =   0
      ReadOnly        =   -1  'True
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT DISTINCT ClassCode, ClassName FROM Class ORDER BY ClassName"
      Top             =   3240
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcDepartment 
      Caption         =   "Department"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   9480
      Options         =   0
      ReadOnly        =   -1  'True
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Department"
      Top             =   2760
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcInventory 
      Caption         =   "Inventory"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   9480
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   2520
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.TextBox txtFields 
      DataField       =   "Remarks"
      DataSource      =   "dtcInventory"
      Height          =   675
      Index           =   17
      Left            =   8640
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   17
      Top             =   1560
      Width           =   2535
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar tbrTaskButton 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   38
      TabStop         =   0   'False
      Top             =   0
      Width           =   11295
      _Version        =   131073
      _ExtentX        =   19923
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
      Btns            =   10
      ToolsetPicture  =   "frmInvt.frx":55B0
      BC              =   10
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
      BtnToolNum(9)   =   9
      BtnPlaceHolder(9)=   0   'False
      ToolsetNumTools =   10
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
      ToolsetToolID(8)=   "ID_Copy"
      ToolsetToolHelp(8)=   "Copy Record"
      ToolsetToolMnemonic(8)=   "c"
      ToolsetToolGroup(8)=   3
      ToolsetToolID(9)=   "ID_Exit"
      ToolsetToolHelp(9)=   "Exit Task"
      ToolsetToolMnemonic(9)=   "x"
      ToolsetToolGroup(9)=   3
      MouseIcon       =   "frmInvt.frx":14642
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   30
      Left            =   120
      TabIndex        =   50
      Top             =   4200
      Width           =   11055
      _ExtentX        =   19500
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
   Begin MSMask.MaskEdBox mskMarkdown 
      DataField       =   "RetailMarkDownAmt"
      DataSource      =   "dtcRetailPrice"
      Height          =   255
      Left            =   8640
      TabIndex        =   19
      Top             =   2640
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   450
      _Version        =   393216
      Format          =   "$#,##0.00"
      PromptChar      =   "_"
   End
   Begin MSMask.MaskEdBox mskLeastSellingPrice 
      DataField       =   "LeastSellingPrice"
      DataSource      =   "dtcRetailPrice"
      Height          =   255
      Left            =   8640
      TabIndex        =   20
      Top             =   3000
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   450
      _Version        =   393216
      PromptInclude   =   0   'False
      Format          =   "$#,##0.00"
      PromptChar      =   "_"
   End
   Begin MSMask.MaskEdBox mskRetailPrice 
      DataField       =   "RetailPrice"
      DataSource      =   "dtcRetailPrice"
      Height          =   255
      Left            =   8640
      TabIndex        =   18
      Top             =   2280
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   450
      _Version        =   393216
      Format          =   "$#,##0.00"
      PromptChar      =   "_"
   End
   Begin MSDBCtls.DBCombo dbcSelBrand 
      Bindings        =   "frmInvt.frx":1465E
      Height          =   315
      Left            =   7680
      TabIndex        =   61
      TabStop         =   0   'False
      Top             =   4560
      Width           =   1695
      _ExtentX        =   2990
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "BrandDescription"
      BoundColumn     =   "BrandCode"
      Text            =   "dbcSelBrand"
   End
   Begin MSMask.MaskEdBox mskSKU 
      DataField       =   "SKU"
      DataSource      =   "dtcInventory"
      Height          =   255
      Left            =   8640
      TabIndex        =   16
      Top             =   1200
      Width           =   1575
      _ExtentX        =   2778
      _ExtentY        =   450
      _Version        =   393216
      PromptInclude   =   0   'False
      MaxLength       =   13
      Mask            =   "#############"
      PromptChar      =   "_"
   End
   Begin MSDBCtls.DBCombo dbcSelSupplier 
      Bindings        =   "frmInvt.frx":14678
      Height          =   315
      Left            =   5520
      TabIndex        =   52
      TabStop         =   0   'False
      Top             =   4560
      Width           =   1935
      _ExtentX        =   3413
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "SupplierName"
      BoundColumn     =   "SupplierCode"
      Text            =   "dbcSelSupplier"
   End
   Begin MSDBCtls.DBCombo dbcSelCategory 
      Bindings        =   "frmInvt.frx":14695
      Height          =   315
      Left            =   3600
      TabIndex        =   49
      TabStop         =   0   'False
      Top             =   4560
      Width           =   1695
      _ExtentX        =   2990
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "CategoryName"
      BoundColumn     =   "CategoryCode"
      Text            =   "dbcSelCategory"
   End
   Begin MSDBCtls.DBCombo dbcSelClass 
      Bindings        =   "frmInvt.frx":146AF
      Height          =   315
      Left            =   1800
      TabIndex        =   48
      TabStop         =   0   'False
      Top             =   4560
      Width           =   1575
      _ExtentX        =   2778
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "ClassName"
      BoundColumn     =   "ClassCode"
      Text            =   "dbcSelClass"
   End
   Begin MSDBCtls.DBCombo dbcSelDepartment 
      Bindings        =   "frmInvt.frx":146C6
      Height          =   315
      Left            =   120
      TabIndex        =   47
      TabStop         =   0   'False
      Top             =   4560
      Width           =   1455
      _ExtentX        =   2566
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "DepartmentName"
      BoundColumn     =   "DepartmentCode"
      Text            =   "dbcSelDepartment"
   End
   Begin MSMask.MaskEdBox mskSize 
      DataField       =   "Size"
      DataSource      =   "dtcInventory"
      Height          =   255
      Left            =   5640
      TabIndex        =   9
      Top             =   1560
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   450
      _Version        =   393216
      ClipMode        =   1
      PromptInclude   =   0   'False
      MaxLength       =   6
      Mask            =   ">aaaaaa"
      PromptChar      =   "_"
   End
   Begin MSMask.MaskEdBox mskColor 
      DataField       =   "Color"
      DataSource      =   "dtcInventory"
      Height          =   255
      Left            =   5640
      TabIndex        =   8
      Top             =   1200
      Width           =   975
      _ExtentX        =   1720
      _ExtentY        =   450
      _Version        =   393216
      ClipMode        =   1
      PromptInclude   =   0   'False
      MaxLength       =   8
      Mask            =   ">CCCCCCCC"
      PromptChar      =   "_"
   End
   Begin MSDBCtls.DBCombo dbcMaterial 
      Bindings        =   "frmInvt.frx":146E2
      DataField       =   "MaterialCode"
      DataSource      =   "dtcInventory"
      Height          =   315
      Left            =   1200
      TabIndex        =   7
      Top             =   3360
      Width           =   2415
      _ExtentX        =   4260
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "MaterialDescription"
      BoundColumn     =   "MaterialCode"
      Text            =   "dbcMaterial"
   End
   Begin MSDBCtls.DBCombo dbcBrand 
      Bindings        =   "frmInvt.frx":146FC
      DataField       =   "BrandCode"
      DataSource      =   "dtcInventory"
      Height          =   315
      Left            =   1200
      TabIndex        =   5
      Top             =   2640
      Width           =   2415
      _ExtentX        =   4260
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "BrandDescription"
      BoundColumn     =   "BrandCode"
      Text            =   "dbcBrand"
   End
   Begin MSDBCtls.DBCombo dbcSupplier 
      Bindings        =   "frmInvt.frx":14713
      DataField       =   "SupplierCode"
      DataSource      =   "dtcInventory"
      Height          =   315
      Left            =   1200
      TabIndex        =   4
      Top             =   2280
      Width           =   2415
      _ExtentX        =   4260
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "SupplierName"
      BoundColumn     =   "SupplierCode"
      Text            =   "dbcSupplier"
   End
   Begin MSDBCtls.DBCombo dbcCategory 
      Bindings        =   "frmInvt.frx":1472D
      DataField       =   "CategoryCode"
      DataSource      =   "dtcInventory"
      Height          =   315
      Left            =   1200
      TabIndex        =   3
      Top             =   1920
      Width           =   2415
      _ExtentX        =   4260
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "CategoryName"
      BoundColumn     =   "CategoryCode"
      Text            =   "dbcCategory"
   End
   Begin MSDBCtls.DBCombo dbcClass 
      Bindings        =   "frmInvt.frx":14747
      DataField       =   "ClassCode"
      DataSource      =   "dtcInventory"
      Height          =   315
      Left            =   1200
      TabIndex        =   2
      Top             =   1560
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
   Begin MSDBCtls.DBCombo dbcDepartment 
      Bindings        =   "frmInvt.frx":1475E
      DataField       =   "DepartmentCode"
      DataSource      =   "dtcInventory"
      Height          =   315
      Left            =   1200
      TabIndex        =   1
      Top             =   1200
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
   Begin Threed.SSCommand cmdFindModel 
      Height          =   315
      Left            =   10800
      TabIndex        =   80
      Top             =   4560
      Width           =   375
      _ExtentX        =   661
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
      Picture         =   "frmInvt.frx":1477A
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand11 
      Height          =   315
      Left            =   9360
      TabIndex        =   77
      TabStop         =   0   'False
      Top             =   2280
      Width           =   345
      _ExtentX        =   609
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
      Picture         =   "frmInvt.frx":14D20
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSRibbon cmdLockBrand 
      Height          =   315
      Left            =   3600
      TabIndex        =   74
      Top             =   2640
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   556
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmInvt.frx":1529E
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmInvt.frx":15800
      GroupNumber     =   5
   End
   Begin Threed.SSRibbon cmdLockSupplier 
      Height          =   315
      Left            =   3600
      TabIndex        =   65
      Top             =   2280
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   556
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmInvt.frx":15D52
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmInvt.frx":162B4
      GroupNumber     =   4
   End
   Begin Threed.SSRibbon cmdLockCategory 
      Height          =   315
      Left            =   3600
      TabIndex        =   64
      Top             =   1920
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   556
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmInvt.frx":16806
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmInvt.frx":16D68
      GroupNumber     =   3
   End
   Begin Threed.SSRibbon cmdLockClass 
      Height          =   315
      Left            =   3600
      TabIndex        =   63
      Top             =   1560
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   556
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmInvt.frx":172BA
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmInvt.frx":1781C
      GroupNumber     =   2
   End
   Begin Threed.SSRibbon cmdLockDept 
      Height          =   315
      Left            =   3600
      TabIndex        =   62
      Top             =   1200
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   556
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmInvt.frx":17D6E
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmInvt.frx":182D0
   End
   Begin Threed.SSCommand SSCommand6 
      Height          =   315
      Left            =   3600
      TabIndex        =   43
      TabStop         =   0   'False
      Top             =   3360
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
      Picture         =   "frmInvt.frx":18822
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand4 
      Height          =   315
      Left            =   3960
      TabIndex        =   42
      TabStop         =   0   'False
      Top             =   2640
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
      Picture         =   "frmInvt.frx":18DF0
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   315
      Left            =   3960
      TabIndex        =   41
      TabStop         =   0   'False
      Top             =   2280
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
      Picture         =   "frmInvt.frx":193BE
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdGetSKU 
      Height          =   300
      Left            =   10200
      TabIndex        =   40
      TabStop         =   0   'False
      Top             =   1200
      Width           =   300
      _ExtentX        =   529
      _ExtentY        =   529
      _Version        =   131074
      PictureFrames   =   1
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Picture         =   "frmInvt.frx":1998C
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   0
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   315
      Left            =   3960
      TabIndex        =   39
      TabStop         =   0   'False
      Top             =   1920
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
      Picture         =   "frmInvt.frx":19EDE
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin VB.Label Label13 
      Caption         =   "Model/Style"
      Height          =   255
      Left            =   9600
      TabIndex        =   78
      Top             =   4320
      Width           =   855
   End
   Begin VB.Label Label12 
      Caption         =   "Brand"
      Height          =   255
      Left            =   7680
      TabIndex        =   60
      Top             =   4320
      Width           =   495
   End
   Begin VB.Label Label11 
      Caption         =   "Markdown"
      Height          =   255
      Left            =   7560
      TabIndex        =   59
      Top             =   2640
      Width           =   975
   End
   Begin VB.Label Label10 
      Caption         =   "Least Selling Price"
      Height          =   375
      Left            =   7560
      TabIndex        =   58
      Top             =   3000
      Width           =   975
   End
   Begin VB.Label Label9 
      Caption         =   "Reorder Qty"
      Height          =   255
      Left            =   7560
      TabIndex        =   57
      Top             =   3840
      Width           =   975
   End
   Begin VB.Label Label8 
      Caption         =   "Reorder Level"
      Height          =   255
      Left            =   7560
      TabIndex        =   56
      Top             =   3480
      Width           =   1095
   End
   Begin VB.Label Label7 
      Caption         =   "Retail Price"
      Height          =   255
      Left            =   7560
      TabIndex        =   55
      Top             =   2280
      Width           =   855
   End
   Begin VB.Label Label6 
      Caption         =   "Temple"
      Height          =   255
      Left            =   4680
      TabIndex        =   54
      Top             =   2280
      Width           =   615
   End
   Begin VB.Label Label5 
      Caption         =   "Bridge"
      Height          =   255
      Left            =   4680
      TabIndex        =   53
      Top             =   1920
      Width           =   615
   End
   Begin VB.Label Label4 
      Caption         =   "Supplier"
      Height          =   255
      Left            =   5520
      TabIndex        =   51
      Top             =   4320
      Width           =   615
   End
   Begin VB.Label Label3 
      Caption         =   "Category"
      Height          =   255
      Left            =   3600
      TabIndex        =   46
      Top             =   4320
      Width           =   735
   End
   Begin VB.Label Label2 
      Caption         =   "Class"
      Height          =   255
      Left            =   1800
      TabIndex        =   45
      Top             =   4320
      Width           =   495
   End
   Begin VB.Label Label1 
      Caption         =   "Department"
      Height          =   255
      Left            =   120
      TabIndex        =   44
      Top             =   4320
      Width           =   855
   End
   Begin VB.Label lblLabels 
      Caption         =   "Remarks:"
      Height          =   255
      Index           =   17
      Left            =   7560
      TabIndex        =   36
      Top             =   1560
      Width           =   735
   End
   Begin VB.Label lblLabels 
      Caption         =   "SKU:"
      Height          =   255
      Index           =   14
      Left            =   7560
      TabIndex        =   35
      Top             =   1200
      Width           =   615
   End
   Begin VB.Label lblLabels 
      Caption         =   "Base Curve:"
      Height          =   255
      Index           =   13
      Left            =   4680
      TabIndex        =   34
      Top             =   3720
      Width           =   975
   End
   Begin VB.Label lblLabels 
      Caption         =   "Diameter"
      Height          =   255
      Index           =   12
      Left            =   4680
      TabIndex        =   33
      Top             =   3360
      Width           =   855
   End
   Begin VB.Label lblLabels 
      Caption         =   "Cylinder:"
      Height          =   255
      Index           =   11
      Left            =   4680
      TabIndex        =   32
      Top             =   3000
      Width           =   615
   End
   Begin VB.Label lblLabels 
      Caption         =   "Sphere:"
      Height          =   255
      Index           =   10
      Left            =   4680
      TabIndex        =   31
      Top             =   2655
      Width           =   735
   End
   Begin VB.Label lblLabels 
      Caption         =   "Material:"
      Height          =   255
      Index           =   9
      Left            =   120
      TabIndex        =   30
      Top             =   3360
      Width           =   855
   End
   Begin VB.Label lblSize 
      Caption         =   "Size:"
      Height          =   255
      Index           =   7
      Left            =   4680
      TabIndex        =   29
      Top             =   1560
      Width           =   615
   End
   Begin VB.Label lblLabels 
      Caption         =   "Color:"
      Height          =   255
      Index           =   6
      Left            =   4680
      TabIndex        =   28
      Top             =   1200
      Width           =   615
   End
   Begin VB.Label lblModel 
      Caption         =   "Model:"
      Height          =   255
      Index           =   5
      Left            =   120
      TabIndex        =   27
      Top             =   3000
      Width           =   975
   End
   Begin VB.Label lblLabels 
      Caption         =   "Brand:"
      Height          =   255
      Index           =   4
      Left            =   120
      TabIndex        =   26
      Top             =   2640
      Width           =   855
   End
   Begin VB.Label lblLabels 
      Caption         =   "Supplier:"
      Height          =   255
      Index           =   3
      Left            =   120
      TabIndex        =   25
      Top             =   2280
      Width           =   855
   End
   Begin VB.Label lblLabels 
      Caption         =   "Category:"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   24
      Top             =   1920
      Width           =   855
   End
   Begin VB.Label lblLabels 
      Caption         =   "Class:"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   23
      Top             =   1575
      Width           =   975
   End
   Begin VB.Label lblLabels 
      Caption         =   "Department:"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   0
      Top             =   1200
      Width           =   975
   End
End
Attribute VB_Name = "frmInvt"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim strLens         As String
Dim strFrame        As String
Dim strContactLens  As String
Dim strService      As String

Dim intBrand        As Integer
Dim intMaterial     As Integer
Dim intModel        As Integer
Dim intColor        As Integer
Dim intSize         As Integer
Dim intBridge       As Integer
Dim intTemple       As Integer
Dim intCylinder     As Integer
Dim intSphere       As Integer
Dim intBaseCurve    As Integer
Dim intDiameter     As Integer




Private Sub cmdFindModel_Click()
        Dim strSQL As String
        
        Screen.MousePointer = vbHourglass
        strSQL = "SELECT * FROM Inventory " _
            & "WHERE Model LIKE '" & txtSelModel.Text & "' " _
            & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
        dtcInventory.RecordSource = strSQL
        dtcInventory.Refresh
        dtcInventory.UpdateControls
        Screen.MousePointer = vbDefault
        
        ' RePaint the grid
        Call Mode_Standard

End Sub


Private Sub cmdGetSKU_Click()
    mskSKU.Text = GetSKUNumber()
    mskSKU.SetFocus

End Sub

Private Sub cmdLockBrand_Click(Value As Integer)
    Select Case Value
    Case True   ' Lock the Brand Info
        ' Set button background color to white
        cmdLockBrand.BackColor = &HFFFFFF
        ' Lock the last Brand Code & Brand Name
        txtLastBrandName.Text = dbcBrand.Text
        txtLastBrandCode.Text = dbcBrand.BoundText
        ' Disable the dbcSupplier
        dbcBrand.Enabled = False
    Case False  ' Unlock the Brand Info
        ' Set button background color to gray
        cmdLockBrand.BackColor = &HC0C0C0      ' Gray
        ' Enable the dbcBrand
        dbcBrand.Enabled = True
    End Select

End Sub


Private Sub cmdLockCategory_Click(Value As Integer)
    Select Case Value
    Case True   ' Lock the Category Info
        ' Set button background color to white
        cmdLockCategory.BackColor = &HFFFFFF
        ' Lock the last Category Code & Class Name
        txtLastCategoryName.Text = dbcCategory.Text
        txtLastCategoryCode.Text = dbcCategory.BoundText
        ' Disable the dbcCategory
        dbcCategory.Enabled = False
    Case False  ' Unlock the Category Info
        ' Set button background color to gray
        cmdLockCategory.BackColor = &HC0C0C0      ' Gray
        ' Enable the dbcCategory
        dbcCategory.Enabled = True
    End Select

End Sub


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


Private Sub cmdLockSupplier_Click(Value As Integer)
    Select Case Value
    Case True   ' Lock the Supplier Info
        ' Set button background color to white
        cmdLockSupplier.BackColor = &HFFFFFF
        ' Lock the last Category Code & Class Name
        txtLastSupplierName.Text = dbcSupplier.Text
        txtLastSupplierCode.Text = dbcSupplier.BoundText
        ' Disable the dbcSupplier
        dbcSupplier.Enabled = False
    Case False  ' Unlock the Supplier Info
        ' Set button background color to gray
        cmdLockSupplier.BackColor = &HC0C0C0      ' Gray
        ' Enable the dbcCategory
        dbcSupplier.Enabled = True
    End Select

End Sub

Private Sub dbcClass_Click(intArea As Integer)

    On Error GoTo dbcClass_Click_Err

    If intArea = dbcAreaList Then
        ' RePaint input screen
        Select Case dbcClass.BoundText
        Case Is = strFrame
            Call Mode_Frame
        Case Is = strLens
            Call Mode_Lens
        Case Is = strContactLens
            Call Mode_ContactLens
        Case Is = strService
            Call Mode_Service
        Case Else
            Call Mode_Else
        End Select
        
        ' When Class was selected,
        ' Category DBCombo contains only those with the same Class Code, Dept Code
        Dim strSQL As String
        strSQL = "SELECT * FROM Category " _
            & "WHERE DepartmentCode = '" & dbcDepartment.BoundText & "' AND " _
            & "ClassCode = '" & dbcClass.BoundText & "' " _
            & "ORDER BY CategoryName"
        dtcCategory.RecordSource = strSQL
        dtcCategory.Refresh
        dtcCategory.UpdateControls
    End If

dbcClass_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                            ' Tutorial Autocode
    Exit Sub                                        ' Tutorial Autocode
dbcClass_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcClass_Click()", Err)  ' Tutorial Autocode
    Resume dbcClass_Click_Exit

End Sub

Private Sub dbcDepartment_Change()
    ' When Dept was selected,
    ' Class DBCombo contains only those with the same Dept Code
        Dim strSQL As String
        strSQL = "SELECT * FROM Class " _
            & "WHERE Department = '" & dbcDepartment.BoundText & "' " _
            & "ORDER BY ClassName"
        dtcClass.RecordSource = strSQL
        dtcClass.Refresh
        dtcClass.UpdateControls

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

Private Sub dbcSelBrand_Click(intArea As Integer)

    On Error GoTo dbcSelBrand_Click_Err


    If intArea = dbcAreaList Then
        dbcSelDepartment.Text = ""  ' Set selected department to null
        dbcSelClass.Text = ""       ' Set selected class to null
        dbcSelCategory.Text = ""    ' Set selected category to null
        dbcSelSupplier.Text = ""    ' Set selected supplier to null
        Dim strSQL As String
        strSQL = "SELECT * FROM Inventory " _
            & "WHERE BrandCode = '" & dbcSelBrand.BoundText & "' " _
            & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
        dtcInventory.RecordSource = strSQL
        dtcInventory.Refresh
        dtcInventory.UpdateControls
        
        ' RePaint the grid
        Call Mode_Standard
    End If


dbcSelBrand_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                               ' Tutorial Autocode
    Exit Sub                                           ' Tutorial Autocode
dbcSelBrand_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelBrand_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelBrand_Click_Exit

End Sub

Private Sub dbcSelCategory_Click(intArea As Integer)

    On Error GoTo dbcSelCategory_Click_Err

    If intArea = dbcAreaList Then
        dbcSelSupplier.Text = ""    ' Set selected supplier to null
        dbcSelBrand.Text = ""       ' Set selected brand to null
        Dim strSQL As String
        strSQL = "SELECT * FROM Inventory " _
            & "WHERE DepartmentCode = '" & dbcSelDepartment.BoundText & "' AND " _
                  & "ClassCode = '" & dbcSelClass.BoundText & "' AND " _
                  & "CategoryCode = '" & dbcSelCategory.BoundText & "' " _
            & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
        dtcInventory.RecordSource = strSQL
        dtcInventory.Refresh
        dtcInventory.UpdateControls
    End If

dbcSelCategory_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                 ' Tutorial Autocode
    Exit Sub                                             ' Tutorial Autocode
dbcSelCategory_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelCategory_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelCategory_Click_Exit

End Sub

Private Sub dbcSelClass_Click(intArea As Integer)

    On Error GoTo dbcSelClass_Click_Err

    If intArea = dbcAreaList Then
        dbcSelCategory.Text = ""    ' Set selected category to null
        dbcSelSupplier.Text = ""    ' Set selected supplier to null
        dbcSelBrand.Text = ""       ' Set selected brand to null
        Dim strSQL As String
        ' Sync Category DAO with SelDepartment & SelClass
        strSQL = "SELECT * FROM Category " _
            & "WHERE DepartmentCode = '" & dbcSelDepartment.BoundText & "' AND " _
            & "ClassCode = '" & dbcSelClass.BoundText & "' " _
            & "ORDER BY CategoryName"
        dtcCategory.RecordSource = strSQL
        dtcCategory.Refresh
        dtcCategory.UpdateControls
        ' Sync Inventory DAO Contents
        strSQL = "SELECT * FROM Inventory " _
            & "WHERE DepartmentCode = '" & dbcSelDepartment.BoundText & "' AND " _
                  & "ClassCode = '" & dbcSelClass.BoundText & "' " _
            & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
        dtcInventory.RecordSource = strSQL
        dtcInventory.Refresh
        dtcInventory.UpdateControls
        
        Select Case dbcSelClass.BoundText
        Case Is = strFrame
            Call Mode_Frame
        Case Is = strLens
            Call Mode_Lens
        Case Is = strContactLens
            Call Mode_ContactLens
        Case Is = strService
            Call Mode_Service
        Case Else
            Call Mode_Else
        End Select
        
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
        dbcSelClass.Text = ""       ' Set selected category to null
        dbcSelCategory.Text = ""    ' Set selected category to null
        dbcSelSupplier.Text = ""    ' Set selected supplier to null
        dbcSelBrand.Text = ""       ' Set selected brand to null
        Dim strSQL As String
        ' Sync Class DAO Contents with the same Dept Code
        strSQL = "SELECT * FROM Class " _
            & "WHERE Department = '" & dbcSelDepartment.BoundText & "' " _
            & "ORDER BY ClassName"
        dtcClass.RecordSource = strSQL
        dtcClass.Refresh
        dtcClass.UpdateControls
        ' Sync Inventory DAO Contents
        strSQL = "SELECT * FROM Inventory " _
            & "WHERE DepartmentCode = '" & dbcSelDepartment.BoundText & "' " _
            & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
        dtcInventory.RecordSource = strSQL
        dtcInventory.Refresh
        dtcInventory.UpdateControls
        ' Skip this if dtcInventory has no record:
        If dtcInventory.Recordset.EOF And dtcInventory.Recordset.BOF Then
            strSQL = "SELECT * FROM RetailPrice " _
                & "WHERE SKU = ' '"
            dtcRetailPrice.RecordSource = strSQL
            dtcRetailPrice.Refresh
            dtcRetailPrice.UpdateControls
        End If
    End If

dbcSelDepartment_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                 ' Tutorial Autocode
    Exit Sub                                             ' Tutorial Autocode
dbcSelDepartment_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelDepartment_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelDepartment_Click_Exit

End Sub

Private Sub dbcSelSupplier_Click(intArea As Integer)

    On Error GoTo dbcSelSupplier_Click_Err

    If intArea = dbcAreaList Then
        dbcSelDepartment.Text = ""  ' Set selected department to null
        dbcSelClass.Text = ""       ' Set selected class to null
        dbcSelCategory.Text = ""    ' Set selected category to null
        dbcSelBrand.Text = ""       ' Set selected brand to null
        Dim strSQL As String
        strSQL = "SELECT * FROM Inventory " _
            & "WHERE SupplierCode = '" & dbcSelSupplier.BoundText & "' " _
            & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
        dtcInventory.RecordSource = strSQL
        dtcInventory.Refresh
        dtcInventory.UpdateControls
        
        ' RePaint the grid
        Call Mode_Standard
        
    End If

dbcSelSupplier_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                 ' Tutorial Autocode
    Exit Sub                                             ' Tutorial Autocode
dbcSelSupplier_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelSupplier_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelSupplier_Click_Exit

End Sub

Private Sub dtcInventory_Reposition()

    On Error GoTo dtcInventory_Reposition_Err

    Dim strSQL As String
    
    With dtcInventory.Recordset
        Select Case .EditMode
            Case dbEditAdd
                mskSKU.Enabled = True
                cmdGetSKU.Visible = True
            Case Else
                mskSKU.Enabled = False
                cmdGetSKU.Visible = False
        End Select
    End With
    ' Synchronize the record position of RetailPrice to Inventory
    ' by SKU
    If dtcInventory.Recordset.BOF Or _
       dtcInventory.Recordset.EOF Then
    Else
        strSQL = "SELECT * FROM RetailPrice WHERE SKU = '" & _
                  dtcInventory.Recordset.Fields("SKU") & "'"
        dtcRetailPrice.RecordSource = strSQL
        dtcRetailPrice.Refresh
        dtcRetailPrice.UpdateControls
        
    End If
    
dtcInventory_Reposition_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                     ' Tutorial Autocode
    Exit Sub                                                 ' Tutorial Autocode
dtcInventory_Reposition_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dtcInventory_Reposition()", Err)  ' Tutorial Autocode
    Resume dtcInventory_Reposition_Exit

End Sub

Private Sub Form_Activate()

    On Error GoTo Form_Activate_Err

    Screen.MousePointer = vbDefault
    
    'Initialize the dbcDepartment
    dbcSelDepartment.SetFocus
    SendKeys "{F4}{Enter}", True
    Call dbcSelDepartment_Click(2)
    
    ' Goto dbcDepartment
    dbcSelDepartment.SetFocus

Form_Activate_Exit:                                ' Tutorial Autocode
    On Error Resume Next                           ' Tutorial Autocode
    Exit Sub                                       ' Tutorial Autocode
Form_Activate_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("Form_Activate()", Err)  ' Tutorial Autocode
    Resume Form_Activate_Exit


End Sub

Private Sub Form_Load()

    On Error GoTo Form_Load_Err
    
    Call ofx_CenterForm(Me)

    ' Set grid column captions
    intBrand = 4
    intMaterial = 6
    intModel = 5
    intColor = 7
    intSize = 8
    intBridge = 9
    intTemple = 10
    intCylinder = 12
    intSphere = 11
    intBaseCurve = 14
    intDiameter = 13
    
    ' Retrieve the Default Class Code for Lens, frame, Contact Lens.
    strLens = GetDefaultClass_Lens
    strFrame = GetDefaultClass_Frame
    strContactLens = GetDefaultClass_ContactLens
    strService = GetDefaultClass_Service
    
    ' Determine the status of the Copy button
    Call SetCopyButton

Form_Load_Exit:                                ' Tutorial Autocode
    On Error Resume Next                       ' Tutorial Autocode
    Exit Sub                                   ' Tutorial Autocode
Form_Load_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("Form_Load()", Err)  ' Tutorial Autocode
    Resume Form_Load_Exit

End Sub















Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub mskColor_GotFocus()
    Call AutoSelect(mskColor)
End Sub

Private Sub mskLeastSellingPrice_Change()

    If Not myIsDecimal(mskLeastSellingPrice, 2, True) Or _
       Not IsPositive(mskLeastSellingPrice, True) Then
        mskLeastSellingPrice.SetFocus
    End If

End Sub

Private Sub mskLeastSellingPrice_GotFocus()
    Call AutoSelect(mskLeastSellingPrice)
End Sub

Private Sub mskLeastSellingPrice_LostFocus()

    If ofx_CCur(mskLeastSellingPrice.Text) = 0 Then Exit Sub  ' Ignor Zero Null ""
    If Not myIsDecimal(mskLeastSellingPrice, 2, True) Or _
       Not IsPositive(mskLeastSellingPrice, True) Or _
       Not IsA_LT_B(mskLeastSellingPrice, mskRetailPrice, True) Then
        mskLeastSellingPrice.SetFocus
    End If

End Sub

Private Sub mskMarkdown_Change()

    If Not myIsDecimal(mskMarkdown, 2, True) Or _
       Not IsPositive(mskMarkdown, True) Then
        mskMarkdown.SetFocus
    End If

End Sub

Private Sub mskMarkdown_GotFocus()
    Call AutoSelect(mskMarkdown)
    
End Sub

Private Sub mskMarkdown_LostFocus()

    If ofx_CCur(mskMarkdown.Text) = 0 Then Exit Sub  ' Ignor Zero Null ""
    If Not myIsDecimal(mskMarkdown, 2, True) Or _
       Not IsPositive(mskMarkdown, True) Or _
       Not IsA_LE_BMinusC(mskMarkdown, mskRetailPrice, mskLeastSellingPrice, True) Then
        mskMarkdown.SetFocus
    End If

End Sub

Private Sub mskRetailPrice_Change()

    If Not myIsDecimal(mskRetailPrice, 2, True) Or _
       Not IsPositive(mskRetailPrice, True) Then
        mskRetailPrice.SetFocus
    End If

End Sub

Private Sub mskRetailPrice_GotFocus()
    Call AutoSelect(mskRetailPrice)
End Sub

Private Sub mskRetailPrice_LostFocus()
    
    If Not myIsDecimal(mskRetailPrice, 2, True) Or _
       Not IsPositive(mskRetailPrice, True) Then
        mskRetailPrice.SetFocus
    End If

End Sub

Private Sub mskSize_GotFocus()
    ' Auto-select the whole window
    Call AutoSelect(mskSize)
'    mskSize.SelStart = 0
'    mskSize.SelLength = Len(mskSize.Text)
End Sub







Private Sub mskSKU_GotFocus()
    Call AutoSelect(mskSKU)
End Sub

Private Sub SSCommand1_Click()

    On Error GoTo SSCommand1_Click_Err

    If ofx_IsFormLoaded(frmCategory) Then _
        Unload frmCategory
    Screen.MousePointer = vbHourglass
    frmCategory.Show vbModal
    dtcCategory.Refresh
    dtcCategory.UpdateControls

SSCommand1_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSCommand1_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSCommand1_Click()", Err)  ' Tutorial Autocode
    Resume SSCommand1_Click_Exit

End Sub


Private Sub SSCommand11_Click()
    Dim RetVal As Variant
    RetVal = Shell("Calc.Exe", 1)
End Sub


Private Sub SSCommand3_Click()

    On Error GoTo SSCommand3_Click_Err

    If ofx_IsFormLoaded(frmSupplier) Then _
        Unload frmSupplier
    Screen.MousePointer = vbHourglass
    frmSupplier.Show vbModal
    dtcSupplier.Refresh
    dtcSupplier.UpdateControls
    dtcSelSupplier.Refresh
    dtcSelSupplier.UpdateControls

SSCommand3_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSCommand3_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSCommand3_Click()", Err)  ' Tutorial Autocode
    Resume SSCommand3_Click_Exit

End Sub

Private Sub SSCommand4_Click()

    On Error GoTo SSCommand4_Click_Err

    If ofx_IsFormLoaded(frmBrand) Then _
        Unload frmBrand
    Screen.MousePointer = vbHourglass
    frmBrand.Show vbModal
    dtcBrand.Refresh
    dtcBrand.UpdateControls
    dtcSelBrand.Refresh
    dtcSelBrand.UpdateControls

SSCommand4_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSCommand4_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSCommand4_Click()", Err)  ' Tutorial Autocode
    Resume SSCommand4_Click_Exit

End Sub


Private Sub SSCommand6_Click()

    On Error GoTo SSCommand6_Click_Err

    If ofx_IsFormLoaded(frmMaterial) Then _
        Unload frmMaterial
    Screen.MousePointer = vbHourglass
    frmMaterial.Show vbModal
    dtcMaterial.Refresh
    dtcMaterial.UpdateControls

SSCommand6_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSCommand6_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSCommand6_Click()", Err)  ' Tutorial Autocode
    Resume SSCommand6_Click_Exit

End Sub



Private Sub Mode_Lens()

    On Error GoTo Mode_Lens_Err


    ' RePaint the form
    dbcBrand.Enabled = True
    dbcMaterial.Enabled = True
    lblModel(5).Caption = "Lens Style"
    txtModel.Enabled = True
    mskColor.Enabled = True
    mskSize.Enabled = False
    
    txtBridge.Enabled = False
    txtTemple.Enabled = False
    txtCylinder.Enabled = True
    txtSphere.Enabled = True
    txtBaseCurve.Enabled = False
    txtDiameter.Enabled = True

    txtBridge.BackColor = pyLightGray
    txtTemple.BackColor = pyLightGray
    txtCylinder.BackColor = vbWindowBackground
    txtSphere.BackColor = vbWindowBackground
    txtBaseCurve.BackColor = pyLightGray
    txtDiameter.BackColor = vbWindowBackground

    ' RePaint the grid
    TDBGrid1.Columns(intBrand).Visible = True
    TDBGrid1.Columns(intMaterial).Visible = True
    TDBGrid1.Columns(intModel).Visible = True
    TDBGrid1.Columns(intModel).Caption = "Lens Style"
    TDBGrid1.Columns(intColor).Visible = True
    TDBGrid1.Columns(intSize).Visible = False
    TDBGrid1.Columns(intBridge).Visible = False
    TDBGrid1.Columns(intTemple).Visible = False
    TDBGrid1.Columns(intCylinder).Visible = True
    TDBGrid1.Columns(intSphere).Visible = True
    TDBGrid1.Columns(intBaseCurve).Visible = False
    TDBGrid1.Columns(intDiameter).Visible = True


Mode_Lens_Exit:                                ' Tutorial Autocode
    On Error Resume Next                       ' Tutorial Autocode
    Exit Sub                                   ' Tutorial Autocode
Mode_Lens_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("Mode_Lens()", Err)  ' Tutorial Autocode
    Resume Mode_Lens_Exit

End Sub

Private Sub Mode_Frame()

    On Error GoTo Mode_Frame_Err


    ' RePaint the form
    dbcBrand.Enabled = True
    dbcMaterial.Enabled = True
    lblModel(5).Caption = "Model"
    txtModel.Enabled = True
    mskColor.Enabled = True
    lblSize(7).Caption = "Eye Size"
    mskSize.Enabled = True
    
    txtBridge.Enabled = True
    txtTemple.Enabled = True
    txtCylinder.Enabled = False
    txtSphere.Enabled = False
    txtBaseCurve.Enabled = False
    txtDiameter.Enabled = False

    txtBridge.BackColor = vbWindowBackground
    txtTemple.BackColor = vbWindowBackground
    txtCylinder.BackColor = pyLightGray
    txtSphere.BackColor = pyLightGray
    txtBaseCurve.BackColor = pyLightGray
    txtDiameter.BackColor = pyLightGray

    ' RePaint the grid
    TDBGrid1.Columns(intBrand).Visible = True
    TDBGrid1.Columns(intMaterial).Visible = True
    TDBGrid1.Columns(intModel).Visible = True
    TDBGrid1.Columns(intModel).Caption = "Model"
    TDBGrid1.Columns(intColor).Visible = True
    TDBGrid1.Columns(intSize).Visible = True
    TDBGrid1.Columns(intSize).Caption = "EyeSize"
    TDBGrid1.Columns(intBridge).Visible = True
    TDBGrid1.Columns(intTemple).Visible = True
    TDBGrid1.Columns(intCylinder).Visible = False
    TDBGrid1.Columns(intSphere).Visible = False
    TDBGrid1.Columns(intBaseCurve).Visible = False
    TDBGrid1.Columns(intDiameter).Visible = False


Mode_Frame_Exit:                                ' Tutorial Autocode
    On Error Resume Next                        ' Tutorial Autocode
    Exit Sub                                    ' Tutorial Autocode
Mode_Frame_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("Mode_Frame()", Err)  ' Tutorial Autocode
    Resume Mode_Frame_Exit

End Sub

Private Sub Mode_ContactLens()

    On Error GoTo Mode_ContactLens_Err


    ' RePaint the form
    dbcBrand.Enabled = True
    dbcMaterial.Enabled = True
    lblModel(5).Caption = "Lens Style"
    txtModel.Enabled = True
    mskColor.Enabled = True
    mskSize.Enabled = False
    
    txtBridge.Enabled = False
    txtBridge.BackColor = pyLightGray
    txtTemple.Enabled = False
    txtTemple.BackColor = pyLightGray
    txtCylinder.Enabled = True
    txtCylinder.BackColor = vbWindowBackground
    txtSphere.Enabled = True
    txtSphere.BackColor = vbWindowBackground
    txtBaseCurve.Enabled = True
    txtBaseCurve.BackColor = vbWindowBackground
    txtDiameter.Enabled = True
    txtDiameter.BackColor = vbWindowBackground

    ' RePaint the grid
    TDBGrid1.Columns(intBrand).Visible = True
    TDBGrid1.Columns(intMaterial).Visible = True
    TDBGrid1.Columns(intModel).Visible = True
    TDBGrid1.Columns(intModel).Caption = "Lens Style"
    TDBGrid1.Columns(intColor).Visible = True
    TDBGrid1.Columns(intSize).Visible = False
    TDBGrid1.Columns(intBridge).Visible = False
    TDBGrid1.Columns(intTemple).Visible = False
    TDBGrid1.Columns(intCylinder).Visible = True
    TDBGrid1.Columns(intSphere).Visible = True
    TDBGrid1.Columns(intBaseCurve).Visible = True
    TDBGrid1.Columns(intDiameter).Visible = True
    

Mode_ContactLens_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
Mode_ContactLens_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("Mode_ContactLens()", Err)  ' Tutorial Autocode
    Resume Mode_ContactLens_Exit

End Sub

Private Sub Mode_Service()

    On Error GoTo Mode_Service_Err


    ' RePaint the form
    dbcBrand.Enabled = False
    dbcMaterial.Enabled = False
    txtModel.Enabled = False
    mskColor.Enabled = False
    mskSize.Enabled = False
    
    txtBridge.Enabled = False
    txtTemple.Enabled = False
    txtCylinder.Enabled = False
    txtSphere.Enabled = False
    txtBaseCurve.Enabled = False
    txtDiameter.Enabled = False

    txtBridge.BackColor = pyLightGray
    txtTemple.BackColor = pyLightGray
    txtCylinder.BackColor = pyLightGray
    txtSphere.BackColor = pyLightGray
    txtBaseCurve.BackColor = pyLightGray
    txtDiameter.BackColor = pyLightGray

    ' RePaint the grid
    TDBGrid1.Columns(intBrand).Visible = False
    TDBGrid1.Columns(intMaterial).Visible = False
    TDBGrid1.Columns(intModel).Visible = False
    TDBGrid1.Columns(intColor).Visible = False
    TDBGrid1.Columns(intSize).Visible = False
    TDBGrid1.Columns(intBridge).Visible = False
    TDBGrid1.Columns(intTemple).Visible = False
    TDBGrid1.Columns(intCylinder).Visible = False
    TDBGrid1.Columns(intSphere).Visible = False
    TDBGrid1.Columns(intBaseCurve).Visible = False
    TDBGrid1.Columns(intDiameter).Visible = False


Mode_Service_Exit:                                ' Tutorial Autocode
    On Error Resume Next                          ' Tutorial Autocode
    Exit Sub                                      ' Tutorial Autocode
Mode_Service_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("Mode_Service()", Err)  ' Tutorial Autocode
    Resume Mode_Service_Exit

End Sub

Private Sub Mode_Else()

    On Error GoTo Mode_Else_Err


    ' RePaint the form
    dbcBrand.Enabled = True
    dbcMaterial.Enabled = True
    txtModel.Enabled = True
    lblModel(5).Caption = "Model"
    mskColor.Enabled = True
    mskSize.Enabled = True
    lblSize(7).Caption = "Size"
    
    txtBridge.Enabled = False
    txtTemple.Enabled = False
    txtCylinder.Enabled = False
    txtSphere.Enabled = False
    txtBaseCurve.Enabled = False
    txtDiameter.Enabled = False

    txtBridge.BackColor = pyLightGray
    txtTemple.BackColor = pyLightGray
    txtCylinder.BackColor = pyLightGray
    txtSphere.BackColor = pyLightGray
    txtBaseCurve.BackColor = pyLightGray
    txtDiameter.BackColor = pyLightGray
    
    ' RePaint the grid
    TDBGrid1.Columns(intBrand).Visible = True
    TDBGrid1.Columns(intMaterial).Visible = True
    TDBGrid1.Columns(intModel).Visible = True
    TDBGrid1.Columns(intModel).Caption = "Model"
    TDBGrid1.Columns(intColor).Visible = True
    TDBGrid1.Columns(intSize).Visible = True
    TDBGrid1.Columns(intSize).Caption = "Size"
    TDBGrid1.Columns(intBridge).Visible = False
    TDBGrid1.Columns(intTemple).Visible = False
    TDBGrid1.Columns(intCylinder).Visible = False
    TDBGrid1.Columns(intSphere).Visible = False
    TDBGrid1.Columns(intBaseCurve).Visible = False
    TDBGrid1.Columns(intDiameter).Visible = False


Mode_Else_Exit:                                ' Tutorial Autocode
    On Error Resume Next                       ' Tutorial Autocode
    Exit Sub                                   ' Tutorial Autocode
Mode_Else_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("Mode_Else()", Err)  ' Tutorial Autocode
    Resume Mode_Else_Exit

End Sub

Private Sub Mode_Standard()

    On Error GoTo Mode_Standard_Err


    ' RePaint the grid
    TDBGrid1.Columns(intBrand).Visible = True
    TDBGrid1.Columns(intMaterial).Visible = True
    TDBGrid1.Columns(intModel).Visible = True
    TDBGrid1.Columns(intModel).Caption = "Model"
    TDBGrid1.Columns(intColor).Visible = True
    TDBGrid1.Columns(intSize).Visible = True
    TDBGrid1.Columns(intSize).Caption = "Size"
    TDBGrid1.Columns(intBridge).Visible = True
    TDBGrid1.Columns(intTemple).Visible = True
    TDBGrid1.Columns(intCylinder).Visible = True
    TDBGrid1.Columns(intSphere).Visible = True
    TDBGrid1.Columns(intBaseCurve).Visible = True
    TDBGrid1.Columns(intDiameter).Visible = True


Mode_Standard_Exit:                                ' Tutorial Autocode
    On Error Resume Next                           ' Tutorial Autocode
    Exit Sub                                       ' Tutorial Autocode
Mode_Standard_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("Mode_Standard()", Err)  ' Tutorial Autocode
    Resume Mode_Standard_Exit

End Sub




Private Sub tbrTaskButton_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)
    On Error GoTo tbrTaskButton_Click_Err

    Select Case ToolID
        Case "ID_Add"
            Action_Add
        Case "ID_Delete"
            Action_Delete
        Case "ID_Undo"
            'this is really only needed for multi user apps
            dtcInventory.Refresh
            dtcRetailPrice.Refresh

        Case "ID_Save"
            Action_Save
        Case "ID_Exit"
            ' Ignor current editing
            dtcInventory.Refresh
            dtcRetailPrice.Refresh
            '
            Unload Me
        Case "ID_First"
            dtcInventory.Recordset.MoveFirst
        Case "ID_Next"
            dtcInventory.Recordset.MoveNext
            ' Prevent the Blank Record
            If dtcInventory.Recordset.EOF Then
                Beep
                dtcInventory.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcInventory.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcInventory.Recordset.BOF Then
                Beep
                dtcInventory.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcInventory.Recordset.MoveLast
        Case "ID_Copy"
            DoCopy
    End Select

tbrTaskButton_Click_Exit:                               ' Tutorial Autocode
    On Error Resume Next                                ' Tutorial Autocode
    Exit Sub                                            ' Tutorial Autocode
tbrTaskButton_Click_Err:                                ' Tutorial Autocode
    Call ofx_GenericError("tbrTaskButton_Click()", Err) ' Tutorial Autocode
    Resume tbrTaskButton_Click_Exit
End Sub

Private Sub tmrClearDBComboHiLite_Timer()
    Call ClearDBComboHiLite(Me)
End Sub

Private Sub txtBaseCurve_Change()

    Dim sngValue As Single
    
    sngValue = ofx_CSng(txtBaseCurve.Text)
    
    If sngValue = 0 Or sngValue = 1 Then   ' Ignor Zero or Null or 1
    Else
        If Not myIsDecimal(txtBaseCurve, 1, True) Or _
           Not WithinRange(txtBaseCurve, 10, 8, True) Then
            txtBaseCurve.SetFocus
        End If
    End If
    
End Sub

Private Sub txtBaseCurve_GotFocus()
    ' Auto-select the whole window
    txtBaseCurve.SelStart = 0
    txtBaseCurve.SelLength = Len(txtBaseCurve.Text)
End Sub


Private Sub txtBaseCurve_LostFocus()

    Dim sngValue As Single
    
    sngValue = ofx_CSng(txtBaseCurve.Text)
    
    If sngValue <> 0 Then   ' Ignor Zero or Null
        If Not myIsDecimal(txtBaseCurve, 1, True) Or _
           Not WithinRange(txtBaseCurve, 10, 8, True) Then
            txtBaseCurve.SetFocus
        End If
    End If

End Sub

Private Sub txtBridge_Change()
    If Not myIsDecimal(txtBridge, 0, True) Or _
       Not WithinRange(txtBridge, 9999, 0, True) Then
        txtBridge.SetFocus
    End If
End Sub

Private Sub txtBridge_GotFocus()
    ' Auto-select the whole window
    txtBridge.SelStart = 0
    txtBridge.SelLength = Len(txtBridge.Text)
End Sub


Private Sub txtBridge_LostFocus()
    If Not myIsDecimal(txtBridge, 0, True) Or _
       Not WithinRange(txtBridge, 9999, 0, True) Then
        txtBridge.SetFocus
    End If
End Sub

Private Sub txtCylinder_Change()
    If Not myIsDecimal(txtCylinder, 2, True) Or _
       Not WithinRange(txtCylinder, 0, -6, True) Then
        txtCylinder.SetFocus
    End If
End Sub

Private Sub txtCylinder_GotFocus()
    ' Auto-select whole window
    txtCylinder.SelStart = 0
    txtCylinder.SelLength = Len(txtCylinder.Text)
End Sub


Private Sub txtCylinder_LostFocus()
    If Not myIsDecimal(txtCylinder, 2, True) Or _
       Not WithinRange(txtCylinder, 0, -6, True) Then
        txtCylinder.SetFocus
    End If
End Sub

Private Sub txtDiameter_Change()
    If Not myIsDecimal(txtDiameter, 2, True) Or _
       Not WithinRange(txtDiameter, 99.99, 0, True) Then
        txtDiameter.SetFocus
    End If
End Sub

Private Sub txtDiameter_GotFocus()
    ' Auto-select the whole window
    txtDiameter.SelStart = 0
    txtDiameter.SelLength = Len(txtDiameter.Text)
End Sub


Private Sub txtDiameter_LostFocus()
    If Not myIsDecimal(txtDiameter, 2, True) Or _
       Not WithinRange(txtDiameter, 99.99, 0, True) Then
        txtDiameter.SetFocus
    End If
End Sub





Private Sub txtModel_GotFocus()
    ' Auto-select the whole window
    Call AutoSelect(txtModel)
'    txtModel.SelStart = 0
'    txtModel.SelLength = Len(txtModel.Text)

End Sub


Private Sub txtReorderLevel_Change()

    If Not myIsDecimal(txtReorderLevel, 0, True) Or _
       Not IsPositive(txtReorderLevel, True) Then
        txtReorderLevel.SetFocus
    End If

End Sub

Private Sub txtReorderLevel_GotFocus()
    'Auto-select the whole window
    Call AutoSelect(txtReorderLevel)
'    txtReorderLevel.SelStart = 0
'    txtReorderLevel.SelLength = Len(txtReorderLevel.Text)
End Sub


Private Sub txtReorderLevel_LostFocus()

    If Not myIsDecimal(txtReorderLevel, 0, True) Or _
       Not IsPositive(txtReorderLevel, True) Then
        txtReorderLevel.SetFocus
    End If

End Sub

Private Sub txtReorderQty_Change()

    If Not myIsDecimal(txtReorderQty, 0, True) Or _
       Not IsPositive(txtReorderQty, True) Then
        txtReorderQty.SetFocus
    End If

End Sub

Private Sub txtReorderQty_GotFocus()
    ' Auto-select the whole window
    Call AutoSelect(txtReorderQty)
'    txtReorderQty.SelStart = 0
'    txtReorderQty.SelLength = Len(txtReorderQty.Text)
End Sub




Private Sub txtReorderQty_LostFocus()

    If Not myIsDecimal(txtReorderQty, 0, True) Or _
       Not IsPositive(txtReorderQty, True) Then
        txtReorderQty.SetFocus
    End If

End Sub

Private Sub txtSelModel_GotFocus()
    Call AutoSelect(txtSelModel)
End Sub

Private Sub txtSelModel_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindModel_Click
        KeyAscii = 0
    End If
End Sub


Private Sub txtSphere_Change()
    If Not myIsDecimal(txtSphere, 2, True) Or _
       Not WithinRange(txtSphere, 20, -20, True) Then
        txtSphere.SetFocus
    End If
End Sub

Private Sub txtSphere_GotFocus()
    ' Auto-select whole window
    txtSphere.SelStart = 0
    txtSphere.SelLength = Len(txtSphere.Text)
End Sub


Private Sub txtSphere_LostFocus()
    If Not myIsDecimal(txtSphere, 2, True) Or _
       Not WithinRange(txtSphere, 20, -20, True) Then
        txtSphere.SetFocus
        Exit Sub
    End If
End Sub


Private Sub txtTemple_Change()
    If Not myIsDecimal(txtTemple, 0, True) Or _
       Not WithinRange(txtTemple, 9999, 0, True) Then
        txtTemple.SetFocus
    End If
End Sub

Private Sub txtTemple_GotFocus()
    ' Auto-select the whole window
    txtTemple.SelStart = 0
    txtTemple.SelLength = Len(txtTemple.Text)
End Sub



' Validate Bridge field
' Accept 4 digit integer
Private Function Validate_Bridge(varBridge As Variant) As Boolean
    Dim IsInteger, WithinRange As Boolean
    Dim MyValue As Currency
    MyValue = ofx_CCur(varBridge)
    If (MyValue - Int(MyValue)) = 0 Then
        IsInteger = True
    End If
    If (MyValue >= 0) And (MyValue <= 9999) Then
        WithinRange = True
    End If
    If IsInteger And WithinRange Then
        Validate_Bridge = True
    Else
        Validate_Bridge = False
        ofx_DoMessageBox "Invalid Entry...Bridge = 0000 - 9999"
        txtBridge.SetFocus
    End If
End Function

Private Sub Action_Save()
    Dim Msg, Style, Title, Help As String
    Dim Ctxt, Response As Integer
    
    ' Validate entries first
'    If Not Validate_Bridge(txtBridge.Text) Then Exit Sub
'    If Not Validate_Temple(txtTemple.Text) Then Exit Sub
'    If Not Validate_Sphere(txtSphere.Text) Then Exit Sub
'    If Not Validate_Cylinder(txtCylinder.Text) Then Exit Sub
'    If Not Validate_Diameter(txtDiameter.Text) Then Exit Sub
'    If Not Validate_BaseCurve(txtBaseCurve.Text) Then Exit Sub
    If mskSKU.Text = "" Then
        Msg = "No SKU." & Chr$(13) & _
              "Do you want the me to generate one for you?"     ' Define message
        Style = vbYesNo + vbCritical + vbDefaultButton2 ' Define buttons.
        Title = "SKU Wizard"    ' Define title.
        Help = ""               ' Define Help file.
        Ctxt = 0                ' Define topic
        ' context.
        ' Display message.
        Response = MsgBox(Msg, Style, Title, Help, Ctxt)
        If Response = vbYes Then    ' User chose Yes.
            mskSKU.Text = GetSKUNumber()
        Else    ' User chose No.
            ofx_DoMessageBox "Save aborted."
            Exit Sub
        End If
    End If
  
    ' All pass;
    If IsNull(dtcRetailPrice.Recordset.Fields("SKU")) Then
        dtcRetailPrice.Recordset.Fields("SKU") = mskSKU.Text
    End If
    ' Update the Last Locked Record Contents
    txtLastDeptName.Text = dbcDepartment.Text
    txtLastDeptCode.Text = dbcDepartment.BoundText
    txtLastClassName.Text = dbcClass.Text
    txtLastClassCode.Text = dbcClass.BoundText
    txtLastCategoryName.Text = dbcCategory.Text
    txtLastCategoryCode.Text = dbcCategory.BoundText
    txtLastSupplierName.Text = dbcSupplier.Text
    txtLastSupplierCode.Text = dbcSupplier.BoundText
    txtLastBrandName.Text = dbcBrand.Text
    txtLastBrandCode.Text = dbcBrand.BoundText
    ' Update the Entries
    dtcRetailPrice.UpdateRecord
    dtcRetailPrice.Recordset.Bookmark = dtcRetailPrice.Recordset.LastModified
    dtcRetailPrice.UpdateControls
    dtcInventory.UpdateRecord
    dtcInventory.Recordset.Bookmark = dtcInventory.Recordset.LastModified
    dtcInventory.UpdateControls
End Sub

' Validate Bridge field
' Accept 4 digit integer
Private Function Validate_Temple(varTemple As Variant) As Boolean
    Dim IsInteger, WithinRange As Boolean
    Dim MyValue As Currency
    MyValue = ofx_CCur(varTemple)
    If (MyValue - Int(MyValue)) = 0 Then
        IsInteger = True
    End If
    If (MyValue >= 0) And (MyValue <= 9999) Then
        WithinRange = True
    End If
    If IsInteger And WithinRange Then
        Validate_Temple = True
    Else
        Validate_Temple = False
        ofx_DoMessageBox "Invalid Entry...Temple = 0000 - 9999"
        txtTemple.SetFocus
    End If
End Function

Private Sub txtTemple_LostFocus()
    If Not myIsDecimal(txtTemple, 0, True) Or _
       Not WithinRange(txtTemple, 9999, 0, True) Then
        txtTemple.SetFocus
    End If
End Sub



' Validate Sphere field
' Accept -20.00 to 20.00 step 0.25
Private Function Validate_Sphere(varSphere As Variant) As Boolean

    Dim Is2Decimal, WithinRange As Boolean
    Dim MyValue As Currency
    MyValue = ofx_CCur(varSphere)
    If ((MyValue * 100) - Int(MyValue * 100)) = 0 Then
        Is2Decimal = True
    End If
    If (MyValue >= -20) And (MyValue <= 20) Then
        WithinRange = True
    End If
    If Is2Decimal And WithinRange Then
        Validate_Sphere = True
    Else
        Validate_Sphere = False
        ofx_DoMessageBox "Invalid Entry...Sphere = -20.00 to 20.00 step 0.25"
        txtSphere.SetFocus
    End If
    
End Function

' Validate Cylinder field
' Accept -3.00 to 0.00 step 0.25
Private Function Validate_Cylinder(varCylinder As Variant) As Boolean
    Dim Is2Decimal, WithinRange As Boolean
    Dim MyValue As Currency
    MyValue = ofx_CCur(varCylinder)
    If ((MyValue * 100) - Int(MyValue * 100)) = 0 Then
        Is2Decimal = True
    End If
    If (MyValue >= -3) And (MyValue <= 0) Then
        WithinRange = True
    End If
    If Is2Decimal And WithinRange Then
        Validate_Cylinder = True
    Else
        Validate_Cylinder = False
        ofx_DoMessageBox "Invalid Entry...Cylinder = -3.00 to 0.00 step 0.25"
        txtCylinder.SetFocus
    End If
End Function

' Validate Diameter field
' Accept 99.99
Private Function Validate_Diameter(varDiameter As Variant) As Boolean
    Dim Is2Decimal, WithinRange As Boolean
    Dim MyValue As Currency
    MyValue = ofx_CCur(varDiameter)
    If ((MyValue * 100) - Int(MyValue * 100)) = 0 Then
        Is2Decimal = True
    End If
    If (MyValue >= 0) And (MyValue <= 99.99) Then
        WithinRange = True
    End If
    If Is2Decimal And WithinRange Then
        Validate_Diameter = True
    Else
        Validate_Diameter = False
        ofx_DoMessageBox "Invalid Entry...Diameter = 0 to 99.99"
        txtDiameter.SetFocus
    End If
End Function

' Validate BaseCurve field
' Accept 8 to 10 step 0.1
Private Function Validate_BaseCurve(varBaseCurve As Variant) As Boolean
    Dim Is2Decimal, WithinRange As Boolean
    Dim MyValue As Currency
    MyValue = ofx_CCur(varBaseCurve)
    If MyValue = 0 Then
        Validate_BaseCurve = True
    Else
    If ((MyValue * 10) - Int(MyValue * 10)) = 0 Then
        Is2Decimal = True
    End If
    If (MyValue >= 8) And (MyValue <= 10) Then
        WithinRange = True
    End If
    If Is2Decimal And WithinRange Then
        Validate_BaseCurve = True
    Else
        Validate_BaseCurve = False
        ofx_DoMessageBox "Invalid Entry...BaseCurve = 8 to 10 step 0.1"
        txtBaseCurve.SetFocus
    End If
    End If
End Function

Private Sub Action_Add()
    With dtcInventory.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    
    dtcInventory.Recordset.AddNew
    dtcRetailPrice.Recordset.AddNew
    ' Retrieve the Locked records
    If cmdLockDept.Value Then
        dbcDepartment.Text = txtLastDeptName.Text
        dbcDepartment.BoundText = txtLastDeptCode.Text
    End If
    If cmdLockClass.Value Then
        dbcClass.Text = txtLastClassName.Text
        dbcClass.BoundText = txtLastClassCode
    End If
    If cmdLockCategory.Value Then
        dbcCategory.Text = txtLastCategoryName.Text
        dbcCategory.BoundText = txtLastCategoryCode.Text
    End If
    If cmdLockSupplier.Value Then
        dbcSupplier.Text = txtLastSupplierName.Text
        dbcSupplier.BoundText = txtLastSupplierCode
    End If
    If cmdLockBrand.Value Then
        dbcBrand.Text = txtLastBrandName.Text
        dbcBrand.BoundText = txtLastBrandCode
    End If
    ' Set focus
    If dbcDepartment.Enabled And dbcClass.Enabled And _
        dbcCategory.Enabled And dbcSupplier.Enabled And _
        dbcBrand.Enabled Then
        dbcDepartment.SetFocus
    ElseIf dbcBrand.Enabled Then
        dbcBrand.SetFocus
    ElseIf dbcSupplier.Enabled Then
        dbcSupplier.SetFocus
    ElseIf dbcCategory.Enabled Then
        dbcCategory.SetFocus
    ElseIf dbcClass.Enabled Then
        dbcClass.SetFocus
    ElseIf dbcDepartment.Enabled Then
        dbcDepartment.SetFocus
    Else
        txtModel.SetFocus
    End If

End Sub

' Copy the current SKU to other forms
' Receiver could be:
'   frmSalesOrder, frmStockReceived
Private Sub DoCopy()
    ' 1st priority is SalesOrder
    ' 2nd priority is Stock Received
    If ofx_IsFormLoaded(frmSalesOrder) Or _
       ofx_IsFormLoaded(frmStockRecEnhanced) Then
        Clipboard.Clear
        Clipboard.SetText dtcInventory.Recordset.Fields("SKU")
        MsgBox "SKU " & dtcInventory.Recordset!SKU & " is copied"
    End If
    Unload Me
End Sub

' Determine the status of the Copy button
' Visible if Receiver is found, otherwise invisible
' Receiver could be: frmSalesOrder, frmStockReceived
Private Sub SetCopyButton()
    If ofx_IsFormLoaded(frmSalesOrder) Or _
       ofx_IsFormLoaded(frmStockRecEnhanced) Then
        tbrTaskButton.Buttons(8).Visible = True
    Else
        tbrTaskButton.Buttons(8).Visible = False
    End If
End Sub

Private Sub Action_Delete()
    ' Abort delete if record is active
    ' Definition of Active: DateLastIssued <> Null Or
    '                       DateLassReceived <> Null or
    '                       QtytotalOnHand <> 0
    With dtcInventory.Recordset
        If !DateLastIssued <> Null Or _
           !DateLastReceived <> Null Or _
           !QtyTotalOnhand <> 0 Then
            MsgBox "This is an active record." & Chr(13) & _
                   "Delete aborted!"
            Exit Sub
        End If
    End With
    
    'this may produce an error if you delete the last
    'record or the only record in the recordset
    dtcInventory.Recordset.Delete
    dtcRetailPrice.Recordset.Delete
    dtcInventory.Recordset.MoveNext
End Sub

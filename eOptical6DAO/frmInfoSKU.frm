VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{B074BC93-5A5B-11CE-98BD-0000C0E6B88E}#2.0#0"; "sstabs32.ocx"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmInfoSKU 
   Caption         =   "SKU Information"
   ClientHeight    =   8235
   ClientLeft      =   360
   ClientTop       =   1335
   ClientWidth     =   11730
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   8235
   ScaleWidth      =   11730
   WindowState     =   2  'Maximized
   Begin Threed.SSFrame SSFrame1 
      Height          =   4335
      Left            =   120
      TabIndex        =   0
      Top             =   1140
      Width           =   11535
      _ExtentX        =   20346
      _ExtentY        =   7646
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
      Caption         =   "Lookup Wizard"
      Begin TrueDBGrid50.TDBGrid TDBGrid1 
         Bindings        =   "frmInfoSKU.frx":0000
         Height          =   2475
         Left            =   120
         OleObjectBlob   =   "frmInfoSKU.frx":001B
         TabIndex        =   24
         Top             =   1740
         Width           =   11295
      End
      Begin VB.TextBox txtSKU 
         Height          =   315
         Left            =   1080
         TabIndex        =   35
         Top             =   300
         Width           =   1335
      End
      Begin VB.TextBox txtModel 
         Height          =   285
         Left            =   5160
         TabIndex        =   31
         Top             =   1020
         Width           =   2295
      End
      Begin VB.TextBox txtBaseCurve 
         DataField       =   "BaseCurve"
         DataSource      =   "dtcInventory"
         Height          =   285
         Left            =   9840
         TabIndex        =   27
         Text            =   "0"
         Top             =   1020
         Width           =   855
      End
      Begin VB.Data dtcBrand 
         Caption         =   "Brand"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   6240
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT BrandCode, BrandDescription FROM Brand ORDER BY BrandDescription"
         Top             =   660
         Visible         =   0   'False
         Width           =   1215
      End
      Begin VB.Data dtcSupplier 
         Caption         =   "Supplier"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   6240
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT SupplierCode, SupplierName FROM Supplier ORDER BY SupplierName"
         Top             =   300
         Visible         =   0   'False
         Width           =   1215
      End
      Begin VB.Data dtcCategory 
         Caption         =   "Category"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   1920
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT DISTINCT CategoryCode, CategoryName FROM Category ORDER BY CAtegoryName"
         Top             =   1380
         Visible         =   0   'False
         Width           =   1215
      End
      Begin VB.Data dtcClass 
         Caption         =   "Class"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   1920
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT DISTINCT ClassCode, ClassName FROM Class ORDER BY ClassName"
         Top             =   1020
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcDepartment 
         Caption         =   "Department"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   315
         Left            =   1920
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT DepartmentCode, DepartmentName FROM Department ORDER BY DepartmentName"
         Top             =   660
         Visible         =   0   'False
         Width           =   1215
      End
      Begin VB.Data dtcInventory 
         Caption         =   "Inventory"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   315
         Left            =   7440
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   ""
         Top             =   2400
         Visible         =   0   'False
         Width           =   3255
      End
      Begin VB.TextBox txtCylinder 
         DataField       =   "Cylinder"
         DataSource      =   "dtcInventory"
         Height          =   285
         Left            =   9840
         TabIndex        =   14
         Text            =   "0"
         Top             =   660
         Width           =   855
      End
      Begin VB.TextBox txtSphere 
         DataField       =   "Sphere"
         DataSource      =   "dtcInventory"
         Height          =   285
         Left            =   9840
         TabIndex        =   13
         Text            =   "0"
         Top             =   300
         Width           =   855
      End
      Begin MSDBCtls.DBCombo dbcBrand 
         Bindings        =   "frmInfoSKU.frx":55A8
         Height          =   315
         Left            =   5160
         TabIndex        =   12
         Top             =   660
         Width           =   2295
         _ExtentX        =   4048
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "BrandDescription"
         BoundColumn     =   "BrandCode"
         Text            =   ""
      End
      Begin MSDBCtls.DBCombo dbcSupplier 
         Bindings        =   "frmInfoSKU.frx":55BF
         Height          =   315
         Left            =   5160
         TabIndex        =   11
         Top             =   300
         Width           =   2295
         _ExtentX        =   4048
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "SupplierName"
         BoundColumn     =   "SupplierCode"
         Text            =   ""
      End
      Begin MSDBCtls.DBCombo dbcCategory 
         Bindings        =   "frmInfoSKU.frx":55D9
         Height          =   315
         Left            =   1080
         TabIndex        =   10
         Top             =   1380
         Width           =   2175
         _ExtentX        =   3836
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "CategoryName"
         BoundColumn     =   "CategoryCode"
         Text            =   ""
      End
      Begin MSDBCtls.DBCombo dbcClass 
         Bindings        =   "frmInfoSKU.frx":55F3
         Height          =   315
         Left            =   1080
         TabIndex        =   9
         Top             =   1020
         Width           =   2175
         _ExtentX        =   3836
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "ClassName"
         BoundColumn     =   "ClassCode"
         Text            =   ""
      End
      Begin MSDBCtls.DBCombo dbcDepartment 
         Bindings        =   "frmInfoSKU.frx":560A
         Height          =   315
         Left            =   1080
         TabIndex        =   8
         Top             =   660
         Width           =   2175
         _ExtentX        =   3836
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "DepartmentName"
         BoundColumn     =   "DepartmentCode"
         Text            =   ""
      End
      Begin Threed.SSCommand cmdFindSKU 
         Height          =   315
         Left            =   2400
         TabIndex        =   36
         Top             =   300
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
         Picture         =   "frmInfoSKU.frx":5626
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdFindModel 
         Height          =   315
         Left            =   7800
         TabIndex        =   33
         Top             =   1020
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
         Picture         =   "frmInfoSKU.frx":5BCC
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSRibbon cmdCascadeModel 
         Height          =   315
         Left            =   7440
         TabIndex        =   32
         Top             =   1020
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSKU.frx":6172
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSKU.frx":6740
         GroupNumber     =   9
      End
      Begin Threed.SSCommand cmdFindBaseCurve 
         Height          =   315
         Left            =   11040
         TabIndex        =   29
         TabStop         =   0   'False
         Top             =   1020
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
         Picture         =   "frmInfoSKU.frx":6D22
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSRibbon cmdCascadeBaseCurve 
         Height          =   315
         Left            =   10680
         TabIndex        =   28
         Top             =   1020
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSKU.frx":72C8
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSKU.frx":7896
         GroupNumber     =   8
      End
      Begin Threed.SSRibbon cmdCascadeCylinder 
         Height          =   315
         Left            =   10680
         TabIndex        =   23
         Top             =   660
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSKU.frx":7E78
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSKU.frx":8446
         GroupNumber     =   7
      End
      Begin Threed.SSRibbon cmdCascadeSphere 
         Height          =   315
         Left            =   10680
         TabIndex        =   22
         Top             =   300
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSKU.frx":8A28
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSKU.frx":8FF6
         GroupNumber     =   6
      End
      Begin Threed.SSRibbon cmdCascadeBrand 
         Height          =   315
         Left            =   7440
         TabIndex        =   21
         Top             =   660
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSKU.frx":95D8
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSKU.frx":9BA6
         GroupNumber     =   5
      End
      Begin Threed.SSRibbon cmdCascadeSupplier 
         Height          =   315
         Left            =   7440
         TabIndex        =   20
         Top             =   300
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSKU.frx":A188
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSKU.frx":A756
         GroupNumber     =   4
      End
      Begin Threed.SSRibbon cmdCascadeCategory 
         Height          =   315
         Left            =   3240
         TabIndex        =   19
         Top             =   1380
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSKU.frx":AD38
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSKU.frx":B306
         GroupNumber     =   3
      End
      Begin Threed.SSRibbon cmdCascadeClass 
         Height          =   315
         Left            =   3240
         TabIndex        =   18
         Top             =   1020
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSKU.frx":B8E8
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSKU.frx":BEB6
         GroupNumber     =   2
      End
      Begin Threed.SSRibbon cmdCascadeDept 
         Height          =   315
         Left            =   3240
         TabIndex        =   17
         Top             =   660
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSKU.frx":C498
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSKU.frx":CA66
      End
      Begin Threed.SSCommand cmdFindCylinder 
         Height          =   315
         Left            =   11040
         TabIndex        =   16
         Top             =   660
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
         Picture         =   "frmInfoSKU.frx":D048
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdFindSphere 
         Height          =   315
         Left            =   11040
         TabIndex        =   15
         Top             =   300
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
         Picture         =   "frmInfoSKU.frx":D5EE
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label38 
         Caption         =   "SKU"
         Height          =   255
         Left            =   120
         TabIndex        =   34
         Top             =   300
         Width           =   615
      End
      Begin VB.Label Label8 
         Caption         =   "Model"
         Height          =   255
         Left            =   4440
         TabIndex        =   30
         Top             =   1020
         Width           =   495
      End
      Begin VB.Label Label26 
         Caption         =   "Base Curve"
         Height          =   255
         Left            =   8880
         TabIndex        =   26
         Top             =   1020
         Width           =   855
      End
      Begin VB.Label Label7 
         Caption         =   "Cylinder"
         Height          =   195
         Left            =   8880
         TabIndex        =   7
         Top             =   660
         Width           =   615
      End
      Begin VB.Label Label6 
         Caption         =   "Sphere"
         Height          =   195
         Left            =   8880
         TabIndex        =   6
         Top             =   300
         Width           =   615
      End
      Begin VB.Label Label5 
         Caption         =   "Brand"
         Height          =   255
         Left            =   4440
         TabIndex        =   5
         Top             =   660
         Width           =   495
      End
      Begin VB.Label Label4 
         Caption         =   "Supplier"
         Height          =   195
         Left            =   4440
         TabIndex        =   4
         Top             =   300
         Width           =   735
      End
      Begin VB.Label Label3 
         Caption         =   "Category"
         Height          =   255
         Left            =   120
         TabIndex        =   3
         Top             =   1380
         Width           =   735
      End
      Begin VB.Label Label2 
         Caption         =   "Class"
         Height          =   195
         Left            =   120
         TabIndex        =   2
         Top             =   1020
         Width           =   495
      End
      Begin VB.Label Label1 
         Caption         =   "Department"
         Height          =   195
         Left            =   120
         TabIndex        =   1
         Top             =   660
         Width           =   855
      End
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   25
      Top             =   0
      Width           =   11730
      _Version        =   131073
      _ExtentX        =   20690
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
      Btns            =   7
      ToolsetPicture  =   "frmInfoSKU.frx":DB94
      BC              =   7
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
      ToolsetNumTools =   7
      ToolsetToolID(0)=   "ID_First"
      ToolsetToolHelp(0)=   "First Record"
      ToolsetToolMnemonic(0)=   "f"
      ToolsetToolGroup(0)=   1
      ToolsetToolID(1)=   "ID_Previous"
      ToolsetToolHelp(1)=   "Previous Record"
      ToolsetToolMnemonic(1)=   "p"
      ToolsetToolGroup(1)=   1
      ToolsetToolID(2)=   "ID_Next"
      ToolsetToolHelp(2)=   "Next Record"
      ToolsetToolMnemonic(2)=   "n"
      ToolsetToolGroup(2)=   1
      ToolsetToolID(3)=   "ID_Last"
      ToolsetToolHelp(3)=   "Last Record"
      ToolsetToolMnemonic(3)=   "l"
      ToolsetToolGroup(3)=   1
      ToolsetToolID(4)=   "ID_Add"
      ToolsetToolHelp(4)=   "Add Record"
      ToolsetToolMnemonic(4)=   "a"
      ToolsetToolGroup(4)=   2
      ToolsetToolID(5)=   "ID_Copy"
      ToolsetToolHelp(5)=   "Copy Record"
      ToolsetToolMnemonic(5)=   "c"
      ToolsetToolGroup(5)=   2
      ToolsetToolID(6)=   "ID_Exit"
      ToolsetToolHelp(6)=   "Exit Task"
      ToolsetToolMnemonic(6)=   "x"
      ToolsetToolGroup(6)=   2
      MouseIcon       =   "frmInfoSKU.frx":18426
   End
   Begin SSDesignerWidgetsTabs.SSIndexTab SSIndexTab1 
      Height          =   2655
      Left            =   120
      TabIndex        =   37
      Top             =   5520
      Width           =   11535
      _Version        =   131078
      _ExtentX        =   20346
      _ExtentY        =   4683
      _StockProps     =   13
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      CoverAllowClose =   0   'False
      CoverMarginX    =   200
      CoverMarginY    =   200
      RingHoleMargin  =   500
      RingMarginTop   =   100
      RingMarginBottom=   100
      RingSeparator   =   200
      RingSize        =   1000
      RingWidth       =   300
      ActualTTO       =   500
      GutterWidth     =   100
      PageAnimationFrames=   20
      TabVisibleLast  =   1
      TabShape        =   6
      TabsPerRow      =   12
      RingCount       =   9
      RingGroups      =   3
      PageTabOrientation=   0
      PageAlignmentCaption=   7
      PageAlignmentPicture=   1
      BeginProperty FontSub {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BeginProperty PageFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BeginProperty ActiveTabFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BeginProperty ActivePageFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      TabsNum         =   2
      Tabs(IC).PictureMetaWidth=   0
      Tabs(IC).PictureMetaHeight=   0
      Tabs(IC).Page   =   0
      Tabs(IC).ControlCount=   0
      Tabs(IC).ControlEnabled=   0   'False
      Tabs(IC).Pages(0).PictureMetaWidth=   0
      Tabs(IC).Pages(0).PictureMetaHeight=   0
      Tabs(IC).Pages(0).Tag=   ""
      Tabs(IC).Pages(0).Caption=   "Page 0"
      Tabs(IC).Pages(0).Name=   "page 0"
      Tabs(IC).Pages(0).CtlCount=   0
      Tabs(IC).Pages(0).CtlEnabled=   0   'False
      Tabs(IC).Tag    =   ""
      Tabs(IC).Caption=   ""
      Tabs(IC).Name   =   ""
      Tabs(0).PictureMetaWidth=   0
      Tabs(0).PictureMetaHeight=   0
      Tabs(0).Page    =   0
      Tabs(0).ControlCount=   0
      Tabs(0).ControlEnabled=   0   'False
      Tabs(0).Pages(0).PictureMetaWidth=   0
      Tabs(0).Pages(0).PictureMetaHeight=   0
      Tabs(0).Pages(0).Tag=   ""
      Tabs(0).Pages(0).Caption=   "Page 0"
      Tabs(0).Pages(0).Name=   "page 0"
      Tabs(0).Pages(0).CtlCount=   1
      Tabs(0).Pages(0).CtlEnabled=   -1  'True
      Tabs(0).Pages(0).Ctl(0)=   "frmGeneral"
      Tabs(0).Tag     =   ""
      Tabs(0).Caption =   "General"
      Tabs(0).Name    =   "tab 0"
      Tabs(1).PictureMetaWidth=   0
      Tabs(1).PictureMetaHeight=   0
      Tabs(1).Page    =   0
      Tabs(1).ControlCount=   0
      Tabs(1).ControlEnabled=   0   'False
      Tabs(1).Pages(0).PictureMetaWidth=   0
      Tabs(1).Pages(0).PictureMetaHeight=   0
      Tabs(1).Pages(0).Tag=   ""
      Tabs(1).Pages(0).Caption=   "Page 0"
      Tabs(1).Pages(0).Name=   "page 0"
      Tabs(1).Pages(0).CtlCount=   14
      Tabs(1).Pages(0).CtlEnabled=   0   'False
      Tabs(1).Pages(0).Ctl(0)=   "cmdPrnSKULedger(1)"
      Tabs(1).Pages(0).Ctl(1)=   "Text8"
      Tabs(1).Pages(0).Ctl(2)=   "Text9"
      Tabs(1).Pages(0).Ctl(3)=   "SSFrame2"
      Tabs(1).Pages(0).Ctl(4)=   "SSFrame3"
      Tabs(1).Pages(0).Ctl(5)=   "fraCost"
      Tabs(1).Pages(0).Ctl(6)=   "MaskEdBox9"
      Tabs(1).Pages(0).Ctl(7)=   "MaskEdBox8"
      Tabs(1).Pages(0).Ctl(8)=   "MaskEdBox7"
      Tabs(1).Pages(0).Ctl(9)=   "Label27"
      Tabs(1).Pages(0).Ctl(10)=   "Label28"
      Tabs(1).Pages(0).Ctl(11)=   "Label29"
      Tabs(1).Pages(0).Ctl(12)=   "Label30"
      Tabs(1).Pages(0).Ctl(13)=   "Label31"
      Tabs(1).Tag     =   ""
      Tabs(1).Caption =   "Summary"
      Tabs(1).Name    =   "tab 1"
      Templates(0).PictureMetaWidth=   0
      Templates(0).PictureMetaHeight=   0
      Templates(0).Tag=   ""
      Templates(0).Caption=   "Page 0"
      Templates(0).Name=   "page 0"
      Templates(0).CtlCount=   0
      Templates(0).CtlEnabled=   -1  'True
      Templates(1).PictureMetaWidth=   0
      Templates(1).PictureMetaHeight=   0
      Templates(1).Tag=   ""
      Templates(1).Caption=   "Page 1"
      Templates(1).Name=   "page 1"
      Templates(1).CtlCount=   0
      Templates(1).CtlEnabled=   0   'False
      Begin VB.CommandButton cmdPrnSKULedger 
         Caption         =   "Print Year-to-date SKU Transactions Summary"
         Height          =   315
         Index           =   1
         Left            =   -69360
         TabIndex        =   103
         Top             =   2280
         Width           =   3855
      End
      Begin Threed.SSFrame frmGeneral 
         Height          =   2175
         Left            =   120
         TabIndex        =   67
         Top             =   360
         Width           =   11295
         _ExtentX        =   19923
         _ExtentY        =   3836
         _Version        =   131074
         Caption         =   "General Info"
         Begin VB.CommandButton cmdPrnSKULedger 
            Caption         =   "Print Year-to-date SKU Transactions Summary"
            Height          =   375
            Index           =   0
            Left            =   5400
            TabIndex        =   102
            Top             =   1680
            Width           =   3855
         End
         Begin VB.TextBox Text23 
            DataField       =   "Remarks"
            DataSource      =   "dtcInventory"
            Height          =   1125
            Left            =   9480
            MultiLine       =   -1  'True
            ScrollBars      =   2  'Vertical
            TabIndex        =   101
            Top             =   960
            Width           =   1695
         End
         Begin VB.TextBox Text22 
            DataField       =   "BaseCurve"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   9480
            TabIndex        =   100
            Top             =   600
            Width           =   855
         End
         Begin VB.TextBox Text21 
            DataField       =   "Diameter"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   9480
            TabIndex        =   99
            Top             =   240
            Width           =   855
         End
         Begin VB.TextBox Text20 
            DataField       =   "Cylinder"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   7440
            TabIndex        =   95
            Top             =   1320
            Width           =   855
         End
         Begin VB.TextBox Text19 
            DataField       =   "Sphere"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   7440
            TabIndex        =   94
            Top             =   960
            Width           =   855
         End
         Begin VB.TextBox Text18 
            DataField       =   "Temple"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   7440
            TabIndex        =   93
            Top             =   600
            Width           =   855
         End
         Begin VB.TextBox Text17 
            DataField       =   "Bridge"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   7440
            TabIndex        =   92
            Top             =   240
            Width           =   855
         End
         Begin VB.TextBox Text16 
            DataField       =   "Size"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   4320
            TabIndex        =   87
            Top             =   1680
            Width           =   855
         End
         Begin VB.TextBox Text15 
            DataField       =   "Color"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   4320
            TabIndex        =   86
            Top             =   1320
            Width           =   855
         End
         Begin VB.TextBox Text14 
            DataField       =   "MaterialDescription"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   4320
            TabIndex        =   85
            Top             =   960
            Width           =   2295
         End
         Begin VB.TextBox Text7 
            DataField       =   "Model"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   4320
            TabIndex        =   81
            Top             =   600
            Width           =   2295
         End
         Begin VB.TextBox Text6 
            DataField       =   "BrandDescription"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   4320
            TabIndex        =   80
            Top             =   240
            Width           =   2295
         End
         Begin VB.TextBox Text5 
            DataField       =   "SupplierName"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   1080
            TabIndex        =   77
            Top             =   1680
            Width           =   2295
         End
         Begin VB.TextBox Text4 
            DataField       =   "CategoryName"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   1080
            TabIndex        =   76
            Top             =   1320
            Width           =   2295
         End
         Begin VB.TextBox Text3 
            DataField       =   "ClassName"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   1080
            TabIndex        =   75
            Top             =   960
            Width           =   2295
         End
         Begin VB.TextBox Text2 
            DataField       =   "DepartmentName"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   1080
            TabIndex        =   74
            Top             =   600
            Width           =   2295
         End
         Begin VB.TextBox txtInfoSKU 
            DataField       =   "SKU"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   1080
            TabIndex        =   73
            Top             =   240
            Width           =   2295
         End
         Begin VB.Label Label25 
            Caption         =   "Remarks"
            Height          =   195
            Left            =   8520
            TabIndex        =   98
            Top             =   960
            Width           =   735
         End
         Begin VB.Label Label24 
            Caption         =   "Diameter"
            Height          =   255
            Left            =   8520
            TabIndex        =   97
            Top             =   240
            Width           =   855
         End
         Begin VB.Label Label23 
            Caption         =   "Base Curve"
            Height          =   255
            Left            =   8520
            TabIndex        =   96
            Top             =   600
            Width           =   855
         End
         Begin VB.Label Label22 
            Caption         =   "Sphere"
            Height          =   195
            Left            =   6840
            TabIndex        =   91
            Top             =   960
            Width           =   735
         End
         Begin VB.Label Label21 
            Caption         =   "Cylinder"
            Height          =   255
            Left            =   6840
            TabIndex        =   90
            Top             =   1320
            Width           =   735
         End
         Begin VB.Label Label20 
            Caption         =   "Bridge"
            Height          =   255
            Left            =   6840
            TabIndex        =   89
            Top             =   240
            Width           =   495
         End
         Begin VB.Label Label19 
            Caption         =   "Temple"
            Height          =   255
            Left            =   6840
            TabIndex        =   88
            Top             =   600
            Width           =   615
         End
         Begin VB.Label Label18 
            Caption         =   "Size"
            Height          =   195
            Left            =   3600
            TabIndex        =   84
            Top             =   1680
            Width           =   735
         End
         Begin VB.Label Label17 
            Caption         =   "Material"
            Height          =   195
            Left            =   3600
            TabIndex        =   83
            Top             =   960
            Width           =   735
         End
         Begin VB.Label Label16 
            Caption         =   "Color"
            Height          =   255
            Left            =   3600
            TabIndex        =   82
            Top             =   1320
            Width           =   735
         End
         Begin VB.Label Label15 
            Caption         =   "Brand"
            Height          =   255
            Left            =   3600
            TabIndex        =   79
            Top             =   240
            Width           =   495
         End
         Begin VB.Label Label14 
            Caption         =   "Model"
            Height          =   255
            Left            =   3600
            TabIndex        =   78
            Top             =   600
            Width           =   495
         End
         Begin VB.Label Label13 
            Caption         =   "Supplier"
            Height          =   195
            Left            =   120
            TabIndex        =   72
            Top             =   1680
            Width           =   735
         End
         Begin VB.Label Label12 
            Caption         =   "Department"
            Height          =   195
            Left            =   120
            TabIndex        =   71
            Top             =   600
            Width           =   855
         End
         Begin VB.Label Label11 
            Caption         =   "Class"
            Height          =   195
            Left            =   120
            TabIndex        =   70
            Top             =   960
            Width           =   495
         End
         Begin VB.Label Label10 
            Caption         =   "Category"
            Height          =   255
            Left            =   120
            TabIndex        =   69
            Top             =   1320
            Width           =   735
         End
         Begin VB.Label Label9 
            Caption         =   "SKU"
            Height          =   255
            Left            =   120
            TabIndex        =   68
            Top             =   240
            Width           =   615
         End
      End
      Begin VB.TextBox Text8 
         DataField       =   "ReorderLevel"
         DataSource      =   "dtcInventory"
         Height          =   285
         Left            =   -73440
         TabIndex        =   39
         TabStop         =   0   'False
         Top             =   1380
         Width           =   495
      End
      Begin VB.TextBox Text9 
         DataField       =   "ReorderQty"
         DataSource      =   "dtcInventory"
         Height          =   285
         Left            =   -73440
         TabIndex        =   38
         TabStop         =   0   'False
         Top             =   1680
         Width           =   495
      End
      Begin Threed.SSFrame SSFrame2 
         Height          =   1755
         Left            =   -72120
         TabIndex        =   40
         Top             =   420
         Width           =   2415
         _ExtentX        =   4260
         _ExtentY        =   3096
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
         Caption         =   "Qty"
         Begin VB.TextBox Text10 
            DataField       =   "QtyTotalOnHand"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   1680
            Locked          =   -1  'True
            TabIndex        =   44
            TabStop         =   0   'False
            Top             =   240
            Width           =   615
         End
         Begin VB.TextBox Text11 
            DataField       =   "QtySaleOrder"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   1680
            Locked          =   -1  'True
            TabIndex        =   43
            TabStop         =   0   'False
            Top             =   600
            Width           =   615
         End
         Begin VB.TextBox Text12 
            DataField       =   "OtyPurchaseOrder"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   1680
            Locked          =   -1  'True
            TabIndex        =   42
            TabStop         =   0   'False
            Top             =   960
            Width           =   615
         End
         Begin VB.TextBox Text13 
            DataField       =   "QtyHolded"
            DataSource      =   "dtcInventory"
            Height          =   285
            Left            =   1680
            Locked          =   -1  'True
            TabIndex        =   41
            TabStop         =   0   'False
            Top             =   1320
            Width           =   615
         End
         Begin VB.Label Label32 
            Caption         =   "Onhand"
            Height          =   255
            Left            =   120
            TabIndex        =   48
            Top             =   240
            Width           =   735
         End
         Begin VB.Label Label33 
            Caption         =   "Need by Sales Order"
            Height          =   255
            Left            =   120
            TabIndex        =   47
            Top             =   600
            Width           =   1575
         End
         Begin VB.Label Label34 
            Caption         =   "To be Received"
            Height          =   255
            Left            =   120
            TabIndex        =   46
            Top             =   960
            Width           =   1215
         End
         Begin VB.Label Label35 
            Caption         =   "Reserved"
            Height          =   255
            Left            =   120
            TabIndex        =   45
            Top             =   1320
            Width           =   975
         End
      End
      Begin Threed.SSFrame SSFrame3 
         Height          =   1755
         Left            =   -69360
         TabIndex        =   49
         Top             =   420
         Width           =   3255
         _ExtentX        =   5741
         _ExtentY        =   3096
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
         Caption         =   "Date"
         Begin MSMask.MaskEdBox MaskEdBox10 
            DataField       =   "DateLastReceived"
            DataSource      =   "dtcInventory"
            Height          =   255
            Left            =   1320
            TabIndex        =   50
            TabStop         =   0   'False
            Top             =   600
            Width           =   1815
            _ExtentX        =   3201
            _ExtentY        =   450
            _Version        =   393216
            Format          =   "dd-mmm-yy"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox2 
            DataField       =   "DateLastIssued"
            DataSource      =   "dtcInventory"
            Height          =   255
            Left            =   1320
            TabIndex        =   51
            TabStop         =   0   'False
            Top             =   300
            Width           =   1815
            _ExtentX        =   3201
            _ExtentY        =   450
            _Version        =   393216
            Format          =   "dd-mmm-yy"
            PromptChar      =   "_"
         End
         Begin VB.Label Label36 
            Caption         =   "Last Issued"
            Height          =   255
            Left            =   120
            TabIndex        =   53
            Top             =   300
            Width           =   975
         End
         Begin VB.Label Label37 
            Caption         =   "Last Received"
            Height          =   255
            Left            =   120
            TabIndex        =   52
            Top             =   600
            Width           =   1095
         End
      End
      Begin Threed.SSFrame fraCost 
         Height          =   1755
         Left            =   -66000
         TabIndex        =   54
         Top             =   420
         Visible         =   0   'False
         Width           =   2415
         _ExtentX        =   4260
         _ExtentY        =   3096
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
         Caption         =   "Cost"
         Begin MSMask.MaskEdBox MaskEdBox1 
            DataField       =   "LeastSellingPrice"
            DataSource      =   "dtcRetailPrice"
            Height          =   255
            Left            =   1200
            TabIndex        =   55
            Top             =   600
            Width           =   1095
            _ExtentX        =   1931
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            Format          =   "$#,##0.00;($#,##0.00)"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskAverageCost 
            DataField       =   "AverageCost"
            DataSource      =   "dtcInventory"
            Height          =   255
            Left            =   1200
            TabIndex        =   56
            Top             =   300
            Width           =   1095
            _ExtentX        =   1931
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            Format          =   "$#,##0.00;($#,##0.00)"
            PromptChar      =   "_"
         End
         Begin VB.Label Label39 
            Caption         =   "Average Cost"
            Height          =   315
            Left            =   120
            TabIndex        =   58
            Top             =   300
            Width           =   975
         End
         Begin VB.Label Label40 
            Caption         =   "Least Selling Price"
            Height          =   435
            Left            =   120
            TabIndex        =   57
            Top             =   600
            Width           =   975
         End
      End
      Begin MSMask.MaskEdBox MaskEdBox9 
         DataField       =   "LeastSellingPrice"
         DataSource      =   "dtcInventory"
         Height          =   255
         Left            =   -73440
         TabIndex        =   59
         TabStop         =   0   'False
         Top             =   1080
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   450
         _Version        =   393216
         Format          =   "$#,##0.00"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox MaskEdBox8 
         DataField       =   "RetailMarkDownAmt"
         DataSource      =   "dtcInventory"
         Height          =   255
         Left            =   -73440
         TabIndex        =   60
         TabStop         =   0   'False
         Top             =   780
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   450
         _Version        =   393216
         Format          =   "$#,##0.00"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox MaskEdBox7 
         DataField       =   "RetailPrice"
         DataSource      =   "dtcInventory"
         Height          =   255
         Left            =   -73440
         TabIndex        =   61
         TabStop         =   0   'False
         Top             =   480
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   450
         _Version        =   393216
         Format          =   "$#,##0.00"
         PromptChar      =   "_"
      End
      Begin VB.Label Label27 
         Caption         =   "Least Selling Price"
         Height          =   255
         Left            =   -74880
         TabIndex        =   66
         Top             =   1080
         Width           =   1335
      End
      Begin VB.Label Label28 
         Caption         =   "Markdown"
         Height          =   255
         Left            =   -74880
         TabIndex        =   65
         Top             =   780
         Width           =   855
      End
      Begin VB.Label Label29 
         Caption         =   "Reorder Level"
         Height          =   255
         Left            =   -74880
         TabIndex        =   64
         Top             =   1380
         Width           =   1095
      End
      Begin VB.Label Label30 
         Caption         =   "Reorder Qty"
         Height          =   255
         Left            =   -74880
         TabIndex        =   63
         Top             =   1680
         Width           =   975
      End
      Begin VB.Label Label31 
         Caption         =   "Retail Price"
         Height          =   255
         Left            =   -74880
         TabIndex        =   62
         Top             =   480
         Width           =   975
      End
   End
End
Attribute VB_Name = "frmInfoSKU"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Const mButtonIndex_First As Integer = 0
Private Const mButtonIndex_Previous As Integer = 1
Private Const mButtonIndex_Next As Integer = 2
Private Const mButtonIndex_Last As Integer = 3
Private Const mButtonIndex_Copy As Integer = 5

Private Sub cmdFindBaseCurve_Click()
    Dim strSQL As String
    
        Call DefaultLensParametersValue
        If cmdCascadeBaseCurve.Value Then        ' Cascade selected
            LookupByCascade
        Else                                    ' No cascade
            strSQL = "SELECT * FROM [Inventory Query] " _
                & "WHERE BaseCurve LIKE " & txtBaseCurve.Text _
                & " ORDER BY DepartmentCode, ClassCode, CategoryCode"
            dtcInventory.RecordSource = strSQL
            dtcInventory.Refresh
            dtcInventory.UpdateControls
        End If

End Sub


Private Sub cmdFindCylinder_Click()
    Dim strSQL As String
    
        Call DefaultLensParametersValue
        If cmdCascadeCylinder.Value Then        ' Cascade selected
            LookupByCascade
        Else                                    ' No cascade
            strSQL = "SELECT * FROM [Inventory Query] " _
                & "WHERE Sphere LIKE " & txtCylinder.Text _
                & " ORDER BY DepartmentCode, ClassCode, CategoryCode"
            dtcInventory.RecordSource = strSQL
            dtcInventory.Refresh
            dtcInventory.UpdateControls
        End If

End Sub

Private Sub cmdFindModel_Click()
    Dim strSQL As String
    
    If txtModel.Text = "" Then Exit Sub
    If cmdCascadeModel.Value Then           ' Cascade selected
        LookupByCascade
    Else                                    ' No cascade
        strSQL = "SELECT * FROM [Inventory Query] " _
               & "WHERE Model LIKE '" & txtModel.Text & "' " _
               & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
        dtcInventory.RecordSource = strSQL
        dtcInventory.Refresh
        dtcInventory.UpdateControls
    End If

End Sub

Private Sub cmdFindSKU_Click()
    Dim strSQL As String
    If txtSKU.Text = "" Then Exit Sub
    strSQL = "SELECT * FROM [Inventory Query] " _
           & "WHERE SKU LIKE '" & txtSKU.Text & "' " _
           & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
    dtcInventory.RecordSource = strSQL
    dtcInventory.Refresh
    dtcInventory.UpdateControls
End Sub

Private Sub cmdFindSphere_Click()
    Dim strSQL As String
    
        Call DefaultLensParametersValue
        If cmdCascadeSphere.Value Then      ' Cascade selected
            LookupByCascade
        Else                                ' No cascade
            strSQL = "SELECT * FROM [Inventory Query] " _
                & "WHERE Sphere LIKE " & txtSphere.Text _
                & " ORDER BY DepartmentCode, ClassCode, CategoryCode"
            dtcInventory.RecordSource = strSQL
            dtcInventory.Refresh
            dtcInventory.UpdateControls
        End If

End Sub

Private Sub cmdPrnSKULedger_Click(Index As Integer)
    Dim strTxNumber As String
    
    strTxNumber = ofx_CStr(txtInfoSKU)
    If strTxNumber <> "" Then
        RptTxNumberFrom = strTxNumber
        Call PrintSKULedger(1, 0)
    End If
End Sub

Private Sub dbcBrand_Click(intArea As Integer)

    If intArea = dbcAreaList Then
        Dim strSQL As String
        If cmdCascadeBrand.Value Then    ' Cascade selected
            LookupByCascade
        Else                                ' No cascade
            strSQL = "SELECT * FROM [Inventory Query]" _
                & "WHERE BrandCode = '" & dbcBrand.BoundText & "' " _
                & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
            dtcInventory.RecordSource = strSQL
            dtcInventory.Refresh
            dtcInventory.UpdateControls
        End If
    End If
    
End Sub

Private Sub dbcCategory_Click(intArea As Integer)
    Dim strSQL As String
    
    If intArea = dbcAreaList Then
        ' Lookup dtcInventory
        If cmdCascadeCategory.Value Then    ' Cascade selected
            LookupByCascade
        Else                                ' No cascade
            strSQL = "SELECT * FROM [Inventory Query] " _
                & "WHERE CategoryCode = '" & dbcCategory.BoundText & "' " _
                & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
            dtcInventory.RecordSource = strSQL
            dtcInventory.Refresh
            dtcInventory.UpdateControls
        End If
    End If

End Sub

Private Sub dbcClass_Click(intArea As Integer)
    Dim strSQL As String
    
    If intArea = dbcAreaList Then
        If cmdCascadeCategory.Value Then
            ' Limit dbcCategory list items to the same Dept
            strSQL = "SELECT * FROM Category " _
                & "WHERE DepartmentCode = '" & dbcDepartment.BoundText & "' AND " _
                & "ClassCode = '" & dbcClass.BoundText & "' " _
                & "ORDER BY CategoryName"
            dtcCategory.RecordSource = strSQL
            dtcCategory.Refresh
            dtcCategory.UpdateControls
        End If
        ' Lookup dtcInventory
        If cmdCascadeClass.Value Then   ' Cascade selected
            LookupByCascade
        Else                            ' No cascade
            strSQL = "SELECT * FROM [Inventory Query] " _
                & "WHERE ClassCode = '" & dbcClass.BoundText & "' " _
                & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
            dtcInventory.RecordSource = strSQL
            dtcInventory.Refresh
            dtcInventory.UpdateControls
        End If
    End If

End Sub

Private Sub dbcDepartment_Click(intArea As Integer)
    Dim strSQL As String
    
    If intArea = dbcAreaList Then
        If cmdCascadeClass.Value Then
            ' Limit dbcClass list items to the same Dept
            strSQL = "SELECT * FROM Class " _
                & "WHERE Department = '" & dbcDepartment.BoundText & "' " _
                & "ORDER BY ClassName"
            dtcClass.RecordSource = strSQL
            dtcClass.Refresh
            dtcClass.UpdateControls
        End If
        ' Lookup dtcInventory
        If cmdCascadeDept.Value Then    ' Cascade selected
            LookupByCascade
        Else                            ' No cascade
            strSQL = "SELECT * FROM [Inventory Query] " _
                & "WHERE DepartmentCode = '" & dbcDepartment.BoundText & "' " _
                & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
            dtcInventory.RecordSource = strSQL
            dtcInventory.Refresh
            dtcInventory.UpdateControls
        End If
        
    End If

End Sub


Private Sub dbcSupplier_Click(intArea As Integer)

    If intArea = dbcAreaList Then
        Dim strSQL As String
        If cmdCascadeSupplier.Value Then    ' Cascade selected
            LookupByCascade
        Else                                ' No cascade
            strSQL = "SELECT * FROM [Inventory Query] " _
                & "WHERE SupplierCode = '" & dbcSupplier.BoundText & "' " _
                & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
            dtcInventory.RecordSource = strSQL
            dtcInventory.Refresh
            dtcInventory.UpdateControls
        End If
    End If
    
End Sub

Private Sub dtcInventory_Reposition()

    Dim strSQL As String
    
    ' Set navigation buttons
    If dtcInventory.Recordset.BOF Or _
       dtcInventory.Recordset.EOF Then
        ' Empty table
        Call SetMenuButton(0)      ' Disable navigation buttons
    Else
        Call SetMenuButton(1)      ' Enable navigation buttons
    End If

End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
    
    '
    If IsSecurityEnabled Then
        If IsCostOK(pyUserSLevel) Then
            fraCost.Visible = True
        End If
    Else
        fraCost.Visible = True
    End If
    '
    Call SetMenuButton(0)
End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)
    
    Select Case ToolID
        Case "ID_Exit"
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
            Clipboard.Clear
            Clipboard.SetText dtcInventory.Recordset.Fields("SKU")
            MsgBox "SKU " & dtcInventory.Recordset.Fields("SKU") & " Copied."
            Unload Me
        Case "ID_Append"
            Clipboard.SetText dtcInventory.Recordset.Fields("SKU")
            MsgBox "SKU " & dtcInventory.Recordset.Fields("SKU") & " Copied."
        Case "ID_Add"
            If ofx_IsFormLoaded(frmInvt) Then
                frmInvt.SetFocus
                SendKeys "% R", True
                frmInvt.ZOrder
            Else
                Screen.MousePointer = vbHourglass
                frmInvt.Show
            End If
    End Select

End Sub



Private Sub LookupByCascade()
        
    Dim strSQL As String
    Dim blnCascade As Boolean
        
    strSQL = "SELECT * FROM [Inventory Query] WHERE "
    If cmdCascadeDept.Value Then
        If dbcDepartment.BoundText <> "" Then
            strSQL = strSQL & "DepartmentCode = '" & dbcDepartment.BoundText & "' "
            blnCascade = True
        End If
    End If
    If cmdCascadeClass.Value Then
        If dbcClass.BoundText <> "" Then
            If blnCascade Then strSQL = strSQL & "And "
            strSQL = strSQL & "ClassCode = '" & dbcClass.BoundText & "' "
            blnCascade = True
        End If
    End If
    If cmdCascadeCategory.Value Then
        If dbcCategory.BoundText <> "" Then
            If blnCascade Then strSQL = strSQL & "And "
            strSQL = strSQL & "CategoryCode = '" & dbcCategory.BoundText & "' "
            blnCascade = True
        End If
    End If
    If cmdCascadeSupplier.Value Then
        If dbcSupplier.BoundText <> "" Then
            If blnCascade Then strSQL = strSQL & "And "
            strSQL = strSQL & "SupplierCode = '" & dbcSupplier.BoundText & "' "
            blnCascade = True
        End If
    End If
    If cmdCascadeBrand.Value Then
        If dbcBrand.BoundText <> "" Then
            If blnCascade Then strSQL = strSQL & "And "
            strSQL = strSQL & "BrandCode = '" & dbcBrand.BoundText & "' "
            blnCascade = True
        End If
    End If
    If cmdCascadeModel.Value Then
        If txtModel.Text <> "" Then
            If blnCascade Then strSQL = strSQL & "And "
            strSQL = strSQL & "Model LIKE '" & txtModel.Text & "' "
            blnCascade = True
        End If
    End If
    If cmdCascadeSphere.Value Then
        If blnCascade Then strSQL = strSQL & "And "
        strSQL = strSQL & "Sphere LIKE " & txtSphere.Text & " "
        blnCascade = True
    End If
    If cmdCascadeCylinder.Value Then
        If blnCascade Then strSQL = strSQL & "And "
        strSQL = strSQL & "Cylinder LIKE " & txtCylinder.Text & " "
    End If
    If cmdCascadeBaseCurve.Value Then
        If blnCascade Then strSQL = strSQL & "And "
        strSQL = strSQL & "BaseCurve LIKE " & txtBaseCurve.Text & " "
    End If
    strSQL = strSQL & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
    dtcInventory.RecordSource = strSQL
    dtcInventory.Refresh
    dtcInventory.UpdateControls

End Sub

Private Sub txtBaseCurve_GotFocus()
    Call AutoSelect(txtBaseCurve)
End Sub

Private Sub txtBaseCurve_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindBaseCurve_Click
        KeyAscii = 0
    End If
End Sub


Private Sub txtCylinder_Change()
    
    If Not myIsDecimal(txtCylinder, 2, True) Or _
       Not WithinRange(txtCylinder, 0, -6, True) Then
        txtCylinder.SetFocus
    End If

End Sub

Private Sub txtCylinder_GotFocus()
    Call AutoSelect(txtCylinder)
End Sub


Private Sub txtCylinder_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindCylinder_Click
        KeyAscii = 0
    End If
End Sub

Private Sub txtCylinder_LostFocus()

    If Not myIsDecimal(txtCylinder, 2, True) Or _
       Not WithinRange(txtCylinder, 0, -6, True) Then
        txtCylinder.SetFocus
    End If

End Sub


Private Sub txtModel_GotFocus()
    Call AutoSelect(txtModel)
End Sub


Private Sub txtSKU_GotFocus()
    Call AutoSelect(txtSKU)
End Sub


Private Sub txtSKU_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindSKU_Click
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
    Call AutoSelect(txtSphere)
End Sub


Private Sub txtSphere_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindSphere_Click
        KeyAscii = 0
    End If
End Sub

Private Sub txtSphere_LostFocus()
    
    If Not myIsDecimal(txtSphere, 2, True) Or _
       Not WithinRange(txtSphere, 20, -20, True) Then
        txtSphere.SetFocus
        Exit Sub
    End If

End Sub



Private Sub DefaultLensParametersValue()
    If txtSphere.Text = "" Then txtSphere.Text = "0"
    If txtCylinder.Text = "" Then txtCylinder.Text = "0"
    If txtBaseCurve.Text = "" Then txtBaseCurve.Text = "0"
End Sub

Private Sub SetMenuButton(intMode As Integer)
    Select Case intMode
        Case 0  ' Empty table
            SSToolbar1.Buttons(mButtonIndex_First).Enabled = False
            SSToolbar1.Buttons(mButtonIndex_Next).Enabled = False
            SSToolbar1.Buttons(mButtonIndex_Previous).Enabled = False
            SSToolbar1.Buttons(mButtonIndex_Last).Enabled = False
            SSToolbar1.Buttons(mButtonIndex_Copy).Enabled = False
        Case 1  ' Atleast one record
            SSToolbar1.Buttons(mButtonIndex_First).Enabled = True
            SSToolbar1.Buttons(mButtonIndex_Next).Enabled = True
            SSToolbar1.Buttons(mButtonIndex_Previous).Enabled = True
            SSToolbar1.Buttons(mButtonIndex_Last).Enabled = True
            SSToolbar1.Buttons(mButtonIndex_Copy).Enabled = True
    End Select
End Sub

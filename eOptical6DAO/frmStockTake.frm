VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form frmStockTake 
   Caption         =   "Stock Take"
   ClientHeight    =   5985
   ClientLeft      =   1275
   ClientTop       =   1980
   ClientWidth     =   11430
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5985
   ScaleWidth      =   11430
   Visible         =   0   'False
   Begin Threed.SSPanel pnlPrintMenu 
      Height          =   1095
      Left            =   5880
      TabIndex        =   10
      Top             =   1020
      Visible         =   0   'False
      Width           =   1395
      _ExtentX        =   2461
      _ExtentY        =   1931
      _Version        =   131074
      BackColor       =   12632256
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
      Begin Threed.SSCommand cmdPrintExceptional 
         Height          =   375
         Left            =   0
         TabIndex        =   52
         Top             =   720
         Width           =   1395
         _ExtentX        =   2461
         _ExtentY        =   661
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
         Caption         =   "Exceptional"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdPrintJournal 
         Height          =   375
         Left            =   0
         TabIndex        =   51
         Top             =   360
         Width           =   1395
         _ExtentX        =   2461
         _ExtentY        =   661
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
         Caption         =   "Journal"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdPrintWorkBook 
         Height          =   375
         Left            =   0
         TabIndex        =   50
         Top             =   0
         Width           =   1395
         _ExtentX        =   2461
         _ExtentY        =   661
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
         Caption         =   "Work Book"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin Threed.SSFrame fraAddSKU 
      Height          =   2715
      Left            =   6240
      TabIndex        =   11
      Top             =   1140
      Visible         =   0   'False
      Width           =   5055
      _ExtentX        =   8916
      _ExtentY        =   4789
      _Version        =   131074
      ForeColor       =   0
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
      Caption         =   "Add SKU into Worksheet"
      Begin Threed.SSPanel SSPanel1 
         Height          =   2295
         Left            =   120
         TabIndex        =   12
         Top             =   300
         Width           =   3855
         _ExtentX        =   6800
         _ExtentY        =   4048
         _Version        =   131074
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
         Begin VB.Data dtcClass2 
            Caption         =   "dtcClass"
            Connect         =   "Access 2000;"
            DatabaseName    =   "SynergyV.mdb"
            DefaultCursorType=   0  'DefaultCursor
            DefaultType     =   2  'UseODBC
            Exclusive       =   0   'False
            Height          =   345
            Left            =   1800
            Options         =   4
            ReadOnly        =   0   'False
            RecordsetType   =   1  'Dynaset
            RecordSource    =   "SELECT DISTINCT ClassCode, ClassName FROM Class ORDER BY ClassName"
            Top             =   840
            Visible         =   0   'False
            Width           =   1140
         End
         Begin VB.Data dtcBrand 
            Caption         =   "dtcBrand"
            Connect         =   "Access 2000;"
            DatabaseName    =   "SynergyV.mdb"
            DefaultCursorType=   0  'DefaultCursor
            DefaultType     =   2  'UseODBC
            Exclusive       =   0   'False
            Height          =   345
            Left            =   1800
            Options         =   4
            ReadOnly        =   0   'False
            RecordsetType   =   1  'Dynaset
            RecordSource    =   "SELECT BrandCode, BrandDescription FROM Brand ORDER BY BrandDescription"
            Top             =   1980
            Visible         =   0   'False
            Width           =   1140
         End
         Begin VB.Data dtcSupplier 
            Caption         =   "dtcSupplier"
            Connect         =   "Access 2000;"
            DatabaseName    =   "SynergyV.mdb"
            DefaultCursorType=   0  'DefaultCursor
            DefaultType     =   2  'UseODBC
            Exclusive       =   0   'False
            Height          =   345
            Left            =   1800
            Options         =   4
            ReadOnly        =   0   'False
            RecordsetType   =   1  'Dynaset
            RecordSource    =   "SELECT SupplierCode, SupplierName FROM Supplier ORDER BY SupplierName"
            Top             =   1620
            Visible         =   0   'False
            Width           =   1140
         End
         Begin VB.Data dtcCategory 
            Caption         =   "dtcCategory"
            Connect         =   "Access 2000;"
            DatabaseName    =   "SynergyV.mdb"
            DefaultCursorType=   0  'DefaultCursor
            DefaultType     =   2  'UseODBC
            Exclusive       =   0   'False
            Height          =   345
            Left            =   1800
            Options         =   4
            ReadOnly        =   0   'False
            RecordsetType   =   1  'Dynaset
            RecordSource    =   "SELECT DISTINCT CategoryCode, CategoryName FROM Category ORDER BY CAtegoryName"
            Top             =   1200
            Visible         =   0   'False
            Width           =   1140
         End
         Begin VB.Data dtcClass 
            Caption         =   "dtcClass"
            Connect         =   "Access 2000;"
            DatabaseName    =   "SynergyV.mdb"
            DefaultCursorType=   0  'DefaultCursor
            DefaultType     =   2  'UseODBC
            Exclusive       =   0   'False
            Height          =   300
            Left            =   1800
            Options         =   4
            ReadOnly        =   0   'False
            RecordsetType   =   1  'Dynaset
            RecordSource    =   "SELECT DISTINCT ClassCode, ClassName FROM Class ORDER BY ClassName"
            Top             =   540
            Visible         =   0   'False
            Width           =   1140
         End
         Begin VB.Data dtcDept 
            Caption         =   "dtcDept"
            Connect         =   "Access 2000;"
            DatabaseName    =   "SynergyV.mdb"
            DefaultCursorType=   0  'DefaultCursor
            DefaultType     =   2  'UseODBC
            Exclusive       =   0   'False
            Height          =   300
            Left            =   1800
            Options         =   4
            ReadOnly        =   0   'False
            RecordsetType   =   1  'Dynaset
            RecordSource    =   "SELECT DepartmentCode, DepartmentName FROM Department ORDER BY DepartmentName"
            Top             =   120
            Visible         =   0   'False
            Width           =   1140
         End
         Begin VB.TextBox txtBaseCurve 
            Height          =   285
            Left            =   1080
            TabIndex        =   38
            Top             =   3360
            Visible         =   0   'False
            Width           =   1875
         End
         Begin VB.TextBox txtCylinder 
            Height          =   315
            Left            =   1080
            TabIndex        =   35
            Top             =   3000
            Visible         =   0   'False
            Width           =   1875
         End
         Begin VB.TextBox txtSphere 
            Height          =   285
            Left            =   1080
            TabIndex        =   32
            Top             =   2640
            Visible         =   0   'False
            Width           =   1875
         End
         Begin VB.TextBox txtModel 
            Height          =   285
            Left            =   1080
            TabIndex        =   29
            Top             =   2280
            Visible         =   0   'False
            Width           =   1875
         End
         Begin MSDBCtls.DBCombo dbcBrand 
            Bindings        =   "frmStockTake.frx":0000
            Height          =   315
            Left            =   1080
            TabIndex        =   26
            Top             =   1920
            Width           =   2295
            _ExtentX        =   4048
            _ExtentY        =   556
            _Version        =   393216
            MatchEntry      =   -1  'True
            ListField       =   "BrandDescription"
            BoundColumn     =   "BrandCode"
            Text            =   ""
         End
         Begin MSDBCtls.DBCombo dbcSupplier 
            Bindings        =   "frmStockTake.frx":0017
            Height          =   315
            Left            =   1080
            TabIndex        =   23
            Top             =   1560
            Width           =   2295
            _ExtentX        =   4048
            _ExtentY        =   556
            _Version        =   393216
            MatchEntry      =   -1  'True
            ListField       =   "SupplierName"
            BoundColumn     =   "SupplierCode"
            Text            =   ""
         End
         Begin MSDBCtls.DBCombo dbcCategory 
            Bindings        =   "frmStockTake.frx":0031
            Height          =   315
            Left            =   1080
            TabIndex        =   20
            Top             =   1200
            Width           =   2295
            _ExtentX        =   4048
            _ExtentY        =   556
            _Version        =   393216
            MatchEntry      =   -1  'True
            ListField       =   "CategoryName"
            BoundColumn     =   "CategoryCode"
            Text            =   ""
         End
         Begin MSDBCtls.DBCombo dbcClass 
            Bindings        =   "frmStockTake.frx":004B
            Height          =   315
            Left            =   1080
            TabIndex        =   17
            Top             =   480
            Width           =   2295
            _ExtentX        =   4048
            _ExtentY        =   556
            _Version        =   393216
            MatchEntry      =   -1  'True
            ListField       =   "ClassName"
            BoundColumn     =   "ClassCode"
            Text            =   ""
         End
         Begin MSDBCtls.DBCombo dbcDept 
            Bindings        =   "frmStockTake.frx":0062
            Height          =   315
            Left            =   1080
            TabIndex        =   14
            Top             =   120
            Width           =   2295
            _ExtentX        =   4048
            _ExtentY        =   556
            _Version        =   393216
            MatchEntry      =   -1  'True
            ListField       =   "DepartmentName"
            BoundColumn     =   "DepartmentCode"
            Text            =   ""
         End
         Begin MSDBCtls.DBCombo dbcClass2 
            Bindings        =   "frmStockTake.frx":0078
            Height          =   315
            Left            =   1080
            TabIndex        =   57
            Top             =   840
            Width           =   2295
            _ExtentX        =   4048
            _ExtentY        =   556
            _Version        =   393216
            MatchEntry      =   -1  'True
            ListField       =   "ClassName"
            BoundColumn     =   "ClassCode"
            Text            =   ""
         End
         Begin Threed.SSRibbon cmdCascadeClass2 
            Height          =   315
            Left            =   3360
            TabIndex        =   58
            ToolTipText     =   "Cascade Class"
            Top             =   840
            Width           =   375
            _ExtentX        =   661
            _ExtentY        =   556
            _Version        =   131074
            BackColor       =   12632256
            PictureFrames   =   1
            Picture         =   "frmStockTake.frx":008F
            ButtonStyle     =   2
            BevelWidth      =   1
            PictureDnFrames =   1
            Outline         =   0   'False
            PictureDn       =   "frmStockTake.frx":065D
            GroupNumber     =   2
            Value           =   -1  'True
         End
         Begin VB.Label Label10 
            Caption         =   "Class (2)"
            Height          =   195
            Left            =   120
            TabIndex        =   56
            Top             =   840
            Width           =   855
         End
         Begin Threed.SSCommand cmdFindBaseCurve 
            Height          =   315
            Left            =   2940
            TabIndex        =   45
            Top             =   3360
            Visible         =   0   'False
            Width           =   435
            _ExtentX        =   767
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
            Picture         =   "frmStockTake.frx":0C3F
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin Threed.SSCommand cmdFindCylinder 
            Height          =   315
            Left            =   2940
            TabIndex        =   44
            Top             =   3000
            Visible         =   0   'False
            Width           =   435
            _ExtentX        =   767
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
            Picture         =   "frmStockTake.frx":11E5
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin Threed.SSCommand cmdFindSphere 
            Height          =   315
            Left            =   2940
            TabIndex        =   43
            Top             =   2640
            Visible         =   0   'False
            Width           =   435
            _ExtentX        =   767
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
            Picture         =   "frmStockTake.frx":178B
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin Threed.SSCommand cmdFindModel 
            Height          =   315
            Left            =   2940
            TabIndex        =   42
            Top             =   2280
            Visible         =   0   'False
            Width           =   435
            _ExtentX        =   767
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
            Picture         =   "frmStockTake.frx":1D31
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin Threed.SSRibbon cmdCascadeBaseCurve 
            Height          =   315
            Left            =   3360
            TabIndex        =   39
            Top             =   3360
            Visible         =   0   'False
            Width           =   375
            _ExtentX        =   661
            _ExtentY        =   556
            _Version        =   131074
            BackColor       =   12632256
            PictureFrames   =   1
            Picture         =   "frmStockTake.frx":22D7
            ButtonStyle     =   2
            BevelWidth      =   1
            PictureDnFrames =   1
            Outline         =   0   'False
            PictureDn       =   "frmStockTake.frx":28A5
            GroupNumber     =   9
         End
         Begin Threed.SSRibbon cmdCascadeCylinder 
            Height          =   315
            Left            =   3360
            TabIndex        =   36
            Top             =   3000
            Visible         =   0   'False
            Width           =   375
            _ExtentX        =   661
            _ExtentY        =   556
            _Version        =   131074
            BackColor       =   12632256
            PictureFrames   =   1
            Picture         =   "frmStockTake.frx":2E87
            ButtonStyle     =   2
            BevelWidth      =   1
            PictureDnFrames =   1
            Outline         =   0   'False
            PictureDn       =   "frmStockTake.frx":3455
            GroupNumber     =   8
         End
         Begin Threed.SSRibbon cmdCascadeSphere 
            Height          =   315
            Left            =   3360
            TabIndex        =   33
            Top             =   2640
            Visible         =   0   'False
            Width           =   375
            _ExtentX        =   661
            _ExtentY        =   556
            _Version        =   131074
            BackColor       =   12632256
            PictureFrames   =   1
            Picture         =   "frmStockTake.frx":3A37
            ButtonStyle     =   2
            BevelWidth      =   1
            PictureDnFrames =   1
            Outline         =   0   'False
            PictureDn       =   "frmStockTake.frx":4005
            GroupNumber     =   7
         End
         Begin Threed.SSRibbon cmdCascadeModel 
            Height          =   315
            Left            =   3360
            TabIndex        =   30
            Top             =   2280
            Visible         =   0   'False
            Width           =   375
            _ExtentX        =   661
            _ExtentY        =   556
            _Version        =   131074
            BackColor       =   12632256
            PictureFrames   =   1
            Picture         =   "frmStockTake.frx":45E7
            ButtonStyle     =   2
            BevelWidth      =   1
            PictureDnFrames =   1
            Outline         =   0   'False
            PictureDn       =   "frmStockTake.frx":4BB5
            GroupNumber     =   6
         End
         Begin Threed.SSRibbon cmdCascadeBrand 
            Height          =   315
            Left            =   3360
            TabIndex        =   27
            Top             =   1920
            Width           =   375
            _ExtentX        =   661
            _ExtentY        =   556
            _Version        =   131074
            BackColor       =   12632256
            PictureFrames   =   1
            Picture         =   "frmStockTake.frx":5197
            ButtonStyle     =   2
            BevelWidth      =   1
            PictureDnFrames =   1
            Outline         =   0   'False
            PictureDn       =   "frmStockTake.frx":5765
            GroupNumber     =   5
            Value           =   -1  'True
         End
         Begin Threed.SSRibbon cmdCascadeSupplier 
            Height          =   315
            Left            =   3360
            TabIndex        =   24
            Top             =   1560
            Width           =   375
            _ExtentX        =   661
            _ExtentY        =   556
            _Version        =   131074
            BackColor       =   12632256
            PictureFrames   =   1
            Picture         =   "frmStockTake.frx":5D47
            ButtonStyle     =   2
            BevelWidth      =   1
            PictureDnFrames =   1
            Outline         =   0   'False
            PictureDn       =   "frmStockTake.frx":6315
            GroupNumber     =   4
            Value           =   -1  'True
         End
         Begin Threed.SSRibbon cmdCascadeCategory 
            Height          =   315
            Left            =   3360
            TabIndex        =   21
            Top             =   1200
            Width           =   375
            _ExtentX        =   661
            _ExtentY        =   556
            _Version        =   131074
            BackColor       =   12632256
            PictureFrames   =   1
            Picture         =   "frmStockTake.frx":68F7
            ButtonStyle     =   2
            BevelWidth      =   1
            PictureDnFrames =   1
            Outline         =   0   'False
            PictureDn       =   "frmStockTake.frx":6EC5
            GroupNumber     =   3
            Value           =   -1  'True
         End
         Begin Threed.SSRibbon cmdCascadeClass 
            Height          =   315
            Left            =   3360
            TabIndex        =   18
            ToolTipText     =   "Cascade Class"
            Top             =   480
            Width           =   375
            _ExtentX        =   661
            _ExtentY        =   556
            _Version        =   131074
            BackColor       =   12632256
            PictureFrames   =   1
            Picture         =   "frmStockTake.frx":74A7
            ButtonStyle     =   2
            BevelWidth      =   1
            PictureDnFrames =   1
            Outline         =   0   'False
            PictureDn       =   "frmStockTake.frx":7A75
            GroupNumber     =   2
            Value           =   -1  'True
         End
         Begin Threed.SSRibbon cmdCascadeDept 
            Height          =   315
            Left            =   3360
            TabIndex        =   15
            ToolTipText     =   "Cascade  Dept"
            Top             =   120
            Width           =   375
            _ExtentX        =   661
            _ExtentY        =   556
            _Version        =   131074
            BackColor       =   12632256
            PictureFrames   =   1
            Picture         =   "frmStockTake.frx":8057
            ButtonStyle     =   2
            BevelWidth      =   1
            PictureDnFrames =   1
            Outline         =   0   'False
            PictureDn       =   "frmStockTake.frx":8625
            Value           =   -1  'True
         End
         Begin VB.Label Label9 
            Caption         =   "Base Curve"
            Height          =   195
            Left            =   120
            TabIndex        =   37
            Top             =   3360
            Visible         =   0   'False
            Width           =   855
         End
         Begin VB.Label Label8 
            Caption         =   "Cylinder"
            Height          =   255
            Left            =   120
            TabIndex        =   34
            Top             =   3000
            Visible         =   0   'False
            Width           =   735
         End
         Begin VB.Label Label7 
            Caption         =   "Sphere"
            Height          =   195
            Left            =   120
            TabIndex        =   31
            Top             =   2640
            Visible         =   0   'False
            Width           =   735
         End
         Begin VB.Label Label6 
            Caption         =   "Model"
            Height          =   195
            Left            =   120
            TabIndex        =   28
            Top             =   2280
            Visible         =   0   'False
            Width           =   855
         End
         Begin VB.Label Label5 
            Caption         =   "Brand"
            Height          =   195
            Left            =   120
            TabIndex        =   25
            Top             =   1920
            Width           =   735
         End
         Begin VB.Label Label4 
            Caption         =   "Supplier"
            Height          =   195
            Left            =   120
            TabIndex        =   22
            Top             =   1560
            Width           =   855
         End
         Begin VB.Label Label3 
            Caption         =   "Category"
            Height          =   195
            Left            =   120
            TabIndex        =   19
            Top             =   1200
            Width           =   855
         End
         Begin VB.Label Label2 
            Caption         =   "Class"
            Height          =   195
            Left            =   120
            TabIndex        =   16
            Top             =   480
            Width           =   855
         End
         Begin VB.Label Label1 
            Caption         =   "Department"
            Height          =   195
            Left            =   120
            TabIndex        =   13
            Top             =   120
            Width           =   855
         End
      End
      Begin Threed.SSCommand cmdAddSKU_Cancel 
         Height          =   375
         Left            =   4080
         TabIndex        =   41
         Top             =   780
         Width           =   855
         _ExtentX        =   1508
         _ExtentY        =   661
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
         Caption         =   "Cancel"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdAddSKU_OK 
         Height          =   375
         Left            =   4080
         TabIndex        =   40
         Top             =   300
         Width           =   855
         _ExtentX        =   1508
         _ExtentY        =   661
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
         Caption         =   "Cascade"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin Threed.SSPanel pnlImportMenu 
      Height          =   1095
      Left            =   2040
      TabIndex        =   46
      Top             =   1020
      Visible         =   0   'False
      Width           =   1335
      _ExtentX        =   2355
      _ExtentY        =   1931
      _Version        =   131074
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
      Begin Threed.SSCommand cmdImportWrite 
         Height          =   375
         Left            =   0
         TabIndex        =   49
         ToolTipText     =   "Write Into Worksheet"
         Top             =   720
         Width           =   1335
         _ExtentX        =   2355
         _ExtentY        =   661
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
         Caption         =   "Write File"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdImportPrint 
         Height          =   375
         Left            =   0
         TabIndex        =   48
         ToolTipText     =   "Print Import Data"
         Top             =   360
         Width           =   1335
         _ExtentX        =   2355
         _ExtentY        =   661
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
         Caption         =   "Print File"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdImportSelect 
         Height          =   375
         Left            =   0
         TabIndex        =   47
         ToolTipText     =   "Select Import File"
         Top             =   0
         Width           =   1335
         _ExtentX        =   2355
         _ExtentY        =   661
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
         Caption         =   "Select File"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin VB.Data dtcSTDetails 
      Caption         =   "dtcSTDetails"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   345
      Left            =   9960
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   1500
      Visible         =   0   'False
      Width           =   1140
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar tbrStockTake 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   11430
      _Version        =   131073
      _ExtentX        =   20161
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
      ToolsetPicture  =   "frmStockTake.frx":8C07
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
      ToolsetToolHelp(0)=   "Add Worksheet"
      ToolsetToolMnemonic(0)=   "a"
      ToolsetToolGroup(0)=   1
      ToolsetToolAllowAllUp(0)=   -1  'True
      ToolsetToolType(0)=   1
      ToolsetToolExclusive(0)=   -1  'True
      ToolsetToolID(1)=   "ID_Open"
      ToolsetToolHelp(1)=   "Open Worksheet"
      ToolsetToolMnemonic(1)=   "o"
      ToolsetToolGroup(1)=   1
      ToolsetToolAllowAllUp(1)=   -1  'True
      ToolsetToolType(1)=   1
      ToolsetToolExclusive(1)=   -1  'True
      ToolsetToolID(2)=   "ID_Import"
      ToolsetToolHelp(2)=   "Import Data"
      ToolsetToolMnemonic(2)=   "i"
      ToolsetToolGroup(2)=   1
      ToolsetToolAllowAllUp(2)=   -1  'True
      ToolsetToolType(2)=   1
      ToolsetToolExclusive(2)=   -1  'True
      ToolsetToolID(3)=   "ID_Edit"
      ToolsetToolHelp(3)=   "Edit Worksheet"
      ToolsetToolMnemonic(3)=   "e"
      ToolsetToolGroup(3)=   1
      ToolsetToolAllowAllUp(3)=   -1  'True
      ToolsetToolType(3)=   1
      ToolsetToolExclusive(3)=   -1  'True
      ToolsetToolID(4)=   "ID_Close"
      ToolsetToolHelp(4)=   "Close Worksheet"
      ToolsetToolMnemonic(4)=   "c"
      ToolsetToolGroup(4)=   1
      ToolsetToolAllowAllUp(4)=   -1  'True
      ToolsetToolType(4)=   1
      ToolsetToolExclusive(4)=   -1  'True
      ToolsetToolID(5)=   "ID_Delete"
      ToolsetToolHelp(5)=   "Delete Worksheet"
      ToolsetToolMnemonic(5)=   "d"
      ToolsetToolGroup(5)=   1
      ToolsetToolAllowAllUp(5)=   -1  'True
      ToolsetToolType(5)=   1
      ToolsetToolExclusive(5)=   -1  'True
      ToolsetToolID(6)=   "ID_Print"
      ToolsetToolHelp(6)=   "Print Worksheet"
      ToolsetToolMnemonic(6)=   "p"
      ToolsetToolGroup(6)=   1
      ToolsetToolAllowAllUp(6)=   -1  'True
      ToolsetToolType(6)=   1
      ToolsetToolExclusive(6)=   -1  'True
      ToolsetToolID(7)=   "ID_Update"
      ToolsetToolHelp(7)=   "Update Worksheet"
      ToolsetToolMnemonic(7)=   "u"
      ToolsetToolGroup(7)=   1
      ToolsetToolAllowAllUp(7)=   -1  'True
      ToolsetToolType(7)=   1
      ToolsetToolExclusive(7)=   -1  'True
      ToolsetToolID(8)=   "ID_Exit"
      ToolsetToolHelp(8)=   "Exit Task"
      ToolsetToolMnemonic(8)=   "x"
      ToolsetToolGroup(8)=   1
      ToolsetToolAllowAllUp(8)=   -1  'True
      ToolsetToolType(8)=   1
      ToolsetToolExclusive(8)=   -1  'True
      MouseIcon       =   "frmStockTake.frx":16499
   End
   Begin VB.Data dtcSTHeader 
      Caption         =   "dtcSTHeader"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   345
      Left            =   9960
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT * FROM InvtSTHeader ORDER BY Name"
      Top             =   1200
      Visible         =   0   'False
      Width           =   1140
   End
   Begin Threed.SSFrame fraOpenWorksheet 
      Height          =   2175
      Left            =   120
      TabIndex        =   3
      Top             =   1080
      Width           =   7215
      _ExtentX        =   12726
      _ExtentY        =   3836
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
      Caption         =   "Open Worksheet"
      Begin TrueDBGrid50.TDBGrid dbgOpenWorksheet 
         Bindings        =   "frmStockTake.frx":164B5
         Height          =   1755
         Left            =   120
         OleObjectBlob   =   "frmStockTake.frx":164CF
         TabIndex        =   4
         Top             =   300
         Width           =   6135
      End
      Begin Threed.SSCommand cmdOpenCancel 
         Height          =   375
         Left            =   6360
         TabIndex        =   6
         Top             =   720
         Width           =   735
         _ExtentX        =   1296
         _ExtentY        =   661
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
         Caption         =   "Cancel"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdOpenOK 
         Height          =   375
         Left            =   6360
         TabIndex        =   5
         Top             =   240
         Width           =   735
         _ExtentX        =   1296
         _ExtentY        =   661
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
         Caption         =   "OK"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   10800
      Top             =   5340
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
      CancelError     =   -1  'True
   End
   Begin Threed.SSFrame fraWorksheetData 
      Height          =   4755
      Left            =   120
      TabIndex        =   1
      Top             =   1080
      Width           =   11175
      _ExtentX        =   19711
      _ExtentY        =   8387
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
      Caption         =   "Worksheet Data"
      Begin TrueDBGrid50.TDBGrid dbgWorksheetData 
         Bindings        =   "frmStockTake.frx":19464
         Height          =   3615
         Left            =   120
         OleObjectBlob   =   "frmStockTake.frx":1947F
         TabIndex        =   2
         Top             =   1020
         Width           =   10935
      End
      Begin Threed.SSFrame fraMiniTools 
         Height          =   735
         Left            =   120
         TabIndex        =   7
         Top             =   240
         Width           =   4455
         _ExtentX        =   7858
         _ExtentY        =   1296
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
         Caption         =   "Mini Tools"
         Begin VB.TextBox txtSKU 
            Height          =   375
            Left            =   2400
            TabIndex        =   55
            Top             =   240
            Width           =   1575
         End
         Begin VB.OptionButton optFindSKU 
            Caption         =   "Find SKU"
            Height          =   255
            Left            =   960
            TabIndex        =   54
            Top             =   180
            Value           =   -1  'True
            Width           =   1220
         End
         Begin VB.OptionButton optFindModel 
            Caption         =   "Find Model"
            Height          =   255
            Left            =   960
            TabIndex        =   53
            Top             =   420
            Width           =   1220
         End
         Begin Threed.SSCommand cmdLookupWizard 
            Height          =   375
            Left            =   3960
            TabIndex        =   9
            ToolTipText     =   "Lookup Wizard"
            Top             =   240
            Width           =   375
            _ExtentX        =   661
            _ExtentY        =   661
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
            Picture         =   "frmStockTake.frx":21B64
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin Threed.SSCommand cmdAddStock 
            Height          =   375
            Left            =   120
            TabIndex        =   8
            ToolTipText     =   "Add New"
            Top             =   240
            Width           =   375
            _ExtentX        =   661
            _ExtentY        =   661
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
            Picture         =   "frmStockTake.frx":2210A
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
      End
   End
End
Attribute VB_Name = "frmStockTake"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Dim mCurrentMode As Integer
Private Const mModeIdle    As Integer = 0
Private Const mModeAdd     As Integer = 1
Private Const mModeOpen    As Integer = 2
Private Const mModeImport  As Integer = 3
Private Const mModeEdit    As Integer = 4
Private Const mModeClose   As Integer = 5
Private Const mModeDelete  As Integer = 6
Private Const mModePrint   As Integer = 7
Private Const mModeUpdate  As Integer = 8
Private Const mModeExit    As Integer = 9

Private Const mButtonIndex_Add     As Integer = 0
Private Const mButtonIndex_Open    As Integer = 1
Private Const mButtonIndex_Import  As Integer = 2
Private Const mButtonIndex_Edit    As Integer = 3
Private Const mButtonIndex_Close   As Integer = 4
Private Const mButtonIndex_Delete  As Integer = 5
Private Const mButtonIndex_Print   As Integer = 6
Private Const mButtonIndex_Update  As Integer = 7
Private Const mButtonIndex_Exit    As Integer = 8

Dim mBatchStatus As Integer
Private Const mBatchIdle       As Integer = -1
Private Const mBatchNormal     As Integer = 0
Private Const mBatchBooked     As Integer = 1
Private Const mBatchInput      As Integer = 2
Private Const mBatchPrinted    As Integer = 3
Private Const mBatchUpdated    As Integer = 4
Private Const mBatchDeleted    As Integer = 5

Private Sub cmdAddSKU_Cancel_Click()
    fraAddSKU.Visible = False
    fraAddSKU.Enabled = False
End Sub

' 2005-08-10 paulus
' use action query to speed up adding SKU
Private Sub cmdAddSKU_OK_Click()
    Dim strSQL As String
    Dim GetID, GetDeptCode, GetClassCode, GetCatCode, GetSuppCode, GetBrandCode As String
    Dim blnCascade As Boolean
        
    GetID = CStr(dtcSTHeader.Recordset!ID)
    strSQL = "INSERT INTO InvtSTDetails ( HeaderID, SKU, ComputerQty, PhysicalQty, DiffQty, AverageCost )" & vbLf & _
"SELECT " & GetID & ", SKU, QtyTotalOnhand, 0, 0 - QtyTotalOnhand, AverageCost" & vbLf & _
"From" & vbLf & _
"(" & vbLf & _
"SELECT *" & vbLf & _
"    From [Inventory Query]" & vbLf & _
"    Where" & vbLf

    If cmdCascadeDept.Value And dbcDept.BoundText <> "" Then
        strSQL = strSQL + "DepartmentCode = '" & dbcDept.BoundText & "' And "
    Else
        strSQL = strSQL + "DepartmentCode LIKE '*' And "
    End If
    If cmdCascadeClass.Value And dbcClass.BoundText <> "" Then
        If cmdCascadeClass2.Value And dbcClass2.BoundText <> "" Then
            strSQL = strSQL + "ClassCode IN ('" & dbcClass.BoundText & "', '" & dbcClass2.BoundText & "') And "
        Else
            strSQL = strSQL + "ClassCode = '" & dbcClass.BoundText & "' And "
        End If
    Else
        If cmdCascadeClass2.Value And dbcClass2.BoundText <> "" Then
            strSQL = strSQL + "ClassCode = '" & dbcClass2.BoundText & "' And "
        Else
            strSQL = strSQL + "ClassCode LIKE '*' And "
        End If
    End If
    If cmdCascadeCategory.Value And dbcCategory.BoundText <> "" Then
        strSQL = strSQL + "CategoryCode = '" & dbcCategory.BoundText & "' And "
    Else
        strSQL = strSQL + "CategoryCode LIKE '*' And "
    End If
    If cmdCascadeSupplier.Value And dbcSupplier.BoundText <> "" Then
        strSQL = strSQL + "SupplierCode = '" & dbcSupplier.BoundText & "' And "
    Else
        strSQL = strSQL + "SupplierCode LIKE '*' And "
    End If
    If cmdCascadeBrand.Value And dbcBrand.BoundText <> "" Then
        strSQL = strSQL + "BrandCode = '" & dbcBrand.BoundText & "' "
    Else
        strSQL = strSQL + "BrandCode LIKE '*' "
    End If
    strSQL = strSQL + vbLf & _
")" & vbLf & _
"WHERE SKU NOT IN" & vbLf & _
"(" & vbLf & _
"    SELECT SKU FROM [InvtSTDetails] WHERE HeaderID = " & GetID & vbLf & _
");"
    Call WriteSKU(strSQL)
    Call GetSTDetails
    HideFraAddSKU
'    Call WriteSKU(strSQL)
'    Call GetSTDetails
'    fraAddSKU.Visible = False
'    fraAddSKU.Enabled = False
End Sub

Private Sub cmdAddSKU_OK_Click_Org()
    Dim strSQL As String
    Dim blnCascade As Boolean
        
    strSQL = "SELECT * FROM [Inventory Query] WHERE "
    If cmdCascadeDept.Value Then
        If dbcDept.BoundText <> "" Then
            strSQL = strSQL & "DepartmentCode = '" & dbcDept.BoundText & "' "
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
    Call WriteSKU(strSQL)
    Call GetSTDetails
    HideFraAddSKU
'    Call WriteSKU(strSQL)
'    Call GetSTDetails
'    fraAddSKU.Visible = False
'    fraAddSKU.Enabled = False
End Sub

Private Sub cmdAddStock_Click()
    PopFraAddSKU
End Sub

Private Sub cmdCascadeBaseCurve_Click(Value As Integer)
    If Value = False Then
        cmdFindBaseCurve.Visible = True
    End If
End Sub

Private Sub cmdCascadeCylinder_Click(Value As Integer)
    If Value = False Then
        cmdFindCylinder.Visible = True
    End If
End Sub

Private Sub cmdCascadeModel_Click(Value As Integer)
    If Value = False Then
        cmdFindModel.Visible = True
    End If
End Sub

Private Sub cmdCascadeSphere_Click(Value As Integer)
    If Value = False Then
        cmdFindSphere.Visible = True
    End If
End Sub

Private Sub cmdFindBaseCurve_Click()
    On Error GoTo cmdFindBaseCurve_Click_Err
    
    Dim strSQL As String
    
    'Call DefaultLensParametersValue
    If cmdCascadeBaseCurve.Value Then        ' Cascade selected
        Exit Sub
    Else                                    ' No cascade
        strSQL = "SELECT * FROM [Inventory Query] " _
               & "WHERE BaseCurve LIKE " & txtBaseCurve.Text _
              & " ORDER BY DepartmentCode, ClassCode, CategoryCode"
        Call WriteSKU(strSQL)
        Call GetSTDetails
    End If
    
cmdFindBaseCurve_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                                    ' SDVB autocode
    Exit Sub                                                ' SDVB autocode
cmdFindBaseCurve_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("cmdFindBaseCurve_Click()", Err)  ' SDVB autocode
    Resume cmdFindBaseCurve_Click_Exit
End Sub

Private Sub cmdFindCylinder_Click()
    On Error GoTo cmdFindCylinder_Click_Err

    Dim strSQL As String
    
    If IsNothingEnter(txtCylinder) Then Exit Sub
    '
    If cmdCascadeCylinder.Value Then        ' Cascade selected
        Exit Sub
    Else                                    ' No cascade
        strSQL = "SELECT * FROM [Inventory Query] " _
               & "WHERE Sphere LIKE " & txtCylinder.Text _
              & " ORDER BY DepartmentCode, ClassCode, CategoryCode"
        Call WriteSKU(strSQL)
        Call GetSTDetails
    End If

cmdFindCylinder_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                                   ' SDVB autocode
    Exit Sub                                               ' SDVB autocode
cmdFindCylinder_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("cmdFindCylinder_Click()", Err)  ' SDVB autocode
    Resume cmdFindCylinder_Click_Exit
End Sub

Private Sub cmdFindModel_Click()
    On Error GoTo cmdFindModel_Click_Err

    Dim strSQL As String
    
    If IsNothingEnter(txtModel) Then Exit Sub
    '
    If cmdCascadeModel.Value Then           ' Cascade selected
        Exit Sub
    Else                                    ' No cascade
        strSQL = "SELECT * FROM [Inventory Query] " _
               & "WHERE Model LIKE '" & txtModel.Text & "' " _
               & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
        Call WriteSKU(strSQL)
        Call GetSTDetails
    End If

cmdFindModel_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                                ' SDVB autocode
    Exit Sub                                            ' SDVB autocode
cmdFindModel_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("cmdFindModel_Click()", Err)  ' SDVB autocode
    Resume cmdFindModel_Click_Exit
End Sub

Private Sub cmdFindSphere_Click()
    On Error GoTo cmdFindSphere_Click_Err

    Dim strSQL As String
    
    If IsNothingEnter(txtSphere) Then Exit Sub
    '
    If cmdCascadeSphere.Value Then      ' Cascade selected
        Exit Sub
    Else                                ' No cascade
        strSQL = "SELECT * FROM [Inventory Query] " _
               & "WHERE Sphere LIKE " & txtSphere.Text _
               & " ORDER BY DepartmentCode, ClassCode, CategoryCode"
        Call WriteSKU(strSQL)
        Call GetSTDetails
    End If

cmdFindSphere_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                                 ' SDVB autocode
    Exit Sub                                             ' SDVB autocode
cmdFindSphere_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("cmdFindSphere_Click()", Err)  ' SDVB autocode
    Resume cmdFindSphere_Click_Exit
End Sub

Private Sub cmdImportPrint_Click()
    Call DoImportPrint
End Sub

Private Sub cmdImportSelect_Click()
    Call DoImportSelect
End Sub

Private Sub cmdImportWrite_Click()
    Call DoImportWrite
End Sub

Private Sub cmdLookupWizard_Click()
    Dim strSQL As String
    
    If txtSKU.Text = "" Then Exit Sub
    If optFindSKU = True Then
        strSQL = "SELECT * FROM qryInvtSTDetails " & _
             "WHERE HeaderID = " & dtcSTHeader.Recordset!ID & " " & _
             "and SKU LIKE '" & txtSKU.Text & "' ORDER BY SKU"
    Else
        strSQL = "SELECT * FROM qryInvtSTDetails " & _
             "WHERE HeaderID = " & dtcSTHeader.Recordset!ID & " " & _
             "and MODEL LIKE '" & txtSKU.Text & "' ORDER BY SKU"
    End If
    With dtcSTDetails
        .RecordSource = strSQL
        .Refresh
        .UpdateControls
    End With
End Sub

Private Sub cmdOpenCancel_Click()
    Call SetProtectedArea(mModeIdle)
    Call SetMenuButton(mModeIdle)
End Sub

Private Sub cmdOpenOK_Click()

    On Error GoTo cmdOpenOK_Click_Err
    
    Call GetSTDetails
    Call SetProtectedArea(mModeIdle)
    Call SetMenuButton(mModeOpen)
    dtcSTDetails.Recordset.MoveLast
    dtcSTDetails.Recordset.MoveFirst
    Call PromptStatusBar(frmMain.statMain, "Total SKUs: " & dtcSTDetails.Recordset.RecordCount)
    
cmdOpenOK_Click_Exit:
    On Error Resume Next
    Exit Sub
cmdOpenOK_Click_Err:
    Call ofx_GenericError("cmdOpenOK_Click()", Err)
    Resume cmdOpenOK_Click_Exit
End Sub

Private Sub cmdPrintExceptional_Click()
    Call PrintSTExceptional(0, dtcSTHeader.Recordset!ID)
End Sub

Private Sub cmdPrintJournal_Click()
    Call PrintSTJournal(0, dtcSTHeader.Recordset!ID)
End Sub

Private Sub cmdPrintWorkBook_Click()

    On Error GoTo cmdPrintWorkBook_Click_Err

    Call PrintSTWorkBook(0, dtcSTHeader.Recordset!ID)

cmdPrintWorkBook_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                                    ' SDVB autocode
    Exit Sub                                                ' SDVB autocode
cmdPrintWorkBook_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("cmdPrintWorkBook_Click()", Err)  ' SDVB autocode
    Resume cmdPrintWorkBook_Click_Exit
End Sub

Private Sub dbcBrand_Click(intArea As Integer)
    Dim strSQL As String
    
    If intArea = dbcAreaList Then
        If cmdCascadeBrand.Value Then    ' Cascade selected
            Exit Sub
        Else                                ' No cascade
            strSQL = "SELECT * FROM [Inventory Query]" _
                & "WHERE BrandCode = '" & dbcBrand.BoundText & "' " _
                & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
            Call WriteSKU(strSQL)
            Call GetSTDetails
        End If
    End If
End Sub

Private Sub dbcCategory_Click(intArea As Integer)
    Dim strSQL As String
    
    If intArea = dbcAreaList Then
        ' Lookup dtcInventory
        If cmdCascadeCategory.Value Then    ' Cascade selected
            Exit Sub
        Else                                ' No cascade
            strSQL = "SELECT * FROM [Inventory Query] " _
                & "WHERE CategoryCode = '" & dbcCategory.BoundText & "' " _
                & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
            Call WriteSKU(strSQL)
            Call GetSTDetails
        End If
    End If
End Sub

Private Sub dbcClass_Click(intArea As Integer)
    Dim strSQL As String
    
    If intArea = dbcAreaList Then
        If cmdCascadeCategory.Value Then
            ' Limit dbcCategory list items to the same Dept
            strSQL = "SELECT * FROM Category " _
                & "WHERE DepartmentCode = '" & dbcDept.BoundText & "' AND " _
                & "ClassCode = '" & dbcClass.BoundText & "' " _
                & "ORDER BY CategoryName"
            dtcCategory.RecordSource = strSQL
            dtcCategory.Refresh
            dtcCategory.UpdateControls
        End If
        '
        ' Lookup dtcInventory
        If cmdCascadeClass.Value Then   ' Cascade selected
            Exit Sub
        Else                            ' No cascade
            strSQL = "SELECT * FROM [Inventory Query] " _
                & "WHERE ClassCode = '" & dbcClass.BoundText & "' " _
                & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
            Call WriteSKU(strSQL)
            Call GetSTDetails
        End If
    End If
End Sub

Private Sub dbcClass2_Click(intArea As Integer)
    Dim strSQL As String
    
    If intArea = dbcAreaList Then
        If cmdCascadeCategory.Value Then
            ' Limit dbcCategory list items to the same Dept
            strSQL = "SELECT * FROM Category " _
                & "WHERE DepartmentCode = '" & dbcDept.BoundText & "' AND " _
                & "ClassCode = '" & dbcClass2.BoundText & "' " _
                & "ORDER BY CategoryName"
            dtcCategory.RecordSource = strSQL
            dtcCategory.Refresh
            dtcCategory.UpdateControls
        End If
        '
        ' Lookup dtcInventory
        If cmdCascadeClass2.Value Then   ' Cascade selected
            Exit Sub
        Else                            ' No cascade
            strSQL = "SELECT * FROM [Inventory Query] " _
                & "WHERE ClassCode = '" & dbcClass2.BoundText & "' " _
                & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
            Call WriteSKU(strSQL)
            Call GetSTDetails
        End If
    End If

End Sub

Private Sub dbcDept_Click(intArea As Integer)
    Dim strSQL As String
    
    If intArea = dbcAreaList Then
        If cmdCascadeClass.Value Then
            ' Limit dbcClass list items to the same Dept
            strSQL = "SELECT * FROM Class " _
                & "WHERE Department = '" & dbcDept.BoundText & "' " _
                & "ORDER BY ClassName"
            dtcClass.RecordSource = strSQL
            dtcClass.Refresh
            dtcClass.UpdateControls
        End If
        '
        ' Lookup dtcInventory
        If cmdCascadeDept.Value Then    ' Cascade selected
            Exit Sub
        Else                            ' No cascade
            strSQL = "SELECT * FROM [Inventory Query] " _
                & "WHERE DepartmentCode = '" & dbcDept.BoundText & "' " _
                & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
            Call WriteSKU(strSQL)
            Call GetSTDetails
        End If
    End If
End Sub

Private Sub dbcSupplier_Click(intArea As Integer)
    Dim strSQL As String
    
    If intArea = dbcAreaList Then
        If cmdCascadeSupplier.Value Then    ' Cascade selected
            Exit Sub
        Else                                ' No cascade
            strSQL = "SELECT * FROM [Inventory Query] " _
                & "WHERE SupplierCode = '" & dbcSupplier.BoundText & "' " _
                & "ORDER BY DepartmentCode, ClassCode, CategoryCode"
            Call WriteSKU(strSQL)
            Call GetSTDetails
        End If
    End If
End Sub

Private Sub dbgWorksheetData_AfterColUpdate(ByVal ColIndex As Integer)
    Dim myCol As Columns
    Dim intComputerQty, intPhysicalQty, intDiffQty As Integer

    Set myCol = dbgWorksheetData.Columns
    
    ' Calculate the Amount if Qty, Unit Price, or Markdown is changed
    If myCol(ColIndex).Caption = "Stock Take Qty" Then
        intComputerQty = ofx_CInt(myCol("Computer Qty"))
        intPhysicalQty = ofx_CInt(myCol("Stock Take Qty"))
        intDiffQty = intPhysicalQty - intComputerQty
        myCol("Difference") = intDiffQty
    End If
    '
    dbgWorksheetData.Update   ' Force update
End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
'    Call FillBrandToAdd
    
    mCurrentMode = mModeIdle
    mBatchStatus = mBatchIdle
    Call SetMenuButton(mModeIdle)
    Call SetProtectedArea(mCurrentMode)
    Call SetBlankForm

End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call PromptStatusBar(frmMain.statMain, "")
    Call ofx_CloseForm(Me)
End Sub

Private Sub tbrStockTake_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)
    Dim i As Integer
    
    ' Ignor Up clicks
    If Value = False Then Exit Sub
    
    ' Avoid operator using the accerator key for disabled buttons.
    ' If the Button pressed is disabled,
    ' raise the button and do nothing.
    If tbrStockTake.Buttons(Btn).Enabled = False And Value = True Then
        tbrStockTake.Buttons(Btn).Value = False
        Exit Sub
    End If
    
    ' The "exculsive" option of Sheriden ToolBar doesn't work here.
    ' Emulate exclusive function by raising all other buttons
    For i = 0 To (tbrStockTake.ToolsetTools.Count - 1)
        If i <> Btn And tbrStockTake.Buttons(i).Value Then
            tbrStockTake.Buttons(i).Value = False
        End If
    Next i
    
' When button was Down
    If Value Then
        ' The "exculsive" option of Sheriden ToolBar doesn't work here.
        ' Emulate exclusive function by raising all other buttons
        For i = 0 To (tbrStockTake.ToolsetTools.Count - 1)
            If i <> Btn Then _
                tbrStockTake.Buttons(i).Value = False
        Next i
    
        Select Case ToolID
            Case "ID_Add"
                Call DoAdd
            Case "ID_Open"
                Call DoOpen
'    fraOpenWorksheet.Visible = False
            Case "ID_Import"
                Call DoImport
            Case "ID_Edit"
                Call DoEdit
            Case "ID_Close"
                Call DoClose
            Case "ID_Delete"
                Call DoDelete
            Case "ID_Print"
                Call DoPrint
            Case "ID_Update"
                Call DoUpdate
            Case "ID_Exit"
                Unload Me
        End Select
    End If

End Sub



Private Sub SetBlankForm()

    Dim i As Integer
    
    For i = 0 To (Me.Count - 1)
        If TypeOf Me.Controls(i) Is CheckBox Then
            Me.Controls(i).Value = 0    ' unchecked
        End If
        If TypeOf Me.Controls(i) Is MaskEdBox Then
            Me.Controls(i).Text = ""    ' empty
        End If
        If TypeOf Me.Controls(i) Is TextBox Then
            Me.Controls(i).Text = ""    ' empty
        End If
        If TypeOf Me.Controls(i) Is DBCombo Then
            Me.Controls(i).Text = ""    ' empty
        End If
    Next i

End Sub

Private Sub SetMenuButton(intMode As Integer)
With tbrStockTake
    Select Case intMode
        Case mModeIdle
            Call ButtonsAllUp
            .Buttons(mButtonIndex_Add).Enabled = True
            .Buttons(mButtonIndex_Open).Enabled = True
            .Buttons(mButtonIndex_Import).Enabled = False
            .Buttons(mButtonIndex_Edit).Enabled = False
            .Buttons(mButtonIndex_Close).Enabled = False
            .Buttons(mButtonIndex_Delete).Enabled = False
            .Buttons(mButtonIndex_Print).Enabled = False
            .Buttons(mButtonIndex_Update).Enabled = False
            .Buttons(mButtonIndex_Exit).Enabled = True
        Case mModeAdd
            .Buttons(mButtonIndex_Add).Enabled = True
            .Buttons(mButtonIndex_Open).Enabled = False
            .Buttons(mButtonIndex_Import).Enabled = False
            .Buttons(mButtonIndex_Edit).Enabled = True
            .Buttons(mButtonIndex_Close).Enabled = True
            .Buttons(mButtonIndex_Delete).Enabled = False
            .Buttons(mButtonIndex_Print).Enabled = False
            .Buttons(mButtonIndex_Update).Enabled = False
            .Buttons(mButtonIndex_Exit).Enabled = True
        Case mModeOpen
            .Buttons(mButtonIndex_Add).Enabled = False
            .Buttons(mButtonIndex_Open).Enabled = True
            .Buttons(mButtonIndex_Import).Enabled = True
            .Buttons(mButtonIndex_Edit).Enabled = True
            .Buttons(mButtonIndex_Close).Enabled = True
            .Buttons(mButtonIndex_Delete).Enabled = True
            .Buttons(mButtonIndex_Print).Enabled = True
            .Buttons(mButtonIndex_Update).Enabled = True
            .Buttons(mButtonIndex_Exit).Enabled = True
            Select Case dtcSTHeader.Recordset.Status
                Case 3, 4   ' Updated or deleted
                    .Buttons(mButtonIndex_Import).Enabled = False
                    .Buttons(mButtonIndex_Edit).Enabled = False
                    .Buttons(mButtonIndex_Delete).Enabled = False
                    .Buttons(mButtonIndex_Update).Enabled = False
            End Select
        Case mModeImport
        Case mModeEdit
            .Buttons(mButtonIndex_Add).Enabled = False
            .Buttons(mButtonIndex_Open).Enabled = False
            .Buttons(mButtonIndex_Import).Enabled = False
            .Buttons(mButtonIndex_Edit).Enabled = True
            .Buttons(mButtonIndex_Close).Enabled = True
            .Buttons(mButtonIndex_Delete).Enabled = False
            .Buttons(mButtonIndex_Print).Enabled = False
            .Buttons(mButtonIndex_Update).Enabled = False
            .Buttons(mButtonIndex_Exit).Enabled = True
        Case mModeClose
            .Buttons(mButtonIndex_Add).Enabled = True
            .Buttons(mButtonIndex_Open).Enabled = True
            .Buttons(mButtonIndex_Import).Enabled = False
            .Buttons(mButtonIndex_Edit).Enabled = False
            .Buttons(mButtonIndex_Close).Enabled = True
            .Buttons(mButtonIndex_Delete).Enabled = False
            .Buttons(mButtonIndex_Print).Enabled = False
            .Buttons(mButtonIndex_Update).Enabled = False
            .Buttons(mButtonIndex_Exit).Enabled = True
        Case mModeDelete
            .Buttons(mButtonIndex_Add).Enabled = True
            .Buttons(mButtonIndex_Open).Enabled = True
            .Buttons(mButtonIndex_Import).Enabled = False
            .Buttons(mButtonIndex_Edit).Enabled = False
            .Buttons(mButtonIndex_Close).Enabled = False
            .Buttons(mButtonIndex_Delete).Enabled = False
            .Buttons(mButtonIndex_Print).Enabled = False
            .Buttons(mButtonIndex_Update).Enabled = False
            .Buttons(mButtonIndex_Exit).Enabled = True
        Case mModePrint
        Case mModeUpdate
            Call SetMenuButton(mModeIdle)
    End Select
End With
End Sub






Private Function GetNewBatch() As Boolean
    Dim Message, Title, BatchName As String
    
    Message = "Enter a Name for it:"   ' Set prompt.
    Title = "Add New Worksheet" ' Set title.
    ' Display message, title, and default value.
    BatchName = InputBox(Message, Title)

    If BatchName = "" Then
        GetNewBatch = False
    Else
        If IsFound("InvtSTHeader", "Name", BatchName, False) Then
            MsgBox "Name already in use."
            GetNewBatch = False
        Else
            With dtcSTHeader.Recordset
                .AddNew
                !Name = BatchName
                !DateOfCreation = Now
                dtcSTHeader.UpdateRecord
                .Bookmark = .LastModified
                dtcSTHeader.UpdateControls
            End With
            GetNewBatch = True
        End If
    End If
End Function

Private Sub SetProtectedArea(intCurrentMode As Integer)

    Select Case intCurrentMode
        Case mModeIdle
            pnlImportMenu.Visible = False
            pnlImportMenu.Enabled = False
            pnlPrintMenu.Visible = False
            pnlPrintMenu.Enabled = False
            fraOpenWorksheet.Visible = False
            fraOpenWorksheet.Enabled = False
            fraWorksheetData.Visible = True
            fraWorksheetData.Enabled = False
        Case mModeAdd
            pnlImportMenu.Visible = False
            pnlImportMenu.Enabled = False
            pnlPrintMenu.Visible = False
            pnlPrintMenu.Enabled = False
            fraOpenWorksheet.Visible = False
            fraOpenWorksheet.Enabled = False
            fraWorksheetData.Visible = True
            fraWorksheetData.Enabled = False
        Case mModeOpen
            pnlImportMenu.Visible = False
            pnlImportMenu.Enabled = False
            pnlPrintMenu.Visible = False
            pnlPrintMenu.Enabled = False
            fraWorksheetData.Visible = False
            fraWorksheetData.Enabled = False
            fraOpenWorksheet.Visible = True
            fraOpenWorksheet.Enabled = True
        Case mModeImport
            pnlImportMenu.Visible = True
            pnlImportMenu.Enabled = True
            pnlPrintMenu.Visible = False
            pnlPrintMenu.Enabled = False
            fraOpenWorksheet.Visible = False
            fraOpenWorksheet.Enabled = False
            fraWorksheetData.Visible = True
            fraWorksheetData.Enabled = False
        Case mModeEdit
            pnlImportMenu.Visible = False
            pnlImportMenu.Enabled = False
            pnlPrintMenu.Visible = False
            pnlPrintMenu.Enabled = False
            fraOpenWorksheet.Visible = False
            fraOpenWorksheet.Enabled = False
            fraWorksheetData.Visible = True
            fraWorksheetData.Enabled = True
        Case mModeClose
            pnlImportMenu.Visible = False
            pnlImportMenu.Enabled = False
            pnlPrintMenu.Visible = False
            pnlPrintMenu.Enabled = False
            fraOpenWorksheet.Visible = False
            fraOpenWorksheet.Enabled = False
            fraWorksheetData.Visible = True
            fraWorksheetData.Enabled = False
        Case mModePrint
            pnlImportMenu.Visible = False
            pnlImportMenu.Enabled = False
            pnlPrintMenu.Visible = True
            pnlPrintMenu.Enabled = True
            fraOpenWorksheet.Visible = False
            fraOpenWorksheet.Enabled = False
            fraWorksheetData.Visible = True
            fraWorksheetData.Enabled = False
        Case mModeUpdate
            pnlImportMenu.Visible = False
            pnlImportMenu.Enabled = False
            pnlPrintMenu.Visible = False
            pnlPrintMenu.Enabled = False
            fraOpenWorksheet.Visible = False
            fraOpenWorksheet.Enabled = False
            fraWorksheetData.Visible = True
            fraWorksheetData.Enabled = False
        Case mModeDelete
            pnlImportMenu.Visible = False
            pnlImportMenu.Enabled = False
            pnlPrintMenu.Visible = False
            pnlPrintMenu.Enabled = False
            fraOpenWorksheet.Visible = False
            fraOpenWorksheet.Enabled = False
            fraWorksheetData.Visible = True
            fraWorksheetData.Enabled = False
    End Select
End Sub

Private Sub GetBatchStatus()
    mBatchStatus = dtcSTHeader.Recordset!Status
End Sub

Private Sub DoImport()
    Dim strSQL As String
    Dim myDB As Database
    Dim myImportFile As Recordset
    
    mCurrentMode = mModeImport
    Call SetMenuButton(mModeImport)
    Call SetProtectedArea(mModeImport)
    
    strSQL = "SELECT * FROM InvtSTImport WHERE HeaderID = " & dtcSTHeader.Recordset!ID
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                           ' Open database
    Set myImportFile = myDB.OpenRecordset(strSQL, dbOpenDynaset)
    '
    If IsTableEmpty(myImportFile) Then
        cmdImportPrint.Enabled = False
        cmdImportWrite.Enabled = False
    Else
        cmdImportPrint.Enabled = True
        cmdImportWrite.Enabled = True
    End If
    myImportFile.Close
    myDB.Close
End Sub

Private Sub DoAdd()
    mCurrentMode = mModeAdd
    If Not GetNewBatch() Then     ' Terminate if new batch not valid
        Call SetMenuButton(mModeIdle)
        Exit Sub
    End If
    Call GetSTDetails
    Call SetMenuButton(mModeAdd)
    Call SetProtectedArea(mModeAdd)
End Sub

Private Sub DoOpen()
    mCurrentMode = mModeOpen
    Call SetProtectedArea(mModeOpen)
End Sub

Private Sub DoClose()
    On Error GoTo DoClose_Err
    
    ' Varify some important entries
    ' If anyone failed, stop update
        If IsGridEditing(dbgWorksheetData, vbYes) Then
            Call ToggleMenuButton(mButtonIndex_Close)
            Call ToggleMenuButton(mButtonIndex_Edit)
            Exit Sub
        End If
    
    mCurrentMode = mModeClose
    Call SetMenuButton(mModeClose)
    Call SetProtectedArea(mModeClose)
    Call ClearWorksheetData

DoClose_Exit:                                ' SDVB autocode
    On Error Resume Next                     ' SDVB autocode
    Call PromptStatusBar(frmMain.statMain, "")
    Exit Sub                                 ' SDVB autocode
DoClose_Err:                                 ' SDVB autocode
    Call ofx_GenericError("DoClose()", Err)  ' SDVB autocode
    Resume DoClose_Exit
End Sub

Private Sub DoDelete()
    On Error GoTo DoDelete_Err

    If Not ConfirmDelete() Then Exit Sub    ' Terminate if new batch not valid
    mCurrentMode = mModeDelete
    Call SetMenuButton(mModeDelete)
    Call SetProtectedArea(mModeDelete)
    
    With dtcSTHeader.Recordset
        .Edit
        !DateOfPurge = Now
        !Status = 4
        .Update
    End With
    Call ClearWorksheetData

DoDelete_Exit:                                ' SDVB autocode
    On Error Resume Next                      ' SDVB autocode
    Exit Sub                                  ' SDVB autocode
DoDelete_Err:                                 ' SDVB autocode
    Call ofx_GenericError("DoDelete()", Err)  ' SDVB autocode
    Resume DoDelete_Exit
End Sub

Private Sub DoPrint()
    mCurrentMode = mModePrint
    Call SetMenuButton(mModePrint)
    Call SetProtectedArea(mModePrint)
    Call UpdateHeaderStatus(mModePrint)
End Sub

Private Sub DoEdit()
    mCurrentMode = mModeEdit
    Call SetMenuButton(mModeEdit)
    Call SetProtectedArea(mModeEdit)
    Call UpdateHeaderStatus(mModeEdit)
End Sub

Private Sub DoUpdate()
    If Not ConfirmUpdate() Then Exit Sub    ' Terminate if user abort
    '
    mCurrentMode = mModeUpdate
    Call SetMenuButton(mModeUpdate)
    Call SetProtectedArea(mModeUpdate)
    Call UpdateHeaderStatus(mModeUpdate)
    '
    Call UpdateWorksheet
    Call ClearWorksheetData
End Sub

Private Sub GetSTDetails()
    On Error GoTo GetSTDetails_Err

    Dim strSQL As String
    
    Screen.MousePointer = vbHourglass
    strSQL = "SELECT * FROM qryInvtSTDetails " & _
             "WHERE HeaderID = " & dtcSTHeader.Recordset!ID & " " & _
             "ORDER BY SKU"
    dtcSTDetails.RecordSource = strSQL
    dtcSTDetails.Refresh
    dtcSTDetails.UpdateControls
    fraWorksheetData.Caption = "Worksheet: " & dtcSTHeader.Recordset!Name
    Call PromptStatusBar(frmMain.statMain, "Ready")
    Screen.MousePointer = vbDefault

GetSTDetails_Exit:                                ' SDVB autocode
    On Error Resume Next                          ' SDVB autocode
    Exit Sub                                      ' SDVB autocode
GetSTDetails_Err:                                 ' SDVB autocode
    Call ofx_GenericError("GetSTDetails()", Err)  ' SDVB autocode
    Resume GetSTDetails_Exit
End Sub

Private Function ConfirmDelete() As Boolean
    Dim intLastChance As Integer
    Dim strMessage As String
    
    strMessage = "Are you realy want to delete this Worksheet?" & Chr(13) & Chr(13) & _
                 "Yes to Confirm Delete" & Chr(13) & _
                 "No  to Abort Delete"
    intLastChance = MsgBox(strMessage, vbYesNo, "Delete Worksheet")
    Select Case intLastChance
        Case vbYes
            ConfirmDelete = True
        Case vbNo
            ConfirmDelete = False
    End Select
End Function

Private Sub ClearWorksheetData()
    Screen.MousePointer = vbHourglass
    dtcSTDetails.RecordSource = "SELECT * FROM qryInvtSTDetails WHERE FALSE"
    dtcSTDetails.Refresh
    dtcSTDetails.UpdateControls
    fraWorksheetData.Caption = "Worksheet: Empty"
    Screen.MousePointer = vbDefault
End Sub

' Extract SKU Info from Inventory Table
Private Sub GetInvtInfo()
    Dim myDB As Database
    Dim myInventory, mySTDetails As Recordset
    
    Screen.MousePointer = vbHourglass
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                           ' Open database
    Set myInventory = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)    ' Open table read only
    Set mySTDetails = myDB.OpenRecordset("InvtSTDetails", dbOpenDynaset)

    With myInventory
        Do While Not .EOF
            mySTDetails.AddNew
            mySTDetails!HeaderID = dtcSTHeader.Recordset!ID
            mySTDetails!SKU = !SKU
            mySTDetails!ComputerQty = !QtyTotalOnhand
            mySTDetails!PhsicalQty = !QtyTotalOnhand
            mySTDetails!DiffQty = 0
            mySTDetails.Update
            .MoveNext
        Loop
    End With
    myInventory.Close
    mySTDetails.Close
    myDB.Close                          ' Close database.
    Screen.MousePointer = vbDefault
End Sub

' 2005-08-10 paulus
' use action query to speed up adding SKU
Private Sub WriteSKU(strTarget As String)
    On Error GoTo WriteSKU_Err

    Dim myDB As Database
    
    Screen.MousePointer = vbHourglass
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                      ' Open database
    myDB.Execute (strTarget)
    
    Screen.MousePointer = vbDefault
    
WriteSKU_WrapUP:
    Screen.MousePointer = vbDefault
    Call PromptStatusBar(frmMain.statMain, pyUserName)
    myDB.Close
    
WriteSKU_Exit:                                ' SDVB autocode
    On Error Resume Next                      ' SDVB autocode
    Exit Sub                                  ' SDVB autocode
WriteSKU_Err:                                 ' SDVB autocode
    Call ofx_GenericError("WriteSKU()", Err)  ' SDVB autocode
    Resume WriteSKU_Exit
End Sub

Private Sub WriteSKU_Org(strTarget As String)
    On Error GoTo WriteSKU_Err

    Dim myDB As Database
    Dim myTarget, mySTDetails As Recordset
    Dim strSQL As String
    
    Screen.MousePointer = vbHourglass
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                           ' Open database
    Set myTarget = myDB.OpenRecordset(strTarget, dbOpenDynaset, dbReadOnly)    ' Open table read only
    Set mySTDetails = myDB.OpenRecordset("InvtSTDetails", dbOpenDynaset)
    
    With myTarget
        If Not .EOF And Not .BOF Then
            .MoveFirst
            Do While Not .EOF
                With mySTDetails
                    strSQL = "SKU = '" & myTarget!SKU & "' And " & _
                             "HeaderID = " & dtcSTHeader.Recordset!ID
                    .FindFirst strSQL
                    If .NoMatch Then
                        Call PromptStatusBar(frmMain.statMain, "Retriving SKU " & myTarget!SKU)
                        .AddNew
                        !HeaderID = dtcSTHeader.Recordset!ID
                        !SKU = myTarget!SKU
                        !ComputerQty = myTarget!QtyTotalOnhand
                        !PhysicalQty = 0
                        !DiffQty = 0 - myTarget!QtyTotalOnhand
                        !AverageCost = myTarget!AverageCost
                        .Update
                    Else
                        Call PromptStatusBar(frmMain.statMain, "Ignoring existing SKU " & myTarget!SKU)
                    End If
                End With
                .MoveNext
            Loop
        End If
    End With
    Screen.MousePointer = vbDefault
    mySTDetails.Close
    
WriteSKU_WrapUP:
    Screen.MousePointer = vbDefault
    Call PromptStatusBar(frmMain.statMain, pyUserName)
    myTarget.Close
    myDB.Close
    
WriteSKU_Exit:                                ' SDVB autocode
    On Error Resume Next                      ' SDVB autocode
    Exit Sub                                  ' SDVB autocode
WriteSKU_Err:                                 ' SDVB autocode
    Call ofx_GenericError("WriteSKU()", Err)  ' SDVB autocode
    Resume WriteSKU_Exit
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

Private Sub txtModel_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindModel_Click
        KeyAscii = 0
    End If
End Sub

Private Sub txtSKU_GotFocus()
    Call AutoSelect(txtSKU)
End Sub

Private Sub txtSKU_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdLookupWizard_Click
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

Private Function ConfirmUpdate() As Boolean
    Dim intLastChance As Integer
    Dim strMessage As String
    
    strMessage = "Are you realy want to Update this Worksheet?" & Chr(13) & Chr(13) & _
                 "Yes to Confirm Update" & Chr(13) & _
                 "No  to Abort Update"
    intLastChance = MsgBox(strMessage, vbYesNo, "Update Worksheet")
    Select Case intLastChance
        Case vbYes
            ConfirmUpdate = True
        Case vbNo
            ConfirmUpdate = False
    End Select
End Function

Private Sub UpdateWorksheet()
    Dim myDB As Database
    Dim myWorksheet, TxHeader, TxDetails, TxSalePerson As Recordset
    Dim MyControlNumber As String
    Dim i As Integer
    Dim MyTxNumber, strSQL, MyCriteria As String
    
    Screen.MousePointer = vbHourglass
    strSQL = "SELECT * FROM InvtSTDetails WHERE HeaderID = " & dtcSTHeader.Recordset!ID
    MyCriteria = "SKU = '" & " " & "'"      ' Set the criteria.
    MyControlNumber = GetNextControlNumber
    MyTxNumber = GetNextTxNumber("SJ")
    
    '
    ' Write entries into Tx files and pass control to OLTP for posting
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                                        ' Open database
    Set myWorksheet = myDB.OpenRecordset(strSQL, dbOpenDynaset, dbReadOnly)                           '
    Set TxHeader = myDB.OpenRecordset("TxHeader", dbOpenDynaset, dbAppendOnly)            ' Open table for append only
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbAppendOnly)          ' Open table for append only
    Set TxSalePerson = myDB.OpenRecordset("TxSalePerson", dbOpenDynaset, dbAppendOnly)    ' Open table for append only
    '
    ' Write TxHeader
    Call PromptStatusBar(frmMain.statMain, "Updating Transaction Header")
    With TxHeader
        .AddNew
        !ControlNumber = MyControlNumber
        !TxType = Left(MyTxNumber, 2)
        !TxNumber = MyTxNumber
        !DateOfEntry = dtcSTHeader.Recordset!DateOfCreation
        !DateOfCreation = Now
        !RefNumber = dtcSTHeader.Recordset!ID
        !Particulars = dtcSTHeader.Recordset!Name
        .Update
    End With
    
    ' Write TxSalePerson
    Call PromptStatusBar(frmMain.statMain, "Updating Sales Person")
    With TxSalePerson
        .AddNew
        !TxNumber = MyTxNumber
        !SalesRowNo = 1
        !StaffCode = pyUserID
        .Update
    End With
    
    ' Write TxDetails
    With myWorksheet
        .MoveFirst
        i = 0
        Do While Not .EOF
            Call PromptStatusBar(frmMain.statMain, "Updating Transaction Details - SKU#" & myWorksheet!SKU)
            
            If (myWorksheet!DiffQty <> 0) Then
            With TxDetails
                .AddNew
                !ControlNumber = MyControlNumber
                !TxType = Left(MyTxNumber, 2)
                !TxNumber = MyTxNumber
                !DateOfEntry = dtcSTHeader.Recordset!DateOfCreation
                !RowNo = (i + 1)
                !SKU = myWorksheet!SKU
                !Qty = myWorksheet!DiffQty
                .Update
            End With
            i = i + 1
            End If
            .MoveNext
        Loop
    End With
    '
    ' Activate OLTP to post transaction
    OLTP_IC (MyTxNumber)
    
    '
    Screen.MousePointer = vbDefault
    ofx_DoMessageBox "Save is done." & Chr$(13) & _
                     "Please stamp your document with the Tx Number: " & MyTxNumber & Chr(13) & _
                     "for later reference."
    TxHeader.Close
    TxDetails.Close
    TxSalePerson.Close
    myWorksheet.Close
    myDB.Close
End Sub

Private Sub DoImportSelect()
    Dim strImportFileName As String
    
    ' Get the Import File Name
    strImportFileName = DoImportSelect_GetFile()
    If strImportFileName = "" Then Exit Sub      ' Terminate if no file selected
    
    ' Import data file
    Call DoImportSelect_ClearImportTable
    Call DoImportSelect_ConvertFile(strImportFileName)
    Call DoImportSelect_VerifyImportTable
    Call DoImportSelect_PrintErrorReport
    
    ' Enable Import Menu Buttons
    cmdImportPrint.Enabled = True
    cmdImportWrite.Enabled = True
End Sub

Private Sub DoImportPrint()

End Sub

Private Sub DoImportWrite()
    On Error GoTo DoImportWrite_Err
    
    Dim strSQL As String
    Dim myDB As Database
    Dim myTarget, myImportFile As Recordset
    
    Screen.MousePointer = vbHourglass
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                           ' Open database
    '
    strSQL = "SELECT * FROM InvtSTImport WHERE HeaderID =" & dtcSTHeader.Recordset!ID
    Set myImportFile = myDB.OpenRecordset(strSQL, dbOpenDynaset, dbReadOnly)
    '
    strSQL = "SELECT * FROM InvtSTDetails WHERE HeaderID =" & dtcSTHeader.Recordset!ID
    Set myTarget = myDB.OpenRecordset(strSQL, dbOpenDynaset)
    With myImportFile
        .MoveFirst
        Do While Not .EOF
            If !Status = 0 Then
                Call PromptStatusBar(frmMain.statMain, "Writing SKU#" & !SKU)
                Sleep (100)
                strSQL = "SKU ='" & !SKU & "'"
                With myTarget
                    .FindFirst strSQL
                    .Edit
                    !PhysicalQty = !PhysicalQty + myImportFile!Qty
                    !DiffQty = !PhysicalQty - !ComputerQty
                    .Update
                End With
            End If
            .MoveNext
        Loop
    End With
    '
    myTarget.Close
    myImportFile.Close
    myDB.Close
    Screen.MousePointer = vbDefault
    Call PromptStatusBar(frmMain.statMain, pyUserName)
    
    ' Clear Import File and refresh the Worksheet Data
    Call DoImportSelect_ClearImportTable
    Call GetSTDetails
    
DoImportWrite_Exit:                                ' SDVB autocode
    On Error Resume Next                           ' SDVB autocode
    Exit Sub                                       ' SDVB autocode
DoImportWrite_Err:                                 ' SDVB autocode
    Call ofx_GenericError("DoImportWrite()", Err)  ' SDVB autocode
    Resume DoImportWrite_Exit
End Sub

Private Function DoImportSelect_GetFile() As String
    
    ' Goto error if User press Cancel button
    On Error GoTo DoImportWrite_GetFileError
    
    With CommonDialog1
        .DialogTitle = "Import Worksheet Data"
        .Filter = "Text Files (*.txt)"
        .FilterIndex = 1
        .FileName = "*.txt"
        .Flags = cdlOFNExplorer Or _
                 cdlOFNFileMustExist
        .ShowOpen
    End With
    
    ' Reset current directory to the Application Startup Directory
    ChDrive App.Path
    ChDir App.Path
    ' Return the selected file name
    DoImportSelect_GetFile = CommonDialog1.FileName
    Exit Function

' User cancel select file
DoImportWrite_GetFileError:
    Exit Function

End Function

Private Sub DoImportSelect_ConvertFile(strImportFileName As String)
    On Error GoTo DoImportSelect_ConvertFile_Err

    Dim strReadLine, strSKU, strSQL As String
    Dim myDB As Database
    Dim myTarget As Recordset
    
    Screen.MousePointer = vbHourglass
    strSQL = "SELECT * FROM InvtSTImport WHERE HeaderID = " & dtcSTHeader.Recordset.ID
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                           ' Open database
    Set myTarget = myDB.OpenRecordset(strSQL, dbOpenDynaset)
    
    ' Import data file
    Screen.MousePointer = vbHourglass
    Open strImportFileName For Input As #1             ' Open file.
    Do While Not EOF(1)                                     ' Loop until end of file.
        Line Input #1, strReadLine                          ' Read line into variable.
        strSKU = Left(strReadLine, InStr(strReadLine, ",") - 1)
        strSQL = "SKU = '" & strSKU & "'"
        Call PromptStatusBar(frmMain.statMain, "Converting SKU#" & strSKU)
        With myTarget
            .FindFirst strSQL
            If .NoMatch Then
                .AddNew
                !HeaderID = dtcSTHeader.Recordset!ID
                !SKU = strSKU
                !Qty = 1
                .Update
            Else
                .Edit
                !Qty = !Qty + 1
                .Update
            End If
        End With
    Loop

DoImportSelect_ConvertFile_Exit:                                ' SDVB autocode
    On Error Resume Next                                        ' SDVB autocode
    Close #1                                                ' Close file.
    myTarget.Close
    myDB.Close
    Screen.MousePointer = vbDefault
    Call PromptStatusBar(frmMain.statMain, pyUserName)
    Exit Sub                                                    ' SDVB autocode
DoImportSelect_ConvertFile_Err:                                 ' SDVB autocode
    Call ofx_GenericError("Bad data in " & strImportFileName, Err)  ' SDVB autocode
    Resume DoImportSelect_ConvertFile_Exit
End Sub

Private Sub DoImportSelect_VerifyImportTable()
    On Error GoTo DoImportSelect_VerifyImportTable_Err

    Dim strSQL As String
    Dim myDB As Database
    Dim myTarget, myImportFile As Recordset
    
    Screen.MousePointer = vbHourglass
    strSQL = "SELECT * FROM InvtSTImport WHERE HeaderID = " & dtcSTHeader.Recordset.ID
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                           ' Open database
    Set myImportFile = myDB.OpenRecordset(strSQL, dbOpenDynaset)
    
    ' Verify with Inventory Table
    Set myTarget = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)
    With myImportFile
        Call PromptStatusBar(frmMain.statMain, "Verifying SKU " & !SKU & " with BOOK")
        .MoveFirst
        Do While Not .EOF
            strSQL = "SKU ='" & !SKU & "'"
            myTarget.FindFirst strSQL
            .Edit
            If myTarget.NoMatch Then
                !Status = 1             ' No Such SKU
            Else
                !Status = 0             ' Good
            End If
            .Update
            .MoveNext
        Loop
    End With
    
    ' Verify with InvtSTDetails Table
    strSQL = "SELECT * FROM InvtSTDetails WHERE HeaderID =" & dtcSTHeader.Recordset!ID
    Set myTarget = myDB.OpenRecordset(strSQL, dbOpenDynaset, dbReadOnly)
    With myImportFile
        .MoveFirst
        Do While Not .EOF
            Call PromptStatusBar(frmMain.statMain, "Verifying SKU " & !SKU & " with Worksheet")
            If !Status = 0 Then             ' Ignor Status = 1 records
                strSQL = "SKU ='" & !SKU & "'"
                myTarget.FindFirst strSQL
                If myTarget.NoMatch Then
                    .Edit
                    !Status = 2             ' Worksheet Not Include Such SKU
                    .Update
                End If
            End If
            .MoveNext
        Loop
    End With
    
    myTarget.Close
    myImportFile.Close
    myDB.Close
    Screen.MousePointer = vbDefault
    Call PromptStatusBar(frmMain.statMain, "")

DoImportSelect_VerifyImportTable_Exit:                                ' SDVB autocode
    On Error Resume Next                                              ' SDVB autocode
    Exit Sub                                                          ' SDVB autocode
DoImportSelect_VerifyImportTable_Err:                                 ' SDVB autocode
    Call ofx_GenericError("DoImportSelect_VerifyImportTable()", Err)  ' SDVB autocode
    Resume DoImportSelect_VerifyImportTable_Exit
End Sub

Private Sub DoImportSelect_PrintErrorReport()
    On Error GoTo DoImportSelect_PrintErrorReport_Err

    Dim strSQL As String
    Dim myDB As Database
    Dim myImportFile As Recordset
    
    strSQL = "SELECT * FROM InvtSTImport " & _
             "WHERE HeaderID = " & dtcSTHeader.Recordset!ID & _
                  " And Status <> 0"
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                           ' Open database
    Set myImportFile = myDB.OpenRecordset(strSQL, dbOpenDynaset)
    
    If Not IsEmpty(myImportFile) Then Call PrintSTImportError(1, dtcSTHeader.Recordset!ID)

DoImportSelect_PrintErrorReport_Exit:                                ' SDVB autocode
    On Error Resume Next                                             ' SDVB autocode
    myImportFile.Close
    myDB.Close

    Exit Sub                                                         ' SDVB autocode
DoImportSelect_PrintErrorReport_Err:                                 ' SDVB autocode
    Call ofx_GenericError("DoImportSelect_PrintErrorReport()", Err)  ' SDVB autocode
    Resume DoImportSelect_PrintErrorReport_Exit
End Sub

' Clear the Import Table for those records with the same HeaderID
Private Sub DoImportSelect_ClearImportTable()
    Dim myDB As Database
    Dim myImportFile As Recordset
    Dim strSQL As String
    
    Screen.MousePointer = vbHourglass
    strSQL = "SELECT * FROM InvtSTImport WHERE HeaderID = " & dtcSTHeader.Recordset.ID
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                           ' Open database
    Set myImportFile = myDB.OpenRecordset(strSQL, dbOpenDynaset)
    
    If Not IsTableEmpty(myImportFile) Then
        Call PromptStatusBar(frmMain.statMain, "Clearing import file#" & dtcSTHeader.Recordset.ID)
        With myImportFile
            .MoveFirst
            Do While Not .EOF
                .Delete
                .MoveNext
            Loop
        End With
    End If
    
    myImportFile.Close
    myDB.Close
    ' Disable Import Menu Buttons
    cmdImportPrint.Enabled = False
    cmdImportWrite.Enabled = False
    '
    Screen.MousePointer = vbDefault
'    Call PromptStatusBar(frmMain.statMain, pyUserName)
End Sub


Private Sub UpdateHeaderStatus(intMode)
    With dtcSTHeader.Recordset
        If !Status = 3 Or !Status = 4 Then
            ' Do nothing
        Else
            .Edit
            Select Case intMode
            Case mModeEdit
                !Status = 1
            Case mModePrint
                !Status = 2
            Case mModeUpdate
                !Status = 3
            Case mModeDelete
                !Status = 4
            End Select
            .Update
        End If
    End With
End Sub

Private Sub ButtonsAllUp()
    Dim i As Integer
    For i = 0 To (tbrStockTake.ToolsetTools.Count - 1)
        If tbrStockTake.Buttons(i).Value Then
            tbrStockTake.Buttons(i).Value = False
        End If
    Next i
End Sub

'------------------------------
' Procedure:  PopFraAddSKU
' Purpose:    Enable & Bring FraAddSKU to front
' Params:
' Returns:    N/A
'------------------------------
Private Sub PopFraAddSKU()
    On Error GoTo PopFraAddSKU_Err

    With fraAddSKU
        .Visible = True
        .Enabled = True
        .ZOrder 0   ' Bring to front
    End With
    
PopFraAddSKU_Exit:                                ' SDVB autocode
    On Error Resume Next                          ' SDVB autocode
    Exit Sub                                      ' SDVB autocode
PopFraAddSKU_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PopFraAddSKU()", Err)  ' SDVB autocode
    Resume PopFraAddSKU_Exit
End Sub

'------------------------------
' Procedure:  HideFraAddSKU
' Purpose:    TBD
' Params:
' Returns:    N/A
'------------------------------
Private Sub HideFraAddSKU()
    On Error GoTo HideFraAddSKU_Err

    With fraAddSKU
        .Visible = False
        .Enabled = False
        .ZOrder 1   ' Send to back
    End With

HideFraAddSKU_Exit:                                ' SDVB autocode
    On Error Resume Next                           ' SDVB autocode
    Exit Sub                                       ' SDVB autocode
HideFraAddSKU_Err:                                 ' SDVB autocode
    Call ofx_GenericError("HideFraAddSKU()", Err)  ' SDVB autocode
    Resume HideFraAddSKU_Exit
End Sub

'------------------------------
' Procedure:  ToggleMenuButton
' Purpose:
' Params:
' Returns:    N/A
'------------------------------
Private Sub ToggleMenuButton(intButtonIndex As Integer)
    On Error GoTo ToggleMenuButton_Err

    With tbrStockTake.Buttons(intButtonIndex)
        If .Value = False Then
            .Value = True
        Else
            .Value = False
        End If
    End With
    
ToggleMenuButton_Exit:                                ' SDVB autocode
    On Error Resume Next                              ' SDVB autocode
    Exit Sub                                          ' SDVB autocode
ToggleMenuButton_Err:                                 ' SDVB autocode
    Call ofx_GenericError("ToggleMenuButton()", Err)  ' SDVB autocode
    Resume ToggleMenuButton_Exit
End Sub


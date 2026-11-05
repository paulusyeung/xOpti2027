VERSION 5.00
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmOrderDetails_Lens 
   Caption         =   "Order Details - Lens"
   ClientHeight    =   4230
   ClientLeft      =   2895
   ClientTop       =   3780
   ClientWidth     =   8175
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4230
   ScaleWidth      =   8175
   Begin VB.Data dtcTxSOrderLens 
      Caption         =   "TxSOrderLens"
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
      RecordSource    =   "TxSOrderLens"
      Top             =   2220
      Visible         =   0   'False
      Width           =   1140
   End
   Begin Threed.SSFrame fraPrescription 
      Height          =   1755
      Left            =   120
      TabIndex        =   0
      Top             =   60
      Width           =   6975
      _ExtentX        =   12303
      _ExtentY        =   3096
      _Version        =   131074
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
      Caption         =   "Prescription"
      Begin VB.Data dtcDoctor 
         Caption         =   "Doctor"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   315
         Left            =   5640
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT ID, DoctorName FROM Doctor ORDER BY DoctorName"
         Top             =   180
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.TextBox txtLeftAdd 
         DataField       =   "LeftAdd"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   5280
         TabIndex        =   28
         Text            =   "Text14"
         Top             =   1320
         Width           =   495
      End
      Begin VB.TextBox txtLeftPrism 
         DataField       =   "LeftPrism"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   4680
         TabIndex        =   27
         Text            =   "Text13"
         Top             =   1320
         Width           =   615
      End
      Begin VB.TextBox txtLeftPdNear 
         DataField       =   "LeftPdNear"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   3840
         TabIndex        =   26
         Text            =   "Text12"
         Top             =   1320
         Width           =   855
      End
      Begin VB.TextBox txtLeftPdDist 
         DataField       =   "LeftPdDist"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   3000
         TabIndex        =   25
         Text            =   "Text11"
         Top             =   1320
         Width           =   855
      End
      Begin VB.TextBox txtLeftAxis 
         DataField       =   "LeftAxis"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   2520
         TabIndex        =   24
         Text            =   "Text10"
         Top             =   1320
         Width           =   495
      End
      Begin VB.TextBox txtLeftCylinder 
         DataField       =   "LeftCylinder"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   1680
         TabIndex        =   23
         Text            =   "Text9"
         Top             =   1320
         Width           =   855
      End
      Begin VB.TextBox txtLeftSphere 
         DataField       =   "LeftSphere"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   960
         TabIndex        =   22
         Text            =   "Text8"
         Top             =   1320
         Width           =   735
      End
      Begin VB.TextBox txtRightAdd 
         DataField       =   "RightAdd"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   5280
         TabIndex        =   21
         Text            =   "Text7"
         Top             =   1020
         Width           =   495
      End
      Begin VB.TextBox txtRightPrism 
         DataField       =   "RightPrism"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   4680
         TabIndex        =   20
         Text            =   "Text6"
         Top             =   1020
         Width           =   615
      End
      Begin VB.TextBox txtRightPdNear 
         DataField       =   "RightPdNear"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   3840
         TabIndex        =   19
         Text            =   "Text5"
         Top             =   1020
         Width           =   855
      End
      Begin VB.TextBox txtRightPdDist 
         DataField       =   "RightPdDist"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   3000
         TabIndex        =   18
         Text            =   "Text4"
         Top             =   1020
         Width           =   855
      End
      Begin VB.TextBox txtRightAxis 
         DataField       =   "RightAxis"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   2520
         TabIndex        =   17
         Text            =   "Text3"
         Top             =   1020
         Width           =   495
      End
      Begin VB.TextBox txtRightCylinder 
         DataField       =   "RightCylinder"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   1680
         TabIndex        =   16
         Text            =   "Text2"
         Top             =   1020
         Width           =   855
      End
      Begin VB.TextBox txtRightSphere 
         DataField       =   "RightSphere"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   960
         TabIndex        =   15
         Text            =   "Text1"
         Top             =   1020
         Width           =   735
      End
      Begin MSDBCtls.DBCombo dbcDoctor 
         Bindings        =   "frmOrderDetails_Lens.frx":0000
         DataField       =   "IssuedBy"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   315
         Left            =   4680
         TabIndex        =   14
         Top             =   300
         Width           =   2175
         _ExtentX        =   3836
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "DoctorName"
         BoundColumn     =   "ID"
         Text            =   ""
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
      Begin SSCalendarWidgets_A.SSDateCombo calIssuedOn 
         DataField       =   "IssuedOn"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   315
         Left            =   960
         TabIndex        =   13
         Top             =   300
         Width           =   2055
         _Version        =   65543
         _ExtentX        =   3625
         _ExtentY        =   556
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
         ShowCentury     =   -1  'True
      End
      Begin VB.Label Label11 
         Caption         =   "L"
         Height          =   195
         Left            =   720
         TabIndex        =   12
         Top             =   1320
         Width           =   135
      End
      Begin VB.Label Label10 
         Caption         =   "R"
         Height          =   255
         Left            =   720
         TabIndex        =   11
         Top             =   1020
         Width           =   135
      End
      Begin VB.Label Label9 
         Caption         =   "Add"
         Height          =   255
         Left            =   5400
         TabIndex        =   10
         Top             =   780
         Width           =   375
      End
      Begin VB.Label Label8 
         Caption         =   "Prism"
         Height          =   255
         Left            =   4800
         TabIndex        =   9
         Top             =   780
         Width           =   495
      End
      Begin VB.Label Label7 
         Caption         =   "PD Near"
         Height          =   255
         Left            =   3960
         TabIndex        =   8
         Top             =   780
         Width           =   735
      End
      Begin VB.Label Label6 
         Caption         =   "PD Dist"
         Height          =   255
         Left            =   3120
         TabIndex        =   7
         Top             =   780
         Width           =   615
      End
      Begin VB.Label Label5 
         Caption         =   "Axis"
         Height          =   255
         Left            =   2640
         TabIndex        =   6
         Top             =   780
         Width           =   375
      End
      Begin VB.Label Label4 
         Caption         =   "Cylinder"
         Height          =   255
         Left            =   1800
         TabIndex        =   5
         Top             =   780
         Width           =   615
      End
      Begin VB.Label Label3 
         Caption         =   "Sphere"
         Height          =   255
         Left            =   1080
         TabIndex        =   4
         Top             =   780
         Width           =   615
      End
      Begin VB.Label Label2 
         Caption         =   "Issued by Doctor"
         Height          =   255
         Left            =   3360
         TabIndex        =   3
         Top             =   300
         Width           =   1335
      End
      Begin VB.Label Label1 
         Caption         =   "Issued on"
         Height          =   255
         Left            =   120
         TabIndex        =   2
         Top             =   300
         Width           =   855
      End
   End
   Begin Threed.SSFrame fraNotes 
      Height          =   2235
      Left            =   120
      TabIndex        =   1
      Top             =   1860
      Width           =   6975
      _ExtentX        =   12303
      _ExtentY        =   3942
      _Version        =   131074
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
      Caption         =   "Notes"
      Begin VB.Data dtcHardening 
         Caption         =   "Hardening"
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
         RecordSource    =   "SELECT * FROM Hardening ORDER BY Name"
         Top             =   1440
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcMaterial 
         Caption         =   "Material"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   315
         Left            =   1800
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT * FROM Material ORDER BY MaterialDescription"
         Top             =   1800
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcAdd 
         Caption         =   "Add"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   4440
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT * FROM Add ORDER BY AddDescription"
         Top             =   1080
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcCategory 
         Caption         =   "Category"
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
         RecordSource    =   "SELECT DISTINCT CategoryCode, CategoryName FROM Category ORDER BY CategoryName"
         Top             =   1080
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.TextBox txtOthers 
         DataField       =   "Others"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   3720
         TabIndex        =   60
         Text            =   "Text26"
         Top             =   1800
         Width           =   1575
      End
      Begin VB.TextBox txtTint 
         DataField       =   "Tint"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   3720
         TabIndex        =   59
         Text            =   "Text25"
         Top             =   1440
         Width           =   1575
      End
      Begin VB.CheckBox chkUV 
         Caption         =   "UV"
         DataField       =   "UV"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   255
         Left            =   5640
         TabIndex        =   54
         Top             =   1620
         Width           =   735
      End
      Begin VB.CheckBox chkARCoat 
         Caption         =   "AR Coat"
         DataField       =   "ARCoat"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   255
         Left            =   5640
         TabIndex        =   53
         Top             =   1320
         Width           =   1095
      End
      Begin VB.CheckBox chkHardCoat 
         Caption         =   "Hard Coat"
         DataField       =   "HardCoat"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   195
         Left            =   5640
         TabIndex        =   52
         Top             =   1080
         Width           =   1095
      End
      Begin VB.TextBox txtLeftVD 
         DataField       =   "LeftVD"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   4920
         TabIndex        =   45
         Text            =   "Text24"
         Top             =   720
         Width           =   1095
      End
      Begin VB.TextBox txtLeftBase 
         DataField       =   "LeftBase"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   4200
         TabIndex        =   44
         Text            =   "Text23"
         Top             =   720
         Width           =   735
      End
      Begin VB.TextBox txtLeftOC 
         DataField       =   "LeftOC"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   3480
         TabIndex        =   43
         Text            =   "Text22"
         Top             =   720
         Width           =   735
      End
      Begin VB.TextBox txtLeftSegHt 
         DataField       =   "LeftSegHt"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   2760
         TabIndex        =   42
         Text            =   "Text21"
         Top             =   720
         Width           =   735
      End
      Begin VB.TextBox txtLeftStyle 
         DataField       =   "LeftStyle"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   960
         TabIndex        =   41
         Text            =   "Text20"
         Top             =   720
         Width           =   1815
      End
      Begin VB.TextBox txtRightVD 
         DataField       =   "RightVD"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   4920
         TabIndex        =   40
         Text            =   "Text19"
         Top             =   420
         Width           =   1095
      End
      Begin VB.TextBox txtRightBase 
         DataField       =   "RigthBase"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   4200
         TabIndex        =   39
         Text            =   "Text18"
         Top             =   420
         Width           =   735
      End
      Begin VB.TextBox txtRightOC 
         DataField       =   "RigthOC"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   3480
         TabIndex        =   38
         Text            =   "Text17"
         Top             =   420
         Width           =   735
      End
      Begin VB.TextBox txtRightSegHt 
         DataField       =   "RightSegHt"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   2760
         TabIndex        =   37
         Text            =   "Text16"
         Top             =   420
         Width           =   735
      End
      Begin VB.TextBox txtRightStyle 
         DataField       =   "RightStyle"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   285
         Left            =   960
         TabIndex        =   36
         Text            =   "Text15"
         Top             =   420
         Width           =   1815
      End
      Begin MSDBCtls.DBCombo dbcCosting 
         Bindings        =   "frmOrderDetails_Lens.frx":0018
         DataField       =   "Coating"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   315
         Left            =   3720
         TabIndex        =   58
         Top             =   1080
         Width           =   1575
         _ExtentX        =   2778
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "AddDescription"
         BoundColumn     =   "AddCode"
         Text            =   "dbcCosting"
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
      Begin MSDBCtls.DBCombo dbcMaterial 
         Bindings        =   "frmOrderDetails_Lens.frx":002D
         DataField       =   "Material"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   315
         Left            =   960
         TabIndex        =   57
         Top             =   1800
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "MaterialDescription"
         BoundColumn     =   "MaterialCode"
         Text            =   "dbcMaterial"
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
      Begin MSDBCtls.DBCombo dbcHardening 
         Bindings        =   "frmOrderDetails_Lens.frx":0047
         DataField       =   "Hardening"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   315
         Left            =   960
         TabIndex        =   56
         Top             =   1440
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "Name"
         BoundColumn     =   "Name"
         Text            =   "dbcHardening"
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
      Begin MSDBCtls.DBCombo dbcType 
         Bindings        =   "frmOrderDetails_Lens.frx":0062
         DataField       =   "Type"
         DataSource      =   "dtcTxSOrderLens"
         Height          =   315
         Left            =   960
         TabIndex        =   55
         Top             =   1080
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "CategoryName"
         BoundColumn     =   "CategoryName"
         Text            =   "dbcType"
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
      Begin VB.Label Label24 
         Caption         =   "Others"
         Height          =   255
         Left            =   3000
         TabIndex        =   51
         Top             =   1800
         Width           =   615
      End
      Begin VB.Label Label23 
         Caption         =   "Tint"
         Height          =   195
         Left            =   3000
         TabIndex        =   50
         Top             =   1440
         Width           =   375
      End
      Begin VB.Label Label22 
         Caption         =   "Coating"
         Height          =   255
         Left            =   3000
         TabIndex        =   49
         Top             =   1080
         Width           =   615
      End
      Begin VB.Label Label21 
         Caption         =   "Material"
         Height          =   195
         Left            =   120
         TabIndex        =   48
         Top             =   1800
         Width           =   735
      End
      Begin VB.Label Label20 
         Caption         =   "Hardening"
         Height          =   255
         Left            =   120
         TabIndex        =   47
         Top             =   1440
         Width           =   855
      End
      Begin VB.Label Label19 
         Caption         =   "Type"
         Height          =   255
         Left            =   120
         TabIndex        =   46
         Top             =   1080
         Width           =   495
      End
      Begin VB.Label Label18 
         Caption         =   "L"
         Height          =   255
         Left            =   720
         TabIndex        =   35
         Top             =   720
         Width           =   135
      End
      Begin VB.Label Label17 
         Caption         =   "R"
         Height          =   255
         Left            =   720
         TabIndex        =   34
         Top             =   420
         Width           =   135
      End
      Begin VB.Label Label16 
         Caption         =   "Vertex Dist"
         Height          =   255
         Left            =   5040
         TabIndex        =   33
         Top             =   180
         Width           =   855
      End
      Begin VB.Label Label15 
         Caption         =   "Base"
         Height          =   255
         Left            =   4320
         TabIndex        =   32
         Top             =   180
         Width           =   495
      End
      Begin VB.Label Label14 
         Caption         =   "OC"
         Height          =   255
         Left            =   3720
         TabIndex        =   31
         Top             =   180
         Width           =   375
      End
      Begin VB.Label Label13 
         Caption         =   "Seg ht"
         Height          =   255
         Left            =   2880
         TabIndex        =   30
         Top             =   180
         Width           =   615
      End
      Begin VB.Label Label12 
         Caption         =   "Lens Style"
         Height          =   255
         Left            =   1440
         TabIndex        =   29
         Top             =   180
         Width           =   855
      End
   End
   Begin Threed.SSCommand cmdRefresh 
      Height          =   375
      Left            =   7200
      TabIndex        =   61
      Top             =   120
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
      Caption         =   "Refresh"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdStore 
      Height          =   375
      Left            =   7200
      TabIndex        =   65
      Top             =   2040
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   661
      _Version        =   131074
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
      Caption         =   "Store"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdRetrieve 
      Height          =   375
      Left            =   7200
      TabIndex        =   64
      Top             =   1560
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   661
      _Version        =   131074
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
      Caption         =   "Retrieve"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdCancel 
      Height          =   375
      Left            =   7200
      TabIndex        =   63
      Top             =   1080
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   661
      _Version        =   131074
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
      Caption         =   "Cancel"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdOK 
      Height          =   375
      Left            =   7200
      TabIndex        =   62
      Top             =   600
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   661
      _Version        =   131074
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
      Caption         =   "OK"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmOrderDetails_Lens"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim mTxNumber As String
Dim mLineNumber As Long
Dim mCustomerName As String
Dim mCustomerID As Long

Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdOK_Click()
    Call StorePrescription
    Unload Me
End Sub

Private Sub cmdRefresh_Click()
    Call GetSOrderHeader
    Call OpenAsWhat
'    Call GetSOrderDetails

    fraPrescription.Enabled = True
    fraNotes.Enabled = True

    cmdOK.Enabled = True
    cmdCancel.Enabled = True
    cmdRetrieve.Enabled = True
    cmdStore.Enabled = True
End Sub


Private Sub cmdRetrieve_Click()
    Call RetrievePrescription
End Sub

Private Sub cmdStore_Click()
    Call StorePrescription
End Sub


Private Sub Form_Load()
    Call ofx_RestoreFormPosition(Me, True)
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call ofx_SaveFormPosition(Me)
End Sub








Private Sub GetSOrderHeader()
    mTxNumber = "SA" + ofx_CStr(frmSalesOrder.mskOrderNumber.Text)
'    mLineNumber = ofx_CSng(frmSalesOrder.tdbgTxBody.Columns(0))
    mLineNumber = 0     ' Use one record per SOrder
    mCustomerName = ofx_CStr(frmSalesOrder.txtCustomerName.Text)
    mCustomerID = ofx_CLng(frmSalesOrder.txtCustomerName.Tag)
'    mCustomerID = ofx_CLng(varTmp)
End Sub



Private Sub RetrievePrescription()
    Dim strSQL As String
    Dim myDB As Database
    Dim myRS As Recordset
    
    Screen.MousePointer = vbHourglass
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")
    Set myRS = myDB.OpenRecordset("CustomerPresLens", dbOpenDynaset, dbReadOnly)

    strSQL = "CustomerID = " & mCustomerID
    myRS.FindFirst strSQL
    If Not myRS.NoMatch Then
        With myRS
            If Not IsNull(!IssuedOn) Then calIssuedOn = Format(!IssuedOn, "MM/DD/YYYY")
            If Not IsNull(!IssuedByDr) Then dbcDoctor.BoundText = !IssuedByDr
            If Not IsNull(!RightSphere) Then txtRightSphere = !RightSphere
            If Not IsNull(!RightCylinder) Then txtRightCylinder = !RightCylinder
            If Not IsNull(!RightAxis) Then txtRightAxis = !RightAxis
            If Not IsNull(!RightPdDist) Then txtRightPdDist = !RightPdDist
            If Not IsNull(!RightPdNear) Then txtRightPdNear = !RightPdNear
            If Not IsNull(!RightPrism) Then txtRightPrism = !RightPrism
            If Not IsNull(!RightAdd) Then txtRightAdd = !RightAdd
            If Not IsNull(!LeftSphere) Then txtLeftSphere = !LeftSphere
            If Not IsNull(!LeftCylinder) Then txtLeftCylinder = !LeftCylinder
            If Not IsNull(!LeftAxis) Then txtLeftAxis = !LeftAxis
            If Not IsNull(!LeftPdDist) Then txtLeftPdDist = !LeftPdDist
            If Not IsNull(!LeftPdNear) Then txtLeftPdNear = !LeftPdNear
            If Not IsNull(!LeftPrism) Then txtLeftPrism = !LeftPrism
            If Not IsNull(!LeftAdd) Then txtLeftAdd = !LeftAdd
        End With
    Else
        MsgBox "Customer " & mCustomerName & " doesn't has Prescription Record"
    End If
    myRS.Close
    myDB.Close
    Screen.MousePointer = vbDefault
End Sub

Private Sub SaveLensData()
    With dtcTxSOrderLens
        If .EditMode = dbEditInProgress Or _
           .EditMode = dbEditAdd Then
            .UpdateRecord
        End If
    End With
End Sub

Private Sub StorePrescription()
    Dim strSQL As String
    Dim myDB As Database
    Dim myRS As Recordset
    
    Screen.MousePointer = vbHourglass
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")
    Set myRS = myDB.OpenRecordset("CustomerPresLens", dbOpenDynaset, dbDenyWrite)

    strSQL = "CustomerID = " & mCustomerID
    myRS.FindFirst strSQL
    
    With myRS
        If .NoMatch Then
            .AddNew
            !CustomerID = mCustomerID
        Else
            .Edit
        End If
            If IsDate(!IssuedOn) Then !IssuedOn = calIssuedOn.Text
            If Not IsNull(dbcDoctor) Then !IssuedByDr = ofx_CLng(dbcDoctor.BoundText)
            If Not IsNull(txtRightSphere) Then !RightSphere = txtRightSphere
            If Not IsNull(txtRightCylinder) Then !RightCylinder = txtRightCylinder
            If Not IsNull(txtRightAxis) Then !RightAxis = txtRightAxis
            If Not IsNull(txtRightPdDist) Then !RightPdDist = txtRightPdDist
            If Not IsNull(txtRightPdNear) Then !RightPdNear = txtRightPdNear
            If Not IsNull(txtRightPrism) Then !RightPrism = txtRightPrism
            If Not IsNull(txtRightAdd) Then !RightAdd = txtRightAdd
'            !RightPupil = txtRightPupil
            If Not IsNull(txtLeftSphere) Then !LeftSphere = txtLeftSphere
            If Not IsNull(txtLeftCylinder) Then !LeftCylinder = txtLeftCylinder
            If Not IsNull(txtLeftAxis) Then !LeftAxis = txtLeftAxis
            If Not IsNull(txtLeftPdDist) Then !LeftPdDist = txtLeftPdDist
            If Not IsNull(txtLeftPdNear) Then !LeftPdNear = txtLeftPdNear
            If Not IsNull(txtLeftPrism) Then !LeftPrism = txtLeftPrism
            If Not IsNull(txtLeftAdd) Then !LeftAdd = txtLeftAdd
'            !LeftPupil = txtLeftPupil
        .Update
    End With
    myRS.Close
    myDB.Close
    Screen.MousePointer = vbDefault
End Sub

Private Sub OpenAsWhat()
    Dim strSQL As String
    
    strSQL = "TxNumber ='" & mTxNumber & "' And " & _
             "LineNumber = " & mLineNumber
    With dtcTxSOrderLens.Recordset
        .FindFirst strSQL
        If .NoMatch Then
            .AddNew
            .TxNumber = mTxNumber
            .LineNumber = mLineNumber
            .Update
            .Bookmark = .LastModified
        End If
        dtcTxSOrderLens.UpdateControls
        .Edit
    End With
End Sub

Private Sub txtLeftAdd_Change()
    If Not myIsDecimal(txtLeftAdd, 2, True) Or _
       Not WithinRange(txtLeftAdd, 9999.99, 0, True) Then
        txtLeftAdd.SetFocus
    End If
End Sub

Private Sub txtLeftAdd_GotFocus()
   Call AutoSelect(txtLeftAdd)
End Sub


Private Sub txtLeftAdd_LostFocus()
    If Not myIsDecimal(txtLeftAdd, 2, True) Or _
       Not WithinRange(txtLeftAdd, 9999.99, 0, True) Then
        txtLeftAdd.SetFocus
    End If
End Sub

Private Sub txtLeftAxis_Change()
    If Not myIsDecimal(txtLeftAxis, 0, True) Or _
       Not WithinRange(txtLeftAxis, 180, 0, True) Then
        txtLeftAxis.SetFocus
    End If
End Sub

Private Sub txtLeftAxis_GotFocus()
   Call AutoSelect(txtLeftAxis)
End Sub


Private Sub txtLeftAxis_LostFocus()
    If Not myIsDecimal(txtLeftAxis, 0, True) Or _
       Not WithinRange(txtLeftAxis, 180, 0, True) Then
        txtLeftAxis.SetFocus
    End If
End Sub

Private Sub txtLeftCylinder_Change()
    If Not myIsDecimal(txtLeftCylinder, 2, True) Or _
       Not WithinRange(txtLeftCylinder, 0, -6, True) Then
        txtLeftCylinder.SetFocus
    End If
End Sub

Private Sub txtLeftCylinder_GotFocus()
    Call AutoSelect(txtLeftCylinder)

End Sub


Private Sub txtLeftCylinder_LostFocus()
    If Not myIsDecimal(txtLeftCylinder, 2, True) Or _
       Not WithinRange(txtLeftCylinder, 0, -6, True) Then
        txtLeftCylinder.SetFocus
    End If
End Sub

Private Sub txtLeftPdDist_Change()
    If Not myIsDecimal(txtLeftPdDist, 2, True) Or _
       Not WithinRange(txtLeftPdDist, 99.99, 0, True) Then
        txtLeftPdDist.SetFocus
    End If
End Sub

Private Sub txtLeftPdDist_GotFocus()
   Call AutoSelect(txtLeftPdDist)
End Sub


Private Sub txtLeftPdDist_LostFocus()
    If Not myIsDecimal(txtLeftPdDist, 2, True) Or _
       Not WithinRange(txtLeftPdDist, 99.99, 0, True) Then
        txtLeftPdDist.SetFocus
    End If
End Sub

Private Sub txtLeftPdNear_Change()
    If Not myIsDecimal(txtLeftPdNear, 2, True) Or _
       Not WithinRange(txtLeftPdNear, 99.99, 0, True) Then
        txtLeftPdNear.SetFocus
    End If
End Sub

Private Sub txtLeftPdNear_GotFocus()
   Call AutoSelect(txtLeftPdNear)
End Sub


Private Sub txtLeftPdNear_LostFocus()
    If Not myIsDecimal(txtLeftPdNear, 2, True) Or _
       Not WithinRange(txtLeftPdNear, 99.99, 0, True) Then
        txtLeftPdNear.SetFocus
    End If
End Sub

Private Sub txtLeftPrism_Change()
    If Not myIsDecimal(txtLeftPrism, 1, True) Or _
       Not WithinRange(txtLeftPrism, 10, 0, True) Then
        txtLeftPrism.SetFocus
    End If
End Sub

Private Sub txtLeftPrism_GotFocus()
   Call AutoSelect(txtLeftPrism)
End Sub


Private Sub txtLeftPrism_LostFocus()
    If Not myIsDecimal(txtLeftPrism, 1, True) Or _
       Not WithinRange(txtLeftPrism, 10, 0, True) Then
        txtLeftPrism.SetFocus
    End If
End Sub

Private Sub txtLeftSphere_Change()
    If Not myIsDecimal(txtLeftSphere, 2, True) Or _
       Not WithinRange(txtLeftSphere, 20, -20, True) Then
        txtLeftSphere.SetFocus
    End If
End Sub

Private Sub txtLeftSphere_GotFocus()
    Call AutoSelect(txtLeftSphere)

End Sub


Private Sub txtLeftSphere_LostFocus()
    If Not myIsDecimal(txtLeftSphere, 2, True) Or _
       Not WithinRange(txtLeftSphere, 20, -20, True) Then
        txtLeftSphere.SetFocus
    End If
End Sub


Private Sub txtRightAdd_Change()
    If Not myIsDecimal(txtRightAdd, 2, True) Or _
       Not WithinRange(txtRightAdd, 9999.99, 0, True) Then
        txtRightAdd.SetFocus
    End If
End Sub

Private Sub txtRightAdd_GotFocus()
   Call AutoSelect(txtRightAdd)
End Sub


Private Sub txtRightAdd_LostFocus()
    If Not myIsDecimal(txtRightAdd, 2, True) Or _
       Not WithinRange(txtRightAdd, 9999.99, 0, True) Then
        txtRightAdd.SetFocus
    End If
End Sub

Private Sub txtRightAxis_Change()
    If Not myIsDecimal(txtRightAxis, 0, True) Or _
       Not WithinRange(txtRightAxis, 180, 0, True) Then
        txtRightAxis.SetFocus
    End If
End Sub

Private Sub txtRightAxis_GotFocus()
    Call AutoSelect(txtRightAxis)
End Sub


Private Sub txtRightAxis_LostFocus()
    If Not myIsDecimal(txtRightAxis, 0, True) Or _
       Not WithinRange(txtRightAxis, 180, 0, True) Then
        txtRightAxis.SetFocus
    End If
End Sub

Private Sub txtRightCylinder_Change()
    If Not myIsDecimal(txtRightCylinder, 2, True) Or _
       Not WithinRange(txtRightCylinder, 0, -6, True) Then
        txtRightCylinder.SetFocus
    End If
End Sub

Private Sub txtRightCylinder_GotFocus()
    Call AutoSelect(txtRightCylinder)

End Sub


Private Sub txtRightCylinder_LostFocus()
    If Not myIsDecimal(txtRightCylinder, 2, True) Or _
       Not WithinRange(txtRightCylinder, 0, -6, True) Then
        txtRightCylinder.SetFocus
    End If
End Sub

Private Sub txtRightPdDist_Change()
    If Not myIsDecimal(txtRightPdDist, 2, True) Or _
       Not WithinRange(txtRightPdDist, 99.99, 0, True) Then
        txtRightPdDist.SetFocus
    End If
End Sub

Private Sub txtRightPdDist_GotFocus()
   Call AutoSelect(txtRightPdDist)
End Sub


Private Sub txtRightPdDist_LostFocus()
    If Not myIsDecimal(txtRightPdDist, 2, True) Or _
       Not WithinRange(txtRightPdDist, 99.99, 0, True) Then
        txtRightPdDist.SetFocus
    End If
End Sub

Private Sub txtRightPdNear_Change()
    If Not myIsDecimal(txtRightPdNear, 2, True) Or _
       Not WithinRange(txtRightPdNear, 99.99, 0, True) Then
        txtRightPdNear.SetFocus
    End If
End Sub

Private Sub txtRightPdNear_GotFocus()
   Call AutoSelect(txtRightPdNear)
End Sub


Private Sub txtRightPdNear_LostFocus()
    If Not myIsDecimal(txtRightPdNear, 2, True) Or _
       Not WithinRange(txtRightPdNear, 99.99, 0, True) Then
        txtRightPdNear.SetFocus
    End If
End Sub

Private Sub txtRightPrism_Change()
    If Not myIsDecimal(txtRightPrism, 1, True) Or _
       Not WithinRange(txtRightPrism, 10, 0, True) Then
        txtRightPrism.SetFocus
    End If
End Sub

Private Sub txtRightPrism_GotFocus()
   Call AutoSelect(txtRightPrism)
End Sub


Private Sub txtRightPrism_LostFocus()
    If Not myIsDecimal(txtRightPrism, 1, True) Or _
       Not WithinRange(txtRightPrism, 10, 0, True) Then
        txtRightPrism.SetFocus
    End If
End Sub

Private Sub txtRightSphere_Change()
    If Not myIsDecimal(txtRightSphere, 2, True) Or _
       Not WithinRange(txtRightSphere, 20, -20, True) Then
        txtRightSphere.SetFocus
    End If
End Sub


Private Sub txtRightSphere_GotFocus()
    Call AutoSelect(txtRightSphere)

End Sub


Private Sub txtRightSphere_LostFocus()
    If Not myIsDecimal(txtRightSphere, 2, True) Or _
       Not WithinRange(txtRightSphere, 20, -20, True) Then
        txtRightSphere.SetFocus
    End If
End Sub



VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{B074BC93-5A5B-11CE-98BD-0000C0E6B88E}#2.0#0"; "sstabs32.ocx"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmInfoSupplier 
   Caption         =   "Supplier Information"
   ClientHeight    =   7425
   ClientLeft      =   165
   ClientTop       =   1035
   ClientWidth     =   11670
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   7425
   ScaleWidth      =   11670
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   11670
      _Version        =   131073
      _ExtentX        =   20585
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
      ToolsetPicture  =   "frmInfoSupplier.frx":0000
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
      ToolsetToolGroup(5)=   2
      ToolsetToolID(6)=   "ID_Exit"
      ToolsetToolHelp(6)=   "Exit Task"
      ToolsetToolMnemonic(6)=   "x"
      ToolsetToolGroup(6)=   2
      MouseIcon       =   "frmInfoSupplier.frx":A892
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   3015
      Left            =   120
      TabIndex        =   1
      Top             =   1140
      Width           =   11415
      _ExtentX        =   20135
      _ExtentY        =   5318
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
         Bindings        =   "frmInfoSupplier.frx":A8AE
         Height          =   1935
         Left            =   120
         OleObjectBlob   =   "frmInfoSupplier.frx":A8C8
         TabIndex        =   10
         Top             =   960
         Width           =   11175
      End
      Begin VB.Data dtcCityFullList 
         Caption         =   "CityFullList"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   5040
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "qryCityFullList"
         Top             =   1980
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.TextBox txtSelPhone 
         Height          =   285
         Left            =   2400
         TabIndex        =   71
         Top             =   540
         Width           =   1095
      End
      Begin VB.Data dtcSelContactPerson 
         Caption         =   "SelContactPerson"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   4200
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT SupplierCode, ContactPerson FROM Supplier WHERE ContactPerson <> """" ORDER BY ContactPerson"
         Top             =   600
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcSelSupplier 
         Caption         =   "SelSupplier"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   315
         Left            =   960
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT SupplierCode, SupplierName FROM Supplier ORDER BY SupplierName"
         Top             =   600
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcCountry 
         Caption         =   "Country"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   6120
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT * FROM Country ORDER BY CountryName"
         Top             =   600
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcProvince 
         Caption         =   "Province"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   8040
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT * FROM Province ORDER BY ProvinceName"
         Top             =   600
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcCity 
         Caption         =   "City"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   9960
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT Code, CityName, CityPhoneCode FROM City ORDER BY CityName"
         Top             =   600
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcSupplier 
         Caption         =   "Supplier"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   4680
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT * FROM Supplier ORDER BY SupplierName"
         Top             =   1560
         Visible         =   0   'False
         Width           =   1140
      End
      Begin MSDBCtls.DBCombo dbcCountry 
         Bindings        =   "frmInfoSupplier.frx":D895
         Height          =   315
         Left            =   5760
         TabIndex        =   12
         Top             =   540
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "CountryName"
         BoundColumn     =   "CountryCode"
         Text            =   ""
      End
      Begin MSDBCtls.DBCombo dbcProvince 
         Bindings        =   "frmInfoSupplier.frx":D8AE
         Height          =   315
         Left            =   7680
         TabIndex        =   9
         Top             =   540
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "ProvinceName"
         BoundColumn     =   "ProvinceCode"
         Text            =   ""
      End
      Begin MSDBCtls.DBCombo dbcCity 
         Bindings        =   "frmInfoSupplier.frx":D8C8
         Height          =   315
         Left            =   9600
         TabIndex        =   8
         Top             =   540
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "CityName"
         BoundColumn     =   "Code"
         Text            =   ""
      End
      Begin MSDBCtls.DBCombo dbcContactPerson 
         Bindings        =   "frmInfoSupplier.frx":D8DE
         Height          =   315
         Left            =   3720
         TabIndex        =   7
         Top             =   540
         Width           =   1815
         _ExtentX        =   3201
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "ContactPerson"
         BoundColumn     =   "SupplierCode"
         Text            =   ""
      End
      Begin MSDBCtls.DBCombo dbcSupplierName 
         Bindings        =   "frmInfoSupplier.frx":D900
         Height          =   315
         Left            =   120
         TabIndex        =   6
         Top             =   540
         Width           =   2055
         _ExtentX        =   3625
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "SupplierName"
         BoundColumn     =   "SupplierCode"
         Text            =   ""
      End
      Begin Threed.SSCommand cmdFindPhone 
         Height          =   345
         Left            =   3240
         TabIndex        =   72
         Top             =   240
         Width           =   345
         _ExtentX        =   609
         _ExtentY        =   609
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
         Picture         =   "frmInfoSupplier.frx":D91D
         AutoSize        =   2
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSRibbon cmdCascadeCity 
         Height          =   315
         Left            =   10920
         TabIndex        =   17
         Top             =   240
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSupplier.frx":DEC3
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSupplier.frx":E491
         GroupNumber     =   5
      End
      Begin Threed.SSRibbon cmdCascadeProvince 
         Height          =   315
         Left            =   9000
         TabIndex        =   16
         Top             =   240
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSupplier.frx":EA73
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSupplier.frx":F041
         GroupNumber     =   4
      End
      Begin Threed.SSRibbon cmdCascadeCountry 
         Height          =   315
         Left            =   7080
         TabIndex        =   15
         Top             =   240
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSupplier.frx":F623
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSupplier.frx":FBF1
         GroupNumber     =   3
      End
      Begin Threed.SSRibbon cmdCascadeContactPerson 
         Height          =   315
         Left            =   5160
         TabIndex        =   14
         Top             =   240
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSupplier.frx":101D3
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSupplier.frx":107A1
         GroupNumber     =   2
      End
      Begin Threed.SSRibbon cmdCascadeSupplier 
         Height          =   315
         Left            =   1800
         TabIndex        =   13
         Top             =   240
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmInfoSupplier.frx":10D83
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmInfoSupplier.frx":11351
      End
      Begin VB.Label Label6 
         Caption         =   "Tel. No."
         Height          =   195
         Left            =   2400
         TabIndex        =   19
         Top             =   300
         Width           =   615
      End
      Begin VB.Label Label5 
         Caption         =   "Country"
         Height          =   255
         Left            =   5760
         TabIndex        =   11
         Top             =   300
         Width           =   615
      End
      Begin VB.Label Label4 
         Caption         =   "Province"
         Height          =   255
         Left            =   7680
         TabIndex        =   5
         Top             =   300
         Width           =   735
      End
      Begin VB.Label Label3 
         Caption         =   "City"
         Height          =   255
         Left            =   9600
         TabIndex        =   4
         Top             =   300
         Width           =   375
      End
      Begin VB.Label Label2 
         Caption         =   "Contact Person"
         Height          =   255
         Left            =   3720
         TabIndex        =   3
         Top             =   300
         Width           =   1095
      End
      Begin VB.Label Label1 
         Caption         =   "Supplier Name"
         Height          =   255
         Left            =   120
         TabIndex        =   2
         Top             =   300
         Width           =   1095
      End
   End
   Begin SSDesignerWidgetsTabs.SSIndexTab SSIndexTab1 
      Height          =   3135
      Left            =   120
      TabIndex        =   18
      Top             =   4260
      Width           =   11415
      _Version        =   131078
      _ExtentX        =   20135
      _ExtentY        =   5530
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
      TabDefault      =   0
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
      Tabs(0).Pages(0).CtlCount=   2
      Tabs(0).Pages(0).CtlEnabled=   -1  'True
      Tabs(0).Pages(0).Ctl(0)=   "SSFrame3"
      Tabs(0).Pages(0).Ctl(1)=   "SSFrame2"
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
      Tabs(1).Pages(0).CtlCount=   16
      Tabs(1).Pages(0).CtlEnabled=   0   'False
      Tabs(1).Pages(0).Ctl(0)=   "Label21"
      Tabs(1).Pages(0).Ctl(1)=   "Label22"
      Tabs(1).Pages(0).Ctl(2)=   "Label23"
      Tabs(1).Pages(0).Ctl(3)=   "Label24"
      Tabs(1).Pages(0).Ctl(4)=   "Label25"
      Tabs(1).Pages(0).Ctl(5)=   "Label26"
      Tabs(1).Pages(0).Ctl(6)=   "Label27"
      Tabs(1).Pages(0).Ctl(7)=   "Label28"
      Tabs(1).Pages(0).Ctl(8)=   "MaskEdBox13"
      Tabs(1).Pages(0).Ctl(9)=   "Text8"
      Tabs(1).Pages(0).Ctl(10)=   "Text9"
      Tabs(1).Pages(0).Ctl(11)=   "Text10"
      Tabs(1).Pages(0).Ctl(12)=   "Text11"
      Tabs(1).Pages(0).Ctl(13)=   "Text12"
      Tabs(1).Pages(0).Ctl(14)=   "Text13"
      Tabs(1).Pages(0).Ctl(15)=   "MaskEdBox14"
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
      Begin MSMask.MaskEdBox MaskEdBox14 
         DataField       =   "DateStarted"
         DataSource      =   "dtcSupplier"
         Height          =   255
         Left            =   -73560
         TabIndex        =   62
         TabStop         =   0   'False
         Top             =   720
         Width           =   1575
         _ExtentX        =   2778
         _ExtentY        =   450
         _Version        =   393216
         Format          =   "dd-mmm-yy"
         PromptChar      =   "_"
      End
      Begin VB.TextBox Text13 
         DataField       =   "GSTNumber"
         DataSource      =   "dtcSupplier"
         Height          =   285
         Left            =   -73560
         Locked          =   -1  'True
         TabIndex        =   70
         TabStop         =   0   'False
         Top             =   1920
         Width           =   975
      End
      Begin VB.TextBox Text12 
         DataField       =   "PSTNumber"
         DataSource      =   "dtcSupplier"
         Height          =   285
         Left            =   -73560
         Locked          =   -1  'True
         TabIndex        =   69
         TabStop         =   0   'False
         Top             =   1620
         Width           =   975
      End
      Begin VB.TextBox Text11 
         DataField       =   "PaymentTerms"
         DataSource      =   "dtcSupplier"
         Height          =   285
         Left            =   -73560
         Locked          =   -1  'True
         TabIndex        =   66
         TabStop         =   0   'False
         Top             =   1320
         Width           =   975
      End
      Begin VB.TextBox Text10 
         DataField       =   "Remarks"
         DataSource      =   "dtcSupplier"
         Height          =   795
         Left            =   -69960
         Locked          =   -1  'True
         MultiLine       =   -1  'True
         TabIndex        =   65
         TabStop         =   0   'False
         Top             =   720
         Width           =   2775
      End
      Begin VB.TextBox Text9 
         DataField       =   "ContactPerson"
         DataSource      =   "dtcSupplier"
         Height          =   285
         Left            =   -69960
         Locked          =   -1  'True
         TabIndex        =   64
         TabStop         =   0   'False
         Top             =   420
         Width           =   2775
      End
      Begin VB.TextBox Text8 
         DataField       =   "AccountNo"
         DataSource      =   "dtcSupplier"
         Height          =   285
         Left            =   -73560
         Locked          =   -1  'True
         TabIndex        =   61
         TabStop         =   0   'False
         Top             =   420
         Width           =   975
      End
      Begin Threed.SSFrame SSFrame2 
         Height          =   2655
         Left            =   120
         TabIndex        =   20
         Top             =   360
         Width           =   3735
         _ExtentX        =   6588
         _ExtentY        =   4683
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
         Caption         =   "Location"
         Begin VB.TextBox Text2 
            DataField       =   "CityName"
            DataSource      =   "dtcCityFullList"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   54
            TabStop         =   0   'False
            Top             =   960
            Width           =   2415
         End
         Begin VB.TextBox Text3 
            DataField       =   "ProvinceName"
            DataSource      =   "dtcCityFullList"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   53
            TabStop         =   0   'False
            Top             =   1260
            Width           =   2415
         End
         Begin VB.TextBox Text5 
            DataField       =   "PostCode"
            DataSource      =   "dtcSupplier"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   29
            TabStop         =   0   'False
            Top             =   1860
            Width           =   735
         End
         Begin VB.TextBox Text4 
            DataField       =   "CountryName"
            DataSource      =   "dtcCityFullList"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   28
            TabStop         =   0   'False
            Top             =   1560
            Width           =   2415
         End
         Begin VB.TextBox Text1 
            DataField       =   "Address"
            DataSource      =   "dtcSupplier"
            Height          =   555
            Left            =   1200
            Locked          =   -1  'True
            MultiLine       =   -1  'True
            TabIndex        =   27
            TabStop         =   0   'False
            Top             =   360
            Width           =   2415
         End
         Begin VB.Label Label11 
            Caption         =   "Postal Code"
            Height          =   255
            Left            =   120
            TabIndex        =   26
            Top             =   1860
            Width           =   855
         End
         Begin VB.Label Label10 
            Caption         =   "Country"
            Height          =   255
            Left            =   120
            TabIndex        =   25
            Top             =   1560
            Width           =   615
         End
         Begin VB.Label Label9 
            Caption         =   "Province"
            Height          =   255
            Left            =   120
            TabIndex        =   24
            Top             =   1260
            Width           =   615
         End
         Begin VB.Label Label8 
            Caption         =   "City"
            Height          =   255
            Left            =   120
            TabIndex        =   23
            Top             =   960
            Width           =   375
         End
         Begin VB.Label Label7 
            Caption         =   "Address"
            Height          =   255
            Left            =   120
            TabIndex        =   22
            Top             =   300
            Width           =   615
         End
      End
      Begin Threed.SSFrame SSFrame3 
         Height          =   2655
         Left            =   3960
         TabIndex        =   21
         Top             =   360
         Width           =   5295
         _ExtentX        =   9340
         _ExtentY        =   4683
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
         Caption         =   "Phone Number"
         Begin VB.TextBox Text7 
            DataField       =   "CityPhoneCode"
            DataSource      =   "dtcCityFullList"
            Height          =   285
            Left            =   3720
            Locked          =   -1  'True
            TabIndex        =   40
            TabStop         =   0   'False
            Top             =   300
            Width           =   495
         End
         Begin VB.TextBox Text6 
            DataField       =   "CountryPhoneCode"
            DataSource      =   "dtcCityFullList"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   39
            TabStop         =   0   'False
            Top             =   300
            Width           =   495
         End
         Begin MSMask.MaskEdBox MaskEdBox12 
            DataField       =   "TollFreeFax2"
            DataSource      =   "dtcSupplier"
            Height          =   255
            Left            =   3720
            TabIndex        =   52
            TabStop         =   0   'False
            Top             =   2280
            Width           =   1455
            _ExtentX        =   2566
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   14
            Mask            =   "# ### ### ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox11 
            DataField       =   "TollFreeFax1"
            DataSource      =   "dtcSupplier"
            Height          =   255
            Left            =   3720
            TabIndex        =   51
            TabStop         =   0   'False
            Top             =   1980
            Width           =   1455
            _ExtentX        =   2566
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   14
            Mask            =   "# ### ### ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox10 
            DataField       =   "PhoneACDeptFax"
            DataSource      =   "dtcSupplier"
            Height          =   255
            Left            =   3720
            TabIndex        =   50
            TabStop         =   0   'False
            Top             =   1680
            Width           =   1455
            _ExtentX        =   2566
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   8
            Mask            =   "### ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox9 
            DataField       =   "PhoneServiceFax"
            DataSource      =   "dtcSupplier"
            Height          =   255
            Left            =   3720
            TabIndex        =   49
            TabStop         =   0   'False
            Top             =   1380
            Width           =   1455
            _ExtentX        =   2566
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   8
            Mask            =   "### ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox8 
            DataField       =   "PhoneSaleFax"
            DataSource      =   "dtcSupplier"
            Height          =   255
            Left            =   3720
            TabIndex        =   48
            TabStop         =   0   'False
            Top             =   1080
            Width           =   1455
            _ExtentX        =   2566
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   8
            Mask            =   "### ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox7 
            DataField       =   "PhoneGenFax"
            DataSource      =   "dtcSupplier"
            Height          =   255
            Left            =   3720
            TabIndex        =   47
            TabStop         =   0   'False
            Top             =   780
            Width           =   1455
            _ExtentX        =   2566
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   8
            Mask            =   "### ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox6 
            DataField       =   "TollFreePhone2"
            DataSource      =   "dtcSupplier"
            Height          =   255
            Left            =   1200
            TabIndex        =   46
            TabStop         =   0   'False
            Top             =   2280
            Width           =   2175
            _ExtentX        =   3836
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   23
            Mask            =   "# ### ### #### ext ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox5 
            DataField       =   "TollFreePhone1"
            DataSource      =   "dtcSupplier"
            Height          =   255
            Left            =   1200
            TabIndex        =   45
            TabStop         =   0   'False
            Top             =   1980
            Width           =   2175
            _ExtentX        =   3836
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   23
            Mask            =   "# ### ### #### ext ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox4 
            DataField       =   "PhoneACDeptExt"
            DataSource      =   "dtcSupplier"
            Height          =   255
            Left            =   1200
            TabIndex        =   44
            TabStop         =   0   'False
            Top             =   1680
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   16
            Mask            =   "### ### ext ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox3 
            DataField       =   "PhoneServiceExt"
            DataSource      =   "dtcSupplier"
            Height          =   255
            Left            =   1200
            TabIndex        =   43
            TabStop         =   0   'False
            Top             =   1380
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   17
            Mask            =   "### #### ext ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox2 
            DataField       =   "PhoneSaleExt"
            DataSource      =   "dtcSupplier"
            Height          =   255
            Left            =   1200
            TabIndex        =   42
            TabStop         =   0   'False
            Top             =   1080
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   17
            Mask            =   "### #### ext ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox1 
            DataField       =   "PhoneGenVoice"
            DataSource      =   "dtcSupplier"
            Height          =   255
            Left            =   1200
            TabIndex        =   41
            TabStop         =   0   'False
            Top             =   780
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   9
            Mask            =   "### #####"
            PromptChar      =   "_"
         End
         Begin VB.Label Label20 
            Caption         =   "Fax"
            Height          =   195
            Left            =   4320
            TabIndex        =   38
            Top             =   600
            Width           =   375
         End
         Begin VB.Label Label19 
            Caption         =   "Phone"
            Height          =   195
            Left            =   1920
            TabIndex        =   37
            Top             =   600
            Width           =   615
         End
         Begin VB.Label Label18 
            Caption         =   "Toll Free"
            Height          =   255
            Left            =   120
            TabIndex        =   36
            Top             =   1980
            Width           =   735
         End
         Begin VB.Label Label17 
            Caption         =   "Account Dept"
            Height          =   255
            Left            =   120
            TabIndex        =   35
            Top             =   1680
            Width           =   1095
         End
         Begin VB.Label Label16 
            Caption         =   "Service Dept"
            Height          =   255
            Left            =   120
            TabIndex        =   34
            Top             =   1380
            Width           =   975
         End
         Begin VB.Label Label15 
            Caption         =   "Sales Dept"
            Height          =   255
            Left            =   120
            TabIndex        =   33
            Top             =   1080
            Width           =   855
         End
         Begin VB.Label Label14 
            Caption         =   "Main"
            Height          =   255
            Left            =   120
            TabIndex        =   32
            Top             =   780
            Width           =   495
         End
         Begin VB.Label Label13 
            Caption         =   "City Code"
            Height          =   255
            Left            =   3000
            TabIndex        =   31
            Top             =   300
            Width           =   735
         End
         Begin VB.Label Label12 
            Caption         =   "Country Code"
            Height          =   255
            Left            =   120
            TabIndex        =   30
            Top             =   300
            Width           =   975
         End
      End
      Begin MSMask.MaskEdBox MaskEdBox13 
         DataField       =   "CreditLimit"
         DataSource      =   "dtcSupplier"
         Height          =   255
         Left            =   -73560
         TabIndex        =   63
         TabStop         =   0   'False
         Top             =   1020
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   450
         _Version        =   393216
         Enabled         =   0   'False
         Format          =   "$##,##0.00"
         PromptChar      =   "_"
      End
      Begin VB.Label Label28 
         Caption         =   "GST Number"
         Height          =   255
         Left            =   -74880
         TabIndex        =   68
         Top             =   1920
         Width           =   975
      End
      Begin VB.Label Label27 
         Caption         =   "PST Number"
         Height          =   255
         Left            =   -74880
         TabIndex        =   67
         Top             =   1620
         Width           =   1095
      End
      Begin VB.Label Label26 
         Caption         =   "Remarks"
         Height          =   255
         Left            =   -71280
         TabIndex        =   60
         Top             =   720
         Width           =   735
      End
      Begin VB.Label Label25 
         Caption         =   "Contact Person"
         Height          =   255
         Left            =   -71280
         TabIndex        =   59
         Top             =   420
         Width           =   1095
      End
      Begin VB.Label Label24 
         Caption         =   "Payment Terms"
         Height          =   255
         Left            =   -74880
         TabIndex        =   58
         Top             =   1320
         Width           =   1095
      End
      Begin VB.Label Label23 
         Caption         =   "Credit Limit"
         Height          =   255
         Left            =   -74880
         TabIndex        =   57
         Top             =   1020
         Width           =   855
      End
      Begin VB.Label Label22 
         Caption         =   "Date Started"
         Height          =   255
         Left            =   -74880
         TabIndex        =   56
         Top             =   720
         Width           =   975
      End
      Begin VB.Label Label21 
         Caption         =   "Account No."
         Height          =   255
         Left            =   -74880
         TabIndex        =   55
         Top             =   420
         Width           =   975
      End
   End
End
Attribute VB_Name = "frmInfoSupplier"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdFindPhone_Click()

    If txtSelPhone <> "" Then
        ' Lookup dtcCustomer
        strSQL = "SELECT * FROM Supplier " _
               & "WHERE PhoneGenVoice LIKE '" & txtSelPhone.Text & "' " _
               & "ORDER BY SupplierName"
        dtcSupplier.RecordSource = strSQL
        dtcSupplier.Refresh
        dtcSupplier.UpdateControls
    End If

End Sub


Private Sub dbcCity_Click(intArea As Integer)

    If intArea = dbcAreaList Then
        ' Lookup dtcCity
        If cmdCascadeCity.Value Then    ' Cascade selected
            LookupByCascade
        Else                            ' No cascade
            strSQL = "SELECT * FROM Supplier " _
                & "WHERE City = " & dbcCity.BoundText _
                & " ORDER BY SupplierName"
            dtcSupplier.RecordSource = strSQL
            dtcSupplier.Refresh
            dtcSupplier.UpdateControls
        End If
    End If

End Sub

Private Sub dbcContactPerson_Click(intArea As Integer)

    If intArea = dbcAreaList Then
        ' Lookup dtcInventory
        If cmdCascadeContactPerson.Value Then    ' Cascade selected
            LookupByCascade
        Else                            ' No cascade
            strSQL = "SELECT * FROM Supplier " _
                & "WHERE ContactPerson = '" & dbcContactPerson.Text & "' " _
                & "ORDER BY SupplierName"
            dtcSupplier.RecordSource = strSQL
            dtcSupplier.Refresh
            dtcSupplier.UpdateControls
        End If
    End If

End Sub

Private Sub dbcCountry_Click(intArea As Integer)

    If intArea = dbcAreaList Then
        ' Lookup dtcCountry
        If cmdCascadeCountry.Value Then    ' Cascade selected
            LookupByCascade
        Else                            ' No cascade
            strSQL = "SELECT * FROM Supplier " _
                & "WHERE Country = '" & dbcCountry.BoundText & "' " _
                & "ORDER BY SupplierName"
            dtcSupplier.RecordSource = strSQL
            dtcSupplier.Refresh
            dtcSupplier.UpdateControls
        End If
    End If

End Sub



Private Sub dbcProvince_Click(intArea As Integer)

    If intArea = dbcAreaList Then
        ' Lookup dtcProvince
        If cmdCascadeProvince.Value Then    ' Cascade selected
            LookupByCascade
        Else                            ' No cascade
            strSQL = "SELECT * FROM Supplier " _
                & "WHERE Province = '" & dbcProvince.BoundText & "' " _
                & "ORDER BY SupplierName"
            dtcSupplier.RecordSource = strSQL
            dtcSupplier.Refresh
            dtcSupplier.UpdateControls
        End If
    End If

End Sub

Private Sub dbcSupplierName_Click(intArea As Integer)
    
    If intArea = dbcAreaList Then
        ' Lookup dtcInventory
        If cmdCascadeSupplier.Value Then    ' Cascade selected
            LookupByCascade
        Else                            ' No cascade
            strSQL = "SELECT * FROM Supplier " _
                & "WHERE SupplierName = '" & dbcSupplierName.Text & "' " _
                & "ORDER BY SupplierName"
            dtcSupplier.RecordSource = strSQL
            dtcSupplier.Refresh
            dtcSupplier.UpdateControls
        End If
    End If

End Sub

Private Sub dtcSupplier_Reposition()

    Dim strTarget As String
    If Not (dtcSupplier.Recordset.EOF Or dtcSupplier.Recordset.BOF) Then
        ' Sync Supplier Address
        If dtcSupplier.Recordset!City <> "" Then
            strTarget = "SELECT * FROM qryCityFullList WHERE Code = " & dtcSupplier.Recordset!City
        Else
            strTarget = "SELECT * FROM qryCityFullList WHERE Code = 0"
        End If
        dtcCityFullList.RecordSource = strTarget
        dtcCityFullList.Refresh
        dtcCityFullList.UpdateControls
    End If

End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub


Private Sub Form_Load()
Call ofx_CenterForm(Me)
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

    Select Case ToolID
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            dtcSupplier.Recordset.MoveFirst
        Case "ID_Next"
            dtcSupplier.Recordset.MoveNext
            ' Prevent the Blank Record
            If dtcSupplier.Recordset.EOF Then
                Beep
                dtcSupplier.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcSupplier.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcSupplier.Recordset.BOF Then
                Beep
                dtcSupplier.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcSupplier.Recordset.MoveLast
        Case "ID_Copy"
            Clipboard.Clear
            Clipboard.SetText dtcSupplier.Recordset.Fields("SupplierCode")
            MsgBox "Supplier Code " & dtcSupplier.Recordset.Fields("SupplierCode") & " Copied."
            Unload Me
        Case "ID_Append"
            Clipboard.SetText dtcSupplier.Recordset.Fields("SupplierCode")
            MsgBox "Supplier Code " & dtcSupplier.Recordset.Fields("SupplierCode") & " Copied."
        Case "ID_Add"
            If ofx_IsFormLoaded(frmSupplier) Then
                frmSupplier.SetFocus
                SendKeys "% R", True
                frmSupplier.ZOrder
            Else
                Screen.MousePointer = vbHourglass
                frmSupplier.Show
            End If
    End Select

End Sub


Private Sub LookupByCascade()
    
    Dim strSQL As String
    Dim blnCascade As Boolean
        
    strSQL = "SELECT * FROM Supplier WHERE "
    If cmdCascadeSupplier.Value Then
        If dbcSupplierName.Text <> "" Then
            strSQL = strSQL & "SupplierName = '" & dbcSupplier.Text & "' "
            blnCascade = True
        End If
    End If
    If cmdCascadeContactPerson.Value Then
        If dbcContactPerson.Text <> "" Then
            If blnCascade Then strSQL = strSQL & "And "
            strSQL = strSQL & "ContactPerson = '" & dbcContactPerson.Text & "' "
            blnCascade = True
        End If
    End If
    If cmdCascadeCountry.Value Then
        If dbcCountry.BoundText <> "" Then
            If blnCascade Then strSQL = strSQL & "And "
            strSQL = strSQL & "Country = '" & dbcCountry.BoundText & "' "
            blnCascade = True
        End If
    End If
    If cmdCascadeProvince.Value Then
        If dbcProvince.BoundText <> "" Then
            If blnCascade Then strSQL = strSQL & "And "
            strSQL = strSQL & "Province = '" & dbcProvince.BoundText & "' "
            blnCascade = True
        End If
    End If
    If cmdCascadeCity.Value Then
        If dbcCity.Text <> "" Then
            If blnCascade Then strSQL = strSQL & "And "
            strSQL = strSQL & "City = " & dbcCity.BoundText & " "
            blnCascade = True
        End If
    End If
    strSQL = strSQL & "ORDER BY SupplierName"
    dtcSupplier.RecordSource = strSQL
    dtcSupplier.Refresh
    dtcSupplier.UpdateControls

End Sub

Private Sub txtPhone_Change()

End Sub


Private Sub txtSelPhone_GotFocus()
    Call AutoSelect(txtSelPhone)
End Sub


Private Sub txtSelPhone_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindPhone_Click
        KeyAscii = 0
    End If
End Sub



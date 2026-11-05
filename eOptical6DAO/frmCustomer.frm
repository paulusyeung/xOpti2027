VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{B074BC93-5A5B-11CE-98BD-0000C0E6B88E}#2.0#0"; "sstabs32.ocx"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmCustomer 
   Caption         =   "Customer"
   ClientHeight    =   7290
   ClientLeft      =   300
   ClientTop       =   960
   ClientWidth     =   10950
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   7290
   ScaleWidth      =   10950
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Bindings        =   "frmCustomer.frx":0000
      Height          =   1635
      Left            =   2160
      OleObjectBlob   =   "frmCustomer.frx":001A
      TabIndex        =   14
      TabStop         =   0   'False
      Top             =   5520
      Width           =   8655
   End
   Begin VB.Timer tmrClearDBComboHiLite 
      Interval        =   100
      Left            =   1320
      Top             =   4860
   End
   Begin VB.Data dtcLookupCustomer 
      Caption         =   "Customer"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   345
      Left            =   120
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Customer"
      Top             =   4800
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcDoctorLens 
      Caption         =   "DoctorLens"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   960
      Options         =   4
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "qryDoctor"
      Top             =   2040
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcDoctorCont 
      Caption         =   "Doctor"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   960
      Options         =   4
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "qryDoctor"
      Top             =   2520
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcCusAccount 
      Caption         =   "CusAccount"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   960
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT CustomerID, JointDate FROM CustomerAccounts"
      Top             =   2280
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcCusPresLens 
      Caption         =   "CusPresLens"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   960
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "CustomerPresLens"
      Top             =   2760
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcCusPresCont 
      Caption         =   "CusPresCont"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   120
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "CustomerPresContact"
      Top             =   2820
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcBizCity 
      Caption         =   "BizCity"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   120
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "qryCityFullList"
      Top             =   1920
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcBizCountry 
      Caption         =   "BizCountry"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   120
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Country"
      Top             =   2520
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcBizProvince 
      Caption         =   "BizProvince"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   120
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Province"
      Top             =   2220
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcSalutation 
      Caption         =   "Salutation"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   120
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Salutation"
      Top             =   4500
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcJobTitle 
      Caption         =   "JobTitle"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   120
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "JobTitle"
      Top             =   4260
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcCountry 
      Caption         =   "Country"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   120
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Country"
      Top             =   4020
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcProvince 
      Caption         =   "Province"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   120
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Province"
      Top             =   3780
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcCity 
      Caption         =   "City"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   120
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "qryCityFullList"
      Top             =   3480
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcCustomer 
      Caption         =   "Customer"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   120
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Customer"
      Top             =   3240
      Visible         =   0   'False
      Width           =   1815
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar tbrTaskButton 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   0
      Width           =   10950
      _Version        =   131073
      _ExtentX        =   19315
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
      ToolsetPicture  =   "frmCustomer.frx":2B83
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
      MouseIcon       =   "frmCustomer.frx":11C15
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   915
      Left            =   2160
      TabIndex        =   5
      Top             =   1080
      Width           =   6255
      _ExtentX        =   11033
      _ExtentY        =   1614
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
      Caption         =   "Customer Name"
      Begin VB.TextBox txtCustomerFullName 
         DataField       =   "FullName"
         DataSource      =   "dtcCustomer"
         Height          =   285
         Left            =   3840
         MaxLength       =   40
         TabIndex        =   13
         Text            =   "Text1"
         Top             =   480
         Width           =   2295
      End
      Begin VB.TextBox txtLastName 
         DataField       =   "LastName"
         DataSource      =   "dtcCustomer"
         Height          =   285
         Left            =   2160
         TabIndex        =   11
         Top             =   480
         Width           =   1575
      End
      Begin VB.TextBox txtFirstName 
         DataField       =   "FirstName"
         DataSource      =   "dtcCustomer"
         Height          =   285
         Left            =   120
         TabIndex        =   7
         Top             =   480
         Width           =   1455
      End
      Begin MSMask.MaskEdBox mskCustomerInitial 
         DataField       =   "Initial"
         DataSource      =   "dtcCustomer"
         Height          =   255
         Left            =   1680
         TabIndex        =   10
         Top             =   480
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   450
         _Version        =   393216
         PromptInclude   =   0   'False
         MaxLength       =   2
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Mask            =   ">aa"
         PromptChar      =   "_"
      End
      Begin VB.Label Label6 
         Caption         =   "Full Name"
         Height          =   255
         Left            =   3840
         TabIndex        =   12
         Top             =   240
         Width           =   855
      End
      Begin VB.Label Label5 
         Caption         =   "Last Name"
         Height          =   255
         Left            =   2160
         TabIndex        =   9
         Top             =   240
         Width           =   975
      End
      Begin VB.Label Label4 
         Caption         =   "Initial"
         Height          =   255
         Left            =   1680
         TabIndex        =   8
         Top             =   240
         Width           =   375
      End
      Begin VB.Label Label3 
         Caption         =   "First Name"
         Height          =   255
         Left            =   120
         TabIndex        =   6
         Top             =   240
         Width           =   855
      End
   End
   Begin SSDesignerWidgetsTabs.SSIndexTab SSIndexTab1 
      Height          =   3195
      Left            =   2160
      TabIndex        =   15
      Top             =   2040
      Width           =   8655
      _Version        =   131078
      _ExtentX        =   15266
      _ExtentY        =   5636
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
      TabVisibleLast  =   4
      TabShape        =   6
      TabsPerRow      =   8
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
      TabsNum         =   5
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
      Tabs(0).Pages(0).CtlCount=   4
      Tabs(0).Pages(0).CtlEnabled=   -1  'True
      Tabs(0).Pages(0).Ctl(0)=   "SSFrame5"
      Tabs(0).Pages(0).Ctl(1)=   "SSFrame2"
      Tabs(0).Pages(0).Ctl(2)=   "txtSyncProvince"
      Tabs(0).Pages(0).Ctl(3)=   "txtSyncCountry"
      Tabs(0).Tag     =   ""
      Tabs(0).Caption =   "Home"
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
      Tabs(1).Pages(0).CtlCount=   8
      Tabs(1).Pages(0).CtlEnabled=   0   'False
      Tabs(1).Pages(0).Ctl(0)=   "Label14"
      Tabs(1).Pages(0).Ctl(1)=   "Label15"
      Tabs(1).Pages(0).Ctl(2)=   "dbcJobTitle"
      Tabs(1).Pages(0).Ctl(3)=   "SSFrame4"
      Tabs(1).Pages(0).Ctl(4)=   "SSFrame3"
      Tabs(1).Pages(0).Ctl(5)=   "txtBizCompany"
      Tabs(1).Pages(0).Ctl(6)=   "txtSyncBizProvince"
      Tabs(1).Pages(0).Ctl(7)=   "txtSyncBizCountry"
      Tabs(1).Tag     =   ""
      Tabs(1).Caption =   "Work"
      Tabs(1).Name    =   "tab 1"
      Tabs(2).PictureMetaWidth=   0
      Tabs(2).PictureMetaHeight=   0
      Tabs(2).Page    =   0
      Tabs(2).ControlCount=   0
      Tabs(2).ControlEnabled=   0   'False
      Tabs(2).Pages(0).PictureMetaWidth=   0
      Tabs(2).Pages(0).PictureMetaHeight=   0
      Tabs(2).Pages(0).Tag=   ""
      Tabs(2).Pages(0).Caption=   "Page 0"
      Tabs(2).Pages(0).Name=   "page 0"
      Tabs(2).Pages(0).CtlCount=   2
      Tabs(2).Pages(0).CtlEnabled=   0   'False
      Tabs(2).Pages(0).Ctl(0)=   "SSFrame7"
      Tabs(2).Pages(0).Ctl(1)=   "SSFrame6"
      Tabs(2).Tag     =   ""
      Tabs(2).Caption =   "Personal"
      Tabs(2).Name    =   "tab 2"
      Tabs(3).PictureMetaWidth=   0
      Tabs(3).PictureMetaHeight=   0
      Tabs(3).Page    =   0
      Tabs(3).ControlCount=   0
      Tabs(3).ControlEnabled=   0   'False
      Tabs(3).Pages(0).PictureMetaWidth=   0
      Tabs(3).Pages(0).PictureMetaHeight=   0
      Tabs(3).Pages(0).Tag=   ""
      Tabs(3).Pages(0).Caption=   "Page 0"
      Tabs(3).Pages(0).Name=   "page 0"
      Tabs(3).Pages(0).CtlCount=   3
      Tabs(3).Pages(0).CtlEnabled=   0   'False
      Tabs(3).Pages(0).Ctl(0)=   "SSFrame10"
      Tabs(3).Pages(0).Ctl(1)=   "SSFrame9"
      Tabs(3).Pages(0).Ctl(2)=   "SSFrame8"
      Tabs(3).Tag     =   ""
      Tabs(3).Caption =   "Pres (Cont)"
      Tabs(3).Name    =   "tab 3"
      Tabs(4).PictureMetaWidth=   0
      Tabs(4).PictureMetaHeight=   0
      Tabs(4).Page    =   0
      Tabs(4).ControlCount=   0
      Tabs(4).ControlEnabled=   0   'False
      Tabs(4).Pages(0).PictureMetaWidth=   0
      Tabs(4).Pages(0).PictureMetaHeight=   0
      Tabs(4).Pages(0).Tag=   ""
      Tabs(4).Pages(0).Caption=   "Page 0"
      Tabs(4).Pages(0).Name=   "page 0"
      Tabs(4).Pages(0).CtlCount=   2
      Tabs(4).Pages(0).CtlEnabled=   0   'False
      Tabs(4).Pages(0).Ctl(0)=   "SSFrame12"
      Tabs(4).Pages(0).Ctl(1)=   "SSFrame11"
      Tabs(4).Tag     =   ""
      Tabs(4).Caption =   "Pres (Lens)"
      Tabs(4).Name    =   "tab 4"
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
      Begin VB.TextBox txtSyncBizCountry 
         BackColor       =   &H0000FFFF&
         DataField       =   "CountryName"
         DataSource      =   "dtcBizCountry"
         Height          =   285
         Left            =   -71760
         Locked          =   -1  'True
         TabIndex        =   67
         TabStop         =   0   'False
         Top             =   1800
         Visible         =   0   'False
         Width           =   1455
      End
      Begin VB.TextBox txtSyncBizProvince 
         BackColor       =   &H0000FFFF&
         DataField       =   "ProvinceName"
         DataSource      =   "dtcBizProvince"
         Height          =   285
         Left            =   -71760
         Locked          =   -1  'True
         TabIndex        =   66
         TabStop         =   0   'False
         Top             =   1500
         Visible         =   0   'False
         Width           =   1455
      End
      Begin VB.TextBox txtSyncCountry 
         BackColor       =   &H0000FFFF&
         DataField       =   "CountryName"
         DataSource      =   "dtcCountry"
         Height          =   285
         Left            =   3240
         Locked          =   -1  'True
         TabIndex        =   51
         TabStop         =   0   'False
         Top             =   1500
         Visible         =   0   'False
         Width           =   1695
      End
      Begin VB.TextBox txtSyncProvince 
         BackColor       =   &H0000FFFF&
         DataField       =   "ProvinceName"
         DataSource      =   "dtcProvince"
         Height          =   285
         Left            =   3240
         Locked          =   -1  'True
         TabIndex        =   50
         TabStop         =   0   'False
         Top             =   1200
         Visible         =   0   'False
         Width           =   1695
      End
      Begin VB.TextBox txtBizCompany 
         DataField       =   "BizCompanyName"
         DataSource      =   "dtcCustomer"
         Height          =   285
         Left            =   -73800
         TabIndex        =   27
         Top             =   360
         Width           =   2415
      End
      Begin Threed.SSFrame SSFrame2 
         Height          =   2715
         Left            =   3960
         TabIndex        =   38
         Top             =   360
         Width           =   2415
         _ExtentX        =   4260
         _ExtentY        =   4789
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
         Begin VB.TextBox Text4 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CityPhoneCode"
            DataSource      =   "dtcCity"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   44
            TabStop         =   0   'False
            Top             =   600
            Width           =   495
         End
         Begin VB.TextBox Text2 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CountryPhoneCode"
            DataSource      =   "dtcCountry"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   43
            TabStop         =   0   'False
            Top             =   300
            Width           =   495
         End
         Begin MSMask.MaskEdBox mskCellular 
            DataField       =   "Cellular"
            DataSource      =   "dtcCustomer"
            Height          =   255
            Left            =   1200
            TabIndex        =   24
            Top             =   1500
            Width           =   1095
            _ExtentX        =   1931
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   9
            BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Mask            =   "### #####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskHomeFax 
            DataField       =   "HomeFax"
            DataSource      =   "dtcCustomer"
            Height          =   255
            Left            =   1200
            TabIndex        =   23
            Top             =   1200
            Width           =   1095
            _ExtentX        =   1931
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   9
            BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Mask            =   "### #####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskHomePhone 
            DataField       =   "HomePhone"
            DataSource      =   "dtcCustomer"
            Height          =   255
            Left            =   1200
            TabIndex        =   22
            Top             =   900
            Width           =   1095
            _ExtentX        =   1931
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   9
            BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Mask            =   "### #####"
            PromptChar      =   "_"
         End
         Begin VB.Label Label7 
            Caption         =   "Cellular"
            Height          =   255
            Left            =   120
            TabIndex        =   68
            Top             =   1500
            Width           =   615
         End
         Begin VB.Label Label28 
            Caption         =   "Fax"
            Height          =   255
            Left            =   120
            TabIndex        =   42
            Top             =   1200
            Width           =   375
         End
         Begin VB.Label Label27 
            Caption         =   "Phone"
            Height          =   255
            Left            =   120
            TabIndex        =   41
            Top             =   900
            Width           =   735
         End
         Begin VB.Label Label26 
            Caption         =   "City Code"
            Height          =   255
            Left            =   120
            TabIndex        =   40
            Top             =   600
            Width           =   735
         End
         Begin VB.Label Label25 
            Caption         =   "Country Code"
            Height          =   255
            Left            =   120
            TabIndex        =   39
            Top             =   300
            Width           =   1095
         End
      End
      Begin Threed.SSFrame SSFrame3 
         Height          =   2415
         Left            =   -71040
         TabIndex        =   45
         Top             =   660
         Width           =   3135
         _ExtentX        =   5530
         _ExtentY        =   4260
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
         Begin VB.TextBox Text6 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CityPhoneCode"
            DataSource      =   "dtcBizCity"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   35
            TabStop         =   0   'False
            Top             =   600
            Width           =   495
         End
         Begin VB.TextBox Text5 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CountryPhoneCode"
            DataSource      =   "dtcBizCountry"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   34
            TabStop         =   0   'False
            Top             =   300
            Width           =   495
         End
         Begin MSMask.MaskEdBox mskBizFax 
            DataField       =   "BizFax"
            DataSource      =   "dtcCustomer"
            Height          =   255
            Left            =   1200
            TabIndex        =   37
            Top             =   1200
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   9
            BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Mask            =   "### #####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskBizPhone 
            DataField       =   "BizPhone"
            DataSource      =   "dtcCustomer"
            Height          =   255
            Left            =   1200
            TabIndex        =   36
            Top             =   900
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   17
            BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Mask            =   "### #### ext ####"
            PromptChar      =   "_"
         End
         Begin VB.Label Label21 
            Caption         =   "Fax"
            Height          =   255
            Left            =   120
            TabIndex        =   49
            Top             =   1200
            Width           =   375
         End
         Begin VB.Label Label20 
            Caption         =   "Phone"
            Height          =   255
            Left            =   120
            TabIndex        =   48
            Top             =   900
            Width           =   615
         End
         Begin VB.Label Label12 
            Caption         =   "City Code"
            Height          =   255
            Left            =   120
            TabIndex        =   47
            Top             =   600
            Width           =   735
         End
         Begin VB.Label Label11 
            Caption         =   "Country Code"
            Height          =   255
            Left            =   120
            TabIndex        =   46
            Top             =   300
            Width           =   975
         End
      End
      Begin Threed.SSFrame SSFrame4 
         Height          =   2415
         Left            =   -74880
         TabIndex        =   52
         Top             =   660
         Width           =   3615
         _ExtentX        =   6376
         _ExtentY        =   4260
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
         Caption         =   "Mailing Address"
         Begin VB.TextBox txtBizCountry 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CountryName"
            DataSource      =   "dtcBizCity"
            Enabled         =   0   'False
            Height          =   315
            Left            =   1080
            TabIndex        =   32
            Top             =   1560
            Width           =   2055
         End
         Begin VB.TextBox txtBizProvince 
            BackColor       =   &H00C0C0C0&
            DataField       =   "ProvinceName"
            DataSource      =   "dtcBizCity"
            Enabled         =   0   'False
            Height          =   315
            Left            =   1080
            TabIndex        =   31
            Top             =   1200
            Width           =   2055
         End
         Begin VB.TextBox Text7 
            DataField       =   "BizAddress"
            DataSource      =   "dtcCustomer"
            Height          =   495
            Left            =   1080
            MultiLine       =   -1  'True
            TabIndex        =   29
            Top             =   300
            Width           =   2415
         End
         Begin MSMask.MaskEdBox mskBizPostalCode 
            DataField       =   "BizPostalCode"
            DataSource      =   "dtcCustomer"
            Height          =   255
            Left            =   1080
            TabIndex        =   33
            Top             =   1920
            Width           =   735
            _ExtentX        =   1296
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   7
            BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Mask            =   ">a#a#a##"
            PromptChar      =   "_"
         End
         Begin MSDBCtls.DBCombo dbcBizCity 
            Bindings        =   "frmCustomer.frx":11C31
            DataField       =   "BizCity"
            DataSource      =   "dtcCustomer"
            Height          =   315
            Left            =   1080
            TabIndex        =   30
            Top             =   840
            Width           =   2055
            _ExtentX        =   3625
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "CityName"
            BoundColumn     =   "Code"
            Text            =   "dbcBizCity"
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
         Begin Threed.SSCommand SSCommand1 
            Height          =   315
            Left            =   3120
            TabIndex        =   65
            Top             =   840
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
            Picture         =   "frmCustomer.frx":11C4A
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin VB.Label Label29 
            Caption         =   "Postal Code"
            Height          =   255
            Left            =   120
            TabIndex        =   57
            Top             =   1920
            Width           =   855
         End
         Begin VB.Label Label19 
            Caption         =   "Country"
            Height          =   255
            Left            =   120
            TabIndex        =   56
            Top             =   1560
            Width           =   615
         End
         Begin VB.Label Label18 
            Caption         =   "Province"
            Height          =   255
            Left            =   120
            TabIndex        =   55
            Top             =   1200
            Width           =   735
         End
         Begin VB.Label Label17 
            Caption         =   "City"
            Height          =   255
            Left            =   120
            TabIndex        =   54
            Top             =   840
            Width           =   375
         End
         Begin VB.Label Label16 
            Caption         =   "Address"
            Height          =   255
            Left            =   120
            TabIndex        =   53
            Top             =   300
            Width           =   615
         End
      End
      Begin Threed.SSFrame SSFrame5 
         Height          =   2715
         Left            =   120
         TabIndex        =   58
         Top             =   360
         Width           =   3615
         _ExtentX        =   6376
         _ExtentY        =   4789
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
         Caption         =   "Mailing Address"
         Begin VB.TextBox txtEmail 
            DataField       =   "Email"
            DataSource      =   "dtcCustomer"
            Height          =   285
            Left            =   1080
            MaxLength       =   128
            TabIndex        =   21
            Top             =   2280
            Width           =   2415
         End
         Begin VB.TextBox txtCountry 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CountryName"
            DataSource      =   "dtcCity"
            Enabled         =   0   'False
            Height          =   315
            Left            =   1080
            TabIndex        =   19
            Top             =   1560
            Width           =   2055
         End
         Begin VB.TextBox txtProvince 
            BackColor       =   &H00C0C0C0&
            DataField       =   "ProvinceName"
            DataSource      =   "dtcCity"
            Enabled         =   0   'False
            Height          =   315
            Left            =   1080
            TabIndex        =   18
            Top             =   1200
            Width           =   2055
         End
         Begin VB.TextBox Text8 
            DataField       =   "HomeAddress"
            DataSource      =   "dtcCustomer"
            Height          =   495
            Left            =   1080
            MaxLength       =   127
            MultiLine       =   -1  'True
            TabIndex        =   16
            Top             =   300
            Width           =   2415
         End
         Begin MSMask.MaskEdBox mskHomePostalCode 
            DataField       =   "HomePostalCode"
            DataSource      =   "dtcCustomer"
            Height          =   255
            Left            =   1080
            TabIndex        =   20
            Top             =   1920
            Width           =   855
            _ExtentX        =   1508
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   7
            BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Mask            =   ">a#a#a##"
            PromptChar      =   "_"
         End
         Begin MSDBCtls.DBCombo dbcCity 
            Bindings        =   "frmCustomer.frx":12218
            DataField       =   "HomeCity"
            DataSource      =   "dtcCustomer"
            Height          =   315
            Left            =   1080
            TabIndex        =   17
            Top             =   840
            Width           =   2055
            _ExtentX        =   3625
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "CityName"
            BoundColumn     =   "Code"
            Text            =   "dbcCity"
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
         Begin VB.Label Label67 
            Caption         =   "Email"
            Height          =   255
            Left            =   120
            TabIndex        =   177
            Top             =   2280
            Width           =   975
         End
         Begin Threed.SSCommand SSCommand2 
            Height          =   315
            Left            =   3120
            TabIndex        =   64
            Top             =   840
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
            Picture         =   "frmCustomer.frx":1222E
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin VB.Label Label34 
            Caption         =   "Postal Code"
            Height          =   255
            Left            =   120
            TabIndex        =   63
            Top             =   1920
            Width           =   975
         End
         Begin VB.Label Label33 
            Caption         =   "Country"
            Height          =   255
            Left            =   120
            TabIndex        =   62
            Top             =   1560
            Width           =   615
         End
         Begin VB.Label Label32 
            Caption         =   "Province"
            Height          =   255
            Left            =   120
            TabIndex        =   61
            Top             =   1200
            Width           =   735
         End
         Begin VB.Label Label31 
            Caption         =   "City"
            Height          =   255
            Left            =   120
            TabIndex        =   60
            Top             =   900
            Width           =   375
         End
         Begin VB.Label Label30 
            Caption         =   "Address"
            Height          =   255
            Left            =   120
            TabIndex        =   59
            Top             =   300
            Width           =   615
         End
      End
      Begin Threed.SSFrame SSFrame6 
         Height          =   2715
         Left            =   -70560
         TabIndex        =   69
         Top             =   360
         Width           =   4095
         _ExtentX        =   7223
         _ExtentY        =   4789
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
         Caption         =   "Medical"
         Begin VB.Data dtcCusMedical 
            Caption         =   "CusMedical"
            Connect         =   "Access 2000;"
            DatabaseName    =   "SynergyV.mdb"
            DefaultCursorType=   0  'DefaultCursor
            DefaultType     =   2  'UseODBC
            Exclusive       =   0   'False
            Height          =   300
            Left            =   1200
            Options         =   0
            ReadOnly        =   0   'False
            RecordsetType   =   1  'Dynaset
            RecordSource    =   "CustomerMedical"
            Top             =   1800
            Visible         =   0   'False
            Width           =   1140
         End
         Begin MSMask.MaskEdBox mskCareCardType 
            DataField       =   "CareCardType"
            DataSource      =   "dtcCusMedical"
            Height          =   255
            Left            =   1920
            TabIndex        =   82
            Top             =   1200
            Width           =   615
            _ExtentX        =   1085
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   4
            BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Mask            =   ">aaaa"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskCareCardValidPeriod 
            DataField       =   "CareCardValidPeriod"
            DataSource      =   "dtcCusMedical"
            Height          =   255
            Left            =   1920
            TabIndex        =   81
            Top             =   900
            Width           =   615
            _ExtentX        =   1085
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   5
            BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Mask            =   "##/##"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskCareCardNumber 
            DataField       =   "CareCardNo"
            DataSource      =   "dtcCusMedical"
            Height          =   255
            Left            =   1920
            TabIndex        =   80
            Top             =   600
            Width           =   1815
            _ExtentX        =   3201
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   12
            BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Mask            =   "#### ### ###"
            PromptChar      =   "_"
         End
         Begin SSCalendarWidgets_A.SSDateCombo calInsMaturityDate 
            DataField       =   "InsMaturityDate"
            DataSource      =   "dtcCusMedical"
            Height          =   315
            Left            =   1920
            TabIndex        =   79
            Top             =   240
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
         Begin VB.Label Label13 
            Caption         =   "Care Card Type"
            Height          =   195
            Left            =   120
            TabIndex        =   73
            Top             =   1200
            Width           =   1215
         End
         Begin VB.Label Label10 
            Caption         =   "Care Card Valid Period"
            Height          =   195
            Left            =   120
            TabIndex        =   72
            Top             =   900
            Width           =   1695
         End
         Begin VB.Label Label9 
            Caption         =   "Care Card Number"
            Height          =   195
            Left            =   120
            TabIndex        =   71
            Top             =   600
            Width           =   1335
         End
         Begin VB.Label Label8 
            Caption         =   "Insurance Maturity Date"
            Height          =   195
            Left            =   120
            TabIndex        =   70
            Top             =   240
            Width           =   1695
         End
      End
      Begin Threed.SSFrame SSFrame7 
         Height          =   2715
         Left            =   -74880
         TabIndex        =   83
         Top             =   360
         Width           =   4095
         _ExtentX        =   7223
         _ExtentY        =   4789
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
         Caption         =   "General"
         Begin VB.TextBox txtRemarks 
            DataField       =   "Remarks"
            DataSource      =   "dtcCustomer"
            Height          =   1035
            Left            =   1440
            MultiLine       =   -1  'True
            ScrollBars      =   2  'Vertical
            TabIndex        =   78
            Top             =   1620
            Width           =   2535
         End
         Begin SSCalendarWidgets_A.SSDateCombo calJointDate 
            DataField       =   "JointDate"
            DataSource      =   "dtcCusAccount"
            Height          =   315
            Left            =   1440
            TabIndex        =   77
            Top             =   1260
            Width           =   2535
            _Version        =   65543
            _ExtentX        =   4471
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
         Begin MSMask.MaskEdBox MaskEdBox4 
            DataField       =   "VIPMarkDownPct"
            DataSource      =   "dtcCustomer"
            Height          =   255
            Left            =   1440
            TabIndex        =   76
            Top             =   960
            Width           =   735
            _ExtentX        =   1296
            _ExtentY        =   450
            _Version        =   393216
            MaxLength       =   6
            BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Format          =   "##0.00"
            PromptChar      =   "_"
         End
         Begin SSCalendarWidgets_A.SSDateCombo calBirthday 
            DataField       =   "Birthday"
            DataSource      =   "dtcCustomer"
            Height          =   315
            Left            =   1440
            TabIndex        =   75
            Top             =   600
            Width           =   2535
            _Version        =   65543
            _ExtentX        =   4471
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
         Begin MSDBCtls.DBCombo dbcSalutation 
            Bindings        =   "frmCustomer.frx":127FC
            DataField       =   "Salutation"
            DataSource      =   "dtcCustomer"
            Height          =   315
            Left            =   1440
            TabIndex        =   74
            Top             =   240
            Width           =   735
            _ExtentX        =   1296
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "Salutation"
            BoundColumn     =   "Salutation"
            Text            =   "dbcSalutation"
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
         Begin Threed.SSCommand SSCommand3 
            Height          =   315
            Left            =   2160
            TabIndex        =   87
            TabStop         =   0   'False
            Top             =   240
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
            Picture         =   "frmCustomer.frx":12818
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin VB.Label Label66 
            Caption         =   "Remarks"
            Height          =   255
            Left            =   120
            TabIndex        =   176
            Top             =   1620
            Width           =   735
         End
         Begin VB.Label Label63 
            Caption         =   "Joint Date"
            Height          =   195
            Left            =   120
            TabIndex        =   163
            Top             =   1260
            Width           =   735
         End
         Begin VB.Label Label37 
            Caption         =   "VIP Discount (%)"
            Height          =   255
            Left            =   120
            TabIndex        =   86
            Top             =   960
            Width           =   1215
         End
         Begin VB.Label Label36 
            Caption         =   "Birthday"
            Height          =   255
            Left            =   120
            TabIndex        =   85
            Top             =   600
            Width           =   735
         End
         Begin VB.Label Label35 
            Caption         =   "Salutation"
            Height          =   255
            Left            =   120
            TabIndex        =   84
            Top             =   300
            Width           =   735
         End
      End
      Begin Threed.SSFrame SSFrame8 
         Height          =   615
         Left            =   -74880
         TabIndex        =   88
         Top             =   300
         Width           =   8415
         _ExtentX        =   14843
         _ExtentY        =   1085
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
         Begin MSDBCtls.DBCombo dbcPresContDoctor 
            Bindings        =   "frmCustomer.frx":12DE6
            DataField       =   "IssuedByDr"
            DataSource      =   "dtcCusPresCont"
            Height          =   315
            Left            =   4800
            TabIndex        =   109
            Top             =   180
            Width           =   2535
            _ExtentX        =   4471
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "DoctorName"
            BoundColumn     =   "ID"
            Text            =   "dbcPresContDoctor"
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
         Begin SSCalendarWidgets_A.SSDateCombo calPresContDate 
            DataField       =   "IssuedOn"
            DataSource      =   "dtcCusPresCont"
            Height          =   315
            Left            =   960
            TabIndex        =   108
            Top             =   180
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
         Begin Threed.SSCommand SSCommand4 
            Height          =   315
            Left            =   7320
            TabIndex        =   161
            TabStop         =   0   'False
            Top             =   180
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
            Picture         =   "frmCustomer.frx":12E02
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin VB.Label Label23 
            Caption         =   "Issued by Doctor"
            Height          =   195
            Left            =   3480
            TabIndex        =   92
            Top             =   180
            Width           =   1335
         End
         Begin VB.Label Label22 
            Caption         =   "Issued on"
            Height          =   195
            Left            =   120
            TabIndex        =   91
            Top             =   180
            Width           =   735
         End
      End
      Begin Threed.SSFrame SSFrame9 
         Height          =   1035
         Left            =   -74880
         TabIndex        =   89
         Top             =   900
         Width           =   8415
         _ExtentX        =   14843
         _ExtentY        =   1826
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
         Begin VB.TextBox txtContLPupil 
            DataField       =   "LeftPupil"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   6480
            TabIndex        =   125
            Text            =   "Text22"
            Top             =   660
            Width           =   615
         End
         Begin VB.TextBox txtContLCorn 
            DataField       =   "LeftCorn"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   5880
            TabIndex        =   124
            Text            =   "Text21"
            Top             =   660
            Width           =   615
         End
         Begin VB.TextBox txtContLPapl 
            DataField       =   "LeftPalp"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   5280
            TabIndex        =   123
            Text            =   "Text20"
            Top             =   660
            Width           =   615
         End
         Begin VB.TextBox txtContLKreadingH 
            DataField       =   "LeftKReadingH"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   4440
            TabIndex        =   122
            Text            =   "Text19"
            Top             =   660
            Width           =   855
         End
         Begin VB.TextBox txtContLKreadingV 
            DataField       =   "LeftKReadingV"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   3480
            TabIndex        =   121
            Text            =   "Text18"
            Top             =   660
            Width           =   855
         End
         Begin VB.TextBox txtContLAxis 
            DataField       =   "LeftAxis"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   3000
            TabIndex        =   120
            Text            =   "Text17"
            Top             =   660
            Width           =   495
         End
         Begin VB.TextBox txtContLCylinder 
            DataField       =   "LeftCylinder"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   2160
            TabIndex        =   119
            Text            =   "Text16"
            Top             =   660
            Width           =   855
         End
         Begin VB.TextBox txtContLSphere 
            DataField       =   "LeftSphere"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   1440
            TabIndex        =   118
            Text            =   "Text15"
            Top             =   660
            Width           =   735
         End
         Begin VB.TextBox txtContRPupil 
            DataField       =   "RightPupil"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   6480
            TabIndex        =   117
            Text            =   "Text14"
            Top             =   360
            Width           =   615
         End
         Begin VB.TextBox txtContRCorn 
            DataField       =   "RightCorn"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   5880
            TabIndex        =   116
            Text            =   "Text13"
            Top             =   360
            Width           =   615
         End
         Begin VB.TextBox txtContRPapl 
            DataField       =   "RightPalp"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   5280
            TabIndex        =   115
            Text            =   "Text12"
            Top             =   360
            Width           =   615
         End
         Begin VB.TextBox txtContRKreadingH 
            DataField       =   "RightKReadingH"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   4440
            TabIndex        =   114
            Text            =   "Text11"
            Top             =   360
            Width           =   855
         End
         Begin VB.TextBox txtContRKreadingV 
            DataField       =   "RightKReadingV"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   3480
            TabIndex        =   113
            Text            =   "Text10"
            Top             =   360
            Width           =   855
         End
         Begin VB.TextBox txtContRAxis 
            DataField       =   "RightAxis"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   3000
            TabIndex        =   112
            Text            =   "Text9"
            Top             =   360
            Width           =   495
         End
         Begin VB.TextBox txtContRCylinder 
            DataField       =   "RightCylinder"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   2160
            TabIndex        =   111
            Text            =   "Text3"
            Top             =   360
            Width           =   855
         End
         Begin VB.TextBox txtContRSphere 
            DataField       =   "RightSphere"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   1440
            TabIndex        =   110
            Text            =   "Text1"
            ToolTipText     =   "Accepts -20.00 to 20.00, step 0.25"
            Top             =   360
            Width           =   735
         End
         Begin VB.Label Label45 
            Caption         =   "L"
            Height          =   195
            Left            =   1200
            TabIndex        =   101
            Top             =   660
            Width           =   135
         End
         Begin VB.Label Label44 
            Caption         =   "R"
            Height          =   195
            Left            =   1200
            TabIndex        =   100
            Top             =   360
            Width           =   135
         End
         Begin VB.Label Label43 
            Caption         =   "Pupil"
            Height          =   195
            Left            =   6600
            TabIndex        =   99
            Top             =   180
            Width           =   375
         End
         Begin VB.Label Label42 
            Caption         =   "Corn"
            Height          =   195
            Left            =   6000
            TabIndex        =   98
            Top             =   180
            Width           =   375
         End
         Begin VB.Label Label41 
            Caption         =   "Palp"
            Height          =   195
            Left            =   5400
            TabIndex        =   97
            Top             =   180
            Width           =   375
         End
         Begin VB.Label Label40 
            Caption         =   "K-reading"
            Height          =   195
            Left            =   4080
            TabIndex        =   96
            Top             =   180
            Width           =   735
         End
         Begin VB.Label Label39 
            Caption         =   "Axis"
            Height          =   195
            Left            =   3120
            TabIndex        =   95
            Top             =   180
            Width           =   375
         End
         Begin VB.Label Label38 
            Caption         =   "Cylinder"
            Height          =   195
            Left            =   2280
            TabIndex        =   94
            Top             =   180
            Width           =   615
         End
         Begin VB.Label Label24 
            Caption         =   "Sphere"
            Height          =   195
            Left            =   1560
            TabIndex        =   93
            Top             =   180
            Width           =   615
         End
      End
      Begin Threed.SSFrame SSFrame10 
         Height          =   1155
         Left            =   -74880
         TabIndex        =   90
         Top             =   1920
         Width           =   8415
         _ExtentX        =   14843
         _ExtentY        =   2037
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
         Begin VB.TextBox txtContTest 
            DataField       =   "Test"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   5160
            MaxLength       =   56
            TabIndex        =   131
            Text            =   "Text28"
            Top             =   780
            Width           =   3135
         End
         Begin VB.TextBox txtContEvaluation 
            DataField       =   "Evaluation"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   5160
            MaxLength       =   56
            TabIndex        =   130
            Text            =   "Text27"
            Top             =   480
            Width           =   3135
         End
         Begin VB.TextBox txtContReason 
            DataField       =   "Reason"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   5160
            MaxLength       =   56
            TabIndex        =   129
            Text            =   "Text26"
            Top             =   180
            Width           =   3135
         End
         Begin VB.TextBox txtContAllergy 
            DataField       =   "Allergy"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   840
            MaxLength       =   56
            TabIndex        =   128
            Text            =   "Text25"
            Top             =   780
            Width           =   3255
         End
         Begin VB.TextBox txtContMedical 
            DataField       =   "Medical"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   840
            MaxLength       =   56
            TabIndex        =   127
            Text            =   "Text24"
            Top             =   480
            Width           =   3255
         End
         Begin VB.TextBox txtContHistory 
            DataField       =   "History"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   840
            MaxLength       =   56
            TabIndex        =   126
            Text            =   "Text23"
            Top             =   180
            Width           =   3255
         End
         Begin VB.Label Label51 
            Caption         =   "Test"
            Height          =   195
            Left            =   4320
            TabIndex        =   107
            Top             =   780
            Width           =   375
         End
         Begin VB.Label Label50 
            Caption         =   "Evaluation"
            Height          =   195
            Left            =   4320
            TabIndex        =   106
            Top             =   480
            Width           =   855
         End
         Begin VB.Label Label49 
            Caption         =   "Reason"
            Height          =   195
            Left            =   4320
            TabIndex        =   105
            Top             =   240
            Width           =   615
         End
         Begin VB.Label Label48 
            Caption         =   "Allergy"
            Height          =   195
            Left            =   120
            TabIndex        =   104
            Top             =   780
            Width           =   615
         End
         Begin VB.Label Label47 
            Caption         =   "Medical"
            Height          =   195
            Left            =   120
            TabIndex        =   103
            Top             =   480
            Width           =   615
         End
         Begin VB.Label Label46 
            Caption         =   "History"
            Height          =   195
            Left            =   120
            TabIndex        =   102
            Top             =   180
            Width           =   615
         End
      End
      Begin Threed.SSFrame SSFrame11 
         Height          =   615
         Left            =   -74880
         TabIndex        =   132
         Top             =   300
         Width           =   8415
         _ExtentX        =   14843
         _ExtentY        =   1085
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
         Begin MSDBCtls.DBCombo dbcPresLensDoctor 
            Bindings        =   "frmCustomer.frx":133D0
            DataField       =   "IssuedByDr"
            DataSource      =   "dtcCusPresLens"
            Height          =   315
            Left            =   4800
            TabIndex        =   146
            Top             =   180
            Width           =   2535
            _ExtentX        =   4471
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "DoctorName"
            BoundColumn     =   "ID"
            Text            =   "dbcPresLensDoctor"
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
         Begin SSCalendarWidgets_A.SSDateCombo calPresLensDate 
            DataField       =   "IssuedOn"
            DataSource      =   "dtcCusPresLens"
            Height          =   315
            Left            =   960
            TabIndex        =   145
            Top             =   180
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
         Begin Threed.SSCommand SSCommand5 
            Height          =   315
            Left            =   7320
            TabIndex        =   162
            TabStop         =   0   'False
            Top             =   180
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
            Picture         =   "frmCustomer.frx":133EC
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin VB.Label Label53 
            Caption         =   "Issued by Doctor"
            Height          =   255
            Left            =   3480
            TabIndex        =   135
            Top             =   180
            Width           =   1215
         End
         Begin VB.Label Label52 
            Caption         =   "Issued on"
            Height          =   195
            Left            =   120
            TabIndex        =   134
            Top             =   180
            Width           =   735
         End
      End
      Begin Threed.SSFrame SSFrame12 
         Height          =   1035
         Left            =   -74880
         TabIndex        =   133
         Top             =   900
         Width           =   8415
         _ExtentX        =   14843
         _ExtentY        =   1826
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
         Begin VB.TextBox txtLensLAdd 
            DataField       =   "LeftAdd"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   6000
            TabIndex        =   160
            Text            =   "Text42"
            Top             =   660
            Width           =   495
         End
         Begin VB.TextBox txtLensLPrism 
            DataField       =   "LeftPrism"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   5400
            TabIndex        =   159
            Text            =   "Text41"
            Top             =   660
            Width           =   615
         End
         Begin VB.TextBox txtLensLPDNear 
            DataField       =   "LeftPdNear"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   4560
            TabIndex        =   158
            Text            =   "Text40"
            Top             =   660
            Width           =   855
         End
         Begin VB.TextBox txtLensLPDDist 
            DataField       =   "LeftPdDist"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   3840
            TabIndex        =   157
            Text            =   "Text39"
            Top             =   660
            Width           =   735
         End
         Begin VB.TextBox txtLensLAxis 
            DataField       =   "LeftAxis"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   3360
            TabIndex        =   156
            Text            =   "Text38"
            Top             =   660
            Width           =   495
         End
         Begin VB.TextBox txtLensLCylinder 
            DataField       =   "LeftCylinder"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   2640
            TabIndex        =   155
            Text            =   "Text37"
            Top             =   660
            Width           =   735
         End
         Begin VB.TextBox txtLensLSphere 
            DataField       =   "LeftSphere"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   1920
            TabIndex        =   154
            Text            =   "Text36"
            Top             =   660
            Width           =   735
         End
         Begin VB.TextBox txtLensRAdd 
            DataField       =   "RightAdd"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   6000
            TabIndex        =   153
            Text            =   "Text35"
            Top             =   360
            Width           =   495
         End
         Begin VB.TextBox txtLensRPrism 
            DataField       =   "RightPrism"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   5400
            TabIndex        =   152
            Text            =   "Text34"
            Top             =   360
            Width           =   615
         End
         Begin VB.TextBox txtLensRPDNear 
            DataField       =   "RightPdNear"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   4560
            TabIndex        =   151
            Text            =   "Text33"
            Top             =   360
            Width           =   855
         End
         Begin VB.TextBox txtLensRPDDist 
            DataField       =   "RightPdDist"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   3840
            TabIndex        =   150
            Text            =   "Text32"
            Top             =   360
            Width           =   735
         End
         Begin VB.TextBox txtLensRAxis 
            DataField       =   "RightAxis"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   3360
            TabIndex        =   149
            Text            =   "Text31"
            Top             =   360
            Width           =   495
         End
         Begin VB.TextBox txtLensRCylinder 
            DataField       =   "RightCylinder"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   2640
            TabIndex        =   148
            Text            =   "Text30"
            Top             =   360
            Width           =   735
         End
         Begin VB.TextBox txtLensRSphere 
            DataField       =   "RightSphere"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   1920
            TabIndex        =   147
            Text            =   "Text29"
            Top             =   360
            Width           =   735
         End
         Begin VB.Label Label62 
            Caption         =   "L"
            Height          =   195
            Left            =   1680
            TabIndex        =   144
            Top             =   660
            Width           =   135
         End
         Begin VB.Label Label61 
            Caption         =   "R"
            Height          =   195
            Left            =   1680
            TabIndex        =   143
            Top             =   360
            Width           =   135
         End
         Begin VB.Label Label60 
            Caption         =   "Add"
            Height          =   195
            Left            =   6120
            TabIndex        =   142
            Top             =   180
            Width           =   375
         End
         Begin VB.Label Label59 
            Caption         =   "Prism"
            Height          =   195
            Left            =   5520
            TabIndex        =   141
            Top             =   180
            Width           =   375
         End
         Begin VB.Label Label58 
            Caption         =   "PD Near"
            Height          =   195
            Left            =   4680
            TabIndex        =   140
            Top             =   180
            Width           =   615
         End
         Begin VB.Label Label57 
            Caption         =   "PD Dist"
            Height          =   195
            Left            =   3960
            TabIndex        =   139
            Top             =   180
            Width           =   615
         End
         Begin VB.Label Label56 
            Caption         =   "Axis"
            Height          =   195
            Left            =   3480
            TabIndex        =   138
            Top             =   180
            Width           =   375
         End
         Begin VB.Label Label55 
            Caption         =   "Cylinder"
            Height          =   195
            Left            =   2760
            TabIndex        =   137
            Top             =   180
            Width           =   615
         End
         Begin VB.Label Label54 
            Caption         =   "Sphere"
            Height          =   195
            Left            =   2040
            TabIndex        =   136
            Top             =   180
            Width           =   615
         End
      End
      Begin MSDBCtls.DBCombo dbcJobTitle 
         Bindings        =   "frmCustomer.frx":139BA
         DataField       =   "BizJobTitle"
         DataSource      =   "dtcCustomer"
         Height          =   315
         Left            =   -69840
         TabIndex        =   28
         Top             =   360
         Width           =   1935
         _ExtentX        =   3413
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "JobTitle"
         BoundColumn     =   "JobTitleCode"
         Text            =   "dbcJobTitle"
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
      Begin VB.Label Label15 
         Caption         =   "Job Title"
         Height          =   255
         Left            =   -70920
         TabIndex        =   26
         Top             =   360
         Width           =   735
      End
      Begin VB.Label Label14 
         Caption         =   "Company"
         Height          =   255
         Left            =   -74760
         TabIndex        =   25
         Top             =   360
         Width           =   735
      End
   End
   Begin Threed.SSFrame SSFrame13 
      Height          =   30
      Left            =   120
      TabIndex        =   168
      Top             =   5340
      Width           =   10815
      _ExtentX        =   19076
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
      Caption         =   "SSFrame13"
   End
   Begin Threed.SSFrame fraLookup 
      Height          =   1695
      Left            =   120
      TabIndex        =   169
      Top             =   5460
      Width           =   1935
      _ExtentX        =   3413
      _ExtentY        =   2990
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
      Caption         =   "Lookup by"
      Begin VB.TextBox txtSelName 
         Height          =   315
         Left            =   120
         TabIndex        =   173
         TabStop         =   0   'False
         Top             =   1200
         Width           =   1335
      End
      Begin VB.TextBox txtSelPhone 
         Height          =   315
         Left            =   120
         TabIndex        =   171
         TabStop         =   0   'False
         Top             =   540
         Width           =   1335
      End
      Begin Threed.SSCommand cmdFindName 
         Height          =   315
         Left            =   1440
         TabIndex        =   175
         Top             =   1200
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
         Picture         =   "frmCustomer.frx":139D4
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdFindPhone 
         Height          =   315
         Left            =   1440
         TabIndex        =   174
         Top             =   540
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
         Picture         =   "frmCustomer.frx":13F7A
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label65 
         Caption         =   "Customer Full Name"
         Height          =   255
         Left            =   120
         TabIndex        =   172
         Top             =   960
         Width           =   1575
      End
      Begin VB.Label Label64 
         Caption         =   "Phone Number"
         Height          =   255
         Left            =   120
         TabIndex        =   170
         Top             =   300
         Width           =   1215
      End
   End
   Begin MSMask.MaskEdBox mskVIPCode 
      DataField       =   "VIPCode"
      DataSource      =   "dtcCustomer"
      Height          =   255
      Left            =   1200
      TabIndex        =   4
      Top             =   1560
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   450
      _Version        =   393216
      PromptInclude   =   0   'False
      MaxLength       =   8
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Mask            =   "########"
      PromptChar      =   "_"
   End
   Begin MSMask.MaskEdBox mskCustomerCode 
      DataField       =   "ID"
      DataSource      =   "dtcCustomer"
      Height          =   255
      Left            =   1200
      TabIndex        =   2
      TabStop         =   0   'False
      Top             =   1200
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   450
      _Version        =   393216
      BackColor       =   12632256
      PromptInclude   =   0   'False
      MaxLength       =   8
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Mask            =   "########"
      PromptChar      =   "_"
   End
   Begin Threed.SSRibbon cmdSortByLastName 
      Height          =   330
      Left            =   7920
      TabIndex        =   167
      Top             =   5520
      Width           =   330
      _ExtentX        =   582
      _ExtentY        =   582
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmCustomer.frx":14520
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmCustomer.frx":14AC6
   End
   Begin Threed.SSRibbon cmdSortByFirstName 
      Height          =   330
      Left            =   6360
      TabIndex        =   166
      Top             =   5520
      Width           =   330
      _ExtentX        =   582
      _ExtentY        =   582
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmCustomer.frx":15080
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmCustomer.frx":15626
   End
   Begin Threed.SSRibbon cmdSortByVIP 
      Height          =   330
      Left            =   4800
      TabIndex        =   165
      Top             =   5520
      Width           =   330
      _ExtentX        =   582
      _ExtentY        =   582
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmCustomer.frx":15BE0
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmCustomer.frx":16186
   End
   Begin Threed.SSRibbon cmdSortByID 
      Height          =   330
      Left            =   3720
      TabIndex        =   164
      Top             =   5520
      Width           =   330
      _ExtentX        =   582
      _ExtentY        =   582
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmCustomer.frx":16740
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmCustomer.frx":16CE6
   End
   Begin VB.Label Label2 
      Caption         =   "VIP No."
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   1560
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Customer No."
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   1200
      Width           =   975
   End
End
Attribute VB_Name = "frmCustomer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim blnAddNew As Boolean    ' Ture = Current Input Mode is Add a new record


Private Sub cmdFindName_Click()
    Dim strSQL As String
    
    If txtSelName <> "" Then
        ' Lookup dtcCustomer
        Screen.MousePointer = vbHourglass
        strSQL = "SELECT * FROM Customer " _
               & "WHERE FullName LIKE '*" & txtSelName.Text & "*' " _
               & "ORDER BY FullName"
        dtcLookupCustomer.RecordSource = strSQL
        dtcLookupCustomer.Refresh
        If (dtcLookupCustomer.Recordset.BOF And dtcLookupCustomer.Recordset.EOF) Then
            Screen.MousePointer = vbDefault
            MsgBox "No record found!"
        Else
            dtcCustomer.RecordSource = strSQL
            dtcCustomer.Refresh
            dtcCustomer.UpdateControls
            Screen.MousePointer = vbDefault
        End If
    End If
End Sub


Private Sub cmdFindPhone_Click()
    Dim strSQL As String
    
    If txtSelPhone <> "" Then
        ' Lookup dtcCustomer
        Screen.MousePointer = vbHourglass
        strSQL = "SELECT * FROM Customer " _
               & "WHERE BizPhone LIKE '*" & txtSelPhone.Text & "*' " _
               & "Or HomePhone LIKE '*" & txtSelPhone.Text & "*' " _
               & "ORDER BY HomePhone, BizPhone, FullName"
        dtcCustomer.RecordSource = strSQL
        dtcLookupCustomer.RecordSource = strSQL
        dtcLookupCustomer.Refresh
        If (dtcLookupCustomer.Recordset.BOF And dtcLookupCustomer.Recordset.EOF) Then
            Screen.MousePointer = vbDefault
            MsgBox "No record found!"
        Else
            dtcCustomer.Refresh
            dtcCustomer.UpdateControls
            Screen.MousePointer = vbDefault
        End If
    End If
End Sub


Private Sub cmdSortByFirstName_Click(Value As Integer)
    Dim strSQL As String
    If cmdSortByFirstName.Value Then
        strSQL = "SELECT * FROM Customer ORDER BY FirstName ASC, LastName ASC"
    Else
        strSQL = "SELECT * FROM Customer ORDER BY FirstName DESC, LastName ASC"
    End If
    dtcCustomer.RecordSource = strSQL
    dtcCustomer.Refresh
    dtcCustomer.UpdateControls
End Sub


Private Sub cmdSortByID_Click(Value As Integer)
    Dim strSQL As String
    If cmdSortByID.Value Then
        strSQL = "SELECT * FROM Customer ORDER BY ID ASC"
    Else
        strSQL = "SELECT * FROM Customer ORDER BY ID DESC"
    End If
    dtcCustomer.RecordSource = strSQL
    dtcCustomer.Refresh
    dtcCustomer.UpdateControls
End Sub

Private Sub cmdSortByLastName_Click(Value As Integer)
    Dim strSQL As String
    If cmdSortByLastName.Value Then
        strSQL = "SELECT * FROM Customer ORDER BY LastName ASC, FirstName ASC"
    Else
        strSQL = "SELECT * FROM Customer ORDER BY LastName DESC, FirstName ASC"
    End If
    dtcCustomer.RecordSource = strSQL
    dtcCustomer.Refresh
    dtcCustomer.UpdateControls
End Sub

Private Sub cmdSortByVIP_Click(Value As Integer)
    Dim strSQL As String
    If cmdSortByVIP.Value Then
        strSQL = "SELECT * FROM Customer ORDER BY VIPCode ASC"
    Else
        strSQL = "SELECT * FROM Customer ORDER BY VIPCode DESC"
    End If
    dtcCustomer.RecordSource = strSQL
    dtcCustomer.Refresh
    dtcCustomer.UpdateControls
End Sub

Private Sub dbcBizCity_Click(intArea As Integer)
    If dbcBizCity.DataChanged Then
        Call dbcBizCitySync
    End If
'    If intArea = dbcAreaList Then
'        ' Sync dtcBizCity
'        Call dbcBizCitySync
'    End If

End Sub

Private Sub dbcBizCity_GotFocus()
    ' Show Province and Country
    txtSyncBizProvince.Visible = True
    txtSyncBizCountry.Visible = True
    txtSyncBizProvince.ZOrder
    txtSyncBizCountry.ZOrder

    With dbcBizCity
        .SelStart = 0
        .SelLength = Len(.Text)
    End With
End Sub


Private Sub dbcBizCity_LostFocus()
    ' Hide Province and Country
    txtSyncBizProvince.Visible = False
    txtSyncBizCountry.Visible = False

End Sub

Private Sub dbcBizCitySync()
    On Error Resume Next
    Dim strTarget As String
    
    ' Sync dtcBizCity
    strTarget = "Code = " & dbcBizCity.BoundText
    dtcBizCity.Recordset.FindFirst strTarget
    If Not dtcBizCity.Recordset.NoMatch Then
        dtcBizCity.UpdateControls
        ' Fill Supplier fields: Biz Province and Country
        If Not blnAddNew Then dtcCustomer.Recordset.Edit
        dtcCustomer.Recordset.Fields("BizProvince") = dtcBizCity.Recordset.Fields("ProvinceCode")
        dtcCustomer.Recordset.Fields("BizCountry") = dtcBizCity.Recordset.Fields("CountryCode")
        ' Sync dtcBizProvince
        strTarget = "ProvinceCode = '" & dtcBizCity.Recordset.Fields("ProvinceCode") & "'"
        dtcBizProvince.Recordset.FindFirst strTarget
        If Not dtcBizProvince.Recordset.NoMatch Then
            dtcBizProvince.UpdateControls
            txtBizProvince.Text = dtcBizProvince.Recordset.Fields("ProvinceName")
        End If
        ' Sync dtcBizCountry
        strTarget = "CountryCode = '" & dtcBizCity.Recordset.Fields("CountryCode") & "'"
        dtcBizCountry.Recordset.FindFirst strTarget
        If Not dtcBizCountry.Recordset.NoMatch Then
            dtcBizCountry.UpdateControls
            txtBizCountry.Text = dtcBizCountry.Recordset.Fields("CountryName")
        End If
    End If

End Sub

Private Sub dbcCity_Click(intArea As Integer)
    If dbcCity.DataChanged Then
        Call dbcCitySync
    End If
'    If intArea = dbcAreaList Then
'        ' Sync dtcCity, display Province, City, Phone Code
'        Call dbcCitySync
'    End If
End Sub

Private Sub dbcCity_GotFocus()
    ' Show Province and Country
    txtSyncProvince.Visible = True
    txtSyncCountry.Visible = True
    txtSyncProvince.ZOrder
    txtSyncCountry.ZOrder
    
    With dbcCity
        .SelStart = 0
        .SelLength = Len(.Text)
    End With
End Sub


Private Sub dbcCity_LostFocus()
    ' Hide Province and Country
    txtSyncProvince.Visible = False
    txtSyncCountry.Visible = False

End Sub

Private Sub dbcCitySync()
    On Error Resume Next
    ' Sync dtcCity
    Dim strTarget As String

    strTarget = "Code = " & dbcCity.BoundText
    dtcCity.Recordset.FindFirst strTarget
    If Not dtcCity.Recordset.NoMatch Then
        dtcCity.UpdateControls
        ' Fill Supplier fields: Province and Country
        If Not blnAddNew Then dtcCustomer.Recordset.Edit
        dtcCustomer.Recordset.Fields("HomeProvince") = dtcCity.Recordset.Fields("ProvinceCode")
        dtcCustomer.Recordset.Fields("HomeCountry") = dtcCity.Recordset.Fields("CountryCode")
        ' Sync dtcProvince
        strTarget = "ProvinceCode = '" & dtcCity.Recordset.Fields("ProvinceCode") & "'"
        dtcProvince.Recordset.FindFirst strTarget
        If Not dtcProvince.Recordset.NoMatch Then
            dtcProvince.UpdateControls
            txtProvince.Text = dtcProvince.Recordset.Fields("ProvinceName")
        End If
        ' Sync dtcCountry
        strTarget = "CountryCode = '" & dtcCity.Recordset.Fields("CountryCode") & "'"
        dtcCountry.Recordset.FindFirst strTarget
        If Not dtcCountry.Recordset.NoMatch Then
            dtcCountry.UpdateControls
            txtCountry.Text = dtcCountry.Recordset.Fields("CountryName")
        End If
    End If
End Sub


Private Sub dtcCustomer_Reposition()

    Dim strTarget As String
    
    ' Avoid Rreposition if
    ' 1. Customer Table is empty
    ' 2. Adding new record
    ' 3. Overflow BeginOfFile or EndOfFile
    If IsTableEmpty(dtcCustomer.Recordset) Then Exit Sub
    If dtcCustomer.Recordset.EditMode = dbEditAdd Then Exit Sub
    If (dtcCustomer.Recordset.BOF Or dtcCustomer.Recordset.EOF) Then Exit Sub
        
        If dtcCustomer.Recordset!HomeCity <> "" Then
            ' Sync dtcCity
            strTarget = "Code = " & dtcCustomer.Recordset.Fields("HomeCity")
            dtcCity.Recordset.FindFirst strTarget
            If Not dtcCity.Recordset.NoMatch Then _
                dtcCity.UpdateControls
            ' Sync dtcCountry
            strTarget = "CountryCode = '" & dtcCustomer.Recordset.Fields("HomeCountry") & "'"
            dtcCountry.Recordset.FindFirst strTarget
            If Not dtcCountry.Recordset.NoMatch Then _
                dtcCountry.UpdateControls
        End If
        If dtcCustomer.Recordset!BizCity <> "" Then
            ' Sync dtcBizCity
            strTarget = "Code = " & dtcCustomer.Recordset.Fields("BizCity")
            dtcBizCity.Recordset.FindFirst strTarget
            If Not dtcBizCity.Recordset.NoMatch Then _
                dtcBizCity.UpdateControls
            ' Sync dtcBizCountry
            strTarget = "CountryCode = '" & dtcCustomer.Recordset.Fields("BizCountry") & "'"
            dtcBizCountry.Recordset.FindFirst strTarget
            If Not dtcBizCountry.Recordset.NoMatch Then _
                dtcBizCountry.UpdateControls
        End If
        ' Sync Customer Medical Table
        strTarget = "SELECT * FROM CustomerMedical WHERE CustomerID = " & dtcCustomer.Recordset!ID
        dtcCusMedical.RecordSource = strTarget
        dtcCusMedical.Refresh
        dtcCusMedical.UpdateControls
        ' Sync Customer Account Table
        strTarget = "SELECT CustomerID, JointDate FROM CustomerAccounts WHERE CustomerID = " & dtcCustomer.Recordset!ID
        dtcCusAccount.RecordSource = strTarget
        dtcCusAccount.Refresh
        dtcCusAccount.UpdateControls
        ' Sync Customer PresCont Table
        strTarget = "SELECT * FROM CustomerPresContact WHERE CustomerID = " & dtcCustomer.Recordset!ID
        dtcCusPresCont.RecordSource = strTarget
        dtcCusPresCont.Refresh
        dtcCusPresCont.UpdateControls
        ' Sync Customer PresLens Table
        strTarget = "SELECT * FROM CustomerPresLens WHERE CustomerID = " & dtcCustomer.Recordset!ID
        dtcCusPresLens.RecordSource = strTarget
        dtcCusPresLens.Refresh
        dtcCusPresLens.UpdateControls
        ' Sheriden Calender bug work arround
'        If dtcCustomer.Recordset!Birthday <> "" Then _
'            calBirthday.Text = Format(dtcCustomer.Recordset!Birthday, "MM/DD/YYYY")
'        If dtcCusPresLens.Recordset!IssuedOn <> "" Then _
'            calPresLensDate.Text = Format(dtcCusPresLens.Recordset!IssuedOn, "MM/DD/YYYY")
'        If dtcCusPresCont.Recordset!IssuedOn <> "" Then _
'            calPresContDate.Text = Format(dtcCusPresCont.Recordset!IssuedOn, "MM/DD/YYYY")

End Sub

Private Sub dtcCustomer_Validate(intAction As Integer, intSave As Integer)
    ' Don't update the current record if it is a Find action
    If intAction = vbDataActionFind Then
        intSave = False
    End If

End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
    blnAddNew = False
    cmdSortByID.ZOrder
    cmdSortByVIP.ZOrder
    cmdSortByFirstName.ZOrder
    cmdSortByLastName.ZOrder

    ' Determine the status of the Copy button
    Call SetCopyButton
End Sub




Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub mskBizFax_GotFocus()
    Call AutoSelect(mskBizFax)
End Sub

Private Sub mskBizPhone_GotFocus()
    Call AutoSelect(mskBizPhone)
End Sub

Private Sub mskBizPostalCode_GotFocus()
    Call AutoSelect(mskBizPostalCode)
End Sub

Private Sub mskCellular_GotFocus()
    Call AutoSelect(mskCellular)
End Sub

Private Sub mskCustomerCode_GotFocus()
    Call AutoSelect(mskCustomerCode)
End Sub

Private Sub mskCustomerInitial_GotFocus()
    Call AutoSelect(mskCustomerInitial)
End Sub

Private Sub mskHomeFax_GotFocus()
    Call AutoSelect(mskHomeFax)
End Sub

Private Sub mskHomePhone_GotFocus()
    Call AutoSelect(mskHomePhone)
End Sub

Private Sub mskHomePostalCode_GotFocus()
    Call AutoSelect(mskHomePostalCode)
End Sub

Private Sub mskVIPCode_GotFocus()
    Call AutoSelect(mskVIPCode)
End Sub

Private Sub SSCommand1_Click()
    If ofx_IsFormLoaded(frmCity) Then _
        Unload frmCity
    Screen.MousePointer = vbHourglass
    frmCity.Show vbModal
    dtcCity.Refresh
    dtcCity.UpdateControls
    dtcBizCity.Refresh
    dtcBizCity.UpdateControls
End Sub



Private Sub SSCommand2_Click()
    If ofx_IsFormLoaded(frmCity) Then _
        Unload frmCity
    Screen.MousePointer = vbHourglass
    frmCity.Show vbModal
    dtcCity.Refresh
    dtcCity.UpdateControls
    dtcBizCity.Refresh
    dtcBizCity.UpdateControls
End Sub

Private Sub SSCommand3_Click()
    If ofx_IsFormLoaded(frmSalutation) Then _
        Unload frmSalutation
    Screen.MousePointer = vbHourglass
    frmSalutation.Show vbModal
    dtcSalutation.Refresh
    dtcSalutation.UpdateControls
End Sub

Private Sub SSCommand4_Click()
    If ofx_IsFormLoaded(frmDoctor) Then _
        Unload frmDoctor
    Screen.MousePointer = vbHourglass
    frmDoctor.Show vbModal
    dtcDoctorCont.Refresh
    dtcDoctorCont.UpdateControls
    dtcDoctorLens.Refresh
    dtcDoctorLens.UpdateControls
End Sub

Private Sub SSCommand5_Click()
    If ofx_IsFormLoaded(frmDoctor) Then _
        Unload frmDoctor
    Screen.MousePointer = vbHourglass
    frmDoctor.Show vbModal
    dtcDoctorLens.Refresh
    dtcDoctorLens.UpdateControls
    dtcDoctorCont.Refresh
    dtcDoctorCont.UpdateControls
End Sub




Private Sub SSRibbon1_Click(Value As Integer)

End Sub

Private Sub SSRibbon2_Click(Value As Integer)

End Sub

Private Sub tbrTaskButton_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

'    On Error GoTo tbrTaskButton_Click_Err

    Select Case ToolID
        Case "ID_Add"
            blnAddNew = True
            Call DoAdd
        Case "ID_Delete"
            If Not IsTableEmpty(dtcCusMedical.Recordset) Then
                dtcCusMedical.Recordset.Delete
                dtcCusPresLens.Recordset.Delete
                dtcCusPresCont.Recordset.Delete
                dtcCusAccount.Recordset.Delete
            End If
            dtcCustomer.Recordset.Delete
            dtcCustomer.Recordset.MoveNext
            blnAddNew = False
        Case "ID_Undo"
            dtcCustomer.Refresh
            blnAddNew = False
        Case "ID_Save"
            If blnAddNew Then
                dtcCusMedical.Recordset!CustomerID = mskCustomerCode.Text
                dtcCusPresLens.Recordset!CustomerID = mskCustomerCode.Text
                dtcCusPresCont.Recordset!CustomerID = mskCustomerCode.Text
                dtcCusAccount.Recordset!CustomerID = mskCustomerCode.Text
            End If
            dtcCusPresCont.UpdateRecord
            dtcCusPresLens.UpdateRecord
            dtcCusAccount.UpdateRecord
            dtcCusMedical.UpdateRecord
            dtcCustomer.UpdateRecord
            dtcCustomer.Recordset.Bookmark = dtcCustomer.Recordset.LastModified
            blnAddNew = False
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            dtcCustomer.Recordset.MoveFirst
            blnAddNew = False
        Case "ID_Next"
            dtcCustomer.Recordset.MoveNext
            If dtcCustomer.Recordset.EOF Then
                Beep
                dtcCustomer.Recordset.MoveLast
            End If
            blnAddNew = False
        Case "ID_Previous"
            dtcCustomer.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcCustomer.Recordset.BOF Then
                Beep
                dtcCustomer.Recordset.MoveFirst
            End If
            blnAddNew = False
        Case "ID_Last"
            dtcCustomer.Recordset.MoveLast
            blnAddNew = False
        Case "ID_Copy"
            Call DoCopy
    End Select
tbrTaskButton_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
tbrTaskButton_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("tbrTaskButton_Click()", Err)  ' Tutorial Autocode
    Resume tbrTaskButton_Click_Exit

End Sub


Private Sub TDBGrid1_HeadClick(ByVal ColIndex As Integer)

    ' Sort grid by column
    
    Dim strSQL As String
    Screen.MousePointer = ccHourglass
    
    Select Case ColIndex
    Case 0   ' Sort by Customer Number
        strSQL = "SELECT * FROM Customer ORDER BY ID"
    Case 1   ' Sort by VIP Number
        strSQL = "SELECT * FROM Customer ORDER BY VIPCode"
    Case 2   ' Sort by Customer First Name
        strSQL = "SELECT * FROM Customer ORDER BY FirstName, LastName"
    Case 3   ' Sort by Customer Last Name
        strSQL = "SELECT * FROM Customer ORDER BY LastName, FirstName"
    End Select
    
    dtcCustomer.RecordSource = strSQL
    dtcCustomer.Refresh
    dtcCustomer.UpdateControls
    Screen.MousePointer = ccDefault
    
End Sub











Private Sub tmrClearDBComboHiLite_Timer()
'    Call ClearDBComboHiLite(Me)
End Sub

Private Sub txtContLAxis_Change()
    If Not myIsDecimal(txtContLAxis, 0, True) Or _
       Not WithinRange(txtContLAxis, 180, 0, True) Then
        txtContLAxis.SetFocus
    End If
End Sub

Private Sub txtContLAxis_GotFocus()
    Call AutoSelect(txtContLAxis)

End Sub


Private Sub txtContLAxis_LostFocus()
    If Not myIsDecimal(txtContLAxis, 0, True) Or _
       Not WithinRange(txtContLAxis, 180, 0, True) Then
        txtContLAxis.SetFocus
    End If
End Sub

Private Sub txtContLCorn_Change()
    If Not myIsDecimal(txtContLCorn, 2, True) Or _
       Not WithinRange(txtContLCorn, 99.99, 0, True) Then
        txtContLCorn.SetFocus
    End If
End Sub

Private Sub txtContLCorn_GotFocus()
    Call AutoSelect(txtContLCorn)

End Sub


Private Sub txtContLCorn_LostFocus()

    If Not myIsDecimal(txtContLCorn, 2, True) Or _
       Not WithinRange(txtContLCorn, 99.99, 0, True) Then
        txtContLCorn.SetFocus
    End If

End Sub

Private Sub txtContLCylinder_Change()
    If Not myIsDecimal(txtContLCylinder, 2, True) Or _
       Not WithinRange(txtContLCylinder, 0, -6, True) Then
        txtContLCylinder.SetFocus
    End If
End Sub

Private Sub txtContLCylinder_GotFocus()
    Call AutoSelect(txtContLCylinder)

End Sub


Private Sub txtContLCylinder_LostFocus()
    If Not myIsDecimal(txtContLCylinder, 2, True) Or _
       Not WithinRange(txtContLCylinder, 0, -6, True) Then
        txtContLCylinder.SetFocus
    End If
End Sub

Private Sub txtContLKreadingH_Change()
    If Not myIsDecimal(txtContLKreadingH, 2, True) Or _
       Not WithinRange(txtContLKreadingH, 99.99, 0, True) Then
        txtContLKreadingH.SetFocus
    End If
End Sub

Private Sub txtContLKreadingH_GotFocus()
    Call AutoSelect(txtContLKreadingH)

End Sub


Private Sub txtContLKreadingV_Change()
    If Not myIsDecimal(txtContLKreadingV, 2, True) Or _
       Not WithinRange(txtContLKreadingV, 99.99, 0, True) Then
        txtContLKreadingV.SetFocus
    End If
End Sub

Private Sub txtContLKreadingV_GotFocus()
    Call AutoSelect(txtContLKreadingV)

End Sub


Private Sub txtContLKreadingV_LostFocus()
    If Not myIsDecimal(txtContLKreadingV, 2, True) Or _
       Not WithinRange(txtContLKreadingV, 99.99, 0, True) Then
        txtContLKreadingV.SetFocus
    End If
End Sub

Private Sub txtContLPapl_Change()
    If Not myIsDecimal(txtContLPapl, 2, True) Or _
       Not WithinRange(txtContLPapl, 99.99, 0, True) Then
        txtContLPapl.SetFocus
    End If
End Sub

Private Sub txtContLPapl_GotFocus()
    Call AutoSelect(txtContLPapl)

End Sub


Private Sub txtContLPapl_LostFocus()
    If Not myIsDecimal(txtContLPapl, 2, True) Or _
       Not WithinRange(txtContLPapl, 99.99, 0, True) Then
        txtContLPapl.SetFocus
    End If
End Sub

Private Sub txtContLPupil_Change()
    If Not myIsDecimal(txtContLPupil, 2, True) Or _
       Not WithinRange(txtContLPupil, 99.99, 0, True) Then
        txtContLPupil.SetFocus
    End If
End Sub

Private Sub txtContLPupil_GotFocus()
    Call AutoSelect(txtContLPupil)

End Sub


Private Sub txtContLPupil_LostFocus()
    If Not myIsDecimal(txtContLPupil, 2, True) Or _
       Not WithinRange(txtContLPupil, 99.99, 0, True) Then
        txtContLPupil.SetFocus
    End If
End Sub

Private Sub txtContLSphere_Change()
    If Not myIsDecimal(txtContLSphere, 2, True) Or _
       Not WithinRange(txtContLSphere, 20, -20, True) Then
        txtContLSphere.SetFocus
    End If
End Sub

Private Sub txtContLSphere_GotFocus()
    Call AutoSelect(txtContLSphere)

End Sub


Private Sub txtContRAxis_Change()
    If Not myIsDecimal(txtContRAxis, 0, True) Or _
       Not WithinRange(txtContRAxis, 180, 0, True) Then
        txtContRAxis.SetFocus
    End If
End Sub

Private Sub txtContRAxis_GotFocus()
    Call AutoSelect(txtContRAxis)

End Sub


Private Sub txtContRAxis_LostFocus()
    If Not myIsDecimal(txtContRAxis, 0, True) Or _
       Not WithinRange(txtContRAxis, 180, 0, True) Then
        txtContRAxis.SetFocus
    End If
End Sub

Private Sub txtContRCorn_Change()
    If Not myIsDecimal(txtContRCorn, 2, True) Or _
       Not WithinRange(txtContRCorn, 99.99, 0, True) Then
        txtContRCorn.SetFocus
    End If
End Sub

Private Sub txtContRCorn_GotFocus()
    Call AutoSelect(txtContRCorn)

End Sub


Private Sub txtContRCorn_LostFocus()
    If Not myIsDecimal(txtContRCorn, 2, True) Or _
       Not WithinRange(txtContRCorn, 99.99, 0, True) Then
        txtContRCorn.SetFocus
    End If
End Sub

Private Sub txtContRCylinder_Change()
    If Not myIsDecimal(txtContRCylinder, 2, True) Or _
       Not WithinRange(txtContRCylinder, 0, -6, True) Then
        txtContRCylinder.SetFocus
    End If
End Sub

Private Sub txtContRCylinder_GotFocus()
    Call AutoSelect(txtContRCylinder)

End Sub


Private Sub txtContRCylinder_LostFocus()
    If Not myIsDecimal(txtContRCylinder, 2, True) Or _
       Not WithinRange(txtContRCylinder, 0, -6, True) Then
        txtContRCylinder.SetFocus
    End If
End Sub

Private Sub txtContRKreadingH_Change()
    If Not myIsDecimal(txtContRKreadingH, 2, True) Or _
       Not WithinRange(txtContRKreadingH, 99.99, 0, True) Then
        txtContRKreadingH.SetFocus
    End If
End Sub

Private Sub txtContRKreadingH_GotFocus()
    Call AutoSelect(txtContRKreadingH)

End Sub


Private Sub txtContRKreadingH_LostFocus()
    If Not myIsDecimal(txtContRKreadingH, 2, True) Or _
       Not WithinRange(txtContRKreadingH, 99.99, 0, True) Then
        txtContRKreadingH.SetFocus
    End If
End Sub

Private Sub txtContRKreadingV_Change()
    If Not myIsDecimal(txtContRKreadingV, 2, True) Or _
       Not WithinRange(txtContRKreadingV, 99.99, 0, True) Then
        txtContRKreadingV.SetFocus
    End If
End Sub

Private Sub txtContRKreadingV_GotFocus()
    Call AutoSelect(txtContRKreadingV)

End Sub


Private Sub txtContRKreadingV_LostFocus()
    If Not myIsDecimal(txtContRKreadingV, 2, True) Or _
       Not WithinRange(txtContRKreadingV, 99.99, 0, True) Then
        txtContRKreadingV.SetFocus
    End If
End Sub

Private Sub txtContRPapl_Change()
    If Not myIsDecimal(txtContRPapl, 2, True) Or _
       Not WithinRange(txtContRPapl, 99.99, 0, True) Then
        txtContRPapl.SetFocus
    End If
End Sub

Private Sub txtContRPapl_GotFocus()
    Call AutoSelect(txtContRPapl)

End Sub


Private Sub txtContRPapl_LostFocus()
    If Not myIsDecimal(txtContRPapl, 2, True) Or _
       Not WithinRange(txtContRPapl, 99.99, 0, True) Then
        txtContRPapl.SetFocus
    End If
End Sub

Private Sub txtContRPupil_Change()
    If Not myIsDecimal(txtContRPupil, 2, True) Or _
       Not WithinRange(txtContRPupil, 99.99, 0, True) Then
        txtContRPupil.SetFocus
    End If
End Sub

Private Sub txtContRPupil_GotFocus()
    Call AutoSelect(txtContRPupil)

End Sub


Private Sub txtContRPupil_LostFocus()
    If Not myIsDecimal(txtContRPupil, 2, True) Or _
       Not WithinRange(txtContRPupil, 99.99, 0, True) Then
        txtContRPupil.SetFocus
    End If
End Sub

Private Sub txtContRSphere_Change()
    If Not myIsDecimal(txtContRSphere, 2, True) Or _
       Not WithinRange(txtContRSphere, 20, -20, True) Then
        txtContRSphere.SetFocus
    End If
End Sub

Private Sub txtContRSphere_GotFocus()
    Call AutoSelect(txtContRSphere)
End Sub


Private Sub txtContRSphere_LostFocus()
    If Not myIsDecimal(txtContRSphere, 2, True) Or _
       Not WithinRange(txtContRSphere, 20, -20, True) Then
        txtContRSphere.SetFocus
    End If
End Sub


Private Sub txtCustomerFullName_GotFocus()
    ' If AddNew, compose Full Name by First Name + Initial + Last Name
    If (txtCustomerFullName = "") And _
        IsNull(dtcCustomer.Recordset("FullName")) Then
        If (mskCustomerInitial = "") Then
            txtCustomerFullName.Text = txtFirstName.Text & " " & txtLastName
        Else
            txtCustomerFullName.Text = txtFirstName.Text & " " & mskCustomerInitial & " " & txtLastName
        End If
    End If
End Sub


Private Sub txtFirstName_GotFocus()
    Call AutoSelect(txtFirstName)
End Sub


Private Sub txtLastName_GotFocus()
    Call AutoSelect(txtLastName)
End Sub


Private Sub txtLensLAdd_Change()
    If Not myIsDecimal(txtLensLAdd, 2, True) Or _
       Not WithinRange(txtLensLAdd, 9999.99, 0, True) Then
        txtLensLAdd.SetFocus
    End If
End Sub

Private Sub txtLensLAdd_GotFocus()
    Call AutoSelect(txtLensLAdd)
End Sub


Private Sub txtLensLAdd_LostFocus()
    If Not myIsDecimal(txtLensLAdd, 2, True) Or _
       Not WithinRange(txtLensLAdd, 9999.99, 0, True) Then
        txtLensLAdd.SetFocus
    End If

End Sub


Private Sub txtLensLAxis_Change()
    If Not myIsDecimal(txtLensLAxis, 0, True) Or _
       Not WithinRange(txtLensLAxis, 180, 0, True) Then
        txtLensLAxis.SetFocus
    End If
End Sub

Private Sub txtLensLAxis_GotFocus()
    Call AutoSelect(txtLensLAxis)
End Sub


Private Sub txtLensLAxis_LostFocus()
    If Not myIsDecimal(txtLensLAxis, 0, True) Or _
       Not WithinRange(txtLensLAxis, 180, 0, True) Then
        txtLensLAxis.SetFocus
    End If
End Sub


Private Sub txtLensLCylinder_Change()
    If Not myIsDecimal(txtLensLCylinder, 2, True) Or _
       Not WithinRange(txtLensLCylinder, 0, -6, True) Then
        txtLensLCylinder.SetFocus
    End If
End Sub

Private Sub txtLensLCylinder_GotFocus()
    Call AutoSelect(txtLensLCylinder)
End Sub


Private Sub txtLensLCylinder_LostFocus()
    If Not myIsDecimal(txtLensLCylinder, 2, True) Or _
       Not WithinRange(txtLensLCylinder, 0, -6, True) Then
        txtLensLCylinder.SetFocus
    End If
End Sub


Private Sub txtLensLPDDist_Change()
    If Not myIsDecimal(txtLensLPDDist, 2, True) Or _
       Not WithinRange(txtLensLPDDist, 99.99, 0, True) Then
        txtLensLPDDist.SetFocus
    End If
End Sub

Private Sub txtLensLPDDist_GotFocus()
    Call AutoSelect(txtLensLPDDist)
End Sub


Private Sub txtLensLPDDist_LostFocus()
    If Not myIsDecimal(txtLensLPDDist, 2, True) Or _
       Not WithinRange(txtLensLPDDist, 99.99, 0, True) Then
        txtLensLPDDist.SetFocus
    End If
End Sub


Private Sub txtLensLPDNear_Change()
    If Not myIsDecimal(txtLensLPDNear, 2, True) Or _
       Not WithinRange(txtLensLPDNear, 99.99, 0, True) Then
        txtLensLPDNear.SetFocus
    End If
End Sub

Private Sub txtLensLPDNear_GotFocus()
    Call AutoSelect(txtLensLPDNear)
End Sub


Private Sub txtLensLPDNear_LostFocus()
    If Not myIsDecimal(txtLensLPDNear, 2, True) Or _
       Not WithinRange(txtLensLPDNear, 99.99, 0, True) Then
        txtLensLPDNear.SetFocus
    End If
End Sub


Private Sub txtLensLPrism_Change()
    If Not myIsDecimal(txtLensLPrism, 1, True) Or _
       Not WithinRange(txtLensLPrism, 10, 0, True) Then
        txtLensLPrism.SetFocus
    End If
End Sub

Private Sub txtLensLPrism_GotFocus()
    Call AutoSelect(txtLensLPrism)
End Sub


Private Sub txtLensLPrism_LostFocus()
    If Not myIsDecimal(txtLensLPrism, 1, True) Or _
       Not WithinRange(txtLensLPrism, 10, 0, True) Then
        txtLensLPrism.SetFocus
    End If
End Sub


Private Sub txtLensLSphere_Change()
    If Not myIsDecimal(txtLensLSphere, 2, True) Or _
       Not WithinRange(txtLensLSphere, 20, -20, True) Then
        txtLensLSphere.SetFocus
    End If
End Sub

Private Sub txtLensLSphere_GotFocus()
    Call AutoSelect(txtLensLSphere)
End Sub


Private Sub txtLensLSphere_LostFocus()
    If Not myIsDecimal(txtLensLSphere, 2, True) Or _
       Not WithinRange(txtLensLSphere, 20, -20, True) Then
        txtLensLSphere.SetFocus
    End If
End Sub


Private Sub txtLensRAdd_Change()
    If Not myIsDecimal(txtLensRAdd, 2, True) Or _
       Not WithinRange(txtLensRAdd, 9999.99, 0, True) Then
        txtLensRAdd.SetFocus
    End If
End Sub

Private Sub txtLensRAdd_GotFocus()
    Call AutoSelect(txtLensRAdd)
End Sub


Private Sub txtLensRAdd_LostFocus()
    If Not myIsDecimal(txtLensRAdd, 2, True) Or _
       Not WithinRange(txtLensRAdd, 9999.99, 0, True) Then
        txtLensRAdd.SetFocus
    End If
End Sub


Private Sub txtLensRAxis_Change()
    If Not myIsDecimal(txtLensRAxis, 0, True) Or _
       Not WithinRange(txtLensRAxis, 180, 0, True) Then
        txtLensRAxis.SetFocus
    End If
End Sub

Private Sub txtLensRAxis_GotFocus()
    Call AutoSelect(txtLensRAxis)
End Sub


Private Sub txtLensRAxis_LostFocus()
    If Not myIsDecimal(txtLensRAxis, 0, True) Or _
       Not WithinRange(txtLensRAxis, 180, 0, True) Then
        txtLensRAxis.SetFocus
    End If
End Sub


Private Sub txtLensRCylinder_Change()
    If Not myIsDecimal(txtLensRCylinder, 2, True) Or _
       Not WithinRange(txtLensRCylinder, 0, -6, True) Then
        txtLensRCylinder.SetFocus
    End If
End Sub

Private Sub txtLensRCylinder_GotFocus()
    Call AutoSelect(txtLensRCylinder)
End Sub


Private Sub txtLensRCylinder_LostFocus()
    If Not myIsDecimal(txtLensRCylinder, 2, True) Or _
       Not WithinRange(txtLensRCylinder, 0, -6, True) Then
        txtLensRCylinder.SetFocus
    End If
End Sub


Private Sub txtLensRPDDist_Change()
    If Not myIsDecimal(txtLensRPDDist, 2, True) Or _
       Not WithinRange(txtLensRPDDist, 99.99, 0, True) Then
        txtLensRPDDist.SetFocus
    End If
End Sub

Private Sub txtLensRPDDist_GotFocus()
    Call AutoSelect(txtLensRPDDist)
End Sub


Private Sub txtLensRPDDist_LostFocus()
    If Not myIsDecimal(txtLensRPDDist, 2, True) Or _
       Not WithinRange(txtLensRPDDist, 99.99, 0, True) Then
        txtLensRPDDist.SetFocus
    End If
End Sub


Private Sub txtLensRPDNear_Change()
    If Not myIsDecimal(txtLensRPDNear, 2, True) Or _
       Not WithinRange(txtLensRPDNear, 99.99, 0, True) Then
        txtLensRPDNear.SetFocus
    End If
End Sub

Private Sub txtLensRPDNear_GotFocus()
    Call AutoSelect(txtLensRPDNear)
End Sub


Private Sub txtLensRPDNear_LostFocus()
    If Not myIsDecimal(txtLensRPDNear, 2, True) Or _
       Not WithinRange(txtLensRPDNear, 99.99, 0, True) Then
        txtLensRPDNear.SetFocus
    End If
End Sub


Private Sub txtLensRPrism_Change()
    If Not myIsDecimal(txtLensRPrism, 1, True) Or _
       Not WithinRange(txtLensRPrism, 10, 0, True) Then
        txtLensRPrism.SetFocus
    End If
End Sub

Private Sub txtLensRPrism_GotFocus()
    Call AutoSelect(txtLensRPrism)
End Sub


Private Sub txtLensRPrism_LostFocus()
    If Not myIsDecimal(txtLensRPrism, 1, True) Or _
       Not WithinRange(txtLensRPrism, 10, 0, True) Then
        txtLensRPrism.SetFocus
    End If
End Sub


Private Sub txtLensRSphere_Change()
    If Not myIsDecimal(txtLensRSphere, 2, True) Or _
       Not WithinRange(txtLensRSphere, 20, -20, True) Then
        txtLensRSphere.SetFocus
    End If
End Sub


Private Sub txtLensRSphere_GotFocus()
    Call AutoSelect(txtLensRSphere)
End Sub


Private Sub txtLensRSphere_LostFocus()
    If Not myIsDecimal(txtLensRSphere, 2, True) Or _
       Not WithinRange(txtLensRSphere, 20, -20, True) Then
        txtLensRSphere.SetFocus
    End If
End Sub



Private Sub DoAdd()
    With dtcCustomer.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    dtcCustomer.Recordset.AddNew
    dtcCusMedical.Recordset.AddNew
    dtcCusPresLens.Recordset.AddNew
    dtcCusPresCont.Recordset.AddNew
    dtcCusAccount.Recordset.AddNew
    calJointDate.Date = Date
    mskVIPCode.SetFocus
End Sub

Private Sub DoCopy()
    ' 1st priority is SalesOrder
    If ofx_IsFormLoaded(frmSalesOrder) Then
        frmSalesOrder.txtCustomerName.Tag = dtcCustomer.Recordset!ID
        frmSalesOrder.txtCustomerName.Text = dtcCustomer.Recordset!FullName
        MsgBox "Customer " & dtcCustomer.Recordset!FullName & " is copied"
    End If
    Unload Me
End Sub

' Determine the status of the Copy button
' Visible if Receiver is found, otherwise invisible
' Receiver could be: frmSalesOrder, frmStockReceived
Private Sub SetCopyButton()
    If ofx_IsFormLoaded(frmSalesOrder) Then
        tbrTaskButton.Buttons(8).Visible = True
    Else
        tbrTaskButton.Buttons(8).Visible = False
    End If
End Sub

Private Sub txtSelName_GotFocus()
    Call AutoSelect(txtSelName)

End Sub


Private Sub txtSelName_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindName_Click
        KeyAscii = 0
    End If
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



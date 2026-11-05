VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{B074BC93-5A5B-11CE-98BD-0000C0E6B88E}#2.0#0"; "sstabs32.ocx"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmStaff 
   Caption         =   "Staff"
   ClientHeight    =   6090
   ClientLeft      =   1695
   ClientTop       =   2055
   ClientWidth     =   8955
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6090
   ScaleWidth      =   8955
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Bindings        =   "frmStaff.frx":0000
      Height          =   1455
      Left            =   4680
      OleObjectBlob   =   "frmStaff.frx":0017
      TabIndex        =   54
      TabStop         =   0   'False
      Top             =   1560
      Width           =   4215
   End
   Begin VB.Data dtcStaffHistory 
      Caption         =   "StaffHistory"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   2880
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "StaffHistory"
      Top             =   1200
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcSelCity 
      Caption         =   "SelCity"
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
      RecordSource    =   "City"
      Top             =   1200
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcCity 
      Caption         =   "City"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   5400
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "qryCityFullList"
      Top             =   1080
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcMaritalStatus 
      Caption         =   "MaritalStatus"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   3600
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "MaritalStatus"
      Top             =   1080
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcPayPeriod 
      Caption         =   "PayPeriod"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   5400
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "PayPeriod"
      Top             =   3000
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.Data dtcPayPer 
      Caption         =   "PayPer"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   3720
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "PayPer"
      Top             =   3000
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.Data dtcJobNature 
      Caption         =   "JobNature"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   7080
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "JobNature"
      Top             =   3000
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.Data dtcJobTitle 
      Caption         =   "JobTitle"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   7200
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "JobTitle"
      Top             =   1080
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.Data dtcStaff 
      Caption         =   "Staff"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   1920
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Staff"
      Top             =   1080
      Visible         =   0   'False
      Width           =   1695
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   0
      Width           =   8955
      _Version        =   131073
      _ExtentX        =   15796
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
      ToolsetPicture  =   "frmStaff.frx":1EE8
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
      MouseIcon       =   "frmStaff.frx":F77A
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   1575
      Left            =   120
      TabIndex        =   2
      Top             =   1440
      Width           =   4455
      _ExtentX        =   7858
      _ExtentY        =   2778
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
      Caption         =   "Staff Name"
      Begin VB.Timer tmrClearDBComboHiLite 
         Interval        =   100
         Left            =   3840
         Top             =   1080
      End
      Begin VB.TextBox txtLastName 
         DataField       =   "StaffLastName"
         DataSource      =   "dtcStaff"
         Height          =   285
         Left            =   2640
         TabIndex        =   5
         Top             =   600
         Width           =   1695
      End
      Begin VB.TextBox txtFirstName 
         DataField       =   "StaffFirstName"
         DataSource      =   "dtcStaff"
         Height          =   285
         Left            =   120
         TabIndex        =   3
         Top             =   600
         Width           =   1695
      End
      Begin MSDBCtls.DBCombo dbcStaffFullName 
         Bindings        =   "frmStaff.frx":F796
         DataField       =   "StaffFullName"
         DataSource      =   "dtcStaff"
         Height          =   315
         Left            =   120
         TabIndex        =   6
         Top             =   1200
         Width           =   2295
         _ExtentX        =   4048
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "StaffFullName"
         BoundColumn     =   "StaffFullName"
         Text            =   "dbcStaffFullName"
      End
      Begin MSMask.MaskEdBox mskStaffInitial 
         DataField       =   "StaffInitial"
         DataSource      =   "dtcStaff"
         Height          =   255
         Left            =   2040
         TabIndex        =   4
         Top             =   600
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   450
         _Version        =   393216
         PromptInclude   =   0   'False
         MaxLength       =   2
         Mask            =   ">aa"
         PromptChar      =   "_"
      End
      Begin VB.Label Label5 
         Caption         =   "Full Name"
         Height          =   255
         Left            =   120
         TabIndex        =   11
         Top             =   960
         Width           =   855
      End
      Begin VB.Label Label4 
         Caption         =   "Last Name"
         Height          =   255
         Left            =   2640
         TabIndex        =   10
         Top             =   360
         Width           =   855
      End
      Begin VB.Label Label3 
         Caption         =   "Initial"
         Height          =   255
         Left            =   2040
         TabIndex        =   9
         Top             =   360
         Width           =   375
      End
      Begin VB.Label Label2 
         Caption         =   "First Name"
         Height          =   255
         Left            =   120
         TabIndex        =   8
         Top             =   360
         Width           =   855
      End
   End
   Begin SSDesignerWidgetsTabs.SSIndexTab SSIndexTab1 
      Height          =   2895
      Left            =   120
      TabIndex        =   12
      Top             =   3120
      Width           =   8655
      _Version        =   131078
      _ExtentX        =   15266
      _ExtentY        =   5106
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
      Tab             =   1
      TabDefault      =   0
      TabVisibleLast  =   1
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
      Tabs(0).Pages(0).CtlCount=   16
      Tabs(0).Pages(0).CtlEnabled=   0   'False
      Tabs(0).Pages(0).Ctl(0)=   "txtPassword"
      Tabs(0).Pages(0).Ctl(1)=   "SSFrame2"
      Tabs(0).Pages(0).Ctl(2)=   "SSFrame3"
      Tabs(0).Pages(0).Ctl(3)=   "SSCommand2"
      Tabs(0).Pages(0).Ctl(4)=   "SSCommand1"
      Tabs(0).Pages(0).Ctl(5)=   "calDateLeaved"
      Tabs(0).Pages(0).Ctl(6)=   "calDateHired"
      Tabs(0).Pages(0).Ctl(7)=   "mskSecurityLevel"
      Tabs(0).Pages(0).Ctl(8)=   "dbcJobNature"
      Tabs(0).Pages(0).Ctl(9)=   "dbcJobTitle"
      Tabs(0).Pages(0).Ctl(10)=   "Label17"
      Tabs(0).Pages(0).Ctl(11)=   "Label10"
      Tabs(0).Pages(0).Ctl(12)=   "Label9"
      Tabs(0).Pages(0).Ctl(13)=   "Label8"
      Tabs(0).Pages(0).Ctl(14)=   "Label7"
      Tabs(0).Pages(0).Ctl(15)=   "Label6"
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
      Tabs(1).Pages(0).CtlCount=   2
      Tabs(1).Pages(0).CtlEnabled=   -1  'True
      Tabs(1).Pages(0).Ctl(0)=   "SSFrame6"
      Tabs(1).Pages(0).Ctl(1)=   "SSFrame4"
      Tabs(1).Tag     =   ""
      Tabs(1).Caption =   "Personal"
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
      Begin VB.TextBox txtPassword 
         DataField       =   "Password"
         DataSource      =   "dtcStaff"
         Height          =   315
         Left            =   -73800
         MaxLength       =   10
         TabIndex        =   20
         Top             =   1380
         Width           =   1455
      End
      Begin Threed.SSFrame SSFrame2 
         Height          =   1455
         Left            =   -71520
         TabIndex        =   25
         Top             =   360
         Width           =   1935
         _ExtentX        =   3413
         _ExtentY        =   2566
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
         Caption         =   "Salary"
         Begin MSMask.MaskEdBox mskBasicSalary 
            DataField       =   "SalaryBasic"
            DataSource      =   "dtcStaff"
            Height          =   255
            Left            =   720
            TabIndex        =   27
            Top             =   240
            Width           =   1095
            _ExtentX        =   1931
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   10
            Format          =   "$#,###.00"
            PromptChar      =   "_"
         End
         Begin MSDBCtls.DBCombo dbcPayPeriod 
            Bindings        =   "frmStaff.frx":F7AD
            DataField       =   "SalaryPayPeriod"
            DataSource      =   "dtcStaff"
            Height          =   315
            Left            =   720
            TabIndex        =   31
            Top             =   960
            Width           =   1095
            _ExtentX        =   1931
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "Name"
            BoundColumn     =   "Code"
            Text            =   "dbcPayPeriod"
         End
         Begin MSDBCtls.DBCombo dbcPayPer 
            Bindings        =   "frmStaff.frx":F7C8
            DataField       =   "SalaryPer"
            DataSource      =   "dtcStaff"
            Height          =   315
            Left            =   720
            TabIndex        =   29
            Top             =   600
            Width           =   1095
            _ExtentX        =   1931
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "Name"
            BoundColumn     =   "Code"
            Text            =   "dbcPayPer"
         End
         Begin VB.Label Label13 
            Caption         =   "Pay Period:"
            Height          =   375
            Left            =   120
            TabIndex        =   30
            Top             =   960
            Width           =   615
         End
         Begin VB.Label Label12 
            Caption         =   "Per"
            Height          =   255
            Left            =   120
            TabIndex        =   28
            Top             =   600
            Width           =   375
         End
         Begin VB.Label Label11 
            Caption         =   "Basic:"
            Height          =   255
            Left            =   120
            TabIndex        =   26
            Top             =   240
            Width           =   495
         End
      End
      Begin Threed.SSFrame SSFrame3 
         Height          =   1455
         Left            =   -69480
         TabIndex        =   32
         Top             =   360
         Width           =   1815
         _ExtentX        =   3201
         _ExtentY        =   2566
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
         Caption         =   "Commission Rates"
         Begin VB.TextBox txtCommGeneral 
            DataField       =   "CommissionGeneral"
            DataSource      =   "dtcStaff"
            Height          =   285
            Left            =   840
            TabIndex        =   38
            Top             =   960
            Width           =   855
         End
         Begin VB.TextBox txtCommBonus 
            DataField       =   "CommissionBonus"
            DataSource      =   "dtcStaff"
            Height          =   285
            Left            =   840
            TabIndex        =   37
            Top             =   600
            Width           =   855
         End
         Begin VB.TextBox txtCommBasic 
            DataField       =   "CommissionRate"
            DataSource      =   "dtcStaff"
            Height          =   285
            Left            =   840
            TabIndex        =   36
            Top             =   240
            Width           =   855
         End
         Begin VB.Label Label16 
            Caption         =   "General:"
            Height          =   255
            Left            =   120
            TabIndex        =   35
            Top             =   960
            Width           =   735
         End
         Begin VB.Label Label15 
            Caption         =   "Bonus:"
            Height          =   255
            Left            =   120
            TabIndex        =   34
            Top             =   600
            Width           =   735
         End
         Begin VB.Label Label14 
            Caption         =   "Basic:"
            Height          =   255
            Left            =   120
            TabIndex        =   33
            Top             =   240
            Width           =   615
         End
      End
      Begin Threed.SSFrame SSFrame4 
         Height          =   2415
         Left            =   3000
         TabIndex        =   43
         Top             =   360
         Width           =   5535
         _ExtentX        =   9763
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
         Caption         =   "Home Address"
         Begin VB.TextBox Text9 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CountryName"
            DataSource      =   "dtcCity"
            Height          =   285
            Left            =   1080
            Locked          =   -1  'True
            TabIndex        =   68
            TabStop         =   0   'False
            Text            =   "Text9"
            Top             =   1560
            Width           =   1935
         End
         Begin VB.TextBox Text8 
            BackColor       =   &H00C0C0C0&
            DataField       =   "ProvinceName"
            DataSource      =   "dtcCity"
            Height          =   285
            Left            =   1080
            Locked          =   -1  'True
            TabIndex        =   67
            TabStop         =   0   'False
            Text            =   "Text8"
            Top             =   1200
            Width           =   1935
         End
         Begin VB.TextBox txtSyncCountry 
            BackColor       =   &H0000FFFF&
            DataField       =   "CountryName"
            DataSource      =   "dtcCity"
            Height          =   285
            Left            =   3000
            TabIndex        =   66
            Text            =   "Text9"
            Top             =   1140
            Visible         =   0   'False
            Width           =   1575
         End
         Begin VB.TextBox txtSyncProvince 
            BackColor       =   &H0000FFFF&
            DataField       =   "ProvinceName"
            DataSource      =   "dtcCity"
            Height          =   285
            Left            =   3000
            TabIndex        =   65
            Text            =   "Text8"
            Top             =   840
            Visible         =   0   'False
            Width           =   1575
         End
         Begin VB.TextBox Text7 
            DataField       =   "HomeAddress"
            DataSource      =   "dtcStaff"
            Height          =   555
            Left            =   1080
            MaxLength       =   128
            MultiLine       =   -1  'True
            TabIndex        =   48
            Top             =   240
            Width           =   2295
         End
         Begin Threed.SSFrame SSFrame5 
            Height          =   2175
            Left            =   3480
            TabIndex        =   56
            Top             =   120
            Width           =   1935
            _ExtentX        =   3413
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
            Caption         =   "Phone"
            Begin VB.TextBox Text2 
               BackColor       =   &H00C0C0C0&
               DataField       =   "CityPhoneCode"
               DataSource      =   "dtcCity"
               Height          =   285
               Left            =   1200
               Locked          =   -1  'True
               TabIndex        =   62
               TabStop         =   0   'False
               Text            =   "Text2"
               Top             =   720
               Width           =   615
            End
            Begin VB.TextBox Text1 
               BackColor       =   &H00C0C0C0&
               DataField       =   "CountryPhoneCode"
               DataSource      =   "dtcCity"
               Height          =   285
               Left            =   1200
               Locked          =   -1  'True
               TabIndex        =   61
               TabStop         =   0   'False
               Text            =   "Text1"
               Top             =   360
               Width           =   615
            End
            Begin MSMask.MaskEdBox mskHomeFax 
               DataField       =   "HomeFax"
               DataSource      =   "dtcStaff"
               Height          =   255
               Left            =   720
               TabIndex        =   64
               Top             =   1440
               Width           =   1095
               _ExtentX        =   1931
               _ExtentY        =   450
               _Version        =   393216
               PromptInclude   =   0   'False
               MaxLength       =   9
               Mask            =   "### #####"
               PromptChar      =   "_"
            End
            Begin MSMask.MaskEdBox mskHomePhone 
               DataField       =   "HomePhone"
               DataSource      =   "dtcStaff"
               Height          =   255
               Left            =   720
               TabIndex        =   63
               Top             =   1080
               Width           =   1095
               _ExtentX        =   1931
               _ExtentY        =   450
               _Version        =   393216
               PromptInclude   =   0   'False
               MaxLength       =   9
               Mask            =   "### #####"
               PromptChar      =   "_"
            End
            Begin VB.Label Label29 
               Caption         =   "Fax"
               Height          =   255
               Left            =   120
               TabIndex        =   60
               Top             =   1440
               Width           =   375
            End
            Begin VB.Label Label28 
               Caption         =   "Phone"
               Height          =   255
               Left            =   120
               TabIndex        =   59
               Top             =   1080
               Width           =   615
            End
            Begin VB.Label Label26 
               Caption         =   "City Code"
               Height          =   255
               Left            =   120
               TabIndex        =   58
               Top             =   720
               Width           =   735
            End
            Begin VB.Label Label25 
               Caption         =   "Country Code"
               Height          =   255
               Left            =   120
               TabIndex        =   57
               Top             =   360
               Width           =   975
            End
         End
         Begin MSMask.MaskEdBox mskPostalCode 
            DataField       =   "HomePostalCode"
            DataSource      =   "dtcStaff"
            Height          =   315
            Left            =   1080
            TabIndex        =   50
            Top             =   1920
            Width           =   855
            _ExtentX        =   1508
            _ExtentY        =   556
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   7
            Mask            =   ">a#a#a##"
            PromptChar      =   "_"
         End
         Begin MSDBCtls.DBCombo dbcCity 
            Bindings        =   "frmStaff.frx":F7E0
            DataField       =   "HomeCity"
            DataSource      =   "dtcStaff"
            Height          =   315
            Left            =   1080
            TabIndex        =   49
            Top             =   840
            Width           =   1935
            _ExtentX        =   3413
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "CityName"
            BoundColumn     =   "Code"
            Text            =   "dbcCity"
         End
         Begin Threed.SSCommand SSCommand3 
            Height          =   315
            Left            =   3000
            TabIndex        =   53
            TabStop         =   0   'False
            Top             =   840
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
            Picture         =   "frmStaff.frx":F7F9
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin VB.Label Label27 
            Caption         =   "Country"
            Height          =   195
            Left            =   120
            TabIndex        =   55
            Top             =   1560
            Width           =   735
         End
         Begin VB.Label Label24 
            Caption         =   "Postal Code"
            Height          =   255
            Left            =   120
            TabIndex        =   47
            Top             =   1920
            Width           =   855
         End
         Begin VB.Label Label23 
            Caption         =   "Province"
            Height          =   255
            Left            =   120
            TabIndex        =   46
            Top             =   1200
            Width           =   735
         End
         Begin VB.Label Label22 
            Caption         =   "City"
            Height          =   255
            Left            =   120
            TabIndex        =   45
            Top             =   840
            Width           =   375
         End
         Begin VB.Label Label21 
            Caption         =   "Street"
            Height          =   255
            Left            =   120
            TabIndex        =   44
            Top             =   240
            Width           =   495
         End
      End
      Begin Threed.SSFrame SSFrame6 
         Height          =   2415
         Left            =   120
         TabIndex        =   69
         Top             =   360
         Width           =   2775
         _ExtentX        =   4895
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
         Caption         =   "General"
         Begin VB.ComboBox dblSex 
            DataField       =   "Sex"
            DataSource      =   "dtcStaff"
            Height          =   315
            ItemData        =   "frmStaff.frx":FDC7
            Left            =   1200
            List            =   "frmStaff.frx":FDD1
            TabIndex        =   40
            Text            =   "Combo1"
            Top             =   540
            Width           =   495
         End
         Begin MSMask.MaskEdBox mskSIN 
            DataField       =   "SIN"
            DataSource      =   "dtcStaff"
            Height          =   255
            Left            =   1200
            TabIndex        =   39
            Top             =   240
            Width           =   1215
            _ExtentX        =   2143
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   11
            Mask            =   "### ### ###"
            PromptChar      =   "_"
         End
         Begin MSDBCtls.DBCombo dbcMaritalStatus 
            Bindings        =   "frmStaff.frx":FDDB
            DataField       =   "MaritalStatus"
            DataSource      =   "dtcStaff"
            Height          =   315
            Left            =   1200
            TabIndex        =   41
            Top             =   900
            Width           =   1215
            _ExtentX        =   2143
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "MaritalStatus"
            BoundColumn     =   "Code"
            Text            =   "dbcMaritalStatus"
         End
         Begin SSCalendarWidgets_A.SSDateCombo calBirthday 
            DataField       =   "Birthday"
            DataSource      =   "dtcStaff"
            Height          =   315
            Left            =   1200
            TabIndex        =   42
            Top             =   1260
            Width           =   1455
            _Version        =   65543
            _ExtentX        =   2566
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
         End
         Begin VB.Label Label31 
            Caption         =   "SIN"
            Height          =   255
            Left            =   120
            TabIndex        =   73
            Top             =   240
            Width           =   375
         End
         Begin VB.Label Label19 
            Caption         =   "Sex"
            Height          =   255
            Left            =   120
            TabIndex        =   72
            Top             =   540
            Width           =   375
         End
         Begin VB.Label Label20 
            Caption         =   "Marital Status"
            Height          =   195
            Left            =   120
            TabIndex        =   71
            Top             =   900
            Width           =   975
         End
         Begin VB.Label Label30 
            Caption         =   "Birthday"
            Height          =   255
            Left            =   120
            TabIndex        =   70
            Top             =   1260
            Width           =   615
         End
      End
      Begin SSCalendarWidgets_A.SSDateCombo calDateLeaved 
         DataField       =   "DateLeaved"
         DataSource      =   "dtcStaff"
         Height          =   255
         Left            =   -73800
         TabIndex        =   24
         Top             =   2040
         Width           =   1455
         _Version        =   65543
         _ExtentX        =   2566
         _ExtentY        =   450
         _StockProps     =   93
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         BeginProperty DropDownFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
      End
      Begin SSCalendarWidgets_A.SSDateCombo calDateHired 
         DataField       =   "DateHired"
         DataSource      =   "dtcStaff"
         Height          =   255
         Left            =   -73800
         TabIndex        =   22
         Top             =   1740
         Width           =   1455
         _Version        =   65543
         _ExtentX        =   2566
         _ExtentY        =   450
         _StockProps     =   93
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         BeginProperty DropDownFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
      End
      Begin MSMask.MaskEdBox mskSecurityLevel 
         DataField       =   "SecurityLevel"
         DataSource      =   "dtcStaff"
         Height          =   255
         Left            =   -73800
         TabIndex        =   18
         Top             =   1080
         Width           =   255
         _ExtentX        =   450
         _ExtentY        =   450
         _Version        =   393216
         PromptInclude   =   0   'False
         MaxLength       =   1
         Mask            =   "#"
         PromptChar      =   "_"
      End
      Begin MSDBCtls.DBCombo dbcJobNature 
         Bindings        =   "frmStaff.frx":FDFA
         DataField       =   "JobNature"
         DataSource      =   "dtcStaff"
         Height          =   315
         Left            =   -73800
         TabIndex        =   16
         Top             =   720
         Width           =   1815
         _ExtentX        =   3201
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "Name"
         BoundColumn     =   "Code"
         Text            =   "dbcJobNature"
      End
      Begin MSDBCtls.DBCombo dbcJobTitle 
         Bindings        =   "frmStaff.frx":FE15
         DataField       =   "JobTitle"
         DataSource      =   "dtcStaff"
         Height          =   315
         Left            =   -73800
         TabIndex        =   14
         Top             =   360
         Width           =   1815
         _ExtentX        =   3201
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "JobTitle"
         BoundColumn     =   "JobTitleCode"
         Text            =   "dbcJobTitle"
      End
      Begin Threed.SSCommand SSCommand2 
         Height          =   315
         Left            =   -72000
         TabIndex        =   52
         Top             =   720
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
         Picture         =   "frmStaff.frx":FE2F
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand SSCommand1 
         Height          =   315
         Left            =   -72000
         TabIndex        =   51
         Top             =   360
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
         Picture         =   "frmStaff.frx":103FD
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label17 
         Caption         =   "Password"
         Height          =   255
         Left            =   -74880
         TabIndex        =   19
         Top             =   1380
         Width           =   855
      End
      Begin VB.Label Label10 
         Caption         =   "Date Leaved:"
         Height          =   255
         Left            =   -74880
         TabIndex        =   23
         Top             =   2040
         Width           =   975
      End
      Begin VB.Label Label9 
         Caption         =   "Date Hired"
         Height          =   255
         Left            =   -74880
         TabIndex        =   21
         Top             =   1740
         Width           =   975
      End
      Begin VB.Label Label8 
         Caption         =   "Security Level:"
         Height          =   255
         Left            =   -74880
         TabIndex        =   17
         Top             =   1080
         Width           =   1095
      End
      Begin VB.Label Label7 
         Caption         =   "Job Nature:"
         Height          =   255
         Left            =   -74880
         TabIndex        =   15
         Top             =   720
         Width           =   855
      End
      Begin VB.Label Label6 
         Caption         =   "Job Title:"
         Height          =   255
         Left            =   -74880
         TabIndex        =   13
         Top             =   360
         Width           =   735
      End
   End
   Begin MSMask.MaskEdBox mskStaffCode 
      DataField       =   "StaffCode"
      DataSource      =   "dtcStaff"
      Height          =   255
      Left            =   1200
      TabIndex        =   1
      Top             =   1200
      Width           =   615
      _ExtentX        =   1085
      _ExtentY        =   450
      _Version        =   393216
      PromptInclude   =   0   'False
      MaxLength       =   4
      Mask            =   ">aaaa"
      PromptChar      =   "_"
   End
   Begin Threed.SSRibbon cmdSortByLastName 
      Height          =   330
      Left            =   8400
      TabIndex        =   76
      Top             =   1560
      Width           =   330
      _ExtentX        =   582
      _ExtentY        =   582
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmStaff.frx":109CB
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmStaff.frx":10F71
   End
   Begin Threed.SSRibbon cmdSortByFirstName 
      Height          =   330
      Left            =   6960
      TabIndex        =   75
      Top             =   1560
      Width           =   330
      _ExtentX        =   582
      _ExtentY        =   582
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmStaff.frx":1152B
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmStaff.frx":11AD1
   End
   Begin Threed.SSRibbon cmdSortByID 
      Height          =   330
      Left            =   5520
      TabIndex        =   74
      Top             =   1560
      Width           =   330
      _ExtentX        =   582
      _ExtentY        =   582
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmStaff.frx":1208B
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmStaff.frx":12631
   End
   Begin VB.Label Label1 
      Caption         =   "Staff Code:"
      Height          =   255
      Left            =   240
      TabIndex        =   7
      Top             =   1200
      Width           =   855
   End
End
Attribute VB_Name = "frmStaff"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdSortByFirstName_Click(Value As Integer)
    Dim strSQL As String
    If cmdSortByFirstName.Value Then
        strSQL = "SELECT * FROM Staff ORDER BY StaffFirstName ASC, StaffLastName ASC"
    Else
        strSQL = "SELECT * FROM Staff ORDER BY StaffFirstName DESC, StaffLastName ASC"
    End If
    dtcStaff.RecordSource = strSQL
    dtcStaff.Refresh
    dtcStaff.UpdateControls
End Sub

Private Sub cmdSortByID_Click(Value As Integer)
    Dim strSQL As String
    If cmdSortByID.Value Then
        strSQL = "SELECT * FROM Staff ORDER BY StaffCode ASC"
    Else
        strSQL = "SELECT * FROM Staff ORDER BY StaffCode DESC"
    End If
    dtcStaff.RecordSource = strSQL
    dtcStaff.Refresh
    dtcStaff.UpdateControls
End Sub

Private Sub cmdSortByLastName_Click(Value As Integer)
    Dim strSQL As String
    If cmdSortByLastName.Value Then
        strSQL = "SELECT * FROM Staff ORDER BY StaffLastName ASC, StaffFirstName ASC"
    Else
        strSQL = "SELECT * FROM Staff ORDER BY StaffLastName DESC, StaffFirstName ASC"
    End If
    dtcStaff.RecordSource = strSQL
    dtcStaff.Refresh
    dtcStaff.UpdateControls
End Sub

Private Sub dbcCity_Click(intArea As Integer)

    Dim strTarget As String
    
    If intArea = dbcAreaList Then
        ' Sync dtcCity
        strTarget = "Code = " & dbcCity.BoundText
        dtcCity.Recordset.FindFirst strTarget
        If Not dtcCity.Recordset.NoMatch Then
            dtcCity.UpdateControls
            ' Fill Supplier fields: Province and Country
            If Not (dtcStaff.Recordset.EditMode = dbEditAdd) Then dtcStaff.Recordset.Edit
            dtcStaff.Recordset!HomeProvince = dtcCity.Recordset!ProvinceCode
            dtcStaff.Recordset!HomeCountry = dtcCity.Recordset!CountryCode
        End If
    End If

End Sub

Private Sub dbcCity_GotFocus()
    ' Show Province and Country
    txtSyncProvince.Visible = True
    txtSyncCountry.Visible = True
    txtSyncProvince.ZOrder
    txtSyncCountry.ZOrder

End Sub


Private Sub dbcCity_LostFocus()
    ' Hide Province and Country
    txtSyncProvince.Visible = False
    txtSyncCountry.Visible = False

End Sub

Private Sub dbcStaffFullName_Click(intArea As Integer)
    ' Display the content of the selected staff
    If intArea = dbcAreaList Then
        Dim MyCriteria As String
        MyCriteria = "StaffFullName = '" & dbcStaffFullName.Text & "'"  ' Set the criteria
        dtcStaff.Recordset.FindFirst MyCriteria   ' Find first matching record.
        If Not dtcStaff.Recordset.NoMatch Then    ' Check if record is found.
            dtcStaff.UpdateControls
        End If
    End If
End Sub

Private Sub dbcStaffFullName_GotFocus()
    ' If AddNew, compose Full Name by First Name + Initial + Last Name
    If (dbcStaffFullName = "") And _
        IsNull(dtcStaff.Recordset("StaffFullName")) Then
        If (dbcStaffInitial = "") Then
            dbcStaffFullName.Text = txtFirstName.Text & " " & txtLastName
        Else
            dbcStaffFullName.Text = txtFirstName.Text & " " & mskStaffInitial & " " & txtLastName
        End If
    End If
End Sub


Private Sub dtcStaff_Reposition()

    Dim strTarget As String
    
    ' Synconize the related tables
    If Not (dtcStaff.Recordset.EOF Or dtcStaff.Recordset.BOF) Then
        If dtcStaff.Recordset!HomeCity <> "" Then
            ' Sync dtcCity
            strTarget = "Code = " & dtcStaff.Recordset!HomeCity
            dtcCity.Recordset.FindFirst strTarget
            If Not dtcCity.Recordset.NoMatch Then _
                dtcCity.UpdateControls
        End If
        If Not IsNull(dtcStaff.Recordset!Birthday) Then _
            calBirthday.Text = Format(dtcStaff.Recordset!Birthday, "MM/DD/YYYY")
        If Not IsNull(dtcStaff.Recordset!DateHired) Then _
            calDateHired.Text = Format(dtcStaff.Recordset!DateHired, "MM/DD/YYYY")
        If Not IsNull(dtcStaff.Recordset!DateLeaved) Then _
            calDateLeaved.Text = Format(dtcStaff.Recordset!DateLeaved, "MM/DD/YYYY")
    End If
    
End Sub

Private Sub dtcStaff_Validate(intAction As Integer, intSave As Integer)
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
    cmdSortByID.ZOrder
    cmdSortByFirstName.ZOrder
    cmdSortByLastName.ZOrder

End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub mskBasicSalary_GotFocus()
    Call AutoSelect(mskBasicSalary)
End Sub

Private Sub mskHomeFax_GotFocus()
    Call AutoSelect(mskHomeFax)
End Sub

Private Sub mskHomePhone_GotFocus()
    Call AutoSelect(mskHomePhone)
End Sub

Private Sub mskPostalCode_GotFocus()
    Call AutoSelect(mskPostalCode)
End Sub

Private Sub mskSecurityLevel_GotFocus()
    Call AutoSelect(mskSecurityLevel)
End Sub

Private Sub mskSIN_GotFocus()
    Call AutoSelect(mskSIN)
End Sub

Private Sub mskStaffCode_GotFocus()
    Call AutoSelect(mskStaffCode)
End Sub

Private Sub mskStaffInitial_GotFocus()
    Call AutoSelect(mskStaffInitial)
End Sub

Private Sub SSCommand1_Click()
    If ofx_IsFormLoaded(frmJobTitle) Then _
        Unload frmJobTitle
    Screen.MousePointer = vbHourglass
    frmJobTitle.Show vbModal
    dtcJobTitle.Refresh
    dtcJobTitle.UpdateControls
End Sub

Private Sub SSCommand2_Click()
    If ofx_IsFormLoaded(frmJobNature) Then _
        Unload frmJobNature
    Screen.MousePointer = vbHourglass
    frmJobNature.Show vbModal
    dtcJobNature.Refresh
    dtcJobNature.UpdateControls
End Sub

Private Sub SSCommand3_Click()
    If ofx_IsFormLoaded(frmCity) Then _
        Unload frmCity
    Screen.MousePointer = vbHourglass
    frmCity.Show vbModal
    dtcCity.Refresh
    dtcCity.UpdateControls
    dtcSelCity.Refresh
    dtcSelCity.UpdateControls
End Sub




Private Sub SSRibbon1_Click(Value As Integer)

End Sub

Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

    On Error GoTo SSToolbar1_Click_Err

    Select Case ToolID
        Case "ID_Add"
            Call DoAdd
        Case "ID_Delete"
            dtcStaff.Recordset.Delete
            dtcStaff.Recordset.MoveNext
        Case "ID_Undo"
            dtcStaff.Refresh
        Case "ID_Save"
            If dtcStaff.Recordset.EditMode = dbEditAdd Then
                dtcStaffHistory.Recordset.AddNew
                dtcStaffHistory.Recordset!StaffCode = mskStaffCode.Text
                dtcStaffHistory.Recordset!Date = Date
                dtcStaffHistory.Recordset!Reason = "Created"
                dtcStaffHistory.Recordset!Remarks = "Hired on " & calDateHired.Text
                dtcStaffHistory.UpdateRecord
            End If
            dtcStaff.UpdateRecord
            dtcStaff.Recordset.Bookmark = dtcStaff.Recordset.LastModified
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            dtcStaff.Recordset.MoveFirst
        Case "ID_Next"
            dtcStaff.Recordset.MoveNext
            If dtcStaff.Recordset.EOF Then
                Beep
                dtcStaff.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcStaff.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcStaff.Recordset.BOF Then
                Beep
                dtcStaff.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcStaff.Recordset.MoveLast
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

Private Sub txtCommBasic_GotFocus()
    Call AutoSelect(txtCommBasic)
End Sub


Private Sub txtCommBonus_GotFocus()
    Call AutoSelect(txtCommBonus)
End Sub


Private Sub txtCommGeneral_GotFocus()
    Call AutoSelect(txtCommGeneral)
End Sub


Private Sub txtFirstName_GotFocus()
    Call AutoSelect(txtFirstName)
End Sub


Private Sub txtLastName_GotFocus()
    Call AutoSelect(txtLastName)
End Sub



Private Sub DoAdd()
    With dtcStaff.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    dtcStaff.Recordset.AddNew
    mskStaffCode.SetFocus
End Sub

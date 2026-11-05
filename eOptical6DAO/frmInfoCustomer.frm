VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{B074BC93-5A5B-11CE-98BD-0000C0E6B88E}#2.0#0"; "sstabs32.ocx"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmInfoCustomer 
   Caption         =   "Customer Information"
   ClientHeight    =   7470
   ClientLeft      =   195
   ClientTop       =   1950
   ClientWidth     =   11670
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   7470
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
      ToolsetPicture  =   "frmInfoCustomer.frx":0000
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
      MouseIcon       =   "frmInfoCustomer.frx":A892
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   3255
      Left            =   120
      TabIndex        =   85
      Top             =   1080
      Width           =   11535
      _ExtentX        =   20346
      _ExtentY        =   5741
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
         Bindings        =   "frmInfoCustomer.frx":A8AE
         Height          =   1575
         Left            =   120
         OleObjectBlob   =   "frmInfoCustomer.frx":A8C8
         TabIndex        =   18
         Top             =   1560
         Width           =   11295
      End
      Begin VB.Data dtcDoctor 
         Caption         =   "Doctor"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   2160
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT ID, DoctorName FROM Doctor ORDER BY DoctorName"
         Top             =   1260
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
         Left            =   1440
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "CustomerPresLens"
         Top             =   1200
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
         Left            =   240
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "CustomerPresContact"
         Top             =   1260
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcCusMedical 
         Caption         =   "CusMedical"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   1440
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "CustomerMedical"
         Top             =   960
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
         Left            =   240
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "CustomerAccounts"
         Top             =   960
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcSelCountry 
         Caption         =   "SelCountry"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   4320
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT * FROM Country ORDER BY CountryName"
         Top             =   360
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcSelProvince 
         Caption         =   "SelProvince"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   4320
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT * FROM Province ORDER BY ProvinceName"
         Top             =   720
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
         Left            =   4320
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT * FROM City ORDER BY CityName"
         Top             =   1080
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcHomeCity 
         Caption         =   "SelHomeCity"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   8880
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "qryCityFullList"
         Top             =   2520
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcJobTitle 
         Caption         =   "JobTitle"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   7320
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "JobTitle"
         Top             =   2220
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
         Left            =   8880
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "qryCityFullList"
         Top             =   2220
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcSelID 
         Caption         =   "SelID"
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
         RecordSource    =   "SELECT ID FROM Customer"
         Top             =   660
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcCustomer 
         Caption         =   "Customer"
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
         RecordSource    =   ""
         Top             =   2220
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.TextBox txtSelVIPCode 
         DataField       =   "VIPCode"
         DataSource      =   "dtcCustomer"
         Height          =   285
         Left            =   120
         TabIndex        =   1
         Top             =   540
         Width           =   1095
      End
      Begin Threed.SSFrame SSFrame2 
         Height          =   1335
         Left            =   9000
         TabIndex        =   88
         Top             =   120
         Width           =   2445
         _ExtentX        =   4313
         _ExtentY        =   2355
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
         Caption         =   "Phone Numbers"
         Begin VB.TextBox txtSelCellAreaCode 
            Height          =   285
            Left            =   830
            TabIndex        =   15
            Top             =   960
            Width           =   375
         End
         Begin VB.TextBox txtSelBizAreaCode 
            Height          =   285
            Left            =   830
            TabIndex        =   9
            Top             =   240
            Width           =   375
         End
         Begin VB.TextBox txtSelHomeAreaCode 
            Height          =   285
            Left            =   830
            TabIndex        =   12
            Top             =   600
            Width           =   375
         End
         Begin VB.TextBox txtSelCellular 
            DataField       =   "Cellular"
            DataSource      =   "dtcCustomer"
            Height          =   285
            Left            =   1200
            TabIndex        =   16
            Top             =   960
            Width           =   855
         End
         Begin VB.TextBox txtSelHomePhone 
            DataField       =   "HomePhone"
            DataSource      =   "dtcCustomer"
            Height          =   285
            Left            =   1200
            TabIndex        =   13
            Top             =   600
            Width           =   855
         End
         Begin VB.TextBox txtSelBizPhone 
            DataField       =   "BizPhone"
            DataSource      =   "dtcCustomer"
            Height          =   285
            Left            =   1200
            TabIndex        =   10
            Top             =   240
            Width           =   855
         End
         Begin Threed.SSCommand cmdFindCellular 
            Height          =   345
            Left            =   2040
            TabIndex        =   17
            TabStop         =   0   'False
            Top             =   960
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
            Picture         =   "frmInfoCustomer.frx":DCA5
            AutoSize        =   2
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin Threed.SSCommand cmdFindHomePhone 
            Height          =   345
            Left            =   2040
            TabIndex        =   14
            TabStop         =   0   'False
            Top             =   600
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
            Picture         =   "frmInfoCustomer.frx":E24B
            AutoSize        =   2
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin Threed.SSCommand cmdFindBizPhone 
            Height          =   345
            Left            =   2040
            TabIndex        =   11
            TabStop         =   0   'False
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
            Picture         =   "frmInfoCustomer.frx":E7F1
            AutoSize        =   2
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin VB.Label Label11 
            Caption         =   "Cellular"
            Height          =   195
            Left            =   120
            TabIndex        =   91
            Top             =   960
            Width           =   735
         End
         Begin VB.Label Label10 
            Caption         =   "Home"
            Height          =   195
            Left            =   120
            TabIndex        =   90
            Top             =   600
            Width           =   495
         End
         Begin VB.Label Label9 
            Caption         =   "Business"
            Height          =   195
            Left            =   120
            TabIndex        =   89
            Top             =   240
            Width           =   735
         End
      End
      Begin Threed.SSFrame SSFrame3 
         Height          =   1335
         Left            =   5760
         TabIndex        =   92
         Top             =   120
         Width           =   3135
         _ExtentX        =   5530
         _ExtentY        =   2355
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
         Begin VB.Data dtcSelFullName 
            Caption         =   "SelFullName"
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
            RecordSource    =   "SELECT DISTINCT FullName FROM Customer ORDER BY FullName"
            Top             =   1020
            Visible         =   0   'False
            Width           =   1140
         End
         Begin VB.Data dtcSelLastName 
            Caption         =   "SelLastName"
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
            RecordSource    =   "SELECT DISTINCT LastName FROM Customer ORDER BY LastName"
            Top             =   660
            Visible         =   0   'False
            Width           =   1140
         End
         Begin VB.Data dtcSelFirstName 
            Caption         =   "SelFirstName"
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
            RecordSource    =   "SELECT DISTINCT FirstName FROM Customer ORDER BY FirstName"
            Top             =   300
            Visible         =   0   'False
            Width           =   1140
         End
         Begin MSDBCtls.DBCombo dbcSelFullName 
            Bindings        =   "frmInfoCustomer.frx":ED97
            Height          =   315
            Left            =   960
            TabIndex        =   8
            Top             =   960
            Width           =   2055
            _ExtentX        =   3625
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "FullName"
            BoundColumn     =   "FullName"
            Text            =   ""
         End
         Begin MSDBCtls.DBCombo dbcSelLastName 
            Bindings        =   "frmInfoCustomer.frx":EDB4
            Height          =   315
            Left            =   960
            TabIndex        =   7
            Top             =   600
            Width           =   1575
            _ExtentX        =   2778
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "LastName"
            BoundColumn     =   "LastName"
            Text            =   ""
         End
         Begin MSDBCtls.DBCombo dbcSelFirstName 
            Bindings        =   "frmInfoCustomer.frx":EDD1
            Height          =   315
            Left            =   960
            TabIndex        =   6
            Top             =   240
            Width           =   1575
            _ExtentX        =   2778
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "FirstName"
            BoundColumn     =   "FirstName"
            Text            =   ""
         End
         Begin VB.Label Label6 
            Caption         =   "Full Name"
            Height          =   195
            Left            =   120
            TabIndex        =   95
            Top             =   960
            Width           =   735
         End
         Begin VB.Label Label5 
            Caption         =   "Last Name"
            Height          =   195
            Left            =   120
            TabIndex        =   94
            Top             =   600
            Width           =   855
         End
         Begin VB.Label Label4 
            Caption         =   "Fisrt Name"
            Height          =   195
            Left            =   120
            TabIndex        =   93
            Top             =   240
            Width           =   855
         End
      End
      Begin Threed.SSFrame SSFrame4 
         Height          =   1335
         Left            =   3000
         TabIndex        =   96
         Top             =   120
         Width           =   2655
         _ExtentX        =   4683
         _ExtentY        =   2355
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
         Begin MSDBCtls.DBCombo dbcSelCity 
            Bindings        =   "frmInfoCustomer.frx":EDEF
            Height          =   315
            Left            =   840
            TabIndex        =   5
            Top             =   960
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
         Begin MSDBCtls.DBCombo dbcSelProvince 
            Bindings        =   "frmInfoCustomer.frx":EE08
            Height          =   315
            Left            =   840
            TabIndex        =   4
            Top             =   600
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
         Begin MSDBCtls.DBCombo dbcSelCountry 
            Bindings        =   "frmInfoCustomer.frx":EE25
            Height          =   315
            Left            =   840
            TabIndex        =   3
            Top             =   240
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
         Begin VB.Label Label3 
            Caption         =   "City"
            Height          =   195
            Left            =   120
            TabIndex        =   99
            Top             =   960
            Width           =   375
         End
         Begin VB.Label Label2 
            Caption         =   "Province"
            Height          =   195
            Left            =   120
            TabIndex        =   98
            Top             =   600
            Width           =   735
         End
         Begin VB.Label Label1 
            Caption         =   "Country"
            Height          =   195
            Left            =   120
            TabIndex        =   97
            Top             =   240
            Width           =   615
         End
      End
      Begin MSDBCtls.DBCombo dbcSelID 
         Bindings        =   "frmInfoCustomer.frx":EE41
         Height          =   315
         Left            =   1440
         TabIndex        =   2
         Top             =   540
         Width           =   1335
         _ExtentX        =   2355
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "ID"
         BoundColumn     =   "ID"
         Text            =   ""
      End
      Begin Threed.SSCommand cmdFindVIP 
         Height          =   345
         Left            =   960
         TabIndex        =   100
         TabStop         =   0   'False
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
         Picture         =   "frmInfoCustomer.frx":EE58
         AutoSize        =   2
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label8 
         Caption         =   "Customer No."
         Height          =   255
         Left            =   1440
         TabIndex        =   87
         Top             =   300
         Width           =   975
      End
      Begin VB.Label Label7 
         Caption         =   "VIP No."
         Height          =   255
         Left            =   120
         TabIndex        =   86
         Top             =   300
         Width           =   615
      End
   End
   Begin SSDesignerWidgetsTabs.SSIndexTab SSIndexTab1 
      Height          =   2955
      Left            =   120
      TabIndex        =   19
      Top             =   4440
      Width           =   11535
      _Version        =   131078
      _ExtentX        =   20346
      _ExtentY        =   5212
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
      Tabs(0).Pages(0).CtlCount=   2
      Tabs(0).Pages(0).CtlEnabled=   -1  'True
      Tabs(0).Pages(0).Ctl(0)=   "SSFrame6"
      Tabs(0).Pages(0).Ctl(1)=   "SSFrame5"
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
      Tabs(1).Pages(0).CtlEnabled=   0   'False
      Tabs(1).Pages(0).Ctl(0)=   "SSFrame7"
      Tabs(1).Pages(0).Ctl(1)=   "SSFrame8"
      Tabs(1).Tag     =   ""
      Tabs(1).Caption =   "Personal"
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
      Tabs(2).Pages(0).CtlCount=   4
      Tabs(2).Pages(0).CtlEnabled=   0   'False
      Tabs(2).Pages(0).Ctl(0)=   "cmdPrnRxCN"
      Tabs(2).Pages(0).Ctl(1)=   "SSFrame11"
      Tabs(2).Pages(0).Ctl(2)=   "SSFrame10"
      Tabs(2).Pages(0).Ctl(3)=   "SSFrame9"
      Tabs(2).Tag     =   ""
      Tabs(2).Caption =   "Pres(Cont)"
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
      Tabs(3).Pages(0).Ctl(0)=   "cmdPrnRxLN"
      Tabs(3).Pages(0).Ctl(1)=   "SSFrame13"
      Tabs(3).Pages(0).Ctl(2)=   "SSFrame12"
      Tabs(3).Tag     =   ""
      Tabs(3).Caption =   "Pres(Lens)"
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
      Tabs(4).Pages(0).CtlCount=   6
      Tabs(4).Pages(0).CtlEnabled=   0   'False
      Tabs(4).Pages(0).Ctl(0)=   "dbgOrders"
      Tabs(4).Pages(0).Ctl(1)=   "dtcQrySOrderSimple"
      Tabs(4).Pages(0).Ctl(2)=   "cmdPrnClaimReceipt"
      Tabs(4).Pages(0).Ctl(3)=   "cmdPrnPrescription"
      Tabs(4).Pages(0).Ctl(4)=   "cmdPrnInvoice"
      Tabs(4).Pages(0).Ctl(5)=   "cmdPrnOrder"
      Tabs(4).Tag     =   ""
      Tabs(4).Caption =   "Orders"
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
      Begin TrueDBGrid50.TDBGrid dbgOrders 
         Bindings        =   "frmInfoCustomer.frx":F3FE
         Height          =   2535
         Left            =   -74880
         OleObjectBlob   =   "frmInfoCustomer.frx":F41F
         TabIndex        =   84
         Top             =   480
         Width           =   11295
      End
      Begin VB.Data dtcQrySOrderSimple 
         Caption         =   "qrySOrderSimple"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   -68040
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   ""
         Top             =   1140
         Visible         =   0   'False
         Width           =   1215
      End
      Begin Threed.SSFrame SSFrame5 
         Height          =   2595
         Left            =   120
         TabIndex        =   101
         Top             =   300
         Width           =   5535
         _ExtentX        =   9763
         _ExtentY        =   4577
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
         Caption         =   "Home"
         Begin VB.TextBox txtEmail 
            DataField       =   "Email"
            DataSource      =   "dtcCustomer"
            Height          =   285
            Left            =   1080
            MaxLength       =   128
            TabIndex        =   182
            Top             =   2040
            Width           =   2295
         End
         Begin VB.TextBox Text5 
            DataField       =   "HomePostalCode"
            DataSource      =   "dtcCustomer"
            Height          =   285
            Left            =   1080
            Locked          =   -1  'True
            TabIndex        =   24
            TabStop         =   0   'False
            Top             =   1680
            Width           =   735
         End
         Begin VB.TextBox Text4 
            DataField       =   "CountryName"
            DataSource      =   "dtcHomeCity"
            Height          =   285
            Left            =   1080
            Locked          =   -1  'True
            TabIndex        =   23
            TabStop         =   0   'False
            Top             =   1380
            Width           =   2295
         End
         Begin VB.TextBox Text3 
            DataField       =   "ProvinceName"
            DataSource      =   "dtcHomeCity"
            Height          =   285
            Left            =   1080
            Locked          =   -1  'True
            TabIndex        =   22
            TabStop         =   0   'False
            Top             =   1080
            Width           =   2295
         End
         Begin VB.TextBox Text2 
            DataField       =   "CityName"
            DataSource      =   "dtcHomeCity"
            Height          =   285
            Left            =   1080
            Locked          =   -1  'True
            TabIndex        =   21
            TabStop         =   0   'False
            Top             =   780
            Width           =   2295
         End
         Begin VB.TextBox Text1 
            DataField       =   "HomeAddress"
            DataSource      =   "dtcCustomer"
            Height          =   555
            Left            =   1080
            Locked          =   -1  'True
            MultiLine       =   -1  'True
            TabIndex        =   20
            TabStop         =   0   'False
            Top             =   240
            Width           =   2295
         End
         Begin Threed.SSPanel SSPanel1 
            Height          =   2235
            Left            =   3480
            TabIndex        =   115
            Top             =   240
            Width           =   1935
            _ExtentX        =   3413
            _ExtentY        =   3942
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
            Caption         =   "Phone:"
            BevelOuter      =   1
            Alignment       =   0
            Begin VB.TextBox Text14 
               DataField       =   "CityPhoneCode"
               DataSource      =   "dtcHomeCity"
               Height          =   285
               Left            =   720
               Locked          =   -1  'True
               TabIndex        =   26
               TabStop         =   0   'False
               Top             =   540
               Width           =   495
            End
            Begin VB.TextBox Text13 
               DataField       =   "CountryPhoneCode"
               DataSource      =   "dtcHomeCity"
               Height          =   285
               Left            =   720
               Locked          =   -1  'True
               TabIndex        =   25
               TabStop         =   0   'False
               Top             =   240
               Width           =   495
            End
            Begin MSMask.MaskEdBox MaskEdBox3 
               DataField       =   "Cellular"
               DataSource      =   "dtcCustomer"
               Height          =   255
               Left            =   720
               TabIndex        =   29
               TabStop         =   0   'False
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
            Begin MSMask.MaskEdBox MaskEdBox2 
               DataField       =   "HomeFax"
               DataSource      =   "dtcCustomer"
               Height          =   255
               Left            =   720
               TabIndex        =   28
               TabStop         =   0   'False
               Top             =   1140
               Width           =   1095
               _ExtentX        =   1931
               _ExtentY        =   450
               _Version        =   393216
               PromptInclude   =   0   'False
               MaxLength       =   9
               Mask            =   "### #####"
               PromptChar      =   "_"
            End
            Begin MSMask.MaskEdBox MaskEdBox1 
               DataField       =   "HomePhone"
               DataSource      =   "dtcCustomer"
               Height          =   255
               Left            =   720
               TabIndex        =   27
               TabStop         =   0   'False
               Top             =   840
               Width           =   1095
               _ExtentX        =   1931
               _ExtentY        =   450
               _Version        =   393216
               BackColor       =   16777215
               PromptInclude   =   0   'False
               MaxLength       =   9
               Mask            =   "### #####"
               PromptChar      =   "_"
            End
            Begin VB.Label Label28 
               Caption         =   "Cellular"
               Height          =   195
               Left            =   120
               TabIndex        =   120
               Top             =   1440
               Width           =   615
            End
            Begin VB.Label Label27 
               Caption         =   "Fax"
               Height          =   195
               Left            =   120
               TabIndex        =   119
               Top             =   1140
               Width           =   375
            End
            Begin VB.Label Label26 
               Caption         =   "Voice"
               Height          =   195
               Left            =   120
               TabIndex        =   118
               Top             =   840
               Width           =   495
            End
            Begin VB.Label Label25 
               Caption         =   "City"
               Height          =   195
               Left            =   120
               TabIndex        =   117
               Top             =   540
               Width           =   375
            End
            Begin VB.Label Label24 
               Caption         =   "Country"
               Height          =   195
               Left            =   120
               TabIndex        =   116
               Top             =   240
               Width           =   615
            End
         End
         Begin VB.Label Label70 
            Caption         =   "Email"
            Height          =   255
            Left            =   120
            TabIndex        =   183
            Top             =   2040
            Width           =   975
         End
         Begin VB.Label Label16 
            Caption         =   "Postal Code"
            Height          =   195
            Left            =   120
            TabIndex        =   107
            Top             =   1680
            Width           =   855
         End
         Begin VB.Label Label15 
            Caption         =   "Country"
            Height          =   255
            Left            =   120
            TabIndex        =   106
            Top             =   1380
            Width           =   615
         End
         Begin VB.Label Label14 
            Caption         =   "Province"
            Height          =   195
            Left            =   120
            TabIndex        =   105
            Top             =   1080
            Width           =   735
         End
         Begin VB.Label Label13 
            Caption         =   "City"
            Height          =   255
            Left            =   120
            TabIndex        =   104
            Top             =   780
            Width           =   375
         End
         Begin VB.Label Label12 
            Caption         =   "Address"
            Height          =   255
            Left            =   120
            TabIndex        =   103
            Top             =   240
            Width           =   735
         End
      End
      Begin Threed.SSFrame SSFrame6 
         Height          =   2595
         Left            =   5760
         TabIndex        =   102
         Top             =   300
         Width           =   5415
         _ExtentX        =   9551
         _ExtentY        =   4577
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
         Caption         =   "Work"
         Begin VB.TextBox Text12 
            DataField       =   "BizPostalCode"
            DataSource      =   "dtcCustomer"
            Height          =   285
            Left            =   1080
            Locked          =   -1  'True
            TabIndex        =   36
            TabStop         =   0   'False
            Top             =   2220
            Width           =   855
         End
         Begin VB.TextBox Text11 
            DataField       =   "CountryName"
            DataSource      =   "dtcBizCity"
            Height          =   285
            Left            =   1080
            Locked          =   -1  'True
            TabIndex        =   35
            TabStop         =   0   'False
            Top             =   1920
            Width           =   2295
         End
         Begin VB.TextBox Text10 
            DataField       =   "ProvinceName"
            DataSource      =   "dtcBizCity"
            Height          =   285
            Left            =   1080
            Locked          =   -1  'True
            TabIndex        =   34
            TabStop         =   0   'False
            Top             =   1620
            Width           =   2295
         End
         Begin VB.TextBox Text9 
            DataField       =   "CityName"
            DataSource      =   "dtcBizCity"
            Height          =   285
            Left            =   1080
            Locked          =   -1  'True
            TabIndex        =   33
            TabStop         =   0   'False
            Top             =   1320
            Width           =   2295
         End
         Begin VB.TextBox Text8 
            DataField       =   "BizAddress"
            DataSource      =   "dtcCustomer"
            Height          =   495
            Left            =   1080
            Locked          =   -1  'True
            MultiLine       =   -1  'True
            TabIndex        =   32
            TabStop         =   0   'False
            Top             =   840
            Width           =   2295
         End
         Begin VB.TextBox Text6 
            DataField       =   "BizCompanyName"
            DataSource      =   "dtcCustomer"
            Height          =   285
            Left            =   1080
            Locked          =   -1  'True
            TabIndex        =   30
            TabStop         =   0   'False
            Top             =   240
            Width           =   2295
         End
         Begin Threed.SSPanel SSPanel2 
            Height          =   2295
            Left            =   3480
            TabIndex        =   121
            Top             =   180
            Width           =   1815
            _ExtentX        =   3201
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
            Caption         =   "Phone:"
            BevelOuter      =   1
            Alignment       =   0
            Begin VB.TextBox Text16 
               DataField       =   "CityPhoneCode"
               DataSource      =   "dtcBizCity"
               Height          =   285
               Left            =   720
               Locked          =   -1  'True
               TabIndex        =   38
               TabStop         =   0   'False
               Top             =   540
               Width           =   495
            End
            Begin VB.TextBox Text15 
               DataField       =   "CountryPhoneCode"
               DataSource      =   "dtcBizCity"
               Height          =   285
               Left            =   720
               Locked          =   -1  'True
               TabIndex        =   37
               TabStop         =   0   'False
               Top             =   240
               Width           =   495
            End
            Begin MSMask.MaskEdBox MaskEdBox5 
               DataField       =   "BizFax"
               DataSource      =   "dtcCustomer"
               Height          =   255
               Left            =   720
               TabIndex        =   40
               TabStop         =   0   'False
               Top             =   1140
               Width           =   975
               _ExtentX        =   1720
               _ExtentY        =   450
               _Version        =   393216
               PromptInclude   =   0   'False
               MaxLength       =   9
               Mask            =   "### #####"
               PromptChar      =   "_"
            End
            Begin MSMask.MaskEdBox MaskEdBox4 
               DataField       =   "BizPhone"
               DataSource      =   "dtcCustomer"
               Height          =   255
               Left            =   720
               TabIndex        =   39
               TabStop         =   0   'False
               Top             =   840
               Width           =   975
               _ExtentX        =   1720
               _ExtentY        =   450
               _Version        =   393216
               PromptInclude   =   0   'False
               MaxLength       =   9
               Mask            =   "### #####"
               PromptChar      =   "_"
            End
            Begin VB.Label Label32 
               Caption         =   "Fax"
               Height          =   195
               Left            =   120
               TabIndex        =   125
               Top             =   1140
               Width           =   375
            End
            Begin VB.Label Label31 
               Caption         =   "Voice"
               Height          =   255
               Left            =   120
               TabIndex        =   124
               Top             =   840
               Width           =   495
            End
            Begin VB.Label Label30 
               Caption         =   "City"
               Height          =   195
               Left            =   120
               TabIndex        =   123
               Top             =   540
               Width           =   375
            End
            Begin VB.Label Label29 
               Caption         =   "Country"
               Height          =   195
               Left            =   120
               TabIndex        =   122
               Top             =   240
               Width           =   615
            End
         End
         Begin MSDBCtls.DBCombo DBCombo1 
            Bindings        =   "frmInfoCustomer.frx":12735
            DataField       =   "BizJobTitle"
            DataSource      =   "dtcCustomer"
            Height          =   315
            Left            =   1080
            TabIndex        =   31
            TabStop         =   0   'False
            Top             =   540
            Width           =   2295
            _ExtentX        =   4048
            _ExtentY        =   1005
            _Version        =   393216
            Locked          =   -1  'True
            Style           =   1
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "JobTitle"
            BoundColumn     =   "JobTitleCode"
            Text            =   "DBCombo1"
         End
         Begin VB.Label Label23 
            Caption         =   "Postal Code"
            Height          =   255
            Left            =   120
            TabIndex        =   114
            Top             =   2220
            Width           =   975
         End
         Begin VB.Label Label22 
            Caption         =   "Country"
            Height          =   255
            Left            =   120
            TabIndex        =   113
            Top             =   1920
            Width           =   615
         End
         Begin VB.Label Label21 
            Caption         =   "Province"
            Height          =   255
            Left            =   120
            TabIndex        =   112
            Top             =   1620
            Width           =   735
         End
         Begin VB.Label Label20 
            Caption         =   "City"
            Height          =   255
            Left            =   120
            TabIndex        =   111
            Top             =   1320
            Width           =   375
         End
         Begin VB.Label Label19 
            Caption         =   "Address"
            Height          =   255
            Left            =   120
            TabIndex        =   110
            Top             =   840
            Width           =   615
         End
         Begin VB.Label Label18 
            Caption         =   "Job Title"
            Height          =   255
            Left            =   120
            TabIndex        =   109
            Top             =   540
            Width           =   735
         End
         Begin VB.Label Label17 
            Caption         =   "Company"
            Height          =   255
            Left            =   120
            TabIndex        =   108
            Top             =   240
            Width           =   735
         End
      End
      Begin Threed.SSFrame SSFrame7 
         Height          =   2595
         Left            =   -74880
         TabIndex        =   126
         Top             =   300
         Width           =   4695
         _ExtentX        =   8281
         _ExtentY        =   4577
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
            Height          =   975
            Left            =   1440
            MultiLine       =   -1  'True
            ScrollBars      =   2  'Vertical
            TabIndex        =   45
            TabStop         =   0   'False
            Top             =   1560
            Width           =   3135
         End
         Begin VB.TextBox Text18 
            DataField       =   "Salutation"
            DataSource      =   "dtcCustomer"
            Height          =   285
            Left            =   1440
            Locked          =   -1  'True
            TabIndex        =   41
            TabStop         =   0   'False
            Text            =   "Text18"
            Top             =   240
            Width           =   615
         End
         Begin VB.TextBox Text7 
            DataField       =   "VIPMarkDownPct"
            DataSource      =   "dtcCustomer"
            Height          =   285
            Left            =   1440
            Locked          =   -1  'True
            TabIndex        =   43
            TabStop         =   0   'False
            Text            =   "Text7"
            Top             =   900
            Width           =   735
         End
         Begin SSCalendarWidgets_A.SSDateCombo calJointDate 
            DataField       =   "JointDate"
            DataSource      =   "dtcCusAccount"
            Height          =   315
            Left            =   1440
            TabIndex        =   44
            TabStop         =   0   'False
            Top             =   1200
            Width           =   2175
            _Version        =   65543
            _ExtentX        =   3836
            _ExtentY        =   556
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
         Begin SSCalendarWidgets_A.SSDateCombo calBirthday 
            DataField       =   "Birthday"
            DataSource      =   "dtcCustomer"
            Height          =   315
            Left            =   1440
            TabIndex        =   42
            TabStop         =   0   'False
            Top             =   540
            Width           =   2175
            _Version        =   65543
            _ExtentX        =   3836
            _ExtentY        =   556
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
         Begin VB.Label Label69 
            Caption         =   "Remarks"
            Height          =   255
            Left            =   120
            TabIndex        =   175
            Top             =   1560
            Width           =   735
         End
         Begin VB.Label Label36 
            Caption         =   "Joint Date"
            Height          =   255
            Left            =   120
            TabIndex        =   131
            Top             =   1200
            Width           =   855
         End
         Begin VB.Label Label35 
            Caption         =   "VIP Discount (%)"
            Height          =   255
            Left            =   120
            TabIndex        =   130
            Top             =   900
            Width           =   1215
         End
         Begin VB.Label Label34 
            Caption         =   "Birthday"
            Height          =   255
            Left            =   120
            TabIndex        =   129
            Top             =   540
            Width           =   735
         End
         Begin VB.Label Label33 
            Caption         =   "Salutation"
            Height          =   255
            Left            =   120
            TabIndex        =   128
            Top             =   240
            Width           =   855
         End
      End
      Begin Threed.SSFrame SSFrame8 
         Height          =   2595
         Left            =   -70080
         TabIndex        =   127
         Top             =   300
         Width           =   4335
         _ExtentX        =   7646
         _ExtentY        =   4577
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
         Begin VB.TextBox Text17 
            DataField       =   "CareCardType"
            DataSource      =   "dtcCusMedical"
            Height          =   285
            Left            =   2040
            Locked          =   -1  'True
            TabIndex        =   49
            TabStop         =   0   'False
            Text            =   "Text17"
            Top             =   1200
            Width           =   735
         End
         Begin MSMask.MaskEdBox MaskEdBox7 
            DataField       =   "CareCardValidPeriod"
            DataSource      =   "dtcCusMedical"
            Height          =   255
            Left            =   2040
            TabIndex        =   48
            TabStop         =   0   'False
            Top             =   900
            Width           =   735
            _ExtentX        =   1296
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   5
            Mask            =   "##/##"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox MaskEdBox6 
            DataField       =   "CareCardNo"
            DataSource      =   "dtcCusMedical"
            Height          =   255
            Left            =   2040
            TabIndex        =   47
            TabStop         =   0   'False
            Top             =   600
            Width           =   1215
            _ExtentX        =   2143
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   11
            Mask            =   "### ### ###"
            PromptChar      =   "_"
         End
         Begin SSCalendarWidgets_A.SSDateCombo calInsMaturityDate 
            DataField       =   "InsMaturityDate"
            DataSource      =   "dtcCusMedical"
            Height          =   315
            Left            =   2040
            TabIndex        =   46
            TabStop         =   0   'False
            Top             =   240
            Width           =   2175
            _Version        =   65543
            _ExtentX        =   3836
            _ExtentY        =   556
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
         Begin VB.Label Label40 
            Caption         =   "Care Card Type"
            Height          =   255
            Left            =   120
            TabIndex        =   135
            Top             =   1200
            Width           =   1215
         End
         Begin VB.Label Label39 
            Caption         =   "Care Card Valid Period"
            Height          =   255
            Left            =   120
            TabIndex        =   134
            Top             =   900
            Width           =   1695
         End
         Begin VB.Label Label38 
            Caption         =   "Care Card Number"
            Height          =   255
            Left            =   120
            TabIndex        =   133
            Top             =   600
            Width           =   1455
         End
         Begin VB.Label Label37 
            Caption         =   "Insurance Maturity Date"
            Height          =   255
            Left            =   120
            TabIndex        =   132
            Top             =   240
            Width           =   1815
         End
      End
      Begin Threed.SSFrame SSFrame9 
         Height          =   915
         Left            =   -74880
         TabIndex        =   136
         Top             =   300
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
         Begin MSDBCtls.DBCombo dbcPresContDr 
            Bindings        =   "frmInfoCustomer.frx":1274F
            DataField       =   "IssuedByDr"
            DataSource      =   "dtcCusPresCont"
            Height          =   315
            Left            =   2160
            TabIndex        =   51
            TabStop         =   0   'False
            Top             =   480
            Width           =   2535
            _ExtentX        =   4471
            _ExtentY        =   556
            _Version        =   393216
            Locked          =   -1  'True
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "DoctorName"
            BoundColumn     =   "ID"
            Text            =   "dbcPresContDr"
         End
         Begin SSCalendarWidgets_A.SSDateCombo calPresContDate 
            DataField       =   "IssuedOn"
            DataSource      =   "dtcCusPresCont"
            Height          =   315
            Left            =   120
            TabIndex        =   50
            TabStop         =   0   'False
            Top             =   480
            Width           =   1815
            _Version        =   65543
            _ExtentX        =   3201
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
            SpinButton      =   0
         End
         Begin VB.Label Label42 
            Caption         =   "Issued by Dr."
            Height          =   255
            Left            =   2160
            TabIndex        =   140
            Top             =   240
            Width           =   1095
         End
         Begin VB.Label Label41 
            Caption         =   "Issued on"
            Height          =   255
            Left            =   120
            TabIndex        =   139
            Top             =   240
            Width           =   735
         End
      End
      Begin Threed.SSFrame SSFrame10 
         Height          =   1635
         Left            =   -74880
         TabIndex        =   137
         Top             =   1260
         Width           =   6255
         _ExtentX        =   11033
         _ExtentY        =   2884
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
         Begin VB.TextBox Text41 
            DataField       =   "LeftPupil"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   5160
            Locked          =   -1  'True
            TabIndex        =   67
            TabStop         =   0   'False
            Text            =   "Text41"
            Top             =   720
            Width           =   615
         End
         Begin VB.TextBox Text40 
            DataField       =   "LeftCorn"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   4560
            Locked          =   -1  'True
            TabIndex        =   66
            TabStop         =   0   'False
            Text            =   "Text40"
            Top             =   720
            Width           =   615
         End
         Begin VB.TextBox Text39 
            DataField       =   "LeftPalp"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   3960
            Locked          =   -1  'True
            TabIndex        =   65
            TabStop         =   0   'False
            Text            =   "Text39"
            Top             =   720
            Width           =   615
         End
         Begin VB.TextBox Text38 
            DataField       =   "LeftKReadingH"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   3240
            Locked          =   -1  'True
            TabIndex        =   64
            TabStop         =   0   'False
            Text            =   "Text38"
            Top             =   720
            Width           =   735
         End
         Begin VB.TextBox Text37 
            DataField       =   "LeftKReadingV"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   2400
            Locked          =   -1  'True
            TabIndex        =   63
            TabStop         =   0   'False
            Text            =   "Text37"
            Top             =   720
            Width           =   735
         End
         Begin VB.TextBox Text36 
            DataField       =   "LeftAxis"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   1920
            Locked          =   -1  'True
            TabIndex        =   62
            TabStop         =   0   'False
            Text            =   "Text36"
            Top             =   720
            Width           =   495
         End
         Begin VB.TextBox Text35 
            DataField       =   "LeftCylinder"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   61
            TabStop         =   0   'False
            Text            =   "Text35"
            Top             =   720
            Width           =   735
         End
         Begin VB.TextBox Text34 
            DataField       =   "LeftSphere"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   480
            Locked          =   -1  'True
            TabIndex        =   60
            TabStop         =   0   'False
            Text            =   "Text34"
            Top             =   720
            Width           =   735
         End
         Begin VB.TextBox Text33 
            DataField       =   "RightPupil"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   5160
            Locked          =   -1  'True
            TabIndex        =   59
            TabStop         =   0   'False
            Text            =   "Text33"
            Top             =   420
            Width           =   615
         End
         Begin VB.TextBox Text32 
            DataField       =   "RightCorn"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   4560
            Locked          =   -1  'True
            TabIndex        =   58
            TabStop         =   0   'False
            Text            =   "Text32"
            Top             =   420
            Width           =   615
         End
         Begin VB.TextBox Text31 
            DataField       =   "RightPalp"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   3960
            Locked          =   -1  'True
            TabIndex        =   57
            TabStop         =   0   'False
            Text            =   "Text31"
            Top             =   420
            Width           =   615
         End
         Begin VB.TextBox Text30 
            DataField       =   "RightKReadingH"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   3240
            Locked          =   -1  'True
            TabIndex        =   56
            TabStop         =   0   'False
            Text            =   "Text30"
            Top             =   420
            Width           =   735
         End
         Begin VB.TextBox Text29 
            DataField       =   "RightKReadingV"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   2400
            Locked          =   -1  'True
            TabIndex        =   55
            TabStop         =   0   'False
            Text            =   "Text29"
            Top             =   420
            Width           =   735
         End
         Begin VB.TextBox Text28 
            DataField       =   "RightAxis"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   1920
            Locked          =   -1  'True
            TabIndex        =   54
            TabStop         =   0   'False
            Text            =   "Text28"
            Top             =   420
            Width           =   495
         End
         Begin VB.TextBox Text27 
            DataField       =   "RightCylinder"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   53
            TabStop         =   0   'False
            Text            =   "Text27"
            Top             =   420
            Width           =   735
         End
         Begin VB.TextBox Text26 
            DataField       =   "RightSphere"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   480
            Locked          =   -1  'True
            TabIndex        =   52
            TabStop         =   0   'False
            Text            =   "Text26"
            Top             =   420
            Width           =   735
         End
         Begin VB.Label Label51 
            Caption         =   "L"
            Height          =   255
            Left            =   240
            TabIndex        =   149
            Top             =   780
            Width           =   135
         End
         Begin VB.Label Label50 
            Caption         =   "R"
            Height          =   255
            Left            =   240
            TabIndex        =   148
            Top             =   420
            Width           =   135
         End
         Begin VB.Label Label49 
            Caption         =   "Pupil"
            Height          =   255
            Left            =   5280
            TabIndex        =   147
            Top             =   180
            Width           =   495
         End
         Begin VB.Label Label48 
            Caption         =   "Corn"
            Height          =   255
            Left            =   4680
            TabIndex        =   146
            Top             =   180
            Width           =   375
         End
         Begin VB.Label Label47 
            Caption         =   "Palp"
            Height          =   255
            Left            =   4080
            TabIndex        =   145
            Top             =   180
            Width           =   495
         End
         Begin VB.Label Label46 
            Caption         =   "K-reading"
            Height          =   255
            Left            =   2880
            TabIndex        =   144
            Top             =   180
            Width           =   855
         End
         Begin VB.Label Label45 
            Caption         =   "Axis"
            Height          =   255
            Left            =   2040
            TabIndex        =   143
            Top             =   180
            Width           =   375
         End
         Begin VB.Label Label44 
            Caption         =   "Cylinder"
            Height          =   255
            Left            =   1320
            TabIndex        =   142
            Top             =   180
            Width           =   615
         End
         Begin VB.Label Label43 
            Caption         =   "Sphere"
            Height          =   255
            Left            =   600
            TabIndex        =   141
            Top             =   180
            Width           =   615
         End
      End
      Begin Threed.SSFrame SSFrame11 
         Height          =   2595
         Left            =   -68520
         TabIndex        =   138
         Top             =   300
         Width           =   4695
         _ExtentX        =   8281
         _ExtentY        =   4577
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
         Begin VB.TextBox Text24 
            DataField       =   "Test"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   960
            Locked          =   -1  'True
            TabIndex        =   161
            TabStop         =   0   'False
            Text            =   "Text24"
            Top             =   1800
            Width           =   3615
         End
         Begin VB.TextBox Text23 
            DataField       =   "Evaluation"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   960
            Locked          =   -1  'True
            TabIndex        =   160
            TabStop         =   0   'False
            Text            =   "Text23"
            Top             =   1500
            Width           =   3615
         End
         Begin VB.TextBox Text22 
            DataField       =   "Reason"
            DataSource      =   "dtcCusPresCont"
            Height          =   315
            Left            =   960
            Locked          =   -1  'True
            TabIndex        =   159
            TabStop         =   0   'False
            Text            =   "Text22"
            Top             =   1140
            Width           =   3615
         End
         Begin VB.TextBox Text21 
            DataField       =   "Allergy"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   960
            Locked          =   -1  'True
            TabIndex        =   158
            TabStop         =   0   'False
            Text            =   "Text21"
            Top             =   840
            Width           =   3615
         End
         Begin VB.TextBox Text20 
            DataField       =   "Medical"
            DataSource      =   "dtcCusPresCont"
            Height          =   285
            Left            =   960
            Locked          =   -1  'True
            TabIndex        =   157
            TabStop         =   0   'False
            Text            =   "Text20"
            Top             =   540
            Width           =   3615
         End
         Begin VB.TextBox Text19 
            DataField       =   "History"
            DataSource      =   "dtcCusPresCont"
            Height          =   315
            Left            =   960
            Locked          =   -1  'True
            TabIndex        =   156
            TabStop         =   0   'False
            Text            =   "Text19"
            Top             =   180
            Width           =   3615
         End
         Begin VB.Label Label57 
            Caption         =   "Test"
            Height          =   255
            Left            =   120
            TabIndex        =   155
            Top             =   1800
            Width           =   375
         End
         Begin VB.Label Label56 
            Caption         =   "Evaluation"
            Height          =   255
            Left            =   120
            TabIndex        =   154
            Top             =   1500
            Width           =   855
         End
         Begin VB.Label Label55 
            Caption         =   "Reason"
            Height          =   255
            Left            =   120
            TabIndex        =   153
            Top             =   1140
            Width           =   615
         End
         Begin VB.Label Label54 
            Caption         =   "Allergy"
            Height          =   255
            Left            =   120
            TabIndex        =   152
            Top             =   840
            Width           =   615
         End
         Begin VB.Label Label53 
            Caption         =   "Medical"
            Height          =   255
            Left            =   120
            TabIndex        =   151
            Top             =   540
            Width           =   615
         End
         Begin VB.Label Label52 
            Caption         =   "History"
            Height          =   255
            Left            =   120
            TabIndex        =   150
            Top             =   180
            Width           =   615
         End
      End
      Begin Threed.SSFrame SSFrame12 
         Height          =   915
         Left            =   -74880
         TabIndex        =   162
         Top             =   300
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
         Begin MSDBCtls.DBCombo dbcPresLensDr 
            Bindings        =   "frmInfoCustomer.frx":12767
            DataField       =   "IssuedByDr"
            DataSource      =   "dtcCusPresLens"
            Height          =   315
            Left            =   2160
            TabIndex        =   69
            TabStop         =   0   'False
            Top             =   480
            Width           =   2535
            _ExtentX        =   4471
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "DoctorName"
            BoundColumn     =   "ID"
            Text            =   "dbcPresLensDr"
         End
         Begin SSCalendarWidgets_A.SSDateCombo calPresLensDate 
            DataField       =   "IssuedOn"
            DataSource      =   "dtcCusPresLens"
            Height          =   315
            Left            =   120
            TabIndex        =   68
            TabStop         =   0   'False
            Top             =   480
            Width           =   1815
            _Version        =   65543
            _ExtentX        =   3201
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
            SpinButton      =   0
         End
         Begin VB.Label Label59 
            Caption         =   "Issued by Dr."
            Height          =   255
            Left            =   2160
            TabIndex        =   165
            Top             =   240
            Width           =   1095
         End
         Begin VB.Label Label58 
            Caption         =   "Issued on"
            Height          =   255
            Left            =   120
            TabIndex        =   164
            Top             =   240
            Width           =   975
         End
      End
      Begin Threed.SSFrame SSFrame13 
         Height          =   1635
         Left            =   -74880
         TabIndex        =   163
         Top             =   1260
         Width           =   6255
         _ExtentX        =   11033
         _ExtentY        =   2884
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
         Begin VB.TextBox Text54 
            DataField       =   "LeftAdd"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   4800
            Locked          =   -1  'True
            TabIndex        =   83
            TabStop         =   0   'False
            Text            =   "Text54"
            Top             =   720
            Width           =   495
         End
         Begin VB.TextBox Text53 
            DataField       =   "LeftPrism"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   4200
            Locked          =   -1  'True
            TabIndex        =   82
            TabStop         =   0   'False
            Text            =   "Text53"
            Top             =   720
            Width           =   615
         End
         Begin VB.TextBox Text52 
            DataField       =   "LeftPdNear"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   3360
            Locked          =   -1  'True
            TabIndex        =   81
            TabStop         =   0   'False
            Text            =   "Text52"
            Top             =   720
            Width           =   855
         End
         Begin VB.TextBox Text51 
            DataField       =   "LeftPdDist"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   2640
            Locked          =   -1  'True
            TabIndex        =   80
            TabStop         =   0   'False
            Text            =   "Text51"
            Top             =   720
            Width           =   735
         End
         Begin VB.TextBox Text50 
            DataField       =   "LeftAxis"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   2160
            Locked          =   -1  'True
            TabIndex        =   79
            TabStop         =   0   'False
            Text            =   "Text50"
            Top             =   720
            Width           =   495
         End
         Begin VB.TextBox Text49 
            DataField       =   "LeftCylinder"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   1440
            Locked          =   -1  'True
            TabIndex        =   78
            TabStop         =   0   'False
            Text            =   "Text49"
            Top             =   720
            Width           =   735
         End
         Begin VB.TextBox Text48 
            DataField       =   "LeftSphere"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   720
            Locked          =   -1  'True
            TabIndex        =   77
            TabStop         =   0   'False
            Text            =   "Text48"
            Top             =   720
            Width           =   735
         End
         Begin VB.TextBox Text47 
            DataField       =   "RightAdd"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   4800
            Locked          =   -1  'True
            TabIndex        =   76
            TabStop         =   0   'False
            Text            =   "Text47"
            Top             =   420
            Width           =   495
         End
         Begin VB.TextBox Text46 
            DataField       =   "RightPrism"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   4200
            Locked          =   -1  'True
            TabIndex        =   75
            TabStop         =   0   'False
            Text            =   "Text46"
            Top             =   420
            Width           =   615
         End
         Begin VB.TextBox Text45 
            DataField       =   "RightPdNear"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   3360
            Locked          =   -1  'True
            TabIndex        =   74
            TabStop         =   0   'False
            Text            =   "Text45"
            Top             =   420
            Width           =   855
         End
         Begin VB.TextBox Text44 
            DataField       =   "RightPdDist"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   2640
            Locked          =   -1  'True
            TabIndex        =   73
            TabStop         =   0   'False
            Text            =   "Text44"
            Top             =   420
            Width           =   735
         End
         Begin VB.TextBox Text43 
            DataField       =   "RightAxis"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   2160
            Locked          =   -1  'True
            TabIndex        =   72
            TabStop         =   0   'False
            Text            =   "Text43"
            Top             =   420
            Width           =   495
         End
         Begin VB.TextBox Text42 
            DataField       =   "RightCylinder"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   1440
            Locked          =   -1  'True
            TabIndex        =   71
            TabStop         =   0   'False
            Text            =   "Text42"
            Top             =   420
            Width           =   735
         End
         Begin VB.TextBox Text25 
            DataField       =   "RightSphere"
            DataSource      =   "dtcCusPresLens"
            Height          =   285
            Left            =   720
            Locked          =   -1  'True
            TabIndex        =   70
            TabStop         =   0   'False
            Text            =   "Text25"
            Top             =   420
            Width           =   735
         End
         Begin VB.Label Label68 
            Caption         =   "L"
            Height          =   255
            Left            =   480
            TabIndex        =   174
            Top             =   900
            Width           =   135
         End
         Begin VB.Label Label67 
            Caption         =   "R"
            Height          =   255
            Left            =   480
            TabIndex        =   173
            Top             =   480
            Width           =   135
         End
         Begin VB.Label Label66 
            Caption         =   "Add"
            Height          =   255
            Left            =   4920
            TabIndex        =   172
            Top             =   180
            Width           =   375
         End
         Begin VB.Label Label65 
            Caption         =   "Prism"
            Height          =   255
            Left            =   4320
            TabIndex        =   171
            Top             =   180
            Width           =   495
         End
         Begin VB.Label Label64 
            Caption         =   "PD Near"
            Height          =   255
            Left            =   3480
            TabIndex        =   170
            Top             =   180
            Width           =   735
         End
         Begin VB.Label Label63 
            Caption         =   "PD Dist"
            Height          =   255
            Left            =   2760
            TabIndex        =   169
            Top             =   180
            Width           =   615
         End
         Begin VB.Label Label62 
            Caption         =   "Axis"
            Height          =   255
            Left            =   2280
            TabIndex        =   168
            Top             =   180
            Width           =   375
         End
         Begin VB.Label Label61 
            Caption         =   "Cylinder"
            Height          =   255
            Left            =   1560
            TabIndex        =   167
            Top             =   180
            Width           =   615
         End
         Begin VB.Label Label60 
            Caption         =   "Sphere"
            Height          =   255
            Left            =   840
            TabIndex        =   166
            Top             =   180
            Width           =   615
         End
      End
      Begin Threed.SSCommand cmdPrnRxCN 
         Height          =   270
         Left            =   -69120
         TabIndex        =   181
         TabStop         =   0   'False
         ToolTipText     =   "Print Prescription"
         Top             =   0
         Width           =   495
         _ExtentX        =   873
         _ExtentY        =   476
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
         Picture         =   "frmInfoCustomer.frx":1277F
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdPrnRxLN 
         Height          =   270
         Left            =   -69120
         TabIndex        =   180
         TabStop         =   0   'False
         ToolTipText     =   "Print Prescription"
         Top             =   0
         Width           =   495
         _ExtentX        =   873
         _ExtentY        =   476
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
         Picture         =   "frmInfoCustomer.frx":12DE3
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdPrnClaimReceipt 
         Height          =   270
         Left            =   -64920
         TabIndex        =   179
         TabStop         =   0   'False
         ToolTipText     =   "Print Claim Receipt"
         Top             =   0
         Width           =   1305
         _ExtentX        =   2302
         _ExtentY        =   476
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "Claim Receipt"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdPrnPrescription 
         Height          =   270
         Left            =   -66240
         TabIndex        =   178
         TabStop         =   0   'False
         ToolTipText     =   "Print Prescription"
         Top             =   0
         Width           =   1305
         _ExtentX        =   2302
         _ExtentY        =   476
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "Prescription"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdPrnInvoice 
         Height          =   270
         Left            =   -67560
         TabIndex        =   177
         TabStop         =   0   'False
         ToolTipText     =   "Print Invoice"
         Top             =   0
         Width           =   1305
         _ExtentX        =   2302
         _ExtentY        =   476
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "Invoice"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdPrnOrder 
         Height          =   270
         Left            =   -68880
         TabIndex        =   176
         TabStop         =   0   'False
         ToolTipText     =   "Print Order"
         Top             =   0
         Width           =   1305
         _ExtentX        =   2302
         _ExtentY        =   476
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "Order"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
End
Attribute VB_Name = "frmInfoCustomer"
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

Private Sub cmdFindBizPhone_Click()
    Dim strSQL As String
    
    On Error GoTo cmdFindBizPhone_Click_Err


    If txtSelBizPhone <> "" Then
        ' Lookup dtcCustomer
        If Trim(txtSelBizAreaCode.Text) <> "" Then
            strSQL = "SELECT Customer.*, City.CityPhoneCode " _
                   & "FROM City RIGHT JOIN Customer ON City.Code = Customer.BizCity " _
                   & "WHERE Customer.BizPhone LIKE '" & txtSelBizPhone.Text & "' AND " _
                   & "City.CityPhoneCode = '" & txtSelBizAreaCode.Text & "' " _
                   & "ORDER BY FullName"
        Else
            strSQL = "SELECT * FROM Customer " _
                   & "WHERE BizPhone LIKE '" & txtSelBizPhone.Text & "' " _
                   & "ORDER BY FullName"
        End If
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        dtcCustomer.UpdateControls
        IsPrintEnable
    End If


cmdFindBizPhone_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                   ' Tutorial Autocode
    Exit Sub                                               ' Tutorial Autocode
cmdFindBizPhone_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdFindBizPhone_Click()", Err)  ' Tutorial Autocode
    Resume cmdFindBizPhone_Click_Exit

End Sub

Private Sub cmdFindCellular_Click()
    Dim strSQL As String
    
    On Error GoTo cmdFindCellular_Click_Err


    If txtSelCellular <> "" Then
        ' Lookup dtcCustomer
        If Trim(txtSelCellAreaCode.Text) <> "" Then
            strSQL = "SELECT Customer.*, City.CityPhoneCode " _
                   & "FROM City RIGHT JOIN Customer ON City.Code = Customer.HomeCity " _
                   & "WHERE Customer.Cellular LIKE '" & txtSelCellular.Text & "' AND " _
                   & "City.CityPhoneCode = '" & txtSelCellAreaCode.Text & "' " _
                   & "ORDER BY FullName"
        Else
            strSQL = "SELECT * FROM Customer " _
                   & "WHERE Cellular LIKE '" & txtSelCellular.Text & "' " _
                   & "ORDER BY FullName"
        End If
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        dtcCustomer.UpdateControls
        IsPrintEnable
    End If


cmdFindCellular_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                   ' Tutorial Autocode
    Exit Sub                                               ' Tutorial Autocode
cmdFindCellular_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdFindCellular_Click()", Err)  ' Tutorial Autocode
    Resume cmdFindCellular_Click_Exit

End Sub


Private Sub cmdFindHomePhone_Click()
    Dim strSQL As String
    
    On Error GoTo cmdFindHomePhone_Click_Err


    If txtSelHomePhone <> "" Then
        ' Lookup dtcCustomer
        If Trim(txtSelHomeAreaCode.Text) <> "" Then
            strSQL = "SELECT Customer.*, City.CityPhoneCode " _
                   & "FROM City RIGHT JOIN Customer ON City.Code = Customer.HomeCity " _
                   & "WHERE Customer.HomePhone LIKE '" & txtSelHomePhone.Text & "' AND " _
                   & "City.CityPhoneCode = '" & txtSelHomeAreaCode.Text & "' " _
                   & "ORDER BY FullName"
        Else
            strSQL = "SELECT * FROM Customer " _
                   & "WHERE HomePhone LIKE '" & txtSelHomePhone.Text & "' " _
                   & "ORDER BY FullName"
        End If
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        dtcCustomer.UpdateControls
        IsPrintEnable
    End If


cmdFindHomePhone_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                    ' Tutorial Autocode
    Exit Sub                                                ' Tutorial Autocode
cmdFindHomePhone_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdFindHomePhone_Click()", Err)  ' Tutorial Autocode
    Resume cmdFindHomePhone_Click_Exit

End Sub



Private Sub cmdFindVIP_Click()
    Dim strSQL As String
    
    On Error GoTo cmdFindVIP_Click_Err


    If txtSelVIPCode <> "" Then
        ' Lookup dtcCustomer
        strSQL = "SELECT * FROM Customer " _
               & "WHERE VIPCode LIKE '" & txtSelVIPCode.Text & "' " _
               & "ORDER BY FullName"
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        dtcCustomer.UpdateControls
        IsPrintEnable
    End If


cmdFindVIP_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
cmdFindVIP_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdFindVIP_Click()", Err)  ' Tutorial Autocode
    Resume cmdFindVIP_Click_Exit

End Sub

Private Sub cmdPrnClaimReceipt_Click()
    Dim strTxNumber As String
    
    strTxNumber = ofx_CStr(dbgOrders.Columns("Invoice Number").Value)
    If strTxNumber <> "" Then
        RptTxNumberFrom = strTxNumber
        Screen.MousePointer = vbHourglass
        Call PrintClaimReceipt(1, 0)
    End If

End Sub

Private Sub cmdPrnInvoice_Click()
    Dim strTxNumber As String
    
    strTxNumber = ofx_CStr(dbgOrders.Columns("Invoice Number").Value)
    If strTxNumber <> "" Then
        RptTxNumberFrom = strTxNumber
        Screen.MousePointer = vbHourglass
        Call PrintInvoice(1, 0)
    End If
End Sub

Private Sub cmdPrnOrder_Click()
    Dim strTxNumber As String
    
    strTxNumber = ofx_CStr(dbgOrders.Columns("Order Number").Value)
    If strTxNumber <> "" Then
        RptTxNumberFrom = strTxNumber
        Screen.MousePointer = vbHourglass
        Call PrintOrder(1, 0)
    End If

End Sub


Private Sub cmdPrnPrescription_Click()
    Dim strTxNumber As String
    
    strTxNumber = ofx_CStr(dbgOrders.Columns("Order Number").Value)
    If strTxNumber <> "" Then
        RptTxNumberFrom = strTxNumber
        Screen.MousePointer = vbHourglass
        Call PrintRxTxNum(1, 0)
    End If


End Sub

Private Sub cmdPrnRxCN_Click()
    Dim strTxNumber As String
    
    strTxNumber = ofx_CStr(TDBGrid1.Columns("Customer No.").Value)
    If strTxNumber <> "" Then
        RptTxNumberFrom = dtcCustomer.Recordset!ID
        Screen.MousePointer = vbHourglass
        Call PrintRxCust(1, 0)
    End If
End Sub

Private Sub cmdPrnRxLN_Click()
    Dim strTxNumber As String
    
    strTxNumber = ofx_CStr(TDBGrid1.Columns("Customer No.").Value)
    If strTxNumber <> "" Then
        RptTxNumberFrom = dtcCustomer.Recordset!ID
        Screen.MousePointer = vbHourglass
        Call PrintRxCust(1, 0)
    End If
End Sub


Private Sub dbcSelCity_Click(intArea As Integer)

    On Error GoTo dbcSelCity_Click_Err

    Dim strSQL As String
    If intArea = dbcAreaList Then
        ' Lookup dtcCustomer
        strSQL = "SELECT * FROM Customer " _
               & "WHERE HomeCity = " & dbcSelCity.BoundText & " " _
               & "ORDER BY FullName"
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        dtcCustomer.UpdateControls
        IsPrintEnable
    End If


dbcSelCity_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
dbcSelCity_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelCity_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelCity_Click_Exit

End Sub

Private Sub dbcSelCountry_Click(intArea As Integer)
    Dim strSQL As String
    
    On Error GoTo dbcSelCountry_Click_Err


    If intArea = dbcAreaList Then
        ' Lookup dtcCustomer
        strSQL = "SELECT * FROM Customer " _
               & "WHERE HomeCountry = '" & dbcSelCountry.BoundText & "' " _
               & "ORDER BY FullName"
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        dtcCustomer.UpdateControls
        IsPrintEnable
    End If


dbcSelCountry_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                 ' Tutorial Autocode
    Exit Sub                                             ' Tutorial Autocode
dbcSelCountry_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelCountry_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelCountry_Click_Exit

End Sub

Private Sub dbcSelFirstName_Click(intArea As Integer)
    Dim strSQL As String
    
    On Error GoTo dbcSelFirstName_Click_Err


    If intArea = dbcAreaList Then
        ' Lookup dtcCustomer
        strSQL = "SELECT * FROM Customer " _
               & "WHERE FirstName = '" & dbcSelFirstName.BoundText & "' " _
               & "ORDER BY FullName"
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        dtcCustomer.UpdateControls
        IsPrintEnable
    End If


dbcSelFirstName_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                   ' Tutorial Autocode
    Exit Sub                                               ' Tutorial Autocode
dbcSelFirstName_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelFirstName_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelFirstName_Click_Exit

End Sub

Private Sub dbcSelFullName_Click(intArea As Integer)
    Dim strSQL As String
    
    On Error GoTo dbcSelFullName_Click_Err


    If intArea = dbcAreaList Then
        ' Lookup dtcCustomer
        strSQL = "SELECT * FROM Customer " _
               & "WHERE FullName = '" & dbcSelFullName.BoundText & "' " _
               & "ORDER BY FullName"
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        dtcCustomer.UpdateControls
        IsPrintEnable
    End If


dbcSelFullName_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                  ' Tutorial Autocode
    Exit Sub                                              ' Tutorial Autocode
dbcSelFullName_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelFullName_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelFullName_Click_Exit

End Sub

Private Sub dbcSelID_Click(intArea As Integer)
    Dim strSQL As String

    On Error GoTo dbcSelID_Click_Err

    If intArea = dbcAreaList Then
        ' Lookup dtcCustomer
        strSQL = "SELECT * FROM Customer " _
               & "WHERE ID = " & dbcSelID.BoundText & " " _
               & "ORDER BY FullName"
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        dtcCustomer.UpdateControls
        IsPrintEnable
    End If


dbcSelID_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                            ' Tutorial Autocode
    Exit Sub                                        ' Tutorial Autocode
dbcSelID_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelID_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelID_Click_Exit

End Sub

Private Sub dbcSelLastName_Click(intArea As Integer)
    Dim strSQL As String
    
    On Error GoTo dbcSelLastName_Click_Err


    If intArea = dbcAreaList Then
        ' Lookup dtcCustomer
        strSQL = "SELECT * FROM Customer " _
               & "WHERE LastName = '" & dbcSelLastName.BoundText & "' " _
               & "ORDER BY FullName"
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        dtcCustomer.UpdateControls
        IsPrintEnable
    End If


dbcSelLastName_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                  ' Tutorial Autocode
    Exit Sub                                              ' Tutorial Autocode
dbcSelLastName_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelLastName_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelLastName_Click_Exit

End Sub

Private Sub dbcSelProvince_Click(intArea As Integer)
    Dim strSQL As String
    
    On Error GoTo dbcSelProvince_Click_Err


    If intArea = dbcAreaList Then
        ' Lookup dtcCustomer
        strSQL = "SELECT * FROM Customer " _
               & "WHERE HomeProvince = '" & dbcSelProvince.BoundText & "' " _
               & "ORDER BY FullName"
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        dtcCustomer.UpdateControls
        IsPrintEnable
    End If


dbcSelProvince_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                  ' Tutorial Autocode
    Exit Sub                                              ' Tutorial Autocode
dbcSelProvince_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcSelProvince_Click()", Err)  ' Tutorial Autocode
    Resume dbcSelProvince_Click_Exit

End Sub



Private Sub dbgOrders_GotFocus()
    Screen.MousePointer = vbArrowQuestion
End Sub


Private Sub dbgOrders_LostFocus()
    Screen.MousePointer = vbDefault
End Sub

Private Sub dbgOrders_RowColChange(LastRow As Variant, ByVal LastCol As Integer)
    IsPrintEnable
End Sub


Private Sub dtcCustomer_Reposition()

'    On Error GoTo dtcCustomer_Reposition_Err


    Dim strTarget As String
    If Not (dtcCustomer.Recordset.EOF Or dtcCustomer.Recordset.BOF) Then
        ' Not an empty table
        Call SetMenuButton(1)      ' Enable navigation buttons
        ' Sync Home Address
        If dtcCustomer.Recordset!HomeCity <> "" Then
            strTarget = "SELECT * FROM qryCityFullList WHERE City.Code = " & dtcCustomer.Recordset!HomeCity
        Else
            strTarget = "SELECT * FROM qryCityFullList WHERE City.Code = 0"
        End If
        dtcHomeCity.RecordSource = strTarget
        dtcHomeCity.Refresh
        dtcHomeCity.UpdateControls
        ' Sync Biz Address
        If dtcCustomer.Recordset!BizCity <> "" Then
            strTarget = "SELECT * FROM qryCityFullList WHERE City.Code = " & dtcCustomer.Recordset!BizCity
        Else
            strTarget = "SELECT * FROM qryCityFullList WHERE City.Code = 0"
        End If
        dtcBizCity.RecordSource = strTarget
        dtcBizCity.Refresh
        dtcBizCity.UpdateControls
        ' Sync Customer Medical Table
        strTarget = "SELECT * FROM CustomerMedical WHERE CustomerID = " & dtcCustomer.Recordset!ID
        dtcCusMedical.RecordSource = strTarget
        dtcCusMedical.Refresh
        dtcCusMedical.UpdateControls
        ' Sync Customer Prescription (Lens) Table
        strTarget = "SELECT * FROM CustomerPresLens WHERE CustomerID = " & dtcCustomer.Recordset!ID
        dtcCusPresLens.RecordSource = strTarget
        dtcCusPresLens.Refresh
        dtcCusPresLens.UpdateControls
        ' Sync Customer Prescription (Contact Lens)Table
        strTarget = "SELECT * FROM CustomerPresContact WHERE CustomerID = " & dtcCustomer.Recordset!ID
        dtcCusPresCont.RecordSource = strTarget
        dtcCusPresCont.Refresh
        dtcCusPresCont.UpdateControls
        
        ' Sync qrySOrderSimple Table
        strTarget = "SELECT * FROM qrySOrderSimple WHERE CustomerID = " & dtcCustomer.Recordset!ID
        dtcQrySOrderSimple.RecordSource = strTarget
        dtcQrySOrderSimple.Refresh
        dtcQrySOrderSimple.UpdateControls
        
        ' The following lines are added because the Sheriden's Calendar DateCombo
        ' could not handle DataBound with Null value properly.
        If Not IsNull(dtcCustomer.Recordset!Birthday) Then _
            calBirthday.Text = Format(dtcCustomer.Recordset!Birthday, "MM/DD/YYYY")
        If Not (dtcCusMedical.Recordset.EOF And dtcCusMedical.Recordset.BOF) Then
            If Not IsNull(dtcCusMedical.Recordset!InsMaturityDate) Then _
                calInsMaturityDate.Text = Format(dtcCusMedical.Recordset!InsMaturityDate, "MM/DD/YYYY")
        End If
        If Not (dtcCusPresLens.Recordset.EOF And dtcCusPresLens.Recordset.BOF) Then
            If Not IsNull(dtcCusPresLens.Recordset!IssuedOn) Then _
                calPresLensDate.Text = Format(dtcCusPresLens.Recordset!IssuedOn, "MM/DD/YYYY")
        End If
        If Not (dtcCusPresCont.Recordset.EOF And dtcCusPresCont.Recordset.BOF) Then
            If Not IsNull(dtcCusPresCont.Recordset!IssuedOn) Then _
                calPresContDate.Text = Format(dtcCusPresCont.Recordset!IssuedOn, "MM/DD/YYYY")
        End If
        If Not (dtcCusAccount.Recordset.EOF And dtcCusAccount.Recordset.BOF) Then
            If Not IsNull(dtcCusAccount.Recordset!JointDate) Then _
                calJointDate.Text = Format(dtcCusAccount.Recordset!JointDate, "MM/DD/YYYY")
        End If
    Else
        ' an empty table
        Call SetMenuButton(0)      ' Disable navigation buttons
    End If


dtcCustomer_Reposition_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                    ' Tutorial Autocode
    Exit Sub                                                ' Tutorial Autocode
dtcCustomer_Reposition_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dtcCustomer_Reposition()", Err)  ' Tutorial Autocode
    Resume dtcCustomer_Reposition_Exit

End Sub

Private Sub Form_Activate()

    On Error GoTo Form_Activate_Err

    Screen.MousePointer = vbDefault


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
    Call SetMenuButton(0)      ' Disable navigation buttons
    
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

Private Sub SSIndexTab1_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    IsPrintEnable
End Sub


Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

    On Error GoTo SSToolbar1_Click_Err


    Select Case ToolID
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            dtcCustomer.Recordset.MoveFirst
        Case "ID_Next"
            dtcCustomer.Recordset.MoveNext
            ' Prevent the Blank Record
            If dtcCustomer.Recordset.EOF Then
                Beep
                dtcCustomer.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcCustomer.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcCustomer.Recordset.BOF Then
                Beep
                dtcCustomer.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcCustomer.Recordset.MoveLast
        Case "ID_Copy"
            If ofx_IsFormLoaded(frmSalesOrder) Then
                frmSalesOrder.txtCustomerName.Tag = dtcCustomer.Recordset!ID
                frmSalesOrder.txtCustomerName.Text = dtcCustomer.Recordset!FullName
                MsgBox "Customer " & dtcCustomer.Recordset!FullName & " is copied"
            End If
'            Call SetXchgCustomer(dtcCustomer.Recordset.Fields("FullName"), _
                                dtcCustomer.Recordset.Fields("ID"))
'            pyTheCustomer.Text dtcCustomer.Recordset.Fields("FullName")
'            pyTheCustomer.BoundText dtcCustomer.Recordset.Fields("ID")
'            MsgBox "Customer Code " & dtcCustomer.Recordset.Fields("ID") & " Copied."
        Case "ID_Append"
            Clipboard.SetText dtcCustomer.Recordset.Fields("ID")
            MsgBox "Customer Code " & dtcCustomer.Recordset.Fields("ID") & " Copied."
        Case "ID_Add"
            If ofx_IsFormLoaded(frmCustomer) Then
                frmCustomer.SetFocus
                SendKeys "% R", True
                frmCustomer.ZOrder
            Else
                Screen.MousePointer = vbHourglass
                frmCustomer.Show
            End If
    End Select


SSToolbar1_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSToolbar1_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSToolbar1_Click()", Err)  ' Tutorial Autocode
    Resume SSToolbar1_Click_Exit

End Sub






Private Sub TDBGrid1_GotFocus()
   IsPrintEnable
End Sub




Private Sub TDBGrid1_RowColChange(LastRow As Variant, ByVal LastCol As Integer)
   IsPrintEnable
End Sub



Private Sub txtSelBizAreaCode_GotFocus()

    On Error GoTo txtSelBizAreaCode_GotFocus_Err

    Call AutoSelect(txtSelBizAreaCode)


txtSelBizAreaCode_GotFocus_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                     ' Tutorial Autocode
    Exit Sub                                                 ' Tutorial Autocode
txtSelBizAreaCode_GotFocus_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("txtSelBizAreaCode_GotFocus()", Err)  ' Tutorial Autocode
    Resume txtSelBizAreaCode_GotFocus_Exit

End Sub

Private Sub txtSelBizAreaCode_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindBizPhone_Click
        KeyAscii = 0
    End If
End Sub

Private Sub txtSelBizPhone_GotFocus()

    On Error GoTo txtSelBizPhone_GotFocus_Err

    Call AutoSelect(txtSelBizPhone)


txtSelBizPhone_GotFocus_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                     ' Tutorial Autocode
    Exit Sub                                                 ' Tutorial Autocode
txtSelBizPhone_GotFocus_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("txtSelBizPhone_GotFocus()", Err)  ' Tutorial Autocode
    Resume txtSelBizPhone_GotFocus_Exit

End Sub


Private Sub txtSelBizPhone_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindBizPhone_Click
        KeyAscii = 0
    End If
End Sub


Private Sub txtSelCellAreaCode_GotFocus()

    On Error GoTo txtSelCellAreaCode_GotFocus_Err

    Call AutoSelect(txtSelCellAreaCode)


txtSelCellAreaCode_GotFocus_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                     ' Tutorial Autocode
    Exit Sub                                                 ' Tutorial Autocode
txtSelCellAreaCode_GotFocus_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("txtSelCellAreaCode_GotFocus()", Err)  ' Tutorial Autocode
    Resume txtSelCellAreaCode_GotFocus_Exit

End Sub

Private Sub txtSelCellAreaCode_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindCellular_Click
        KeyAscii = 0
    End If
End Sub

Private Sub txtSelCellular_GotFocus()

    On Error GoTo txtSelCellular_GotFocus_Err

    Call AutoSelect(txtSelCellular)


txtSelCellular_GotFocus_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                     ' Tutorial Autocode
    Exit Sub                                                 ' Tutorial Autocode
txtSelCellular_GotFocus_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("txtSelCellular_GotFocus()", Err)  ' Tutorial Autocode
    Resume txtSelCellular_GotFocus_Exit

End Sub


Private Sub txtSelCellular_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindCellular_Click
        KeyAscii = 0
    End If
End Sub


Private Sub txtSelHomeAreaCode_GotFocus()

    On Error GoTo txtSelHomeAreaCode_GotFocus_Err

    Call AutoSelect(txtSelHomeAreaCode)


txtSelHomeAreaCode_GotFocus_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                      ' Tutorial Autocode
    Exit Sub                                                  ' Tutorial Autocode
txtSelHomeAreaCode_GotFocus_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("txtSelHomeAreaCode_GotFocus()", Err)  ' Tutorial Autocode
    Resume txtSelHomeAreaCode_GotFocus_Exit

End Sub

Private Sub txtSelHomeAreaCode_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindHomePhone_Click
        KeyAscii = 0
    End If
End Sub

Private Sub txtSelHomePhone_GotFocus()

    On Error GoTo txtSelHomePhone_GotFocus_Err

    Call AutoSelect(txtSelHomePhone)


txtSelHomePhone_GotFocus_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                      ' Tutorial Autocode
    Exit Sub                                                  ' Tutorial Autocode
txtSelHomePhone_GotFocus_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("txtSelHomePhone_GotFocus()", Err)  ' Tutorial Autocode
    Resume txtSelHomePhone_GotFocus_Exit

End Sub


Private Sub txtSelHomePhone_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindHomePhone_Click
        KeyAscii = 0
    End If
End Sub


Private Sub txtSelVIPCode_GotFocus()

    On Error GoTo txtSelVIPCode_GotFocus_Err

    Call AutoSelect(txtSelVIPCode)

txtSelVIPCode_GotFocus_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                    ' Tutorial Autocode
    Exit Sub                                                ' Tutorial Autocode
txtSelVIPCode_GotFocus_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("txtSelVIPCode_GotFocus()", Err)  ' Tutorial Autocode
    Resume txtSelVIPCode_GotFocus_Exit

End Sub


Private Sub txtSelVIPCode_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindVIP_Click
        KeyAscii = 0
    End If
End Sub



Private Sub IsPrintEnable()
    Dim strTxNumber As String
    Dim xVisible As Boolean
    
    strTxNumber = ofx_CStr(TDBGrid1.Columns("Customer No.").Value)
    If strTxNumber <> "" Then
        cmdPrnRxCN.Visible = True
        cmdPrnRxLN.Visible = True
        strTxNumber = ofx_CStr(dbgOrders.Columns("Order Number").Value)
        xVisible = (strTxNumber <> "")
        cmdPrnOrder.Visible = xVisible
        cmdPrnPrescription.Visible = xVisible
        strTxNumber = ofx_CStr(dbgOrders.Columns("Invoice Number").Value)
        xVisible = (strTxNumber <> "")
        cmdPrnInvoice.Visible = xVisible
        cmdPrnClaimReceipt.Visible = xVisible
      Else
        cmdPrnRxCN.Visible = False
        cmdPrnRxLN.Visible = False
        cmdPrnOrder.Visible = False
        cmdPrnInvoice.Visible = False
        cmdPrnPrescription.Visible = False
        cmdPrnClaimReceipt.Visible = False
    End If

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

VERSION 5.00
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{B074BC93-5A5B-11CE-98BD-0000C0E6B88E}#2.0#0"; "sstabs32.ocx"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmSystemProfile 
   Caption         =   "System Profile"
   ClientHeight    =   5775
   ClientLeft      =   2790
   ClientTop       =   1590
   ClientWidth     =   7935
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5775
   ScaleWidth      =   7935
   Begin VB.Data dtcSelCity 
      Caption         =   "SelCity"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   315
      Left            =   6360
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT Code, CityName FROM City ORDER BY CityName"
      Top             =   1380
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.Data dtcUserCity 
      Caption         =   "UserCity"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   240
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "qryCityFullList"
      Top             =   2280
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.Data dtcOwnerCity 
      Caption         =   "OwnerCity"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   240
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "qryCityFullList"
      Top             =   1920
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.Data dtcPreference 
      Caption         =   "Preference"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   240
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Preference"
      Top             =   1560
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.TextBox Text4 
      DataField       =   "Paltform"
      DataSource      =   "dtcPreference"
      Height          =   285
      Left            =   1800
      Locked          =   -1  'True
      MaxLength       =   20
      TabIndex        =   7
      Text            =   "Text4"
      Top             =   840
      Width           =   1695
   End
   Begin VB.TextBox Text3 
      DataField       =   "NumberOfUser"
      DataSource      =   "dtcPreference"
      Height          =   285
      Left            =   1800
      Locked          =   -1  'True
      TabIndex        =   6
      Text            =   "Text3"
      Top             =   480
      Width           =   735
   End
   Begin VB.TextBox Text2 
      DataField       =   "Serial Number"
      DataSource      =   "dtcPreference"
      Height          =   285
      Left            =   1800
      Locked          =   -1  'True
      MaxLength       =   10
      TabIndex        =   5
      Text            =   "Text2"
      Top             =   120
      Width           =   1695
   End
   Begin VB.TextBox Text1 
      DataField       =   "ProductName"
      DataSource      =   "dtcPreference"
      Height          =   1455
      Left            =   1800
      Locked          =   -1  'True
      MaxLength       =   128
      MultiLine       =   -1  'True
      TabIndex        =   4
      Text            =   "frmSystemProfile.frx":0000
      Top             =   1200
      Width           =   4095
   End
   Begin SSDesignerWidgetsTabs.SSIndexTab SSIndexTab1 
      Height          =   2895
      Left            =   120
      TabIndex        =   8
      Top             =   2760
      Width           =   7695
      _Version        =   131078
      _ExtentX        =   13573
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
      Tab             =   2
      TabDefault      =   0
      TabVisibleLast  =   3
      TabShape        =   6
      TabsPerRow      =   6
      RingCount       =   9
      RingGroups      =   3
      PageTabOrientation=   0
      PageTabsPerRow  =   2
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
      TabsNum         =   4
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
      Tabs(0).Pages(0).CtlCount=   15
      Tabs(0).Pages(0).CtlEnabled=   0   'False
      Tabs(0).Pages(0).Ctl(0)=   "txtUserCountry"
      Tabs(0).Pages(0).Ctl(1)=   "txtUserProvince"
      Tabs(0).Pages(0).Ctl(2)=   "Text18"
      Tabs(0).Pages(0).Ctl(3)=   "Text13"
      Tabs(0).Pages(0).Ctl(4)=   "Text12"
      Tabs(0).Pages(0).Ctl(5)=   "SSFrame2"
      Tabs(0).Pages(0).Ctl(6)=   "mskUserPostalCode"
      Tabs(0).Pages(0).Ctl(7)=   "Label18"
      Tabs(0).Pages(0).Ctl(8)=   "Label20"
      Tabs(0).Pages(0).Ctl(9)=   "Label17"
      Tabs(0).Pages(0).Ctl(10)=   "Label16"
      Tabs(0).Pages(0).Ctl(11)=   "dbcUserCity"
      Tabs(0).Pages(0).Ctl(12)=   "Label15"
      Tabs(0).Pages(0).Ctl(13)=   "Label14"
      Tabs(0).Pages(0).Ctl(14)=   "Label12"
      Tabs(0).Tag     =   ""
      Tabs(0).Caption =   "User"
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
      Tabs(1).Pages(0).CtlCount=   15
      Tabs(1).Pages(0).CtlEnabled=   0   'False
      Tabs(1).Pages(0).Ctl(0)=   "txtOwnerProvince"
      Tabs(1).Pages(0).Ctl(1)=   "Text11"
      Tabs(1).Pages(0).Ctl(2)=   "txtOwnerCountry"
      Tabs(1).Pages(0).Ctl(3)=   "Text6"
      Tabs(1).Pages(0).Ctl(4)=   "Text5"
      Tabs(1).Pages(0).Ctl(5)=   "SSFrame3"
      Tabs(1).Pages(0).Ctl(6)=   "mskOwnerPostalCode"
      Tabs(1).Pages(0).Ctl(7)=   "Label13"
      Tabs(1).Pages(0).Ctl(8)=   "dbcOwnerCity"
      Tabs(1).Pages(0).Ctl(9)=   "Label10"
      Tabs(1).Pages(0).Ctl(10)=   "Label9"
      Tabs(1).Pages(0).Ctl(11)=   "Label8"
      Tabs(1).Pages(0).Ctl(12)=   "Label7"
      Tabs(1).Pages(0).Ctl(13)=   "Label6"
      Tabs(1).Pages(0).Ctl(14)=   "Label5"
      Tabs(1).Tag     =   ""
      Tabs(1).Caption =   "Owner"
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
      Tabs(2).Pages(0).CtlCount=   17
      Tabs(2).Pages(0).CtlEnabled=   -1  'True
      Tabs(2).Pages(0).Ctl(0)=   "Label21"
      Tabs(2).Pages(0).Ctl(1)=   "Label22"
      Tabs(2).Pages(0).Ctl(2)=   "Label23"
      Tabs(2).Pages(0).Ctl(3)=   "Label24"
      Tabs(2).Pages(0).Ctl(4)=   "Label25"
      Tabs(2).Pages(0).Ctl(5)=   "Label26"
      Tabs(2).Pages(0).Ctl(6)=   "Label27"
      Tabs(2).Pages(0).Ctl(7)=   "Label28"
      Tabs(2).Pages(0).Ctl(8)=   "SSDateCombo1"
      Tabs(2).Pages(0).Ctl(9)=   "SSDateCombo2"
      Tabs(2).Pages(0).Ctl(10)=   "mskPSTValue"
      Tabs(2).Pages(0).Ctl(11)=   "mskGSTValue"
      Tabs(2).Pages(0).Ctl(12)=   "SSFrame1"
      Tabs(2).Pages(0).Ctl(13)=   "txtBranchNumber"
      Tabs(2).Pages(0).Ctl(14)=   "txtCountryCode"
      Tabs(2).Pages(0).Ctl(15)=   "txtPSTNumber"
      Tabs(2).Pages(0).Ctl(16)=   "txtGSTNumber"
      Tabs(2).Tag     =   ""
      Tabs(2).Caption =   "General"
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
      Tabs(3).Pages(0).CtlCount=   2
      Tabs(3).Pages(0).CtlEnabled=   0   'False
      Tabs(3).Pages(0).Ctl(0)=   "TDBGrid1"
      Tabs(3).Pages(0).Ctl(1)=   "dtcPrefTxNumber"
      Tabs(3).Tag     =   ""
      Tabs(3).Caption =   "Numbers"
      Tabs(3).Name    =   "tab 3"
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
      Begin TrueDBGrid50.TDBGrid TDBGrid1 
         Bindings        =   "frmSystemProfile.frx":0006
         Height          =   2355
         Left            =   -74880
         OleObjectBlob   =   "frmSystemProfile.frx":0024
         TabIndex        =   69
         Top             =   420
         Width           =   7455
      End
      Begin VB.TextBox txtOwnerProvince 
         BackColor       =   &H00C0C0C0&
         DataField       =   "ProvinceName"
         DataSource      =   "dtcOwnerCity"
         Height          =   285
         Left            =   -73560
         Locked          =   -1  'True
         TabIndex        =   36
         TabStop         =   0   'False
         Text            =   "Text7"
         Top             =   1800
         Width           =   1815
      End
      Begin VB.TextBox txtUserCountry 
         BackColor       =   &H00C0C0C0&
         DataField       =   "CountryName"
         DataSource      =   "dtcUserCity"
         Height          =   285
         Left            =   -73560
         Locked          =   -1  'True
         TabIndex        =   23
         TabStop         =   0   'False
         Text            =   "Text14"
         Top             =   2160
         Width           =   1815
      End
      Begin VB.TextBox txtUserProvince 
         BackColor       =   &H00C0C0C0&
         DataField       =   "ProvinceName"
         DataSource      =   "dtcUserCity"
         Height          =   285
         Left            =   -73560
         Locked          =   -1  'True
         TabIndex        =   22
         TabStop         =   0   'False
         Text            =   "Text7"
         Top             =   1800
         Width           =   1815
      End
      Begin VB.Data dtcPrefTxNumber 
         Caption         =   "PrefTxNumber"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   315
         Left            =   -71400
         Options         =   0
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "PrefTxNumber"
         Top             =   1980
         Visible         =   0   'False
         Width           =   1935
      End
      Begin VB.TextBox txtGSTNumber 
         DataField       =   "GSTNumber"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   1320
         MaxLength       =   10
         TabIndex        =   61
         Text            =   "Text23"
         Top             =   1620
         Width           =   1215
      End
      Begin VB.TextBox txtPSTNumber 
         DataField       =   "PSTNumber"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   1320
         MaxLength       =   10
         TabIndex        =   59
         Text            =   "Text21"
         Top             =   1020
         Width           =   1215
      End
      Begin VB.TextBox txtCountryCode 
         DataField       =   "CountryCode"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   1320
         MaxLength       =   2
         TabIndex        =   58
         Text            =   "Text20"
         Top             =   720
         Width           =   735
      End
      Begin VB.TextBox txtBranchNumber 
         DataField       =   "BranchNumber"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   1320
         MaxLength       =   4
         TabIndex        =   57
         Text            =   "Text19"
         Top             =   420
         Width           =   735
      End
      Begin VB.TextBox Text18 
         DataField       =   "UserContactPerson"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   -70080
         MaxLength       =   30
         TabIndex        =   25
         Text            =   "Text18"
         Top             =   600
         Width           =   2655
      End
      Begin VB.TextBox Text13 
         DataField       =   "UserAddress"
         DataSource      =   "dtcPreference"
         Height          =   675
         Left            =   -73560
         MaxLength       =   128
         MultiLine       =   -1  'True
         TabIndex        =   19
         Text            =   "frmSystemProfile.frx":2751
         Top             =   720
         Width           =   3135
      End
      Begin VB.TextBox Text12 
         DataField       =   "UserName"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   -73560
         MaxLength       =   40
         TabIndex        =   17
         Text            =   "Text12"
         Top             =   360
         Width           =   3135
      End
      Begin VB.TextBox Text11 
         DataField       =   "OwnerContactPerson"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   -70080
         MaxLength       =   30
         TabIndex        =   41
         Text            =   "Text11"
         Top             =   600
         Width           =   2655
      End
      Begin VB.TextBox txtOwnerCountry 
         BackColor       =   &H00C0C0C0&
         DataField       =   "CountryName"
         DataSource      =   "dtcOwnerCity"
         Height          =   285
         Left            =   -73560
         Locked          =   -1  'True
         MaxLength       =   15
         TabIndex        =   38
         TabStop         =   0   'False
         Text            =   "Text9"
         Top             =   2160
         Width           =   1815
      End
      Begin VB.TextBox Text6 
         DataField       =   "OwnerAddress"
         DataSource      =   "dtcPreference"
         Height          =   675
         Left            =   -73560
         MaxLength       =   128
         MultiLine       =   -1  'True
         TabIndex        =   33
         Text            =   "frmSystemProfile.frx":2758
         Top             =   720
         Width           =   3135
      End
      Begin VB.TextBox Text5 
         DataField       =   "OwnerName"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   -73560
         MaxLength       =   40
         TabIndex        =   31
         Text            =   "Text5"
         Top             =   360
         Width           =   3135
      End
      Begin Threed.SSFrame SSFrame1 
         Height          =   1455
         Left            =   2760
         TabIndex        =   52
         Top             =   1320
         Width           =   2895
         _ExtentX        =   5106
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
         Caption         =   "Next"
         Begin VB.TextBox txtNextControlNumber 
            Alignment       =   1  'Right Justify
            DataField       =   "NextInvtControlNumber"
            DataSource      =   "dtcPreference"
            Height          =   285
            Left            =   1560
            MaxLength       =   8
            MultiLine       =   -1  'True
            TabIndex        =   65
            Text            =   "frmSystemProfile.frx":275E
            Top             =   240
            Width           =   1215
         End
         Begin VB.TextBox txtNextOrderNumber 
            Alignment       =   1  'Right Justify
            DataField       =   "NextSalesOrderNumber"
            DataSource      =   "dtcPreference"
            Height          =   285
            Left            =   1560
            MaxLength       =   8
            MultiLine       =   -1  'True
            TabIndex        =   68
            Text            =   "frmSystemProfile.frx":2764
            Top             =   1140
            Width           =   1215
         End
         Begin VB.TextBox txtNextInvoiceNumber 
            Alignment       =   1  'Right Justify
            DataField       =   "NextInvoiceNumber"
            DataSource      =   "dtcPreference"
            Height          =   285
            Left            =   1560
            MaxLength       =   8
            MultiLine       =   -1  'True
            TabIndex        =   67
            Text            =   "frmSystemProfile.frx":276B
            Top             =   840
            Width           =   1215
         End
         Begin VB.TextBox txtNextSKUNumber 
            Alignment       =   1  'Right Justify
            DataField       =   "NextInvtSKU"
            DataSource      =   "dtcPreference"
            Height          =   285
            Left            =   1560
            MaxLength       =   6
            MultiLine       =   -1  'True
            TabIndex        =   66
            Text            =   "frmSystemProfile.frx":2772
            Top             =   540
            Width           =   1215
         End
         Begin VB.Label Label32 
            Caption         =   "Order Number"
            Height          =   255
            Left            =   120
            TabIndex        =   56
            Top             =   1140
            Width           =   1095
         End
         Begin VB.Label Label31 
            Caption         =   "Invoice Number"
            Height          =   255
            Left            =   120
            TabIndex        =   55
            Top             =   840
            Width           =   1215
         End
         Begin VB.Label Label30 
            Caption         =   "SKU Number"
            Height          =   255
            Left            =   120
            TabIndex        =   54
            Top             =   540
            Width           =   1095
         End
         Begin VB.Label Label29 
            Caption         =   "Control Number"
            Height          =   255
            Left            =   120
            TabIndex        =   53
            Top             =   240
            Width           =   1215
         End
      End
      Begin Threed.SSFrame SSFrame2 
         Height          =   1875
         Left            =   -70080
         TabIndex        =   72
         Top             =   900
         Width           =   2655
         _ExtentX        =   4683
         _ExtentY        =   3307
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
         Begin VB.TextBox Text17 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CityPhoneCode"
            DataSource      =   "dtcUserCity"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   27
            TabStop         =   0   'False
            Text            =   "Text17"
            Top             =   600
            Width           =   495
         End
         Begin VB.TextBox Text16 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CountryPhoneCode"
            DataSource      =   "dtcUserCity"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   26
            TabStop         =   0   'False
            Text            =   "Text16"
            Top             =   300
            Width           =   495
         End
         Begin MSMask.MaskEdBox mskUserFax 
            DataField       =   "OwnerFax"
            DataSource      =   "dtcPreference"
            Height          =   255
            Left            =   1200
            TabIndex        =   29
            Top             =   1200
            Width           =   1335
            _ExtentX        =   2355
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   9
            Mask            =   "### #####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskUserPhone 
            DataField       =   "UserPhone"
            DataSource      =   "dtcPreference"
            Height          =   255
            Left            =   1200
            TabIndex        =   28
            Top             =   900
            Width           =   1335
            _ExtentX        =   2355
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   9
            Mask            =   "### #####"
            PromptChar      =   "_"
         End
         Begin VB.Label Label36 
            Caption         =   "Fax"
            Height          =   195
            Left            =   120
            TabIndex        =   76
            Top             =   1200
            Width           =   375
         End
         Begin VB.Label Label35 
            Caption         =   "Phone"
            Height          =   255
            Left            =   120
            TabIndex        =   75
            Top             =   900
            Width           =   615
         End
         Begin VB.Label Label34 
            Caption         =   "City Code"
            Height          =   195
            Left            =   120
            TabIndex        =   74
            Top             =   600
            Width           =   735
         End
         Begin VB.Label Label33 
            Caption         =   "Country Code"
            Height          =   195
            Left            =   120
            TabIndex        =   73
            Top             =   300
            Width           =   975
         End
      End
      Begin Threed.SSFrame SSFrame3 
         Height          =   1875
         Left            =   -70080
         TabIndex        =   78
         Top             =   900
         Width           =   2655
         _ExtentX        =   4683
         _ExtentY        =   3307
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
         Begin VB.TextBox Text8 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CityPhoneCode"
            DataSource      =   "dtcOwnerCity"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   43
            TabStop         =   0   'False
            Text            =   "Text8"
            Top             =   600
            Width           =   495
         End
         Begin VB.TextBox Text7 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CountryPhoneCode"
            DataSource      =   "dtcOwnerCity"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   42
            TabStop         =   0   'False
            Text            =   "Text7"
            Top             =   300
            Width           =   495
         End
         Begin MSMask.MaskEdBox mskOwnerFax 
            DataField       =   "OwnerFax"
            DataSource      =   "dtcPreference"
            Height          =   255
            Left            =   1200
            TabIndex        =   45
            Top             =   1200
            Width           =   1335
            _ExtentX        =   2355
            _ExtentY        =   450
            _Version        =   393216
            BackColor       =   16777215
            PromptInclude   =   0   'False
            MaxLength       =   9
            Mask            =   "### #####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskOwnerPhone 
            DataField       =   "OwnerPhone"
            DataSource      =   "dtcPreference"
            Height          =   255
            Left            =   1200
            TabIndex        =   44
            Top             =   900
            Width           =   1335
            _ExtentX        =   2355
            _ExtentY        =   450
            _Version        =   393216
            BackColor       =   16777215
            PromptInclude   =   0   'False
            MaxLength       =   9
            Mask            =   "### #####"
            PromptChar      =   "_"
         End
         Begin VB.Label Label38 
            Caption         =   "Fax"
            Height          =   195
            Left            =   120
            TabIndex        =   82
            Top             =   1200
            Width           =   375
         End
         Begin VB.Label Label37 
            Caption         =   "Phone"
            Height          =   255
            Left            =   120
            TabIndex        =   81
            Top             =   900
            Width           =   495
         End
         Begin VB.Label Label19 
            Caption         =   "City Code"
            Height          =   195
            Left            =   120
            TabIndex        =   80
            Top             =   600
            Width           =   855
         End
         Begin VB.Label Label11 
            Caption         =   "Country Code"
            Height          =   255
            Left            =   120
            TabIndex        =   79
            Top             =   300
            Width           =   975
         End
      End
      Begin MSMask.MaskEdBox mskOwnerPostalCode 
         DataField       =   "OwnerPostalCode"
         DataSource      =   "dtcPreference"
         Height          =   255
         Left            =   -73560
         TabIndex        =   39
         Top             =   2460
         Width           =   1095
         _ExtentX        =   1931
         _ExtentY        =   450
         _Version        =   393216
         PromptInclude   =   0   'False
         MaxLength       =   7
         Mask            =   ">a#a#a##"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskUserPostalCode 
         DataField       =   "UserPostalCode"
         DataSource      =   "dtcPreference"
         Height          =   255
         Left            =   -73560
         TabIndex        =   24
         Top             =   2460
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   450
         _Version        =   393216
         PromptInclude   =   0   'False
         MaxLength       =   7
         Mask            =   ">a#a#a##"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskGSTValue 
         DataField       =   "TaxBRate"
         DataSource      =   "dtcPreference"
         Height          =   255
         Left            =   1320
         TabIndex        =   62
         Top             =   1920
         Width           =   495
         _ExtentX        =   873
         _ExtentY        =   450
         _Version        =   393216
         MaxLength       =   5
         Format          =   "##0.00"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskPSTValue 
         DataField       =   "TaxARate"
         DataSource      =   "dtcPreference"
         Height          =   255
         Left            =   1320
         TabIndex        =   60
         Top             =   1320
         Width           =   495
         _ExtentX        =   873
         _ExtentY        =   450
         _Version        =   393216
         MaxLength       =   5
         Format          =   "##0.00"
         PromptChar      =   "_"
      End
      Begin SSCalendarWidgets_A.SSDateCombo SSDateCombo2 
         DataField       =   "CurrentMonth"
         DataSource      =   "dtcPreference"
         Height          =   255
         Left            =   3840
         TabIndex        =   64
         Top             =   720
         Width           =   1815
         _Version        =   65543
         _ExtentX        =   3201
         _ExtentY        =   450
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
         SpinButton      =   0
      End
      Begin SSCalendarWidgets_A.SSDateCombo SSDateCombo1 
         DataField       =   "FiscalPeriod"
         DataSource      =   "dtcPreference"
         Height          =   255
         Left            =   3840
         TabIndex        =   63
         Top             =   420
         Width           =   1815
         _Version        =   65543
         _ExtentX        =   3201
         _ExtentY        =   450
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
         SpinButton      =   0
      End
      Begin MSDBCtls.DBCombo dbcUserCity 
         Bindings        =   "frmSystemProfile.frx":2779
         DataField       =   "UserCity"
         DataSource      =   "dtcPreference"
         Height          =   315
         Left            =   -73560
         TabIndex        =   21
         Top             =   1440
         Width           =   1815
         _ExtentX        =   3201
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "CityName"
         BoundColumn     =   "Code"
         Text            =   "dbcUserCity"
      End
      Begin MSDBCtls.DBCombo dbcOwnerCity 
         Bindings        =   "frmSystemProfile.frx":2792
         DataField       =   "OwnerCity"
         DataSource      =   "dtcPreference"
         Height          =   315
         Left            =   -73560
         TabIndex        =   35
         Top             =   1440
         Width           =   1815
         _ExtentX        =   3201
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "CityName"
         BoundColumn     =   "Code"
         Text            =   "dbcOwnerCity"
      End
      Begin VB.Label Label18 
         Caption         =   "Country"
         Height          =   255
         Left            =   -74880
         TabIndex        =   77
         Top             =   2160
         Width           =   615
      End
      Begin VB.Label Label28 
         Caption         =   "Current Month"
         Height          =   255
         Left            =   2760
         TabIndex        =   51
         Top             =   720
         Width           =   1095
      End
      Begin VB.Label Label27 
         Caption         =   "Fiscal Period"
         Height          =   255
         Left            =   2760
         TabIndex        =   50
         Top             =   420
         Width           =   1095
      End
      Begin VB.Label Label26 
         Caption         =   "GST Value"
         Height          =   255
         Left            =   120
         TabIndex        =   49
         Top             =   1920
         Width           =   855
      End
      Begin VB.Label Label25 
         Caption         =   "GST Number"
         Height          =   255
         Left            =   120
         TabIndex        =   48
         Top             =   1620
         Width           =   975
      End
      Begin VB.Label Label24 
         Caption         =   "PST Value"
         Height          =   255
         Left            =   120
         TabIndex        =   47
         Top             =   1320
         Width           =   975
      End
      Begin VB.Label Label23 
         Caption         =   "PST Number"
         Height          =   255
         Left            =   120
         TabIndex        =   46
         Top             =   1020
         Width           =   975
      End
      Begin VB.Label Label22 
         Caption         =   "Country Code"
         Height          =   255
         Left            =   120
         TabIndex        =   40
         Top             =   720
         Width           =   975
      End
      Begin VB.Label Label21 
         Caption         =   "Branch Number"
         Height          =   255
         Left            =   120
         TabIndex        =   37
         Top             =   420
         Width           =   1215
      End
      Begin VB.Label Label20 
         Caption         =   "Contact Person"
         Height          =   255
         Left            =   -70080
         TabIndex        =   34
         Top             =   360
         Width           =   1215
      End
      Begin VB.Label Label17 
         Caption         =   "Postal Code"
         Height          =   255
         Left            =   -74880
         TabIndex        =   32
         Top             =   2460
         Width           =   855
      End
      Begin VB.Label Label16 
         Caption         =   "Province"
         Height          =   255
         Left            =   -74880
         TabIndex        =   30
         Top             =   1800
         Width           =   975
      End
      Begin VB.Label Label15 
         Caption         =   "City"
         Height          =   255
         Left            =   -74880
         TabIndex        =   20
         Top             =   1440
         Width           =   1095
      End
      Begin VB.Label Label14 
         Caption         =   "Address"
         Height          =   255
         Left            =   -74880
         TabIndex        =   18
         Top             =   720
         Width           =   1095
      End
      Begin VB.Label Label13 
         Caption         =   "Contact Person"
         Height          =   255
         Left            =   -70080
         TabIndex        =   16
         Top             =   360
         Width           =   1215
      End
      Begin VB.Label Label12 
         Caption         =   "Company Name"
         Height          =   255
         Left            =   -74880
         TabIndex        =   15
         Top             =   360
         Width           =   1215
      End
      Begin VB.Label Label10 
         Caption         =   "Country"
         Height          =   255
         Left            =   -74880
         TabIndex        =   14
         Top             =   2160
         Width           =   735
      End
      Begin VB.Label Label9 
         Caption         =   "Postal Code"
         Height          =   255
         Left            =   -74880
         TabIndex        =   13
         Top             =   2460
         Width           =   975
      End
      Begin VB.Label Label8 
         Caption         =   "Province"
         Height          =   255
         Left            =   -74880
         TabIndex        =   12
         Top             =   1800
         Width           =   1215
      End
      Begin VB.Label Label7 
         Caption         =   "City"
         Height          =   255
         Left            =   -74880
         TabIndex        =   11
         Top             =   1440
         Width           =   1095
      End
      Begin VB.Label Label6 
         Caption         =   "Address"
         Height          =   255
         Left            =   -74880
         TabIndex        =   10
         Top             =   720
         Width           =   1215
      End
      Begin VB.Label Label5 
         Caption         =   "Company Name"
         Height          =   255
         Left            =   -74880
         TabIndex        =   9
         Top             =   360
         Width           =   1215
      End
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   375
      Left            =   6840
      TabIndex        =   71
      Top             =   540
      Width           =   975
      _ExtentX        =   1720
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
   Begin Threed.SSCommand SSCommand1 
      Height          =   375
      Left            =   6840
      TabIndex        =   70
      Top             =   120
      Width           =   975
      _ExtentX        =   1720
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
      Caption         =   "Save"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin VB.Label Label4 
      Caption         =   "Product Description"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   1200
      Width           =   1575
   End
   Begin VB.Label Label3 
      Caption         =   "Platform"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   840
      Width           =   1215
   End
   Begin VB.Label Label2 
      Caption         =   "Number of User"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   480
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Serial Number"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1095
   End
End
Attribute VB_Name = "frmSystemProfile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub dbcOwnerCity_Click(intArea As Integer)

    Dim strTarget As String
    
    If intArea = dbcAreaList Then
        ' Sync dtcOwnerCity
        strTarget = "Code = " & dbcOwnerCity.BoundText
        dtcOwnerCity.Recordset.FindFirst strTarget
        If Not dtcOwnerCity.Recordset.NoMatch Then
            dtcOwnerCity.UpdateControls
            ' Fill Preference fields: Owner Province and Country
            If Not (dtcPreference.Recordset.EditMode = dbEditAdd) Then dtcPreference.Recordset.Edit
            dtcPreference.Recordset!OwnerProvince = dtcOwnerCity.Recordset!ProvinceCode
            dtcPreference.Recordset!OwnerCountry = dtcOwnerCity.Recordset!CountryCode
        End If
    End If

End Sub

Private Sub dbcUserCity_Click(intArea As Integer)

    Dim strTarget As String
    
    If intArea = dbcAreaList Then
        ' Sync dtcUserCity
        strTarget = "Code = " & dbcUserCity.BoundText
        dtcUserCity.Recordset.FindFirst strTarget
        If Not dtcUserCity.Recordset.NoMatch Then
            dtcOwnerCity.UpdateControls
            ' Fill Preference fields: User Province and Country
            If Not (dtcPreference.Recordset.EditMode = dbEditAdd) Then dtcPreference.Recordset.Edit
            dtcPreference.Recordset!UserProvince = dtcUserCity.Recordset!ProvinceCode
            dtcPreference.Recordset!UserCountry = dtcUserCity.Recordset!CountryCode
        End If
    End If

End Sub


Private Sub dtcPreference_Reposition()

    If IsTableEmpty(dtcPreference.Recordset) Then Exit Sub       ' Terminate if empty table
    
    Dim strTarget As String
    
    ' Synconize the related tables
    If Not (dtcPreference.Recordset.EOF Or dtcPreference.Recordset.BOF) Then
        ' Sync dtcUserCity
        If dtcPreference.Recordset!UserCity <> "" Then
            strTarget = "Code = " & dtcPreference.Recordset!UserCity
            dtcUserCity.Recordset.FindFirst strTarget
            If Not dtcUserCity.Recordset.NoMatch Then _
                dtcUserCity.UpdateControls
        End If
        ' Sync dtcOwnerCity
        If dtcPreference.Recordset!OwnerCity <> "" Then
            strTarget = "Code = " & dtcPreference.Recordset!OwnerCity
            dtcOwnerCity.Recordset.FindFirst strTarget
            If Not dtcOwnerCity.Recordset.NoMatch Then _
                dtcOwnerCity.UpdateControls
        End If
    End If

End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)

End Sub


Private Sub Form_Unload(Cancel As Integer)
    dtcPreference.Refresh
    dtcPrefTxNumber.Refresh
End Sub


Private Sub MaskEdBox1_GotFocus()
    
End Sub

Private Sub MaskEdBox1_ValidationError(InvalidText As String, StartPosition As Integer)

End Sub

Private Sub mskGSTValue_GotFocus()
    Call AutoSelect(mskGSTValue)
End Sub

Private Sub mskOwnerFax_GotFocus()
    Call AutoSelect(mskOwnerFax)
End Sub

Private Sub mskOwnerPhone_GotFocus()
    Call AutoSelect(mskOwnerPhone)
End Sub

Private Sub mskOwnerPostalCode_GotFocus()
    Call AutoSelect(mskOwnerPostalCode)
End Sub

Private Sub mskPSTValue_GotFocus()
    Call AutoSelect(mskPSTValue)
End Sub

Private Sub mskUserFax_GotFocus()
    Call AutoSelect(mskUserFax)
End Sub

Private Sub mskUserPhone_GotFocus()
    Call AutoSelect(mskUserPhone)
End Sub

Private Sub mskUserPostalCode_GotFocus()
    Call AutoSelect(mskUserPostalCode)
End Sub

Private Sub SSCommand1_Click()
    dtcPreference.UpdateRecord
    dtcPrefTxNumber.UpdateRecord
End Sub


Private Sub SSCommand2_Click()
    dtcPreference.Refresh
    dtcPrefTxNumber.Refresh
End Sub


Private Sub Text19_Change()

End Sub


Private Sub txtBranchNumber_GotFocus()
    Call AutoSelect(txtBranchNumber)
End Sub


Private Sub txtCountryCode_GotFocus()
    Call AutoSelect(txtCountryCode)
End Sub


Private Sub txtGSTNumber_GotFocus()
    Call AutoSelect(txtGSTNumber)
End Sub


Private Sub txtNextControlNumber_GotFocus()
    Call AutoSelect(txtNextControlNumber)
End Sub


Private Sub txtNextInvoiceNumber_GotFocus()
    Call AutoSelect(txtNextInvoiceNumber)
End Sub


Private Sub txtNextOrderNumber_GotFocus()
    Call AutoSelect(txtNextOrderNumber)
End Sub


Private Sub txtNextSKUNumber_GotFocus()
    Call AutoSelect(txtNextSKUNumber)
End Sub


Private Sub txtPSTNumber_GotFocus()
    Call AutoSelect(txtPSTNumber)
End Sub



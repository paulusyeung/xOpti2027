VERSION 4.00
Begin VB.Form frmPreference 
   Caption         =   "Preference"
   ClientHeight    =   5775
   ClientLeft      =   2745
   ClientTop       =   1935
   ClientWidth     =   7935
   Height          =   6180
   Left            =   2685
   LinkTopic       =   "Form1"
   ScaleHeight     =   5775
   ScaleWidth      =   7935
   Top             =   1590
   Width           =   8055
   Begin VB.Data dtcProvince 
      Caption         =   "Province"
      Connect         =   "Access"
      DatabaseName    =   "SynergyV.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   240
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Province"
      Top             =   2280
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.Data dtcCity 
      Caption         =   "City"
      Connect         =   "Access"
      DatabaseName    =   "SynergyV.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   240
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "City"
      Top             =   1920
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.Data dtcPreference 
      Caption         =   "Preference"
      Connect         =   "Access"
      DatabaseName    =   "SynergyV.mdb"
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
      Text            =   "frmPreference.frx":0000
      Top             =   1200
      Width           =   4095
   End
   Begin SSDesignerWidgetsTabs.SSIndexTab SSIndexTab1 
      Height          =   2895
      Left            =   120
      TabIndex        =   8
      Top             =   2760
      Width           =   7695
      _Version        =   131077
      _ExtentX        =   13573
      _ExtentY        =   5106
      _StockProps     =   9
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
      Tabs(0).Pages(0).CtlEnabled=   -1  'True
      Tabs(0).Pages(0).Ctl(0)=   "Label12"
      Tabs(0).Pages(0).Ctl(1)=   "Label14"
      Tabs(0).Pages(0).Ctl(2)=   "Label15"
      Tabs(0).Pages(0).Ctl(3)=   "DBCombo3"
      Tabs(0).Pages(0).Ctl(4)=   "Label16"
      Tabs(0).Pages(0).Ctl(5)=   "Label17"
      Tabs(0).Pages(0).Ctl(6)=   "Label20"
      Tabs(0).Pages(0).Ctl(7)=   "Label18"
      Tabs(0).Pages(0).Ctl(8)=   "MaskEdBox3"
      Tabs(0).Pages(0).Ctl(9)=   "SSFrame2"
      Tabs(0).Pages(0).Ctl(10)=   "Text12"
      Tabs(0).Pages(0).Ctl(11)=   "Text13"
      Tabs(0).Pages(0).Ctl(12)=   "Text18"
      Tabs(0).Pages(0).Ctl(13)=   "Text7"
      Tabs(0).Pages(0).Ctl(14)=   "Text14"
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
      Tabs(1).Pages(0).CtlCount=   16
      Tabs(1).Pages(0).CtlEnabled=   0   'False
      Tabs(1).Pages(0).Ctl(0)=   "Label5"
      Tabs(1).Pages(0).Ctl(1)=   "Label6"
      Tabs(1).Pages(0).Ctl(2)=   "Label7"
      Tabs(1).Pages(0).Ctl(3)=   "Label8"
      Tabs(1).Pages(0).Ctl(4)=   "Label9"
      Tabs(1).Pages(0).Ctl(5)=   "Label10"
      Tabs(1).Pages(0).Ctl(6)=   "Label11"
      Tabs(1).Pages(0).Ctl(7)=   "DBCombo1"
      Tabs(1).Pages(0).Ctl(8)=   "DBCombo2"
      Tabs(1).Pages(0).Ctl(9)=   "Label13"
      Tabs(1).Pages(0).Ctl(10)=   "Text5"
      Tabs(1).Pages(0).Ctl(11)=   "Text6"
      Tabs(1).Pages(0).Ctl(12)=   "Text8"
      Tabs(1).Pages(0).Ctl(13)=   "Text9"
      Tabs(1).Pages(0).Ctl(14)=   "Text10"
      Tabs(1).Pages(0).Ctl(15)=   "Text11"
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
      Tabs(2).Pages(0).CtlEnabled=   0   'False
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
      Begin VB.TextBox Text14 
         BackColor       =   &H00C0C0C0&
         Height          =   285
         Left            =   1440
         Locked          =   -1  'True
         TabIndex        =   70
         TabStop         =   0   'False
         Text            =   "Text14"
         Top             =   2160
         Width           =   1815
      End
      Begin VB.TextBox Text7 
         BackColor       =   &H00C0C0C0&
         Height          =   285
         Left            =   1440
         Locked          =   -1  'True
         TabIndex        =   68
         TabStop         =   0   'False
         Text            =   "Text7"
         Top             =   1800
         Width           =   1815
      End
      Begin VB.Data dtcPrefTxNumber 
         Caption         =   "PrefTxNumber"
         Connect         =   "Access"
         DatabaseName    =   "SynergyV.mdb"
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
         Left            =   -73680
         MaxLength       =   10
         TabIndex        =   52
         Text            =   "Text23"
         Top             =   1620
         Width           =   1215
      End
      Begin VB.TextBox txtPSTNumber 
         DataField       =   "PSTNumber"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   -73680
         MaxLength       =   10
         TabIndex        =   50
         Text            =   "Text21"
         Top             =   1020
         Width           =   1215
      End
      Begin VB.TextBox txtCountryCode 
         DataField       =   "CountryCode"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   -73680
         MaxLength       =   2
         TabIndex        =   49
         Text            =   "Text20"
         Top             =   720
         Width           =   735
      End
      Begin VB.TextBox txtBranchNumber 
         DataField       =   "BranchNumber"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   -73680
         MaxLength       =   4
         TabIndex        =   48
         Text            =   "Text19"
         Top             =   420
         Width           =   735
      End
      Begin VB.TextBox Text18 
         DataField       =   "UserContactPerson"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   4920
         MaxLength       =   30
         TabIndex        =   34
         Text            =   "Text18"
         Top             =   600
         Width           =   2655
      End
      Begin VB.TextBox Text13 
         DataField       =   "UserAddress"
         DataSource      =   "dtcPreference"
         Height          =   675
         Left            =   1440
         MaxLength       =   128
         MultiLine       =   -1  'True
         TabIndex        =   28
         Text            =   "frmPreference.frx":0006
         Top             =   720
         Width           =   3135
      End
      Begin VB.TextBox Text12 
         DataField       =   "UserName"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   1440
         MaxLength       =   40
         TabIndex        =   26
         Text            =   "Text12"
         Top             =   360
         Width           =   3135
      End
      Begin VB.TextBox Text11 
         DataField       =   "OwnerContactPerson"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   -73560
         MaxLength       =   30
         TabIndex        =   25
         Text            =   "Text11"
         Top             =   2520
         Width           =   4215
      End
      Begin VB.TextBox Text10 
         DataField       =   "OwnerFax"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   -71160
         MaxLength       =   15
         TabIndex        =   22
         Text            =   "Text10"
         Top             =   2160
         Width           =   1815
      End
      Begin VB.TextBox Text9 
         DataField       =   "OwnerPhone"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   -73560
         MaxLength       =   15
         TabIndex        =   21
         Text            =   "Text9"
         Top             =   2160
         Width           =   1815
      End
      Begin VB.TextBox Text8 
         DataField       =   "OwnerPostalCode"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   -70440
         MaxLength       =   7
         TabIndex        =   20
         Text            =   "Text8"
         Top             =   1800
         Width           =   1095
      End
      Begin VB.TextBox Text6 
         DataField       =   "OwnerAddress"
         DataSource      =   "dtcPreference"
         Height          =   675
         Left            =   -73560
         MaxLength       =   128
         MultiLine       =   -1  'True
         TabIndex        =   17
         Text            =   "frmPreference.frx":000D
         Top             =   720
         Width           =   4215
      End
      Begin VB.TextBox Text5 
         DataField       =   "OwnerName"
         DataSource      =   "dtcPreference"
         Height          =   285
         Left            =   -73560
         MaxLength       =   40
         TabIndex        =   16
         Text            =   "Text5"
         Top             =   360
         Width           =   4215
      End
      Begin Threed.SSFrame SSFrame1 
         Height          =   1455
         Left            =   -72240
         TabIndex        =   43
         Top             =   1320
         Width           =   2895
         _Version        =   65536
         _ExtentX        =   5106
         _ExtentY        =   2566
         _StockProps     =   14
         Caption         =   "Next"
         Begin VB.TextBox txtNextControlNumber 
            Alignment       =   1  'Right Justify
            DataField       =   "NextInvtControlNumber"
            DataSource      =   "dtcPreference"
            Height          =   285
            Left            =   1560
            MaxLength       =   8
            MultiLine       =   -1  'True
            TabIndex        =   56
            Text            =   "frmPreference.frx":0013
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
            TabIndex        =   59
            Text            =   "frmPreference.frx":0019
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
            TabIndex        =   58
            Text            =   "frmPreference.frx":0020
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
            TabIndex        =   57
            Text            =   "frmPreference.frx":0027
            Top             =   540
            Width           =   1215
         End
         Begin VB.Label Label32 
            Caption         =   "Order Number"
            Height          =   255
            Left            =   120
            TabIndex        =   47
            Top             =   1140
            Width           =   1095
         End
         Begin VB.Label Label31 
            Caption         =   "Invoice Number"
            Height          =   255
            Left            =   120
            TabIndex        =   46
            Top             =   840
            Width           =   1215
         End
         Begin VB.Label Label30 
            Caption         =   "SKU Number"
            Height          =   255
            Left            =   120
            TabIndex        =   45
            Top             =   540
            Width           =   1095
         End
         Begin VB.Label Label29 
            Caption         =   "Control Number"
            Height          =   255
            Left            =   120
            TabIndex        =   44
            Top             =   240
            Width           =   1215
         End
      End
      Begin Threed.SSFrame SSFrame2 
         Height          =   1875
         Left            =   4920
         TabIndex        =   63
         Top             =   900
         Width           =   2655
         _Version        =   65536
         _ExtentX        =   4683
         _ExtentY        =   3307
         _StockProps     =   14
         Caption         =   "Phone"
         Begin VB.TextBox Text17 
            BackColor       =   &H00C0C0C0&
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   72
            TabStop         =   0   'False
            Text            =   "Text17"
            Top             =   540
            Width           =   495
         End
         Begin VB.TextBox Text16 
            BackColor       =   &H00C0C0C0&
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   71
            TabStop         =   0   'False
            Text            =   "Text16"
            Top             =   240
            Width           =   495
         End
         Begin MSMask.MaskEdBox MaskEdBox2 
            Height          =   255
            Left            =   1200
            TabIndex        =   74
            Top             =   1140
            Width           =   1335
            _Version        =   65536
            _ExtentX        =   2355
            _ExtentY        =   450
            _StockProps     =   109
            ForeColor       =   -2147483640
            BackColor       =   -2147483643
            BorderStyle     =   1
            PromptInclude   =   0   'False
            MaxLength       =   9
            Mask            =   "### #####"
         End
         Begin MSMask.MaskEdBox MaskEdBox1 
            Height          =   255
            Left            =   1200
            TabIndex        =   73
            Top             =   840
            Width           =   1335
            _Version        =   65536
            _ExtentX        =   2355
            _ExtentY        =   450
            _StockProps     =   109
            ForeColor       =   -2147483640
            BackColor       =   -2147483643
            BorderStyle     =   1
            PromptInclude   =   0   'False
            MaxLength       =   9
            Mask            =   "### #####"
         End
         Begin VB.Label Label36 
            Caption         =   "Fax"
            Height          =   195
            Left            =   120
            TabIndex        =   67
            Top             =   1140
            Width           =   375
         End
         Begin VB.Label Label35 
            Caption         =   "Phone"
            Height          =   255
            Left            =   120
            TabIndex        =   66
            Top             =   840
            Width           =   615
         End
         Begin VB.Label Label34 
            Caption         =   "City Code"
            Height          =   195
            Left            =   120
            TabIndex        =   65
            Top             =   540
            Width           =   735
         End
         Begin VB.Label Label33 
            Caption         =   "Country Code"
            Height          =   195
            Left            =   120
            TabIndex        =   64
            Top             =   240
            Width           =   975
         End
      End
      Begin MSMask.MaskEdBox MaskEdBox3 
         Height          =   255
         Left            =   1440
         TabIndex        =   75
         Top             =   2460
         Width           =   975
         _Version        =   65536
         _ExtentX        =   1720
         _ExtentY        =   450
         _StockProps     =   109
         ForeColor       =   -2147483640
         BackColor       =   -2147483643
         BorderStyle     =   1
         PromptInclude   =   0   'False
         MaxLength       =   7
         Mask            =   ">a#a#a##"
      End
      Begin VB.Label Label18 
         Caption         =   "Country"
         Height          =   255
         Left            =   120
         TabIndex        =   69
         Top             =   2160
         Width           =   615
      End
      Begin MSMask.MaskEdBox mskGSTValue 
         DataField       =   "TaxBRate"
         DataSource      =   "dtcPreference"
         Height          =   255
         Left            =   -73680
         TabIndex        =   53
         Top             =   1920
         Width           =   495
         _Version        =   65536
         _ExtentX        =   873
         _ExtentY        =   450
         _StockProps     =   109
         ForeColor       =   -2147483640
         BackColor       =   -2147483643
         BorderStyle     =   1
         MaxLength       =   5
         Format          =   "##0.00"
      End
      Begin MSMask.MaskEdBox mskPSTValue 
         DataField       =   "TaxARate"
         DataSource      =   "dtcPreference"
         Height          =   255
         Left            =   -73680
         TabIndex        =   51
         Top             =   1320
         Width           =   495
         _Version        =   65536
         _ExtentX        =   873
         _ExtentY        =   450
         _StockProps     =   109
         ForeColor       =   -2147483640
         BackColor       =   -2147483643
         BorderStyle     =   1
         MaxLength       =   5
         Format          =   "##0.00"
      End
      Begin TrueDBGrid.TDBGrid TDBGrid1 
         Bindings        =   "frmPreference.frx":002E
         Height          =   2355
         Left            =   -74880
         OleObjectBlob   =   "frmPreference.frx":0046
         TabIndex        =   60
         Top             =   420
         Width           =   5535
      End
      Begin SSCalendarWidgets_A.SSDateCombo SSDateCombo2 
         DataField       =   "CurrentMonth"
         DataSource      =   "dtcPreference"
         Height          =   255
         Left            =   -71160
         TabIndex        =   55
         Top             =   720
         Width           =   1815
         _Version        =   65536
         _ExtentX        =   3201
         _ExtentY        =   450
         _StockProps     =   77
         Format          =   "MMMM DD, YYYY"
         SpinButton      =   0
      End
      Begin SSCalendarWidgets_A.SSDateCombo SSDateCombo1 
         DataField       =   "FiscalPeriod"
         DataSource      =   "dtcPreference"
         Height          =   255
         Left            =   -71160
         TabIndex        =   54
         Top             =   420
         Width           =   1815
         _Version        =   65536
         _ExtentX        =   3201
         _ExtentY        =   450
         _StockProps     =   77
         Format          =   "MMMM DD, YYYY"
         SpinButton      =   0
      End
      Begin VB.Label Label28 
         Caption         =   "Current Month"
         Height          =   255
         Left            =   -72240
         TabIndex        =   42
         Top             =   720
         Width           =   1095
      End
      Begin VB.Label Label27 
         Caption         =   "Fiscal Period"
         Height          =   255
         Left            =   -72240
         TabIndex        =   41
         Top             =   420
         Width           =   1095
      End
      Begin VB.Label Label26 
         Caption         =   "GST Value"
         Height          =   255
         Left            =   -74880
         TabIndex        =   40
         Top             =   1920
         Width           =   855
      End
      Begin VB.Label Label25 
         Caption         =   "GST Number"
         Height          =   255
         Left            =   -74880
         TabIndex        =   39
         Top             =   1620
         Width           =   975
      End
      Begin VB.Label Label24 
         Caption         =   "PST Value"
         Height          =   255
         Left            =   -74880
         TabIndex        =   38
         Top             =   1320
         Width           =   975
      End
      Begin VB.Label Label23 
         Caption         =   "PST Number"
         Height          =   255
         Left            =   -74880
         TabIndex        =   37
         Top             =   1020
         Width           =   975
      End
      Begin VB.Label Label22 
         Caption         =   "Country Code"
         Height          =   255
         Left            =   -74880
         TabIndex        =   36
         Top             =   720
         Width           =   975
      End
      Begin VB.Label Label21 
         Caption         =   "Branch Number"
         Height          =   255
         Left            =   -74880
         TabIndex        =   35
         Top             =   420
         Width           =   1215
      End
      Begin VB.Label Label20 
         Caption         =   "Contact Person"
         Height          =   255
         Left            =   4920
         TabIndex        =   33
         Top             =   360
         Width           =   1215
      End
      Begin VB.Label Label17 
         Caption         =   "Postal Code"
         Height          =   255
         Left            =   120
         TabIndex        =   32
         Top             =   2460
         Width           =   855
      End
      Begin VB.Label Label16 
         Caption         =   "Province"
         Height          =   255
         Left            =   120
         TabIndex        =   31
         Top             =   1800
         Width           =   975
      End
      Begin MSDBCtls.DBCombo DBCombo3 
         Bindings        =   "frmPreference.frx":1DAC
         DataField       =   "UserCity"
         DataSource      =   "dtcPreference"
         Height          =   315
         Left            =   1440
         TabIndex        =   30
         Top             =   1440
         Width           =   1815
         _Version        =   65536
         _ExtentX        =   3201
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
         ListField       =   "CityName"
         BoundColumn     =   "Code"
      End
      Begin VB.Label Label15 
         Caption         =   "City"
         Height          =   255
         Left            =   120
         TabIndex        =   29
         Top             =   1440
         Width           =   1095
      End
      Begin VB.Label Label14 
         Caption         =   "Address"
         Height          =   255
         Left            =   120
         TabIndex        =   27
         Top             =   720
         Width           =   1095
      End
      Begin VB.Label Label13 
         Caption         =   "Contact Person"
         Height          =   255
         Left            =   -74880
         TabIndex        =   24
         Top             =   2520
         Width           =   1215
      End
      Begin VB.Label Label12 
         Caption         =   "Company Name"
         Height          =   255
         Left            =   120
         TabIndex        =   23
         Top             =   360
         Width           =   1215
      End
      Begin MSDBCtls.DBCombo DBCombo2 
         Bindings        =   "frmPreference.frx":1DBC
         DataField       =   "UserProvince"
         DataSource      =   "dtcPreference"
         Height          =   315
         Left            =   -73560
         TabIndex        =   19
         Top             =   1800
         Width           =   1815
         _Version        =   65536
         _ExtentX        =   3201
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
         ListField       =   "ProvinceName"
         BoundColumn     =   "ProvinceCode"
      End
      Begin MSDBCtls.DBCombo DBCombo1 
         Bindings        =   "frmPreference.frx":1DD0
         DataField       =   "OwnerCity"
         DataSource      =   "dtcPreference"
         Height          =   315
         Left            =   -73560
         TabIndex        =   18
         Top             =   1440
         Width           =   1815
         _Version        =   65536
         _ExtentX        =   3201
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
         ListField       =   "CityName"
         BoundColumn     =   "Code"
      End
      Begin VB.Label Label11 
         Caption         =   "Fax"
         Height          =   255
         Left            =   -71520
         TabIndex        =   15
         Top             =   2160
         Width           =   375
      End
      Begin VB.Label Label10 
         Caption         =   "Phone"
         Height          =   255
         Left            =   -74880
         TabIndex        =   14
         Top             =   2160
         Width           =   735
      End
      Begin VB.Label Label9 
         Caption         =   "Postal Code"
         Height          =   255
         Left            =   -71520
         TabIndex        =   13
         Top             =   1800
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
      Left            =   4920
      TabIndex        =   62
      Top             =   540
      Width           =   975
      _Version        =   65536
      _ExtentX        =   1720
      _ExtentY        =   661
      _StockProps     =   78
      Caption         =   "Refresh"
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   375
      Left            =   4920
      TabIndex        =   61
      Top             =   120
      Width           =   975
      _Version        =   65536
      _ExtentX        =   1720
      _ExtentY        =   661
      _StockProps     =   78
      Caption         =   "Save"
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
Attribute VB_Name = "frmPreference"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
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


Private Sub mskGSTValue_GotFocus()
    Call AutoSelect(mskGSTValue)
End Sub

Private Sub mskGSTValue_ValidationError(InvalidText As String, StartPosition As Integer)

End Sub

Private Sub mskPSTValue_GotFocus()
    Call AutoSelect(mskPSTValue)
End Sub

Private Sub mskPSTValue_ValidationError(InvalidText As String, StartPosition As Integer)

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


Private Sub txtBranchNumber_Change()

End Sub


Private Sub txtBranchNumber_GotFocus()
    Call AutoSelect(txtBranchNumber)
End Sub


Private Sub txtCountryCode_Change()

End Sub


Private Sub txtCountryCode_GotFocus()
    Call AutoSelect(txtCountryCode)
End Sub


Private Sub txtGSTNumber_Change()

End Sub

Private Sub txtGSTNumber_GotFocus()
    Call AutoSelect(txtGSTNumber)
End Sub


Private Sub txtNextControlNumber_Change()

End Sub

Private Sub txtNextControlNumber_GotFocus()
    Call AutoSelect(txtNextControlNumber)
End Sub


Private Sub txtNextInvoiceNumber_Change()

End Sub

Private Sub txtNextInvoiceNumber_GotFocus()
    Call AutoSelect(txtNextInvoiceNumber)
End Sub


Private Sub txtNextOrderNumber_Change()

End Sub

Private Sub txtNextOrderNumber_GotFocus()
    Call AutoSelect(txtNextOrderNumber)
End Sub


Private Sub txtNextSKUNumber_Change()

End Sub

Private Sub txtNextSKUNumber_GotFocus()
    Call AutoSelect(txtNextSKUNumber)
End Sub


Private Sub txtPSTNumber_Change()

End Sub


Private Sub txtPSTNumber_GotFocus()
    Call AutoSelect(txtPSTNumber)
End Sub



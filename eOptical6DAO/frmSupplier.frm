VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{B074BC93-5A5B-11CE-98BD-0000C0E6B88E}#2.0#0"; "sstabs32.ocx"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmSupplier 
   Caption         =   "Supplier"
   ClientHeight    =   6300
   ClientLeft      =   2550
   ClientTop       =   2205
   ClientWidth     =   9120
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6300
   ScaleWidth      =   9120
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Bindings        =   "frmSupplier.frx":0000
      Height          =   1695
      Left            =   3720
      OleObjectBlob   =   "frmSupplier.frx":001A
      TabIndex        =   41
      TabStop         =   0   'False
      Top             =   1200
      Width           =   5295
   End
   Begin VB.Timer tmrClearDBComboHiLite 
      Interval        =   100
      Left            =   600
      Top             =   2460
   End
   Begin VB.Data dtcSelCity 
      Caption         =   "SelCity"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   1920
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "City"
      Top             =   2100
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcCountry 
      Caption         =   "Country"
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
      RecordSource    =   "Country"
      Top             =   2040
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcProvince 
      Caption         =   "Province"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   6000
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Province"
      Top             =   2040
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
      Left            =   4800
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "qryCityFullList"
      Top             =   2040
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data datSupplier 
      Caption         =   "Supplier"
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
      RecordSource    =   "Supplier"
      Top             =   2040
      Visible         =   0   'False
      Width           =   1140
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   975
      Left            =   120
      TabIndex        =   0
      Top             =   1080
      Width           =   3495
      _ExtentX        =   6165
      _ExtentY        =   1720
      _Version        =   131074
      ForeColor       =   0
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Supplier"
      Begin MSMask.MaskEdBox mskSupplierCode 
         DataField       =   "SupplierCode"
         DataSource      =   "datSupplier"
         Height          =   255
         Left            =   840
         TabIndex        =   1
         Top             =   240
         Width           =   855
         _ExtentX        =   1508
         _ExtentY        =   450
         _Version        =   393216
         PromptInclude   =   0   'False
         MaxLength       =   6
         Mask            =   ">aaaaaa"
         PromptChar      =   "_"
      End
      Begin MSDBCtls.DBCombo dbcSupplierName 
         Bindings        =   "frmSupplier.frx":1ABF
         DataField       =   "SupplierName"
         DataSource      =   "datSupplier"
         Height          =   315
         Left            =   840
         TabIndex        =   2
         Top             =   600
         Width           =   2535
         _ExtentX        =   4471
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "SupplierName"
         BoundColumn     =   "SupplierName"
         Text            =   "dbcSupplierName"
      End
      Begin VB.Label Label2 
         Caption         =   "Name"
         Height          =   255
         Left            =   120
         TabIndex        =   26
         Top             =   480
         Width           =   495
      End
      Begin VB.Label Label1 
         Caption         =   "Code"
         Height          =   255
         Left            =   120
         TabIndex        =   25
         Top             =   240
         Width           =   495
      End
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   27
      Top             =   0
      Width           =   9120
      _Version        =   131073
      _ExtentX        =   16087
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
      BevelInner      =   2
      BevelColorFace  =   16777215
      BackColorHelp   =   12648447
      ToolsetNumBtnStates=   3
      BtnGroupSpacing =   4
      BtnSpacing      =   0
      Btns            =   9
      ToolsetPicture  =   "frmSupplier.frx":1AD9
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
      MouseIcon       =   "frmSupplier.frx":F36B
   End
   Begin SSDesignerWidgetsTabs.SSIndexTab SSIndexTab1 
      Height          =   3255
      Left            =   120
      TabIndex        =   28
      Top             =   2940
      Width           =   8895
      _Version        =   131078
      _ExtentX        =   15690
      _ExtentY        =   5741
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
      Tabs(0).Pages(0).CtlCount=   14
      Tabs(0).Pages(0).CtlEnabled=   0   'False
      Tabs(0).Pages(0).Ctl(0)=   "Label3"
      Tabs(0).Pages(0).Ctl(1)=   "Label5"
      Tabs(0).Pages(0).Ctl(2)=   "Label4"
      Tabs(0).Pages(0).Ctl(3)=   "Label6"
      Tabs(0).Pages(0).Ctl(4)=   "Label7"
      Tabs(0).Pages(0).Ctl(5)=   "SSCommand1"
      Tabs(0).Pages(0).Ctl(6)=   "cboPriCity"
      Tabs(0).Pages(0).Ctl(7)=   "mskPostalCode"
      Tabs(0).Pages(0).Ctl(8)=   "SSFrame4"
      Tabs(0).Pages(0).Ctl(9)=   "Text1"
      Tabs(0).Pages(0).Ctl(10)=   "txtSyncProvince"
      Tabs(0).Pages(0).Ctl(11)=   "txtSyncCountry"
      Tabs(0).Pages(0).Ctl(12)=   "txtPriProvince"
      Tabs(0).Pages(0).Ctl(13)=   "txtPriCountry"
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
      Tabs(1).Pages(0).CtlCount=   12
      Tabs(1).Pages(0).CtlEnabled=   -1  'True
      Tabs(1).Pages(0).Ctl(0)=   "txtRemarks"
      Tabs(1).Pages(0).Ctl(1)=   "txtContactPerson"
      Tabs(1).Pages(0).Ctl(2)=   "txtPaymentTerms"
      Tabs(1).Pages(0).Ctl(3)=   "txtCreditLimit"
      Tabs(1).Pages(0).Ctl(4)=   "txtAccountNumber"
      Tabs(1).Pages(0).Ctl(5)=   "calDateStarted"
      Tabs(1).Pages(0).Ctl(6)=   "Label14"
      Tabs(1).Pages(0).Ctl(7)=   "Label12"
      Tabs(1).Pages(0).Ctl(8)=   "Label11"
      Tabs(1).Pages(0).Ctl(9)=   "Label10"
      Tabs(1).Pages(0).Ctl(10)=   "Label9"
      Tabs(1).Pages(0).Ctl(11)=   "Label8"
      Tabs(1).Tag     =   ""
      Tabs(1).Caption =   "Confidential"
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
      Begin VB.TextBox txtPriCountry 
         BackColor       =   &H00C0C0C0&
         DataField       =   "CountryName"
         DataSource      =   "dtcCity"
         Enabled         =   0   'False
         Height          =   315
         Left            =   -73920
         TabIndex        =   6
         Text            =   "Text2"
         Top             =   1800
         Width           =   1815
      End
      Begin VB.TextBox txtPriProvince 
         BackColor       =   &H00C0C0C0&
         DataField       =   "ProvinceName"
         DataSource      =   "dtcCity"
         Enabled         =   0   'False
         Height          =   285
         Left            =   -73920
         TabIndex        =   5
         Top             =   1440
         Width           =   1815
      End
      Begin VB.TextBox txtSyncCountry 
         BackColor       =   &H0000FFFF&
         DataField       =   "CountryName"
         DataSource      =   "dtcCountry"
         Height          =   285
         Left            =   -72120
         Locked          =   -1  'True
         TabIndex        =   55
         TabStop         =   0   'False
         Top             =   1380
         Visible         =   0   'False
         Width           =   1815
      End
      Begin VB.TextBox txtSyncProvince 
         BackColor       =   &H0000FFFF&
         DataField       =   "ProvinceName"
         DataSource      =   "dtcProvince"
         ForeColor       =   &H00000000&
         Height          =   285
         Left            =   -72120
         Locked          =   -1  'True
         TabIndex        =   54
         TabStop         =   0   'False
         Top             =   1080
         Visible         =   0   'False
         Width           =   1815
      End
      Begin VB.TextBox txtRemarks 
         DataField       =   "Remarks"
         DataSource      =   "datSupplier"
         Height          =   855
         Left            =   4680
         MultiLine       =   -1  'True
         TabIndex        =   49
         Top             =   840
         Width           =   2655
      End
      Begin VB.TextBox txtContactPerson 
         DataField       =   "ContactPerson"
         DataSource      =   "datSupplier"
         Height          =   285
         Left            =   4680
         TabIndex        =   24
         Top             =   480
         Width           =   2655
      End
      Begin VB.TextBox txtPaymentTerms 
         DataField       =   "PaymentTerms"
         DataSource      =   "datSupplier"
         Height          =   285
         Left            =   1440
         TabIndex        =   23
         Top             =   1560
         Width           =   1695
      End
      Begin VB.TextBox txtCreditLimit 
         DataField       =   "CreditLimit"
         DataSource      =   "datSupplier"
         Height          =   285
         Left            =   1440
         TabIndex        =   22
         Top             =   1200
         Width           =   975
      End
      Begin VB.TextBox txtAccountNumber 
         DataField       =   "AccountNo"
         DataSource      =   "datSupplier"
         Height          =   285
         Left            =   1440
         TabIndex        =   20
         Top             =   480
         Width           =   975
      End
      Begin VB.TextBox Text1 
         DataField       =   "Address"
         DataSource      =   "datSupplier"
         Height          =   675
         Left            =   -73920
         MultiLine       =   -1  'True
         TabIndex        =   3
         Top             =   360
         Width           =   2535
      End
      Begin Threed.SSFrame SSFrame4 
         Height          =   2715
         Left            =   -71280
         TabIndex        =   34
         Top             =   420
         Width           =   5055
         _ExtentX        =   8916
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
         Begin VB.TextBox Text7 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CityPhoneCode"
            DataSource      =   "dtcCity"
            Height          =   285
            Left            =   2880
            Locked          =   -1  'True
            TabIndex        =   53
            TabStop         =   0   'False
            Top             =   300
            Width           =   495
         End
         Begin VB.TextBox Text3 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CountryPhoneCode"
            DataSource      =   "dtcCountry"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   51
            TabStop         =   0   'False
            Top             =   300
            Width           =   495
         End
         Begin MSMask.MaskEdBox mskToll2Fax 
            DataField       =   "TollFreeFax2"
            DataSource      =   "datSupplier"
            Height          =   255
            Left            =   3480
            TabIndex        =   19
            Top             =   2340
            Width           =   1455
            _ExtentX        =   2566
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   14
            Mask            =   "# ### ### ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskToll2Phone 
            DataField       =   "TollFreePhone2"
            DataSource      =   "datSupplier"
            Height          =   255
            Left            =   1200
            TabIndex        =   18
            Top             =   2340
            Width           =   2175
            _ExtentX        =   3836
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   23
            Mask            =   "# ### ### #### etx ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskToll1Fax 
            DataField       =   "TollFreeFax1"
            DataSource      =   "datSupplier"
            Height          =   255
            Left            =   3480
            TabIndex        =   17
            Top             =   2040
            Width           =   1455
            _ExtentX        =   2566
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   14
            Mask            =   "# ### ### ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskToll1Phone 
            DataField       =   "TollFreePhone1"
            DataSource      =   "datSupplier"
            Height          =   255
            Left            =   1200
            TabIndex        =   16
            Top             =   2040
            Width           =   2175
            _ExtentX        =   3836
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   23
            Mask            =   "# ### ### #### etx ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskAccountFax 
            DataField       =   "PhoneServiceFax"
            DataSource      =   "datSupplier"
            Height          =   255
            Left            =   3480
            TabIndex        =   15
            Top             =   1740
            Width           =   1095
            _ExtentX        =   1931
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   9
            Mask            =   "### #####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskServiceFax 
            DataField       =   "PhoneACDeptFax"
            DataSource      =   "datSupplier"
            Height          =   255
            Left            =   3480
            TabIndex        =   13
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
         Begin MSMask.MaskEdBox mskSaleFax 
            DataField       =   "PhoneSaleFax"
            DataSource      =   "datSupplier"
            Height          =   255
            Left            =   3480
            TabIndex        =   11
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
         Begin MSMask.MaskEdBox mskGenVoice 
            DataField       =   "PhoneGenVoice"
            DataSource      =   "datSupplier"
            Height          =   255
            Left            =   1200
            TabIndex        =   8
            Top             =   840
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   9
            Mask            =   "### #####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskSalePhone 
            DataField       =   "PhoneSaleExt"
            DataSource      =   "datSupplier"
            Height          =   255
            Left            =   1200
            TabIndex        =   10
            Top             =   1140
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   17
            Mask            =   "### #### ext ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskAccountPhone 
            DataField       =   "PhoneServiceExt"
            DataSource      =   "datSupplier"
            Height          =   255
            Left            =   1200
            TabIndex        =   14
            Top             =   1740
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   17
            Mask            =   "### #### ext ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskGenFax 
            DataField       =   "PhoneGenFax"
            DataSource      =   "datSupplier"
            Height          =   255
            Left            =   3480
            TabIndex        =   9
            Top             =   840
            Width           =   1095
            _ExtentX        =   1931
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   9
            Mask            =   "### #####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskServicePhone 
            DataField       =   "PhoneACDeptExt"
            DataSource      =   "datSupplier"
            Height          =   255
            Left            =   1200
            TabIndex        =   12
            Top             =   1440
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   17
            Mask            =   "### #### ext ####"
            PromptChar      =   "_"
         End
         Begin VB.Label Label17 
            Caption         =   "Toll Free"
            Height          =   255
            Left            =   120
            TabIndex        =   56
            Top             =   2040
            Width           =   855
         End
         Begin VB.Label Label16 
            Caption         =   "City Code"
            Height          =   255
            Left            =   2040
            TabIndex        =   52
            Top             =   300
            Width           =   735
         End
         Begin VB.Label Label15 
            Caption         =   "Country Code"
            Height          =   255
            Left            =   120
            TabIndex        =   50
            Top             =   300
            Width           =   975
         End
         Begin VB.Label Label13 
            Caption         =   "Phone"
            Height          =   195
            Left            =   1800
            TabIndex        =   40
            Top             =   600
            Width           =   615
         End
         Begin VB.Label Label34 
            Caption         =   "Service Dept."
            Height          =   255
            Left            =   120
            TabIndex        =   39
            Top             =   1440
            Width           =   1095
         End
         Begin VB.Label Label33 
            Caption         =   "Fax"
            Height          =   195
            Left            =   3840
            TabIndex        =   38
            Top             =   600
            Width           =   375
         End
         Begin VB.Label Label32 
            Caption         =   "Account Dept."
            Height          =   255
            Left            =   120
            TabIndex        =   37
            Top             =   1740
            Width           =   1095
         End
         Begin VB.Label Label31 
            Caption         =   "Sales Dept."
            Height          =   255
            Left            =   120
            TabIndex        =   36
            Top             =   1140
            Width           =   1095
         End
         Begin VB.Label Label22 
            Caption         =   "Main"
            Height          =   255
            Left            =   120
            TabIndex        =   35
            Top             =   840
            Width           =   735
         End
      End
      Begin SSCalendarWidgets_A.SSDateCombo calDateStarted 
         DataField       =   "DateStarted"
         DataSource      =   "datSupplier"
         Height          =   255
         Left            =   1440
         TabIndex        =   21
         Top             =   840
         Width           =   1695
         _Version        =   65543
         _ExtentX        =   2990
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
         Format          =   "MM/DD/YYYY"
      End
      Begin MSMask.MaskEdBox mskPostalCode 
         DataField       =   "PostCode"
         DataSource      =   "datSupplier"
         Height          =   255
         Left            =   -73920
         TabIndex        =   7
         Top             =   2160
         Width           =   855
         _ExtentX        =   1508
         _ExtentY        =   450
         _Version        =   393216
         PromptInclude   =   0   'False
         MaxLength       =   6
         Mask            =   ">a#a#a#"
         PromptChar      =   "_"
      End
      Begin MSDBCtls.DBCombo cboPriCity 
         Bindings        =   "frmSupplier.frx":F387
         DataField       =   "City"
         DataSource      =   "datSupplier"
         Height          =   315
         Left            =   -73920
         TabIndex        =   4
         Top             =   1080
         Width           =   1815
         _ExtentX        =   3201
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "CityName"
         BoundColumn     =   "Code"
         Text            =   "cboPriCity"
      End
      Begin Threed.SSCommand SSCommand1 
         Height          =   315
         Left            =   -72120
         TabIndex        =   42
         TabStop         =   0   'False
         Top             =   1080
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
         Picture         =   "frmSupplier.frx":F3A0
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label14 
         Caption         =   "Remarks"
         Height          =   195
         Left            =   3480
         TabIndex        =   48
         Top             =   840
         Width           =   735
      End
      Begin VB.Label Label12 
         Caption         =   "Contact Person"
         Height          =   255
         Left            =   3480
         TabIndex        =   47
         Top             =   480
         Width           =   1095
      End
      Begin VB.Label Label11 
         Caption         =   "Payment Terms"
         Height          =   255
         Left            =   240
         TabIndex        =   46
         Top             =   1560
         Width           =   1095
      End
      Begin VB.Label Label10 
         Caption         =   "Credit Limit"
         Height          =   255
         Left            =   240
         TabIndex        =   45
         Top             =   1200
         Width           =   975
      End
      Begin VB.Label Label9 
         Caption         =   "Date Started"
         Height          =   255
         Left            =   240
         TabIndex        =   44
         Top             =   840
         Width           =   975
      End
      Begin VB.Label Label8 
         Caption         =   "Account No."
         Height          =   255
         Left            =   240
         TabIndex        =   43
         Top             =   480
         Width           =   975
      End
      Begin VB.Label Label7 
         Caption         =   "Postal Code"
         Height          =   255
         Left            =   -74880
         TabIndex        =   33
         Top             =   2160
         Width           =   855
      End
      Begin VB.Label Label6 
         Caption         =   "Country"
         Height          =   255
         Left            =   -74880
         TabIndex        =   32
         Top             =   1800
         Width           =   855
      End
      Begin VB.Label Label4 
         Caption         =   "Province"
         Height          =   255
         Left            =   -74880
         TabIndex        =   31
         Top             =   1440
         Width           =   855
      End
      Begin VB.Label Label5 
         Caption         =   "City"
         Height          =   255
         Left            =   -74880
         TabIndex        =   30
         Top             =   1080
         Width           =   735
      End
      Begin VB.Label Label3 
         Caption         =   "Address"
         Height          =   255
         Left            =   -74880
         TabIndex        =   29
         Top             =   360
         Width           =   735
      End
   End
   Begin Threed.SSRibbon cmdSortBySupplierCode 
      Height          =   330
      Left            =   5400
      TabIndex        =   58
      Top             =   1200
      Width           =   330
      _ExtentX        =   582
      _ExtentY        =   582
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmSupplier.frx":F96E
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmSupplier.frx":FF14
   End
   Begin Threed.SSRibbon cmdSortBySupplierName 
      Height          =   330
      Left            =   7320
      TabIndex        =   57
      Top             =   1200
      Width           =   330
      _ExtentX        =   582
      _ExtentY        =   582
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmSupplier.frx":104CE
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmSupplier.frx":10A74
   End
End
Attribute VB_Name = "frmSupplier"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim blnAddNew As Boolean

Private Sub cmdSortBySupplierCode_Click(Value As Integer)
    Dim strSQL As String
    If cmdSortBySupplierCode.Value Then
        strSQL = "SELECT * FROM Supplier ORDER BY SupplierCode ASC"
    Else
        strSQL = "SELECT * FROM Supplier ORDER BY SupplierCode DESC"
    End If
    datSupplier.RecordSource = strSQL
    datSupplier.Refresh
    datSupplier.UpdateControls
End Sub

Private Sub cmdSortBySupplierName_Click(Value As Integer)
    Dim strSQL As String
    If cmdSortBySupplierName.Value Then
        strSQL = "SELECT * FROM Supplier ORDER BY SupplierName ASC"
    Else
        strSQL = "SELECT * FROM Supplier ORDER BY SupplierName DESC"
    End If
    datSupplier.RecordSource = strSQL
    datSupplier.Refresh
    datSupplier.UpdateControls
End Sub

Private Sub cboPriCity_Click(intArea As Integer)

    Dim strTarget As String
    
    If intArea = dbcAreaList Then
        ' Sync dtcCity
        strTarget = "Code = " & cboPriCity.BoundText
        dtcCity.Recordset.FindFirst strTarget
        If Not dtcCity.Recordset.NoMatch Then
            dtcCity.UpdateControls
            ' Fill Supplier fields: Province and Country
            If Not blnAddNew Then datSupplier.Recordset.Edit
            datSupplier.Recordset.Fields("Province") = dtcCity.Recordset.Fields("ProvinceCode")
            datSupplier.Recordset.Fields("Country") = dtcCity.Recordset.Fields("CountryCode")
            ' Sync dtcProvince
            strTarget = "ProvinceCode = '" & dtcCity.Recordset.Fields("ProvinceCode") & "'"
            dtcProvince.Recordset.FindFirst strTarget
            If Not dtcProvince.Recordset.NoMatch Then
                dtcProvince.UpdateControls
                txtPriProvince.Text = dtcProvince.Recordset.Fields("ProvinceName")
            End If
            ' Sync dtcCountry
            strTarget = "CountryCode = '" & dtcCity.Recordset.Fields("CountryCode") & "'"
            dtcCountry.Recordset.FindFirst strTarget
            If Not dtcCountry.Recordset.NoMatch Then
                dtcCountry.UpdateControls
                txtPriCountry.Text = dtcCountry.Recordset.Fields("CountryName")
            End If
        End If
    End If
    
End Sub

Private Sub cboPriCity_GotFocus()
    ' Show Province and Country
    txtSyncProvince.Visible = True
    txtSyncCountry.Visible = True
    txtSyncProvince.ZOrder
    txtSyncCountry.ZOrder
End Sub


Private Sub cboPriCity_LostFocus()
    ' Hide Province and Country
    txtSyncProvince.Visible = False
    txtSyncCountry.Visible = False

End Sub


Private Sub datSupplier_Reposition()
            
    Dim strTarget As String
    If Not (datSupplier.Recordset.EOF Or datSupplier.Recordset.BOF) Then
        If datSupplier.Recordset!City <> "" Then
            ' Sync dtcCity
            strTarget = "Code = " & datSupplier.Recordset!City
            dtcCity.Recordset.FindFirst strTarget
            If Not dtcCity.Recordset.NoMatch Then _
            dtcCity.UpdateControls
            ' Sync dtcCountry
            strTarget = "CountryCode = '" & datSupplier.Recordset!Country & "'"
            dtcCountry.Recordset.FindFirst strTarget
            If Not dtcCountry.Recordset.NoMatch Then _
            dtcCountry.UpdateControls
        End If
        If Not IsNull(datSupplier.Recordset!DateStarted) Then _
            calDateStarted.Text = Format(datSupplier.Recordset!DateStarted, "MM/DD/YYYY")
    End If

End Sub

Private Sub datSupplier_Validate(intAction As Integer, intSave As Integer)
    ' Don't update the current record if it is a Find action
    If intAction = vbDataActionFind Then
        intSave = False
    End If
End Sub

Private Sub dbcSupplierName_Click(intArea As Integer)
    ' Display the content of the selected staff
    If intArea = dbcAreaList Then
        Dim MyCriteria As String
        MyCriteria = "SupplierName = '" & dbcSupplierName.Text & "'"  ' Set the criteria
        datSupplier.Recordset.FindFirst MyCriteria   ' Find first matching record.
        If Not datSupplier.Recordset.NoMatch Then    ' Check if record is found.
            datSupplier.UpdateControls
        End If
    End If
End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
    blnAddNew = False
    cmdSortBySupplierCode.ZOrder
    cmdSortBySupplierName.ZOrder
End Sub


Private Sub Form_Unload(Cancel As Integer)
    ' Avoid save on unload
    datSupplier.Refresh
    
    Call ofx_CloseForm(Me)
End Sub




Private Sub mskAccountFax_GotFocus()
    Call AutoSelect(mskAccountFax)
End Sub

Private Sub mskAccountPhone_GotFocus()
    Call AutoSelect(mskAccountPhone)
End Sub

Private Sub mskGenFax_GotFocus()
    Call AutoSelect(mskGenFax)

End Sub

Private Sub mskGenVoice_GotFocus()
    Call AutoSelect(mskGenVoice)
End Sub

Private Sub mskPostalCode_GotFocus()
    Call AutoSelect(mskPostalCode)
End Sub

Private Sub mskSaleFax_GotFocus()
    Call AutoSelect(mskSaleFax)
End Sub

Private Sub mskSalePhone_GotFocus()
    Call AutoSelect(mskSalePhone)
End Sub

Private Sub mskServiceFax_GotFocus()
    Call AutoSelect(mskServiceFax)
End Sub

Private Sub mskServicePhone_GotFocus()
    Call AutoSelect(mskServicePhone)
End Sub

Private Sub mskSupplierCode_GotFocus()
    Call AutoSelect(mskSupplierCode)
End Sub

Private Sub mskToll1Fax_GotFocus()
    Call AutoSelect(mskToll1Fax)
End Sub

Private Sub mskToll1Phone_GotFocus()
    Call AutoSelect(mskToll1Phone)
End Sub

Private Sub mskToll2Fax_GotFocus()
    Call AutoSelect(mskToll2Fax)
End Sub

Private Sub mskToll2Phone_GotFocus()
    Call AutoSelect(mskToll2Phone)
End Sub

Private Sub SSCommand1_Click()
    If ofx_IsFormLoaded(frmCity) Then _
        Unload frmCity
    Screen.MousePointer = vbHourglass
    frmCity.Show vbModal
    dtcCity.Refresh
    dtcCity.UpdateControls
    dtcSelCity.Refresh
    dtcSelCity.UpdateControls
End Sub



Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

    On Error GoTo SSToolbar1_Click_Err

    Select Case ToolID
    Case "ID_Add"
        Call DoAdd
    Case "ID_Delete"
        If blnAddNew Then
            datSupplier.Refresh
            Exit Sub
        End If
        'this may produce an error if you delete the last
        'record or the only record in the recordset
        datSupplier.Recordset.Delete
        datSupplier.Recordset.MoveNext
        blnAddNew = False
    Case "ID_Undo"
        'this is really only needed for multi user apps
        datSupplier.Refresh
        blnAddNew = False
    Case "ID_Save"
        If blnAddNew And calDateStarted = "" Then
            datSupplier.Recordset.Fields("DateStarted") = Date
        End If
        datSupplier.UpdateRecord
        datSupplier.Recordset.Bookmark = datSupplier.Recordset.LastModified
        blnAddNew = False
    Case "ID_Exit"
        Unload Me
    Case "ID_First"
        datSupplier.Recordset.MoveFirst
    Case "ID_Next"
        datSupplier.Recordset.MoveNext
        If datSupplier.Recordset.EOF Then
            Beep
            datSupplier.Recordset.MoveLast
        End If
    Case "ID_Previous"
        datSupplier.Recordset.MovePrevious
        If datSupplier.Recordset.BOF Then
            Beep
            datSupplier.Recordset.MoveFirst
        End If
    Case "ID_Last"
        datSupplier.Recordset.MoveLast
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

Private Sub txtAccountNumber_GotFocus()
    Call AutoSelect(txtAccountNumber)
End Sub


Private Sub txtContactPerson_GotFocus()
    Call AutoSelect(txtContactPerson)

End Sub


Private Sub txtCreditLimit_GotFocus()
    Call AutoSelect(txtCreditLimit)
End Sub


Private Sub txtPaymentTerms_GotFocus()
    Call AutoSelect(txtPaymentTerms)

End Sub

Private Sub DoAdd()
    With datSupplier.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    datSupplier.Recordset.AddNew
    blnAddNew = True
    mskSupplierCode.SetFocus
End Sub


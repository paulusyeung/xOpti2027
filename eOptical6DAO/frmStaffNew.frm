VERSION 4.00
Begin VB.Form frmStaffNew 
   Caption         =   "Staff"
   ClientHeight    =   6120
   ClientLeft      =   1575
   ClientTop       =   2160
   ClientWidth     =   8925
   Height          =   6525
   Left            =   1515
   LinkTopic       =   "Form1"
   ScaleHeight     =   6120
   ScaleWidth      =   8925
   Top             =   1815
   Width           =   9045
   Begin VB.Data dtcProvince 
      Caption         =   "Province"
      Connect         =   "Access"
      DatabaseName    =   "Synergyv.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   5280
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Province"
      Top             =   1800
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcCity 
      Caption         =   "City"
      Connect         =   "Access"
      DatabaseName    =   "Synergyv.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   5280
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "City"
      Top             =   1440
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Data dtcMaritalStatus 
      Caption         =   "MaritalStatus"
      Connect         =   "Access"
      DatabaseName    =   "Synergyv.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   5280
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
      Connect         =   "Access"
      DatabaseName    =   "Synergyv.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   7200
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "PayPeriod"
      Top             =   2520
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.Data dtcPayPer 
      Caption         =   "PayPer"
      Connect         =   "Access"
      DatabaseName    =   "Synergyv.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   7200
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "PayPer"
      Top             =   2160
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.Data dtcJobNature 
      Caption         =   "JobNature"
      Connect         =   "Access"
      DatabaseName    =   "Synergyv.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   7200
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "JobNature"
      Top             =   1800
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.Data dtcJobTitle 
      Caption         =   "JobTitle"
      Connect         =   "Access"
      DatabaseName    =   "Synergyv.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   7200
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "JobTitle"
      Top             =   1440
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.Data dtcStaff 
      Caption         =   "Staff"
      Connect         =   "Access"
      DatabaseName    =   "Synergyv.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   7200
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
      Top             =   0
      Width           =   8925
      _Version        =   131073
      _ExtentX        =   15743
      _ExtentY        =   1906
      _StockProps     =   69
      BackColor       =   12632256
      FloatingCaption =   "SSToolbar1"
      AlreadyCreated  =   -1  'True
      Outline         =   0   'False
      ToolsetNumBtnStates=   3
      Btns            =   9
      ToolsetPicture  =   "frmStaffNew.frx":0000
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
      ToolsetToolHelp(0)=   "Add a new record"
      ToolsetToolMnemonic(0)=   "a"
      ToolsetToolGroup(0)=   1
      ToolsetToolID(1)=   "ID_Delete"
      ToolsetToolHelp(1)=   "Delete this record"
      ToolsetToolMnemonic(1)=   "d"
      ToolsetToolGroup(1)=   1
      ToolsetToolID(2)=   "ID_Refresh"
      ToolsetToolHelp(2)=   "Refresh this record"
      ToolsetToolMnemonic(2)=   "r"
      ToolsetToolGroup(2)=   1
      ToolsetToolID(3)=   "ID_Save"
      ToolsetToolHelp(3)=   "Save this record"
      ToolsetToolMnemonic(3)=   "s"
      ToolsetToolGroup(3)=   1
      ToolsetToolID(4)=   "ID_Close"
      ToolsetToolHelp(4)=   "Close and exit"
      ToolsetToolMnemonic(4)=   "c"
      ToolsetToolGroup(4)=   1
      ToolsetToolID(5)=   "ID_First"
      ToolsetToolHelp(5)=   "Goto first record"
      ToolsetToolMnemonic(5)=   "f"
      ToolsetToolGroup(5)=   2
      ToolsetToolID(6)=   "ID_Next"
      ToolsetToolHelp(6)=   "Next record"
      ToolsetToolMnemonic(6)=   "x"
      ToolsetToolGroup(6)=   2
      ToolsetToolID(7)=   "ID_Previous"
      ToolsetToolHelp(7)=   "Previous record"
      ToolsetToolMnemonic(7)=   "p"
      ToolsetToolGroup(7)=   2
      ToolsetToolID(8)=   "ID_Last"
      ToolsetToolHelp(8)=   "Goto last record"
      ToolsetToolMnemonic(8)=   "l"
      ToolsetToolGroup(8)=   2
      MouseIcon       =   "frmStaffNew.frx":1B452
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   1575
      Left            =   120
      TabIndex        =   2
      Top             =   1440
      Width           =   4455
      _Version        =   65536
      _ExtentX        =   7858
      _ExtentY        =   2778
      _StockProps     =   14
      Caption         =   "Staff Name"
      Begin VB.TextBox Text2 
         DataField       =   "StaffLastName"
         DataSource      =   "dtcStaff"
         Height          =   285
         Left            =   2640
         TabIndex        =   5
         Top             =   600
         Width           =   1695
      End
      Begin VB.TextBox Text1 
         DataField       =   "StaffFirstName"
         DataSource      =   "dtcStaff"
         Height          =   285
         Left            =   120
         TabIndex        =   3
         Top             =   600
         Width           =   1695
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
      Begin MSDBCtls.DBCombo dbcStaffFullName 
         Bindings        =   "frmStaffNew.frx":1B46E
         DataField       =   "StaffFullName"
         DataSource      =   "dtcStaff"
         Height          =   315
         Left            =   120
         TabIndex        =   6
         Top             =   1200
         Width           =   2295
         _Version        =   65536
         _ExtentX        =   4048
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
         ListField       =   "StaffFullName"
         BoundColumn     =   "StaffFullName"
      End
      Begin MSMask.MaskEdBox mskStaffInitial 
         DataField       =   "StaffInitial"
         DataSource      =   "dtcStaff"
         Height          =   255
         Left            =   2040
         TabIndex        =   4
         Top             =   600
         Width           =   375
         _Version        =   65536
         _ExtentX        =   661
         _ExtentY        =   450
         _StockProps     =   109
         ForeColor       =   -2147483640
         BackColor       =   -2147483643
         BorderStyle     =   1
         PromptInclude   =   0   'False
         MaxLength       =   2
         Mask            =   ">??"
      End
   End
   Begin SSDesignerWidgetsTabs.SSIndexTab SSIndexTab1 
      Height          =   2895
      Left            =   120
      TabIndex        =   12
      Top             =   3120
      Width           =   8655
      _Version        =   131077
      _ExtentX        =   15266
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
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   400
         size            =   8.25
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      BeginProperty PageFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   400
         size            =   8.25
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      BeginProperty ActiveTabFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   8.25
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      BeginProperty ActivePageFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   8.25
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
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
      Tabs(0).Pages(0).CtlCount=   12
      Tabs(0).Pages(0).CtlEnabled=   0   'False
      Tabs(0).Pages(0).Ctl(0)=   "SSFrame2"
      Tabs(0).Pages(0).Ctl(1)=   "SSFrame3"
      Tabs(0).Pages(0).Ctl(2)=   "SSDateCombo2"
      Tabs(0).Pages(0).Ctl(3)=   "Label10"
      Tabs(0).Pages(0).Ctl(4)=   "SSDateCombo1"
      Tabs(0).Pages(0).Ctl(5)=   "Label9"
      Tabs(0).Pages(0).Ctl(6)=   "MaskEdBox1"
      Tabs(0).Pages(0).Ctl(7)=   "Label8"
      Tabs(0).Pages(0).Ctl(8)=   "dbcJobNature"
      Tabs(0).Pages(0).Ctl(9)=   "Label7"
      Tabs(0).Pages(0).Ctl(10)=   "dbcJobTitle"
      Tabs(0).Pages(0).Ctl(11)=   "Label6"
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
      Tabs(1).Pages(0).CtlCount=   9
      Tabs(1).Pages(0).CtlEnabled=   -1  'True
      Tabs(1).Pages(0).Ctl(0)=   "dblSex"
      Tabs(1).Pages(0).Ctl(1)=   "SSFrame4"
      Tabs(1).Pages(0).Ctl(2)=   "SSDateCombo3"
      Tabs(1).Pages(0).Ctl(3)=   "dbcMaritalStatus"
      Tabs(1).Pages(0).Ctl(4)=   "mskSIN"
      Tabs(1).Pages(0).Ctl(5)=   "Label20"
      Tabs(1).Pages(0).Ctl(6)=   "Label19"
      Tabs(1).Pages(0).Ctl(7)=   "Label18"
      Tabs(1).Pages(0).Ctl(8)=   "Label17"
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
      Begin VB.ComboBox dblSex 
         DataField       =   "Sex"
         DataSource      =   "dtcStaff"
         Height          =   315
         ItemData        =   "frmStaffNew.frx":1B47F
         Left            =   1320
         List            =   "frmStaffNew.frx":1B489
         TabIndex        =   42
         Text            =   "Combo1"
         Top             =   840
         Width           =   495
      End
      Begin Threed.SSFrame SSFrame2 
         Height          =   1455
         Left            =   -71760
         TabIndex        =   23
         Top             =   360
         Width           =   1935
         _Version        =   65536
         _ExtentX        =   3413
         _ExtentY        =   2566
         _StockProps     =   14
         Caption         =   "Salary"
         Begin VB.TextBox Text3 
            DataField       =   "SalaryBasic"
            DataSource      =   "dtcStaff"
            Height          =   285
            Left            =   720
            TabIndex        =   26
            Top             =   240
            Width           =   1095
         End
         Begin MSDBCtls.DBCombo dbcPayPeriod 
            Bindings        =   "frmStaffNew.frx":1B493
            DataField       =   "SalaryPayPeriod"
            DataSource      =   "dtcStaff"
            Height          =   315
            Left            =   720
            TabIndex        =   29
            Top             =   960
            Width           =   1095
            _Version        =   65536
            _ExtentX        =   1931
            _ExtentY        =   556
            _StockProps     =   77
            ForeColor       =   0
            BackColor       =   16777215
            ListField       =   "Name"
            BoundColumn     =   "Code"
         End
         Begin VB.Label Label13 
            Caption         =   "Pay Period:"
            Height          =   375
            Left            =   120
            TabIndex        =   28
            Top             =   960
            Width           =   615
         End
         Begin MSDBCtls.DBCombo dbcPayPer 
            Bindings        =   "frmStaffNew.frx":1B4A8
            DataField       =   "SalaryPer"
            DataSource      =   "dtcStaff"
            Height          =   315
            Left            =   720
            TabIndex        =   27
            Top             =   600
            Width           =   1095
            _Version        =   65536
            _ExtentX        =   1931
            _ExtentY        =   556
            _StockProps     =   77
            ForeColor       =   0
            BackColor       =   16777215
            ListField       =   "Name"
            BoundColumn     =   "Code"
         End
         Begin VB.Label Label12 
            Caption         =   "Per"
            Height          =   255
            Left            =   120
            TabIndex        =   25
            Top             =   600
            Width           =   375
         End
         Begin VB.Label Label11 
            Caption         =   "Basic:"
            Height          =   255
            Left            =   120
            TabIndex        =   24
            Top             =   240
            Width           =   495
         End
      End
      Begin Threed.SSFrame SSFrame3 
         Height          =   1455
         Left            =   -69720
         TabIndex        =   30
         Top             =   360
         Width           =   1815
         _Version        =   65536
         _ExtentX        =   3201
         _ExtentY        =   2566
         _StockProps     =   14
         Caption         =   "Commission Rates"
         Begin VB.TextBox Text6 
            DataField       =   "CommissionGeneral"
            DataSource      =   "dtcStaff"
            Height          =   285
            Left            =   840
            TabIndex        =   36
            Top             =   960
            Width           =   855
         End
         Begin VB.TextBox Text5 
            DataField       =   "CommissionBonus"
            DataSource      =   "dtcStaff"
            Height          =   285
            Left            =   840
            TabIndex        =   35
            Top             =   600
            Width           =   855
         End
         Begin VB.TextBox Text4 
            DataField       =   "CommissionRate"
            DataSource      =   "dtcStaff"
            Height          =   285
            Left            =   840
            TabIndex        =   34
            Top             =   240
            Width           =   855
         End
         Begin VB.Label Label16 
            Caption         =   "General:"
            Height          =   255
            Left            =   120
            TabIndex        =   33
            Top             =   960
            Width           =   735
         End
         Begin VB.Label Label15 
            Caption         =   "Bonus:"
            Height          =   255
            Left            =   120
            TabIndex        =   32
            Top             =   600
            Width           =   735
         End
         Begin VB.Label Label14 
            Caption         =   "Basic:"
            Height          =   255
            Left            =   120
            TabIndex        =   31
            Top             =   240
            Width           =   615
         End
      End
      Begin Threed.SSFrame SSFrame4 
         Height          =   2415
         Left            =   3000
         TabIndex        =   45
         Top             =   360
         Width           =   5535
         _Version        =   65536
         _ExtentX        =   9763
         _ExtentY        =   4260
         _StockProps     =   14
         Caption         =   "Home Address"
         Begin VB.TextBox Text8 
            DataField       =   "HomeAddress2"
            DataSource      =   "dtcStaff"
            Height          =   285
            Left            =   1080
            TabIndex        =   53
            Top             =   600
            Width           =   2535
         End
         Begin VB.TextBox Text7 
            DataField       =   "HomeAddress1"
            DataSource      =   "dtcStaff"
            Height          =   285
            Left            =   1080
            TabIndex        =   52
            Top             =   240
            Width           =   2535
         End
         Begin MSMask.MaskEdBox mskPostalCode 
            DataField       =   "HomePostalCode"
            DataSource      =   "dtcStaff"
            Height          =   255
            Left            =   1080
            TabIndex        =   56
            Top             =   1680
            Width           =   855
            _Version        =   65536
            _ExtentX        =   1508
            _ExtentY        =   450
            _StockProps     =   109
            ForeColor       =   -2147483640
            BackColor       =   -2147483643
            BorderStyle     =   1
            PromptInclude   =   0   'False
            MaxLength       =   6
            Mask            =   ">A#A#A#"
         End
         Begin MSMask.MaskEdBox mskFax 
            DataField       =   "HomeFax"
            DataSource      =   "dtcStaff"
            Height          =   255
            Left            =   3600
            TabIndex        =   58
            Top             =   2040
            Width           =   1455
            _Version        =   65536
            _ExtentX        =   2566
            _ExtentY        =   450
            _StockProps     =   109
            ForeColor       =   -2147483640
            BackColor       =   -2147483643
            BorderStyle     =   1
            PromptInclude   =   0   'False
            MaxLength       =   16
            Mask            =   "(###) ### - ####"
         End
         Begin MSMask.MaskEdBox mskPhone 
            DataField       =   "HomePhone"
            DataSource      =   "dtcStaff"
            Height          =   255
            Left            =   1080
            TabIndex        =   57
            Top             =   2040
            Width           =   1455
            _Version        =   65536
            _ExtentX        =   2566
            _ExtentY        =   450
            _StockProps     =   109
            ForeColor       =   -2147483640
            BackColor       =   -2147483643
            BorderStyle     =   1
            PromptInclude   =   0   'False
            MaxLength       =   16
            Mask            =   "(###) ### - ####"
         End
         Begin MSDBCtls.DBCombo dbcProvince 
            Bindings        =   "frmStaffNew.frx":1B4BA
            DataField       =   "HomeProvince"
            DataSource      =   "dtcStaff"
            Height          =   315
            Left            =   1080
            TabIndex        =   55
            Top             =   1320
            Width           =   1935
            _Version        =   65536
            _ExtentX        =   3413
            _ExtentY        =   556
            _StockProps     =   77
            ForeColor       =   0
            BackColor       =   16777215
            ListField       =   "ProvinceName"
            BoundColumn     =   "ProvinceCode"
         End
         Begin MSDBCtls.DBCombo dbcCity 
            Bindings        =   "frmStaffNew.frx":1B4CE
            DataField       =   "HomeCity"
            DataSource      =   "dtcStaff"
            Height          =   315
            Left            =   1080
            TabIndex        =   54
            Top             =   960
            Width           =   1935
            _Version        =   65536
            _ExtentX        =   3413
            _ExtentY        =   556
            _StockProps     =   77
            ForeColor       =   0
            BackColor       =   16777215
            ListField       =   "CityName"
            BoundColumn     =   "CityName"
         End
         Begin VB.Label Label26 
            Caption         =   "Fax"
            Height          =   255
            Left            =   3120
            TabIndex        =   51
            Top             =   2040
            Width           =   495
         End
         Begin VB.Label Label25 
            Caption         =   "Phone"
            Height          =   255
            Left            =   120
            TabIndex        =   50
            Top             =   2040
            Width           =   615
         End
         Begin VB.Label Label24 
            Caption         =   "Postal Code"
            Height          =   255
            Left            =   120
            TabIndex        =   49
            Top             =   1680
            Width           =   855
         End
         Begin VB.Label Label23 
            Caption         =   "Province"
            Height          =   255
            Left            =   120
            TabIndex        =   48
            Top             =   1320
            Width           =   735
         End
         Begin VB.Label Label22 
            Caption         =   "City"
            Height          =   255
            Left            =   120
            TabIndex        =   47
            Top             =   960
            Width           =   375
         End
         Begin VB.Label Label21 
            Caption         =   "Street"
            Height          =   255
            Left            =   120
            TabIndex        =   46
            Top             =   240
            Width           =   495
         End
      End
      Begin SSCalendarWidgets_A.SSDateCombo SSDateCombo3 
         Height          =   255
         Left            =   1320
         TabIndex        =   44
         Top             =   1560
         Width           =   1455
         _Version        =   65536
         _ExtentX        =   2566
         _ExtentY        =   450
         _StockProps     =   77
      End
      Begin MSDBCtls.DBCombo dbcMaritalStatus 
         Bindings        =   "frmStaffNew.frx":1B4DE
         DataField       =   "MaritalStatus"
         DataSource      =   "dtcStaff"
         Height          =   315
         Left            =   1320
         TabIndex        =   43
         Top             =   1200
         Width           =   1215
         _Version        =   65536
         _ExtentX        =   2143
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
         ListField       =   "MaritalStatus"
         BoundColumn     =   "Code"
      End
      Begin MSMask.MaskEdBox mskSIN 
         DataField       =   "SIN"
         DataSource      =   "dtcStaff"
         Height          =   255
         Left            =   1320
         TabIndex        =   41
         Top             =   480
         Width           =   1455
         _Version        =   65536
         _ExtentX        =   2566
         _ExtentY        =   450
         _StockProps     =   109
         ForeColor       =   -2147483640
         BackColor       =   -2147483643
         BorderStyle     =   1
         PromptInclude   =   0   'False
         MaxLength       =   11
         Mask            =   "### ### ###"
      End
      Begin VB.Label Label20 
         Caption         =   "Birthday"
         Height          =   255
         Left            =   120
         TabIndex        =   40
         Top             =   1560
         Width           =   975
      End
      Begin VB.Label Label19 
         Caption         =   "Marital Status"
         Height          =   255
         Left            =   120
         TabIndex        =   39
         Top             =   1200
         Width           =   975
      End
      Begin VB.Label Label18 
         Caption         =   "Sex"
         Height          =   255
         Left            =   120
         TabIndex        =   38
         Top             =   840
         Width           =   855
      End
      Begin VB.Label Label17 
         Caption         =   "SIN"
         Height          =   255
         Left            =   120
         TabIndex        =   37
         Top             =   480
         Width           =   735
      End
      Begin SSCalendarWidgets_A.SSDateCombo SSDateCombo2 
         DataField       =   "DateLeaved"
         DataSource      =   "dtcStaff"
         Height          =   255
         Left            =   -73800
         TabIndex        =   22
         Top             =   1800
         Width           =   1455
         _Version        =   65536
         _ExtentX        =   2566
         _ExtentY        =   450
         _StockProps     =   77
      End
      Begin VB.Label Label10 
         Caption         =   "Date Leaved:"
         Height          =   255
         Left            =   -74880
         TabIndex        =   21
         Top             =   1800
         Width           =   975
      End
      Begin SSCalendarWidgets_A.SSDateCombo SSDateCombo1 
         DataField       =   "DateHired"
         DataSource      =   "dtcStaff"
         Height          =   255
         Left            =   -73800
         TabIndex        =   20
         Top             =   1440
         Width           =   1455
         _Version        =   65536
         _ExtentX        =   2566
         _ExtentY        =   450
         _StockProps     =   77
      End
      Begin VB.Label Label9 
         Caption         =   "Date Hired"
         Height          =   255
         Left            =   -74880
         TabIndex        =   19
         Top             =   1440
         Width           =   975
      End
      Begin MSMask.MaskEdBox MaskEdBox1 
         DataField       =   "SecurityLevel"
         DataSource      =   "dtcStaff"
         Height          =   255
         Left            =   -73800
         TabIndex        =   18
         Top             =   1080
         Width           =   255
         _Version        =   65536
         _ExtentX        =   450
         _ExtentY        =   450
         _StockProps     =   109
         ForeColor       =   -2147483640
         BackColor       =   -2147483643
         BorderStyle     =   1
         PromptInclude   =   0   'False
         MaxLength       =   1
         Mask            =   "#"
      End
      Begin VB.Label Label8 
         Caption         =   "Security Level:"
         Height          =   255
         Left            =   -74880
         TabIndex        =   17
         Top             =   1080
         Width           =   1095
      End
      Begin MSDBCtls.DBCombo dbcJobNature 
         Bindings        =   "frmStaffNew.frx":1B4F7
         DataField       =   "JobNature"
         DataSource      =   "dtcStaff"
         Height          =   315
         Left            =   -73800
         TabIndex        =   16
         Top             =   720
         Width           =   1815
         _Version        =   65536
         _ExtentX        =   3201
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
         ListField       =   "Name"
         BoundColumn     =   "Code"
      End
      Begin VB.Label Label7 
         Caption         =   "Job Nature:"
         Height          =   255
         Left            =   -74880
         TabIndex        =   15
         Top             =   720
         Width           =   855
      End
      Begin MSDBCtls.DBCombo dbcJobTitle 
         Bindings        =   "frmStaffNew.frx":1B50C
         DataField       =   "JobTitle"
         DataSource      =   "dtcStaff"
         Height          =   315
         Left            =   -73800
         TabIndex        =   14
         Top             =   360
         Width           =   1815
         _Version        =   65536
         _ExtentX        =   3201
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
         ListField       =   "JobTitle"
         BoundColumn     =   "JobTitleCode"
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
   Begin VB.Label Label1 
      Caption         =   "Staff Code:"
      Height          =   255
      Left            =   240
      TabIndex        =   7
      Top             =   1200
      Width           =   855
   End
   Begin MSMask.MaskEdBox mskStaffCode 
      DataField       =   "StaffCode"
      DataSource      =   "dtcStaff"
      Height          =   255
      Left            =   1200
      TabIndex        =   1
      Top             =   1200
      Width           =   735
      _Version        =   65536
      _ExtentX        =   1296
      _ExtentY        =   450
      _StockProps     =   109
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      PromptInclude   =   0   'False
      MaxLength       =   4
      Mask            =   ">aaaa"
   End
End
Attribute VB_Name = "frmStaffNew"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

    On Error GoTo SSToolbar1_Click_Err

    Select Case ToolID
        Case "ID_Add"
            dtcStaff.Recordset.AddNew
            mskStaffCode.SetFocus
        Case "ID_Delete"
            dtcStaff.Recordset.Delete
            dtcStaff.Recordset.MoveNext
        Case "ID_Refresh"
            dtcStaff.Refresh
        Case "ID_Save"
            dtcStaff.UpdateRecord
            dtcStaff.Recordset.Bookmark = dtcStaff.Recordset.LastModified
            dtcStaff.Refresh
        Case "ID_Close"
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



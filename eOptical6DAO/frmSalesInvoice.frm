VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{B074BC93-5A5B-11CE-98BD-0000C0E6B88E}#2.0#0"; "sstabs32.ocx"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmSalesInvoice 
   Caption         =   "Sales Invoice"
   ClientHeight    =   7155
   ClientLeft      =   600
   ClientTop       =   1230
   ClientWidth     =   10785
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   7155
   ScaleWidth      =   10785
   Begin VB.TextBox Text7 
      Height          =   285
      Left            =   1320
      TabIndex        =   1
      Text            =   "Text7"
      Top             =   1200
      Width           =   1095
   End
   Begin VB.TextBox Text6 
      Height          =   285
      Left            =   9480
      TabIndex        =   28
      Text            =   "Text6"
      Top             =   6840
      Width           =   1095
   End
   Begin VB.TextBox Text5 
      Height          =   285
      Left            =   9480
      TabIndex        =   27
      Text            =   "Text5"
      Top             =   6480
      Width           =   1095
   End
   Begin VB.TextBox Text4 
      Height          =   285
      Left            =   9480
      TabIndex        =   26
      Text            =   "Text4"
      Top             =   6120
      Width           =   1095
   End
   Begin VB.TextBox Text3 
      Height          =   285
      Left            =   9480
      TabIndex        =   25
      Text            =   "Text3"
      Top             =   5760
      Width           =   1095
   End
   Begin VB.TextBox Text2 
      Height          =   285
      Left            =   9480
      TabIndex        =   24
      Text            =   "Text2"
      Top             =   5400
      Width           =   1095
   End
   Begin VB.TextBox Text1 
      Height          =   735
      Left            =   5520
      TabIndex        =   13
      Text            =   "Text1"
      Top             =   1920
      Width           =   2775
   End
   Begin VB.ComboBox Combo4 
      Height          =   315
      Left            =   1320
      TabIndex        =   7
      Text            =   "Combo4"
      Top             =   2280
      Width           =   2175
   End
   Begin VB.ComboBox Combo3 
      Height          =   315
      Left            =   1320
      TabIndex        =   5
      Text            =   "Combo3"
      Top             =   1920
      Width           =   2175
   End
   Begin VB.ComboBox Combo2 
      Height          =   315
      Left            =   1320
      TabIndex        =   3
      Text            =   "Combo2"
      Top             =   1560
      Width           =   1095
   End
   Begin SSDesignerWidgetsTabs.SSIndexTab SSIndexTab1 
      Height          =   2535
      Left            =   120
      TabIndex        =   14
      Top             =   2760
      Width           =   10575
      _Version        =   131078
      _ExtentX        =   18653
      _ExtentY        =   4471
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
      TabVisibleLast  =   3
      TabShape        =   6
      TabsPerRow      =   10
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
      Tabs(0).Pages(0).CtlCount=   3
      Tabs(0).Pages(0).CtlEnabled=   -1  'True
      Tabs(0).Pages(0).Ctl(0)=   "TDBGrid1"
      Tabs(0).Pages(0).Ctl(1)=   "SSCommand2"
      Tabs(0).Pages(0).Ctl(2)=   "SSCommand3"
      Tabs(0).Tag     =   ""
      Tabs(0).Caption =   "Glass"
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
      Tabs(1).Pages(0).CtlCount=   1
      Tabs(1).Pages(0).CtlEnabled=   0   'False
      Tabs(1).Pages(0).Ctl(0)=   "TDBGrid2"
      Tabs(1).Tag     =   ""
      Tabs(1).Caption =   "Contact"
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
      Tabs(2).Pages(0).CtlCount=   1
      Tabs(2).Pages(0).CtlEnabled=   0   'False
      Tabs(2).Pages(0).Ctl(0)=   "TDBGrid3"
      Tabs(2).Tag     =   ""
      Tabs(2).Caption =   "Disposal"
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
      Tabs(3).Pages(0).CtlCount=   1
      Tabs(3).Pages(0).CtlEnabled=   0   'False
      Tabs(3).Pages(0).Ctl(0)=   "TDBGrid4"
      Tabs(3).Tag     =   ""
      Tabs(3).Caption =   "Accessory"
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
         Height          =   2055
         Left            =   120
         OleObjectBlob   =   "frmSalesInvoice.frx":0000
         TabIndex        =   15
         Top             =   360
         Width           =   10335
      End
      Begin TrueDBGrid50.TDBGrid TDBGrid2 
         Height          =   2055
         Left            =   -74880
         OleObjectBlob   =   "frmSalesInvoice.frx":3FB1
         TabIndex        =   16
         Top             =   360
         Width           =   10335
      End
      Begin TrueDBGrid50.TDBGrid TDBGrid3 
         Height          =   2055
         Left            =   -74880
         OleObjectBlob   =   "frmSalesInvoice.frx":7B46
         TabIndex        =   17
         Top             =   360
         Width           =   10335
      End
      Begin TrueDBGrid50.TDBGrid TDBGrid4 
         Height          =   2055
         Left            =   -74880
         OleObjectBlob   =   "frmSalesInvoice.frx":B6DB
         TabIndex        =   18
         Top             =   360
         Width           =   10335
      End
      Begin Threed.SSCommand SSCommand3 
         Height          =   345
         Left            =   4680
         TabIndex        =   32
         Top             =   480
         Width           =   360
         _ExtentX        =   635
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
         Picture         =   "frmSalesInvoice.frx":DDDC
         AutoSize        =   2
         ButtonStyle     =   2
         BevelWidth      =   0
         Outline         =   0   'False
      End
      Begin Threed.SSCommand SSCommand2 
         Height          =   300
         Left            =   1440
         TabIndex        =   31
         Top             =   480
         Width           =   315
         _ExtentX        =   556
         _ExtentY        =   529
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
         Picture         =   "frmSalesInvoice.frx":E2A2
         AutoSize        =   2
         ButtonStyle     =   2
         BevelWidth      =   0
         Outline         =   0   'False
      End
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Height          =   840
      Left            =   0
      TabIndex        =   29
      Top             =   5280
      Width           =   7275
      _Version        =   131073
      _ExtentX        =   12832
      _ExtentY        =   1483
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
      ToolsetNumBtnStates=   3
      Btns            =   10
      ToolsetPicture  =   "frmSalesInvoice.frx":E834
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
      ToolsetToolID(0)=   "TOOL0000"
      ToolsetToolGroup(0)=   1
      ToolsetToolID(1)=   "TOOL0001"
      ToolsetToolGroup(1)=   1
      ToolsetToolID(2)=   "TOOL0002"
      ToolsetToolGroup(2)=   1
      ToolsetToolID(3)=   "TOOL0003"
      ToolsetToolGroup(3)=   1
      ToolsetToolID(4)=   "TOOL0004"
      ToolsetToolGroup(4)=   1
      ToolsetToolID(5)=   "TOOL0005"
      ToolsetToolGroup(5)=   1
      ToolsetToolID(6)=   "TOOL0006"
      ToolsetToolGroup(6)=   1
      ToolsetToolID(7)=   "TOOL0007"
      ToolsetToolGroup(7)=   1
      ToolsetToolID(8)=   "TOOL0008"
      ToolsetToolGroup(8)=   1
      ToolsetToolID(9)=   "TOOL0009"
      ToolsetToolGroup(9)=   1
      MouseIcon       =   "frmSalesInvoice.frx":1FA86
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar2 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   33
      Top             =   0
      Width           =   10785
      _Version        =   131073
      _ExtentX        =   19024
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
      FloatingCaption =   "SSToolbar2"
      AlreadyCreated  =   -1  'True
      Outline         =   0   'False
      ToolsetNumBtnStates=   3
      Btns            =   9
      ToolsetPicture  =   "frmSalesInvoice.frx":1FAA2
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
      ToolsetToolID(0)=   "TOOL0000"
      ToolsetToolGroup(0)=   1
      ToolsetToolID(1)=   "TOOL0001"
      ToolsetToolGroup(1)=   1
      ToolsetToolID(2)=   "TOOL0002"
      ToolsetToolGroup(2)=   1
      ToolsetToolID(3)=   "TOOL0003"
      ToolsetToolGroup(3)=   1
      ToolsetToolID(4)=   "TOOL0004"
      ToolsetToolGroup(4)=   1
      ToolsetToolID(5)=   "TOOL0005"
      ToolsetToolGroup(5)=   2
      ToolsetToolID(6)=   "TOOL0006"
      ToolsetToolGroup(6)=   2
      ToolsetToolID(7)=   "TOOL0007"
      ToolsetToolGroup(7)=   3
      ToolsetToolID(8)=   "TOOL0008"
      ToolsetToolGroup(8)=   3
      MouseIcon       =   "frmSalesInvoice.frx":3AEF4
   End
   Begin SSCalendarWidgets_A.SSDateCombo SSDateCombo2 
      Height          =   255
      Left            =   5520
      TabIndex        =   11
      Top             =   1560
      Width           =   1455
      _Version        =   65543
      _ExtentX        =   2566
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
   End
   Begin SSCalendarWidgets_A.SSDateCombo SSDateCombo1 
      Height          =   255
      Left            =   5520
      TabIndex        =   8
      Top             =   1200
      Width           =   1455
      _Version        =   65543
      _ExtentX        =   2566
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
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   300
      Left            =   3480
      TabIndex        =   30
      Top             =   2280
      Width           =   315
      _ExtentX        =   556
      _ExtentY        =   529
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
      Picture         =   "frmSalesInvoice.frx":3AF10
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   0
      Outline         =   0   'False
   End
   Begin VB.Label Label13 
      Caption         =   "Outstanding"
      Height          =   255
      Left            =   8520
      TabIndex        =   23
      Top             =   6840
      Width           =   975
   End
   Begin VB.Label Label12 
      Caption         =   "Depsit Paid"
      Height          =   255
      Left            =   8520
      TabIndex        =   22
      Top             =   6480
      Width           =   975
   End
   Begin VB.Label Label11 
      Caption         =   "Gross Sale"
      Height          =   255
      Left            =   8520
      TabIndex        =   21
      Top             =   6120
      Width           =   975
   End
   Begin VB.Label Label9 
      Caption         =   "Total Tax"
      Height          =   255
      Left            =   8520
      TabIndex        =   20
      Top             =   5760
      Width           =   735
   End
   Begin VB.Label Label8 
      Caption         =   "Total Sale"
      Height          =   255
      Left            =   8520
      TabIndex        =   19
      Top             =   5400
      Width           =   855
   End
   Begin VB.Label Label7 
      Caption         =   "Particular"
      Height          =   255
      Left            =   4080
      TabIndex        =   12
      Top             =   1920
      Width           =   1575
   End
   Begin VB.Label Label6 
      Caption         =   "Est. Delivery Date"
      Height          =   255
      Left            =   4080
      TabIndex        =   10
      Top             =   1560
      Width           =   1335
   End
   Begin VB.Label Label5 
      Caption         =   "Date Ordered"
      Height          =   255
      Left            =   4080
      TabIndex        =   9
      Top             =   1200
      Width           =   1335
   End
   Begin VB.Label Label4 
      Caption         =   "Customer Name"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   2280
      Width           =   1335
   End
   Begin VB.Label Label3 
      Caption         =   "Sales Person"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   1920
      Width           =   975
   End
   Begin VB.Label Label2 
      Caption         =   "Status"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   1560
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Order Number"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   1200
      Width           =   1095
   End
End
Attribute VB_Name = "frmSalesInvoice"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Activate()
    ' Declare the data source of dtcSalePerson
    Dim strSQL As String
    strSQL = "SELECT DISTINCTROW Staff.StaffCode, Staff.StaffFullName " _
            & "FROM Staff INNER JOIN " _
            & "(TxHeader INNER JOIN TxSalePerson " _
            & "ON TxHeader.TxNumber = TxSalePerson.TxNumber) " _
            & "ON Staff.StaffCode = TxSalePerson.StaffCode " _
            & "GROUP BY Staff.StaffCode, Staff.StaffFullName"
'    dtcStaff.RecordSource = SQL
'    dtcStaff.Refresh
'    dtcStaff.UpdateControls

End Sub


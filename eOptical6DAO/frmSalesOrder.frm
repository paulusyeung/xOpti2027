VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmSalesOrder 
   Caption         =   "Sale Order Entry"
   ClientHeight    =   8175
   ClientLeft      =   525
   ClientTop       =   645
   ClientWidth     =   11760
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   8175
   ScaleWidth      =   11760
   WindowState     =   2  'Maximized
   Begin TrueDBGrid50.TDBGrid tdbgTxBody 
      Height          =   2055
      Left            =   120
      OleObjectBlob   =   "frmSalesOrder.frx":0000
      TabIndex        =   31
      Top             =   3600
      Width           =   11475
   End
   Begin VB.Data dtcTxDetails 
      Caption         =   "TxDetails"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   345
      Left            =   7320
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT * FROM TxDetails ORDER BY TxNumber, RowNo"
      Top             =   3240
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcTxSOrderExtra 
      Caption         =   "TxSOrderExtra"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   345
      Left            =   8040
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "TxSOrderExtra"
      Top             =   4980
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcQryTxPayment 
      Caption         =   "qryTxPayment"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   345
      Left            =   9360
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "qryTxPayment"
      Top             =   4860
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcTxSalesPerson 
      Caption         =   "TxSalePerson"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   345
      Left            =   9360
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "qryTxSalesPerson"
      Top             =   4440
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcTxHeader 
      Caption         =   "TxHeader"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   345
      Left            =   6960
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "TxHeader"
      Top             =   3060
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcPaymentMethods 
      Caption         =   "PaymentMethods"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   1680
      Options         =   4
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT * FROM PaymentMethods ORDER BY PaymentNameLong"
      Top             =   7140
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.Data dtcPLU 
      Caption         =   "PLU"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   840
      Options         =   4
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   4080
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcStaff 
      Caption         =   "Staff"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   345
      Left            =   5940
      Options         =   4
      ReadOnly        =   -1  'True
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT StaffCode, StaffFullName FROM Staff ORDER BY StaffFullName"
      Top             =   3120
      Visible         =   0   'False
      Width           =   1140
   End
   Begin Threed.SSFrame fraHeaderR 
      Height          =   1995
      Left            =   9240
      TabIndex        =   16
      Top             =   1020
      Width           =   2175
      _ExtentX        =   3836
      _ExtentY        =   3519
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
      Caption         =   "Service"
      Begin VB.TextBox txtRefNumber 
         Height          =   285
         Left            =   120
         TabIndex        =   22
         Top             =   1620
         Width           =   1095
      End
      Begin VB.CheckBox chkWarranty 
         Caption         =   "Warranty"
         Height          =   255
         Left            =   120
         TabIndex        =   20
         Top             =   1080
         Width           =   975
      End
      Begin VB.CheckBox chkMsd 
         Caption         =   "Msd"
         Height          =   255
         Left            =   120
         TabIndex        =   18
         Top             =   540
         Width           =   615
      End
      Begin VB.CheckBox chkMail 
         Caption         =   "Mail"
         Height          =   255
         Left            =   120
         TabIndex        =   17
         Top             =   300
         Width           =   735
      End
      Begin VB.CheckBox chkRedo 
         Caption         =   "Redo"
         Height          =   255
         Left            =   120
         TabIndex        =   19
         Top             =   840
         Width           =   735
      End
      Begin VB.Label Label5 
         Caption         =   "Original Order Number"
         Height          =   255
         Left            =   120
         TabIndex        =   21
         Top             =   1380
         Width           =   1815
      End
   End
   Begin VB.Data dtcTaxMethod 
      Caption         =   "TaxMethod"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   6480
      Options         =   4
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "TaxMethod"
      Top             =   4620
      Visible         =   0   'False
      Width           =   1140
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar tbrOrderEntry 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   0
      Width           =   11760
      _Version        =   131073
      _ExtentX        =   20743
      _ExtentY        =   1906
      _StockProps     =   69
      BackColor       =   12632256
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      FloatingCaption =   "SSToolbar2"
      AlreadyCreated  =   -1  'True
      Outline         =   0   'False
      BackColorHelp   =   12648447
      ToolsetNumBtnStates=   3
      BtnGroupSpacing =   4
      BtnSpacing      =   0
      Btns            =   9
      ToolsetPicture  =   "frmSalesOrder.frx":8033
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
      BtnToolNum(6)   =   7
      BtnPlaceHolder(6)=   0   'False
      BtnToolNum(7)   =   9
      BtnPlaceHolder(7)=   0   'False
      BtnToolNum(8)   =   10
      BtnPlaceHolder(8)=   0   'False
      ToolsetNumTools =   11
      ToolsetToolID(0)=   "ID_Add"
      ToolsetToolHelp(0)=   "Add Order"
      ToolsetToolMnemonic(0)=   "a"
      ToolsetToolGroup(0)=   1
      ToolsetToolAllowAllUp(0)=   -1  'True
      ToolsetToolType(0)=   1
      ToolsetToolExclusive(0)=   -1  'True
      ToolsetToolID(1)=   "ID_Lookup"
      ToolsetToolHelp(1)=   "Lookup Order"
      ToolsetToolMnemonic(1)=   "l"
      ToolsetToolGroup(1)=   1
      ToolsetToolAllowAllUp(1)=   -1  'True
      ToolsetToolType(1)=   1
      ToolsetToolExclusive(1)=   -1  'True
      ToolsetToolID(2)=   "ID_Change"
      ToolsetToolHelp(2)=   "Change Order"
      ToolsetToolMnemonic(2)=   "c"
      ToolsetToolGroup(2)=   1
      ToolsetToolAllowAllUp(2)=   -1  'True
      ToolsetToolType(2)=   1
      ToolsetToolExclusive(2)=   -1  'True
      ToolsetToolID(3)=   "ID_Save"
      ToolsetToolHelp(3)=   "Save Order"
      ToolsetToolMnemonic(3)=   "s"
      ToolsetToolGroup(3)=   1
      ToolsetToolAllowAllUp(3)=   -1  'True
      ToolsetToolType(3)=   1
      ToolsetToolExclusive(3)=   -1  'True
      ToolsetToolID(4)=   "ID_Void"
      ToolsetToolHelp(4)=   "Void Order"
      ToolsetToolMnemonic(4)=   "v"
      ToolsetToolGroup(4)=   1
      ToolsetToolAllowAllUp(4)=   -1  'True
      ToolsetToolType(4)=   1
      ToolsetToolExclusive(4)=   -1  'True
      ToolsetToolID(5)=   "ID_Bill"
      ToolsetToolHelp(5)=   "Bill Customer"
      ToolsetToolMnemonic(5)=   "b"
      ToolsetToolGroup(5)=   1
      ToolsetToolAllowAllUp(5)=   -1  'True
      ToolsetToolType(5)=   1
      ToolsetToolExclusive(5)=   -1  'True
      ToolsetToolID(6)=   "ID_Refund"
      ToolsetToolHelp(6)=   "Refund Cutomer"
      ToolsetToolMnemonic(6)=   "r"
      ToolsetToolGroup(6)=   1
      ToolsetToolAllowAllUp(6)=   -1  'True
      ToolsetToolType(6)=   1
      ToolsetToolExclusive(6)=   -1  'True
      ToolsetToolID(7)=   "ID_Undo"
      ToolsetToolHelp(7)=   "Undo Edit"
      ToolsetToolMnemonic(7)=   "u"
      ToolsetToolGroup(7)=   2
      ToolsetToolType(7)=   1
      ToolsetToolID(8)=   "ID_Cashier"
      ToolsetToolHelp(8)=   "Regist Sale"
      ToolsetToolMnemonic(8)=   "h"
      ToolsetToolGroup(8)=   2
      ToolsetToolType(8)=   1
      ToolsetToolID(9)=   "ID_Print"
      ToolsetToolHelp(9)=   "Print Document"
      ToolsetToolMnemonic(9)=   "p"
      ToolsetToolGroup(9)=   2
      ToolsetToolType(9)=   1
      ToolsetToolID(10)=   "ID_Exit"
      ToolsetToolHelp(10)=   "Exit Task"
      ToolsetToolMnemonic(10)=   "x"
      ToolsetToolGroup(10)=   2
      ToolsetToolType(10)=   1
      MouseIcon       =   "frmSalesOrder.frx":188C5
   End
   Begin Threed.SSFrame fraTender 
      Height          =   1815
      Left            =   120
      TabIndex        =   33
      Top             =   5700
      Width           =   8415
      _ExtentX        =   14843
      _ExtentY        =   3201
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
      Caption         =   "Tender"
      Begin TrueDBGrid50.TDBGrid tdbgTxTender 
         Height          =   1455
         Left            =   120
         OleObjectBlob   =   "frmSalesOrder.frx":188E1
         TabIndex        =   34
         Top             =   240
         Width           =   8175
      End
   End
   Begin Threed.SSFrame fraMiniTools 
      Height          =   555
      Left            =   120
      TabIndex        =   27
      ToolTipText     =   "Helpful Functions"
      Top             =   3000
      Width           =   1575
      _ExtentX        =   2778
      _ExtentY        =   979
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
      Caption         =   "Mini Tools"
      Begin Threed.SSCommand cmdLookupSKU 
         Height          =   315
         Left            =   840
         TabIndex        =   30
         TabStop         =   0   'False
         ToolTipText     =   "Lookup SKU"
         Top             =   240
         Width           =   315
         _ExtentX        =   556
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
         Picture         =   "frmSalesOrder.frx":1B876
         AutoSize        =   2
         ButtonStyle     =   2
         BevelWidth      =   0
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdPriceWizard 
         Height          =   300
         Left            =   480
         TabIndex        =   29
         TabStop         =   0   'False
         ToolTipText     =   "Price Wizard"
         Top             =   240
         Width           =   300
         _ExtentX        =   529
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
         Picture         =   "frmSalesOrder.frx":1BE1C
         AutoSize        =   2
         ButtonStyle     =   2
         BevelWidth      =   0
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdCalculator 
         Height          =   285
         Left            =   120
         TabIndex        =   28
         TabStop         =   0   'False
         ToolTipText     =   "Calculator"
         Top             =   240
         Width           =   315
         _ExtentX        =   556
         _ExtentY        =   503
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
         Picture         =   "frmSalesOrder.frx":1C36E
         AutoSize        =   2
         ButtonStyle     =   2
         BevelWidth      =   0
         Outline         =   0   'False
      End
   End
   Begin Threed.SSFrame fraOrderDetails 
      Height          =   555
      Left            =   1740
      TabIndex        =   23
      ToolTipText     =   "Order Details per Page"
      Top             =   3000
      Width           =   3975
      _ExtentX        =   7011
      _ExtentY        =   979
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
      Caption         =   "Order Details"
      Begin Threed.SSCommand cmdRemarks 
         Height          =   255
         Left            =   2940
         TabIndex        =   50
         TabStop         =   0   'False
         ToolTipText     =   "Remarks for Customer"
         Top             =   240
         Width           =   915
         _ExtentX        =   1614
         _ExtentY        =   450
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
         Caption         =   "Remarks"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdOrderDetails_Frame 
         Height          =   255
         Left            =   120
         TabIndex        =   24
         TabStop         =   0   'False
         ToolTipText     =   "Details for Frame"
         Top             =   240
         Width           =   675
         _ExtentX        =   1191
         _ExtentY        =   450
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
         Caption         =   "Frame"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdOrderDetails_Cont 
         Height          =   255
         Left            =   1620
         TabIndex        =   26
         TabStop         =   0   'False
         ToolTipText     =   "Details for Contact Lens/Disposal Lens"
         Top             =   240
         Width           =   1215
         _ExtentX        =   2143
         _ExtentY        =   450
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
         Caption         =   "Contact Lens"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdOrderDetails_Lens 
         Height          =   255
         Left            =   900
         TabIndex        =   25
         TabStop         =   0   'False
         ToolTipText     =   "Details for Lens"
         Top             =   240
         Width           =   615
         _ExtentX        =   1085
         _ExtentY        =   450
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
         Caption         =   "Lens"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin Threed.SSFrame fraHeaderC 
      Height          =   1995
      Left            =   4620
      TabIndex        =   9
      Top             =   1020
      Width           =   4455
      _ExtentX        =   7858
      _ExtentY        =   3519
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
      Begin VB.TextBox txtParticular 
         Height          =   915
         Left            =   1080
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   15
         Top             =   960
         Width           =   2775
      End
      Begin SSCalendarWidgets_A.SSDateCombo calDeliverOn 
         Height          =   315
         Left            =   1080
         TabIndex        =   13
         Top             =   600
         Width           =   1935
         _Version        =   65543
         _ExtentX        =   3413
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
      Begin SSCalendarWidgets_A.SSDateCombo calOrderedOn 
         Height          =   315
         Left            =   1080
         TabIndex        =   11
         Top             =   240
         Width           =   1935
         _Version        =   65543
         _ExtentX        =   3413
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
      Begin Threed.SSCommand cmdDefaultRemarks 
         Height          =   315
         Left            =   3900
         TabIndex        =   52
         TabStop         =   0   'False
         ToolTipText     =   "Default Particular"
         Top             =   960
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
         Picture         =   "frmSalesOrder.frx":1C8EC
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label10 
         Caption         =   "Particular"
         Height          =   255
         Left            =   120
         TabIndex        =   14
         Top             =   960
         Width           =   735
      End
      Begin VB.Label Label9 
         Caption         =   "Deliver on"
         Height          =   255
         Left            =   120
         TabIndex        =   12
         Top             =   600
         Width           =   855
      End
      Begin VB.Label Label8 
         Caption         =   "Ordered on"
         Height          =   255
         Left            =   120
         TabIndex        =   10
         Top             =   240
         Width           =   855
      End
   End
   Begin Threed.SSFrame fraHeaderL 
      Height          =   1995
      Left            =   120
      TabIndex        =   1
      Top             =   1020
      Width           =   4395
      _ExtentX        =   7752
      _ExtentY        =   3519
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
      Begin VB.TextBox txtCustomerName 
         BackColor       =   &H00C0C0C0&
         Height          =   315
         Left            =   1200
         Locked          =   -1  'True
         TabIndex        =   7
         TabStop         =   0   'False
         Top             =   1560
         Width           =   2295
      End
      Begin MSDBCtls.DBCombo dbcStaff 
         Bindings        =   "frmSalesOrder.frx":1CCFE
         Height          =   315
         Left            =   1200
         TabIndex        =   5
         Top             =   840
         Width           =   2295
         _ExtentX        =   4048
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "StaffFullName"
         BoundColumn     =   "StaffCode"
         Text            =   ""
      End
      Begin MSMask.MaskEdBox mskOrderNumber 
         Height          =   315
         Left            =   1200
         TabIndex        =   3
         Top             =   180
         Width           =   1095
         _ExtentX        =   1931
         _ExtentY        =   556
         _Version        =   393216
         PromptInclude   =   0   'False
         MaxLength       =   8
         Format          =   ">"
         PromptChar      =   "_"
      End
      Begin Threed.SSCommand cmdDefaultCustomer 
         Height          =   315
         Left            =   3840
         TabIndex        =   51
         TabStop         =   0   'False
         ToolTipText     =   "Default Customer"
         Top             =   1560
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
         Picture         =   "frmSalesOrder.frx":1CD15
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdLookupCustomer 
         Height          =   315
         Left            =   3480
         TabIndex        =   8
         ToolTipText     =   "Lookup Customer"
         Top             =   1560
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
         Picture         =   "frmSalesOrder.frx":1D127
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label11 
         Caption         =   "Customer Name"
         Height          =   375
         Left            =   120
         TabIndex        =   6
         Top             =   1560
         Width           =   735
      End
      Begin VB.Label Label7 
         Caption         =   "Sales Person"
         Height          =   255
         Left            =   120
         TabIndex        =   4
         Top             =   840
         Width           =   1095
      End
      Begin VB.Label lblOrderNumber 
         Caption         =   "Order Number"
         Height          =   255
         Left            =   120
         TabIndex        =   2
         Top             =   180
         Width           =   1095
      End
   End
   Begin Threed.SSFrame fraTotal 
      Height          =   1815
      Left            =   8640
      TabIndex        =   35
      Top             =   5700
      Width           =   2055
      _ExtentX        =   3625
      _ExtentY        =   3201
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
      Caption         =   "Total"
      Begin MSMask.MaskEdBox mskBalance 
         Height          =   255
         Left            =   960
         TabIndex        =   45
         TabStop         =   0   'False
         Top             =   1440
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   450
         _Version        =   393216
         BackColor       =   65535
         PromptInclude   =   0   'False
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskDeposit 
         Height          =   255
         Left            =   960
         TabIndex        =   43
         TabStop         =   0   'False
         Top             =   1140
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   450
         _Version        =   393216
         BackColor       =   65535
         PromptInclude   =   0   'False
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskGrossSale 
         Height          =   255
         Left            =   960
         TabIndex        =   41
         TabStop         =   0   'False
         Top             =   840
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   450
         _Version        =   393216
         BackColor       =   65535
         PromptInclude   =   0   'False
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskTax 
         Height          =   255
         Left            =   960
         TabIndex        =   39
         TabStop         =   0   'False
         Top             =   540
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   450
         _Version        =   393216
         BackColor       =   65535
         PromptInclude   =   0   'False
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskNetSale 
         Height          =   255
         Left            =   960
         TabIndex        =   37
         TabStop         =   0   'False
         Top             =   240
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   450
         _Version        =   393216
         BackColor       =   65535
         PromptInclude   =   0   'False
         Format          =   "$#,##0.00"
         PromptChar      =   "_"
      End
      Begin VB.Label Label13 
         Caption         =   "Balance"
         Height          =   255
         Left            =   120
         TabIndex        =   44
         Top             =   1440
         Width           =   735
      End
      Begin VB.Label Label6 
         Caption         =   "Deposit"
         Height          =   255
         Left            =   120
         TabIndex        =   42
         Top             =   1140
         Width           =   735
      End
      Begin VB.Label Label3 
         Caption         =   "Gross Sale"
         Height          =   255
         Left            =   120
         TabIndex        =   40
         Top             =   840
         Width           =   855
      End
      Begin VB.Label Label2 
         Caption         =   "Tax"
         Height          =   255
         Left            =   120
         TabIndex        =   38
         Top             =   540
         Width           =   735
      End
      Begin VB.Label Label1 
         Caption         =   "Sale"
         Height          =   255
         Left            =   120
         TabIndex        =   36
         Top             =   240
         Width           =   735
      End
   End
   Begin Threed.SSFrame fraLastChange 
      Height          =   555
      Left            =   7440
      TabIndex        =   46
      Top             =   7560
      Width           =   3255
      _ExtentX        =   5741
      _ExtentY        =   979
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
      Caption         =   "Last Change"
      Begin MSMask.MaskEdBox mskChange 
         Height          =   375
         Left            =   1200
         TabIndex        =   47
         TabStop         =   0   'False
         Top             =   120
         Width           =   1935
         _ExtentX        =   3413
         _ExtentY        =   661
         _Version        =   393216
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
   End
   Begin MSMask.MaskEdBox mskTotalTender 
      Height          =   315
      Left            =   3240
      TabIndex        =   49
      TabStop         =   0   'False
      Top             =   7020
      Visible         =   0   'False
      Width           =   1215
      _ExtentX        =   2143
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   65535
      PromptChar      =   "_"
   End
   Begin MSDBCtls.DBCombo dbcPaymentMethods 
      Bindings        =   "frmSalesOrder.frx":1D6CD
      Height          =   315
      Left            =   1080
      TabIndex        =   48
      Top             =   7020
      Visible         =   0   'False
      Width           =   1575
      _ExtentX        =   2778
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "PaymentNameLong"
      BoundColumn     =   "PaymentNameShort"
      Text            =   "dbcPaymentMethods"
   End
   Begin MSDBCtls.DBCombo dbcTaxMethod 
      Bindings        =   "frmSalesOrder.frx":1D6ED
      Height          =   315
      Left            =   6240
      TabIndex        =   32
      Top             =   4320
      Visible         =   0   'False
      Width           =   1575
      _ExtentX        =   2778
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "TaxName"
      BoundColumn     =   "TaxCode"
      Text            =   "dbcTaxMethod"
   End
End
Attribute VB_Name = "frmSalesOrder"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim mCurrentMode As Integer
Dim mLastMode As Integer
Private Const mModeIdle    As Integer = 0
Private Const mModeAdd     As Integer = 1
Private Const mModeLookup  As Integer = 2
Private Const mModeChange  As Integer = 3
Private Const mModeSave    As Integer = 4
Private Const mModeVoid    As Integer = 5
Private Const mModeBill    As Integer = 6
' removed
'Private Const mModeRefund  As Integer = 7
Private Const mModeUndo    As Integer = 7
Private Const mModePrint   As Integer = 8
Private Const mModeExit    As Integer = 9

Private Const mButtonIndex_Add     As Integer = 0
Private Const mButtonIndex_Lookup  As Integer = 1
Private Const mButtonIndex_Change  As Integer = 2
Private Const mButtonIndex_Save    As Integer = 3
Private Const mButtonIndex_Void    As Integer = 4
Private Const mButtonIndex_Bill    As Integer = 5
' removed
'Private Const mButtonIndex_Refund  As Integer = 6
Private Const mButtonIndex_Undo    As Integer = 6
Private Const mButtonIndex_Print   As Integer = 7
Private Const mButtonIndex_Exit    As Integer = 8

Dim TxHeader_SP     As UnboundGrids ' SalesPersons
Dim TxBody          As UnboundGrids ' TxBody - Active Page
'Dim TxBodyP1        As UnboundGrids ' TxBody - Active Page
Dim TxFooter_TD     As UnboundGrids ' Tender
'Dim DefaultTxBody   As UnboundGrids

Private Const TxHeader_SP_MaxRow    As Integer = 2
Private Const TxHeader_SP_MaxCol    As Integer = 2
Private Const TxBody_MaxCol         As Integer = 17
Private Const TxBody_MaxRow         As Integer = 6
Private Const TxFooter_TD_MaxCol    As Integer = 7
Private Const TxFooter_TD_MaxRow    As Integer = 2

Private Const ColIndexSKU       As Integer = 1
Private Const ColIndexSupplier  As Integer = 2
Private Const ColIndexBrand     As Integer = 3
Private Const ColIndexModel     As Integer = 4
Private Const ColIndexOnhand    As Integer = 5
Private Const ColIndexMaterial  As Integer = 6
Private Const ColIndexColor     As Integer = 7
Private Const ColIndexSize      As Integer = 8
Private Const ColIndexSphere    As Integer = 9
Private Const ColIndexCylinder  As Integer = 10
Private Const ColIndexBaseCurve As Integer = 11
Private Const ColIndexTax       As Integer = 12
Private Const ColIndexQty       As Integer = 13
Private Const ColIndexUnitPrice As Integer = 14
Private Const ColIndexMarkdown  As Integer = 15
Private Const ColIndexAmount    As Integer = 16

' TxTender default column index
Private Const ColIndexType      As Integer = 1
Private Const ColIndexCardNo    As Integer = 2
Private Const ColIndexTender    As Integer = 3
Private Const ColIndexXchgRate  As Integer = 4
Private Const ColIndexLocalCur  As Integer = 5
Private Const ColIndexAppCode   As Integer = 6

Private Type Totals
    Cost As Currency
    Sale As Currency
    GST As Currency
    PST As Currency
    Tax As Currency
    Gross As Currency
    Qty As Integer
End Type

Dim OrderTotal As Totals

Dim mOrderStatus As Integer     ' current order is:0=Draft,1=Confirmed,2=Cancelled,3=Completed
Dim mControlNumber As Long
Dim mTxNumber As String
Dim mOrderNumber As String
Dim mVoidOn As Date

'   WA added on Jan 07, 1998 for Date Control
Private Const mDateAllowance As Integer = 7
Private Const mDateDelivery As Integer = 60
Dim mOrderDate As Date

Private Sub cmdCalculator_Click()
    Dim RetVal As Variant
    RetVal = Shell("Calc.Exe", 1)
End Sub


Private Sub cmdLookupCustomer_Click()
    If ofx_IsFormLoaded(frmLookupCustomer) Then
        frmLookupCustomer.SetFocus
        SendKeys "% R", True
        frmLookupCustomer.ZOrder
    Else
        Screen.MousePointer = vbHourglass
        frmLookupCustomer.Show
    End If
End Sub

Private Sub cmdLookupSKU_Click()
    Dim strRetVal As String
    
    Clipboard.Clear
    If ofx_IsFormLoaded(frmLookupPLU) Then _
        Unload frmLookupPLU
    Screen.MousePointer = vbHourglass
    frmLookupPLU.Show vbModal
    
    strRetVal = Clipboard.GetText
    strRetVal = Left(strRetVal, 10)
    If strRetVal = "" Or strRetVal = Null Then
    Else
        tdbgTxBody.Columns("SKU").Value = Clipboard.GetText
        Call FillPLU
    End If
End Sub

Private Sub cmdOrderDetails_Cont_Click()
    frmOrderDetails_Cont.Show vbModal
End Sub

Private Sub cmdOrderDetails_Frame_Click()
    frmOrderDetails_Frame.Show vbModal
End Sub

Private Sub cmdOrderDetails_Lens_Click()
    frmOrderDetails_Lens.Show vbModal
End Sub

Private Sub cmdPriceWizard_Click()
    frmPriceWizard.Show vbModal
End Sub


Private Sub cmdRemarks_Click()
    If txtCustomerName.Tag = "" Or txtCustomerName.Tag = Null Then
    Else
        frmOrderCustomerRemarks.Show vbModal
    End If
End Sub



Private Sub dbcPaymentMethods_Click(intArea As Integer)
    dbcPaymentMethods.Visible = False    ' Hide DBcombo
    If intArea = dbcAreaList Then
        tdbgTxTender.Columns(1).Text = dbcPaymentMethods.Text
        ' display row numbers for the first column.
        tdbgTxTender.Columns(0).Value = tdbgTxTender.row + 1    ' TxFooter_TD.MaxRow + 1
        ' Fill defaults
        Call FillTender
    End If
End Sub




Private Sub dbcTaxMethod_Click(intArea As Integer)
    dbcTaxMethod.Visible = False    ' Hide DBcombo

    If intArea = dbcAreaList Then
        tdbgTxBody.Columns("Tax").Text = dbcTaxMethod.BoundText
        tdbgTxBody.Update
    End If
End Sub


Private Sub Form_Activate()
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
    Call SetParameterValue
    mCurrentMode = mModeIdle
    Call SetMenuButton(mCurrentMode)
    Call SetProtectedArea(mCurrentMode)
    Call SetBlankForm
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub mskOrderNumber_GotFocus()
    Call AutoSelect(mskOrderNumber)
End Sub


Private Sub mskOrderNumber_LostFocus()
    Dim strTxNumber As String
    Dim blnFound As Boolean
    
    strTxNumber = ofx_CStr(mskOrderNumber.Text)
    If strTxNumber = "" Then Exit Sub
    
    ' If add new order
    ' make sure Order Number not used
    If mCurrentMode = mModeAdd Then
        strTxNumber = "SA" & strTxNumber
        blnFound = IsFound("TxHeader", "TxNumber", strTxNumber, True)
        If blnFound Then
            Beep
            MsgBox "Order Number is used." & Chr(13) & _
                   "Please enter a new Order Number"
            mskOrderNumber.SetFocus
        End If
    End If
End Sub


Private Sub tbrOrderEntry_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)
    Dim i, intResult As Integer
    
    ' Ignor Up clicks
    If Value = False Then Exit Sub
    
    
    With tbrOrderEntry
        ' Avoid operator using the accerator key for disabled buttons.
        ' If the Button pressed is disabled,
        ' raise the button and do nothing.
        If .Buttons(Btn).Enabled = False And Value = True Then
            .Buttons(Btn).Value = False
            Exit Sub
        End If
        
        ' The "exculsive" option of Sheriden ToolBar doesn't work here.
        ' Emulate exclusive function by raising all other buttons
        For i = 0 To (.ToolsetTools.Count - 3)
            If i <> Btn And .Buttons(i).Value Then
                .Buttons(i).Value = False
            End If
        Next i
    End With
    
    ' Button is Down after Click
    If Value Then
        Select Case ToolID
            Case "ID_Add"
                Call SetCurrentMode(mModeAdd)
                Call SetBlankForm
                ' Reset Controlling dates
                With calOrderedOn
                    .Date = Date
                    .MinDate = (Date - mDateAllowance)
                End With
                With calDeliverOn
                    .Date = Date
                    .MinDate = Date
                End With
            Case "ID_Lookup"
                intResult = DoLookup()
                Select Case intResult
                    Case vbOK
                        mCurrentMode = mModeLookup
                    Case vbCancel
                        tbrOrderEntry.Buttons(Btn).Value = False
                        mCurrentMode = mModeIdle
                End Select
            Case "ID_Change"
                Call SetCurrentMode(mModeChange)
            Case "ID_Save"
                Call SaveTender
                Call SetCurrentMode(mModeSave)
                'WA
                Select Case mLastMode
                    Case mModeVoid
                        intResult = DoRefund()
                        Select Case intResult
                            Case vbOK
                                Call SetCurrentMode(mModeIdle)
                                Call SetBlankForm
                            Case Else
                        End Select
                    Case Else
                        Call DoSave
                End Select
            Case "ID_Void"
                Call SetCurrentMode(mModeVoid)
                If Value Then intResult = DoVoid()
                Select Case intResult
                    Case vbCancel
                        Call SetCurrentMode(mModeIdle)
                        Call SetBlankForm
                End Select
            Case "ID_Bill"
                Call SetCurrentMode(mModeBill)
                Call DoBill
            Case "ID_Undo"
                Call SetCurrentMode(mModeIdle)
                Call SetBlankForm
            Case "ID_Print"
                Call SaveTender
                Call SetCurrentMode(mModePrint)
                intResult = DoPrint()
                Select Case intResult
                    Case vbOK
                        Call SetCurrentMode(mModeIdle)
                        Call SetBlankForm
                    Case vbCancel
                        Call SetCurrentMode(mLastMode)
                        tbrOrderEntry.Buttons(Btn).Value = False
                End Select
            Case "ID_Exit"
                Call ofx_CloseForm(frmSalesOrder)
                Exit Sub
        End Select
        '
    End If
    Call SetMenuButton(mCurrentMode)
    Call SetProtectedArea(mCurrentMode)
    Call SetEditArea(mCurrentMode)
    Call SetStartPoint(mCurrentMode)
    
End Sub


Private Sub tdbgTxBody_AfterColUpdate(ByVal ColIndex As Integer)
    Dim myCol As Columns
    Dim intQty As Integer
    Dim curUnitPrice, curMarkdown, curAmount As Currency

    Set myCol = tdbgTxBody.Columns
    
    ' Calculate the Amount if Qty, Unit Price, or Markdown is changed
    If myCol(ColIndex).Caption = "Qty" Or _
       myCol(ColIndex).Caption = "Unit Price" Or _
       myCol(ColIndex).Caption = "Markdown" Then
        intQty = ofx_CInt(myCol("Qty"))
        curUnitPrice = ofx_CCur(myCol("Unit Price"))
        curMarkdown = ofx_CCur(myCol("Markdown"))
        curAmount = intQty * (curUnitPrice - curMarkdown)
        curAmount = Format(curAmount, "####0.00")
        myCol("Amount") = curAmount
    End If
    
    ' If cashier punch in the exact charge,
    ' the computer would calc the markdown
    If myCol(ColIndex).Caption = "Amount" And _
       myCol(ColIndex).DataChanged Then
        intQty = ofx_CInt(myCol("Qty"))
        curAmount = ofx_CCur(myCol(ColIndex))
        curUnitPrice = ofx_CCur(myCol("Unit Price"))
        curMarkdown = (curUnitPrice - (curAmount / intQty))
        curMarkdown = Format(curMarkdown, "####0.00")
        myCol("Markdown") = curMarkdown
    End If
    
    tdbgTxBody.Update   ' Force update
End Sub

Private Sub tdbgTxBody_BeforeColEdit(ByVal ColIndex As Integer, ByVal KeyAscii As Integer, Cancel As Integer)
    ' If user is editing the 2nd column and
    ' the 1st column is blank than
    ' display row numbers for the first column.
    With tdbgTxBody
        If ColIndex = 1 And _
            .Columns(0) = "" Then
            .Columns(0).Value = .row + 1  'TxBody.MaxRow + 1
            If TxBody.MaxRow >= TxBody_MaxRow Then
                .Columns(0).Value = TxBody.MaxRow + 1
            End If
            Debug.Print "Line#=" & .Columns(0).Value & " | " & _
                        "Array Line#=" & TxBody.GridArray(0, TxBody.MaxRow - 1) & " | " & _
                        "Grid Row#=" & .row & " | " & _
                        "Array MaxRow=" & TxBody.MaxRow
        End If
    End With

    ' If Editing Tax column, Transfer Editing mode to Button_Click
    If tdbgTxBody.Columns(ColIndex).Caption = "Tax" Then
        Cancel = True                           ' Cancel built-in editing
        tdbgTxBody_ButtonClick (ColIndex)       ' Pass control to Button_Click
    End If
    
End Sub

Private Sub tdbgTxBody_BeforeColUpdate(ByVal ColIndex As Integer, OldValue As Variant, Cancel As Integer)
    Dim myCol As Columns
    Dim intQty As Integer
    Dim curUnitPrice, curMarkdown, curAmount As Currency
    
    Set myCol = tdbgTxBody.Columns
    
    ' Varify the SKU
    ' If valid, move to next cell; else remains on current cell
    If tdbgTxBody.Col = myCol("SKU").ColIndex And _
       myCol(ColIndex).Value <> "" Then
        If Not IsFound("Inventory", "SKU", myCol(ColIndex).Value, vbYes) Then
            Cancel = True
        Else
            Call FillPLU
        End If
    End If
    
    ' Varify the Qty
    If tdbgTxBody.Col = myCol("Qty").ColIndex Then
        intQty = ofx_CInt(myCol(ColIndex))
        If intQty < 0 Then
            ofx_DoMessageBox "You're not allowed to enter a negative Qty"
            Cancel = True
        End If
    End If
    
    ' Varify the Unit Price
    If tdbgTxBody.Col = myCol("Unit Price").ColIndex Then
        curUnitPrice = ofx_CCur(myCol(ColIndex))
        If curUnitPrice < 0 Then
            ofx_DoMessageBox "You're not allowed to enter a negative Unit Price"
            Cancel = True
        End If
    End If
    
    ' Varify the Markdown
    If tdbgTxBody.Col = myCol("Markdown").ColIndex Then
        curUnitPrice = ofx_CCur(myCol("Unit Price"))
        curMarkdown = ofx_CCur(myCol("Markdown"))
        If curMarkdown < 0 Or _
           curMarkdown > curUnitPrice Then
            ofx_DoMessageBox "Markdown should not negative nor greater than Unit Price"
            Cancel = True
        End If
    End If
    
End Sub


Private Sub tdbgTxBody_BeforeDelete(Cancel As Integer)
Exit Sub
    Dim i, j, intLastRow As Integer
    
    intLastRow = TxBody.MaxRow - 1
    
    Screen.MousePointer = vbHourglass
    For i = tdbgTxBody.row To (TxBody.MaxRow - 2)
        For j = 1 To (TxBody.MaxCol - 1)
            TxBody.GridArray(j, i) = TxBody.GridArray(j, i + 1)
        Next j
    Next i
    For j = 1 To (TxBody.MaxCol - 1)
        TxBody.GridArray(j, intLastRow) = ""
    Next j
    tdbgTxBody.ReBind
    Cancel = True
    Screen.MousePointer = vbDefault
End Sub

Private Sub tdbgTxBody_BeforeInsert(Cancel As Integer)

    ' When insert a new line to the grid,
    ' auto fill the line number
    ' and set the Prescription Check Box to False
    ' tdbgTxBody.Columns(0) = (TxBody.MaxRow + 1)
    
End Sub


' Activate the coresspond Dropdown Control
Private Sub tdbgTxBody_ButtonClick(ByVal ColIndex As Integer)
'Exit Sub
    Dim Co As column
    
    Set Co = tdbgTxBody.Columns(ColIndex)
    Select Case tdbgTxBody.Columns(ColIndex).Caption
        Case "Tax"                          ' Activate the Tax Dropdown
            dbcTaxMethod.Left = tdbgTxBody.Left + Co.Left + Co.Width    ' Position the DBcombo
            dbcTaxMethod.Top = tdbgTxBody.Top + tdbgTxBody.RowTop(tdbgTxBody.row)
            dbcTaxMethod.Visible = True
            dbcTaxMethod.ZOrder 0
            dbcTaxMethod.SetFocus           ' Pass current focus to DBcombo
            SendKeys "{F4}", True           ' Pulldown the DBcombo
    End Select
    
End Sub

Private Sub tdbgTxBody_ClassicAdd(NewRowBookmark As Variant, _
    ByVal Col As Integer, Value As Variant)
    ' ClassicAdd is fired when the user adds a new row
    ' of data through code or by typing in the AddNew row
    ' (the one with the asterisk in the record selector
    ' column.  It alerts your application that it must add
    ' a new row of data to its unbound dataset.  This event
    ' will NOT be fired if the grid's AllowAddNew property
    ' is set to False.
    
    ' Assume that a function StoreUserData(Bookmark, Col,
    ' Value) takes a row bookmark, a column index, and a
    ' variant with the appropriate data to be stored in an
    ' array or database.  The function returns True if the
    ' data is acceptable and can be stored, False otherwise.

    If IsNull(NewRowBookmark) Then
       ' First, get a bookmark for the new row.  Do this
       ' with a VB function, GetNewBookmark.  This
       ' function allocates a new row of data in the storage
       ' medium (array or database), and returns a variant
       ' containing a bookmark for the added row.
       NewRowBookmark = GetNewBookmark(TxBody)
    End If
    
    ' Now store the new value.
    If Not StoreUserData(NewRowBookmark, Col, Value, TxBody) Then
            ' Storage of the data has failed.  Delete the
            ' added row using a VB function, DeleteRow,
            ' which takes a bookmark as an argument.  Also,
            ' fail the update by setting NewRowBookmark to
            ' Null.
            NewRowBookmark = DeleteRow(NewRowBookmark, TxBody)
            NewRowBookmark = Null   'Tell the grid the
                                    ' update failed.
    End If

End Sub

Private Sub tdbgTxBody_ClassicDelete(Bookmark As Variant)
    ' ClassicDelete is fired when the user deletes an
    ' existing row in the Unbound grid.  This event
    ' alerts the user that the program must delete the
    ' row specified by the Bookmark parameter from the
    ' dataset.  Here, an auxiliary function (DeleteRow)
    ' is used to do this.

    If Not DeleteRow(Bookmark, TxBody) Then Bookmark = Null
    Call RowNumberReset(TxBody)
End Sub

Private Sub tdbgTxBody_ClassicRead(Bookmark As Variant, _
    ByVal Col As Integer, Value As Variant)
    ' ClassicRead is analogous to the Fetch event of the
    ' TrueGrid Pro VBX control.  When the grid needs data
    ' in DataMode 3, it fires a ClassicRead event for
    ' each visible cell on the grid to retrieve the data
    ' that will be shown there, so it fires on a
    ' cell-by-cell basis.  The cell that this event is
    ' firing for is specified by the Bookmark (which
    ' tells which row to fetch the data from) and the
    ' Col parameter (which gives the column index).  The
    ' only difference from the Fetch event of the VBX is
    ' that the row to fetch is specified by a Bookmark
    ' and not an integral row index.  Thus, you must
    ' determine which row in your data source the bookmark.
    ' GetUserData uses the IndexFromBookmark function to
    ' do that.
    
    ' Assume that a function GetUserData(Bookmark, Col,
    ' Value) takes a row bookmark, a column index, and
    ' a variant which will hold the appropriate data to
    ' be fetched from the array or database.  The function
    ' returns the fetched data in the Value parameter if
    ' the fetch is successful, otherwise, it returns Null.
    
    Value = GetUserData(Bookmark, Col, TxBody)

End Sub

Private Sub tdbgTxBody_ClassicWrite(Bookmark As Variant, _
    ByVal Col As Integer, Value As Variant)
    ' ClassicWrite is analogous to the Update event of
    ' the TrueGrid Pro VBX control.  When the user
    ' changes data in the grid and commits the change by
    ' moving off of the row in DataMode 3, the grid fires
    ' a ClassicRead event for each cell on that row.  This
    ' event is fired on a cell-by-cell basis.  The cell
    ' that this event is firing for is specified by the
    ' Bookmark (which tells which row the data to be
    ' stored is in) and the Col parameter (which gives
    ' the particular column index of this cell).  The
    ' only difference from the Update event of the VBX is
    ' that the row in which the data is to be stored is
    ' specified by a Bookmark and not an integral row
    ' index.  Thus, you must determine which row in your
    ' data source the bookmark refers to.  StoreUserData
    ' uses the IndexFromBookmark function to do that.
    
    ' Assume that a function StoreUserData(Bookmark, Col,
    ' Value) takes a row bookmark, a column index, and a
    ' variant data value and stores the contents of the
    ' specified cell to the array or database.  The function
    ' returns True if the Update is successful, otherwise,
    ' it returns False.

    If Not StoreUserData(Bookmark, Col, Value, TxBody) Then
        Bookmark = Null   ' Tell the grid the update failed.
    End If


End Sub

Private Sub tdbgTxBody_KeyPress(KeyAscii As Integer)
    Dim strDummy, strMessage As String
    
    With tdbgTxBody
        ' If current col is Line Number,
        ' alert user column is not editable
        If .Col = 0 Then
            If .Columns(.Col).Value = "" Then
                strMessage = "You don't need to fill the line number. " _
                           & "I'll take care of it."
                strDummy = MsgBox(strMessage, vbInformation)
            Else
                strMessage = "This column is locked. " _
                           & "You're not allowed to change it."
                strDummy = MsgBox(strMessage, vbInformation)
            End If
        End If
        '
        If .Columns(tdbgTxBody.Col).Caption = "Pre." Then
            '.Columns(.Col).Value = False
        End If
    End With
End Sub

Private Sub tdbgTxBody_LostFocus()
    If Not IsTableEmptyBody Then
        tdbgTxBody.Update
        Call FlushTxBody
        Call CalcTotals
        Call FillOrderTotals
    End If
End Sub

Private Sub tdbgTxBody_RowColChange(LastRow As Variant, ByVal LastCol As Integer)
    Dim strDummy, strMessage As String
    
    ' SKU column must be filled
    With tdbgTxBody
        If LastCol = .Columns("SKU").ColIndex Then
            If Not (IsNull(.Columns("SKU")) Or .Columns("SKU") = "") Then
                If Not FindPLU(.Columns("SKU")) Then
                    strMessage = "You must enter a valid SKU."
                    strDummy = MsgBox(strMessage, vbExclamation)
                    .Col = .Columns("SKU").ColIndex
                End If
            End If
        End If
    End With
    Call SetColFocus(tdbgTxBody, TxBody, LastRow, LastCol)
        
End Sub

Private Sub tdbgTxBody_UnboundGetRelativeBookmark(StartLocation As Variant, _
    ByVal OffSet As Long, NewLocation As Variant, ApproximatePosition As Long)
    ' TDBGrid1 calls this routine each time it needs to
    ' reposition itself.  StartLocation is a bookmark
    ' supplied by the grid to indicate the "current"
    ' position -- the row we are moving from.  Offset is
    ' the number of rows we must move from StartLocation
    ' in order to arrive at the desired destination row.
    ' A positive offset means the desired record is after
    ' the StartLocation, and a negative offset means the
    ' desired record is before StartLocation.

    ' If StartLocation is NULL, then we are positioning
    ' from either BOF or EOF.  Once we determine the
    ' correct index for StartLocation, we will simply add
    ' the offset to get the correct destination row.
    ' GetRelativeBookmark already does all of this, so we
    ' just call it here.
    NewLocation = GetRelativeBookmark(StartLocation, OffSet, TxBody)
    
    ' If we are on a valid data row (i.e., not at BOF or
    ' EOF), then set the ApproximatePosition (the ordinal
    ' row number) to improve scroll bar accuracy.  We can
    ' call IndexFromBookmark to do this.
    If Not IsNull(NewLocation) Then
       ApproximatePosition = IndexFromBookmark(NewLocation, 0, TxBody)
    End If

End Sub

' Fills the first column with the row number
Private Sub FillLineNumber(Caller As UnboundGrids, FirstDigit As Integer)

    Dim Index As Integer
    
    For Index = 0 To (Caller.MaxRow - 1)
        If FirstDigit > 0 Then
            Caller.GridArray(0, Index) = (FirstDigit + ((Index + 1) / 10))
        Else
            Caller.GridArray(0, Index) = (Index + 1)
        End If
    Next Index
    
End Sub

Private Sub tdbgTxTender_AfterColUpdate(ByVal ColIndex As Integer)
    Dim myCol As Columns
    
    Set myCol = tdbgTxTender.Columns
    
    ' If Tender is changed
    If myCol(ColIndex).Caption = "Tender" Then
'        myCol("Local Currency") = ofx_CCur(myCol("Tender")) * _
                                  ofx_CCur(myCol("Exchange Rate"))
'        Call CalcTender         ' Calculate all rows and update Deposit/Balance
    End If
End Sub

Private Sub tdbgTxTender_BeforeColEdit(ByVal ColIndex As Integer, ByVal KeyAscii As Integer, Cancel As Integer)
    ' If user is editing the 2nd column and
    ' the 1st column is blank than
    ' display row numbers for the first column.
    With tdbgTxTender
        If ColIndex = 1 And _
            .Columns(0) = "" Then
            .Columns(0).Value = .row + 1    ' TxFooter_TD.MaxRow + 1
        End If
    End With

    ' If Editing Tax column, Transfer Editing mode to Button_Click
    If tdbgTxTender.Columns(ColIndex).Caption = "Type" Then
        Cancel = True                           ' Cancel built-in editing
        tdbgTxTender_ButtonClick (ColIndex)       ' Pass control to Button_Click
    End If
    
End Sub

Private Sub tdbgTxTender_BeforeColUpdate(ByVal ColIndex As Integer, OldValue As Variant, Cancel As Integer)
    Dim myCol As Columns
    Dim curTender As Currency

    Set myCol = tdbgTxTender.Columns
    
    ' If in column Type:
    ' Varify the Tender Type
    ' If valid, move to next cell; else remains on current cell
    If tdbgTxTender.Col = myCol("Type").ColIndex And _
       myCol(ColIndex).Value <> "" Then
        If Not IsFound("PaymentMethods", "PaymentNameLong", myCol(ColIndex).Value, vbYes) Then
            Cancel = True
        Else
            Call FillTender
        End If
    End If
    
    ' Varify the Tender
    If tdbgTxTender.Col = myCol("Tender").ColIndex Then
        curTender = ofx_CCur(myCol(ColIndex))
        If curTender < 0 Then
            ofx_DoMessageBox "You're not allowed to enter a negative Tender"
            Cancel = True
        End If
    End If
    
End Sub

Private Sub tdbgTxTender_BeforeInsert(Cancel As Integer)

    ' When insert a new line to the grid,
    ' auto fill the line number
    ' tdbgTxTender.Columns(0) = (TxFooter_TD.MaxRow + 1)

End Sub


Private Sub tdbgTxTender_ButtonClick(ByVal ColIndex As Integer)

    ' Activate the Dropdown Control
    Dim Co As column
    Set Co = tdbgTxTender.Columns(ColIndex)
    dbcPaymentMethods.Left = tdbgTxTender.Left + fraTender.Left + _
                             Co.Left + Co.Width    ' Position the DBcombo
    dbcPaymentMethods.Top = tdbgTxTender.Top + fraTender.Top + _
                            tdbgTxTender.RowTop(tdbgTxTender.row)
    dbcPaymentMethods.Visible = True
    dbcPaymentMethods.SetFocus          ' Pass current focus to DBcombo
    SendKeys "{F4}", True               ' Pulldown the DBcombo
    dbcPaymentMethods.ZOrder

End Sub

Private Sub tdbgTxTender_ClassicAdd(NewRowBookmark As Variant, _
    ByVal Col As Integer, Value As Variant)
    ' ClassicAdd is fired when the user adds a new row
    ' of data through code or by typing in the AddNew row
    ' (the one with the asterisk in the record selector
    ' column.  It alerts your application that it must add
    ' a new row of data to its unbound dataset.  This event
    ' will NOT be fired if the grid's AllowAddNew property
    ' is set to False.
    
    ' Assume that a function StoreUserData(Bookmark, Col,
    ' Value) takes a row bookmark, a column index, and a
    ' variant with the appropriate data to be stored in an
    ' array or database.  The function returns True if the
    ' data is acceptable and can be stored, False otherwise.
        
    If IsNull(NewRowBookmark) Then
       ' First, get a bookmark for the new row.  Do this
       ' with a VB function, GetNewBookmark.  This
       ' function allocates a new row of data in the storage
       ' medium (array or database), and returns a variant
       ' containing a bookmark for the added row.
       NewRowBookmark = GetNewBookmark(TxFooter_TD)
    End If
    
    ' Now store the new value.
    If Not StoreUserData(NewRowBookmark, Col, Value, TxFooter_TD) Then
            ' Storage of the data has failed.  Delete the
            ' added row using a VB function, DeleteRow,
            ' which takes a bookmark as an argument.  Also,
            ' fail the update by setting NewRowBookmark to
            ' Null.
            NewRowBookmark = DeleteRow(NewRowBookmark, TxFooter_TD)
            NewRowBookmark = Null   'Tell the grid the
                                    ' update failed.
    End If

End Sub

Private Sub tdbgTxTender_ClassicDelete(Bookmark As Variant)
    ' ClassicDelete is fired when the user deletes an
    ' existing row in the Unbound grid.  This event
    ' alerts the user that the program must delete the
    ' row specified by the Bookmark parameter from the
    ' dataset.  Here, an auxiliary function (DeleteRow)
    ' is used to do this.

    If Not DeleteRow(Bookmark, TxFooter_TD) Then Bookmark = Null
    Call RowNumberReset(TxFooter_TD)
End Sub

Private Sub tdbgTxTender_ClassicRead(Bookmark As Variant, _
    ByVal Col As Integer, Value As Variant)
    ' ClassicRead is analogous to the Fetch event of the
    ' TrueGrid Pro VBX control.  When the grid needs data
    ' in DataMode 3, it fires a ClassicRead event for
    ' each visible cell on the grid to retrieve the data
    ' that will be shown there, so it fires on a
    ' cell-by-cell basis.  The cell that this event is
    ' firing for is specified by the Bookmark (which
    ' tells which row to fetch the data from) and the
    ' Col parameter (which gives the column index).  The
    ' only difference from the Fetch event of the VBX is
    ' that the row to fetch is specified by a Bookmark
    ' and not an integral row index.  Thus, you must
    ' determine which row in your data source the bookmark.
    ' GetUserData uses the IndexFromBookmark function to
    ' do that.
    
    ' Assume that a function GetUserData(Bookmark, Col,
    ' Value) takes a row bookmark, a column index, and
    ' a variant which will hold the appropriate data to
    ' be fetched from the array or database.  The function
    ' returns the fetched data in the Value parameter if
    ' the fetch is successful, otherwise, it returns Null.
    
    Value = GetUserData(Bookmark, Col, TxFooter_TD)

End Sub

Private Sub tdbgTxTender_ClassicWrite(Bookmark As Variant, _
    ByVal Col As Integer, Value As Variant)
    ' ClassicWrite is analogous to the Update event of
    ' the TrueGrid Pro VBX control.  When the user
    ' changes data in the grid and commits the change by
    ' moving off of the row in DataMode 3, the grid fires
    ' a ClassicRead event for each cell on that row.  This
    ' event is fired on a cell-by-cell basis.  The cell
    ' that this event is firing for is specified by the
    ' Bookmark (which tells which row the data to be
    ' stored is in) and the Col parameter (which gives
    ' the particular column index of this cell).  The
    ' only difference from the Update event of the VBX is
    ' that the row in which the data is to be stored is
    ' specified by a Bookmark and not an integral row
    ' index.  Thus, you must determine which row in your
    ' data source the bookmark refers to.  StoreUserData
    ' uses the IndexFromBookmark function to do that.
    
    ' Assume that a function StoreUserData(Bookmark, Col,
    ' Value) takes a row bookmark, a column index, and a
    ' variant data value and stores the contents of the
    ' specified cell to the array or database.  The function
    ' returns True if the Update is successful, otherwise,
    ' it returns False.

    If Not StoreUserData(Bookmark, Col, Value, TxFooter_TD) Then
        Bookmark = Null   ' Tell the grid the update failed.
    End If

End Sub

Private Sub tdbgTxTender_GotFocus()
    If Not IsTableEmptyBody Then
        Call CalcTotals
        Call FillOrderTotals
    End If
End Sub

Private Sub tdbgTxTender_KeyPress(KeyAscii As Integer)

    'alert user if a column is not editable
    If tdbgTxTender.Columns(tdbgTxTender.Col).Locked = True Then
        If tdbgTxTender.Columns(tdbgTxTender.Col).Value = "" Then
            ofx_DoMessageBox "You don't need to fill the line number. " _
                & "I'll take care of it"
        Else
            ofx_DoMessageBox "This column is locked. " _
                & "You're not allowed to change it"
        End If
    End If

End Sub

Private Sub tdbgTxTender_LostFocus()

    'You may want to write unsaved changes to the data source if the grid loses focus.
    'The changes will be written if you set the grid's Bookmark property.
'    tdbgTxTender.Bookmark = tdbgTxTender.Bookmark

End Sub

Private Sub tdbgTxTender_RowColChange(LastRow As Variant, ByVal LastCol As Integer)
    Dim strDummy, strMessage As String
    Dim curTender, curXchgRate, curLocalCurrency As Currency
    Dim myCol As Columns
    Dim intLastRow, intLastCol As Integer
    
    Set myCol = tdbgTxTender.Columns
    intLastRow = ofx_CInt(LastRow)
    intLastCol = ofx_CInt(LastCol)
    
    ' Type column must be filled
    With tdbgTxTender
        If LastCol = .Columns("Type").ColIndex Then
            If Not (IsNull(.Columns("Type")) Or .Columns("Type") = "") Then
                If Not FindTender(.Columns("Type")) Then
                    strMessage = "You must enter a valid Type."
                    strDummy = MsgBox(strMessage, vbExclamation)
                    .Col = .Columns("Type").ColIndex
                End If
            End If
        End If
    End With
    Call SetColFocus(tdbgTxTender, TxFooter_TD, LastRow, LastCol)
    
    ' If tab out of Tender,
    ' calculate the Deposit/Balance
    If intLastCol >= 0 And intLastCol < myCol.Count Then
        If myCol(LastCol).Caption = "Tender" Then
            curTender = ofx_CCur(myCol("Tender"))
            curXchgRate = ofx_CCur(myCol("Exchange Rate"))
            curLocalCurrency = curTender * curXchgRate
            myCol("Local Currency") = curLocalCurrency
            Call CalcTender
        End If
    End If
End Sub

Private Sub tdbgTxTender_UnboundGetRelativeBookmark(StartLocation As Variant, _
    ByVal OffSet As Long, _
    NewLocation As Variant, _
    ApproximatePosition As Long)
    ' TDBGrid1 calls this routine each time it needs to
    ' reposition itself.  StartLocation is a bookmark
    ' supplied by the grid to indicate the "current"
    ' position -- the row we are moving from.  Offset is
    ' the number of rows we must move from StartLocation
    ' in order to arrive at the desired destination row.
    ' A positive offset means the desired record is after
    ' the StartLocation, and a negative offset means the
    ' desired record is before StartLocation.

    ' If StartLocation is NULL, then we are positioning
    ' from either BOF or EOF.  Once we determine the
    ' correct index for StartLocation, we will simply add
    ' the offset to get the correct destination row.
    ' GetRelativeBookmark already does all of this, so we
    ' just call it here.
    NewLocation = GetRelativeBookmark(StartLocation, OffSet, TxFooter_TD)
    
    ' If we are on a valid data row (i.e., not at BOF or
    ' EOF), then set the ApproximatePosition (the ordinal
    ' row number) to improve scroll bar accuracy.  We can
    ' call IndexFromBookmark to do this.
    If Not IsNull(NewLocation) Then
       ApproximatePosition = IndexFromBookmark(NewLocation, 0, TxFooter_TD)
    End If

End Sub

Private Sub SetMenuButton(iMode As Integer)
    With tbrOrderEntry
    Select Case iMode
        Case mModeIdle
            .Buttons(mButtonIndex_Add).Enabled = True
            .Buttons(mButtonIndex_Lookup).Enabled = True
            .Buttons(mButtonIndex_Change).Enabled = False
            .Buttons(mButtonIndex_Save).Enabled = False
            .Buttons(mButtonIndex_Void).Enabled = False
            .Buttons(mButtonIndex_Bill).Enabled = False
            .Buttons(mButtonIndex_Undo).Enabled = False
            .Buttons(mButtonIndex_Print).Enabled = False
            .Buttons(mButtonIndex_Exit).Enabled = True
        Case mModeAdd
            .Buttons(mButtonIndex_Add).Enabled = False
            .Buttons(mButtonIndex_Lookup).Enabled = False
            .Buttons(mButtonIndex_Change).Enabled = False
            .Buttons(mButtonIndex_Save).Enabled = True
            .Buttons(mButtonIndex_Void).Enabled = False
            .Buttons(mButtonIndex_Bill).Enabled = False
            .Buttons(mButtonIndex_Undo).Enabled = True
            .Buttons(mButtonIndex_Print).Enabled = False
            .Buttons(mButtonIndex_Exit).Enabled = False
        Case mModeLookup
            Select Case mOrderStatus
                Case 3      ' Completed Order
                    .Buttons(mButtonIndex_Add).Enabled = False
                    .Buttons(mButtonIndex_Lookup).Enabled = False
                    .Buttons(mButtonIndex_Change).Enabled = False
                    .Buttons(mButtonIndex_Save).Enabled = False
                    .Buttons(mButtonIndex_Void).Enabled = True
                    .Buttons(mButtonIndex_Bill).Enabled = False
                    .Buttons(mButtonIndex_Undo).Enabled = True
                    .Buttons(mButtonIndex_Print).Enabled = True
                    .Buttons(mButtonIndex_Exit).Enabled = False
                Case 2      ' Cancelled Order
                    .Buttons(mButtonIndex_Add).Enabled = False
                    .Buttons(mButtonIndex_Lookup).Enabled = False
                    .Buttons(mButtonIndex_Change).Enabled = False
                    .Buttons(mButtonIndex_Save).Enabled = False
                    .Buttons(mButtonIndex_Void).Enabled = False
                    .Buttons(mButtonIndex_Bill).Enabled = False
                    .Buttons(mButtonIndex_Undo).Enabled = True
                    .Buttons(mButtonIndex_Print).Enabled = True
                    .Buttons(mButtonIndex_Exit).Enabled = False
                Case Else   ' Draft or Confirmed Order
                    .Buttons(mButtonIndex_Add).Enabled = False
                    .Buttons(mButtonIndex_Lookup).Enabled = False
                    .Buttons(mButtonIndex_Change).Enabled = True
                    .Buttons(mButtonIndex_Save).Enabled = False
                    .Buttons(mButtonIndex_Void).Enabled = True
                    .Buttons(mButtonIndex_Bill).Enabled = True
                    .Buttons(mButtonIndex_Undo).Enabled = True
                    .Buttons(mButtonIndex_Print).Enabled = True
                    .Buttons(mButtonIndex_Exit).Enabled = False
            End Select
        Case mModeChange
            .Buttons(mButtonIndex_Add).Enabled = False
            .Buttons(mButtonIndex_Lookup).Enabled = False
            .Buttons(mButtonIndex_Change).Enabled = False
            .Buttons(mButtonIndex_Save).Enabled = True
            .Buttons(mButtonIndex_Void).Enabled = False
            .Buttons(mButtonIndex_Bill).Enabled = False
            .Buttons(mButtonIndex_Undo).Enabled = True
            .Buttons(mButtonIndex_Print).Enabled = False
            .Buttons(mButtonIndex_Exit).Enabled = False
        Case mModeSave
            .Buttons(mButtonIndex_Add).Enabled = False
            .Buttons(mButtonIndex_Lookup).Enabled = False
            .Buttons(mButtonIndex_Change).Enabled = True
            .Buttons(mButtonIndex_Save).Enabled = False
            .Buttons(mButtonIndex_Void).Enabled = True
            .Buttons(mButtonIndex_Bill).Enabled = True
            .Buttons(mButtonIndex_Undo).Enabled = True
            .Buttons(mButtonIndex_Print).Enabled = True
            .Buttons(mButtonIndex_Exit).Enabled = False
        Case mModeVoid
            .Buttons(mButtonIndex_Add).Enabled = False
            .Buttons(mButtonIndex_Lookup).Enabled = False
            .Buttons(mButtonIndex_Change).Enabled = False
            .Buttons(mButtonIndex_Save).Enabled = True
            .Buttons(mButtonIndex_Void).Enabled = False
            .Buttons(mButtonIndex_Bill).Enabled = False
            .Buttons(mButtonIndex_Undo).Enabled = True
            .Buttons(mButtonIndex_Print).Enabled = False
            .Buttons(mButtonIndex_Exit).Enabled = False
        Case mModeBill
            .Buttons(mButtonIndex_Add).Enabled = False
            .Buttons(mButtonIndex_Lookup).Enabled = False
            .Buttons(mButtonIndex_Change).Enabled = False
            .Buttons(mButtonIndex_Save).Enabled = False
            .Buttons(mButtonIndex_Void).Enabled = False
            .Buttons(mButtonIndex_Bill).Enabled = False
            .Buttons(mButtonIndex_Undo).Enabled = True
            .Buttons(mButtonIndex_Print).Enabled = True
            .Buttons(mButtonIndex_Exit).Enabled = False
    End Select
    End With
End Sub

Private Sub SetProtectedArea(iMode As Integer)
    
    Select Case iMode
        Case mModeIdle
            fraHeaderR.Enabled = False
            fraHeaderC.Enabled = False
            fraHeaderL.Enabled = False
            fraOrderDetails.Enabled = False
            fraMiniTools.Enabled = False
            tdbgTxBody.Enabled = False
            tdbgTxBody.Splits(0).Locked = False
            tdbgTxBody.Splits(1).Locked = False
            fraTotal.Enabled = False
            fraTender.Enabled = False
        Case mModeAdd
            fraHeaderR.Enabled = True
            mskOrderNumber.Enabled = True
            fraHeaderC.Enabled = True
            calOrderedOn.Enabled = True
            fraHeaderL.Enabled = True
            fraOrderDetails.Enabled = True
            fraMiniTools.Enabled = True
            tdbgTxBody.Enabled = True
            fraTotal.Enabled = False
            fraTender.Enabled = True
        Case mModeLookup
            fraHeaderR.Enabled = False
            fraHeaderC.Enabled = False
            fraHeaderL.Enabled = False
            fraOrderDetails.Enabled = True
            fraMiniTools.Enabled = False
            tdbgTxBody.Enabled = True
            fraTotal.Enabled = False
            fraTender.Enabled = False
            Select Case mOrderStatus
                Case "2", "3"   ' Cancelled Order or Completed Order
                    tdbgTxBody.Splits(0).Locked = True
                    tdbgTxBody.Splits(1).Locked = True
                Case Else       ' Otherwise
                    tdbgTxBody.Splits(0).Locked = False
                    tdbgTxBody.Splits(1).Locked = False
            End Select
        Case mModeChange
            fraHeaderR.Enabled = True
            mskOrderNumber.Enabled = False
            fraHeaderC.Enabled = True
            calOrderedOn.Enabled = False
            fraHeaderL.Enabled = True
            fraOrderDetails.Enabled = True
            fraMiniTools.Enabled = True
            tdbgTxBody.Enabled = True
            fraTotal.Enabled = False
            fraTender.Enabled = False
        Case mModeSave
            fraHeaderR.Enabled = False
            fraHeaderC.Enabled = False
            fraHeaderL.Enabled = False
            fraOrderDetails.Enabled = False
            fraMiniTools.Enabled = False
            tdbgTxBody.Enabled = False
            fraTotal.Enabled = False
            fraTender.Enabled = False
        Case mModeVoid
            fraHeaderR.Enabled = False
            fraHeaderC.Enabled = False
            fraHeaderL.Enabled = False
            fraOrderDetails.Enabled = False
            fraMiniTools.Enabled = False
            tdbgTxBody.Enabled = True
            fraTotal.Enabled = False
            fraTender.Enabled = True
        Case mModeBill
            fraHeaderR.Enabled = False
            fraHeaderC.Enabled = True
            fraHeaderL.Enabled = False
            fraOrderDetails.Enabled = True
            fraMiniTools.Enabled = True
            tdbgTxBody.Enabled = True
            fraTotal.Enabled = False
            fraTender.Enabled = True
    End Select

End Sub

' Initialize Parameter Values, such as Grid maxrow & maxcol
Private Sub SetParameterValue()
    
    TxHeader_SP.MaxRow = TxHeader_SP_MaxRow
    TxHeader_SP.MaxCol = TxHeader_SP_MaxCol
    '
    TxBody.MaxCol = TxBody_MaxCol
    TxBody.MaxRow = TxBody_MaxRow
    '
    TxFooter_TD.MaxCol = TxFooter_TD_MaxCol
    TxFooter_TD.MaxRow = TxFooter_TD_MaxRow
    '
End Sub

Private Sub SetBlankForm()
    On Error GoTo SetBlankForm_Err
    Dim strTemp As String
    Dim i As Integer
    
    For i = 0 To (Me.Count - 1)
        If TypeOf Me.Controls(i) Is CheckBox Then
            Me.Controls(i).Value = 0    ' unchecked
        End If
        If TypeOf Me.Controls(i) Is MaskEdBox Then
            ' For a MaskEdBox with Mask,
            ' clearing it needs to clear the MaskEdBox.Mask first
            Me.Controls(i).Text = ""    ' empty
        End If
        If TypeOf Me.Controls(i) Is TextBox Then
            Me.Controls(i).Text = ""    ' empty
        End If
    Next i
    
    Call UnboundGrids_Initialize(TxHeader_SP)
    Call UnboundGrids_Initialize(TxBody)
    Call UnboundGrids_Initialize(TxFooter_TD)
'    TxBody = DefaultTxBody
    tdbgTxBody.ReBind
    tdbgTxTender.ReBind
    
SetBlankForm_Exit:                                ' SDVB autocode
    On Error Resume Next                          ' SDVB autocode
    Exit Sub                                      ' SDVB autocode
SetBlankForm_Err:                                 ' SDVB autocode
    Call ofx_GenericError("SetBlankForm()", Err)  ' SDVB autocode
    Resume SetBlankForm_Exit
End Sub

Private Function IsNoSKU() As Boolean

    If tdbgTxBody.Columns("SKU") = "" Or tdbgTxBody.Columns("SKU") = Null Then
        IsNoSKU = True
    Else
        IsNoSKU = False
    End If

End Function



' Works for TxBody only
' Move the active cell to row 0, column 1
Private Sub SetTxBodyHome()
    tdbgTxBody.Split = 0
    tdbgTxBody.row = 0
    tdbgTxBody.Col = 0
    SendKeys "{RIGHT}", True
End Sub


Private Sub SetStartPoint(iMode As Integer)
    
    Select Case iMode
        Case mModeIdle
            tbrOrderEntry.SetFocus      ' Task Bar
        Case mModeAdd
            mskOrderNumber.SetFocus     ' Order Number
        Case mModeLookup
        Case mModeChange
        Case mModeSave
        Case mModeVoid
        Case mModeBill
    End Select

End Sub

' Loop thro TxBodyP1~6
' Calc values for OrderTotal
Private Sub CalcTotals()
    Dim intQty As Integer
    
    Call CalcTotals_Clear
    intQty = ofx_CInt(TxBody.GridArray(ColIndexQty, 0))
    If intQty <> 0 Then Call CalcTotals_Each(TxBody)
End Sub

Private Sub CalcTotals_Clear()
    OrderTotal.Cost = 0
    OrderTotal.Sale = 0
    OrderTotal.GST = 0
    OrderTotal.PST = 0
    OrderTotal.Tax = 0
    OrderTotal.Gross = 0
    OrderTotal.Qty = 0
End Sub

Private Sub CalcTotals_Each(EachPage As UnboundGrids)
    Dim i As Integer
    Dim strTax As String
    Dim intQty As Integer
    Dim curUnitPrice, curMarkdown, curAmount As Currency
    Dim curGST, curPST, curTax As Currency
    Dim curSoldPrice, curCost As Currency
    Dim strSKU, strSQL As String
    Dim myDB As Database
    Dim myRS, myRSPref As Recordset
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set myRS = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)    ' Open table read only
    Set myRSPref = myDB.OpenRecordset("Preference", dbOpenDynaset, dbReadOnly)    ' Open table read only
    
    For i = 0 To (EachPage.MaxRow - 1)
        intQty = ofx_CInt(EachPage.GridArray(ColIndexQty, i))
        If intQty <> 0 Then
        strSKU = ofx_CStr(EachPage.GridArray(ColIndexSKU, i))
        strTax = ofx_CStr(EachPage.GridArray(ColIndexTax, i))
        curUnitPrice = ofx_CCur(EachPage.GridArray(ColIndexUnitPrice, i))
        curMarkdown = ofx_CCur(EachPage.GridArray(ColIndexMarkdown, i))
        curAmount = ofx_CCur(EachPage.GridArray(ColIndexAmount, i))
        curSoldPrice = curUnitPrice - curMarkdown
        
        curCost = 0
        strSQL = "SKU = '" & strSKU & "'"
            With myRS
                .FindFirst strSQL
                If Not .NoMatch Then
                    curCost = ofx_CCur(Format((intQty * !AverageCost), "####0.00"))
                End If
            End With
        
        With myRSPref
            .MoveFirst
            Select Case strTax
                Case "N"    ' No Tax
                    curGST = 0
                    curPST = 0
                Case "B"    ' Both GST & PST
                    curGST = ofx_CCur(Format((curAmount * !TaxARate / 100), "####0.00"))
                    curPST = ofx_CCur(Format((curAmount * !TaxBRate / 100), "####0.00"))
                Case "G"    ' GST only
                    curGST = ofx_CCur(Format((curAmount * !TaxARate / 100), "####0.00"))
                    curPST = 0
                Case "P"    ' PST only
                    curGST = 0
                    curPST = ofx_CCur(Format((curAmount * !TaxBRate / 100), "####0.00"))
                Case "g"    ' GST Included
                    curGST = ofx_CCur(Format((curAmount * 100 / (100 + !TaxARate)), "####0.00"))
                    curGST = curAmount - curGST
                    curPST = 0
                Case "p"    ' PST on GST
                    curGST = ofx_CCur(Format((curAmount * !TaxARate / 100), "####0.00"))
                    curPST = ofx_CCur(Format(((curAmount + curGST) * !TaxBRate / 100), "####0.00"))
                Case Else   ' Null
                    curGST = 0
                    curPST = 0
            End Select
        End With
        curTax = curGST + curPST
        OrderTotal.Cost = OrderTotal.Cost + curCost
        OrderTotal.Sale = OrderTotal.Sale + curAmount
        OrderTotal.GST = OrderTotal.GST + curGST
        OrderTotal.PST = OrderTotal.PST + curPST
        OrderTotal.Tax = OrderTotal.Tax + curTax
        OrderTotal.Gross = OrderTotal.Gross + curAmount + curTax
        OrderTotal.Qty = OrderTotal.Qty + intQty
        End If
    Next i

    myRS.Close
    myRSPref.Close
    myDB.Close
End Sub

' Write the current editing page
Private Sub FlushTxBody()
    Dim i As Integer
'TxBodyP1 = TxBody
Exit Sub
'    For i = 0 To (tbrOrderEntry.ToolsetTools.Count - 1)
'        If tbrOrderEntry.Buttons(i).Value Then
'            TxBodyP1 = TxBody
'        End If
'    Next i
End Sub

' Use by tdbgTxBody only
' Find the SKU and fill Qty, UnitPrice, Markdown, Amount
Private Sub FillPLU()
    Dim myCol As Columns
    Dim strSQL As String

    Set myCol = tdbgTxBody.Columns
    
    ' Find the SKU for this line
    ' If not found then terminate sub
    If Not FindPLU(myCol("SKU")) Then Exit Sub
    
    ' Is onhand qty enough for this sale when bill?
    With dtcPLU.Recordset
        If mCurrentMode = mModeBill Then
            If !QtyTotalOnhand < 1 Then
                Call WarnMsg_QtyEmpty(myCol("SKU"))
            End If
        End If
    End With
    
    ' Fill the PLU for this line
    With dtcPLU.Recordset
        myCol("Supplier") = !SupplierName
        myCol("Brand") = !BrandDescription
        myCol("Model/Style") = ofx_CStr(!Model)
        myCol("OH") = ofx_CStr(!QtyTotalOnhand)
        myCol("Material") = ofx_CStr(!MaterialDescription)
        myCol("Color") = ofx_CStr(!Color)
        myCol("Size") = ofx_CStr(!Size)
        myCol("Sphere") = ofx_CSng(!Sphere)
        myCol("Cylinder") = ofx_CSng(!Cylinder)
        myCol("Base Curve") = ofx_CSng(!BaseCurve)
        myCol("Tax") = !TaxMethod
        myCol("Qty") = 1
        myCol("Unit Price") = !RetailPrice
        myCol("Markdown") = !RetailMarkdownAmt
        myCol("Amount") = myCol("Unit Price") - myCol("Markdown")
    End With
End Sub

' Works with all row of Tender
' Calculate the Total Tender and fills the Deposit / Balance
Private Sub CalcTender_All()
    Dim myCol As Columns
    Dim i As Integer
    Dim curTender, curXchgRate, curLocalCurrency As Currency
    Dim curGrossSale, curDeposit, curBalance, curChange As Currency
    
    Set myCol = tdbgTxTender.Columns
    curGrossSale = ofx_CCur(mskGrossSale)
    
    ' Clear fields
    Select Case mCurrentMode
        Case mModeBill
            curDeposit = ofx_CCur(mskDeposit)
            curBalance = 0
        Case Else
            curDeposit = 0
            curBalance = 0
    End Select
    
    ' Loop thro' the Tender input grid
    For i = 0 To (TxFooter_TD.MaxRow - 1)
        tdbgTxTender.row = i
        curTender = ofx_CCur(myCol("Tender"))
        curXchgRate = ofx_CCur(myCol("Exchange Rate"))
        curLocalCurrency = curTender * curXchgRate
        curLocalCurrency = Format(curLocalCurrency, "####0.00")
        Select Case mCurrentMode
            Case mModeBill
                curBalance = curBalance + curLocalCurrency
            Case mModeVoid
                Select Case mOrderStatus
                    Case 1      ' Confirmed Order
                        curDeposit = curDeposit + curLocalCurrency
                    Case 3      ' Completed Order
                        curBalance = curBalance + curLocalCurrency
                End Select
            Case Else
                curDeposit = curDeposit + curLocalCurrency
        End Select
    Next i
    
    ' Any change?
    Select Case mCurrentMode
        Case mModeBill
            curChange = curBalance + curDeposit - curGrossSale
        Case mModeVoid
            ' Do nothing
        Case Else
            curChange = curDeposit - curGrossSale
    End Select
    If curChange < 0 Then
        curChange = 0
    End If

    ' Adjust Deposit/Balance
    Select Case mCurrentMode
        Case mModeBill
            If curBalance > (curGrossSale - curDeposit) Then
                curBalance = 0
            Else
                curBalance = curGrossSale - curDeposit
            End If
        Case mModeVoid
            ' Do nothing
        Case Else
            If curDeposit > curGrossSale Then
                curDeposit = curGrossSale
                curBalance = 0
            Else
                curBalance = curGrossSale - curDeposit
            End If
    End Select
    
    ' Show Totals
    Select Case mCurrentMode
        Case mModeBill
'            mskDeposit = curDeposit
'            mskBalance = curBalance
            mskChange = curChange
        Case Else
            mskDeposit = curDeposit
            mskBalance = curBalance
            mskChange = curChange
    End Select
End Sub

Private Sub FillTender()
    Dim myCol As Columns
    Dim strSQL As String

    Set myCol = tdbgTxTender.Columns
    
    ' Find the Tender Type for this line
    ' If not found then terminate sub
    If Not FindTender(myCol("Type")) Then Exit Sub
    
    ' Fill the PLU for this line
    myCol("Tender") = 0
    myCol("Exchange Rate") = dtcPaymentMethods.Recordset!ExchangeRate
    myCol("Local Currency") = 0
End Sub

Private Sub SetTxTenderColFocus(LastRow As Variant, ByVal LastCol As Integer)
    Dim blnForward As Boolean
    Dim intRow, intCol As Integer
    Dim intOldXY, intNewXY As Integer
    intRow = tdbgTxTender.row
    intCol = tdbgTxTender.Col
    
    ' Determine the direction of movement
    intOldXY = ofx_CInt(LastRow) * TxFooter_TD.MaxCol + LastCol
    intNewXY = intRow * TxFooter_TD.MaxCol + intCol
    If intNewXY > intOldXY Then
        blnForward = True
    Else
        blnForward = False
    End If
    
    ' If within X-Y Area, skip locked columns
    If (intRow >= 0 And intRow < TxFooter_TD.MaxRow) And _
       (intCol >= 0 And intCol < TxFooter_TD.MaxCol) Then
        If tdbgTxTender.Columns(intCol).Locked = True Then
            If blnForward Then
                SendKeys "{RIGHT}", True
            Else
                SendKeys "{LEFT}", True
            End If
        End If
    End If
End Sub

' Works with current row only
' Use the Tender to calculate the Local Currency
Private Sub CalcTender_Each()
    Dim myCol As Columns
    Dim curTender, curXchgRate, curLocalCurrency As Currency
    
    Set myCol = tdbgTxTender.Columns
    
    curTender = ofx_CCur(myCol("Tender"))
    curXchgRate = ofx_CCur(myCol("Exchange Rate"))
    curLocalCurrency = ofx_CCur(Format((curTender * curXchgRate), "####0.00"))
    
    myCol("Local Currency") = curLocalCurrency
End Sub

Private Sub CalcTender()
    Call CalcTender_Each
'    Call CalcTender_All
    Call CalcTender_Total
    Call CalcChange
    Call CalcThisPaid
End Sub

' Called by Add or Change
Private Sub SaveOrder()
    Screen.MousePointer = vbHourglass
    
    mTxNumber = "SA" & ofx_CStr(mskOrderNumber.Text)
    Select Case mLastMode
        Case mModeAdd
            mControlNumber = GetNextControlNumber
            mOrderStatus = 1
        Case mModeChange
            mControlNumber = dtcTxHeader.Recordset!ControlNumber
            mOrderStatus = 3
            If Not IsTableEmptyBody Then
                tdbgTxBody.Update
                Call CalcTotals
                Call FillOrderTotals
            End If
            Call DeleteTxDetails(mTxNumber)
    End Select
    
    Call Save_TxHeader(mTxNumber)
    Call Save_TxSalesPerson(mTxNumber)
    Call Save_TxSOrderExtra(mTxNumber)
    Call Save_TxDetails(mTxNumber)
    Select Case mLastMode
        Case mModeAdd
            Call Save_TxPayment(mTxNumber)              ' Update Tender
            Call OLTP_PoS_PaymentSummary(mTxNumber)     ' Update Payment Summary
            Call OLTP_PoS_Inventory(mTxNumber)          ' Update SO Qty
        Case mModeChange
    End Select
    Screen.MousePointer = vbDefault
End Sub






Private Sub LookupOrder(MyTxNumber As String)
    Call LookupOrder_TxHeader(MyTxNumber)
    Call LookupOrder_TxExtra(MyTxNumber)
    Call LookupOrder_TxDetails(MyTxNumber)
    Call LookupOrder_TxSalesPerson(MyTxNumber)
    Call LookupOrder_TxPayment(MyTxNumber)
    
    ' Re-calculate Totals but don't FillOrderTotals
    Call CalcTotals
End Sub


Private Sub LookupOrder_TxHeader(MyTxNumber As String)
    If Not FindTxHeader(MyTxNumber) Then
        Exit Sub
    End If
    With dtcTxHeader.Recordset
        mskOrderNumber.Text = Mid(MyTxNumber, 3)    ' Take away prefix
        calOrderedOn.Text = Format(!DateOfEntry, "MM/DD/YYYY")
        calDeliverOn.Text = Format(!SecondDate, "MM/DD/YYYY")
        txtParticular = ofx_CStr(!Particulars)
        txtRefNumber.Text = !RefNumber
        mskNetSale.Text = !TotalSale
        mskTax.Text = (!TaxA + !TaxB)
        mskGrossSale.Text = !GrossSale
        mskDeposit.Text = !ThisPaid
        mskBalance.Text = !GrossSale - !ThisPaid
        txtCustomerName.Text = dtcTxHeader.Recordset!FullName
        txtCustomerName.Tag = dtcTxHeader.Recordset!CustomerID
    End With
End Sub

Private Sub LookupOrder_TxDetails(MyTxNumber As String)
    Dim strSQL, strSKU As String
    Dim i, intRow As Integer
    
    If Not FindTxDetails(MyTxNumber) Then Exit Sub    ' Terminate if no TxDetails found
    
    With dtcTxDetails.Recordset
        If Not .BOF And Not .EOF Then
            ' 20030725 Resize the udbg to hold all the data
            .MoveLast
'            TxBody.MaxRow = .RecordCount
'            ReDim TxBody.GridArray(0 To TxBody_MaxCol, .RecordCount - 1)
            .MoveFirst
            Call UnboundGrids_Initialize(TxBody)
            Do While Not .EOF
'                strSKU = ofx_CStr(!SKU)
'                FindPLU (strSKU)
                intRow = CInt(!RowNo) - 1               ' 2008.12.20 paulus: changed from Int to CInt
                If FindPLU(!SKU) Then
                    With dtcPLU.Recordset
                        TxBody.GridArray(ColIndexSKU, intRow) = !SKU
                        TxBody.GridArray(ColIndexSupplier, intRow) = !SupplierName
                        TxBody.GridArray(ColIndexBrand, intRow) = !BrandDescription
                        TxBody.GridArray(ColIndexModel, intRow) = !Model
                        TxBody.GridArray(ColIndexOnhand, intRow) = !QtyTotalOnhand
                        TxBody.GridArray(ColIndexMaterial, intRow) = !MaterialDescription
                        TxBody.GridArray(ColIndexColor, intRow) = !Color
                        TxBody.GridArray(ColIndexSize, intRow) = !Size
                        TxBody.GridArray(ColIndexSphere, intRow) = !Sphere
                        TxBody.GridArray(ColIndexCylinder, intRow) = !Cylinder
                        TxBody.GridArray(ColIndexBaseCurve, intRow) = !BaseCurve
                    End With
                End If
                TxBody.GridArray(ColIndexTax, intRow) = !TaxCode
                TxBody.GridArray(ColIndexQty, intRow) = !Qty
                TxBody.GridArray(ColIndexUnitPrice, intRow) = !UnitAmount
                TxBody.GridArray(ColIndexMarkdown, intRow) = !MarkDownAmount
                TxBody.GridArray(ColIndexAmount, intRow) = !Amount
                Call GetNewBookmark(TxBody)
                .MoveNext
            Loop
        End If
    End With
    Call RowNumberReset(TxBody)
    tdbgTxBody.ApproxCount = TxBody.MaxRow
    tdbgTxBody.ReBind
    tdbgTxBody.MoveLast
    tdbgTxBody.MoveFirst
End Sub

Private Sub LookupOrder_TxSalesPerson(MyTxNumber As String)
    Dim strSQL As String
    
    strSQL = "SELECT * FROM qryTxSalesPerson " & _
             "WHERE TxNumber = '" & MyTxNumber & "'"
    
    dtcTxSalesPerson.RecordSource = strSQL
    dtcTxSalesPerson.Refresh
    If IsTableEmpty(dtcTxSalesPerson.Recordset) Then Exit Sub
    
    With dtcTxSalesPerson.Recordset
        dbcStaff.Text = !StaffFullName
    End With
End Sub

Private Sub LookupOrder_TxPayment(MyTxNumber As String)
    Dim strSQL, strSKU As String
    Dim i, intPage As Integer
    
    strSQL = "SELECT * FROM qryTxPayment " & _
             "WHERE TxNumber = '" & MyTxNumber & "' " & _
             "ORDER BY PaymentLineNo"
    dtcQryTxPayment.RecordSource = strSQL
    dtcQryTxPayment.Refresh
    If IsTableEmpty(dtcQryTxPayment.Recordset) Then Exit Sub
    i = 0
    
    With dtcQryTxPayment.Recordset
        If Not .EOF And Not .BOF Then
            ' 20030725 Resize the udbg to hold all the data
            .MoveLast
'            TxFooter_TD.MaxRow = .RecordCount
'            ReDim TxFooter_TD.GridArray(0 To TxFooter_TD_MaxCol, .RecordCount - 1)
            Call UnboundGrids_Initialize(TxFooter_TD)
            .MoveFirst
            Do While Not .EOF
                If !AmountTender > 0 Then
                    TxFooter_TD.GridArray(0, i) = !PaymentLineNo
                    TxFooter_TD.GridArray(1, i) = !PaymentNameLong
                    TxFooter_TD.GridArray(2, i) = !CardNumber
                    TxFooter_TD.GridArray(3, i) = !AmountTender
                    TxFooter_TD.GridArray(4, i) = !ExchangeRate
                    TxFooter_TD.GridArray(5, i) = !EqAmount
                    TxFooter_TD.GridArray(6, i) = !AuthorizationCode
                End If
                i = i + 1
                Call GetNewBookmark(TxFooter_TD)
                .MoveNext
            Loop
        End If
    End With
'    tdbgTxTender.ReBind
    Call RowNumberReset(TxFooter_TD)
    tdbgTxTender.ApproxCount = TxFooter_TD.MaxRow
    tdbgTxTender.ReBind
    tdbgTxTender.MoveLast
    tdbgTxTender.MoveFirst
End Sub


Private Sub LookupOrder_TxExtra(MyTxNumber As String)
    Dim strSQL As String
    
    strSQL = "SELECT * FROM TxSOrderExtra " & _
             "WHERE TxNumber = '" & MyTxNumber & "'"
    dtcTxSOrderExtra.RecordSource = strSQL
    dtcTxSOrderExtra.Refresh
    If IsTableEmpty(dtcTxSOrderExtra.Recordset) Then Exit Sub
    With dtcTxSOrderExtra.Recordset
        If !Redo Then chkRedo.Value = 1
        If !Warranty Then chkWarranty.Value = 1
        If !Mail Then chkMail.Value = 1
        If !Msd Then chkMsd.Value = 1
    End With
End Sub


Private Sub LookupOrder_TxDetailsPx(ByRef myTxBody As UnboundGrids)
    Dim strSQL, strSKU As String
    Dim sngRowNo As Single
    Dim intRow, intCol As Integer
    
    With dtcTxDetails.Recordset
        sngRowNo = !RowNo
'        intRow = (((sngRowNo * 10) - (Int(sngRowNo) * 10)) - 1)
        intRow = (sngRowNo - 1)
        strSKU = ofx_CStr(!SKU)
        If FindPLU(!SKU) Then
            With dtcPLU.Recordset
                myTxBody.GridArray(ColIndexSKU, intRow) = !SKU
                myTxBody.GridArray(ColIndexSupplier, intRow) = !SupplierName
                myTxBody.GridArray(ColIndexBrand, intRow) = !BrandDescription
                myTxBody.GridArray(ColIndexModel, intRow) = !Model
                myTxBody.GridArray(ColIndexOnhand, intRow) = !QtyTotalOnhand
                myTxBody.GridArray(ColIndexMaterial, intRow) = !MaterialDescription
                myTxBody.GridArray(ColIndexColor, intRow) = !Color
                myTxBody.GridArray(ColIndexSize, intRow) = !Size
                myTxBody.GridArray(ColIndexSphere, intRow) = !Sphere
                myTxBody.GridArray(ColIndexCylinder, intRow) = !Cylinder
                myTxBody.GridArray(ColIndexBaseCurve, intRow) = !BaseCurve
            End With
        End If
        myTxBody.GridArray(ColIndexTax, intRow) = !TaxCode
        myTxBody.GridArray(ColIndexQty, intRow) = !Qty
        myTxBody.GridArray(ColIndexUnitPrice, intRow) = !UnitAmount
        myTxBody.GridArray(ColIndexMarkdown, intRow) = !MarkDownAmount
        myTxBody.GridArray(ColIndexAmount, intRow) = !Amount
    End With
End Sub

Private Function DoPrint() As Integer
    On Error GoTo DoPrint_Err
    Dim intResult, intLastChance As Integer
    
    Select Case mLastMode
        Case mModeBill         ' Invoice
            DoPrint = DoPrint_Bill
        Case mModeVoid         ' Refund
            DoPrint = DoPrint_Void
        Case Else
            RptTxNumberFrom = "SA" & ofx_CStr(mskOrderNumber.Text)
            Call PrintOrder(1, 0)
            DoPrint = vbOK
    End Select
    
DoPrint_Exit:                                ' SDVB autocode
    On Error Resume Next                     ' SDVB autocode
    Exit Function                            ' SDVB autocode
DoPrint_Err:                                 ' SDVB autocode
    Call ofx_GenericError("DoPrint()", Err)  ' SDVB autocode
    Resume DoPrint_Exit
End Function

Private Function DoVoid() As Integer
    On Error GoTo DoVoid_Err
    Call ofx_CloseForm(frmVoidRefundDate)
    Screen.MousePointer = vbHourglass
    frmVoidRefundDate.Show vbModal
    
    If pyVoidRefundDate = #1/1/1900# Then
        DoVoid = vbCancel
        Exit Function
    Else
        DoVoid = vbOK
        mVoidOn = Format(pyVoidRefundDate, "mm/dd/yyyy")
    End If

'    Dim intLastChance, Result As Integer
'  Dim strInputDate, strTxNumber, strSQL As String
   
    'Do While strInputDate = ""
'       strInputDate = InputBox("Please enter the date Void On (MM/DD/YYYY)", _
                            "Void Sales Order")
    'Loop
    
'   If strInputDate = "" Then
'       DoVoid = vbCancel
'       Exit Function
'   End If
    
'   DoVoid = vbOK
'   mVoidOn = Format(strInputDate, "mm/dd/yyyy")
    
    ' Don't clear. Enforce the user to input a valid TxPayment
    ' Clear the Tender Grid for input
'    Call UnboundGrids_Initialize(TxFooter_TD)
'    tdbgTxTender.ReBind
    
    Select Case mOrderStatus
        Case 1          ' Confirmed Order
'            mskBalance = ofx_CCur(mskDeposit)
'            mskDeposit = 0
        Case 3          ' Completed Order
        'WA
        MsgBox "Make sure that Refund Amount equal Gross Sale."
'            mskBalance = ofx_CCur(mskGrossSale)
'            mskDeposit = 0
    End Select
    
DoVoid_Exit:                                ' SDVB autocode
    On Error Resume Next                    ' SDVB autocode
    Exit Function                           ' SDVB autocode
DoVoid_Err:                                 ' SDVB autocode
    Call ofx_GenericError("DoVoid()", Err)  ' SDVB autocode
    Resume DoVoid_Exit
End Function



Private Sub FillOrderTotals()
    mskNetSale = OrderTotal.Sale
    mskTax = OrderTotal.Tax
    mskGrossSale = OrderTotal.Gross
    mskBalance = OrderTotal.Gross - ofx_CCur(mskDeposit)
End Sub

Private Function SaveInvoice() As Integer
    Dim strSQL As String
    Dim myRS As Recordset
    If Not IsValidInvoice Then
        SaveInvoice = vbCancel
        Exit Function
    End If

    mControlNumber = GetNextControlNumber
    mTxNumber = GetNextTxNumber("RC")
    mOrderNumber = "SA" & ofx_CStr(mskOrderNumber)
    
    Call Save_TxHeader(mTxNumber)
    Call Save_TxSalesPerson(mTxNumber)
    Call Save_TxSOrderExtra(mTxNumber)
    Call Save_TxDetails(mTxNumber)
    Call Save_TxPayment(mTxNumber)
    
    ' Mark the status of original invoice as Completed
    strSQL = "TxNumber = '" & mOrderNumber & "'"
    With dtcTxHeader.Recordset
        .FindFirst strSQL
        If Not .NoMatch Then
            .Edit
            !RefNumber = mTxNumber          ' Requested by William Au
            !SecondDate = calDeliverOn.Text ' Requested by Sunny Lai
            !Status = 3
            .Update
        End If
    End With
    
    Call OLTP_PoS(mTxNumber)    ' Posting
    SaveInvoice = vbOK
End Function




Private Function IsValidInvoice() As Boolean
    Dim blnRetVal As Boolean
    
'    If blnRetVal Then blnRetVal = IsValidInvoice_Paid
    blnRetVal = IsValidInvoice_Paid
    IsValidInvoice = blnRetVal
End Function

Private Function IsValidInvoice_Each(myTxBody As UnboundGrids) As Boolean
    Dim i As Integer
    Dim strSKU, strSQL As String
    Dim intQty As Integer
    Dim sngLineNumber As Single
    Dim RetVal As Boolean
    
    RetVal = True
    
    For i = 0 To (myTxBody.MaxRow - 1)
        sngLineNumber = ofx_CSng(myTxBody.GridArray(0, i))
        strSKU = ofx_CStr(myTxBody.GridArray(ColIndexSKU, i))
        intQty = ofx_CInt(myTxBody.GridArray(ColIndexQty, i))
        
        ' Test as long as RetVal is still True
        If RetVal Then
            ' Ignor checking on rows without Qty
            If intQty > 0 Then
                ' SKU must be found
                If Not FindPLU(strSKU) Then
                    RetVal = False
                Else
                    RetVal = True
                End If
            End If
            If RetVal = False Then
                MsgBox "Invalid entry on Line Number: " & sngLineNumber
                Exit For
            End If
        End If
    Next i
End Function

Private Function IsValidInvoice_Paid() As Boolean
    Dim RetVal As Boolean
    Dim i As Integer
    Dim idxLocalCurrency As Integer
    Dim myCol As Columns
    Dim strSQL As String
    Dim TotalTender, Balance As Currency
    
    Set myCol = tdbgTxTender.Columns
    idxLocalCurrency = myCol("Local Currency").ColIndex
    
    For i = 0 To TxFooter_TD.MaxRow - 1
        TotalTender = TotalTender + ofx_CCur(TxFooter_TD.GridArray(idxLocalCurrency, i))
    Next i
    Balance = ofx_CCur(mskBalance)
    
    If Balance > TotalTender Then
        MsgBox "Amount Tender is not enought."
        IsValidInvoice_Paid = False
    Else
        IsValidInvoice_Paid = True
    End If
End Function

Private Sub DoBill()
    On Error GoTo DoBill_Err

    ' Default today as the Date of Deliver On,
    ' which is the invoice date
    With calDeliverOn
        .Text = Format(Now, "mm/dd/yyyy")
        .MaxDate = (Date + mDateDelivery)
        .MinDate = Date
    End With
    
    ' Clear the Tender Grid for input
    Call UnboundGrids_Initialize(TxFooter_TD)
    tdbgTxTender.ReBind

    ' Is there enough Qty for this bill
    Call VerifyBillQty

DoBill_Exit:                                ' SDVB autocode
    On Error Resume Next                    ' SDVB autocode
    Exit Sub                                ' SDVB autocode
DoBill_Err:                                 ' SDVB autocode
    Call ofx_GenericError("DoBill()", Err)  ' SDVB autocode
    Resume DoBill_Exit
End Sub

Private Function SaveRefund() As Integer
    Dim strSQL As String
    Dim myRS As Recordset
    Dim myDB As Database
    
'    If IsValidInvoice Then
'        SaveRefund = vbCancel
'        Exit Function
'    End If

    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")
    mOrderNumber = "SA" & ofx_CStr(mskOrderNumber)
    mControlNumber = GetNextControlNumber
    mTxNumber = GetNextTxNumber("RS")
    
    Call SaveRefund_TxHeader(mTxNumber)
    Call Save_TxSalesPerson(mTxNumber)
    Call Save_TxSOrderExtra(mTxNumber)
    Call SaveRefund_TxDetails
    Call SaveRefund_TxPayment
    
    ' Mark the TxHeader.Status of original order/invoice as Cancelled
    '
    Set myRS = myDB.OpenRecordset("TxHeader", dbOpenDynaset)
    '
    ' Mark Order as Voided
    strSQL = "TxNumber = '" & mOrderNumber & "'"
    With myRS
        .FindFirst strSQL
        If Not .NoMatch Then
            .Edit
            !Status = 2
            .Update
        End If
    End With
    '
    ' If Order is a Completed Order, mark Invoice as Refunded
    If mOrderStatus = 3 Then
        strSQL = "TxNumber = '" & ofx_CStr(txtRefNumber) & "'"
        With myRS
            .FindFirst strSQL
            If Not .NoMatch Then
                .Edit
                !Status = 1     ' Refunded Invoice
                .Update
            End If
        End With
    End If
    '
    myRS.Close
    myDB.Close
    
    ' Restock if it's a completed order
    If mOrderStatus = 3 Then
        Call OLTP_PoS(mTxNumber)    ' Posting
    End If
    
    SaveRefund = vbOK
End Function


Private Sub SaveRefund_TxDetails()
'    Call SaveRefund_TxDetails_Each(TxBodyP1)
    Call SaveRefund_TxDetails_Each(TxBody)
End Sub

Private Sub SaveRefund_TxDetails_Each(myTxBody As UnboundGrids)
    Dim i, intQty As Integer
    Dim strSQL, strSKU, strTxNumber As String
    
    For i = 0 To (myTxBody.MaxRow - 1)
        intQty = ofx_CInt(myTxBody.GridArray(ColIndexQty, i))
        If intQty <> 0 Then
            ' Locate the Inventory Record
            strSKU = ofx_CStr(myTxBody.GridArray(ColIndexSKU, i))
            If FindPLU(strSKU) Then
                With dtcTxDetails.Recordset
                    .AddNew
                    !ControlNumber = mControlNumber
                    !TxType = "RS"
                    !TxNumber = mTxNumber
                    !DateOfEntry = calOrderedOn.Text
                    !RowNo = (i + 1)                                    ' ofx_CSng(myTxBody.GridArray(0, i))
                    !SKU = ofx_CStr(myTxBody.GridArray(ColIndexSKU, i))
                    !Qty = (0 - ofx_CInt(myTxBody.GridArray(ColIndexQty, i)))
                    !UnitAmount = ofx_CCur(myTxBody.GridArray(ColIndexUnitPrice, i))
                    !UnitCost = dtcPLU.Recordset!AverageCost
                    !UnitLSP = dtcPLU.Recordset!LeastSellingPrice
                    !MarkDownAmount = ofx_CCur(myTxBody.GridArray(ColIndexMarkdown, i))
                    !Amount = (0 - ofx_CCur(myTxBody.GridArray(ColIndexAmount, i)))
                    !TaxCode = ofx_CStr(myTxBody.GridArray(ColIndexTax, i))
                    .Update
                End With
            End If
        End If
    Next i
End Sub

Private Sub SaveRefund_TxHeader(MyTxNumber As String)
    Dim strOrderNumber, strSQL As String
    
    With dtcTxHeader.Recordset
        .AddNew
        !ControlNumber = mControlNumber
        !TxType = Left(MyTxNumber, 2)
        !TxNumber = MyTxNumber
        !DateOfCreation = Now
        !CustomerID = ofx_CLng(txtCustomerName.Tag)
        !Particulars = txtParticular.Text
        !TotalCost = OrderTotal.Cost
        !TotalSale = 0 - OrderTotal.Sale
        !TaxA = 0 - OrderTotal.GST
        !TaxB = 0 - OrderTotal.PST
        !GrossSale = 0 - OrderTotal.Gross
        !TotalAmount = 0 - OrderTotal.Gross
        !TotalQty = 0 - OrderTotal.Qty
        !Change = 0
        !PaymentLink = NoOfSplitPayment
        !SalesPersonLink = 1
        !Status = "0"
        Select Case mOrderStatus
            Case 1      ' void a Confirmed Order
                !DateOfEntry = Format(mVoidOn, "MM/DD/YYYY")
                !RefNumber = mOrderNumber
                !TrackingNumber = mOrderNumber
                !SecondDate = calOrderedOn.Text
                !PreviousPaid = 0
                !ThisPaid = 0 - ofx_CCur(mskDeposit)
            Case 3      ' Void a Completed Order
                !DateOfEntry = Format(mVoidOn, "MM/DD/YYYY")
                !RefNumber = txtRefNumber.Text
                !TrackingNumber = mOrderNumber
                !SecondDate = calDeliverOn.Text
                !PreviousPaid = 0
                !ThisPaid = 0 - ofx_CCur(mskGrossSale)
        End Select
        .Update
        .Bookmark = .LastModified
    End With
End Sub

Private Sub SaveRefund_TxPayment()
    Dim myDB As Database
    Dim myRS, myRS2 As Recordset
    Dim i, idxType As Integer
    Dim idxTender, idxXchgRate, idxLocalCurrency As Integer
    Dim idxCardNumber, idxACode As Integer
    Dim myCol As Columns
    Dim strSQL As String
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")
    Set myRS = myDB.OpenRecordset("TxPayment", dbOpenDynaset, dbAppendOnly)
    Set myRS2 = myDB.OpenRecordset("PaymentMethods", dbOpenDynaset, dbReadOnly)
    Set myCol = tdbgTxTender.Columns
    
    idxType = myCol("Type").ColIndex
    idxCardNumber = myCol("Card Number").ColIndex
    idxACode = myCol("Approval Number").ColIndex
    idxTender = myCol("Tender").ColIndex
    idxXchgRate = myCol("Exchange Rate").ColIndex
    idxLocalCurrency = myCol("Local Currency").ColIndex
    
    For i = 0 To TxFooter_TD.MaxRow - 1
        If ofx_CCur(TxFooter_TD.GridArray(idxTender, i)) <> 0 Then
        With myRS
            strSQL = "PaymentNameLong = '" & ofx_CStr(TxFooter_TD.GridArray(idxType, i)) & "'"
            myRS2.FindFirst strSQL
            
            .AddNew
            !TxNumber = mTxNumber
            !PaymentLineNo = (i + 1)
            !Type = myRS2!PaymentCode
            !CardNumber = TxFooter_TD.GridArray(idxCardNumber, i)
            !AuthorizationCode = TxFooter_TD.GridArray(idxACode, i)
            !AmountTender = 0 - ofx_CCur(TxFooter_TD.GridArray(idxTender, i))
            !ExchangeRate = ofx_CCur(TxFooter_TD.GridArray(idxXchgRate, i))
            !EqAmount = 0 - ofx_CCur(TxFooter_TD.GridArray(idxLocalCurrency, i))
            !TotalThisPay = 0 - ofx_CCur(TxFooter_TD.GridArray(idxLocalCurrency, i))
            .Update
        End With
        End If
    Next i
    myRS.Close
    myRS2.Close
    myDB.Close
End Sub


Private Function DoPrint_Bill() As Integer
    Dim intResult, intLastChance As Integer
    Dim strMessage As String
    
    strMessage = "Yes    to Save and Print Invoice;" & Chr(13) & _
                 "No     to Save but not Print Invoice;" & Chr(13) & _
                 "Cancel to Abort Job."
    intLastChance = MsgBox(strMessage, vbYesNoCancel, "Bill Sales Order")
    Select Case intLastChance
        Case vbYes      ' Save and Print
            Screen.MousePointer = vbHourglass
            intResult = SaveInvoice             ' Posting
            If intResult = vbOK Then
                RptTxNumberFrom = mTxNumber
                Call PrintInvoice(1, 0)         ' Print invoice
                DoPrint_Bill = vbOK
            Else
                DoPrint_Bill = vbCancel
            End If
            Screen.MousePointer = vbDefault
            MsgBox "Done." & Chr(13) & _
                   "The Invoice Number is " & mTxNumber
        Case vbNo       ' Save nut not Print
            Screen.MousePointer = vbHourglass
            intResult = SaveInvoice             ' Posting
            If intResult = vbOK Then
                DoPrint_Bill = vbOK
            Else
                DoPrint_Bill = vbCancel
            End If
            Screen.MousePointer = vbDefault
            MsgBox "Done." & Chr(13) & _
                   "The Invoice Number is " & mTxNumber
        Case vbCancel   ' Abort Save and Print
            MsgBox "Job Aborted!"
            DoPrint_Bill = vbCancel
    End Select
End Function

Private Function DoPrint_Void() As Boolean
    Dim intResult, intLastChance As Integer
            
    RptTxNumberFrom = mTxNumber
    Select Case mOrderStatus
        Case 1      ' Confirmed Order
            Call PrintOrder(1, 1)
        Case 3      ' Completed Order
            Call PrintInvoice(1, 1)
    End Select
End Function

Private Function DoLookup() As Integer
'    On Error GoTo DoLookup_Err
    Dim strSQL, strDummy As String
    Dim strOrderNumber As String
    Dim strPrompt, strTitle As String
    Dim strTxNumber As String
    
    ' Ask the operator for the order number to lookup
    strPrompt = "Which Order Number to Lookup?"
    strTitle = "Order Number Lookup"
    strOrderNumber = InputBox(strPrompt, strTitle)
    If IsNull(strOrderNumber) Or strOrderNumber = "" Then
        ' If cancel reset buttons to ModeIdle
        tbrOrderEntry.Buttons(mButtonIndex_Lookup).Value = False
        mCurrentMode = mModeIdle
        DoLookup = vbCancel
        Exit Function
    End If
    
    Screen.MousePointer = vbHourglass
    '
    strTxNumber = "SA" & Trim(strOrderNumber)
    If Not FindOrder(strTxNumber) Then
        strDummy = MsgBox("Order Number not found.", vbExclamation)
        tbrOrderEntry.Buttons(mButtonIndex_Lookup).Value = False
        mCurrentMode = mModeIdle
        Screen.MousePointer = vbDefault
        DoLookup = vbCancel
        Exit Function
    End If
    '
    mOrderStatus = dtcTxHeader.Recordset!Status
    Select Case mOrderStatus
        Case "2"    ' Cancelled
            Screen.MousePointer = vbArrowHourglass
            strPrompt = "Order Number " & strOrderNumber & " is a Cancelled Order: " & GetRefundRef(strTxNumber) & Chr(13) & _
                        "You may: print, or undo to clear form."
            strDummy = MsgBox(strPrompt, vbInformation)
            Screen.MousePointer = vbHourglass
        Case "3"    ' Completed
            Screen.MousePointer = vbArrowHourglass
            strPrompt = "Order Number " & strOrderNumber & " is a Completed Order: " & GetInvoiceRef(strTxNumber) & Chr(13) & _
                        "You may: refund, print, or undo to clear form."
            strDummy = MsgBox(strPrompt, vbInformation)
            Screen.MousePointer = vbHourglass
        Case Else   ' Draft or Confirmed
    End Select
    Call LookupOrder(strTxNumber)
    DoLookup = vbOK
    Screen.MousePointer = vbDefault

DoLookup_Exit:                                ' SDVB autocode
    On Error Resume Next                      ' SDVB autocode
    Exit Function                             ' SDVB autocode
DoLookup_Err:                                 ' SDVB autocode
    Call ofx_GenericError("DoLookup()", Err)  ' SDVB autocode
    Resume DoLookup_Exit
End Function

' Caller supply the New Mode
' Migrate the Current Mode to Last Mode
' Update the New Mode to Current Mode
Private Sub SetCurrentMode(intNewMode As Integer)
    mLastMode = mCurrentMode
    mCurrentMode = intNewMode
' 20030725 Temporary removed
'    Call SetMenuButton(mCurrentMode)
'    Call SetProtectedArea(mCurrentMode)
'    Call SetStartPoint(mCurrentMode)
End Sub

Private Function NoOfSplitPayment() As Integer
    Dim i, RetVal As Integer
    Dim curTender As Currency
    
    For i = 1 To TxFooter_TD.MaxRow
        curTender = ofx_CCur(TxFooter_TD.GridArray(ColIndexTender, i - 1))
        If curTender > 0 Then RetVal = i
    Next i
    
    NoOfSplitPayment = RetVal
End Function

' Works for
'  Add
'  Bill
Private Sub Save_TxSalesPerson(strTxNumber As String)
    Dim strSQL As String
    
    strSQL = "TxNumber = '" & strTxNumber & "'"
    With dtcTxSalesPerson.Recordset
        .FindFirst strSQL
        If .NoMatch Then
            .AddNew
            !TxNumber = strTxNumber
        Else
            .Edit
        End If
        !SalesRowNo = 1
        !StaffCode = dbcStaff.BoundText
        .Update
    End With
End Sub

' Works for
'  Add  - Tender is for Deposit
'  Bill - Tender is for Balance
Private Sub Save_TxPayment(MyTxNumber As String)
    Dim i As Integer
    Dim strSQL, strTxNumber As String
    Dim strType, strCardNo, strAppCode As String
    Dim curTender, curXchgRate, curLocalCur As Currency
    Dim curGrossSale, curDeposit, curBalance, curAllTender As Currency
    
    curGrossSale = ofx_CCur(mskGrossSale)
    curDeposit = ofx_CCur(mskDeposit)
    curBalance = ofx_CCur(mskBalance)
    
    curAllTender = 0
    
    For i = 0 To (TxFooter_TD.MaxRow - 1)
        curLocalCur = ofx_CCur(TxFooter_TD.GridArray(ColIndexLocalCur, i))
        If curLocalCur <> 0 Then
            curAllTender = curLocalCur + curAllTender
            strType = ofx_CStr(TxFooter_TD.GridArray(ColIndexType, i))
            strCardNo = ofx_CStr(TxFooter_TD.GridArray(ColIndexCardNo, i))
            curTender = ofx_CCur(TxFooter_TD.GridArray(ColIndexTender, i))
            curXchgRate = ofx_CCur(TxFooter_TD.GridArray(ColIndexXchgRate, i))
            strAppCode = ofx_CStr(TxFooter_TD.GridArray(ColIndexAppCode, i))
            
            strSQL = "PaymentNameLong = '" & strType & "'"
            dtcPaymentMethods.Recordset.FindFirst strSQL
                
            strSQL = "TxNumber = '" & MyTxNumber & "' And " & _
                     "PaymentLineNo = " & (i + 1)
            With dtcQryTxPayment.Recordset
                .FindFirst strSQL
                If .NoMatch Then
                    .AddNew
                    !TxNumber = MyTxNumber
                    !PaymentLineNo = (i + 1)                        ' use the counter as the line number
                Else
                    .Edit
                End If
                !Type = dtcPaymentMethods.Recordset!PaymentCode
                !CardNumber = strCardNo
                !AuthorizationCode = strAppCode
                !AmountTender = curTender
                !ExchangeRate = curXchgRate
                !EqAmount = curLocalCur
                Select Case mLastMode
                    Case mModeAdd
                        If curAllTender > curDeposit Then
                            !TotalThisPay = curLocalCur - (curAllTender - curDeposit)
                        Else
                            !TotalThisPay = curLocalCur
                        End If
                    Case mModeBill
                        curBalance = curGrossSale - curDeposit
                        If curAllTender > curBalance Then
                            !TotalThisPay = curLocalCur - (curAllTender - curBalance)
                        Else
                            !TotalThisPay = curLocalCur
                        End If
                End Select
                .Update
            End With
        End If
    Next i
End Sub

Private Sub Save_TxHeader(MyTxNumber As String)
    On Error GoTo ErrorHandler
    Dim strOrderNumber, strSQL As String
    
    strOrderNumber = "SA" & ofx_CStr(mskOrderNumber)
    strSQL = "TxNumber = '" & MyTxNumber & "'"
    
    With dtcTxHeader.Recordset
        .FindFirst strSQL
        If .NoMatch Then
            .AddNew
            !TxNumber = MyTxNumber
        Else
            .Edit
        End If
        !ControlNumber = mControlNumber
        !TxType = Left(MyTxNumber, 2)
        !DateOfCreation = Now
        !CustomerID = ofx_CLng(txtCustomerName.Tag)
        !Particulars = txtParticular.Text
        !TotalCost = OrderTotal.Cost
        !TotalSale = OrderTotal.Sale
        !TaxA = OrderTotal.GST
        !TaxB = OrderTotal.PST
        !GrossSale = OrderTotal.Gross
        !TotalAmount = OrderTotal.Gross
        !TotalQty = OrderTotal.Qty
        !PaymentLink = NoOfSplitPayment
        !SalesPersonLink = 1
        !Change = ofx_CCur(mskChange)
        Select Case mLastMode
            Case mModeAdd
                !DateOfEntry = calOrderedOn.Text
                !RefNumber = txtRefNumber.Text
                !TrackingNumber = MyTxNumber
                !SecondDate = calDeliverOn.Text
                !PreviousPaid = 0
                !ThisPaid = ofx_CCur(mskDeposit)
                !Status = "1"       ' Confirmed Order
            Case mModeChange
'                !DateOfEntry = calOrderedOn.Text
                !RefNumber = txtRefNumber.Text
'                !TrackingNumber = MyTxNumber
                !SecondDate = calDeliverOn.Text
'                !PreviousPaid = 0
'                !ThisPaid = ofx_CCur(mskDeposit)
                !Status = "1"       ' Confirmed Order
            Case mModeBill
                !DateOfEntry = calDeliverOn.Text
                !RefNumber = strOrderNumber
                !TrackingNumber = strOrderNumber
                !SecondDate = calOrderedOn.Text
                !PreviousPaid = ofx_CCur(mskDeposit)
                !ThisPaid = ofx_CCur(mskGrossSale) - ofx_CCur(mskDeposit)
                !Status = "0"       ' Normal Invoice
        End Select
        .Update
        .Bookmark = .LastModified
    End With
    Exit Sub

ErrorHandler:
    MsgBox Error$, vbOKOnly + vbCritical, "Error on Save_TxHeader"
    Exit Sub
End Sub

Private Sub Save_TxSOrderExtra(MyTxNumber As String)
    Dim strSQL As String
    
    strSQL = "TxNumber = '" & MyTxNumber & "'"
    
    With dtcTxSOrderExtra.Recordset
        .FindFirst strSQL
        If .NoMatch Then
            .AddNew
            !TxNumber = MyTxNumber
        Else
            .Edit
        End If
        If chkRedo.Value = 1 Then !Redo = True
        If chkWarranty.Value = 1 Then !Warranty = True
        If chkMail.Value = 1 Then !Mail = True
        If chkMsd.Value = 1 Then !Msd = True
        .Update
    End With
End Sub

Private Sub Save_TxDetailsEach(MyTxNumber As String, myTxBody As UnboundGrids)
    Dim i, intQty As Integer
    Dim strSQL, strSKU  As String
    
    For i = 0 To (myTxBody.MaxRow - 1)
        strSKU = ofx_CStr(myTxBody.GridArray(ColIndexSKU, i))
        intQty = ofx_CInt(myTxBody.GridArray(ColIndexQty, i))
        If intQty <> 0 Then
            ' Locate the Inventory Record
            If FindPLU(strSKU) Then
                strSQL = "TxNumber = '" & MyTxNumber & "' And " & _
                         "RowNo = " & ofx_CStr(i + 1)                   ' ofx_CSng(myTxBody.GridArray(0, i))
                With dtcTxDetails.Recordset
                    .FindFirst strSQL       ' For Mode Change
                    If .NoMatch Then
                        .AddNew
                    Else
                        .Edit
                    End If
                    !ControlNumber = mControlNumber
                    !TxType = Left(MyTxNumber, 2)
                    !TxNumber = MyTxNumber
                    !RowNo = i + 1                                      ' ofx_CSng(myTxBody.GridArray(0, i))
                    !SKU = ofx_CStr(myTxBody.GridArray(ColIndexSKU, i))
                    !Qty = ofx_CInt(myTxBody.GridArray(ColIndexQty, i))
                    !UnitAmount = ofx_CCur(myTxBody.GridArray(ColIndexUnitPrice, i))
                    !UnitCost = dtcPLU.Recordset!AverageCost
                    !UnitLSP = dtcPLU.Recordset!LeastSellingPrice
                    !MarkDownAmount = ofx_CCur(myTxBody.GridArray(ColIndexMarkdown, i))
                    !Amount = ofx_CCur(myTxBody.GridArray(ColIndexAmount, i))
                    !TaxCode = ofx_CStr(myTxBody.GridArray(ColIndexTax, i))
                    Select Case mLastMode
                        Case mModeAdd, mModeChange
                            !DateOfEntry = calOrderedOn.Text
                        Case mModeBill
                            !DateOfEntry = calDeliverOn.Text
                    End Select
                    .Update
                End With
            End If
        End If
    Next i
End Sub

Private Sub Save_TxDetails(MyTxNumber As String)
'    Call Save_TxDetailsEach(MyTxNumber, TxBodyP1)
    Call Save_TxDetailsEach(MyTxNumber, TxBody)
End Sub



Private Sub DeleteTxDetails(MyTxNumber As String)
    Dim strSQL As String
    
    strSQL = "TxNumber = '" & mTxNumber & "'"
    
    With dtcTxDetails.Recordset
        .FindFirst strSQL
        Do While Not .NoMatch
            .Delete
            .FindNext strSQL
        Loop
    End With
End Sub

Private Sub DoSave()
    Dim intLastChance, Result As Integer
    Dim strMessage As String
    
    If Not IsGoodEntry Then
        mCurrentMode = mLastMode
        Exit Sub
    End If
    
    Select Case mLastMode
        Case mModeVoid
            strMessage = "This is your last chance." & Chr(13) & _
                         "Are you sure to void this Order?"
            intLastChance = MsgBox(strMessage, vbYesNo, "Void Sales Order")
            Select Case intLastChance
                Case vbYes
                    Screen.MousePointer = vbHourglass
                    Result = SaveRefund
                    If Result = vbOK Then
                        MsgBox "Void/ Refound Number: RS" & CStr(mTxNumber)
                    End If
                    Screen.MousePointer = vbDefault
                Case vbCancel
                    MsgBox "Job Aborted."
            End Select
        Case Else
            Call SaveOrder
    End Select
End Sub

Private Function IsTableEmptyBody() As Boolean
    Dim i, intCurrentRow As Integer
    Dim blnRetVal As Boolean
    
    If tdbgTxBody.VisibleRows > 0 Then
        intCurrentRow = tdbgTxBody.row
        tdbgTxBody.row = 0
        If ofx_CInt(tdbgTxBody.Columns("Qty").Value) > 0 Then
            blnRetVal = False
        Else
            blnRetVal = True
        End If
        tdbgTxBody.row = intCurrentRow
    Else
        blnRetVal = True
    End If
    
    IsTableEmptyBody = blnRetVal
End Function

Private Sub CalcTender_Total()
    Dim curTotalTender As Currency
    Dim myCol As Columns
    Dim i As Integer
    
    Set myCol = tdbgTxTender.Columns
    
    curTotalTender = 0
    For i = 0 To (TxFooter_TD.MaxRow - 1)
        tdbgTxTender.row = i
        curTotalTender = curTotalTender + ofx_CCur(myCol("Local Currency"))
    Next i
    
    mskTotalTender = curTotalTender
End Sub

Private Sub CalcChange()
    Dim curGrossSale, curDeposit, curBalance As Currency
    Dim curTotalTender, curChange As Currency
    
    curGrossSale = ofx_CCur(mskGrossSale)
    curDeposit = ofx_CCur(mskDeposit)
    curBalance = ofx_CCur(mskBalance)
    curTotalTender = ofx_CCur(mskTotalTender)
    curChange = 0
    
    Select Case mCurrentMode
        Case mModeAdd, mModeChange
' 2008.05.14 paulus:
            If (curTotalTender > curGrossSale) Then
                curChange = curTotalTender - curGrossSale
            End If
        Case mModeBill
' 2008.05.14 paulus:
'            curChange = curTotalTender - curBalance
            curChange = curTotalTender - curGrossSale + curDeposit
        Case mModeVoid
            ' Do nothing
    End Select
    If curChange > 0 Then
        mskChange = curChange
    Else
        mskChange = 0
    End If
End Sub

Private Sub CalcThisPaid()
    Dim curGrossSale, curDeposit, curBalance As Currency
    Dim curTotalTender, curChange As Currency
    
    curGrossSale = ofx_CCur(mskGrossSale)
    curDeposit = ofx_CCur(mskDeposit)
    curBalance = ofx_CCur(mskBalance)
    curTotalTender = ofx_CCur(mskTotalTender)
    curChange = ofx_CCur(mskChange)
    
    Select Case mCurrentMode
        Case mModeAdd, mModeChange
' 2008.05.14 paulus:
'            curDeposit = curTotalTender - curChange
            If (curTotalTender >= curGrossSale) Then
                curDeposit = curGrossSale
            Else
                curDeposit = curTotalTender
            End If
            curBalance = curGrossSale - curDeposit
            mskDeposit = curDeposit
            mskBalance = curBalance
        Case mModeBill
' 2008.05.14 paulus:
'            curBalance = curTotalTender - curChange
            curBalance = curGrossSale - curDeposit - curTotalTender
            mskBalance = curBalance
        Case mModeVoid
            ' Do nothing
    End Select
End Sub

Private Function IsGoodEntry() As Boolean
    Dim RetVal As Boolean
    Dim curGrossSale, curDeposit, curBalance As Currency
    Dim curTotalTender, curChange As Currency
    
' 20030724 assume Good
    RetVal = True
    ' Must fill in Order Number, Staff, Customer
    If ofx_CStr(mskOrderNumber) = "" Then
        RetVal = False
        MsgBox "You must provide the Order Number." & Chr(13) & _
               "Job Aborted!"
    End If
    '
    If dbcStaff.BoundText = "" Then
        RetVal = False
        MsgBox "You must pick the Staff from the available list." & Chr(13) & _
               "Job Aborted!"
    End If
    '
    If ofx_CStr(txtCustomerName) = "" Then
        RetVal = False
        MsgBox "You must provide the Customer Name." & Chr(13) & _
               "Job Aborted!"
    End If
    
' 20030724 added
    If Not RetVal Then
        IsGoodEntry = False
        Exit Function
    End If
    
    ' Re-Calc Totals
    Call CalcTotals
    Call CalcTender_Total
    Call CalcChange
    Call CalcThisPaid
    
    curGrossSale = ofx_CCur(mskGrossSale)
    curDeposit = ofx_CCur(mskDeposit)
    curBalance = ofx_CCur(mskBalance)
    curTotalTender = ofx_CCur(mskTotalTender)
    curChange = ofx_CCur(mskChange)
    
    Select Case mLastMode
        Case mModeAdd, mModeChange
        Case mModeBill
        Case mModeVoid
            Select Case mOrderStatus
                Case 1      ' Normal Order
                    If curTotalTender <> curDeposit Then
                        MsgBox "Void Amount should equals original Deposit." & Chr(13) & _
                               "Job Aborted!"
                        RetVal = False
                    End If
                Case 3      ' Completed Order
                    ' 2010.10.25 paulus:
                    ' curGrossSale sometimes contains more than 2 decimal places,
                    ' use a Round function to avoid it.
                    If curTotalTender <> Round(curGrossSale, 2) Then
                        MsgBox "Refund Amount should equals Gross Sale." & Chr(13) & _
                               "Job Aborted!"
                        RetVal = False
                    End If
            End Select
    End Select
    
    IsGoodEntry = RetVal
End Function


Private Sub WarnMsg_QtyEmpty(SKU As Variant)
    MsgBox "There's not enough Onhand Qty" & Chr(13) & _
           "for this SKU: " & SKU
End Sub

Private Sub VerifyBillQty()
    If mCurrentMode <> mModeBill Then Exit Sub
    Dim i As Integer
    Dim intQty As Integer
    Dim strSKU, strSQL As String
    Dim myDB As Database
    Dim myRS As Recordset
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set myRS = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)    ' Open table read only
    
    For i = 0 To (TxBody.MaxRow - 1)
        intQty = ofx_CInt(TxBody.GridArray(ColIndexQty, i))
        If intQty <> 0 Then
            strSKU = ofx_CStr(TxBody.GridArray(ColIndexSKU, i))
            strSQL = "SKU = '" & strSKU & "'"
            With myRS
                .FindFirst strSQL
                If Not .NoMatch Then
                    If !QtyTotalOnhand < intQty Then
                        Call WarnMsg_QtyEmpty(strSKU)
                    End If
                End If
            End With
        End If
    Next i

    myRS.Close
    myDB.Close
End Sub


' Caller past the target SKU
' Function search the Table for the matched SKU
Private Function FindPLU(ByVal mySKU As String) As Boolean
    Dim strSQL As String
    
    If IsEmpty(mySKU) Or IsNull(mySKU) Then
        FindPLU = False
    Else
        strSQL = "SELECT * FROM [Inventory Query] " & _
                 "WHERE SKU = '" & mySKU & "'"
        With dtcPLU
            .RecordSource = strSQL
            .Refresh
            If IsTableEmpty(.Recordset) Then
                FindPLU = False
            Else
                FindPLU = True
            End If
        End With
    End If
End Function

Private Function FindTxDetails(myTarget As String) As Boolean
    Dim strSQL As String
    
    If IsEmpty(myTarget) Or IsNull(myTarget) Then
        FindTxDetails = False
    Else
        strSQL = "SELECT * FROM TxDetails " & _
                 "WHERE TxNumber = '" & myTarget & "' " & _
                 "ORDER BY TxNumber, RowNo"
        With dtcTxDetails
            .RecordSource = strSQL
            .Refresh
            If IsTableEmpty(.Recordset) Then
                FindTxDetails = False
            Else
                FindTxDetails = True
            End If
        End With
    End If
End Function

Private Sub DoUndo()
    Call SetCurrentMode(mModeIdle)
    Call SetBlankForm
End Sub

Private Function FindOrder(myOrder As String) As Boolean
    Dim strSQL As String
    
    If IsEmpty(myOrder) Or IsNull(myOrder) Then
        FindOrder = False
    Else
        strSQL = "SELECT * FROM qryTxHeader " & _
                 "WHERE TxNumber = '" & myOrder & "'"
        With dtcTxHeader
            .RecordSource = strSQL
            .Refresh
            If IsTableEmpty(.Recordset) Then
                FindOrder = False
            Else
                FindOrder = True
            End If
        End With
    End If
End Function

Private Function FindTxHeader(myTarget As String) As Boolean
    Dim strSQL As String
    
    If IsEmpty(myTarget) Or IsNull(myTarget) Then
        FindTxHeader = False
    Else
        strSQL = "SELECT * FROM qryTxHeader " & _
                 "WHERE TxNumber = '" & myTarget & "'"
        With dtcTxDetails
            .RecordSource = strSQL
            .Refresh
            If IsTableEmpty(.Recordset) Then
                FindTxHeader = False
            Else
                FindTxHeader = True
            End If
        End With
    End If
End Function

Public Function FindTender(myTenderType As String) As Boolean
    Dim strSQL As String
    
    If IsEmpty(myTenderType) Or IsNull(myTenderType) Then
        FindTender = False
    Else
        strSQL = "PaymentNameLong = '" & myTenderType & "'"
        With dtcPaymentMethods.Recordset
            .FindFirst strSQL
            If .NoMatch Then
                FindTender = False
            Else
                FindTender = True
            End If
        End With
    End If
End Function

'WA added on May 7 1998
'
Private Function DoRefund() As Integer

'    On Error GoTo DoRefund_Err

    Dim intLastChance, Result As Integer
    Dim strMessage As String
    
    If Not IsGoodEntry Then
        mCurrentMode = mLastMode
        Exit Function
    End If
    
    strMessage = "This is your last chance." & Chr(13) & _
                 "Are you sure to void this Order?"
    intLastChance = MsgBox(strMessage, vbYesNo, "Void Sales Order")
    Select Case intLastChance
        Case vbYes
            Screen.MousePointer = vbHourglass
            DoRefund = SaveRefund
            If DoRefund = vbOK Then
                MsgBox "Void/ Refund Number: RS" & CStr(mTxNumber)
            End If
            Screen.MousePointer = vbDefault
        Case vbCancel
            DoRefund = vbCancel
            MsgBox "Job Aborted."
    End Select

DoRefund_Exit:                                ' SDVB autocode
    On Error Resume Next                    ' SDVB autocode
    Exit Function                           ' SDVB autocode
DoRefund_Err:                                 ' SDVB autocode
    Call ofx_GenericError("DoRefund()", Err)  ' SDVB autocode
    Resume DoRefund_Exit

End Function

Private Sub SetEditArea(intCurrentMode As Integer)

    On Error GoTo SetEditArea_Err

    
    Select Case intCurrentMode
        Case mModeIdle
        Case mModeAdd
            tdbgTxBody.row = 0
        Case mModeLookup
        Case mModeChange
            tdbgTxBody.row = 0
        Case mModeSave
        Case mModeVoid
        Case mModeBill
    End Select


SetEditArea_Exit:                                ' SDVB autocode
    On Error Resume Next                         ' SDVB autocode
    Exit Sub                                     ' SDVB autocode
SetEditArea_Err:                                 ' SDVB autocode
    Call ofx_GenericError("SetEditArea()", Err)  ' SDVB autocode
    Resume SetEditArea_Exit

End Sub

' Initialize UnboundGrids
'
Private Sub UnboundGrids_Initialize(Caller As UnboundGrids)

    On Error GoTo UnboundGrids_Initialize_Err


'    ReDim Preserve Caller.GridArray(0 To Caller.MaxCol - 1, 0 _
            To Caller.MaxRow - 1)
    Caller.MaxRow = 1
    ReDim Caller.GridArray(0 To Caller.MaxCol - 1, 0)
    Dim i, j As Integer
    ' Skip 1 st column
    ' 1st column is reserved for line number
    For i = 1 To (Caller.MaxCol - 1)
        For j = 0 To (Caller.MaxRow - 1)
            Caller.GridArray(i, j) = ""
        Next j
    Next i


UnboundGrids_Initialize_Exit:                                ' SDVB autocode
    On Error Resume Next                                     ' SDVB autocode
    Exit Sub                                                 ' SDVB autocode
UnboundGrids_Initialize_Err:                                 ' SDVB autocode
    Call ofx_GenericError("UnboundGrids_Initialize()", Err)  ' SDVB autocode
    Resume UnboundGrids_Initialize_Exit

End Sub

' 2008.12.15 paulus:
' make sure the last tender entry is updated
Private Sub SaveTender()
    Dim myCol As Columns
    Dim i As Integer
    Set myCol = tdbgTxTender.Columns
    For i = 0 To (TxFooter_TD.MaxRow - 1)
        tdbgTxTender.row = i
        If ofx_CCur(myCol(ColIndexTender)) <> 0 And ofx_CCur(myCol(ColIndexLocalCur)) = 0 Then
            myCol(ColIndexLocalCur) = ofx_CCur(myCol(ColIndexTender)) * ofx_CCur(myCol(ColIndexXchgRate))
            tdbgTxTender.Update
            Call CalcTender
        End If
    Next i
End Sub

' 2010.10.25 paulus:
' retrieve the invoice + date of an order
Private Function GetInvoiceRef(strOrderNumber As String) As String
    Dim strResult As String
    Dim strSQL As String
    Dim myRS As Recordset
    Dim myDB As Database

    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")
    Set myRS = myDB.OpenRecordset("TxHeader", dbOpenDynaset)
    strSQL = "TxType = 'RC' AND RefNumber = '" & strOrderNumber & "'"
    With myRS
        .FindFirst strSQL
        If Not .NoMatch Then
            strResult = !TxNumber & " on " & Format$(!DateOfEntry, "mm/dd/yyyy")
        End If
    End With
    myRS.Close
    myDB.Close

    GetInvoiceRef = strResult
End Function

' 2010.10.25 paulus:
' retrieve the Refund + date of an order
Private Function GetRefundRef(strOrderNumber As String) As String
    Dim strResult As String
    Dim strSQL As String
    Dim myRS As Recordset
    Dim myDB As Database

    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")
    Set myRS = myDB.OpenRecordset("TxHeader", dbOpenDynaset)
    strSQL = "TxType = 'RS' AND RefNumber = '" & strOrderNumber & "'"
    With myRS
        .FindFirst strSQL
        If Not .NoMatch Then
            strResult = !TxNumber & " on " & Format$(!DateOfEntry, "mm/dd/yyyy")
        End If
    End With
    myRS.Close
    myDB.Close

    GetRefundRef = strResult
End Function


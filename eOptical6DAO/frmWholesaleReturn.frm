VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmWholesaleReturn 
   Caption         =   "Wholesale Return"
   ClientHeight    =   8445
   ClientLeft      =   855
   ClientTop       =   1605
   ClientWidth     =   11790
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   8445
   ScaleWidth      =   11790
   WindowState     =   2  'Maximized
   Begin TrueDBGrid50.TDBGrid dbgTxBody 
      Height          =   2535
      Left            =   120
      OleObjectBlob   =   "frmWholesaleReturn.frx":0000
      TabIndex        =   6
      Top             =   3480
      Width           =   11535
   End
   Begin VB.Data dtcInvt 
      Caption         =   "Inventory"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   315
      Left            =   5040
      Options         =   4
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   2820
      Visible         =   0   'False
      Width           =   1935
   End
   Begin VB.Data dtcStaff 
      Caption         =   "Staff"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   315
      Left            =   3000
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT StaffFullName, StaffCode FROM Staff ORDER BY StaffFullName"
      Top             =   3100
      Visible         =   0   'False
      Width           =   1935
   End
   Begin VB.Data dtcSupplier 
      Caption         =   "Supplier"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   315
      Left            =   3000
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT SupplierName, SupplierCode FROM Supplier ORDER BY SupplierName"
      Top             =   2820
      Visible         =   0   'False
      Width           =   1935
   End
   Begin Threed.SSFrame fraHeader 
      Height          =   1635
      Left            =   120
      TabIndex        =   13
      Top             =   1080
      Width           =   9375
      _ExtentX        =   16536
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
      Caption         =   "Header"
      Begin VB.TextBox txtParticular 
         Height          =   495
         Left            =   5520
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   5
         Top             =   1020
         Width           =   2895
      End
      Begin VB.TextBox txtRefNumber 
         Height          =   315
         Left            =   5520
         TabIndex        =   4
         Top             =   660
         Width           =   1455
      End
      Begin VB.TextBox txtReturnNumber 
         Height          =   315
         Left            =   1320
         TabIndex        =   2
         Top             =   1020
         Width           =   2055
      End
      Begin MSDBCtls.DBCombo dbcSupplierName 
         Bindings        =   "frmWholesaleReturn.frx":8C76
         Height          =   315
         Left            =   5520
         TabIndex        =   3
         Top             =   300
         Width           =   2895
         _ExtentX        =   5106
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "SupplierName"
         BoundColumn     =   "SupplierCode"
         Text            =   ""
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
      Begin MSDBCtls.DBCombo dbcStaffFullName 
         Bindings        =   "frmWholesaleReturn.frx":8C90
         Height          =   315
         Left            =   1320
         TabIndex        =   1
         Top             =   660
         Width           =   2055
         _ExtentX        =   3625
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "StaffFullName"
         BoundColumn     =   "StaffCode"
         Text            =   ""
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
      Begin SSCalendarWidgets_A.SSDateCombo calTxDate 
         Height          =   315
         Left            =   1320
         TabIndex        =   0
         Top             =   300
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
         MinDate         =   "1996/1/1"
         MaxDate         =   "2100/12/31"
         Format          =   "MMMM DD, YYYY"
         ShowCentury     =   -1  'True
      End
      Begin Threed.SSCommand cmdGetTxNumber 
         Height          =   315
         Left            =   3360
         TabIndex        =   34
         TabStop         =   0   'False
         ToolTipText     =   "Get Next Return Number"
         Top             =   1020
         Width           =   390
         _ExtentX        =   688
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
         Picture         =   "frmWholesaleReturn.frx":8CA7
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdSupplierInfo 
         Height          =   315
         Left            =   8760
         TabIndex        =   20
         TabStop         =   0   'False
         Top             =   300
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
         Picture         =   "frmWholesaleReturn.frx":91F9
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdNewSupplier 
         Height          =   315
         Left            =   8400
         TabIndex        =   19
         TabStop         =   0   'False
         Top             =   300
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
         Picture         =   "frmWholesaleReturn.frx":978B
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label6 
         Caption         =   "Particular"
         Height          =   255
         Left            =   4320
         TabIndex        =   22
         Top             =   1020
         Width           =   855
      End
      Begin VB.Label Label3 
         Caption         =   "Ref. Invoice No."
         Height          =   435
         Left            =   4320
         TabIndex        =   21
         Top             =   660
         Width           =   1215
      End
      Begin VB.Label Label1 
         Caption         =   "Buyer Name"
         Height          =   255
         Left            =   4320
         TabIndex        =   18
         Top             =   300
         Width           =   1215
      End
      Begin Threed.SSCommand cmdNewStaff 
         Height          =   315
         Left            =   3360
         TabIndex        =   16
         TabStop         =   0   'False
         Top             =   660
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
         Picture         =   "frmWholesaleReturn.frx":9D59
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label10 
         Caption         =   "Return Number"
         Height          =   375
         Left            =   120
         TabIndex        =   17
         Top             =   1020
         Width           =   1215
      End
      Begin VB.Label Label9 
         Caption         =   "Handled by"
         Height          =   255
         Left            =   120
         TabIndex        =   15
         Top             =   660
         Width           =   975
      End
      Begin VB.Label Label8 
         Caption         =   "Returned on"
         Height          =   255
         Left            =   120
         TabIndex        =   14
         Top             =   300
         Width           =   1095
      End
   End
   Begin Threed.SSFrame fraMiniTools 
      Height          =   615
      Left            =   120
      TabIndex        =   23
      Top             =   2760
      Width           =   2055
      _ExtentX        =   3625
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
      Caption         =   "Mini Tools"
      Begin Threed.SSCommand cmdMarkdownByDollar 
         Height          =   315
         Left            =   1080
         TabIndex        =   26
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
         Picture         =   "frmWholesaleReturn.frx":A327
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdMarkdownByPercentage 
         Height          =   315
         Left            =   600
         TabIndex        =   25
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
         Picture         =   "frmWholesaleReturn.frx":A7FD
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdCalculator 
         Height          =   315
         Left            =   120
         TabIndex        =   24
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
         Picture         =   "frmWholesaleReturn.frx":ACC7
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin Threed.SSFrame fraTotal 
      Height          =   1695
      Left            =   6540
      TabIndex        =   27
      Top             =   6120
      Width           =   4455
      _ExtentX        =   7858
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
      Caption         =   "Total"
      Begin VB.TextBox txtTotalQty 
         Alignment       =   1  'Right Justify
         BackColor       =   &H0000FFFF&
         Enabled         =   0   'False
         Height          =   315
         Left            =   480
         MultiLine       =   -1  'True
         TabIndex        =   7
         TabStop         =   0   'False
         Top             =   240
         Width           =   495
      End
      Begin MSMask.MaskEdBox mskGrossSold 
         Height          =   315
         Left            =   3000
         TabIndex        =   11
         TabStop         =   0   'False
         Top             =   1200
         Width           =   1215
         _ExtentX        =   2143
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   65535
         Enabled         =   0   'False
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskFreight 
         Height          =   315
         Left            =   3000
         TabIndex        =   10
         Top             =   880
         Width           =   1215
         _ExtentX        =   2143
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   65535
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskTotalTax 
         Height          =   315
         Left            =   3000
         TabIndex        =   9
         Top             =   560
         Width           =   1215
         _ExtentX        =   2143
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   65535
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskNetSold 
         Height          =   315
         Left            =   3000
         TabIndex        =   8
         TabStop         =   0   'False
         Top             =   240
         Width           =   1215
         _ExtentX        =   2143
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   65535
         Enabled         =   0   'False
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
      Begin VB.Label Label12 
         Caption         =   "Gross Return"
         Height          =   315
         Left            =   1920
         TabIndex        =   31
         Top             =   1200
         Width           =   975
      End
      Begin VB.Label Label11 
         Caption         =   "Freight"
         Height          =   315
         Left            =   1920
         TabIndex        =   30
         Top             =   880
         Width           =   855
      End
      Begin VB.Label Label7 
         Caption         =   "Total Tax"
         Height          =   315
         Left            =   1920
         TabIndex        =   29
         Top             =   560
         Width           =   855
      End
      Begin VB.Label Label4 
         Caption         =   "Net Return"
         Height          =   315
         Left            =   1920
         TabIndex        =   28
         Top             =   240
         Width           =   855
      End
      Begin VB.Label Label2 
         Caption         =   "Qty"
         Height          =   255
         Left            =   120
         TabIndex        =   32
         Top             =   240
         Width           =   495
      End
   End
   Begin VB.PictureBox statStkRecEnhanced 
      Align           =   2  'Align Bottom
      Height          =   375
      Left            =   0
      ScaleHeight     =   315
      ScaleWidth      =   11730
      TabIndex        =   12
      Top             =   8070
      Width           =   11790
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar tbrWSReturn 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   33
      Top             =   0
      Width           =   11790
      _Version        =   131073
      _ExtentX        =   20796
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
      Btns            =   8
      ToolsetPicture  =   "frmWholesaleReturn.frx":B245
      BC              =   8
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
      ToolsetNumTools =   8
      ToolsetToolID(0)=   "ID_Add"
      ToolsetToolHelp(0)=   "Add Record"
      ToolsetToolMnemonic(0)=   "a"
      ToolsetToolGroup(0)=   1
      ToolsetToolAllowAllUp(0)=   -1  'True
      ToolsetToolType(0)=   1
      ToolsetToolExclusive(0)=   -1  'True
      ToolsetToolID(1)=   "ID_Undo"
      ToolsetToolHelp(1)=   "Undo Edit"
      ToolsetToolMnemonic(1)=   "u"
      ToolsetToolGroup(1)=   1
      ToolsetToolAllowAllUp(1)=   -1  'True
      ToolsetToolType(1)=   1
      ToolsetToolExclusive(1)=   -1  'True
      ToolsetToolID(2)=   "ID_Save"
      ToolsetToolHelp(2)=   "Save Record"
      ToolsetToolMnemonic(2)=   "s"
      ToolsetToolGroup(2)=   1
      ToolsetToolAllowAllUp(2)=   -1  'True
      ToolsetToolType(2)=   1
      ToolsetToolExclusive(2)=   -1  'True
      ToolsetToolID(3)=   "ID_Print"
      ToolsetToolHelp(3)=   "Print Record"
      ToolsetToolMnemonic(3)=   "p"
      ToolsetToolGroup(3)=   1
      ToolsetToolAllowAllUp(3)=   -1  'True
      ToolsetToolType(3)=   1
      ToolsetToolExclusive(3)=   -1  'True
      ToolsetToolID(4)=   "ID_BarCode"
      ToolsetToolHelp(4)=   "Print Bar Code"
      ToolsetToolMnemonic(4)=   "b"
      ToolsetToolGroup(4)=   1
      ToolsetToolAllowAllUp(4)=   -1  'True
      ToolsetToolType(4)=   1
      ToolsetToolExclusive(4)=   -1  'True
      ToolsetToolID(5)=   "ID_FindSKU"
      ToolsetToolHelp(5)=   "Find SKU"
      ToolsetToolMnemonic(5)=   "f"
      ToolsetToolGroup(5)=   1
      ToolsetToolAllowAllUp(5)=   -1  'True
      ToolsetToolType(5)=   1
      ToolsetToolExclusive(5)=   -1  'True
      ToolsetToolID(6)=   "ID_AddSKU"
      ToolsetToolHelp(6)=   "Add SKU"
      ToolsetToolMnemonic(6)=   "k"
      ToolsetToolGroup(6)=   1
      ToolsetToolAllowAllUp(6)=   -1  'True
      ToolsetToolType(6)=   1
      ToolsetToolExclusive(6)=   -1  'True
      ToolsetToolID(7)=   "ID_Exit"
      ToolsetToolHelp(7)=   "Exit Task"
      ToolsetToolMnemonic(7)=   "x"
      ToolsetToolGroup(7)=   1
      ToolsetToolAllowAllUp(7)=   -1  'True
      ToolsetToolType(7)=   1
      ToolsetToolExclusive(7)=   -1  'True
      MouseIcon       =   "frmWholesaleReturn.frx":172D7
   End
End
Attribute VB_Name = "frmWholesaleReturn"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim TxBody      As UnboundGrids ' TxBody grid data source
Dim MyEditMode  As Byte         ' Current Edit Mode
Dim MyNewMode   As Byte
Dim MySaveMode  As Byte
Dim MyClearMode As Byte
Dim MyTxNumber  As String       ' Current Tx Number

Private Const mColIndexQty As Integer = 13
Private Const mColIndexUnitCost As Integer = 14
Private Const mColIndexMarkdownD As Integer = 15
Private Const mColIndexMarkdownP As Integer = 16
Private Const mColIndexTotalCost As Integer = 17
Private Const mColIndexLSP As Integer = 18

'   WA added on Jan 07, 1998 for Date Control
Private Const mDateAllowance As Integer = 90

Dim mCurrentMode  As Integer         ' Current Edit Mode
Private Const mModeIdle     As Integer = 0
Private Const mModeAdd      As Integer = 1
Private Const mModeUndo     As Integer = 2
Private Const mModeSave     As Integer = 3
Private Const mModePrint    As Integer = 4
Private Const mModeBarCode  As Integer = 5

Private Const mButtonIndex_Add As Integer = 0
Private Const mButtonIndex_Undo As Integer = 1
Private Const mButtonIndex_Save As Integer = 2
Private Const mButtonIndex_Print As Integer = 3
Private Const mButtonIndex_BarCode As Integer = 4
Private Const mButtonIndex_FindSKU As Integer = 5
Private Const mButtonIndex_AddSKU As Integer = 6
Private Const mButtonIndex_Exit As Integer = 7

Private Sub calTxDate_DateError(ErrCode As Integer, ErrString As String, LastValidDate As String, Text As String, RtnDispErrMsg As Integer, RtnRestore As Integer)
    
    If Not IsDate(Text) Then
        RtnRestore = False
        Exit Sub
    End If
    
    Dim sysMinDate, srcMaxDate, srcMinDate, srcLastValidDate, srcInputDate As Date
    
    With calTxDate
        srcMaxDate = CDate(.MaxDate)
        srcMinDate = CDate(.MinDate)
        srcLastValidDate = CDate(LastValidDate)
        srcInputDate = CDate(Text)
        
        If srcInputDate > srcMaxDate Then
            RtnRestore = False
            Exit Sub
        End If
    
        If srcMinDate = pyMinDate Then
            MsgBox "Returned On Date cannot smaller than system opening date (" & _
                pyMinDate & ")", vbOKOnly + vbCritical, pyUserName
            .Date = srcLastValidDate
        ElseIf srcInputDate >= pyMinDate Then
            Select Case MsgBox("Sold On Date should not aged " & _
                mDateAllowance & " days from today." & Chr(13) & _
                "Are you sure to overide this restriction?", _
                vbYesNo + vbQuestion, pyUserName)
                Case vbYes
                    .MinDate = pyMinDate
                    .Date = srcInputDate
                Case Else
            End Select
        End If
    End With
End Sub


Private Sub cmdCalculator_Click()

    On Error GoTo cmdCalculator_Click_Err

    Dim RetVal As Variant
    RetVal = Shell("Calc.Exe", 1)

cmdCalculator_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                                 ' SDVB autocode
    Exit Sub                                             ' SDVB autocode
cmdCalculator_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("cmdCalculator_Click()", Err)  ' SDVB autocode
    Resume cmdCalculator_Click_Exit

End Sub






Private Sub cmdGetTxNumber_Click()
    Dim sNextWSNumber As String
    
    sNextWSNumber = GetNextTxNumber("WR")
    txtReturnNumber.Text = Right(sNextWSNumber, 8)
End Sub

Private Sub cmdMarkdownByDollar_Click()

    On Error GoTo cmdMarkdownByDollar_Click_Err

    ' Change TxBody to Markdown $
    dbgTxBody.Columns("Markdown $").Visible = True
    dbgTxBody.Columns("Markdown %").Visible = False

cmdMarkdownByDollar_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                                       ' SDVB autocode
    Exit Sub                                                   ' SDVB autocode
cmdMarkdownByDollar_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("cmdMarkdownByDollar_Click()", Err)  ' SDVB autocode
    Resume cmdMarkdownByDollar_Click_Exit

End Sub

Private Sub cmdMarkdownByPercentage_Click()

    On Error GoTo cmdMarkdownByPercentage_Click_Err

    ' Change TxBody to Markdown %
    dbgTxBody.Columns("Markdown $").Visible = False
    dbgTxBody.Columns("Markdown %").Visible = True

cmdMarkdownByPercentage_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                                           ' SDVB autocode
    Exit Sub                                                       ' SDVB autocode
cmdMarkdownByPercentage_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("cmdMarkdownByPercentage_Click()", Err)  ' SDVB autocode
    Resume cmdMarkdownByPercentage_Click_Exit

End Sub

Private Sub cmdNewStaff_Click()

    On Error GoTo cmdNewStaff_Click_Err

    Call ofx_CloseForm(frmStaff)
    Screen.MousePointer = vbHourglass
    frmStaff.Show vbModal
    dtcStaff.Refresh
    dtcStaff.UpdateControls

cmdNewStaff_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                               ' SDVB autocode
    Exit Sub                                           ' SDVB autocode
cmdNewStaff_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("cmdNewStaff_Click()", Err)  ' SDVB autocode
    Resume cmdNewStaff_Click_Exit

End Sub

Private Sub cmdNewSupplier_Click()

    On Error GoTo cmdNewSupplier_Click_Err

    Call ofx_CloseForm(frmSupplier)
    Screen.MousePointer = vbHourglass
    frmSupplier.Show vbModal
    dtcSupplier.Refresh
    dtcSupplier.UpdateControls

cmdNewSupplier_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                                  ' SDVB autocode
    Exit Sub                                              ' SDVB autocode
cmdNewSupplier_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("cmdNewSupplier_Click()", Err)  ' SDVB autocode
    Resume cmdNewSupplier_Click_Exit

End Sub

Private Sub cmdSupplierInfo_Click()

    On Error GoTo cmdSupplierInfo_Click_Err

    Call ofx_CloseForm(frmInfoSupplier)
    Screen.MousePointer = vbHourglass
    frmInfoSupplier.Show vbModal
'    dbgTxBody.Columns("SKU").Value = Clipboard.GetText

cmdSupplierInfo_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                                   ' SDVB autocode
    Exit Sub                                               ' SDVB autocode
cmdSupplierInfo_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("cmdSupplierInfo_Click()", Err)  ' SDVB autocode
    Resume cmdSupplierInfo_Click_Exit

End Sub

Private Sub dbgTxBody_AfterColUpdate(ByVal ColIndex As Integer)

    On Error GoTo dbgTxBody_AfterColUpdate_Err

    
    ' Calculate the Net Cost if Qty, Unit Amount, or Markdown is changed
    If dbgTxBody.Columns(ColIndex).Caption = "Qty" Or _
       dbgTxBody.Columns(ColIndex).Caption = "Unit Cost" Or _
       dbgTxBody.Columns(ColIndex).Caption = "Markdown $" Or _
       dbgTxBody.Columns(ColIndex).Caption = "Markdown %" Then
        CalcNetCost
    End If
    

dbgTxBody_AfterColUpdate_Exit:                                ' SDVB autocode
    On Error Resume Next                                      ' SDVB autocode
    Exit Sub                                                  ' SDVB autocode
dbgTxBody_AfterColUpdate_Err:                                 ' SDVB autocode
    Call ofx_GenericError("dbgTxBody_AfterColUpdate()", Err)  ' SDVB autocode
    Resume dbgTxBody_AfterColUpdate_Exit

End Sub

Private Sub dbgTxBody_BeforeColEdit(ByVal ColIndex As Integer, ByVal KeyAscii As Integer, Cancel As Integer)
    ' If user is editing the 2nd column and
    ' the 1st column is blank than
    ' display row numbers for the first column.
    With dbgTxBody
        If ColIndex = 1 And _
            .Columns(0) = "" Then
            .Columns(0).Value = TxBody.MaxRow + 1
        End If
    End With
End Sub

Private Sub dbgTxBody_BeforeColUpdate(ByVal ColIndex As Integer, _
    OldValue As Variant, Cancel As Integer)

'    On Error GoTo dbgTxBody_BeforeColUpdate_Err

    Dim strSQL As String
    Dim intQty As Integer
    Dim curUnitCost, curMarkdownD, curMarkdownP As Currency
    
    ' Varify the SKU
    ' If valid, move to next cell; else remains on current cell
    If dbgTxBody.Col = dbgTxBody.Columns("SKU").ColIndex And _
       dbgTxBody.Columns(ColIndex).Value <> "" Then
        If LookupPLU(dbgTxBody.Columns("SKU")) Then
            Call FillPLU
        Else
            MsgBox "Invalid SKU!"
            Cancel = True
        End If
    End If
    
    ' Varify the Qty
    If dbgTxBody.Col = dbgTxBody.Columns("Qty").ColIndex Then
        intQty = ofx_CInt(dbgTxBody.Columns(ColIndex).Value)
        If intQty < 0 Then
            ofx_DoMessageBox "You're not allowed to enter a negative Qty"
            Cancel = True
        End If
    End If
    
    ' Varify the Unit Amount
    If dbgTxBody.Col = dbgTxBody.Columns("Unit Cost").ColIndex Then
        curUnitCost = ofx_CCur(dbgTxBody.Columns(ColIndex).Value)
        If curUnitCost < 0 Then
            ofx_DoMessageBox "You're not allowed to enter a negative Unit Cost"
            Cancel = True
        End If
    End If
    
    ' Varify the Markdown $
    If dbgTxBody.Col = dbgTxBody.Columns("Markdown $").ColIndex Then
        curMarkdownD = ofx_CCur(dbgTxBody.Columns("Markdown $").Value)
        curUnitCost = ofx_CCur(dbgTxBody.Columns("Unit Cost").Value)
        If curMarkdownD < 0 Or _
           curMarkdownD > curUnitCost Then
            ofx_DoMessageBox "Markdown $ should not negative nor greater than Unit Cost"
            Cancel = True
        End If
    End If
    
    ' Varify the Markdown %
    If dbgTxBody.Col = dbgTxBody.Columns("Markdown %").ColIndex Then
        curMarkdownP = ofx_CCur(dbgTxBody.Columns(ColIndex).Value)
        If curMarkdownP < 0 Or _
           curMarkdownP > 100 Then
            ofx_DoMessageBox "Markdown % must between 0 to 100"
            Cancel = True
        End If
    End If
    

dbgTxBody_BeforeColUpdate_Exit:                                ' SDVB autocode
    On Error Resume Next                                       ' SDVB autocode
    Exit Sub                                                   ' SDVB autocode
dbgTxBody_BeforeColUpdate_Err:                                 ' SDVB autocode
    Call ofx_GenericError("dbgTxBody_BeforeColUpdate()", Err)  ' SDVB autocode
    Resume dbgTxBody_BeforeColUpdate_Exit

End Sub

Private Sub dbgTxBody_ClassicAdd(NewRowBookmark As Variant, ByVal Col As Integer, Value As Variant)

    On Error GoTo dbgTxBody_ClassicAdd_Err

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


dbgTxBody_ClassicAdd_Exit:                                ' SDVB autocode
    On Error Resume Next                                  ' SDVB autocode
    Exit Sub                                              ' SDVB autocode
dbgTxBody_ClassicAdd_Err:                                 ' SDVB autocode
    Call ofx_GenericError("dbgTxBody_ClassicAdd()", Err)  ' SDVB autocode
    Resume dbgTxBody_ClassicAdd_Exit

End Sub

Private Sub dbgTxBody_ClassicDelete(Bookmark As Variant)

    On Error GoTo dbgTxBody_ClassicDelete_Err

    ' ClassicDelete is fired when the user deletes an
    ' existing row in the Unbound grid.  This event
    ' alerts the user that the program must delete the
    ' row specified by the Bookmark parameter from the
    ' dataset.  Here, an auxiliary function (DeleteRow)
    ' is used to do this.

    If Not DeleteRow(Bookmark, TxBody) Then Bookmark = Null


dbgTxBody_ClassicDelete_Exit:                                ' SDVB autocode
    On Error Resume Next                                     ' SDVB autocode
    Exit Sub                                                 ' SDVB autocode
dbgTxBody_ClassicDelete_Err:                                 ' SDVB autocode
    Call ofx_GenericError("dbgTxBody_ClassicDelete()", Err)  ' SDVB autocode
    Resume dbgTxBody_ClassicDelete_Exit

End Sub


Private Sub dbgTxBody_ClassicRead(Bookmark As Variant, ByVal Col As Integer, Value As Variant)

    On Error GoTo dbgTxBody_ClassicRead_Err

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


dbgTxBody_ClassicRead_Exit:                                ' SDVB autocode
    On Error Resume Next                                   ' SDVB autocode
    Exit Sub                                               ' SDVB autocode
dbgTxBody_ClassicRead_Err:                                 ' SDVB autocode
    Call ofx_GenericError("dbgTxBody_ClassicRead()", Err)  ' SDVB autocode
    Resume dbgTxBody_ClassicRead_Exit

End Sub

Private Sub dbgTxBody_ClassicWrite(Bookmark As Variant, ByVal Col As Integer, Value As Variant)

    On Error GoTo dbgTxBody_ClassicWrite_Err

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


dbgTxBody_ClassicWrite_Exit:                                ' SDVB autocode
    On Error Resume Next                                    ' SDVB autocode
    Exit Sub                                                ' SDVB autocode
dbgTxBody_ClassicWrite_Err:                                 ' SDVB autocode
    Call ofx_GenericError("dbgTxBody_ClassicWrite()", Err)  ' SDVB autocode
    Resume dbgTxBody_ClassicWrite_Exit

End Sub



Private Sub dbgTxBody_LostFocus()

    On Error GoTo dbgTxBody_LostFocus_Err


    ' Calculate the Total Qty Received
    Call CalcTotals

dbgTxBody_LostFocus_Exit:                                ' SDVB autocode
    On Error Resume Next                                 ' SDVB autocode
    Exit Sub                                             ' SDVB autocode
dbgTxBody_LostFocus_Err:                                 ' SDVB autocode
    Call ofx_GenericError("dbgTxBody_LostFocus()", Err)  ' SDVB autocode
    Resume dbgTxBody_LostFocus_Exit

End Sub

Private Sub dbgTxBody_RowColChange(LastRow As Variant, ByVal LastCol As Integer)

    On Error GoTo dbgTxBody_RowColChange_Err
    Dim strDummy, strMessage As String


    ' If current columns is Net Cost,
    ' advance to beginning of next row.
'    If dbgTxBody.Columns(dbgTxBody.Col).Caption = "Net Cost" Then
'        SendKeys "{RIGHT}", True
'    End If
    
    ' SKU column must be filled
'    If Not (dbgTxBody.Col = dbgTxBody.Columns("SKU").ColIndex) Then
'        If dbgTxBody.Columns("SKU").Value = "" Then
'            ofx_DoMessageBox "You must enter a valid SKU"
'            dbgTxBody.Col = dbgTxBody.Columns("SKU").ColIndex
'        End If
'    End If
    ' SKU column must be filled
    With dbgTxBody
        If LastCol = .Columns("SKU").ColIndex Then
            If Not (IsNull(.Columns("SKU")) Or .Columns("SKU") = "") Then
                If Not LookupPLU(.Columns("SKU")) Then
                    strMessage = "You must enter a valid SKU."
                    strDummy = MsgBox(strMessage, vbExclamation)
                    .Col = .Columns("SKU").ColIndex
                End If
            End If
        End If
    End With
    
    ' Skip locked columns
    Call SetTxBodyColFocus(LastRow, LastCol)
'    Call CalcTotals


dbgTxBody_RowColChange_Exit:                                ' SDVB autocode
    On Error Resume Next                                    ' SDVB autocode
    Exit Sub                                                ' SDVB autocode
dbgTxBody_RowColChange_Err:                                 ' SDVB autocode
    Call ofx_GenericError("dbgTxBody_RowColChange()", Err)  ' SDVB autocode
    Resume dbgTxBody_RowColChange_Exit

End Sub

Private Sub dbgTxBody_UnboundGetRelativeBookmark(StartLocation As Variant, ByVal OffSet As Long, NewLocation As Variant, ApproximatePosition As Long)

    On Error GoTo dbgTxBody_UnboundGetRelativeBookmark_Err

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


dbgTxBody_UnboundGetRelativeBookmark_Exit:                                ' SDVB autocode
    On Error Resume Next                                                  ' SDVB autocode
    Exit Sub                                                              ' SDVB autocode
dbgTxBody_UnboundGetRelativeBookmark_Err:                                 ' SDVB autocode
    Call ofx_GenericError("dbgTxBody_UnboundGetRelativeBookmark()", Err)  ' SDVB autocode
    Resume dbgTxBody_UnboundGetRelativeBookmark_Exit

End Sub


Private Sub Form_Activate()

    On Error GoTo Form_Activate_Err
    Screen.MousePointer = vbDefault


Form_Activate_Exit:                                ' SDVB autocode
    On Error Resume Next                           ' SDVB autocode
    Exit Sub                                       ' SDVB autocode
Form_Activate_Err:                                 ' SDVB autocode
    Call ofx_GenericError("Form_Activate()", Err)  ' SDVB autocode
    Resume Form_Activate_Exit

End Sub

Private Sub Form_Load()

    On Error GoTo Form_Load_Err

    Call ofx_CenterForm(Me)

    ' Set Controlling dates
    With calTxDate
        .MaxDate = Date
        .MinDate = (Date - mDateAllowance)
    End With

    ' Set Grid TXBody X-Y value
    TxBody.MaxCol = 19
    TxBody.MaxRow = 0
    InitTxTotal
    
    ' Default Edit Mode as Clear at the beginning
    MyClearMode = 0
    MyNewMode = 1
    MySaveMode = 2
    SetEditMode (mModeIdle)
    
    ' Default TxBody uses Markdown %
    dbgTxBody.Columns("Markdown $").Visible = False
    
    ' Create status panel
'    Call CreatePanelObjects(statStkRecEnhanced)
    
'    Call PromptStatusBar(statStkRecEnhanced, pyUserName)
    
    
    ' Only enable ToolBar
    Call FrameDisable

Form_Load_Exit:                                ' SDVB autocode
    On Error Resume Next                       ' SDVB autocode
    Exit Sub                                   ' SDVB autocode
Form_Load_Err:                                 ' SDVB autocode
    Call ofx_GenericError("Form_Load()", Err)  ' SDVB autocode
    Resume Form_Load_Exit

End Sub



Private Sub CalcNetCost()

    On Error GoTo CalcNetCost_Err

    ' Calculate the NetCost
    Dim intQty      As Integer
    Dim curUnitCost As Currency
    Dim curMarkDnD  As Currency
    Dim curMarkDnP  As Currency
    Dim curNetCost  As Currency
    
    intQty = ofx_CInt(dbgTxBody.Columns("Qty").Value)
    curUnitCost = ofx_CCur(dbgTxBody.Columns("Unit Cost").Value)
    If dbgTxBody.Columns("Markdown $").Visible Then
        curMarkDnD = ofx_CCur(dbgTxBody.Columns("Markdown $").Value)
        If curMarkDnD <> 0 Then
            curMarkDnP = (ofx_CInt((curMarkDnD * 10000) / curUnitCost) / 100)
            dbgTxBody.Columns("Markdown %").Value = curMarkDnP
        Else
            dbgTxBody.Columns("Markdown %").Value = 0
        End If
    End If
    If dbgTxBody.Columns("Markdown %").Visible Then
        curMarkDnP = ofx_CCur(dbgTxBody.Columns("Markdown %").Value)
        If curMarkDnP <> 0 Then
            curMarkDnD = (ofx_CInt(curUnitCost * curMarkDnP) / 100)
            dbgTxBody.Columns("Markdown $").Value = curMarkDnD
        Else
            dbgTxBody.Columns("Markdown $").Value = 0
        End If
    End If
    curNetCost = intQty * (curUnitCost - curMarkDnD)
    dbgTxBody.Columns("Total Cost").Value = curNetCost


CalcNetCost_Exit:                                ' SDVB autocode
    On Error Resume Next                         ' SDVB autocode
    Exit Sub                                     ' SDVB autocode
CalcNetCost_Err:                                 ' SDVB autocode
    Call ofx_GenericError("CalcNetCost()", Err)  ' SDVB autocode
    Resume CalcNetCost_Exit

End Sub


Private Sub mskFreight_Change()
    Call CalcTotals
End Sub

Private Sub mskFreight_GotFocus()
    Call AutoSelect(mskFreight)
End Sub

Private Sub mskFreight_LostFocus()
    Call CalcTotals
End Sub



Private Sub mskTotalTax_Change()
    Call CalcTotals
End Sub

Private Sub mskTotalTax_GotFocus()
    Call AutoSelect(mskTotalTax)
End Sub

Private Sub mskTotalTax_LostFocus()
    Call CalcTotals
End Sub

' Calculate the Net Purchase by adding all Net Cost
Private Function CalcNetSold() As Currency

    On Error GoTo CalcNetSold_Err


    Dim i As Integer
    Dim curNetSold As Currency
    
    For i = 0 To (TxBody.MaxRow - 1)
        curNetSold = ofx_CCur(TxBody.GridArray(mColIndexTotalCost, i)) + curNetSold
    Next i
    CalcNetSold = curNetSold
    

CalcNetSold_Exit:                                ' SDVB autocode
    On Error Resume Next                             ' SDVB autocode
    Exit Function                                    ' SDVB autocode
CalcNetSold_Err:                                 ' SDVB autocode
    Call ofx_GenericError("CalcNetSold()", Err)  ' SDVB autocode
    Resume CalcNetSold_Exit

End Function

' Calculate the Gross Purchase
Private Function CalcGrossSold() As Currency

    On Error GoTo CalcGrossSold_Err

    Dim curNetSold, curTotalTax, curOtherCharges As Currency
    Dim curGrossSold As Currency
    curNetSold = ofx_CCur(mskNetSold)
    curTotalTax = ofx_CCur(mskTotalTax)
    curOtherCharges = ofx_CCur(mskFreight)
    CalcGrossSold = (curNetSold + curTotalTax + curOtherCharges)

CalcGrossSold_Exit:                                ' SDVB autocode
    On Error Resume Next                               ' SDVB autocode
    Exit Function                                      ' SDVB autocode
CalcGrossSold_Err:                                 ' SDVB autocode
    Call ofx_GenericError("CalcGrossSold()", Err)  ' SDVB autocode
    Resume CalcGrossSold_Exit

End Function













' Clear TxTotal columns and set first column lable names
Private Sub InitTxTotal()

    On Error GoTo InitTxTotal_Err

    ' Clear Totals
    mskNetSold = 0
    mskTotalTax = 0
    mskFreight = 0
    mskGrossSold = 0
    fraTotal.Refresh
    
InitTxTotal_Exit:                                ' SDVB autocode
    On Error Resume Next                         ' SDVB autocode
    Exit Sub                                     ' SDVB autocode
InitTxTotal_Err:                                 ' SDVB autocode
    Call ofx_GenericError("InitTxTotal()", Err)  ' SDVB autocode
    Resume InitTxTotal_Exit

End Sub

Private Function CalcTotalQty() As Integer

    On Error GoTo CalcTotalQty_Err

    Dim i As Integer
    Dim intTotalQty As Integer

    For i = 0 To (TxBody.MaxRow - 1)
        intTotalQty = ofx_CInt(TxBody.GridArray(mColIndexQty, i)) + intTotalQty
    Next i
    CalcTotalQty = intTotalQty

CalcTotalQty_Exit:                                ' SDVB autocode
    On Error Resume Next                          ' SDVB autocode
    Exit Function                                 ' SDVB autocode
CalcTotalQty_Err:                                 ' SDVB autocode
    Call ofx_GenericError("CalcTotalQty()", Err)  ' SDVB autocode
    Resume CalcTotalQty_Exit

End Function

' This subroutine would clear all the current entries
Private Sub ClearAllEntries()

    On Error GoTo ClearAllEntries_Err

    ' Clear TxHeader
    dbcStaffFullName.Text = ""
    txtReturnNumber.Text = ""
    dbcSupplierName.Text = ""
    txtRefNumber.Text = ""
    txtParticular.Text = ""
    txtTotalQty.Text = ""
    
    ' Clear TxBody
    TxBody.MaxRow = 0
    ReDim TxBody.GridArray(0 To TxBody.MaxCol - 1, 0)
    dbgTxBody.Bookmark = Null
    dbgTxBody.ReBind
    
    ' Clear TxTotal, keep cloumn 0
    Call InitTxTotal
    
    ' Reset Current Tx Number to Null
    MyTxNumber = ""
    
    ' Return focus to first entry field
'    calTxDate.SetFocus

ClearAllEntries_Exit:                                ' SDVB autocode
    On Error Resume Next                             ' SDVB autocode
    Exit Sub                                         ' SDVB autocode
ClearAllEntries_Err:                                 ' SDVB autocode
    Call ofx_GenericError("ClearAllEntries()", Err)  ' SDVB autocode
    Resume ClearAllEntries_Exit

End Sub


Private Sub SaveEntries()
    Dim MyControlNumber As String
    Dim curNetSold, curTotalTax, curOtherCharges, curGrossSold As Currency
    Dim i As Integer
    Dim MyWS As Workspace
    Dim myDB As Database
    Dim TxHeader, TxDetails, TxSalePerson, TxPayment As Recordset
    Dim MyCriteria, strSKU As String

    On Error GoTo SaveEntries_Err


    ' Varify some important entries
    ' If anyone failed, stop update
    If Not IsFound("Staff", "StaffFullName", dbcStaffFullName.Text, vbYes) Or _
       Not IsFound("Supplier", "SupplierName", dbcSupplierName.Text, vbYes) Or _
       IsGridEmpty(dbgTxBody, vbYes) Or _
       IsGridEditing(dbgTxBody, vbYes) Then
        SetEditMode (MyNewMode)
        Exit Sub
    End If
    
    ' Return focus to empty Return Number
    If IsNothingEnter(txtReturnNumber, vbYes, "Return Number") Then
        SetEditMode (MyNewMode)
        txtReturnNumber.SetFocus
        Exit Sub
    End If
    
    ' make sure Return Number not used
    Dim strTxNumber As String
    Dim blnFound As Boolean
    
    strTxNumber = ofx_CStr(txtReturnNumber.Text)
    If strTxNumber = "" Then Exit Sub
    
    strTxNumber = "WR" & strTxNumber
    blnFound = IsFound("TxHeader", "TxNumber", strTxNumber, True)
    If blnFound Then
        Beep
        MsgBox "Return Number is used." & Chr(13) & _
               "Please enter a new Return Number"
        SetEditMode (MyNewMode)
        txtReturnNumber.SetFocus
        Exit Sub
    End If

    ' Calculate the Total Qty Received
    Call CalcTotals
    
    ' Start prepare to update entries
    ' Updates the TxHeader, TxDetails, and TxSalePerson
    Screen.MousePointer = vbHourglass
    MyCriteria = "SKU = '" & " " & "'"      ' Set the criteria.
    MyControlNumber = GetNextControlNumber
    MyTxNumber = "WR" & ofx_CStr(txtReturnNumber)
    curNetSold = ofx_CCur(mskNetSold)
    curTotalTax = ofx_CCur(mskTotalTax)
    curOtherCharges = ofx_CCur(mskFreight)
    curGrossSold = ofx_CCur(mskGrossSold)
    
    '
    ' Write entries into Tx files and pass control to OLTP for posting
    '
    Set MyWS = Workspaces(0)
    Set myDB = MyWS.OpenDatabase("SynergyV.mdb")                           ' Open database
    Set TxHeader = myDB.OpenRecordset("TxHeader", dbOpenDynaset, dbAppendOnly, dbOptimistic)      ' Open table for append only
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbAppendOnly, dbOptimistic)    ' Open table for append only
    Set TxSalePerson = myDB.OpenRecordset("TxSalePerson", dbOpenDynaset, dbAppendOnly, dbOptimistic)      ' Open table for append only
    Set TxPayment = myDB.OpenRecordset("TxPayment", dbOpenDynaset, dbAppendOnly, dbOptimistic)      ' Open table for append only
    '
    'On Error GoTo RollbackSaveEntries
'    MyWS.BeginTrans
    ' Write TxHeader
'    Call PromptStatusBar(statStkRecEnhanced, "Posting Transaction Header")
    With TxHeader
        .AddNew
        !ControlNumber = MyControlNumber
        !TxType = Left(MyTxNumber, 2)
        !TxNumber = MyTxNumber
        !DateOfEntry = calTxDate.Text
        !DateOfCreation = Now
        !RefNumber = txtRefNumber.Text          ' Assume the operator input the
        !TrackingNumber = txtRefNumber.Text     ' original invoice number here
        !Particulars = txtParticular.Text
        !SupplierCode = dbcSupplierName.BoundText
        !TotalCost = 0 - GetTotalCost
        !TotalSale = 0 - curNetSold
        !TaxA = 0 - curTotalTax
        !OtherCharges = 0 - curOtherCharges
        !GrossSale = 0 - curGrossSold
        !TotalAmount = 0 - curGrossSold
        !TotalQty = 0 - ofx_CInt(txtTotalQty.Text)
        !ThisPaid = 0 - curGrossSold    ' Assume full amount was paid
        !Change = 0
        !SalesPersonLink = 1
        !PaymentLink = 1
        .Update
    End With
    ' Write TxSalePerson
'    Call PromptStatusBar(statStkRecEnhanced, "Posting Sales Person")
    With TxSalePerson
        .AddNew
        !TxNumber = MyTxNumber
        !SalesRowNo = 1
        !StaffCode = dbcStaffFullName.BoundText
        .Update
    End With
    ' Write TxPayment
'    Call (statStkRecEnhanced, "Posting Payment")
    With TxPayment
        .AddNew
        !TxNumber = MyTxNumber
        !PaymentLineNo = (i + 1)
        !Type = "0"         ' Assume Local Currency
        !CardNumber = ""
        !AuthorizationCode = ""
        !AmountTender = 0 - curGrossSold
        !ExchangeRate = 1
        !EqAmount = 0 - curGrossSold
        !TotalThisPay = 0 - curGrossSold
        .Update
    End With
    ' Write TxDetails
'    Call PromptStatusBar(statStkRecEnhanced, "Posting Transaction Details")
    For i = 0 To TxBody.MaxRow - 1
        ' 20030830 detect empty SKU instead of Line No.
        strSKU = Trim(ofx_CStr(TxBody.GridArray(1, i)))
        If strSKU <> "" Then
'        If Trim(TxBody.GridArray(1, i)) <> "" Then
            With TxDetails
                strSKU = TxBody.GridArray(1, i)
                If LookupPLU(strSKU) Then
                    .AddNew
                    !ControlNumber = MyControlNumber
                    !TxType = Left(MyTxNumber, 2)
                    !TxNumber = MyTxNumber
                    !DateOfEntry = calTxDate.Text
                    !RowNo = (i + 1)
                    !SKU = strSKU
                    !Qty = 0 - ofx_CInt(TxBody.GridArray(mColIndexQty, i))
                    !UnitAmount = ofx_CCur(TxBody.GridArray(mColIndexUnitCost, i))
                    !MarkDownAmount = ofx_CCur(TxBody.GridArray(mColIndexMarkdownD, i))
                    !MarkDownPercent = ofx_CSng(TxBody.GridArray(mColIndexMarkdownP, i))
                    !Amount = 0 - ofx_CCur(TxBody.GridArray(mColIndexTotalCost, i))
                    !UnitCost = dtcInvt.Recordset!AverageCost
                    !UnitLSP = dtcInvt.Recordset!LeastSellingPrice
                    .Update
                End If
            End With
        End If
    Next i
    '
'    MyWS.CommitTrans
    TxPayment.Close
    TxSalePerson.Close
    TxHeader.Close
    TxDetails.Close
    myDB.Close
    
    ' Activate OLTP to post transaction
    OLTP_PoS (MyTxNumber)
    
    '
    Screen.MousePointer = vbDefault
'    Call PromptStatusBar(frmMain.statMain, pyUserName)
    ofx_DoMessageBox "Save is done." & Chr$(13) & _
                     "Please stamp your document with the Tx Number: " & MyTxNumber & Chr(13) & _
                     "for later reference."
    Exit Sub

RollbackSaveEntries:
'    MyWS.Rollback
    Screen.MousePointer = vbDefault
'    Call PromptStatusBar(frmMain.statMain, pyUserName)
    ofx_DoMessageBox "Error Detected.  Current Save was aborted."
    Exit Sub

SaveEntries_Exit:                                ' SDVB autocode
    On Error Resume Next                         ' SDVB autocode
'    Call PromptStatusBar(frmMain.statMain, pyUserName)
    Exit Sub                                     ' SDVB autocode
SaveEntries_Err:                                 ' SDVB autocode
    Call ofx_GenericError("SaveEntries()", Err)  ' SDVB autocode
    Resume SaveEntries_Exit

End Sub

Private Sub statStkRecEnhanced_Click()
'    Call StatusBarClick(statStkRecEnhanced)
End Sub

Private Sub SetEditMode(ByVal CurrentMode As Integer)
    mCurrentMode = CurrentMode
    Call SetMenuButton(CurrentMode)
End Sub

Private Sub FrameEnable()

    On Error GoTo FrameEnable_Err

    fraHeader.Enabled = True
    fraMiniTools.Enabled = True
    fraTotal.Enabled = True
    dbgTxBody.Enabled = True

FrameEnable_Exit:                                ' SDVB autocode
    On Error Resume Next                         ' SDVB autocode
    Exit Sub                                     ' SDVB autocode
FrameEnable_Err:                                 ' SDVB autocode
    Call ofx_GenericError("FrameEnable()", Err)  ' SDVB autocode
    Resume FrameEnable_Exit

End Sub

Private Sub FrameDisable()

    On Error GoTo FrameDisable_Err

    fraHeader.Enabled = False
    fraMiniTools.Enabled = False
    fraTotal.Enabled = False
    dbgTxBody.Enabled = False

FrameDisable_Exit:                                ' SDVB autocode
    On Error Resume Next                          ' SDVB autocode
    Exit Sub                                      ' SDVB autocode
FrameDisable_Err:                                 ' SDVB autocode
    Call ofx_GenericError("FrameDisable()", Err)  ' SDVB autocode
    Resume FrameDisable_Exit

End Sub

Private Sub FillPLU()

    On Error GoTo FillPLU_Err

    Dim myCol As Columns
    Dim strSQL As String

    Set myCol = dbgTxBody.Columns
    
    ' Find the SKU for this line
    ' If not found then terminate sub
    If Not LookupPLU(myCol("SKU")) Then
        MsgBox "Invalid SKU!"
        Exit Sub
    End If
    
    ' Fill the PLU for this line
    With dtcInvt.Recordset
        If Trim(ofx_CStr(myCol("Line No."))) = "" Then
            myCol("Line No.") = dbgTxBody.row + 1
        End If
'        myCol("Supplier") = !SupplierName
        myCol("Brand") = !BrandDescription
        myCol("Model/Style") = !Model
        myCol("Category") = ofx_CStr(!Categoryname)
        myCol("Material") = ofx_CStr(!MaterialDescription)
        myCol("Color") = ofx_CStr(!Color)
        myCol("Size") = ofx_CStr(!Size)
        myCol("Sphere") = ofx_CSng(!Sphere)
        myCol("Cylinder") = ofx_CSng(!Cylinder)
        myCol("Base Curve") = ofx_CSng(!BaseCurve)
        myCol("Qty") = 1
        myCol("Unit Cost") = !AverageCost       'RetailPrice
        myCol("Total Cost") = !AverageCost      'RetailPrice
        myCol("LSP") = !LeastSellingPrice
    End With

FillPLU_Exit:                                ' SDVB autocode
    On Error Resume Next                     ' SDVB autocode
    Exit Sub                                 ' SDVB autocode
FillPLU_Err:                                 ' SDVB autocode
    Call ofx_GenericError("FillPLU()", Err)  ' SDVB autocode
    Resume FillPLU_Exit

End Sub

Private Sub SetTxBodyColFocus(LastRow As Variant, ByVal LastCol As Integer)

    On Error GoTo SetTxBodyColFocus_Err


    Dim blnForward As Boolean
    Dim intRow, intCol As Integer
    Dim intOldXY, intNewXY As Integer
    intRow = dbgTxBody.row
    intCol = dbgTxBody.Col
    
    ' Determine the direction of movement
    intOldXY = ofx_CInt(LastRow) * TxBody.MaxCol + LastCol
    intNewXY = intRow * TxBody.MaxCol + intCol
    If intNewXY > intOldXY Then
        blnForward = True
    Else
        blnForward = False
    End If
    
    ' If within X-Y Area, skip locked columns
    If (intRow >= 0 And intRow < (TxBody.MaxRow + 1)) And _
       (intCol >= 0 And intCol < TxBody.MaxCol) Then
        If dbgTxBody.Columns(intCol).Locked = True Then
            If blnForward Then
                SendKeys "{RIGHT}", True
            Else
                SendKeys "{LEFT}", True
            End If
        End If
    End If

SetTxBodyColFocus_Exit:                                ' SDVB autocode
    On Error Resume Next                               ' SDVB autocode
    Exit Sub                                           ' SDVB autocode
SetTxBodyColFocus_Err:                                 ' SDVB autocode
    Call ofx_GenericError("SetTxBodyColFocus()", Err)  ' SDVB autocode
    Resume SetTxBodyColFocus_Exit

End Sub

Private Sub CalcTotals()
    txtTotalQty = CalcTotalQty
    mskNetSold = CalcNetSold
    mskGrossSold = CalcGrossSold
    fraTotal.Refresh
End Sub

Private Function LookupPLU(strSKU As String) As Boolean
    Dim strSQL As String
    
    strSQL = "SELECT * FROM [Inventory Query] " & _
             "WHERE SKU = '" & strSKU & "'"
    With dtcInvt
        .RecordSource = strSQL
        .Refresh
        If IsEmpty(dtcInvt.Recordset) Then
            LookupPLU = False
        Else
            LookupPLU = True
        End If
    End With
End Function

Private Function GetTotalCost() As Currency
    Dim curCost, curTotalCost As Currency
    Dim strSKU As String
    Dim intQty, i As Integer
    
    For i = 0 To TxBody.MaxRow - 1
        If TxBody.GridArray(1, i) <> "" Then
            strSKU = ofx_CStr(TxBody.GridArray(1, i))
            intQty = ofx_CInt(TxBody.GridArray(mColIndexQty, i))
            If LookupPLU(strSKU) Then
                curCost = ofx_CCur(Format((intQty * dtcInvt.Recordset!AverageCost), "####0.00"))
                curTotalCost = curTotalCost + curCost
            End If
        End If
    Next i
End Function

Private Sub tbrWSReturn_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)
    Dim strPrefix As String
    Dim i As Integer
    
    ' Ignor Up clicks
    If Value = False Then Exit Sub
    
    With tbrWSReturn
        ' Avoid operator using the accerator key for disabled buttons.
        ' If the Button pressed is disabled,
        ' raise the button and do nothing.
        If .Buttons(Btn).Enabled = False And Value = True Then
            .Buttons(Btn).Value = False
            Exit Sub
        End If
        
        ' The "exculsive" option of Sheriden ToolBar doesn't work here.
        ' Emulate exclusive function by raising all other buttons
        For i = 0 To (.ToolsetTools.Count - 1)
            If i <> Btn And .Buttons(i).Value Then
                .Buttons(i).Value = False
            End If
        Next i
        
        ' When button was Down
        If Value Then
            ' The "exculsive" option of Sheriden ToolBar doesn't work here.
            ' Emulate exclusive function by raising all other buttons
            For i = 0 To (.ToolsetTools.Count - 1)
                If i <> Btn Then _
                    .Buttons(i).Value = False
            Next i
            '
            Select Case ToolID
            Case "ID_Add"
                Call DoAdd
            Case "ID_Undo"
                Call DoUndo
            Case "ID_Save"
                Call DoSave
            Case "ID_Exit"
                Unload Me
            Case "ID_Print"
                Call DoPrint
            Case "ID_BarCode"
                Call DoBarCode
            Case "ID_FindSKU"
                Call DoFindSKU
            Case "ID_AddSKU"
                Call DoAddSKU
            End Select
        End If
    End With
End Sub

Private Sub txtReturnNumber_LostFocus()

    On Error GoTo txtReturnNumber_LostFocus_Err

    Dim strTxNumber As String
    Dim blnFound As Boolean
    
    strTxNumber = ofx_CStr(txtReturnNumber.Text)
    If strTxNumber = "" Then Exit Sub
    
    ' If add new invoice
    ' make sure Invoice Number not used
'    If myCurrentMode = MyNewMode Then
    strTxNumber = "WR" & strTxNumber
    blnFound = IsFound("TxHeader", "TxNumber", strTxNumber, True)
    If blnFound Then
        Beep
        MsgBox "Return Number is used." & Chr(13) & _
               "Please enter a new Return Number"
        txtReturnNumber.SetFocus
    End If
'    End If

txtReturnNumber_LostFocus_Exit:                                ' SDVB autocode
    On Error Resume Next                                      ' SDVB autocode
    Exit Sub                                                  ' SDVB autocode
txtReturnNumber_LostFocus_Err:                                 ' SDVB autocode
    Call ofx_GenericError("txtReturnNumber_LostFocus()", Err)  ' SDVB autocode
    Resume txtReturnNumber_LostFocus_Exit

End Sub

Private Sub DoFindSKU()
    Clipboard.Clear
    If ofx_IsFormLoaded(frmInfoSKU) Then
        Unload frmInfoSKU
    End If
    Screen.MousePointer = vbHourglass
    frmInfoSKU.Show vbModal
    If IsNull(Clipboard.GetText) Or Clipboard.GetText = "" Then
    Else
        dbgTxBody.Columns("SKU").Value = Clipboard.GetText
        Call FillPLU
    End If
End Sub

Private Sub SetMenuButton(intMode As Integer)
    With tbrWSReturn
    Select Case intMode
        Case mModeIdle
            .Buttons(mButtonIndex_Add).Enabled = True
            .Buttons(mButtonIndex_Undo).Enabled = False
            .Buttons(mButtonIndex_Save).Enabled = False
            .Buttons(mButtonIndex_Print).Enabled = False
            .Buttons(mButtonIndex_BarCode).Enabled = False
            .Buttons(mButtonIndex_FindSKU).Enabled = False
            .Buttons(mButtonIndex_AddSKU).Enabled = False
            .Buttons(mButtonIndex_Exit).Enabled = True
        Case mModeAdd
            .Buttons(mButtonIndex_Add).Enabled = False
            .Buttons(mButtonIndex_Undo).Enabled = True
            .Buttons(mButtonIndex_Save).Enabled = True
            .Buttons(mButtonIndex_Print).Enabled = False
            .Buttons(mButtonIndex_BarCode).Enabled = False
            .Buttons(mButtonIndex_FindSKU).Enabled = True
            .Buttons(mButtonIndex_AddSKU).Enabled = True
            .Buttons(mButtonIndex_Exit).Enabled = False
        Case mModeUndo
            Call SetMenuButton(mModeIdle)
        Case mModeSave
            .Buttons(mButtonIndex_Add).Enabled = True
            .Buttons(mButtonIndex_Undo).Enabled = False
            .Buttons(mButtonIndex_Save).Enabled = False
            .Buttons(mButtonIndex_Print).Enabled = True
            .Buttons(mButtonIndex_BarCode).Enabled = False
            .Buttons(mButtonIndex_FindSKU).Enabled = False
            .Buttons(mButtonIndex_AddSKU).Enabled = False
            .Buttons(mButtonIndex_Exit).Enabled = True
        Case mModeBarCode
            .Buttons(mButtonIndex_Add).Enabled = True
            .Buttons(mButtonIndex_Undo).Enabled = False
            .Buttons(mButtonIndex_Save).Enabled = False
            .Buttons(mButtonIndex_Print).Enabled = True
            .Buttons(mButtonIndex_BarCode).Enabled = False
            .Buttons(mButtonIndex_FindSKU).Enabled = False
            .Buttons(mButtonIndex_AddSKU).Enabled = False
            .Buttons(mButtonIndex_Exit).Enabled = True
    End Select
    End With
End Sub

Private Sub DoAdd()
    SetEditMode (mModeAdd)
    
    ' Reset Working Date Control
    With calTxDate
        .Date = Date
        .MaxDate = Date
        .MinDate = (Date - mDateAllowance)
    End With
    
    FrameEnable
    ClearAllEntries
End Sub

Private Sub DoSave()
    SetEditMode (mModeSave)
    SaveEntries
    If MyEditMode = MyNewMode Then
        'Do nothing to able users re-enter errors trap info
    Else
        FrameDisable    'else entries have saved, ready for new entries
    End If
End Sub

Private Sub DoUndo()
    SetEditMode (mModeUndo)
    ClearAllEntries
    FrameDisable
End Sub

Private Sub DoPrint()
    RptTxNumberFrom = MyTxNumber
    Call PrintWholesalesReturn(1, 0)
End Sub

Private Sub DoBarCode()
    RptTxNumberFrom = MyTxNumber
    Call PrintBarCode(1, 1)
    tbrWSReturn.Buttons(4).Enabled = False   ' Print once only
End Sub

Private Sub DoAddSKU()
    Clipboard.Clear
    Call ofx_CloseForm(frmInvt)
    Screen.MousePointer = vbHourglass
    frmInvt.Show vbModal
    dbgTxBody.Columns("SKU").Value = Clipboard.GetText
End Sub

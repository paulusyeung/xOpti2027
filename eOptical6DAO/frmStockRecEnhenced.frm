VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmStockRecEnhanced 
   Caption         =   "c"
   ClientHeight    =   7680
   ClientLeft      =   75
   ClientTop       =   720
   ClientWidth     =   11790
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   7680
   ScaleWidth      =   11790
   WindowState     =   2  'Maximized
   Begin TrueDBGrid50.TDBGrid dbgTxBody 
      Height          =   2535
      Left            =   120
      OleObjectBlob   =   "frmStockRecEnhenced.frx":0000
      TabIndex        =   10
      Top             =   3480
      Width           =   11535
   End
   Begin Threed.SSFrame fraLSPWizard 
      Height          =   1575
      Left            =   3000
      TabIndex        =   26
      Top             =   6060
      Visible         =   0   'False
      Width           =   3135
      _ExtentX        =   5530
      _ExtentY        =   2778
      _Version        =   131074
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
      Caption         =   "LSP Wizard"
      Begin VB.OptionButton optByNetCost 
         Caption         =   "Equals Net Cost"
         Height          =   255
         Left            =   1440
         TabIndex        =   30
         Top             =   660
         Width           =   1455
      End
      Begin VB.OptionButton optByUnitCost 
         Caption         =   "Equals Unit Cost"
         Height          =   255
         Left            =   1440
         TabIndex        =   29
         Top             =   360
         Width           =   1575
      End
      Begin VB.OptionButton optByCost 
         Caption         =   "By Cost"
         Height          =   315
         Left            =   240
         TabIndex        =   28
         Top             =   600
         Width           =   975
      End
      Begin VB.OptionButton optByQty 
         Caption         =   "By Qty"
         Height          =   315
         Left            =   240
         TabIndex        =   27
         Top             =   300
         Width           =   975
      End
      Begin Threed.SSCommand cmdLSPcancel 
         Height          =   375
         Left            =   1680
         TabIndex        =   32
         Top             =   1080
         Width           =   855
         _ExtentX        =   1508
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
         Caption         =   "Cancel"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdLSPok 
         Height          =   375
         Left            =   480
         TabIndex        =   31
         Top             =   1080
         Width           =   855
         _ExtentX        =   1508
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
         Caption         =   "OK"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin VB.Data dtcInventory 
      Caption         =   "Inventory"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   315
      Left            =   5040
      Options         =   4
      ReadOnly        =   -1  'True
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
      Height          =   300
      Left            =   3000
      Options         =   0
      ReadOnly        =   -1  'True
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT StaffFullName, StaffCode FROM Staff ORDER BY StaffFullName"
      Top             =   3060
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
      Height          =   300
      Left            =   3000
      Options         =   0
      ReadOnly        =   -1  'True
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT SupplierName, SupplierCode FROM Supplier ORDER BY SupplierName"
      Top             =   2820
      Visible         =   0   'False
      Width           =   1935
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar tbrStockReceived 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   0
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
      ToolsetPicture  =   "frmStockRecEnhenced.frx":8C76
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
      MouseIcon       =   "frmStockRecEnhenced.frx":14D08
   End
   Begin Threed.SSFrame fraHeader 
      Height          =   1635
      Left            =   120
      TabIndex        =   11
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
         TabIndex        =   9
         Top             =   1020
         Width           =   2895
      End
      Begin VB.TextBox txtInvoiceNumber 
         Height          =   315
         Left            =   5520
         TabIndex        =   8
         Top             =   660
         Width           =   1455
      End
      Begin VB.TextBox txtPONumber 
         Height          =   285
         Left            =   1320
         TabIndex        =   4
         Top             =   1020
         Width           =   1455
      End
      Begin MSDBCtls.DBCombo dbcSupplierName 
         Bindings        =   "frmStockRecEnhenced.frx":14D24
         Height          =   315
         Left            =   5520
         TabIndex        =   5
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
      End
      Begin MSDBCtls.DBCombo dbcStaffFullName 
         Bindings        =   "frmStockRecEnhenced.frx":14D3E
         Height          =   315
         Left            =   1320
         TabIndex        =   2
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
      End
      Begin SSCalendarWidgets_A.SSDateCombo calTxDate 
         Height          =   315
         Left            =   1320
         TabIndex        =   1
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
         Format          =   "DD MMMM, YYYY"
         ShowCentury     =   -1  'True
      End
      Begin Threed.SSCommand cmdSupplierInfo 
         Height          =   315
         Left            =   8760
         TabIndex        =   7
         TabStop         =   0   'False
         ToolTipText     =   "Supplier Information"
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
         Picture         =   "frmStockRecEnhenced.frx":14D55
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdNewSupplier 
         Height          =   315
         Left            =   8400
         TabIndex        =   6
         TabStop         =   0   'False
         ToolTipText     =   "Add New Supplier"
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
         Picture         =   "frmStockRecEnhenced.frx":152E7
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdNewStaff 
         Height          =   315
         Left            =   3360
         TabIndex        =   3
         TabStop         =   0   'False
         ToolTipText     =   "Add New Staff"
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
         Picture         =   "frmStockRecEnhenced.frx":158B5
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label6 
         Caption         =   "Particular"
         Height          =   255
         Left            =   4320
         TabIndex        =   18
         Top             =   1020
         Width           =   855
      End
      Begin VB.Label Label3 
         Caption         =   "Invoice Number"
         Height          =   255
         Left            =   4320
         TabIndex        =   17
         Top             =   660
         Width           =   1215
      End
      Begin VB.Label Label1 
         Caption         =   "Supplier Name"
         Height          =   255
         Left            =   4320
         TabIndex        =   16
         Top             =   300
         Width           =   1215
      End
      Begin VB.Label Label10 
         Caption         =   "Purchase Order Number"
         Height          =   375
         Left            =   120
         TabIndex        =   14
         Top             =   1020
         Width           =   1095
      End
      Begin VB.Label Label9 
         Caption         =   "Received by"
         Height          =   255
         Left            =   120
         TabIndex        =   13
         Top             =   660
         Width           =   975
      End
      Begin VB.Label Label8 
         Caption         =   "Received on"
         Height          =   255
         Left            =   120
         TabIndex        =   12
         Top             =   300
         Width           =   1095
      End
   End
   Begin Threed.SSFrame fraMiniTools 
      Height          =   615
      Left            =   120
      TabIndex        =   15
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
      Begin Threed.SSCommand cmdLSPWizard 
         Height          =   315
         Left            =   1560
         TabIndex        =   22
         TabStop         =   0   'False
         ToolTipText     =   "LSP Wizard"
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
         Picture         =   "frmStockRecEnhenced.frx":15E83
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdMarkdownByDollar 
         Height          =   315
         Left            =   1080
         TabIndex        =   21
         TabStop         =   0   'False
         ToolTipText     =   "Markdown in $"
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
         Picture         =   "frmStockRecEnhenced.frx":163D5
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdMarkdownByPercentage 
         Height          =   315
         Left            =   600
         TabIndex        =   20
         TabStop         =   0   'False
         ToolTipText     =   "Markdown in %"
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
         Picture         =   "frmStockRecEnhenced.frx":168AB
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdCalculator 
         Height          =   315
         Left            =   120
         TabIndex        =   19
         TabStop         =   0   'False
         ToolTipText     =   "Calculator"
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
         Picture         =   "frmStockRecEnhenced.frx":16D75
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin Threed.SSFrame fraTotal 
      Height          =   1335
      Left            =   6480
      TabIndex        =   23
      Top             =   6060
      Width           =   4395
      _ExtentX        =   7752
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
      Caption         =   "Total"
      Begin MSMask.MaskEdBox mskNetPurchase 
         Height          =   255
         Left            =   2940
         TabIndex        =   37
         Top             =   240
         Width           =   1275
         _ExtentX        =   2249
         _ExtentY        =   450
         _Version        =   393216
         BackColor       =   8454143
         Enabled         =   0   'False
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
      Begin VB.TextBox txtTotalQty 
         Alignment       =   1  'Right Justify
         BackColor       =   &H0000FFFF&
         Height          =   285
         Left            =   480
         MultiLine       =   -1  'True
         TabIndex        =   25
         TabStop         =   0   'False
         Top             =   240
         Width           =   495
      End
      Begin MSMask.MaskEdBox mskTotalTax 
         Height          =   255
         Left            =   2940
         TabIndex        =   38
         Top             =   480
         Width           =   1275
         _ExtentX        =   2249
         _ExtentY        =   450
         _Version        =   393216
         BackColor       =   8454143
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskFreight 
         Height          =   255
         Left            =   2940
         TabIndex        =   39
         Top             =   720
         Width           =   1275
         _ExtentX        =   2249
         _ExtentY        =   450
         _Version        =   393216
         BackColor       =   8454143
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskGrossPurchase 
         Height          =   255
         Left            =   2940
         TabIndex        =   40
         Top             =   960
         Width           =   1275
         _ExtentX        =   2249
         _ExtentY        =   450
         _Version        =   393216
         BackColor       =   8454143
         Enabled         =   0   'False
         Format          =   "$#,##0.00;($#,##0.00)"
         PromptChar      =   "_"
      End
      Begin VB.Label Label11 
         Caption         =   "Gross Purchase"
         Height          =   195
         Left            =   1620
         TabIndex        =   36
         Top             =   960
         Width           =   1215
      End
      Begin VB.Label Label7 
         Caption         =   "Freight"
         Height          =   195
         Left            =   1620
         TabIndex        =   35
         Top             =   720
         Width           =   795
      End
      Begin VB.Label Label5 
         Caption         =   "Total Tax"
         Height          =   255
         Left            =   1620
         TabIndex        =   34
         Top             =   480
         Width           =   1155
      End
      Begin VB.Label Label4 
         Caption         =   "Net Purchase"
         Height          =   255
         Left            =   1620
         TabIndex        =   33
         Top             =   240
         Width           =   1095
      End
      Begin VB.Label Label2 
         Caption         =   "Qty"
         Height          =   255
         Left            =   120
         TabIndex        =   24
         Top             =   240
         Width           =   495
      End
   End
End
Attribute VB_Name = "frmStockRecEnhanced"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim TxBody      As UnboundGrids ' TxBody grid data source
Dim mCurrentMode  As Integer         ' Current Edit Mode
Private Const mModeIdle     As Integer = 0
Private Const mModeAdd      As Integer = 1
Private Const mModeUndo     As Integer = 2
Private Const mModeSave     As Integer = 3
Private Const mModePrint    As Integer = 4
Private Const mModeBarCode  As Integer = 5
Dim mTxNumber  As String       ' Current Tx Number

Private Const mColIndexSKU As Integer = 1
Private Const mColIndexQty As Integer = 13
Private Const mColIndexUnitCost As Integer = 14
Private Const mColIndexMarkdownD As Integer = 15
Private Const mColIndexMarkdownP As Integer = 16
Private Const mColIndexTotalCost As Integer = 17
Private Const mColIndexLSP As Integer = 18

Private Const mButtonIndex_Add As Integer = 0
Private Const mButtonIndex_Undo As Integer = 1
Private Const mButtonIndex_Save As Integer = 2
Private Const mButtonIndex_Print As Integer = 3
Private Const mButtonIndex_BarCode As Integer = 4
Private Const mButtonIndex_FindSKU As Integer = 5
Private Const mButtonIndex_AddSKU As Integer = 6
Private Const mButtonIndex_Exit As Integer = 7


Private Sub cmdCalculator_Click()
    Dim RetVal As Variant
    RetVal = Shell("Calc.Exe", 1)
End Sub

Private Sub cmdLSPcancel_Click()
    fraLSPWizard.Enabled = False
    fraLSPWizard.Visible = False
End Sub

Private Sub cmdLSPok_Click()
    If optByQty.Value Then Call LSPwithFreightByQty
    If optByCost.Value Then Call LSPwithFreightByCost
    If optByUnitCost.Value Then Call LSPByUnitCost
    If optByNetCost.Value Then Call LSPByNetCost
    fraLSPWizard.Enabled = False
    fraLSPWizard.Visible = False
End Sub

Private Sub cmdLSPWizard_Click()
    fraLSPWizard.Visible = True
    fraLSPWizard.Enabled = True
    optByQty.SetFocus
End Sub

Private Sub cmdMarkdownByDollar_Click()
    ' Change TxBody to Markdown $
    dbgTxBody.Columns("Markdown $").Visible = True
    dbgTxBody.Columns("Markdown %").Visible = False
End Sub

Private Sub cmdMarkdownByPercentage_Click()
    ' Change TxBody to Markdown %
    dbgTxBody.Columns("Markdown $").Visible = False
    dbgTxBody.Columns("Markdown %").Visible = True
End Sub

Private Sub cmdNewStaff_Click()
    If ofx_IsFormLoaded(frmStaff) Then _
        Unload frmStaff
    Screen.MousePointer = vbHourglass
    frmStaff.Show vbModal
    dtcStaff.Refresh
    dtcStaff.UpdateControls
End Sub

Private Sub cmdNewSupplier_Click()
    If ofx_IsFormLoaded(frmSupplier) Then _
        Unload frmSupplier
    Screen.MousePointer = vbHourglass
    frmSupplier.Show vbModal
    dtcSupplier.Refresh
    dtcSupplier.UpdateControls
End Sub

Private Sub cmdSupplierInfo_Click()
    If ofx_IsFormLoaded(frmInfoSupplier) Then _
        Unload frmInfoSupplier
    Screen.MousePointer = vbHourglass
    frmInfoSupplier.Show vbModal
'    dbgTxBody.Columns("SKU").Value = Clipboard.GetText
End Sub

Private Sub dbgTxBody_AfterColUpdate(ByVal ColIndex As Integer)
    
    ' Calculate the Net Cost if Qty, Unit Cost, or Markdown is changed
    If dbgTxBody.Columns(ColIndex).Caption = "Qty" Or _
       dbgTxBody.Columns(ColIndex).Caption = "Unit Cost" Or _
       dbgTxBody.Columns(ColIndex).Caption = "Markdown $" Or _
       dbgTxBody.Columns(ColIndex).Caption = "Markdown %" Then
        CalcNetCost
    End If
    
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
    
    ' Varify the Unit Cost
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
    
End Sub

Private Sub dbgTxBody_ClassicAdd(NewRowBookmark As Variant, ByVal Col As Integer, Value As Variant)
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

Private Sub dbgTxBody_ClassicDelete(Bookmark As Variant)
    ' ClassicDelete is fired when the user deletes an
    ' existing row in the Unbound grid.  This event
    ' alerts the user that the program must delete the
    ' row specified by the Bookmark parameter from the
    ' dataset.  Here, an auxiliary function (DeleteRow)
    ' is used to do this.

    If Not DeleteRow(Bookmark, TxBody) Then Bookmark = Null
    Call RowNumberReset(TxBody)

End Sub


Private Sub dbgTxBody_ClassicRead(Bookmark As Variant, ByVal Col As Integer, Value As Variant)
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

Private Sub dbgTxBody_ClassicWrite(Bookmark As Variant, ByVal Col As Integer, Value As Variant)
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



Private Sub dbgTxBody_LostFocus()

    ' Calculate the Total Qty Received
    Call CalcTotals
    
End Sub

Private Sub dbgTxBody_RowColChange(LastRow As Variant, ByVal LastCol As Integer)
    Dim strDummy, strMessage As String
    
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
    Call SetColFocus(dbgTxBody, TxBody, LastRow, LastCol)
End Sub

Private Sub dbgTxBody_UnboundGetRelativeBookmark(StartLocation As Variant, ByVal OffSet As Long, NewLocation As Variant, ApproximatePosition As Long)
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









Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)

    ' Set Grid TXBody X-Y value
    TxBody.MaxCol = 19
    TxBody.MaxRow = 0
    ' Initialize TxTotal
    InitTxTotal
    
    
    Call SetMenuButton(mModeIdle)       ' Disable some of the buttons
    Call SetProtectedArea(mModeIdle)    ' Protect input area
    SetEditMode (mModeIdle)             ' Default Edit Mode as Clear at the beginning
    
    ' Default TxBody uses Markdown %
    dbgTxBody.Columns("Markdown $").Visible = False
    
    ' Only enable ToolBar
    Call FrameDisable
End Sub



Private Sub CalcNetCost()
    ' Calculate the NetCost
    Dim intQty      As Integer
    Dim curUnitCost As Currency
    Dim curMarkDnD  As Currency
    Dim curMarkDnP  As Currency
    Dim curNetCost  As Currency
    
    intQty = dbgTxBody.Columns("Qty").Value
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

End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

' Calculate the Net Purchase by adding all Net Cost
Private Function CalcNetPurchase() As Currency

    Dim i As Integer
    Dim curNetPurchase As Currency
    
    For i = 0 To (TxBody.MaxRow - 1)
        curNetPurchase = ofx_CCur(TxBody.GridArray(mColIndexTotalCost, i)) + curNetPurchase
    Next i
    CalcNetPurchase = curNetPurchase
    
End Function

' Calculate the Gross Purchase
Private Function CalcGrossPurchase() As Currency
    Dim curNetPurchase, curTotalTax, curOtherCharges As Currency
    Dim curGrossPurchase As Currency
    curNetPurchase = ofx_CCur(mskNetPurchase)
    curTotalTax = ofx_CCur(mskTotalTax)
    curOtherCharges = ofx_CCur(mskFreight)
    CalcGrossPurchase = (curNetPurchase + curTotalTax + curOtherCharges)
End Function

' Clear TxTotal columns and set first column lable names
Private Sub InitTxTotal()
    ' Set all zero
    mskNetPurchase = 0
    mskTotalTax = 0
    mskFreight = 0
    mskGrossPurchase = 0
    mskNetPurchase.Refresh
    mskTotalTax.Refresh
    mskFreight.Refresh
    mskGrossPurchase.Refresh
End Sub

Private Function CalcTotalQty() As Integer
    Dim i As Integer
    Dim intTotalQty As Integer

    For i = 0 To (TxBody.MaxRow - 1)
        intTotalQty = ofx_CInt(TxBody.GridArray(mColIndexQty, i)) + intTotalQty
    Next i
    CalcTotalQty = intTotalQty
End Function

Private Sub mskFreight_Change()
    CalcTotals
End Sub

Private Sub mskFreight_GotFocus()
    mskFreight.SelStart = 0
    mskFreight.SelLength = Len(mskTotalTax.Text)
End Sub

Private Sub mskTotalTax_Change()
    CalcTotals
End Sub

Private Sub mskTotalTax_GotFocus()
    mskTotalTax.SelStart = 0
    mskTotalTax.SelLength = Len(mskTotalTax.Text)
End Sub

Private Sub tbrStockReceived_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)
    Dim strPrefix As String
    Dim i As Integer
    
    ' Ignor Up clicks
    If Value = False Then Exit Sub
    
    With tbrStockReceived
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



' This subroutine would clear all the current entries
Private Sub ClearAllEntries()
    Dim i, j As Integer
    
    ' Clear TxHeader
    dbcStaffFullName.Text = ""
    txtPONumber.Text = ""
    dbcSupplierName.Text = ""
    txtInvoiceNumber.Text = ""
    txtParticular.Text = ""
    txtTotalQty.Text = ""
    
    ' Clear TxBody
    TxBody.MaxRow = 0
    ReDim TxBody.GridArray(0 To TxBody.MaxCol - 1, 0)
    dbgTxBody.Bookmark = Null
    dbgTxBody.ReBind
    
    ' Clear TxTotal
    InitTxTotal
    
    ' Reset Current Tx Number to Null
    mTxNumber = ""
End Sub


Private Sub SaveEntries()
    Dim MyControlNumber As String
    Dim curNetPurchase, curTotalTax, curOtherCharges, curGrossPurchase As Currency
    Dim i As Integer
    Dim MyWS As Workspace
    Dim myDB As Database
    Dim TxHeader, TxDetails, TxSalePerson As Recordset
    Dim MyCriteria As String
    
    ' Make sure there's total qty calculated
    Call CalcTotals
    
    ' Start prepare to update entries
    ' Updates the TxHeader, TxDetails, and TxSalePerson
    Screen.MousePointer = vbHourglass
    MyCriteria = "SKU = '" & " " & "'"      ' Set the criteria.
    MyControlNumber = GetNextControlNumber
    mTxNumber = GetNextTxNumber("SR")
    curNetPurchase = ofx_CCur(mskNetPurchase)
    curTotalTax = ofx_CCur(mskTotalTax)
    curOtherCharges = ofx_CCur(mskFreight)
    curGrossPurchase = ofx_CCur(mskGrossPurchase)
    
    '
    ' Write entries into Tx files and pass control to OLTP for posting
    '
    Set MyWS = Workspaces(0)
    Set myDB = MyWS.OpenDatabase("SynergyV.mdb")                           ' Open database
    Set TxHeader = myDB.OpenRecordset("TxHeader", dbOpenDynaset, dbAppendOnly, dbOptimistic)      ' Open table for append only
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbAppendOnly, dbOptimistic)    ' Open table for append only
    Set TxSalePerson = myDB.OpenRecordset("TxSalePerson", dbOpenDynaset, dbAppendOnly, dbOptimistic)      ' Open table for append only
    '
    'On Error GoTo RollbackSaveEntries
'    MyWS.BeginTrans
    ' Write TxHeader
    TxHeader.AddNew
    TxHeader!ControlNumber = MyControlNumber
    TxHeader!TxType = Left(mTxNumber, 2)
    TxHeader!TxNumber = mTxNumber
    TxHeader!DateOfEntry = calTxDate.Text
    TxHeader!DateOfCreation = Now
    TxHeader!RefNumber = txtInvoiceNumber.Text
    TxHeader!TrackingNumber = txtPONumber.Text
    TxHeader!Particulars = txtParticular.Text
    TxHeader!SupplierCode = dbcSupplierName.BoundText
    TxHeader!TotalCost = curNetPurchase
    TxHeader!TaxA = curTotalTax
    TxHeader!OtherCharges = curOtherCharges
    TxHeader!GrossSale = curGrossPurchase
    TxHeader!TotalAmount = curGrossPurchase
    TxHeader!TotalQty = ofx_CInt(txtTotalQty.Text)
    TxHeader.Update
    ' Write TxSalePerson
    TxSalePerson.AddNew
    TxSalePerson!TxNumber = mTxNumber
    TxSalePerson!SalesRowNo = 1
    TxSalePerson!StaffCode = dbcStaffFullName.BoundText
    TxSalePerson.Update
    ' Write TxDetails
    For i = 0 To TxBody.MaxRow - 1
        If TxBody.GridArray(0, i) <> "" Then
            TxDetails.AddNew
            TxDetails!ControlNumber = MyControlNumber
            TxDetails!TxType = Left(mTxNumber, 2)
            TxDetails!TxNumber = mTxNumber
            TxDetails!DateOfEntry = calTxDate.Text
            TxDetails!RowNo = (i + 1)
            TxDetails!SKU = TxBody.GridArray(mColIndexSKU, i)
            TxDetails!Qty = ofx_CInt(TxBody.GridArray(mColIndexQty, i))
            TxDetails!UnitCost = ofx_CCur(TxBody.GridArray(mColIndexUnitCost, i))
            TxDetails!MarkDownAmount = ofx_CCur(TxBody.GridArray(mColIndexMarkdownD, i))
            TxDetails!MarkDownPercent = ofx_CSng(TxBody.GridArray(mColIndexMarkdownP, i))
            TxDetails!Amount = ofx_CCur(TxBody.GridArray(mColIndexTotalCost, i))
            TxDetails!UnitLSP = ofx_CCur(TxBody.GridArray(mColIndexLSP, i))
            TxDetails.Update
        End If
    Next i
    '
'    MyWS.CommitTrans
    TxSalePerson.Close
    TxHeader.Close
    TxDetails.Close
    myDB.Close
    ' Activate OLTP to post transaction
    OLTP_IC (mTxNumber)
    
    '
    Screen.MousePointer = vbDefault
    ofx_DoMessageBox "Save is done." & Chr$(13) & _
                     "Please stamp your document with the Tx Number: " & mTxNumber & Chr(13) & _
                     "for later reference."
    Exit Sub

RollbackSaveEntries:
'    MyWS.Rollback
    Screen.MousePointer = vbDefault
    ofx_DoMessageBox "Error Detected.  Current Save was aborted."
    Exit Sub
End Sub







Private Sub SetEditMode(CurrentMode As Integer)
    mCurrentMode = CurrentMode
    Call SetMenuButton(CurrentMode)
End Sub

Private Sub FrameEnable()
    fraHeader.Enabled = True
    fraMiniTools.Enabled = True
    fraTotal.Enabled = True
    dbgTxBody.Enabled = True
End Sub

Private Sub FrameDisable()
    fraHeader.Enabled = False
    fraMiniTools.Enabled = False
    fraTotal.Enabled = False
    dbgTxBody.Enabled = False
End Sub

Private Sub FillPLU()
    Dim myCol As Columns
    Dim strDummy, strSQL, strPrompt As String

    Set myCol = dbgTxBody.Columns
    
    ' Find the SKU for this line
    ' If not found then terminate sub
    If Not LookupPLU(myCol("SKU")) Then
        MsgBox "Invalid SKU!"
        Exit Sub
    End If
    
    With dtcInventory.Recordset
        ' Warn the operator if the default supplier of the Inventory
        ' no equals the Supplier in the header
        If !SupplierName <> dbcSupplierName Then
            strPrompt = "Warning!" & Chr(13) & Chr(13) & _
                        "This is to remind you that," & Chr(13) & _
                        "the Original Supplier of SKU " & !SKU & Chr(13) & _
                        "is not the current supplier."
' 20030725 remove warning, requested by customer
'            strDummy = MsgBox(strPrompt, vbExclamation)
        End If
    
        ' Fill the PLU for this line
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
        myCol("Unit Cost") = !AverageCost
        myCol("Total Cost") = !AverageCost
        myCol("LSP") = !LeastSellingPrice
    End With
End Sub



' Distribute the freight into LSP
' proportionate by TotalCost
Private Sub LSPwithFreightByCost()
    Dim curFreight As Currency
    Dim curNetPurchase As Currency
    Dim curTotalCost As Currency
    Dim curLSP As Currency
    Dim intQty As Integer
    Dim i As Integer
    
    curFreight = ofx_CCur(mskFreight)
    curNetPurchase = ofx_CCur(mskNetPurchase)
    If curFreight = 0 Then Exit Sub
    
    For i = 0 To TxBody.MaxRow - 1
        If TxBody.GridArray(0, i) <> "" Then
            intQty = ofx_CCur(TxBody.GridArray(mColIndexQty, i))
            curTotalCost = ofx_CCur(TxBody.GridArray(mColIndexTotalCost, i))
            curLSP = ofx_CCur(TxBody.GridArray(mColIndexLSP, i))
            '
            curLSP = (curLSP + _
                    ((curTotalCost * curFreight) / (curNetPurchase * intQty)))
            curLSP = Format(curLSP, "####0.00")
            TxBody.GridArray(mColIndexLSP, i) = curLSP
        End If
    Next i
    dbgTxBody.Refresh
End Sub

Private Sub LSPwithFreightByQty()
    Dim curFreight As Currency
    Dim intQty As Integer
    Dim intTotalQty As Integer
    Dim curLSP As Currency
    Dim i As Integer
    
    curFreight = ofx_CCur(mskFreight)
    intTotalQty = txtTotalQty
    If curFreight = 0 Then Exit Sub
    
    For i = 0 To TxBody.MaxRow - 1
        If TxBody.GridArray(0, i) <> "" Then
            intQty = ofx_CCur(TxBody.GridArray(mColIndexQty, i))
            curLSP = ofx_CCur(TxBody.GridArray(mColIndexLSP, i))
            '
            curLSP = (curLSP + (curFreight / intTotalQty))
            curLSP = Format(curLSP, "####0.00")
            TxBody.GridArray(mColIndexLSP, i) = curLSP
        End If
    Next i
    dbgTxBody.Refresh
End Sub

Private Sub LSPByUnitCost()
    Dim curUnitCost As Currency
    Dim i As Integer
    
    For i = 0 To TxBody.MaxRow - 1
        If TxBody.GridArray(0, i) <> "" Then
            curUnitCost = ofx_CCur(TxBody.GridArray(mColIndexUnitCost, i))
            '
            TxBody.GridArray(mColIndexLSP, i) = curUnitCost
        End If
    Next i
    dbgTxBody.Refresh
End Sub

Private Sub LSPByNetCost()
    Dim curLSP As Currency
    Dim curTotalCost As Currency
    Dim intQty As Integer
    Dim i As Integer
    
    For i = 0 To TxBody.MaxRow - 1
        If TxBody.GridArray(0, i) <> "" Then
            intQty = ofx_CCur(TxBody.GridArray(mColIndexQty, i))
            curTotalCost = ofx_CCur(TxBody.GridArray(mColIndexTotalCost, i))
            '
            curLSP = (curTotalCost / intQty)
            TxBody.GridArray(mColIndexLSP, i) = curLSP
        End If
    Next i
    dbgTxBody.Refresh
End Sub

Private Sub SetMenuButton(intMode As Integer)
    With tbrStockReceived
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
            .Buttons(mButtonIndex_BarCode).Enabled = True
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

' Caller past the target SKU
' Function search the Table for the matched SKU
Private Function LookupPLU(mySKU As String) As Boolean
    Dim strSQL As String
    
    If IsEmpty(mySKU) Or IsNull(mySKU) Then
        LookupPLU = False
    Else
        strSQL = "SELECT * FROM [Inventory Query] " & _
                 "WHERE SKU = '" & mySKU & "'"
        With dtcInventory
            .RecordSource = strSQL
            .Refresh
            If IsTableEmpty(.Recordset) Then
                LookupPLU = False
            Else
                LookupPLU = True
            End If
        End With
    End If
End Function




Private Sub CalcTotals()
    ' Calculate the Total Qty Received
    txtTotalQty = CalcTotalQty
    ' Calculate the total amounts
    mskNetPurchase = CalcNetPurchase
    mskGrossPurchase = CalcGrossPurchase        ' mskNetPurchase + mskTotalTax + mskFreight
    '
    fraTotal.Refresh
End Sub

Private Sub DoAdd()
    Call SetEditMode(mModeAdd)
    Call SetMenuButton(mModeAdd)
    Call SetProtectedArea(mModeAdd)
    FrameEnable
    ClearAllEntries
End Sub

Private Sub DoUndo()
    Call SetEditMode(mModeUndo)
    Call SetMenuButton(mModeUndo)
    Call SetProtectedArea(mModeUndo)
    ClearAllEntries
    FrameDisable
End Sub

Private Sub DoSave()
    Dim strDummy, strMessage As String
    
    ' Varify some important entries
    ' If anyone failed, stop Save
    ' 1. Staff  2. Supplier  3. Grid Empty  4. Grid Editing
    If Not IsFound("Staff", "StaffFullName", dbcStaffFullName.Text, vbYes) Or _
       Not IsFound("Supplier", "SupplierName", dbcSupplierName.Text, vbYes) Or _
       IsGridEmpty(dbgTxBody, vbYes) Or _
       IsGridEditing(dbgTxBody, vbYes) Then
        Call SetEditMode(mModeAdd)
        strMessage = "After corrected the error(s)," & Chr(13) & _
                     "toggle the Save button to resume Save."
        strDummy = MsgBox(strMessage, vbInformation)
        Exit Sub
    End If
    
    Call SetEditMode(mModeSave)
    Call SetMenuButton(mModeSave)
    SaveEntries
    FrameDisable
End Sub

Private Sub DoPrint()
    Dim strPrefix As String
    
    RptTxNumberFrom = mTxNumber
    strPrefix = Left(mTxNumber, 2)
    Call PrintStockTrans(strPrefix, 1, 0)
End Sub

Private Sub DoBarCode()
    RptTxNumberFrom = mTxNumber
    Call PrintBarCode(1, 1)
    Call SetMenuButton(mModeBarCode)
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

Private Sub DoAddSKU()
    Clipboard.Clear
    If ofx_IsFormLoaded(frmInvt) Then _
        Unload frmInvt
    Screen.MousePointer = vbHourglass
    frmInvt.Show vbModal
    If IsNull(Clipboard.GetText) Or Clipboard.GetText = "" Then
    Else
        dbgTxBody.Columns("SKU").Value = Clipboard.GetText
        Call FillPLU
    End If
End Sub

Private Sub SetProtectedArea(iMode As Integer)
    Select Case iMode
    Case mModeIdle
        fraHeader.Enabled = False
        fraMiniTools.Enabled = False
        fraTotal.Enabled = False
    Case mModeAdd
        fraHeader.Enabled = True
        fraMiniTools.Enabled = True
        fraTotal.Enabled = True
    Case mModeUndo
        Call SetProtectedArea(mModeIdle)
    End Select
End Sub

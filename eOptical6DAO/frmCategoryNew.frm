VERSION 4.00
Begin VB.Form frmCategoryNew 
   Caption         =   "Category New"
   ClientHeight    =   5535
   ClientLeft      =   1545
   ClientTop       =   2640
   ClientWidth     =   8895
   Height          =   5940
   Left            =   1485
   LinkTopic       =   "Form1"
   ScaleHeight     =   5535
   ScaleWidth      =   8895
   Top             =   2295
   Width           =   9015
   Begin VB.TextBox Text1 
      Height          =   285
      Left            =   1320
      TabIndex        =   14
      Text            =   "Text1"
      Top             =   2280
      Width           =   1935
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   8895
      _Version        =   131073
      _ExtentX        =   15690
      _ExtentY        =   1906
      _StockProps     =   69
      BackColor       =   12632256
      FloatingCaption =   "SSToolbar1"
      AlreadyCreated  =   -1  'True
      Outline         =   0   'False
      ToolsetNumBtnStates=   3
      Btns            =   9
      ToolsetPicture  =   "frmCategoryNew.frx":0000
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
      MouseIcon       =   "frmCategoryNew.frx":1B452
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   2775
      Left            =   120
      TabIndex        =   8
      Top             =   2640
      Width           =   8655
      _Version        =   65536
      _ExtentX        =   15266
      _ExtentY        =   4895
      _StockProps     =   14
      Caption         =   "Review"
      Begin TrueDBGrid.TDBGrid TDBGrid1 
         Height          =   1695
         Left            =   120
         OleObjectBlob   =   "frmCategoryNew.frx":1B46E
         TabIndex        =   22
         Top             =   960
         Width           =   8415
      End
      Begin Threed.SSCommand SSCommand2 
         Height          =   375
         Left            =   2760
         TabIndex        =   21
         Top             =   480
         Width           =   375
         _Version        =   65536
         _ExtentX        =   661
         _ExtentY        =   661
         _StockProps     =   78
         Caption         =   "SSCommand2"
      End
      Begin Threed.SSCommand SSCommand1 
         Height          =   375
         Left            =   120
         TabIndex        =   20
         Top             =   480
         Width           =   375
         _Version        =   65536
         _ExtentX        =   661
         _ExtentY        =   661
         _StockProps     =   78
         Caption         =   "SSCommand1"
      End
      Begin MSDBCtls.DBCombo DBCombo7 
         Height          =   315
         Left            =   3120
         TabIndex        =   19
         Top             =   480
         Width           =   1695
         _Version        =   65536
         _ExtentX        =   2990
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
      End
      Begin MSDBCtls.DBCombo DBCombo6 
         Height          =   315
         Left            =   480
         TabIndex        =   18
         Top             =   480
         Width           =   1695
         _Version        =   65536
         _ExtentX        =   2990
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
      End
      Begin VB.Label Label9 
         Caption         =   "Class"
         Height          =   255
         Left            =   2760
         TabIndex        =   10
         Top             =   240
         Width           =   495
      End
      Begin VB.Label Label8 
         Caption         =   "Department"
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   240
         Width           =   855
      End
   End
   Begin MSDBCtls.DBCombo DBCombo5 
      Height          =   315
      Left            =   5520
      TabIndex        =   17
      Top             =   2280
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   556
      _StockProps     =   77
      ForeColor       =   0
      BackColor       =   16777215
   End
   Begin MSDBCtls.DBCombo DBCombo4 
      Height          =   315
      Left            =   5520
      TabIndex        =   16
      Top             =   1920
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   556
      _StockProps     =   77
      ForeColor       =   0
      BackColor       =   16777215
   End
   Begin MSDBCtls.DBCombo DBCombo3 
      Height          =   315
      Left            =   5520
      TabIndex        =   15
      Top             =   1560
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   556
      _StockProps     =   77
      ForeColor       =   0
      BackColor       =   16777215
   End
   Begin MSMask.MaskEdBox MaskEdBox1 
      Height          =   255
      Left            =   1320
      TabIndex        =   13
      Top             =   1920
      Width           =   375
      _Version        =   65536
      _ExtentX        =   661
      _ExtentY        =   450
      _StockProps     =   109
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
   End
   Begin MSDBCtls.DBCombo DBCombo2 
      Height          =   315
      Left            =   1320
      TabIndex        =   12
      Top             =   1560
      Width           =   1935
      _Version        =   65536
      _ExtentX        =   3413
      _ExtentY        =   556
      _StockProps     =   77
      ForeColor       =   0
      BackColor       =   16777215
   End
   Begin MSDBCtls.DBCombo DBCombo1 
      Height          =   315
      Left            =   1320
      TabIndex        =   11
      Top             =   1200
      Width           =   1935
      _Version        =   65536
      _ExtentX        =   3413
      _ExtentY        =   556
      _StockProps     =   77
      ForeColor       =   0
      BackColor       =   16777215
   End
   Begin VB.Label Label7 
      Caption         =   "Tax Method"
      Height          =   255
      Left            =   4080
      TabIndex        =   7
      Top             =   2280
      Width           =   975
   End
   Begin VB.Label Label6 
      Caption         =   "Inventory Method"
      Height          =   255
      Left            =   4080
      TabIndex        =   6
      Top             =   1920
      Width           =   1335
   End
   Begin VB.Label Label5 
      Caption         =   "Costing Method"
      Height          =   255
      Left            =   4080
      TabIndex        =   5
      Top             =   1560
      Width           =   1215
   End
   Begin VB.Label Label4 
      Caption         =   "Category Name"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   2280
      Width           =   1095
   End
   Begin VB.Label Label3 
      Caption         =   "Category Code"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   1920
      Width           =   1095
   End
   Begin VB.Label Label2 
      Caption         =   "Class"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   1560
      Width           =   495
   End
   Begin VB.Label Label1 
      Caption         =   "Department"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   1200
      Width           =   975
   End
End
Attribute VB_Name = "frmCategoryNew"
Attribute VB_Creatable = False
Attribute VB_Exposed = False

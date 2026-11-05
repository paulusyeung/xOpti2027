VERSION 5.00
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmStockTxfer 
   Caption         =   "Stock Transfer"
   ClientHeight    =   5505
   ClientLeft      =   2505
   ClientTop       =   2115
   ClientWidth     =   6360
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5505
   ScaleWidth      =   6360
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Height          =   2655
      Left            =   120
      OleObjectBlob   =   "frmStockTxfer.frx":0000
      TabIndex        =   10
      Top             =   2040
      Width           =   6255
   End
   Begin VB.TextBox Text1 
      Height          =   285
      Left            =   1800
      TabIndex        =   12
      Text            =   "Text1"
      Top             =   4920
      Width           =   615
   End
   Begin VB.ComboBox Combo4 
      Height          =   315
      Left            =   1320
      TabIndex        =   9
      Text            =   "Combo4"
      Top             =   1200
      Width           =   4335
   End
   Begin VB.ComboBox Combo3 
      Height          =   315
      Left            =   1320
      TabIndex        =   8
      Text            =   "Combo3"
      Top             =   1560
      Width           =   4335
   End
   Begin VB.ComboBox Combo2 
      Height          =   315
      Left            =   1320
      TabIndex        =   5
      Text            =   "Combo2"
      Top             =   840
      Width           =   1215
   End
   Begin VB.ComboBox Combo1 
      Height          =   315
      ItemData        =   "frmStockTxfer.frx":169C
      Left            =   1320
      List            =   "frmStockTxfer.frx":16A6
      TabIndex        =   3
      Text            =   "Transfer In"
      Top             =   480
      Width           =   1215
   End
   Begin SSCalendarWidgets_A.SSDateCombo SSDateCombo1 
      Height          =   255
      Left            =   1320
      TabIndex        =   1
      Top             =   120
      Width           =   1455
      _Version        =   65537
      _ExtentX        =   2566
      _ExtentY        =   450
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
   Begin VB.Label Label6 
      Caption         =   "Total Qty"
      Height          =   255
      Left            =   1080
      TabIndex        =   11
      Top             =   4920
      Width           =   735
   End
   Begin VB.Label Label5 
      Caption         =   "Caller Staff"
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   1560
      Width           =   1095
   End
   Begin VB.Label Label4 
      Caption         =   "Branch Name"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   1200
      Width           =   1095
   End
   Begin VB.Label Label3 
      Caption         =   "Branch Number"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   840
      Width           =   1215
   End
   Begin VB.Label Label2 
      Caption         =   "Flow"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   480
      Width           =   855
   End
   Begin VB.Label Label1 
      Caption         =   "Transfer on"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   975
   End
End
Attribute VB_Name = "frmStockTxfer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub


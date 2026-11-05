VERSION 5.00
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmMenuOLAP 
   BorderStyle     =   0  'None
   Caption         =   "OLAP"
   ClientHeight    =   3330
   ClientLeft      =   2595
   ClientTop       =   2940
   ClientWidth     =   6000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3330
   ScaleWidth      =   6000
   ShowInTaskbar   =   0   'False
   Begin Threed.SSFrame fraDateSelector 
      Height          =   1455
      Left            =   240
      TabIndex        =   3
      Top             =   120
      Width           =   5535
      _ExtentX        =   9763
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
      Caption         =   "Date Selector"
      Begin SSCalendarWidgets_A.SSDateCombo calToDate 
         Height          =   315
         Left            =   3480
         TabIndex        =   8
         Top             =   900
         Width           =   1815
         _Version        =   65543
         _ExtentX        =   3201
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
         Format          =   "DD, MMMM, YYYY"
         SpinButton      =   0
         ShowCentury     =   -1  'True
      End
      Begin SSCalendarWidgets_A.SSDateCombo calFromDate 
         Height          =   315
         Left            =   3480
         TabIndex        =   6
         Top             =   420
         Width           =   1815
         _Version        =   65543
         _ExtentX        =   3201
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
         Format          =   "DD, MMMM, YYYY"
         SpinButton      =   0
         ShowCentury     =   -1  'True
      End
      Begin Threed.SSPanel SSPanel1 
         Height          =   1035
         Left            =   120
         TabIndex        =   4
         Top             =   300
         Width           =   2295
         _ExtentX        =   4048
         _ExtentY        =   1826
         _Version        =   131074
         CaptionStyle    =   1
         BackColor       =   16776960
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "Enter the period of interest first and then click on the Type of information that you want."
      End
      Begin VB.Label Label2 
         Caption         =   "To Date:"
         Height          =   255
         Left            =   2640
         TabIndex        =   7
         Top             =   900
         Width           =   735
      End
      Begin VB.Label Label1 
         Caption         =   "From Date:"
         Height          =   195
         Left            =   2640
         TabIndex        =   5
         Top             =   480
         Width           =   855
      End
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   1455
      Left            =   4080
      TabIndex        =   2
      Top             =   1680
      Width           =   1695
      _ExtentX        =   2990
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
      Caption         =   "Order In Progress"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   1455
      Left            =   2160
      TabIndex        =   1
      Top             =   1680
      Width           =   1695
      _ExtentX        =   2990
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
      Caption         =   "Sales by LSP"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   1455
      Left            =   240
      TabIndex        =   0
      Top             =   1680
      Width           =   1695
      _ExtentX        =   2990
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
      Caption         =   "Sales by Cost"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmMenuOLAP"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
    Call ofx_CenterForm(Me)
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub SSCommand1_Click()
    frmSales.Show
End Sub


Private Sub SSCommand1_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand2_Click()
    frmSalesByLSP.Show
End Sub


Private Sub SSCommand2_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand3_Click()
    frmOrderInProgress.Show
End Sub


Private Sub SSCommand4_Click()
    frmOLAPDateSelector.Show
End Sub

Private Sub SSCommand3_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

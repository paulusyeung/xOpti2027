VERSION 5.00
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmVoidRefundDate 
   Caption         =   "frmVoidRefundDate"
   ClientHeight    =   1965
   ClientLeft      =   1110
   ClientTop       =   1560
   ClientWidth     =   3660
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1965
   ScaleWidth      =   3660
   Begin VB.Frame Frame2 
      Caption         =   "Command"
      Height          =   830
      Left            =   120
      TabIndex        =   1
      Top             =   1000
      Width           =   3375
      Begin VB.CommandButton cmdCancel 
         Caption         =   "Cancel"
         Height          =   375
         Left            =   1850
         TabIndex        =   4
         Top             =   250
         Width           =   1200
      End
      Begin VB.CommandButton cmdOK 
         Caption         =   "OK"
         Height          =   375
         Left            =   360
         TabIndex        =   3
         Top             =   250
         Width           =   1200
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Void/Refund Date"
      Height          =   830
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   3375
      Begin SSCalendarWidgets_A.SSDateCombo calVoidOn 
         Height          =   375
         Left            =   120
         TabIndex        =   2
         Top             =   250
         Width           =   3135
         _Version        =   65543
         _ExtentX        =   5530
         _ExtentY        =   661
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
         MinDate         =   "1996/1/1"
         MaxDate         =   "2030/12/31"
         Format          =   "MMMM DD, YYYY"
      End
   End
End
Attribute VB_Name = "frmVoidRefundDate"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdCancel_Click()
    pyVoidRefundDate = #1/1/1900#
    Call ofx_CloseForm(frmVoidRefundDate)
End Sub

Private Sub cmdOK_Click()
    pyVoidRefundDate = calVoidOn.DateValue
    Call ofx_CloseForm(frmVoidRefundDate)
End Sub


Private Sub Form_Load()
    Call ofx_CenterForm(Me)
    Screen.MousePointer = vbDefault
    Me.Caption = "Void/Refund Date"
    Me.Icon = LoadPicture(SynergyIcon)
    With calVoidOn
        .MaxDate = Date
    End With
End Sub



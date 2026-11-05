VERSION 5.00
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Begin VB.Form frmMenuInfo 
   BorderStyle     =   0  'None
   Caption         =   "Information Centre"
   ClientHeight    =   4050
   ClientLeft      =   1755
   ClientTop       =   3120
   ClientWidth     =   6555
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4050
   ScaleWidth      =   6555
   ShowInTaskbar   =   0   'False
   Begin Threed.SSCommand SSCommand4 
      Height          =   1455
      Left            =   240
      TabIndex        =   3
      Top             =   2040
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
      Caption         =   "Order Planner"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   1455
      Left            =   4320
      TabIndex        =   2
      Top             =   240
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
      Caption         =   "Customer Info"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   1455
      Left            =   2280
      TabIndex        =   1
      Top             =   240
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
      Caption         =   "Supplier Info"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   1455
      Left            =   240
      TabIndex        =   0
      Top             =   240
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
      Caption         =   "SKU Info"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmMenuInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
'    Call ofx_RestoreFormPosition(Me, True)
    Call ofx_CenterForm(Me)
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call ofx_SaveFormPosition(Me)
    Call ofx_CloseForm(Me)
End Sub

Private Sub SSCommand1_Click()
    If ofx_IsFormLoaded(frmInfoSKU) Then
        frmInfoSKU.SetFocus
        SendKeys "% R", True
        frmInfoSKU.ZOrder
    Else
        Screen.MousePointer = vbHourglass
        frmInfoSKU.Show
    End If
End Sub


Private Sub SSCommand1_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand2_Click()
    If ofx_IsFormLoaded(frmInfoSupplier) Then
        frmInfoSupplier.SetFocus
        SendKeys "% R", True
        frmInfoSupplier.ZOrder
    Else
        Screen.MousePointer = vbHourglass
        frmInfoSupplier.Show
    End If
End Sub


Private Sub SSCommand2_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand3_Click()
    If ofx_IsFormLoaded(frmInfoCustomer) Then
        frmInfoCustomer.SetFocus
        SendKeys "% R", True
        frmInfoCustomer.ZOrder
    Else
        Screen.MousePointer = vbHourglass
        frmInfoCustomer.Show
    End If
End Sub


Private Sub SSCommand3_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand4_Click()

    If ofx_IsFormLoaded(frmInfoOrderPlanner) Then
        frmInfoOrderPlanner.SetFocus
        SendKeys "% R", True
        frmInfoOrderPlanner.ZOrder
    Else
        Screen.MousePointer = vbHourglass
        frmInfoOrderPlanner.Show
    End If

End Sub


Private Sub SSCommand4_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

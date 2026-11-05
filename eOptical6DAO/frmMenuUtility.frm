VERSION 5.00
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#1.0#0"; "THREED32.OCX"
Begin VB.Form frmMenuUtility 
   BorderStyle     =   0  'None
   Caption         =   "Utility Menu"
   ClientHeight    =   3495
   ClientLeft      =   2610
   ClientTop       =   3975
   ClientWidth     =   6045
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3495
   ScaleWidth      =   6045
   ShowInTaskbar   =   0   'False
   Begin VB.PictureBox Transparent1 
      Height          =   420
      Left            =   8760
      ScaleHeight     =   360
      ScaleWidth      =   360
      TabIndex        =   0
      Top             =   5340
      Visible         =   0   'False
      Width           =   420
   End
   Begin Threed.SSCommand SSCommand6 
      Height          =   1455
      Left            =   4080
      TabIndex        =   6
      Top             =   1860
      Width           =   1695
      _Version        =   65536
      _ExtentX        =   2990
      _ExtentY        =   2566
      _StockProps     =   78
      Caption         =   "&Build Summary"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand5 
      Height          =   1455
      Left            =   2160
      TabIndex        =   5
      Top             =   1860
      Width           =   1695
      _Version        =   65536
      _ExtentX        =   2990
      _ExtentY        =   2566
      _StockProps     =   78
      Caption         =   "Data &Import"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand4 
      Height          =   1455
      Left            =   4080
      TabIndex        =   4
      Top             =   180
      Width           =   1695
      _Version        =   65536
      _ExtentX        =   2990
      _ExtentY        =   2566
      _StockProps     =   78
      Caption         =   "System Profile"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   1455
      Left            =   2160
      TabIndex        =   3
      Top             =   180
      Width           =   1695
      _Version        =   65536
      _ExtentX        =   2990
      _ExtentY        =   2566
      _StockProps     =   78
      Caption         =   "&Special Reports"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   1455
      Left            =   240
      TabIndex        =   2
      Top             =   1860
      Width           =   1695
      _Version        =   65536
      _ExtentX        =   2990
      _ExtentY        =   2566
      _StockProps     =   78
      Caption         =   "&Data Convertion"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   1455
      Left            =   240
      TabIndex        =   1
      Top             =   180
      Width           =   1695
      _Version        =   65536
      _ExtentX        =   2990
      _ExtentY        =   2566
      _StockProps     =   78
      Caption         =   "&Check Table Integrity"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmMenuUtility"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
End Sub


Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub SSCommand1_Click()
    If ofx_IsFormLoaded(frmUtilCheckTable) Then
        Unload frmUtilCheckTable
    End If
    Screen.MousePointer = vbHourglass
    frmUtilCheckTable.Show vbModal
End Sub


Private Sub SSCommand1_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand2_Click()
    
    If ofx_IsFormLoaded(frmUtilDataConvertion) Then
        Unload frmUtilDataConvertion
    End If
    Screen.MousePointer = vbHourglass
    frmUtilDataConvertion.Show vbModal

End Sub


Private Sub SSCommand2_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand3_Click()
    If ofx_IsFormLoaded(frmSpecialReports) Then
        Unload frmSpecialReports
    End If
    Screen.MousePointer = vbHourglass
    frmSpecialReports.Show vbModal
End Sub


Private Sub SSCommand3_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand4_Click()
    
    If ofx_IsFormLoaded(frmSystemProfile) Then
        frmSystemProfile.SetFocus
        frmSystemProfile.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmSystemProfile.Show
    End If

End Sub


Private Sub SSCommand4_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand5_Click()
    
    If ofx_IsFormLoaded(frmUtilDataImport) Then
        Unload frmUtilDataImport
    End If
    Screen.MousePointer = vbHourglass
    frmUtilDataImport.Show vbModal


End Sub


Private Sub SSCommand5_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand6_Click()
    
    If ofx_IsFormLoaded(frmUtilDataSum) Then
        Unload frmUtilDataSum
    End If
    Screen.MousePointer = vbHourglass
    frmUtilDataSum.Show vbModal


End Sub


Private Sub SSCommand6_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call SetCursorToHand
End Sub

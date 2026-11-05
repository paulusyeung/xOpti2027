VERSION 5.00
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Begin VB.Form frmMenuPreference 
   BorderStyle     =   0  'None
   Caption         =   "Preference"
   ClientHeight    =   4770
   ClientLeft      =   1425
   ClientTop       =   1950
   ClientWidth     =   6180
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4770
   ScaleWidth      =   6180
   ShowInTaskbar   =   0   'False
   Begin Threed.SSCommand SSCommand1 
      Height          =   1575
      Left            =   2160
      TabIndex        =   7
      Top             =   3180
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Special Report"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand8 
      Height          =   1575
      Left            =   120
      TabIndex        =   6
      Top             =   3180
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Security"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand7 
      Height          =   1515
      Left            =   4200
      TabIndex        =   5
      Top             =   1620
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2672
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
      Caption         =   "Salutation"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand6 
      Height          =   1515
      Left            =   2160
      TabIndex        =   4
      Top             =   1620
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2672
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
      Caption         =   "Job Nature"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand5 
      Height          =   1515
      Left            =   120
      TabIndex        =   3
      Top             =   1620
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2672
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
      Caption         =   "Job Title"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand4 
      Height          =   1575
      Left            =   4200
      TabIndex        =   2
      Top             =   0
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Country"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   1575
      Left            =   2160
      TabIndex        =   1
      Top             =   0
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Province"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   1575
      Left            =   120
      TabIndex        =   0
      Top             =   0
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "City"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmMenuPreference"
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
    If ofx_IsFormLoaded(frmSpecialReports) Then
        frmSpecialReports.SetFocus
        frmSpecialReports.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmSpecialReports.Show
    End If
End Sub


Private Sub SSCommand1_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand2_Click()
    If ofx_IsFormLoaded(frmCity) Then
        frmCity.SetFocus
        frmCity.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmCity.Show
    End If
End Sub


Private Sub SSCommand2_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand3_Click()
    If ofx_IsFormLoaded(frmProvince) Then
        frmProvince.SetFocus
        frmProvince.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmProvince.Show
    End If
End Sub


Private Sub SSCommand3_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand4_Click()
    If ofx_IsFormLoaded(frmCountry) Then
        frmCountry.SetFocus
        frmCountry.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmCountry.Show
    End If
End Sub


Private Sub SSCommand4_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand5_Click()
    If ofx_IsFormLoaded(frmJobTitle) Then
        frmJobTitle.SetFocus
        frmJobTitle.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmJobTitle.Show
    End If
End Sub


Private Sub SSCommand5_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand6_Click()
    If ofx_IsFormLoaded(frmJobNature) Then
        frmJobNature.SetFocus
        frmJobNature.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmJobNature.Show
    End If
End Sub


Private Sub SSCommand6_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand7_Click()
    If ofx_IsFormLoaded(frmSalutation) Then
        frmSalutation.SetFocus
        frmSalutation.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmSalutation.Show
    End If
End Sub


Private Sub SSCommand7_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand8_Click()
    If ofx_IsFormLoaded(frmSecurity) Then
        frmSecurity.SetFocus
        frmSecurity.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmSecurity.Show
    End If
End Sub


Private Sub SSCommand8_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

VERSION 5.00
Begin VB.Form dlgLogon 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Logon"
   ClientHeight    =   1875
   ClientLeft      =   3660
   ClientTop       =   3060
   ClientWidth     =   4275
   Icon            =   "AppLogon.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   NegotiateMenus  =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1875
   ScaleWidth      =   4275
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton btnCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   390
      Left            =   2970
      TabIndex        =   5
      Top             =   615
      Width           =   1215
   End
   Begin VB.CommandButton btnOK 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   390
      Left            =   2970
      TabIndex        =   4
      Top             =   165
      Width           =   1215
   End
   Begin VB.TextBox txtPassword 
      Height          =   300
      IMEMode         =   3  'DISABLE
      Left            =   185
      PasswordChar    =   "*"
      TabIndex        =   3
      Top             =   1200
      Width           =   2000
   End
   Begin VB.TextBox txtUserName 
      Height          =   300
      Left            =   185
      TabIndex        =   1
      Top             =   435
      Width           =   2000
   End
   Begin VB.Label STATIC 
      Caption         =   "&Password:"
      Height          =   195
      Index           =   1
      Left            =   180
      TabIndex        =   2
      Top             =   960
      Width           =   1500
   End
   Begin VB.Label STATIC 
      Caption         =   "&User:"
      Height          =   195
      Index           =   0
      Left            =   185
      TabIndex        =   0
      Top             =   210
      Width           =   1500
   End
End
Attribute VB_Name = "dlgLogon"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim mTries As Integer
Private Sub btnCancel_Click()
    On Error Resume Next
    Unload Me
End Sub

Public Property Get UserName() As String
    UserName = Me.txtUserName.Text
End Property

Public Property Let UserName(vNewValue As String)
    Me.txtUserName.Text = vNewValue
End Property

Public Property Get Password() As String
    Password = Me.txtPassword.Text
End Property

Public Property Let Password(vNewValue As String)
    Me.txtPassword.Text = vNewValue
End Property

Private Sub btnOK_Click()
    On Error Resume Next
    
    If (0 = Len(Me.txtUserName.Text)) Then
        Beep
        Exit Sub
    Else
        Me.Visible = False
    End If

End Sub

Public Property Get DatabaseName() As String
    'Write-Only
    DatabaseName = ""
End Property

Public Property Let DatabaseName(vNewValue As String)
    Me.Caption = "Logon - " & vNewValue
End Property


Private Sub Form_Load()
    On Error Resume Next
    
    'this may need to be on top of the splash form
    If (ofx_IsFormLoaded(frmSplash)) Then
        SetWindowPos frmSplash.hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOSIZE Or SWP_NOMOVE
    End If
    
End Sub

Private Sub txtPassword_GotFocus()
    On Error Resume Next
    ofx_SelectText txtPassword
End Sub

Private Sub txtUserName_GotFocus()
    On Error Resume Next
    ofx_SelectText txtUserName
End Sub


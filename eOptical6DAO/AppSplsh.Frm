VERSION 5.00
Begin VB.Form frmSplash 
   AutoRedraw      =   -1  'True
   BorderStyle     =   3  'Fixed Dialog
   ClientHeight    =   4860
   ClientLeft      =   5190
   ClientTop       =   2535
   ClientWidth     =   6465
   ControlBox      =   0   'False
   Icon            =   "AppSplsh.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4860
   ScaleWidth      =   6465
   ShowInTaskbar   =   0   'False
   Begin VB.TextBox txtInterval 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFF00&
      Height          =   285
      Left            =   4605
      TabIndex        =   3
      Text            =   "VB3 Interval"
      Top             =   3120
      Visible         =   0   'False
      Width           =   1095
   End
   Begin VB.Timer timSplash 
      Left            =   5880
      Top             =   3120
   End
   Begin VB.Label lblProductName 
      Caption         =   "Product Name"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   20.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   3120
      TabIndex        =   5
      Top             =   120
      Width           =   3255
   End
   Begin VB.Label lblCompanyName 
      Alignment       =   1  'Right Justify
      Caption         =   "Company Name"
      Height          =   255
      Left            =   3120
      TabIndex        =   4
      Top             =   4320
      Width           =   3135
   End
   Begin VB.Image Image1 
      Height          =   4425
      Left            =   120
      Picture         =   "AppSplsh.frx":068A
      Top             =   120
      Width           =   2820
   End
   Begin VB.Label lblVersion 
      Alignment       =   1  'Right Justify
      Caption         =   "Version Number"
      Height          =   255
      Left            =   3240
      TabIndex        =   2
      Top             =   3840
      Width           =   3015
   End
   Begin VB.Label lblCopyright 
      Alignment       =   1  'Right Justify
      Caption         =   "Copyright Notice"
      Height          =   255
      Left            =   3120
      TabIndex        =   1
      Top             =   4080
      Width           =   3135
   End
   Begin VB.Label lblAppTitle 
      Caption         =   "App Title"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   20.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   3150
      TabIndex        =   0
      Top             =   720
      Width           =   3135
   End
End
Attribute VB_Name = "frmSplash"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Load()
    On Error Resume Next
    
    #If Not VB3 Then
        Me.lblVersion = "Version " & App.Major & "." & Format$(App.Minor, "00") & "." & Format$(App.Revision, "000")
        Me.lblCopyright = App.LegalCopyright
    #End If
    Me.lblProductName = App.ProductName
'    Me.lblAppTitle = "for " & App.Title
    Me.lblAppTitle = "for Optical"
    Me.lblCompanyName = App.CompanyName
    
    Me.Left = (Screen.Width / 2) - (Me.Width / 2)
    Me.Top = (Screen.Height / 2) - (Me.Height / 2)
    SetWindowPos hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE Or SWP_NOMOVE
    Show
End Sub


Private Sub timSplash_Timer()
    On Error Resume Next
    Unload Me
End Sub


Private Sub txtInterval_Change()
    On Error Resume Next
    timSplash.Interval = ofx_CInt(txtInterval)
End Sub



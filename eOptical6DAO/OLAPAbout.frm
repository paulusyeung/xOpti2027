VERSION 4.00
Begin VB.Form frmAbout 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "About Synergy V"
   ClientHeight    =   3435
   ClientLeft      =   600
   ClientTop       =   2295
   ClientWidth     =   5700
   Height          =   3840
   Icon            =   "OLAPAbout.frx":0000
   Left            =   540
   LinkTopic       =   "Form2"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3435
   ScaleWidth      =   5700
   ShowInTaskbar   =   0   'False
   Top             =   1950
   Width           =   5820
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   375
      Left            =   2160
      TabIndex        =   0
      Top             =   3000
      Width           =   1335
   End
   Begin VB.Image imgLogo 
      Height          =   915
      Left            =   240
      Picture         =   "OLAPAbout.frx":068A
      Top             =   240
      Width           =   930
   End
   Begin VB.Label lblAbout 
      Height          =   2655
      Left            =   2160
      TabIndex        =   1
      Top             =   120
      Width           =   3495
   End
End
Attribute VB_Name = "frmAbout"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdOK_Click()

    On Error GoTo cmdOK_Click_Err

    Unload Me

cmdOK_Click_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdOK_Click_Err:          ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdOK_Click_Exit

End Sub

Private Sub Form_Load()

    On Error GoTo Form_Load_Err

Dim sAbout As String
    Left = (Screen.Width - Width) / 2   ' Center form horizontally.
    Top = (Screen.Height - Height) / 2  ' Center form vertically.
    
    sAbout = vbCrLf
    sAbout = sAbout & vbCrLf
    sAbout = sAbout & "Synergy V" & vbCrLf
    sAbout = sAbout & "By Synergy Technologies, Inc." & vbCrLf & vbCrLf
    sAbout = sAbout & "9300 Ryan Crescent" & vbCrLf
    sAbout = sAbout & "Richmond BC, V7A 2H2" & vbCrLf
    sAbout = sAbout & "Tel: (604) 241 1681" & vbCrLf
    sAbout = sAbout & "Fax: (604) 241 4665" & vbCrLf
    sAbout = sAbout & "Price: $4999.00" & vbCrLf
    lblAbout = sAbout

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub


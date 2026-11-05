VERSION 5.00
Begin VB.Form frmFormat 
   Caption         =   "Number Format"
   ClientHeight    =   1185
   ClientLeft      =   555
   ClientTop       =   3450
   ClientWidth     =   4740
   Icon            =   "OLAPFormat.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1185
   ScaleWidth      =   4740
   Begin VB.TextBox txtFormat 
      Height          =   330
      Left            =   1470
      TabIndex        =   0
      Top             =   210
      Width           =   3165
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "&Cancel"
      Height          =   330
      Left            =   2415
      TabIndex        =   2
      Top             =   735
      Width           =   1065
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   330
      Left            =   1155
      TabIndex        =   1
      Top             =   735
      Width           =   1065
   End
   Begin VB.Label lblTag 
      Caption         =   "Number Format:"
      Height          =   225
      Left            =   105
      TabIndex        =   3
      Top             =   315
      Width           =   1275
   End
End
Attribute VB_Name = "frmFormat"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdCancel_Click()

    On Error GoTo cmdCancel_Click_Err

    Me.Hide

cmdCancel_Click_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdCancel_Click_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdCancel_Click_Exit

End Sub

Private Sub cmdOK_Click()

    On Error GoTo cmdOK_Click_Err

    Me.Hide

cmdOK_Click_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdOK_Click_Err:          ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdOK_Click_Exit

End Sub

Private Sub Form_Load()
    Left = (Screen.Width - Width) / 2   ' Center form horizontally.
    Top = (Screen.Height - Height) / 2  ' Center form vertically.
End Sub



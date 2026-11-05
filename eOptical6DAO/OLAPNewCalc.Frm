VERSION 5.00
Begin VB.Form frmNewCalc 
   Caption         =   "Add Calculated Field"
   ClientHeight    =   1695
   ClientLeft      =   4470
   ClientTop       =   3315
   ClientWidth     =   4215
   Icon            =   "OLAPNewCalc.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1695
   ScaleWidth      =   4215
   Begin VB.CommandButton cmdCancel 
      Caption         =   "&Cancel"
      Height          =   330
      Left            =   2205
      TabIndex        =   5
      Top             =   1260
      Width           =   1065
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   330
      Left            =   840
      TabIndex        =   2
      Top             =   1260
      Width           =   1065
   End
   Begin VB.TextBox txtCaption 
      Height          =   330
      Left            =   1050
      MaxLength       =   50
      TabIndex        =   1
      Top             =   630
      Width           =   3060
   End
   Begin VB.TextBox txtFormula 
      Height          =   330
      Left            =   1050
      MaxLength       =   50
      TabIndex        =   0
      Top             =   210
      Width           =   3060
   End
   Begin VB.Label lblTag 
      Caption         =   "&Caption:"
      Height          =   225
      Index           =   1
      Left            =   210
      TabIndex        =   4
      Top             =   735
      Width           =   750
   End
   Begin VB.Label lblTag 
      Caption         =   "&Formula:"
      Height          =   225
      Index           =   0
      Left            =   210
      TabIndex        =   3
      Top             =   315
      Width           =   750
   End
End
Attribute VB_Name = "frmNewCalc"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdCancel_Click()

    On Error GoTo cmdCancel_Click_Err

    Unload Me

cmdCancel_Click_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdCancel_Click_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdCancel_Click_Exit

End Sub

Private Sub cmdOK_Click()

    On Error GoTo cmdOK_Click_Err

Dim x As Object
    Set x = dcCurrent.Fields.Add(txtFormula, txtCaption, DCData)
    x.Calculated = True
    x.AggregateFunc = DCFSum
    x.GroupFooterType = DCFCalculated
    x.Visible = True
    x.Position = dcCurrent.DataFields.Count
    dcCurrent.RefreshData
    Unload Me

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



VERSION 5.00
Object = "{65E121D4-0C60-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCHRT20.OCX"
Begin VB.Form frmGraph 
   Caption         =   "Graph"
   ClientHeight    =   4725
   ClientLeft      =   1800
   ClientTop       =   2850
   ClientWidth     =   5475
   Icon            =   "OLAPGraph.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4725
   ScaleWidth      =   5475
   Begin MSChart20Lib.MSChart mscDemo 
      Height          =   3900
      Left            =   180
      OleObjectBlob   =   "OLAPGraph.frx":068A
      TabIndex        =   2
      Top             =   600
      Width           =   4995
   End
   Begin VB.ComboBox cboGraphType 
      Height          =   315
      Left            =   1440
      Style           =   2  'Dropdown List
      TabIndex        =   1
      Top             =   120
      Width           =   3615
   End
   Begin VB.CommandButton cmdClose 
      Caption         =   "&Close"
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1215
   End
End
Attribute VB_Name = "frmGraph"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cboGraphType_Click()

    On Error GoTo cboGraphType_Click_Err

'    grfDemo.GraphType = cboGraphType.ListIndex
'    grfDemo.DrawMode = 2
    mscDemo.chartType = cboGraphType.ListIndex
    mscDemo.DrawMode = VtChDrawModeDraw

cboGraphType_Click_Exit:  ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cboGraphType_Click_Err:   ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cboGraphType_Click_Exit

End Sub

Private Sub cmdClose_Click()

    On Error GoTo cmdClose_Click_Err

    Unload Me

cmdClose_Click_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdClose_Click_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdClose_Click_Exit

End Sub

Private Sub Form_Load()

    On Error GoTo Form_Load_Err
    Left = (Screen.Width - Width) / 2   ' Center form horizontally.
    Top = (Screen.Height - Height) / 2  ' Center form vertically.
    cboGraphType.AddItem "0- None"
    cboGraphType.AddItem "1- 2D Pie"
    cboGraphType.AddItem "2- 3D Pie"
    cboGraphType.AddItem "3- 2D Bar"
    cboGraphType.AddItem "4- 3D Bar"
    cboGraphType.AddItem "5- Gannt"
    cboGraphType.AddItem "6- Line"
    cboGraphType.AddItem "7- Log/Lin"
    cboGraphType.AddItem "8- Area"
    cboGraphType.AddItem "9- Scatter"
    cboGraphType.AddItem "10- Polar"
    cboGraphType.AddItem "11- HLC"
    
    cboGraphType.ListIndex = 3

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub

Private Sub Form_Resize()

    On Error GoTo Form_Resize_Err

    If Me.WindowState <> vbMinimized Then
'        grfDemo.Height = Me.Height - 1100
'        grfDemo.Width = Me.Width - 300
        mscDemo.Height = Me.Height - 1100
        mscDemo.Width = Me.Width - 300
    End If

Form_Resize_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Resize_Err:          ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Resize_Exit

End Sub


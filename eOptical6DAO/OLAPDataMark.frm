VERSION 5.00
Begin VB.Form frmDataMarker 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Data Marker"
   ClientHeight    =   1215
   ClientLeft      =   225
   ClientTop       =   930
   ClientWidth     =   6930
   Icon            =   "OLAPDataMark.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1215
   ScaleWidth      =   6930
   ShowInTaskbar   =   0   'False
   Begin VB.PictureBox picColor 
      BackColor       =   &H00808000&
      BorderStyle     =   0  'None
      FillStyle       =   0  'Solid
      Height          =   255
      Index           =   7
      Left            =   2805
      ScaleHeight     =   255
      ScaleWidth      =   255
      TabIndex        =   9
      Top             =   600
      Width           =   255
   End
   Begin VB.PictureBox picColor 
      BackColor       =   &H00800000&
      BorderStyle     =   0  'None
      FillStyle       =   0  'Solid
      Height          =   255
      Index           =   6
      Left            =   2430
      ScaleHeight     =   255
      ScaleWidth      =   255
      TabIndex        =   8
      Top             =   600
      Width           =   255
   End
   Begin VB.PictureBox picColor 
      BackColor       =   &H00FF00FF&
      BorderStyle     =   0  'None
      FillStyle       =   0  'Solid
      Height          =   255
      Index           =   5
      Left            =   2055
      ScaleHeight     =   255
      ScaleWidth      =   255
      TabIndex        =   7
      Top             =   600
      Width           =   255
   End
   Begin VB.PictureBox picColor 
      BackColor       =   &H00FF0000&
      BorderStyle     =   0  'None
      FillStyle       =   0  'Solid
      Height          =   255
      Index           =   4
      Left            =   1680
      ScaleHeight     =   255
      ScaleWidth      =   255
      TabIndex        =   6
      Top             =   600
      Width           =   255
   End
   Begin VB.PictureBox picColor 
      BackColor       =   &H00FFFF00&
      BorderStyle     =   0  'None
      FillStyle       =   0  'Solid
      Height          =   255
      Index           =   3
      Left            =   1305
      ScaleHeight     =   255
      ScaleWidth      =   255
      TabIndex        =   5
      Top             =   600
      Width           =   255
   End
   Begin VB.PictureBox picColor 
      BackColor       =   &H0000FF00&
      BorderStyle     =   0  'None
      FillStyle       =   0  'Solid
      Height          =   255
      Index           =   2
      Left            =   930
      ScaleHeight     =   255
      ScaleWidth      =   255
      TabIndex        =   4
      Top             =   600
      Width           =   255
   End
   Begin VB.PictureBox picColor 
      BackColor       =   &H0000FFFF&
      BorderStyle     =   0  'None
      FillColor       =   &H000000FF&
      FillStyle       =   0  'Solid
      Height          =   255
      Index           =   1
      Left            =   555
      ScaleHeight     =   255
      ScaleWidth      =   255
      TabIndex        =   3
      Top             =   600
      Width           =   255
   End
   Begin VB.PictureBox picColor 
      BackColor       =   &H000000FF&
      FillColor       =   &H000000FF&
      FillStyle       =   0  'Solid
      Height          =   255
      Index           =   0
      Left            =   180
      ScaleHeight     =   195
      ScaleWidth      =   195
      TabIndex        =   2
      Top             =   600
      Width           =   255
   End
   Begin VB.CommandButton cmdClose 
      Caption         =   "&Close"
      Height          =   315
      Left            =   3375
      TabIndex        =   14
      Top             =   825
      Width           =   990
   End
   Begin VB.CommandButton cmdDelete 
      Caption         =   "&Delete"
      Enabled         =   0   'False
      Height          =   315
      Left            =   3375
      TabIndex        =   12
      Top             =   450
      Width           =   990
   End
   Begin VB.CommandButton cmdAdd 
      Caption         =   "&Add"
      Height          =   315
      Left            =   3375
      TabIndex        =   11
      Top             =   75
      Width           =   990
   End
   Begin VB.ListBox lstRanges 
      Height          =   1035
      Left            =   4500
      TabIndex        =   10
      Top             =   75
      Width           =   2295
   End
   Begin VB.TextBox txtLimit 
      Alignment       =   1  'Right Justify
      Height          =   285
      Index           =   1
      Left            =   2100
      MaxLength       =   8
      TabIndex        =   1
      Text            =   "0"
      Top             =   150
      Width           =   1140
   End
   Begin VB.TextBox txtLimit 
      Alignment       =   1  'Right Justify
      Height          =   285
      Index           =   0
      Left            =   825
      MaxLength       =   8
      TabIndex        =   0
      Text            =   "0"
      Top             =   150
      Width           =   1140
   End
   Begin VB.Label Label1 
      Caption         =   "Range:"
      Height          =   255
      Left            =   150
      TabIndex        =   13
      Top             =   150
      Width           =   615
   End
End
Attribute VB_Name = "frmDataMarker"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private Function GetColor() As Long

    On Error GoTo GetColor_Err

Dim i As Integer
    For i = 0 To 7
        If picColor(i).Enabled And picColor(i).BorderStyle = 1 Then
            GetColor = picColor(i).BackColor
            picColor(i).BorderStyle = 0
            If i < 7 Then picColor(i + 1).BorderStyle = 1 Else picColor(0).BorderStyle = 1
            Exit Function
        End If
    Next
    GetColor = 0

GetColor_Exit:            ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Function         ' SDVB autocode
GetColor_Err:             ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume GetColor_Exit

End Function
Private Sub cmdAdd_Click()

    On Error GoTo cmdAdd_Click_Err

Dim lColor As Long
    If lstRanges.ListCount > 8 Then Exit Sub
    
    lColor = GetColor()
    If Val(txtLimit(0)) <= Val(txtLimit(1)) Then
        lstRanges.AddItem Trim$(txtLimit(0)) & " - " & Trim$(txtLimit(1))
        ReDim Preserve aRanges(lstRanges.ListCount - 1)
        iRanges = lstRanges.ListCount
        aRanges(lstRanges.ListCount - 1).dStart = Val(txtLimit(0))
        aRanges(lstRanges.ListCount - 1).dEnd = Val(txtLimit(1))
        aRanges(lstRanges.ListCount - 1).lColor = lColor
    End If

cmdAdd_Click_Exit:        ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdAdd_Click_Err:         ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdAdd_Click_Exit

End Sub

Private Sub cmdClose_Click()

    On Error GoTo cmdClose_Click_Err

    ' Update Global Arrays
    Unload Me

cmdClose_Click_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdClose_Click_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdClose_Click_Exit

End Sub

Private Sub cmdDelete_Click()

    On Error GoTo cmdDelete_Click_Err

Dim i, j As Integer
    If lstRanges.ListCount > 0 Then
        i = lstRanges.ListIndex
        lstRanges.RemoveItem i
        If i = iRanges Then
            ReDim Preserve aRanges(iRanges - 1)
        Else
            For j = i To iRanges - 2
                aRanges(j) = aRanges(j + 1)
            Next
            ReDim Preserve aRanges(iRanges - 1)
        End If
        iRanges = iRanges - 1
    End If

cmdDelete_Click_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdDelete_Click_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdDelete_Click_Exit

End Sub

Private Sub Form_Load()

    On Error GoTo Form_Load_Err
    Left = (Screen.Width - Width) / 2   ' Center form horizontally.
    Top = (Screen.Height - Height) / 2  ' Center form vertically.

    Dim i, j As Integer
    If iRanges > 0 Then
        For i = 0 To iRanges - 1
            lstRanges.AddItem Str(aRanges(i).dStart) & " - " & Str(aRanges(i).dEnd)
            For j = 0 To 7
                If picColor(j).BackColor = aRanges(i).lColor Then
                    picColor(j).Enabled = False
                    Exit For
                End If
            Next
        Next
    End If

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub

Private Sub lstRanges_GotFocus()

    On Error GoTo lstRanges_GotFocus_Err

    cmdDelete.Enabled = (iRanges > 0)

lstRanges_GotFocus_Exit:  ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
lstRanges_GotFocus_Err:   ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume lstRanges_GotFocus_Exit

End Sub

Private Sub lstRanges_LostFocus()

    On Error GoTo lstRanges_LostFocus_Err

    cmdDelete.Enabled = (iRanges > 0)

lstRanges_LostFocus_Exit:  ' SDVB autocode
    On Error Resume Next   ' SDVB autocode
    Exit Sub               ' SDVB autocode
lstRanges_LostFocus_Err:   ' SDVB autocode
    MsgBox Error           ' SDVB autocode
    Resume lstRanges_LostFocus_Exit

End Sub

Private Sub picColor_GotFocus(Index As Integer)

    On Error GoTo picColor_GotFocus_Err

Dim i As Integer
    For i = 0 To 7
        If picColor(i).BorderStyle = 1 Then
            picColor(i).BorderStyle = 0
            Exit For
        End If
    Next
    picColor(Index).BorderStyle = 1

picColor_GotFocus_Exit:   ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
picColor_GotFocus_Err:    ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume picColor_GotFocus_Exit

End Sub

Private Sub txtLimit_GotFocus(Index As Integer)

    On Error GoTo txtLimit_GotFocus_Err

    txtLimit(Index).SelStart = 0
    txtLimit(Index).SelLength = Len(txtLimit(Index))

txtLimit_GotFocus_Exit:   ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
txtLimit_GotFocus_Err:    ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume txtLimit_GotFocus_Exit

End Sub

Private Sub txtLimit_LostFocus(Index As Integer)

    On Error GoTo txtLimit_LostFocus_Err

    If Not IsNumeric(txtLimit(Index)) Then
        txtLimit(Index).SetFocus
    End If

txtLimit_LostFocus_Exit:  ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
txtLimit_LostFocus_Err:   ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume txtLimit_LostFocus_Exit

End Sub

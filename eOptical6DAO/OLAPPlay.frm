VERSION 5.00
Object = "{6D63F73C-3688-11D0-9C0F-00A0C90F29FC}#2.0#0"; "DCUBE.OCX"
Begin VB.Form frmPlay 
   Caption         =   "Play Around Synergy V"
   ClientHeight    =   5010
   ClientLeft      =   375
   ClientTop       =   2115
   ClientWidth     =   7275
   Icon            =   "OLAPPlay.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5010
   ScaleWidth      =   7275
   WindowState     =   2  'Maximized
   Begin DynamiCubeLibCtl.DCube dcOLAP 
      Height          =   4095
      Left            =   60
      TabIndex        =   4
      Top             =   840
      Width           =   7155
      _ExtentX        =   12621
      _ExtentY        =   7223
      DataSource      =   ""
      BeginProperty HeadingsFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BeginProperty FieldFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      RowAlignment    =   0
      ColAlignment    =   0
      RowStyle        =   1
      ColStyle        =   1
      OutlineIconAlignment=   1
      GridColor       =   12632256
      BackColor       =   16777215
      DCConnect       =   ""
      DCDatabaseName  =   ""
      CursorStyle     =   0
      FieldsBackColor =   8421504
      FieldsForeColor =   16777215
      HeadingsForeColor=   0
      HeadingsBackColor=   16777215
      DCRecordSource  =   ""
      TotalsBackColor =   16777215
      TotalsForeColor =   0
      BeginProperty TotalsFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      GridStyle       =   1
      ForeColor       =   0
      AllowFiltering  =   -1  'True
      AllowUserPivotFields=   -1  'True
      LeftMargin      =   0.75
      RightMargin     =   0.75
      TopMargin       =   0.49
      BottomMargin    =   0.49
      HeaderMargin    =   0.49
      FooterMargin    =   0.49
      FooterCaption   =   "- Page &P -"
      HeaderCaption   =   "DynamiCube"
      HeaderJustification=   1
      FooterJustification=   1
      ColPageBreak    =   0
      RowPageBreak    =   0
      ColHeadingsOnEveryPage=   -1  'True
      RowHeadingsOnEveryPage=   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      DCOptions       =   0
      AutoDataRefresh =   -1  'True
      BeginProperty PrinterFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BeginProperty PrinterFontTotals {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BeginProperty PrinterFontHeadings {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      PrinterColumnSpacing=   0.01
      PrinterGridColor=   0
      DCConnectType   =   0
      DCQueryTimeOut  =   0
      SQLYearPart     =   "datepart(""yyyy"",<field>)"
      SQLQuarterPart  =   "datepart(""q"",<field>)"
      SQLMonthPart    =   "datepart(""m"",<field>)"
      SQLWeekPart     =   "datepart(""ww"",<field>)"
      BorderStyle     =   1
      AllowSplitters  =   -1  'True
      QueryByPass     =   0   'False
      DataPath        =   ""
      DataNotAvailableCaption=   ""
      PageFieldsVisible=   -1  'True
      Fields          =   "OLAPPlay.frx":068A
   End
   Begin VB.Label lblDataValue 
      Height          =   330
      Left            =   1260
      TabIndex        =   3
      Top             =   420
      Width           =   1590
   End
   Begin VB.Label Label1 
      Caption         =   "Data Value:"
      Height          =   330
      Left            =   105
      TabIndex        =   2
      Top             =   420
      Width           =   1065
   End
   Begin VB.Label lblStatus 
      Height          =   255
      Left            =   3240
      TabIndex        =   1
      Top             =   75
      Width           =   3975
   End
   Begin VB.Label lblSel 
      DragMode        =   1  'Automatic
      Height          =   255
      Left            =   135
      TabIndex        =   0
      Top             =   105
      Width           =   2655
   End
   Begin VB.Menu mnuDynamiCube 
      Caption         =   "&Synergy V"
      Begin VB.Menu mnuDataMarker 
         Caption         =   "&Data Marker"
      End
      Begin VB.Menu mnuPerformance 
         Caption         =   "Perfor&mance"
      End
      Begin VB.Menu mnuGraph 
         Caption         =   "&Graph"
      End
      Begin VB.Menu mnuPrintPreview 
         Caption         =   "&Print Preview"
      End
      Begin VB.Menu mnuSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuSave 
         Caption         =   "&Save"
      End
      Begin VB.Menu mnuExportText 
         Caption         =   "Export to &Text"
      End
      Begin VB.Menu mnuExportExcel 
         Caption         =   "Export to E&xcel"
      End
      Begin VB.Menu mnuSep2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuProperties 
         Caption         =   "P&roperties"
      End
      Begin VB.Menu mnuSep3 
         Caption         =   "-"
      End
      Begin VB.Menu mnuClose 
         Caption         =   "&Close"
      End
   End
End
Attribute VB_Name = "frmPlay"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub dcOLAP_Click()

    On Error GoTo dcOLAP_Click_Err

    lblStatus = "Mouse Click"

dcOLAP_Click_Exit:        ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_Click_Err:         ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_Click_Exit

End Sub

Private Sub dcOLAP_DataError(ByVal ErrorCode As Long, SuppressErrorMessage As Long)

    On Error GoTo dcOLAP_DataError_Err

    MsgBox "Error: " & Str(ErrorCode)
    SuppressErrorMessage = 1

dcOLAP_DataError_Exit:    ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_DataError_Err:     ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_DataError_Exit

End Sub

Private Sub dcOLAP_DblClick()

    On Error GoTo dcOLAP_DblClick_Err

    lblStatus = "Mouse Double Click"

dcOLAP_DblClick_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_DblClick_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_DblClick_Exit

End Sub

Private Sub dcOLAP_DragDrop(Source As Control, x As Single, Y As Single)

    On Error GoTo dcOLAP_DragDrop_Err

    lblStatus = "Drop " & Source.Name & "  At: " & Str(x) & ", " & Str(Y)

dcOLAP_DragDrop_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_DragDrop_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_DragDrop_Exit

End Sub

Private Sub dcOLAP_DragOver(Source As Control, x As Single, Y As Single, State As Integer)

    On Error GoTo dcOLAP_DragOver_Err

    lblStatus = "Drag " & Source.Name & "  At: " & Str(x) & ", " & Str(Y)

dcOLAP_DragOver_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_DragOver_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_DragOver_Exit

End Sub

Private Sub dcOLAP_FetchAttributes(ByVal cellAttrib As DynamiCubeLibCtl.Attrib)
' ByVal DataFieldIndex As Integer, ByVal DataValue As Double, ForeColor As Long, BackColor As Long
    On Error GoTo dcOLAP_FetchAttributes_Err

    If cellAttrib.DataFieldIndex = -1 Then ForeColor = vbRed

dcOLAP_FetchAttributes_Exit:  ' SDVB autocode
    On Error Resume Next      ' SDVB autocode
    Exit Sub                  ' SDVB autocode
dcOLAP_FetchAttributes_Err:   ' SDVB autocode
    MsgBox Error              ' SDVB autocode
    Resume dcOLAP_FetchAttributes_Exit

End Sub

Private Sub dcOLAP_GotFocus()

    On Error GoTo dcOLAP_GotFocus_Err

    lblStatus = "Got Focus"

dcOLAP_GotFocus_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_GotFocus_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_GotFocus_Exit

End Sub

Private Sub dcOLAP_KeyDown(ByVal KeyCode As DynamiCubeLibCtl.ReturnInteger, ByVal Shift As Integer)

    On Error GoTo dcOLAP_KeyDown_Err

    lblStatus = "KeyDown " & Str(KeyCode)

dcOLAP_KeyDown_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_KeyDown_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_KeyDown_Exit

End Sub


Private Sub dcOLAP_KeyPress(ByVal KeyAscii As DynamiCubeLibCtl.ReturnInteger)

    On Error GoTo dcOLAP_KeyPress_Err

    lblStatus = "KeyPress " & Str(KeyAscii)

dcOLAP_KeyPress_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_KeyPress_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_KeyPress_Exit

End Sub


Private Sub dcOLAP_KeyUp(ByVal KeyCode As DynamiCubeLibCtl.ReturnInteger, ByVal Shift As Integer)

    On Error GoTo dcOLAP_KeyUp_Err

    lblStatus = "Key Up " & Str(KeyCode)

dcOLAP_KeyUp_Exit:        ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_KeyUp_Err:         ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_KeyUp_Exit

End Sub

Private Sub dcOLAP_LostFocus()

    On Error GoTo dcOLAP_LostFocus_Err

    lblStatus = "Lost Focus"

dcOLAP_LostFocus_Exit:    ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_LostFocus_Err:     ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_LostFocus_Exit

End Sub

Private Sub dcOLAP_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo dcOLAP_MouseDown_Err

    lblStatus = "Mouse Down"

dcOLAP_MouseDown_Exit:    ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_MouseDown_Err:     ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_MouseDown_Exit

End Sub

Private Sub dcOLAP_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo dcOLAP_MouseMove_Err

    lblStatus = "Mouse Move"

dcOLAP_MouseMove_Exit:    ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_MouseMove_Err:     ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_MouseMove_Exit

End Sub

Private Sub dcOLAP_MouseUp(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo dcOLAP_MouseUp_Err

    lblStatus = "Mouse Up"

dcOLAP_MouseUp_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_MouseUp_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_MouseUp_Exit

End Sub

Private Sub dcOLAP_SelChange()

    On Error GoTo dcOLAP_SelChange_Err

    lblSel = Str(dcOLAP.SelStartRow) & ", " & Str(dcOLAP.SelStartCol) & " - " & Str(dcOLAP.SelEndRow) & "," & Str(dcOLAP.SelEndCol)
    lblDataValue = dcOLAP.DataValue(dcOLAP.SelStartRow, dcOLAP.SelStartCol)

dcOLAP_SelChange_Exit:    ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_SelChange_Err:     ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_SelChange_Exit

End Sub

Private Sub Form_Resize()

    On Error GoTo Form_Resize_Err

    If Me.WindowState <> vbMinimized Then
        dcOLAP.Width = Me.Width - 300
        dcOLAP.Height = Me.Height - 1700
    End If

Form_Resize_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Resize_Err:          ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Resize_Exit

End Sub

Private Sub mnuClose_Click()

    On Error GoTo mnuClose_Click_Err

    Unload Me

mnuClose_Click_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
mnuClose_Click_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume mnuClose_Click_Exit

End Sub

Private Sub mnuDataMarker_Click()

    On Error GoTo mnuDataMarker_Click_Err

    frmDataMarker.Show vbModal
    dcOLAP.Refresh

mnuDataMarker_Click_Exit:  ' SDVB autocode
    On Error Resume Next   ' SDVB autocode
    Exit Sub               ' SDVB autocode
mnuDataMarker_Click_Err:   ' SDVB autocode
    MsgBox Error           ' SDVB autocode
    Resume mnuDataMarker_Click_Exit

End Sub

Private Sub mnuExportExcel_Click()

    On Error GoTo mnuExportExcel_Click_Err

    ExportToExcel dcOLAP

mnuExportExcel_Click_Exit:  ' SDVB autocode
    On Error Resume Next    ' SDVB autocode
    Exit Sub                ' SDVB autocode
mnuExportExcel_Click_Err:   ' SDVB autocode
    MsgBox Error            ' SDVB autocode
    Resume mnuExportExcel_Click_Exit

End Sub

Private Sub mnuExportText_Click()

    On Error GoTo mnuExportText_Click_Err

    ExportToText dcOLAP, "PLAY.TXT"

mnuExportText_Click_Exit:  ' SDVB autocode
    On Error Resume Next   ' SDVB autocode
    Exit Sub               ' SDVB autocode
mnuExportText_Click_Err:   ' SDVB autocode
    MsgBox Error           ' SDVB autocode
    Resume mnuExportText_Click_Exit

End Sub
Private Sub mnuGraph_Click()

    On Error GoTo mnuGraph_Click_Err

    DispGraph dcOLAP

mnuGraph_Click_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
mnuGraph_Click_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume mnuGraph_Click_Exit

End Sub

Private Sub mnuPerformance_Click()

    On Error GoTo mnuPerformance_Click_Err

    dcOLAP.PerformanceDlg

mnuPerformance_Click_Exit:  ' SDVB autocode
    On Error Resume Next    ' SDVB autocode
    Exit Sub                ' SDVB autocode
mnuPerformance_Click_Err:   ' SDVB autocode
    MsgBox Error            ' SDVB autocode
    Resume mnuPerformance_Click_Exit

End Sub

Private Sub mnuPrintPreview_Click()

    On Error GoTo mnuPrintPreview_Click_Err

    dcOLAP.PrintPreview

mnuPrintPreview_Click_Exit:  ' SDVB autocode
    On Error Resume Next     ' SDVB autocode
    Exit Sub                 ' SDVB autocode
mnuPrintPreview_Click_Err:   ' SDVB autocode
    MsgBox Error             ' SDVB autocode
    Resume mnuPrintPreview_Click_Exit

End Sub

Private Sub mnuProperties_Click()

    On Error GoTo mnuProperties_Click_Err

    Set dcCurrent = dcOLAP
    frmDCProp.Show vbModal

mnuProperties_Click_Exit:  ' SDVB autocode
    On Error Resume Next   ' SDVB autocode
    Exit Sub               ' SDVB autocode
mnuProperties_Click_Err:   ' SDVB autocode
    MsgBox Error           ' SDVB autocode
    Resume mnuProperties_Click_Exit

End Sub

Private Sub mnuSave_Click()

    On Error GoTo mnuSave_Click_Err

    dcOLAP.Save loctext$ & "PLAY.CUB", 1

mnuSave_Click_Exit:       ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
mnuSave_Click_Err:        ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume mnuSave_Click_Exit

End Sub

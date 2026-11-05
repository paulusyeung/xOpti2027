VERSION 4.00
Begin VB.Form frmMargin 
   Caption         =   "Sales by LSP - Right Click in Grid Area for a Context Menu"
   ClientHeight    =   4830
   ClientLeft      =   1305
   ClientTop       =   1830
   ClientWidth     =   7950
   Height          =   5520
   Icon            =   "OLAPMargin.frx":0000
   Left            =   1245
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   ScaleHeight     =   4830
   ScaleWidth      =   7950
   Top             =   1200
   Width           =   8070
   WindowState     =   2  'Maximized
   Begin DYNACUBELib.DynaCube dcOLAP 
      Height          =   4695
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   7815
      _Version        =   65537
      _ExtentX        =   13785
      _ExtentY        =   8281
      _StockProps     =   45
      BackColor       =   65535
      DCConnect       =   "Access"
      DCConnectType   =   1
      DCDatabaseName  =   "C:\SynergyV\SynergyV.mdb"
      DCRecordSource  =   "OlapSalesLSP"
      BeginProperty HeadingsFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   8.25
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      BeginProperty TotalsFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   8.25
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      BeginProperty FieldFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   8.25
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      BeginProperty PrinterFontHeadings {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         name            =   "Arial"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      BeginProperty PrinterFontTotals {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         name            =   "Arial"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      BeginProperty PrinterFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         name            =   "Arial"
         charset         =   0
         weight          =   400
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      RowStyle        =   2
      ColStyle        =   2
      AllowFiltering  =   -1  'True
      AllowUserPivotFields=   -1  'True
      AllowSplitters  =   -1  'True
      TopMargin       =   1
      BottomMargin    =   1
      HeaderCaption   =   "SynergyV OLAP - Sales by LSP"
      FieldsCount     =   19
      Fields          =   "OLAPMargin.frx":068A
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
         Caption         =   "Export &Text"
      End
      Begin VB.Menu mnuExportExcel 
         Caption         =   "Export E&xcel"
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
   Begin VB.Menu mnuPopup 
      Caption         =   "Popup"
      Visible         =   0   'False
      Begin VB.Menu mnuNormal 
         Caption         =   "&Normal"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnuRowPercent 
         Caption         =   "% of &Row"
      End
      Begin VB.Menu mnuColPercent 
         Caption         =   "% of Col"
      End
      Begin VB.Menu mnuPopSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuFormat 
         Caption         =   "&Number Format..."
      End
      Begin VB.Menu mnuAddNew 
         Caption         =   "&Add New..."
      End
      Begin VB.Menu mnuFields 
         Caption         =   "-"
         Index           =   0
         Visible         =   0   'False
      End
   End
End
Attribute VB_Name = "frmMargin"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Option Explicit
Dim bSetMenu As Boolean

Private Sub dcOLAP_FetchAttributes(ByVal DataFieldIndex As Integer, ByVal DataValue As Double, ForeColor As Long, BackColor As Long)

    On Error GoTo dcOLAP_FetchAttributes_Err

Dim i As Integer
    If DataFieldIndex <> -1 And iRanges <> 0 Then
        For i = 0 To iRanges - 1
           If DataValue >= aRanges(i).dStart And DataValue < aRanges(i).dEnd Then
                ForeColor = aRanges(i).lColor
               Exit For
           End If
        Next
    End If
    If DataFieldIndex = 4 Then  ' Margin
        BackColor = vbYellow
    End If

dcOLAP_FetchAttributes_Exit:  ' SDVB autocode
    On Error Resume Next      ' SDVB autocode
    Exit Sub                  ' SDVB autocode
dcOLAP_FetchAttributes_Err:   ' SDVB autocode
    MsgBox Error              ' SDVB autocode
    Resume dcOLAP_FetchAttributes_Exit

End Sub

Private Sub dcOLAP_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    On Error Resume Next
    If Button = vbRightButton Then
        ' First select the cell under the mouse
        Dim row As Long, column As Long
        If dcOLAP.GetCellForPoint(X, Y, row, column) Then
            dcOLAP.SelStartCol = column
            dcOLAP.SelEndCol = column
            dcOLAP.SelStartRow = row
            dcOLAP.SelEndRow = row
            dcOLAP.Refresh
        End If
    End If
    On Error GoTo 0
End Sub

Private Sub dcOLAP_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)

    On Error GoTo dcOLAP_MouseUp_Err

    If Button = vbRightButton Then
        Dim i As Integer
        i = GetCurrDataField(dcOLAP)
        SetDispAs dcOLAP.DataFields(i).DisplayAs
        If bSetMenu Then
            mnuFields(0).Visible = True
            For i = 0 To dcOLAP.DataFields.Count - 1
                Load mnuFields(i + 1)
                mnuFields(i + 1).Caption = dcOLAP.DataFields(i).Caption
                mnuFields(i + 1).Checked = dcOLAP.DataFields(i).Visible
                mnuFields(i + 1).Visible = True
            Next
            bSetMenu = False
        End If
        PopupMenu mnuPopup
    End If

dcOLAP_MouseUp_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
dcOLAP_MouseUp_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume dcOLAP_MouseUp_Exit

End Sub

Private Sub dcOLAP_QueryCompleted()

    On Error GoTo dcOLAP_QueryCompleted_Err

Dim i As Integer
    If dcOLAP.RowFields.Count > 1 Then
        For i = 0 To dcOLAP.RowFields.Count - 2
            dcOLAP.RowFields(i).ShowDetail False
        Next
    End If
    If dcOLAP.ColFields.Count > 1 Then
        For i = 0 To dcOLAP.ColFields.Count - 2
            dcOLAP.ColFields(i).ShowDetail False
        Next
    End If

dcOLAP_QueryCompleted_Exit:  ' SDVB autocode
    On Error Resume Next     ' SDVB autocode
    Exit Sub                 ' SDVB autocode
dcOLAP_QueryCompleted_Err:   ' SDVB autocode
    MsgBox Error             ' SDVB autocode
    Resume dcOLAP_QueryCompleted_Exit

End Sub

Private Sub Form_Load()

    On Error GoTo Form_Load_Err

    dcOLAP.DCDatabaseName = loctext$ & "synergyv.mdb"
    bSetMenu = True

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub

Private Sub mnuAddNew_Click()

    On Error GoTo mnuAddNew_Click_Err

Dim i As Integer
    Set dcCurrent = dcOLAP
    frmNewCalc.Show vbModal
    Set dcCurrent = Nothing
    i = dcOLAP.DataFields.Count
    Load mnuFields(i)
    mnuFields(i).Caption = dcOLAP.DataFields(i - 1).Caption
    mnuFields(i).Visible = True
    mnuFields(i).Checked = True

mnuAddNew_Click_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
mnuAddNew_Click_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume mnuAddNew_Click_Exit

End Sub

Private Sub Form_Resize()

    On Error GoTo Form_Resize_Err

    If Me.WindowState <> vbMinimized Then
        dcOLAP.Width = Me.Width - 400
        dcOLAP.Height = Me.Height - 1000
    End If

Form_Resize_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Resize_Err:          ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Resize_Exit

End Sub

Private Sub mnuColPercent_Click()

    On Error GoTo mnuColPercent_Click_Err

Dim i As Integer
    i = GetCurrDataField(dcOLAP)
    dcOLAP.DataFields(i).DisplayAs = DCDTPercentCol
    dcOLAP.DataFields(i).NumberFormat = "% #.00"

mnuColPercent_Click_Exit:  ' SDVB autocode
    On Error Resume Next   ' SDVB autocode
    Exit Sub               ' SDVB autocode
mnuColPercent_Click_Err:   ' SDVB autocode
    MsgBox Error           ' SDVB autocode
    Resume mnuColPercent_Click_Exit

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

    ExportToText dcOLAP, "MARGIN.TXT"

mnuExportText_Click_Exit:  ' SDVB autocode
    On Error Resume Next   ' SDVB autocode
    Exit Sub               ' SDVB autocode
mnuExportText_Click_Err:   ' SDVB autocode
    MsgBox Error           ' SDVB autocode
    Resume mnuExportText_Click_Exit

End Sub

Private Sub mnuFields_Click(Index As Integer)

    On Error GoTo mnuFields_Click_Err

    mnuFields(Index).Checked = Not mnuFields(Index).Checked
    dcOLAP.DataFields(Index - 1).Visible = mnuFields(Index).Checked

mnuFields_Click_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
mnuFields_Click_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume mnuFields_Click_Exit

End Sub

Private Sub mnuFormat_Click()

    On Error GoTo mnuFormat_Click_Err

Dim i As Integer
    Load frmFormat
    i = GetCurrDataField(dcOLAP)
    frmFormat.txtFormat.Text = dcOLAP.DataFields(i).NumberFormat
    frmFormat.Show vbModal
    dcOLAP.DataFields(i).NumberFormat = frmFormat.txtFormat.Text
    dcOLAP.Refresh
    Unload frmFormat

mnuFormat_Click_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
mnuFormat_Click_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume mnuFormat_Click_Exit

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

Private Sub mnuNormal_Click()

    On Error GoTo mnuNormal_Click_Err

Dim i As Integer
    i = GetCurrDataField(dcOLAP)
    dcOLAP.DataFields(i).DisplayAs = DCDTNormal
    If i = 0 Then
        dcOLAP.DataFields(i).NumberFormat = "  #,##0"
    Else
        dcOLAP.DataFields(i).NumberFormat = "$#,##0.00;($#,##0.00)"
    End If

mnuNormal_Click_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
mnuNormal_Click_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume mnuNormal_Click_Exit

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

Private Sub SetDispAs(iDispAs As Integer)

    On Error GoTo SetDispAs_Err

    mnuNormal.Checked = (iDispAs = DCDTNormal)
    mnuColPercent.Checked = (iDispAs = DCDTPercentCol)
    mnuRowPercent.Checked = (iDispAs = DCDTPercentRow)

SetDispAs_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
SetDispAs_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume SetDispAs_Exit

End Sub

Private Sub mnuRowPercent_Click()

    On Error GoTo mnuRowPercent_Click_Err

Dim i As Integer
    i = GetCurrDataField(dcOLAP)
    dcOLAP.DataFields(i).DisplayAs = DCDTPercentRow
    dcOLAP.DataFields(i).NumberFormat = "% #.00"

mnuRowPercent_Click_Exit:  ' SDVB autocode
    On Error Resume Next   ' SDVB autocode
    Exit Sub               ' SDVB autocode
mnuRowPercent_Click_Err:   ' SDVB autocode
    MsgBox Error           ' SDVB autocode
    Resume mnuRowPercent_Click_Exit

End Sub

Private Sub mnuSave_Click()

    On Error GoTo mnuSave_Click_Err

    dcOLAP.Save loctext$ & "MARGIN.CUB", 1

mnuSave_Click_Exit:       ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
mnuSave_Click_Err:        ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume mnuSave_Click_Exit

End Sub


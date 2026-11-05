VERSION 5.00
Object = "{6D63F73C-3688-11D0-9C0F-00A0C90F29FC}#2.0#0"; "dcube.ocx"
Begin VB.Form frmOrderInProgress 
   Caption         =   "Order In Progress - Right Click in Grid Area for a Context Menu"
   ClientHeight    =   4830
   ClientLeft      =   2100
   ClientTop       =   3210
   ClientWidth     =   7950
   Icon            =   "OLAPOrderInProgress.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4830
   ScaleWidth      =   7950
   WindowState     =   2  'Maximized
   Begin DynamiCubeLibCtl.DCube dcOLAP 
      Height          =   4815
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   7935
      _ExtentX        =   13996
      _ExtentY        =   8493
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
      DCConnect       =   "DSN=SynergyV"
      DCDatabaseName  =   "D:\SynergyV\SynergyV.mdb"
      CursorStyle     =   0
      FieldsBackColor =   8421504
      FieldsForeColor =   16777215
      HeadingsForeColor=   0
      HeadingsBackColor=   16777215
      DCRecordSource  =   "SELECT * FROM OlapOrderInProgress"
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
      HeaderCaption   =   "SynergyV OLAP - Order in Progress"
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
      DCConnectType   =   3
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
      Fields          =   "OLAPOrderInProgress.frx":068A
   End
   Begin VB.Menu mnuDynamiCube 
      Caption         =   "&Synergy V"
      Begin VB.Menu mnuDataMarker 
         Caption         =   "&Data Marker"
      End
      Begin VB.Menu mnuGraph 
         Caption         =   "&Graph"
      End
      Begin VB.Menu mnuPerformance 
         Caption         =   "Perfor&mance"
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
Attribute VB_Name = "frmOrderInProgress"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private bSetMenu As Boolean

Private Sub dcOLAP_FetchAttributes(ByVal cellAttrib As DynamiCubeLibCtl.Attrib)

    On Error GoTo dcOLAP_FetchAttributes_Err

    Dim i As Integer
    ' DataFieldIndex:
    ' DataValue:
    ' ForeColor:
    ' BackColor:
    
    With cellAttrib
    If .DataFieldIndex <> -1 And iRanges <> 0 Then
        For i = 0 To iRanges - 1
           If .DataValue >= aRanges(i).dStart And .DataValue < aRanges(i).dEnd Then
                .ForeColor = aRanges(i).lColor
               Exit For
           End If
        Next
    End If
    End With

dcOLAP_FetchAttributes_Exit:  ' SDVB autocode
    On Error Resume Next      ' SDVB autocode
    Exit Sub                  ' SDVB autocode
dcOLAP_FetchAttributes_Err:   ' SDVB autocode
    MsgBox Error              ' SDVB autocode
    Resume dcOLAP_FetchAttributes_Exit

End Sub

Private Sub dcOLAP_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)
    On Error Resume Next
    If Button = vbRightButton Then
        ' First select the cell under the mouse
        Dim row As Long, column As Long
        If dcOLAP.GetCellForPoint(x, Y, row, column) Then
            dcOLAP.SelStartCol = column
            dcOLAP.SelEndCol = column
            dcOLAP.SelStartRow = row
            dcOLAP.SelEndRow = row
            dcOLAP.Refresh
        End If
    End If
    On Error GoTo 0
End Sub

Private Sub dcOLAP_MouseUp(Button As Integer, Shift As Integer, x As Single, Y As Single)

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

Private Sub DCube1_FetchAttributes(ByVal cellAttrib As DynamiCubeLibCtl.Attrib)

End Sub

Private Sub DCube1_SelChange()

End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Load()
    On Error GoTo Form_Load_Err
    Dim strSQL, strHeader As String
    
    With frmMenuOLAP
        strSQL = "SELECT * FROM OlapOrderInProgress WHERE " & _
                 "(([DateOfEntry] >= #" & .calFromDate & "#) AND " & _
                 "([DateOfEntry] <= #" & .calToDate & "#))"
        strHeader = dcOLAP.HeaderCaption & " from " & _
                 Format(.calFromDate, "dd mmm yyyy") & " to " & _
                 Format(.calToDate, "dd mmm yyyy")
    End With
    dcOLAP.HeaderCaption = strHeader
    dcOLAP.DCConnectType = DCCT_ODBC
    dcOLAP.DCConnect = "DSN=SynergyV;"
    dcOLAP.DCRecordSource = strSQL
    dcOLAP.RefreshData
    
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

    ExportToText dcOLAP, "OrderInProgress.TXT"

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
    dcOLAP.DataFields(i).NumberFormat = "$#,##0.00;($#,##0.00)"

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

Private Sub Form_Resize()

    On Error GoTo Form_Resize_Err

    If Me.WindowState <> vbMinimized Then
        dcOLAP.Width = Me.Width - 400
        dcOLAP.Height = Me.Height - 1200
    End If

Form_Resize_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Resize_Err:          ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Resize_Exit

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

    dcOLAP.Save loctext$ & "OrderInProgress.CUB", 1

mnuSave_Click_Exit:       ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
mnuSave_Click_Err:        ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume mnuSave_Click_Exit

End Sub

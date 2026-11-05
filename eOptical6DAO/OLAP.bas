Attribute VB_Name = "modOLAP"
Option Explicit

Public Type udtField
    Name As String
    Caption As String
    Orient As Integer
    GFCaption As String
    GFType As Integer
End Type

Public Type udtRange
    dStart As Double
    dEnd As Long
    lColor As Long
End Type
Public iRanges As Integer
Public aRanges() As udtRange

Public dcCurrent As Control

Sub DispGraph(dc As Control)
Dim iSet As Integer
Dim iSets As Integer
Dim iPoints As Integer
Dim aLabels() As String
Dim aLegends() As String
Dim i, j, l As Integer
Dim row, rows, Col, cols As Integer
    On Error GoTo ehDispGraph
    
    iPoints = 0
    iSets = 0
    If dc.SelStartCol <= dc.SelEndCol Then
        i = dc.SelStartCol
        l = dc.SelEndCol
    Else
        i = dc.SelEndCol
        l = dc.SelStartCol
    End If
    Do While i <= l
        iPoints = iPoints + 1
        ReDim Preserve aLabels(iPoints)
        For j = 1 To dc.GetColDepth(i)
            aLabels(iPoints) = aLabels(iPoints) + dc.ColHeading(i, j) + " "
        Next
        i = dc.GetNextCol(i)
    Loop
    
    If dc.SelStartRow <= dc.SelEndRow Then
        i = dc.SelStartRow
        l = dc.SelEndRow
    Else
        i = dc.SelEndRow
        l = dc.SelStartRow
    End If
    Do While i <= l
        iSets = iSets + 1
        ReDim Preserve aLegends(iSets)
        For j = 1 To dc.GetRowDepth(i)
            aLegends(iSets) = aLegends(iSets) + dc.RowHeading(i, j) + " "
        Next
        i = dc.GetNextRow(i)
    Loop
    
    'Debug.Print "Legends": For i = 1 To iSets: Debug.Print aLegends(i): Next
    'Debug.Print "Labels": For i = 1 To iPoints: Debug.Print aLabels(i): Next
    If iSets < 1 Then Exit Sub
'    frmGraph!grfDemo.NumSets = iSets
    frmGraph!mscDemo.RowCount = iSets
'    If iPoints > 2 Then frmGraph!grfDemo.NumPoints = iPoints
    If iPoints > 2 Then frmGraph!mscDemo.ColumnCount = iPoints
    For i = 1 To iSets
'         frmGraph!grfDemo.ThisSet = i
'         frmGraph!grfDemo.LegendText = aLegends(i)
         frmGraph!mscDemo.row = i
         frmGraph!mscDemo.RowLabel = aLegends(i)
    Next
    For i = 1 To iPoints
'        frmGraph!grfDemo.ThisPoint = i
'        frmGraph!grfDemo.LabelText = aLabels(i)
        frmGraph!mscDemo.column = i
        frmGraph!mscDemo.ColumnLabel = aLabels(i)
    Next
    
    If dc.SelStartCol <= dc.SelEndCol Then
        cols = dc.SelEndCol
        Col = dc.SelStartCol
    Else
        cols = dc.SelStartCol
        Col = dc.SelEndCol
    End If
    
    If dc.SelStartRow <= dc.SelEndRow Then
        rows = dc.SelEndRow
    Else
        rows = dc.SelStartCol
    End If
    i = 1
    Do While Col <= cols
        If dc.SelStartRow <= dc.SelEndRow Then
            row = dc.SelStartRow
        Else
            row = dc.SelEndRow
        End If
        j = 1
        Do While row <= rows
'            frmGraph!grfDemo.ThisSet = j
'            frmGraph!grfDemo.ThisPoint = i
'            frmGraph!grfDemo.GraphData = dc.DataValue(row, Col)
            frmGraph!mscDemo.row = j
            frmGraph!mscDemo.column = i
            frmGraph!mscDemo.Data = dc.DataValue(row, Col)
            row = dc.GetNextRow(row)
            j = j + 1
        Loop
        i = i + 1
        Col = dc.GetNextCol(Col)
    Loop
    
'    frmGraph!grfDemo.DrawMode = 2
    frmGraph!mscDemo.DrawMode = VtChDrawModeDraw
    frmGraph.Show vbModal
    
    Exit Sub
    
ehDispGraph:
    MsgBox Error$, vbOKOnly + vbCritical, "Error"
    Exit Sub
End Sub

Sub OLAPMain()

    On Error GoTo OLAPMain_Err

Dim sDBName As String

    Screen.MousePointer = 0
    sDBName = loctext$ & "synergyv.mdb"
    If Dir(sDBName) = "" Then
        MsgBox "SynergyV Database Not Found", vbCritical + vbOKOnly, "Error"
        End
    End If
    'frmOLAP.Show vbModal       removed by Paulus

OLAPMain_Exit:                ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
OLAPMain_Err:                 ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume OLAPMain_Exit

End Sub

Function GetCurrDataField(dc As Control) As Integer

    On Error GoTo GetCurrDataField_Err

Dim i, j As Integer
Dim iFlds As Integer

    iFlds = 0
    For i = 0 To (dc.DataFields.Count - 1)
        If dc.DataFields(i).Visible Then iFlds = iFlds + 1
    Next
        
    i = dc.SelStartCol Mod iFlds
    For j = 0 To dc.DataFields.Count - 1
        If dc.DataFields(j).Visible And i = 0 Then
            GetCurrDataField = j
            Exit Function
        End If
        i = i - 1
    Next

GetCurrDataField_Exit:    ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Function         ' SDVB autocode
GetCurrDataField_Err:     ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume GetCurrDataField_Exit

End Function

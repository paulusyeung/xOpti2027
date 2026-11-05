Attribute VB_Name = "modExport"

Public Sub ExportToExcel(dc As Control)

    On Error GoTo ExportToExcel_Err

    Dim oXLApp As Object
    Dim iRow, iCol, iDepth As Integer
    Dim iRowFields, iColFields As Integer
    Dim iXLRow, iXLCol As Integer
    Dim SubTitle, BookTitle As String
    Dim iCount As Integer
    
    
    'Creates OLE object to Excel
    Set oXLApp = CreateObject("excel.application")
    'Sending VB Applications Edition commands to Excel via the new OLE
    'object to create a new workbook fill in numbers, create the chart, and
    'rotate the chart.
    
    oXLApp.SheetsInNewWorkbook = 1
   
    Set newBook = oXLApp.Workbooks.Add
    
    iCount = InStr(Screen.ActiveForm.Caption, "-")
    If iCount <> 0 Then
        BookTitle = Left(Screen.ActiveForm.Caption, iCount - 1)
        BookTitle = Trim(BookTitle)
    Else
        BookTitle = "NewBook"
    End If
    
    With newBook
        .Title = BookTitle
        .Sheets("Sheet1").Name = BookTitle
        .SaveAs FileName:=BookTitle & ".xls"
    End With
    
    oXLApp.Visible = True
    
    'Get iXLRow and iXLCol
    iRowFields = 0
    iColFields = 0
    iRow = 0
    iCol = 0
    Do While (iRow < dc.RowCount)
        iDepth = dc.GetRowDepth(iRow)
        If iDepth > iRowFields Then iRowFields = iDepth
        iRow = dc.GetNextRow(iRow)
    Loop
    Do While (iCol < dc.ColCount)
        iDepth = dc.GetColDepth(iCol)
        If iDepth > iColFields Then iColFields = iDepth
        iCol = dc.GetNextCol(iCol)
    Loop
    
    'Get Column Title & enable Prefix-character
    oXLApp.TransitionNavigKeys = True
    iCol = 0
    iXLCol = 1 + iRowFields
    Do While (iCol < dc.ColCount)
        iCount = dc.DataFields.Count
        If iCount > 1 Then
            For iDepth = 1 To dc.GetColDepth(iCol) - 1
                With oXLApp.cells(iDepth, iXLCol)
                    .Font.bold = True
                End With
                SubTitle = Chr(34) & dc.ColHeading(iCol, iDepth)
                oXLApp.cells(iDepth, iXLCol).Value = SubTitle
                If iDepth = 1 And SubTitle Like "?Total" Then
                    oXLApp.Columns(iXLCol).Font.bold = True
                End If
            Next
            With oXLApp.cells(iDepth, iXLCol)
                  .Font.bold = True
            End With
            oXLApp.cells(iDepth, iXLCol).Value = Chr(34) & dc.DataFields(iCol Mod iCount).Caption
        Else
            For iDepth = 1 To dc.GetColDepth(iCol)
                With oXLApp.cells(iDepth, iXLCol)
                    .Font.bold = True
                End With
                SubTitle = Chr(34) & dc.ColHeading(iCol, iDepth)
                'Debug.Print iCount; iCol; depth; SubTitle
                oXLApp.cells(iDepth, iXLCol).Value = SubTitle
                If iDepth = 1 And SubTitle Like "?Total" Then
                    oXLApp.Columns(iXLCol).Font.bold = True
                End If
            Next
        End If
        iCol = dc.GetNextCol(iCol)
        iXLCol = iXLCol + 1
    Loop
     
    'Get Row Title & disable prefix-character
    oXLApp.TransitionNavigKeys = False
    iRow = 0
    iXLRow = 1 + iColFields
    Do While (iRow < dc.RowCount)
        For iDepth = 1 To dc.GetRowDepth(iRow)
            With oXLApp.cells(iXLRow, iDepth)
              .Font.bold = True
            End With
            SubTitle = dc.RowHeading(iRow, iDepth)
            oXLApp.cells(iXLRow, iDepth).Value = SubTitle
            If iDepth = 1 And SubTitle Like "Total" Then
                oXLApp.rows(iXLRow).Font.bold = True
            End If
         Next
        iRow = dc.GetNextRow(iRow)
        iXLRow = iXLRow + 1
    Loop
    
    'Get Data Values
    iXLRow = iColFields + 1
    iRow = 0
    Do While iRow < dc.RowCount
        iCol = 0
        iXLCol = iRowFields + 1
        iCount = 0
        Do While iCol < dc.ColCount
            If iCount >= dc.DataFields.Count Then iCount = 0
            If dc.DataFields(iCount).NumberFormat Like "*%*" Then
                oXLApp.cells(iXLRow, iXLCol).Style = "Percent"
            ElseIf dc.DataFields(iCount).NumberFormat Like "*$*" Then
                oXLApp.cells(iXLRow, iXLCol).NumberFormat = "_($#,##0.00_);_(($#,##0.00);_($* ""-""??_);_(@_)"
            Else
                oXLApp.cells(iXLRow, iXLCol).NumberFormat = "_(* #,##0_);_(* (#,##0);_(* ""-""??_);_(@_)"
            End If                                                             ' Else as it
            iCount = iCount + 1
            oXLApp.cells(iXLRow, iXLCol).Value = dc.DataValue(iRow, iCol)
            iCol = dc.GetNextCol(iCol)
            iXLCol = iXLCol + 1
        Loop
        iRow = dc.GetNextRow(iRow)
        iXLRow = iXLRow + 1
    Loop
    
    'Final setting of Spreadsheet
    oXLApp.cells.Select
    oXLApp.cells.EntireColumn.AutoFit
    oXLApp.cells(iColFields + 1, iRowFields + 1).Select
    oXLApp.activewindow.FreezePanes = True
    
ExportToExcel_Exit:       ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
ExportToExcel_Err:        ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume ExportToExcel_Exit

End Sub
Public Sub ExportToText(dc As Control, sFileName As String)

    On Error GoTo ExportToText_Err

Dim hFile As Integer
Dim iRow, iCol, iDepth As Integer
Dim iRowFields, iColFields As Integer
Dim iSpaces As Integer

    hFile = FreeFile
    Open sFileName For Output As #hFile ' Create file.
    
    iRowFields = dc.GetRowDepth(0)
    iColFields = dc.GetColDepth(0)
    
    For iDepth = 1 To dc.GetColDepth(iCol)
        iCol = 0
                ' space for rowheading area
        For iSpaces = 1 To iRowFields
            Print #hFile, Chr(9);
        Next
                ' column headings
        Do While (iCol < dc.ColCount)
            Print #hFile, dc.ColHeading(iCol, iDepth) + Chr(9);
            iCol = dc.GetNextCol(iCol)
        Loop
        Print #hFile,
    Next
    
    iRow = 0
    Do While (iRow < dc.RowCount)
                ' output row headings
        For iDepth = 1 To dc.GetRowDepth(iRow)
            Print #hFile, dc.RowHeading(iRow, iDepth) + Chr(9);
        Next
                ' if current iDepth is smaller than maxsize output spaces
        Do While iDepth <= iRowFields
            Print #hFile, Chr(9);
            iDepth = iDepth + 1
        Loop

        '---- now output data----
   
        iCol = 0

        Do While iCol < dc.ColCount
            Print #hFile, Str$(dc.DataValue(iRow, iCol)) + Chr(9);
            iCol = dc.GetNextCol(iCol)
        Loop
        ' incr loop counters for rows
        iRow = dc.GetNextRow(iRow)
        Print #hFile,
    Loop
 
    Close #hFile

ExportToText_Exit:        ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
ExportToText_Err:         ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume ExportToText_Exit

End Sub

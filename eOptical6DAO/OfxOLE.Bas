Attribute VB_Name = "OfxOLEAutomation"
'------------------------------------------------------------------------------
' Module:   Ofx - OLE Automation
'
' Purpose:  OLE 2.0 automation helpers.
'
' Notes:    Access only supports OLE automation in version 7.0 (Access 95) or greater.
'
' Examples: Access 95 Usage:
'
'           After the object is "set" you need to open a database.  This function
'           will only open the database if it is not already open, saving some
'           performance expense.
'
'           If (ofx_SetAccessObject()) Then
'               If (ofx_ACCESS_OpenDatabase("employees.mdb")) Then
'                   ofx_ACCESS_ListReports Combo1
'               End If
'           End If
'
'           Private Sub btnPrint_Click()
'               ofx_ACCESS_PrintReport Combo1.Text, True
'           End Sub
'
'
'           Excel Usage:
'
'           This works the same across all platforms.  Note that Excel will initially
'           be created as NOT visible.
'
'           If (ofx_SetExcelObject()) Then
'               If (ofx_EXCEL_OpenFile("expenses.xls")) Then
'               ofxApp.oExcel.Visible = True        'Key Point
'               End If
'           End If
'
'
'           Word Usage:
'
'           If (ofx_SetWordObject()) Then
'               If (ofx_WORD_OpenFile("d:\data\doc1.doc")) Then
'                   'do something with ofxApp.oWord
'               End If
'           End If
'
'
'           Project usage:
'
'           If (ofx_SetProjectObject()) Then
'               ofxApp.oProject.OrganizerDeleteItem >...>
'           End If
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

'----- Main Window Class names

Public Const sWordClassName = "OpusApp"                         ' Word for Windows
Public Const sExcelClassName = "XLMain"                         ' Excel
Public Const sProjectClassName = "JWinproj-WhimperMainClass"    ' WinProj
Public Const sAccessClassName = "OMain"                         ' Access


#If OFXOPT_AUTOMATION Or MSA Then

'------------------------------------------------------------------------------
' Function: ofx_WORD_InsertInfo
'
' Purpose:  Inserts a string into a bookmarked location in a Word document.
'
' Params:   sBk   (I) The name of the bookmark (where the data should be inserted)
'           sData (I) The data (string) to insert.
'
' Returns:  True if successful, False otherwise
'
' Notes:    This function will actually do 3 things:
'
'           1. Insert data at a bookmark.
'           2. RE-Edit the bookmark to encompass the entire selection.
'           3. Insert a DocumentVariable (a hidden document property) with the name
'               of the bookmark and the contents of sData.
'
'           For FUTURE (and further) expansion a Document Variable is created
'           regardless of whether or not a matching bookmark can be found.
'
'           This is so that if you wanted to store phone numbers (or something) in
'           a letter, then later be able to automatically address and fax the thing,
'           you would have the data for this stored in the document.
'------------------------------------------------------------------------------
Public Function ofx_WORD_InsertInfo(ByVal sBk As String, sData As String) As Boolean
    On Error GoTo ofx_WORD_InsertInfo_Error
    
    #If DBG Then
        ASSERT (Not (ofxApp.oWord Is Nothing)), "ofx_WORD_InsertInfo", "Word Object is not set."
    #End If
    
    If (ofxApp.oWord.ExistingBookmark(sBk)) Then
        
        ofxApp.oWord.EditGoTo sBk                       ' Goto the bookmark
        If (ofxApp.oWord.SelType() = 2) Then            ' Solid selection
            ofxApp.oWord.EditClear                      ' Delete, which deletes the bookmark
            ofxApp.oWord.EditBookmark sBk               ' Re-insert the bookmark
        End If

        ofxApp.oWord.INSERT ofx_WORD_ParaToNewLine(sData)         ' Do the insert (even if it is blank)
        
        If (Len(sData) > 0) Then
            ofxApp.oWord.ExtendSelection
            ofxApp.oWord.EditGoTo sBk
            
            If (ofxApp.oWord.ExistingBookmark(sBk)) Then
                ofxApp.oWord.EditBookmark sBk
            End If
        End If
    
        ofxApp.oWord.Cancel
    
    End If

    '----- Useful, inexpensive data stored with the document, even if it was
    '----- not inserted.
    
    ofxApp.oWord.SetDocumentVar sBk, sData      ' Set the document variable
    
    ofx_WORD_InsertInfo = True                  ' No errors
    
ofx_WORD_InsertInfo_Exit:
    Exit Function
ofx_WORD_InsertInfo_Error:
    Call ofx_GenericError("ofx_WORD_InsertInfo()", Err)
    Resume ofx_WORD_InsertInfo_Exit
End Function

'------------------------------------------------------------------------------
' Function: ofx_WORD_InsertRecordset
'
' Purpose:  Inserts the CURRENT row of the (rs) recordset into the document
'
' Params:   rs  (I) Recordset to insert
'
' Notes:    This function uses "InsertInfo" which uses some (simple) WordBasic
'           commands.  Essentially, the data from the field is inserted into
'           the document at a "bookmarked" location, where the bookmark name
'           is the same as the field name.
'
' Returns:  TRUE on success, else FALSE.
'
' See Also: ofx_WORD_InsertInfo()
'------------------------------------------------------------------------------
Public Function ofx_WORD_InsertRecordset(rs As Recordset) As Boolean
    On Error GoTo ofx_WORD_InsertRecordset_Error
    
    #If DBG Then
        ASSERT (Not (ofxApp.oWord Is Nothing)), "ofx_WORD_InsertRecordset", "Word Object is not set."
    #End If
    
    Dim i As Integer
    
    If (Not (rs.BOF)) Then
        Dim fld As Field

        For Each fld In rs.Fields
            Call ofx_WORD_InsertInfo(fld.Name, CStr(Nz((fld.Value))))
        Next fld
    End If

    ofx_WORD_InsertRecordset = True

ofx_WORD_InsertRecordset_Exit:
    Exit Function
ofx_WORD_InsertRecordset_Error:
    Call ofx_GenericError("ofx_WORD_InsertRecordset()", Err)
    Resume ofx_WORD_InsertRecordset_Exit
End Function

'------------------------------------------------------------------------------
' Function: ofx_EXCEL_IsFileOpen
'
' Purpose:  Determines if file is already open in Excel.
'
' Params:   sFile   (I) The Excel .XLS file
'
' Returns:  TRUE if the given file is already open in Excel, else FALSE.
'------------------------------------------------------------------------------
Public Function ofx_EXCEL_IsFileOpen(sFile As String) As Integer
    On Error GoTo ofx_EXCEL_IsFileOpen_Error

    #If DBG Then
        ASSERT (Not (ofxApp.oExcel Is Nothing)), "ofx_EXCEL_IsFileOpen", "Excel Object is not set."
    #End If

    Dim nWorkbooks As Integer
    Dim i As Integer
    
    nWorkbooks = ofxApp.oExcel.Workbooks.Count
    
    For i = 1 To nWorkbooks
        If (0 = StrComp(sFile, CStr(Nz(ofxApp.oExcel.Workbooks(i).Path & "\" & ofxApp.oExcel.Workbooks(i).Name)), 1)) Then
            ofx_EXCEL_IsFileOpen = True
        End If
    Next

ofx_EXCEL_IsFileOpen_Exit:
    Exit Function
ofx_EXCEL_IsFileOpen_Error:
    Call ofx_GenericError("ofx_EXCEL_IsFileOpen()", Err)
    Resume ofx_EXCEL_IsFileOpen_Exit
End Function

'------------------------------------------------------------------------------
' Function: ofx_EXCEL_OpenFile
'
' Purpose:  Opens a file in Excel.
'
' Params:   sFile   (I) The Excel .XLS file
'
' Returns:  TRUE if the is successfully opened or already open, else FALSE.
'------------------------------------------------------------------------------
Public Function ofx_EXCEL_OpenFile(sFile As String) As Boolean
    On Error GoTo ofx_EXCEL_OpenFile_Error
    
    Dim bOk As Boolean
    
    bOk = False

    #If DBG Then
        ASSERT (Not (ofxApp.oExcel Is Nothing)), "ofx_EXCEL_OpenFile", "Excel Object is not set."
    #End If

    If (Not (ofx_EXCEL_IsFileOpen(sFile))) Then
        ofxApp.oExcel.Workbooks.Open sFile
    End If
    
    bOk = True

ofx_EXCEL_OpenFile_Exit:
    ofx_EXCEL_OpenFile = bOk
    Exit Function
ofx_EXCEL_OpenFile_Error:
    Call ofx_GenericError("ofx_EXCEL_OpenFile()", Err)
    Resume ofx_EXCEL_OpenFile_Exit
End Function

'------------------------------------------------------------------------------
' Sub:      ofx_WORD_OpenFile
'
' Purpose:  Opens a file in Word.
'
' Params:   sFile   (I) The name of the file
'
' Returns:  True on success, else False.
'------------------------------------------------------------------------------
Public Function ofx_WORD_OpenFile(sFile As String) As Boolean
    On Error GoTo ofx_WORD_OpenFile_Error
    
    Dim bOk As Boolean
    
    bOk = False
    
    #If DBG Then
        ASSERT (Not (ofxApp.oWord Is Nothing)), "ofx_WORD_OpenFile", "Word Object is not set."
    #End If
    
    '----- Check args
    
    If (ofxApp.oWord Is Nothing) Then GoTo ofx_WORD_OpenFile_Exit

    If (False = ofx_FileExists(sFile)) Then
        Debug.Print "The file " & sFile & " does not exist."
        GoTo ofx_WORD_OpenFile_Exit
    End If
    
    ofx_WaitCursor True
    
    '----- Make sure we have a Word object
    
    If (Not ofx_SetWordObject()) Then GoTo ofx_WORD_OpenFile_Exit
    
    '----- Open the file
    
    ofxApp.oWord.FileOpen sFile
    Call ofx_ActivateApp(sWordClassName, "Microsoft Word", SW_SHOWMAXIMIZED)
    
    bOk = True

ofx_WORD_OpenFile_Exit:
    ofx_WaitCursor False
    ofx_WORD_OpenFile = bOk
    Exit Function
ofx_WORD_OpenFile_Error:
    Call ofx_GenericError("ofx_WORD_OpenFile()", Err)
    Resume ofx_WORD_OpenFile_Exit
End Function

'------------------------------------------------------------------------------
' Function: ofx_WORD_ParaToNewLine
'
' Purpose:  Converts CRLF combination to Chr$(11).
'
' Params:   sParagraph  (I) String with, optionally, embedded CRLF's.
'
' Returns:  The converted string.
'
' Notes:    In general, you may want to avoid using CRLF in Word when the text
'           that you are inserting is really one piece (such as an address).
'           This function will replace CRLF with the special Word Chr$(11), or
'           "soft return" which keeps the inserted text as one paragraph.
'
'           7/17/96  Modified to NOT alter sParagraph
'------------------------------------------------------------------------------
Function ofx_WORD_ParaToNewLine(ByVal sParagraph As String) As String
    Dim nPos As Integer
    
    nPos = InStr(sParagraph, Chr$(13))

    If (nPos = 0) Then
        ofx_WORD_ParaToNewLine = sParagraph
        GoTo ofx_WORD_ParaToNewLine_Exit
    End If

    While (nPos)
        sParagraph = left$(sParagraph, nPos - 1) + Chr$(11) + Mid$(sParagraph, nPos + 2)
        nPos = InStr(sParagraph, Chr$(13))
    Wend

    ofx_WORD_ParaToNewLine = sParagraph

ofx_WORD_ParaToNewLine_Exit:
    Exit Function
End Function

'------------------------------------------------------------------------------
' Function: ofx_SetExcelObject
'
' Purpose:  Creates or "sets" the global object representing Excel.
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Public Function ofx_SetExcelObject() As Integer
    On Error GoTo ofx_SetExcelObject_Error

    Dim hWnd As Long
    hWnd = FindWindow(sExcelClassName, vbNullString)

    If (0 = hWnd) Then          'Excel may have been shut down
        Set ofxApp.oExcel = Nothing
    End If

    '----- Is the object already created
    
    If (Not (ofxApp.oExcel Is Nothing)) Then
        ofx_SetExcelObject = True
        GoTo ofx_SetExcelObject_Exit
    End If
    
    On Error GoTo 0
    On Error Resume Next

    '----- First try to get the object without starting a new instance of excel
    
    If (hWnd) Then Set ofxApp.oExcel = GetObject(, "Excel.Application")

    DoEvents

    If (ofxApp.oExcel Is Nothing) Then
        Err = 0
        Set ofxApp.oExcel = CreateObject("Excel.Application")

        If (ofxApp.oExcel Is Nothing) Then
            Call ofx_DoMessageBox(ofxErrorCreateObjectExcel)
            GoTo ofx_SetExcelObject_Exit
        End If
    End If

    ofx_SetExcelObject = (Err = 0)

ofx_SetExcelObject_Exit:
    Exit Function
ofx_SetExcelObject_Error:
    Call ofx_GenericError("ofx_SetExcelObject()", Err)
    Exit Function
End Function

'------------------------------------------------------------------------------
' Function: ofx_SetProjectObject
'
' Purpose:  Creates or "sets" the global object representing Project.
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Public Function ofx_SetProjectObject() As Boolean
    On Error GoTo ofx_SetProjectObject_Error
       
    Dim hWnd As Long
    hWnd = FindWindow(sProjectClassName, vbNullString)
    
    '----- If project is gone, then kill the object, just in case
    
    If (0& = hWnd) Then Set ofxApp.oProject = Nothing
    
    If (ofxApp.oProject Is Nothing) Then
        Set ofxApp.oProject = CreateObject("MSProject.Application")
    End If
    
    ofx_SetProjectObject = Not (ofxApp.oProject Is Nothing)
    
ofx_SetProjectObject_Exit:
    Exit Function
ofx_SetProjectObject_Error:
    Set ofxApp.oProject = Nothing
    Call ofx_GenericError("ofx_SetProjectObject()", Err)
    Resume ofx_SetProjectObject_Exit
End Function

'------------------------------------------------------------------------------
' Function: ofx_SetWordObject
'
' Purpose:  Creates or "sets" the global object representing Word.
'
' Returns:  TRUE on success, else FALSE.
'
' Note:     The object should be destroyed (set back to nothing) before the
'           app is closed.  Normally, this is handled in the ofx_Uninitialize()
'           procedure.
'------------------------------------------------------------------------------
Public Function ofx_SetWordObject() As Boolean
    On Error GoTo ofx_SetWordObject_Error

    Dim hWnd As Long
    hWnd = FindWindow(sWordClassName, vbNullString)

    If (0 = hWnd) Then          'Word may have been shut down
        Set ofxApp.oWord = Nothing
    End If
    
    If (Not (ofxApp.oWord Is Nothing)) Then
        ofx_SetWordObject = True
        GoTo ofx_SetWordObject_Exit
    End If

ofx_SetWordObject_CreateObject:

    '----- Always use CreateObject with word, there is NO application object
    '----- that is exposed in version 6.x
    
    Set ofxApp.oWord = CreateObject("Word.Basic")
    
    If (ofxApp.oWord Is Nothing) Then
        Call ofx_DoMessageBox(ofxErrorCreatingWordObject)
        GoTo ofx_SetWordObject_Exit
    End If

    ofx_SetWordObject = True

ofx_SetWordObject_Exit:
    Exit Function
ofx_SetWordObject_Error:
    Call ofx_GenericError("ofx_SetWordObject()", Err)
    Resume ofx_SetWordObject_Exit
End Function
#If Win32 And Not MSA Then
'------------------------------------------------------------------------------
' Function: ofx_SetAccessObject
'
' Purpose:  Creates or "sets" the global object representing Access.
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Public Function ofx_SetAccessObject() As Boolean
    On Error GoTo ofx_SetAccessObject_Error
       
    Dim hWnd As Long
    hWnd = FindWindow(sAccessClassName, vbNullString)
    
    '----- If access is gone, then kill the object, just in case
    
    If (0& = hWnd) Then Set ofxApp.oAccess = Nothing
    
    If (ofxApp.oAccess Is Nothing) Then
        ' Current instance? Try GetObject
        If (hWnd) Then
            Set ofxApp.oAccess = GetObject(, "Access.Application.7")
        Else
            Set ofxApp.oAccess = CreateObject("Access.Application.7")
        End If
        
    End If
    
    ofx_SetAccessObject = Not (ofxApp.oAccess Is Nothing)
    
ofx_SetAccessObject_Exit:
    Exit Function
ofx_SetAccessObject_Error:
    Set ofxApp.oAccess = Nothing
    Call ofx_GenericError("ofx_SetAccessObject()", Err)
    Resume ofx_SetAccessObject_Exit
End Function




'------------------------------------------------------------------------------
' Function: ofx_ACCESS_ListReports
'
' Purpose:  Fills a ListBox or ComboBox with all the reports in a database.
'
' Params:   list    (I/O) List box into which to insert reports
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Public Function ofx_ACCESS_ListReports(list As Control) As Boolean
    On Error GoTo ofx_ACCESS_ListReports_Err

    list.Clear      'every time
    
    #If DBG Then
        ASSERT (Not (ofxApp.oAccess Is Nothing)), "ofx_ACCESS_ListReports", "Access Object is not set."
    #End If

    
    If (Not (ofxApp.oAccess Is Nothing)) Then
        ofx_WaitCursor True
        
        Dim nCount As Integer
        Dim cont As Object
               
        If (ofxApp.oAccess.DBEngine(0).Databases.Count > 0) Then
            Set cont = ofxApp.oAccess.DBEngine(0)(0).Containers("Reports").Documents
            nCount = cont.Count
            'Put each report into a list box
            Dim i As Integer
            For i = 1 To nCount
                list.AddItem cont(i - 1).Name
            Next
        Else
            Debug.Print "Warning: No database is open."
        End If
    End If
    
ofx_ACCESS_ListReports_Exit:
    On Error Resume Next
    ofx_WaitCursor False
    Exit Function
ofx_ACCESS_ListReports_Err:
    Call ofx_GenericError("ofx_ACCESS_ListReports()", Err)
    Resume ofx_ACCESS_ListReports_Exit
End Function




'------------------------------------------------------------------------------
' Function: ofx_ACCESS_OpenDatabase
'
' Purpose:  Opens a database in Access.
'
' Params:   sFileName   (I) Name of database to open (e.g. "myapp.mdb")
'
' Returns:  TRUE on success, else FALSE.
'
' Notes:    This procedure is "smart" enough not to close and open the same database
'           if it is already open in Access. It is important to note that any
'           startup forms or AutoExec macros in the database will NOT be suppressed.
'           This means that you could be in a "hung" state as Access waits for
'           user input, but your program (VB) is in the foreground.  Win32 being
'           non-preemptive, Access will wait forever.
'------------------------------------------------------------------------------
Public Function ofx_ACCESS_OpenDatabase(sFileName As String) As Boolean
    On Error GoTo ofx_ACCESS_OpenDatabase_Err
    
    #If DBG Then
        ASSERT (Not (ofxApp.oAccess Is Nothing)), "ofx_ACCESS_OpenDatabase", "Access Object is not set."
    #End If
        
    If (Not (ofxApp.oAccess Is Nothing)) Then
        
        If (ofx_FileExists(sFileName)) Then
        
            If (ofxApp.oAccess.DBEngine(0).Databases.Count > 0) Then
                If (0 = StrComp(ofxApp.oAccess.DBEngine(0)(0).Name, sFileName, 1)) Then
                    Debug.Print "Database " & sFileName & " is already open."
                Else
                    ofxApp.oAccess.CloseCurrentDatabase
                    ofxApp.oAccess.OpenCurrentDatabase sFileName
                End If
            Else
                ofxApp.oAccess.OpenCurrentDatabase sFileName
            End If
            
            ofx_ACCESS_OpenDatabase = True
            
        Else
            Debug.Print "Database " & sFileName & " does not exist."
        End If
        
    Else
        Debug.Print "The object 'ofxApp.oAccess' has not been set."
    End If
    
ofx_ACCESS_OpenDatabase_Exit:
    On Error Resume Next
    ofx_WaitCursor False
    Exit Function
ofx_ACCESS_OpenDatabase_Err:
    Call ofx_GenericError("ofx_ACCESS_OpenDatabase()", Err)
    Resume ofx_ACCESS_OpenDatabase_Exit
End Function


'------------------------------------------------------------------------------
' Function: ofx_ACCESS_PrintReport
'
' Purpose:  Run an Access report.
'
' Params:   sReportName (I) Name of report to run
'           bPreview    (I) Run report in preview mode?
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Function ofx_ACCESS_PrintReport(sReportName As String, bPreview As Boolean) As Boolean
    On Error GoTo ofx_ACCESS_PrintReport_Error
    
    #If DBG Then
        ASSERT (Not (ofxApp.oAccess Is Nothing)), "ofx_ACCESS_PrintReport", "Access Object is not set."
    #End If

    If (Not (ofxApp.oAccess Is Nothing)) Then
        If (ofxApp.oAccess.DBEngine(0).Databases.Count > 0) Then
        
            '----- Print Report with Print Preview
            
            ofxApp.oAccess.DoCmd.OpenReport sReportName, IIf(bPreview, 2, 1)
        
            '----- Activate Access
            
            If (bPreview) Then
                ofx_ActivateApp sAccessClassName, "Microsoft Access", SW_SHOWMAXIMIZED
            End If
        Else
            Debug.Print "No database is open."
        End If
    Else
        Debug.Print "The object 'ofxApp.oAccess' has not been set."
    End If
    
ofx_ACCESS_PrintReport_Exit:
    On Error Resume Next
    Exit Function
ofx_ACCESS_PrintReport_Error:
    Call ofx_GenericError("ofx_ACCESS_PrintReport()", Err)
    Resume ofx_ACCESS_PrintReport_Exit
End Function

#End If     ' Win32 And Not MSA

#End If     ' OFXOPT_AUTOMATION


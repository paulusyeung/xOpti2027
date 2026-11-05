Attribute VB_Name = "OfxErrorHandling"
'------------------------------------------------------------------------------
' Module:   Ofx - Error Handling
'
' Purpose:  Functions for logging and displaying errors to the user.
'
' VB:       This module is part of both the Start Developing for Access and Start Developing
'           for Visual Basic frameworks.  Table logging is only available for Access applications,
'           not VB.  VB application developers should ignore any references to table logging.
'
' Details:  The error logging options are driven by entries in the INI file for 16-bit
'           applications and the registry for 32-bit applications.
'
'   The INI file/registry entries are as follows:
'
'       [Error Tracking]
'       Log To Table=1
'       Log To File=1
'       Log File Name=c:\application\error.txt
'       Clear Table at Startup=1
'       Clear File at Startup=1
'       Show Generic Error=1
'
'   Options:
'       Log to Table  - True (1) if log errors to the _tbl_error_log table.
'                       False (0) if no logging to table.
'       Log to File   - True (1) if log errors to the file specified by the
'                       "Log File Name" setting.  False (0) if not.
'       Log File Name - Name of the error log disk file (used in conjunction with
'                       the "Log to File" setting.
'       Clear Table at Startup - True (1) if clear _tbl_error_log entries when
'                       the application starts via call to the ofx_InitErrorLog()
'                       function.  False if keep entries in the table and append
'                       and append new ones.
'       Clear File at Startup - True (1) if delete the error log file specified
'                       by the "Log File Name" entry when the application starts
'                       via a call to the ofx_InitErrorLog() function.  False if
'                       keep entries in the table and append new ones.
'       Show Generic Error - turn on/off the display of the message box in the
'                       ofx_GenericError() function.
'
'------------------------------------------------------------------------------

Option Explicit
Option Compare Text

'----- struct to hold current error flags

Type TYPE_OFX_APP_ERROR_INFO
    bInitialized As Boolean            ' has this structure been initilized
    bLogToTable As Boolean             ' True if logging errors to table.
    bLogToFile As Boolean              ' True if logging to file.
    sErrorTableName As String          ' Name of the error table
    sLogFileName As String             ' Name of file to log errors to.
    bClearTable As Boolean             ' Clear the error table?
    bClearFile As Boolean              ' Clear error file?
    bShowGenericError As Boolean       ' True if show MsgBox in ofx_GenericError().
End Type

'-----Initailized from the INI file.

Dim ofxErrInfo As TYPE_OFX_APP_ERROR_INFO

'----- struct to hold current error information (for the error dialog)

Type TYPE_OFX_CURRENT_ERROR
    sProcedure As String               ' Routine in which the error occurred.
    sErrText As String                 ' Error text to display to the user.
    sErrNumber As String               ' Error number to display to the user.
    dWhen As Variant                   ' Date & time of error
End Type


'----- Used by the error handler dialog.  Note this is GLOBAL!

Global ofxLastError As TYPE_OFX_CURRENT_ERROR

'----- Module Constants (ini file constants).  These should NOT be localized

Const S_SECTION_ERRORLOG$ = "Error Tracking"
Const S_KEY_ERRLOGTOTABLE$ = "Log To Table"
Const S_KEY_ERRLOGTOFILE$ = "Log To File"
Const S_KEY_ERRLOGFILENAME$ = "Log File Name"
Const S_CLEARTABLEATSTARTUP$ = "Clear Table at Startup"
Const S_KEY_CLEARFILEATSTARTUP$ = "Clear File at Startup"
Const S_KEY_SHOWGENERICERROR$ = "Show Generic Error"

'------------------------------------------------------------------------------
' Sub:      ofx_ClearErrorLog
'
' Purpose:  Deletes all entries in the error log table (_tbl_error_log) so that
'           it is ready to store new errors.  Also deletes the error log file
'           if it is specified in the INI file.
'
' Params:   bTable  (I) True to delete table entries, false to not.
'           bFile   (I) True to delete file log, false to not.
'------------------------------------------------------------------------------
Sub ofx_ClearErrorLog(bTable As Boolean, bFile As Boolean)
    On Error Resume Next

    #If MSA Then
        Dim sSql As String              ' SQL string to delete table entries.
        Dim nRetVal As Integer          ' Return value from ofx_DoSql() function.
    
        '----- If the host requested, delete all entries from the error log table.
    
        If bTable Then
            sSql = "DELETE FROM " & ofxErrInfo.sErrorTableName
            nRetVal = ofx_DoSql(sSql, dbFailOnError)
        End If
    #End If

    '----- If the host requested, delete the error log file if it exists
    
    If (bFile) Then
        If Len(ofxErrInfo.sLogFileName) Then
            If (ofx_FileExists(ofxErrInfo.sLogFileName)) Then Kill ofxErrInfo.sLogFileName
        End If
    End If
    
End Sub

'------------------------------------------------------------------------------
' Sub:      ofx_GenericError
'
' Purpose:  This is a generic error handler that displays the error to the
'           host.  Call this function from your error trap as a last case.
'
' Params:   sProcedureName  (I) Name of the module/routine in which the error occurred.
'           nErr            (I) Error to log.
'
' Example:  The following code will call ofx_GenericError() with the form
'           name (i.e. CStr(Nz(Me.Name)), the routine name (i.e. Form_Load()),
'           and pass the current error number.
'
'           ofx_GenericError CStr(Nz(Me.Name) & "::Form_Load()", Err
'------------------------------------------------------------------------------
Sub ofx_GenericError(Optional vProcedureName As Variant, Optional vErr As Variant)

    #If MSA Then
       'DON'T LOCALIZE!
        Const sErrorDialog = "OfxErrorHandler_dialog"
    
        #If DBG Then
            ASSERT ((Not (ofxApp.dbThis Is Nothing)) And (Not (ofxApp.wsThis Is Nothing))), "ofx_GenericError", "Application is not initialized.  Re-run startup."
        #End If
    #End If
    
    Dim sMsg As String
    Dim sError As String
    Dim sProcedureName As String
    Dim nErr As Long
    
    If (Not IsMissing(vProcedureName)) Then
        sProcedureName = CStr(vProcedureName)
    End If
    
    If (IsMissing(vErr)) Then
        nErr = Err.Number
    Else
        nErr = CLng(vErr)
    End If

    '----- If the caller's error number is the same as the Global "Err" variable
    '----- then use the Global "Error" variable to get complete information,
    '----- otherwise, get the error from access
    '----- this avoids those nasty errors like "Could not open |." from access.
    
    If (nErr = Err.Number) Then
        #If MSA Then
            '----- if this is a database error, then enum the DBEngine collection
        
            If (nErr = DBEngine.Errors(DBEngine.Errors.Count - 1).Number) Then
        
                Dim errObj As Error
                sError = " "
                For Each errObj In DBEngine.Errors
                    sError = sError & "[" & errObj.Source & "]:  "
                    sError = sError & errObj.Description
                    sError = sError & Chr$(13) & Chr$(10)
                Next
            Else
                sError = Err.Description
            End If
        #Else
            sError = Err.Description
        #End If
        
        ofxLastError.sErrText = sError
    Else
        sError = Error$(nErr)
    End If
    
    ofxLastError.dWhen = Now
     
    '----- Set the current error trap (it will clear the error).
    
    On Error Resume Next
    #If MSA Then
        DBEngine.Errors.Clear
    #End If

    If (False = ofxErrInfo.bInitialized) Then
        ofx_InitErrorLog
    End If

    '----- Initialize the module level variables used by the error handler dialog.
    
    ofxLastError.sErrNumber = CStr(Nz(nErr))
    ofxLastError.sProcedure = sProcedureName

    '----- Handle the error.
    
    If (nErr <> 0) Then                   ' Check for no error condition.
        If (Len(sProcedureName) > 0) Then
            sMsg = "AccessBasic Error in '" & sProcedureName & "'." & ofx_CRLF()
        End If
        
        sMsg = sMsg & "Error #: " & CStr(Nz(nErr)) & ofx_CRLF() & sError
    End If

    Call ofx_WaitCursor(False)         ' Normal cursor
    #If MSA Then
        Call ofx_SetStatusBar              ' Status bar back to "Ready"
        Call ofx_SetEcho(True)             ' Turn screen updating ON.
    #End If

    '----- First, log the error to the error log.
    
    Call ofx_LogError(sProcedureName, nErr, sError)

    '----- Display any error to the user.
    
    If (0 <> nErr And 0 <> ofxErrInfo.bShowGenericError) Then
        '----- The ONLY time that DoModal will return TRUE here
        '----- is if the user clicks the CODE button
        '----- which should only be visible with normal Access, not the runtime
        
        #If MSA Then
            If ofx_DoModal(sErrorDialog, acEdit, "", "") Then
                Call ofx_CloseForm(sErrorDialog)
                Stop                                'We're in debug mode: the developer requested break.
            End If
        #Else
            #If VB3 Then
            If (ofx_DoModal(ofx_dlgGenericError)) Then
            #Else
            If (ofx_DoModal(ofx_dlgGenericError)) Then
            #End If
                Call ofx_CloseForm(ofx_dlgGenericError)
                Stop                                'We're in debug mode: the developer requested break.
            End If
        #End If
    End If

End Sub

'------------------------------------------------------------------------------
' Sub:      ofx_InitErrorLog
'
' Purpose:  Init the error log settings by getting them from the
'           application's INI file.  If error logging is on, add
'           an entry to the log that the error logging was initialized.
'
'           See the description of the INI file entries in the
'           (declarations) section.
'------------------------------------------------------------------------------
Sub ofx_InitErrorLog()
    On Error Resume Next
    
    Dim nDummy As Integer

    'DONT LOCALIZE
    Const sDefaultErrorFile = "ofxerror.log"
    
    #If MSA Then
        '----- Log errors to an attached table?
        '----- Get the clear at startup settings from the INI file (default is yes).
    
        Call ofx_InitErrorTable
        ofxErrInfo.bClearTable = ofx_ProfileGetInt(S_SECTION_ERRORLOG, S_CLEARTABLEATSTARTUP, True)
    #End If

    '----- Determine if we are going to be logging errors to a file (default is no) and its name
    
    ofxErrInfo.bLogToFile = ofx_ProfileGetInt(S_SECTION_ERRORLOG, S_KEY_ERRLOGTOFILE, 0)
    ofxErrInfo.sLogFileName = ofx_ProfileGetString(S_SECTION_ERRORLOG, S_KEY_ERRLOGFILENAME, sDefaultErrorFile)
    
    If (ofxErrInfo.sLogFileName = sDefaultErrorFile) Then
        ofxErrInfo.sLogFileName = CurDir$
        If (Right$(ofxErrInfo.sLogFileName, 1) <> "\") Then ofxErrInfo.sLogFileName = ofxErrInfo.sLogFileName & "\"
        ofxErrInfo.sLogFileName = ofxErrInfo.sLogFileName & sDefaultErrorFile
        nDummy = ofx_ProfileWriteString(S_SECTION_ERRORLOG, S_KEY_ERRLOGFILENAME, ofxErrInfo.sLogFileName)
    End If

    '----- Get the Show Generic Error settings from the INI file.  This drives whether
    '----- or not the ofx_GenericError() function displays a message box or not.
    
    ofxErrInfo.bShowGenericError = ofx_ProfileGetInt(S_SECTION_ERRORLOG, S_KEY_SHOWGENERICERROR, True)
    
    '----- Get the clear at startup settings from the INI file (default is yes).

    ofxErrInfo.bClearFile = ofx_ProfileGetInt(S_SECTION_ERRORLOG, S_KEY_CLEARFILEATSTARTUP, True)

    '----- Clear any part of the error log requested and enter a startup entry in the
    '----- error log table and/or file.

    Call ofx_ClearErrorLog(ofxErrInfo.bClearTable, ofxErrInfo.bClearFile)
    
    Call ofx_LogError("ofx_InitErrorLog()", 0, "Error logging initialized.")
    
    ofxErrInfo.bInitialized = True
                                                    
End Sub

'------------------------------------------------------------------------------
' Sub:      ofx_InitErrorTable
'
' Purpose:  Sets the error table logging stuff
'
' Note:     If the .INI file says to log the errors, then we need to make
'           sure that the error table (look in the string table for the name)
'           exists in the attached table list if not, then just disable this feature.
'------------------------------------------------------------------------------
#If MSA Then
Private Sub ofx_InitErrorTable()
    On Error GoTo ofx_InitErrorTable_Error

    '----- Determine if we are going to be logging errors to the table (default is yes).
    
    ofxErrInfo.bLogToTable = ofx_ProfileGetInt(S_SECTION_ERRORLOG, S_KEY_ERRLOGTOTABLE, 1)

    If (ofxErrInfo.bLogToTable) Then
        ofxErrInfo.sErrorTableName = ofx_LoadString(ofxErrorTableName)
    
        Dim sSql As String
        sSql = "SELECT COUNT(*) FROM [_attached_tables] WHERE [_attached_tables].table_name=" & ofx_AnsiQuote(ofxErrInfo.sErrorTableName)
        
        Dim rs As Recordset
        Set rs = ofxApp.dbThis.OpenRecordset(sSql, dbOpenSnapshot)
        If (rs.BOF) Then
            ofxErrInfo.bLogToTable = False
            ofxErrInfo.sErrorTableName = ""
        End If

    End If

ofx_InitErrorTable_Exit:
    Exit Sub
ofx_InitErrorTable_Error:
    ofxErrInfo.sErrorTableName = ""    'if there is an error here, then assume the default
    Resume ofx_InitErrorTable_Exit
End Sub
#End If

'------------------------------------------------------------------------------
' Sub:      ofx_LogError
'
' Purpose:  Log the error passed in the error log table.
'
' Params:   sProcedureName  (I) Name of the routine in which the error occurred.
'           nErr            (I) Error number to log.
'           sErr            (I) Error text to log.
'------------------------------------------------------------------------------
Sub ofx_LogError(sProcedureName As String, nErr As Long, sErr As String)

    Dim nErrFile As Integer                 ' Handle to error log file.
    Dim sErrorText As String                ' Error text to log.
    Dim vntDateTime As Variant              ' Date/Time in which the error occurred.

    '----- Get the error text to store in the error log and the date and time
    '----- that this routine was called.
    
    If (Len(sErr) > 0) Then                 ' If error text was passed,
        sErrorText = sErr                   ' use it.
    ElseIf (nErr = Err) Then                ' If nErr = Access error,
        sErrorText = Error$                 ' use the current error text.
    Else                                    ' Otherwise...
        sErrorText = Error$(nErr)           ' get the error text from access (not the best solution)
    End If
    
    On Error Resume Next                    ' Set error handler (kill current error).

    vntDateTime = Now                       ' Get the date and time.

    #If MSA Then
        '----- If logging to table is enabled, log the error.
        
        If (ofxErrInfo.bLogToTable) Then
            Dim rs As Recordset                     ' Recordset object.
            
            '----- Get the database pointer and create the _tbl_error_log recordset
            '----- so that we can add a new record.
            
            Set rs = ofxApp.dbThis.OpenRecordset(ofxErrInfo.sErrorTableName, dbOpenDynaset, dbAppendOnly)
    
            '----- Create a new error log record and add the routine name, the
            '----- error number, and the error text.
            
            rs.AddNew                               ' Add a new entry to the table.
            rs("user_id") = CVar(ofx_CurrentUser())
            rs("error_date") = Now
            rs("proc_name") = CVar(sProcedureName)
            rs("err_number") = CVar(nErr)
            rs("error_text") = CVar(sErrorText)
            rs.Update                          ' Update the new record.
            Call ofx_SafeCloseRecordset(rs)
        End If
    #End If
    
    '----- If logging to file is enabled, log the error.
    
    If (ofxErrInfo.bLogToFile <> 0 And Len(ofxErrInfo.sLogFileName) > 0) Then
        '----- Get the next free file handle and open the error log file.
        
        nErrFile = FreeFile

        If ofx_FileExists(ofxErrInfo.sLogFileName) Then
            Open ofxErrInfo.sLogFileName For Append As nErrFile
        Else
            Open ofxErrInfo.sLogFileName For Output As nErrFile
        End If

        '----- Print the error information to the error log file and close file
        
        Print #nErrFile, sProcedureName, ofx_CurrentUser(), Now, CStr(Nz(nErr)), sErrorText
        Close nErrFile
    End If

ofx_LogError_Exit:
    Exit Sub
    
End Sub


Attribute VB_Name = "OfxEventLogging"
'------------------------------------------------------------------------------
' Module:   Ofx - Event Logging
'
' Purpose:  This module contains routines providing for logging developer defined events.
'           Logging various events allows developers to keep track of such things as
'           how many times a specific report was requested and by what users.
'           The use of the event log is defined entirely by the developer.
'
' VB:       This module is part of both the Start Developing for Access and Start Developing
'           for Visual Basic frameworks.  Table logging is only available for Access applications,
'           not VB.  VB application developers should ignore any references to table logging.
'
' Details:  This module contains routines that log to the _tbl_event_log table and/or
'           a log file.  The table/file can be put on the network or local to the client machine.
'
'   The behavior of the event log is defined by the entries in the application's
'   INI file (16-bit applications) or registry (32-bit applications).  The following is a breakdown
'   of the contents of the INI file/registry for event logging:
'
'       [Event Log]
'       Log To Table=1
'       Clear Table at Startup=1
'       Log To File=1
'       Log File Name=c:\application\eventlog.txt
'       Clear File at Startup=1
'
'   Options:
'       Log To Table - (Access only) log the events to the table _tbl_event_log.
'                      This log can be on the server or on the client PC.
'       Log To File  - log events to a text file.
'       Log File Name - path and name of the text file to write events to if
'                      the "Log To File" option is enabled.
'       Clear Table at Startup - (Access only) optional delete of all entries in
'                      the event log table when the application starts.
'       Clear File at Startup - same as "Clear Table at Startup" except with
'                      the log file.
'
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

'----- Module variables.

Type OFX_TYPE_EVENT_INFO
#If MSA Then
    bLogToTable As Integer             ' True if logging errors to table.
    sEventTableName As String          ' Name of table to which to log events.
#End If
    bLogToFile As Integer              ' True if logging to file.
    sLogFileName As String             ' Name of file to which to log events
End Type

Dim ofxEventInfo As OFX_TYPE_EVENT_INFO

'----- Module Constants.

Const S_SECTION_EVENTLOG$ = "Event Log"
#If MSA Then
    Const S_KEY_EVENTLOGTOTABLE$ = "Log To Table"
    Const S_KEY_CLEARTABLEATSTARTUP$ = "Clear Table at Startup"
#End If
Const S_KEY_EVENTLOGTOFILE$ = "Log To File"
Const S_KEY_EVENTLOGFILENAME$ = "Log File Name"
Const S_KEY_CLEARFILEATSTARTUP$ = "Clear File at Startup"





'------------------------------------------------------------------------------
' Sub:      ofx_ClearEventLog
'
' Purpose:  Optionally clear the event log table and/or event log file.
'
#If MSA Then
' Params:   bTable  (I) If true, clear all entries from the event table.
'           bFile   (I) If true, clear the event log file.
#Else
' Params:   bFile   (I) If true, clear the event log file.
#End If
'------------------------------------------------------------------------------
#If MSA Then
Private Sub ofx_ClearEventLog(bTable As Integer, bFile As Integer) ' MS Access
#Else
Private Sub ofx_ClearEventLog(bFile As Integer) ' Visual Basic
#End If

    On Error Resume Next
    
    #If MSA Then
        '----- If caller requested, delete all entries from the event log table.
    
        If (bTable And Len(ofxEventInfo.sEventTableName) > 0) Then
        
            Dim sSql As String              ' SQL string to delete table entries.
            Dim rc As Integer               ' ignored

            sSql = "DELETE * FROM " & ofxEventInfo.sEventTableName
            rc = ofx_DoSql(sSql, 0)

        End If
    #End If
   
    On Error GoTo Err_ofx_ClearEventLog

    '----- If caller requested, delete the event log file if it exists.
    
    If (bFile) Then
        If Len(ofxEventInfo.sLogFileName) Then
            If (ofx_FileExists(ofxEventInfo.sLogFileName)) Then Kill ofxEventInfo.sLogFileName
        End If
    End If

Exit_ClearEventLog:
    Exit Sub

Err_ofx_ClearEventLog:
    ofx_GenericError "ofx_ClearEventLog()", Err
    Resume Exit_ClearEventLog

End Sub

'------------------------------------------------------------------------------
' Sub:      ofx_InitEventLog
'
' Purpose:  Initialize the event log by reading the entries in the INI
'           file and setting up the event log environment accordingly.
'           Then add an entry to the event log that a user opened the
'           application.
'
' See also: The description of the INI file entries in the (declarations) section.
'------------------------------------------------------------------------------
Sub ofx_InitEventLog()

    On Error GoTo Err_ofx_InitEventLog

    Const sEventFileDef$ = "ofxevent.log"   ' Error log default file name.

    Dim bClearFile As Integer               ' Delete error log file flag.
    Dim nDummy As Integer

    #If MSA Then
        Dim bClearTable As Integer          ' Delete error table entries flag.
        Dim sSql As String
        Dim rs As Recordset
        
        '----- Determine if we are going to be logging events to the table (default is no)
        '----- and if it should be cleared at startup (default is no).
    
        ofxEventInfo.bLogToTable = ofx_ProfileGetInt(S_SECTION_EVENTLOG, S_KEY_EVENTLOGTOTABLE, False)
        bClearTable = ofx_ProfileGetInt(S_SECTION_EVENTLOG, S_KEY_CLEARTABLEATSTARTUP, False)

        '----- Make sure we have an event log table
    
        ofxEventInfo.sEventTableName = ofx_LoadString(ofxEventTableName)
    
        sSql = "SELECT COUNT(*) FROM [_attached_tables] WHERE [_attached_tables].table_name=" & ofx_AnsiQuote(ofxEventInfo.sEventTableName)
    
        Set rs = ofxApp.dbThis.OpenRecordset(sSql, dbOpenSnapshot)
        If (rs.BOF) Then
            ofxEventInfo.bLogToTable = False
            ofxEventInfo.sEventTableName = ""
        End If
    #End If

    '----- Determine if we are going to be logging events to file and its name (default is no)
    '----- and if it should be cleared at startup (default is no).

    ofxEventInfo.bLogToFile = ofx_ProfileGetInt(S_SECTION_EVENTLOG, S_KEY_EVENTLOGTOFILE, False)

    ofxEventInfo.sLogFileName = ofx_ProfileGetString(S_SECTION_EVENTLOG, S_KEY_EVENTLOGFILENAME, "")
    If (ofxEventInfo.sLogFileName = sEventFileDef) Then
        ofxEventInfo.sLogFileName = CurDir$
        If (right$(ofxEventInfo.sLogFileName, 1) <> "\") Then ofxEventInfo.sLogFileName = ofxEventInfo.sLogFileName & "\"
        ofxEventInfo.sLogFileName = ofxEventInfo.sLogFileName & sEventFileDef
        nDummy = ofx_ProfileWriteString(S_SECTION_EVENTLOG, S_KEY_EVENTLOGFILENAME, ofxEventInfo.sLogFileName)
    End If

    bClearFile = ofx_ProfileGetInt(S_SECTION_EVENTLOG, S_KEY_CLEARFILEATSTARTUP, False)

    '----- Clear any part of the error log requested and enter a startup entry in the
    '----- error log table and/or file.
     
    #If MSA Then
        Call ofx_ClearEventLog(bClearTable, bClearFile)
    #Else
        Call ofx_ClearEventLog(bClearFile)
    #End If
    Call ofx_LogEvent("ofx_InitEventLog()", 0, "Event logging initialized.")

Exit_InitEventLog:
    Exit Sub

Err_ofx_InitEventLog:
    ofx_GenericError "ofx_InitEventLog()", Err
    Resume Exit_InitEventLog

End Sub

'------------------------------------------------------------------------------
' Sub:      ofx_LogEvent
'
' Purpose:  Write the requested event to the event log table and/or the event
'           log file.  If neither were requested, exit the routine and do nothing.
'
' Params:   sRoutineName    (I) Routine that the event occurred in.
'           nEventNumber    (I) Developer defined event number.
'           sEventText      (I) Developer defined event text.
'------------------------------------------------------------------------------
Sub ofx_LogEvent(sRoutineName As String, nEventNumber As Integer, sEventText As String)

    On Error GoTo Err_ofx_LogEvent

    Dim nEventFile As Integer               ' Handle to error log file.
    Dim sErrorText As String                ' Error text to log.

    On Error Resume Next

    #If MSA Then
        '----- If logging to table is enabled, log the event.
    
        If (ofxEventInfo.bLogToTable) Then
            Dim rs As Recordset                     ' Recordset object.
        
            '----- Get the database pointer and create the OfxEventLog recordset
            '----- so that we can add a new record.
            
            Set rs = ofxApp.dbThis.OpenRecordset(ofxEventInfo.sEventTableName, dbOpenDynaset)
    
            '----- Create a new error log record and add the routine name, the
            '----- error number, and the error text.
            
            rs.AddNew                               ' Add a new entry to the table.
            rs("user_id") = CVar(ofx_CurrentUser())
            rs("event_date") = Now
            rs("proc_name") = CVar(sRoutineName)
            rs("event_number") = CVar(nEventNumber)
            rs("event_text") = CVar(sEventText)
            rs.UPDATE                               ' Update the new record.
            ofx_SafeCloseRecordset rs
        End If
    #End If

    '----- If logging to file is enabled, log the event.
    
    If (ofxEventInfo.bLogToFile And Len(ofxEventInfo.sLogFileName) > 0) Then
        '----- Get the next free file handle and open the error log file.
        
        nEventFile = FreeFile

        If ofx_FileExists(ofxEventInfo.sLogFileName) Then
            Open ofxEventInfo.sLogFileName For Append As nEventFile
        Else
            Open ofxEventInfo.sLogFileName For Output As nEventFile
        End If

        '----- Print the event information to the event log file.
        
        Print #nEventFile, sRoutineName, ofx_CurrentUser(), Now, CStr(Nz(nEventNumber)), sEventText
        Close nEventFile            ' Close the file.
    End If

Exit_LogEvent:
    Exit Sub

Err_ofx_LogEvent:
    ofx_GenericError "ofx_LogEvent()", Err
    Resume Exit_LogEvent

End Sub


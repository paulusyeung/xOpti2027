Attribute VB_Name = "OfxVBSql"
'------------------------------------------------------------------------------
' Module:   Ofx - VBSQL
'
' Purpose:  This module contains the CORE of the Start Developing
'           VBSQL implementation.
'
'           You MUST have the module MSVBSQL.BAS (with all of the VBSQL
'           declarations) or this module will not compile.
'
'           These functions are specific to VBSQL and we felt that they really
'           belonged here, not in the database utilities module.  One reason is
'           that they could be used without the Framework (although we really
'           don't recommend it). Another is that we wanted the static variables
'           to be contained in one spot.
'
'           Since we also wanted to make this work with VB 3.0, we did NOT use
'           some of the features (such as classes and collections) that are
'           VB 4.0 specific.
'
'           If you want to handle VBSQL errors, then you will need to put a
'           VBSQL.OCX control on a form (the main form normally) and then put
'           the following two procedures into the form.  (Note that the name of
'           your control may be different.)  This way DB-lib errors (VBSQL) can
'           be handled just like Basic errors.
'
'#If Win32 Then
'Private Sub <Vbsql control>_Error(...)
'    ofx_sqlSetLastError SqlConn, Severity, ErrorNum, ErrorStr, OSErrorNum, OSErrorStr
'End Sub
'
'Private Sub <Vbsql control>_Message(...)
'    ofx_sqlSetLastMessage SqlConn, Message, State, Severity, MsgStr, ServerNameStr, ProcNameStr, Line
'End Sub
'#Else
'Private Sub <Vbsql control>_Error(...)
'    ofx_sqlSetLastError SqlConn, Severity, ErrorNum, ErrorStr, 0, ""
'End Sub
'
'Private Sub <Vbsql control>_Message(...)
'    ofx_sqlSetLastMessage SqlConn, Message, State, Severity, MsgStr, "", "", 0
'End Sub
'#End If
'------------------------------------------------------------------------------

Option Explicit             'always, always, always

#If Win32 Then

'----- Holds a single SQL Server "error"

Type vbsqlErrorInfo
    SqlConn As Long
    Severity As Long
    ErrorNum As Long
    ErrorStr As String
    OSErrorNum As Long
    OSErrorStr As String
End Type

'----- Holds a single SQL Server "message"

Type vbsqlMessageInfo
    SqlConn As Long
    Message As Long
    State As Long
    Severity As Long
    MsgStr As String
    ServerNameStr As String
    ProcNameStr As String
    LineNumber As Long
End Type

#Else 'Win16 (VBSQL.VBX)
Type vbsqlErrorInfo
    SqlConn As Integer
    Severity As Integer
    ErrorNum As Integer
    ErrorStr As String
    
    '----- These are not supplied by VBSQL.VBX (16-bit)
    
    OSErrorNum As Long
    OSErrorStr As String
End Type


Type vbsqlMessageInfo
    SqlConn As Integer
    Message As Long
    State As Integer
    Severity As Integer
    MsgStr As String
    
    '----- These are not provided with VBSQL.VBX (16-bit)
    
    ServerNameStr As String
    ProcNameStr As String
    LineNumber As Long
End Type


#End If

'----- Variables to hold the last error info
'----- Note that the "s_" means Static or module level and the rg means "Range" (Array)

'----- First, we define two arrays to hold a list of errors or messages
Dim s_rgMessages() As vbsqlMessageInfo
Dim s_rgErrors() As vbsqlErrorInfo

'----- Next, the count of errors or messages
Dim s_nMessages As Integer
Dim s_nErrors As Integer

'----- Since we have to clear the error/message lists, keep the last one around
'----- for user purposes.

'----- Holds the last error information, copy of s_rsMessages/s_rgErrors, ...
'----- Ideally, these would be in a single User defined type, but VB 3.0 prevents this as
'----- you are not allowed to put UNSIZED arrays into a structure.  (Of course, if it supported
'----- collections, then even better, but now we are dreaming...)

'----- So, these are (yuck) global, but you should really treat them as READ-ONLY
'----- As writing to them is rather unproductive (and also could be considered rude).

Global vbsqlMessages() As vbsqlMessageInfo
Global vbsqlErrors() As vbsqlErrorInfo
Global vbsqlMessageCount As Integer
Global vbsqlErrorCount As Integer


'----- Formatted error string

Dim s_sLastErrorString As String

'----- This is the error number ALWAYS when we raise an error in VB 3.0
'----- You can then examine the error/message lists to see what to do about the
'----- real error.

Const ofxVbSqlError = 30001



'------------------------------------------------------------------------------
' Function: OFXVBSQLTRY
'
' Purpose:  Executes a VBSQL.OCX function and (possibly) raises an error.
'
' Params:   SqlConn     (I) A SQL connection handle
'           nRetCode    (I) The return code to check
'
' Returns:  The value in nRetCode.
'
' Notes:    This procedure can be used as a safe wrapper for any of the VBSQL.OCX
'           functions that return a Long.
'
'           With a .DLL interface like VBSQL.OCX, the caller of a function is required
'           to check the return value of every function call.
'
'           Problem is, with VBSQL, other parts of your code (namely the VBSQL_Error()
'           and VBSQL_Event() procs) may be called BEFORE the function you called
'           returns.  (Yes, this is absolutely true.)
'
'           So, it works like this:
'           1. You call a function: nRetCode = SqlExec(SqlConn)
'           2. DB-lib (VBSQL) calls VBSQL_Message() (at least once, could be multiple times)
'           3. DB-lib (VBSQL) calls VBSQL_Error()  (over and over)
'           4. Your function returns FAIL (most of the time)
'
'           Whoops, all the error and message information (a message is usually an
'           error) is gone.  You could display a dialog box every time you get a message,
'           but that sucks as most of the stuff is not real meaningful.  Also, if you
'           want to run this unattended, you can't.  Next problem, the code you have to write.
'
'           On Error Goto MyUselessErrorHandler_Err
'           nRetCode = Sql<first function>
'           If nRetCode = SUCCEED Then
'               'continue
'           Else
'               'Now what?, the thing bombed, but why, what should I tell the user
'               MsgBox "An error has occurred of which there is no explanation, there was one, but I lost it."
'               Exit Function?  Clean up?  Goto?
'           End If
'
'           nRetCode = Sql<next function>
'           If nRetCode = SUCCEED Then
'               'continue
'           Else
'               'you get the idea
'           End If
'
'           To make matters even worse, you have all this nice error handling
'           which will NEVER, EVER be used.
'
'           Enter the "OFXVBSQLTRY()" function.
'
'           The OFXVBSQLTRY() function will simply return the value in the nRetCode parameter,
'           and then if there is an error, it will format it, decide on a good number,
'           and then Raise it like a normal visual basic error.
'
'           Now your code looks like:
'
'           On Error Goto MyUseFULErrorHandler_Err
'           OFXVBSQLTRY SqlConn, Sql<first function>()
'           OFXVBSQLTRY SqlConn, Sql<next function>()
'
'           MyUseFULErrorHandler_Err:
'               ofx_GenericError "MyProc", Err
'               Resume MyUseFULErrorHandler_Exit
'
'           All error handling is done in the normal manner, in an error trap.
'           (Probably, if you got this far, with the ofx_GenericError handler.
'------------------------------------------------------------------------------
#If Win32 Then
Public Function OFXVBSQLTRY(SqlConn As Long, nRetCode As Long) As Long
#Else
Public Function OFXVBSQLTRY(SqlConn As Integer, nRetCode As Integer) As Integer
#End If
    'No Error handling!
    
    'Always make sure this function will return the value of the original function
    OFXVBSQLTRY = nRetCode
      
    
    If (SUCCEED <> nRetCode And ((SqlConn = 0) Or _
        Not (SqlConn = nRetCode)) And (s_nMessages Or s_nErrors)) Then
        ofx_sqlRaiseError SqlConn
    End If
        
End Function




'---------------------------------------------------------
' Sub:      ofx_sqlSetLastError
'
' Purpose:  Set last error.
'
' Params:   SqlConn    (I) A vbsql connection handle
'           Severity   (I) Error severity
'           ErrorNum   (I) Error number
'           ErrorStr   (I) Error string
'           OSErrorNum (I) Error number from OS
'           OSErrorStr (I) Error string from OS
'
' Notes:    Should be called ONLY by the VBSQL_Error() event
'           procedure.  (The control is probably on frmMain)
'
'           This function adds to the module level error list.
'---------------------------------------------------------
#If Win32 Then
Public Sub ofx_sqlSetLastError(ByVal SqlConn As Long, ByVal Severity As Long, ByVal ErrorNum As Long, ByVal ErrorStr As String, ByVal OSErrorNum As Long, ByVal OSErrorStr As String)
#Else
Public Sub ofx_sqlSetLastError(ByVal SqlConn As Integer, ByVal Severity As Integer, ByVal ErrorNum As Integer, ByVal ErrorStr As String, ByVal OSErrorNum As Long, ByVal OSErrorStr As String)
#End If
    
    ReDim Preserve s_rgErrors(s_nErrors)
        
    s_rgErrors(s_nErrors).SqlConn = SqlConn
    s_rgErrors(s_nErrors).Severity = Severity
    s_rgErrors(s_nErrors).ErrorNum = ErrorNum
    s_rgErrors(s_nErrors).ErrorStr = ErrorStr
    s_rgErrors(s_nErrors).OSErrorNum = OSErrorNum
    s_rgErrors(s_nErrors).OSErrorStr = OSErrorStr
    
    s_nErrors = s_nErrors + 1
    
End Sub



'---------------------------------------------------------
' Sub:      ofx_sqlSetLastMessage
'
' Purpose:  Set last message.
'
' Params:   SqlConn       (I) A vbsql connection handle
'           Message       (I) The message
'           State         (I) Database state
'           Severity      (I) Message severity
'           MsgStr        (I) Message string
'           ServerNameStr (I) Name of server
'           ProcNameStr   (I) Name of procedure
'           LineNumber    (I) Line number within procedure
'
' Notes:    Called ONLY by the VBSQL_Message() event
'           procedure.  (Probably on frmMain)
'---------------------------------------------------------
#If Win32 Then
Public Sub ofx_sqlSetLastMessage(ByVal SqlConn As Long, ByVal Message As Long, ByVal State As Long, ByVal Severity As Long, ByVal MsgStr As String, ByVal ServerNameStr As String, ByVal ProcNameStr As String, ByVal LineNumber As Long)
#Else
Public Sub ofx_sqlSetLastMessage(ByVal SqlConn As Integer, ByVal Message As Integer, ByVal State As Integer, ByVal Severity As Integer, ByVal MsgStr As String, ByVal ServerNameStr As String, ByVal ProcNameStr As String, ByVal LineNumber As Long)
#End If

    
    ReDim Preserve s_rgMessages(s_nMessages)
    
    s_rgMessages(s_nMessages).SqlConn = SqlConn
    s_rgMessages(s_nMessages).Message = Message
    s_rgMessages(s_nMessages).State = State
    s_rgMessages(s_nMessages).Severity = Severity
    s_rgMessages(s_nMessages).MsgStr = MsgStr
    s_rgMessages(s_nMessages).ServerNameStr = ServerNameStr
    s_rgMessages(s_nMessages).ProcNameStr = ProcNameStr
    s_rgMessages(s_nMessages).LineNumber = LineNumber
    
    s_nMessages = s_nMessages + 1
   

End Sub




'---------------------------------------------------------
' Function: ofx_sqlGetMessageString
'
' Purpose:  Get the SQL message string(s) for this connection.
'           If there were multiple messages, each message will
'           be in a separate line.
'
' Params:   SqlConn (I) A vbsql connection handle
'
' Returns:  A formatted message string
'
' Notes:    Notice that all "database context" messages are ignored.
'           Also, the SqlConn param is used to filter out any
'           messages that may not be associated with this connection.
'---------------------------------------------------------
#If Win32 Then
Private Function ofx_sqlGetMessageString(SqlConn As Long) As String
#Else
Private Function ofx_sqlGetMessageString(SqlConn As Integer) As String
#End If

    On Error Resume Next
    
    Dim i As Integer
    Dim sMsg As String
    
    'For some reason, the Message definitions are not defined by the sql toolkit
    Const MSG_DBCONTEXTCHANGED As Integer = 5701
    
    For i = 0 To s_nMessages - 1
        
        If (s_rgMessages(i).Message <> MSG_DBCONTEXTCHANGED) Then
        
            If (SqlConn = 0 Or SqlConn = s_rgMessages(i).SqlConn) Then
            
                sMsg = sMsg & "Error#:" & s_rgMessages(i).Message
                sMsg = sMsg & ",State:" & s_rgMessages(i).State
                sMsg = sMsg & ",Severity:" & s_rgMessages(i).Severity
                sMsg = sMsg & ",Server:" & s_rgMessages(i).ServerNameStr
                                
                If (Len(s_rgMessages(i).ProcNameStr) > 0) Then
                    sMsg = sMsg & ofx_CRLF() & "Procedure:" & Trim$(s_rgMessages(i).ProcNameStr)
                    sMsg = sMsg & ",LineNumber:" & s_rgMessages(i).LineNumber
                End If
                
                'actual error message
                sMsg = sMsg & ofx_CRLF() & Trim$(s_rgMessages(i).MsgStr)
                sMsg = sMsg & ofx_CRLF()
            End If
            
        End If
        
        
        Debug.Print "Message ignored: " & s_rgMessages(i).MsgStr

    Next
    
    If (Len(sMsg)) Then
        Do While (Right$(sMsg, Len(ofx_CRLF())) = ofx_CRLF())
            sMsg = Left$(sMsg, Len(sMsg) - Len(ofx_CRLF()))
        Loop
    End If
    ofx_sqlGetMessageString = sMsg
           
End Function


'---------------------------------------------------------
' Function: ofx_sqlGetErrorString
'
' Purpose:  Get the SQL error string(s) for this connection.
'           If there were multiple errors, each error will
'           be in a separate line.
'
' Params:   SqlConn (I) A vbsql connection handle
'
' Returns:  A formatted error string.
'
' Notes:    The SqlConn param is used to filter out any errors
'           that may not be associated with this connection.
'
'           Note that information messages (SQLEMSG) are ignored.
'
'           The most important thing to remember is that you
'           may only call this function ONCE usefully.  Before
'           each OFXVBSQLTRY call, the current list of errors/messages are
'           cleared.
'---------------------------------------------------------
#If Win32 Then
Private Function ofx_sqlGetErrorString(SqlConn As Long) As String
#Else
Private Function ofx_sqlGetErrorString(SqlConn As Integer) As String
#End If
    On Error Resume Next
    
    Dim i As Integer
    Dim sErr As String
    
    For i = 0 To s_nErrors - 1
    
        
        If (SqlConn = 0 Or (SqlConn = s_rgErrors(i).SqlConn)) Then
        
            'we want to ignore informational messages
            If (SQLESMSG <> s_rgErrors(i).ErrorNum) Then
            
                sErr = sErr & "Number: " & s_rgErrors(i).ErrorNum
                sErr = sErr & ",Severity: " & s_rgErrors(i).Severity
                sErr = sErr & ofx_CRLF() & Trim$(s_rgErrors(i).ErrorStr)
                sErr = sErr & ofx_CRLF()
            
#If DBG Then
            Else
            'print the error for debugging purposes
            Debug.Print "Error Ignored: " & Trim$(s_rgErrors(i).ErrorStr)
#End If
        End If
            
        End If
        
    Next
    
    ' Trim any trailing carriage return/LineNumber feed characters
    If (Len(sErr)) Then
        Do While (Right$(sErr, Len(ofx_CRLF())) = ofx_CRLF())
            sErr = Left$(sErr, Len(sErr) - Len(ofx_CRLF()))
        Loop
    End If
    
    ofx_sqlGetErrorString = sErr
    
   
End Function




'---------------------------------------------------------
' Sub:      ofx_sqlRaiseError
'
' Purpose:  Raise an error so that standard VB error handling
'           can field it.
'
' Params:   SqlConn (I) A connection handle or 0 (zero)
'
' Notes:    The SqlConn parameter is used to filter out any errors
'           that may not be associated with this connection.
'
'           This is a helper function that will cause an error in
'           the calling function. You should not call this
'           function directly, and most of all, don't add error handling.
'
'           The interesting problem here is deciding on what
'           the actual error "number" should be when it is
'           Raised.  This implementation chooses the Message
'           from the VBSQL_Message() event. Typically, this
'           has the more meaningful information.
'---------------------------------------------------------
#If Win32 Then
Private Sub ofx_sqlRaiseError(SqlConn As Long)
#Else
Private Sub ofx_sqlRaiseError(SqlConn As Integer)
#End If
    ' THIS PROCEDURE SHOULD HAVE NO ERROR HANDLING
    ' Errors are "thrown" out (or up, depending on how you look at it.)
    
    Dim sMsg As String
    Dim sErr As String
    Dim nErrToRaise As Long
    
    If (s_nErrors Or s_nMessages) Then
    
    
        If (s_nMessages) Then
            nErrToRaise = s_rgMessages(s_nMessages - 1).Message
        Else
            nErrToRaise = s_rgErrors(s_nErrors - 1).ErrorNum
        End If
        
        
        ' after the next two functions are called, there will be
        ' no more errors or messages
        sMsg = ofx_sqlGetMessageString(SqlConn)
        sErr = ofx_sqlGetErrorString(SqlConn)
        
        s_sLastErrorString = sMsg & IIf(Len(sMsg), ofx_CRLF(), "") & sErr
        
        'Saves the last error/message info into the global variables for this module
        ofx_sqlClearErrors
        
#If Not VB3 Then
        If (Len(sMsg) > 0 Or Len(sErr) > 0) Then
            Err.Clear
            Err.Raise nErrToRaise, "SQL Server", s_sLastErrorString
        End If
#Else
        If (Len(sMsg) > 0 Or Len(sErr) > 0) Then
            Error nErrToRaise
        End If
#End If
    
    End If
    
End Sub




'---------------------------------------------------------
' Function: ofx_sqlOpenConnection
'
' Purpose:  Opens a connection to the SQL Server database.
'
' Params:   sServer     (I) The name of the server
'           sUserName   (I) User
'           sPassword   (I) Password
'           SqlConn     (O) A vbsql connection handle
'
' Returns:  True (SqlConn is valid) or False (function bombed)
'           (Could Raise an Error)
'
' Notes:    If this is called from the CDatabaseHolder.OpenDatabase()
'           function, then the Login time-out has been set to
'           whatever was in the registry/ini file
'
'           There are (as you might expect) two different ways
'           to login to SQL Server. This requires less code
'           than the other method. Refer to the Visual
'           Programmers toolkit for reference to the other method.
'
'           This function could potentially raise an error,
'           (if the connection attempt fails).  If called from
'           CDatabaseHolder.OpenDatabase, then this is expected
'---------------------------------------------------------
#If Win32 Then
Public Function ofx_sqlOpenConnection(ByVal sServer As String, ByVal sUserName As String, ByVal sPassword As String, ByRef SqlConn As Long) As Boolean
#Else
Public Function ofx_sqlOpenConnection(ByVal sServer As String, ByVal sUserName As String, ByVal sPassword As String, SqlConn As Integer) As Boolean
#End If
    
    On Error GoTo ofx_sqlOpenConnection_Err
   
    SqlConn = SqlOpenConnection(sServer, sUserName, sPassword, _
        "SDVB", Left$(ofxApp.sAppName, 30))
    
    If (0 = SqlConn) Then
        ofx_sqlRaiseError SqlConn
    Else
        ofx_sqlOpenConnection = True
    End If

ofx_sqlOpenConnection_Exit:
    On Error Resume Next
    Exit Function
ofx_sqlOpenConnection_Err:
    ' Don't call ofx_GenericError() here, we just want a simple message box,
    ' let's not scare anybody.
    MsgBox Err.Description, 16
    Resume ofx_sqlOpenConnection_Exit
End Function




'---------------------------------------------------------
' Function: ofx_sqlIsNull
'
' Purpose:  Determine if the specified column in the query is Null.
'
' Params:   SqlConn (I) Valid connection handle
'           Column  (I) Ordinal column number (should be in range)
'
' Returns:  True if the column is Null, False otherwise
'---------------------------------------------------------
#If Win32 Then
Function ofx_sqlIsNull(SqlConn As Long, Column As Long) As Boolean
#Else
Function ofx_sqlIsNull(SqlConn As Integer, Column As Integer) As Boolean
#End If
    ofx_sqlIsNull = (0 = OFXVBSQLTRY(SqlConn, SqlDatLen(SqlConn, Column)))
End Function




'---------------------------------------------------------
' Function: ofx_sqlGetData
'
' Purpose:  Get the specified column from the query results.
'           If the column is Null, Null will be returned.
'
' Params:   SqlConn (I) Valid connection handle
'           Column  (I) Ordinal column number (should be in range)
'
' Returns:  A Variant, either a string or Null
'
' Notes:    DB-Lib implementation of dbgetdata or SqlGetData in
'           VBSQL.OCX will return an empty string if a column
'           is null.  In some cases (See the DLookup member of
'           the CDatabaseHolder class) it is desirable to get
'           an actual "Null" value.
'
'           If this function for some reason causes an error
'           (rather unlikely), then it should "bubble-up"
'           to the caller.
'---------------------------------------------------------
#If Win32 Then
Function ofx_sqlGetData(SqlConn As Long, Column As Long) As Variant
#Else
Function ofx_sqlGetData(SqlConn As Integer, Column As Integer) As Variant
#End If
    If (ofx_sqlIsNull(SqlConn, Column)) Then
        ofx_sqlGetData = Null
    Else
        ofx_sqlGetData = SqlData(SqlConn, Column)
        If (s_nErrors Or s_nMessages) Then
            ofx_sqlRaiseError SqlConn
        End If
    End If
End Function



'---------------------------------------------------------
' Function: ofx_sqlOpenResultset
'
' Purpose:  Execute a query.
'
' Params:   SqlConn (I) Valid connection handle
'           sSql    (I) Query to execute (Open)
'
' Returns:  True if results available, else false.
'
' Notes:    Safe, single LineNumber method to open a result set.
'           Just like Jet or RDO, this function positions the
'           cursor at the first row (if any).
'
'           If this function for some reason causes an error
'           (rather unlikely), then it should "bubble-up"
'           to the caller.
'---------------------------------------------------------
#If Win32 Then
Public Function ofx_sqlOpenResultset(SqlConn As Long, sSql As String) As Boolean
#Else
Public Function ofx_sqlOpenResultset(SqlConn As Integer, sSql As String) As Boolean
#End If
    'NO ERROR HANDLING!
    If (SUCCEED = OFXVBSQLTRY(SqlConn, SqlSendCmd(SqlConn, sSql))) Then
        If (NOMORERESULTS <> OFXVBSQLTRY(SqlConn, SqlResults(SqlConn))) Then
            ofx_sqlOpenResultset = (NOMOREROWS <> OFXVBSQLTRY(SqlConn, SqlNextRow(SqlConn)))
        End If
    End If
End Function



'---------------------------------------------------------
' Sub:      ofx_sqlClearErrors
'
' Purpose:  Clears the error/message list, but saves it into
'           a local variable for access by a user.
'---------------------------------------------------------
Private Sub ofx_sqlClearErrors()
    On Error Resume Next
    
    Dim i As Integer
    If (s_nMessages) Then
        ReDim vbsqlMessages(s_nMessages - 1)
        For i = 0 To s_nMessages - 1
            vbsqlMessages(i).SqlConn = s_rgMessages(i).SqlConn
            vbsqlMessages(i).Message = s_rgMessages(i).Message
            vbsqlMessages(i).State = s_rgMessages(i).State
            vbsqlMessages(i).Severity = s_rgMessages(i).Severity
            vbsqlMessages(i).MsgStr = s_rgMessages(i).MsgStr
            vbsqlMessages(i).ServerNameStr = s_rgMessages(i).ServerNameStr
            vbsqlMessages(i).ProcNameStr = s_rgMessages(i).ProcNameStr
            vbsqlMessages(i).LineNumber = s_rgMessages(i).LineNumber
        Next
    End If
    
    If (s_nErrors) Then
        ReDim vbsqlErrors(s_nErrors - 1)
        For i = 0 To s_nErrors - 1
            
            vbsqlErrors(i).SqlConn = s_rgErrors(i).SqlConn
            vbsqlErrors(i).Severity = s_rgErrors(i).Severity
            vbsqlErrors(i).ErrorNum = s_rgErrors(i).ErrorNum
            vbsqlErrors(i).ErrorStr = s_rgErrors(i).ErrorStr
            vbsqlErrors(i).OSErrorNum = s_rgErrors(i).OSErrorNum
            vbsqlErrors(i).OSErrorStr = s_rgErrors(i).OSErrorStr

        Next
    End If
    
    vbsqlMessageCount = s_nMessages
    vbsqlErrorCount = s_nErrors

    'clear current message list
    s_nMessages = 0
    Erase s_rgMessages
    
    ' Clear the current error list
    s_nErrors = 0
    Erase s_rgErrors

End Sub

VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CDBException"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
'------------------------------------------------------------------------------
' Class:    CDBException
'
' Purpose:  Encapsulates an ODBC Error
'
' Notes:    This class makes reporting on ODBC errors simpler.
'
'           To use, you must first call this class' BuildErrorString() method.
'
'           The string built looks something like this:
'
'           StateNativeOrigin == State: 07001,Native Error: -3010, Origin: [Microsoft][ODBC Microsoft Access 7.0 Driver]
'           Error:            == Too few parameters. Expected 1.
'           Number:           == -3010
'
' See also: For a good example of how to use, see ofx_odbcReportError() in
'           the OfxDatabaseUtilities module.
'------------------------------------------------------------------------------

Option Explicit

Private m_henv As Long
Private m_hdbc As Long
Private m_hstmt As Long

Private m_sError As String
Private m_sStateNativeOrigin As String
Private m_nNativeError As Long

'------------------------------------------------------------------------------
' Method:   BuildErrorString
'
' Purpose:  Constructs this class and builds the formatted error string.
'
' Params:   hEnv    (I) The database environment
'           hDbc    (I) The database connection
'           hStmt   (I) The statement being executed
'------------------------------------------------------------------------------
Public Sub BuildErrorString(hEnv As Long, hDbc As Long, hstmt As Long)
    On Error Resume Next
    
    m_henv = hEnv
    m_hstmt = hstmt
    m_hdbc = hDbc
    
#If DBG Then
    ASSERT (m_henv And m_hdbc), "CDBException.BuildErrorString", "Class is not initialized properly."
#End If
    
    m_sError = ""
    m_sStateNativeOrigin = ""
    
    Dim lpszSqlState As String * 256
    Dim lpszErrorMsg As String * 512
    Dim cbErrorMsg As Integer
    Dim nRetCode As Long
    
    Dim sState As String
    Dim sMsg As String
    
    nRetCode = SQLError(m_henv, m_hdbc, m_hstmt, lpszSqlState, m_nNativeError, lpszErrorMsg, 256, cbErrorMsg)
    sState = Left$(lpszSqlState, InStr(lpszSqlState, Chr$(0)) - 1)
    
    While ((nRetCode = SQL_SUCCESS Or nRetCode = SQL_SUCCESS_WITH_INFO) And (sState <> "00000"))
        ' Skip non-errors
                
        sMsg = Left$(lpszErrorMsg, InStr(lpszErrorMsg, Chr$(0)) - 1)
        
        Dim sNative As String
        sNative = ",Native Error: " & CStr(m_nNativeError) & ", Origin: "
        sState = sState & sNative

        'transfer [origin] from message string to StateNativeOrigin string
        Dim nCloseBracket As Integer
        Dim nMsgLength As Integer
        nCloseBracket = InStr(sMsg, "]")
        
        If (Left$(sMsg, 1) = "[" And nCloseBracket > 0) Then
            If (InStr(nCloseBracket + 1, sMsg, "]")) Then nCloseBracket = InStr(nCloseBracket + 1, sMsg, "]")
            
            sState = sState & Left(sMsg, nCloseBracket)
            sMsg = Trim$(Mid$(sMsg, nCloseBracket + 1))
        End If
        
        sState = sState & Chr$(13) & Chr$(10)
        
        m_sStateNativeOrigin = m_sStateNativeOrigin & "State: " & sState
        m_sError = m_sError & sMsg & Chr$(13) & Chr$(10)
        
        nRetCode = SQLError(m_henv, m_hdbc, m_hstmt, lpszSqlState, m_nNativeError, lpszErrorMsg, 256, cbErrorMsg)
        sState = Left$(lpszSqlState, InStr(lpszSqlState, Chr$(0)) - 1)
    Wend
    
End Sub

'------------------------------------------------------------------------------
' Method:   ReportError
'
' Purpose:  Displays the contents of the error to the user.
'
' Notes:    This is an alternative to using Err.Raise to display the error.
'------------------------------------------------------------------------------
Public Sub ReportError()
    On Error Resume Next
    MsgBox m_sStateNativeOrigin & vbCrLf & m_sError
End Sub

'------------------------------------------------------------------------------
' Property: Error
'
' Purpose:  Holds the ODBC error string
'
' Notes:    This property is read only
'------------------------------------------------------------------------------
Public Property Get Error() As String
    Error = m_sError
End Property

'------------------------------------------------------------------------------
' Property: StateNativeOrigin
'
' Purpose:  Holds the ODBC [State:n ] and Native Origin string
'
' Notes:    This property is read only
'------------------------------------------------------------------------------
Public Property Get StateNativeOrigin() As String
    StateNativeOrigin = m_sStateNativeOrigin
End Property

'------------------------------------------------------------------------------
' Property: Number
'
' Purpose:  Holds the native error number
'
' Notes:    This property is read only
'------------------------------------------------------------------------------
Public Property Get Number() As Long
    Number = m_nNativeError
End Property


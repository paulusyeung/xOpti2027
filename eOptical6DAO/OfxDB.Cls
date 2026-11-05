VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CDatabase"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
'------------------------------------------------------------------------------
' Class:    CDatabase
'
' Purpose:  A CDatabase object represents a connection to an ODBC data source,
'           through which you can operate on the data source.
'           A data source is a specific instance of data hosted by some database management system (DBMS).
'           Examples include Microsoft SQL Server, Microsoft Access, Borland® dBASE®, and xBASE.
'           You can have one or more CDatabase objects active at a time in your application.
'
' Notes:    A CDatabase object is normally accessed (or aggregated) through its "Parent"
'           object - CDatabaseHolder.
'
'           The class depends on other objects in the application:
'               CDBState            - SINGLE instance (per app) object that holds an ODBC HENV (environment handle)
'               CDBException        - An object that handles ODBC errors.
'
'           Note that there is a GLOBAL CDBState object (ofxApp.dbState).
'           This variable is available if the option DBOPT_ODBC is #Defined.
'           You should ONLY have one of these objects in your application.  (Very important.)
'
'           The CDatabase class has several other objects in that depend on it:
'               CResultset          - similar to a DAO Recordset or RDO Resultset
'               CField              - similar to a DAO Field or RDO column
'               CLongBinary         - a field object that manages long binary (or text) columns (BLOBs)
'
'           In general, properties that are Read-only do not have "Let" procedures.  Trying to
'           set these properties will cause a compile error.
'------------------------------------------------------------------------------

Option Explicit
Option Compare Text

Private m_bIsOpen As Boolean        'Is the database open?

Private m_hdbc As Long              'Handle to an ODBC connection
Private m_sConnect As String        'Connect string (ODBC;DSN=...;UID=)

Private m_hWnd As Long              'Parent window handle (for any ODBC dialogs)

Private m_sDatabase As String       'The name of the database
Private m_sDSN As String            'The DSN name.

Private m_sUserName As String       'The user name.
Private m_sPassword As String       'The password.

Private m_henv As Long              'Handle to the ODBC environment.

Private m_nRowsAffected As Long     'Number of rows affected by an INSERT, UPDATE, or DELETE statement

Private m_nLoginTimeout As Long     'Login timeout

Private m_bTransactionPending As Boolean    'True if a transaction is pending.

Private m_bReadOnly As Boolean      'True if datasource is read only

#If Win32 Then
Private Declare Function GetLastActivePopup Lib "user32" (ByVal hwndOwnder As Long) As Long
#Else
Private Declare Function GetLastActivePopup Lib "user" (ByVal hwndOwnder As Integer) As Integer
#End If


'------------------------------------------------------------------------------
' Method:  OpenConnection
'
' Purpose: Open a database connection.
'
' Params:  sName        (I) DSN name.
'          fDrvrPrompt  (I) Flag which indicates whether Driver Manager or driver must prompt for more connection information:
'                           SQL_DRIVER_PROMPT, SQL_DRIVER_COMPLETE, SQL_DRIVER_COMPLETE_REQUIRED, or SQL_DRIVER_NOPROMPT.
'          bReadOnly    (I) Open the database read-only?
'          sConnect     (I) Full connect string.
'
' Returns: True (Success, the datasource is connected) or False (Error)
'
' Notes:   If an error occurs, then a message box is displayed UNLESS the prompt is
'          SQL_DRIVER_NOPROMPT
'------------------------------------------------------------------------------
Function OpenConnection(sName As String, fDrvrPrompt As Long, bReadOnly As Boolean, sConnect As String) As Boolean
    'No error handling, should bubble up
    
    Dim nRetCode As Integer
    Dim hWnd As Long

    Dim lpszConnectOut As String * 512
    Dim cbOut As Integer
    
#If DBG Then
    ASSERT (m_bIsOpen = False), "CDatabase.OpenConnection", "Connection is already open."
    'already open? close the connection
    CloseConnection
#End If

    If (AllocConnect()) Then
        
        If (m_nLoginTimeout) Then
            SQLSetConnectOption m_hdbc, SQL_LOGIN_TIMEOUT, m_nLoginTimeout
        End If
        
        If (bReadOnly) Then
            SQLSetConnectOption m_hdbc, SQL_ACCESS_MODE, SQL_MODE_READ_ONLY
        End If
                    
#If DBG Then
        If (m_bReadOnly) Then
            Debug.Print "Warning: Datasource is read-only"
        End If
#End If
            
        If (Len(sName) > 0) Then
            'use DSN
            m_sDSN = sName
            m_sConnect = "DSN=" & sName & ";UID=" & m_sUserName & ";PWD=" & m_sPassword
        Else
            'might need to append UID, PWD,
            m_sConnect = sConnect
            If (Len(m_sConnect)) Then
                If (0 = InStr(sConnect, "PWD")) Then
                    m_sConnect = m_sConnect & ";PWD=" & m_sPassword
                End If
                If (0 = InStr(sConnect, "UID")) Then
                    m_sConnect = m_sConnect & ";UID=" & m_sUserName
                End If
            End If
        End If
    
        On Error Resume Next
        m_hWnd = GetHWnd()
        nRetCode = SQLDriverConnect(m_hdbc, m_hWnd, m_sConnect, _
            SQL_NTS, lpszConnectOut, 512, cbOut, fDrvrPrompt)
            
        If (SQL_ERROR = nRetCode Or SQL_SUCCESS_WITH_INFO = nRetCode) Then
            
            Dim e As New CDBException
            e.BuildErrorString m_henv, m_hdbc, 0&

            If (InStr(e.StateNativeOrigin, "01000")) Then
                ' informational message (changed database context)
                m_bIsOpen = True
                m_sConnect = "ODBC;" & Nz(lpszConnectOut)   'add ODBC; for Access compatability
            Else
                Free
                e.ReportError
            End If
                
        ElseIf (SQL_SUCCESS = nRetCode) Then
            m_bIsOpen = True
            m_sConnect = "ODBC;" & ofx_C2ABStr(lpszConnectOut)   'add ODBC; for Access/VB compatibility
        ElseIf (SQL_NO_DATA_FOUND = nRetCode) Then
            'cancel...
            Free
        End If
        
    End If
    
    If (m_bIsOpen) Then
        Call ofx_SplitDSN(m_sConnect, m_sDatabase, m_sDSN, m_sUserName, m_sPassword)
    End If
    
    OpenConnection = m_bIsOpen

End Function


'------------------------------------------------------------------------------
' Method:  Class_Initialize
'
' Purpose: Initialized this class instance.
'------------------------------------------------------------------------------
Private Sub Class_Initialize()
    On Error Resume Next
    m_hWnd = ofx_GetForegroundWindow()
End Sub

'------------------------------------------------------------------------------
' Method:   Class_Terminate
'
' Purpose:  Class instance clean up.
'
' Notes:    This implementation closes any current connection and frees the
'           connection handle.
'------------------------------------------------------------------------------
Private Sub Class_Terminate()
    On Error Resume Next            'No Errors
    CloseConnection
End Sub


'------------------------------------------------------------------------------
' Method:   AllocConnect
'
' Purpose:  Allocates an ODBC connection handle.
'
' Returns:  True (Success) or False
'------------------------------------------------------------------------------
Private Function AllocConnect() As Boolean
    Dim hEnv As Long
    Dim nRetCode As Integer
    
    On Error Resume Next
    
    #If DBG Then
        ASSERT (m_henv <> 0), "AllocConnect", "HENV is NULL"
    #End If
    
    If (m_henv) Then
        If (m_hdbc) Then
            AllocConnect = True
        Else
            nRetCode = SQLAllocConnect(m_henv, m_hdbc)
            If (SQL_SUCCESS = nRetCode) Then
                AllocConnect = True
            Else
                Dim e As New CDBException
                e.BuildErrorString m_henv, m_hdbc, 0&
                e.ReportError
                Set e = Nothing
            End If
        End If
    End If
End Function


'------------------------------------------------------------------------------
' Method:   CloseConnection
'
' Purpose:  Closes an existing connection.
'
' Notes:    The method should have been called "Close" but
'           VB prevents this.  Called by OpenConnection (if you are re-using this object)
'           or the destructor.
'------------------------------------------------------------------------------
Public Sub CloseConnection()
    On Error Resume Next

    Dim nRetCode As Integer
    If (m_bIsOpen) Then
        If (m_bIsOpen And m_hdbc) Then
            nRetCode = SQLDisconnect(m_hdbc)  'only call disconnect
            
            DoEvents
            
            #If DBG Then
                ASSERT (SQL_SUCCESS = nRetCode), "OpenConnection", "SQLDisconnect() returns: " & CStr(nRetCode)
            #End If
            
        End If
        m_bIsOpen = False
    End If
    
    Free        ' and free the HDBC
    
End Sub

'------------------------------------------------------------------------------
' Method:  Execute
'
' Purpose: Execute a SQL statement (INSERT, UPDATE, DELETE)
'
' Params:  sSql     (I) The SQL statement to execute.
'          Options  (I) Reserved for future use.
'
' Returns: True if successful (even if no rows were affected) or False otherwise.
'------------------------------------------------------------------------------
Public Function Execute(sSql As String, Optional Options As Variant) As Boolean
    On Error GoTo Execute_Error
    
    m_nRowsAffected = -1
    
    If (m_bIsOpen) Then
    
        Dim nRetCode As Integer
        Dim hStmt As Long
        
        nRetCode = SQLAllocStmt(m_hdbc, hStmt)
        If (SQL_SUCCESS = nRetCode) Then
        
            Dim i As Integer
                            
            Dim nId As Long
            Dim strAdd As String
    
            nRetCode = SQLExecDirect(hStmt, sSql, SQL_NTS)
            If (SQL_SUCCESS = nRetCode) Then
            
                SQLRowCount hStmt, m_nRowsAffected
                
                Dim nColumns As Integer
                nRetCode = SQLNumResultCols(hStmt, nColumns)
                If (SQL_SUCCESS = nRetCode And nColumns > 0) Then
                
                    Do
                        nRetCode = SQLFetch(hStmt)
                    Loop While (SQL_SUCCESS = nRetCode And SQL_NO_DATA_FOUND <> nRetCode)
    
                End If
                
                Execute = True
            
            ElseIf (SQL_ERROR = nRetCode) Then
                        
                Dim e As New CDBException
                e.BuildErrorString m_henv, hDbc, hStmt
                e.ReportError
                                                
            End If
            
            SQLFreeStmt hStmt, SQL_DROP
        
        End If  'SQLAllocStatement
        
    End If
    
Execute_Exit:
    Exit Function
Execute_Error:
    ofx_GenericError "Execute()"
    Resume Execute_Exit
End Function


'------------------------------------------------------------------------------
' Method:   GetHWnd
'
' Purpose:  Returns the topmost window handle (HWND)
'
' Returns:  Window handle of topmost window.
'------------------------------------------------------------------------------
Private Function GetHWnd() As Long
    On Error GoTo GetHWnd_Error
    
    m_hWnd = Screen.ActiveForm.hWnd
    Dim hWndPopup As Long
    hWndPopup = GetLastActivePopup(m_hWnd)
    
    If (hWndPopup And hWndPopup <> m_hWnd) Then
        m_hWnd = hWndPopup
    ElseIf (ofx_IsFormLoaded(frmSplash)) Then
        m_hWnd = frmSplash.hWnd
    End If
    
    GetHWnd = m_hWnd
    Exit Function
GetHWnd_Error:
    m_hWnd = ofx_GetForegroundWindow()
    Exit Function
End Function





'------------------------------------------------------------------------------
' Method:   BeginTrans
'
' Purpose:  Starts a transaction.
'
' Notes:    This method may Raise an error.  It should only be called when
'           there are no other transactions pending.
'------------------------------------------------------------------------------
Public Sub BeginTrans()
    'No error handling
    
    If (m_bTransactionPending) Then
        Err.Raise dbOdbcTranLevelErr, dbOdbcTranLevelErrMsg
    End If
    If (SQL_SUCCESS = SQLSetConnectOption(m_hdbc, SQL_AUTOCOMMIT, SQL_AUTOCOMMIT_OFF)) Then
        m_bTransactionPending = True
    End If
End Sub

'------------------------------------------------------------------------------
' Method:   CommitTrans
'
' Purpose:  Commits a transaction.
'
' Notes:    This method may Raise an error.  It should only be called when
'           there are no other transactions pending.
'------------------------------------------------------------------------------
Public Sub CommitTrans()
    'No error handling
    If (m_bTransactionPending) Then
        SQLTransact m_henv, m_hdbc, SQL_COMMIT
        SQLSetConnectOption m_hdbc, SQL_AUTOCOMMIT, SQL_AUTOCOMMIT_ON
        m_bTransactionPending = False
    Else
        Err.Clear
        Err.Raise dbOdbcNoPendingTranErr, dbOdbcNoPendingTranErrMsg
    End If
End Sub

'------------------------------------------------------------------------------
' Method:   Rollback
'
' Purpose:  Cancels a pending transaction.
'
' Notes:    You should only Rollback after you have called BeginTrans
'           This method may Raise an error.
'------------------------------------------------------------------------------
Public Function Rollback() As Boolean
    'No error handling
    If (m_bTransactionPending) Then
        Rollback = (SQL_SUCCESS = SQLTransact(m_henv, m_hdbc, SQL_ROLLBACK))
        SQLSetConnectOption m_hdbc, SQL_AUTOCOMMIT, SQL_AUTOCOMMIT_ON
        m_bTransactionPending = False
    Else
        Debug.Print "Rollback called with no outstanding transaction."
    End If
End Function




'------------------------------------------------------------------------------
' Method:   Free
'
' Purpose:  Frees the allocation HDBC
'------------------------------------------------------------------------------
Private Sub Free()
    On Error Resume Next
    Dim nRetCode As Integer
    If (m_hdbc) Then
        nRetCode = SQLFreeConnect(m_hdbc)
#If DBG Then
        ASSERT (nRetCode = 0), "CDatabase.Free()", "SQLFreeConnect() returns " & nRetCode
#End If
    End If
    m_hdbc = 0&

End Sub





'------------------------------------------------------------------------------
' Property: RowsAffected
'
' Purpose:  Returns the number of rows affected by the last Execute call.
'
' Notes:    This property is only valid after Execute has returned
'           successfully.
'           This property is read only.
'------------------------------------------------------------------------------
Public Property Get RowsAffected() As Long
    RowsAffected = m_nRowsAffected
End Property

'------------------------------------------------------------------------------
' Property: IsOpen
'
' Purpose:  True if the datasource is open, False otherwise.
'
' Notes:    This property is read-only.
'------------------------------------------------------------------------------
Public Property Get IsOpen() As Boolean
    IsOpen = m_bIsOpen
End Property

'------------------------------------------------------------------------------
' Property: UserName
'
' Purpose:  Sets/Returns the user name
'------------------------------------------------------------------------------
Public Property Get UserName() As String
    UserName = m_sUserName
End Property
Public Property Let UserName(vNewValue As String)
    m_sUserName = vNewValue
End Property

'------------------------------------------------------------------------------
' Property: Password
'
' Purpose:  Sets/Returns the password
'------------------------------------------------------------------------------
Public Property Get Password() As String
    Password = m_sPassword
End Property
Public Property Let Password(vNewValue As String)
    m_sPassword = vNewValue
End Property

'------------------------------------------------------------------------------
' Property: hDbc
'
' Purpose:  Returns the HDBC.
'
' Notes:    This property is read-only.
'------------------------------------------------------------------------------
Public Property Get hDbc() As Long
    hDbc = m_hdbc
End Property

'------------------------------------------------------------------------------
' Property: hEnv
'
' Purpose:  Sets/Returns the HENV
'------------------------------------------------------------------------------
Public Property Get hEnv() As Long
    hEnv = m_henv
End Property
Public Property Let hEnv(vNewValue As Long)
    m_henv = vNewValue
End Property

'------------------------------------------------------------------------------
' Property: Database
'
' Purpose:  Returns the current database.
'
' Notes:    This property is read only.
'------------------------------------------------------------------------------
Public Property Get Database() As String
    Database = m_sDatabase
End Property


'------------------------------------------------------------------------------
' Property: Readonly
'
' Purpose:  Returns the read only state of the datasource.
'
' Notes:    This property is read only.  (Ironic, huh?)
'------------------------------------------------------------------------------
Public Property Get ReadOnly() As Boolean
    ReadOnly = m_bReadOnly
End Property


'------------------------------------------------------------------------------
' Property: LoginTimeout
'
' Purpose:  Returns/Sets the Login timeout.
'------------------------------------------------------------------------------
Public Property Get LoginTimeout() As Long
    LoginTimeout = m_nLoginTimeout
End Property
Public Property Let LoginTimeout(vNewValue As Long)
    m_nLoginTimeout = vNewValue
End Property


'------------------------------------------------------------------------------
' Property: DSN
'
' Purpose:  Returns/Sets the DSN
'------------------------------------------------------------------------------
Public Property Get DSN() As String
    DSN = m_sDSN
End Property

Public Property Let DSN(vNewValue As String)
#If DBG Then
    ASSERT (Not (m_bIsOpen)), TypeName(Me) & ".DSN", "DSN should only be set on closed databases."
#End If
    m_sDSN = vNewValue
End Property

'------------------------------------------------------------------------------
' Property: Connect
'
' Purpose:  Returns/Sets the Connect string
'------------------------------------------------------------------------------
Public Property Get Connect() As String
    If (m_bIsOpen) Then
        Connect = m_sConnect
    Else
        Connect = ""
    End If
End Property
Public Property Let Connect(sConnect As String)
    m_sConnect = sConnect
End Property

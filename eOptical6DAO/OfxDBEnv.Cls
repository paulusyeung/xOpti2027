VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CDBState"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
'------------------------------------------------------------------------------
' Class:    CDBState
'
' Purpose:  Holds an ODBC HENV (environment handle)
'
' Notes:    The Framework stores global variable of this type and
'           constructs it when the first database needs it.  If you
'           must use an HENV in your application, you can safely use
'           the hEnv property of the class to retrieve it.  You should NOT
'           use SQLAllocEnv and create this class.
'
' Example:  Set ofxApp.dbState = New CDBState
'           myhenv = ofxApp.dbState.hEnv
'------------------------------------------------------------------------------
Option Explicit

Private m_henv As Long
Private m_sName As String
Private m_sUserName As String
Private m_sPassword As String

'------------------------------------------------------------------------------
' Method:   AllocEnv
'
' Purpose:  Allocates memory for an ODBC environment handle
'           and initializes the ODBC call level interface for use
'           by an application. An application must call AllocEnv
'           prior to calling any other ODBC function.
'
' Returns:  True if successful, otherwise False
'------------------------------------------------------------------------------
Private Function AllocEnv() As Boolean
    On Error Resume Next
    
    If (0 = m_henv) Then
        AllocEnv = (SQL_SUCCESS = SQLAllocEnv(m_henv))
    End If
    AllocEnv = (m_henv <> 0)
End Function

'------------------------------------------------------------------------------
' Method:  Class_Initialize
'
' Purpose:  Initialize this class
'------------------------------------------------------------------------------
Private Sub Class_Initialize()
    On Error Resume Next
    m_henv = 0&
End Sub

'------------------------------------------------------------------------------
' Method:   Class_Terminate
'
' Purpose:  Terminates this class
'
' Notes:    This method will free the environment if it exists.
'------------------------------------------------------------------------------
Private Sub Class_Terminate()
    On Error Resume Next
    If (m_henv) Then
        SQLFreeEnv m_henv
    End If
End Sub


'------------------------------------------------------------------------------
' Property: hEnv
'
' Purpose:  Returns the ODBC HENV
'
' Notes:    This property is read only.
'------------------------------------------------------------------------------
Public Property Get hEnv() As Long
    If (0& = m_henv) Then AllocEnv
    hEnv = m_henv
End Property

'------------------------------------------------------------------------------
' Property:  Name
'
' Purpose:  Sets the name of this environment.
'
' Notes:    This property is read/write.
'           This property is provided for compatibility with the RDO libraries.
'------------------------------------------------------------------------------
Public Property Get Name() As String
    Name = m_sName
End Property
Public Property Let Name(vNewValue As String)
    m_sName = vNewValue
End Property



'------------------------------------------------------------------------------
' Property: UserName
'
' Purpose:  Sets the user name of this environment.
'
' Notes:    This property is read/write.
'           This property is provided for compatibility with the RDO libraries.
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
' Purpose:  Sets the Password of this environment.
'
' Notes:    This property is read/write.
'           This property is provided for compatibility with the RDO libraries.
'------------------------------------------------------------------------------
Public Property Get Password() As String
    Password = m_sPassword
End Property

Public Property Let Password(vNewValue As String)
    m_sPassword = vNewValue
End Property

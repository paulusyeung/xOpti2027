VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CResultset"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
'------------------------------------------------------------------------------
' Class:    CResultset
'
' Purpose:  Emulates a forward only snapshot using the CDatabase, CField classes.
'
' Notes:    This class does not support (or open) a cursor, an is therefore, not
'           updatable.
'
' Example:  Dim rs As Variant
'           Dim db As CDatabaseHolder
'           Set db = GetDB()
'
'           Set rs = db.OpenRecordset("SELECT PeopleID, DisplayName FROM People ORDER BY DisplayName")
'
'           Dim sDisplayName As String
'           Dim nPeopleID As Long
'
'           If (Not (rs.BOF)) Then
'               Do
'                   ofx_ListBoxAddString List1, _
'                      rs.Fields("DisplayName").Value, rs.Fields("PeopleID").Value
'
'                   rs.MoveNext
'               Loop Until rs.EOF
'           End If
'
'           rs.CloseResultset
'
'           Set rs = Nothing
'------------------------------------------------------------------------------
    
Option Explicit

' Type used by BindColumns()
Private Type tagColumn
    lpbData(256) As Byte
    cbSize As Long
    nLength As Long
    nType As Long
    sName As String
    bIsNull As Boolean
    nPosition As Integer
End Type

Private m_columnsArray() As tagColumn

'odbc specific
Private m_hstmt As Long
Private m_hdbc As Long

'exposed as properties
Private m_nColumnCount As Integer
Private m_bIsBOF As Boolean
Private m_bIsEOF As Boolean
Private m_bIsOpen As Boolean
Private m_nRow As Long

' Helper for long columns
Private m_lb As New CLongBinary

' QueryTimeout
Private m_nQueryTimeout As Long

'public
Public Fields As New Collection



'------------------------------------------------------------------------------
' Method:   OpenResultset
'
' Purpose:  Opens the result set and prepares the columns for use.
'
' Params:   hDbc     (I) A valid, open HDBC.
'           sSql     (I) The SQL Statement
'           nType    (I) The type of the result set (Reserved, provided for future compatibility.))
'           nOptions (I) Result set options. (Reserved, provided for future compatibility.))
'
' Returns:  True if the result set is opened, False if an error occurred.
'
' Notes:    This function should only be called with a valid HDBC as a first parameter.
'           Normally, the CDatabaseHolder class will create and terminate this class and
'           call this function.
'------------------------------------------------------------------------------
Public Function OpenResultset(hDbc As Long, sSql As String, Optional nType As Variant, Optional nOptions As Variant) As Boolean
    On Error GoTo OpenResultset_Err
    
#If DBG Then
    ASSERT (hDbc <> 0&), TypeName(Me) & ".OpenResultset", "HDBC is not valid."
#End If
   
    CloseResultset
    
    m_hdbc = hDbc

    Dim nRetCode As Integer
    nRetCode = SQLAllocStmt(m_hdbc, m_hstmt)
    
    If (SQL_SUCCESS = nRetCode) Then
    
        If (m_nQueryTimeout) Then
            SQLSetStmtOption m_hstmt, SQL_QUERY_TIMEOUT, m_nQueryTimeout
        End If
    
        nRetCode = SQLExecDirect(m_hstmt, sSql, SQL_NTS)
        If (SQL_SUCCESS = nRetCode) Then
        
            SQLNumResultCols m_hstmt, m_nColumnCount
        
            If (m_nColumnCount > 0) Then
                If (BindColumns()) Then
                    m_nRow = 0
                    m_bIsOpen = True
                    m_bIsEOF = False
                    m_bIsBOF = False
                    MoveNext                'gets the first row
                    OpenResultset = True    'No errors
                End If
            End If
        
        Else
            ReportError
            OpenResultset = False
        End If  '//SQLExecDirect
    
    Else
        ReportError
        OpenResultset = False
    End If      '//SQLAllocStmt
    
OpenResultset_Exit:
    On Error Resume Next
    Exit Function
OpenResultset_Err:
    Call ofx_GenericError("OpenResultset()", Err)
    Resume OpenResultset_Exit
End Function




'------------------------------------------------------------------------------
' Method:  BindColumns
'
' Purpose:  Bind column array to result set values.
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Private Function BindColumns() As Boolean
    On Error GoTo BindColumns_Err                ' SDVB
    
    Dim nRetCode As Integer
    Dim i As Integer
    
    Erase m_columnsArray
    If (Not (Fields Is Nothing)) Then
        For i = 1 To Fields.Count
            Fields.Remove 1
        Next
    End If
    
    ReDim m_columnsArray(1 To m_nColumnCount) As tagColumn
    
    For i = 1 To m_nColumnCount
        m_columnsArray(i).nPosition = i
    
        nRetCode = SQLColAttributes(m_hstmt, i, _
                        SQL_COLUMN_LENGTH, ByVal 0&, 0, ByVal 0&, m_columnsArray(i).nLength)
        nRetCode = SQLColAttributes(m_hstmt, i, _
                        SQL_COLUMN_TYPE, ByVal 0&, 0, ByVal 0&, m_columnsArray(i).nType)
                        
        Dim sColumnName(256) As Byte
        Dim cbName As Integer
        nRetCode = SQLColAttributes(m_hstmt, i, _
                        SQL_COLUMN_NAME, sColumnName(0), 256, cbName, ByVal 0&)
        m_columnsArray(i).sName = BytesToString(sColumnName())
        
        If (m_columnsArray(i).nType = SQL_LONGVARCHAR Or m_columnsArray(i).nType = SQL_LONGVARBINARY) Then
        Else
            nRetCode = SQLBindCol(m_hstmt, i, SQL_C_CHAR, m_columnsArray(i).lpbData(0), 256, m_columnsArray(i).cbSize)
        End If
         
        Dim Col As New CField
        Col.Name = m_columnsArray(i).sName
        Col.Size = m_columnsArray(i).cbSize
        Col.DataType = m_columnsArray(i).nType
        
        Fields.Add Col, Col.Name
        Set Col = Nothing
    Next
    
    BindColumns = True

BindColumns_Exit:
    On Error Resume Next
    Exit Function
BindColumns_Err:
    Call ofx_GenericError("BindColumns()", Err)
    Resume BindColumns_Exit
End Function

'------------------------------------------------------------------------------
' Method:   MoveNext
'
' Purpose:  Move to the next record in a specified Result set object and make that record the current record.
'
' Notes:    Note that this result set supports forward only movement.
'------------------------------------------------------------------------------
Public Sub MoveNext()
    On Error GoTo MoveNext_Err
    
    'if we are already at the end, then jump out
    If (Not (m_bIsEOF)) Then

        Dim nRetCode As Integer
        nRetCode = SQLFetch(m_hstmt)
        
        If (SQL_ERROR = nRetCode) Then
            m_bIsBOF = True
            m_bIsEOF = True
            ReportError
        Else
            
            'first time only, check for BOF, essentially, no match
            If (m_nRow = 0) Then
                m_bIsBOF = (nRetCode = SQL_NO_DATA_FOUND)
            End If
                    
            m_bIsEOF = (nRetCode = SQL_NO_DATA_FOUND)
                
            If (Not (m_bIsEOF)) Then
               
                m_nRow = m_nRow + 1
            
                Dim i As Integer
                'since we can't actually bind to the collection (go figure)
                'we need to copy the value data into the CField.Value member
                For i = 1 To m_nColumnCount
                    m_columnsArray(i).bIsNull = (SQL_NULL_DATA = m_columnsArray(i).cbSize)
                    Fields(m_columnsArray(i).sName).Value = GetColumnValue(i)
                Next
            
            End If  'Not EOF
            
        End If      'no error
    
    End If          'Not EOF
    
MoveNext_Exit:
    On Error Resume Next
    Exit Sub
MoveNext_Err:
    Call ofx_GenericError("MoveNext()", Err)
    Resume MoveNext_Exit
End Sub

'------------------------------------------------------------------------------
' Method:  Class_Initialize
'
' Purpose:  Initialize this instance of the class.
'
' Notes:    Note that with a non-open result set, BOF and EOF are true.
'------------------------------------------------------------------------------
Private Sub Class_Initialize()
    On Error Resume Next
    
    m_bIsBOF = True
    m_bIsEOF = True
    m_bIsOpen = False
End Sub

'------------------------------------------------------------------------------
' Method:  Class_Terminate
'
' Purpose:  Instance cleanup.
'
' Notes:    This function will close the result set if it is open, however,
'           in general you should have called the CloseResultset() method before
'           you destroy the object.
'------------------------------------------------------------------------------
Private Sub Class_Terminate()
    On Error Resume Next
    CloseResultset
End Sub


'------------------------------------------------------------------------------
' Method:  BytesToString
'
' Purpose:  Converts a Byte array to a string.
'------------------------------------------------------------------------------
Private Function BytesToString(byte_array() As Byte) As String
    On Error Resume Next
    
    ' convert byte array to string.
    Dim DATA As String, StrLen As String
    DATA = StrConv(byte_array(), vbUnicode)
    StrLen = InStr(DATA, Chr(0)) - 1
    BytesToString = Left(DATA, StrLen)
End Function


'------------------------------------------------------------------------------
' Method:   CloseResultset
'
' Purpose:  Closes the result set and frees the statement.
'------------------------------------------------------------------------------
Public Sub CloseResultset()
    On Error Resume Next
    
    If (m_hstmt) Then
        SQLFreeStmt m_hstmt, SQL_DROP
    End If
    m_bIsOpen = False
    m_hstmt = 0&
End Sub

'------------------------------------------------------------------------------
' Method:   GetColumnValue
'
' Purpose:  Converts the bound byte array into the correct datatype for the column.
'
' Params:   nIndex  (I) Column of interest
'
' Returns:  The data for the column as correct data type.
'
' Notes:    Long binary columns and Long VARCHAR columns are not bound using BindColumns()
'           the data is retrieved using the CLongBinary class GetData() method.
'------------------------------------------------------------------------------
Private Function GetColumnValue(nIndex As Integer) As Variant
    On Error Resume Next
    
    If (m_columnsArray(nIndex).bIsNull) Then
        GetColumnValue = Null
    Else
        Select Case m_columnsArray(nIndex).nType
            Case SQL_BINARY, SQL_VARBINARY
                GetColumnValue = m_columnsArray(nIndex).lpbData
            Case SQL_DATE, SQL_TIME, SQL_TIMESTAMP
                GetColumnValue = CVDate(BytesToString(m_columnsArray(nIndex).lpbData()))
            Case SQL_INTEGER, SQL_BIGINT
                GetColumnValue = CLng(BytesToString(m_columnsArray(nIndex).lpbData()))
            Case SQL_TINYINT
                GetColumnValue = CByte(BytesToString(m_columnsArray(nIndex).lpbData()))
            Case SQL_BIT
                GetColumnValue = CBool(BytesToString(m_columnsArray(nIndex).lpbData()))
            Case SQL_SMALLINT
                GetColumnValue = CInt(BytesToString(m_columnsArray(nIndex).lpbData()))
            Case SQL_REAL, SQL_FLOAT
                GetColumnValue = CSng(BytesToString(m_columnsArray(nIndex).lpbData()))
            Case SQL_DOUBLE, SQL_DECIMAL, SQL_NUMERIC
                GetColumnValue = CDbl(BytesToString(m_columnsArray(nIndex).lpbData()))
            Case SQL_CHAR, SQL_VARCHAR
                GetColumnValue = BytesToString(m_columnsArray(nIndex).lpbData())
            Case SQL_LONGVARCHAR, SQL_LONGVARBINARY
                m_lb.hDbc = m_hdbc
                m_lb.hStmt = m_hstmt
                Dim lpbBuf() As Byte
                If (m_lb.GetData(m_columnsArray(nIndex).nPosition, lpbBuf())) Then
                    If (SQL_LONGVARCHAR = m_columnsArray(nIndex).nType) Then
                        GetColumnValue = BytesToString(lpbBuf())
                    Else
                        'just the data
                        GetColumnValue = lpbBuf
                    End If
                End If
                Erase lpbBuf
        End Select
        
    End If
End Function





'------------------------------------------------------------------------------
' Method:  ReportError
'
' Purpose: Displays an error message.
'------------------------------------------------------------------------------
Private Sub ReportError()
    On Error Resume Next
    
    Dim e As New CDBException
    e.BuildErrorString ofxApp.dbState.hEnv, m_hdbc, m_hstmt
    e.ReportError
    Set e = Nothing
End Sub

'------------------------------------------------------------------------------
' Property: QueryTimeout
'
' Purpose:  Sets the timeout for this HSTMT
'
' Notes:    This class will not set the query timeout statement option
'           if the QueryTimeout is 0.  This way, the
'           default driver timeout will be used.
'           Note that this property will only be applied when Opening the Result set.
'           To change the timeout, you have to Close (CloseResultset), then Open (OpenResultset)
'------------------------------------------------------------------------------
Public Property Get QueryTimeout() As Long
    QueryTimeout = m_nQueryTimeout
End Property
Public Property Let QueryTimeout(vNewValue As Long)
#If DBG Then
    ASSERT (Not (m_bIsOpen)), TypeName(Me) & ".QueryTimeout", "QueryTimeout should only be set on closed statements."
#End If
    m_nQueryTimeout = vNewValue
End Property

'------------------------------------------------------------------------------
' Property: BOF
'
' Purpose:  Returns True if we are before the first Row of the result set.
'
' Notes:    This property is read-only.
'           If BOF is True, you can assume that the result set is empty.  (No rows
'           were returned.)
'------------------------------------------------------------------------------
Public Property Get BOF()
    BOF = m_bIsBOF
End Property


'------------------------------------------------------------------------------
' Property: EOF
'
' Purpose:  Returns True if we are at the End of the result set.
'
' Notes:    This property is read-only.
'------------------------------------------------------------------------------
Public Property Get EOF()
    EOF = m_bIsEOF
End Property



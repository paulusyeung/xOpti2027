VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CLongBinary"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
'------------------------------------------------------------------------------
' Class:    CLongBinary
'
' Purpose:  Handles ODBC Long binary columns (BLOBs)
'
' Example:  Dim lb as New CLongBinary
'
'           lb.hDbc = m_hdbc
'           lb.hStmt = m_hstmt
'           Dim lpbBuf() As Byte
'           If (lb.GetData(1, lpbBuf())) Then
'               .. do something with the data
'           Else
'               'handle error condition
'           End If
'           Set lb = Nothing
'------------------------------------------------------------------------------

Option Explicit

Private m_hstmt As Long
Private m_henv As Long
Private m_hdbc As Long
Private m_bIsConstructed As Boolean
Private m_nField As Integer

' Properties (end of this file)
Private m_bIsNull As Boolean






'------------------------------------------------------------------------------
' Method:   CopyToFile
'
' Purpose:  Copies the contents of a long binary column to a file.
'
' Params:   nField  (I) Column number of result data, ordered sequentially left to right, starting at 1.
'           sFile   (I) The name of the file.
'
' Returns:  True if successful, False otherwise
'
' Notes:    Use this method of the class if you want to copy a BLOB to a file.
'           Note that this method gets data a "chunk" (4k) at a time, which makes it
'           somewhat slower, but also it is nearly certain not to fail.
'
'           If the file exists, then it is overwritten.
'------------------------------------------------------------------------------
Public Function CopyToFile(nField As Integer, sFile As String) As Boolean
    On Error GoTo CopyToFile_Error
    
    If (Not (m_bIsConstructed)) Then
        'should raise an error
        Exit Function
    End If

Const lChunkDataSize = 4096

    Dim nRetCode As Integer
    Dim lActualDataSize As Long
    Dim e As New CDBException
    Dim hFile As Integer
    Dim nBytesWritten As Long
        
    Dim szData As String
    szData = String$(lChunkDataSize, 0)
        
    hFile = FreeFile
    Open sFile For Binary As #hFile
            
    Do
        
        nRetCode = SQLGetData(m_hstmt, nField, SQL_C_BINARY, szData, lChunkDataSize, lActualDataSize)
        
        If (SQL_NULL_DATA = lActualDataSize) Then
            m_bIsNull = True
            Exit Do
        ElseIf (SQL_NO_DATA_FOUND = nRetCode) Then
            'column is null
            Exit Do
        ElseIf (SQL_SUCCESS = nRetCode) Then
            'all done
            Exit Do
        ElseIf (SQL_SUCCESS_WITH_INFO = nRetCode) Then
            
            e.BuildErrorString m_henv, m_hdbc, m_hstmt
            
            If (InStr(e.StateNativeOrigin, "State: 01004") > 0) Then
               'data truncated, ignore
               'szData = String$(lChunkDataSize, 0)
            Else
                Exit Do
            End If
            
        Else
            e.BuildErrorString m_henv, m_hdbc, m_hstmt
            e.ReportError
            Exit Do
            'handle error
        End If
        
        Put #hFile, , szData
        nBytesWritten = nBytesWritten + lActualDataSize
        
    Loop While (lActualDataSize = SQL_NO_TOTAL Or nRetCode = SQL_SUCCESS_WITH_INFO)
    
    
    'last bit of data, should be less than one chunk
    If (lActualDataSize > 0 And SQL_SUCCESS = nRetCode And lActualDataSize < lChunkDataSize) Then
        Dim sz As String
        sz = Left$(szData, lActualDataSize)
        Put #hFile, , sz
        nBytesWritten = nBytesWritten + lActualDataSize
    End If
    
    CopyToFile = True

CopyToFile_Exit:
    If (hFile) Then Close #hFile
    Exit Function
CopyToFile_Error:
    MsgBox Err.Description
    Resume CopyToFile_Exit
End Function


'------------------------------------------------------------------------------
' Method:   GetSize
'
' Purpose:  Determine the size (in bytes) of the BLOB.
'
' Params:   nField    (I) Column number of result data, ordered sequentially left to right, starting at 1.
'           lSize     (O) The actual size of the field.
'
' Returns:  True if successful, False otherwise.
'------------------------------------------------------------------------------
Private Function GetSize(nField As Integer, lSize As Long) As Boolean
    On Error Resume Next
    
    If (Not (m_bIsConstructed)) Then
        'should raise an error
        Exit Function
    End If
    
    Dim nRetCode As Integer
    Dim lActualDataSize As Long
    lSize = 0
    Dim nDummy As Integer
                
    nRetCode = SQLGetData(m_hstmt, nField, SQL_C_DEFAULT, nDummy, 0, lActualDataSize)
    
    If (SQL_ERROR = nRetCode) Then
        Dim e As New CDBException
        e.BuildErrorString m_henv, m_hdbc, m_hstmt
        'should raise an error
        e.ReportError
        GetSize = False
    ElseIf (SQL_NO_DATA_FOUND = nRetCode) Then
        'this has been called for the second time on the same column
        'should raise an error here too, bad calling!
        GetSize = False
    Else
        m_bIsNull = (lActualDataSize = SQL_NULL_DATA)
        lSize = lActualDataSize
        GetSize = True
    End If
     
End Function


'------------------------------------------------------------------------------
' Method:   GetData
'
' Purpose:  Get the BLOB data.  lpbBuf is filled with the BLOB's data.
'
' Params:   nField  (I) Column number of result data, ordered sequentially left to right, starting at 1.
'           lpbBuf  (O) A reference to an array of bytes where the data from the column will be stored.
'
' Returns:  True if successful, False otherwise.
'
' Notes:    If this function fails, then it will not display an error message.
'------------------------------------------------------------------------------
Public Function GetData(nField As Integer, lpbBuf() As Byte) As Boolean
    'No error handling
    
#If DBG Then
    ASSERT (m_henv And m_hdbc And m_hstmt), "CLongBinary", "Class has not been initialized properly."
#End If
    
    On Error GoTo GetData_Error

    Dim nRetCode As Integer
    Dim lActualDataSize As Long
    Dim lSize As Long
    
    If (GetSize(nField, lSize)) Then
        'this could bomb (with a memory error)
        ReDim lpbBuf(lSize)
    Else
        Exit Function
    End If
    
    'all in one call
    nRetCode = SQLGetBinaryData(m_hstmt, nField, SQL_C_BINARY, lpbBuf(0), lSize, lActualDataSize)
       
    GetData = (SQL_SUCCESS = nRetCode)

GetData_Exit:
    Exit Function
GetData_Error:
    MsgBox Err.Description
    Resume GetData_Exit
End Function

'------------------------------------------------------------------------------
' Method:   Class_Initialize
'
' Purpose:  Construct this instance.
'
' Notes:    This class assumes that the global ofxApp.dbState object has been created
'           and initialized.
'------------------------------------------------------------------------------
Private Sub Class_Initialize()
    On Error Resume Next
#If DBG Then
    ASSERT (ofxApp.dbState.hEnv <> 0), "CLongBinary.Class_Initialize()", "ofxApp.dbState.hEnv is NULL."
#End If
    m_henv = ofxApp.dbState.hEnv
End Sub



'------------------------------------------------------------------------------
' Property: IsNull
'
' Purpose:  Returns True if the column is null.
'
' Notes:    This property is read only.
'------------------------------------------------------------------------------
Public Property Get IsNull() As Boolean
    IsNull = m_bIsNull
End Property


'------------------------------------------------------------------------------
' Property: hDbc
'
' Purpose:  Sets the ODBC HDBC handle.
'
' Notes:    This property is WRITE-ONLY
'------------------------------------------------------------------------------
Property Let hDbc(h As Long)
    m_hdbc = h
End Property

'------------------------------------------------------------------------------
' Method:   hStmt
'
' Purpose:  Sets the HSTMT
'
' Notes:    This property is WRITE-ONLY
'------------------------------------------------------------------------------
Property Let hStmt(h As Long)
    m_hstmt = h
End Property

Private Sub Class_Terminate()
    On Error Resume Next
End Sub



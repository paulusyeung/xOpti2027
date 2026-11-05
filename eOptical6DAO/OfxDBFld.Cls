VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CField"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
'------------------------------------------------------------------------------
' Class:    CField
'
' Purpose:  Holds information about a bound CResultset column
'
' Notes:    This class is used by the CResultset class.  Because the
'           CResultset class only supports forward only, read only resultsets,
'           It should be treated as read-only.
'
'           Note also that this class is used exactly as if it were a user-defined type,
'           (it could have been one), which means that there are no Methods in this class.
'------------------------------------------------------------------------------

Option Explicit

Private m_nSize As Long
Private m_nDataType As Long
Private m_vValue As Variant
Private m_sName As String


'------------------------------------------------------------------------------
' Property: Value
'
' Purpose:  Holds the column value
'
' Notes:    This property is read-only
'------------------------------------------------------------------------------
Public Property Get Value() As Variant
    Value = m_vValue
End Property

Public Property Let Value(vNewValue As Variant)
    m_vValue = vNewValue
End Property

'------------------------------------------------------------------------------
' Property: Size
'
' Purpose:  Holds the column size.
'
' Notes:    This property is read-only.
'------------------------------------------------------------------------------
Public Property Get Size() As Long
    Size = m_nSize
End Property

Public Property Let Size(vNewValue As Long)
#If DBG Then
    ASSERT (0 = m_nSize), "CField.Size", "Size property is read-only."
#End If
    m_nSize = vNewValue
End Property

'------------------------------------------------------------------------------
' Property: DataType
'
' Purpose:  Holds the data type.  One of the SQL_* types.
'
' Notes:    This property is read-only
'------------------------------------------------------------------------------
Public Property Get DataType() As Long
    DataType = m_nDataType
End Property

Public Property Let DataType(vNewValue As Long)
#If DBG Then
    ASSERT (0 = m_nDataType), "CField.DataType", "DataType property is read-only."
#End If
    m_nDataType = vNewValue
End Property

'------------------------------------------------------------------------------
' Property: Name
'
' Purpose:  Holds the column name
'
' Notes:    This property is read-only
'------------------------------------------------------------------------------
Public Property Get Name() As String
    Name = m_sName
End Property

Public Property Let Name(vNewValue As String)
#If DBG Then
    ASSERT (0 = Len(m_sName)), "CField.Name", "Name property is read-only."
#End If
    m_sName = vNewValue
End Property


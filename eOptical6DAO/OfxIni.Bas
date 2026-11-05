Attribute VB_Name = "OfxIniFiles"
'------------------------------------------------------------------------------
' Module:   Ofx - Ini Files
'
' Purpose:  This module provides an interface to Windows .INI files.
'
' See also: The Ofx Profile module for an interface providing a common interface
'           for using .INI files in 16-bit applications and the registry in 32-bit applications.
'           The Ofx Registry module for 32-bit application registry interface.
'
' Note:     These functions use the .INI file specified in the global variable
'           ofxApp.sIniFile.  This variable is normally defined in Ofx Globals and
'           initialized in ofx_Initialize().  If you want to set it up yourself,
'           sIniFile should include the ".INI" file extension, but no path.
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

Const TOKEN_SEPARATOR$ = ";"

'----- Windows API function declarations.

Const ERR_FILENOTFOUND = 53

#If Win32 Then
Declare Function GetPrivateProfileInt Lib "kernel32" Alias "GetPrivateProfileIntA" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal nDefault As Long, ByVal lpFileName As String) As Long
Declare Function GetPrivateProfileString Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long
Declare Function GetPrivateProfileValues Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal nZero As Long, ByVal sDefault As String, ByVal lpReturnedString As String, ByVal MaxSize As Integer, ByVal FileName As String) As Long
Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lpFileName As String) As Long
#Else
Declare Function GetPrivateProfileInt Lib "KERNEL" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal nDefault As Integer, ByVal lpFileName As String) As Integer
Declare Function GetPrivateProfileString Lib "KERNEL" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Integer, ByVal lpFileName As String) As Integer
Declare Function GetPrivateProfileValues Lib "KERNEL" Alias "GetPrivateProfileString" (ByVal Appname As String, ByVal nZero As Long, ByVal sDefault As String, ByVal ReturnedString As String, ByVal MaxSize As Integer, ByVal FileName As String) As Integer
Declare Function WritePrivateProfileString Lib "KERNEL" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lplFileName As String) As Integer
#End If


'------------------------------------------------------------------------------
'   Function:   ofx_IniDataType()
'
'   Purpose:    Determine data type of the specified INI entry.
'
'   Params:     sSection    (I) Section name
'               sKey        (I) Key name
'               nSize       (O) Size of data
'
'   Returns:    Data type REG_* from the Ofx Windows module
'------------------------------------------------------------------------------
Public Function ofx_IniDataType(sSection As String, sKey As String, nSize As Long) As Long
    ofx_IniDataType = REG_SZ
End Function


'------------------------------------------------------------------------------
' Function: ofx_IniDeleteSection
'
' Purpose:  Delete the specified section from this application's .INI file.
'
' Params:   sSection    (I) Name of section to delete
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Function ofx_IniDeleteSection(sSection As String) As Boolean
    On Error Resume Next
    ofx_IniDeleteSection = (WritePrivateProfileString(sSection, vbNullString, vbNullString, ofxApp.sIniFile) <> 0)
End Function

'------------------------------------------------------------------------------
' Function: ofx_IniDeleteKey
'
' Purpose:  Delete the specified key in the specified section.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Public Function ofx_IniDeleteKey(sSection As String, sKey As String) As Boolean
    On Error Resume Next
    
    ofx_IniDeleteKey = (WritePrivateProfileString(sSection, sKey, vbNullString, ofxApp.sIniFile) <> 0)
End Function



'------------------------------------------------------------------------------
' Function: ofx_IniCreateSection
'
' Purpose:  Create a new section in the INI file.
'
' Params:   sSection    (I) New section name
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Function ofx_IniCreateSection(sSection As String) As Boolean
    
    On Error GoTo ofx_IniCreateSection_Err
    
    Dim bOk As Boolean
    Dim nFile As Integer
    
    bOk = False

    If (sSection = "") Then GoTo ofx_IniCreateSection_Exit
    
    '----- Open .INI file

    nFile = FreeFile
    Open (ofx_GetWindowsDirectory() & ofxApp.sIniFile) For Append Access Write As #nFile
    
    '----- Add the section
    
    Print #nFile, ""
    Print #nFile, "[" & sSection & "]"

    bOk = True
    
ofx_IniCreateSection_Exit:
    On Error Resume Next
    Close #nFile
    ofx_IniCreateSection = bOk
    Exit Function
    
ofx_IniCreateSection_Err:
    Call ofx_GenericError("ofx_IniCreateSection()", Err)
    Resume ofx_IniCreateSection_Exit
    
End Function

'------------------------------------------------------------------------------
' Function: ofx_IniGetBool()
'
' Purpose:  Retrieve a boolean value from the INI file.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key entry
'           bDefault    (I) Default value
'
' Notes:    TRUE and FALSE are stored as "Yes" and "No" strings respectively.
'           The default value is returned when no entry is found,
'           however, it is never written.
'
' Returns:  The value from the INI file if found, else the default value.
'
' See also: ofx_IniWriteBool(), ofx_IniGetInt(), ofx_IniGetRect(), ofx_IniGetString().
'------------------------------------------------------------------------------
Public Function ofx_IniGetBool(sSection As String, sKey As String, bDefault As Boolean) As Boolean
    On Error Resume Next
    ofx_IniGetBool = (ofx_IniGetString(sSection, sKey, IIf(bDefault, "Yes", "No")) = "Yes")
End Function




'------------------------------------------------------------------------------
' Function: ofx_IniWriteBool
'
' Purpose:  Write a boolean value to the INI file.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           bValue      (I) Value to set
'
' Notes:    TRUE and FALSE are stored as "Yes" and "No" strings respectively.
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_IniGetBool(), ofx_IniWriteInt(),
'           ofx_IniWriteRect(), ofx_IniWriteString().
'------------------------------------------------------------------------------
Public Function ofx_IniWriteBool(sSection As String, sKey As String, bValue As Boolean) As Integer
    On Error Resume Next
    ofx_IniWriteBool = ofx_IniWriteString(sSection, sKey, IIf(bValue, "Yes", "No"))
End Function


'------------------------------------------------------------------------------
' Function: ofx_IniEnumSections
'
' Purpose:  Determine names of all sections in the INI file.
'
' Params:   sSections   (O) List of all section names
'
' Returns:  Number of sections found.
'
' Notes:    Assumes that INI file is in the Windows directory.
'
' See also: ofx_IniEnumKeys()
'------------------------------------------------------------------------------
Function ofx_IniEnumSections(sSections() As String) As Long
    On Error GoTo ofx_IniEnumSections_Err

    Dim nFile As Integer
    Dim sLine As String
    Dim nCount As Integer

    nCount = 0

    '----- Open .INI file

    nFile = FreeFile
    Open (ofx_GetWindowsDirectory() & ofxApp.sIniFile) For Input Access Read Lock Read As #nFile

    '----- Find sections

    Do While (Not EOF(nFile))
        Line Input #nFile, sLine
        If (left(LTrim(sLine), 1) = "[") Then
            sLine = Mid(LTrim(sLine), 2)
            If (InStr(sLine, "]")) Then
                ReDim Preserve sSections(0 To nCount)
                sSections(nCount) = left(sLine, InStr(sLine, "]") - 1)
                nCount = nCount + 1
            End If
        End If
    Loop

ofx_IniEnumSections_Exit:
    On Error Resume Next
    Close #nFile
    ofx_IniEnumSections = nCount
    Exit Function

ofx_IniEnumSections_Err:
    If (Err <> ERR_FILENOTFOUND) Then
        Call ofx_GenericError("ofx_IniEnumSections", Err)
    End If
    Resume ofx_IniEnumSections_Exit

End Function


'------------------------------------------------------------------------------
' Function: ofx_IniEnumKeys
'
' Purpose:  Determine names of keys in specified section of INI file.
'
' Params:   sSection    (I) Section for which to find keys
'           sKeys       (O) List of all key names in section
'
' Returns:  Number of keys found in section
'
' See also: ofx_IniEnumSections()
'------------------------------------------------------------------------------
Function ofx_IniEnumKeys(sSection As String, sKeys() As String) As Long
    On Error GoTo ofx_IniEnumKeys_Err

    Const INI_BUF_SIZE = 512
    Dim cch As Integer
    Dim sBuf As String
    Dim nCount As Integer
    
    nCount = 0
    sBuf = String$(INI_BUF_SIZE + 1, 0)
    
    cch = GetPrivateProfileValues(sSection, 0, "", sBuf, INI_BUF_SIZE, ofxApp.sIniFile)
    If (cch = 0) Then GoTo ofx_IniEnumKeys_Exit
    
    nCount = ofx_StringToArray(left(sBuf, cch - 1), sKeys(), Chr(0))
    
ofx_IniEnumKeys_Exit:
    ofx_IniEnumKeys = nCount
    Exit Function
    
ofx_IniEnumKeys_Err:
    If (Err <> ERR_FILENOTFOUND) Then
        Call ofx_GenericError("ofx_IniEnumKeys", Err)
    End If
    Resume ofx_IniEnumKeys_Exit
    
End Function



'------------------------------------------------------------------------------
' Function: ofx_IniPrivateGetString()
'
' Purpose:  Get a string from the requested INI file.
'
' Params:   sSection    (I) INI section (e.g. Administrator, Options, etc.).
'           sKey        (I) Key within the requested section (e.g. Option1).
'           sDefault    (I) Default value if the entry is blank or does not exist.
'           sIniFile    (I) Name of the INI file to get the string from.
'
' Returns:  The requested string or the default passed.
'
' See Also: ofx_IniPrivateWriteString()
'
' Notes:    Do not use this function unless you want to use an INI file other
'           than the standard INI file for your application.
'------------------------------------------------------------------------------
Function ofx_IniPrivateGetString(sSection As String, sKey As String, sDefault As String, sIniFile As String) As String
    
    On Error Resume Next
    
    Const INI_BUF_SIZE = 255
    Dim cch As Integer
    Dim sBuf As String
    
    sBuf = String$(INI_BUF_SIZE + 1, 0)
    
    cch = GetPrivateProfileString(sSection, sKey, sDefault, sBuf, INI_BUF_SIZE, sIniFile)
    ofx_IniPrivateGetString = ofx_C2ABStr(sBuf)

End Function

'------------------------------------------------------------------------------
' Function: ofx_IniGetInt
'
' Purpose:  Retrieve a numeric value from the INI file.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           nDefault    (I) Default value
'
' Returns:  The numeric value if found, else the default.
'
' See also: ofx_IniWriteInt(), ofx_IniGetBool(), ofx_IniGetRect(), ofx_IniGetString()
'------------------------------------------------------------------------------
Function ofx_IniGetInt(sSection As String, sKey As String, nDefault As Integer) As Integer
    ofx_IniGetInt = GetPrivateProfileInt(sSection, sKey, nDefault, ofxApp.sIniFile)
End Function



'------------------------------------------------------------------------------
' Function: ofx_IniGetRect
'
' Purpose:  Retrieve a rectangle from the INI file.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           r           (I/O) Default and retrieved rectangle
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_IniWriteRect(), ofx_IniGetBool(), ofx_IniGetInt(), ofx_IniGetString().
'------------------------------------------------------------------------------
Function ofx_IniGetRect(sSection As String, sKey As String, r As RECT) As Boolean

    On Error GoTo ofx_IniGetRect_Err
    
    Dim bOk As Boolean
    Dim sCoords As String
    Dim sCoord As String
    
    bOk = False

    '----- Read tokenized rectangle coordinates
    
    sCoords = ofx_IniPrivateGetString(sSection, sKey, "", ofxApp.sIniFile)
    
    If (sCoords = "") Then GoTo ofx_IniGetRect_Exit

    ' Pull apart the list of coordinate integers.  If there are any
    ' missing parts in the token string, exit the routine without
    ' attempting to size the form.
    
    sCoord = ofx_GetStringToken(sCoords, 1, TOKEN_SEPARATOR)
    If (Len(sCoord) = 0) Then GoTo ofx_IniGetRect_Exit
    r.nLeft = CInt(sCoord)
    
    sCoord = ofx_GetStringToken(sCoords, 2, TOKEN_SEPARATOR)
    If (Len(sCoord) = 0) Then GoTo ofx_IniGetRect_Exit
    r.nTop = CInt(sCoord)
    
    sCoord = ofx_GetStringToken(sCoords, 3, TOKEN_SEPARATOR)
    If (Len(sCoord) = 0) Then GoTo ofx_IniGetRect_Exit
    r.nRight = CInt(sCoord)
    
    sCoord = ofx_GetStringToken(sCoords, 4, TOKEN_SEPARATOR)
    If (Len(sCoord) = 0) Then GoTo ofx_IniGetRect_Exit
    r.nBottom = CInt(sCoord)
    
    bOk = True
    
ofx_IniGetRect_Exit:
    ofx_IniGetRect = bOk
    Exit Function
    
ofx_IniGetRect_Err:
    Call ofx_GenericError("ofx_IniGetRect_Err()", Err)
    Resume ofx_IniGetRect_Exit
    
End Function

'------------------------------------------------------------------------------
' Function: ofx_IniWriteInt
'
' Purpose:  Write an integer value to the INI file.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           nValue      (I) Value to write
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_IniGetInt(), ofx_IniWriteBool(), ofx_IniWriteRect(), ofx_IniWriteString().
'------------------------------------------------------------------------------
Function ofx_IniWriteInt(sSection As String, sKey As String, nValue As Integer) As Boolean
    ofx_IniWriteInt = ofx_IniPrivateWriteString(sSection, sKey, ofx_CStr(nValue), ofxApp.sIniFile)
End Function

'------------------------------------------------------------------------------
' Function: ofx_IniWriteRect
'
' Purpose:  Write a rectangle to the INI file.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           r           (I) Rectangle to write
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_IniGetRect(), ofx_IniWriteBool(), ofx_IniWriteInt(),
'           ofx_IniWriteString().
'
' Notes:    The rectangle is written as four coordinates separated by a
'           separator character.
'------------------------------------------------------------------------------
Function ofx_IniWriteRect(sSection As String, sKey As String, r As RECT) As Boolean
    Dim sCoords As String               ' String containing the coordinates.
    
    ' Generate the coordinate token string to write out to the INI file.
    sCoords = r.nLeft & TOKEN_SEPARATOR & r.nTop & TOKEN_SEPARATOR & r.nRight & TOKEN_SEPARATOR & r.nBottom

    ' Write out the name of the form and its coordinates to the INI file.
    ofx_IniWriteRect = ofx_IniPrivateWriteString(sSection, sKey, sCoords, ofxApp.sIniFile)
End Function



'------------------------------------------------------------------------------
' Function: ofx_IniGetString
'
' Purpose:  Retrieve a string from the INI file.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           sDefault    (I) Default value
'
' Returns:  The string if found, else the default.
'
' See also: ofx_IniWriteString(), ofx_IniGetBool(), ofx_IniGetInt(),
'           ofx_IniGetRect()
'------------------------------------------------------------------------------
Function ofx_IniGetString(sSection As String, sKey As String, sDefault As String) As String
    ofx_IniGetString = ofx_IniPrivateGetString(sSection, sKey, sDefault, ofxApp.sIniFile)
End Function


'------------------------------------------------------------------------------
' Function: ofx_IniPrivateWriteString()
'
' Purpose:  Write a string to specified INI file at the requested section and key.
'
' Params:   sSection    (I) Section in the INI file to write to (e.g. Options).
'           sKey        (I) Entry within the requested section (e.g. Option1).
'           sValue      (I) String to write into the entry.
'           sIniFile    (I) Name of the INI file to write the string to.
'
' Returns:  TRUE on success, else FALSE.
'
' Notes:    Do not use this function unless you want to use an INI file other
'           than the standard INI file for your application.
'
'           If sKey is empty, all keys for the specified section are deleted.
'
' See Also: ofx_IniPrivateGetString()
'------------------------------------------------------------------------------
Function ofx_IniPrivateWriteString(sSection As String, sKey As String, sValue As String, sIniFile As String) As Boolean
    
    On Error Resume Next

    If (Len(sKey) > 0) Then
        ofx_IniPrivateWriteString = (WritePrivateProfileString(sSection, sKey, sValue, sIniFile) <> 0)
    Else
        '----- Delete all keys in this section
        
        ofx_IniPrivateWriteString = (WritePrivateProfileString(sSection, vbNullString, sValue, sIniFile) <> 0)
    End If
End Function





'------------------------------------------------------------------------------
' Function: ofx_IniWriteString
'
' Purpose:  Write a string to the INI file.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           sValue      (I) Value to write
'
' Returns:  TRUE on success, else FALSE
'
' See also: ofx_IniGetString(), ofx_IniWriteBool(), ofx_IniWriteInt(),
'           ofx_IniWriteRect().
'------------------------------------------------------------------------------
Function ofx_IniWriteString(sSection As String, sKey As String, sValue As String) As Boolean
    ofx_IniWriteString = ofx_IniPrivateWriteString(sSection, sKey, sValue, ofxApp.sIniFile)
End Function


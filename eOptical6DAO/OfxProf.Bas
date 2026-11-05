Attribute VB_Name = "OfxProfile"
'------------------------------------------------------------------------------
' Module:   Ofx - Profile
'
' Purpose:  This module provides an identical interface to Windows .INI files for 16-bit
'           applications and the Windows registry for 32-bit applications.  This
'           allows for common sourcing an application whose 32-bit version uses
'           the registry while its 16-bit version uses the INI file.
'
' See also: Ofx Ini Files module for using the .INI file interface from both
'           16 and 32-bit applications.
'           Ofx Registry module for using the registry interface from both
'           32-bit applications.
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

Const TOKEN_SEPARATOR$ = ";"

'------------------------------------------------------------------------------
' Function: ofx_ProfileDataType()
'
' Purpose:  Determine data type of the specified entry.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           nSize       (O) Size of data
'
' Returns:  Data type REG_* from the Ofx Windows module
'------------------------------------------------------------------------------
Public Function ofx_ProfileDataType(sSection As String, sKey As String, nSize As Long) As Long
    #If Win32 Then
        ofx_ProfileDataType = ofx_RegDataType(sSection, sKey, nSize)
    #Else
        ofx_ProfileDataType = ofx_IniDataType(sSection, sKey, nSize)
    #End If
End Function


'------------------------------------------------------------------------------
' Function: ofx_ProfileDeleteSection
'
' Purpose:  Delete the specified section.
'
' Params:   sSection    (I) Name of section to delete
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Function ofx_ProfileDeleteSection(sSection As String) As Boolean
    #If Win32 Then
        ofx_ProfileDeleteSection = ofx_RegDeleteSection(sSection)
    #Else
        ofx_ProfileDeleteSection = ofx_IniDeleteSection(sSection)
    #End If
End Function

'------------------------------------------------------------------------------
' Function: ofx_ProfileDeleteKey
'
' Purpose:  Delete the specified key in the specified section.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Public Function ofx_ProfileDeleteKey(sSection As String, sKey As String) As Boolean
    #If Win32 Then
        ofx_ProfileDeleteKey = ofx_RegDeleteKey(sSection, sKey)
    #Else
        ofx_ProfileDeleteKey = ofx_IniDeleteKey(sSection, sKey)
    #End If
End Function



'------------------------------------------------------------------------------
' Function: ofx_ProfileCreateSection
'
' Purpose:  Create a new section.
'
' Params:   sSection    (I) New section name
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Function ofx_ProfileCreateSection(sSection As String) As Boolean
    #If Win32 Then
        ofx_ProfileCreateSection = ofx_RegCreateSection(sSection)
    #Else
        ofx_ProfileCreateSection = ofx_IniCreateSection(sSection)
    #End If
End Function

'------------------------------------------------------------------------------
' Function: ofx_ProfileGetBool()
'
' Purpose:  Retrieve a boolean value.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key entry
'           bDefault    (I) Default value
'
' Notes:    TRUE and FALSE are stored as "Yes" and "No" strings respectively.
'           The default value is returned when no entry is found, however, it
'           is never written.
'
' Returns:  The value if found, else the default value.
'
' See also: ofx_ProfileWriteBool(), ofx_ProfileGetInt(),
'           ofx_ProfileGetRect(), ofx_ProfileGetString().
'------------------------------------------------------------------------------
Public Function ofx_ProfileGetBool(sSection As String, sKey As String, bDefault As Boolean) As Boolean
    #If Win32 Then
        ofx_ProfileGetBool = ofx_RegGetBool(sSection, sKey, bDefault)
    #Else
        ofx_ProfileGetBool = ofx_IniGetBool(sSection, sKey, bDefault)
    #End If
End Function




'------------------------------------------------------------------------------
' Function: ofx_ProfileWriteBool
'
' Purpose:  Write a boolean value to the application profile.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           bValue      (I) Value to set
'
' Notes:    TRUE and FALSE are stored as "Yes" and "No" strings respectively.
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_ProfileGetBool(), ofx_ProfileWriteInt(),
'           ofx_ProfileWriteRect(), ofx_ProfileWriteString().
'------------------------------------------------------------------------------
Public Function ofx_ProfileWriteBool(sSection As String, sKey As String, bValue As Boolean) As Integer
    #If Win32 Then
        ofx_ProfileWriteBool = ofx_RegWriteBool(sSection, sKey, bValue)
    #Else
        ofx_ProfileWriteBool = ofx_IniWriteBool(sSection, sKey, bValue)
    #End If
End Function


'------------------------------------------------------------------------------
' Function: ofx_ProfileEnumSections
'
' Purpose:  Determine names of all sections.
'
' Params:   sSections   (O) List of all section names
'
' Returns:  Number of sections found.
'
' See also: ofx_ProfileEnumKeys()
'------------------------------------------------------------------------------
Function ofx_ProfileEnumSections(sSections() As String) As Long
    #If Win32 Then
        ofx_ProfileEnumSections = ofx_RegEnumSections(sSections())
    #Else
        ofx_ProfileEnumSections = ofx_IniEnumSections(sSections())
    #End If
End Function


'------------------------------------------------------------------------------
' Function: ofx_ProfileEnumKeys
'
' Purpose:  Determine names of keys in the specified section.
'
' Params:   sSection    (I) Section for which to find keys
'           sKeys       (O) List of all key names in section
'
' Returns:  Number of keys found in section.
'
' See also: ofx_ProfileEnumSections()
'------------------------------------------------------------------------------
Function ofx_ProfileEnumKeys(sSection As String, sKeys() As String) As Long
    #If Win32 Then
        ofx_ProfileEnumKeys = ofx_RegEnumKeys(sSection, sKeys())
    #Else
        ofx_ProfileEnumKeys = ofx_IniEnumKeys(sSection, sKeys())
    #End If
End Function




'------------------------------------------------------------------------------
' Function: ofx_ProfileGetInt
'
' Purpose:  Retrieve a numeric value from application profile.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           nDefault    (I) Default value
'
' Returns:  The numeric value if found, else the default.
'
' See also: ofx_ProfileWriteInt(), ofx_ProfileGetBool(),
'           ofx_ProfileGetRect(), ofx_ProfileGetString()
'------------------------------------------------------------------------------
Function ofx_ProfileGetInt(sSection As String, sKey As String, nDefault As Integer) As Integer
    #If Win32 Then
        ofx_ProfileGetInt = ofx_RegGetInt(sSection, sKey, nDefault)
    #Else
        ofx_ProfileGetInt = ofx_IniGetInt(sSection, sKey, nDefault)
    #End If
End Function



'------------------------------------------------------------------------------
' Function: ofx_ProfileGetRect
'
' Purpose:  Retrieve a rectangle from the application profile.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           r           (I/O) Default and retrieved rectangle
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_ProfileWriteRect(), ofx_ProfileGetBool(), ofx_ProfileGetInt(),
'           ofx_ProfileGetString().
'------------------------------------------------------------------------------
Function ofx_ProfileGetRect(sSection As String, sKey As String, r As RECT) As Boolean
    #If Win32 Then
        ofx_ProfileGetRect = ofx_RegGetRect(sSection, sKey, r)
    #Else
        ofx_ProfileGetRect = ofx_IniGetRect(sSection, sKey, r)
    #End If
End Function

'------------------------------------------------------------------------------
' Function: ofx_ProfileWriteInt
'
' Purpose:  Write an integer value to the application profile.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           nValue      (I) Value to write
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_ProfileGetInt(), ofx_ProfileWriteBool(),
'           ofx_ProfileWriteRect(), ofx_ProfileWriteString().
'------------------------------------------------------------------------------
Function ofx_ProfileWriteInt(sSection As String, sKey As String, nValue As Integer) As Boolean
    #If Win32 Then
        ofx_ProfileWriteInt = ofx_RegWriteInt(sSection, sKey, nValue)
    #Else
        ofx_ProfileWriteInt = ofx_IniWriteInt(sSection, sKey, nValue)
    #End If
End Function

'------------------------------------------------------------------------------
' Function: ofx_ProfileWriteRect
'
' Purpose:  Write a rectangle to the application profile.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           r           (I) Rectangle to write
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_ProfileGetRect(), ofx_ProfileWriteBool(), ofx_ProfileWriteInt(),
'           ofx_ProfileWriteString().
'------------------------------------------------------------------------------
Function ofx_ProfileWriteRect(sSection As String, sKey As String, r As RECT) As Boolean
    #If Win32 Then
        ofx_ProfileWriteRect = ofx_RegWriteRect(sSection, sKey, r)
    #Else
        ofx_ProfileWriteRect = ofx_IniWriteRect(sSection, sKey, r)
    #End If
End Function



'------------------------------------------------------------------------------
' Function: ofx_ProfileGetString
'
' Purpose:  Retrieve a string from the application profile.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           sDefault    (I) Default value
'
' Returns:  The string if found, else the default.
'
' See also: ofx_ProfileWriteString(), ofx_ProfileGetBool(), ofx_ProfileGetInt(),
'           ofx_ProfileGetRect()
'------------------------------------------------------------------------------
Function ofx_ProfileGetString(sSection As String, sKey As String, sDefault As String) As String
    #If Win32 Then
        ofx_ProfileGetString = ofx_RegGetString(sSection, sKey, sDefault)
    #Else
        ofx_ProfileGetString = ofx_IniGetString(sSection, sKey, sDefault)
    #End If
End Function


'------------------------------------------------------------------------------
' Function: ofx_ProfileWriteString
'
' Purpose:  Write a string to the application profile.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           sValue      (I) Value to write
'
' Returns:  TRUE on success, else FALSE
'
' See also: ofx_ProfileGetString(), ofx_ProfileWriteBool(), ofx_ProfileWriteInt(),
'           ofx_ProfileWriteRect().
'------------------------------------------------------------------------------
Function ofx_ProfileWriteString(sSection As String, sKey As String, sValue As String) As Boolean
    #If Win32 Then
        ofx_ProfileWriteString = ofx_RegWriteString(sSection, sKey, sValue)
    #Else
        ofx_ProfileWriteString = ofx_IniWriteString(sSection, sKey, sValue)
    #End If
End Function


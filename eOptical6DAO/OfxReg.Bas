Attribute VB_Name = "OfxRegistry"
#If Win32 Then
'------------------------------------------------------------------------------
' Module:   Ofx - Registry
'
' Purpose:  This module provides safe, simple methods to access the Windows registry.
'           (Works in Windows 95 or Windows NT).  There are functions to read and write
'           both strings and Double-words (Long integers).  Note that you should use
'           the data type correct functions or the functionality is compromised.
'
'   Example:
'
'           Dim nOptionIn As Long, nOptionOut As Long
'           nOptionIn = 1
'           ofx_RegWriteInt "KeyName", "ValueName", nOptionIn
'           nOptionOut = ofx_RegGetInt("KeyName", "ValueName", 0)
'           ASSERT (nOptionIn = nOptionOut And VarType(nOptionOut) = vbLong)
'
'           Dim sOptionIn As String, sOptionOut As String
'           sOptionIn = "Test"
'           ofx_RegWriteInt "KeyName", "ValueName", sOptionIn
'           sOptionOut = ofx_RegGetInt("KeyName", "ValueName", "")
'           ASSERT (sOptionIn = sOptionOut And VarType(sOptionOut) = vbString)
'
'           There are also two functions that operate on a Windows RECT
'           (rectangle) structure.  These functions serve as an example of how
'           to read and write structured data to the registry. (See the Form
'           positions module for an example of how to use these.
'
'           Unfortunately, VBA doesn't support the 'Any' declaration in user
'           defined procedures, so if you want to read and write other binary
'           data, you will need to copy the ofx_RegGet/WriteRect() functions
'           and supply your own types.
'
' Notes:    This module is reusable across any version of VBA (Excel, Project, VB4, ...)
'           so ofxApp.sAppName and ofxApp.sCompany are global variables.  They
'           are declared in Ofx Globals and initialized by the ofx_Initialize()
'           function.  If you do not wish to use those mules, you must declare
'           and initialize these variables yourself.
'
'           This module includes a number of "Extended" functions (ofx_RegEx*)
'           which provide complete access to the registry. These functions are
'           intended for experienced developers and should be used with care.
'
' See also: Ofx INI Files for .INI file access.
'           Ofx Profile for virtualized .INI file/registry access.
'------------------------------------------------------------------------------

Option Explicit
Option Private Module

'-----Registration functions

Private Const dwReserved& = 0&

'----- For Windows 32-bit Registry API

Private Type SECURITY_ATTRIBUTES
    nLength As Long
    lpSecurityDescriptor As Long
    bInheritHandle As Boolean
End Type

Private Type FILETIME
    dwLowDateTime As Long
    dwHighDateTime As Long
End Type

'----- Reg Create Type Values...

Private Const REG_OPTION_RESERVED = 0           ' Parameter is reserved
Private Const REG_OPTION_NON_VOLATILE = 0       ' Key is preserved when system is rebooted
Private Const REG_OPTION_VOLATILE = 1           ' Key is not preserved when system is rebooted
Private Const REG_OPTION_CREATE_LINK = 2        ' Created key is a symbolic link
Private Const REG_OPTION_BACKUP_RESTORE = 4     ' open for backup or restore
Private Const SYNCHRONIZE = &H100000

'----- See the Ofx Windows module for data type symbols

Private Const REG_CREATED_NEW_KEY = &H1                         ' New Registry Key created
Private Const REG_OPENED_EXISTING_KEY = &H2                     ' Existing Key opened
Private Const REG_WHOLE_HIVE_VOLATILE = &H1                     ' Restore whole hive volatile
Private Const REG_REFRESH_HIVE = &H2                            ' Unwind changes to last flush
Private Const REG_NOTIFY_CHANGE_NAME = &H1                      ' Create or delete (child)
Private Const REG_NOTIFY_CHANGE_ATTRIBUTES = &H2
Private Const REG_NOTIFY_CHANGE_LAST_SET = &H4                  ' Time stamp
Private Const REG_NOTIFY_CHANGE_SECURITY = &H8
Private Const REG_LEGAL_CHANGE_FILTER = (REG_NOTIFY_CHANGE_NAME Or REG_NOTIFY_CHANGE_ATTRIBUTES Or REG_NOTIFY_CHANGE_LAST_SET Or REG_NOTIFY_CHANGE_SECURITY)
Private Const REG_LEGAL_OPTION = (REG_OPTION_RESERVED Or REG_OPTION_NON_VOLATILE Or REG_OPTION_VOLATILE Or REG_OPTION_CREATE_LINK Or REG_OPTION_BACKUP_RESTORE)

'----- Reg Key Security Options

Private Const READ_CONTROL = &H20000
Private Const STANDARD_RIGHTS_READ = (READ_CONTROL)
Private Const STANDARD_RIGHTS_WRITE = (READ_CONTROL)
Private Const STANDARD_RIGHTS_ALL = &H1F0000
Private Const KEY_QUERY_VALUE = &H1
Private Const KEY_SET_VALUE = &H2
Private Const KEY_CREATE_SUB_KEY = &H4
Private Const KEY_ENUMERATE_SUB_KEYS = &H8
Private Const KEY_NOTIFY = &H10
Private Const KEY_CREATE_LINK = &H20
Private Const KEY_READ = ((STANDARD_RIGHTS_READ Or KEY_QUERY_VALUE Or KEY_ENUMERATE_SUB_KEYS Or KEY_NOTIFY) And (Not SYNCHRONIZE))
Private Const KEY_WRITE = ((STANDARD_RIGHTS_WRITE Or KEY_SET_VALUE Or KEY_CREATE_SUB_KEY) And (Not SYNCHRONIZE))
Private Const KEY_EXECUTE = (KEY_READ)
Private Const KEY_ALL_ACCESS = ((STANDARD_RIGHTS_ALL Or KEY_QUERY_VALUE Or KEY_SET_VALUE Or KEY_CREATE_SUB_KEY Or KEY_ENUMERATE_SUB_KEYS Or KEY_NOTIFY Or KEY_CREATE_LINK) And (Not SYNCHRONIZE))

Public Const HKEY_CLASSES_ROOT = &H80000000
Public Const HKEY_CURRENT_USER = &H80000001
Public Const HKEY_LOCAL_MACHINE = &H80000002
Public Const HKEY_USERS = &H80000003
Public Const HKEY_PERFORMANCE_DATA = &H80000004
Public Const HKEY_CURRENT_CONFIG = &H80000005
Public Const HKEY_DYN_DATA = &H80000006

'----- Registry API prototypes

Private Declare Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As Long
Private Declare Function RegCreateKeyEx Lib "advapi32.dll" Alias "RegCreateKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal Reserved As Long, ByVal lpClass As String, ByVal dwOptions As Long, ByVal samDesired As Long, lpSecurityAttributes As Any, phkResult As Long, lpdwDisposition As Long) As Long
Private Declare Function RegDeleteKey Lib "advapi32.dll" Alias "RegDeleteKeyA" (ByVal hKey As Long, ByVal lpSubKey As String) As Long
Private Declare Function RegDeleteValue Lib "advapi32.dll" Alias "RegDeleteValueA" (ByVal hKey As Long, ByVal lpValueName As String) As Long
Private Declare Function RegEnumKey Lib "advapi32.dll" Alias "RegEnumKeyA" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpName As String, ByVal cbName As Long) As Long
Private Declare Function RegEnumKeyEx Lib "advapi32.dll" Alias "RegEnumKeyExA" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpName As String, lpcbName As Long, lpReserved As Long, ByVal lpClass As String, lpcbClass As Long, lpftLastWriteTime As FILETIME) As Long
Private Declare Function RegEnumValue Lib "advapi32.dll" Alias "RegEnumValueA" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpValueName As String, lpcbValueName As Long, ByVal lpReserved As Long, lpType As Long, lpData As Byte, lpcbData As Long) As Long
Private Declare Function RegOpenKey Lib "advapi32.dll" Alias "RegOpenKeyA" (ByVal hKey As Long, ByVal lpSubKey As String, phkResult As Long) As Long
Private Declare Function RegOpenKeyEx Lib "advapi32.dll" Alias "RegOpenKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal ulOptions As Long, ByVal samDesired As Long, phkResult As Long) As Long
Private Declare Function RegQueryValue Lib "advapi32.dll" Alias "RegQueryValueA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal lpValue As String, lpcbValue As Long) As Long
Private Declare Function RegQueryValueEx Lib "advapi32.dll" Alias "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, lpType As Long, lpData As Any, lpcbData As Long) As Long         ' Note that if you declare the lpData parameter as String, you must pass it By Value.
Private Declare Function RegSetValue Lib "advapi32.dll" Alias "RegSetValueA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal dwType As Long, ByVal lpData As String, ByVal cbData As Long) As Long
Private Declare Function RegSetValueEx Lib "advapi32.dll" Alias "RegSetValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal Reserved As Long, ByVal dwType As Long, lpData As Any, ByVal cbData As Long) As Long         ' Note that if you declare the lpData parameter as String, you must pass it By Value.

'----- Return codes from Registration functions

Private Const ERROR_SUCCESS = 0&
Private Const ERROR_BADDB = 1&
Private Const ERROR_BADKEY = 2&
Private Const ERROR_CANTOPEN = 3&
Private Const ERROR_CANTREAD = 4&
Private Const ERROR_CANTWRITE = 5&
Private Const ERROR_OUTOFMEMORY = 6&
Private Const ERROR_INVALID_PARAMETER = 7&
Private Const ERROR_ACCESS_DENIED = 8&
Private Const ERROR_NO_MORE_ITEMS = 259&


'------------------------------------------------------------------------------
' Function: ofx_RegCreateSection
'
' Purpose:  Create a new section in the registry.
'
' Params:   sSection    (I) New section name
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Function ofx_RegCreateSection(sSection As String) As Boolean
    
    On Error GoTo ofx_RegCreateSection_Err
    
    Dim bOk As Boolean
    Dim hAppKey As Long
    Dim hSecKey As Long
    Dim dw As Long
    
    bOk = False

    hAppKey = ofx_RegGetAppKey()
    
    If (ERROR_SUCCESS <> RegCreateKeyEx(hAppKey, sSection, dwReserved, "", REG_OPTION_NON_VOLATILE, KEY_WRITE Or KEY_READ, ByVal 0&, hSecKey, dw)) Then
        Call ofx_GenericError("ofx_RegCreateSection()", "Unable to create registry section")
        GoTo ofx_RegCreateSection_Exit
    End If
    
    bOk = True
    
ofx_RegCreateSection_Exit:
    On Error Resume Next
    If (hSecKey) Then dw = RegCloseKey(hSecKey)
    If (hSecKey) Then dw = RegCloseKey(hAppKey)
    ofx_RegCreateSection = bOk
    Exit Function
    
ofx_RegCreateSection_Err:
    Call ofx_GenericError("ofx_RegCreateSection()", Err)
    Resume ofx_RegCreateSection_Exit
    
End Function


'----------------------------------------------------------------------------------------
' Function: ofx_RegExWriteVariant
'
' Purpose:  Set the value for ANY key.
'
' Params:   hKeyRoot    (I) Parent key
'           sKey        (I) Key name
'           sValueName  (I) Value name
'           vValue      (I) The value
'
' Returns:  TRUE on success, else FALSE
'
' Note:     The root key is NOT ALWAYS HKEY_LOCAL_MACHINE, its whatever is supplied
'           in the hKeyRoot parameter.
'           If the data type of vValue is Integer or Long then it is written as a REG_DWORD,
'           if it is a string, then as REG_SZ
'----------------------------------------------------------------------------------------
Function ofx_RegExWriteVariant(hKeyRoot As Long, sKey As String, sValueName As String, vValue As Variant) As Boolean
    
    On Error GoTo ofx_RegExWriteVariant_Err
    
    Dim bOk As Boolean
    Dim hKey As Long
    Dim dw As Long
    Dim sValue As String
    Dim nValue As Long
    
    bOk = False
    
    '----- Open key if exists, else create it.
    
    If (RegOpenKeyEx(hKeyRoot, sKey, 0&, KEY_ALL_ACCESS, hKey) <> ERROR_SUCCESS) Then
         If (RegCreateKeyEx(hKeyRoot, sKey, dwReserved, "", REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, ByVal 0&, hKey, dw)) Then GoTo ofx_RegExWriteVariant_Exit
    End If
    
    '----- Set the value w/ appropriate type.
    
    If (VarType(vValue) = vbString) Then
        sValue = vValue
        If (RegSetValueEx(hKey, sValueName, 0&, REG_SZ, ByVal sValue, Len(sValue)) <> ERROR_SUCCESS) Then GoTo ofx_RegExWriteVariant_Exit
    ElseIf (VarType(vValue) = vbInteger Or VarType(vValue) = vbLong) Then
        nValue = vValue
        If (RegSetValueEx(hKey, sValueName, 0&, REG_DWORD, nValue, Len(nValue)) <> ERROR_SUCCESS) Then GoTo ofx_RegExWriteVariant_Exit
    Else
        GoTo ofx_RegExWriteVariant_Exit
    End If
    
    bOk = True
    
ofx_RegExWriteVariant_Exit:
    On Error Resume Next
    If (hKey) Then Call RegCloseKey(hKey)
    ofx_RegExWriteVariant = bOk
    Exit Function
    
ofx_RegExWriteVariant_Err:
    Call ofx_GenericError("ofx_RegExWriteVariant()", Err)
    Resume ofx_RegExWriteVariant_Exit
    
End Function

'------------------------------------------------------------------------------
' Function: ofx_RegGetBool()
'
' Purpose:  Retrieve a boolean value from the registry.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key entry
'           bDefault    (I) Default value
'
' Notes:    TRUE and FALSE are stored as "Yes" and "No" strings respectively.
'           The default value is returned when no entry is found,
'           however, it is never written.
'
' Returns:  The value if found, else the default value.
'
' See also: ofx_RegWriteBool(), ofx_RegGetInt(), ofx_RegGetVariant(),
'           ofx_RegGetRect(), ofx_RegGetString().
'------------------------------------------------------------------------------
Public Function ofx_RegGetBool(sSection As String, sKey As String, bDefault As Boolean) As Boolean
    On Error Resume Next
    ofx_RegGetBool = (ofx_RegGetString(sSection, sKey, IIf(bDefault, "Yes", "No")) = "Yes")
End Function


'------------------------------------------------------------------------------
' Function: ofx_RegDeleteSection
'
' Purpose:  Delete the specified section from the registry.
'
' Params:   sSection    (I) Name of section to delete
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Function ofx_RegDeleteSection(sSection As String) As Boolean
    On Error GoTo ofx_RegDeleteSection_Err
    
    Dim bOk As Boolean
    Dim hKey As Long
    Dim nDummy As Long
    
    bOk = False
    
    hKey = ofx_RegGetAppKey()
    
    If (hKey) Then
        bOk = (ERROR_SUCCESS = RegDeleteKey(hKey, sSection))
        nDummy = RegCloseKey(hKey)
    End If

    bOk = True
    
ofx_RegDeleteSection_Exit:
    ofx_RegDeleteSection = bOk
    Exit Function
    
ofx_RegDeleteSection_Err:
    Call ofx_GenericError("ofx_RegDeleteSection()", Err)
    Resume ofx_RegDeleteSection_Exit
    
End Function

'------------------------------------------------------------------------------
' Function: ofx_RegDeleteKey
'
' Purpose:  Delete the specified key in the specified section.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Public Function ofx_RegDeleteKey(sSection As String, sKey As String) As Boolean
    On Error Resume Next
    
    Dim hKey As Long
    Dim nDummy As Long
    
    hKey = ofx_RegGetSectionKey(sSection)
    If (hKey) Then
        ofx_RegDeleteKey = (RegDeleteValue(hKey, sKey) = ERROR_SUCCESS)
        If (hKey) Then nDummy = RegCloseKey(hKey)
    End If
End Function

'------------------------------------------------------------------------------
' Function: ofx_RegExEnumKeys
'
' Purpose:  Allows the enumeration of ANY key in the registry.
'
' Params:   hKeyBase    (I) The base key
'           sRootKey    (I) The root key name
'           sKeys       (O) List of keys found (0-based index)
'
' Returns:  The number of keys in sKeys() or 0 if none
'------------------------------------------------------------------------------
Public Function ofx_RegExEnumKeys(hKeyBase As Long, sRootKey As String, sKeys() As String) As Long
    On Error GoTo ofx_RegExEnumKeys_Error

    Const BUF_SIZE As Long = 256&
    
    Dim hKeyRoot As Long
    Dim nDummy As Long
    Dim nKey As Long
    Dim dwResult As Long
    Dim sName As String
    Dim cbName As Long
    
    If (ERROR_SUCCESS <> RegOpenKeyEx(hKeyBase, sRootKey, dwReserved, KEY_WRITE Or KEY_READ, hKeyRoot)) Then GoTo ofx_RegExEnumKeys_Exit
    
    nKey = 0
    cbName = BUF_SIZE
    sName = String$(BUF_SIZE, 0)
    
    dwResult = RegEnumKey(hKeyRoot, 0&, sName, cbName)
    If (dwResult <> ERROR_SUCCESS) Then GoTo ofx_RegExEnumKeys_Exit
    
    Do
        ReDim Preserve sKeys(nKey + 1) As String
        sKeys(nKey) = ofx_C2ABStr(Nz(sName))
        nKey = nKey + 1
        
        cbName = BUF_SIZE
        sName = String$(BUF_SIZE, 0)
        dwResult = RegEnumKey(hKeyRoot, nKey, sName, cbName)
    Loop Until (dwResult <> ERROR_SUCCESS)
        
ofx_RegExEnumKeys_Exit:
    If (hKeyRoot) Then nDummy = RegCloseKey(hKeyRoot)
    ofx_RegExEnumKeys = nKey      'return number of elements
    Exit Function
    
ofx_RegExEnumKeys_Error:
    MsgBox Err.Description
    Resume ofx_RegExEnumKeys_Exit
End Function

'------------------------------------------------------------------------------
' Function: ofx_RegGetAppKey()
'
' Purpose:  Get the registry key for:
'           HKEY_LOCAL_MACHINE\Software\<Company>\<AppName>
'
' Returns:  The handle to the key if successful, 0 otherwise
'------------------------------------------------------------------------------
Private Function ofx_RegGetAppKey() As Long

    On Error GoTo ofx_RegGetAppKey_Exit
    
    'NEVER localized
    Const sSoftware$ = "Software"
  
    #If MSA Then
        'Have to have something to look for
        'There is a bug in Access 7 that will reset all global/module variables
        'when the MDI parent window is destroyed.  If you have forms open that would normally
        'want to use these variables, then too bad.  Here, we are forcing the lookup to restore
        'the value of these variables, however, this obviously points to a larger problem.
        If (0 = Len(ofxApp.sAppName) Or 0 = Len(ofxApp.sCompany)) Then
            ofxApp.sCompany = ofx_LoadString(ofxCompanyName)
            ofxApp.sAppName = ofx_LoadString(ofxAppName)
        End If
    #Else
        If (0 = Len(ofxApp.sAppName) Or 0 = Len(ofxApp.sCompany)) Then
            ofxApp.sCompany = "Moss Micro"
            ofxApp.sAppName = "SDVB"
        End If
    #End If
    
    Dim hAppKey As Long
    Dim hSoftKey As Long
    Dim hCompanyKey As Long
    Dim nDummy As Long
    
    hAppKey = 0
    
    If (ERROR_SUCCESS = RegOpenKeyEx(HKEY_LOCAL_MACHINE, sSoftware, dwReserved, KEY_ALL_ACCESS, hSoftKey)) Then
        Dim dw As Long
        Dim dwResult As Long
        dwResult = RegCreateKeyEx(hSoftKey, ofxApp.sCompany, dwReserved, "", REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, ByVal 0&, hCompanyKey, dw)
        #If DBG Then
            ASSERT (ERROR_SUCCESS = dwResult), "ofx_RegGetAppKey"
        #End If
        If (ERROR_SUCCESS = dwResult) Then
            dwResult = RegCreateKeyEx(hCompanyKey, ofxApp.sAppName, dwReserved, "", REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, ByVal 0&, hAppKey, dw)
            
            #If DBG Then
                ASSERT (dwResult = ERROR_SUCCESS), "ofx_RegGetAppKey"
            #End If
        End If
    End If

ofx_RegGetAppKey_Exit:
    On Error Resume Next
    If (hCompanyKey) Then nDummy = RegCloseKey(hCompanyKey)
    If (hSoftKey) Then nDummy = RegCloseKey(hSoftKey)
    ofx_RegGetAppKey = hAppKey
    Exit Function
    
ofx_RegGetAppKey_Err:
    Call ofx_GenericError("ofx_RegGetAppKey()", Err)
    Resume ofx_RegGetAppKey_Exit
    
End Function


'------------------------------------------------------------------------------
' Function: ofx_RegEnumSections
'
' Purpose:  Determine names of all sections in the application's registry.
'
' Params:   sSections   (O) List of all section names (0-based index)
'
' Returns:  Number of sections found.
'
' See also: ofx_RegEnumKeys()
'------------------------------------------------------------------------------
Public Function ofx_RegEnumSections(sSections() As String) As Long
    On Error GoTo ofx_RegEnumSections_Error

    Dim hAppKey As Long
    hAppKey = ofx_RegGetAppKey()
    
    Dim nKey As Long
    
    Dim dwResult As Long
    Dim sName As String
    Dim cbName As Long
    Dim nDummy As Long

    Const BUF_SIZE& = 128&
    
    nKey = 0
    cbName = BUF_SIZE
    sName = String$(BUF_SIZE, 0)
    dwResult = RegEnumKey(hAppKey, 0&, sName, cbName)
    
    If (ERROR_SUCCESS = dwResult) Then
        Do
            ReDim Preserve sSections(nKey + 1) As String
            sSections(nKey) = ofx_C2ABStr(sName)
            nKey = nKey + 1
            
            cbName = BUF_SIZE
            sName = String$(BUF_SIZE, 0)
            dwResult = RegEnumKey(hAppKey, nKey, sName, cbName)
        Loop Until (dwResult <> ERROR_SUCCESS)
    End If
    
ofx_RegEnumSections_Exit:
    If (hAppKey) Then nDummy = RegCloseKey(hAppKey)
    ofx_RegEnumSections = nKey      'return number of elements
    Exit Function
    
ofx_RegEnumSections_Error:
    MsgBox Err.Description
    Resume ofx_RegEnumSections_Exit
End Function



'------------------------------------------------------------------------------
' Function: ofx_RegEnumKeys
'
' Purpose:  Determine names of keys in specified section the registry.
'
' Params:   sSection    (I) Section for which to find keys
'           sKeys       (O) List of all key names in section (0-based index)
'
' Returns:  Number of keys found in section
'
' See also: ofx_RegEnumSections()
'------------------------------------------------------------------------------
Public Function ofx_RegEnumKeys(sSection As String, sKeys() As String) As Long
    On Error GoTo ofx_RegEnumKeys_Error
    
    Dim hSecKey As Long
    hSecKey = ofx_RegGetSectionKey(sSection)
    
    Dim nKey As Long
    
    Dim dwResult As Long
    Dim sName As String
    Dim cbName As Long
    Dim dwType As Long
    Dim nDummy As Long

    Const BUF_SIZE& = 128&
    
    nKey = 0
    cbName = BUF_SIZE
    sName = String$(BUF_SIZE, 0)
    dwResult = RegEnumValue(hSecKey, 0&, sName, cbName, dwReserved, dwType, ByVal 0&, ByVal 0&)
    
    If (ERROR_SUCCESS = dwResult) Then
        Do
            ReDim Preserve sKeys(nKey + 1) As String
            If (cbName > 0) Then sKeys(nKey) = ofx_C2ABStr(left$(sName, cbName))
            nKey = nKey + 1
            
            cbName = BUF_SIZE
            sName = String$(BUF_SIZE, 0)
            dwResult = RegEnumValue(hSecKey, nKey, sName, cbName, dwReserved, dwType, ByVal 0&, ByVal 0&)
        Loop Until (dwResult <> ERROR_SUCCESS)
    End If
    
ofx_RegEnumKeys_Exit:
    If (hSecKey) Then nDummy = RegCloseKey(hSecKey)
    ofx_RegEnumKeys = nKey      'return number of elements
    Exit Function
    
ofx_RegEnumKeys_Error:
    MsgBox Err.Description              'don't call Generic Error
    Resume ofx_RegEnumKeys_Exit
End Function

'------------------------------------------------------------------------------
' Function: ofx_RegGetString
'
' Purpose:  Retrieve a string from the application's registry.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           sDefault    (I) Default value
'
' Returns   The string if found, else the default.
'
' See also: ofx_RegWriteString(), ofx_RegGetBool(), ofx_RegGetInt(),
'           ofx_RegGetRect(), ofx_RegGetVariant()
'------------------------------------------------------------------------------
Public Function ofx_RegGetString(ByVal sSection As String, sKey As String, sDefault As String) As String

    Dim hKey As Long
    Dim nDummy As Long
    Dim sValue As String
    Dim szValue As String
    Dim cbValue As Long
    Dim dwType As Long
    
    sValue = sDefault
    
    hKey = ofx_RegGetSectionKey(sSection)
    If (hKey = 0) Then GoTo ofx_RegGetString_Exit
    
    '----- Get the length of the buffer required and verify data type first
    
    If (RegQueryValueEx(hKey, sKey, 0&, dwType, ByVal 0&, cbValue) <> ERROR_SUCCESS) Then GoTo ofx_RegGetString_Exit
    If (REG_SZ <> dwType) Then GoTo ofx_RegGetString_Exit
    
    '----- Get the string
    
    szValue = String$(cbValue + 1, 0)   'for safety
    If (RegQueryValueEx(hKey, sKey, 0&, REG_SZ, ByVal szValue, cbValue) <> ERROR_SUCCESS) Then GoTo ofx_RegGetString_Exit
        
    '----- Convert from C to BASIC string
    
    If (cbValue > 0) Then
        sValue = ofx_C2ABStr(left$(szValue, cbValue))
    Else
        sValue = ""
    End If
    
ofx_RegGetString_Exit:
    On Error Resume Next
    If (hKey) Then nDummy = RegCloseKey(hKey)
    ofx_RegGetString = sValue
    Exit Function
End Function



'------------------------------------------------------------------------------
' Function: ofx_RegGetInt
'
' Purpose:  Retrieve a numeric value from the application's registry.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           nDefault    (I) Default value
'
' Returns:  The numeric value if found, else the default.
'
' See also: ofx_RegWriteInt(), ofx_RegGetBool(), ofx_RegGetRect(), ofx_RegGetString(),
'           ofx_RegGetVariant()
'------------------------------------------------------------------------------
Public Function ofx_RegGetInt(sSection As String, sKey As String, ByVal nDefault As Long) As Long
    On Error GoTo ofx_RegGetInt_Error
    
    Dim nValue As Long
    Dim hKey As Long
    Dim nDummy As Long
    Dim cbValue As Long
    Dim dwType As Long
        
    nValue = nDefault
    
    hKey = ofx_RegGetSectionKey(sSection)
    If (hKey = 0) Then GoTo ofx_RegGetInt_Exit
    
    '----- Get the value
    
    cbValue = Len(nValue)
    If (RegQueryValueEx(hKey, sKey, 0&, dwType, nValue, cbValue) <> ERROR_SUCCESS) Then GoTo ofx_RegGetInt_Exit

    '----- Make sure type is correct
    
    #If DBG Then
        ASSERT (REG_DWORD = dwType), "ofx_RegGetInt", "Value is the wrong type."
    #End If
    
    If (REG_DWORD <> dwType) Then
        nValue = nDefault
    End If
    
ofx_RegGetInt_Exit:
    On Error Resume Next
    If (hKey) Then nDummy = RegCloseKey(hKey)
    ofx_RegGetInt = nValue
    Exit Function
ofx_RegGetInt_Error:
    MsgBox Err.Description
    Resume ofx_RegGetInt_Exit
End Function


'------------------------------------------------------------------------------
' Function: ofx_RegGetSectionKey
'
' Params:   sSection    (I) Name of the section to for which to retrieve the key.
'
' Purpose:  Gets the handle to the "section" key wanted.  Note that the section is
'           created if it does not exist.
'
' Returns:  The handle to the key if successful, 0 otherwise
'------------------------------------------------------------------------------
Private Function ofx_RegGetSectionKey(sSection As String) As Long
    
    Dim hAppKey As Long
    Dim nDummy As Long
    
    hAppKey = ofx_RegGetAppKey()
    
    #If DBG Then
        ASSERT (hAppKey), "ofx_RegGetSectionKey"
    #End If
    
    If (hAppKey) Then
            
        Dim hSecKey As Long
        Dim dw As Long
        
        If (ERROR_SUCCESS = RegCreateKeyEx(hAppKey, sSection, dwReserved, "", REG_OPTION_NON_VOLATILE, KEY_WRITE Or KEY_READ, ByVal 0&, hSecKey, dw)) Then
            ofx_RegGetSectionKey = hSecKey
        End If
      
        nDummy = RegCloseKey(hAppKey)
      
    End If
    
End Function

'----------------------------------------------------------------------------------------
' Function: ofx_RegExGetVariant
'
' Purpose:  Get the value for ANY key.
'
' Params:   hKeyRoot    (I) Parent key
'           sKey        (I) Key name
'           sValueName  (I) Value name
'
' Returns:  A variant, either a string (REG_SZ) or long (REG_DWORD) for the specified key
'
' Note:     The root key is NOT ALWAYS HKEY_LOCAL_MACHINE, its whatever is supplied
'           in the hKeyRoot parameter.
'           To get (Default) value for a key sValueName should be an empty string.
'----------------------------------------------------------------------------------------
Function ofx_RegExGetVariant(hKeyRoot As Long, sKey As String, sValueName As String) As Variant
    
    Dim hKey As Long
    Dim dwResult As Long
    
    dwResult = RegOpenKeyEx(hKeyRoot, sKey, 0&, KEY_ALL_ACCESS, hKey)
    
    If (ERROR_SUCCESS = dwResult) Then
    
        Dim sValue As String
        Dim cbBytes As Long
        Dim dwType As Long
        cbBytes = 0&
        
        'sizeof()...
        If (ERROR_SUCCESS = RegQueryValueEx(hKey, sValueName, 0&, dwType, ByVal 0&, cbBytes)) Then
        
            If (REG_SZ = dwType) Then
                sValue = String$(cbBytes + 1, 0)    'essentially malloc
            
                If (ERROR_SUCCESS = RegQueryValueEx(hKey, sValueName, 0&, dwType, ByVal sValue, cbBytes)) Then
                    If (cbBytes > 0) Then
                        ofx_RegExGetVariant = ofx_C2ABStr(Nz(sValue))
                    End If
                End If
            
            ElseIf (REG_DWORD = dwType) Then
                
                Dim nValue As Long
                
                If (ERROR_SUCCESS = RegQueryValueEx(hKey, sValueName, 0&, dwType, nValue, cbBytes)) Then
                    ofx_RegExGetVariant = nValue
                End If
            
            Else
                ofx_RegExGetVariant = Null
            End If
            
        End If
        
        Call RegCloseKey(hKey)
        
    Else
        ofx_RegExGetVariant = Null
    End If

End Function

'------------------------------------------------------------------------------
' Function: ofx_RegExEnumValues
'
' Purpose:  Allows the enumeration of ANY value in the registry.
'
' Params:   hKeyRoot    (I) Parent key
'           sKey        (I) Key name
'           sValues     (O) List of values for specified key (0-based index)
'
' Returns:  Number of entries in list.
'------------------------------------------------------------------------------
Public Function ofx_RegExEnumValues(hKeyRoot As Long, sKey As String, sValues() As String) As Long
    On Error GoTo ofx_RegExEnumValues_Error
    
    Dim hSecKey As Long
    If (ERROR_SUCCESS = RegOpenKey(hKeyRoot, sKey, hSecKey)) Then
        
        Dim nKey As Long
        
        Dim dwResult As Long
        Dim sName As String
        Dim cbName As Long
        Dim dwType As Long
    
        Const BUF_SIZE& = 128&
        
        cbName = BUF_SIZE
        sName = String$(BUF_SIZE, 0)
        dwResult = RegEnumValue(hSecKey, 0&, sName, cbName, dwReserved, dwType, ByVal 0&, ByVal 0&)
        If (ERROR_SUCCESS = dwResult) Then
        
            Do
                ReDim Preserve sValues(0 To nKey) As String
                If (cbName > 0) Then sValues(nKey) = ofx_C2ABStr(Nz(sName))
                nKey = nKey + 1
                
                cbName = BUF_SIZE
                sName = String$(BUF_SIZE, 0)
                dwResult = RegEnumValue(hSecKey, nKey, sName, cbName, dwReserved, dwType, ByVal 0&, ByVal 0&)
            Loop Until (dwResult <> ERROR_SUCCESS)
        
            ofx_RegExEnumValues = (UBound(sValues) + 1)      'return number of elements
            
        End If
    
    End If
    
ofx_RegExEnumValues_Exit:
    If (hSecKey) Then Call RegCloseKey(hSecKey)
    Exit Function
ofx_RegExEnumValues_Error:
    MsgBox Err.Description              'don't call Generic Error
    Resume ofx_RegExEnumValues_Exit
End Function

'------------------------------------------------------------------------------
' Function: ofx_RegExRecursiveDeleteKey
'
' Purpose:  Deletes a key from the registry (deleting all sub-keys and values if any)
'
' Params:   hParentKey  (I) Parent key
'           sKey        (I) Key name
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Function ofx_RegExRecursiveDeleteKey(hParentKey As Long, sKey As String) As Boolean
    ofx_RegExRecursiveDeleteKey = (ofx_RegRecursiveDeleteKey_Private(hParentKey, sKey) = ERROR_SUCCESS)
End Function



'------------------------------------------------------------------------------
' Function: ofx_RegRecursiveDeleteKey_Private
'
' Purpose:  Deletes a key from the registry (deleting all sub-keys and values if any)
'
' Params:   hParentKey  (I) Parent key
'           sKey        (I) Key name
'
' Returns:  dwResult, result of last Win API call.
'------------------------------------------------------------------------------
Private Function ofx_RegRecursiveDeleteKey_Private(hParentKey As Long, sKey As String) As Long
    On Error Resume Next
    
    Dim szSubKeyName As String * 256
    Dim hCurrentKey As Long
    Dim dwResult As Long
    
    dwResult = RegOpenKey(hParentKey, sKey, hCurrentKey)
    If (ERROR_SUCCESS = dwResult) Then
    
        '----- Remove all subkeys of the key to delete
        
        Do
            dwResult = RegEnumKey(hCurrentKey, 0&, szSubKeyName, 255)
            If (ERROR_SUCCESS = dwResult) Then
                dwResult = ofx_RegRecursiveDeleteKey_Private(hCurrentKey, szSubKeyName)
                If (dwResult <> ERROR_SUCCESS) Then
                    Exit Do
                End If
            End If
        Loop Until (ERROR_SUCCESS <> dwResult)

        '----- If all went well, we should now be able to delete the requested key
        
        If ((dwResult = ERROR_NO_MORE_ITEMS) Or (dwResult = ERROR_BADKEY)) Then
            dwResult = RegDeleteKey(hParentKey, sKey)
        End If
    
    End If

    Call RegCloseKey(hCurrentKey)
    ofx_RegRecursiveDeleteKey_Private = dwResult
End Function


'------------------------------------------------------------------------------
' Function: ofx_RegWriteBool
'
' Purpose:  Write a boolean value to the application's registry.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           bValue      (I) Value to set
'
' Notes:    TRUE and FALSE are stored as "Yes" and "No" strings respectively.
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_RegGetBool(), ofx_RegWriteInt(), ofx_RegWriteMultiString(),
'           ofx_RegWriteRect(), ofx_RegWriteString().
'------------------------------------------------------------------------------
Public Function ofx_RegWriteBool(sSection As String, sKey As String, bValue As Boolean) As Boolean
    On Error Resume Next
    ofx_RegWriteBool = ofx_RegWriteString(sSection, sKey, IIf(bValue, "Yes", "No"))
End Function

'------------------------------------------------------------------------------
' Function: ofx_RegWriteString
'
' Purpose:  Write a string to the application's registry.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           sValue      (I) Value to write
'
' Returns:  TRUE on success, else FALSE
'
' See also: ofx_RegGetString(), ofx_RegWriteBool(), ofx_RegWriteInt(),
'           ofx_RegWriteMultiString(), ofx_RegWriteRect().
'------------------------------------------------------------------------------
Public Function ofx_RegWriteString(sSection As String, sKey As String, sValue As String) As Boolean

    On Error Resume Next
            
    Dim bOk As Boolean
    Dim hKey As Long
    Dim nDummy As Long
    
    bOk = False
    
    hKey = ofx_RegGetSectionKey(sSection)
    If (hKey = 0) Then GoTo ofx_RegWriteString_Exit
    
    If (RegSetValueEx(hKey, sKey, 0&, REG_SZ, ByVal sValue, Len(sValue)) <> ERROR_SUCCESS) Then GoTo ofx_RegWriteString_Exit
    
    bOk = True
    
ofx_RegWriteString_Exit:
    On Error Resume Next
    If (hKey) Then nDummy = RegCloseKey(hKey)
    ofx_RegWriteString = bOk
    Exit Function
    
End Function

'------------------------------------------------------------------------------
' Function: ofx_RegWriteInt
'
' Purpose:  Write an integer value to the application's registry.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           nValue      (I) Value to write
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_RegGetInt(), ofx_RegWriteBool(), ofx_RegWriteMultiString(),
'           ofx_RegWriteRect(), ofx_RegWriteString().
'------------------------------------------------------------------------------
Public Function ofx_RegWriteInt(sSection As String, sKey As String, ByVal nValue As Long) As Boolean
    On Error GoTo ofx_RegWriteInt_Error
    
    Dim bOk As Boolean
    Dim hKey As Long
    Dim nDummy As Long
    
    bOk = False
    
    '----- Check args
    
    #If DBG Then
        ASSERT ((Len(sSection) > 0) And Len(sKey) > 0), "ofx_WriteProfileInt"
    #End If
    
    hKey = ofx_RegGetSectionKey(sSection)
    #If DBG Then
        ASSERT (hKey), "ofx_RegWriteInt"
    #End If
    If (hKey = 0) Then GoTo ofx_RegWriteInt_Exit
 
    '----- Write value
    
    If (RegSetValueEx(hKey, sKey, 0&, REG_DWORD, nValue, Len(nValue)) <> ERROR_SUCCESS) Then GoTo ofx_RegWriteInt_Exit
    
    bOk = True
    
ofx_RegWriteInt_Exit:
    On Error Resume Next
    If (hKey) Then nDummy = RegCloseKey(hKey)
    ofx_RegWriteInt = bOk
    Exit Function
ofx_RegWriteInt_Error:
    MsgBox Err.Description
    Resume ofx_RegWriteInt_Exit
    
End Function

'------------------------------------------------------------------------------
' Function: ofx_RegWriteRect
'
' Purpose:  Write a rectangle to the INI file.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           r           (I) Rectangle to write
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_RegGetRect(), ofx_RegWriteBool(), ofx_RegWriteInt(),
'           ofx_RegWriteMultiString(), ofx_RegWriteString().
'
' Notes:    This function is an example of how to use the registry to
'           store structured data.  It could easily be copied to support
'           any data type that was defined in the application.
'------------------------------------------------------------------------------
Public Function ofx_RegWriteRect(ByVal sSection As String, ByVal sKey As String, ByRef rc As RECT) As Boolean
    On Error Resume Next
    
    Dim bOk As Boolean
    Dim hKey As Long
    Dim nDummy As Long
    
    bOk = False
    
    hKey = ofx_RegGetSectionKey(sSection)
    If (hKey = 0) Then GoTo ofx_RegWriteRect_Exit
        
    If (RegSetValueEx(hKey, sKey, 0&, REG_BINARY, rc, Len(rc)) <> ERROR_SUCCESS) Then GoTo ofx_RegWriteRect_Exit
            
    bOk = True
    
ofx_RegWriteRect_Exit:
    On Error Resume Next
    If (hKey) Then nDummy = RegCloseKey(hKey)
    ofx_RegWriteRect = bOk
    Exit Function
    
End Function

'------------------------------------------------------------------------------
' Function: ofx_RegGetRect
'
' Purpose:  Retrieve a rectangle from the application's registry.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           r           (I/O) Default and retrieved rectangle
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_RegWriteRect(), ofx_RegGetBool(), ofx_RegGetInt(),
'           ofx_RegGetString().
'
' Notes:    This function is an example of how to use the registry to
'           retrieve structured data.  It could easily be copied to support
'           any data type that was defined in the application.
'------------------------------------------------------------------------------
Function ofx_RegGetRect(ByVal sSection As String, ByVal sKey As String, ByRef rc As RECT) As Boolean

    Dim bOk As Boolean
    Dim hKey As Long
    Dim nDummy As Long
    Dim dwResult As Long
    Dim cbValue As Long
    Dim dwType As Long
    
    bOk = False
    
    hKey = ofx_RegGetSectionKey(sSection)
    If (hKey = 0) Then GoTo ofx_RegGetRect_Exit

    '----- Get the length of the buffer required first
    
    If (RegQueryValueEx(hKey, sKey, 0&, dwType, ByVal 0&, cbValue) <> ERROR_SUCCESS) Then GoTo ofx_RegGetRect_Exit
    
    '----- Verify type and size
    
    If (REG_BINARY <> dwType Or Len(rc) <> cbValue) Then GoTo ofx_RegGetRect_Exit
    
    '----- Get the rect
    
    nDummy = RegQueryValueEx(hKey, sKey, 0&, REG_BINARY, rc, Len(rc))
    
    bOk = True
    
ofx_RegGetRect_Exit:
    On Error Resume Next
    If (hKey) Then nDummy = RegCloseKey(hKey)
    ofx_RegGetRect = bOk
    Exit Function
    
End Function


'------------------------------------------------------------------------------
'   Function:   ofx_RegDataType()
'
'   Purpose:    Determine data type of the specified registry entry.
'
'   Params:     sSection    (I) Section name
'               sKey        (I) Key name
'               nSize       (O) Size of data
'
'   Returns:    Data type REG_* from the Ofx Windows module
'------------------------------------------------------------------------------
Public Function ofx_RegDataType(sSection As String, sKey As String, nSize As Long) As Long

    On Error GoTo ofx_RegDataType_Err  ' SDVB error handling

    Dim bOk As Boolean
    Dim hKey As Long
    Dim dwResult As Long
    Dim cbValue As Long
    Dim dwType As Long
    Dim nDummy As Long
    
    dwType = REG_NONE
    nSize = 0

    hKey = ofx_RegGetSectionKey(sSection)
    If (hKey = 0) Then GoTo ofx_RegDataType_Exit
    
    '----- Get info about specified key/value
    
    dwResult = RegQueryValueEx(hKey, sKey, 0&, dwType, ByVal 0&, cbValue)
    If (ERROR_SUCCESS <> dwResult) Then GoTo ofx_RegDataType_Exit
    
    nSize = cbValue
    
ofx_RegDataType_Exit:                                ' SDVB error handling
    On Error Resume Next
    If (hKey) Then nDummy = RegCloseKey(hKey)
    ofx_RegDataType = dwType                         ' SDVB error handling
    Exit Function                                    ' SDVB error handling
    
ofx_RegDataType_Err:                                 ' SDVB error handling
    Call ofx_GenericError("ofx_RegDataType()", Err)  ' SDVB error handling
    Resume ofx_RegDataType_Exit                      ' SDVB error handling

End Function

'------------------------------------------------------------------------------
' Function: ofx_RegWriteMultiString
'
' Purpose:  Store a multi-line string in the application's registry.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           sValue      (I) String to store
'
' Returns:  TRUE on success, else FALSE.
'
' Note:     Use ofx_RegGetVariant() to retrieve multi-line strings.
'
' See also: ofx_RegGetVariant(), ofx_RegWriteBool(), ofx_RegWriteInt(),
'           ofx_RegWriteRect(), ofx_RegWriteString().
'------------------------------------------------------------------------------
Public Function ofx_RegWriteMultiString(sSection As String, sKey As String, sValue As String) As Boolean

    On Error GoTo ofx_RegWriteMultiString_Err  ' SDVB error handling

    Dim bOk As Boolean
    Dim hKey As Long
    Dim szValue As String
    Dim nDummy As Long

    bOk = False
    
    hKey = ofx_RegGetSectionKey(sSection)
    If (hKey = 0) Then GoTo ofx_RegWriteMultiString_Exit

    '----- Insert multi-line value
    
    If (sSection = "" Or sKey = "") Then GoTo ofx_RegWriteMultiString_Exit
    
    szValue = ofx_ReplaceString(sValue, ofx_CRLF(), Chr(0))
    If (RegSetValueEx(hKey, sKey, 0&, REG_MULTI_SZ, ByVal szValue, Len(szValue)) <> ERROR_SUCCESS) Then GoTo ofx_RegWriteMultiString_Exit

    bOk = True
    
ofx_RegWriteMultiString_Exit:                                ' SDVB error handling
    On Error Resume Next
    If (hKey) Then nDummy = RegCloseKey(hKey)
    ofx_RegWriteMultiString = bOk
    Exit Function                                            ' SDVB error handling
ofx_RegWriteMultiString_Err:                                 ' SDVB error handling
    Call ofx_GenericError("ofx_RegWriteMultiString()", Err)  ' SDVB error handling
    Resume ofx_RegWriteMultiString_Exit                      ' SDVB error handling

End Function

'------------------------------------------------------------------------------
' Function: ofx_RegGetVariant
'
' Purpose:  Retrieve the appropriate value from the registry regardless of type.
'
' Params:   sSection    (I) Section name
'           sKey        (I) Key name
'           vDefault    (I) Default value
'
' Returns:  The type-safe value if found, else the default.
'------------------------------------------------------------------------------
Public Function ofx_RegGetVariant(ByVal sSection As String, sKey As String, vDefault As Variant) As Variant

    On Error GoTo ofx_RegGetVariant_Err  ' SDVB error handling

    Dim hKey As Long
    Dim vValue As Variant
    Dim nDummy As Long
    Dim cbValue As Long
    Dim dwType As Long
    
    vValue = vDefault
    
    '----- Get section key
    
    hKey = ofx_RegGetSectionKey(sSection)
    If (hKey = 0) Then GoTo ofx_RegGetVariant_Exit
    
    '----- Get data as appropriate
    
    dwType = ofx_RegDataType(sSection, sKey, cbValue)
    Select Case dwType
        Case REG_SZ, REG_MULTI_SZ
            Dim szValue As String
            
            szValue = String$(cbValue + 1, 0)   'for safety
            If (RegQueryValueEx(hKey, sKey, 0&, dwType, ByVal szValue, cbValue) <> ERROR_SUCCESS) Then GoTo ofx_RegGetVariant_Exit
            
            If (cbValue > 0) Then
                If (dwType = REG_SZ) Then
                    vValue = ofx_C2ABStr(left$(szValue, cbValue))
                Else
                    vValue = ofx_ReplaceString(left$(szValue, cbValue), Chr(0), ofx_CRLF())
                End If
            Else
                vValue = ""
            End If
        Case REG_DWORD
            Dim nValue As Long
            
            If (RegQueryValueEx(hKey, sKey, 0&, dwType, nValue, cbValue) <> ERROR_SUCCESS) Then GoTo ofx_RegGetVariant_Exit
                
            vValue = nValue
    End Select
    
ofx_RegGetVariant_Exit:                                ' SDVB error handling
    On Error Resume Next
    If (hKey) Then nDummy = RegCloseKey(hKey)
    ofx_RegGetVariant = vValue
    Exit Function                                      ' SDVB error handling
ofx_RegGetVariant_Err:                                 ' SDVB error handling
    Call ofx_GenericError("ofx_RegGetVariant()", Err)  ' SDVB error handling
    Resume ofx_RegGetVariant_Exit                      ' SDVB error handling

End Function


#End If     ' Win32 only


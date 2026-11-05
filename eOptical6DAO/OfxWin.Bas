Attribute VB_Name = "OfxWinAPI"
'------------------------------------------------------------------------------
' Module:   Ofx - Win API
'
' Purpose:  This module contains all the declarations to the Windows API
'           functions.  It also contains BASIC functions that act
'           as "higher level" replacements to the API calls.
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

Public Const SM_CYSIZE = 31

'----- Structure used by API calls that reqire a C RECT or C POINT data structures
'----- (also generally handy).

Type RECT
#If Win16 Then
    nLeft As Integer
    nTop As Integer
    nRight As Integer
    nBottom As Integer
#Else
    nLeft As Long
    nTop As Long
    nRight As Long
    nBottom As Long
#End If
End Type

Type POINTAPI
#If Win16 Then
    x As Integer
    y As Integer
#Else
    x As Long
    y As Long
#End If
End Type

Type Size
#If Win16 Then
    cx As Integer
    cy As Integer
#Else
    cx As Long
    cy As Long
#End If
End Type

'----- Windows API function declarations.

#If Win32 Then
Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Declare Function GetForegroundWindow Lib "user32" () As Long
Declare Function SetForegroundWindow Lib "user32" (ByVal Hwnd As Long) As Long
Declare Function GetClassName Lib "user32" Alias "GetClassNameA" (ByVal Hwnd As Long, ByVal lpClassName As String, ByVal nMaxCount As Long) As Long
Declare Function GetSysColor Lib "user32" (ByVal nIndex As Long) As Long
Declare Function GetWindowsDirectory Lib "kernel32" Alias "GetWindowsDirectoryA" (ByVal lpBuffer As String, ByVal nSize As Long) As Long
Declare Function GetSystemDirectory Lib "kernel32" Alias "GetSystemDirectoryA" (ByVal lpBuffer As String, ByVal nSize As Long) As Long

Declare Function GetTempPath Lib "kernel32" Alias "GetTempPathA" (ByVal nBufferLength As Long, ByVal lpBuffer As String) As Long
Declare Function GetTempFileName Lib "kernel32" Alias "GetTempFileNameA" (ByVal lpszPath As String, ByVal lpPrefixString As String, ByVal wUnique As Long, ByVal lpTempFileName As String) As Long

Declare Function GetWindow Lib "user32" (ByVal Hwnd As Long, ByVal wCmd As Long) As Long

Declare Function GetClientRect Lib "user32" (ByVal Hwnd As Long, lpRect As RECT) As Long
Declare Function GetWindowRect Lib "user32" (ByVal Hwnd As Long, lpRect As RECT) As Long

Declare Function SetWindowText Lib "user32" Alias "SetWindowTextA" (ByVal Hwnd As Long, ByVal lpString As String) As Long
Declare Function GetWindowText Lib "user32" Alias "GetWindowTextA" (ByVal Hwnd As Long, ByVal lpString As String, ByVal cch As Long) As Long
Declare Function GetWindowTextLength Lib "user32" Alias "GetWindowTextLengthA" (ByVal Hwnd As Long) As Long

Declare Function ShowWindow Lib "user32" (ByVal Hwnd As Long, ByVal nCmdShow As Long) As Long

Declare Function IsWindowVisible Lib "user32" (ByVal Hwnd As Long) As Long
Declare Function IsIconic Lib "user32" (ByVal Hwnd As Long) As Long
Declare Function AnyPopup Lib "user32" () As Long
Declare Function BringWindowToTop Lib "user32" (ByVal Hwnd As Long) As Long
Declare Function IsZoomed Lib "user32" (ByVal Hwnd As Long) As Long

Declare Function SetWindowPos Lib "user32" (ByVal Hwnd As Long, ByVal hWndInsertAfter As Long, ByVal x As Long, ByVal y As Long, ByVal cx As Long, ByVal cy As Long, ByVal wFlags As Long) As Long

Declare Function GetSystemMetrics Lib "user32" (ByVal nIndex As Long) As Long

Declare Function ClientToScreen Lib "user32" (ByVal Hwnd As Long, lpPoint As POINTAPI) As Long
Declare Function ScreenToClient Lib "user32" (ByVal Hwnd As Long, lpPoint As POINTAPI) As Long

Declare Function MoveWindow Lib "user32" (ByVal Hwnd As Long, ByVal x As Long, ByVal y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal bRepaint As Long) As Long

Declare Function GetCursorPos Lib "user32" (lpPoint As POINTAPI) As Long
Declare Function WindowFromPoint Lib "user32" (ByVal xPoint As Long, ByVal yPoint As Long) As Long
Declare Function GetTextExtentPoint Lib "gdi32" Alias "GetTextExtentPointA" (ByVal hdc As Long, ByVal lpszString As String, ByVal cbString As Long, lpSize As Size) As Long

Declare Function SetParent Lib "user32" (ByVal hWndChild As Long, ByVal hWndNewParent As Long) As Long
Declare Function EnableWindow Lib "user32" (ByVal Hwnd As Long, ByVal fEnable As Long) As Long
#Else
Public Const GWW_HINSTANCE = (-6)
Public Const WF_WINNT = &H4000
    
Declare Function FindWindow Lib "User" (ByVal lpClassName As Any, ByVal lpWindowName As Any) As Integer
Declare Function GetClassName Lib "User" (ByVal Hwnd As Integer, ByVal lpClassName As String, ByVal nMaxCount As Integer) As Integer
Declare Function GetSysColor Lib "User" (ByVal nIndex As Integer) As Long
Declare Function GetWindowsDirectory Lib "KERNEL" (ByVal lpBuffer As String, ByVal nSize As Integer) As Integer
Declare Function GetSystemDirectory Lib "KERNEL" (ByVal lpBuffer As String, ByVal nSize As Integer) As Integer
Declare Function GetTempFileName Lib "KERNEL" (ByVal cDriveLetter As Integer, ByVal lpPrefixString As String, ByVal wUnique As Integer, ByVal lpTempFileName As String) As Integer
Declare Function GetWindow Lib "User" (ByVal Hwnd As Integer, ByVal wCmd As Integer) As Integer
Declare Sub GetClientRect Lib "User" (ByVal Hwnd As Integer, lpRect As RECT)
Declare Sub GetWindowRect Lib "User" (ByVal Hwnd As Integer, lpRect As RECT)
Declare Sub SetWindowText Lib "User" (ByVal Hwnd As Integer, ByVal lpString As String)
Declare Function GetWindowText Lib "User" (ByVal Hwnd As Integer, ByVal lpString As String, ByVal aint As Integer) As Integer
Declare Function GetWindowTextLength Lib "User" (ByVal Hwnd As Integer) As Integer
Declare Function ShowWindow Lib "User" (ByVal Hwnd As Integer, ByVal nCmdShow As Integer) As Integer
Declare Function IsWindowVisible Lib "User" (ByVal Hwnd As Integer) As Integer
Declare Function IsIconic Lib "User" (ByVal Hwnd As Integer) As Integer
Declare Function AnyPopup Lib "User" () As Integer
Declare Sub BringWindowToTop Lib "User" (ByVal Hwnd As Integer)
Declare Function IsZoomed Lib "User" (ByVal Hwnd As Integer) As Integer
Declare Sub SetWindowPos Lib "User" (ByVal Hwnd As Integer, ByVal hWndInsertAfter As Integer, ByVal x As Integer, ByVal y As Integer, ByVal cx As Integer, ByVal cy As Integer, ByVal wFlags As Integer)
Declare Function GetSystemMetrics Lib "User" (ByVal nIndex As Integer) As Integer
Declare Sub ClientToScreen Lib "User" (ByVal Hwnd As Integer, lpPoint As POINTAPI)
Declare Sub ScreenToClient Lib "User" (ByVal Hwnd As Integer, lpPoint As POINTAPI)
Declare Sub MoveWindow Lib "User" (ByVal Hwnd As Integer, ByVal x As Integer, ByVal y As Integer, ByVal nWidth As Integer, ByVal nHeight As Integer, ByVal bRepaint As Integer)
Declare Sub GetCursorPos Lib "User" (lpPoint As POINTAPI)
Declare Function WindowFromPoint Lib "User" (ByVal Pnt As Any) As Integer
Declare Function GetTextExtentPoint Lib "GDI" (ByVal hdc As Integer, ByVal lpszString As String, ByVal cbString As Integer, lpSize As Size) As Integer
Declare Function SetParent Lib "User" (ByVal hWndChild As Integer, ByVal hWndNewParent As Integer) As Integer
Declare Function EnableWindow Lib "User" (ByVal Hwnd As Integer, ByVal aBOOL As Integer) As Integer
Declare Function LoadString Lib "User" (ByVal hInstance As Integer, ByVal wID As Integer, ByVal lpBuffer As Any, ByVal nBufferMax As Integer) As Integer
Declare Function GetWindowLong Lib "User" (ByVal Hwnd As Integer, ByVal nIndex As Integer) As Long
Declare Function GetWindowWord Lib "User" (ByVal Hwnd As Integer, ByVal nIndex As Integer) As Integer
Declare Function GetWinFlags Lib "KERNEL" () As Long
Declare Function GetVersion Lib "KERNEL" () As Long
Declare Function GetActiveWindow Lib "User" () As Integer
Declare Function SetActiveWindow Lib "User" (ByVal Hwnd As Integer) As Integer
#End If

'----- GetSystemMetrics constants

Public Const SM_CYCAPTION = 4
Public Const SM_CYBORDER = 6
Public Const SM_CYMENU = 15

'----- SetWindowPos Flags

Public Const SWP_NOSIZE = &H1
Public Const SWP_NOMOVE = &H2
Public Const SWP_NOZORDER = &H4
Public Const SWP_NOREDRAW = &H8
Public Const SWP_NOACTIVATE = &H10
Public Const SWP_DRAWFRAME = &H20
Public Const SWP_SHOWWINDOW = &H40
Public Const SWP_HIDEWINDOW = &H80
Public Const SWP_NOCOPYBITS = &H100
Public Const SWP_NOREPOSITION = &H200

'----- SetWindowPos() hwndInsertAfter values

Public Const HWND_TOP = 0
Public Const HWND_BOTTOM = 1
Public Const HWND_TOPMOST = -1
Public Const HWND_NOTOPMOST = -2

'----- ShowWindow() function constants, (see ofx_ActivateApp())

Public Const SW_HIDE = 0
Public Const SW_SHOWNORMAL = 1
Public Const SW_NORMAL = 1
Public Const SW_SHOWMINIMIZED = 2
Public Const SW_SHOWMAXIMIZED = 3
Public Const SW_MAXIMIZE = 3
Public Const SW_SHOWNOACTIVATE = 4
Public Const SW_SHOW = 5
Public Const SW_MINIMIZE = 6
Public Const SW_SHOWMINNOACTIVE = 7
Public Const SW_SHOWNA = 8
Public Const SW_RESTORE = 9

'----- ofx_GetWindowState() constants.

Public Const OFX_NORMAL = 0             ' Window state: normal.
Public Const OFX_MAXIMIZED = 1          ' Window state: maximized.
Public Const OFX_MINIMIZED = 2          ' Window state: minimized.

'----- GetSysColor() constants.

Public Const COLOR_ACTIVECAPTION = 2
Public Const COLOR_ACTIVEBORDER = 10
Public Const COLOR_APPWORKSPACE = 12

'----- Reg Data Types... (used by INI file/Profile/Registry functions)

Public Const REG_NONE = 0                       ' No value type
Public Const REG_SZ = 1                         ' Unicode nul terminated string
Public Const REG_EXPAND_SZ = 2                  ' Unicode nul terminated string
Public Const REG_BINARY = 3                     ' Free form binary
Public Const REG_DWORD = 4                      ' 32-bit number
Public Const REG_DWORD_LITTLE_ENDIAN = 4        ' 32-bit number (same as REG_DWORD)
Public Const REG_DWORD_BIG_ENDIAN = 5           ' 32-bit number
Public Const REG_LINK = 6                       ' Symbolic Link (unicode)
Public Const REG_MULTI_SZ = 7                   ' Multiple Unicode strings
Public Const REG_RESOURCE_LIST = 8              ' Resource list in the resource map
Public Const REG_FULL_RESOURCE_DESCRIPTOR = 9   ' Resource list in the hardware description
Private Const REG_RESOURCE_REQUIREMENTS_LIST = 10

'----- Network stuff

#If Win16 Then
Declare Function OfxGetNetworkUserID Lib "ofxutl16.dll" (ByVal lpszUser As String, ByVal nBufSize As Integer) As Integer
#Else
Public Const NO_ERROR& = 0
Declare Function WNetGetUser Lib "mpr.dll" Alias "WNetGetUserA" (ByVal lpName As Long, ByVal lpUserName As String, lpnLength As Long) As Long
#End If


'------------------------------------------------------------------------------
' Function: ofx_GetForegroundWindow
'
' Purpose:  Get the foreground window.
'
' Returns:  Handle to foreground window.
'
' Note:     Virtualizes 16-bit vs. 32-bit Windows API's.
'------------------------------------------------------------------------------
Function ofx_GetForegroundWindow() As Long
    #If Win32 Then
        ofx_GetForegroundWindow = GetForegroundWindow()
    #Else
        ofx_GetForegroundWindow = GetActiveWindow()
    #End If
End Function


'------------------------------------------------------------------------------
' Function: ofx_SetForegroundWindow
'
' Purpose:  Set the foreground window.
'
' Params:   hWnd    (I) Handle to window to put in the foreground.
'
' Note:     Virtualizes 16-bit vs. 32-bit Windows API's.
'------------------------------------------------------------------------------
Sub ofx_SetForegroundWindow(ByVal Hwnd As Long)
    Dim nDummy As Long
    
    #If Win32 Then
        nDummy = SetForegroundWindow(Hwnd)
    #Else
        nDummy = SetActiveWindow(Hwnd)
    #End If
End Sub

'------------------------------------------------------------------------------
' Function: ofx_PointAPIToLong
'
' Purpose:  Convert a POINT data structure into a Long with X in the low word
'           and Y in the high word.
'
' Params:   pt  (I) The point to convert
'
' Returns:  The point converted to a Long
'
' Note:     Provided because some Windows API calls require the point
'           coordinates crammed in a Long.
'------------------------------------------------------------------------------
Function ofx_PointAPIToLong(pt As POINTAPI) As Long
    ofx_PointAPIToLong = CLng(pt.x) + CLng(pt.y) * &H10000
End Function

'------------------------------------------------------------------------------
' Function: ofx_GetNetworkUserID
'
' Purpose:  Returns the network name for the current user in Windows For
'           Workgroups and other Networks.
'
' Returns:  The current network user's ID.
'------------------------------------------------------------------------------
#If Win32 Then
Function ofx_GetNetworkUserID() As String
    On Error GoTo GetNetworkUserID_Error
    
    Dim nReturn As Long
    Dim lpnBufferSize As Long
    Dim sUser As String * 256
    lpnBufferSize = 255
    
    nReturn = WNetGetUser(0&, sUser, lpnBufferSize)
    
    If (nReturn <> NO_ERROR) Then
        ofx_GetNetworkUserID = ""
    Else
        
        ofx_GetNetworkUserID = ofx_C2ABStr(sUser)
    End If

    Exit Function
GetNetworkUserID_Error:
    Exit Function
End Function

#Else
Function ofx_GetNetworkUserID() As String
    Dim sName As String * 255
    Dim nLen As Integer
    
    nLen = OfxGetNetworkUserID(sName, 255)
    
    ofx_GetNetworkUserID = ofx_C2ABStr(sName)
End Function
#End If






'------------------------------------------------------------------------------
' Function: ofx_ActivateApp
'
' Purpose:  Activate the specified application.
'
' Params:   sClassName  (I) Class of the application
'           sCaption    (I) START of the Caption of the app (Microsoft Word, )
'
' Returns:  TRUE if the application is found, else FALSE
'
' Note:     This function does not use the obvious method of determining if
'           an app is running (GetModuleHandle()) because under Windows NT the function
'           GetModuleHandle() ALWAYS returns 0 even if an app is running IF that
'           app is running on a separate virtual machine (memory space)
'
' Example:
'           rc = ofx_ActivateApp("OpusApp", "Microsoft Word")
'           rc = ofx_ActivateApp("XLMAIN", "Microsoft Excel"
'------------------------------------------------------------------------------
Function ofx_ActivateApp(sClassName As String, sCaption As String, Optional vCmdShow As Variant) As Integer
    
    On Error GoTo Err_ofx_ActivateApp

    Const GW_HWNDFIRST = 0      'local to this function !!!!
    Const GW_HWNDLAST = 1       'because the wzcs.mda (SQL server upsizer wizard)
    Const GW_HWNDNEXT = 2       'declare these globally
    Const GW_HWNDPREV = 3
    Const GW_OWNER = 4
    Const GW_CHILD = 5
    
    Dim nCmdShow As Long
    Dim nDummy As Long

    If (Not (IsMissing(vCmdShow))) Then
        nCmdShow = CLng(vCmdShow)
    Else
        nCmdShow = SW_SHOWMAXIMIZED
    End If
    
    Dim Hwnd As Long
    Dim hWndLast As Long
    Dim hWndPopup As Long
    Dim sBuf As String

    sBuf = String$(256, 0)
    
    If (Len(sClassName) > 0) Then
        Hwnd = FindWindow(sClassName, vbNullString)
    Else
        Hwnd = FindWindow(vbNullString, vbNullString)
    End If

    If (Hwnd And 0 = Len(sCaption) And Len(sClassName) > 0) Then
        nDummy = ShowWindow(Hwnd, nCmdShow)
        #If Win16 Then
            nDummy = SetActiveWindow(Hwnd)
        #Else
            nDummy = SetForegroundWindow(Hwnd)
        #End If
        ofx_ActivateApp = True
    ElseIf (0 = Hwnd) Then
        ofx_ActivateApp = False
    Else

        Do While (Hwnd)
            
            If (GetWindowTextLength(Hwnd) > 0) Then
    
                nDummy = GetWindowText(Hwnd, sBuf, 255)
                If (0 = StrComp(Left$(sBuf, Len(sCaption)), sCaption, 1)) Then
                
                    nDummy = ShowWindow(Hwnd, nCmdShow)
                    #If Win16 Then
                        nDummy = SetActiveWindow(Hwnd)
                    #Else
                        nDummy = SetForegroundWindow(Hwnd)
                    #End If
                    
                    ofx_ActivateApp = True
                    Exit Do
        
                End If
            End If
    
            hWndLast = Hwnd
            Hwnd = GetWindow(hWndLast, GW_HWNDNEXT)
        Loop

    End If

    Exit Function
Err_ofx_ActivateApp:
    ofx_GenericError "ofx_ActivateApp()", Err
    Exit Function
End Function


'------------------------------------------------------------------------------
' Function: ofx_GetCurrentWnd
'
' Purpose:  Returns the handle to the window over which the
'           mouse currently sits.
'
' Returns:  The handle to the current window.
'------------------------------------------------------------------------------
Function ofx_GetCurrentWnd() As Long
    On Error Resume Next
    
    Dim ptMouse As POINTAPI

    '----- Figure out what window the mouse is on

    Call GetCursorPos(ptMouse)
    ofx_GetCurrentWnd = ofx_WindowFromPoint(ptMouse)
End Function




'------------------------------------------------------------------------------
' Function: ofx_GetSystemDirectory
'
' Purpose:  Get the Microsoft Windows System directory.
'
' Returns:  The Windows system directory with a trailing backslash.
'
' Example:  c:\windows\system\
'
' Notes:    The path ALWAYS includes the trailing backslash.
'           This function acts as a higher level call to the
'           Windows API function GetSystemDirectory().
'------------------------------------------------------------------------------
Function ofx_GetSystemDirectory() As String
    
    On Error Resume Next

    Const BUF_SIZE = 256
    Dim sBuffer As String
    Dim sSystemDir As String
    Dim cch As Integer

    sBuffer = String$(BUF_SIZE + 1, 0)
    cch = GetSystemDirectory(sBuffer, BUF_SIZE)
    sSystemDir = ofx_C2ABStr(sBuffer)
    
    If ("\" <> Right$(sSystemDir, 1)) Then
        sSystemDir = sSystemDir & "\"
    End If

    ofx_GetSystemDirectory = sSystemDir
    
End Function

'------------------------------------------------------------------------------
' Function: ofx_GetWindowsDirectory()
'
' Purpose:  Get the directory in which Microsoft Windows is installed.
'
' Returns:  The Windows directory with a trailing backslash.
'
' Example:  c:\windows\
'
' Notes:    The path ALWAYS includes the trailing backslash.
'           This function acts as a higher level call to the Windows
'           API function GetWindowsDirectory().
'------------------------------------------------------------------------------
Function ofx_GetWindowsDirectory() As String

    On Error Resume Next

    Dim sBuffer As String
    Dim sWinDir As String
    Dim cch As Integer
    Const BUF_SIZE = 255

    sBuffer = String$(BUF_SIZE + 1, 0)
    cch = GetWindowsDirectory(sBuffer, BUF_SIZE)
    sWinDir = ofx_C2ABStr(sBuffer)

    If ("\" <> Right$(sWinDir, 1)) Then
        sWinDir = sWinDir & "\"
    End If
    
    ofx_GetWindowsDirectory = sWinDir

End Function

'------------------------------------------------------------------------------
' Function: ofx_GetWindowState
'
' Purpose:  Returns the state of the requested window to the host
'           (i.e. maximized, minimized, or normal).
'
' Params:   hWnd    (I) Handle to the requested window.
'
' Returns:  OFX_MAXIMIZED - the selected window is maximized.
'           OFX_MINIMIZED - the selected window is minimized.
'           OFX_NORMAL    - the selected window is normal.
'
' Example:  The following code returns the window state for the
'           currently active form:
'
'               nWndState = ofx_GetWindowState(Screen.ActiveForm.hWnd)
'------------------------------------------------------------------------------
Function ofx_GetWindowState(Hwnd As Long) As Integer
    On Error GoTo Err_ofx_GetWindowState

    If IsZoomed(Hwnd) Then
        ofx_GetWindowState = OFX_MAXIMIZED
    ElseIf IsIconic(Hwnd) Then
        ofx_GetWindowState = OFX_MINIMIZED
    Else
        ofx_GetWindowState = OFX_NORMAL
    End If

Exit_ofx_GetWindowState:
    Exit Function

Err_ofx_GetWindowState:
    ofx_GenericError "ofx_GetWindowState", Err
    Resume Exit_ofx_GetWindowState
End Function


'------------------------------------------------------------------------------
' Function: ofx_WindowFromPoint
'
' Purpose:  Determine the uppermost window at the specified point on the screen.
'
' Params:   pt  (I) Point on screen
'
' Returns:  Handle to uppermost window at specified point.
'
' Note:     Virtualizes 16-bit vs. 32-bit Windows API's.
'------------------------------------------------------------------------------
Function ofx_WindowFromPoint(pt As POINTAPI) As Long
    #If Win16 Then
        ofx_WindowFromPoint = WindowFromPoint(ofx_PointAPIToLong&(pt))
    #Else
        ofx_WindowFromPoint = WindowFromPoint(pt.x, pt.y)
    #End If
End Function




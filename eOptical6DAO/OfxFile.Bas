Attribute VB_Name = "OfxFile"
'------------------------------------------------------------------------------
' Module:   Ofx - File
'
' Purpose:  File and path handling routines.
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

'----- Symbols for use with ofx_PathPart()

Public Const ofxFPDriveAndDir = 1
Public Const ofxFPName = 2
Public Const ofxFPExt = 3
Public Const ofxFPNameAndExt = 4

'----- C structure definition for use with file/dir dialogs.

Private Type OFX_GETFILENAMEINFO
#If Win32 Then
    hwndOwner As Long
    szFilter As String * 256
    nFilterIndex As Long
    szFile As String * 256
    szFileTitle As String * 256
    szInitialDir As String * 256
    szDlgTitle As String * 256
    Flags As Long
    nFileOffset As Integer
    nFileExtension As Integer
    szDefExt As String * 256
#Else
    hwndOwner As Integer
    szFilter As String * 255
    szCustomFilter As String * 255
    nFilterIndex As Long
    szFile As String * 255
    szFileTitle As String * 255
    szInitialDir As String * 255
    szDlgTitle As String * 255
    Flags As Long
    nFileOffset As Integer
    nFileExtension As Integer
    szDefExt As String * 255
#End If
End Type


'----- From the Start Developing... OFXUTL16.DLL and OFXUTL32.DLL utility DLL's

#If Win32 Then
Private Declare Function OfxDoFileNameDialog Lib "OFXUTL32.DLL" (gfni As OFX_GETFILENAMEINFO, ByVal fOpen As Integer, ByVal fBrowse As Integer) As Integer
#Else
Private Declare Function OfxDoFileNameDialog Lib "ofxutl16.dll" (gfni As OFX_GETFILENAMEINFO, ByVal fOpen As Integer, ByVal fBrowse As Integer) As Integer
#End If

'------------------------------------------------------------------------------
' Function: ofx_GetDirName
'
' Purpose:  Display a directory selection dialog box and return the
'           path to the selected directory.
'
' Params:   hWnd        (I) Window handle of parent form (or 0 if none)
'           sTitle      (I) Title to display on dialog box
'           sInitialDir (I) Initially selected directory (or "" for default)
'           sPath       (O) Full path to selected dir (valid if TRUE returned)
'
' Returns:  TRUE  = Directory path has been returned (user hit OK),
'           FALSE = Directory path not returned (user hit Cancel).
'
' See also: ofx_GetSaveFileName(), ofx_GetOpenFileName()
'------------------------------------------------------------------------------
Function ofx_GetDirName(hWnd As Long, sTitle As String, sInitialDir As String, sPath As String) As Integer

    On Error GoTo ofx_GetDirName_Err

    Dim bOk As Integer
    Dim ofn As OFX_GETFILENAMEINFO

    bOk = False

    '----- Setup for call to common dialog

    ofn.hwndOwner = hWnd
    ofn.szDlgTitle = sTitle & Chr$(0)
    ofn.szInitialDir = sInitialDir & Chr$(0)

    '----- Get dir from user

    If (Not OfxDoFileNameDialog(ofn, False, True)) Then GoTo ofx_GetDirName_Exit

    '----- Prepare results from common dialog

    sPath = ofx_PathPart(ofx_C2ABStr(ofn.szFile), ofxFPDriveAndDir)

    bOk = True

ofx_GetDirName_Exit:
    ofx_GetDirName = bOk
    Exit Function

ofx_GetDirName_Err:
    Call ofx_GenericError("ofx_GetDirName()", Err)
    Resume ofx_GetDirName_Exit

End Function


'------------------------------------------------------------------------------
' Function: ofx_PathPart
'
' Purpose:  Splits out specified portion of a (possibly) fully qualified path.
'
'               Example path: "c:\dir1\dir2\filename1.ext"
'
' Params:   sFullPath   (I) Path to file.
'           nPartNum    (I) Portion of path to return.
'                           One of the following (with result on example path):
'
'               ofxFPDriveAndDir    - "c:\dir1\dir2\"
'               ofxFPName           - "filename1"
'               ofxFPExt            - "ext"
'               ofxFPNameAndExt     - "filename1.ext"
'
' Returns:  Specified path part
'------------------------------------------------------------------------------
Function ofx_PathPart(sFullPath As String, nPartNum As Integer) As String
    On Error Resume Next

    Dim nSplit As Integer
    Dim sPart As String
    Dim nPeriod As Integer

    '----- Find last colon or backslash (end of path)
    
    For nSplit = Len(sFullPath) To 1 Step -1
        sPart = Mid$(sFullPath, nSplit, 1)
        If (sPart = ":" Or sPart = "\") Then Exit For
    Next nSplit

    If (nSplit < 1) Then
        nSplit = 1
    Else
        nSplit = nSplit + 1
    End If

    '----- Find period (filename vs. ext delimiter)
    
    nPeriod = InStr(nSplit, sFullPath, ".")

    '----- Get desired portion of path
    
    Select Case nPartNum
        Case ofxFPDriveAndDir
            If (nSplit = 1) Then
                ofx_PathPart = ""
            Else
                ofx_PathPart = Left$(sFullPath, nSplit - 1)
            End If
        Case ofxFPName
            ofx_PathPart = Mid$(sFullPath, nSplit, nPeriod - nSplit)
        Case ofxFPExt
            If (nPeriod = 0) Then
                ofx_PathPart = ""
            Else
                ofx_PathPart = Mid$(sFullPath, nPeriod + 1)
            End If
        Case ofxFPNameAndExt
            ofx_PathPart = Mid$(sFullPath, nSplit)
    End Select

End Function

'------------------------------------------------------------------------------
' Function: ofx_GetSaveFileName
'
' Purpose:  Get name of file to save from user.
'
' Params:   hWnd        (I) Window handle of parent form (or 0 if none)
'           sTitle      (I) Title to display in the open file dialog box.
'           sFilter     (I) File filter(s) to use in the dialog.
'           sFile       (O) Name and path of selected file (e.g. c:\dir\file.ext)
'           sFileTitle  (O) Name of the file w/o path (e.g. file.ext)
'
' Returns:  TRUE  = File name has been returned (user hit OK).
'           FALSE = File name not returned (user hit Cancel).
'
' See also: ofx_GetOpenFileName(), ofx_GetDirName()
'------------------------------------------------------------------------------
Function ofx_GetSaveFileName(hWnd As Long, sTitle As String, sFilter As String, sFile As String, sFileTitle As String, sDefExt As String, nFilterIndex As Integer) As Boolean
    On Error GoTo GetSaveFileName_Error
    
    Dim ofn As OFX_GETFILENAMEINFO
    
    ofn.hwndOwner = hWnd
    
    '----- Null terminate the strings for C
    
    ofn.szFilter = sFilter & Chr$(0)
    ofn.szDlgTitle = sTitle & Chr$(0)
    ofn.szInitialDir = String$(256, 0)
    ofn.szDefExt = sDefExt & Chr$(0)
    ofn.szFile = String$(256, 0)
    ofn.szFileTitle = String(256, 0)
    
    ofn.nFilterIndex = 1
    ofn.Flags = &H4000 Or &H800 Or &H4 Or &H1000
    
    '----- Get filename from user
    
    If (ofx_GetFileNameDlg(ofn, False, False)) Then
        sFile = LCase$(RTrim$(ofn.szFile))
        sFileTitle = LCase$(RTrim$(ofn.szFileTitle))
        ofx_GetSaveFileName = True
        nFilterIndex = ofn.nFilterIndex
    Else
        sFile = ""
        sFileTitle = ""
        ofx_GetSaveFileName = False
    End If

GetSaveFileName_Exit:
    Exit Function
GetSaveFileName_Error:
    ofx_GenericError "ofx_GetSaveFileName()", Err
    Resume GetSaveFileName_Exit
End Function

'------------------------------------------------------------------------------
' Function: ofx_ClearHelpTopic
'
' Purpose:  Clear out the help topic
'
' VB:       Does not apply.
'------------------------------------------------------------------------------
Private Function ofx_ClearHelpTopic() As Integer
    On Error Resume Next
    #If MSA Then
        ofx_ClearHelpTopic = SysCmd(SYSCMD_CLEARHELPTOPIC)
    #End If
End Function

'------------------------------------------------------------------------------
' Function: ofx_FileExists
'
' Purpose:  Check to see if the file passed exists.
'
' Params:   sFileName   (I) Name of the file for which to check.
'
' Returns:  TRUE if the file exists, else FALSE.
'------------------------------------------------------------------------------
Function ofx_FileExists(sFileName As String) As Boolean
    On Error Resume Next
    ofx_FileExists = (Len(sFileName) > 0 And Len(Dir$(sFileName)) > 0)
End Function
'------------------------------------------------------------------------------
' Function: ofx_GetFileNameDlg
'
' Purpose:  Prompts user for a filename.
'
' Notes:    Wraps the OFXUTL##.DLL common dialog function.  Intended for internal
'           use only.
'
' See also: ofx_GetOpenFileName(), ofx_GetSaveFileName(), ofx_GetDirName()
'------------------------------------------------------------------------------
Private Function ofx_GetFileNameDlg(fni As OFX_GETFILENAMEINFO, ByVal fOpen As Integer, ByVal fBrowse As Integer) As Integer

    Dim vntRetVal As Variant
    Dim nRet As Integer

    '----- NULL terminate strings for C
    
    fni.szFilter = RTrim$(fni.szFilter) & "||" & Chr$(0)
    fni.szFile = RTrim$(fni.szFile) & Chr$(0)
    fni.szFileTitle = RTrim$(fni.szFileTitle) & Chr$(0)
    fni.szInitialDir = RTrim$(fni.szInitialDir) & Chr$(0)
    fni.szDlgTitle = RTrim$(fni.szDlgTitle) & Chr$(0)
    fni.szDefExt = RTrim$(fni.szDefExt) & Chr$(0)

    vntRetVal = ofx_ClearHelpTopic()
   
    '----- Get filename from user
    
    nRet = OfxDoFileNameDialog(fni, fOpen, fBrowse)

    '----- Convert results from C strings to BASIC strings
    
    fni.szFilter = ofx_C2ABStr(fni.szFilter)
    fni.szFile = ofx_C2ABStr(fni.szFile)
    fni.szFileTitle = ofx_C2ABStr(fni.szFileTitle)
    fni.szInitialDir = ofx_C2ABStr(fni.szInitialDir)
    fni.szDlgTitle = ofx_C2ABStr(fni.szDlgTitle)
    fni.szDefExt = ofx_C2ABStr(fni.szDefExt)

    ofx_GetFileNameDlg = nRet

End Function
'------------------------------------------------------------------------------
' Procedure:    ofx_DeleteFilesInFolder
'
' Purpose:      Deletes all files matching the file spec.
'
' Params:       sFolder (I) The full path to be deleted
'               sSpec   (I) The FileSpec (*.*, *.txt, ...)
'
' Returns:      TRUE if successful, else FALSE
'------------------------------------------------------------------------------
Public Function ofx_DeleteFilesInFolder(sFolder As String, sSpec As String) As Boolean
    On Error GoTo ofx_DeleteFilesInFolder_Err                ' SDVB

    Dim bOk As Boolean
    Dim sFile As String
    Dim sPath As String
    
    bOk = False
    
    sPath = sFolder
    If (Right$(sPath, 1) = "\") Then sPath = Left$(sPath, Len(sPath) - 1)
        
    sFile = Dir$(sPath & "\" & sSpec)
    Do While (Len(sFile))
        SetAttr sPath & "\" & sFile, vbNormal
        Kill sPath & "\" & sFile
        sFile = Dir$()
    Loop
    
    bOk = True

ofx_DeleteFilesInFolder_Exit:                                ' SDVB
    On Error Resume Next                                     ' SDVB
    ofx_DeleteFilesInFolder = bOk                            ' SDVB
    Exit Function                                            ' SDVB
ofx_DeleteFilesInFolder_Err:                                 ' SDVB
    Call ofx_GenericError("ofx_DeleteFilesInFolder()", Err)  ' SDVB
    Resume ofx_DeleteFilesInFolder_Exit                      ' SDVB
End Function




'------------------------------------------------------------------------------
' Function: ofx_GetOpenFileName
'
' Purpose:  Display an "Open File" dialog box and return the
'           selected file in the sFile parameter passed.
'
' Params:   hWnd        (I) Window handle of parent form (or 0 if none)
'           sTitle      (I) Title to display in the open file dialog box.
'           sFilter     (I) File filter(s) to use in the dialog.
'           sFile       (O) Name and path of selected file (e.g. c:\dir\file.ext)
'           sFileTitle  (O) Name of the file w/o path (e.g. file.ext)
'
' Returns:  TRUE  = File name has been returned (user hit OK).
'           FALSE = File name not returned (user hit Cancel).
'
' See also: ofx_GetSaveFileName(), ofx_GetDirName()
'------------------------------------------------------------------------------
Function ofx_GetOpenFileName(hWnd As Long, sTitle As String, sFilter As String, sFile As String, sFileTitle As String, sDefExt As String, nFilterIndex As Integer) As Boolean
    On Error GoTo GetOpenFileName_Error
    
    Dim ofn As OFX_GETFILENAMEINFO
    
    ofn.hwndOwner = hWnd
    
    '----- NULL terminate strings for C
    
    ofn.szFilter = sFilter & Chr$(0)
    ofn.szDlgTitle = sTitle & Chr$(0)
    ofn.szInitialDir = String$(256, 0)
    ofn.szDefExt = sDefExt & Chr$(0)
    ofn.szFile = String$(256, 0)
    ofn.szFileTitle = String(256, 0)
    
    ofn.nFilterIndex = 1
    ofn.Flags = &H4000 Or &H800 Or &H4 Or &H1000
    
    '----- Get filename from user
    
    If (ofx_GetFileNameDlg(ofn, True, False)) Then
        sFile = LCase$(RTrim$(ofn.szFile))
        sFileTitle = LCase$(RTrim$(ofn.szFileTitle))
        ofx_GetOpenFileName = True
        nFilterIndex = ofn.nFilterIndex
    Else
        sFile = ""
        sFileTitle = ""
        ofx_GetOpenFileName = False
    End If

GetOpenFileName_Exit:
    Exit Function
GetOpenFileName_Error:
    Call ofx_GenericError("ofx_GetOpenFileName()", Err)
    Resume GetOpenFileName_Exit
End Function
'------------------------------------------------------------------------------
' Function: ofx_GetTempFileName
'
' Purpose:  Call the Windows API to get a temporary file name that is
'           unique and uses the requested prefix and extension.
'
' Params:   sPrefix     (I) File name prefix to use in creating temp file name.
'           sExtension  (I) File name extension to use in creating temp file name.
'                           If the extension is less than 3 characters (e.g. empty
'                           string), the extension will be defaulted to TMP.
'
' Returns:  The temporary file name.
'------------------------------------------------------------------------------
Function ofx_GetTempFileName(sPrefix As String, sExtension As String) As String

    On Error Resume Next

    If (Len(sExtension) > 3 Or Len(sExtension) = 0) Then sExtension = "TMP"
    
    Dim sBuf As String
    Dim sTemp As String, rc As Integer
    Dim sPath As String
    Dim nDummy As Long

    sBuf = String$(1024, 0)
    #If Win16 Then
        rc = GetTempFileName(0, sPrefix, 0, sBuf)
    #Else
        sPath = String$(1024, 0)
        nDummy = GetTempPath(1024, sPath)
        rc = GetTempFileName(ofx_C2ABStr(sPath), sPrefix, 0, sBuf)
    #End If
    
    sTemp = ofx_C2ABStr(sBuf)
    If (ofx_FileExists(sTemp)) Then Kill sTemp
    sTemp = Left$(sTemp, Len(sTemp) - 3) & sExtension
    
    '----- If the file exists (unlikely, although possible if the extension has
    '----- been changed) then call the function again.
    
    If (ofx_FileExists(sTemp)) Then
        sTemp = ofx_GetTempFileName(sPrefix, sExtension)
    End If

    ofx_GetTempFileName = sTemp

End Function
'------------------------------------------------------------------------------
' Function: ofx_GetTempPath
'
' Purpose:  Get path to Windows temporary directory (typically c:\temp).
'
' Returns:  Path to Windows temporary directory.
'------------------------------------------------------------------------------
Function ofx_GetTempPath() As String
    On Error Resume Next
    
    Dim sTempPath As String * 256
    Dim nLen As Long
    
    #If Win16 Then
        Dim nDummy As Integer
        Dim sFile As String * 256
        
        nDummy = GetTempFileName(0, "", 0, sFile)
        sFile = Left(sFile, InStr(sFile, Chr(0)) - 1)
        ofx_GetTempPath = ofx_PathPart(sFile, ofxFPDriveAndDir)
    #Else
        nLen = GetTempPath(256, sTempPath)
        ofx_GetTempPath = Left(sTempPath, nLen)
    #End If
End Function




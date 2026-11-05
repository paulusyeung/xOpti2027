Attribute VB_Name = "OfxPlatformCompatibility"
'------------------------------------------------------------------------------
' Module:   Ofx - Platform Compatibility
'
' Purpose:  These modules help to provide platform compatibility across MS Access,
'           Visual Basic 3.0, and Visual Basic 4.0 platforms.
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

#If VB3 Then
    Global Const vbModal% = 1
    Global Const vbModeless% = 0
    
    Global Const vbInformation% = 64
    Global Const vbYesNo% = 1
    Global Const vbYes% = 6
    Global Const vbNo% = 7
    Global Const vbCancel% = 2
    
    Global Const vbNull% = 1
    Global Const vbString% = 8
    Global Const vbLong% = 3
    Global Const vbInteger% = 2
    
    Global Const vbNullString$ = ""
    
    Global Const vbNormal% = 0
    
    Global Const vbCascade% = 0
    Global Const vbTileHorizontal% = 1
    Global Const vbTileVertical% = 2

    Private Declare Function OfxGetCtrlName Lib "ofxutl16.dll" (ByVal hWnd As Integer, ByVal lpName As String, ByVal nLen As Integer) As Integer
#End If


#If VB3 Then
'------------------------------------------------------------------------------
' Function: IsMissing
'
' Purpose:  Provide VB4 compatibility by providing a surrogate for the VBA
'           IsMissing() function.
'
' Params:   vParam  (I) Usually a parameter which is Optional in VB4.
'
' Note:     VB4 provides an IsMissing() function as part of its support for
'           optional procedure parameters.  It is used to determine whether an
'           optional parameter has been provided by the caller of a procedure.
'------------------------------------------------------------------------------
Function IsMissing(vParam As Variant) As Boolean
    IsMissing = False
End Function
#End If

#If Not MSA Then
#If VB3 Then
'------------------------------------------------------------------------------
' Function: Nz
'
' Purpose:  Provide compatibility with Access by providing a surrogate for the VBA
'           Nz() function.
'
' Params:   vValue  (I) The, possibly NULL, value
'
' Returns:  vValue not NULL                 vValue
'           vValue NULL                     0
'------------------------------------------------------------------------------
Function Nz(vValue As Variant) As Variant
    Dim vIfNull As Variant
#Else
'------------------------------------------------------------------------------
' Function: Nz
'
' Purpose:  Provide compatibility with Access by providing a surrogate for the VBA
'           Nz() function.
'
' Params:   vValue  (I) The, possibly NULL, value
'           vIfNull (I) Value to use if vValue is NULL (n/a for VB3)
'
' Returns:  vValue not NULL                 vValue
'           vValue NULL, vIfNull provided   vIfNull
'           vValue NULL, no vIfNull         ""
'------------------------------------------------------------------------------
Function Nz(vValue As Variant, Optional vIfNull As Variant) As Variant
#End If
    If (Not IsNull(vValue)) Then
        Nz = vValue
    ElseIf (Not IsMissing(vIfNull)) Then
        Nz = vIfNull
    Else
        Nz = ""
    End If
End Function
#End If

'------------------------------------------------------------------------------
' Function: ofx_CurrentUser
'
' Purpose:  Determine the name of the current user.
'
' Returns:  The current user name (Access), "" (VB).
'------------------------------------------------------------------------------
Function ofx_CurrentUser() As String
    #If MSA Then
        ofx_CurrentUser = CurrentUser()
    #Else
        ofx_CurrentUser = ""
    #End If
End Function


'------------------------------------------------------------------------------
' Function: ofx_GetFormName
'
' Purpose:  Get the name of the specified form.
'
' Params:   frm     (I) Form for which to get name
'
' Returns:  Name of form.
'
' Note:     In Access and VB4 you can access frm.Name directly.  In VB3, the
'           form Name property is not available at runtime.
'------------------------------------------------------------------------------
#If VB3 Then
Function ofx_GetFormName(frm As Form) As String
    On Error Resume Next
    
    Dim sName As String * 256
    Dim nLen As Integer
    
    nLen = OfxGetCtrlName(frm.hWnd, sName, 256)
    ofx_GetFormName = left(sName, nLen)
End Function
#Else
Function ofx_GetFormName(frm As Form) As String
    ofx_GetFormName = frm.Name
End Function
#End If

'------------------------------------------------------------------------------
' Function: ofx_GetCtrlName
'
' Purpose:  Get the name of the specified control.
'
' Params:   ctrl    (I) Control for which to get name
'
' Returns:  Name of control.
'
' Note:     In Access and VB4 you can access ctrl.Name directly.  In VB3, the
'           control Name property is not available at runtime.
'------------------------------------------------------------------------------
#If VB3 Then
Function ofx_GetCtrlName(ctrl As Control) As String
    On Error Resume Next
    
    Dim sName As String * 256
    Dim nLen As Integer
    
    nLen = OfxGetCtrlName(ctrl.hWnd, sName, 256)
    ofx_GetCtrlName = left(sName, nLen)
End Function
#Else
Function ofx_GetCtrlName(ctrl As Control) As String
    ofx_GetCtrlName = ctrl.Name
End Function
#End If




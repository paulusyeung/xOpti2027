Attribute VB_Name = "OfxMessageBoxes"
'------------------------------------------------------------------------------
' Module:   Ofx - Message Boxes
'
' Purpose:  Enhanced Message Box handlers taking EITHER an integer string ID or
'           a string and display a message box with the current ofxAppName as
'           the title.
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit


'------------------------------------------------------------------------------
' Sub:      ofx_DoMessageBox
'
' Purpose:  Displays the normal message box displaying the message provided as
'           either a string or a string ID.
'
' Params:   vMessage    (I) The message (if a string), the message ID (otherwise)
'           nTypeMask   (I) vbYesNo, vbInformation, etc. (you get the picture)
'
' Returns:  vbYes, vbNo, vbCancel, (...)
'
' See:      The VBA MsgBox() function for more information.
'------------------------------------------------------------------------------
Function ofx_DoMessageBox(vMessage As Variant, Optional vTypeMask As Variant) As Integer
    On Error Resume Next
    
    ofx_WaitCursor False
    Dim sMsg As String
    Dim nTypeMask As Integer
    If (IsMissing(vTypeMask)) Then
        nTypeMask = vbInformation
    Else
        nTypeMask = CInt(vTypeMask)
    End If
    
    If (vbLong = VarType(vMessage) Or vbInteger = VarType(vMessage)) Then
        sMsg = ofx_LoadString(CLng(vMessage))
    ElseIf (vbString = VarType(vMessage)) Then
        sMsg = CStr(Nz(vMessage))
    End If

    If (0 = Len(sMsg) And (vbInteger = VarType(vMessage) Or vbLong = VarType(vMessage))) Then
        sMsg = "Message #" & CStr(Nz(vMessage))
    End If

    ofx_DoMessageBox = MsgBox(sMsg, nTypeMask, ofxApp.sAppName)

End Function


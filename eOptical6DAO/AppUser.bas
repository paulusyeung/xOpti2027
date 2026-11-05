Attribute VB_Name = "AppUser"
'------------------------------
' Procedure:  SetUserProfile
' Purpose:    Setting permission as per User's Level
' Params:
' Returns:    N/A
' Added by:   WA on Nov 14, 1997
'------------------------------
Public Sub SetUserProfile(Optional srcUserID As Variant)
    On Error GoTo SetUserProfile_Err
    
    If Not IsMissing(srcUserID) Then
        pyUserID = srcUserID
    End If
    pyUserSLevel = GetUserSecurity(pyUserID)
    pyHasCostLevel = IsCostOK(pyUserSLevel)

SetUserProfile_Exit:                                ' SDVB autocode
    On Error Resume Next                            ' SDVB autocode
    Exit Sub                                        ' SDVB autocode
SetUserProfile_Err:                                 ' SDVB autocode
    Call ofx_GenericError("SetUserProfile()", Err)  ' SDVB autocode
    Resume SetUserProfile_Exit
End Sub

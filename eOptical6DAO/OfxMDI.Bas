Attribute VB_Name = "OfxMDI"
'------------------------------------------------------------------------
' Module:   Ofx - MDI
'
' Purpose:  Multiple Document Interface (MDI) utility functions.
'------------------------------------------------------------------------

Option Explicit

'------------------------------------------------------------------------
' Function: ofx_MDICenterChild
'
' Purpose:  Centers an MDI child window within its parent.
'
' Params:   frmParent   (I) Parent form
'           frmChild    (I/O) Denominator number.
'------------------------------------------------------------------------
Sub ofx_MDICenterChild(frmParent As Form, frmChild As Form)
    On Error Resume Next
    
    Dim cTop As Long
    Dim cLeft As Long
    
    '----- Center form vertically
    
    cTop = (frmParent.ScaleHeight - frmChild.Height) \ 2
    If (cTop < 0) Then
        frmChild.Top = 0
    Else
        frmChild.Top = cTop
    End If
    
    '----- Center form horizontally
    
    cLeft = (frmParent.ScaleWidth - frmChild.Width) \ 2
    If (cLeft < 0) Then
        frmChild.Left = 0
    Else
        frmChild.Left = cLeft
    End If
End Sub

'------------------------------------------------------------------------
' Function: ofx_MDIIsChild
'
' Purpose:  Determines if specified file is an MDI child window.
'
' Params:   frm (I) Form in question
'
' Returns:  TRUE if form is a child window, else FALSE.
'------------------------------------------------------------------------
Private Function ofx_MDIIsChild(frm As Form) As Boolean
    On Error Resume Next
    
    Dim bChild As Boolean
    
    bChild = False
            
    '----- This statement throws an error for MDI parent
    '----- forms since there is no MDIChild property for
    '----- such forms.  Since we initialized bChild to false,
    '----- we will correctly conclude that this form is
    '----- not an MDI child.
    
    bChild = frm.MDIChild

    ofx_MDIIsChild = bChild
End Function

'------------------------------------------------------------------------
' Function: ofx_MDIChildCount
'
' Purpose:  Count the number of open MDI child window forms in this app.
'
' Returns:  Number of open MDI child windows in this application.
'------------------------------------------------------------------------
Function ofx_MDIChildCount() As Integer

    On Error GoTo ofx_MDIChildCount_Err
    
    Dim nFrm As Integer
    Dim nChildCount As Integer
    
    nChildCount = 0
    
    For nFrm = 0 To Forms.Count - 1
        If (ofx_MDIIsChild(Forms(nFrm))) Then
            nChildCount = nChildCount + 1
        End If
    Next nFrm
    
ofx_MDIChildCount_Exit:
    ofx_MDIChildCount = nChildCount
    Exit Function
    
ofx_MDIChildCount_Err:
    ofx_GenericError "ofx_MDIChildCount()", Err
    Resume ofx_MDIChildCount_Exit
    
End Function






'------------------------------------------------------------------------
' Function: ofx_MDIIsParent
'
' Purpose:  Determine if specified form is an MDI parent form.
'
' Params:   frm (I) The form in question
'
' Returns:  TRUE if form is an MDI parent form, else FALSE.
'------------------------------------------------------------------------
Function ofx_MDIIsParent(frm As Form) As Boolean

    On Error GoTo ofx_MDIIsParent_Err
    
    Dim bParent As Boolean
    Dim sName As String * 255
    Dim nLen As Integer
    
    bParent = False
    
    nLen = GetClassName(frm.hWnd, sName, 255)
    bParent = (Left(sName, nLen) = "ThunderMDIForm")
    
ofx_MDIIsParent_Exit:
    On Error Resume Next
    ofx_MDIIsParent = bParent
    Exit Function
    
ofx_MDIIsParent_Err:
    Call ofx_GenericError("ofx_MDIIsParent()", Err)
    Resume ofx_MDIIsParent_Exit
    
End Function

#If Not VB3 Then
'------------------------------------------------------------------------
' Function: ofx_MDIParent
'
' Purpose:  Get the MDI parent form in this application.
'
' Params:   frm (O) The MDI parent form (if found)
'
' Returns:  TRUE if MDI parent form found, else FALSE.
'
' Notes:    VB applications can have at most 1 MDI parent form.
'           The form can only be detected if it is open.
'           Not available for VB3.  The basic algorithm is valid for VB3,
'           but VB3 does not allow a "Set" statement on a formal parameter.
'------------------------------------------------------------------------
Function ofx_MDIParent(frm As Form) As Boolean

    On Error GoTo ofx_MDIParent_Err
    
    Dim bOk As Boolean
    Dim nFrm As Integer
    
    bOk = False
    
    For nFrm = 0 To Forms.Count - 1
        If (ofx_MDIIsParent(Forms(nFrm))) Then
            Set frm = Forms(nFrm)
            bOk = True
            Exit For
        End If
    Next nFrm
    
ofx_MDIParent_Exit:
    On Error Resume Next
    ofx_MDIParent = bOk
    Exit Function
    
ofx_MDIParent_Err:
    ofx_GenericError "ofx_MDIParent()", Err
    Resume ofx_MDIParent_Exit
    
End Function
#End If




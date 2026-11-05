Attribute VB_Name = "OfxFormPositioning"
'------------------------------------------------------------------------------
' Module:   Ofx - Form Positioning
'
' Purpose:  This set of routines is used to position forms.  Two of these functions
'           are provided for placing forms in their last known positions.
'
'           ofx_RestoreFormPosition()
'           ofx_SaveFormPosition()
'
'           Call these functions at the OnOpen() and OnClose() events respectively
'           to open the form at its last position before it was closed, and to
'           save the form's current position so that it can be restored to the
'           same place next time.
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

'----- Constants used by this module.

Const REGKEY_SECTION$ = "Form Positions"       ' INI/registry section header.


#If Not MSA Then
'------------------------------------------------------------------------
' Function: ofx_GetFormWidth
'
' Purpose:  Determines width (in twips) of form's client area.
'
' Params:   frm - (I) The form whose width we want
'
' Returns:  Width of form's client area in twips.
'
' Note:     Useful when dynamically sizing form relative to control position
'           because form.Width includes non-client areas, but control coordinates
'           are relative to client area of form.
'------------------------------------------------------------------------
Function ofx_GetFormWidth(frm As Form) As Long
    On Error Resume Next
    
    Dim rcForm As RECT
    Dim rcClient As RECT
    
    Call GetWindowRect(frm.hWnd, rcForm)
    Call GetClientRect(frm.hWnd, rcClient)
    
    ofx_GetFormWidth = Screen.TwipsPerPixelY * (ofx_RectWidth(rcForm) - ofx_RectWidth(rcClient))

End Function
#End If

#If Not MSA Then
'------------------------------------------------------------------------
' Function: ofx_GetTitlebarHeight
'
' Purpose:  Determines height (in twips) of form's titlebar.
'
' Params:   frm - (I) The form whose titlebar height we want
'
' Returns:  Height of form's titlebar in twips.
'
' Note:     Useful when dynamically sizing form relative to control position
'           because form height includes titlebar, but control coordinates
'           are relative to client area of form (excludes titlebar).
'------------------------------------------------------------------------
Function ofx_GetTitlebarHeight(frm As Form) As Long
    On Error Resume Next
    
    Dim rcForm As RECT
    Dim rcClient As RECT
    
    Call GetWindowRect(frm.hWnd, rcForm)
    Call GetClientRect(frm.hWnd, rcClient)
    
    ofx_GetTitlebarHeight = Screen.TwipsPerPixelY * (ofx_RectHeight(rcForm) - ofx_RectHeight(rcClient))
End Function
#End If

#If Not MSA Then
'------------------------------------------------------------------------
' Function: ofx_CenterForm
'
' Purpose:  Centers a form on the screen.
'
' Params:   frm - (I/O) The form to center
'
' See also: ofx_MDICenterChild() in OFXMDI.BAS
'------------------------------------------------------------------------
Sub ofx_CenterForm(frm As Form)
    On Error Resume Next
    
    frm.left = (Screen.Width / 2) - (frm.Width / 2)
    frm.top = (Screen.Height / 2) - (frm.Height / 2)
End Sub
#End If

'------------------------------------------------------------------------------
' Function: ofx_MoveForm
'
' Purpose:  Move the form to the coordinates specified by RECT.
'
'           Note that if the form has the AutoResize property set to True
'           or the BorderStyle set to 3 (Dialog), then the size is ignored.
'
' Params:   frm     (I/O) Form to move.
'           rc      (I) Rectangle data structure with the coordiantes.
'
' Returns:  TRUE if form is moved, else FALSE.
'
' Note:     Form will not be moved if the width or height of rc is zero.
'
'           This function is not intended for use with MDI child forms. MDI
'           child forms are positioned relative to the parent while this function
'           works in the screen coordinate space.
'------------------------------------------------------------------------------
Private Function ofx_MoveForm(frm As Form, rc As RECT) As Boolean
    On Error GoTo ofx_MoveForm_Error

    Dim bMoved As Boolean
    Dim nWidth As Long
    Dim nHeight As Long
    Dim nFlags As Integer
    
    nWidth = ofx_RectWidth(rc)
    nHeight = ofx_RectHeight(rc)

    bMoved = False
    
    #If MSA Then
        nFlags = IIf(frm.AutoResize Or (frm.BorderStyle = 3), SWP_NOSIZE Or SWP_NOZORDER, SWP_NOZORDER)
    #Else
        nFlags = IIf(frm.BorderStyle = 3, SWP_NOSIZE Or SWP_NOZORDER, SWP_NOZORDER)
    #End If
   
    If (nWidth > 0 And nHeight > 0) Then
        Call SetWindowPos(CLng(frm.hWnd), 0, rc.nLeft, rc.nTop, nWidth, nHeight, nFlags)
        bMoved = True
    End If

ofx_MoveForm_Exit:
    ofx_MoveForm = bMoved
    Exit Function
ofx_MoveForm_Error:
    Call ofx_GenericError("ofx_MoveForm()", Err)
    Resume ofx_MoveForm_Exit
End Function

'------------------------------------------------------------------------------
' Function: ofx_RestoreFormPosition
'
' Purpose:  Restore a requested form's position to what it was when it
'           was last opened.  For this to work, the form must have
'           called the ofx_SaveFormPosition() function when it last
'           closed.
'
'           You will typically call this routine from the Form_Open()
'           event of the form passed.
'
'           Example:
'
'               Sub Form_Open (Cancel as Integer)
'                   call ofx_RestoreFormPostion(Me, TRUE)
'               End Sub
'
' Params:   frm     (I/O) The form whose last position you wish to restore.
'           bCenter (I) Center form if saved position not found?
'
' Returns:  TRUE if form repositioned, else FALSE.
'
' Note:     This function is not intended for use with MDI child forms. MDI
'           child forms are positioned relative to the parent while this function
'           works in the screen coordinate space.
'
' See Also: ofx_SaveFormPosition()
'------------------------------------------------------------------------------
Function ofx_RestoreFormPosition(frm As Form, bCenter As Boolean) As Boolean
    On Error GoTo ofx_RestoreFormPosition_Error

    Dim bMoved As Boolean
    Dim nMinMax As Long
    Dim rc As RECT
    
    bMoved = False
    
    '----- Read the form's last position string from the application's INI file.
    
    If (Not ofx_ProfileGetRect(REGKEY_SECTION, CStr(Nz(ofx_GetFormName(frm))) & "_RECT", rc)) Then
        nMinMax = ofx_ProfileGetInt(REGKEY_SECTION, CStr(Nz(ofx_GetFormName(frm))), 0)
    End If

    If (nMinMax) Then
        If (OFX_MAXIMIZED = nMinMax) Then
            If (ShowWindow(frm.hWnd, SW_SHOWMAXIMIZED)) Then
            End If
        ElseIf (OFX_MINIMIZED = nMinMax) Then
            If (ShowWindow(frm.hWnd, SW_SHOWMINIMIZED)) Then
            End If
        End If
    Else
        ' Move the form to the appropriate location based on the coordinates
        ' retrieved from the Registry and stored in the rect data structure.
        bMoved = ofx_MoveForm(frm, rc)
        #If Not MSA Then
            If (Not bMoved And bCenter) Then
                Call ofx_CenterForm(frm)
                bMoved = True
            End If
        #End If
    End If

ofx_RestoreFormPosition_Exit:
    ofx_RestoreFormPosition = bMoved
    Exit Function

ofx_RestoreFormPosition_Error:
    Call ofx_GenericError("ofx_RestoreFormPosition()", Err)
    Resume ofx_RestoreFormPosition_Exit
End Function

'------------------------------------------------------------------------------
' Sub:      ofx_SaveFormPosition
'
' Purpose:  Save the RECT (ofx_WriteProfileRect) to the registry.
'
' Example:  Sub Form_Close()
'               ofx_SaveFormPostion Me
'           End Sub
'
' Parms:    frm     (I) Form whose position we are going to save.
'
' Note:     This function is not intended for use with MDI child forms. MDI
'           child forms are positioned relative to the parent while this function
'           works in the screen coordinate space.
'
' See Also: ofx_RestoreFormPosition()
'------------------------------------------------------------------------------
Sub ofx_SaveFormPosition(frm As Form)
    On Error GoTo ofx_SaveFormPosition_Error

    Dim nState As Integer
    Dim sFormName As String
    Dim nDummy As Integer
    
    nState = ofx_GetWindowState(CLng(frm.hWnd))
    sFormName = CStr(Nz(ofx_GetFormName(frm)))
    
    If (OFX_MAXIMIZED = nState) Then
        nDummy = ofx_ProfileWriteInt(REGKEY_SECTION, sFormName, OFX_MAXIMIZED)
    ElseIf (OFX_MINIMIZED = nState) Then
        nDummy = ofx_ProfileWriteInt(REGKEY_SECTION, sFormName, OFX_MINIMIZED)
    Else
        Dim rc As RECT                    ' Rectangle structure.
        Dim ptUpperLeft As POINTAPI       ' client coordinate of upper left
        Dim ptLowerRight As POINTAPI      ' client coordinate of lower right

        Call GetWindowRect(frm.hWnd, rc)  ' Get the form's current size.
                
        ptUpperLeft.x = rc.nLeft
        ptUpperLeft.y = rc.nTop
        ptLowerRight.x = rc.nRight
        ptLowerRight.y = rc.nBottom
        
        #If MSA Then
            '----- Adjust for the type of window
        
            If (frm.PopUp) Then
                'nothing, this form works correctly
            ElseIf (frm.BorderStyle <> 0) Then
                Call ScreenToClient(Application.hWndAccessApp, ptUpperLeft)
                Call ScreenToClient(Application.hWndAccessApp, ptLowerRight)
            End If
        #End If
        
        '----- Generate the coordinate token string to write out to the INI file.
        
        rc.nLeft = ptUpperLeft.x
        rc.nTop = ptUpperLeft.y
        rc.nRight = ptLowerRight.x
        rc.nBottom = ptLowerRight.y
        
        '----- Write out the name of the form plus "RECT" with the RECT
        
        nDummy = ofx_ProfileWriteRect(REGKEY_SECTION, sFormName & "_RECT", rc)
    End If

ofx_SaveFormPosition_Exit:
    Exit Sub
ofx_SaveFormPosition_Error:
    Call ofx_GenericError("ofx_SaveFormPosition()", Err)
    Resume ofx_SaveFormPosition_Exit
End Sub


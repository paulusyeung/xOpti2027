Attribute VB_Name = "OfxFormsReports"
'------------------------------------------------------------------------------
' Module:   Ofx - Forms & Reports
'
' Purpose:  Form and Report manipulation routines.  These include routines for
'           opening modal forms, closing specific forms and reports, checking to
'           see if a form or report is loaded, and turning the hourglass on and
'           off.
'
'           Note that reports do not apply to Visual Basic.
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

'------------------------------------------------------------------------------
' Function: ofx_IsFormLoadedByName
'
' Purpose:  Determine if form (specified by name) is currently loaded.
'
' Params:   sFormName   (I) Name of form to check
'
' Returns:  TRUE if form is currently loaded, else FALSE.
'
' See also: ofx_IsFormLoaded(), ofx_CloseForm(), ofx_DoModal().
'------------------------------------------------------------------------------
#If Not MSA Then
Function ofx_IsFormLoadedByName(sFormName As String) As Boolean
    On Error GoTo ofx_IsFormLoadedByName_Exit
    
    Dim bFound As Boolean
    Dim ii As Integer
    
    bFound = False

    '----- Determine if form is in collection of loaded forms

    For ii = 0 To Forms.Count - 1
        bFound = (ofx_GetFormName(Forms(ii)) = sFormName)
        If (bFound) Then Exit For
    Next ii
    
ofx_IsFormLoadedByName_Exit:
    ofx_IsFormLoadedByName = bFound
    Exit Function
    
ofx_IsFormLoadedByName_Err:
    Call ofx_GenericError("ofx_IsFormLoadedByName()", Err)
    Resume ofx_IsFormLoadedByName_Exit
End Function
#End If

'------------------------------------------------------------------------------
' Function: ofx_CloseForm
'
' Purpose:  Close the requested form.
'
#If MSA Then
' Params:   sFormName   (I) Name of form to close
#Else
' Params:   frm         (I/O) Form to close
#End If
'
' See Also: ofx_DoModal(), ofx_IsFormLoaded(), ofx_IsFormLoadedByName()
'------------------------------------------------------------------------------
#If MSA Then
Sub ofx_CloseForm(sFormName As String)
    On Error Resume Next
    
    '----- If the requested form is in memory, close it.

    If ofx_IsFormLoaded(sFormName) Then
        DoCmd.Close A_FORM, sFormName
        Set sFormName = Nothing     ' added by Paulus Yeung
    End If
End Sub

#Else
Sub ofx_CloseForm(frm As Form)
    On Error Resume Next
    
    '----- If the requested form is in memory, close it.
    
    If (ofx_IsFormLoaded(frm)) Then
        Unload frm
        Set frm = Nothing     ' added by Paulus Yeung
    End If
End Sub
#End If

#If MSA Then
'------------------------------------------------------------------------------
' Function: ofx_CloseReport
'
' Purpose:  Close the requested report.
'
' Params:   sReportName - (I) Name of the report to close.
'
' VB:       Not applicable.
'
' See Also: ofx_CloseForm()
'------------------------------------------------------------------------------
Sub ofx_CloseReport(sReportName As String)

    On Error GoTo Err_ofx_CloseReport

    ' If the requested report is in memory, close it.
    If ofx_IsReportLoaded(sReportName) Then
        DoCmd.Close A_REPORT, sReportName
    End If
 
Exit_ofx_CloseReport:
    Exit Sub

Err_ofx_CloseReport:
    ofx_GenericError "ofx_CloseReport()", Err
    Resume Exit_ofx_CloseReport

End Sub
#End If

'------------------------------------------------------------------------------
' Function: ofx_DoModal
'
' Purpose:  Opens the requested dialog box form (with the specified WHERE
'           clause in Access applications).  If the function returns True, the
'           form is still loaded in memory and values can be retrieved from the
'           dialog box form's various controls.
'
'           If the function returns True (form is still in memory), the form
'           must explicitly be closed after retrieving values from the form.
'
#If MSA Then
' Params:   sFormName   (I) Name of the modal form to open.
'           sWhere      (I) The WHERE clause to apply to the form.
'           nDataMode   (I) A_EDIT, A_ADD, A_READONLY
'           sOpenArgs   (I) The open args for the form
#Else
' Params:   frm         (I/O) Form to open modally.
#End If
'
' Returns:  True = Form is still in memory.
'           False = Form is not in memory (i.e. user clicked on Cancel button).
'
' Note:     Normally the modal dialog is implemented by including "Me.Hide" in
'           the Click event of the OK button and "Unload Me" in the Click event
'           of the Cancel button.  Thus, clicking Cancel unloads the form and
'           code in ofx_DoModal() can detect that the form is no longer loaded
'           while clicking OK just hides the form (looking to the user as if
'           the form has been closed) leaving it in memory so that data can be
'           retrieved from it.
'
' See Also: ofx_CloseForm(), ofx_IsFormLoaded(), ofx_IsFormLoadedByName().
'------------------------------------------------------------------------------
#If MSA Then
Function ofx_DoModal(sFormName As String, Optional vDataMode As Variant, Optional vWhere As Variant, Optional vOpenArgs As Variant) As Integer

    On Error GoTo Err_ofx_DoModal
    
    Dim nDataMode As Integer
    Dim sWhere As String
    Dim sOpenArgs As String
    
    If (Not (IsMissing(vDataMode))) Then
        nDataMode = CInt(vDataMode)
    Else
        nDataMode = acEdit
    End If
    
    If (Not (IsMissing(vWhere))) Then sWhere = CStr(vWhere)
    
    If (Not (IsMissing(vOpenArgs))) Then sOpenArgs = CStr(vOpenArgs)
    
    ' Open the form as a modal dialog box.
    DoCmd.OpenForm sFormName, A_NORMAL, , sWhere, nDataMode, A_DIALOG, sOpenArgs

    ' Tell the caller whether the form is still in memory or not.
    ofx_DoModal = ofx_IsFormLoaded(sFormName)
    
Exit_ofx_DoModal:
    Exit Function
    
Err_ofx_DoModal:
    Call ofx_GenericError("ofx_DoModal()", Err)
    Resume Exit_ofx_DoModal

End Function
#Else

Function ofx_DoModal(frm As Form) As Integer

    On Error GoTo ofx_DoModal_Err
    
    Dim bLoaded As Integer
    
    bLoaded = False
    
    '----- Show the form
    
    frm.Show vbModal
    
    '----- Determine if form is still loaded.  If so, user clicked
    '----- OK, else Cancel
    
    bLoaded = ofx_IsFormLoaded(frm)
    
ofx_DoModal_Exit:
    ofx_DoModal = bLoaded
    Exit Function
    
ofx_DoModal_Err:
    Call ofx_GenericError("ofx_DoModal()", Err)
    Resume ofx_DoModal_Exit
End Function
#End If



'------------------------------------------------------------------------------
' Function: ofx_IsFormLoaded
'
' Purpose:  Determines if the requested form is loaded in
'           memory or not.
'
#If MSA Then
' Params:   sFormName   (I) Name of the form to check.
#Else
' Params:   frm         (I) Form to check.
#End If
'
' Returns:  True - form is in memory.
'           False - form is not in memory.
'
' See Also: ofx_IsReportLoaded()
'------------------------------------------------------------------------------
#If MSA Then
Function ofx_IsFormLoaded(sFormName As String) As Boolean
    On Error Resume Next
    ofx_IsFormLoaded = (0 <> SysCmd(acSysCmdGetObjectState, acForm, sFormName))
End Function
#Else
Function ofx_IsFormLoaded(frm As Form) As Boolean
    On Error GoTo ofx_IsFormLoaded_Exit
    
    Dim bFound As Boolean
    Dim ii As Integer
    
    bFound = False

    '----- Determine if form is in collection of loaded forms

    For ii = 0 To Forms.Count - 1
        bFound = (Forms(ii) Is frm)
        If (bFound) Then Exit For
    Next ii
    
ofx_IsFormLoaded_Exit:
    ofx_IsFormLoaded = bFound
    Exit Function
    
ofx_IsFormLoaded_Err:
    Call ofx_GenericError("ofx_IsFormLoaded()", Err)
    Resume ofx_IsFormLoaded_Exit
End Function
#End If

#If MSA Then
'------------------------------------------------------------------------------
' Function: ofx_IsReportLoaded
'
' Purpose:  Determines whether a specified report is loaded in
'           memory or not.
'
' Params:   sReportName - name of the report to search for.
'
' Returns:  True = report is in memory.
'           False = report is not in memory.
'
' See Also: ofx_IsFormLoaded()
'------------------------------------------------------------------------------
Function ofx_IsReportLoaded(sReportName As String) As Integer
    
    On Error Resume Next

    ofx_IsReportLoaded = IIf(SysCmd(SYSCMD_GETOBJECTSTATE, A_REPORT, sReportName) = OBJSTATE_OPEN, True, False)

End Function
#End If



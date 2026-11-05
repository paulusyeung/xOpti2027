Attribute VB_Name = "AppValidation"
Option Explicit



' Is the Target an existing record?
' Caller supplies:
'  strTable  = Table Name
'  strField  = Field Name
'  strTarget = Field Value to find
' Returns:
'  True  = Target is found
'  False = Target is not found
Public Function IsFound(strTable As String, _
                        strField As String, _
                        strTarget As String, _
                        Optional intShowWarningMsg As Variant) As Boolean
    Dim myDB As Database, myRS As Recordset
    Dim MyCriteria, strDummy, strMessage As String
    MyCriteria = strField & " = '" & strTarget & "'"        ' Set the search criteria.
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set myRS = myDB.OpenRecordset(strTable, dbOpenDynaset, dbReadOnly)      ' Open table read only
    myRS.FindFirst MyCriteria       ' Find the record
    If Not myRS.NoMatch Then        ' Check if record is found.
        IsFound = True
    Else
        IsFound = False
        If intShowWarningMsg = vbYes Then
            strMessage = "Invalid " & strField
            strDummy = MsgBox(strMessage, vbExclamation)
        End If
    End If
    myRS.Close                      ' Close table.
    myDB.Close                      ' Close database.
    '
    ' End Lookup
    '

End Function

' The caller has AutoSelect ON
Public Sub Masked_Key_Press(mskEdit As MaskEdBox, KeyAscii As Integer)
    
    Dim mask_cents_pos, mask_dollars, tlen As Integer
    Dim tempo As String
    
    ' Calculate the location of the decimal point in the mask:
    mask_cents_pos = InStr(mskEdit.Mask, ".")
    mask_dollars = mask_cents_pos - 1
    
    ' Check for period keypress:
    If KeyAscii = 46 And mskEdit.SelStart < 6 Then
        tlen = mskEdit.SelStart + 1     ' Store corrent location
        mskEdit.SelStart = 0
        mskEdit.SelLength = tlen        ' Highlight upto the current
        tempo = mskEdit.SelText         '  position & save selected text
        mskEdit.SelLength = mask_dollars
        mskEdit.SelText = ""            ' Clear to the left of decimal
        mskEdit.SelStart = mask_cents_pos - tlen
        mskEdit.SelLength = tlen        ' Re-position caret
        mskEdit.SelText = tempo         ' Paste copied text
        mskEdit.SelStart = mask_cents_pos   ' Reset caret
    End If
    
End Sub

Public Function WithinRange(Target As Object, Max As Variant, MIN As Variant, ShowMsg As Boolean) As Boolean
    Dim dblTarget, dblMax, dblMin As Double
    dblTarget = ofx_CDbl(Target.Text)
    dblMax = ofx_CDbl(Max)
    dblMin = ofx_CDbl(MIN)
    
    If dblTarget <= dblMax And dblTarget >= dblMin Then
        WithinRange = True
    Else
        WithinRange = False
        If ShowMsg = True Then
            ' 2008.12.15 paulus: some range are no longer applicable, like the Sphere & Cylinder
            Dim intResponse
            intResponse = MsgBox(Mid(Target.Name, 4) & Chr$(13) & _
                   "Out of Range." & Chr$(13) & _
                   "Allows " & MIN & " to " & Max & " only." & Chr$(13) & Chr$(13) & _
                   "Are you sure it's correct?", vbYesNo)
            If intResponse = vbYes Then
                WithinRange = True
            End If
        End If
    End If
    
End Function

Public Function myIsDecimal(Target As Object, intDecimal As Integer, ShowMsg As Boolean) As Boolean
    
    Dim strTarget As String
    Dim intLength, intDecimalPosition As Integer
    
    strTarget = ofx_CStr(Target.Text)
    intLength = Len(strTarget)
    intDecimalPosition = InStr(strTarget, ".")
    
    If intDecimalPosition = 0 Then
        myIsDecimal = True
    Else
        If (intLength - intDecimalPosition) <= intDecimal Then
            myIsDecimal = True
        Else
            myIsDecimal = False
            If ShowMsg = True Then
                MsgBox Mid(Target.Name, 4) & Chr$(13) & _
                       "Allows " & intDecimal & " decimal place only."
            End If
        End If
    End If

End Function

Public Function IsPositive(Target As Object, ShowMsg As Boolean) As Boolean
    Dim dblTarget As Double
    
    dblTarget = ofx_CDbl(Target.Text)
    If dblTarget >= 0 Then
        IsPositive = True
    Else
        IsPositive = False
        If ShowMsg = True Then
            MsgBox Mid(Target.Name, 4) & Chr$(13) & _
                   "Allows positive value only."
        End If
    End If
End Function

Public Function IsA_LT_B(objA As Object, objB As Object, ShowMsg As Boolean) As Boolean
    Dim dblA, dblB As Double
    
    dblA = ofx_CDbl(objA.Text)
    dblB = ofx_CDbl(objB.Text)
    
    If dblA < dblB Then
        IsA_LT_B = True
    Else
        IsA_LT_B = False
        If ShowMsg = True Then
            MsgBox Mid(objA.Name, 4) & " should less than " & _
                   Mid(objB.Name, 4) & "."
        End If
    End If
    
End Function

Public Function IsA_LE_BMinusC(objA As Object, objB As Object, _
                                   objC As Object, ShowMsg As Boolean) As Boolean
    Dim dblA, dblB, dblC As Double
    
    dblA = ofx_CDbl(objA)
    dblB = ofx_CDbl(objB)
    dblC = ofx_CDbl(objC)
    
    If dblA <= (dblB - dblC) Then
        IsA_LE_BMinusC = True
    Else
        IsA_LE_BMinusC = False
        If ShowMsg Then
            MsgBox Mid(objA.Name, 4) & " should less than" & Chr$(13) & _
                   Mid(objB.Name, 4) & " - " & Mid(objC.Name, 4)
        End If
    End If
    
End Function

Public Function IsTableEmpty(myTarget As Recordset) As Boolean
    If myTarget.EOF And myTarget.BOF Then
        IsTableEmpty = True
    Else
        IsTableEmpty = False
    End If
End Function



' Return:
'  True  - Security Table contains more than one record
'  False - Security Table contains one or no record
Public Function IsSecurityEnabled() As Boolean
    Dim myDB As Database
    Dim myRS As Recordset
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set myRS = myDB.OpenRecordset("Security", dbOpenDynaset, dbReadOnly)    ' Open table read only
    
    myRS.MoveLast
    If myRS.RecordCount > 1 Then
        IsSecurityEnabled = True
    Else
        IsSecurityEnabled = False
    End If
    
    myRS.Close
    myDB.Close
End Function


Public Function IsSecurityPassed(myUserName As String, myPassword As String) As Boolean
    Dim myDB As Database
    Dim myRS As Recordset
    Dim strSQL As String
    Dim RetVal As Boolean
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set myRS = myDB.OpenRecordset("Staff", dbOpenDynaset, dbReadOnly)    ' Open table read only
    strSQL = "StaffCode = '" & myUserName & "'"
    
    myRS.FindFirst strSQL
    If myRS.NoMatch Then
        RetVal = False
    Else
        If ofx_CStr(myPassword) = ofx_CStr(myRS!Password) Then
            RetVal = True
        Else
            RetVal = False
        End If
    End If
    
    myRS.Close
    myDB.Close
    IsSecurityPassed = RetVal
End Function

' This function always returns a value of '9999'
' If there's not such staff code in the Staff Table,
' this function would create one.
'
' The Deault User is '9999';
' named as 'Reserved User' with Security Level 1.
' Applicable when there's only one security level.
Public Function GetDefaultUser() As String
    Dim myDB As Database
    Dim myRS As Recordset
    Dim strSQL, strDefaultUser As String
    Dim RetVal As Integer
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set myRS = myDB.OpenRecordset("Staff", dbOpenDynaset)
    strDefaultUser = "9999"
    strSQL = "StaffCode = '" & strDefaultUser & "'"
    
    With myRS
        .FindFirst strSQL
        If .NoMatch Then
            .AddNew
            !StaffCode = strDefaultUser
            !StaffFullName = "Reserved User"
            !SecurityLevel = 1
            !DateHired = #1/1/1997#
            !Sin = "999999999"
            .Update
        End If
    End With
    
    myRS.Close
    myDB.Close
    GetDefaultUser = strDefaultUser
End Function

' Usage    : Check if the Grid is still in Edit mode or not
' Arguments: iPrompt could be vbYes or vbNo
Public Function IsGridEditing(oTargetGrid As TDBGrid, iPrompt As Integer) As Boolean
    Dim strDummy, strMessage As String
    
    If oTargetGrid.DataChanged Then
        IsGridEditing = True
        If iPrompt = vbYes Then
            strMessage = "Editing Not Finished"
            strDummy = MsgBox(strMessage, vbExclamation)
        End If
    Else
        IsGridEditing = False
    End If
End Function


' Usage    : Check if the Grid is still in Edit mode or not
' Arguments: iPrompt could be vbYes or vbNo
Public Function IsGridEmpty(oTargetGrid As TDBGrid, iPrompt As Integer) As Boolean
    Dim strDummy, strMessage As String
    
    If IsNull(oTargetGrid.Bookmark) And _
        oTargetGrid.row = 0 Then
        IsGridEmpty = True
        If iPrompt = vbYes Then
            strMessage = "There's No Entry"
            strDummy = MsgBox(strMessage, vbExclamation)
        End If
    Else
        IsGridEmpty = False
    End If
End Function

Public Function GetUserSecurity(myUserName) As Integer

    On Error GoTo GetUserSecurity_Err

    Dim myDB As Database
    Dim myRS As Recordset
    Dim strSQL As String
    Dim RetVal As Integer
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set myRS = myDB.OpenRecordset("Staff", dbOpenDynaset, dbReadOnly)    ' Open table read only
    strSQL = "StaffCode = '" & myUserName & "'"
    
    myRS.FindFirst strSQL
    If myRS.NoMatch Then
        RetVal = 0
    Else
        RetVal = myRS!SecurityLevel
    End If
    
    myRS.Close
    myDB.Close
    GetUserSecurity = RetVal

GetUserSecurity_Exit:                                ' SDVB autocode
    On Error Resume Next                             ' SDVB autocode
    Exit Function                                    ' SDVB autocode
GetUserSecurity_Err:                                 ' SDVB autocode
    Call ofx_GenericError("GetUserSecurity()", Err)  ' SDVB autocode
    Resume GetUserSecurity_Exit

End Function

Public Function IsCostOK(mySLevel As Integer) As Boolean

    On Error GoTo IsCostOK_Err

    Dim myDB As Database
    Dim myRS As Recordset
    Dim strSQL As String
    Dim RetVal As Boolean
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set myRS = myDB.OpenRecordset("Security", dbOpenDynaset, dbReadOnly)    ' Open table read only
    strSQL = "Level = " & mySLevel
    
    With myRS
        .FindFirst strSQL
        If .NoMatch Then
            RetVal = False
        Else
            RetVal = !Cost
        End If
        .Close
    End With
    myDB.Close
    IsCostOK = RetVal

IsCostOK_Exit:                                ' SDVB autocode
    On Error Resume Next                      ' SDVB autocode
    Exit Function                             ' SDVB autocode
IsCostOK_Err:                                 ' SDVB autocode
    Call ofx_GenericError("IsCostOK()", Err)  ' SDVB autocode
    Resume IsCostOK_Exit

End Function

Public Function IsNothingEnter(objTarget As Control, _
                Optional intShowWarningMsg As Variant, _
                    Optional objName As Variant) As Boolean

    On Error GoTo IsNothingEnter_Err

    If IsNull(objTarget) Then
        IsNothingEnter = True
    Else
        If Trim(objTarget) = "" Then
            IsNothingEnter = True
            If intShowWarningMsg = vbYes Then
                ofx_DoMessageBox "null " & objName & " not allowed!!"
            End If
        Else
            IsNothingEnter = False
        End If
    End If

IsNothingEnter_Exit:                                ' SDVB autocode
    On Error Resume Next                            ' SDVB autocode
    Exit Function                                   ' SDVB autocode
IsNothingEnter_Err:                                 ' SDVB autocode
    Call ofx_GenericError("IsNothingEnter()", Err)  ' SDVB autocode
    Resume IsNothingEnter_Exit

End Function



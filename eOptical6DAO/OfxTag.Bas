Attribute VB_Name = "OfxTagStrings"
'------------------------------------------------------------------------------
' Module:   Ofx - Tag Strings
'
' Purpose:  This set of routines is used for inserting, retrieving, and
'           deleting named parameters (tags) from a text string (tag string).
'           Tag strings are perfect for storing multiple pieces of information in a
'           single buffer.  There are two particularly valuable uses for tag string:
'
'           1)  Storing several pieces of information in a form or control's "Tag" property.
'           2)  Passing information to a form as it loads by passing the tag string
'               as the OpenArgs parameter.
'
' Example:  An example of a tag string is as follows:
'
'               "left=30;top=40;right=165;height=90;"
'
'           Each element in a tag string is named.  For each name is a value.
'           In the above example, the "left" tag has a value of 30.  If the
'           following code was executed:
'
'               sTagStr = "left=30;top=40;right=165;height=90;"
'               sValue = ofx_GetTagString(sTagStr, "left")
'
'           sValue would be equal to 30.  Likewise, if the following code
'           was executed:
'
'               ofx_UpdateTagString sTagStr, "top", "5"          ' Set a tag value.
'               ofx_InsertTagString sTagStr, "name", "frm_Form1"  ' Add a tag value.
'
'           The string sTagStr would be equal to:
'
'               "left=30;top=5;right=165;height=90;name=frm_Form1";
'
' History:  Original    Courtesy of Ken Getz
'           1995        Modified for Start Developing for Access
'           July 1996   Fixes for Start Developing for Visual Basic
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

Const TAG_SEPARATOR$ = ";"
Const TAG_EQUALS$ = "="

'------------------------------------------------------------------------------
' Sub:      ofx_DeleteTag
'
' Purpose:  Delete the requested tag from the tags string.  If
'           the tag does not exist, do nothing.
'
' Params:   sTags   (I/O) Tags string from which to remove the requested tag.
'           sName   (I) Name of tag to delete.
'------------------------------------------------------------------------------
Public Sub ofx_DeleteTag(sTags As String, sName As String)

    On Error GoTo Err_DeleteTag

    Dim nTagStart As Integer
    Dim nTagEnd As Integer
    Dim nLen As Integer
    Dim sTemp As String

    '----- If the tag is not in the string, exit the routine and do nothing.
    
    If (Not FindTagInString(sTags, sName, nTagStart, nTagEnd)) Then
        GoTo Exit_DeleteTag
    End If

    '----- Always make sure that there is a separator at the end of the string.
    
    If (right$(sTags, 1) <> TAG_SEPARATOR) Then
        sTags = sTags & TAG_SEPARATOR
    End If

    nLen = Len(sTags)                   ' Retain the length of the tags string.

    If nTagStart = 1 Then               ' If the tag is at the beginning...
        If nTagEnd = nLen Then          ' If it is the only tag...
            sTemp = ""                  ' empty the string.
        Else                            ' Otherwise, get the rest of the string.
            If nTagEnd + 1 < nLen Then
                nTagEnd = nTagEnd + 1
            End If
            sTemp = Mid$(sTags, nTagEnd + 1, nLen - nTagEnd)
        End If
    Else
        sTemp = left$(sTags, nTagStart - 1) ' Get the first part of the string.

        ' If there is more on the end of the string, get that too.
        If nTagEnd + 1 < nLen Then
            sTemp = sTemp & right$(sTags, nLen - (nTagEnd + 1))
        End If
    End If

    sTags = sTemp               ' Return the new string back to the host.

Exit_DeleteTag:
    Exit Sub

Err_DeleteTag:
    ofx_GenericError "DeleteTag()", Err
    Resume Exit_DeleteTag
End Sub

'------------------------------------------------------------------------------
' Function: FindTagInString
'
' Purpose:  Finds the requested tag name AND value in the tags string passed and
'           returns its start and end points.
'
'           For example:
'
'               sTags = "left=1;top=2;right=3;bottom=4"
'               bRetVal = FindTagInString(sTags, "left", nStart, nEnd)
'               sValue = Mid$(sTags, nStart, nEnd)
'
'           The sValue variable would be equal to "left=1".
'
' Params:   sTags   (I) The tagged string to retrieve the item from.
'           sName   (I) Name of the tag to retrieve the start and end for.
'           nStart  (O) Will contain the start of the tag on exit.
'           nEnd    (O) Will contain the end of the tag on exit.
'
' Returns:  TRUE  - found the tag and set the positions.
'           FALSE - the tag does not exist in the string.
'
' Note:     7/8/96  Fix to correctly use entire tag name for match
'------------------------------------------------------------------------------
Private Function FindTagInString(sTags As String, sName As String, nStart As Integer, nEnd As Integer) As Boolean

    On Error GoTo Err_FindTagInString

    Dim bFound As Boolean
    Dim nTagStart As Integer            ' Used to find the start of the tag.
    Dim nTagEnd As Integer              ' Used to find the end of the tag.

    bFound = False              ' Initialize the return value.
    
    '----- Find the beginning of the tag.  If its not at the beginning of the tag
    '----- string, make sure that it starts with the TAG_SEPARATOR.  This ensures
    '----- that if we are looking for the "top" tag, for example, we won't find the
    '----- "stop" tag instead!
    
    nTagStart = InStr(sTags, sName)
    If (nTagStart = 0) Then GoTo Exit_FindTagInString
    If (nTagStart > 1) Then
        nTagStart = InStr(sTags, TAG_SEPARATOR & sName) + 1
        If (nTagStart <= 1) Then GoTo Exit_FindTagInString
    End If

    '----- Find the end of the tag by looking for the next tag separator (;).  If there
    '----- is no tag separator, assume it is the last tag item and set the end position
    '----- to the length of the string.  If a separator was found, do not return it to
    '----- the host, but decrement the end position by one to not include it.
    
    nTagEnd = InStr(nTagStart, sTags, TAG_SEPARATOR)
    If (nTagEnd = 0) Then
        nTagEnd = Len(sTags)
    Else
        nTagEnd = nTagEnd - 1
    End If

    '----- Set both the start and end positions in the parameters passed
    
    nStart = nTagStart
    nEnd = nTagEnd
    
    bFound = True

Exit_FindTagInString:
    FindTagInString = bFound
    Exit Function

Err_FindTagInString:
    Call ofx_GenericError("FindTagInString()", Err)
    Resume Exit_FindTagInString

End Function

'------------------------------------------------------------------------------
' Function: ofx_GetTagString
'
' Purpose:  Get the requested tag value from the tag string (see the
'           general/declarations section for a detailed explanation
'           of what a tagged string is).
'
' Example:  sValue = ofx_GetTagString("left=1;top=10", "top")
'
'           sValue will be equal to "10".
'
' Params:   sTags   (I) Tagged string.
'           sName   (I) Name of the tag to retrieve the value for.
'
' Returns:  The value of the tag requested.
'
' Note:     7/8/96  Fix to correctly use entire tag name for match
'------------------------------------------------------------------------------
Function ofx_GetTagString(sTags As String, ByVal sName As String) As String

    On Error GoTo Err_ofx_GetTagString

    Dim nTagStart As Integer        ' Start of the tag item.
    Dim nTagEnd As Integer          ' End of the tag item.
    Dim nValStart As Integer        ' Start of the value in the tag.
    Dim nValEnd As Integer          ' End of the value in the tag.
    Dim sValue As String            ' Tag item value extracted.
    
    sValue = ""

    If (right$(sName, 1) <> "=") Then sName = sName & "="

    '----- Find the tag and its value.  If the requested tag does not
    '----- exist, return an empty string to the host.
    
    If (Not (FindTagInString(sTags, sName, nTagStart, nTagEnd))) Then
        GoTo Exit_ofx_GetTagString
    End If
    
    '----- Find the beginning of the value for the requested tag.
    
    nValStart = InStr(nTagStart, sTags, TAG_EQUALS)
    If nValStart = 0 Then
        GoTo Exit_ofx_GetTagString
    ElseIf nValStart = nTagEnd Then
        GoTo Exit_ofx_GetTagString
    Else
        nValStart = nValStart + 1   ' Go to the next character (past the =).
    End If

    '----- Make sure that there is a value to retrieve.  This is done by checking if
    '----- the next character in the string is either a tag separator (;) or nothing.
    
    If nValStart = nTagEnd + 1 Then
        GoTo Exit_ofx_GetTagString
    ElseIf Mid$(sTags, nValStart, 1) = TAG_SEPARATOR Then
        GoTo Exit_ofx_GetTagString
    End If

    '----- Extract the tag value and return to the host.
    
    sValue = Mid$(sTags, nValStart, nTagEnd - nValStart + 1)

Exit_ofx_GetTagString:
    ofx_GetTagString = sValue
    Exit Function

Err_ofx_GetTagString:
    Call ofx_GenericError("ofx_GetTagString()", Err)
    Resume Exit_ofx_GetTagString
End Function

'------------------------------------------------------------------------------
' Sub:      ofx_InsertTagString
'
' Purpose:  Insert a tag into a tagged string.  If the tag already exists,
'           modify the value of the existing tag.
'
' Params:   sTags   (I/O) Tag string
'           sName   (I) Name of tag to insert
'           sValue  (I) Value of tag to insert
'
' Note:     7/8/96  Fix to preserve tag order when tag already exists
'------------------------------------------------------------------------------
Sub ofx_InsertTagString(sTags As String, sName As String, sValue As String)

    On Error GoTo Err_ofx_InsertTagString

    Dim nTagStart As Integer
    Dim nTagEnd As Integer

    If (FindTagInString(sTags, sName, nTagStart, nTagEnd)) Then
        sTags = left(sTags, nTagStart - 1) & sName & TAG_EQUALS & sValue & Mid(sTags, nTagEnd + 1)
    Else
        '----- If there is not a final tags separator at the end of the string, add it.
        
        If (Len(sTags) > 0) Then
            If (Mid$(sTags, Len(sTags), 1) <> TAG_SEPARATOR) Then
                sTags = sTags & TAG_SEPARATOR
            End If
        End If

        '----- Append the new tag and its value at the end of the string.
        
        sTags = sTags & sName & TAG_EQUALS & sValue & TAG_SEPARATOR
    End If

Exit_ofx_InsertTagString:
    Exit Sub

Err_ofx_InsertTagString:
    ofx_GenericError "ofx_InsertTagString()", Err
    Resume 'Exit_ofx_InsertTagString

End Sub

'------------------------------------------------------------------------------
' Sub:      ofx_UpdateTagString
'
' Purpose:  Update the value of an existing tag in the tag string.
'
' Example:  sTags = "left=5;top=5;right=10;bottom=10;"
'           Call ofx_UpdateTagString(sTags, "top", "0")
'
'           sTags will be equal to "left=5;top=0;right=10;bottom=10".
'
' Params:   sTags   (I/O) Tag string
'           sName   (I) Name of tag to update
'           sValue  (I) Value of tag to update
'
' Note:     7/8/96  Fix to preserve tag order when tag already exists
'------------------------------------------------------------------------------
Sub ofx_UpdateTagString(sTags As String, sName As String, sValue As String)

    On Error GoTo Err_ofx_UpdateTagString

    '----- Delete the current tag from the string and append it as a new tag.
    
    Call ofx_InsertTagString(sTags, sName, sValue)

Exit_ofx_UpdateTagString:
    Exit Sub

Err_ofx_UpdateTagString:
    Call ofx_GenericError("ofx_UpdateTagString()", Err)
    Resume Exit_ofx_UpdateTagString

End Sub



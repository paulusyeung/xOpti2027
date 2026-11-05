Attribute VB_Name = "OfxStrings"
'------------------------------------------------------------------------
' Module:   Ofx - Strings
'
' Purpose:  String manipulation functions.
'------------------------------------------------------------------------

Option Compare Text
Option Explicit


'------------------------------------------------------------------------
' Function: ofx_MoneyToWords
'
' Purpose:  Converts a currency amount to a string of English words.
'           Typically to use for check printing.
'
' Params:   cMoney  (I) The dollar amount
'
' Returns:  The English string.
'
' Note:     Valid up to $999,999,999.00.
'------------------------------------------------------------------------
Function ofx_MoneyToWords(cMoney As Currency) As String
    Dim lRemaining As Long
    Dim sTempString As String
    Dim nNextNumber As Integer
    Dim sReturnValue As String
    Dim nDigits As Integer
    Dim sSet As String
    
    On Error GoTo ErrMoneyToWords

    lRemaining = Int(cMoney)   'Drops the cents!
    
    '----- Handle cents

    sReturnValue = Format$(100 * (cMoney - lRemaining), "00") & "/100"
    If (lRemaining > 0) Then sReturnValue = "and " & sReturnValue
    
    '----- Prepend zeros so that we can always process full sets of 3 digits
    
    sTempString = "000" & lRemaining

    nDigits = 0
    
    '----- Process sets of 3 digits from least to most significant

    Do While (IsNumeric(sTempString) And Val(sTempString) > 0)
        nNextNumber = Val(Right$(sTempString, 2))
        sTempString = Left(sTempString, Len(sTempString) - 2)
        
        '----- Handle tens and units digits this set
        
        sSet = ""
        If (nNextNumber > 9 And nNextNumber < 20) Then
            sSet = Choose(nNextNumber - 9, "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen") & " " & sSet
        ElseIf (nNextNumber > 0) Then
            sSet = Choose(Val(Right(Str(nNextNumber), 1)), "one ", "two ", "three ", "four ", "five ", "six ", "seven ", "eight ", "nine ") & sSet
        End If
        If (nNextNumber >= 20) Then
            sSet = Choose(Val(Left$(Str$(nNextNumber), 2)), "error", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety") & " " & sSet
        End If
        
        '----- Handle hundreds digit in this set
        
        nNextNumber = Val(Right$(sTempString, 1))
        sTempString = Left(sTempString, Len(sTempString) - 1)
        If (nNextNumber >= 1) Then
            sSet = "hundred " & sSet
            sSet = Choose(nNextNumber, "one", "two", "three", "four", "five", "six", "seven", "eight", "nine") & " " & sSet
        End If

        '----- Handle set suffix, no suffix if this set was "000"
        
        If (sSet <> "") Then
            sReturnValue = sSet & Choose(nDigits / 3, "thousand ", "million ") & sReturnValue
        End If
        nDigits = nDigits + 3
    Loop

    ofx_MoneyToWords = sReturnValue
    

    Exit Function
ErrMoneyToWords:
    If Err <> 0 Then
        Call ofx_GenericError("ofx_MoneyToWords", Err)
    End If
    Exit Function

End Function


'------------------------------------------------------------------------
' Function: ofx_CopyStringArray
'
' Purpose:  Copy all elements of sSrc to sDst
'
' Params:   sSrc    (I) Source array of strings, may be empty
'           sDst    (O) Destination array of strings,
'                       original contents will be clobbered
'
' Returns:  Number of elements copied.
'
' Note:     If source array is empty, destination string will not be modified
'           and no elements will be copied.
'------------------------------------------------------------------------
Public Function ofx_CopyStringArray(sSrc() As String, sDst() As String) As Integer

    On Error GoTo ofx_CopyStringArray_Err                ' Autocode

    Dim nCount As Integer
    Dim ii As Integer
    Dim nFirst As Integer
    Dim nLast As Integer

    nCount = 0
    
    If (ofx_IsDimensioned(sSrc())) Then
        nFirst = LBound(sSrc)
        nLast = UBound(sSrc)
               
        ReDim sDst(nFirst To nLast)
        
        For ii = nFirst To nLast
            sDst(ii) = sSrc(ii)
            nCount = nCount + 1
        Next ii
    End If
    
ofx_CopyStringArray_Exit:                                ' Autocode
    On Error Resume Next                                 ' Autocode
    ofx_CopyStringArray = nCount                         ' Autocode
    Exit Function                                        ' Autocode
ofx_CopyStringArray_Err:                                 ' Autocode
    Call ofx_GenericError("ofx_CopyStringArray()", Err)  ' Autocode
    Resume ofx_CopyStringArray_Exit                      ' Autocode

End Function
'------------------------------------------------------------------------
' Function: ofx_AppendStringArray
'
' Purpose:  Append all elements of sSrc to sDst
'
' Params:   sSrc    (I) Source array of strings, may be empty
'           sDst    (I/O) Destination array of strings, may be empty
'
' Returns:  TRUE if successful, else FALSE
'------------------------------------------------------------------------
Public Function ofx_AppendStringArray(sSrc() As String, sDst() As String) As Boolean

    On Error GoTo ofx_AppendStringArray_Err                ' Autocode

    Dim bOk As Boolean
    Dim ii As Integer
    Dim nCount As Integer
    Dim nSrcFirst As Integer
    Dim nDstFirst As Integer

    bOk = False
    
    If (ofx_IsDimensioned(sSrc())) Then
        If (Not ofx_IsDimensioned(sDst())) Then
            bOk = (ofx_CopyStringArray(sSrc(), sDst()) > 0)
        Else
            nSrcFirst = LBound(sSrc)
            nDstFirst = UBound(sDst) + 1
            nCount = UBound(sSrc) - LBound(sSrc) + 1
            
            ReDim Preserve sDst(LBound(sDst) To UBound(sDst) + nCount)
               
            For ii = 0 To nCount
                sDst(nDstFirst + ii) = sSrc(nSrcFirst + ii)
            Next ii
        End If
    End If
    
    bOk = True

ofx_AppendStringArray_Exit:                                ' Autocode
    On Error Resume Next                                   ' Autocode
    ofx_AppendStringArray = bOk                            ' Autocode
    Exit Function                                          ' Autocode
ofx_AppendStringArray_Err:                                 ' Autocode
    Call ofx_GenericError("ofx_AppendStringArray()", Err)  ' Autocode
    Resume ofx_AppendStringArray_Exit                      ' Autocode

End Function





'------------------------------------------------------------------------
' Function: ofx_CRLF
'
' Purpose:  Return a Carriage Return <CR>, Line Feed <LF>.
'           the standard ASCII line termination characters.
'
' Returns:  <CR><LF> string
'------------------------------------------------------------------------
Public Function ofx_CRLF() As String
    On Error Resume Next
    ofx_CRLF = Chr(13) & Chr(10)
End Function


'------------------------------------------------------------------------
' Function: ofx_IndentLines
'
' Purpose:  Indent all line(s) the specified # of characters.
'           If sLines has more than 1 line, then each line is indented.
'
' Params:   sLines          (I/O) String containing 1 or more lines where
'                               multiple lines are separated by <CR><LF> chars.
'           nIndentation    (I) # of character to indent each line
'
' Returns:  The indented string
'------------------------------------------------------------------------
Public Function ofx_IndentLines(sLines As String, nIndentation As Integer) As String
    On Error Resume Next
    ofx_IndentLines = Space(nIndentation) & ofx_ReplaceString(sLines, ofx_CRLF(), ofx_CRLF() & Space(nIndentation))
End Function


'------------------------------------------------------------------------
' Function: ofx_InStringArray
'
' Purpose:  Determine if specified string is one of the strings in
'           then specified string array
'
' Params:   sList   (I) String array to be searched
'           sItem   (I) String for which to search
'           nPos    (O) Index of item in array if found, otherwise undefined
'
' Returns:  TRUE if string found in array, else FALSE
'------------------------------------------------------------------------
Function ofx_InStringArray(sList() As String, sItem As String, nPos As Integer) As Boolean

    On Error GoTo ofx_InStringArray_Err                          ' SDVB test

    Dim bFound As Boolean
    Dim ii As Integer
    
    bFound = False
    
    If (Not ofx_IsDimensioned(sList())) Then GoTo ofx_InStringArray_Exit
    
    For ii = LBound(sList) To UBound(sList)
        If (sList(ii) = sItem) Then
            bFound = True
            nPos = ii
            Exit For
        End If
    Next ii
    
ofx_InStringArray_Exit:                                          ' SDVB test
    On Error Resume Next                                         ' SDVB test
    ofx_InStringArray = bFound
    Exit Function                                                ' SDVB test
ofx_InStringArray_Err:                                           ' SDVB test
    Call ofx_GenericError("ofx_InStringArray()", Err)            ' SDVB test
    Resume ofx_InStringArray_Exit                                ' SDVB test

End Function


'------------------------------------------------------------------------
' Function: ofx_JustCenter
'
' Purpose:  Center string in a string of specified length.
'
' Params:   sStr    (I) String to center
'           nLen    (I) Length of resulting string
'
' Returns:  String of specified length with sStr centered in it.
'------------------------------------------------------------------------
Public Function ofx_JustCenter(sStr As String, nLen As Integer) As String
    On Error Resume Next
    If (Len(sStr) > nLen) Then
        ofx_JustCenter = sStr
    Else
        ofx_JustCenter = Right(Space((nLen - Len(sStr)) / 2) & sStr & Space((nLen - Len(sStr)) / 2), nLen)
    End If
End Function

'------------------------------------------------------------------------
' Function: ofx_JustLeft
'
' Purpose:  Left justify string in a string of specified length.
'
' Params:   sStr    (I) String to left justify
'           nLen    (I) Length of resulting string
'
' Returns:  String of specified length with sStr left justified in it.
'------------------------------------------------------------------------
Public Function ofx_JustLeft(sStr As String, nLen As Integer) As String
    On Error Resume Next
    ofx_JustLeft = Left(sStr & Space(nLen), nLen)
End Function


'------------------------------------------------------------------------
' Function: ofx_JustRight
'
' Purpose:  Right justify string in a string of specified length.
'
' Params:   sStr    (I) String to right justify
'           nLen    (I) Length of resulting string
'
' Returns:  String of specified length with sStr right justified in it.
'------------------------------------------------------------------------
Public Function ofx_JustRight(sStr As String, nLen As Integer) As String
    On Error Resume Next
    ofx_JustRight = Right(Space(nLen) & sStr, nLen)
End Function


'------------------------------------------------------------------------
' Sub:      ofx_AppendString
'
' Purpose:  Redimension the string array and append string to string array.
'           If string array is empty, dimension it for 1 string.
'
' Params:   sStrs   (O) String array to which to append
'           sStr    (I) String to append
'------------------------------------------------------------------------
Public Sub ofx_AppendString(sStrs() As String, sStr As String)
    On Error Resume Next
    
    If (Not ofx_IsDimensioned(sStrs())) Then
        ReDim sStrs(0 To 0)
    Else
        ReDim Preserve sStrs(LBound(sStrs) To UBound(sStrs) + 1)
    End If
    
    sStrs(UBound(sStrs)) = sStr
End Sub

'------------------------------------------------------------------------
' Sub:      ofx_SortStringArray
'
' Purpose:  Sorts the array of strings into ascending order.
'
' Params:   sStrings    (I/O) Array of strings to sort.
'------------------------------------------------------------------------
Sub ofx_SortStringArray(sStrings() As String)

    On Error GoTo ofx_SortStringArray_Err

    Dim nFirst As Integer
    Dim nLast As Integer
    Dim nFirstUnsorted As Integer
    Dim nBeingSorted As Integer
    Dim nLowestIndex As Integer

    If (Not ofx_IsDimensioned(sStrings())) Then GoTo ofx_SortStringArray_Exit
    
    nFirst = LBound(sStrings)
    nLast = UBound(sStrings)

    For nFirstUnsorted = nFirst To nLast - 1
        nLowestIndex = nFirstUnsorted
        For nBeingSorted = nFirstUnsorted + 1 To nLast
            If (sStrings(nBeingSorted) < sStrings(nLowestIndex)) Then
                nLowestIndex = nBeingSorted
            End If
        Next nBeingSorted
        Call ofx_Swap(sStrings(nFirstUnsorted), sStrings(nLowestIndex))
    Next nFirstUnsorted

ofx_SortStringArray_Exit:
    Exit Sub

ofx_SortStringArray_Err:
    Call ofx_GenericError("ofx_SortStringArray", Err)
    Resume ofx_SortStringArray_Exit

End Sub

'------------------------------------------------------------------------
' Function: ofx_SafeStringUBound
'
' Purpose:  Same as VBA UBound() except that it works
'           even when the array in question is dynamic
'           and has not been redimensioned to have any elements.
'           Under those circumstances, UBound() throws an Err = 9.
'
' Params:   s   (I) Array of strings
'
' Returns:  UBound(s) when UBound(s) is valid, 0 otherwise
'------------------------------------------------------------------------
Function ofx_SafeStringUBound(s() As String) As Integer
    Dim n As Integer
    
    On Error Resume Next
    n = 0
    n = UBound(s)
    
    ofx_SafeStringUBound = n
    
End Function

'------------------------------------------------------------------------
' Function: ofx_IsDimensioned()
'
' Purpose:  Determines whether a string array has been dimensioned.
'           Normally one uses UBound() to determine the upper bound
'           of an array, but if the array has not been dimensioned
'           UBound() (and LBound()) throws an Err = 9.
'
' Params:   s   (I) Array of strings
'
' Returns:  TRUE if s has been dimensioned, FALSE otherwise
'------------------------------------------------------------------------
Function ofx_IsDimensioned(s() As String) As Boolean
    Dim bDimmed As Boolean
    Dim n As Integer
    
    On Error GoTo ofx_IsDimensioned_Exit
    
    bDimmed = False
    n = UBound(s)
    
    bDimmed = True
    
ofx_IsDimensioned_Exit:
    ofx_IsDimensioned = bDimmed
    
End Function



'------------------------------------------------------------------------
' Function: ofx_LeadingCaps()
'
' Purpose:  Converts a string to be all lower case except those
'           characters following one of the delimiter character.
'
' Params:   sStr    (I) String to be converted.
'           sDelims (I) String of delimiter characters.
'
' Returns:  The modified string.
'------------------------------------------------------------------------
Function ofx_LeadingCaps(sStr As String, sDelims As String) As String
    On Error GoTo ofx_LeadingCaps_Error

    Dim sChar As String
    Dim ii As Integer
    Dim sPhrase As String
    Dim nPos As Integer
    
    '----- Make string all lower case except 1st char upper

    sPhrase = LCase$(sStr)
    sPhrase = UCase$(Left$(sPhrase, 1)) & Mid$(sPhrase, 2)

    For ii = 1 To Len(sDelims)
        sChar = Mid$(sDelims, ii, 1)
        
        nPos = 0
        Do While True
            nPos = ofx_CInt(InStr(nPos + 1, sPhrase, sChar))
            If (nPos = 0) Then
                Exit Do
            Else
                sPhrase = Left$(sPhrase, nPos) & UCase$(Mid$(sPhrase, nPos + 1, 1)) & Mid$(sPhrase, nPos + 2)
            End If
        Loop
    Next ii

ofx_LeadingCaps_Exit:
    ofx_LeadingCaps = sPhrase
    Exit Function

ofx_LeadingCaps_Error:
    Call ofx_GenericError("ofx_LeadingCaps()", Err)
    Resume ofx_LeadingCaps_Exit:

End Function


'------------------------------------------------------------------------
' Function: ofx_FindNthSubstr()
'
' Purpose:  Finds the Nth occurrence of pattern in string.
'
' Params:   sString     (I) String in which to search.
'           sPattern    (I) Pattern for which to search.
'           nN          (I) Instance of interest.
'
' Returns:  The starting position of the string if found, else 0.
'------------------------------------------------------------------------
Function ofx_FindNthSubstr(sString As String, sPattern As String, nN As Integer) As Integer

    On Error GoTo ofx_FindNthSubstr_Err

    Dim nStart As Integer
    Dim nCount As Integer

    nStart = 0
    nCount = 0

    Do While (nCount < nN)
        nStart = InStr(nStart + 1, sString, sPattern)
        If (nStart = 0) Then
            Exit Do
        End If
        nCount = nCount + 1
    Loop

ofx_FindNthSubstr_Exit:
    ofx_FindNthSubstr = nStart
    Exit Function

ofx_FindNthSubstr_Err:
    MsgBox Error
    GoTo ofx_FindNthSubstr_Exit

End Function


'------------------------------------------------------------------------
' Function: ofx_InStrBack()
'
' Purpose:  Finds last occurrence of pattern in string starting at
'           nStart or later in sStr.  Similar to the InStr() function
'           except that the LAST string is found rather than the first.
'
' Params:   nStart      (I) Starting position in string from which to search.
'           sStr        (I) String in which to search.
'           sPattern    (I) Pattern for which to search.
'
' Returns:  The position of the last occurrence of one string within another.
'           If sPattern is empty, nStart is returned.  If sStr is empty, or sPattern
'           is not found, or nStart is > len(sStr) then 0 is returned.
'------------------------------------------------------------------------
Function ofx_InStrBack(nStart As Integer, sStr As String, sPattern As String) As Integer
    
    On Error GoTo ofx_InStrBack_Err

    Dim nPos As Integer
    Dim nLen As Integer
    Dim bFound As Integer

    '----- If searched-string is empty, return 0 (not found)

    If (sStr = "") Then
        nPos = 0
        GoTo ofx_InStrBack_Exit
    End If

    '----- Determine starting position

    nLen = Len(sPattern)

    If (nStart <= 0 Or nStart > Len(sStr)) Then
        nPos = Len(sStr)
    Else
        nPos = nStart
    End If

    '----- If pattern is empty, return starting position

    If (sPattern = "") Then GoTo ofx_InStrBack_Exit
    
    '----- If pattern won't fit then rtn pattern not found

    nPos = nPos - nLen + 1
    If (nPos <= 0) Then
        nPos = 0
        GoTo ofx_InStrBack_Exit
    End If

    '----- Find the pattern by searching backwards from starting point

    bFound = False
    While (nPos > 0 And Not bFound)
        If (Mid(sStr, nPos, nLen) = sPattern) Then
            bFound = True
        Else
            nPos = nPos - 1
        End If
    Wend

ofx_InStrBack_Exit:
    ofx_InStrBack = nPos
    Exit Function

ofx_InStrBack_Err:
    Call ofx_GenericError("ofx_InStrBack()", Err)
    Resume ofx_InStrBack_Exit

End Function


'------------------------------------------------------------------------
' Function: ofx_FirstDelimPos()
'
' Purpose:  Finds the first occurrence of a delimiter from a set
'           of delimiters in a string.  For example, both of the
'           following calls return 7 because both space and
'           open parenthesis are delimiters:
'
'           ofx_FirstDelimPos("MyFunc (", " (")
'           ofx_FirstDelimPos("MyFunc(", " (")
'
' Params:   sStr    (I) String in which to search for first delimiter.
'           sDelims (I) String of delimiter characters.
'
' Returns:  The position of the first occurrence in sStr of a character in
'           sDelims.
'------------------------------------------------------------------------
Function ofx_FirstDelimPos(sStr As String, sDelims As String) As Integer
    On Error Resume Next
    
    Dim ii As Integer
    Dim nDelimPos As Integer
    Dim nFirstDelimPos As Integer
    
    nFirstDelimPos = 32000
    
    For ii = 1 To Len(sDelims)
        nDelimPos = InStr(sStr, Mid(sDelims, ii, 1))
        If (nDelimPos > 0 And nDelimPos < nFirstDelimPos) Then
            nFirstDelimPos = nDelimPos
        End If
    Next ii
    
    If (nFirstDelimPos = 32000) Then
        nFirstDelimPos = 0
    End If
    
    ofx_FirstDelimPos = nFirstDelimPos
End Function

'------------------------------------------------------------------------
' Function: ofx_C2ABStr
'
' Purpose:  Convert a C string (NULL terminated) to a BASIC string.
'
' Params:   sCString  (I) C string to convert.
'
' Returns:  The converted string.
'------------------------------------------------------------------------
Function ofx_C2ABStr(sCString As String) As String
    
    On Error Resume Next
         
    Dim nPos As Integer

    nPos = InStr(sCString, Chr$(0))                 ' Find the Null terminator.

    If nPos Then                                    ' If Null terminator exists...
        ofx_C2ABStr = Left$(sCString, nPos - 1)     ' extract the string.
    Else                                            ' Otherwise...
        ofx_C2ABStr = sCString                      ' return the string "as is".
    End If

End Function













#If Not VB3 Then
'------------------------------------------------------------------------
' Function: ofx_vsprintf
'
' Purpose:  Similar to the C sprintf() function.
'
' Params:   vFmt    (I) Variant: either a string ID or literal string with
'                       the formatting codes
'           arg     (I) Variant(s):  A variable length list of arguments
'
' Returns:  The formatted string.
'
' Notes:    The only formatting codes recognized are %i and %s.
'           %i will cover ALL numbers, %s ALL strings.
'------------------------------------------------------------------------
Function ofx_vsprintf(ByVal vFmt As Variant, ParamArray arg()) As String
    On Error GoTo ofx_sprintf_error
    
    Dim sBuf As String, sBufOut As String
    
    #If MSA Then
        If ((VarType(vFmt) = vbLong) Or (VarType(vFmt) = vbInteger)) Then
            sBuf = ofx_LoadString(CLng(vFmt))
        Else
            sBuf = CStr(vFmt)
        End If
    #Else
        sBuf = CStr(vFmt)
    #End If
    
    Dim nLen As Integer
    Dim nChar As Integer
    
    nLen = Len(sBuf)
    Dim sChar As String
    Dim nArg As Integer
    
    For nChar = 1 To nLen
        sChar = Mid$(sBuf, nChar, 1)
        If (sChar = "%") Then
            
            ' get the next char
            nChar = nChar + 1
            sChar = Mid$(sBuf, nChar, 1)
            
            Select Case sChar
                Case "i"        'integers expanded to longs
                    sBufOut = sBufOut & CStr(CLng(Nz(arg(nArg))))
                    nArg = nArg + 1
                Case "s"
                    sBufOut = sBufOut & CStr(Nz(arg(nArg)))
                    nArg = nArg + 1
                Case "%"
                    sBufOut = sBufOut & "%"
            End Select
            
        Else
            sBufOut = sBufOut & sChar
        End If
    Next
    
    ofx_vsprintf = sBufOut
    
ofx_sprintf_exit:
    Exit Function
ofx_sprintf_error:
    MsgBox Err.Description
    Resume ofx_sprintf_exit
End Function
#End If

'------------------------------------------------------------------------
' Sub:      ofx_ToLower
'
' Purpose:  Convert the character code passed to a lower case character.
'
' Params:   KeyAscii    (I/O) ASCII character code to convert to lower case.
'------------------------------------------------------------------------
Sub ofx_ToLower(KeyAscii As Integer)

    On Error Resume Next
    KeyAscii = Asc(LCase$(Chr$(KeyAscii)))

End Sub


'------------------------------------------------------------------------
' Sub:      ofx_ToUpper
'
' Purpose:  Convert the character code passed to upper case.
'
' Params:   KeyAscii    (I/O) ASCII character code to convert to upper case.
'------------------------------------------------------------------------
Sub ofx_ToUpper(KeyAscii As Integer)

    On Error Resume Next
    KeyAscii = Asc(UCase$(Chr$(KeyAscii)))

End Sub


'------------------------------------------------------------------------
' Function: ofx_AnsiQuote()
'
' Purpose:  Wrap the string passed in quotes and return it to
'           the host.  For example, if the word DATA was passed
'           to this function, the return value would be 'DATA'.
'
'           if the sParam contains single quotes, they are substituted
'           with double ones
'
'           IN = Steve's        OUT = 'Steve''s'
'
' Params:   sParam  (I) The text to enclose in quotes.
'
' Returns:  The string enclosed in single quotes.
'------------------------------------------------------------------------
Function ofx_AnsiQuote(sParam As String) As String
 
    On Error Resume Next
    ofx_AnsiQuote = "'" & ofx_ReplaceString(sParam, "'", "''") & "'"

End Function



'------------------------------------------------------------------------
' Function: ofx_GetStringToken()
'
' Purpose:  Retrieves the requested token from the tokenized string passed
'           by its ordinal position.
'
'           For example:
'
'               ofx_GetStringToken("1,2,3", 2, ",")
'
'           would return "2" (second token in a string delimited by commas).
'
'               ofx_GetStringToken("This is a test", 2, " ")
'
'           would return "is" (second token delimited by spaces).
'
' Params:   sTokens     (I) String containing the delimited tokens.
'           nOrdinal    (I) Ordinal position of the token requested (1 based).
'           sDelim      (I) Token delimiter.
'
' Returns:  The string token requested, or empty string.
'------------------------------------------------------------------------
Function ofx_GetStringToken(sTokens As String, nOrdinal As Integer, sDelim As String) As String

    On Error GoTo Err_ofx_GetStringToken

    Dim nPos As Integer
    Dim nPos1 As Integer
    Dim nCount As Integer

    nPos = 0
    ofx_GetStringToken = ""

    For nCount = 0 To nOrdinal - 1
        nPos1 = InStr(nPos + 1, sTokens, sDelim)

        If (nPos1 = 0) Then nPos1 = Len(sTokens) + 1
        If (nCount <> nOrdinal - 1) Then nPos = nPos1
    Next nCount

    If (nPos1 > nPos) Then
        ofx_GetStringToken = Mid$(sTokens, nPos + 1, nPos1 - nPos - 1)
    End If

Exit_ofx_GetStringToken:
    Exit Function

Err_ofx_GetStringToken:
    Call ofx_GenericError("ofx_GetStringToken()", Err)
    Resume Exit_ofx_GetStringToken

End Function

#If MSA Then
'------------------------------------------------------------------------
' Function: ofx_LoadString -- MS Access only
'
' Purpose:  Looks up a string in the local string table "tbl_strings" and
'           returns the string.  This function will throw an error if the
'           string table does not exist or is in the wrong format.
'
' Params:   nID (I) ID of the string to return (should be a constant).
'
' Returns:  The string requested from the strings table.
'
' See Also:  _strings table and _strings_constants_qry
'------------------------------------------------------------------------
Function ofx_LoadString(nID As Long, Optional sTable As Variant) As String
    On Error GoTo ofx_LoadString_Error
    
    Dim rs As Recordset
    
    Const sStringTable$ = "_strings"
    Const sStringTextColumn$ = "StringText"

    Dim sTableName As String
    If (Not (IsMissing(sTable))) Then
        sTableName = sTable
    Else
        sTableName = sStringTable
    End If

    '----- Set the database and recordset objects.
    
    Dim db As Database
    Set db = CurrentDb      'may be called before ofxApp is constructed
    Set rs = db.OpenRecordset(sTableName, dbOpenDynaset, dbReadOnly)
    
    '----- Set the primary index and seek to to the record (we can seek because we
    '----- opened it as a local table...).
    
    rs.Index = "PrimaryKey"
    rs.Seek "=", nID
    
    '----- If a match is found, return the string text.
    
    If (Not (rs.NoMatch)) Then
        If (Not (IsNull(rs(0)))) Then ofx_LoadString = CStr(Nz(rs(sStringTextColumn)))
    Else
        ofx_LoadString = ""
    End If
    
ofx_LoadString_Exit:
    ofx_SafeCloseRecordset rs
    Exit Function
ofx_LoadString_Error:
    MsgBox Err.Description          'don't call generic error, it may call back into this proc
    Resume ofx_LoadString_Exit
End Function
#Else
'------------------------------------------------------------------------
' Function: ofx_LoadString -- Visual Basic only
'
' Purpose:  Looks up a string in the string resource.
'
' Params:   nID (I) ID of the string to return (should be a constant).
'
' Returns:  The string requested from the strings table.
'------------------------------------------------------------------------
Function ofx_LoadString(nID As Long) As String
    On Error Resume Next
    #If VB3 Then
        Dim nLen As Integer
        Dim sValue As String * 512
        
        nLen = LoadString(GetWindowWord(Screen.ActiveForm.hWnd, GWW_HINSTANCE), nID, sValue, 512)
        If (nLen > 0) Then
            ofx_LoadString = Left(sValue, nLen)
        End If
    #Else
        ofx_LoadString = LoadResString(nID)
    #End If
End Function
#End If

'------------------------------------------------------------------------
' Function: ofx_ReplaceString
'
' Purpose:  String search and replace function.  Replaces the occurrences
'           of sSearch with sReplace in the sText string.
'
' Params:   sText       (I) String containing the text.
'           sSearch     (I) Text to search for.
'           sReplace    (I) Text to replace with.
'
' Returns:  The text string with the replacements in it.
'
' Note:     6/19/96  Modified to NOT alter sText
'------------------------------------------------------------------------
Function ofx_ReplaceString(sText As String, sSearch As String, sReplace As String) As String
    
    On Error Resume Next
    
    Dim sStr As String
    Dim iPOS As Integer
    
    sStr = sText
    
    '----- Special handling when pattern not in string
    
    If (0 = Len(sSearch)) Then GoTo ofx_ReplaceString_Exit
    
    '----- Now replace all instances of pattern with replacement
    
    iPOS = InStr(1, sStr, sSearch, 1)
    
    While (iPOS <> 0)
        sStr = Left$(sStr, iPOS - 1) & sReplace & Mid$(sStr, iPOS + Len(sSearch))
        iPOS = InStr(iPOS + Len(sReplace), sStr, sSearch, 1)
    Wend
    
ofx_ReplaceString_Exit:
    ofx_ReplaceString = sStr
    Exit Function
    
End Function

'------------------------------------------------------------------------
' Function: ofx_StringToArray()
'
' Purpose:  Converts a "packed" string into an array.  The array passed
'           need not be large enough to hold the entire array since it
'           will be reallocated as necessary.
'
'           The string will be parsed based on the delimiter passed.
'           The size of the array will be based on the delimiters passed.
'
' Params:   sList       (I) String of delimited elements.
'           sArray      (O) Array to hold the individual string elements.
'           sListDelim  (I) Delimiter string.
'
' Returns:  The number of elements in the list.
'
' Note:     6/7/96  Fix to correctly handle delimiter > 1 char long
'------------------------------------------------------------------------
Function ofx_StringToArray(sList As String, sArray() As String, sListDelim As String) As Integer
    
    On Error GoTo ofx_StringToArray_Err

    Dim nArrayIndex As Integer
    Dim nStartPos As Integer
    Dim nSepPos As Integer
    Dim nQuotePos As Integer
    Dim nCurPos As Integer
    Dim nNumElements As Integer
    Dim nDelimLen
    
    If (Not ofx_IsDimensioned(sArray())) Then
        ReDim sArray(1)
    End If
    nArrayIndex = LBound(sArray)  'start at the lower bound of the array
    nStartPos = 1
    nNumElements = 0
    nDelimLen = Len(sListDelim)

    Do
        '----- Look for delimiter

        nSepPos = InStr(nStartPos, sList, sListDelim)

        '----- If no delimiter found then end of list so exit

        If (0 = nSepPos) Then

            If (nStartPos <= Len(sList)) Then
                If (nArrayIndex > UBound(sArray)) Then
                    ReDim Preserve sArray(nArrayIndex)
                End If
                
                sArray(nArrayIndex) = Mid$(sList, nStartPos)
                nNumElements = nNumElements + 1
            End If
'            ofx_StringToArray = nNumElements + 1
'            Exit Function
            GoTo ofx_StringToArray_Exit
        End If

        '----- Special handling for quotes within string

        nQuotePos = InStr(nStartPos, sList, """")
        If (nQuotePos = 0 Or nSepPos < nQuotePos) Then
            nCurPos = nSepPos
        Else
            nQuotePos = InStr(nQuotePos + 1, sList, """")
            nCurPos = InStr(nQuotePos + 1, sList, sListDelim)
        End If

        '----- Copy item to array
        
        If nCurPos = 0 Then
            If (nArrayIndex > UBound(sArray)) Then
                ReDim Preserve sArray(nArrayIndex)
            End If
            sArray(nArrayIndex) = Mid$(sList, nStartPos)
            Exit Do 'Done
        Else
            If (nArrayIndex > UBound(sArray)) Then
                ReDim Preserve sArray(nArrayIndex)
            End If
            
            sArray(nArrayIndex) = Mid$(sList, nStartPos, nCurPos - nStartPos)
            nStartPos = nCurPos + nDelimLen
        End If

        '----- Move to next item in list (if any)
        
        nNumElements = nNumElements + 1
        nArrayIndex = nArrayIndex + 1
    Loop

ofx_StringToArray_Exit:
    ofx_StringToArray = nNumElements
    Exit Function

ofx_StringToArray_Err:
    Call ofx_GenericError("ofx_StringToArray()", Err)
    Resume ofx_StringToArray_Exit

End Function


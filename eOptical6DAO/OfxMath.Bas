Attribute VB_Name = "OfxMath"
'------------------------------------------------------------------------------
' Module:   Ofx - Math
'
' Purpose:  Mathematical routines.
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

'------------------------------------------------------------------------
' Function: ofx_SafeDiv
'
' Purpose:  Safely divides two numbers even if denominator is 0.
'
' Params:   vNum    (I) Numerator number.
'           vDenom  (I) Denominator number.
'
' Returns:  Result of division, or 0 in the case of divide by zero.
'------------------------------------------------------------------------
Function ofx_SafeDiv(vNum As Variant, vDenom As Variant) As Variant

    On Error GoTo ofx_SafeDiv_Err

    Dim nNum As Double
    Dim nDenom As Double

    If (vDenom = 0) Then
        ofx_SafeDiv = 0
    Else
        ofx_SafeDiv = vNum / vDenom
    End If

ofx_SafeDiv_Exit:
    Exit Function

ofx_SafeDiv_Err:
    Call ofx_GenericError("ofx_SafeDiv()", Err)
    Resume ofx_SafeDiv_Exit

End Function

'------------------------------------------------------------------------
' Function: ofx_HighByte
'
' Purpose:  Get the high byte (8 bits) of a word (16 bits).
'
' Params:   n   (I) the word from which to extract the high byte.
'
' Returns:  The high byte in the word
'
' See also: ofx_LowByte(), ofx_HighWord(), ofx_LowWord().
'------------------------------------------------------------------------
Function ofx_HighByte(n As Integer) As Byte
    On Error Resume Next
    
    If (n < 0) Then
        ofx_HighByte = ((n And &H7F00) \ &H100) + &H80
    Else
        ofx_HighByte = n \ 256
    End If
    
End Function





'------------------------------------------------------------------------
' Function: ofx_HighWord
'
' Purpose:  Get the high word (16 bits) of a long (32 bits).
'
' Params:   n   (I) The long from which to extract the high word.
'
' Returns:  The high word in the long
'
' See also: ofx_LowWord(), ofx_HighByte(), ofx_LowByte().
'------------------------------------------------------------------------
Function ofx_HighWord(n As Long) As Integer
    On Error Resume Next
    ofx_HighWord = ((n And &HFFFF0000) \ 65536)
End Function


'------------------------------------------------------------------------
' Function: ofx_LowByte
'
' Purpose:  Get the low byte (8 bits) of a word (16 bits).
'
' Params:   n   (I) The word from which to extract the low byte.
'
' Returns:  The low byte in the word
'
' See also: ofx_HighByte(), ofx_HighWord(), ofx_LowWord().
'------------------------------------------------------------------------
Function ofx_LowByte(n As Integer) As Byte
    On Error Resume Next
    ofx_LowByte = n And &HFF
End Function

'------------------------------------------------------------------------
' Function: ofx_LowWord
'
' Purpose:  Get the low word (16 bits) of a long (32 bits).
'
' Params:   n   (I) The long from which to extract the low word.
'
' Returns:  The low word in the long
'
' See also: ofx_HighWord(), ofx_HighByte(), ofx_LowByte().
'------------------------------------------------------------------------
Function ofx_LowWord(n As Long) As Integer
    On Error Resume Next
    ofx_LowWord = n And 65535
End Function





'------------------------------------------------------------------------
' Function: ofx_RectHeight
'
' Purpose:  Calculate the height of the specified rectangle.
'
' Params:   rc  (I) Rectangle for which to calculate height
'
' Returns:  Height of the rectangle
'
' See also: ofx_RectWidth().
'------------------------------------------------------------------------
Function ofx_RectHeight(rc As RECT) As Long
    On Error Resume Next
    ofx_RectHeight = (rc.nBottom - rc.nTop)
End Function

'------------------------------------------------------------------------
' Function: ofx_RectWidth
'
' Purpose:  Calculate the width of the specified rectangle.
'
' Params:   rc  (I) Rectangle for which to calculate width
'
' Returns:  Width of the rectangle
'
' See also: ofx_RectHeight().
'------------------------------------------------------------------------
Function ofx_RectWidth(rc As RECT) As Long
    On Error Resume Next
    ofx_RectWidth = (rc.nRight - rc.nLeft)
End Function

'------------------------------------------------------------------------
' Function: ofx_TestBit
'
' Purpose:  Determine if the specified bit in the nBits parameter is set.
'           Bits are numbered from least to most significant starting with 0.
'
' Params:   nBits   (I) The byte/integer/long in which to check the bit
'           nBit    (I) The bit to check
'
' Returns:  TRUE if the bit is set (= 1), FALSE otherwise
'------------------------------------------------------------------------
Public Function ofx_TestBit(ByVal nBits As Long, nBit As Integer) As Boolean
    On Error Resume Next
    ofx_TestBit = ((nBits \ (2 ^ nBit) And 1) <> 0)
End Function

'------------------------------------------------------------------------
' Function: ofx_Max
'
' Purpose:  Determine the larger of two values.  Both values should be of
'           like types (e.g. both strings or both numeric types).
'
' Params:   vValue1 (I) 1st value to compare
'           vValue2 (I) 2nd value to compare
'
' Returns:  Larger of the two values.
'
' See also: ofx_Min().
'------------------------------------------------------------------------
Function ofx_Max(vValue1 As Variant, vValue2 As Variant) As Variant
    On Error Resume Next
    ofx_Max = IIf(vValue1 >= vValue2, vValue1, vValue2)
End Function

'------------------------------------------------------------------------
' Function: ofx_Min
'
' Purpose:  Determine the smaller of two values.  Both values should be of
'           like types (e.g. both strings or both numeric types).
'
' Params:   vValue1 (I) 1st value to compare
'           vValue2 (I) 2nd value to compare
'
' Returns:  Smaller of the two values.
'
' See also: ofx_Max().
'------------------------------------------------------------------------
Function ofx_Min(vValue1 As Variant, vValue2 As Variant) As Variant
    On Error Resume Next
    ofx_Min = IIf(vValue1 <= vValue2, vValue1, vValue2)
End Function


'------------------------------------------------------------------------------
' Function: ofx_HexToDecimal
'
' Purpose:  Convert a hexadecimal value (string) to a long.
'
' Params:   sHex    (I) Hex string
'
' Returns:  Decimal value of hexadecimal number in sHex.
'
' Note:     String should not include BASIC &h prefix
'           (e.g. "AA04" is OK, "&hAA04" is not).
'
'           Use the VBA hex() function to convert a number to a hex string.
'------------------------------------------------------------------------------
Function ofx_HexToDecimal(sHex As String) As Long
    ofx_HexToDecimal = Val("&h" & sHex & "&")
End Function



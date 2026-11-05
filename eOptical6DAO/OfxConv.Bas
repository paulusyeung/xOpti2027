Attribute VB_Name = "OfxConversions"
'------------------------------------------------------------------------------
' Module:   Ofx - Conversions
'
' Purpose:  This module contains functions for safely converting values from one
'           data type to another without NULL problems.
'
' See also: For string type conversions (i.e. C to BASIC), upper lower case
'           conversions for single characters, etc. see the OFX Strings module.
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit



'------------------------------------------------------------------------------
'   Function:   ofx_CCur()
'
'   Purpose:    Extended currency conversion routine.  If the value passed
'               is NULL, it returns a 0, otherwise the currency data type
'               value.  This function is a replacement to the VBA
'               CCur() function.
'
'   Params:     vData   (I) Variant data to convert.
'
'   Returns:    The converted value or 0.
'
'   See also:   ofx_CCurDef()
'------------------------------------------------------------------------------
Function ofx_CCur(vData As Variant) As Currency
    On Error Resume Next
    ofx_CCur = ofx_CCurDef(vData, 0@)
End Function

'------------------------------------------------------------------------------
'   Function:   ofx_CCurDef()
'
'   Purpose:    Extended currency conversion routine.  If the value passed
'               is NULL, it returns the default value passed.  Otherwise the
'               currency data type value.  This function is a replacement
'               to the VBA CCur() function.
'
'   Params:     vData       (I) Variant data to convert.
'               curDefault  (I) Default value to return if vData is Null.
'
'   Returns:    The converted value or the default value.
'
'   See also:   ofx_CCur()
'------------------------------------------------------------------------------
Function ofx_CCurDef(vData As Variant, curDefault As Currency) As Currency

    On Error Resume Next

    If IsNull(vData) Then
        ofx_CCurDef = curDefault
    Else
        ofx_CCurDef = CCur(vData)
    End If

End Function

'------------------------------------------------------------------------------
'   Function:   ofx_CDbl()
'
'   Purpose:    Convert the variant data passed to a VBA Double
'               This function replaces the CDbl() VBA
'               function because it checks to see if the data passed is
'               Null or not.  If Null, it returns 0, otherwise the
'               converted value.
'
'   Params:     vData   (I)   Variant data to convert.
'
'   Returns:    The converted value or 0.
'
'   See also:   ofx_CDblDef()
'------------------------------------------------------------------------------
Function ofx_CDbl(vData As Variant) As Double

    On Error Resume Next

    ofx_CDbl = ofx_CDblDef(vData, 0@)

End Function

'------------------------------------------------------------------------------
'   Function:   ofx_CDblDef()
'
'   Purpose:    Convert the variant data passed to a VBA Double
'               This function replaces the CDbl() VBA
'               function because it checks to see if the data passed is
'               Null or not.  If Null, it returns the value passed as a
'               default.
'
'   Params:     vData       (I) Variant data to convert.
'               dblDefault  (I) Default value to use if vData is Null.
'
'   Returns:    The converted value or the default value passed.
'
'   See also:   ofx_CDbl()
'------------------------------------------------------------------------------
Function ofx_CDblDef(vData As Variant, dblDefault As Double) As Double

    On Error Resume Next

    If IsNull(vData) Then
        ofx_CDblDef = dblDefault
    Else
        ofx_CDblDef = CDbl(vData)
    End If

End Function

'------------------------------------------------------------------------------
'   Function:   ofx_CInt()
'
'   Purpose:    Convert the variant data passed to a VBA integer.
'               This function replaces the CInt() VBA function
'               because it checks to see if the data passed is Null or not.
'               If Null, it returns 0, otherwise the converted value.
'
'   Params:     vData   (I) Variant data to convert.
'
'   Returns:    The converted value or 0.
'
'   See also:   ofx_CIntDef()
'------------------------------------------------------------------------------
Function ofx_CInt(vData As Variant) As Integer
    
    On Error Resume Next

    ofx_CInt = ofx_CIntDef(vData, 0)

End Function

'------------------------------------------------------------------------------
'   Function:   ofx_CIntDef()
'
'   Purpose:    Convert the variant data passed to a VBA integer.
'               This function replaces the CInt() VBA function
'               because it checks to see if the data passed is Null or not.
'               If Null, it returns the default value passed, otherwise the
'               converted value.
'
'   Params:     vData       (I) Variant data to convert.
'               nDefault    (I) Default value to return if vData is Null.
'
'   Returns:    The converted value or the default value passed.
'
'   See also:   ofx_CInt()
'------------------------------------------------------------------------------
Function ofx_CIntDef(vData As Variant, nDefault As Integer) As Integer

    On Error Resume Next

    If IsNull(vData) Then
        ofx_CIntDef = nDefault
    Else
        ofx_CIntDef = CInt(vData)
    End If

End Function

'------------------------------------------------------------------------------
'   Function:   ofx_CLng()
'
'   Purpose:    Convert the variant data passed to a VBA long
'               integer.  This function replaces the CLng() VBA
'               function because it checks to see if the data passed is
'               Null or not.  If Null, it returns 0, otherwise the
'               converted value.
'
'   Params:     vData   (I) Variant data to convert.
'
'   Returns:    The converted value or 0.
'
'   See also:   ofx_CLngDef()
'------------------------------------------------------------------------------
Function ofx_CLng(vData As Variant) As Long

    On Error Resume Next

    ofx_CLng = ofx_CLngDef(vData, 0&)

End Function

'------------------------------------------------------------------------------
'   Function:   ofx_CLngDef()
'
'   Purpose:    Convert the variant data passed to a VBA long
'               integer.  This function replaces the CLng() VBA
'               function because it checks to see if the data passed is
'               Null or not.  If Null, it returns 0, otherwise the
'               converted value.
'
'   Params:     vData       (I) Variant data to convert.
'               nDefault    (I) Default value to return if vData is Null.
'
'   Returns:    The converted value or the default value passed.
'
'   See also:   ofx_CLng()
'------------------------------------------------------------------------------
Function ofx_CLngDef(vData As Variant, lDefault As Long) As Long

    On Error Resume Next

    If IsNull(vData) Then
        ofx_CLngDef = lDefault
    Else
        ofx_CLngDef = CLng(vData)
    End If

End Function

'------------------------------------------------------------------------------
'   Function:   ofx_CSng()
'
'   Purpose:    Convert the variant data passed to a VBA single
'               This function replaces the CSng() VBA
'               function because it checks to see if the data passed is
'               Null or not.  If Null, it returns 0, otherwise the
'               converted value.
'
'   Params:     vData   (I) Variant data to convert.
'
'   Returns:    The converted value or 0.
'
'   See also:   ofx_CSngDef()
'------------------------------------------------------------------------------
Function ofx_CSng(vData As Variant) As Single

    On Error Resume Next

    ofx_CSng = ofx_CSngDef(vData, 0)

End Function

'------------------------------------------------------------------------------
'   Function:   ofx_CSngDef()
'
'   Purpose:    Convert the variant data passed to a VBA single
'               This function replaces the CSng() VBA
'               function because it checks to see if the data passed is
'               Null or not.  If Null, it returns the default value.
'               Otherwise the converted value.
'
'   Params:     vData       (I) Variant data to convert.
'               sngDefault  (I) Default value to return if vData is Null.
'
'   Returns:    The converted value or the default passed.
'
'   See also:   ofx_CSng()
'------------------------------------------------------------------------------
Function ofx_CSngDef(vData As Variant, sngDefault As Single) As Single

    On Error Resume Next

    If (IsNull(vData)) Then
        ofx_CSngDef = sngDefault
    Else
        ofx_CSngDef = CSng(vData)
    End If

End Function

'------------------------------------------------------------------------------
'   Function:   ofx_CStr()
'
'   Purpose:    Convert the variant data passed to a VBA string.
'               This function replaces the CStr() VBA
'               function because it checks to see if the data passed is
'               Null or not.  If Null, it returns an empty string, otherwise
'               the converted value.
'
'   Params:     vData   (I) Variant data to convert.
'
'   Returns:    The converted value or an empty string.
'
'   See also:   ofx_CStrDef()
'------------------------------------------------------------------------------
Function ofx_CStr(vData As Variant) As String

    On Error Resume Next
    
    ofx_CStr = ofx_CStrDef(vData, "")

End Function

'------------------------------------------------------------------------------
'   Function:   ofx_CStrDef()
'
'   Purpose:    Convert the variant data passed to a VBA string.
'               This function replaces the CStr() VBA
'               function because it checks to see if the data passed is
'               Null or not.  If Null, it returns the default value passed.
'               Otherwise the converted value.
'
'   Params:     vData       (I) Variant data to convert.
'               sDefault    (I) Default value to return if vData is Null.
'
'   Returns:    The converted value or the default value passed.
'
'   See also:   ofx_CStr()
'------------------------------------------------------------------------------
Function ofx_CStrDef(vData As Variant, sDefault As String) As String

    On Error Resume Next

    If IsNull(vData) Then
        ofx_CStrDef = sDefault
    Else
        ofx_CStrDef = CStr(vData)
    End If

End Function




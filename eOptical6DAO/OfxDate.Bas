Attribute VB_Name = "OfxDate"
'------------------------------------------------------------------------------
' Module:   Ofx - Date
'
' Purpose:  Date manipulation routines for determining weekday dates either
'           previous or next (i.e. get next Monday, previous Saturday, etc.).
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

'----- Date manipulation constants used as parameters to the functions.

Public Const OFX_DATEPREV% = 0
Public Const OFX_DATENEXT% = 1


'------------------------------------------------------------------------------
' Function: ofx_Friday
'
' Purpose:  Get the next or previous date that falls on a Friday.
'
' Params:   vCurDate    (I) date to start from.  Must be one of the following
'                           formats:  "1/1/95" or "1-January-1995".
'           nDirection  (I) OFX_DATEPREV: previous Friday
'                           OFX_DATENEXT: next Friday.
'
' Returns:  The date that Friday falls on.
'------------------------------------------------------------------------------
Function ofx_Friday(vCurDate As Variant, nDirection As Integer) As Variant
    
    On Error Resume Next
    ofx_Friday = ofx_GetDayDate(vCurDate, 5, nDirection)

End Function

'------------------------------------------------------------------------------
' Function: ofx_GetDayDate
'
' Purpose:  Used to return the date passed plus the week day requested.
'           Used by the ofx_Sunday() - ofx_Saturday() routines.
'
' Params:   vCurDate    (I) Starting date to add to get the day of the week.
'           nDayOfWeek  (I) Number representing the desired day of the week
'                            (i.e. Sunday = 0 ... Saturday = 6).
'           nDirection  (I) OFX_DATEPREV: last previous specified day
'                           OFX_DATENEXT: next specified day.
'
' Returns:  The requested day of the week based on the day of the week number passed.
'
' Note:     7/27/96  Modified work properly in borderline condition
'------------------------------------------------------------------------------
Private Function ofx_GetDayDate(vCurDate As Variant, nDayOfWeek As Integer, nDirection As Integer) As Variant

    On Error GoTo Err_ofx_GetDayDate

    Dim nDate As Integer

    nDate = (nDayOfWeek - WeekDay(vCurDate) + 8) Mod 7

    If (nDirection = OFX_DATEPREV) Then
        nDate = nDate - 7
    End If

    ofx_GetDayDate = DateAdd("d", nDate, vCurDate)

Exit_GetDayDate:
    Exit Function

Err_ofx_GetDayDate:
    ofx_GenericError "GetWeekDay()", Err
    Resume Exit_GetDayDate

End Function

'------------------------------------------------------------------------------
' Function: ofx_Monday
'
' Purpose:  Get the next or previous date that falls on a Monday.
'
' Params:   vCurDate    (I) date to start from.  Must be one of the following
'                           formats:  "1/1/95" or "1-January-1995".
'           nDirection  (I) OFX_DATEPREV: previous Monday
'                           OFX_DATENEXT: next Monday.
'
' Returns:  The date that Monday falls on.
'------------------------------------------------------------------------------
Function ofx_Monday(vCurDate As Variant, nDirection As Integer) As Variant

    On Error Resume Next
    ofx_Monday = ofx_GetDayDate(vCurDate, 1, nDirection)

End Function

'------------------------------------------------------------------------------
' Function: ofx_Saturday
'
' Purpose:  Get the next or previous date that falls on a Saturday.
'
' Params:   vCurDate    (I) date to start from.  Must be one of the following
'                           formats:  "1/1/95" or "1-January-1995".
'           nDirection  (I) OFX_DATEPREV: previous Saturday
'                           OFX_DATENEXT: next Saturday.
'
' Returns:  The date that Saturday falls on.
'------------------------------------------------------------------------------
Function ofx_Saturday(vCurDate As Variant, nDirection As Integer) As Variant
    
    On Error Resume Next
    ofx_Saturday = ofx_GetDayDate(vCurDate, 6, nDirection)

End Function

'------------------------------------------------------------------------------
' Function: ofx_Sunday
'
' Purpose:  Get the next or previous date that falls on a Sunday.
'
' Params:   vCurDate    (I) date to start from.  Must be one of the following
'                           formats:  "1/1/95" or "1-January-1995".
'           nDirection  (I) OFX_DATEPREV: previous Sunday
'                           OFX_DATENEXT: next Sunday.
'
' Returns:  The date that Sunday falls on.
'------------------------------------------------------------------------------
Function ofx_Sunday(vCurDate As Variant, nDirection As Integer) As Variant
    
    On Error Resume Next
    ofx_Sunday = ofx_GetDayDate(vCurDate, 0, nDirection)

End Function

'------------------------------------------------------------------------------
' Function: ofx_Thursday
'
' Purpose:  Get the next or previous date that falls on a Thursday.
'
' Params:   vCurDate    (I) date to start from.  Must be one of the following
'                           formats:  "1/1/95" or "1-January-1995".
'           nDirection  (I) OFX_DATEPREV: previous Thursday
'                           OFX_DATENEXT: next Thursday.
'
' Returns:  The date that Thursday falls on.
'------------------------------------------------------------------------------
Function ofx_Thursday(vCurDate As Variant, nDirection As Integer) As Variant

    On Error Resume Next
    ofx_Thursday = ofx_GetDayDate(vCurDate, 4, nDirection)

End Function

'------------------------------------------------------------------------------
' Function: ofx_Tuesday
'
' Purpose:  Get the next or previous date that falls on a Tuesday.
'
' Params:   vCurDate    (I) date to start from.  Must be one of the following
'                           formats:  "1/1/95" or "1-January-1995".
'           nDirection  (I) OFX_DATEPREV: previous Tuesday
'                           OFX_DATENEXT: next Tuesday.
'
' Returns:  The date that Tuesday falls on.
'------------------------------------------------------------------------------
Function ofx_Tuesday(vCurDate As Variant, nDirection As Integer) As Variant
    
    On Error Resume Next
    ofx_Tuesday = ofx_GetDayDate(vCurDate, 2, nDirection)

End Function

'------------------------------------------------------------------------------
' Function: ofx_Wednesday
'
' Purpose:  Get the next or previous date that falls on a Wednesday.
'
' Params:   vCurDate    (I) date to start from.  Must be one of the following
'                           formats:  "1/1/95" or "1-January-1995".
'           nDirection  (I) OFX_DATEPREV: previous Wednesday
'                           OFX_DATENEXT: next Wednesday.
'
' Returns:  The date that Wednesday falls on.
'------------------------------------------------------------------------------
Function ofx_Wednesday(vCurDate As Variant, nDirection As Integer) As Variant
    
    On Error Resume Next
    ofx_Wednesday = ofx_GetDayDate(vCurDate, 3, nDirection)

End Function


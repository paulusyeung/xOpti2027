Attribute VB_Name = "OfxMiscellaneous"
'------------------------------------------------------------------------------
' Module:   Ofx - Miscellaneous
'
' Purpose:  Miscellaneous utility functions.
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit

'------------------------------------------------------------------------------
' Function: ofx_Is16BitOs
'
' Purpose:  Determines if application is running under a
'           16-bit or 32-bit operating system.
'
' Returns:  TRUE if OS is 16-bit, else FALSE.
'
' Notes:    1)  Only applies to 16-bit applications since only
'               16-bit applications can run on both 16 and 32-bit
'               OS's.
'           2)  Works for Win 3.1, WFW, Windows95, and WindowsNT
'           3)  Likely, but not guaranteed, to work for future Windows versions.
'------------------------------------------------------------------------------
#If Win16 Then
Function ofx_Is16BitOs() As Boolean
    On Error Resume Next
    
    Dim b16Bit As Boolean
    Dim nMinor As Integer
    
    If (GetWinFlags() And WF_WINNT) Then
        b16Bit = False
    Else
        nMinor = ofx_HighByte(GetVersion())
        b16Bit = (nMinor < &H95)
    End If
    
    ofx_Is16BitOs = b16Bit
End Function
#End If

'------------------------------------------------------------------------------
' Sub:      ofx_Swap
'
' Purpose:  Swaps item1 and item2.
'
' Params:   vItem1   (I/O) 1st item to swap.
'           vItem2   (I/O) 2nd item to swap.
'
' Note:     Both items should be of like types.
'------------------------------------------------------------------------------
Sub ofx_Swap(vItem1 As Variant, vItem2 As Variant)

    On Error GoTo ofx_Swap_Err

    Dim vTemp As Variant

    vTemp = vItem1
    vItem1 = vItem2
    vItem2 = vTemp

ofx_Swap_Exit:
    Exit Sub

ofx_Swap_Err:
    Call ofx_GenericError("ofx_Swap", Err)
    Resume ofx_Swap_Exit

End Sub


'------------------------------------------------------------------------------
' Sub:      ofx_WaitCursor
'
' Purpose:  Turns the hourglass cursor on or off depending on the
'           value that is passed.
'
'           This function is preferable to the "DoCmd Hourglass True/False"
'           method because you can nest calls to turn the hourglass on or
'           off.
'
'           For example, Func1() calls Func2().  Func1() turns on the
'           hourglass, then calls Func2() who also turns on the hourglass.
'           Func2() turns off the hourglass on exit, but Func1() still
'           assumes that it is on.  By using this function, Func2()'s call
'           to turn the hourglass off will be ignored, because it is the
'           responsibility of Func1() to turn it off.
'
'           It is VERY important that you code your routines so that the
'           hourglass is never left on, because it will throw the stack off
'           and your user will be stuck with an hourglass for a cursor.
'
' Note:     During development it can be a bit annoying to have the
'           hourglass on when you need to click on something.
'           If you would like to turn that functionality off during development
'           you can do so by adding the BYPASS_WAIT_CURSOR compilation constant to
'           the modules tab of the tools/options menu item.  Set it to 'True'.
'           If you want the cursor to change even in development then change it to 'False'.
'
' Params:   bTrue   (I) True to turn the hourglass on, False to turn it off.
'------------------------------------------------------------------------------
Sub ofx_WaitCursor(bTrue As Integer)

    On Error Resume Next
    
    Static nStack As Integer                ' Routine call stack counter.

    nStack = nStack + IIf(bTrue, 1, -1)     ' Increment/Decrement stack counter.

    Select Case bTrue
        Case True
            #If MSA And Not BYPASS_WAIT_CURSOR Then
                DoCmd.Hourglass bTrue           ' Turn on the hourglass.
            #End If
            #If Not MSA Then
                Screen.MousePointer = 11
            #End If
        Case False
            If nStack < 1 Then              ' If stack has been cleared...
                nStack = 0                  ' arbitrarily set the stack count
                #If MSA Then
                    DoCmd.Hourglass bTrue       ' and turn the hourglass off.
                #Else
                    Screen.MousePointer = 0
                #End If
            End If
    End Select

End Sub

#If MSA Then
'------------------------------------------------------------------------------
' Sub:     ofx_SetEcho
'
' Purpose: Turn the Echo on/off depending on whether or not
'          the we are running the runtime version.  If not
'          in runtime, do not turn the echo off since debugging
'          mode will not work correctly.
'
' Params:  bTrue    (I) True = on, False = off.
'------------------------------------------------------------------------------
Sub ofx_SetEcho(bTrue As Integer)

    On Error GoTo Err_ofx_SetEcho

    If ofx_IsRuntime() Then
        Application.Echo bTrue
    End If
        
Exit_ofx_SetEcho:
    Exit Sub

Err_ofx_SetEcho:
    ofx_GenericError "ofx_SetEcho()", Err
    Resume Exit_ofx_SetEcho

End Sub
#Else
    Sub ofx_SetEcho(bTrue As Integer)
    
    End Sub
#End If



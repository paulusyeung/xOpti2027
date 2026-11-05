Attribute VB_Name = "AppStatusBar"
Option Explicit

'------------------------------
' Procedure:  StatusBarClick
' Purpose:    Toggle between simple and normal style.
' Params:
' Returns:    N/A
'------------------------------
Public Sub StatusBarClick(ctlStatusBar As Control)
    On Error GoTo StatusBarClick_Err

    ' Toggle between simple and normal style.
    With ctlStatusBar
        If .Style = 0 Then
            .Style = sbrSimple  ' Simple style.
            If Trim(pyUserName) <> "" Then
                ' This text will be displayed when the StatusBar is in Simple style.
                .SimpleText = "User: " & pyUserName & ", logon since " & _
                                pyUserLogonTime
            End If
        Else
            .Style = sbrNormal  ' Normal style.
        End If
    End With

StatusBarClick_Exit:                                ' SDVB autocode
    On Error Resume Next                            ' SDVB autocode
    Exit Sub                                        ' SDVB autocode
StatusBarClick_Err:                                 ' SDVB autocode
    Call ofx_GenericError("StatusBarClick()", Err)  ' SDVB autocode
    Resume StatusBarClick_Exit
End Sub


'------------------------------
' Procedure:  LogonLog
' Purpose:    Keep Logon User Name & Time
' Params:
' Returns:    N/A
'------------------------------
Public Function LogonLog(myUserID) As Integer
    On Error GoTo LogonLog_Err

    Dim myDB As Database
    Dim myRS As Recordset
    Dim strSQL As String
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set myRS = myDB.OpenRecordset("Staff", dbOpenDynaset, dbReadOnly)    ' Open table read only
    strSQL = "StaffCode = '" & myUserID & "'"
    
    myRS.FindFirst strSQL
    If myRS.NoMatch Then
        LogonLog = 0
    Else
        pyUserName = myRS!StaffFullName
        pyUserLogonTime = Format(Date, "mmm dd, yyyy (dddd)") & " at " & Format(Time, "Long Time")
        LogonLog = 1
    End If
    
    myRS.Close
    myDB.Close

LogonLog_Exit:                                ' SDVB autocode
    On Error Resume Next                      ' SDVB autocode
    Exit Function                             ' SDVB autocode
LogonLog_Err:                                 ' SDVB autocode
    Call ofx_GenericError("LogonLog()", Err)  ' SDVB autocode
    Resume LogonLog_Exit
End Function
'------------------------------
' Procedure:  CreatePanelObjects
' Purpose:
' Params:
' Returns:    N/A
'------------------------------
Public Sub CreatePanelObjects(ctlStatusBar As Control)
    On Error GoTo CreatePanelObjects_Err

    Dim i, j1, j2 As Integer
    For i = 1 To 6
        ctlStatusBar.Panels.Add   ' Add 6 Panel objects.
    Next i
    
    With ctlStatusBar.Panels
        .Item(1).Style = sbrText    ' Any Text
        .Item(2).Style = sbrText
        .Item(2).Text = Format(Now, "mmm dd, yyyy")   ' Date
        .Item(3).Style = sbrTime    ' Time
        .Item(4).Style = sbrIns     ' Insert lock
        .Item(5).Style = sbrNum     ' Number lock
        .Item(6).Style = sbrCaps    ' Caps lock
        .Item(7).Style = sbrScrl    ' Scroll lock
    End With
 
    
    ' Set Width of Panels(2th - 3rd)
    j1 = 1080
    For i = 2 To 3
        With ctlStatusBar.Panels(i)
            .Width = j1
            .Alignment = sbrCenter
        End With
    Next i
    
    ' Set Width of Panels(4th - last)
    j2 = 500
    For i = 4 To 7
        With ctlStatusBar.Panels(i)
            .Width = j2
            .Alignment = sbrCenter
        End With
    Next i
    
    ' Set Width of Panels(1st)
    i = (ctlStatusBar.Width - j1 * 2 - j2 * 4)
    ctlStatusBar.Panels(1).Width = i
    
    ' Set all

CreatePanelObjects_Exit:                                ' SDVB autocode
    On Error Resume Next                                ' SDVB autocode
    Exit Sub                                            ' SDVB autocode
CreatePanelObjects_Err:                                 ' SDVB autocode
    Call ofx_GenericError("CreatePanelObjects()", Err)  ' SDVB autocode
    Resume CreatePanelObjects_Exit
End Sub



'------------------------------
' Procedure:  PromptStatusBar
' Purpose:    Display text message at status bar item (1)
' Params:
' Returns:    N/A
'------------------------------
Public Sub PromptStatusBar(ctlStatusBar As Control, nMsg As String)
    On Error GoTo PromptStatusBar_Err

    With ctlStatusBar
        .Panels.Item(1).Text = nMsg
        .Refresh
    End With

PromptStatusBar_Exit:                                ' SDVB autocode
    On Error Resume Next                             ' SDVB autocode
    Exit Sub                                         ' SDVB autocode
PromptStatusBar_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PromptStatusBar()", Err)  ' SDVB autocode
    Resume PromptStatusBar_Exit
End Sub

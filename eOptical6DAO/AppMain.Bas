Attribute VB_Name = "AppMain"
Option Explicit

'Menu Command constants
Public Const idMenuFileNew As Integer = 1001
Public Const idMenuFileOpen As Integer = 1002
Public Const idMenuFileClose As Integer = 1003
Public Const idMenuFileSend As Integer = 1004
Public Const idMenuExit As Integer = 1005

Public Const idMenuCut As Integer = 1006
Public Const idMenuCopy As Integer = 1007
Public Const idMenuPaste As Integer = 1008

Public Const idMenuToolbar As Integer = 1009
Public Const idMenuStatusbar As Integer = 1010

Public Const idMenuToolsOptions As Integer = 1011
Public Const idMenuToolsOfficeBook As Integer = 1012

Public Const idMenuTileHoriz As Integer = 1013
Public Const idMenuTileVert As Integer = 1014
Public Const idMenuCascade As Integer = 1015

Public Const idMenuAbout As Integer = 1016

Public Const pyLightGray As Long = &HC0C0C0
Public pyTheCustomer As Control
Public pyTheSupplier As Control
Public pyTheSKU As Control
Public pyUserName As String
Public pyUserID As String
Public pyUserSLevel As Integer
Public pyUserLogonTime As Date

' WA added on Nov 14, 1997 for control display of cost
Public pyUserHasCostLevel As Boolean
' WA added on Jan 07, 1998 for override MinDate restriction
Public Const pyMinDate As Date = #7/1/1996#
' WA added on May 09, 1998 for Void/Refund Date
Public pyVoidRefundDate As Date


'---------------------------------------------------------
' Procedure:  OnFileClose
'
' Scope:  Public
'
' Params:     frm - Calling form
'
' Returns:
'   True or False
'
' Date:  6/21/96
'
' Notes:
'
'---------------------------------------------------------
Function OnFileClose(frm As Form) As Boolean
    On Error GoTo OnFileClose_Error
    
    '//TO DO:  handle file close
    #If DBOPT_JET Or DBOPT_RDO Or DBOPT_ODBC Or DBOPT_VBSQL Then
        CloseAllDatabases
    #End If
    
    OnFileClose = True
    
OnFileClose_Exit:
    Exit Function
OnFileClose_Error:
    Call ofx_GenericError("OnFileClose()", Err)
    Resume OnFileClose_Exit
End Function

'---------------------------------------------------------
' Procedure:  OnFileSend
'
' Scope:  Public
'
' Params:     frm -
'
' Returns:
'
' Date:  6/21/96
'
' Notes:
'
'---------------------------------------------------------
'
Function OnFileSend(frm As Form) As Boolean
#If OFXOPT_MAPI Then

    On Error GoTo OnFileSend_Error
    Dim oSession As Object
    Set oSession = CreateObject("MAPI.Session")
    oSession.Logon
    
    Dim oMessage As Object
    Set oMessage = oSession.Outbox.Messages.Add
            
    With oMessage
        .subject = "Start Developing..."
        .Text = "File|Send shell command."
        .Update   ' update the message
    End With
    
    oMessage.Send True, True, frm.hWnd
    
    oSession.Logoff
        
OnFileSend_Exit:
    Set oSession = Nothing
    Exit Function
OnFileSend_Error:
    If (-2147221229 = Err.Number) Then
        'user canceled
    Else
        ofx_GenericError "AppMain::OnFileSend()"
    End If
    Resume OnFileSend_Exit
#End If
End Function


'---------------------------------------------------------
' Procedure:  OnFileOpen
'
' Scope:  Public
'
' Params:     frm -
'
' Returns:
'
' Date:  6/21/96
'
' Notes:
'
'---------------------------------------------------------
'
Function OnFileOpen(frm As Form) As Boolean
    On Error GoTo OnFileOpen_Error
    
    'If ANY of the database options are defined, assume that File|Open
    'is actually File|Open Database
    
    'If the splash form is loaded, then we should unload it, as it is a TOPMOST window
    'and any new dialogs will be displayed below it.  (Really annoying)
    If (ofx_IsFormLoaded(frmSplash)) Then
        SetWindowPos frmSplash.hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOSIZE Or SWP_NOMOVE
    End If

    #If DBOPT_JET Or DBOPT_RDO Or DBOPT_ODBC Or DBOPT_VBSQL Then
        
        If (ofxApp.dbList Is Nothing) Then
            PopulateDatabaseList
        End If
        
        If (Not (ofxApp.dbList Is Nothing)) Then
            Dim dbHolder As CDatabaseHolder
            For Each dbHolder In ofxApp.dbList
                OpenDatabase dbHolder.Name
            Next dbHolder
        End If
    
    #Else
    
        Dim hWnd As Long
        If (frm Is Nothing) Then
            hWnd = ofx_GetForegroundWindow()
        Else
            hWnd = frm.hWnd
        End If
        
        Dim sFile As String, sFileTitle As String, nFilterIndex As Integer
        If (ofx_GetOpenFileName(hWnd, "Open", "All Files|*.*||", sFile, sFileTitle, "TXT", nFilterIndex)) Then
            '// TO DO:  Handle File|Open
            OnFileOpen = True
        End If
        
    #End If
    
OnFileOpen_Exit:
    Exit Function
OnFileOpen_Error:
    Call ofx_GenericError("OnFileOpen()", Err)
    Resume OnFileOpen_Exit
End Function

'---------------------------------------------------------
' Procedure:  OnFileNew
'
' Scope:  Public
'
' Params:     frm -
'
' Returns:
'
' Date:  6/21/96
'
' Notes:
'
'---------------------------------------------------------
'
Function OnFileNew(frm As Form) As Boolean
    On Error GoTo OnFileNew_Err
    
    Dim nDummy As Integer

    'If the splash form is loaded, then we should unload it, as it is a TOPMOST window
    'and any new dialogs will be displayed below it.  (Really annoying)
    nDummy = DoSplash(ofxSplashStartupClose)

    Dim sFile As String, sFileTitle As String, nFilterIndex As Integer
    If (ofx_GetSaveFileName((frm.hWnd), "New", "All Files|*.*||", sFile, sFileTitle, "TXT", nFilterIndex)) Then
        '// TO DO:  Handle File|Open
        OnFileNew = True
    End If

OnFileNew_Exit:
    On Error Resume Next
    Exit Function
OnFileNew_Err:
    Call ofx_GenericError("OnFileNew()", Err)
    Resume OnFileNew_Exit

End Function

'---------------------------------------------------------
' Procedure:  DoSplash
'
' Scope:  Public
'
' Params:     nAction -
'
' Returns:
'
' Date:  6/21/96
'
' Notes:
'
'---------------------------------------------------------
'
Function DoSplash(nAction As Integer) As Boolean

    On Error GoTo DoSplash_Err


    'This function will be called 2 times
    '   First time:  as the very first action
    '                in the app
    
    '   Second time: after the startup has EITHER
    '                TRY or failed
    
    '   Note that if this application is ONLY to be
    '   run as a server application, then we probably
    '   don't want a splash screen.
    
    #If Not OFXOPT_SERVERONLY Then
        If (Not (ofxApp.bRunAutomated)) Then
            Select Case nAction
            
                Case ofxSplashShow
                    'Show the splash
                    frmSplash.Show
                    frmSplash.Refresh
                Case ofxSplashStartupSuccess
                    'starup worked, so keep the splash
                    'around for a couple of seconds
                    If (ofx_IsFormLoaded(frmSplash)) Then
                        frmSplash.timSplash.Interval = 1000
                    End If
                Case ofxSplashStartupClose
                    'Just unload
                    Unload frmSplash
                    'may want to repaint the main form
'                    If (ofx_IsFormLoaded(frmMain)) Then
'                        frmMain.Refresh
'                    End If
             End Select
        End If
    #End If
    

DoSplash_Exit:
    On Error Resume Next
    Exit Function
DoSplash_Err:
    Call ofx_GenericError("DoSplash()", Err)
    Resume DoSplash_Exit

End Function

'---------------------------------------------------------
' Procedure:  InitInstance
'
' Scope:  Public
'
' Params:     None
'
' Returns:
'
' Date:  6/21/96
'
' Notes:
'
'---------------------------------------------------------
'
Function InitInstance() As Boolean
    On Error GoTo InitInstance_Error

    'The AppWizard will set this compilation flag to True
    'if you choose the 'Make this app an OLE server'
    'feature with the 'Run ONLY as a server application' option selected
    'This causes the Main form to NOT be shown
    
    If (Not (ofxApp.bRunAutomated)) Then
        frmMain.Caption = App.Title
        frmMain.Show vbModeless
    End If
    
    #If Not VB3 Then
        'PopulateDatabaseList() will return True even if there are no databases to open
        
        If (PopulateDatabaseList()) Then
        End If
    #End If
    
    If (Not (ofxApp.bRunAutomated)) Then
        frmMain.ZOrder
    End If
    
    InitInstance = True
    
InitInstance_Exit:
    Exit Function
InitInstance_Error:
    Call ofx_GenericError("InitInstance()", Err)
    Resume InitInstance_Exit
End Function

'---------------------------------------------------------
' Procedure:  ExitInstance
'
' Scope:  Public
'
' Params:     frm -
'
' Returns:
'
' Date:  6/21/96
'
' Notes:
'
'---------------------------------------------------------
'
Function ExitInstance(frm As Form) As Boolean
    On Error Resume Next
    
    
    'DON't use the form if it is not set!!!
    If (Not (frm Is Nothing)) Then
        ' any form clean-up here
    End If
    
    #If Not VB3 Then
        CloseAllDatabases
    #End If
    
    'Return False to cancel the Unload
    'Note that the return code is ignored
    'if NOT called from the main form, for instance, InitInstance failed
    ExitInstance = True
    
End Function

Public Function GetSKUNumber() As String

    Dim strSKU, strCountryCode, strNextSKUNumber As String
    Dim myDB As Database, dtcPref As Recordset
    
    '
    ' Fetch and update the Next SKU Number from Table Preference
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                       ' Open database
    Set dtcPref = myDB.OpenRecordset("Preference", dbOpenDynaset, dbDenyWrite, dbOptimistic)     ' Open table exclusively
    dtcPref.MoveFirst   ' Move to the first record
    strCountryCode = CStr(dtcPref.Fields("CountryCode"))
    strNextSKUNumber = CStr(dtcPref.Fields("NextInvtSKU"))
    dtcPref.Edit        ' Declare an Edit event
    dtcPref.Fields("NextInvtSKU") = dtcPref.Fields("NextInvtSKU") + 1   ' Increment the SKU field
    dtcPref.Update      ' Update the SKU field value
    dtcPref.Close       ' Close table.
    myDB.Close          ' Close database.
    '
    ' End Fetch
    '
    
    '
    ' Compu the SKU Number as:
    ' CountryCode + Next SKU Number + Check Digit
    '
    strSKU = CompuBarCode_EAN8(strCountryCode, strNextSKUNumber)
    '
    ' End Compu
    '
    
    GetSKUNumber = strSKU   ' Return this number to caller
    
End Function

Public Function CompuBarCode_EAN8(varCountryCode As Variant, varArticalCode As Variant) As String

    Dim strEAN8 As String
    Dim i, iLength, intOdd, intEven, intCheckDigit As Integer
    
    ' Insert leading Zeros to Artical Code
    iLength = 5 - Len(varArticalCode)
    varArticalCode = String(iLength, "0") & varArticalCode
    
    ' Compu the Check Digit
    strEAN8 = varCountryCode & varArticalCode
    For i = 0 To 3
        intOdd = CInt(Mid(strEAN8, ((i * 2) + 1), 1)) + intOdd
    Next i
    For i = 0 To 2
        intEven = CInt(Mid(strEAN8, ((i * 2) + 2), 1)) + intEven
    Next i
    intCheckDigit = (10 - (((intOdd * 3) + intEven) Mod 10))
    If intCheckDigit = 10 Then
        intCheckDigit = 0
    End If
    
    ' Return the result
    CompuBarCode_EAN8 = strEAN8 & CStr(intCheckDigit)

End Function

Public Function GetDefaultClass_Lens() As String

    Dim strRetVal As String
    Dim myDB As Database, myRS As Recordset
    Dim MyCriteria As String
    MyCriteria = "Name = 'Lens'" ' Set the criteria.
    
    '
    ' Fetch the default lens code from Table Z_DefaultClass
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                       ' Open database
    Set myRS = myDB.OpenRecordset("Z_DefaultClass", dbOpenDynaset, dbConsistent, dbReadOnly) ' Open table exclusively
    myRS.FindFirst MyCriteria                   ' Find the record
    If Not myRS.NoMatch Then                    ' Check if record is found.
        strRetVal = myRS.Fields("Code")
    Else
        strRetVal = ""
    End If
    myRS.Close                          ' Close table.
    myDB.Close                          ' Close database.
    '
    ' End Fetch
    '
    
    GetDefaultClass_Lens = strRetVal    ' Return this number to caller
    
End Function

Public Function GetDefaultClass_Frame() As String

    Dim strRetVal As String
    Dim myDB As Database, myRS As Recordset
    Dim MyCriteria As String
    MyCriteria = "Name = 'Frame'" ' Set the criteria.
    
    '
    ' Fetch the default lens code from Table Z_DefaultClass
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                                   ' Open database
    Set myRS = myDB.OpenRecordset("Z_DefaultClass", dbOpenDynaset, dbConsistent, dbReadOnly)     ' Open table exclusively
    myRS.FindFirst MyCriteria         ' Find the record
    If Not myRS.NoMatch Then                    ' Check if record is found.
        strRetVal = myRS.Fields("Code")
    Else
        strRetVal = ""
    End If
    myRS.Close                          ' Close table.
    myDB.Close                          ' Close database.
    '
    ' End Fetch
    '
    
    GetDefaultClass_Frame = strRetVal    ' Return this number to caller
 
End Function

Public Function GetDefaultClass_ContactLens()

    Dim strRetVal As String
    Dim myDB As Database, myRS As Recordset
    Dim MyCriteria As String
    MyCriteria = "Name = 'Contact Lens'" ' Set the criteria.
    
    '
    ' Fetch the default lens code from Table Z_DefaultClass
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                                   ' Open database
    Set myRS = myDB.OpenRecordset("Z_DefaultClass", dbOpenDynaset, dbConsistent, dbReadOnly)    ' Open table exclusively
    myRS.FindFirst MyCriteria      ' Find the record
    If Not myRS.NoMatch Then                    ' Check if record is found.
        strRetVal = myRS.Fields("Code")
    Else
        strRetVal = ""
    End If
    myRS.Close                ' Close table.
    myDB.Close                          ' Close database.
    '
    ' End Fetch
    '
    
    GetDefaultClass_ContactLens = strRetVal    ' Return this number to caller
 
End Function

Public Function GetDefaultDept_Accessories() As String

    Dim strRetVal As String
    Dim myDB As Database, myRS As Recordset
    Dim MyCriteria As String
    MyCriteria = "Name = 'Accessories'" ' Set the criteria.
    
    '
    ' Fetch the default lens code from Table Z_DefaultClass
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                                   ' Open database
    Set myRS = myDB.OpenRecordset("Z_DefaultDept", dbOpenDynaset, dbForwardOnly, dbReadOnly)     ' Open table exclusively
    myRS.FindFirst MyCriteria         ' Find the record
    If Not myRS.NoMatch Then                    ' Check if record is found.
        strRetVal = myRS.Fields("Code")
    Else
        strRetVal = ""
    End If
    myRS.Close                          ' Close table.
    myDB.Close                          ' Close database.
    '
    ' End Fetch
    '
    
    GetDefaultDept_Accessories = strRetVal    ' Return this number to caller

End Function

Public Function GetDefaultClass_Service() As String

    Dim strRetVal As String
    Dim myDB As Database, myRS As Recordset
    Dim MyCriteria As String
    MyCriteria = "Name = 'Service'" ' Set the criteria.
    
    '
    ' Fetch the default lens code from Table Z_DefaultClass
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                                   ' Open database
    Set myRS = myDB.OpenRecordset("Z_DefaultClass", dbOpenDynaset, dbConsistent, dbReadOnly)    ' Open table exclusively
    myRS.FindFirst MyCriteria         ' Find the record
    If Not myRS.NoMatch Then                    ' Check if record is found.
        strRetVal = myRS.Fields("Code")
    Else
        strRetVal = ""
    End If
    myRS.Close                          ' Close table.
    myDB.Close                          ' Close database.
    '
    ' End Fetch
    '
    
    GetDefaultClass_Service = strRetVal    ' Return this number to caller

End Function


Public Function GetNextControlNumber() As String

    Dim strNextCN As String
    Dim myDB As Database, myRS As Recordset
    
    '
    ' Fetch and update the Next SKU Number from Table Preference
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                       ' Open database
    Set myRS = myDB.OpenRecordset("Preference", dbOpenDynaset, dbDenyRead, dbOptimistic)   ' Open table exclusively
    myRS.MoveFirst   ' Move to the first record
    strNextCN = CStr(myRS.Fields("NextInvtControlNumber"))
    myRS.Edit        ' Declare an Edit event
    myRS.Fields("NextInvtControlNumber") = myRS.Fields("NextInvtControlNumber") + 1   ' Increment the Control Number field
    myRS.Update      ' Update the SKU field value
    myRS.Close       ' Close table.
    myDB.Close       ' Close database.
    '
    ' End Fetch
    '
    
    '
    ' Insert leading Zero into the Control Number:
    '
    strNextCN = String((8 - Len(strNextCN)), "0") & strNextCN
    '
    ' End Compu
    '
    
    GetNextControlNumber = strNextCN   ' Return this number to caller

End Function

' Caller supplies the TxPrefix
' Returns the Next Tx Number completed with TxPrefix
Public Function GetNextTxNumber(MyTxPrefix As String) As String

    Dim MyNextTxNumber As String
    Dim myDB As Database, myRS As Recordset
    Dim MyCriteria As String
    MyCriteria = "TxPrefix = '" & MyTxPrefix & "'"      ' Set the criteria.
    
    '
    ' Fetch and update the Next SKU Number from Table Preference
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                       ' Open database
    Set myRS = myDB.OpenRecordset("PrefTxNumber", dbOpenDynaset, dbDenyWrite)    ' Open table exclusively
    myRS.FindFirst MyCriteria         ' Find the record
    If Not myRS.NoMatch Then                    ' Check if record is found.
        MyNextTxNumber = myRS.Fields("TxNextNumber")
    Else
        MyNextTxNumber = ""
    End If
    myRS.Edit        ' Declare an Edit event
    myRS.Fields("TxNextNumber") = myRS.Fields("TxNextNumber") + 1   ' Increment the Control Number field
    myRS.Update      ' Update the SKU field value
    myRS.Close       ' Close table.
    myDB.Close       ' Close database.
    '
    ' End Fetch
    '
    
    '
    ' Insert leading Zero into the Tx Number:
    '
    MyNextTxNumber = String((8 - Len(MyNextTxNumber)), "0") & MyNextTxNumber
    MyNextTxNumber = MyTxPrefix & MyNextTxNumber
    '
    ' End Compu
    '
    
    GetNextTxNumber = MyNextTxNumber        ' Return this number to caller

End Function

Public Sub AutoSelect(Target As Control)
    If TypeOf Target Is MaskEdBox Then
        Target.SelStart = 0
        Target.SelLength = Target.MaxLength
    Else
        Target.SelStart = 0
        Target.SelLength = Len(Target.Text)
    End If
End Sub

Public Sub ClearDBComboHiLite(Caller As Form)
    Dim i As Integer
    
    For i = 0 To (Caller.Controls.Count - 1)
        If TypeOf Caller.Controls(i) Is DBCombo Then
            Caller.Controls(i).SelLength = 0
        End If
    Next i
End Sub

Public Sub SetCursorToHand()
    Dim strHandIconPic As String
    
    strHandIconPic = App.Path & "/Graphics/Hand.ico"
    Screen.MouseIcon = LoadPicture(strHandIconPic)
    Screen.MousePointer = vbCustom
End Sub

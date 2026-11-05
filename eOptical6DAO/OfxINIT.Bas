Attribute VB_Name = "OfxInitExit"
'------------------------------------------------------------------------
' Module:   Ofx - Init & Exit
'
' Purpose:  Application initialization and exit routines.
'------------------------------------------------------------------------

Option Compare Text
Option Explicit

Public Const ofxSplashShow As Integer = 1
Public Const ofxSplashStartupSuccess As Integer = 2
Public Const ofxSplashStartupClose As Integer = 3


'------------------------------------------------------------------------
' Sub:      Main
'
' Purpose:  Application entry point.
'
' Notes:    Basically, this is the normal order of events in an application
'           that is NOT automated ONLY:
'
'           1. ofx_Initialize()     this module
'           2. DoSplash()           AppMain.bas - (Can be overridden)
'           3. InitInstance()       AppMain.bas - (Can be overridden)
'           4. The main form is loaded  (frmMain, either AppSDI.frm or AppMDI.frm)
'           5. Main form is destroyed   (frmMain, either AppSDI.frm or AppMDI.frm)
'           6. ofx_OnFinalUnload()  this module, called by frmMain.Form_Unload()
'           7. ExitInstance         AppMain.bas - (Can be overridden)  (This function must return True or the Exit process is stopped)
'           8. ofx_Uninitialize     this module
'           9. End
'
'------------------------------------------------------------------------
Sub Main()
    On Error Resume Next                'have to just ignore any errors
    
    If (ofx_Initialize()) Then
        
        Dim nDummy As Integer
        ' let this app decide on the splash
        nDummy = DoSplash(ofxSplashShow)
        
        If (InitInstance()) Then
            nDummy = DoSplash(ofxSplashStartupSuccess)
        Else
            'abnormal termination
            ofx_AppAbort
        End If
        
    End If
End Sub




'------------------------------------------------------------------------
' Function: ofx_Initialize
'
' Purpose:  Initialize the Start Developing for Visual Basic framework.
'
' Returns:  TRUE on success, else FALSE
'
' Notes:    This function should ALWAYS be the first called in an application
'           using the framework.
'
' See also: ofx_Unitialize()
'------------------------------------------------------------------------
Public Function ofx_Initialize() As Integer
    On Error GoTo ofx_Initialize_Err

    'If this app was built with the AppWizard and the "Run ONLY as a server" was selected,
    'then set the StartMode == server which will prevent the main form from being displayed.
#If OFXOPT_SERVERONLY Then
    ofxApp.bRunAutomated = (App.StartMode = 1)
#Else
    ofxApp.bRunAutomated = False
#End If
    
#If Not VB3 Then
    ofxApp.sAppName = App.ProductName
    ofxApp.sCompany = App.CompanyName
#End If

    ofxApp.sIniFile = App.EXEName & ".INI"
    
    ' Root registry key (Win32)
    ofxApp.sRegKeyRoot = ofxApp.sAppName
    
    ofx_InitErrorLog
    ofx_InitEventLog
        
    ofx_Initialize = True

ofx_Initialize_Exit:
    On Error Resume Next
    Exit Function
ofx_Initialize_Err:
    MsgBox Error                    'Don't call GenericError here
    Resume ofx_Initialize_Exit
End Function



'------------------------------------------------------------------------
' Sub:      ofx_Uninitialize
'
' Purpose:  Uninitialize (cleanup) the Start Developing for Visual Basic
'           framework.
'
' Notes:    This function should ALWAYS be the last called in an application
'           using the framework.
'
' See also: ofx_Initialize()
'------------------------------------------------------------------------
Public Sub ofx_Uninitialize()
    On Error Resume Next

#If OFXOPT_AUTOMATION Then
    Set ofxApp.oWord = Nothing
    Set ofxApp.oExcel = Nothing
    Set ofxApp.oProject = Nothing
    Set ofxApp.oAccess = Nothing
#End If

#If Win32 And OFXOPT_INET Then
    If (ofxApp.hInternetSession) Then
        ofx_InetCloseSession ofxApp.hInternetSession
        ofxApp.hInternetSession = 0&
    End If
#End If

#If DBOPT_ODBC Then
    'This will free the ODBC environment handle.
    Set ofxApp.dbState = Nothing
#End If

#If DBOPT_VBSQL Then
    ' This call unloads the SQL Server libraries from memory.
    ' If you want to logon in an application after you have called this,
    ' you must call the initialiation procedure again - SQLInit() before
    ' attempting the logon sequence.
    SqlExit
    SQLWINExit
#End If

#If OFXOPT_OFFICEBOOK Then
    ofx_OfbkUninitialize
#End If

End Sub




#If Not VB3 And DBG Then
'------------------------------------------------------------------------
' Sub:      ASSERT
'
' Purpose:  During development, generate a message box when a designated
'           error condition occurs.
'
' Params:   bExpr       (I) Generate message if this expression is FALSE
'           Messages    (I) Message line(s) if expression is FALSE
'
' Notes:    By convention, the Framework uses the first element of the Messages() array as
'           the procedure name.
'
'           The most typical use of the ASSERT macro is to identify program errors during development.
'           The argument given to ASSERT should be chosen so that it holds true only
'           if the program is operating as intended.
'           The function evaluates the ASSERT argument and,
'           if the argument expression is False, alerts the user and
'           breaks the program into the debugging environment.
'           No action is taken if the argument is true (nonzero).
'
'           The liberal use of assertions throughout your programs can catch errors
'           during development. A good rule of thumb is that you should write assertions
'           for any assumptions you make.
'           For example, if you assume that an object variable has been "set" before
'           you use it, use an assertion statement to check for that condition.
'------------------------------------------------------------------------
Public Sub ASSERT(bExpr As Boolean, ParamArray Messages() As Variant)

Const sAssert = "Assertion Failed."
        
    If (False = bExpr) Then
    
        Dim sMsg As String
        
        sMsg = sAssert
        If (UBound(Messages) >= 0) Then
        
            'first element is the procecure name
            sMsg = sMsg & ofx_CRLF() & "Procedure: " & Messages(0)
        
            Dim i As Long
            For i = 1 To UBound(Messages)
                sMsg = sMsg & ofx_CRLF() & Messages(i)
            Next
        
            MsgBox sMsg
        End If
        
        'should be debugging (DBG == True)
        'so press F8 to return to the procedure that caused the assertion
        Stop
        
    End If
    

End Sub
#End If


'------------------------------------------------------------------------
' Function: ofx_OnFinalUnload
'
' Purpose:  Performs application clean-up.  Should be called from the main
'           form's Form_Unload() event.
'
' Params:   frm     (I) The form that is being unloaded.  This value is
'                       passed to the ExitInstance() procedure.
'
' Returns:  TRUE if unload not canceled, else FALSE.
'
' Notes:    This function begins the application exit process.  It will only
'           continue (and end the application if the function ExitInstance
'           returns True.  (This gives the developer to prompt for unsaved
'           files, get missing data from the user, etc.)
'
'           If you built this application with the AppWizard, then this
'           function is called in the frmMain.Form_Unload() event.  If not,
'           you should put this function in the Form_Unload event of the
'           application's final form.
'------------------------------------------------------------------------
Function ofx_OnFinalUnload(frm As Form) As Boolean
    On Error Resume Next
    
    If (ExitInstance(frm)) Then
        ofx_OnFinalUnload = True
        
        'Only 'end' if we are running stand-alone!
        'Otherwise, the End (and ofx_Uninitialize) will be called
        'from the Application class Class_Terminate Function
        If (Not (ofxApp.bRunAutomated)) Then
            'clean-up!
            ofx_Uninitialize
            End
        End If
        
    End If
    
End Function



'------------------------------------------------------------------------
' Sub:      ofx_AppAbort
'
' Purpose:  Handles abnormal termination.
'
' Notes:    This function is called when InitInstance fails (returns False).
'------------------------------------------------------------------------
Private Sub ofx_AppAbort()
    On Error Resume Next
    Dim nDummy As Integer
    nDummy = ExitInstance(Nothing)
    ofx_Uninitialize
    End
End Sub

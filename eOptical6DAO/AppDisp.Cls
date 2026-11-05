VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Application"
Attribute VB_Creatable = True
Attribute VB_Exposed = True
'------------------------------------------------------------------------------
' Module:   Application
'
' Purpose:  The Public OLE Automation interface to this application.
'
' Notes:    To use this class properly, you should structure you code as follows:
'
'           Dim sdvbApp as Object
'           Set sdvbApp = CreateObject("MyApp.Application")
'
'           If (sdvbApp.Initialize(...)) Then
'
'               'TO DO:  Manipulate the application with methods and properties you add to this class
'
'               sdvbApp.Uninitialize
'               Set sdvbApp = Nothing
'           End If
'------------------------------------------------------------------------------
Option Explicit

Private m_bInitialzed As Boolean

Const dispErrNotInitialized = 1
Const dispErrBadParam = 2

'------------------------------------------------------------------------------
' Method:   Uninitialize
'
' Purpose:  Cleans up this instance of the application.
'
' TO DO:    Add any application specific cleanup here
'------------------------------------------------------------------------------
Public Sub Uninitialize()
    On Error Resume Next        'no errors, no UI
    
    'Only call once
    Static bTerm As Boolean
    If (bTerm) Then Exit Sub
    bTerm = True
    
    'Unload the main form, in case it was displayed modeless
    Unload frmMain
    
    ofxApp.hWndParent = 0&
    ofxApp.bRunAutomated = False
    'TO DO:  Add cleanup code HERE
    
    'The ofx_OnFinalUnload will NOT End the app.
    ofx_Uninitialize
    End
    
End Sub
'------------------------------------------------------------------------------
' Method:   Initialize
'
' Purpose:  Initialize the class.
'
' Notes:    This should be the FIRST method called on the object.  It
'           allows you to perform application specific initialization and
'           receive a return value (to the caller) to indicate success or failure.
'
' TO DO:    Add any application specific parameters to this function.
'           For performance reasons, it is normally better to construct
'           a class using a single Method call with a bunch of parameters, rather
'           that exposing a bunch of properties to the caller.
'------------------------------------------------------------------------------
Public Function Initialize(ParamArray vargs() As Variant) As Boolean
    On Error GoTo Initialize_Error

    'TO DO: Add specific initialization HERE
    
    
    'Only return True if everything was properly initialized
    m_bInitialzed = True
    Initialize = True
    
Initialize_Exit:
    Exit Function
Initialize_Error:
    Call ofx_GenericError("Initialize()", Err)
    Resume Initialize_Exit
End Function

'------------------------------------------------------------------------------
' Method:   ShowMainForm
'
' Purpose:  Displays the main form (of type frmMain)
'
' Notes:    The AppWizard will set the OFXOPT_SERVERONLY conditional compilation flag
'           if you choose the 'Make this app an OLE server'
'           feature with the 'Run ONLY as a server application' option selected.
'           This causes the Main form (frmMain to NOT be shown in the InitInstance
'           function (by default).
'
'           So, here we are creating a NEW instance of the main form, then showing it with the
'           nShow option, care should be taken here, however, because if the main form happens
'           to be a MDI parent, then you CAN NOT show it Modally (nShow = vbModal)
'------------------------------------------------------------------------------
Public Function ShowMainForm(hWnd As Long, Optional ovnShow As Variant) As Boolean
    On Error Resume Next
    
    Dim nShow As Integer
    #If Not OFXOPT_MDI Then
        If (Not (IsMissing(ovnShow))) Then
            nShow = CInt(ovnShow)
        Else
            nShow = vbModal
        End If
    #Else
        nShow = vbModeless
    #End If
    
    
    If (Not (m_bInitialzed)) Then
        Err.Clear
        Err.Raise dispErrNotInitialized, App.Title, "Class has not been initialized, call <class>.Initialize() first."
    End If
    
    If (Not (nShow = vbModal Or nShow = vbModeless)) Then
        Err.Raise vbObjectError + dispErrBadParam, App.Title, "Bad parameter value."
    End If
    
    If (vbModal = nShow) Then
        ofxApp.hWndParent = hWnd
    End If
    
    frmMain.Show nShow
    
    ' TO DO:  return some meaningful value to the caller
    ' Note that if the form is NOT modal, then this function returns immediately
    ShowMainForm = True
    
End Function

'------------------------------------------------------------------------------
' Method:   Class_Initialize
'
' Purpose:  Initializes this instance of the Application object.
'
' Notes:    This implementation assumes that the next function you call will be the
'           Initialize function.
'------------------------------------------------------------------------------
Private Sub Class_Initialize()
    On Error Resume Next
    m_bInitialzed = False
End Sub

'------------------------------------------------------------------------------
' Method:   Class_Terminate
'
' Purpose:  End this instance of the class.
'
' Notes:    While debugging from within another VisualBasic application,
'           THIS FUNCTION MAY NEVER BE CALLED.
'           This is not usually a problem with a 'compiled' version.
'           For this reason, it may be helpful just to call the Uninitialize method
'           (at least while debugging).
'------------------------------------------------------------------------------
Private Sub Class_Terminate()
    On Error Resume Next
    Uninitialize
End Sub


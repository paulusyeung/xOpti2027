VERSION 4.00
Begin VB.MDIForm frmMain 
   BackColor       =   &H00C0C0C0&
   Caption         =   "Start Developing"
   ClientHeight    =   5070
   ClientLeft      =   2445
   ClientTop       =   2325
   ClientWidth     =   7350
   Height          =   5760
   Icon            =   "APPMDI.frx":0000
   Left            =   2385
   LinkTopic       =   "MDIForm1"
   Top             =   1695
   Width           =   7470
   Begin ComctlLib.Toolbar toolMain 
      Align           =   1  'Align Top
      Height          =   390
      Left            =   0
      TabIndex        =   1
      Top             =   0
      Width           =   7350
      _Version        =   65536
      _ExtentX        =   12965
      _ExtentY        =   688
      _StockProps     =   96
      ImageList       =   "imglstMain"
      ButtonWidth     =   609
      NumButtons      =   7
      i1              =   "APPMDI.frx":0442
      i2              =   "APPMDI.frx":05E5
      i3              =   "APPMDI.frx":0784
      i4              =   "APPMDI.frx":092F
      i5              =   "APPMDI.frx":0ACE
      i6              =   "APPMDI.frx":0C8D
      i7              =   "APPMDI.frx":0E54
      AlignSet        =   -1  'True
   End
   Begin ComctlLib.StatusBar statMain 
      Align           =   2  'Align Bottom
      Height          =   270
      Left            =   0
      TabIndex        =   0
      Top             =   4800
      Width           =   7350
      _Version        =   65536
      _ExtentX        =   12965
      _ExtentY        =   476
      _StockProps     =   68
      AlignSet        =   -1  'True
      SimpleText      =   ""
      i1              =   "APPMDI.frx":101B
   End
   Begin ComctlLib.ImageList imglstMain 
      Left            =   5340
      Top             =   450
      _Version        =   65536
      _ExtentX        =   1005
      _ExtentY        =   1005
      _StockProps     =   1
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      NumImages       =   5
      i1              =   "APPMDI.frx":1127
      i2              =   "APPMDI.frx":12DE
      i3              =   "APPMDI.frx":1495
      i4              =   "APPMDI.frx":164C
      i5              =   "APPMDI.frx":1803
   End
   Begin VB.Menu MenuFileTop 
      Caption         =   "&File"
      Begin VB.Menu MenuFile 
         Caption         =   "&New"
         Index           =   0
         Shortcut        =   ^N
      End
      Begin VB.Menu MenuFile 
         Caption         =   "&Open"
         Index           =   1
         Shortcut        =   ^O
      End
      Begin VB.Menu MenuFile 
         Caption         =   "&Close"
         Index           =   2
         Shortcut        =   ^{F4}
      End
      Begin VB.Menu MenuFile 
         Caption         =   "-"
         Index           =   3
      End
      Begin VB.Menu MenuFile 
         Caption         =   "E&xit"
         Index           =   6
      End
   End
   Begin VB.Menu MenuViewTop 
      Caption         =   "&View"
      Begin VB.Menu MenuView 
         Caption         =   "&Toolbar"
         Checked         =   -1  'True
         Index           =   0
      End
      Begin VB.Menu MenuView 
         Caption         =   "&Status Bar"
         Checked         =   -1  'True
         Index           =   1
      End
   End
   Begin VB.Menu MenuHelpTop 
      Caption         =   "&Help"
      Begin VB.Menu MenuHelp 
         Caption         =   "&About"
         Index           =   0
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Option Explicit


'Number of child forms
Private m_nChildCount As Integer


'------------------------------------------------------------------------
' Sub:      HandleMenuClick
'
' Purpose:  Central location for handling all menu clicks, toolbar selections,
'           etc. We handle them here rather that in each menu handler so that
'           toolbar events can be single-sourced with menu clicks.
'
' Params:   nItem   (I) ID of menu item to handle
'------------------------------------------------------------------------
Public Sub HandleMenuClick(nItem As Integer)
    On Error GoTo HandleMenuClick_Exit
    
    Dim nDummy As Integer
    
    Select Case nItem
        Case idMenuFileOpen
            nDummy = OnFileOpen(Me)
            
        Case idMenuFileNew
            'simple (example) implementation of File New
            Dim frm As New frmMDIChild
            m_nChildCount = m_nChildCount + 1
            frm.Caption = "Child(" & m_nChildCount & ")"
            frm.Show vbModeless
                            
        Case idMenuAbout
            nDummy = ofx_DoModal(dlgAbout)
            
        Case idMenuExit
            'exit, DO NOT 'End' here, the framework will exit the application
            Unload Me
            
        Case idMenuToolbar
            toolMain.Visible = Not toolMain.Visible
            nDummy = ofx_ProfileWriteBool("Options", ofx_GetFormName(Me) & "_TOOLBAR", (toolMain.Visible))
            
        Case idMenuStatusbar
            statMain.Visible = Not statMain.Visible
            nDummy = ofx_ProfileWriteBool("Options", ofx_GetFormName(Me) & "_STATUSBAR", (statMain.Visible))
                   
        '----- MDI specific
        Case idMenuTileHoriz
            Me.Arrange vbTileHorizontal
        Case idMenuTileVert
            Me.Arrange vbTileVertical
        Case idMenuCascade
            Me.Arrange vbCascade

            
    End Select
HandleMenuClick_Exit:                                ' SDVB
    On Error Resume Next                             ' SDVB
    Exit Sub                                         ' SDVB
HandleMenuClick_Err:                                 ' SDVB
    Call ofx_GenericError("HandleMenuClick()", Err)  ' SDVB
    Resume HandleMenuClick_Exit                      ' SDVB
End Sub







Private Sub MDIForm_Load()
    On Error GoTo MDIForm_Load_Error
    
    Call ofx_CenterForm(Me)
    
    ZOrder 1
    
    toolMain.Visible = ofx_ProfileGetBool("Options", ofx_GetFormName(Me) & "_TOOLBAR", True)
    statMain.Visible = ofx_ProfileGetBool("Options", ofx_GetFormName(Me) & "_STATUSBAR", True)
    
    MenuFile(6).Caption = MenuFile(6).Caption & Chr$(9) & "Alt+F4"
    
    If (ofxApp.hWndParent And ofxApp.bRunAutomated) Then
        Call ofx_SetForegroundWindow(Me.hWnd)
    End If
    
    Me.Tag = 0
   
MDIForm_Load_Exit:
    Exit Sub
MDIForm_Load_Error:
    Call ofx_GenericError("MDIForm_Load()", Err)
    Resume MDIForm_Load_Exit
End Sub


Private Sub MDIForm_Unload(Cancel As Integer)
    On Error Resume Next
    
    Dim nDummy As Integer

    Cancel = (Not (ofx_OnFinalUnload(Me)))
    
    If (Not (Cancel)) Then
        If (ofxApp.hWndParent And ofxApp.bRunAutomated) Then
            Call ofx_SetForegroundWindow(ofxApp.hWndParent)
        End If
    End If
    
End Sub

Private Sub MenuFile_Click(Index As Integer)
    On Error Resume Next
    
    Select Case Index
        Case 0
            Call HandleMenuClick(idMenuFileNew)
        Case 1
            Call HandleMenuClick(idMenuFileOpen)
        Case 2
            Call HandleMenuClick(idMenuFileClose)
        Case 6
            Call HandleMenuClick(idMenuExit)
    End Select
End Sub

Private Sub MenuFileTop_Click()
    On Error Resume Next
    MenuFile(2).Enabled = (ofx_MDIChildCount() > 0)
End Sub


Private Sub MenuHelp_Click(Index As Integer)
    On Error Resume Next
    
    Select Case Index
        Case 0
            Call HandleMenuClick(idMenuAbout)
    End Select
End Sub


Private Sub MenuView_Click(Index As Integer)
    On Error Resume Next
    Select Case Index
        Case 0
            Call HandleMenuClick(idMenuToolbar)
            MenuView(Index).Checked = Not (MenuView(Index).Checked)
        Case 1
            Call HandleMenuClick(idMenuStatusbar)
            MenuView(Index).Checked = Not (MenuView(Index).Checked)
    End Select
End Sub

Public Sub MenuViewTop_Click()
    On Error Resume Next
    Me.MenuView(0).Checked = toolMain.Visible
    Me.MenuView(1).Checked = statMain.Visible
End Sub

Private Sub toolMain_ButtonClick(ByVal Button As Button)
    On Error Resume Next
    
    Select Case Button.Key
        Case "filenew"
            Call HandleMenuClick(idMenuFileNew)
        Case "fileopen"
            Call HandleMenuClick(idMenuFileOpen)
        Case "cut"
            Call HandleMenuClick(idMenuCut)
        Case "copy"
            Call HandleMenuClick(idMenuCopy)
        Case "paste"
            Call HandleMenuClick(idMenuPaste)
    End Select
End Sub





#If DBOPT_VBSQL Then
'------------------------------------------------------------------------------
' Sub:      Vbsql1_Error
'
' Purpose:  Handles errors produced by DB-library
'
' See also: The OfxVBSql.bas module for a fuller explanation.
'------------------------------------------------------------------------------
#If Win32 Then
Private Sub VBSQL1_Error(ByVal SqlConn As Long, ByVal Severity As Long, ByVal ErrorNum As Long, ByVal ErrorStr As String, ByVal OSErrorNum As Long, ByVal OSErrorStr As String, RetCode As Long)
    ofx_sqlSetLastError SqlConn, Severity, ErrorNum, ErrorStr, OSErrorNum, OSErrorStr
End Sub
#Else
Private Sub VBSQL1_Error(SqlConn As Integer, Severity As Integer, ErrorNum As Integer, ErrorStr As String, RetCode As Integer)
    ofx_sqlSetLastError SqlConn, Severity, ErrorNum, ErrorStr, 0, ""
End Sub
#End If
'------------------------------------------------------------------------------
' Sub:      Vbsql1_Message
'
' Purpose:  Handles messages produced by DB-library
'
' See also: The OfxVBSql.bas module for a fuller explanation.
'------------------------------------------------------------------------------
#If Win32 Then
Private Sub VBSQL1_Message(ByVal SqlConn As Long, ByVal Message As Long, ByVal State As Long, ByVal Severity As Long, ByVal MsgStr As String, ByVal ServerNameStr As String, ByVal ProcNameStr As String, ByVal Line As Long)
    ofx_sqlSetLastMessage SqlConn, Message, State, Severity, MsgStr, ServerNameStr, ProcNameStr, Line
End Sub
#Else
Private Sub VBSQL1_Message(SqlConn As Integer, Message As Long, State As Integer, Severity As Integer, MsgStr As String)
    ofx_sqlSetLastMessage SqlConn, Message, State, Severity, MsgStr, "", "", 0
End Sub
#End If         'Win32
#End If         'OFXOPT_VBSQL


Private Sub toolMain_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    On Error Resume Next
    ' We set focus here as a workaround to a known bug in Visual Basic 4.0 32-bit.
    ' See Microsoft article Q145677 "BUG: Arrow and Tab keys Stop Working in MDI Child Form"
    Me.SetFocus
End Sub

'------------------------------------------------------------------------------
' Sub:      UpdateControlBars
'
' Purpose:  Updates the Toolbar and Status bar "view" state from the registry.
'
'------------------------------------------------------------------------------
Public Sub UpdateControlBars()
    #If Win32 Then
        Me.toolMain.Visible = ofx_ProfileGetBool("Options", ofx_GetFormName(Me) & "_TOOLBAR", True)
        Me.statMain.Visible = ofx_ProfileGetBool("Options", ofx_GetFormName(Me) & "_STATUSBAR", True)
        MenuView(0).Checked = toolMain.Visible
        MenuView(1).Checked = statMain.Visible
    #End If
End Sub

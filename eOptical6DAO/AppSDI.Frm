VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Begin VB.Form frmMain 
   Caption         =   "Synergy V for Optical"
   ClientHeight    =   7935
   ClientLeft      =   1020
   ClientTop       =   2505
   ClientWidth     =   11880
   Icon            =   "AppSDI.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   7935
   ScaleWidth      =   11880
   WindowState     =   2  'Maximized
   Begin MSComctlLib.Toolbar toolMain 
      Align           =   1  'Align Top
      Height          =   390
      Left            =   0
      TabIndex        =   1
      Top             =   0
      Width           =   11880
      _ExtentX        =   20955
      _ExtentY        =   688
      ButtonWidth     =   609
      ButtonHeight    =   582
      ImageList       =   "ImageList1"
      _Version        =   393216
      BeginProperty Buttons {66833FE8-8583-11D1-B16A-00C0F0283628} 
         NumButtons      =   5
         BeginProperty Button1 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "fileopen"
            Object.ToolTipText     =   "Open"
            ImageIndex      =   1
         EndProperty
         BeginProperty Button2 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            ImageIndex      =   2
            Style           =   3
         EndProperty
         BeginProperty Button3 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "cut"
            Object.ToolTipText     =   "Cut"
            ImageIndex      =   2
         EndProperty
         BeginProperty Button4 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "copy"
            Object.ToolTipText     =   "Copy"
            ImageIndex      =   3
         EndProperty
         BeginProperty Button5 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "paste"
            Object.ToolTipText     =   "Paste"
            ImageIndex      =   4
         EndProperty
      EndProperty
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar tbrMainMenu 
      Align           =   1  'Align Top
      Height          =   990
      Left            =   0
      TabIndex        =   2
      Top             =   390
      Width           =   11880
      _Version        =   131073
      _ExtentX        =   20955
      _ExtentY        =   1747
      _StockProps     =   69
      BackColor       =   12632256
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      FloatingCaption =   "tbrMainMenu"
      AlreadyCreated  =   -1  'True
      BevelOuter      =   0
      ToolsetNumBtnStates=   4
      BorderWidth     =   0
      BtnMarginX      =   0
      BtnMarginY      =   0
      BevelWidth      =   0
      Btns            =   8
      ToolsetPicture  =   "AppSDI.frx":068A
      BC              =   8
      BtnToolNum(0)   =   0
      BtnPlaceHolder(0)=   0   'False
      BtnToolNum(1)   =   1
      BtnPlaceHolder(1)=   0   'False
      BtnToolNum(2)   =   2
      BtnPlaceHolder(2)=   0   'False
      BtnToolNum(3)   =   3
      BtnPlaceHolder(3)=   0   'False
      BtnToolNum(4)   =   4
      BtnPlaceHolder(4)=   0   'False
      BtnToolNum(5)   =   5
      BtnPlaceHolder(5)=   0   'False
      BtnToolNum(6)   =   6
      BtnPlaceHolder(6)=   0   'False
      BtnToolNum(7)   =   7
      BtnVisible(7)   =   0   'False
      BtnPlaceHolder(7)=   0   'False
      ToolsetNumTools =   8
      ToolsetToolID(0)=   "ID_PoS"
      ToolsetToolMnemonic(0)=   "p"
      ToolsetToolGroup(0)=   1
      ToolsetToolAllowAllUp(0)=   -1  'True
      ToolsetToolType(0)=   1
      ToolsetToolExclusive(0)=   -1  'True
      ToolsetToolID(1)=   "ID_IC"
      ToolsetToolMnemonic(1)=   "i"
      ToolsetToolGroup(1)=   1
      ToolsetToolAllowAllUp(1)=   -1  'True
      ToolsetToolType(1)=   1
      ToolsetToolExclusive(1)=   -1  'True
      ToolsetToolID(2)=   "ID_OLAP"
      ToolsetToolMnemonic(2)=   "o"
      ToolsetToolGroup(2)=   1
      ToolsetToolAllowAllUp(2)=   -1  'True
      ToolsetToolType(2)=   1
      ToolsetToolExclusive(2)=   -1  'True
      ToolsetToolID(3)=   "ID_InfoCentre"
      ToolsetToolMnemonic(3)=   "f"
      ToolsetToolGroup(3)=   1
      ToolsetToolAllowAllUp(3)=   -1  'True
      ToolsetToolType(3)=   1
      ToolsetToolExclusive(3)=   -1  'True
      ToolsetToolID(4)=   "ID_Coding"
      ToolsetToolMnemonic(4)=   "c"
      ToolsetToolGroup(4)=   1
      ToolsetToolAllowAllUp(4)=   -1  'True
      ToolsetToolType(4)=   1
      ToolsetToolExclusive(4)=   -1  'True
      ToolsetToolID(5)=   "ID_Report"
      ToolsetToolMnemonic(5)=   "r"
      ToolsetToolGroup(5)=   1
      ToolsetToolAllowAllUp(5)=   -1  'True
      ToolsetToolType(5)=   1
      ToolsetToolExclusive(5)=   -1  'True
      ToolsetToolID(6)=   "ID_Preference"
      ToolsetToolMnemonic(6)=   "e"
      ToolsetToolGroup(6)=   1
      ToolsetToolAllowAllUp(6)=   -1  'True
      ToolsetToolType(6)=   1
      ToolsetToolExclusive(6)=   -1  'True
      ToolsetToolID(7)=   "ID_Utility"
      ToolsetToolMnemonic(7)=   "u"
      ToolsetToolGroup(7)=   1
      ToolsetToolAllowAllUp(7)=   -1  'True
      ToolsetToolType(7)=   1
      ToolsetToolExclusive(7)=   -1  'True
      MouseIcon       =   "AppSDI.frx":20ADC
   End
   Begin Threed.SSFrame fraUserLogon 
      Height          =   1635
      Left            =   9240
      TabIndex        =   4
      Top             =   4920
      Visible         =   0   'False
      Width           =   2535
      _ExtentX        =   4471
      _ExtentY        =   2884
      _Version        =   131074
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "User Logon"
      Begin VB.TextBox txtPassword 
         Height          =   315
         IMEMode         =   3  'DISABLE
         Left            =   960
         MaxLength       =   10
         PasswordChar    =   "*"
         TabIndex        =   8
         Top             =   720
         Width           =   1335
      End
      Begin VB.TextBox txtUserID 
         Height          =   315
         Left            =   960
         MaxLength       =   10
         TabIndex        =   6
         Top             =   360
         Width           =   1335
      End
      Begin Threed.SSCommand cmdCancel 
         Height          =   375
         Left            =   1320
         TabIndex        =   10
         Top             =   1140
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   661
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "Cancel"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdOK 
         Height          =   375
         Left            =   240
         TabIndex        =   9
         Top             =   1140
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   661
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "OK"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label2 
         Caption         =   "Password"
         Height          =   255
         Left            =   120
         TabIndex        =   7
         Top             =   720
         Width           =   735
      End
      Begin VB.Label Label1 
         Caption         =   "User ID"
         Height          =   255
         Left            =   120
         TabIndex        =   5
         Top             =   360
         Width           =   735
      End
   End
   Begin MSComctlLib.StatusBar statMain 
      Align           =   2  'Align Bottom
      Height          =   300
      Left            =   0
      TabIndex        =   0
      Top             =   7635
      Width           =   11880
      _ExtentX        =   20955
      _ExtentY        =   529
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   1
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   20426
         EndProperty
      EndProperty
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
   Begin MSComctlLib.ImageList ImageList1 
      Left            =   2640
      Top             =   -120
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   4
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "AppSDI.frx":20AF8
            Key             =   ""
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "AppSDI.frx":20C0A
            Key             =   ""
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "AppSDI.frx":20D1C
            Key             =   ""
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "AppSDI.frx":20E2E
            Key             =   ""
         EndProperty
      EndProperty
   End
   Begin Threed.SSCommand cmdUserLogo 
      Height          =   4275
      Left            =   3360
      TabIndex        =   3
      TabStop         =   0   'False
      Top             =   2280
      Width           =   5655
      _ExtentX        =   9975
      _ExtentY        =   7541
      _Version        =   131074
      Font3D          =   2
      PictureFrames   =   1
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Picture         =   "AppSDI.frx":20F40
      AutoSize        =   1
      ButtonStyle     =   2
      BevelWidth      =   10
      Outline         =   0   'False
   End
   Begin VB.Menu MenuFileTop 
      Caption         =   "&File"
      Index           =   0
      Begin VB.Menu MenuFile 
         Caption         =   "&New..."
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
         Caption         =   "&Send..."
         Index           =   4
      End
      Begin VB.Menu MenuFile 
         Caption         =   "-"
         Index           =   5
      End
      Begin VB.Menu MenuFile 
         Caption         =   "E&xit"
         Index           =   6
      End
   End
   Begin VB.Menu MenuEditTop 
      Caption         =   "&Edit"
      Index           =   1
      Begin VB.Menu MenuEdit 
         Caption         =   "Cu&t"
         Index           =   0
         Shortcut        =   ^X
      End
      Begin VB.Menu MenuEdit 
         Caption         =   "&Copy"
         Index           =   1
         Shortcut        =   ^C
      End
      Begin VB.Menu MenuEdit 
         Caption         =   "&Paste"
         Index           =   2
         Shortcut        =   ^V
      End
   End
   Begin VB.Menu MenuViewTop 
      Caption         =   "&View"
      Index           =   2
      Begin VB.Menu MenuView 
         Caption         =   "&Toolbar"
         Index           =   0
      End
      Begin VB.Menu MenuView 
         Caption         =   "&Status bar"
         Index           =   1
      End
   End
   Begin VB.Menu MenuToolsTop 
      Caption         =   "&Tools"
      Begin VB.Menu MenuTools 
         Caption         =   "&Options..."
         Index           =   0
      End
      Begin VB.Menu MenuTools 
         Caption         =   "-"
         Index           =   1
      End
      Begin VB.Menu MenuTools 
         Caption         =   "Office Boo&k..."
         Index           =   2
         Shortcut        =   ^K
      End
   End
   Begin VB.Menu MenuHelpTop 
      Caption         =   "&Help"
      Index           =   3
      Begin VB.Menu MenuHelp 
         Caption         =   "&About"
         Index           =   0
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Const idMenuFileOpen As Integer = 1001
Private Const idMenuFileClose As Integer = 1002
Private Const idMenuExit As Integer = 1003
Private Const idMenuCut As Integer = 1004
Private Const idMenuCopy As Integer = 1005
Private Const idMenuPaste As Integer = 1006
Private Const idMenuAbout As Integer = 1007
Private Const idMenuFileSend As Integer = 1008
Private Const idMenuToolbar As Integer = 1009
Private Const idMenuStatusbar As Integer = 1010
Private Const idMenuFileNew As Integer = 1011
Private Const idMenuToolsOptions As Integer = 1012
Private Const idMenuToolsOfficeBook As Integer = 1013

Dim LogonTries As Integer
'------------------------------------------------------------------------
' Sub:      HandleMenuClick
'
' Purpose:  Central location for handling all menu clicks, toolbar selections,
'           etc. We handle them here rather that in each menu handler so that
'           toolbar events can be single-sourced with menu clicks.
'
' Params:   nItem   (I) ID of menu item to handle
'------------------------------------------------------------------------
Private Sub HandleMenuClick(nItem As Integer)
    On Error GoTo HandleMenuClick_Err                ' SDVB
    
    Dim nDummy As Integer

    Select Case nItem
        Case idMenuFileOpen
            nDummy = OnFileOpen(Me)
            
        Case idMenuFileNew
            nDummy = OnFileNew(Me)
            
        Case idMenuFileClose
            nDummy = OnFileClose(Me)
            
        Case idMenuFileSend
            #If OFXOPT_MAPI Then
                nDummy = OnFileSend(Me)
            #End If
            
        Case idMenuAbout
            nDummy = ofx_DoModal(dlgAbout)
            
        Case idMenuExit
            'exit, DO NOT 'End' here, the framework will exit the application
            Unload Me
            
        'Generic implementations
        Case idMenuCut
        Case idMenuCopy
        Case idMenuPaste
            
        Case idMenuToolbar
            toolMain.Visible = Not toolMain.Visible
            nDummy = ofx_ProfileWriteBool("Options", ofx_GetFormName(Me) & "_TOOLBAR", (toolMain.Visible))
            
        Case idMenuStatusbar
            statMain.Visible = Not statMain.Visible
            nDummy = ofx_ProfileWriteBool("Options", ofx_GetFormName(Me) & "_STATUSBAR", (statMain.Visible))
        
        Case idMenuToolsOptions
            'Handle Tools Options
            
        #If OFXOPT_OFFICEBOOK Then
        Case idMenuToolsOfficeBook
            
            If (ofx_OfbkMainDialog(True)) Then
                'do something with the selected results
                'Example:
                'ofx_OfbkFillList Me.List1, ofbkDisplayName, True
            End If
            
        #End If
            
    End Select

HandleMenuClick_Exit:                                ' SDVB
    On Error Resume Next                             ' SDVB
    Exit Sub                                         ' SDVB
HandleMenuClick_Err:                                 ' SDVB
    Call ofx_GenericError("HandleMenuClick()", Err)  ' SDVB
    Resume HandleMenuClick_Exit                      ' SDVB
End Sub





Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdOK_Click()
    If IsSecurityPassed(txtUserID.Text, txtPassword.Text) Then
        ' WA edited on Nov 14, 1997
        Call SetUserProfile(txtUserID.Text)
        Call SetButtonBySLevel(pyUserSLevel)
        pyUserID = txtUserID.Text
        pyUserSLevel = GetUserSecurity(txtUserID.Text)
        pyUserHasCostLevel = IsCostOK(pyUserSLevel)
        pyUserLogonTime = Now
        fraUserLogon.Visible = False
    Else
        Beep
        LogonTries = LogonTries + 1
        txtUserID.SetFocus
    End If
    If LogonTries >= 3 Then Unload Me       ' Allows 3 tries
End Sub



Private Sub Form_Activate()
    Dim i, intButtonIndex  As Integer
    
    If (fraUserLogon.Visible) Then _
        txtUserID.SetFocus
    
    If Screen.ActiveForm.Name <> Me.Name Then
        Exit Sub
    Else
      For i = 0 To (tbrMainMenu.ToolsetTools.Count - 1)
        If tbrMainMenu.Buttons(i).Value = True Then
            intButtonIndex = i
            Select Case intButtonIndex
            Case 0
                frmMenuPoS.ZOrder
            Case 1
                frmMenuIC.ZOrder
            Case 2
                frmMenuOLAP.ZOrder
            Case 3
                frmMenuInfo.ZOrder
            Case 4
                frmMenuCoding.ZOrder
            Case 5
                frmReports.ZOrder
            Case 6
                frmMenuPreference.ZOrder
            Case 7
                frmMenuUtility.ZOrder
            End Select
            Exit For
        End If
      Next i
    End If
End Sub


Private Sub Form_Load()
    On Error GoTo Form_Load_Error
    
    ' Prevent multiple instances
    Dim SaveTitle$
    If App.PrevInstance Then
        Unload frmSplash
        SaveTitle$ = App.Title
        App.Title = "... duplicate instance."
        frmMain.Caption = "... duplicate instance."
        AppActivate SaveTitle$
        SendKeys "% R", True
        End
    End If
    
    ' Initialize the Crystal Report print engine
'    If sDBName = "" Then
'        Call InitPrintEngine
'    End If
    
    ' User Logon
    '
    ' If Security Table has more than one record
    If IsSecurityEnabled Then
        ' Ask for user ID
        DisableButtons
        fraUserLogon.Visible = True
    Else
        ' Use default user
        pyUserID = GetDefaultUser()
        pyUserSLevel = GetUserSecurity(pyUserID)
    End If
    
    Call ofx_CenterForm(Me)
   
    ZOrder 1
    
    toolMain.Visible = ofx_ProfileGetBool("Options", ofx_GetFormName(Me) & "_TOOLBAR", True)
    statMain.Visible = ofx_ProfileGetBool("Options", ofx_GetFormName(Me) & "_STATUSBAR", True)
    
    'Add Alt+F4 to the 'Exit' menu item
    MenuFile(6).Caption = MenuFile(6).Caption & Chr$(9) & "Alt+F4"
    
    #If Not OFXOPT_OFFICEBOOK Then
        'you may want to actually remove the Office Book menu if you are not using it
        MenuTools(1).Visible = False
        MenuTools(2).Visible = False
    #End If
    #If Not OFXOPT_MAPI Then
        'you may want to actually remove the Send... command if you are not using it
        MenuFile(4).Visible = False
        MenuFile(5).Visible = False
    #End If
    
    'Running as an OLE server, and we are supposed to be
    'modal, so set this window to be the foreground window
    'DON't use SetParent!
    If (ofxApp.hWndParent And ofxApp.bRunAutomated) Then
        Refresh
        ofx_SetForegroundWindow Me.hWnd
    End If
    
    
Form_Load_Exit:
    Exit Sub
Form_Load_Error:
    Call ofx_GenericError("Form_Load()", Err)
    Resume Form_Load_Exit
End Sub


Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Resize()
    Dim i As Integer
    Const MIN = 1
     
    If frmMain.WindowState = MIN Then   ' If parent form is minimized, hide others
        'If ofx_IsFormLoaded(frmMenuPoS) Then frmMenuPoS.Hide
        'If ofx_IsFormLoaded(frmMenuIC) Then frmMenuIC.Hide
        'If ofx_IsFormLoaded(frmMenuOLAP) Then frmMenuOLAP.Hide
        'If ofx_IsFormLoaded(frmMenuInfo) Then frmMenuInfo.Hide
        'If ofx_IsFormLoaded(frmMenuCoding) Then frmMenuCoding.Hide
        'If ofx_IsFormLoaded(frmReports) Then frmReports.Hide
        'If ofx_IsFormLoaded(frmMenuPreference) Then frmMenuPreference.Hide
' 2008.09.02 paulus: cancelled
'        For i = 1 To Forms.Count - 1        '   0 = frmMain
'            Forms(i).Hide
'        Next i
    Else                                 ' If parent form isn't minimized,
        'If ofx_IsFormLoaded(frmMenuPoS) Then frmMenuPoS.Visible = True
        'If ofx_IsFormLoaded(frmMenuIC) Then frmMenuIC.Visible = True
        'If ofx_IsFormLoaded(frmMenuOLAP) Then frmMenuOLAP.Visible = True
        'If ofx_IsFormLoaded(frmMenuInfo) Then frmMenuInfo.Visible = True
        'If ofx_IsFormLoaded(frmMenuCoding) Then frmMenuCoding.Visible = True
        'If ofx_IsFormLoaded(frmReports) Then frmReports.Visible = True
        'If ofx_IsFormLoaded(frmMenuPreference) Then frmMenuPreference.Visible = True
' 2008.09.02 paulus: cancelled
'        For i = 1 To Forms.Count - 1
'            If Forms(i).Name Like "frm*" Then Forms(i).Visible = True
'        Next i
'        frmMain.Show
'        Form_Activate
    End If
End Sub

Private Sub Form_Unload(Cancel As Integer)

    On Error GoTo Form_Unload_Err                ' SDVB
    
    UnloadAllForms
    Cancel = (Not (ofx_OnFinalUnload(Me)))
    If (Not (Cancel)) Then
        'Running as an OLE server, and we are supposed to be
        'modal, so set the caller to be the foreground window
        If (ofxApp.hWndParent And ofxApp.bRunAutomated) Then
'            ofx_SetForegroundWindow ofxApp.hWndParent
        End If
    End If

Form_Unload_Exit:                                ' SDVB
    On Error Resume Next                         ' SDVB
    Exit Sub                                     ' SDVB
Form_Unload_Err:                                 ' SDVB
    Call ofx_GenericError("Form_Unload()", Err)  ' SDVB
    Resume Form_Unload_Exit                      ' SDVB

End Sub












Private Sub MenuEdit_Click(Index As Integer)

    On Error GoTo MenuEdit_Click_Err                ' SDVB

    Select Case Index
        Case 0
            Call HandleMenuClick(idMenuCut)
        Case 1
            Call HandleMenuClick(idMenuCopy)
        Case 2
            Call HandleMenuClick(idMenuPaste)
    End Select

MenuEdit_Click_Exit:                                ' SDVB
    On Error Resume Next                            ' SDVB
    Exit Sub                                        ' SDVB
MenuEdit_Click_Err:                                 ' SDVB
    Call ofx_GenericError("MenuEdit_Click()", Err)  ' SDVB
    Resume MenuEdit_Click_Exit                      ' SDVB

End Sub

Private Sub MenuFile_Click(Index As Integer)

    On Error GoTo MenuFile_Click_Err                ' SDVB

    Select Case Index
        Case 0
            Call HandleMenuClick(idMenuFileNew)
        Case 1
            Call HandleMenuClick(idMenuFileOpen)
        Case 2
            Call HandleMenuClick(idMenuFileClose)
        Case 4
            Call HandleMenuClick(idMenuFileSend)
        Case 6
            Call HandleMenuClick(idMenuExit)
    End Select

MenuFile_Click_Exit:                                ' SDVB
    On Error Resume Next                            ' SDVB
    Exit Sub                                        ' SDVB
MenuFile_Click_Err:                                 ' SDVB
    Call ofx_GenericError("MenuFile_Click()", Err)  ' SDVB
    Resume MenuFile_Click_Exit                      ' SDVB

End Sub



Private Sub MenuFileTop_Click(Index As Integer)
    #If DBOPT_JET Or DBOPT_RDO Or DBOPT_ODBC Or DBOPT_VBSQL Then
        MenuFile(1).Enabled = Not (IsDatabaseOpen())
        MenuFile(2).Enabled = IsDatabaseOpen()
    #End If
End Sub

Private Sub MenuHelp_Click(Index As Integer)

    On Error GoTo MenuHelp_Click_Err                ' SDVB

    Select Case Index
        Case 0
            Call HandleMenuClick(idMenuAbout)
    End Select

MenuHelp_Click_Exit:                                ' SDVB
    On Error Resume Next                            ' SDVB
    Exit Sub                                        ' SDVB
MenuHelp_Click_Err:                                 ' SDVB
    Call ofx_GenericError("MenuHelp_Click()", Err)  ' SDVB
    Resume MenuHelp_Click_Exit                      ' SDVB

End Sub




Private Sub MenuTools_Click(Index As Integer)

    On Error GoTo MenuTools_Click_Err                ' SDVB

    Select Case Index
        Case 0
            HandleMenuClick (idMenuToolsOptions)
        Case 2
            HandleMenuClick (idMenuToolsOfficeBook)
    End Select

MenuTools_Click_Exit:                                ' SDVB
    On Error Resume Next                             ' SDVB
    Exit Sub                                         ' SDVB
MenuTools_Click_Err:                                 ' SDVB
    Call ofx_GenericError("MenuTools_Click()", Err)  ' SDVB
    Resume MenuTools_Click_Exit                      ' SDVB

End Sub

Private Sub MenuView_Click(Index As Integer)

    On Error GoTo MenuView_Click_Err                ' SDVB

    Select Case Index
        Case 0
            MenuView(Index).Checked = Not (MenuView(Index).Checked)
            Call HandleMenuClick(idMenuToolbar)
        Case 1
            MenuView(Index).Checked = Not (MenuView(Index).Checked)
            Call HandleMenuClick(idMenuStatusbar)
    End Select

MenuView_Click_Exit:                                ' SDVB
    On Error Resume Next                            ' SDVB
    Exit Sub                                        ' SDVB
MenuView_Click_Err:                                 ' SDVB
    Call ofx_GenericError("MenuView_Click()", Err)  ' SDVB
    Resume MenuView_Click_Exit                      ' SDVB

End Sub

Private Sub MenuViewTop_Click(Index As Integer)

    On Error GoTo MenuViewTop_Click_Err                ' SDVB

    MenuView(0).Checked = toolMain.Visible
    MenuView(1).Checked = statMain.Visible

MenuViewTop_Click_Exit:                                ' SDVB
    On Error Resume Next                               ' SDVB
    Exit Sub                                           ' SDVB
MenuViewTop_Click_Err:                                 ' SDVB
    Call ofx_GenericError("MenuViewTop_Click()", Err)  ' SDVB
    Resume MenuViewTop_Click_Exit                      ' SDVB

End Sub








Private Sub tbrMainMenu_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)
    
    If Value = False Then
        Call UnloadThisForm(ToolID)
    Else
        Call LoadThisForm(ToolID)
    End If
    Call SetUserLogo
    
End Sub

Private Sub toolMain_ButtonClick(ByVal Button As Button)

    On Error GoTo toolMain_ButtonClick_Err                ' SDVB

    Select Case Button.Key
        Case "fileopen"
            Call HandleMenuClick(idMenuFileOpen)
        Case "cut"
            Call HandleMenuClick(idMenuCut)
        Case "copy"
            Call HandleMenuClick(idMenuCopy)
        Case "paste"
            Call HandleMenuClick(idMenuPaste)
    End Select

toolMain_ButtonClick_Exit:                                ' SDVB
    On Error Resume Next                                  ' SDVB
    Exit Sub                                              ' SDVB
toolMain_ButtonClick_Err:                                 ' SDVB
    Call ofx_GenericError("toolMain_ButtonClick()", Err)  ' SDVB
    Resume toolMain_ButtonClick_Exit                      ' SDVB
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




Private Sub MyLoadForm(Target As Form)
    If ofx_IsFormLoaded(Target) Then
        Me.ZOrder 1
        Target.ZOrder 0
    Else
        Target.Show
    End If
End Sub

Private Sub UnloadAllForms()

    Call MyUnloadForm(frmMenuPoS)
    Call MyUnloadForm(frmMenuIC)
    Call MyUnloadForm(frmMenuOLAP)
    Call MyUnloadForm(frmMenuInfo)
    Call MyUnloadForm(frmMenuCoding)
    Call MyUnloadForm(frmReports)
    Call MyUnloadForm(frmMenuPreference)
    Call MyUnloadForm(frmMenuUtility)

End Sub

Private Sub UnloadThisForm(strToolID As String)

    Select Case strToolID
        Case "ID_PoS"
            Call MyUnloadForm(frmMenuPoS)
        Case "ID_IC"
            Call MyUnloadForm(frmMenuIC)
        Case "ID_OLAP"
            Call MyUnloadForm(frmMenuOLAP)
        Case "ID_InfoCentre"
            Call MyUnloadForm(frmMenuInfo)
        Case "ID_Coding"
            Call MyUnloadForm(frmMenuCoding)
        Case "ID_Report"
            Call MyUnloadForm(frmReports)
        Case "ID_Preference"
            Call MyUnloadForm(frmMenuPreference)
        Case "ID_Utility"
            Call MyUnloadForm(frmMenuUtility)
    End Select

End Sub

Private Sub LoadThisForm(strToolID As String)

    Select Case strToolID
        Case "ID_PoS"
'            MsgBox "Would be activated when coding input is ready."
            Call MyLoadForm(frmMenuPoS)
        Case "ID_IC"
'            MsgBox "Would be activated when coding input is ready."
            Call MyLoadForm(frmMenuIC)
        Case "ID_OLAP"
            Call MyLoadForm(frmMenuOLAP)
        Case "ID_InfoCentre"
            Call MyLoadForm(frmMenuInfo)
        Case "ID_Coding"
            Call MyLoadForm(frmMenuCoding)
        Case "ID_Report"
            Call MyLoadForm(frmReports)
        Case "ID_Preference"
            Call MyLoadForm(frmMenuPreference)
        Case "ID_Utility"
            Call MyLoadForm(frmMenuUtility)
    End Select

End Sub

Private Sub MyUnloadForm(Target As Form)
        
    If ofx_IsFormLoaded(Target) Then
        Unload Target
    End If

End Sub

Private Sub SetUserLogo()

    Dim blnAllUp As Boolean
    Dim i As Integer
    
    blnAllUp = True
    For i = 0 To (tbrMainMenu.ToolsetTools.Count - 1)
        If tbrMainMenu.Buttons(i).Value = True Then blnAllUp = False
    Next i
    
    If blnAllUp Then
        cmdUserLogo.Visible = True
    Else
        cmdUserLogo.Visible = False
    End If
    
End Sub

' Enable/disable taskbar buttons according to User Security Level
Private Sub SetButtonBySLevel(myUserSLevel As Integer)
    Dim myDB As Database
    Dim myRS As Recordset
    Dim strSQL As String
    Dim RetVal As Boolean
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set myRS = myDB.OpenRecordset("Security", dbOpenDynaset, dbReadOnly)    ' Open table read only
    strSQL = "Level = " & myUserSLevel
    
    myRS.FindFirst strSQL
    If myRS.NoMatch Then
        RetVal = 0
    Else
        RetVal = myRS!Level
    End If
        
    With myRS
        If !Point_of_Sale Then tbrMainMenu.Buttons(0).Enabled = True
        If !Inventory_Control Then tbrMainMenu.Buttons(1).Enabled = True
        If !OLAP Then tbrMainMenu.Buttons(2).Enabled = True
        If !Information_Centre Then tbrMainMenu.Buttons(3).Enabled = True
        If !Coding Then tbrMainMenu.Buttons(4).Enabled = True
        If !Report_Centre Then tbrMainMenu.Buttons(5).Enabled = True
        If !Preference Then tbrMainMenu.Buttons(6).Enabled = True
    End With
    
    myRS.Close
    myDB.Close
End Sub

Private Sub DisableButtons()
    Dim i As Integer

    For i = 0 To (tbrMainMenu.ToolsetTools.Count - 1)
        tbrMainMenu.Buttons(i).Enabled = False
    Next i
End Sub

Private Sub txtPassword_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdOK_Click
        KeyAscii = 0
    End If
End Sub


Private Sub txtUserID_GotFocus()
    ' The initial value of the Text Box might contains blanks,
    ' the following line make sure there's nothing before user input.
    txtUserID.Text = ""
End Sub

Private Sub txtUserID_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdOK_Click
        KeyAscii = 0
    End If
End Sub



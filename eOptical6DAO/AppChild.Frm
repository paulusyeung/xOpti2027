VERSION 4.00
Begin VB.Form frmMDIChild 
   Caption         =   "Child1"
   ClientHeight    =   3660
   ClientLeft      =   2085
   ClientTop       =   3945
   ClientWidth     =   6180
   Height          =   4350
   Icon            =   "APPCHILD.frx":0000
   Left            =   2025
   LinkTopic       =   "Form1"
   MDIChild        =   -1  'True
   ScaleHeight     =   3660
   ScaleWidth      =   6180
   Top             =   3315
   Width           =   6300
   Begin VB.Menu MenuFileTop 
      Caption         =   "&File"
      Index           =   0
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
         Enabled         =   0   'False
         Index           =   0
         Shortcut        =   ^X
      End
      Begin VB.Menu MenuEdit 
         Caption         =   "&Copy"
         Enabled         =   0   'False
         Index           =   1
         Shortcut        =   ^C
      End
      Begin VB.Menu MenuEdit 
         Caption         =   "&Paste"
         Enabled         =   0   'False
         Index           =   2
         Shortcut        =   ^V
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
      End
   End
   Begin VB.Menu MenuWindowTop 
      Caption         =   "&Window"
      Index           =   2
      WindowList      =   -1  'True
      Begin VB.Menu MenuWindow 
         Caption         =   "T&ile Horizontally"
         Index           =   0
      End
      Begin VB.Menu MenuWindow 
         Caption         =   "&Tile Vertically"
         Index           =   1
      End
      Begin VB.Menu MenuWindow 
         Caption         =   "&Cascade"
         Index           =   2
      End
   End
   Begin VB.Menu MenuHelpTop 
      Caption         =   "&Help"
      Index           =   2
      Begin VB.Menu MenuHelp 
         Caption         =   "&About"
         Index           =   0
      End
   End
End
Attribute VB_Name = "frmMDIChild"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Option Explicit




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
    On Error GoTo HandleMenuClick_Exit
    
    Dim nDummy As Integer
    
    Select Case nItem
                            
        Case idMenuFileClose
            Unload Me
            
        Case idMenuFileSend
            #If OFXOPT_MAPI Then
                OnFileSend Me
            #End If
            
        'Generic implementations
        Case idMenuCut
        Case idMenuCopy
        Case idMenuPaste
        
        Case idMenuToolsOptions
            'Handle Tools Options
            
        #If OFXOPT_OFFICEBOOK Then
        Case idMenuToolsOfficeBook
            If (ofx_OfbkMainDialog(True)) Then
                'do something with the selected results
                'Example:
                'ofx_GetDisplayNames Me.List1
            End If
        #End If
        
        
        ' In all other cases, defer to the parent
        Case Else
            Call frmMain.HandleMenuClick(nItem)
            
            
    End Select

HandleMenuClick_Exit:                                ' SDVB
    On Error Resume Next                             ' SDVB
    Exit Sub                                         ' SDVB
HandleMenuClick_Err:                                 ' SDVB
    Call ofx_GenericError("HandleMenuClick()", Err)  ' SDVB
    Resume HandleMenuClick_Exit                      ' SDVB
End Sub








Private Sub Form_Load()
    On Error Resume Next
    
    
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
        Case 4
            Call HandleMenuClick(idMenuFileSend)
        Case 6
            Call HandleMenuClick(idMenuExit)
    End Select
End Sub


Private Sub MenuHelp_Click(Index As Integer)
    On Error Resume Next
    
    Select Case Index
        Case 0
            Call HandleMenuClick(idMenuAbout)
    End Select
End Sub

Private Sub MenuTools_Click(Index As Integer)
    On Error Resume Next
    
    Select Case Index
        Case 0
            HandleMenuClick (idMenuToolsOptions)
        Case 2
            HandleMenuClick (idMenuToolsOfficeBook)
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



Private Sub MenuViewTop_Click()
    On Error Resume Next
    Call frmMain.MenuViewTop_Click
End Sub


Private Sub MenuWindow_Click(Index As Integer)
    On Error Resume Next
    
    Select Case Index
        Case 0
            Call HandleMenuClick(idMenuTileHoriz)
        Case 1
            Call HandleMenuClick(idMenuTileVert)
        Case 2
            Call HandleMenuClick(idMenuCascade)
    End Select
End Sub




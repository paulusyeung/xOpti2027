VERSION 5.00
Begin VB.Form ofx_Tooltips 
   Appearance      =   0  'Flat
   BackColor       =   &H80000005&
   BorderStyle     =   0  'None
   Caption         =   "Tooltips"
   ClientHeight    =   2235
   ClientLeft      =   7035
   ClientTop       =   1230
   ClientWidth     =   4185
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   Enabled         =   0   'False
   BeginProperty Font 
      Name            =   "Arial"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   149
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   279
   ShowInTaskbar   =   0   'False
   Visible         =   0   'False
   Begin VB.Timer timRecentHelp 
      Interval        =   100
      Left            =   2760
      Top             =   120
   End
   Begin VB.TextBox txtTooltip 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFF00&
      Height          =   315
      Left            =   3600
      TabIndex        =   4
      Top             =   1800
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.CheckBox chkMouseRelative 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Help relative to mouse position"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   210
      Left            =   90
      TabIndex        =   1
      Top             =   510
      Value           =   1  'Checked
      Width           =   3090
   End
   Begin VB.Timer timShowHelp 
      Enabled         =   0   'False
      Interval        =   750
      Left            =   2280
      Top             =   120
   End
   Begin VB.PictureBox txtHelp 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00C0FFFF&
      BorderStyle     =   0  'None
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   120
      ScaleHeight     =   17
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   129
      TabIndex        =   0
      Top             =   120
      Width           =   1935
   End
   Begin VB.PictureBox txtBorder 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H80000005&
      Enabled         =   0   'False
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   3360
      ScaleHeight     =   15
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   39
      TabIndex        =   6
      Top             =   120
      Width           =   615
   End
   Begin VB.Label lblCodeLine 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "VB3:  ofx_Tooltips.txtTooltip = <msg>"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   195
      Index           =   1
      Left            =   240
      TabIndex        =   5
      Top             =   1800
      Visible         =   0   'False
      Width           =   3195
   End
   Begin VB.Label lblCodeLine 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "VB4:  Call ofx_Tooltips.Tooltip(<msg>)"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   195
      Index           =   0
      Left            =   240
      TabIndex        =   3
      Top             =   1560
      Visible         =   0   'False
      Width           =   3255
   End
   Begin VB.Label lblInstructions 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "To use:  In the MouseMove method of each control for which you wish a tooltip, add the following code:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   615
      Left            =   75
      TabIndex        =   2
      Top             =   870
      Visible         =   0   'False
      Width           =   4050
   End
End
Attribute VB_Name = "ofx_Tooltips"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim msCurrentMsg As String   ' The msg for the current control
Dim mnStdBackColor As Long   ' Standard background color
Dim mnStdDelay As Long       ' Standard help delay
Dim mhLastWnd As Long        ' Last ctrl wnd for which we received MOUSEMOVE
Dim mhCtrlWnd As Long        ' The hWnd of the current control

Const VK_LBUTTON = &H1
Const VK_RBUTTON = &H2
Const WM_LBUTTONDOWN = &H201
Const WM_RBUTTONDOWN = &H204
Const WM_MBUTTONDOWN = &H207

Const COLOR_RED& = &HFF
Const RECENT_HELP_INTERVAL% = 100

#If Win32 Then
Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hWnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Long) As Long
Private Declare Function GetKeyState Lib "user32" (ByVal nVirtKey As Long) As Integer
Private Declare Function SetCapture Lib "user32" (ByVal hWnd As Long) As Long
Private Declare Function ReleaseCapture Lib "user32" () As Long
#Else
Private Declare Function SendMessage Lib "User" (ByVal hWnd As Integer, ByVal wMsg As Integer, ByVal wParam As Integer, lParam As Any) As Long
Private Declare Function GetKeyState Lib "User" (ByVal nVirtKey As Integer) As Integer
Private Declare Sub ReleaseCapture Lib "User" ()
Private Declare Function SetCapture Lib "User" (ByVal hWnd As Integer) As Integer
#End If




'------------------------------------------------------------------------------
' Function: SendMouseDown
'
' Purpose:  Send a mouse down event to the current control. Need to do this
'           because we intercepted the message by capturing mouse intput.
'------------------------------------------------------------------------------
Sub SendMouseDown(nButton As Integer, nShift As Integer, ByVal x As Long, ByVal Y As Long)
    On Error Resume Next
    
    Dim nMsg As Integer
    Dim pt As POINTAPI
    Dim nDummy As Long
    
    Select Case nButton
        Case 1:
            nMsg = WM_LBUTTONDOWN
        Case 2:
            nMsg = WM_RBUTTONDOWN
        Case 4:
            nMsg = WM_MBUTTONDOWN
    End Select
    
    pt.x = x
    pt.Y = Y
    
    nDummy = SendMessage(mhCtrlWnd, nMsg, nShift, ofx_PointAPIToLong(pt))
End Sub

'------------------------------------------------------------------------------
' Function: MouseButtonDown
'
' Purpose:  Determine if either mouse button is currently depressed.
'
' Returns:  TRUE if either mouse button down, else FALSE
'------------------------------------------------------------------------------
Function MouseButtonDown() As Boolean
    On Error Resume Next
    MouseButtonDown = (GetKeyState(VK_LBUTTON) < 0 Or GetKeyState(VK_RBUTTON) < 0)
End Function

'------------------------------------------------------------------------------
' Sub:      PopupHelp
'
' Purpose:  Popup the tip.
'
' Params:   sMsg            (I) Tip text
'           bMouseRelative  (I) Tip position relative to mouse position vs. ctrl relative?
'           hCtrlWnd        (I) Control for which tip given
'------------------------------------------------------------------------------
Private Sub PopupHelp(sMsg As String, bMouseRelative As Integer, hCtrlWnd As Long)

    On Error GoTo PopupHelp_Err
    
    Dim w As Long
    Dim h As Long
    Dim cy As Long
    Dim nFlags As Integer
    Dim ptMouse As POINTAPI
    Dim rcWnd As RECT
    Dim szText As Size
    Dim nDummy As Long

    '----- Special handling for empty help

    If (sMsg = "") Then
        sMsg = "* No help *"
        txtHelp.BackColor = COLOR_RED
    ElseIf (txtHelp.BackColor <> mnStdBackColor) Then
        txtHelp.BackColor = mnStdBackColor
    End If

    '----- Set help window size based on length of message text

    nDummy = GetTextExtentPoint(txtHelp.hdc, sMsg, Len(sMsg), szText)
    w = szText.cx And &H1FF
    h = szText.cy
    
    '----- Fudge factor

    txtHelp.Width = w + 6
    txtHelp.Height = h + 2
    Height = (txtHelp.Height + 1) * Screen.TwipsPerPixelY
    Width = (txtHelp.Width + 1) * Screen.TwipsPerPixelX

    '----- Print help message

    txtHelp.Cls
    txtHelp.CurrentY = 1
    txtHelp.CurrentX = 2
    txtHelp.Print sMsg
    txtBorder.Top = txtHelp.Top
    txtBorder.Left = txtHelp.Left
    txtBorder.Width = txtHelp.Width + 1
    txtBorder.Height = txtHelp.Height + 1

    '----- Get window handle to relative to which tip will display
    
    If (bMouseRelative) Then
        Dim hWndOver As Long
        
        hWndOver = ofx_WindowFromPoint(ptMouse)
        Call GetWindowRect(hWndOver, rcWnd)
    Else
        Call GetWindowRect(hCtrlWnd, rcWnd)
    End If
  
    '----- Position help message window relative to cursor

    If (bMouseRelative) Then
        Call GetCursorPos(ptMouse)
        cy = GetSystemMetrics(SM_CYSIZE)
        Top = (ptMouse.Y + cy + h / 4) * Screen.TwipsPerPixelY
        Left = (ptMouse.x - 2) * Screen.TwipsPerPixelX
    Else
        #If HELPABOVECTRL Then
            Top = (rcWnd.nTop - 5) * Screen.TwipsPerPixelY - Me.Height
        #Else
            Top = (rcWnd.nBottom + 5) * Screen.TwipsPerPixelY
        #End If
        Left = (rcWnd.nLeft + 5) * Screen.TwipsPerPixelX
    End If
    
    '----- Adjust position of popup if needed, ie - don't let
    '----- message run off screen

    If (Top + Height > Screen.Height) Then
        Top = Screen.Height - Height
        ' don't cover the button either
'        If (Top + Height > rcWnd.nTop * Screen.TwipsPerPixelY) Then
        If (Top + Height > rcWnd.nBottom * Screen.TwipsPerPixelY) Then
            Top = (rcWnd.nTop * Screen.TwipsPerPixelY) - Me.Height
        ElseIf (Top < 0) Then
            Top = 1
        End If
    End If

    If (Left + Width > Screen.Width) Then
        Left = Screen.Width - Width
    ElseIf (Left < 0) Then
        Left = 1
    End If

    '----- Display window;  SWP_NOACTIVATE is the key here...

    nFlags = SWP_NOSIZE Or SWP_NOMOVE Or SWP_NOACTIVATE Or SWP_SHOWWINDOW
    Call SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, nFlags)

PopupHelp_Exit:
    Exit Sub
    
PopupHelp_Err:
    Resume PopupHelp_Exit
End Sub

'------------------------------------------------------------------------------
' Sub:      ToolTip
'
' Purpose:  VB4 entry point for invoking tool tip.
'
' Params:   sMsg    (I) Tip text
'
' Note:     VB3 does not allow calling procedures in forms (except from within
'           the form itself of course) so this is called from elsewhere in the
'           form for VB3.
'------------------------------------------------------------------------------
Public Sub ToolTip(sMsg As String)
    On Error Resume Next
    
    Dim nDummy As Long
    Dim hCurrentWnd As Long
    
    hCurrentWnd = ofx_GetCurrentWnd()
    If (Not MouseButtonDown() And hCurrentWnd <> mhCtrlWnd) Then
        nDummy = SetCapture(Me.hWnd)
        
        msCurrentMsg = sMsg
        mhCtrlWnd = hCurrentWnd
        timShowHelp.Enabled = True
        timRecentHelp.Enabled = False
    End If
End Sub












Private Sub Form_Load()
    On Error Resume Next
    
    txtHelp.Top = 0
    txtHelp.Left = 0
    mnStdBackColor = txtHelp.BackColor
    mnStdDelay = timShowHelp.Interval
End Sub





Private Sub Form_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)
    timShowHelp.Enabled = False
    timRecentHelp.Enabled = False
    timShowHelp.Interval = mnStdDelay
    Me.Hide
    Call ReleaseCapture
    Call SendMouseDown(Button, Shift, x, Y)
End Sub











Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    On Error Resume Next
    
    Dim hCurrentWnd As Long
    
    '----- If we we move from current control to some other window
    
    hCurrentWnd = ofx_GetCurrentWnd()
    If (mhLastWnd <> hCurrentWnd) Then
        If (mhLastWnd = mhCtrlWnd) Then
            Call ReleaseCapture
            Me.Hide
            timShowHelp.Enabled = False
            mhCtrlWnd = 0
            timShowHelp.Interval = RECENT_HELP_INTERVAL
            timRecentHelp.Enabled = True
        End If
    End If
    
    mhLastWnd = hCurrentWnd
End Sub


Private Sub Form_Unload(Cancel As Integer)
    timShowHelp.Enabled = False
End Sub



Private Sub timRecentHelp_Timer()
    timRecentHelp.Enabled = False
    timShowHelp.Interval = mnStdDelay
End Sub

'------------------------------------------------------------------------------
' Sub:      timShowHelp_Timer
'
' Purpose:  Fires when ShowHelp timer expires. This timer controls the delay so
'           that a tooltip does not show up the instant the mouse passes over an
'           enabled control.  Instead, a timer is started and if the mouse is
'           still over the same control when the timer expires then the tooltip
'           is presented.
'------------------------------------------------------------------------------
Private Sub timShowHelp_Timer()

    On Error GoTo timShowHelp_Timer_Err
    
    Dim hMouseWnd As Long

    timShowHelp.Enabled = False ' Kill the show msg timer
    
    '----- If we are not still on the control that triggered
    '----- this timer then unload the tooltip

    hMouseWnd = ofx_GetCurrentWnd()
    If (hMouseWnd <> mhCtrlWnd) Then
        Call ReleaseCapture
        Me.Hide
        mhCtrlWnd = 0
        mhLastWnd = 0
        GoTo timShowHelp_Timer_Exit
    End If
    
    '----- Put up the msg
    
    Call PopupHelp(msCurrentMsg, (chkMouseRelative = 1), mhCtrlWnd)
    
timShowHelp_Timer_Exit:
    Exit Sub
    
timShowHelp_Timer_Err:
    Resume timShowHelp_Timer_Exit
    
End Sub



'------------------------------------------------------------------------------
' Sub:      txtTooltip_Change
'
' Purpose:  Since VB3 does not allow outside calls to form procedures, the
'           txtTooltip text box control is provided.  When a caller sets the
'           text for that control this event fires and the tool tips work as if
'           a VB4 application had called the ToolTip() procedure.
'
' See also: ToolTip()
'------------------------------------------------------------------------------
Private Sub txtTooltip_Change()
    Call ToolTip((txtTooltip))
    txtTooltip = ""
End Sub



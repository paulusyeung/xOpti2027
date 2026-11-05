VERSION 5.00
Begin VB.Form ofx_dlgGenericError 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Start Developing"
   ClientHeight    =   4470
   ClientLeft      =   825
   ClientTop       =   2700
   ClientWidth     =   6930
   Icon            =   "OfxErr.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4470
   ScaleWidth      =   6930
   ShowInTaskbar   =   0   'False
   Begin VB.TextBox txtProcedure 
      BackColor       =   &H00C0C0C0&
      Height          =   285
      Left            =   1800
      Locked          =   -1  'True
      TabIndex        =   12
      Top             =   3375
      Width           =   4815
   End
   Begin VB.TextBox txtWhen 
      BackColor       =   &H00C0C0C0&
      Height          =   285
      Left            =   4320
      Locked          =   -1  'True
      TabIndex        =   10
      Top             =   1080
      Width           =   2295
   End
   Begin VB.TextBox txtErrorMessage 
      BackColor       =   &H00C0C0C0&
      Height          =   1665
      Left            =   1800
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      TabIndex        =   7
      Top             =   1560
      Width           =   4815
   End
   Begin VB.TextBox txtErrorNumber 
      BackColor       =   &H00C0C0C0&
      Height          =   285
      Left            =   1800
      Locked          =   -1  'True
      TabIndex        =   5
      Top             =   1080
      Width           =   1335
   End
   Begin VB.CommandButton cmdViewCode 
      Caption         =   "&View Code"
      Height          =   375
      Left            =   3360
      TabIndex        =   2
      Tag             =   "Stop execution; view code"
      ToolTipText     =   "Stop execution; view code"
      Top             =   4005
      Width           =   1335
   End
   Begin VB.CommandButton cmdEnd 
      Caption         =   "&End"
      Height          =   375
      Left            =   1800
      TabIndex        =   1
      Tag             =   "Quit application"
      ToolTipText     =   "Quit application"
      Top             =   4005
      Width           =   1335
   End
   Begin VB.CommandButton cmdContinue 
      Cancel          =   -1  'True
      Caption         =   "&Continue"
      Default         =   -1  'True
      Height          =   375
      Left            =   240
      TabIndex        =   0
      Tag             =   "Continue with application, ignore error"
      Top             =   4005
      Width           =   1335
   End
   Begin VB.Label STATIC 
      BackStyle       =   0  'Transparent
      Caption         =   "When:"
      Height          =   255
      Index           =   3
      Left            =   3600
      TabIndex        =   11
      Top             =   1080
      Width           =   615
   End
   Begin VB.Label STATIC 
      BackStyle       =   0  'Transparent
      Caption         =   "Procedure:"
      Height          =   255
      Index           =   4
      Left            =   240
      TabIndex        =   9
      Top             =   3375
      Width           =   1455
   End
   Begin VB.Label STATIC 
      BackStyle       =   0  'Transparent
      Caption         =   "Error Message:"
      Height          =   255
      Index           =   5
      Left            =   240
      TabIndex        =   8
      Top             =   1560
      Width           =   1455
   End
   Begin VB.Label STATIC 
      BackStyle       =   0  'Transparent
      Caption         =   "Error Number:"
      Height          =   255
      Index           =   2
      Left            =   240
      TabIndex        =   6
      Top             =   1080
      Width           =   1455
   End
   Begin VB.Label STATIC 
      BackStyle       =   0  'Transparent
      Caption         =   "Please write down the following information and contact the development support team."
      Height          =   495
      Index           =   1
      Left            =   240
      TabIndex        =   4
      Top             =   480
      Width           =   6495
   End
   Begin VB.Label STATIC 
      BackStyle       =   0  'Transparent
      Caption         =   "A Visual Basic Error has occurred."
      Height          =   255
      Index           =   0
      Left            =   240
      TabIndex        =   3
      Top             =   120
      Width           =   6375
   End
End
Attribute VB_Name = "ofx_dlgGenericError"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'------------------------------------------------------------------------------
' Form:     ofx_dlgGenericError
'
' Purpose:  Error message presentation dialog.
'
' Note:     Much more full-featured than using MsgBox.
'
' See also: ofx_GenericError()
'------------------------------------------------------------------------------

Option Explicit

'------------------------------------------------------------------------------
' Sub:      cmdContinue_Click
'
' Purpose:  User clicked Continue button so unload form so caller can continue.
'------------------------------------------------------------------------------
Private Sub cmdContinue_Click()
    On Error Resume Next
    Unload Me
End Sub


'------------------------------------------------------------------------------
' Sub:      cmdEnd_Click
'
' Purpose:  Allow user to terminate the application.
'
' Note:     Comment-out if you are building an OLE Server.
'           End statements are not valid in such projects.
'------------------------------------------------------------------------------
Private Sub cmdEnd_Click()
    ' If you are building an In-Process OLE Server you will need to comment-out
    ' this line. End statements are not valid in such projects.
    End
End Sub


'------------------------------------------------------------------------------
' Sub:      cmdViewCode_Click
'
' Purpose:  Allow user to step into procedure in which this form called.
'
' Note:     Since VB provides no way to determine if we are in run-time mode or
'           design mode and we don't want to allow this if in run-time mode, we
'           disable (in fact hide the control) unless code is compiled with the
'           DBG conditional compilation constant is ON.
'------------------------------------------------------------------------------
Private Sub cmdViewCode_Click()
    On Error Resume Next
    
    #If MSA Or DBG Then
        Me.Hide
    #End If
End Sub


Private Sub Form_Load()
    On Error Resume Next
    
    Call ofx_CenterForm(Me)
    
    Me.txtErrorNumber = ofxLastError.sErrNumber
    Me.txtErrorMessage = ofxLastError.sErrText
    Me.txtProcedure = ofxLastError.sProcedure
    Me.txtWhen = ofxLastError.dWhen
    Me.Caption = ofxApp.sAppName
    #If Not MSA And Not DBG Then
        cmdViewCode.Visible = False
    #End If
End Sub






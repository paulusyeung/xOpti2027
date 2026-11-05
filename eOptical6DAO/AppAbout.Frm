VERSION 5.00
Begin VB.Form dlgAbout 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "About"
   ClientHeight    =   5580
   ClientLeft      =   1530
   ClientTop       =   2250
   ClientWidth     =   6450
   Icon            =   "AppAbout.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5580
   ScaleWidth      =   6450
   ShowInTaskbar   =   0   'False
   Begin VB.Frame Frame1 
      Height          =   50
      Left            =   120
      TabIndex        =   5
      Top             =   4590
      Width           =   6300
   End
   Begin VB.CommandButton cmdSystemInfo 
      Caption         =   "&System Info..."
      Height          =   375
      Left            =   120
      TabIndex        =   1
      Top             =   5115
      Width           =   1335
   End
   Begin VB.CommandButton cmdOK 
      Cancel          =   -1  'True
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   4695
      Width           =   1335
   End
   Begin VB.Label lblProductName 
      Caption         =   "Product Name"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   20.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   3120
      TabIndex        =   7
      Top             =   120
      Width           =   3135
   End
   Begin VB.Label lblCompanyName 
      Alignment       =   1  'Right Justify
      Caption         =   "Company Name"
      Height          =   255
      Left            =   3240
      TabIndex        =   6
      Top             =   1920
      Width           =   3135
   End
   Begin VB.Label lblVersion 
      Alignment       =   1  'Right Justify
      Caption         =   "Version Number"
      Height          =   255
      Left            =   3360
      TabIndex        =   4
      Top             =   1440
      Width           =   3015
   End
   Begin VB.Image Image1 
      Height          =   4425
      Left            =   120
      Picture         =   "AppAbout.frx":068A
      Top             =   120
      Width           =   2820
   End
   Begin VB.Label lblAppTitle 
      Caption         =   "App Title"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   20.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   3105
      TabIndex        =   3
      Top             =   720
      Width           =   3135
   End
   Begin VB.Label lblCopyright 
      Alignment       =   1  'Right Justify
      Caption         =   "Copyright Notice"
      Height          =   255
      Left            =   3240
      TabIndex        =   2
      Top             =   1680
      Width           =   3135
   End
End
Attribute VB_Name = "dlgAbout"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Sub ShowSystemInfo()
    
    On Error GoTo ShowSystemInfo_Exit

    Dim sPath As String
   
    #If Win16 Then
        Dim nDummy As Integer
        
        ' Get the path to the MSINFO Microsoft "MiniApp" that we want to run.
        sPath = ofx_IniPrivateGetString("MSAPPS", "MSINFO", "", "WIN.INI")
    
        ' Make sure there is a trailing backslash and add the name of the app.
        If (Right$(sPath, 1) <> "\") Then sPath = sPath & "\"
        sPath = sPath & "MSINFO.EXE"
    
        ' If the file exists, execute it.
        If (ofx_FileExists(sPath)) Then
            nDummy = Shell(sPath, 1)
        End If
    #Else
        sPath = ofx_RegExGetVariant(HKEY_LOCAL_MACHINE, "Software\Microsoft\Shared Tools\MSInfo", "Path")
    
        '----- If the file exists, execute it.
        If (ofx_FileExists(sPath)) Then
            Shell sPath, 1
        End If
    #End If

ShowSystemInfo_Exit:
    Exit Sub
ShowSystemInfo_Error:
    Call ofx_GenericError(CStr(Nz(ofx_GetFormName(Me))) & "::cmdSystemInfo_Click()", Err)
    Resume ShowSystemInfo_Exit
End Sub

Private Sub cmdOK_Click()
    On Error Resume Next
    Unload Me
End Sub


Private Sub cmdSystemInfo_Click()
    On Error Resume Next
    Call ShowSystemInfo
End Sub


Private Sub Form_Load()
    On Error Resume Next

    #If Not VB3 Then
        Me.lblVersion = "Version " & App.Major & "." & Format$(App.Minor, "00") & "." & Format$(App.Revision, "000")
        Me.lblCopyright = App.LegalCopyright
    #End If
    Me.lblProductName = App.ProductName
'    Me.lblAppTitle = "for " & App.Title
    Me.lblAppTitle = "for Optical"
    Me.lblCompanyName = App.CompanyName
    Call ofx_CenterForm(Me)
End Sub




VERSION 5.00
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmLookupCustomer 
   Caption         =   "Lookup Customer"
   ClientHeight    =   4425
   ClientLeft      =   2430
   ClientTop       =   2025
   ClientWidth     =   8415
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4425
   ScaleWidth      =   8415
   Begin TrueDBGrid50.TDBGrid dbgCustInfo 
      Bindings        =   "frmLookupCustomer.frx":0000
      Height          =   2955
      Left            =   120
      OleObjectBlob   =   "frmLookupCustomer.frx":001A
      TabIndex        =   6
      Top             =   1380
      Width           =   8175
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   1215
      Left            =   120
      TabIndex        =   0
      Top             =   60
      Width           =   8175
      _ExtentX        =   14420
      _ExtentY        =   2143
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
      Caption         =   "Lookup Selection"
      Begin VB.TextBox txtSelName 
         Height          =   315
         Left            =   1320
         TabIndex        =   4
         Top             =   660
         Width           =   2535
      End
      Begin VB.Data dtcCustomer 
         Caption         =   "Customer"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   315
         Left            =   3720
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   ""
         Top             =   240
         Visible         =   0   'False
         Width           =   2055
      End
      Begin VB.TextBox txtSelPhone 
         Height          =   315
         Left            =   1320
         TabIndex        =   2
         Top             =   300
         Width           =   1335
      End
      Begin Threed.SSCommand cmdFindName 
         Height          =   315
         Left            =   3840
         TabIndex        =   5
         Top             =   660
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
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
         Picture         =   "frmLookupCustomer.frx":2756
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdAdd 
         Height          =   375
         Left            =   7080
         TabIndex        =   8
         Top             =   720
         Width           =   855
         _ExtentX        =   1508
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
         Caption         =   "&Add"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdCopy 
         Height          =   375
         Left            =   7080
         TabIndex        =   7
         Top             =   240
         Width           =   855
         _ExtentX        =   1508
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
         Caption         =   "&Copy"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdFindPhone 
         Height          =   315
         Left            =   2640
         TabIndex        =   3
         Top             =   300
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
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
         Picture         =   "frmLookupCustomer.frx":2CFC
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label2 
         Caption         =   "Full Name"
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   660
         Width           =   855
      End
      Begin VB.Label Label1 
         Caption         =   "Phone Number"
         Height          =   255
         Left            =   120
         TabIndex        =   1
         Top             =   300
         Width           =   1095
      End
   End
End
Attribute VB_Name = "frmLookupCustomer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdAdd_Click()
    Unload Me
    If ofx_IsFormLoaded(frmCustomer) Then
        frmCustomer.SetFocus
        SendKeys "% R", True
        frmCustomer.ZOrder
    Else
        Screen.MousePointer = vbHourglass
        frmCustomer.Show
    End If
End Sub


Private Sub cmdCopy_Click()
    If ofx_IsFormLoaded(frmSalesOrder) Then
        frmSalesOrder.txtCustomerName.Tag = dtcCustomer.Recordset!ID
        frmSalesOrder.txtCustomerName.Text = dtcCustomer.Recordset!FullName
        MsgBox "Customer " & dtcCustomer.Recordset!FullName & " is copied"
    End If
'    Call SetXchgCustomer(dtcCustomer.Recordset.Fields("FullName"), _
                         dtcCustomer.Recordset.Fields("ID"))
    Unload Me
End Sub

Private Sub cmdFindName_Click()
    If txtSelName <> "" Then
        ' Lookup dtcCustomer
        Screen.MousePointer = vbHourglass
        strSQL = "SELECT * FROM Customer " _
               & "WHERE FullName LIKE '*" & txtSelName.Text & "*' " _
               & "ORDER BY FullName"
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        If IsTableEmpty(dtcCustomer.Recordset) Then
            cmdCopy.Enabled = False
        Else
            dtcCustomer.UpdateControls
            cmdCopy.Enabled = True
        End If
        Screen.MousePointer = vbDefault
    End If
End Sub

Private Sub cmdFindPhone_Click()
    If txtSelPhone <> "" Then
        ' Lookup dtcCustomer
        Screen.MousePointer = vbHourglass
        strSQL = "SELECT * FROM Customer " _
               & "WHERE BizPhone LIKE '*" & txtSelPhone.Text & "*' " _
               & "Or HomePhone LIKE '*" & txtSelPhone.Text & "*' " _
               & "ORDER BY HomePhone, BizPhone, FullName"
        dtcCustomer.RecordSource = strSQL
        dtcCustomer.Refresh
        If IsTableEmpty(dtcCustomer.Recordset) Then
            cmdCopy.Enabled = False
        Else
            dtcCustomer.UpdateControls
            cmdCopy.Enabled = True
        End If
        Screen.MousePointer = vbDefault
    End If
End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault
    txtSelPhone.SetFocus
End Sub

Private Sub Form_Load()
    Call ofx_RestoreFormPosition(Me, True)
    cmdCopy.Enabled = False
End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_SaveFormPosition(Me)

End Sub






Private Sub txtSelName_GotFocus()
    Call AutoSelect(txtSelName)

End Sub


Private Sub txtSelName_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindName_Click
        KeyAscii = 0
    End If
End Sub


Private Sub txtSelPhone_GotFocus()
    Call AutoSelect(txtSelPhone)

End Sub


Private Sub txtSelPhone_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindPhone_Click
        KeyAscii = 0
    End If
End Sub



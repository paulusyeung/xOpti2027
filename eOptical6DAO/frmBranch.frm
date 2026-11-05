VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmBranch 
   Caption         =   "Branch"
   ClientHeight    =   5880
   ClientLeft      =   1155
   ClientTop       =   2325
   ClientWidth     =   9855
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5880
   ScaleWidth      =   9855
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Bindings        =   "frmBranch.frx":0000
      Height          =   2175
      Left            =   120
      OleObjectBlob   =   "frmBranch.frx":0014
      TabIndex        =   16
      Top             =   3600
      Width           =   9615
   End
   Begin VB.TextBox txtFields 
      DataField       =   "Country"
      DataSource      =   "Data1"
      Height          =   285
      Index           =   9
      Left            =   6240
      MaxLength       =   20
      TabIndex        =   11
      Top             =   3045
      Width           =   2295
   End
   Begin VB.TextBox txtFields 
      DataField       =   "PostalCode"
      DataSource      =   "Data1"
      Height          =   285
      Index           =   8
      Left            =   6240
      MaxLength       =   8
      TabIndex        =   10
      Top             =   2715
      Width           =   975
   End
   Begin VB.TextBox txtFields 
      DataField       =   "Province"
      DataSource      =   "Data1"
      Height          =   285
      Index           =   7
      Left            =   6240
      MaxLength       =   20
      TabIndex        =   9
      Top             =   2400
      Width           =   2295
   End
   Begin VB.TextBox txtFields 
      DataField       =   "City"
      DataSource      =   "Data1"
      Height          =   285
      Index           =   6
      Left            =   6240
      MaxLength       =   20
      TabIndex        =   8
      Top             =   2040
      Width           =   2295
   End
   Begin VB.TextBox txtFields 
      DataField       =   "Address2"
      DataSource      =   "Data1"
      Height          =   285
      Index           =   5
      Left            =   6240
      MaxLength       =   40
      TabIndex        =   7
      Top             =   1680
      Width           =   3375
   End
   Begin VB.TextBox txtFields 
      DataField       =   "Address1"
      DataSource      =   "Data1"
      Height          =   285
      Index           =   4
      Left            =   6240
      MaxLength       =   40
      TabIndex        =   6
      Top             =   1320
      Width           =   3375
   End
   Begin VB.Data Data1 
      Connect         =   "Access 2000;"
      DatabaseName    =   "SYNERGYV.MDB"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   1320
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Branch"
      Top             =   3240
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.TextBox txtFields 
      DataField       =   "Fax"
      DataSource      =   "Data1"
      Height          =   285
      Index           =   11
      Left            =   1320
      MaxLength       =   13
      TabIndex        =   15
      Top             =   2835
      Width           =   2055
   End
   Begin VB.TextBox txtFields 
      DataField       =   "Phone"
      DataSource      =   "Data1"
      Height          =   285
      Index           =   10
      Left            =   1320
      MaxLength       =   13
      TabIndex        =   13
      Top             =   2520
      Width           =   2055
   End
   Begin VB.TextBox txtFields 
      DataField       =   "JobTitle"
      DataSource      =   "Data1"
      Height          =   285
      Index           =   3
      Left            =   1320
      MaxLength       =   30
      TabIndex        =   5
      Top             =   2205
      Width           =   3375
   End
   Begin VB.TextBox txtFields 
      DataField       =   "ContactPerson"
      DataSource      =   "Data1"
      Height          =   285
      Index           =   2
      Left            =   1320
      MaxLength       =   40
      TabIndex        =   3
      Top             =   1875
      Width           =   3375
   End
   Begin VB.TextBox txtFields 
      DataField       =   "BranchName"
      DataSource      =   "Data1"
      Height          =   285
      Index           =   1
      Left            =   1320
      MaxLength       =   40
      TabIndex        =   1
      Top             =   1560
      Width           =   3375
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   18
      Top             =   0
      Width           =   9855
      _Version        =   131073
      _ExtentX        =   17383
      _ExtentY        =   1906
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
      FloatingCaption =   "SSToolbar1"
      AlreadyCreated  =   -1  'True
      Outline         =   0   'False
      BackColorHelp   =   12648447
      ToolsetNumBtnStates=   3
      BtnGroupSpacing =   4
      BtnSpacing      =   0
      Btns            =   9
      ToolsetPicture  =   "frmBranch.frx":2B79
      BC              =   9
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
      BtnPlaceHolder(7)=   0   'False
      BtnToolNum(8)   =   8
      BtnPlaceHolder(8)=   0   'False
      ToolsetNumTools =   9
      ToolsetToolID(0)=   "ID_Add"
      ToolsetToolHelp(0)=   "Add Record"
      ToolsetToolMnemonic(0)=   "a"
      ToolsetToolGroup(0)=   1
      ToolsetToolID(1)=   "ID_Delete"
      ToolsetToolHelp(1)=   "Delete Record"
      ToolsetToolMnemonic(1)=   "d"
      ToolsetToolGroup(1)=   1
      ToolsetToolID(2)=   "ID_Undo"
      ToolsetToolHelp(2)=   "Undo Edit"
      ToolsetToolMnemonic(2)=   "u"
      ToolsetToolGroup(2)=   1
      ToolsetToolID(3)=   "ID_Save"
      ToolsetToolHelp(3)=   "Save Record"
      ToolsetToolMnemonic(3)=   "s"
      ToolsetToolGroup(3)=   1
      ToolsetToolID(4)=   "ID_First"
      ToolsetToolHelp(4)=   "First Record"
      ToolsetToolMnemonic(4)=   "f"
      ToolsetToolGroup(4)=   2
      ToolsetToolID(5)=   "ID_Previous"
      ToolsetToolHelp(5)=   "Previous Record"
      ToolsetToolMnemonic(5)=   "p"
      ToolsetToolGroup(5)=   2
      ToolsetToolID(6)=   "ID_Next"
      ToolsetToolHelp(6)=   "Next Record"
      ToolsetToolMnemonic(6)=   "n"
      ToolsetToolGroup(6)=   2
      ToolsetToolID(7)=   "ID_Last"
      ToolsetToolHelp(7)=   "Last Record"
      ToolsetToolMnemonic(7)=   "l"
      ToolsetToolGroup(7)=   2
      ToolsetToolID(8)=   "ID_Exit"
      ToolsetToolHelp(8)=   "Exit Task"
      ToolsetToolMnemonic(8)=   "x"
      ToolsetToolGroup(8)=   3
      MouseIcon       =   "frmBranch.frx":1040B
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   2415
      Left            =   5040
      TabIndex        =   19
      Top             =   1080
      Width           =   4695
      _ExtentX        =   8281
      _ExtentY        =   4260
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
      Caption         =   "Home Address"
      Begin VB.Label Label1 
         Caption         =   "Street"
         Height          =   255
         Left            =   120
         TabIndex        =   24
         Top             =   240
         Width           =   975
      End
      Begin VB.Label Label2 
         Caption         =   "City"
         Height          =   255
         Left            =   120
         TabIndex        =   23
         Top             =   960
         Width           =   975
      End
      Begin VB.Label Label3 
         Caption         =   "Province"
         Height          =   255
         Left            =   120
         TabIndex        =   22
         Top             =   1320
         Width           =   975
      End
      Begin VB.Label Label4 
         Caption         =   "Postal Code"
         Height          =   255
         Left            =   120
         TabIndex        =   21
         Top             =   1680
         Width           =   975
      End
      Begin VB.Label Label5 
         Caption         =   "Country"
         Height          =   255
         Left            =   120
         TabIndex        =   20
         Top             =   2040
         Width           =   975
      End
   End
   Begin MSMask.MaskEdBox mskBranchCode 
      DataField       =   "BranchCode"
      DataSource      =   "Data1"
      Height          =   255
      Left            =   1320
      TabIndex        =   25
      Top             =   1200
      Width           =   615
      _ExtentX        =   1085
      _ExtentY        =   450
      _Version        =   393216
      PromptInclude   =   0   'False
      MaxLength       =   4
      Mask            =   ">aaaa"
      PromptChar      =   "_"
   End
   Begin VB.Label lblLabels 
      Caption         =   "BranchCode:"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   17
      Top             =   1200
      Width           =   1095
   End
   Begin VB.Label lblLabels 
      Caption         =   "Fax:"
      Height          =   255
      Index           =   11
      Left            =   120
      TabIndex        =   14
      Top             =   2865
      Width           =   1095
   End
   Begin VB.Label lblLabels 
      Caption         =   "Phone:"
      Height          =   255
      Index           =   10
      Left            =   120
      TabIndex        =   12
      Top             =   2535
      Width           =   1095
   End
   Begin VB.Label lblLabels 
      Caption         =   "JobTitle:"
      Height          =   255
      Index           =   3
      Left            =   120
      TabIndex        =   4
      Top             =   2220
      Width           =   1095
   End
   Begin VB.Label lblLabels 
      Caption         =   "ContactPerson:"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   2
      Top             =   1905
      Width           =   1095
   End
   Begin VB.Label lblLabels 
      Caption         =   "BranchName:"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   0
      Top             =   1575
      Width           =   1095
   End
End
Attribute VB_Name = "frmBranch"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdAdd_Click()
  Data1.Recordset.AddNew
End Sub

Private Sub cmdDelete_Click()
  'this may produce an error if you delete the last
  'record or the only record in the recordset
  Data1.Recordset.Delete
  Data1.Recordset.MoveNext
End Sub

Private Sub cmdRefresh_Click()
  'this is really only needed for multi user apps
  Data1.Refresh
End Sub

Private Sub cmdUpdate_Click()
  Data1.UpdateRecord
  Data1.Recordset.Bookmark = Data1.Recordset.LastModified
End Sub

Private Sub cmdClose_Click()
  Unload Me
End Sub

Private Sub Data1_Error(DataErr As Integer, Response As Integer)
  'This is where you would put error handling code
  'If you want to ignore errors, comment out the next line
  'If you want to trap them, add code here to handle them
  MsgBox "Data error event hit err:" & Error$(DataErr)
  Response = 0  'throw away the error
End Sub

Private Sub Data1_Reposition()
  Screen.MousePointer = vbDefault
  On Error Resume Next
  'This will display the current record position
  'for dynasets and snapshots
  Data1.Caption = "Record: " & (Data1.Recordset.AbsolutePosition + 1)
  'for the table object you must set the index property when
  'the recordset gets created and use the following line
  'Data1.Caption = "Record: " & (Data1.Recordset.RecordCount * (Data1.Recordset.PercentPosition * 0.01)) + 1
End Sub

Private Sub Data1_Validate(Action As Integer, Save As Integer)
  'This is where you put validation code
  'This event gets called when the following actions occur
  Select Case Action
    Case vbDataActionMoveFirst
    Case vbDataActionMovePrevious
    Case vbDataActionMoveNext
    Case vbDataActionMoveLast
    Case vbDataActionAddNew
    Case vbDataActionUpdate
    Case vbDataActionDelete
    Case vbDataActionFind
    Case vbDataActionBookmark
    Case vbDataActionClose
  End Select
  'Screen.MousePointer = vbHourglass
End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)

End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

    On Error GoTo SSToolbar1_Click_Err

    Select Case ToolID
        Case "ID_Add"
            Call DoAdd
        Case "ID_Delete"
            Data1.Recordset.Delete
            Data1.Recordset.MoveNext
        Case "ID_Undo"
            Data1.Refresh
        Case "ID_Save"
            Data1.UpdateRecord
            Data1.Recordset.Bookmark = Data1.Recordset.LastModified
            Data1.Refresh
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            Data1.Recordset.MoveFirst
        Case "ID_Next"
            Data1.Recordset.MoveNext
            If Data1.Recordset.EOF Then
                Beep
                Data1.Recordset.MoveLast
            End If
        Case "ID_Previous"
            Data1.Recordset.MovePrevious
            ' Prevent the Blank Record
            If Data1.Recordset.BOF Then
                Beep
                Data1.Recordset.MoveFirst
            End If
        Case "ID_Last"
            Data1.Recordset.MoveLast
    End Select

SSToolbar1_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSToolbar1_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSToolbar1_Click()", Err)  ' Tutorial Autocode
    Resume SSToolbar1_Click_Exit

End Sub



Private Sub DoAdd()
    With Data1.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    Data1.Recordset.AddNew
    mskBranchCode.SetFocus
End Sub

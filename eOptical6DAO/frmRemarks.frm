VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmRemarks 
   Caption         =   "Remarks"
   ClientHeight    =   5940
   ClientLeft      =   2055
   ClientTop       =   1965
   ClientWidth     =   8910
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5940
   ScaleWidth      =   8910
   Begin TrueDBGrid50.TDBGrid dbgRemarks 
      Bindings        =   "frmRemarks.frx":0000
      Height          =   3075
      Left            =   120
      OleObjectBlob   =   "frmRemarks.frx":0019
      TabIndex        =   3
      Top             =   2760
      Width           =   8655
   End
   Begin VB.TextBox txtRemarks 
      DataField       =   "Remarks"
      DataSource      =   "dtcRemarks"
      Height          =   1395
      Left            =   1200
      MultiLine       =   -1  'True
      TabIndex        =   2
      Text            =   "frmRemarks.frx":1670
      Top             =   1200
      Width           =   3615
   End
   Begin VB.Data dtcRemarks 
      Caption         =   "Remarks"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   7200
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT * FROM Z_DefaultRemarks WHERE Z_DefaultRemarks.Group = 0 ORDER BY Remarks"
      Top             =   1680
      Visible         =   0   'False
      Width           =   1140
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   8910
      _Version        =   131073
      _ExtentX        =   15716
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
      ToolsetNumBtnStates=   3
      Btns            =   9
      ToolsetPicture  =   "frmRemarks.frx":1676
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
      ToolsetToolHelp(0)=   "Add a new record"
      ToolsetToolMnemonic(0)=   "a"
      ToolsetToolGroup(0)=   1
      ToolsetToolID(1)=   "ID_Delete"
      ToolsetToolHelp(1)=   "Delete this record"
      ToolsetToolMnemonic(1)=   "d"
      ToolsetToolGroup(1)=   1
      ToolsetToolID(2)=   "ID_Refresh"
      ToolsetToolHelp(2)=   "Refresh this record"
      ToolsetToolMnemonic(2)=   "r"
      ToolsetToolGroup(2)=   1
      ToolsetToolID(3)=   "ID_Save"
      ToolsetToolHelp(3)=   "Save this record"
      ToolsetToolMnemonic(3)=   "s"
      ToolsetToolGroup(3)=   1
      ToolsetToolID(4)=   "ID_Close"
      ToolsetToolHelp(4)=   "Close and exit"
      ToolsetToolMnemonic(4)=   "c"
      ToolsetToolGroup(4)=   1
      ToolsetToolID(5)=   "ID_First"
      ToolsetToolHelp(5)=   "Goto first record"
      ToolsetToolMnemonic(5)=   "f"
      ToolsetToolGroup(5)=   2
      ToolsetToolID(6)=   "ID_Next"
      ToolsetToolHelp(6)=   "Next record"
      ToolsetToolMnemonic(6)=   "x"
      ToolsetToolGroup(6)=   2
      ToolsetToolID(7)=   "ID_Previous"
      ToolsetToolHelp(7)=   "Previous record"
      ToolsetToolMnemonic(7)=   "p"
      ToolsetToolGroup(7)=   2
      ToolsetToolID(8)=   "ID_Last"
      ToolsetToolHelp(8)=   "Goto last record"
      ToolsetToolMnemonic(8)=   "l"
      ToolsetToolGroup(8)=   2
      MouseIcon       =   "frmRemarks.frx":1CAC8
   End
   Begin VB.Label Label1 
      Caption         =   "Remarks"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   1200
      Width           =   855
   End
End
Attribute VB_Name = "frmRemarks"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)

End Sub


Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)
    Select Case ToolID
        Case "ID_Add"
            Call DoAdd
        Case "ID_Delete"
            dtcRemarks.Recordset.Delete
            dtcRemarks.Recordset.MoveNext
        Case "ID_Refresh"
            dtcRemarks.Refresh
        Case "ID_Save"
            If dtcRemarks.Recordset.EditMode = dbAddNew Then
                dtcRemarks.Recordset!Group = 0
            End If
            dtcRemarks.UpdateRecord
            dtcRemarks.Recordset.Bookmark = dtcRemarks.Recordset.LastModified
'            dtcRemarks.Refresh
        Case "ID_Close"
            Unload Me
        Case "ID_First"
            dtcRemarks.Recordset.MoveFirst
        Case "ID_Next"
            dtcRemarks.Recordset.MoveNext
            If dtcRemarks.Recordset.EOF Then
                Beep
                dtcRemarks.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcRemarks.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcRemarks.Recordset.BOF Then
                Beep
                dtcRemarks.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcRemarks.Recordset.MoveLast
    End Select
End Sub



Private Sub DoAdd()
    With dtcRemarks.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    dtcRemarks.Recordset.AddNew
    txtRemarks.SetFocus
End Sub

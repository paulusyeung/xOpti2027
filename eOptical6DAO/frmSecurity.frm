VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmSecurity 
   Caption         =   "Security Table"
   ClientHeight    =   5295
   ClientLeft      =   1530
   ClientTop       =   2400
   ClientWidth     =   8955
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5295
   ScaleWidth      =   8955
   Begin SSDesignerWidgetsToolbar.SSToolbar tbrSecurityTable 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   8955
      _Version        =   131073
      _ExtentX        =   15796
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
      ToolsetPicture  =   "frmSecurity.frx":0000
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
      MouseIcon       =   "frmSecurity.frx":D892
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   4035
      Left            =   120
      TabIndex        =   1
      Top             =   1140
      Width           =   8775
      _ExtentX        =   15478
      _ExtentY        =   7117
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
      Caption         =   "Security Table Browser"
      Begin TrueDBGrid50.TDBGrid TDBGrid1 
         Bindings        =   "frmSecurity.frx":D8AE
         Height          =   3615
         Left            =   120
         OleObjectBlob   =   "frmSecurity.frx":D8C8
         TabIndex        =   2
         Top             =   300
         Width           =   7815
      End
      Begin VB.Data dtcSecurity 
         Caption         =   "Security"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   315
         Left            =   6720
         Options         =   0
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "Security"
         Top             =   840
         Visible         =   0   'False
         Width           =   1215
      End
   End
End
Attribute VB_Name = "frmSecurity"
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


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub tbrSecurityTable_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)
    Select Case ToolID
        Case "ID_Add"
            dtcSecurity.Recordset.AddNew
        Case "ID_Delete"
            dtcSecurity.Recordset.Delete
            dtcSecurity.Recordset.MoveNext
        Case "ID_Undo"
            dtcSecurity.Refresh
        Case "ID_Save"
            dtcSecurity.UpdateRecord
            dtcSecurity.Recordset.Bookmark = dtcSecurity.Recordset.LastModified
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            dtcSecurity.Recordset.MoveFirst
        Case "ID_Next"
            dtcSecurity.Recordset.MoveNext
            If dtcSecurity.Recordset.EOF Then
                Beep
                dtcSecurity.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcSecurity.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcSecurity.Recordset.BOF Then
                Beep
                dtcSecurity.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcSecurity.Recordset.MoveLast
    End Select
End Sub



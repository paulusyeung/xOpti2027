VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmCountry 
   Caption         =   "Country"
   ClientHeight    =   4065
   ClientLeft      =   1440
   ClientTop       =   3405
   ClientWidth     =   8955
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4065
   ScaleWidth      =   8955
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Bindings        =   "frmCountry.frx":0000
      Height          =   1695
      Left            =   120
      OleObjectBlob   =   "frmCountry.frx":0019
      TabIndex        =   5
      TabStop         =   0   'False
      Top             =   2280
      Width           =   4575
   End
   Begin VB.TextBox txtPhoneCode 
      DataField       =   "CountryPhoneCode"
      DataSource      =   "dtcCountry"
      Height          =   285
      Left            =   1200
      MaxLength       =   4
      TabIndex        =   7
      Top             =   1920
      Width           =   495
   End
   Begin VB.Data dtcCountry 
      Caption         =   "Country"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   375
      Left            =   6000
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT * FROM Country ORDER BY CountryName"
      Top             =   1200
      Visible         =   0   'False
      Width           =   1935
   End
   Begin VB.TextBox Text1 
      DataField       =   "CountryName"
      DataSource      =   "dtcCountry"
      Height          =   285
      Left            =   1200
      TabIndex        =   4
      Top             =   1560
      Width           =   1695
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   0
      TabStop         =   0   'False
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
      ToolsetPicture  =   "frmCountry.frx":1EE6
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
      MouseIcon       =   "frmCountry.frx":F778
   End
   Begin MSMask.MaskEdBox mskCountryCode 
      DataField       =   "CountryCode"
      DataSource      =   "dtcCountry"
      Height          =   255
      Left            =   1200
      TabIndex        =   3
      Top             =   1200
      Width           =   495
      _ExtentX        =   873
      _ExtentY        =   450
      _Version        =   393216
      ClipMode        =   1
      PromptInclude   =   0   'False
      MaxLength       =   3
      Mask            =   ">aaa"
      PromptChar      =   "_"
   End
   Begin VB.Label Label3 
      Caption         =   "Phone Code"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   1920
      Width           =   975
   End
   Begin VB.Label Label2 
      Caption         =   "Country"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   1560
      Width           =   735
   End
   Begin VB.Label Label1 
      Caption         =   "Code"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   1200
      Width           =   735
   End
End
Attribute VB_Name = "frmCountry"
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

Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

    On Error GoTo SSToolbar1_Click_Err

    Select Case ToolID
        Case "ID_Add"
            Call DoAdd
        Case "ID_Delete"
            dtcCountry.Recordset.Delete
            dtcCountry.Recordset.MoveNext
        Case "ID_Undo"
            dtcCountry.Refresh
        Case "ID_Save"
            dtcCountry.UpdateRecord
            dtcCountry.Recordset.Bookmark = dtcCountry.Recordset.LastModified
            dtcCountry.Refresh
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            dtcCountry.Recordset.MoveFirst
        Case "ID_Next"
            dtcCountry.Recordset.MoveNext
            If dtcCountry.Recordset.EOF Then
                Beep
                dtcCountry.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcCountry.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcCountry.Recordset.BOF Then
                Beep
                dtcCountry.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcCountry.Recordset.MoveLast
    End Select

SSToolbar1_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSToolbar1_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSToolbar1_Click()", Err)  ' Tutorial Autocode
    Resume SSToolbar1_Click_Exit

End Sub



Private Sub DoAdd()
    With dtcCountry.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    dtcCountry.Recordset.AddNew
    mskCountryCode.SetFocus
End Sub

VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmBrand 
   Caption         =   "Brand"
   ClientHeight    =   4575
   ClientLeft      =   1395
   ClientTop       =   2985
   ClientWidth     =   8970
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4575
   ScaleWidth      =   8970
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Bindings        =   "frmBrand.frx":0000
      Height          =   2175
      Left            =   120
      OleObjectBlob   =   "frmBrand.frx":0017
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   2280
      Width           =   5535
   End
   Begin VB.TextBox txtBrandDescription 
      DataField       =   "BrandDescription"
      DataSource      =   "dtcBrand"
      Height          =   285
      Left            =   1560
      MaxLength       =   30
      TabIndex        =   5
      Text            =   "Text1"
      Top             =   1680
      Width           =   3255
   End
   Begin VB.Data dtcBrand 
      Caption         =   "dtcBrand"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   375
      Left            =   7080
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Brand"
      Top             =   1680
      Visible         =   0   'False
      Width           =   1695
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   8970
      _Version        =   131073
      _ExtentX        =   15822
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
      ToolsetPicture  =   "frmBrand.frx":1ABC
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
      MouseIcon       =   "frmBrand.frx":F34E
   End
   Begin MSMask.MaskEdBox mskBrandCode 
      DataField       =   "BrandCode"
      DataSource      =   "dtcBrand"
      Height          =   255
      Left            =   1560
      TabIndex        =   4
      Top             =   1200
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   450
      _Version        =   393216
      PromptInclude   =   0   'False
      MaxLength       =   4
      Mask            =   ">aaaa"
      PromptChar      =   "_"
   End
   Begin VB.Label Label2 
      Caption         =   "Brand Description:"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   1680
      Width           =   1335
   End
   Begin VB.Label Label1 
      Caption         =   "Brand Code:"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   1200
      Width           =   975
   End
End
Attribute VB_Name = "frmBrand"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub dbcBrandDescription_Click(intArea As Integer)

    On Error GoTo dbcBrandDescription_Click_Err

    If intArea = dbcAreaList Then
        Dim strSQL As String
        strSQL = "BrandDescription = '" & _
            dbcBrandDescription.Text & "'"
        dtcBrand.Recordset.FindFirst strSQL
        dtcBrand.UpdateControls
    End If

dbcBrandDescription_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                       ' Tutorial Autocode
    Exit Sub                                                   ' Tutorial Autocode
dbcBrandDescription_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcBrandDescription_Click()", Err)  ' Tutorial Autocode
    Resume dbcBrandDescription_Click_Exit

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

Private Sub mskBrandCode_GotFocus()
    Call AutoSelect(mskBrandCode)
End Sub

Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

    On Error GoTo SSToolbar1_Click_Err

    Select Case ToolID
        Case "ID_Add"
            Call DoAdd
        Case "ID_Delete"
            dtcBrand.Recordset.Delete
            dtcBrand.Recordset.MoveNext
        Case "ID_Undo"
            dtcBrand.Refresh
        Case "ID_Save"
            dtcBrand.UpdateRecord
            dtcBrand.Recordset.Bookmark = dtcBrand.Recordset.LastModified
            dtcBrand.Refresh
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            dtcBrand.Recordset.MoveFirst
        Case "ID_Next"
            dtcBrand.Recordset.MoveNext
            If dtcBrand.Recordset.EOF Then
                Beep
                dtcBrand.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcBrand.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcBrand.Recordset.BOF Then
                Beep
                dtcBrand.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcBrand.Recordset.MoveLast
    End Select

SSToolbar1_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSToolbar1_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSToolbar1_Click()", Err)  ' Tutorial Autocode
    Resume SSToolbar1_Click_Exit

End Sub


Private Sub Text1_Change()

End Sub


Private Sub Text1_GotFocus()

End Sub


Private Sub txtBrandDescription_GotFocus()
    Call AutoSelect(txtBrandDescription)
End Sub



Private Sub DoAdd()
    With dtcBrand.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    dtcBrand.Recordset.AddNew
    mskBrandCode.SetFocus
End Sub

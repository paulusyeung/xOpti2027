VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmCity 
   Caption         =   "City"
   ClientHeight    =   5700
   ClientLeft      =   1635
   ClientTop       =   2610
   ClientWidth     =   8955
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5700
   ScaleWidth      =   8955
   Begin VB.TextBox txtLastProvinceCode 
      Height          =   285
      Left            =   5280
      TabIndex        =   18
      TabStop         =   0   'False
      Top             =   1500
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.TextBox txtLastProvinceName 
      Height          =   285
      Left            =   4320
      TabIndex        =   17
      TabStop         =   0   'False
      Top             =   1500
      Visible         =   0   'False
      Width           =   975
   End
   Begin VB.TextBox txtLastCountryCode 
      Height          =   315
      Left            =   5280
      TabIndex        =   16
      TabStop         =   0   'False
      Top             =   1140
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.TextBox txtLastCountryName 
      Height          =   315
      Left            =   4320
      TabIndex        =   15
      TabStop         =   0   'False
      Top             =   1140
      Visible         =   0   'False
      Width           =   975
   End
   Begin VB.TextBox txtCityCode 
      BackColor       =   &H00C0C0C0&
      DataField       =   "Code"
      DataSource      =   "dtcCity"
      Height          =   285
      Left            =   1080
      Locked          =   -1  'True
      TabIndex        =   3
      TabStop         =   0   'False
      Top             =   1860
      Width           =   615
   End
   Begin VB.Data dtcProvince 
      Caption         =   "Province"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   5760
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT * FROM Province ORDER BY ProvinceName"
      Top             =   2220
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.Data dtcCountry 
      Caption         =   "Country"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   5760
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT * FROM Country ORDER BY CountryName"
      Top             =   1860
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.TextBox txtPhoneCode 
      DataField       =   "CityPhoneCode"
      DataSource      =   "dtcCity"
      Height          =   285
      Left            =   1080
      TabIndex        =   5
      Top             =   2520
      Width           =   615
   End
   Begin VB.Data dtcCity 
      Caption         =   "City"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   5760
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "City"
      Top             =   1440
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.TextBox txtCityName 
      DataField       =   "CityName"
      DataSource      =   "dtcCity"
      Height          =   285
      Left            =   1080
      TabIndex        =   4
      Top             =   2160
      Width           =   2415
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
      ToolsetPicture  =   "frmCity.frx":0000
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
      MouseIcon       =   "frmCity.frx":D892
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   2775
      Left            =   120
      TabIndex        =   19
      Top             =   2880
      Width           =   6375
      _ExtentX        =   11245
      _ExtentY        =   4895
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
      Caption         =   "Lookup Wizard"
      Begin TrueDBGrid50.TDBGrid TDBGrid1 
         Bindings        =   "frmCity.frx":D8AE
         Height          =   1755
         Left            =   120
         OleObjectBlob   =   "frmCity.frx":D8C4
         TabIndex        =   26
         TabStop         =   0   'False
         Top             =   900
         Width           =   6075
      End
      Begin MSDBCtls.DBCombo dbcSelProvince 
         Bindings        =   "frmCity.frx":FFF9
         Height          =   315
         Left            =   2760
         TabIndex        =   23
         TabStop         =   0   'False
         Top             =   540
         Width           =   2415
         _ExtentX        =   4260
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "ProvinceName"
         BoundColumn     =   "ProvinceCode"
         Text            =   "dbcSelProvince"
      End
      Begin MSDBCtls.DBCombo dbcSelCountry 
         Bindings        =   "frmCity.frx":10013
         Height          =   315
         Left            =   120
         TabIndex        =   22
         TabStop         =   0   'False
         Top             =   540
         Width           =   2295
         _ExtentX        =   4048
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "CountryName"
         BoundColumn     =   "CountryCode"
         Text            =   "dbcSelCountry"
      End
      Begin Threed.SSRibbon cmdCascadeProvince 
         Height          =   315
         Left            =   4800
         TabIndex        =   25
         Top             =   240
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmCity.frx":1002C
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmCity.frx":105FA
         GroupNumber     =   4
      End
      Begin Threed.SSRibbon cmdCascadeCountry 
         Height          =   315
         Left            =   2040
         TabIndex        =   24
         Top             =   240
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         BackColor       =   12632256
         PictureFrames   =   1
         Picture         =   "frmCity.frx":10BDC
         ButtonStyle     =   2
         BevelWidth      =   1
         PictureDnFrames =   1
         Outline         =   0   'False
         PictureDn       =   "frmCity.frx":111AA
         GroupNumber     =   3
      End
      Begin VB.Label Label7 
         Caption         =   "Province"
         Height          =   255
         Left            =   2760
         TabIndex        =   21
         Top             =   300
         Width           =   735
      End
      Begin VB.Label Label6 
         Caption         =   "Country"
         Height          =   255
         Left            =   120
         TabIndex        =   20
         Top             =   300
         Width           =   615
      End
   End
   Begin MSDBCtls.DBCombo dbcProvince 
      Bindings        =   "frmCity.frx":1178C
      DataField       =   "ProvinceCode"
      DataSource      =   "dtcCity"
      Height          =   315
      Left            =   1080
      TabIndex        =   2
      Top             =   1500
      Width           =   2415
      _ExtentX        =   4260
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "ProvinceName"
      BoundColumn     =   "ProvinceCode"
      Text            =   "dbcProvince"
   End
   Begin MSDBCtls.DBCombo dbcCountry 
      Bindings        =   "frmCity.frx":117A6
      DataField       =   "CountryCode"
      DataSource      =   "dtcCity"
      Height          =   315
      Left            =   1080
      TabIndex        =   1
      Top             =   1140
      Width           =   2415
      _ExtentX        =   4260
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "CountryName"
      BoundColumn     =   "CountryCode"
      Text            =   "dbcCountry"
   End
   Begin Threed.SSRibbon cmdLockProvince 
      Height          =   315
      Left            =   3480
      TabIndex        =   14
      Top             =   1500
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   556
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmCity.frx":117BF
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmCity.frx":11D21
      GroupNumber     =   2
   End
   Begin Threed.SSRibbon cmdLockCountry 
      Height          =   315
      Left            =   3480
      TabIndex        =   13
      Top             =   1140
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   556
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmCity.frx":12273
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmCity.frx":127D5
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   315
      Left            =   3840
      TabIndex        =   12
      TabStop         =   0   'False
      Top             =   1500
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
      Picture         =   "frmCity.frx":12D27
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   315
      Left            =   3840
      TabIndex        =   11
      TabStop         =   0   'False
      Top             =   1140
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
      Picture         =   "frmCity.frx":132F5
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin VB.Label Label5 
      Caption         =   "Province"
      Height          =   255
      Left            =   120
      TabIndex        =   10
      Top             =   1500
      Width           =   735
   End
   Begin VB.Label Label4 
      Caption         =   "Country"
      Height          =   255
      Left            =   120
      TabIndex        =   9
      Top             =   1140
      Width           =   615
   End
   Begin VB.Label Label3 
      Caption         =   "Phone Code"
      Height          =   255
      Left            =   120
      TabIndex        =   8
      Top             =   2520
      Width           =   975
   End
   Begin VB.Label Label2 
      Caption         =   "City"
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   2160
      Width           =   855
   End
   Begin VB.Label Label1 
      Caption         =   "City Code"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   1860
      Width           =   855
   End
End
Attribute VB_Name = "frmCity"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdLockCountry_Click(Value As Integer)
    Select Case Value
    Case True   ' Lock the Country Info
        ' Set button background color to white
        cmdLockCountry.BackColor = &HFFFFFF
        ' Lock the last Country Code & Country Name
        txtLastCountryName.Text = dbcCountry.Text
        txtLastCountryCode.Text = dbcCountry.BoundText
        ' Disable the dbcCountry
        dbcCountry.Enabled = False
    Case False  ' Unlock the Country Info
        ' Set button background color to gray
        cmdLockCountry.BackColor = &HC0C0C0      ' Gray
        ' Enable the dbcCountry
        dbcCountry.Enabled = True
    End Select

End Sub

Private Sub cmdLockProvince_Click(Value As Integer)
    Select Case Value
    Case True   ' Lock the Province Info
        ' Set button background color to white
        cmdLockProvince.BackColor = &HFFFFFF
        ' Lock the last Province Code & Province Name
        txtLastProvinceName.Text = dbcProvince.Text
        txtLastProvinceCode.Text = dbcProvince.BoundText
        ' Disable the dbcProvince
        dbcProvince.Enabled = False
    Case False  ' Unlock the Province Info
        ' Set button background color to gray
        cmdLockProvince.BackColor = &HC0C0C0      ' Gray
        ' Enable the dbcProvince
        dbcProvince.Enabled = True
    End Select

End Sub

Private Sub dbcSelCountry_Click(intArea As Integer)
    If intArea = dbcAreaList Then
        ' Lookup dtcCity
        If cmdCascadeCountry.Value Then    ' Cascade selected
            LookupByCascade
        Else                            ' No cascade
            strSQL = "SELECT * FROM City " _
                & "WHERE CountryCode = '" & dbcSelCountry.BoundText & "' " _
                & "ORDER BY CityName"
            dtcCity.RecordSource = strSQL
            dtcCity.Refresh
            dtcCity.UpdateControls
        End If
    End If

End Sub

Private Sub dbcSelProvince_Click(intArea As Integer)
    If intArea = dbcAreaList Then
        ' Lookup dtcCity
        If cmdCascadeProvince.Value Then    ' Cascade selected
            LookupByCascade
        Else                            ' No cascade
            strSQL = "SELECT * FROM City " _
                & "WHERE ProvinceCode = '" & dbcSelProvince.BoundText & "' " _
                & "ORDER BY CityName"
            dtcCity.RecordSource = strSQL
            dtcCity.Refresh
            dtcCity.UpdateControls
        End If
    End If

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

Private Sub SSCommand1_Click()
    If ofx_IsFormLoaded(frmCountry) Then _
        Unload frmCountry
    Screen.MousePointer = vbHourglass
    frmCountry.Show vbModal
    dtcCountry.Refresh
    dtcCountry.UpdateControls
End Sub

Private Sub SSCommand2_Click()
    If ofx_IsFormLoaded(frmProvince) Then _
        Unload frmProvince
    Screen.MousePointer = vbHourglass
    frmProvince.Show vbModal
    dtcProvince.Refresh
    dtcProvince.UpdateControls
End Sub



Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

    On Error GoTo SSToolbar1_Click_Err

    Select Case ToolID
        Case "ID_Add"
            Call DoAdd
        Case "ID_Delete"
            dtcCity.Recordset.Delete
            dtcCity.Recordset.MoveNext
        Case "ID_Undo"
            dtcCity.Refresh
        Case "ID_Save"
            txtLastCountryName = dbcCountry.Text
            txtLastCountryCode = dbcCountry.BoundText
            txtLastProvinceName = dbcProvince.Text
            txtLastProvinceCode = dbcProvince.BoundText
            If dtcCity.Recordset.Fields("CountryCode") = "" Or _
               IsNull(dtcCity.Recordset.Fields("CountryCode")) Then
                dtcCity.Recordset.Fields("CountryCode") = dbcCountry.BoundText
                dtcCity.Recordset.Fields("ProvinceCode") = dbcProvince.BoundText
            End If
            dtcCity.UpdateRecord
            dtcCity.Recordset.Bookmark = dtcCity.Recordset.LastModified
            dtcCity.Refresh
        Case "ID_Exit"
            dtcCity.Refresh
            Unload Me
        Case "ID_First"
            dtcCity.Recordset.MoveFirst
        Case "ID_Next"
            dtcCity.Recordset.MoveNext
            If dtcCity.Recordset.EOF Then
                Beep
                dtcCity.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcCity.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcCity.Recordset.BOF Then
                Beep
                dtcCity.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcCity.Recordset.MoveLast
    End Select

SSToolbar1_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSToolbar1_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSToolbar1_Click()", Err)  ' Tutorial Autocode
    Resume SSToolbar1_Click_Exit

End Sub



Private Sub LookupByCascade()
    Dim strSQL As String
    Dim blnCascade As Boolean
        
    strSQL = "SELECT * FROM City WHERE "
    If cmdCascadeCountry.Value Then
        If dbcSelCountry.BoundText <> "" Then
            strSQL = strSQL & "CountryCode = '" & dbcSelCountry.BoundText & "' "
            blnCascade = True
        End If
    End If
    If cmdCascadeProvince.Value Then
        If dbcSelProvince.BoundText <> "" Then
            If blnCascade Then strSQL = strSQL & "And "
            strSQL = strSQL & "ProvinceCode = '" & dbcSelProvince.BoundText & "' "
            blnCascade = True
        End If
    End If
    strSQL = strSQL & "ORDER BY CityName"
    dtcCity.RecordSource = strSQL
    dtcCity.Refresh
    dtcCity.UpdateControls

End Sub

Private Sub DoAdd()
    With dtcCity.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    dtcCity.Recordset.AddNew
    If cmdLockCountry.Value Then
        dbcCountry.Text = txtLastCountryName.Text
        dbcCountry.BoundText = txtLastCountryCode.Text
    End If
    If cmdLockProvince.Value Then
        dbcProvince.Text = txtLastProvinceName.Text
        dbcProvince.BoundText = txtLastProvinceCode.Text
    End If
    ' Set focus
    If dbcCountry.Enabled And dbcProvince.Enabled Then
        dbcCountry.SetFocus
    ElseIf dbcProvince.Enabled Then
        dbcProvince.SetFocus
    ElseIf dbcCountry.Enabled Then
        dbcCountry.SetFocus
    Else
        txtCityName.SetFocus
    End If
End Sub

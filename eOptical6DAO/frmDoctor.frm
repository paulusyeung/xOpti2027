VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmDoctor 
   Caption         =   "Doctor"
   ClientHeight    =   5940
   ClientLeft      =   2820
   ClientTop       =   1710
   ClientWidth     =   8955
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5940
   ScaleWidth      =   8955
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Bindings        =   "frmDoctor.frx":0000
      Height          =   2115
      Left            =   120
      OleObjectBlob   =   "frmDoctor.frx":0018
      TabIndex        =   3
      TabStop         =   0   'False
      Top             =   3720
      Width           =   8655
   End
   Begin VB.TextBox txtSyncCountry 
      BackColor       =   &H0000FFFF&
      DataField       =   "CountryName"
      DataSource      =   "dtcSelCity"
      Height          =   285
      Left            =   6480
      Locked          =   -1  'True
      TabIndex        =   30
      TabStop         =   0   'False
      Text            =   "Text2"
      Top             =   3060
      Visible         =   0   'False
      Width           =   1575
   End
   Begin VB.TextBox txtSyncProvince 
      BackColor       =   &H0000FFFF&
      DataField       =   "ProvinceName"
      DataSource      =   "dtcSelCity"
      Height          =   285
      Left            =   6480
      Locked          =   -1  'True
      TabIndex        =   29
      TabStop         =   0   'False
      Text            =   "Text1"
      Top             =   2700
      Visible         =   0   'False
      Width           =   1575
   End
   Begin VB.Data dtcSelCity 
      Caption         =   "SelCity"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   6720
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "qryCityFullList"
      Top             =   2100
      Visible         =   0   'False
      Width           =   2055
   End
   Begin VB.Data dtcCity 
      Caption         =   "City"
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
      RecordSource    =   "SELECT * FROM City ORDER BY CityName"
      Top             =   1740
      Visible         =   0   'False
      Width           =   2055
   End
   Begin VB.Data dtcDoctor 
      Caption         =   "Doctor"
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
      RecordSource    =   "SELECT * FROM Doctor ORDER BY DoctorName"
      Top             =   1320
      Visible         =   0   'False
      Width           =   2055
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
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
      ToolsetPicture  =   "frmDoctor.frx":2735
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
      MouseIcon       =   "frmDoctor.frx":FFC7
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   2235
      Left            =   120
      TabIndex        =   2
      Top             =   1380
      Width           =   5895
      _ExtentX        =   10398
      _ExtentY        =   3942
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
      Caption         =   "Business"
      Begin VB.TextBox Text4 
         BackColor       =   &H00C0C0C0&
         DataField       =   "CountryName"
         DataSource      =   "dtcSelCity"
         Height          =   285
         Left            =   1200
         Locked          =   -1  'True
         TabIndex        =   19
         TabStop         =   0   'False
         Text            =   "Text4"
         Top             =   1500
         Width           =   1815
      End
      Begin VB.TextBox Text3 
         BackColor       =   &H00C0C0C0&
         DataField       =   "ProvinceName"
         DataSource      =   "dtcSelCity"
         Height          =   285
         Left            =   1200
         Locked          =   -1  'True
         TabIndex        =   18
         TabStop         =   0   'False
         Text            =   "Text3"
         Top             =   1200
         Width           =   1815
      End
      Begin VB.TextBox txtAddress 
         DataField       =   "Address"
         DataSource      =   "dtcDoctor"
         Height          =   495
         Left            =   1200
         MultiLine       =   -1  'True
         TabIndex        =   16
         Text            =   "frmDoctor.frx":FFE3
         Top             =   300
         Width           =   2175
      End
      Begin Threed.SSFrame SSFrame2 
         Height          =   1995
         Left            =   3480
         TabIndex        =   4
         Top             =   120
         Width           =   2295
         _ExtentX        =   4048
         _ExtentY        =   3519
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
         Caption         =   "Phone"
         Begin VB.TextBox Text6 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CityPhoneCode"
            DataSource      =   "dtcSelCity"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   22
            TabStop         =   0   'False
            Text            =   "Text6"
            Top             =   600
            Width           =   495
         End
         Begin VB.TextBox Text5 
            BackColor       =   &H00C0C0C0&
            DataField       =   "CountryPhoneCode"
            DataSource      =   "dtcSelCity"
            Height          =   285
            Left            =   1200
            Locked          =   -1  'True
            TabIndex        =   21
            TabStop         =   0   'False
            Text            =   "Text5"
            Top             =   300
            Width           =   495
         End
         Begin MSMask.MaskEdBox mskEmergency 
            Height          =   255
            Left            =   1200
            TabIndex        =   25
            Top             =   1560
            Width           =   975
            _ExtentX        =   1720
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   8
            Mask            =   "### ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskFax 
            DataField       =   "Fax"
            DataSource      =   "dtcDoctor"
            Height          =   255
            Left            =   1200
            TabIndex        =   24
            Top             =   1260
            Width           =   975
            _ExtentX        =   1720
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   8
            Mask            =   "### ####"
            PromptChar      =   "_"
         End
         Begin MSMask.MaskEdBox mskPhone 
            DataField       =   "Phone"
            DataSource      =   "dtcDoctor"
            Height          =   255
            Left            =   1200
            TabIndex        =   23
            Top             =   960
            Width           =   975
            _ExtentX        =   1720
            _ExtentY        =   450
            _Version        =   393216
            PromptInclude   =   0   'False
            MaxLength       =   8
            Mask            =   "### ####"
            PromptChar      =   "_"
         End
         Begin VB.Label Label11 
            Caption         =   "Emergency"
            Height          =   195
            Left            =   120
            TabIndex        =   14
            Top             =   1560
            Width           =   855
         End
         Begin VB.Label Label10 
            Caption         =   "Fax"
            Height          =   255
            Left            =   120
            TabIndex        =   13
            Top             =   1260
            Width           =   375
         End
         Begin VB.Label Label9 
            Caption         =   "Phone"
            Height          =   255
            Left            =   120
            TabIndex        =   12
            Top             =   960
            Width           =   495
         End
         Begin VB.Label Label8 
            Caption         =   "City Code"
            Height          =   255
            Left            =   120
            TabIndex        =   11
            Top             =   600
            Width           =   855
         End
         Begin VB.Label Label7 
            Caption         =   "Country Code"
            Height          =   255
            Left            =   120
            TabIndex        =   10
            Top             =   300
            Width           =   975
         End
      End
      Begin MSMask.MaskEdBox mskPostalCode 
         DataField       =   "PostalCode"
         DataSource      =   "dtcDoctor"
         Height          =   255
         Left            =   1200
         TabIndex        =   20
         Top             =   1800
         Width           =   855
         _ExtentX        =   1508
         _ExtentY        =   450
         _Version        =   393216
         PromptInclude   =   0   'False
         MaxLength       =   7
         Mask            =   ">a#a#a##"
         PromptChar      =   "_"
      End
      Begin MSDBCtls.DBCombo dbcCity 
         Bindings        =   "frmDoctor.frx":FFE9
         DataField       =   "City"
         DataSource      =   "dtcDoctor"
         Height          =   315
         Left            =   1200
         TabIndex        =   17
         Top             =   840
         Width           =   1815
         _ExtentX        =   3201
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "CityName"
         BoundColumn     =   "Code"
         Text            =   "dbcCity"
      End
      Begin Threed.SSCommand SSCommand1 
         Height          =   315
         Left            =   3000
         TabIndex        =   26
         TabStop         =   0   'False
         Top             =   840
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
         Picture         =   "frmDoctor.frx":FFFF
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label6 
         Caption         =   "Postal Code"
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   1800
         Width           =   855
      End
      Begin VB.Label Label5 
         Caption         =   "Country"
         Height          =   255
         Left            =   120
         TabIndex        =   8
         Top             =   1500
         Width           =   615
      End
      Begin VB.Label Label4 
         Caption         =   "Province"
         Height          =   255
         Left            =   120
         TabIndex        =   7
         Top             =   1200
         Width           =   735
      End
      Begin VB.Label Label3 
         Caption         =   "City"
         Height          =   255
         Left            =   120
         TabIndex        =   6
         Top             =   840
         Width           =   375
      End
      Begin VB.Label Label2 
         Caption         =   "Address"
         Height          =   255
         Left            =   120
         TabIndex        =   5
         Top             =   300
         Width           =   615
      End
   End
   Begin MSMask.MaskEdBox mskDrName 
      DataField       =   "DoctorName"
      DataSource      =   "dtcDoctor"
      Height          =   255
      Left            =   1320
      TabIndex        =   15
      Top             =   1140
      Width           =   2175
      _ExtentX        =   3836
      _ExtentY        =   450
      _Version        =   393216
      MaxLength       =   40
      PromptChar      =   "_"
   End
   Begin Threed.SSRibbon cmdSortByDrName 
      Height          =   330
      Left            =   1800
      TabIndex        =   28
      Top             =   3720
      Width           =   330
      _ExtentX        =   582
      _ExtentY        =   582
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmDoctor.frx":105CD
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmDoctor.frx":10B73
   End
   Begin Threed.SSRibbon cmdSortByPhone 
      Height          =   330
      Left            =   3840
      TabIndex        =   27
      Top             =   3720
      Width           =   330
      _ExtentX        =   582
      _ExtentY        =   582
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmDoctor.frx":1112D
      AutoSize        =   2
      ButtonStyle     =   2
      BevelWidth      =   1
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmDoctor.frx":116D3
   End
   Begin VB.Label Label1 
      Caption         =   "Doctor Name"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   1140
      Width           =   1095
   End
End
Attribute VB_Name = "frmDoctor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdSortByDrName_Click(Value As Integer)

    Dim strSQL As String
    
    If cmdSortByDrName.Value Then
        strSQL = "SELECT * FROM Doctor ORDER BY DoctorName ASC"
    Else
        strSQL = "SELECT * FROM Doctor ORDER BY DoctorName DESC"
    End If
    dtcDoctor.RecordSource = strSQL
    dtcDoctor.Refresh
    dtcDoctor.UpdateControls

End Sub

Private Sub cmdSortByPhone_Click(Value As Integer)

    Dim strSQL As String
    
    If cmdSortByPhone.Value Then
        strSQL = "SELECT * FROM Doctor ORDER BY Phone ASC"
    Else
        strSQL = "SELECT * FROM Doctor ORDER BY Phone DESC"
    End If
    dtcDoctor.RecordSource = strSQL
    dtcDoctor.Refresh
    dtcDoctor.UpdateControls

End Sub


Private Sub dbcCity_Click(intArea As Integer)

    Dim strTarget As String
    
    If intArea = dbcAreaList Then
        ' Sync dtcCity
        strTarget = "Code = " & dbcCity.BoundText
        dtcSelCity.Recordset.FindFirst strTarget
        If Not dtcSelCity.Recordset.NoMatch Then
            dtcSelCity.UpdateControls
            ' Fill Supplier fields: Province and Country
            If Not (dtcDoctor.Recordset.EditMode = dbEditAdd) Then dtcDoctor.Recordset.Edit
            dtcDoctor.Recordset!Province = dtcSelCity.Recordset!ProvinceCode
            dtcDoctor.Recordset!Country = dtcSelCity.Recordset!CountryCode
        End If
    End If

End Sub

Private Sub dbcCity_GotFocus()
    ' Show Province and Country
    txtSyncProvince.Visible = True
    txtSyncCountry.Visible = True
    txtSyncProvince.ZOrder
    txtSyncCountry.ZOrder

End Sub


Private Sub dbcCity_LostFocus()
    ' Hide Province and Country
    txtSyncProvince.Visible = False
    txtSyncCountry.Visible = False

End Sub

Private Sub dtcDoctor_Reposition()

    Dim strTarget As String
    
    ' Synconize the related tables
    If Not (dtcDoctor.Recordset.EOF Or dtcDoctor.Recordset.BOF) Then
        If dtcDoctor.Recordset!City <> "" Then
            ' Sync dtcCity
            strTarget = "Code = " & dtcDoctor.Recordset!City
            dtcSelCity.Recordset.FindFirst strTarget
            If Not dtcSelCity.Recordset.NoMatch Then _
                dtcSelCity.UpdateControls
        End If
    End If

End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
    cmdSortByPhone.ZOrder
    cmdSortByDrName.ZOrder
End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub mskEmergency_GotFocus()
    Call AutoSelect(mskEmergency)
End Sub

Private Sub mskFax_GotFocus()
    Call AutoSelect(mskFax)
End Sub

Private Sub mskPhone_GotFocus()
    Call AutoSelect(mskPhone)
End Sub

Private Sub mskPostalCode_GotFocus()
    Call AutoSelect(mskPostalCode)
End Sub

Private Sub SSCommand1_Click()
    If ofx_IsFormLoaded(frmCity) Then _
        Unload frmCity
    Screen.MousePointer = vbHourglass
    frmCity.Show vbModal
    dtcCity.Refresh
    dtcCity.UpdateControls
    dtcSelCity.Refresh
    dtcSelCity.UpdateControls
End Sub


Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

    Select Case ToolID
        Case "ID_Add"
            Call DoAdd
        Case "ID_Delete"
            dtcDoctor.Recordset.Delete
            dtcDoctor.Recordset.MoveNext
        Case "ID_Undo"
            dtcDoctor.Refresh
        Case "ID_Save"
            dtcDoctor.UpdateRecord
            dtcDoctor.Recordset.Bookmark = dtcDoctor.Recordset.LastModified
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            dtcDoctor.Recordset.MoveFirst
        Case "ID_Next"
            dtcDoctor.Recordset.MoveNext
            If dtcDoctor.Recordset.EOF Then
                Beep
                dtcDoctor.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcDoctor.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcDoctor.Recordset.BOF Then
                Beep
                dtcDoctor.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcDoctor.Recordset.MoveLast
    End Select

End Sub




Private Sub DoAdd()
    With dtcDoctor.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    dtcDoctor.Recordset.AddNew
    mskDrName.SetFocus
End Sub

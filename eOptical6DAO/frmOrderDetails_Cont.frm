VERSION 5.00
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmOrderDetails_Cont 
   Caption         =   "Order Details - Contact Lens/Disposal Lens"
   ClientHeight    =   3870
   ClientLeft      =   2925
   ClientTop       =   2865
   ClientWidth     =   8175
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3870
   ScaleWidth      =   8175
   Begin VB.Data dtcDoctor 
      Caption         =   "Doctor"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   5640
      Options         =   4
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT ID, DoctorName FROM Doctor ORDER BY DoctorName"
      Top             =   180
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Data dtcTxSOrderCont 
      Caption         =   "TxSOrderCont"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   5400
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "TxSOrderCont"
      Top             =   3060
      Visible         =   0   'False
      Width           =   1140
   End
   Begin Threed.SSFrame fraPrescription 
      Height          =   2655
      Left            =   120
      TabIndex        =   0
      Top             =   60
      Width           =   6975
      _ExtentX        =   12303
      _ExtentY        =   4683
      _Version        =   131074
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Prescription"
      Begin VB.TextBox txtTest 
         DataField       =   "Test"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   4680
         TabIndex        =   43
         Text            =   "Text22"
         Top             =   2220
         Width           =   2175
      End
      Begin VB.TextBox txtEvaluation 
         DataField       =   "Evaluation"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   4680
         TabIndex        =   42
         Text            =   "Text21"
         Top             =   1920
         Width           =   2175
      End
      Begin VB.TextBox txtReason 
         DataField       =   "Reason"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   315
         Left            =   4680
         TabIndex        =   41
         Text            =   "Text20"
         Top             =   1560
         Width           =   2175
      End
      Begin VB.TextBox txtAllergy 
         DataField       =   "Allergy"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   960
         TabIndex        =   40
         Text            =   "Text19"
         Top             =   2220
         Width           =   2535
      End
      Begin VB.TextBox txtMedical 
         DataField       =   "Medical"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   315
         Left            =   960
         TabIndex        =   39
         Text            =   "Text18"
         Top             =   1860
         Width           =   2535
      End
      Begin VB.TextBox txtHistory 
         DataField       =   "History"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   960
         TabIndex        =   38
         Text            =   "Text17"
         Top             =   1560
         Width           =   2535
      End
      Begin VB.TextBox txtLeftPupil 
         DataField       =   "LeftPupil"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   5760
         TabIndex        =   37
         Text            =   "Text16"
         Top             =   1200
         Width           =   615
      End
      Begin VB.TextBox txtLeftCorn 
         DataField       =   "LeftCorn"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   5160
         TabIndex        =   36
         Text            =   "Text15"
         Top             =   1200
         Width           =   615
      End
      Begin VB.TextBox txtLeftPalp 
         DataField       =   "LeftPalp"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   4560
         TabIndex        =   35
         Text            =   "Text14"
         Top             =   1200
         Width           =   615
      End
      Begin VB.TextBox txtLeftKReadingH 
         DataField       =   "LeftKReadingH"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   3840
         TabIndex        =   34
         Text            =   "Text13"
         Top             =   1200
         Width           =   735
      End
      Begin VB.TextBox txtLeftKReadingV 
         DataField       =   "LeftKReadingV"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   3000
         TabIndex        =   33
         Text            =   "Text12"
         Top             =   1200
         Width           =   735
      End
      Begin VB.TextBox txtLeftAxis 
         DataField       =   "LeftAxis"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   2520
         TabIndex        =   32
         Text            =   "Text11"
         Top             =   1200
         Width           =   495
      End
      Begin VB.TextBox txtLeftCylinder 
         DataField       =   "LeftCylinder"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   1680
         TabIndex        =   31
         Text            =   "Text10"
         Top             =   1200
         Width           =   855
      End
      Begin VB.TextBox txtLeftSphere 
         DataField       =   "LeftSphere"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   960
         TabIndex        =   30
         Text            =   "Text9"
         ToolTipText     =   "Accepts -20.00 to 20.00, step 0.25"
         Top             =   1200
         Width           =   735
      End
      Begin VB.TextBox txtRightPupil 
         DataField       =   "RightPupil"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   5760
         TabIndex        =   29
         Text            =   "Text8"
         Top             =   900
         Width           =   615
      End
      Begin VB.TextBox txtRightCorn 
         DataField       =   "RightCorn"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   5160
         TabIndex        =   28
         Text            =   "Text7"
         Top             =   900
         Width           =   615
      End
      Begin VB.TextBox txtRightPalp 
         DataField       =   "RightPalp"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   4560
         TabIndex        =   27
         Text            =   "Text6"
         Top             =   900
         Width           =   615
      End
      Begin VB.TextBox txtRightKReadingH 
         DataField       =   "RightKReadingH"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   3840
         TabIndex        =   26
         Text            =   "Text5"
         Top             =   900
         Width           =   735
      End
      Begin VB.TextBox txtRightKReadingV 
         DataField       =   "RightKReadingV"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   3000
         TabIndex        =   25
         Text            =   "Text4"
         Top             =   900
         Width           =   735
      End
      Begin VB.TextBox txtRightAxis 
         DataField       =   "RightAxis"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   2520
         TabIndex        =   24
         Text            =   "Text3"
         Top             =   900
         Width           =   495
      End
      Begin VB.TextBox txtRightCylinder 
         DataField       =   "RightCylinder"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   1680
         TabIndex        =   23
         Text            =   "Text2"
         Top             =   900
         Width           =   855
      End
      Begin VB.TextBox txtRightSphere 
         DataField       =   "RightSphere"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   285
         Left            =   960
         TabIndex        =   22
         Text            =   "Text1"
         ToolTipText     =   "Accepts -20.00 to 20.00, step 0.25"
         Top             =   900
         Width           =   735
      End
      Begin MSDBCtls.DBCombo dbcDoctor 
         Bindings        =   "frmOrderDetails_Cont.frx":0000
         DataField       =   "IssuedBy"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   315
         Left            =   4680
         TabIndex        =   21
         Top             =   240
         Width           =   2175
         _ExtentX        =   3836
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "DoctorName"
         BoundColumn     =   "ID"
         Text            =   ""
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
      End
      Begin SSCalendarWidgets_A.SSDateCombo calIssuedOn 
         DataField       =   "IssuedOn"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   315
         Left            =   960
         TabIndex        =   20
         Top             =   240
         Width           =   2055
         _Version        =   65543
         _ExtentX        =   3625
         _ExtentY        =   556
         _StockProps     =   93
         BeginProperty DropDownFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Format          =   "MMMM DD, YYYY"
         ShowCentury     =   -1  'True
      End
      Begin VB.Label Label17 
         Caption         =   "Test"
         Height          =   195
         Left            =   3840
         TabIndex        =   18
         Top             =   2220
         Width           =   375
      End
      Begin VB.Label Label16 
         Caption         =   "Evaluation"
         Height          =   255
         Left            =   3840
         TabIndex        =   17
         Top             =   1920
         Width           =   855
      End
      Begin VB.Label Label15 
         Caption         =   "Reason"
         Height          =   255
         Left            =   3840
         TabIndex        =   16
         Top             =   1560
         Width           =   615
      End
      Begin VB.Label Label14 
         Caption         =   "Allergy"
         Height          =   255
         Left            =   120
         TabIndex        =   15
         Top             =   2220
         Width           =   495
      End
      Begin VB.Label Label13 
         Caption         =   "Medical"
         Height          =   255
         Left            =   120
         TabIndex        =   14
         Top             =   1860
         Width           =   615
      End
      Begin VB.Label Label12 
         Caption         =   "History"
         Height          =   255
         Left            =   120
         TabIndex        =   13
         Top             =   1560
         Width           =   615
      End
      Begin VB.Label Label11 
         Caption         =   "L"
         Height          =   255
         Left            =   720
         TabIndex        =   12
         Top             =   1200
         Width           =   135
      End
      Begin VB.Label Label10 
         Caption         =   "R"
         Height          =   255
         Left            =   720
         TabIndex        =   11
         Top             =   900
         Width           =   135
      End
      Begin VB.Label Label9 
         Caption         =   "Pupil"
         Height          =   255
         Left            =   5880
         TabIndex        =   10
         Top             =   660
         Width           =   375
      End
      Begin VB.Label Label8 
         Caption         =   "Corn"
         Height          =   255
         Left            =   5280
         TabIndex        =   9
         Top             =   660
         Width           =   375
      End
      Begin VB.Label Label7 
         Caption         =   "Palp"
         Height          =   255
         Left            =   4680
         TabIndex        =   8
         Top             =   660
         Width           =   375
      End
      Begin VB.Label Label6 
         Caption         =   "K-reading"
         Height          =   255
         Left            =   3480
         TabIndex        =   7
         Top             =   660
         Width           =   735
      End
      Begin VB.Label Label5 
         Caption         =   "Axis"
         Height          =   255
         Left            =   2640
         TabIndex        =   6
         Top             =   660
         Width           =   375
      End
      Begin VB.Label Label4 
         Caption         =   "Cylinder"
         Height          =   255
         Left            =   1800
         TabIndex        =   5
         Top             =   660
         Width           =   615
      End
      Begin VB.Label Label3 
         Caption         =   "Sphere"
         Height          =   255
         Left            =   1080
         TabIndex        =   4
         Top             =   660
         Width           =   615
      End
      Begin VB.Label Label2 
         Caption         =   "Issued by Doctor"
         Height          =   255
         Left            =   3360
         TabIndex        =   3
         Top             =   240
         Width           =   1215
      End
      Begin VB.Label Label1 
         Caption         =   "Issued on"
         Height          =   255
         Left            =   120
         TabIndex        =   2
         Top             =   240
         Width           =   735
      End
   End
   Begin Threed.SSFrame fraNotes 
      Height          =   975
      Left            =   120
      TabIndex        =   1
      Top             =   2760
      Width           =   6975
      _ExtentX        =   12303
      _ExtentY        =   1720
      _Version        =   131074
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Notes"
      Begin VB.TextBox txtSpecialInstruction 
         DataField       =   "SpecialInstruction"
         DataSource      =   "dtcTxSOrderCont"
         Height          =   615
         Left            =   960
         TabIndex        =   44
         Text            =   "Text23"
         Top             =   240
         Width           =   2535
      End
      Begin VB.Label Label18 
         Caption         =   "Special Instruction"
         Height          =   375
         Left            =   120
         TabIndex        =   19
         Top             =   240
         Width           =   735
      End
   End
   Begin Threed.SSCommand cmdRefresh 
      Height          =   375
      Left            =   7200
      TabIndex        =   49
      Top             =   120
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
      Caption         =   "Refresh"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdStore 
      Height          =   375
      Left            =   7200
      TabIndex        =   48
      ToolTipText     =   "Store Prescription"
      Top             =   2040
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   661
      _Version        =   131074
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Stroe"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdRetrieve 
      Height          =   375
      Left            =   7200
      TabIndex        =   47
      ToolTipText     =   "Retrieve Prescription"
      Top             =   1560
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   661
      _Version        =   131074
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Retrieve"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdCancel 
      Height          =   375
      Left            =   7200
      TabIndex        =   46
      Top             =   1080
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   661
      _Version        =   131074
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Cancel"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdOK 
      Height          =   375
      Left            =   7200
      TabIndex        =   45
      Top             =   600
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   661
      _Version        =   131074
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "OK"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmOrderDetails_Cont"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim mTxNumber As String
Dim mLineNumber As Long
Dim mCustomerName As String
Dim mCustomerID As Long

Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdOK_Click()
    Call SaveContData
    Unload Me
End Sub

Private Sub cmdRefresh_Click()
    Call GetSOrderHeader
    Call OpenAsWhat
'    Call GetSOrder

    fraPrescription.Enabled = True
    fraNotes.Enabled = True

    cmdOK.Enabled = True
    cmdCancel.Enabled = True
    cmdRetrieve.Enabled = True
    cmdStore.Enabled = True
End Sub

Private Sub cmdRetrieve_Click()
    Call RetrievePrescription
End Sub


Private Sub cmdStore_Click()
    Call StorePrescription
End Sub

Private Sub Form_Load()
    Call ofx_RestoreFormPosition(Me, True)
End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_SaveFormPosition(Me)
End Sub






Private Sub GetSOrderHeader()
    mTxNumber = "SA" + ofx_CStr(frmSalesOrder.mskOrderNumber.Text)
'    mLineNumber = ofx_CSng(frmSalesOrder.tdbgTxBody.Columns(0))
    mLineNumber = 0     ' Use one record per SOrder
    mCustomerName = ofx_CStr(frmSalesOrder.txtCustomerName.Text)
    mCustomerID = ofx_CLng(frmSalesOrder.txtCustomerName.Tag)
End Sub



Private Sub SaveContData()
    With dtcTxSOrderCont
        If .EditMode = dbEditInProgress Or _
           .EditMode = dbEditAdd Then
            .UpdateRecord
        End If
    End With
End Sub

Private Sub RetrievePrescription()
    Dim strSQL As String
    Dim MyWS As Workspace
    Dim myDB As Database
    Dim myRS As Recordset
    
    Screen.MousePointer = vbHourglass
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")
    Set myRS = myDB.OpenRecordset("CustomerPresContact", dbOpenDynaset, dbReadOnly)

    strSQL = "CustomerID = " & mCustomerID
    myRS.FindFirst strSQL
    If Not myRS.NoMatch Then
        With myRS
            If Not IsNull(!IssuedOn) Then calIssuedOn = Format(!IssuedOn, "MM/DD/YYYY")
            If Not IsNull(!IssuedByDr) Then dbcDoctor.BoundText = !IssuedByDr
            If Not IsNull(!RightSphere) Then txtRightSphere = !RightSphere
            If Not IsNull(!RightCylinder) Then txtRightCylinder = !RightCylinder
            If Not IsNull(!RightAxis) Then txtRightAxis = !RightAxis
            If Not IsNull(!RightKReadingV) Then txtRightKReadingV = !RightKReadingV
            If Not IsNull(!RightKReadingH) Then txtRightKReadingH = !RightKReadingH
            If Not IsNull(!RightPalp) Then txtRightPalp = !RightPalp
            If Not IsNull(!RightCorn) Then txtRightCorn = !RightCorn
            If Not IsNull(!RightPupil) Then txtRightPupil = !RightPupil
            If Not IsNull(!LeftSphere) Then txtLeftSphere = !LeftSphere
            If Not IsNull(!LeftCylinder) Then txtLeftCylinder = !LeftCylinder
            If Not IsNull(!LeftAxis) Then txtLeftAxis = !LeftAxis
            If Not IsNull(!LeftKReadingV) Then txtLeftKReadingV = !LeftKReadingV
            If Not IsNull(!LeftKReadingH) Then txtLeftKReadingH = !LeftKReadingH
            If Not IsNull(!LeftPalp) Then txtLeftPalp = !LeftPalp
            If Not IsNull(!LeftCorn) Then txtLeftCorn = !LeftCorn
            If Not IsNull(!LeftPupil) Then txtLeftPupil = !LeftPupil
            If Not IsNull(!History) Then txtHistory = !History
            If Not IsNull(!Medical) Then txtMedical = !Medical
            If Not IsNull(!Allergy) Then txtAllergy = !Allergy
            If Not IsNull(!Reason) Then txtReason = !Reason
            If Not IsNull(!Evaluation) Then txtEvaluation = !Evaluation
            If Not IsNull(!Test) Then txtTest = !Test
        End With
    Else
        MsgBox "Customer " & mCustomerName & " doesn't has Prescription Record"
    End If
    myRS.Close
    myDB.Close
    Screen.MousePointer = vbDefault
End Sub

Private Sub StorePrescription()
    Dim strSQL As String
    Dim myDB As Database
    Dim myRS As Recordset
    
    Screen.MousePointer = vbHourglass
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")
    Set myRS = myDB.OpenRecordset("CustomerPresContact", dbOpenDynaset, dbDenyWrite)

    strSQL = "CustomerID = " & mCustomerID
    
    With myRS
        .FindFirst strSQL
        If .NoMatch Then
            .AddNew
            !CustomerID = mCustomerID
        Else
            .Edit
        End If
        If IsDate(calIssuedOn) Then !IssuedOn = calIssuedOn.Text
        If Not IsNull(dbcDoctor) Then !IssuedByDr = ofx_CLng(dbcDoctor.BoundText)
        If Not IsNull(txtRightSphere) Then !RightSphere = txtRightSphere
        If Not IsNull(txtRightCylinder) Then !RightCylinder = txtRightCylinder
        If Not IsNull(txtRightAxis) Then !RightAxis = txtRightAxis
        If Not IsNull(txtRightKReadingV) Then !RightKReadingV = txtRightKReadingV
        If Not IsNull(txtRightKReadingH) Then !RightKReadingH = txtRightKReadingH
        If Not IsNull(txtRightPalp) Then !RightPalp = txtRightPalp
        If Not IsNull(txtRightCorn) Then !RightCorn = txtRightCorn
        If Not IsNull(txtRightPupil) Then !RightPupil = txtRightPupil
        If Not IsNull(txtLeftSphere) Then !LeftSphere = txtLeftSphere
        If Not IsNull(txtLeftCylinder) Then !LeftCylinder = txtLeftCylinder
        If Not IsNull(txtLeftAxis) Then !LeftAxis = txtLeftAxis
        If Not IsNull(txtLeftKReadingV) Then !LeftKReadingV = txtLeftKReadingV
        If Not IsNull(txtLeftKReadingH) Then !LeftKReadingH = txtLeftKReadingH
        If Not IsNull(txtLeftPalp) Then !LeftPalp = txtLeftPalp
        If Not IsNull(txtLeftCorn) Then !LeftCorn = txtLeftCorn
        If Not IsNull(txtLeftPupil) Then !LeftPupil = txtLeftPupil
        .Update
    End With
    myRS.Close
    myDB.Close
    Screen.MousePointer = vbDefault
End Sub

Private Sub OpenAsWhat()
    Dim strSQL As String
    
    strSQL = "TxNumber ='" & mTxNumber & "' And " & _
             "LineNumber = " & mLineNumber
    With dtcTxSOrderCont.Recordset
        .FindFirst strSQL
        If .NoMatch Then
            .AddNew
            .TxNumber = mTxNumber
            .LineNumber = mLineNumber
            .Update
            .Bookmark = .LastModified
        End If
        dtcTxSOrderCont.UpdateControls
        .Edit
    End With
End Sub



Private Sub txtHistory_GotFocus()
    Call AutoSelect(txtHistory)

End Sub


Private Sub txtLeftAxis_Change()
    If Not myIsDecimal(txtLeftAxis, 0, True) Or _
       Not WithinRange(txtLeftAxis, 180, 0, True) Then
        txtLeftAxis.SetFocus
    End If
End Sub

Private Sub txtLeftAxis_GotFocus()
    Call AutoSelect(txtLeftAxis)
End Sub


Private Sub txtLeftAxis_LostFocus()
    If Not myIsDecimal(txtLeftAxis, 0, True) Or _
       Not WithinRange(txtLeftAxis, 180, 0, True) Then
        txtLeftAxis.SetFocus
    End If
End Sub

Private Sub txtLeftCorn_Change()
    If Not myIsDecimal(txtLeftCorn, 2, True) Or _
       Not WithinRange(txtLeftCorn, 99.99, 0, True) Then
        txtLeftCorn.SetFocus
    End If
End Sub

Private Sub txtLeftCorn_GotFocus()
    Call AutoSelect(txtLeftCorn)

End Sub


Private Sub txtLeftCorn_LostFocus()
    If Not myIsDecimal(txtLeftCorn, 2, True) Or _
       Not WithinRange(txtLeftCorn, 99.99, 0, True) Then
        txtLeftCorn.SetFocus
    End If
End Sub


Private Sub txtLeftCylinder_Change()
    If Not myIsDecimal(txtLeftCylinder, 2, True) Or _
       Not WithinRange(txtLeftCylinder, 0, -6, True) Then
        txtLeftCylinder.SetFocus
    End If
End Sub

Private Sub txtLeftCylinder_GotFocus()
    Call AutoSelect(txtLeftCylinder)

End Sub


Private Sub txtLeftKReadingH_Change()
    If Not myIsDecimal(txtLeftKReadingH, 2, True) Or _
       Not WithinRange(txtLeftKReadingH, 99.99, 0, True) Then
        txtLeftKReadingH.SetFocus
    End If
End Sub

Private Sub txtLeftKReadingH_GotFocus()
    Call AutoSelect(txtLeftKReadingH)

End Sub


Private Sub txtLeftKReadingH_LostFocus()
    If Not myIsDecimal(txtLeftKReadingH, 2, True) Or _
       Not WithinRange(txtLeftKReadingH, 99.99, 0, True) Then
        txtLeftKReadingH.SetFocus
    End If
End Sub


Private Sub txtLeftKReadingV_Change()
    If Not myIsDecimal(txtLeftKReadingV, 2, True) Or _
       Not WithinRange(txtLeftKReadingV, 99.99, 0, True) Then
        txtLeftKReadingV.SetFocus
    End If
End Sub

Private Sub txtLeftKReadingV_GotFocus()
    Call AutoSelect(txtLeftKReadingV)

End Sub


Private Sub txtLeftKReadingV_LostFocus()
    If Not myIsDecimal(txtLeftKReadingV, 2, True) Or _
       Not WithinRange(txtLeftKReadingV, 99.99, 0, True) Then
        txtLeftKReadingV.SetFocus
    End If
End Sub


Private Sub txtLeftPalp_Change()
    If Not myIsDecimal(txtLeftPalp, 2, True) Or _
       Not WithinRange(txtLeftPalp, 99.99, 0, True) Then
        txtLeftPalp.SetFocus
    End If
End Sub

Private Sub txtLeftPalp_GotFocus()
    Call AutoSelect(txtLeftPalp)

End Sub


Private Sub txtLeftPalp_LostFocus()
    If Not myIsDecimal(txtLeftPalp, 2, True) Or _
       Not WithinRange(txtLeftPalp, 99.99, 0, True) Then
        txtLeftPalp.SetFocus
    End If
End Sub


Private Sub txtLeftPupil_Change()
    If Not myIsDecimal(txtLeftPupil, 2, True) Or _
       Not WithinRange(txtLeftPupil, 99.99, 0, True) Then
        txtLeftPupil.SetFocus
    End If
End Sub

Private Sub txtLeftPupil_GotFocus()
    Call AutoSelect(txtRightPupil)

End Sub


Private Sub txtLeftPupil_LostFocus()
    If Not myIsDecimal(txtLeftPupil, 2, True) Or _
       Not WithinRange(txtLeftPupil, 99.99, 0, True) Then
        txtLeftPupil.SetFocus
    End If
End Sub


Private Sub txtLeftSphere_Change()
    If Not myIsDecimal(txtLeftSphere, 2, True) Or _
       Not WithinRange(txtLeftSphere, 20, -20, True) Then
        txtLeftSphere.SetFocus
    End If
End Sub

Private Sub txtLeftSphere_GotFocus()
    Call AutoSelect(txtLeftSphere)
End Sub


Private Sub txtLeftSphere_LostFocus()
    If Not myIsDecimal(txtLeftSphere, 2, True) Or _
       Not WithinRange(txtLeftSphere, 20, -20, True) Then
        txtLeftSphere.SetFocus
    End If
End Sub

Private Sub txtRightAxis_Change()
    If Not myIsDecimal(txtRightAxis, 0, True) Or _
       Not WithinRange(txtRightAxis, 180, 0, True) Then
        txtRightAxis.SetFocus
    End If
End Sub

Private Sub txtRightAxis_GotFocus()
    Call AutoSelect(txtRightAxis)

End Sub


Private Sub txtRightAxis_LostFocus()
    If Not myIsDecimal(txtRightAxis, 0, True) Or _
       Not WithinRange(txtRightAxis, 180, 0, True) Then
        txtRightAxis.SetFocus
    End If
End Sub

Private Sub txtRightCorn_Change()
    If Not myIsDecimal(txtRightCorn, 2, True) Or _
       Not WithinRange(txtRightCorn, 99.99, 0, True) Then
        txtRightCorn.SetFocus
    End If
End Sub

Private Sub txtRightCorn_GotFocus()
    Call AutoSelect(txtRightCorn)

End Sub


Private Sub txtRightCorn_LostFocus()
    If Not myIsDecimal(txtRightCorn, 2, True) Or _
       Not WithinRange(txtRightCorn, 99.99, 0, True) Then
        txtRightCorn.SetFocus
    End If
End Sub


Private Sub txtRightCylinder_Change()
    If Not myIsDecimal(txtRightCylinder, 2, True) Or _
       Not WithinRange(txtRightCylinder, 0, -6, True) Then
        txtRightCylinder.SetFocus
    End If
End Sub

Private Sub txtRightCylinder_GotFocus()
    Call AutoSelect(txtRightCylinder)

End Sub


Private Sub txtRightCylinder_LostFocus()
    If Not myIsDecimal(txtRightCylinder, 2, True) Or _
       Not WithinRange(txtRightCylinder, 0, -6, True) Then
        txtRightCylinder.SetFocus
    End If
End Sub


Private Sub txtRightKReadingH_Change()
    If Not myIsDecimal(txtRightKReadingH, 2, True) Or _
       Not WithinRange(txtRightKReadingH, 99.99, 0, True) Then
        txtRightKReadingH.SetFocus
    End If
End Sub

Private Sub txtRightKReadingH_GotFocus()
    Call AutoSelect(txtRightKReadingH)

End Sub


Private Sub txtRightKReadingH_LostFocus()
    If Not myIsDecimal(txtRightKReadingH, 2, True) Or _
       Not WithinRange(txtRightKReadingH, 99.99, 0, True) Then
        txtRightKReadingH.SetFocus
    End If
End Sub


Private Sub txtRightKReadingV_Change()
    If Not myIsDecimal(txtRightKReadingV, 2, True) Or _
       Not WithinRange(txtRightKReadingV, 99.99, 0, True) Then
        txtRightKReadingV.SetFocus
    End If
End Sub

Private Sub txtRightKReadingV_GotFocus()
    Call AutoSelect(txtRightKReadingV)

End Sub


Private Sub txtRightKReadingV_LostFocus()
    If Not myIsDecimal(txtRightKReadingV, 2, True) Or _
       Not WithinRange(txtRightKReadingV, 99.99, 0, True) Then
        txtRightKReadingV.SetFocus
    End If
End Sub


Private Sub txtRightPalp_Change()
    If Not myIsDecimal(txtRightPalp, 2, True) Or _
       Not WithinRange(txtRightPalp, 99.99, 0, True) Then
        txtRightPalp.SetFocus
    End If
End Sub

Private Sub txtRightPalp_GotFocus()
    Call AutoSelect(txtRightPalp)
End Sub


Private Sub txtRightPalp_LostFocus()
    If Not myIsDecimal(txtRightPalp, 2, True) Or _
       Not WithinRange(txtRightPalp, 99.99, 0, True) Then
        txtRightPalp.SetFocus
    End If
End Sub


Private Sub txtRightPupil_Change()
    If Not myIsDecimal(txtRightPupil, 2, True) Or _
       Not WithinRange(txtRightPupil, 99.99, 0, True) Then
        txtRightPupil.SetFocus
    End If
End Sub

Private Sub txtRightPupil_GotFocus()
    Call AutoSelect(txtRightPupil)

End Sub


Private Sub txtRightPupil_LostFocus()
    If Not myIsDecimal(txtRightPupil, 2, True) Or _
       Not WithinRange(txtRightPupil, 99.99, 0, True) Then
        txtRightPupil.SetFocus
    End If
End Sub


Private Sub txtRightSphere_Change()
    If Not myIsDecimal(txtRightSphere, 2, True) Or _
       Not WithinRange(txtRightSphere, 20, -20, True) Then
        txtRightSphere.SetFocus
    End If
End Sub


Private Sub txtRightSphere_GotFocus()
    Call AutoSelect(txtRightSphere)
End Sub


Private Sub txtRightSphere_LostFocus()
    If Not myIsDecimal(txtRightSphere, 2, True) Or _
       Not WithinRange(txtRightSphere, 20, -20, True) Then
        txtRightSphere.SetFocus
    End If
End Sub



VERSION 5.00
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmLookupPLU 
   Caption         =   "Lookup PLU"
   ClientHeight    =   4260
   ClientLeft      =   1935
   ClientTop       =   3315
   ClientWidth     =   9615
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4260
   ScaleWidth      =   9615
   Begin TrueDBGrid50.TDBGrid dbgPLU 
      Bindings        =   "frmLookupPLU.frx":0000
      Height          =   2175
      Left            =   120
      OleObjectBlob   =   "frmLookupPLU.frx":0015
      TabIndex        =   22
      Top             =   1980
      Width           =   9375
   End
   Begin VB.Data dtcPLU 
      Caption         =   "qryPLU"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   315
      Left            =   5280
      Options         =   4
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   3000
      Visible         =   0   'False
      Width           =   1935
   End
   Begin Threed.SSFrame fraLookupSelection 
      Height          =   1815
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   9375
      _ExtentX        =   16536
      _ExtentY        =   3201
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
      Begin Threed.SSFrame fraSelectGroup 
         Height          =   1455
         Left            =   120
         TabIndex        =   1
         Top             =   240
         Width           =   1575
         _ExtentX        =   2778
         _ExtentY        =   2566
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
         Caption         =   "Select Group"
         Begin VB.OptionButton optAllCategory 
            Caption         =   "All Category"
            Height          =   255
            Left            =   120
            TabIndex        =   6
            Top             =   1140
            Width           =   1215
         End
         Begin VB.OptionButton optContactLens 
            Caption         =   "Contact Lens"
            Height          =   255
            Left            =   120
            TabIndex        =   5
            Top             =   840
            Width           =   1335
         End
         Begin VB.OptionButton optLens 
            Caption         =   "Lens"
            Height          =   255
            Left            =   120
            TabIndex        =   4
            Top             =   540
            Width           =   1095
         End
         Begin VB.OptionButton optFrame 
            Caption         =   "Frame"
            Height          =   255
            Left            =   120
            TabIndex        =   3
            Top             =   240
            Width           =   1095
         End
      End
      Begin Threed.SSFrame fraSelectValue 
         Height          =   1455
         Left            =   1800
         TabIndex        =   2
         Top             =   240
         Width           =   7455
         _ExtentX        =   13150
         _ExtentY        =   2566
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
         Caption         =   "Select Value"
         Begin VB.Data dtcBrand 
            Caption         =   "Brand"
            Connect         =   "Access 2000;"
            DatabaseName    =   "SynergyV.mdb"
            DefaultCursorType=   0  'DefaultCursor
            DefaultType     =   2  'UseODBC
            Exclusive       =   0   'False
            Height          =   300
            Left            =   4800
            Options         =   4
            ReadOnly        =   0   'False
            RecordsetType   =   1  'Dynaset
            RecordSource    =   "SELECT BrandCode, BrandDescription FROM Brand ORDER BY BrandDescription"
            Top             =   180
            Visible         =   0   'False
            Width           =   1140
         End
         Begin VB.Data dtcSupplier 
            Caption         =   "Supplier"
            Connect         =   "Access 2000;"
            DatabaseName    =   "SynergyV.mdb"
            DefaultCursorType=   0  'DefaultCursor
            DefaultType     =   2  'UseODBC
            Exclusive       =   0   'False
            Height          =   315
            Left            =   1680
            Options         =   4
            ReadOnly        =   0   'False
            RecordsetType   =   1  'Dynaset
            RecordSource    =   "SELECT SupplierCode, SupplierName FROM Supplier ORDER BY SupplierName"
            Top             =   180
            Visible         =   0   'False
            Width           =   1140
         End
         Begin VB.TextBox txtSel4th 
            Height          =   315
            Left            =   4440
            TabIndex        =   18
            Top             =   960
            Width           =   1575
         End
         Begin VB.TextBox txtSel3rd 
            Height          =   315
            Left            =   1200
            TabIndex        =   16
            Top             =   960
            Width           =   1575
         End
         Begin VB.TextBox txtSel2nd 
            Height          =   315
            Left            =   4440
            TabIndex        =   14
            Top             =   600
            Width           =   1575
         End
         Begin VB.TextBox txtSel1st 
            Height          =   315
            Left            =   1200
            TabIndex        =   12
            Top             =   600
            Width           =   1575
         End
         Begin MSDBCtls.DBCombo dbcBrand 
            Bindings        =   "frmLookupPLU.frx":4D44
            Height          =   315
            Left            =   4440
            TabIndex        =   10
            Top             =   240
            Width           =   1935
            _ExtentX        =   3413
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "BrandDescription"
            BoundColumn     =   "BrandCode"
            Text            =   ""
         End
         Begin MSDBCtls.DBCombo dbcSupplier 
            Bindings        =   "frmLookupPLU.frx":4D5B
            Height          =   315
            Left            =   1200
            TabIndex        =   8
            Top             =   240
            Width           =   2055
            _ExtentX        =   3625
            _ExtentY        =   556
            _Version        =   393216
            BackColor       =   16777215
            ForeColor       =   0
            ListField       =   "SupplierName"
            BoundColumn     =   "SupplierCode"
            Text            =   ""
         End
         Begin Threed.SSCommand cmdAdd 
            Height          =   315
            Left            =   6600
            TabIndex        =   21
            Top             =   960
            Width           =   735
            _ExtentX        =   1296
            _ExtentY        =   556
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
            Caption         =   "Add"
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin Threed.SSCommand cmdCopy 
            Height          =   315
            Left            =   6600
            TabIndex        =   20
            Top             =   600
            Width           =   735
            _ExtentX        =   1296
            _ExtentY        =   556
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
            Caption         =   "Copy"
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin Threed.SSCommand cmdGo 
            Height          =   315
            Left            =   6600
            TabIndex        =   19
            Top             =   240
            Width           =   735
            _ExtentX        =   1296
            _ExtentY        =   556
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
            Caption         =   "Find"
            ButtonStyle     =   2
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin VB.Label lblBrand 
            Caption         =   "Brand"
            Height          =   255
            Left            =   3480
            TabIndex        =   9
            Top             =   240
            Width           =   975
         End
         Begin VB.Label lblSupplier 
            Caption         =   "Supplier"
            Height          =   255
            Left            =   120
            TabIndex        =   7
            Top             =   240
            Width           =   735
         End
         Begin VB.Label lblSel4th 
            Caption         =   "4th Choice"
            Height          =   255
            Left            =   3480
            TabIndex        =   17
            Top             =   960
            Width           =   975
         End
         Begin VB.Label lblSel3rd 
            Caption         =   "3rd Choice"
            Height          =   255
            Left            =   120
            TabIndex        =   15
            Top             =   960
            Width           =   975
         End
         Begin VB.Label lblSel2nd 
            Caption         =   "2nd Choice"
            Height          =   195
            Left            =   3480
            TabIndex        =   13
            Top             =   600
            Width           =   975
         End
         Begin VB.Label lblSel1st 
            Caption         =   "1st Choice"
            Height          =   255
            Left            =   120
            TabIndex        =   11
            Top             =   600
            Width           =   1095
         End
      End
   End
End
Attribute VB_Name = "frmLookupPLU"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Const ColIndexSKU       As Integer = 0
Private Const ColIndexCategory  As Integer = 0
Private Const ColIndexSupplier  As Integer = 0
Private Const ColIndexBrand     As Integer = 0
Private Const ColIndexMaterial  As Integer = 0
Private Const ColIndexModel     As Integer = 0
Private Const ColIndexColor     As Integer = 0
Private Const ColIndexSize      As Integer = 0
Private Const ColIndexCylinder  As Integer = 0
Private Const ColIndexSphere    As Integer = 0
Private Const ColIndexBaseCurve As Integer = 0
Private Const ColIndexPrice     As Integer = 0
Private Const ColIndexLSP       As Integer = 0

Private Sub cmdAdd_Click()
    Unload Me
    If ofx_IsFormLoaded(frmInvt) Then _
        Unload frmInvt
    Screen.MousePointer = vbHourglass
    frmInvt.Show vbModal
End Sub

Private Sub cmdCopy_Click()
    Clipboard.Clear
    Clipboard.SetText dtcPLU.Recordset.Fields("SKU")
    MsgBox "SKU " & dtcPLU.Recordset.Fields("SKU") & " Copied."
    Unload Me
End Sub


Private Sub cmdGo_Click()
    Screen.MousePointer = vbHourglass
    If optFrame.Value Then Call Go_Frame
    If optLens.Value Then Call Go_Lens
    If optContactLens.Value Then Call Go_Lens
    If optAllCategory.Value Then Call Go_All
    Screen.MousePointer = vbDefault
End Sub


Private Sub Form_Activate()
    Screen.MousePointer = vbDefault
    optFrame.SetFocus
End Sub

Private Sub Form_Load()
    Call ofx_RestoreFormPosition(Me, True)
    cmdCopy.Enabled = False
End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_SaveFormPosition(Me)
End Sub



Private Sub Setup4_Frame()
    ' Setup Select Value
    lblBrand.Visible = True
    dbcBrand.Visible = True
    lblSel1st.Caption = "Model"
    lblSel2nd.Caption = "Eye Size"
    lblSel2nd.Visible = True
    txtSel2nd.Visible = True
    lblSel3rd.Caption = ""
    lblSel3rd.Visible = False
    txtSel3rd.Visible = False
    lblSel4th.Caption = ""
    lblSel4th.Visible = False
    txtSel4th.Visible = False
    ' Setup Grid
    dbgPLU.Columns(5).Caption = "Model"
    dbgPLU.Columns(7).Caption = "Eye Size"
    dbgPLU.Columns(7).Visible = True
    dbgPLU.Columns(8).Visible = False           ' Cylinder
    dbgPLU.Columns(9).Visible = False           ' Sphere
    dbgPLU.Columns(10).Visible = False           ' Base Curve
End Sub

Private Sub Setup4_Lens()
    ' Setup Select Value
    lblBrand.Visible = True
    dbcBrand.Visible = True
    lblSel1st.Caption = "Len Style"
    lblSel2nd.Caption = "Cylinder"
    lblSel2nd.Visible = True
    txtSel2nd.Visible = True
    lblSel3rd.Caption = "Sphere"
    lblSel3rd.Visible = True
    txtSel3rd.Visible = True
    lblSel4th.Caption = "Base Curve"
    lblSel4th.Visible = True
    txtSel4th.Visible = True
    ' Setup Grid
    dbgPLU.Columns(5).Caption = "Len Style"
    dbgPLU.Columns(7).Visible = False
    dbgPLU.Columns(8).Visible = True            ' Cylinder
    dbgPLU.Columns(9).Visible = True            ' Sphere
    dbgPLU.Columns(10).Visible = True            ' Base Curve
End Sub

Private Sub Setup4_Cont()
    ' Setup Select Value
    lblBrand.Visible = True
    dbcBrand.Visible = True
    lblSel1st.Caption = "Len Style"
    lblSel2nd.Caption = "Cylinder"
    lblSel2nd.Visible = True
    txtSel2nd.Visible = True
    lblSel3rd.Caption = "Sphere"
    lblSel3rd.Visible = True
    txtSel3rd.Visible = True
    lblSel4th.Caption = "Base Curve"
    lblSel4th.Visible = True
    txtSel4th.Visible = True
    ' Setup Grid
    dbgPLU.Columns(5).Caption = "Len Style"
    dbgPLU.Columns(7).Caption = "Eye Size"
    dbgPLU.Columns(7).Visible = False
    dbgPLU.Columns(8).Visible = True            ' Cylinder
    dbgPLU.Columns(9).Visible = True            ' Sphere
    dbgPLU.Columns(10).Visible = True            ' Base Curve
End Sub


Private Sub Setup4_All()
    ' Setup Select Value
    lblBrand.Visible = True
    dbcBrand.Visible = True
    lblSel1st.Caption = "Model"
    lblSel2nd.Caption = "Color"
    lblSel2nd.Visible = False
    txtSel2nd.Visible = False
    lblSel3rd.Caption = ""
    lblSel3rd.Visible = False
    txtSel3rd.Visible = False
    lblSel4th.Caption = ""
    lblSel4th.Visible = False
    txtSel4th.Visible = False
    ' Setup Grid
    dbgPLU.Columns(5).Caption = "Model"
    dbgPLU.Columns(7).Caption = "Size"
    dbgPLU.Columns(7).Visible = True
    dbgPLU.Columns(8).Visible = True            ' Cylinder
    dbgPLU.Columns(9).Visible = True            ' Sphere
    dbgPLU.Columns(10).Visible = True            ' Base Curve
End Sub


Private Sub optAllCategory_Click()
    Call Setup4_All

End Sub

Private Sub optContactLens_Click()
    Call Setup4_Cont

End Sub

Private Sub optFrame_Click()
    Call Setup4_Frame
End Sub


Private Sub optLens_Click()
    Call Setup4_Lens
End Sub



Private Sub Go_Frame()
    Dim strSQL As String
    Dim blnMultiSel As Boolean
    
    Screen.MousePointer = vbHourglass
    blnMultiSel = False
    strSQL = "SELECT * FROM qryPLU WHERE"
    If dbcSupplier.BoundText <> "" Then
        strSQL = strSQL & " SupplierCode = '" & dbcSupplier.BoundText & "'"
        blnMultiSel = True
    End If
    If dbcBrand.BoundText <> "" Then
        If blnMultiSel Then strSQL = strSQL & " And"
        strSQL = strSQL & " BrandCode = '" & dbcBrand.BoundText & "'"
        blnMultiSel = True
    End If
    If txtSel1st.Text <> "" Then
        If blnMultiSel Then strSQL = strSQL & " And"
        strSQL = strSQL & " Model LIKE '" & txtSel1st.Text & "'"
        blnMultiSel = True
    End If
    If txtSel2nd.Text <> "" Then
        If blnMultiSel Then strSQL = strSQL & " And"
        strSQL = strSQL & " Size LIKE " & txtSel2nd.Text
        blnMultiSel = True
    End If

    If blnMultiSel Then
        strSQL = strSQL & " ORDER BY Model"
        dtcPLU.RecordSource = strSQL
        dtcPLU.Refresh
        If IsTableEmpty(dtcPLU.Recordset) Then
            cmdCopy.Enabled = False
        Else
            dtcPLU.UpdateControls
            cmdCopy.Enabled = True
        End If
    End If

    Screen.MousePointer = vbDefault
End Sub

Private Sub Go_Lens()
    Dim strSQL As String
    Dim blnMultiSel As Boolean
    
    Screen.MousePointer = vbHourglass
    blnMultiSel = False
    strSQL = "SELECT * FROM qryPLU WHERE"
    If dbcSupplier.BoundText <> "" Then
        strSQL = strSQL & " SupplierCode = '" & dbcSupplier.BoundText & "'"
        blnMultiSel = True
    End If
    If dbcBrand.BoundText <> "" Then
        If blnMultiSel Then strSQL = strSQL & " And"
        strSQL = strSQL & " BrandCode = '" & dbcBrand.BoundText & "'"
        blnMultiSel = True
    End If
    If txtSel1st.Text <> "" Then
        If blnMultiSel Then strSQL = strSQL & " And"
        strSQL = strSQL & " Model LIKE '" & txtSel1st.Text & "'"
        blnMultiSel = True
    End If
    If txtSel2nd.Text <> "" Then
        If blnMultiSel Then strSQL = strSQL & " And"
        strSQL = strSQL & " Cylinder LIKE " & txtSel2nd.Text
        blnMultiSel = True
    End If
    If txtSel3rd.Text <> "" Then
        If blnMultiSel Then strSQL = strSQL & " And"
        strSQL = strSQL & " Sphere LIKE " & txtSel3rd.Text
        blnMultiSel = True
    End If
    If txtSel4th.Text <> "" Then
        If blnMultiSel Then strSQL = strSQL & " And"
        strSQL = strSQL & " BaseCurve LIKE " & txtSel4th.Text
        blnMultiSel = True
    End If

    If blnMultiSel Then
        strSQL = strSQL & " ORDER BY Model"
        dtcPLU.RecordSource = strSQL
        dtcPLU.Refresh
        If IsTableEmpty(dtcPLU.Recordset) Then
            cmdCopy.Enabled = False
        Else
            dtcPLU.UpdateControls
            cmdCopy.Enabled = True
        End If
    End If

    Screen.MousePointer = vbDefault
End Sub

Private Sub Go_Cont()

End Sub

Private Sub Go_All()
    Dim strSQL As String
    Dim blnMultiSel As Boolean
    
    Screen.MousePointer = vbHourglass
    blnMultiSel = False
    strSQL = "SELECT * FROM qryPLU WHERE"
    If dbcSupplier.BoundText <> "" Then
        strSQL = strSQL & " SupplierCode = '" & dbcSupplier.BoundText & "'"
        blnMultiSel = True
    End If
    If dbcBrand.BoundText <> "" Then
        If blnMultiSel Then strSQL = strSQL & " And"
        strSQL = strSQL & " BrandCode = '" & dbcBrand.BoundText & "'"
        blnMultiSel = True
    End If
    If txtSel1st.Text <> "" Then
        If blnMultiSel Then strSQL = strSQL & " And"
        strSQL = strSQL & " Model LIKE '" & txtSel1st.Text & "'"
        blnMultiSel = True
    End If

    If blnMultiSel Then
        strSQL = strSQL & " ORDER BY Model"
        dtcPLU.RecordSource = strSQL
        dtcPLU.Refresh
        If IsTableEmpty(dtcPLU.Recordset) Then
            cmdCopy.Enabled = False
        Else
            dtcPLU.UpdateControls
            cmdCopy.Enabled = True
        End If
    End If

    Screen.MousePointer = vbDefault
End Sub

Private Sub txtSel1st_GotFocus()
    Call AutoSelect(txtSel1st)
End Sub


Private Sub txtSel1st_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdGo_Click
        KeyAscii = 0
    End If
End Sub


Private Sub txtSel2nd_GotFocus()
    Call AutoSelect(txtSel2nd)
End Sub


Private Sub txtSel2nd_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdGo_Click
        KeyAscii = 0
    End If
End Sub


Private Sub txtSel3rd_GotFocus()
    Call AutoSelect(txtSel3rd)
End Sub


Private Sub txtSel3rd_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdGo_Click
        KeyAscii = 0
    End If
End Sub


Private Sub txtSel4th_GotFocus()
    Call AutoSelect(txtSel4th)
End Sub


Private Sub txtSel4th_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdGo_Click
        KeyAscii = 0
    End If
End Sub



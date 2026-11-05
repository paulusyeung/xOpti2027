VERSION 4.00
Begin VB.Form frmRBIC_EnterCost 
   Caption         =   "Re-Build Inventory Cost - Enter Cost"
   ClientHeight    =   6930
   ClientLeft      =   1875
   ClientTop       =   1485
   ClientWidth     =   9735
   Height          =   7335
   Left            =   1815
   LinkTopic       =   "Form1"
   ScaleHeight     =   6930
   ScaleWidth      =   9735
   Top             =   1140
   Width           =   9855
   Begin VB.Data dtcReBuildCost 
      Caption         =   "ReBuildCost"
      Connect         =   "Access"
      DatabaseName    =   "SynergyV.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   3600
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   3840
      Visible         =   0   'False
      Width           =   2295
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   2775
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   9495
      _Version        =   65536
      _ExtentX        =   16748
      _ExtentY        =   4895
      _StockProps     =   14
      Caption         =   "Select WorkBook"
      Begin Threed.SSFrame SSFrame2 
         Height          =   2355
         Left            =   120
         TabIndex        =   1
         Top             =   300
         Width           =   1695
         _Version        =   65536
         _ExtentX        =   2990
         _ExtentY        =   4154
         _StockProps     =   14
         Caption         =   "Select Group"
         Begin VB.OptionButton optSKU 
            Caption         =   "By SKU"
            Height          =   315
            Left            =   120
            TabIndex        =   23
            Top             =   1500
            Width           =   1215
         End
         Begin VB.OptionButton optAllCategory 
            Caption         =   "All Category"
            Height          =   255
            Left            =   120
            TabIndex        =   6
            Top             =   1200
            Width           =   1335
         End
         Begin VB.OptionButton optContactLens 
            Caption         =   "Contact Lens"
            Height          =   255
            Left            =   120
            TabIndex        =   5
            Top             =   900
            Width           =   1335
         End
         Begin VB.OptionButton optLens 
            Caption         =   "Lens"
            Height          =   255
            Left            =   120
            TabIndex        =   4
            Top             =   600
            Width           =   1095
         End
         Begin VB.OptionButton optFrame 
            Caption         =   "Frame"
            Height          =   255
            Left            =   120
            TabIndex        =   3
            Top             =   300
            Width           =   1095
         End
      End
      Begin Threed.SSFrame fraSelectValue 
         Height          =   1575
         Left            =   1920
         TabIndex        =   2
         Top             =   300
         Width           =   7455
         _Version        =   65536
         _ExtentX        =   13150
         _ExtentY        =   2778
         _StockProps     =   14
         Caption         =   "Select Value"
         Enabled         =   0   'False
         Begin VB.Data dtcBrand 
            Caption         =   "Brand"
            Connect         =   "Access"
            DatabaseName    =   "SynergyV.mdb"
            Exclusive       =   0   'False
            Height          =   315
            Left            =   5040
            Options         =   4
            ReadOnly        =   0   'False
            RecordsetType   =   1  'Dynaset
            RecordSource    =   "SELECT BrandCode, BrandDescription FROM Brand ORDER BY BrandDescription"
            Top             =   120
            Visible         =   0   'False
            Width           =   1140
         End
         Begin VB.Data dtcSupplier 
            Caption         =   "Supplier"
            Connect         =   "Access"
            DatabaseName    =   "SynergyV.mdb"
            Exclusive       =   0   'False
            Height          =   315
            Left            =   1800
            Options         =   4
            ReadOnly        =   0   'False
            RecordsetType   =   1  'Dynaset
            RecordSource    =   "SELECT SupplierCode, SupplierName FROM Supplier ORDER BY SupplierName"
            Top             =   120
            Visible         =   0   'False
            Width           =   1140
         End
         Begin VB.TextBox txtSel4th 
            Height          =   315
            Left            =   4320
            TabIndex        =   18
            Top             =   1080
            Width           =   1455
         End
         Begin VB.TextBox txtSel3rd 
            Height          =   315
            Left            =   960
            TabIndex        =   16
            Top             =   1080
            Width           =   1575
         End
         Begin VB.TextBox txtSel2nd 
            Height          =   285
            Left            =   4320
            TabIndex        =   14
            Top             =   660
            Width           =   1455
         End
         Begin VB.TextBox txtSel1st 
            Height          =   315
            Left            =   960
            TabIndex        =   12
            Top             =   660
            Width           =   1575
         End
         Begin Threed.SSCommand cmdFind 
            Height          =   315
            Left            =   6600
            TabIndex        =   19
            Top             =   240
            Width           =   735
            _Version        =   65536
            _ExtentX        =   1296
            _ExtentY        =   556
            _StockProps     =   78
            Caption         =   "&Find"
            BevelWidth      =   1
            Outline         =   0   'False
         End
         Begin VB.Label lblSel4th 
            Caption         =   "4th Choice"
            Height          =   255
            Left            =   3360
            TabIndex        =   17
            Top             =   1080
            Width           =   855
         End
         Begin VB.Label lblSel3rd 
            Caption         =   "3rd Choice"
            Height          =   255
            Left            =   120
            TabIndex        =   15
            Top             =   1080
            Width           =   855
         End
         Begin VB.Label lblSel2nd 
            Caption         =   "2nd Choice"
            Height          =   255
            Left            =   3360
            TabIndex        =   13
            Top             =   660
            Width           =   855
         End
         Begin VB.Label lblSel1st 
            Caption         =   "1st Choice"
            Height          =   255
            Left            =   120
            TabIndex        =   11
            Top             =   660
            Width           =   855
         End
         Begin MSDBCtls.DBCombo dbcBrand 
            Bindings        =   "frmRBIC_EnterCost.frx":0000
            Height          =   315
            Left            =   4320
            TabIndex        =   10
            Top             =   240
            Width           =   1935
            _Version        =   65536
            _ExtentX        =   3413
            _ExtentY        =   556
            _StockProps     =   77
            ForeColor       =   0
            BackColor       =   16777215
            ListField       =   "BrandDescription"
            BoundColumn     =   "BrandCode"
         End
         Begin VB.Label lblBrand 
            Caption         =   "Brand"
            Height          =   255
            Left            =   3360
            TabIndex        =   9
            Top             =   240
            Width           =   615
         End
         Begin MSDBCtls.DBCombo dbcSupplier 
            Bindings        =   "frmRBIC_EnterCost.frx":0011
            Height          =   315
            Left            =   960
            TabIndex        =   8
            Top             =   240
            Width           =   2055
            _Version        =   65536
            _ExtentX        =   3625
            _ExtentY        =   556
            _StockProps     =   77
            ForeColor       =   0
            BackColor       =   16777215
            ListField       =   "SupplierName"
            BoundColumn     =   "SupplierCode"
         End
         Begin VB.Label Label1 
            Caption         =   "Supplier"
            Height          =   255
            Left            =   120
            TabIndex        =   7
            Top             =   240
            Width           =   735
         End
      End
      Begin Threed.SSFrame fraSelectSKU 
         Height          =   735
         Left            =   1920
         TabIndex        =   22
         Top             =   1920
         Width           =   7455
         _Version        =   65536
         _ExtentX        =   13150
         _ExtentY        =   1296
         _StockProps     =   14
         Caption         =   "Select by SKU"
         Enabled         =   0   'False
         Begin Threed.SSCommand cmdFindSKU 
            Height          =   315
            Left            =   2520
            TabIndex        =   26
            Top             =   240
            Width           =   375
            _Version        =   65536
            _ExtentX        =   661
            _ExtentY        =   556
            _StockProps     =   78
            BevelWidth      =   1
            Outline         =   0   'False
            Picture         =   "frmRBIC_EnterCost.frx":0025
         End
         Begin MSMask.MaskEdBox mskSKU 
            Height          =   315
            Left            =   960
            TabIndex        =   25
            Top             =   240
            Width           =   1575
            _Version        =   65536
            _ExtentX        =   2778
            _ExtentY        =   556
            _StockProps     =   109
            ForeColor       =   -2147483640
            BackColor       =   -2147483643
            BorderStyle     =   1
            PromptInclude   =   0   'False
            MaxLength       =   13
         End
         Begin VB.Label Label2 
            Caption         =   "SKU"
            Height          =   195
            Left            =   120
            TabIndex        =   24
            Top             =   240
            Width           =   735
         End
      End
   End
   Begin Threed.SSRibbon cmdSortBySKU 
      Height          =   315
      Left            =   1200
      TabIndex        =   21
      Top             =   3060
      Width           =   375
      _Version        =   65536
      _ExtentX        =   661
      _ExtentY        =   556
      _StockProps     =   65
      BackColor       =   12632256
      BevelWidth      =   1
      Outline         =   0   'False
      PictureUp       =   "frmRBIC_EnterCost.frx":05CB
      PictureDn       =   "frmRBIC_EnterCost.frx":0B71
   End
   Begin TrueDBGrid.TDBGrid dbgWorkBook 
      Bindings        =   "frmRBIC_EnterCost.frx":112B
      Height          =   3855
      Left            =   120
      OleObjectBlob   =   "frmRBIC_EnterCost.frx":1142
      TabIndex        =   20
      Top             =   3000
      Width           =   9495
   End
End
Attribute VB_Name = "frmRBIC_EnterCost"
Attribute VB_Creatable = False
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

Public mstrSQL As String
Private Sub cmdFind_Click()
    Screen.MousePointer = vbHourglass
    If optFrame.Value Then Call Go_Frame
    If optLens.Value Then Call Go_Lens
    If optContactLens.Value Then Call Go_Lens
    If optAllCategory.Value Then Call Go_All
    Screen.MousePointer = vbDefault
End Sub

Private Sub cmdFindSKU_Click()
    Call Go_SKU
End Sub

Private Sub cmdSortBySKU_Click(Value As Integer)
    Dim mySQL As String
        
    Screen.MousePointer = vbHourglass
    If cmdSortBySKU.Value Then
        mySQL = mstrSQL & " ORDER BY ReBuildCost.SKU ASC"
    Else
        mySQL = mstrSQL & " ORDER BY ReBuildCost.SKU DESC"
    End If
    dtcReBuildCost.RecordSource = mySQL
    dtcReBuildCost.Refresh
    dtcReBuildCost.UpdateControls
    Screen.MousePointer = vbDefault
End Sub

Private Sub dbgWorkBook_LostFocus()
    If dbgWorkBook.DataChanged Then
        dbgWorkBook.Update
    End If
End Sub


Private Sub Form_Activate()
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)

    cmdSortBySKU.ZOrder
End Sub


Private Sub Form_Unload(Cancel As Integer)
    If dbgWorkBook.DataChanged Then
        dbgWorkBook.Update
    End If
End Sub

Private Sub mskSKU_GotFocus()
    Call AutoSelect(mskSKU)
End Sub

Private Sub mskSKU_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFindSKU_Click
        KeyAscii = 0
    End If
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


Private Sub optSKU_Click()
    Call Setup4_SKU

End Sub

Private Sub txtSel1st_GotFocus()
    Call AutoSelect(txtSel1st)

End Sub


Private Sub txtSel1st_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFind_Click
        KeyAscii = 0
    End If

End Sub


Private Sub txtSel2nd_GotFocus()
    Call AutoSelect(txtSel2nd)

End Sub


Private Sub txtSel2nd_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFind_Click
        KeyAscii = 0
    End If

End Sub


Private Sub txtSel3rd_GotFocus()
    Call AutoSelect(txtSel3rd)

End Sub


Private Sub txtSel3rd_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFind_Click
        KeyAscii = 0
    End If

End Sub


Private Sub txtSel4th_GotFocus()
    Call AutoSelect(txtSel4th)

End Sub


Private Sub txtSel4th_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call cmdFind_Click
        KeyAscii = 0
    End If

End Sub



Private Sub Go_All()
    Dim blnMultiSel As Boolean
    
    Screen.MousePointer = vbHourglass
    blnMultiSel = False
    mstrSQL = "SELECT * FROM qryReBuildCost WHERE"
    If dbcSupplier.BoundText <> "" Then
        mstrSQL = mstrSQL & " SupplierCode = '" & dbcSupplier.BoundText & "'"
        blnMultiSel = True
    End If
    If dbcBrand.BoundText <> "" Then
        If blnMultiSel Then mstrSQL = mstrSQL & " And"
        mstrSQL = mstrSQL & " BrandCode = '" & dbcBrand.BoundText & "'"
        blnMultiSel = True
    End If
    If txtSel1st.Text <> "" Then
        If blnMultiSel Then mstrSQL = mstrSQL & " And"
        mstrSQL = mstrSQL & " Model LIKE '" & txtSel1st.Text & "'"
        blnMultiSel = True
    End If

    If blnMultiSel Then
'        mstrSQL = mstrSQL & " ORDER BY Model"
        dtcReBuildCost.RecordSource = mstrSQL
        dtcReBuildCost.Refresh
        dtcReBuildCost.UpdateControls
    End If

    Screen.MousePointer = vbDefault
End Sub

Private Sub Go_Frame()
    Dim blnMultiSel As Boolean
    
    Screen.MousePointer = vbHourglass
    blnMultiSel = False
    mstrSQL = "SELECT * FROM qryReBuildCost WHERE"
    If dbcSupplier.BoundText <> "" Then
        mstrSQL = mstrSQL & " SupplierCode = '" & dbcSupplier.BoundText & "'"
        blnMultiSel = True
    End If
    If dbcBrand.BoundText <> "" Then
        If blnMultiSel Then mstrSQL = mstrSQL & " And"
        mstrSQL = mstrSQL & " BrandCode = '" & dbcBrand.BoundText & "'"
        blnMultiSel = True
    End If
    If txtSel1st.Text <> "" Then
        If blnMultiSel Then mstrSQL = mstrSQL & " And"
        mstrSQL = mstrSQL & " Model LIKE '" & txtSel1st.Text & "'"
        blnMultiSel = True
    End If
    If txtSel2nd.Text <> "" Then
        If blnMultiSel Then mstrSQL = mstrSQL & " And"
        mstrSQL = mstrSQL & " Size LIKE " & txtSel2nd.Text
        blnMultiSel = True
    End If

    If blnMultiSel Then
'        mstrSQL = mstrSQL & " ORDER BY Model"
        dtcReBuildCost.RecordSource = mstrSQL
        dtcReBuildCost.Refresh
        dtcReBuildCost.UpdateControls
    End If

    Screen.MousePointer = vbDefault
End Sub

Private Sub Go_Lens()
    Dim blnMultiSel As Boolean
    
    Screen.MousePointer = vbHourglass
    blnMultiSel = False
    mstrSQL = "SELECT * FROM qryReBuildCost WHERE"
    If dbcSupplier.BoundText <> "" Then
        mstrSQL = mstrSQL & " SupplierCode = '" & dbcSupplier.BoundText & "'"
        blnMultiSel = True
    End If
    If dbcBrand.BoundText <> "" Then
        If blnMultiSel Then mstrSQL = mstrSQL & " And"
        mstrSQL = mstrSQL & " BrandCode = '" & dbcBrand.BoundText & "'"
        blnMultiSel = True
    End If
    If txtSel1st.Text <> "" Then
        If blnMultiSel Then mstrSQL = mstrSQL & " And"
        mstrSQL = mstrSQL & " Model LIKE '" & txtSel1st.Text & "'"
        blnMultiSel = True
    End If
    If txtSel2nd.Text <> "" Then
        If blnMultiSel Then mstrSQL = mstrSQL & " And"
        mstrSQL = mstrSQL & " Cylinder LIKE " & txtSel2nd.Text
        blnMultiSel = True
    End If
    If txtSel3rd.Text <> "" Then
        If blnMultiSel Then mstrSQL = mstrSQL & " And"
        mstrSQL = mstrSQL & " Sphere LIKE " & txtSel3rd.Text
        blnMultiSel = True
    End If
    If txtSel4th.Text <> "" Then
        If blnMultiSel Then mstrSQL = mstrSQL & " And"
        mstrSQL = mstrSQL & " BaseCurve LIKE " & txtSel4th.Text
        blnMultiSel = True
    End If

    If blnMultiSel Then
'        mstrSQL = mstrSQL & " ORDER BY Model"
        dtcReBuildCost.RecordSource = mstrSQL
        dtcReBuildCost.Refresh
        dtcReBuildCost.UpdateControls
    End If

    Screen.MousePointer = vbDefault
End Sub

Private Sub Setup4_All()
    Call Setup_Frames(0)
    
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
    dbgWorkBook.Splits(0).Columns(5).Caption = "Model"
    dbgWorkBook.Splits(0).Columns(7).Caption = "Size"
    dbgWorkBook.Splits(0).Columns(7).Visible = True
    dbgWorkBook.Splits(0).Columns(8).Visible = True            ' Cylinder
    dbgWorkBook.Splits(0).Columns(9).Visible = True            ' Sphere
    dbgWorkBook.Splits(0).Columns(10).Visible = True            ' Base Curve
End Sub

Private Sub Setup4_Cont()
    Call Setup_Frames(0)
    
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
    dbgWorkBook.Splits(0).Columns(5).Caption = "Len Style"
    dbgWorkBook.Splits(0).Columns(7).Caption = "Eye Size"
    dbgWorkBook.Splits(0).Columns(7).Visible = False
    dbgWorkBook.Splits(0).Columns(8).Visible = True            ' Cylinder
    dbgWorkBook.Splits(0).Columns(9).Visible = True            ' Sphere
    dbgWorkBook.Splits(0).Columns(10).Visible = True            ' Base Curve
End Sub

Private Sub Setup4_Frame()
    Call Setup_Frames(0)
    
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
    dbgWorkBook.Splits(0).Columns(5).Caption = "Model"
    dbgWorkBook.Splits(0).Columns(7).Caption = "Eye Size"
    dbgWorkBook.Splits(0).Columns(7).Visible = True
    dbgWorkBook.Splits(0).Columns(8).Visible = False           ' Cylinder
    dbgWorkBook.Splits(0).Columns(9).Visible = False           ' Sphere
    dbgWorkBook.Splits(0).Columns(10).Visible = False           ' Base Curve
End Sub

Private Sub Setup4_Lens()
    Call Setup_Frames(0)
    
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
    dbgWorkBook.Splits(0).Columns(5).Caption = "Len Style"
    dbgWorkBook.Splits(0).Columns(7).Visible = False
    dbgWorkBook.Splits(0).Columns(8).Visible = True            ' Cylinder
    dbgWorkBook.Splits(0).Columns(9).Visible = True            ' Sphere
    dbgWorkBook.Splits(0).Columns(10).Visible = True            ' Base Curve
End Sub

Private Sub Go_SKU()
    Dim strSQL As String

    Screen.MousePointer = vbHourglass
    
    strSQL = "SELECT * FROM qryReBuildCost WHERE " & _
             "[ReBuildCost].[SKU] LIKE '" & mskSKU.Text & "'"
    dtcReBuildCost.RecordSource = strSQL
    dtcReBuildCost.Refresh
    dtcReBuildCost.UpdateControls

    Screen.MousePointer = vbDefault
End Sub

Private Sub Setup_Frames(intWhichFrame)
    Select Case intWhichFrame
        Case 1      ' Use SKU
            fraSelectValue.Enabled = False
            fraSelectSKU.Enabled = True
        Case 0      ' Use Others
            fraSelectValue.Enabled = True
            fraSelectSKU.Enabled = False
    End Select
End Sub

Private Sub Setup4_SKU()
    Call Setup_Frames(1)
End Sub

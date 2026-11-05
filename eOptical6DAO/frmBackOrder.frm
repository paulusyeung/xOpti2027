VERSION 4.00
Begin VB.Form frmBackOrder 
   Caption         =   "Back Order"
   ClientHeight    =   3045
   ClientLeft      =   4560
   ClientTop       =   4035
   ClientWidth     =   6270
   Height          =   3450
   Left            =   4500
   LinkTopic       =   "Form1"
   ScaleHeight     =   3045
   ScaleWidth      =   6270
   Top             =   3690
   Width           =   6390
   Begin Threed.SSFrame SSFrame1 
      Height          =   2895
      Left            =   120
      TabIndex        =   0
      Top             =   60
      Width           =   6015
      _Version        =   65536
      _ExtentX        =   10610
      _ExtentY        =   5106
      _StockProps     =   14
      Caption         =   "Back Order - Add"
      Begin VB.Data dtcInventory 
         Caption         =   "Inventory"
         Connect         =   "Access"
         DatabaseName    =   "SynergyV.mdb"
         Exclusive       =   0   'False
         Height          =   300
         Left            =   4200
         Options         =   0
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "Inventory"
         Top             =   1440
         Visible         =   0   'False
         Width           =   1215
      End
      Begin VB.Data dtcBrand 
         Caption         =   "Brand"
         Connect         =   "Access"
         DatabaseName    =   "SynergyV.mdb"
         Exclusive       =   0   'False
         Height          =   315
         Left            =   2280
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT * FROM Brand ORDER BY BrandDescription"
         Top             =   1800
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcSupplier 
         Caption         =   "Supplier"
         Connect         =   "Access"
         DatabaseName    =   "SynergyV.mdb"
         Exclusive       =   0   'False
         Height          =   300
         Left            =   2280
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT SupplierCode, SupplierName FROM Supplier ORDER BY SupplierName"
         Top             =   1440
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcCategory 
         Caption         =   "Category"
         Connect         =   "Access"
         DatabaseName    =   "SynergyV.mdb"
         Exclusive       =   0   'False
         Height          =   315
         Left            =   2280
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT DISTINCT CategoryCode, CategoryName FROM Category ORDER BY CategoryName"
         Top             =   1080
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcClass 
         Caption         =   "Class"
         Connect         =   "Access"
         DatabaseName    =   "SynergyV.mdb"
         Exclusive       =   0   'False
         Height          =   300
         Left            =   2280
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "SELECT DISTINCT ClassCode, ClassName FROM Class ORDER BY ClassName"
         Top             =   720
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.Data dtcDept 
         Caption         =   "Department"
         Connect         =   "Access"
         DatabaseName    =   "SynergyV.mdb"
         Exclusive       =   0   'False
         Height          =   300
         Left            =   2280
         Options         =   4
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "Department"
         Top             =   360
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.TextBox txtModel 
         Height          =   285
         Left            =   1200
         MaxLength       =   30
         TabIndex        =   12
         Top             =   2160
         Width           =   2535
      End
      Begin MSMask.MaskEdBox mskSKU 
         Height          =   315
         Left            =   1200
         TabIndex        =   14
         Top             =   2460
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
         Mask            =   "#############"
      End
      Begin Threed.SSCommand cmdCancel 
         Height          =   375
         Left            =   4920
         TabIndex        =   17
         Top             =   720
         Width           =   855
         _Version        =   65536
         _ExtentX        =   1508
         _ExtentY        =   661
         _StockProps     =   78
         Caption         =   "&Cancel"
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdOK 
         Height          =   375
         Left            =   4920
         TabIndex        =   16
         Top             =   240
         Width           =   855
         _Version        =   65536
         _ExtentX        =   1508
         _ExtentY        =   661
         _StockProps     =   78
         Caption         =   "&OK"
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdGetSKU 
         Height          =   315
         Left            =   2760
         TabIndex        =   15
         Top             =   2460
         Width           =   375
         _Version        =   65536
         _ExtentX        =   661
         _ExtentY        =   556
         _StockProps     =   78
         BevelWidth      =   1
         Outline         =   0   'False
         Picture         =   "frmBackOrder.frx":0000
      End
      Begin VB.Label Label7 
         Caption         =   "SKU"
         Height          =   255
         Left            =   240
         TabIndex        =   13
         Top             =   2460
         Width           =   495
      End
      Begin VB.Label Label6 
         Caption         =   "Model/Style"
         Height          =   255
         Left            =   240
         TabIndex        =   11
         Top             =   2160
         Width           =   975
      End
      Begin MSDBCtls.DBCombo dbcBrand 
         Bindings        =   "frmBackOrder.frx":0552
         Height          =   315
         Left            =   1200
         TabIndex        =   10
         Top             =   1800
         Width           =   2535
         _Version        =   65536
         _ExtentX        =   4471
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
         ListField       =   "BrandDescription"
         BoundColumn     =   "BrandCode"
      End
      Begin VB.Label Label5 
         Caption         =   "Brand"
         Height          =   255
         Left            =   240
         TabIndex        =   9
         Top             =   1800
         Width           =   495
      End
      Begin MSDBCtls.DBCombo dbcSupplier 
         Bindings        =   "frmBackOrder.frx":0563
         Height          =   315
         Left            =   1200
         TabIndex        =   8
         Top             =   1440
         Width           =   2535
         _Version        =   65536
         _ExtentX        =   4471
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
         ListField       =   "SupplierName"
         BoundColumn     =   "SupplierCode"
      End
      Begin VB.Label Label4 
         Caption         =   "Supplier"
         Height          =   255
         Left            =   240
         TabIndex        =   7
         Top             =   1440
         Width           =   735
      End
      Begin MSDBCtls.DBCombo dbcCategory 
         Bindings        =   "frmBackOrder.frx":0577
         Height          =   315
         Left            =   1200
         TabIndex        =   6
         Top             =   1080
         Width           =   2055
         _Version        =   65536
         _ExtentX        =   3625
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
         ListField       =   "CategoryName"
         BoundColumn     =   "CategoryCode"
      End
      Begin VB.Label Label3 
         Caption         =   "Category"
         Height          =   255
         Left            =   240
         TabIndex        =   5
         Top             =   1080
         Width           =   735
      End
      Begin MSDBCtls.DBCombo dbcClass 
         Bindings        =   "frmBackOrder.frx":058B
         Height          =   315
         Left            =   1200
         TabIndex        =   4
         Top             =   720
         Width           =   2055
         _Version        =   65536
         _ExtentX        =   3625
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
         ListField       =   "ClassName"
         BoundColumn     =   "ClassCode"
      End
      Begin VB.Label Label2 
         Caption         =   "Class"
         Height          =   255
         Left            =   240
         TabIndex        =   3
         Top             =   720
         Width           =   495
      End
      Begin MSDBCtls.DBCombo dbcDept 
         Bindings        =   "frmBackOrder.frx":059C
         Height          =   315
         Left            =   1200
         TabIndex        =   2
         Top             =   360
         Width           =   2055
         _Version        =   65536
         _ExtentX        =   3625
         _ExtentY        =   556
         _StockProps     =   77
         ForeColor       =   0
         BackColor       =   16777215
         ListField       =   "DepartmentName"
         BoundColumn     =   "DepartmentCode"
      End
      Begin VB.Label Label1 
         Caption         =   "Department"
         Height          =   255
         Left            =   240
         TabIndex        =   1
         Top             =   360
         Width           =   855
      End
   End
End
Attribute VB_Name = "frmBackOrder"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdGetSKU_Click()
    mskSKU.Text = GetSKUNumber()
    mskSKU.SetFocus
End Sub


Private Sub cmdOK_Click()
    Clipboard.Clear
    Clipboard.SetText dtcInventory.Recordset.Fields("SKU")
End Sub

Private Sub dbcClass_Click(intArea As Integer)
    If intArea = dbcAreaList Then
        ' When Class was selected,
        ' Category DBCombo contains only those with the same Class Code, Dept Code
        Dim strSQL As String
        strSQL = "SELECT DISTINCT CategoryCode, CategoryName FROM Category " _
            & "WHERE DepartmentCode = '" & dbcDept.BoundText & "' AND " _
            & "ClassCode = '" & dbcClass.BoundText & "' " _
            & "ORDER BY CategoryName"
        dtcCategory.RecordSource = strSQL
        dtcCategory.Refresh
        dtcCategory.UpdateControls
    End If
End Sub

Private Sub dbcDept_Click(intArea As Integer)
    ' When Dept was selected,
    ' Class DBCombo contains only those with the same Dept Code
    If intArea = dbcAreaList Then
        Dim strSQL As String
        strSQL = "SELECT * FROM Class " _
            & "WHERE Department = '" & dbcDept.BoundText & "' " _
            & "ORDER BY ClassName"
        dtcClass.RecordSource = strSQL
        dtcClass.Refresh
        dtcClass.UpdateControls
    End If
End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Load()
    Call ofx_RestoreFormPosition(Me, True)
End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_SaveFormPosition(Me)
End Sub


Private Sub mskSKU_GotFocus()
    Call AutoSelect(mskSKU)
End Sub

Private Sub txtModel_GotFocus()
    Call AutoSelect(txtModel)
End Sub



VERSION 4.00
Begin VB.Form frmCoding 
   BorderStyle     =   0  'None
   Caption         =   "Coding"
   ClientHeight    =   5400
   ClientLeft      =   810
   ClientTop       =   2265
   ClientWidth     =   10200
   Height          =   5805
   Left            =   750
   LinkTopic       =   "Form1"
   ScaleHeight     =   5400
   ScaleWidth      =   10200
   ShowInTaskbar   =   0   'False
   Top             =   1920
   Width           =   10320
   Begin Threed.SSCommand SSCommand12 
      Height          =   1575
      Left            =   4200
      TabIndex        =   12
      Top             =   1920
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Add"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand11 
      Height          =   1575
      Left            =   6240
      TabIndex        =   11
      Top             =   1920
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Material"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand10 
      Height          =   1575
      Left            =   2160
      TabIndex        =   10
      Top             =   1920
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Brand"
      Outline         =   0   'False
   End
   Begin Sidewalk_Transparent.Transparent Transparent1 
      Height          =   420
      Left            =   9480
      TabIndex        =   9
      Top             =   120
      Visible         =   0   'False
      Width           =   420
      _Version        =   65537
      _ExtentX        =   741
      _ExtentY        =   741
      _StockProps     =   0
   End
   Begin Threed.SSCommand SSCommand9 
      Height          =   1575
      Left            =   4200
      TabIndex        =   8
      Top             =   3720
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Staff"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand8 
      Height          =   1575
      Left            =   120
      TabIndex        =   7
      Top             =   3720
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Supplier"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand7 
      Height          =   1575
      Left            =   2160
      TabIndex        =   6
      Top             =   3720
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Customer"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand6 
      Height          =   1575
      Left            =   6240
      TabIndex        =   5
      Top             =   3720
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Branch"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand5 
      Height          =   1575
      Left            =   8280
      TabIndex        =   4
      Top             =   3720
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Payment"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand4 
      Height          =   1575
      Left            =   120
      TabIndex        =   3
      Top             =   1920
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Inventory"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   1575
      Left            =   4200
      TabIndex        =   2
      Top             =   120
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Category"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   1575
      Left            =   2160
      TabIndex        =   1
      Top             =   120
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Class"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   1575
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Department"
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmCoding"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Private Sub SSCommand1_Click()
    frmDept.Show 1
End Sub


Private Sub SSCommand10_Click()
    frmBrand.Show 1
End Sub


Private Sub SSCommand11_Click()
    frmMaterial.Show 1
End Sub

Private Sub SSCommand12_Click()
    frmAdd.Show 1
End Sub

Private Sub SSCommand2_Click()
    frmClass.Show 1
End Sub


Private Sub SSCommand3_Click()
    frmCategory.Show 1
End Sub


Private Sub SSCommand4_Click()
    frmInvt.Show 1
End Sub


Private Sub SSCommand5_Click()
    frmPayment.Show 1
End Sub


Private Sub SSCommand6_Click()
    frmBranch.Show 1
End Sub


Private Sub SSCommand7_Click()
    frmCustomer.Show 1
End Sub


Private Sub SSCommand8_Click()
    frmSupplier.Show 1
End Sub


Private Sub SSCommand9_Click()
    frmStaff.Show 1
End Sub



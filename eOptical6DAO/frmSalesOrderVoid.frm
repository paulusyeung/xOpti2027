VERSION 4.00
Begin VB.Form frmSalesOrderVoid 
   Caption         =   "Void Sales Order"
   ClientHeight    =   1410
   ClientLeft      =   3720
   ClientTop       =   3585
   ClientWidth     =   3525
   Height          =   1815
   Left            =   3660
   LinkTopic       =   "Form1"
   ScaleHeight     =   1410
   ScaleWidth      =   3525
   Top             =   3240
   Width           =   3645
   Begin Threed.SSCommand cmdCancel 
      Height          =   375
      Left            =   1920
      TabIndex        =   3
      Top             =   900
      Width           =   975
      _Version        =   65536
      _ExtentX        =   1720
      _ExtentY        =   661
      _StockProps     =   78
      Caption         =   "Cancel"
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdOK 
      Height          =   375
      Left            =   600
      TabIndex        =   2
      Top             =   900
      Width           =   975
      _Version        =   65536
      _ExtentX        =   1720
      _ExtentY        =   661
      _StockProps     =   78
      Caption         =   "OK"
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin SSCalendarWidgets_A.SSDateCombo calVoidOn 
      Height          =   315
      Left            =   1080
      TabIndex        =   1
      Top             =   120
      Width           =   2175
      _Version        =   65536
      _ExtentX        =   3836
      _ExtentY        =   556
      _StockProps     =   77
      Format          =   "MMMM DD, YYYY"
      ShowCentury     =   -1  'True
   End
   Begin VB.Label Label1 
      Caption         =   "Void On"
      Height          =   255
      Left            =   240
      TabIndex        =   0
      Top             =   120
      Width           =   735
   End
End
Attribute VB_Name = "frmSalesOrderVoid"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Private Sub Form_Load()
    Call ofx_CenterForm(Me)
End Sub



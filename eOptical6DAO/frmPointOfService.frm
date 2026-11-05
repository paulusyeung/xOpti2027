VERSION 4.00
Begin VB.Form frmPointOfService 
   BorderStyle     =   0  'None
   Caption         =   "Point-of-Service"
   ClientHeight    =   5625
   ClientLeft      =   60
   ClientTop       =   2910
   ClientWidth     =   11910
   Height          =   6030
   Left            =   0
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5625
   ScaleWidth      =   11910
   ShowInTaskbar   =   0   'False
   Top             =   2565
   Width           =   12030
   Begin Sidewalk_Transparent.Transparent Transparent1 
      Height          =   420
      Left            =   6000
      TabIndex        =   5
      Top             =   3000
      Visible         =   0   'False
      Width           =   420
      _Version        =   65537
      _ExtentX        =   741
      _ExtentY        =   741
      _StockProps     =   0
   End
   Begin Threed.SSCommand SSCommand5 
      Height          =   1575
      Left            =   2040
      TabIndex        =   4
      Top             =   1800
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Lock Out"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand4 
      Height          =   1575
      Left            =   120
      TabIndex        =   3
      Top             =   1800
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Daily Closing"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   1575
      Left            =   3960
      TabIndex        =   2
      Top             =   120
      Width           =   1935
      _Version        =   65536
      _ExtentX        =   3413
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Refund"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   1575
      Left            =   2040
      TabIndex        =   1
      Top             =   120
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Invoice"
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
      Caption         =   "Order Entry"
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmPointOfService"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Private Sub SSCommand1_Click()
    frmSalesOrder.Show
End Sub


Private Sub SSCommand2_Click()
    frmSalesInvoice.Show
End Sub


Private Sub SSCommand3_Click()
    frmSalesRefund.Show
End Sub



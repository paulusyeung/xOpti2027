VERSION 4.00
Begin VB.Form frmIC 
   BorderStyle     =   0  'None
   Caption         =   "Inventory Control"
   ClientHeight    =   5985
   ClientLeft      =   75
   ClientTop       =   2535
   ClientWidth     =   11835
   Height          =   6390
   Left            =   15
   LinkTopic       =   "Form1"
   ScaleHeight     =   5985
   ScaleWidth      =   11835
   ShowInTaskbar   =   0   'False
   Top             =   2190
   Width           =   11955
   Begin Sidewalk_Transparent.Transparent Transparent1 
      Height          =   420
      Left            =   480
      TabIndex        =   4
      Top             =   2280
      Visible         =   0   'False
      Width           =   420
      _Version        =   65537
      _ExtentX        =   741
      _ExtentY        =   741
      _StockProps     =   0
   End
   Begin Threed.SSCommand SSCommand4 
      Height          =   1575
      Left            =   5880
      TabIndex        =   3
      Top             =   120
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Stock Adjustment"
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   1575
      Left            =   3960
      TabIndex        =   2
      Top             =   120
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Stock Transfer"
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
      Caption         =   "Stock Reject"
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
      Caption         =   "Stock Received"
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmIC"
Attribute VB_Creatable = False
Attribute VB_Exposed = False

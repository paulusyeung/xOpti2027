VERSION 4.00
Begin VB.Form frmOLAP 
   Caption         =   "OLAP"
   ClientHeight    =   4575
   ClientLeft      =   1140
   ClientTop       =   2880
   ClientWidth     =   8835
   Height          =   4980
   Left            =   1080
   LinkTopic       =   "Form1"
   ScaleHeight     =   0
   ScaleWidth      =   0
   Top             =   2535
   Width           =   8955
   Begin Sidewalk_Transparent.Transparent Transparent1 
      Height          =   420
      Left            =   6960
      TabIndex        =   3
      Top             =   1800
      Width           =   420
      _Version        =   65537
      _ExtentX        =   741
      _ExtentY        =   741
      _StockProps     =   0
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   1455
      Left            =   4080
      TabIndex        =   2
      Top             =   360
      Width           =   1695
      _Version        =   65536
      _ExtentX        =   2990
      _ExtentY        =   2566
      _StockProps     =   78
      Caption         =   "Order In Progress"
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   1455
      Left            =   2160
      TabIndex        =   1
      Top             =   360
      Width           =   1695
      _Version        =   65536
      _ExtentX        =   2990
      _ExtentY        =   2566
      _StockProps     =   78
      Caption         =   "Margin"
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   1455
      Left            =   240
      TabIndex        =   0
      Top             =   360
      Width           =   1695
      _Version        =   65536
      _ExtentX        =   2990
      _ExtentY        =   2566
      _StockProps     =   78
      Caption         =   "Sales"
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmOLAP"
Attribute VB_Creatable = False
Attribute VB_Exposed = False

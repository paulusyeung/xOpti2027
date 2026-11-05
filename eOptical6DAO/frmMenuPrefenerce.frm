VERSION 4.00
Begin VB.Form frmMenuPrefenerce 
   BorderStyle     =   0  'None
   Caption         =   "Preference"
   ClientHeight    =   5940
   ClientLeft      =   1335
   ClientTop       =   1950
   ClientWidth     =   9975
   Height          =   6345
   Left            =   1275
   LinkTopic       =   "Form1"
   ScaleHeight     =   0
   ScaleWidth      =   0
   ShowInTaskbar   =   0   'False
   Top             =   1605
   Width           =   10095
   Begin Sidewalk_Transparent.Transparent Transparent1 
      Height          =   420
      Left            =   9120
      TabIndex        =   4
      Top             =   5280
      Visible         =   0   'False
      Width           =   420
      _Version        =   65537
      _ExtentX        =   741
      _ExtentY        =   741
      _StockProps     =   0
   End
   Begin Threed.SSCommand SSCommand4 
      Height          =   1575
      Left            =   4320
      TabIndex        =   3
      Top             =   1980
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Country"
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   1575
      Left            =   2280
      TabIndex        =   2
      Top             =   1980
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "Province"
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   1575
      Left            =   240
      TabIndex        =   1
      Top             =   1980
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "City"
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   1575
      Left            =   240
      TabIndex        =   0
      Top             =   240
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2778
      _StockProps     =   78
      Caption         =   "System Profile"
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmMenuPrefenerce"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Private Sub SSCommand1_Click()
    frmPreference.Show vbModal
End Sub


Private Sub SSCommand2_Click()
    frmCity.Show
End Sub


Private Sub SSCommand3_Click()
    frmProvince.Show
End Sub


Private Sub SSCommand4_Click()
    frmCountry.Show
End Sub



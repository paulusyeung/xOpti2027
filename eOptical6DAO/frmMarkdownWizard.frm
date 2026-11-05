VERSION 4.00
Begin VB.Form frmMarkdownWizard 
   BorderStyle     =   0  'None
   Caption         =   "MarkdownWizard"
   ClientHeight    =   1530
   ClientLeft      =   5865
   ClientTop       =   5070
   ClientWidth     =   2535
   Height          =   1935
   Left            =   5805
   LinkTopic       =   "Form1"
   ScaleHeight     =   1530
   ScaleWidth      =   2535
   ShowInTaskbar   =   0   'False
   Top             =   4725
   Width           =   2655
   Begin Threed.SSFrame SSFrame1 
      Height          =   1455
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   2535
      _Version        =   65536
      _ExtentX        =   4471
      _ExtentY        =   2566
      _StockProps     =   14
      Caption         =   "Markdown Wizard"
      Begin VB.Label Label1 
         Caption         =   "Markdown"
         Height          =   255
         Left            =   120
         TabIndex        =   3
         Top             =   240
         Width           =   975
      End
      Begin Threed.SSCommand SSCommand2 
         Height          =   375
         Left            =   1320
         TabIndex        =   2
         Top             =   960
         Width           =   1095
         _Version        =   65536
         _ExtentX        =   1931
         _ExtentY        =   661
         _StockProps     =   78
         Caption         =   "Cancel"
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand SSCommand1 
         Height          =   375
         Left            =   120
         TabIndex        =   1
         Top             =   960
         Width           =   1095
         _Version        =   65536
         _ExtentX        =   1931
         _ExtentY        =   661
         _StockProps     =   78
         Caption         =   "OK"
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
End
Attribute VB_Name = "frmMarkdownWizard"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Private Sub Form_Load()

End Sub

Private Sub SSCommand1_Click()
    Unload Me
End Sub


Private Sub SSCommand2_Click()
    Unload Me
End Sub



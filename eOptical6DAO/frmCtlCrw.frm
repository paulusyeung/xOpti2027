VERSION 5.00
Object = "{00025600-0000-0000-C000-000000000046}#5.2#0"; "Crystl32.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form frmCtlCrw 
   BorderStyle     =   0  'None
   Caption         =   "Control Centre for Crystal Reports"
   ClientHeight    =   1500
   ClientLeft      =   5220
   ClientTop       =   4095
   ClientWidth     =   4065
   Enabled         =   0   'False
   Icon            =   "frmCtlCrw.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1500
   ScaleWidth      =   4065
   ShowInTaskbar   =   0   'False
   Visible         =   0   'False
   WindowState     =   2  'Maximized
   Begin VB.TextBox txtCrwRptName 
      Enabled         =   0   'False
      Height          =   375
      Left            =   600
      TabIndex        =   0
      TabStop         =   0   'False
      Text            =   "CrwRptName"
      Top             =   480
      Visible         =   0   'False
      Width           =   3015
   End
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   1200
      Top             =   960
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin Crystal.CrystalReport CrystalReport1 
      Left            =   2520
      Top             =   960
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   348160
      WindowState     =   2
      PrintFileLinesPerPage=   60
   End
End
Attribute VB_Name = "frmCtlCrw"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

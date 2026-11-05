VERSION 5.00
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Begin VB.Form frmOrderCustomerRemarks 
   Caption         =   "Customer - Remarks"
   ClientHeight    =   2610
   ClientLeft      =   3720
   ClientTop       =   3915
   ClientWidth     =   6630
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   2610
   ScaleWidth      =   6630
   Begin Threed.SSFrame fraEditRemarks 
      Height          =   2415
      Left            =   120
      TabIndex        =   0
      Top             =   60
      Width           =   6375
      _ExtentX        =   11245
      _ExtentY        =   4260
      _Version        =   131074
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Edit Remarks"
      Begin VB.Data dtcCustomer 
         Caption         =   "Customer"
         Connect         =   "Access 2000;"
         DatabaseName    =   "SynergyV.mdb"
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   315
         Left            =   240
         Options         =   0
         ReadOnly        =   0   'False
         RecordsetType   =   1  'Dynaset
         RecordSource    =   ""
         Top             =   1260
         Visible         =   0   'False
         Width           =   1140
      End
      Begin VB.TextBox txtRemarks 
         DataField       =   "Remarks"
         DataSource      =   "dtcCustomer"
         Height          =   1635
         Left            =   1560
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   4
         Top             =   660
         Width           =   3495
      End
      Begin VB.TextBox txtCustomerName 
         DataField       =   "FullName"
         DataSource      =   "dtcCustomer"
         Enabled         =   0   'False
         Height          =   315
         Left            =   1560
         TabIndex        =   2
         Top             =   300
         Width           =   2175
      End
      Begin Threed.SSCommand cmdCancel 
         Height          =   375
         Left            =   5280
         TabIndex        =   6
         Top             =   660
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   661
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "Cancel"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdSave 
         Height          =   375
         Left            =   5280
         TabIndex        =   5
         Top             =   240
         Width           =   975
         _ExtentX        =   1720
         _ExtentY        =   661
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "Save"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label2 
         Caption         =   "Customer Remarks"
         Height          =   315
         Left            =   120
         TabIndex        =   3
         Top             =   720
         Width           =   1335
      End
      Begin VB.Label Label1 
         Caption         =   "Customer Name"
         Height          =   255
         Left            =   120
         TabIndex        =   1
         Top             =   300
         Width           =   1215
      End
   End
End
Attribute VB_Name = "frmOrderCustomerRemarks"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdCancel_Click()
    dtcCustomer.Refresh
    Unload Me
End Sub


Private Sub cmdSave_Click()
    With dtcCustomer.Recordset
        .Edit
        .Update
    End With
    Unload Me
End Sub


Private Sub Form_Activate()
    If txtCustomerName.Tag = "" Or txtCustomerName.Tag = Null Then
    Else
        Screen.MousePointer = vbDefault
    End If
End Sub

Private Sub Form_Load()
    Call ofx_RestoreFormPosition(Me, True)
    Call DoRetrieve
End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_SaveFormPosition(Me)
End Sub



Private Sub DoRetrieve()
    Dim strSQL As String
    
    strSQL = "SELECT ID, FullName, Remarks FROM Customer " & _
             "WHERE ID =" & frmSalesOrder.txtCustomerName.Tag
    dtcCustomer.RecordSource = strSQL
    dtcCustomer.Refresh
    dtcCustomer.UpdateControls
End Sub

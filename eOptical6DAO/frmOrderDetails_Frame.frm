VERSION 5.00
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Begin VB.Form frmOrderDetails_Frame 
   Caption         =   "Order Details - Frame"
   ClientHeight    =   3735
   ClientLeft      =   2235
   ClientTop       =   2280
   ClientWidth     =   7065
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3735
   ScaleWidth      =   7065
   Begin VB.Data dtcTxSOrderFrame 
      Caption         =   "TxSOrderFrame"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   5880
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "TxSOrderFrame"
      Top             =   1560
      Visible         =   0   'False
      Width           =   1140
   End
   Begin Threed.SSFrame fraFrameSource 
      Height          =   1515
      Left            =   120
      TabIndex        =   0
      Top             =   60
      Width           =   1575
      _ExtentX        =   2778
      _ExtentY        =   2672
      _Version        =   131074
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Frame Source"
      Begin VB.OptionButton optLenses 
         Caption         =   "Lenses"
         Height          =   255
         Left            =   120
         TabIndex        =   6
         Top             =   1200
         Width           =   855
      End
      Begin VB.OptionButton optFollow 
         Caption         =   "Follow"
         Height          =   255
         Left            =   120
         TabIndex        =   5
         Top             =   900
         Width           =   855
      End
      Begin VB.OptionButton optEnclosed 
         Caption         =   "Enclosed"
         Height          =   255
         Left            =   120
         TabIndex        =   4
         Top             =   600
         Width           =   975
      End
      Begin VB.OptionButton optSupply 
         Caption         =   "Suppliy"
         Height          =   255
         Left            =   120
         TabIndex        =   3
         Top             =   300
         Width           =   855
      End
   End
   Begin Threed.SSFrame fraFrameInfo 
      Height          =   1515
      Left            =   1800
      TabIndex        =   1
      Top             =   60
      Width           =   4215
      _ExtentX        =   7435
      _ExtentY        =   2672
      _Version        =   131074
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Frame Info"
      Begin VB.TextBox txtColor 
         DataField       =   "Color"
         DataSource      =   "dtcTxSOrderFrame"
         Height          =   285
         Left            =   840
         TabIndex        =   21
         Text            =   "Text3"
         Top             =   840
         Width           =   855
      End
      Begin VB.TextBox txtModel 
         BackColor       =   &H00C0C0C0&
         Height          =   285
         Left            =   840
         Locked          =   -1  'True
         TabIndex        =   20
         Text            =   "Text2"
         Top             =   540
         Width           =   2415
      End
      Begin VB.TextBox txtBrand 
         BackColor       =   &H00C0C0C0&
         Height          =   285
         Left            =   840
         Locked          =   -1  'True
         TabIndex        =   19
         Text            =   "Text1"
         Top             =   240
         Width           =   2415
      End
      Begin MSMask.MaskEdBox mskTemple 
         DataField       =   "Temple"
         DataSource      =   "dtcTxSOrderFrame"
         Height          =   255
         Left            =   3240
         TabIndex        =   24
         Top             =   1140
         Width           =   855
         _ExtentX        =   1508
         _ExtentY        =   450
         _Version        =   393216
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskBridge 
         DataField       =   "Bridge"
         DataSource      =   "dtcTxSOrderFrame"
         Height          =   255
         Left            =   3240
         TabIndex        =   23
         Top             =   840
         Width           =   855
         _ExtentX        =   1508
         _ExtentY        =   450
         _Version        =   393216
         PromptChar      =   "_"
      End
      Begin MSMask.MaskEdBox mskEyeSize 
         DataField       =   "EyeSize"
         DataSource      =   "dtcTxSOrderFrame"
         Height          =   255
         Left            =   840
         TabIndex        =   22
         Top             =   1140
         Width           =   855
         _ExtentX        =   1508
         _ExtentY        =   450
         _Version        =   393216
         PromptChar      =   "_"
      End
      Begin VB.Label Label6 
         Caption         =   "Temple"
         Height          =   255
         Left            =   2640
         TabIndex        =   12
         Top             =   1140
         Width           =   615
      End
      Begin VB.Label Label5 
         Caption         =   "Bridge"
         Height          =   255
         Left            =   2640
         TabIndex        =   11
         Top             =   840
         Width           =   495
      End
      Begin VB.Label Label4 
         Caption         =   "Eye Size"
         Height          =   255
         Left            =   120
         TabIndex        =   10
         Top             =   1140
         Width           =   735
      End
      Begin VB.Label Label3 
         Caption         =   "Color"
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   840
         Width           =   495
      End
      Begin VB.Label Label2 
         Caption         =   "Model"
         Height          =   255
         Left            =   120
         TabIndex        =   8
         Top             =   540
         Width           =   615
      End
      Begin VB.Label Label1 
         Caption         =   "Brand"
         Height          =   255
         Left            =   120
         TabIndex        =   7
         Top             =   240
         Width           =   495
      End
   End
   Begin Threed.SSFrame fraNotes 
      Height          =   1995
      Left            =   120
      TabIndex        =   2
      Top             =   1620
      Width           =   5895
      _ExtentX        =   10398
      _ExtentY        =   3519
      _Version        =   131074
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Notes"
      Begin VB.TextBox txtSpecialInstruction 
         DataField       =   "SpecialInstruction"
         DataSource      =   "dtcTxSOrderFrame"
         Height          =   735
         Left            =   960
         MultiLine       =   -1  'True
         TabIndex        =   30
         Text            =   "frmOrderDetails_Frame.frx":0000
         Top             =   1140
         Width           =   4815
      End
      Begin VB.TextBox txtB 
         DataField       =   "B"
         DataSource      =   "dtcTxSOrderFrame"
         Height          =   285
         Left            =   3720
         TabIndex        =   29
         Text            =   "Text8"
         Top             =   840
         Width           =   2055
      End
      Begin VB.TextBox txtA 
         DataField       =   "A"
         DataSource      =   "dtcTxSOrderFrame"
         Height          =   285
         Left            =   960
         TabIndex        =   28
         Text            =   "Text7"
         Top             =   840
         Width           =   2055
      End
      Begin VB.TextBox txtR3 
         DataField       =   "R3"
         DataSource      =   "dtcTxSOrderFrame"
         Height          =   285
         Left            =   960
         TabIndex        =   27
         Text            =   "Text6"
         Top             =   540
         Width           =   2055
      End
      Begin VB.TextBox txtR2 
         DataField       =   "R2"
         DataSource      =   "dtcTxSOrderFrame"
         Height          =   285
         Left            =   3720
         TabIndex        =   26
         Text            =   "Text5"
         Top             =   240
         Width           =   2055
      End
      Begin VB.TextBox txtR1 
         DataField       =   "R1"
         DataSource      =   "dtcTxSOrderFrame"
         Height          =   285
         Left            =   960
         TabIndex        =   25
         Text            =   "Text4"
         Top             =   240
         Width           =   2055
      End
      Begin VB.Label Label12 
         Caption         =   "Special Instruction"
         Height          =   435
         Left            =   120
         TabIndex        =   18
         Top             =   1140
         Width           =   855
      End
      Begin VB.Label Label11 
         Caption         =   "B"
         Height          =   255
         Left            =   3360
         TabIndex        =   17
         Top             =   840
         Width           =   255
      End
      Begin VB.Label Label10 
         Caption         =   "A"
         Height          =   255
         Left            =   120
         TabIndex        =   16
         Top             =   840
         Width           =   255
      End
      Begin VB.Label Label9 
         Caption         =   "R3"
         Height          =   255
         Left            =   120
         TabIndex        =   15
         Top             =   540
         Width           =   255
      End
      Begin VB.Label Label8 
         Caption         =   "R2"
         Height          =   255
         Left            =   3360
         TabIndex        =   14
         Top             =   240
         Width           =   255
      End
      Begin VB.Label Label7 
         Caption         =   "R1"
         Height          =   255
         Left            =   120
         TabIndex        =   13
         Top             =   240
         Width           =   255
      End
   End
   Begin Threed.SSCommand cmdRefresh 
      Height          =   375
      Left            =   6120
      TabIndex        =   31
      Top             =   120
      Width           =   855
      _ExtentX        =   1508
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
      Caption         =   "Refresh"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdCancel 
      Height          =   375
      Left            =   6120
      TabIndex        =   33
      Top             =   1080
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   661
      _Version        =   131074
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "&Cancel"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdOK 
      Height          =   375
      Left            =   6120
      TabIndex        =   32
      Top             =   600
      Width           =   855
      _ExtentX        =   1508
      _ExtentY        =   661
      _Version        =   131074
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "&OK"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmOrderDetails_Frame"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim mTxNumber As String
Dim mLineNumber As Long
Dim mSKU As String
Dim mBrand As String
Dim mModel As String
Dim mCustomerName As String
Dim mCustomerID As Long

Private Sub cmdCancel_Click()
    dtcTxSOrderFrame.Refresh
    Unload Me
End Sub

Private Sub cmdOK_Click()
    Call StoreFrameData
    Unload Me
End Sub

Private Sub cmdRefresh_Click()
    Call GetSOrderHeader
    Call OpenWhat
    Call GetSOrderRow
    fraFrameSource.Enabled = True
    fraFrameInfo.Enabled = True
    fraNotes.Enabled = True
    cmdOK.Enabled = True
    cmdCancel.Enabled = True
    cmdRefresh.Enabled = False
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






Private Sub SetBlankForm()
    Dim i As Integer
    
    For i = 0 To (Me.Count - 1)
        If TypeOf Me.Controls(i) Is OptionButton Then
            Me.Controls(i).Value = False    ' unchecked
        End If
        If TypeOf Me.Controls(i) Is MaskEdBox Then
            Me.Controls(i).Text = ""    ' empty
        End If
        If TypeOf Me.Controls(i) Is TextBox Then
            Me.Controls(i).Text = ""    ' empty
        End If
    Next i
    
    ' Default values
    optSupply.Value = True
End Sub


Private Sub StoreFrameData()
    With dtcTxSOrderFrame
        If .EditMode = dbEditInProgress Or _
           .EditMode = dbEditAdd Then
            .UpdateRecord
        End If
    End With
End Sub


Private Sub GetSOrderRow()
    mSKU = ofx_CStr(frmSalesOrder.tdbgTxBody.Columns("SKU"))
    mBrand = ofx_CStr(frmSalesOrder.tdbgTxBody.Columns("Brand"))
    mModel = ofx_CStr(frmSalesOrder.tdbgTxBody.Columns("Model/Style"))
    mCustomerName = frmSalesOrder.txtCustomerName.Text
    mCustomerID = ofx_CLng(frmSalesOrder.txtCustomerName.Tag)
    
    txtBrand = mBrand
    txtModel = mModel
    If mSKU <> "" Then Call GetSOrderRow_SKU
End Sub

' Retrieve the SKU info from Inventory Table
Private Sub GetSOrderRow_SKU()
    Dim strSQL As String
    Dim myDB As Database
    Dim myRS As Recordset
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")
    Set myRS = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)

    strSQL = "SKU = '" & mSKU & "'"
    myRS.FindFirst strSQL
    If Not myRS.NoMatch Then
        txtColor = ofx_CStr(myRS!Color)
        mskEyeSize = ofx_CStr(myRS!Size)
        mskBridge = ofx_CStr(myRS!Bridge)
        mskTemple = ofx_CStr(myRS!Temple)
    End If
    myRS.Close
    myDB.Close
End Sub



Private Sub GetSOrderHeader()
    mTxNumber = "SA" + ofx_CStr(frmSalesOrder.mskOrderNumber.Text)
' The design of TxSOrder could handle multiple Frame Info
' But is not used with this version
'    mLineNumber = ofx_CSng(frmSalesOrder.tdbgTxBody.Columns(0))
    mLineNumber = 0     ' Use one record per SOrder
End Sub


Private Sub OpenWhat()
    Dim strSQL As String
    
    strSQL = "TxNumber ='" & mTxNumber & "' And " & _
             "LineNumber = " & mLineNumber
    With dtcTxSOrderFrame.Recordset
        .FindFirst strSQL
        If .NoMatch Then
            .AddNew
            !TxNumber = mTxNumber
            !LineNumber = mLineNumber
            .Update
            .Bookmark = .LastModified
        End If
        dtcTxSOrderFrame.UpdateControls
        .Edit
    End With
End Sub






VERSION 5.00
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmUtilDataImport 
   Caption         =   "Data Import"
   ClientHeight    =   5205
   ClientLeft      =   1140
   ClientTop       =   2130
   ClientWidth     =   9930
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5205
   ScaleWidth      =   9930
   Begin VB.Data dtcWorksheet 
      Caption         =   "Worksheet"
      Connect         =   "Excel 8.0;"
      DatabaseName    =   "ImportQty.xls"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   315
      Left            =   5640
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   0  'Table
      RecordSource    =   ""
      Top             =   2280
      Visible         =   0   'False
      Width           =   1140
   End
   Begin Threed.SSFrame SSFrame2 
      Height          =   1455
      Left            =   120
      TabIndex        =   0
      Top             =   60
      Width           =   4815
      _ExtentX        =   8493
      _ExtentY        =   2566
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
      Caption         =   "Select Worksheet"
      Begin VB.OptionButton optNewItems 
         Caption         =   "New Items"
         Height          =   255
         Left            =   120
         TabIndex        =   3
         Top             =   1020
         Width           =   1335
      End
      Begin VB.OptionButton optNonLens 
         Caption         =   "Non Lens"
         Height          =   255
         Left            =   120
         TabIndex        =   2
         Top             =   660
         Width           =   1095
      End
      Begin VB.OptionButton optAllLens 
         Caption         =   "All Lens"
         Height          =   315
         Left            =   120
         TabIndex        =   1
         Top             =   300
         Width           =   2295
      End
   End
   Begin Threed.SSFrame SSFrame1 
      Height          =   3555
      Left            =   120
      TabIndex        =   4
      Top             =   1560
      Width           =   9735
      _ExtentX        =   17171
      _ExtentY        =   6271
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
      Caption         =   "Worksheet Data"
      Begin TrueDBGrid50.TDBGrid dbgWorksheet 
         Bindings        =   "frmUtilDataImport.frx":0000
         Height          =   3135
         Left            =   120
         OleObjectBlob   =   "frmUtilDataImport.frx":001B
         TabIndex        =   5
         Top             =   300
         Width           =   9495
      End
   End
   Begin Threed.SSFrame SSFrame3 
      Height          =   1455
      Left            =   5040
      TabIndex        =   6
      Top             =   60
      Width           =   4815
      _ExtentX        =   8493
      _ExtentY        =   2566
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
      Caption         =   "Import Data"
      Begin VB.CheckBox chkImportData 
         Caption         =   "Import Selected Worksheet"
         Height          =   255
         Left            =   240
         TabIndex        =   7
         Top             =   300
         Width           =   2295
      End
      Begin Threed.SSPanel pnlProgress 
         Height          =   615
         Left            =   240
         TabIndex        =   9
         Top             =   720
         Visible         =   0   'False
         Width           =   4335
         _ExtentX        =   7646
         _ExtentY        =   1085
         _Version        =   131074
         BackColor       =   12632256
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "Processing:"
         BevelOuter      =   1
         Alignment       =   0
         Begin VB.TextBox txtTotalRecord 
            Alignment       =   1  'Right Justify
            Enabled         =   0   'False
            Height          =   285
            Left            =   3120
            MultiLine       =   -1  'True
            TabIndex        =   13
            Text            =   "frmUtilDataImport.frx":1A94
            Top             =   240
            Width           =   855
         End
         Begin VB.TextBox txtRecordCount 
            Alignment       =   1  'Right Justify
            Enabled         =   0   'False
            Height          =   285
            Left            =   1680
            MultiLine       =   -1  'True
            TabIndex        =   11
            Text            =   "frmUtilDataImport.frx":1A9A
            Top             =   240
            Width           =   855
         End
         Begin VB.Label Label2 
            Caption         =   "of"
            Height          =   255
            Left            =   2760
            TabIndex        =   12
            Top             =   240
            Width           =   255
         End
         Begin VB.Label Label1 
            Caption         =   "Record"
            Height          =   255
            Left            =   960
            TabIndex        =   10
            Top             =   240
            Width           =   615
         End
      End
      Begin Threed.SSCommand cmdGo 
         Height          =   375
         Left            =   3480
         TabIndex        =   8
         Top             =   240
         Width           =   1095
         _ExtentX        =   1931
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
         Caption         =   "Go"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
End
Attribute VB_Name = "frmUtilDataImport"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim myCurrentOption As Integer
Private Const myOptionAllLens As Integer = 1
Private Const myOptionNonLens   As Integer = 2
Private Const myOptionNewItems  As Integer = 3

Dim myTargetSKU As String

Private Sub cmdGo_Click()
    If chkImportData Then
        Call ImportData
    Else
        MsgBox "You need to make a selection"
    End If
End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)

End Sub


Private Sub optAllLens_Click()
    Dim strSQL As String
    strSQL = "ALLLENS$"
    dtcWorksheet.RecordSource = strSQL
    dtcWorksheet.Refresh
    dtcWorksheet.UpdateControls
    dbgWorksheet.ReBind
    myCurrentOption = myOptionAllLens
End Sub



Private Sub optNonLens_Click()

    Dim strSQL As String
    strSQL = "NONLENS$"
    dtcWorksheet.RecordSource = strSQL
    dtcWorksheet.Refresh
    dtcWorksheet.UpdateControls
    dbgWorksheet.ReBind
    myCurrentOption = myOptionNonLens

End Sub


Private Sub optNewItems_Click()

    Dim strSQL As String
    strSQL = "NEWITEMS$"
    dtcWorksheet.RecordSource = strSQL
    dtcWorksheet.Refresh
    dtcWorksheet.UpdateControls
    dbgWorksheet.ReBind
    myCurrentOption = myOptionNewItems

End Sub




Private Sub ImportData()
    
    Dim intRecordCount As Integer
    
    pnlProgress.Visible = True
    pnlProgress.Refresh
    Call ShowTotalRecord
    
    '
    dtcWorksheet.Recordset.MoveFirst
    Do While Not dtcWorksheet.Recordset.EOF
        If dtcWorksheet.Recordset!SKU = "" Or IsNull(dtcWorksheet.Recordset!SKU) Then
            myTargetSKU = GetSKUNumber()
        Else
            myTargetSKU = dtcWorksheet.Recordset!SKU
        End If
        Call ImportData_Inventory
        Call ImportData_Summary
        intRecordCount = (intRecordCount + 1)
        Call ShowRecordCount(intRecordCount)
        dtcWorksheet.Recordset.MoveNext
    Loop
    
    chkImportData = False
    MsgBox "Done!"
    pnlProgress.Visible = False
    
End Sub







Private Function GetTotalRecord() As Long
    dtcWorksheet.Recordset.MoveFirst
    dtcWorksheet.Recordset.MoveLast
    GetTotalRecord = dtcWorksheet.Recordset.RecordCount
End Function

Private Sub ShowTotalRecord()
    txtTotalRecord.Text = GetTotalRecord()
    txtTotalRecord.Refresh
End Sub

Private Sub ImportData_Inventory()
        
    Dim strCriteria As String
    Dim myDB As Database
    Dim Inventory As Recordset
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set Inventory = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbDenyWrite)      ' Open table read only
    
    strCriteria = "SKU = '" & myTargetSKU & "'"        ' Set the search criteria.
    Inventory.FindFirst strCriteria     ' Find the record. Assume always found
    If Inventory.NoMatch Then
        MsgBox "SKU#" & myTargetSKU & " not exist!!!" & Chr(13) & _
        "Please add new record by mean of function Data Conversion"
        GoTo WrapUp
    Else
        Inventory.Edit
    End If
    
    Inventory!QtyTotalOnhand = dtcWorksheet.Recordset!StockTakeQty
    Inventory.Update
WrapUp:
    Inventory.Close
    myDB.Close                          ' Close database.

End Sub

Private Sub ShowRecordCount(intShowCount As Integer)

    txtRecordCount.Text = intShowCount
    txtRecordCount.Refresh
    
End Sub


Private Sub ImportData_Summary()
    
    Dim strCriteria As String
    Dim myDB As Database
    Dim Summary As Recordset
    Dim RetailPrice As Recordset
    Dim Inventory As Recordset
    Dim datToday As Date
    
    datToday = Now
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set Summary = myDB.OpenRecordset("InvtSummary", dbOpenDynaset, dbDenyWrite)      ' Open table read only
    Set RetailPrice = myDB.OpenRecordset("RetailPrice", dbOpenDynaset, dbDenyWrite)     ' Open table read only
    Set Inventory = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbDenyWrite)     ' Open table read only
    
    strCriteria = "SKU = '" & myTargetSKU & "' And " & _
                  "Year = " & 1997 & " And " & _
                  "Month = " & 1
    Summary.FindFirst strCriteria
    
    strCriteria = "SKU = '" & myTargetSKU & "'"
    RetailPrice.FindFirst strCriteria
    Inventory.FindFirst strCriteria
    
    If Summary.NoMatch Then
        MsgBox "SKU#" & myTargetSKU & " not exist!!!" & Chr(13) & _
        "Please add new record by mean of function Data Conversion"
        GoTo WrapUp
    Else
        Summary.Edit
    End If
    With Summary
            !QtyBF = !QtyPurchased
            !AmtBF = !AmtPurchased
            !qtyCD = dtcWorksheet.Recordset!StockTakeQty
            !AmtCD = !qtyCD * Inventory!AverageCost
            If !QtyBF < !qtyCD Then
                !QtyBF = !qtyCD
                !AmtBF = !AmtCD
            End If
            !QtySold = !QtyBF - !qtyCD
            !AmtSold = !QtySold * RetailPrice!RetailPrice
            !AmtCostOfGoodsSold = !QtySold * Inventory!AverageCost
            !QtyPurchased = 0
            !AmtPurchased = 0
    End With

    Summary.Update
WrapUp:
    Summary.Close
    Inventory.Close
    RetailPrice.Close
    myDB.Close                          ' Close database.

End Sub


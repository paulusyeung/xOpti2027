VERSION 5.00
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmUtilDataConvertion 
   Caption         =   "Data Convertion"
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
      DatabaseName    =   "Import2NDData.xls"
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
      Begin VB.OptionButton optSunGlasses 
         Caption         =   "Sun Glasses"
         Height          =   255
         Left            =   2520
         TabIndex        =   6
         Top             =   1080
         Width           =   1335
      End
      Begin VB.OptionButton optLens 
         Caption         =   "Lens"
         Height          =   255
         Left            =   2520
         TabIndex        =   5
         Top             =   720
         Width           =   735
      End
      Begin VB.OptionButton optFrame 
         Caption         =   "Frame"
         Height          =   315
         Left            =   2520
         TabIndex        =   4
         Top             =   300
         Width           =   855
      End
      Begin VB.OptionButton optDisposal 
         Caption         =   "Disposal"
         Height          =   255
         Left            =   120
         TabIndex        =   3
         Top             =   1020
         Width           =   975
      End
      Begin VB.OptionButton optContact 
         Caption         =   "Contact"
         Height          =   255
         Left            =   120
         TabIndex        =   2
         Top             =   660
         Width           =   1095
      End
      Begin VB.OptionButton optAccessory 
         Caption         =   "Accessory"
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
      TabIndex        =   7
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
         Bindings        =   "frmUtilDataConvertion.frx":0000
         Height          =   3135
         Left            =   120
         OleObjectBlob   =   "frmUtilDataConvertion.frx":001B
         TabIndex        =   8
         Top             =   300
         Width           =   9495
      End
   End
   Begin Threed.SSFrame SSFrame3 
      Height          =   1455
      Left            =   5040
      TabIndex        =   9
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
         TabIndex        =   10
         Top             =   300
         Width           =   2295
      End
      Begin Threed.SSPanel pnlProgress 
         Height          =   615
         Left            =   240
         TabIndex        =   12
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
            TabIndex        =   16
            Text            =   "frmUtilDataConvertion.frx":1A94
            Top             =   240
            Width           =   855
         End
         Begin VB.TextBox txtRecordCount 
            Alignment       =   1  'Right Justify
            Enabled         =   0   'False
            Height          =   285
            Left            =   1680
            MultiLine       =   -1  'True
            TabIndex        =   14
            Text            =   "frmUtilDataConvertion.frx":1A9A
            Top             =   240
            Width           =   855
         End
         Begin VB.Label Label2 
            Caption         =   "of"
            Height          =   255
            Left            =   2760
            TabIndex        =   15
            Top             =   240
            Width           =   255
         End
         Begin VB.Label Label1 
            Caption         =   "Record"
            Height          =   255
            Left            =   960
            TabIndex        =   13
            Top             =   240
            Width           =   615
         End
      End
      Begin Threed.SSCommand cmdGo 
         Height          =   375
         Left            =   3480
         TabIndex        =   11
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
Attribute VB_Name = "frmUtilDataConvertion"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim myCurrentOption As Integer
Private Const myOptionAccessory As Integer = 1
Private Const myOptionContact   As Integer = 2
Private Const myOptionDisposal  As Integer = 3
Private Const myOptionFrame     As Integer = 4
Private Const myOptionLens      As Integer = 5
Private Const myOptionSunglasses    As Integer = 6

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


Private Sub optAccessory_Click()
    Dim strSQL As String
    strSQL = "ACCESSORIES$"
    dtcWorksheet.RecordSource = strSQL
    dtcWorksheet.Refresh
    dtcWorksheet.UpdateControls
    dbgWorksheet.ReBind
    myCurrentOption = myOptionAccessory
End Sub


Private Sub optContact_Click()

    Dim strSQL As String
    strSQL = "CONTACT$"
    dtcWorksheet.RecordSource = strSQL
    dtcWorksheet.Refresh
    dtcWorksheet.UpdateControls
    dbgWorksheet.ReBind
    myCurrentOption = myOptionContact

End Sub


Private Sub optDisposal_Click()

    Dim strSQL As String
    strSQL = "DISPOSAL$"
    dtcWorksheet.RecordSource = strSQL
    dtcWorksheet.Refresh
    dtcWorksheet.UpdateControls
    dbgWorksheet.ReBind
    myCurrentOption = myOptionDisposal

End Sub


Private Sub optFrame_Click()
    
    Dim strSQL As String
    strSQL = "FRAME$"
    dtcWorksheet.RecordSource = strSQL
    dtcWorksheet.Refresh
    dtcWorksheet.UpdateControls
    dbgWorksheet.ReBind
    myCurrentOption = myOptionFrame

End Sub


Private Sub optLens_Click()

    Dim strSQL As String
    strSQL = "LENS$"
    dtcWorksheet.RecordSource = strSQL
    dtcWorksheet.Refresh
    dtcWorksheet.UpdateControls
    dbgWorksheet.ReBind
    myCurrentOption = myOptionLens

End Sub


Private Sub optSunGlasses_Click()

    Dim strSQL As String
    strSQL = "SUNGLASSES$"
    dtcWorksheet.RecordSource = strSQL
    dtcWorksheet.Refresh
    dtcWorksheet.UpdateControls
    dbgWorksheet.ReBind
    myCurrentOption = myOptionSunglasses

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
        Call ImportData_RetailPrice
        intRecordCount = (intRecordCount + 1)
        Call ShowRecordCount(intRecordCount)
        dtcWorksheet.Recordset.MoveNext
    Loop
    
    chkImportData = False
    MsgBox "Done!"
    pnlProgress.Visible = False
    
End Sub

Private Sub ImportAccessory()
    MsgBox "Import Accessory"
End Sub

Private Sub ImportContact()
    MsgBox "Import Contact"
End Sub

Private Sub ImportDisposal()
    MsgBox "Import Disposal"
End Sub

Private Sub ImportFrame()
    MsgBox "Import Frame"
End Sub

Private Sub ImportLens()
    MsgBox "Import Lens"
End Sub

Private Sub ImportSunglasses()
    MsgBox "Import Sunglasses"
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
        Inventory.AddNew
        Inventory!SKU = myTargetSKU
    Else
        Inventory.Edit
    End If
    
    With Inventory
        !DepartmentCode = dtcWorksheet.Recordset!DeptCode
        !ClassCode = dtcWorksheet.Recordset!ClassCode
        !CategoryCode = dtcWorksheet.Recordset!CatCode
        !BrandCode = dtcWorksheet.Recordset!BrandCode
        !MaterialCode = dtcWorksheet.Recordset!MaterialCode
        !SupplierCode = dtcWorksheet.Recordset!SupplierCode
        !Color = Left(dtcWorksheet.Recordset!Color, 8)
        !AverageCost = dtcWorksheet.Recordset!Cost
    End With
    If myCurrentOption = myOptionLens Then
        Inventory!QtyTotalOnhand = dtcWorksheet.Recordset!OPENINGQuantity - _
                                   dtcWorksheet.Recordset!QuantitySold
    Else
        Inventory!QtyTotalOnhand = dtcWorksheet.Recordset!OnhandQuantity
    End If
    Select Case myCurrentOption
        Case myOptionAccessory, myOptionFrame, myOptionSunglasses
            Inventory!Model = dtcWorksheet.Recordset!Model
            Inventory!Size = dtcWorksheet.Recordset!Eye
            Inventory!Bridge = dtcWorksheet.Recordset!Brid
            Inventory!Temple = dtcWorksheet.Recordset!Temp
        Case myOptionContact, myOptionDisposal, myOptionLens
            Inventory!Model = dtcWorksheet.Recordset!LensStyle
            Inventory!Sphere = dtcWorksheet.Recordset!Sphe
            Inventory!Cylinder = dtcWorksheet.Recordset!Cyli
            Inventory!BaseCurve = dtcWorksheet.Recordset!BC
            Inventory!Diameter = dtcWorksheet.Recordset!Diam
    End Select

    Inventory.Update
    Inventory.Close
    myDB.Close                          ' Close database.

End Sub

Private Sub ShowRecordCount(intShowCount As Integer)

    txtRecordCount.Text = intShowCount
    txtRecordCount.Refresh
    
End Sub

Private Sub ImportData_RetailPrice()

    Dim strCriteria As String
    Dim myDB As Database
    Dim RetailPrice As Recordset
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set RetailPrice = myDB.OpenRecordset("RetailPrice", dbOpenDynaset, dbDenyWrite)      ' Open table read only
    
    strCriteria = "SKU = '" & myTargetSKU & "'"        ' Set the search criteria.
    RetailPrice.FindFirst strCriteria     ' Find the record. Assume always found
    If RetailPrice.NoMatch Then
        RetailPrice.AddNew
        RetailPrice!SKU = myTargetSKU
    Else
        RetailPrice.Edit
    End If
    RetailPrice!RetailPrice = dtcWorksheet.Recordset!RetailPrice
    RetailPrice.Update
    RetailPrice.Close
    myDB.Close                          ' Close database.

End Sub

Private Sub ImportData_Summary()
    
    Dim strCriteria As String
    Dim myDB As Database
    Dim Summary As Recordset
    Dim datToday As Date
    
    datToday = Format("1/1/1997", "MM/DD/YYYY")
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set Summary = myDB.OpenRecordset("InvtSummary", dbOpenDynaset, dbDenyWrite)      ' Open table read only
    
    strCriteria = "SKU = '" & myTargetSKU & "' And " & _
                  "Year = " & Year(datToday) & " And " & _
                  "Month = " & Month(datToday)
    Summary.FindFirst strCriteria
    If Summary.NoMatch Then
        Summary.AddNew
        Summary!SKU = myTargetSKU
        Summary!Year = Year(datToday)
        Summary!Month = Month(datToday)
        Summary!FirstDateOfMonth = DateSerial(Year(datToday), Month(datToday), 1)
    Else
        Summary.Edit
    End If
    
    If myCurrentOption = myOptionLens Then
        With Summary
            !qtyCD = dtcWorksheet.Recordset!OPENINGQuantity - dtcWorksheet.Recordset!QuantitySold
            !AmtCD = Summary!qtyCD * dtcWorksheet.Recordset!Cost
            !QtySold = dtcWorksheet.Recordset!QuantitySold
            !AmtSold = (dtcWorksheet.Recordset!AmountSold * 0.756679276) ' adjust by Sunny 02/12/97
            !AmtCostOfGoodsSold = Summary!QtySold * dtcWorksheet.Recordset!Cost
            !QtyPurchased = dtcWorksheet.Recordset!OPENINGQuantity
            !AmtPurchased = Summary!QtyPurchased * dtcWorksheet.Recordset!Cost
        End With
    Else
        With Summary
            !qtyCD = dtcWorksheet.Recordset!OnhandQuantity
            !AmtCD = Summary!qtyCD * dtcWorksheet.Recordset!Cost
            !QtySold = dtcWorksheet.Recordset!QuantitySold
            !AmtSold = (dtcWorksheet.Recordset!AmountSold * 0.756679276) ' adjust by Sunny 02/12/97
            !AmtCostOfGoodsSold = Summary!QtySold * dtcWorksheet.Recordset!Cost
            !QtyPurchased = dtcWorksheet.Recordset!QuantitySold + dtcWorksheet.Recordset!OnhandQuantity
            !AmtPurchased = Summary!QtyPurchased * dtcWorksheet.Recordset!Cost
        End With
    End If

    Summary.Update
    Summary.Close
    myDB.Close                          ' Close database.

End Sub


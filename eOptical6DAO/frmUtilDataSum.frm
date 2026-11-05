VERSION 5.00
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#1.0#0"; "THREED32.OCX"
Begin VB.Form frmUtilDataSum 
   Caption         =   "Data Sum"
   ClientHeight    =   5205
   ClientLeft      =   1395
   ClientTop       =   2400
   ClientWidth     =   9930
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5205
   ScaleWidth      =   9930
   Begin Threed.SSFrame SSFrame1 
      Height          =   5055
      Left            =   240
      TabIndex        =   0
      Top             =   120
      Width           =   4575
      _Version        =   65536
      _ExtentX        =   8070
      _ExtentY        =   8916
      _StockProps     =   14
      Caption         =   "Building Department/Class/Category Summary"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Begin VB.Label Label7 
         Caption         =   "    - Category Summary"
         Height          =   375
         Left            =   600
         TabIndex        =   14
         Top             =   1920
         Width           =   2535
      End
      Begin VB.Label Label6 
         Caption         =   "    - Class Summary"
         Height          =   255
         Left            =   600
         TabIndex        =   13
         Top             =   1560
         Width           =   2535
      End
      Begin VB.Label Label5 
         Caption         =   "    - Department Summary"
         Height          =   375
         Left            =   600
         TabIndex        =   12
         Top             =   1200
         Width           =   2535
      End
      Begin VB.Label Label4 
         Caption         =   "This program re-build following tables:"
         Height          =   375
         Left            =   480
         TabIndex        =   11
         Top             =   840
         Width           =   3855
      End
   End
   Begin Threed.SSFrame SSFrame3 
      Height          =   5055
      Left            =   4920
      TabIndex        =   1
      Top             =   120
      Width           =   4935
      _Version        =   65536
      _ExtentX        =   8705
      _ExtentY        =   8916
      _StockProps     =   14
      Caption         =   "Processing Status"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Begin VB.CheckBox chkGoAhead 
         Caption         =   "Click to start"
         Height          =   255
         Left            =   240
         TabIndex        =   2
         Top             =   300
         Width           =   2295
      End
      Begin Threed.SSPanel pnlProgress 
         Height          =   1695
         Left            =   240
         TabIndex        =   4
         Top             =   720
         Visible         =   0   'False
         Width           =   4335
         _Version        =   65536
         _ExtentX        =   7646
         _ExtentY        =   2990
         _StockProps     =   15
         Caption         =   "Processing:"
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
         BevelOuter      =   1
         Alignment       =   0
         Begin VB.TextBox txtSKU 
            Enabled         =   0   'False
            Height          =   495
            Left            =   1680
            TabIndex        =   9
            TabStop         =   0   'False
            Text            =   "SKU No."
            Top             =   840
            Width           =   2295
         End
         Begin VB.TextBox txtTotalRecord 
            Alignment       =   1  'Right Justify
            Enabled         =   0   'False
            Height          =   285
            Left            =   3120
            MultiLine       =   -1  'True
            TabIndex        =   8
            TabStop         =   0   'False
            Text            =   "frmUtilDataSum.frx":0000
            Top             =   240
            Width           =   855
         End
         Begin VB.TextBox txtRecordCount 
            Alignment       =   1  'Right Justify
            Enabled         =   0   'False
            Height          =   285
            Left            =   1680
            MultiLine       =   -1  'True
            TabIndex        =   6
            TabStop         =   0   'False
            Text            =   "frmUtilDataSum.frx":0006
            Top             =   240
            Width           =   855
         End
         Begin VB.Label Label3 
            Caption         =   "SKU#"
            Height          =   255
            Left            =   960
            TabIndex        =   10
            Top             =   840
            Width           =   615
         End
         Begin VB.Label Label2 
            Caption         =   "of"
            Height          =   255
            Left            =   2760
            TabIndex        =   7
            Top             =   240
            Width           =   255
         End
         Begin VB.Label Label1 
            Caption         =   "Record"
            Height          =   255
            Left            =   960
            TabIndex        =   5
            Top             =   240
            Width           =   615
         End
      End
      Begin Threed.SSCommand cmdGo 
         Height          =   375
         Left            =   3480
         TabIndex        =   3
         Top             =   240
         Width           =   1095
         _Version        =   65536
         _ExtentX        =   1931
         _ExtentY        =   661
         _StockProps     =   78
         Caption         =   "Go"
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
End
Attribute VB_Name = "frmUtilDataSum"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Public intRecordCount As Integer
Public myTargetMonth As Integer
Public myTargetYear As Integer

Public myTargetSKU As String

Public myTargetDept As String
Public myTargetClass As String
Public myTargetCat As String



Private Sub cmdGo_Click()
    If chkGoAhead Then
        Call GetHeaderData
    Else
        MsgBox "You need to click to start"
    End If
End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
End Sub




Private Sub GetHeaderData()
    
    Dim strCriteria As String
    
    Dim SrcDB As Database
    Dim InvtSummary As Recordset
    Dim Inventory As Recordset
    
    Set SrcDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set InvtSummary = SrcDB.OpenRecordset("InvtSummary", dbOpenDynaset, dbDenyWrite)      ' Open table exclusively
    Set Inventory = SrcDB.OpenRecordset("Inventory", dbOpenDynaset, dbDenyWrite)      ' Open table exclusively
  
    pnlProgress.Visible = True
    pnlProgress.Refresh
    Call ShowTotalRecord(InvtSummary)
    intRecordCount = 0
    
    '
    InvtSummary.MoveFirst
    Do While Not InvtSummary.EOF
        With InvtSummary
            myTargetSKU = !SKU
            myTargetYear = !Year
            myTargetMonth = !Month
        End With
        strCriteria = "SKU = '" & myTargetSKU & "'"
        Inventory.FindFirst strCriteria
        If Inventory.NoMatch Then
            MsgBox "SKU#" & myTargetSKU & " not exist!!!" & Chr(13) & _
            "Please add new record by mean of function Data Conversion"
            GoTo WrapUp
        Else
            With Inventory
                myTargetDept = !DepartmentCode
                myTargetClass = !ClassCode
                myTargetCat = !CategoryCode
            End With
            Call BuildDept_Summary(InvtSummary)
            Call BuildClass_Summary(InvtSummary)
            Call BuildCategory_Summary(InvtSummary)
        End If
        intRecordCount = (intRecordCount + 1)
        Call ShowRecordCount(intRecordCount)
        InvtSummary.MoveNext
    Loop
    
    chkGoAhead = False
    MsgBox "Done!"
    pnlProgress.Visible = False
WrapUp:
    InvtSummary.Close
    Inventory.Close
    SrcDB.Close                          ' Close database.

End Sub
Private Function GetTotalRecord(SourceRS As Recordset) As Long

    SourceRS.MoveFirst
    SourceRS.MoveLast
    GetTotalRecord = SourceRS.RecordCount
End Function

Private Sub ShowTotalRecord(SourceRS As Recordset)
    txtTotalRecord.Text = GetTotalRecord(SourceRS)
    txtTotalRecord.Refresh
End Sub


Private Sub ShowRecordCount(intShowCount As Integer)

    txtRecordCount.Text = intShowCount
    txtRecordCount.Refresh
    txtSKU.Text = myTargetSKU
    txtSKU.Refresh
    
End Sub


Private Sub BuildCategory_Summary(SourceRS As Recordset)
    
    Dim strCriteria As String
    Dim myDB As Database
    Dim CategorySummary As Recordset
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    '   Zero file on first record
    If intRecordCount = 0 Then
        myDB.Execute ("DELETE * FROM CategorySummary")
    End If
    
    Set CategorySummary = myDB.OpenRecordset("CategorySummary", dbOpenDynaset, dbDenyWrite)
    strCriteria = "DepartmentCode = '" & myTargetDept & "' And " & _
                  "ClassCode = '" & myTargetClass & "' And " & _
                  "CategoryCode = '" & myTargetCat & "' And " & _
                  "Year = " & myTargetYear & " And " & _
                  "Month = " & myTargetMonth
                  
    CategorySummary.FindFirst strCriteria
    
    If CategorySummary.NoMatch Then
        CategorySummary.AddNew
        With CategorySummary
            !DepartmentCode = myTargetDept
            !ClassCode = myTargetClass
            !CategoryCode = myTargetCat
            !Year = myTargetYear
            !Month = myTargetMonth
            !FirstDateOfMonth = SourceRS!FirstDateOfMonth
            !QtyBF = ofx_CInt(SourceRS!QtyBF)
            !AmtBF = ofx_CCur(SourceRS!AmtBF)
            !qtyCD = ofx_CInt(SourceRS!qtyCD)
            !AmtCD = ofx_CCur(SourceRS!AmtCD)
            !QtySold = ofx_CInt(SourceRS!QtySold)
            !AmtSold = ofx_CCur(SourceRS!AmtSold)
            !AmtCostOfGoodsSold = ofx_CCur(SourceRS!AmtCostOfGoodsSold)
            !QtyPurchased = ofx_CInt(SourceRS!QtyPurchased)
            !AmtPurchased = ofx_CCur(SourceRS!AmtPurchased)
            !QtyAdjustedIncr = ofx_CInt(SourceRS!QtyAdjIncr)
            !AmtAdjustedIncr = ofx_CCur(SourceRS!AmtAdjIncr)
            !QtyAdjustedDecr = ofx_CInt(SourceRS!QtyAdjDecr)
            !AmtAdjustedDecr = ofx_CCur(SourceRS!AmtAdjDecr)
            !QtyRejected = ofx_CInt(SourceRS!QtyRejected)
            !AmtRejected = ofx_CCur(SourceRS!AmtRejected)
            !QtyRestocked = ofx_CInt(SourceRS!QtyRestocked)
            !AmtRestocked = ofx_CCur(SourceRS!AmtRestocked)
            !QtyTransferIn = ofx_CInt(SourceRS!QtyTransferIn)
            !AmtTransferIn = ofx_CCur(SourceRS!AmtTransferIn)
            !QtyTransferOut = ofx_CInt(SourceRS!QtyTransferOut)
            !AmtTransferOut = ofx_CCur(SourceRS!AmtTransferOut)
        End With
    Else
        CategorySummary.Edit
        With CategorySummary
            !QtyBF = !QtyBF + ofx_CInt(SourceRS!QtyBF)
            !AmtBF = !AmtBF + ofx_CCur(SourceRS!AmtBF)
            !qtyCD = !qtyCD + ofx_CInt(SourceRS!qtyCD)
            !AmtCD = !AmtCD + ofx_CCur(SourceRS!AmtCD)
            !QtySold = !QtySold + ofx_CInt(SourceRS!QtySold)
            !AmtSold = !AmtSold + ofx_CCur(SourceRS!AmtSold)
            !AmtCostOfGoodsSold = !AmtCostOfGoodsSold + ofx_CCur(SourceRS!AmtCostOfGoodsSold)
            !QtyPurchased = !QtyPurchased + ofx_CInt(SourceRS!QtyPurchased)
            !AmtPurchased = !AmtPurchased + ofx_CCur(SourceRS!AmtPurchased)
            !QtyAdjustedIncr = !QtyAdjustedIncr + ofx_CInt(SourceRS!QtyAdjIncr)
            !AmtAdjustedIncr = !AmtAdjustedIncr + ofx_CCur(SourceRS!AmtAdjIncr)
            !QtyAdjustedDecr = !QtyAdjustedDecr + ofx_CInt(SourceRS!QtyAdjDecr)
            !AmtAdjustedDecr = !AmtAdjustedDecr + ofx_CCur(SourceRS!AmtAdjDecr)
            !QtyRejected = !QtyRejected + ofx_CInt(SourceRS!QtyRejected)
            !AmtRejected = !AmtRejected + ofx_CCur(SourceRS!AmtRejected)
            !QtyRestocked = !QtyRestocked + ofx_CInt(SourceRS!QtyRestocked)
            !AmtRestocked = !AmtRestocked + ofx_CCur(SourceRS!AmtRestocked)
            !QtyTransferIn = !QtyTransferIn + ofx_CInt(SourceRS!QtyTransferIn)
            !AmtTransferIn = !AmtTransferIn + ofx_CCur(SourceRS!AmtTransferIn)
            !QtyTransferOut = !QtyTransferOut + ofx_CInt(SourceRS!QtyTransferOut)
            !AmtTransferOut = !AmtTransferOut + ofx_CCur(SourceRS!AmtTransferOut)
        End With
    End If
    CategorySummary.Update
WrapUp:
    CategorySummary.Close
    myDB.Close                          ' Close database.

End Sub

Private Sub BuildDept_Summary(SourceRS As Recordset)
    
    Dim strCriteria As String
    Dim myDB As Database
    Dim DeptSummary As Recordset
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    '   Zero file on first record
    If intRecordCount = 0 Then
        myDB.Execute ("DELETE * FROM DeptSummary")
    End If
    
    Set DeptSummary = myDB.OpenRecordset("DeptSummary", dbOpenDynaset, dbDenyWrite)
    
    strCriteria = "DepartmentCode = '" & myTargetDept & "' And " & _
                  "Year = " & myTargetYear & " And " & _
                  "Month = " & myTargetMonth
                  
    DeptSummary.FindFirst strCriteria
    
    If DeptSummary.NoMatch Then
        DeptSummary.AddNew
        With DeptSummary
            !DepartmentCode = myTargetDept
            !Year = myTargetYear
            !Month = myTargetMonth
            !FirstDateOfMonth = SourceRS!FirstDateOfMonth
            !QtyBF = ofx_CInt(SourceRS!QtyBF)
            !AmtBF = ofx_CCur(SourceRS!AmtBF)
            !qtyCD = ofx_CInt(SourceRS!qtyCD)
            !AmtCD = ofx_CCur(SourceRS!AmtCD)
            !QtySold = ofx_CInt(SourceRS!QtySold)
            !AmtSold = ofx_CCur(SourceRS!AmtSold)
            !AmtCostOfGoodsSold = ofx_CCur(SourceRS!AmtCostOfGoodsSold)
            !QtyPurchased = ofx_CInt(SourceRS!QtyPurchased)
            !AmtPurchased = ofx_CCur(SourceRS!AmtPurchased)
            !QtyAdjustedIncr = ofx_CInt(SourceRS!QtyAdjIncr)
            !AmtAdjustedIncr = ofx_CCur(SourceRS!AmtAdjIncr)
            !QtyAdjustedDecr = ofx_CInt(SourceRS!QtyAdjDecr)
            !AmtAdjustedDecr = ofx_CCur(SourceRS!AmtAdjDecr)
            !QtyRejected = ofx_CInt(SourceRS!QtyRejected)
            !AmtRejected = ofx_CCur(SourceRS!AmtRejected)
            !QtyRestocked = ofx_CInt(SourceRS!QtyRestocked)
            !AmtRestocked = ofx_CCur(SourceRS!AmtRestocked)
            !QtyTransferIn = ofx_CInt(SourceRS!QtyTransferIn)
            !AmtTransferIn = ofx_CCur(SourceRS!AmtTransferIn)
            !QtyTransferOut = ofx_CInt(SourceRS!QtyTransferOut)
            !AmtTransferOut = ofx_CCur(SourceRS!AmtTransferOut)
       End With
    Else
        DeptSummary.Edit
        With DeptSummary
            !QtyBF = !QtyBF + ofx_CInt(SourceRS!QtyBF)
            !AmtBF = !AmtBF + ofx_CCur(SourceRS!AmtBF)
            !qtyCD = !qtyCD + ofx_CInt(SourceRS!qtyCD)
            !AmtCD = !AmtCD + ofx_CCur(SourceRS!AmtCD)
            !QtySold = !QtySold + ofx_CInt(SourceRS!QtySold)
            !AmtSold = !AmtSold + ofx_CCur(SourceRS!AmtSold)
            !AmtCostOfGoodsSold = !AmtCostOfGoodsSold + ofx_CCur(SourceRS!AmtCostOfGoodsSold)
            !QtyPurchased = !QtyPurchased + ofx_CInt(SourceRS!QtyPurchased)
            !AmtPurchased = !AmtPurchased + ofx_CCur(SourceRS!AmtPurchased)
            !QtyAdjustedIncr = !QtyAdjustedIncr + ofx_CInt(SourceRS!QtyAdjIncr)
            !AmtAdjustedIncr = !AmtAdjustedIncr + ofx_CCur(SourceRS!AmtAdjIncr)
            !QtyAdjustedDecr = !QtyAdjustedDecr + ofx_CInt(SourceRS!QtyAdjDecr)
            !AmtAdjustedDecr = !AmtAdjustedDecr + ofx_CCur(SourceRS!AmtAdjDecr)
            !QtyRejected = !QtyRejected + ofx_CInt(SourceRS!QtyRejected)
            !AmtRejected = !AmtRejected + ofx_CCur(SourceRS!AmtRejected)
            !QtyRestocked = !QtyRestocked + ofx_CInt(SourceRS!QtyRestocked)
            !AmtRestocked = !AmtRestocked + ofx_CCur(SourceRS!AmtRestocked)
            !QtyTransferIn = !QtyTransferIn + ofx_CInt(SourceRS!QtyTransferIn)
            !AmtTransferIn = !AmtTransferIn + ofx_CCur(SourceRS!AmtTransferIn)
            !QtyTransferOut = !QtyTransferOut + ofx_CInt(SourceRS!QtyTransferOut)
            !AmtTransferOut = !AmtTransferOut + ofx_CCur(SourceRS!AmtTransferOut)
        End With
    End If
    DeptSummary.Update
WrapUp:
    DeptSummary.Close
    myDB.Close                          ' Close database.

End Sub



Private Sub BuildClass_Summary(SourceRS As Recordset)
    
    Dim strCriteria As String
    Dim myDB As Database
    Dim ClassSummary As Recordset
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    '   Zero file on first record
    If intRecordCount = 0 Then
        myDB.Execute ("DELETE * FROM ClassSummary")
    End If
    
    Set ClassSummary = myDB.OpenRecordset("ClassSummary", dbOpenDynaset, dbDenyWrite)
    
    strCriteria = "DepartmentCode = '" & myTargetDept & "' And " & _
                  "ClassCode = '" & myTargetClass & "' And " & _
                  "Year = " & myTargetYear & " And " & _
                  "Month = " & myTargetMonth
                  
    ClassSummary.FindFirst strCriteria
    
    If ClassSummary.NoMatch Then
        ClassSummary.AddNew
        With ClassSummary
            !DepartmentCode = myTargetDept
            !ClassCode = myTargetClass
            !Year = myTargetYear
            !Month = myTargetMonth
            !FirstDateOfMonth = SourceRS!FirstDateOfMonth
            !QtyBF = ofx_CInt(SourceRS!QtyBF)
            !AmtBF = ofx_CCur(SourceRS!AmtBF)
            !qtyCD = ofx_CInt(SourceRS!qtyCD)
            !AmtCD = ofx_CCur(SourceRS!AmtCD)
            !QtySold = ofx_CInt(SourceRS!QtySold)
            !AmtSold = ofx_CCur(SourceRS!AmtSold)
            !AmtCostOfGoodsSold = ofx_CCur(SourceRS!AmtCostOfGoodsSold)
            !QtyPurchased = ofx_CInt(SourceRS!QtyPurchased)
            !AmtPurchased = ofx_CCur(SourceRS!AmtPurchased)
            !QtyAdjustedIncr = ofx_CInt(SourceRS!QtyAdjIncr)
            !AmtAdjustedIncr = ofx_CCur(SourceRS!AmtAdjIncr)
            !QtyAdjustedDecr = ofx_CInt(SourceRS!QtyAdjDecr)
            !AmtAdjustedDecr = ofx_CCur(SourceRS!AmtAdjDecr)
            !QtyRejected = ofx_CInt(SourceRS!QtyRejected)
            !AmtRejected = ofx_CCur(SourceRS!AmtRejected)
            !QtyRestocked = ofx_CInt(SourceRS!QtyRestocked)
            !AmtRestocked = ofx_CCur(SourceRS!AmtRestocked)
            !QtyTransferIn = ofx_CInt(SourceRS!QtyTransferIn)
            !AmtTransferIn = ofx_CCur(SourceRS!AmtTransferIn)
            !QtyTransferOut = ofx_CInt(SourceRS!QtyTransferOut)
            !AmtTransferOut = ofx_CCur(SourceRS!AmtTransferOut)
        End With
    Else
        ClassSummary.Edit
        With ClassSummary
            !QtyBF = !QtyBF + ofx_CInt(SourceRS!QtyBF)
            !AmtBF = !AmtBF + ofx_CCur(SourceRS!AmtBF)
            !qtyCD = !qtyCD + ofx_CInt(SourceRS!qtyCD)
            !AmtCD = !AmtCD + ofx_CCur(SourceRS!AmtCD)
            !QtySold = !QtySold + ofx_CInt(SourceRS!QtySold)
            !AmtSold = !AmtSold + ofx_CCur(SourceRS!AmtSold)
            !AmtCostOfGoodsSold = !AmtCostOfGoodsSold + ofx_CCur(SourceRS!AmtCostOfGoodsSold)
            !QtyPurchased = !QtyPurchased + ofx_CInt(SourceRS!QtyPurchased)
            !AmtPurchased = !AmtPurchased + ofx_CCur(SourceRS!AmtPurchased)
            !QtyAdjustedIncr = !QtyAdjustedIncr + ofx_CInt(SourceRS!QtyAdjIncr)
            !AmtAdjustedIncr = !AmtAdjustedIncr + ofx_CCur(SourceRS!AmtAdjIncr)
            !QtyAdjustedDecr = !QtyAdjustedDecr + ofx_CInt(SourceRS!QtyAdjDecr)
            !AmtAdjustedDecr = !AmtAdjustedDecr + ofx_CCur(SourceRS!AmtAdjDecr)
            !QtyRejected = !QtyRejected + ofx_CInt(SourceRS!QtyRejected)
            !AmtRejected = !AmtRejected + ofx_CCur(SourceRS!AmtRejected)
            !QtyRestocked = !QtyRestocked + ofx_CInt(SourceRS!QtyRestocked)
            !AmtRestocked = !AmtRestocked + ofx_CCur(SourceRS!AmtRestocked)
            !QtyTransferIn = !QtyTransferIn + ofx_CInt(SourceRS!QtyTransferIn)
            !AmtTransferIn = !AmtTransferIn + ofx_CCur(SourceRS!AmtTransferIn)
            !QtyTransferOut = !QtyTransferOut + ofx_CInt(SourceRS!QtyTransferOut)
            !AmtTransferOut = !AmtTransferOut + ofx_CCur(SourceRS!AmtTransferOut)
        End With
    End If
    ClassSummary.Update
WrapUp:
    ClassSummary.Close
    myDB.Close                          ' Close database.

End Sub






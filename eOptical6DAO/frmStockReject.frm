VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmStockReject 
   Caption         =   "Stock Rejected"
   ClientHeight    =   7050
   ClientLeft      =   420
   ClientTop       =   1020
   ClientWidth     =   11340
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   7050
   ScaleWidth      =   11340
   WindowState     =   2  'Maximized
   Begin TrueDBGrid50.TDBGrid dbgTxBody 
      Height          =   2595
      Left            =   120
      OleObjectBlob   =   "frmStockReject.frx":0000
      TabIndex        =   0
      Top             =   3600
      Width           =   11055
   End
   Begin VB.Data dtcInventory 
      Caption         =   "Inventory"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   315
      Left            =   5040
      Options         =   4
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   3240
      Visible         =   0   'False
      Width           =   1935
   End
   Begin VB.Data dtcSupplier 
      Caption         =   "dtcSupplier"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   315
      Left            =   5160
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT SupplierName, SupplierCode FROM Supplier ORDER BY SupplierName"
      Top             =   2940
      Visible         =   0   'False
      Width           =   2175
   End
   Begin VB.Data dtcStaff 
      Caption         =   "dtcStaff"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   315
      Left            =   2880
      Options         =   0
      ReadOnly        =   -1  'True
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT StaffFullName, StaffCode FROM Staff ORDER BY StaffFullName"
      Top             =   2940
      Visible         =   0   'False
      Width           =   2175
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar tbrStockReject 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   0
      Width           =   11340
      _Version        =   131073
      _ExtentX        =   20003
      _ExtentY        =   1906
      _StockProps     =   69
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
      FloatingCaption =   "SSToolbar1"
      AlreadyCreated  =   -1  'True
      Outline         =   0   'False
      BackColorHelp   =   12648447
      ToolsetNumBtnStates=   3
      BtnGroupSpacing =   4
      BtnSpacing      =   0
      Btns            =   8
      ToolsetPicture  =   "frmStockReject.frx":7A0E
      BC              =   8
      BtnToolNum(0)   =   0
      BtnPlaceHolder(0)=   0   'False
      BtnToolNum(1)   =   1
      BtnPlaceHolder(1)=   0   'False
      BtnToolNum(2)   =   2
      BtnPlaceHolder(2)=   0   'False
      BtnToolNum(3)   =   3
      BtnPlaceHolder(3)=   0   'False
      BtnToolNum(4)   =   4
      BtnPlaceHolder(4)=   0   'False
      BtnToolNum(5)   =   5
      BtnPlaceHolder(5)=   0   'False
      BtnToolNum(6)   =   6
      BtnPlaceHolder(6)=   0   'False
      BtnToolNum(7)   =   7
      BtnPlaceHolder(7)=   0   'False
      ToolsetNumTools =   8
      ToolsetToolID(0)=   "ID_Add"
      ToolsetToolHelp(0)=   "Add Record"
      ToolsetToolMnemonic(0)=   "a"
      ToolsetToolGroup(0)=   1
      ToolsetToolAllowAllUp(0)=   -1  'True
      ToolsetToolType(0)=   1
      ToolsetToolExclusive(0)=   -1  'True
      ToolsetToolID(1)=   "ID_Undo"
      ToolsetToolHelp(1)=   "Undo Edit"
      ToolsetToolMnemonic(1)=   "u"
      ToolsetToolGroup(1)=   1
      ToolsetToolAllowAllUp(1)=   -1  'True
      ToolsetToolType(1)=   1
      ToolsetToolExclusive(1)=   -1  'True
      ToolsetToolID(2)=   "ID_Save"
      ToolsetToolHelp(2)=   "Save Record"
      ToolsetToolMnemonic(2)=   "s"
      ToolsetToolGroup(2)=   1
      ToolsetToolAllowAllUp(2)=   -1  'True
      ToolsetToolType(2)=   1
      ToolsetToolExclusive(2)=   -1  'True
      ToolsetToolID(3)=   "ID_Print"
      ToolsetToolHelp(3)=   "Print Record"
      ToolsetToolMnemonic(3)=   "p"
      ToolsetToolGroup(3)=   1
      ToolsetToolAllowAllUp(3)=   -1  'True
      ToolsetToolType(3)=   1
      ToolsetToolExclusive(3)=   -1  'True
      ToolsetToolID(4)=   "ID_BarCode"
      ToolsetToolHelp(4)=   "Print Bar Code"
      ToolsetToolMnemonic(4)=   "b"
      ToolsetToolGroup(4)=   1
      ToolsetToolAllowAllUp(4)=   -1  'True
      ToolsetToolType(4)=   1
      ToolsetToolExclusive(4)=   -1  'True
      ToolsetToolID(5)=   "ID_FindSKU"
      ToolsetToolHelp(5)=   "Find SKU"
      ToolsetToolMnemonic(5)=   "f"
      ToolsetToolGroup(5)=   1
      ToolsetToolAllowAllUp(5)=   -1  'True
      ToolsetToolType(5)=   1
      ToolsetToolExclusive(5)=   -1  'True
      ToolsetToolID(6)=   "ID_AddSKU"
      ToolsetToolHelp(6)=   "Add SKU"
      ToolsetToolMnemonic(6)=   "k"
      ToolsetToolGroup(6)=   1
      ToolsetToolAllowAllUp(6)=   -1  'True
      ToolsetToolType(6)=   1
      ToolsetToolExclusive(6)=   -1  'True
      ToolsetToolID(7)=   "ID_Exit"
      ToolsetToolHelp(7)=   "Exit Task"
      ToolsetToolMnemonic(7)=   "x"
      ToolsetToolGroup(7)=   1
      ToolsetToolAllowAllUp(7)=   -1  'True
      ToolsetToolType(7)=   1
      ToolsetToolExclusive(7)=   -1  'True
      MouseIcon       =   "frmStockReject.frx":13AA0
   End
   Begin Threed.SSFrame fraHeader 
      Height          =   1755
      Left            =   120
      TabIndex        =   2
      Top             =   1080
      Width           =   9855
      _ExtentX        =   17383
      _ExtentY        =   3096
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
      Caption         =   "Header"
      Begin VB.TextBox txtParticular 
         Height          =   495
         Left            =   6240
         MultiLine       =   -1  'True
         TabIndex        =   15
         Top             =   1080
         Width           =   2655
      End
      Begin VB.TextBox txtInvoiceNumber 
         Height          =   315
         Left            =   6240
         TabIndex        =   13
         Top             =   600
         Width           =   1335
      End
      Begin MSDBCtls.DBCombo dbcSupplierName 
         Bindings        =   "frmStockReject.frx":13ABC
         Height          =   315
         Left            =   6240
         TabIndex        =   9
         Top             =   240
         Width           =   2655
         _ExtentX        =   4683
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "SupplierName"
         BoundColumn     =   "SupplierCode"
         Text            =   ""
      End
      Begin MSDBCtls.DBCombo dbcStaffFullName 
         Bindings        =   "frmStockReject.frx":13AD6
         Height          =   315
         Left            =   1200
         TabIndex        =   6
         Top             =   600
         Width           =   2655
         _ExtentX        =   4683
         _ExtentY        =   556
         _Version        =   393216
         BackColor       =   16777215
         ForeColor       =   0
         ListField       =   "StaffFullName"
         BoundColumn     =   "StaffCode"
         Text            =   ""
      End
      Begin SSCalendarWidgets_A.SSDateCombo calTxDate 
         Height          =   315
         Left            =   1200
         TabIndex        =   4
         Top             =   240
         Width           =   2055
         _Version        =   65543
         _ExtentX        =   3625
         _ExtentY        =   556
         _StockProps     =   93
         BeginProperty DropDownFont {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Format          =   "DD MMMM, YYYY"
         ShowCentury     =   -1  'True
      End
      Begin Threed.SSCommand cmdSupplierInfo 
         Height          =   315
         Left            =   9240
         TabIndex        =   11
         TabStop         =   0   'False
         ToolTipText     =   "Supplier Info"
         Top             =   240
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         PictureFrames   =   1
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Picture         =   "frmStockReject.frx":13AED
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdAddSupplier 
         Height          =   315
         Left            =   8880
         TabIndex        =   10
         TabStop         =   0   'False
         ToolTipText     =   "Add Supplier"
         Top             =   240
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         PictureFrames   =   1
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Picture         =   "frmStockReject.frx":1407F
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdAddStaff 
         Height          =   315
         Left            =   3840
         TabIndex        =   7
         TabStop         =   0   'False
         ToolTipText     =   "Add Staff"
         Top             =   600
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         PictureFrames   =   1
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Picture         =   "frmStockReject.frx":1464D
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin VB.Label Label12 
         Caption         =   "Particular"
         Height          =   315
         Left            =   5040
         TabIndex        =   14
         Top             =   1080
         Width           =   1095
      End
      Begin VB.Label Label11 
         Caption         =   "Original Invoice Number"
         Height          =   435
         Left            =   5040
         TabIndex        =   12
         Top             =   660
         Width           =   1095
      End
      Begin VB.Label Label10 
         Caption         =   "Supplier Name"
         Height          =   315
         Left            =   5040
         TabIndex        =   8
         Top             =   240
         Width           =   1215
      End
      Begin VB.Label Label9 
         Caption         =   "Rejected By"
         Height          =   315
         Left            =   120
         TabIndex        =   5
         Top             =   600
         Width           =   1095
      End
      Begin VB.Label Label8 
         Caption         =   "Rejected On"
         Height          =   255
         Left            =   120
         TabIndex        =   3
         Top             =   240
         Width           =   1095
      End
   End
   Begin Threed.SSFrame fraMiniTools 
      Height          =   615
      Left            =   120
      TabIndex        =   16
      Top             =   2880
      Width           =   2175
      _ExtentX        =   3836
      _ExtentY        =   1085
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
      Caption         =   "Mini Tools"
      Begin Threed.SSCommand cmdCalculator 
         Height          =   315
         Left            =   120
         TabIndex        =   17
         TabStop         =   0   'False
         ToolTipText     =   "Calculator"
         Top             =   240
         Width           =   375
         _ExtentX        =   661
         _ExtentY        =   556
         _Version        =   131074
         PictureFrames   =   1
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Picture         =   "frmStockReject.frx":14C1B
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin Threed.SSFrame fraTotal 
      Height          =   675
      Left            =   8160
      TabIndex        =   18
      Top             =   6240
      Width           =   2895
      _ExtentX        =   5106
      _ExtentY        =   1191
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
      Caption         =   "Total"
      Begin VB.TextBox txtTotalAmount 
         Alignment       =   1  'Right Justify
         BackColor       =   &H0000FFFF&
         Height          =   285
         Left            =   1860
         MultiLine       =   -1  'True
         TabIndex        =   22
         TabStop         =   0   'False
         Top             =   300
         Width           =   915
      End
      Begin VB.TextBox txtTotalQty 
         Alignment       =   1  'Right Justify
         BackColor       =   &H0000FFFF&
         Height          =   285
         Left            =   480
         MultiLine       =   -1  'True
         TabIndex        =   20
         TabStop         =   0   'False
         Top             =   300
         Width           =   495
      End
      Begin VB.Label Label2 
         Caption         =   "Amount"
         Height          =   255
         Left            =   1200
         TabIndex        =   21
         Top             =   300
         Width           =   615
      End
      Begin VB.Label Label1 
         Caption         =   "Qty"
         Height          =   255
         Left            =   120
         TabIndex        =   19
         Top             =   300
         Width           =   375
      End
   End
End
Attribute VB_Name = "frmStockReject"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim TxBody As UnboundGrids              ' TxBody grid data source
Dim mCurrentMode  As Integer            ' Current Edit Mode
Private Const mModeIdle As Integer = 0
Private Const mModeAdd  As Integer = 1
Private Const mModeUndo As Integer = 2
Private Const mModeSave As Integer = 3
Dim mTxNumber  As String                ' Current Tx Number

Private Const mColIndexSKU As Integer = 1
Private Const mColIndexQty As Integer = 13
Private Const mColIndexUnitAmt As Integer = 14
Private Const mColIndexAmount As Integer = 15

Private Const mButtonIndex_Add As Integer = 0
Private Const mButtonIndex_Undo As Integer = 1
Private Const mButtonIndex_Save As Integer = 2
Private Const mButtonIndex_Print As Integer = 3
Private Const mButtonIndex_BarCode As Integer = 4
Private Const mButtonIndex_FindSKU As Integer = 5
Private Const mButtonIndex_AddSKU As Integer = 6
Private Const mButtonIndex_Exit As Integer = 7


Private Sub cmdAddStaff_Click()
    frmStaff.Show

End Sub


Private Sub cmdAddSupplier_Click()
    frmSupplier.Show

End Sub

Private Sub cmdCalculator_Click()
    Dim RetVal As Variant
    RetVal = Shell("Calc.Exe", 1)
End Sub

Private Sub cmdSupplierInfo_Click()
    If ofx_IsFormLoaded(frmInfoSupplier) Then _
        Unload frmInfoSupplier
    Screen.MousePointer = vbHourglass
    frmInfoSupplier.Show vbModal
End Sub

Private Sub dbgTxBody_AfterColUpdate(ByVal ColIndex As Integer)
    
    ' Calculate the Net Cost if Qty, Unit Cost, or Markdown is changed
    If dbgTxBody.Columns(ColIndex).Caption = "Qty" Or _
       dbgTxBody.Columns(ColIndex).Caption = "Unit Amount" Then
        CalcAmount
    End If
    

End Sub

Private Sub dbgTxBody_BeforeColEdit(ByVal ColIndex As Integer, ByVal KeyAscii As Integer, Cancel As Integer)
    ' If user is editing the 2nd column and
    ' the 1st column is blank than
    ' display row numbers for the first column.
    With dbgTxBody
        If ColIndex = 1 And _
            .Columns(0) = "" Then
            .Columns(0).Value = TxBody.MaxRow + 1
        End If
    End With
End Sub

Private Sub dbgTxBody_BeforeColUpdate(ByVal ColIndex As Integer, OldValue As Variant, Cancel As Integer)
    Dim strSQL As String
    
    ' Varify the SKU
    ' If valid, move to next cell; else remains on current cell
    If dbgTxBody.Col = dbgTxBody.Columns("SKU").ColIndex And _
       dbgTxBody.Columns(ColIndex).Value <> "" Then
        If LookupPLU(dbgTxBody.Columns("SKU")) Then
            Call FillPLU
        Else
            MsgBox "Invalid SKU!"
            Cancel = True
        End If
    End If
    
    ' Varify the Qty
    If dbgTxBody.Col = dbgTxBody.Columns("Qty").ColIndex Then
        If dbgTxBody.Columns(ColIndex).Value < 0 Then
            ofx_DoMessageBox "You're not allowed to enter a negative Qty"
            Cancel = True
        End If
    End If
    
    ' Varify the Unit Amount
    If dbgTxBody.Col = dbgTxBody.Columns("Unit Amount").ColIndex Then
        If dbgTxBody.Columns(ColIndex).Value < 0 Then
            ofx_DoMessageBox "You're not allowed to enter a negative Unit Amount"
            Cancel = True
        End If
    End If

End Sub


Private Sub dbgTxBody_ClassicAdd(NewRowBookmark As Variant, ByVal Col As Integer, Value As Variant)
    ' ClassicAdd is fired when the user adds a new row
    ' of data through code or by typing in the AddNew row
    ' (the one with the asterisk in the record selector
    ' column.  It alerts your application that it must add
    ' a new row of data to its unbound dataset.  This event
    ' will NOT be fired if the grid's AllowAddNew property
    ' is set to False.
    
    ' Assume that a function StoreUserData(Bookmark, Col,
    ' Value) takes a row bookmark, a column index, and a
    ' variant with the appropriate data to be stored in an
    ' array or database.  The function returns True if the
    ' data is acceptable and can be stored, False otherwise.

    If IsNull(NewRowBookmark) Then
       ' First, get a bookmark for the new row.  Do this
       ' with a VB function, GetNewBookmark.  This
       ' function allocates a new row of data in the storage
       ' medium (array or database), and returns a variant
       ' containing a bookmark for the added row.
       NewRowBookmark = GetNewBookmark(TxBody)
    End If
    
    ' Now store the new value.
    If Not StoreUserData(NewRowBookmark, Col, Value, TxBody) Then
            ' Storage of the data has failed.  Delete the
            ' added row using a VB function, DeleteRow,
            ' which takes a bookmark as an argument.  Also,
            ' fail the update by setting NewRowBookmark to
            ' Null.
            NewRowBookmark = DeleteRow(NewRowBookmark, TxBody)
            NewRowBookmark = Null   'Tell the grid the
                                    ' update failed.
    End If

End Sub

Private Sub dbgTxBody_ClassicDelete(Bookmark As Variant)
    ' ClassicDelete is fired when the user deletes an
    ' existing row in the Unbound grid.  This event
    ' alerts the user that the program must delete the
    ' row specified by the Bookmark parameter from the
    ' dataset.  Here, an auxiliary function (DeleteRow)
    ' is used to do this.

    If Not DeleteRow(Bookmark, TxBody) Then Bookmark = Null
    Call RowNumberReset(TxBody)
End Sub

Private Sub dbgTxBody_ClassicRead(Bookmark As Variant, ByVal Col As Integer, Value As Variant)
    ' ClassicRead is analogous to the Fetch event of the
    ' TrueGrid Pro VBX control.  When the grid needs data
    ' in DataMode 3, it fires a ClassicRead event for
    ' each visible cell on the grid to retrieve the data
    ' that will be shown there, so it fires on a
    ' cell-by-cell basis.  The cell that this event is
    ' firing for is specified by the Bookmark (which
    ' tells which row to fetch the data from) and the
    ' Col parameter (which gives the column index).  The
    ' only difference from the Fetch event of the VBX is
    ' that the row to fetch is specified by a Bookmark
    ' and not an integral row index.  Thus, you must
    ' determine which row in your data source the bookmark.
    ' GetUserData uses the IndexFromBookmark function to
    ' do that.
    
    ' Assume that a function GetUserData(Bookmark, Col,
    ' Value) takes a row bookmark, a column index, and
    ' a variant which will hold the appropriate data to
    ' be fetched from the array or database.  The function
    ' returns the fetched data in the Value parameter if
    ' the fetch is successful, otherwise, it returns Null.
    
    Value = GetUserData(Bookmark, Col, TxBody)

End Sub

Private Sub dbgTxBody_ClassicWrite(Bookmark As Variant, ByVal Col As Integer, Value As Variant)
    ' ClassicWrite is analogous to the Update event of
    ' the TrueGrid Pro VBX control.  When the user
    ' changes data in the grid and commits the change by
    ' moving off of the row in DataMode 3, the grid fires
    ' a ClassicRead event for each cell on that row.  This
    ' event is fired on a cell-by-cell basis.  The cell
    ' that this event is firing for is specified by the
    ' Bookmark (which tells which row the data to be
    ' stored is in) and the Col parameter (which gives
    ' the particular column index of this cell).  The
    ' only difference from the Update event of the VBX is
    ' that the row in which the data is to be stored is
    ' specified by a Bookmark and not an integral row
    ' index.  Thus, you must determine which row in your
    ' data source the bookmark refers to.  StoreUserData
    ' uses the IndexFromBookmark function to do that.
    
    ' Assume that a function StoreUserData(Bookmark, Col,
    ' Value) takes a row bookmark, a column index, and a
    ' variant data value and stores the contents of the
    ' specified cell to the array or database.  The function
    ' returns True if the Update is successful, otherwise,
    ' it returns False.

    If Not StoreUserData(Bookmark, Col, Value, TxBody) Then
        Bookmark = Null   ' Tell the grid the update failed.
    End If

End Sub

Private Sub dbgTxBody_LostFocus()

    ' Calculate the Net Purchase
    ' CalcNetPurchase
    ' Calculate the Total Qty Received
    Call CalcTotals

End Sub

Private Sub dbgTxBody_RowColChange(LastRow As Variant, ByVal LastCol As Integer)
    Dim strDummy, strMessage As String
    
    ' SKU column must be filled
    With dbgTxBody
        If LastCol = .Columns("SKU").ColIndex Then
            If Not (IsNull(.Columns("SKU")) Or .Columns("SKU") = "") Then
                If Not LookupPLU(.Columns("SKU")) Then
                    strMessage = "You must enter a valid SKU."
                    strDummy = MsgBox(strMessage, vbExclamation)
                    .Col = .Columns("SKU").ColIndex
                End If
            End If
        End If
    End With

    ' If current columns is Net Cost,
    ' advance to beginning of next row.
    If dbgTxBody.Columns(dbgTxBody.Col).Caption = "Amount" Then
        SendKeys "{RIGHT}", True
    End If
    
    ' Skip locked columns
    Call SetColFocus(dbgTxBody, TxBody, LastRow, LastCol)
End Sub

Private Sub dbgTxBody_UnboundGetRelativeBookmark(StartLocation As Variant, ByVal OffSet As Long, NewLocation As Variant, ApproximatePosition As Long)
    ' TDBGrid1 calls this routine each time it needs to
    ' reposition itself.  StartLocation is a bookmark
    ' supplied by the grid to indicate the "current"
    ' position -- the row we are moving from.  Offset is
    ' the number of rows we must move from StartLocation
    ' in order to arrive at the desired destination row.
    ' A positive offset means the desired record is after
    ' the StartLocation, and a negative offset means the
    ' desired record is before StartLocation.

    ' If StartLocation is NULL, then we are positioning
    ' from either BOF or EOF.  Once we determine the
    ' correct index for StartLocation, we will simply add
    ' the offset to get the correct destination row.
    ' GetRelativeBookmark already does all of this, so we
    ' just call it here.
    NewLocation = GetRelativeBookmark(StartLocation, OffSet, TxBody)
    
    ' If we are on a valid data row (i.e., not at BOF or
    ' EOF), then set the ApproximatePosition (the ordinal
    ' row number) to improve scroll bar accuracy.  We can
    ' call IndexFromBookmark to do this.
    If Not IsNull(NewLocation) Then
       ApproximatePosition = IndexFromBookmark(NewLocation, 0, TxBody)
    End If

End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
    
    ' Set Grid TXBody X-Y value
    TxBody.MaxCol = 16
    TxBody.MaxRow = 0
    ' Disable some of the buttons
    Call SetMenuButton(mModeIdle)
    Call SetEditMode(mModeIdle)
    
    ' Only enable ToolBar
    Call FrameDisable
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub tbrStockReject_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)
    Dim strPrefix As String
    Dim i As Integer
    
    ' Ignor Up clicks
    If Value = False Then Exit Sub
    
    With tbrStockReject
    ' Avoid operator using the accerator key for disabled buttons.
    ' If the Button pressed is disabled,
    ' raise the button and do nothing.
    If .Buttons(Btn).Enabled = False And Value = True Then
        .Buttons(Btn).Value = False
        Exit Sub
    End If
    
    ' The "exculsive" option of Sheriden ToolBar doesn't work here.
    ' Emulate exclusive function by raising all other buttons
    For i = 0 To (.ToolsetTools.Count - 1)
        If i <> Btn And .Buttons(i).Value Then
            .Buttons(i).Value = False
        End If
    Next i
    
' When button was Down
    If Value Then
        ' The "exculsive" option of Sheriden ToolBar doesn't work here.
        ' Emulate exclusive function by raising all other buttons
        For i = 0 To (.ToolsetTools.Count - 1)
            If i <> Btn Then _
                .Buttons(i).Value = False
        Next i
        '
    Select Case ToolID
    Case "ID_Add"
        Call DoAdd
    Case "ID_Undo"
        Call DoUndo
    Case "ID_Save"
        Call DoSave
    Case "ID_Exit"
        Unload Me
    Case "ID_Print"
        Call DoPrint
    Case "ID_BarCode"
        ' Not Available
    Case "ID_FindSKU"
        Call DoFindSKU
    Case "ID_AddSKU"
        Call DoAddSKU
    End Select
    End If
    End With
End Sub



' Calculate the Amount column
Private Sub CalcAmount()
    Dim intQty      As Integer
    Dim curUnitAmount As Currency
    Dim curAmount  As Currency
    
    intQty = dbgTxBody.Columns("Qty").Value
    curUnitAmount = ofx_CCur(dbgTxBody.Columns("Unit Amount").Value)
    curAmount = intQty * curUnitAmount
    dbgTxBody.Columns("Amount").Value = curAmount

End Sub

' Calculate the Total Amount of this transaction
Private Function CalcTotalAmount() As Currency

    Dim i As Integer
    Dim curTotalAmount As Currency
    
    For i = 0 To (TxBody.MaxRow - 1)
        curTotalAmount = TxBody.GridArray((TxBody.MaxCol - 1), i) + curTotalAmount
    Next i
    CalcTotalAmount = curTotalAmount
    
End Function

Private Function CalcTotalQty() As Integer
    Dim i As Integer
    Dim intTotalQty As Integer

    For i = 0 To (TxBody.MaxRow - 1)
        intTotalQty = ofx_CInt(TxBody.GridArray((TxBody.MaxCol - 3), i)) + intTotalQty
    Next i
    CalcTotalQty = intTotalQty

End Function

' This subroutine would clear all the current entries
Private Sub ClearAllEntries()
    Dim i, j As Integer
    
    ' Clear TxHeader
    dbcStaffFullName.Text = ""
    dbcSupplierName.Text = ""
    txtInvoiceNumber.Text = ""
    txtParticular.Text = ""
    txtTotalQty.Text = ""
    txtTotalAmount.Text = ""
    
    ' Clear TxBody
    TxBody.MaxRow = 0
    ReDim TxBody.GridArray(0 To TxBody.MaxCol - 1, 0)
    dbgTxBody.Bookmark = Null
    dbgTxBody.ReBind
    
    ' Reset Current Tx Number to Null
    mTxNumber = ""
    
    ' Return focus to first entry field
    calTxDate.SetFocus

End Sub

Private Sub SaveEntries()
    Dim curUnitAmount, curAmount, curTotalAmount As Currency
    Dim intQty, intTotalQty As Integer
    Dim strSKU, MyControlNumber As String
    Dim i As Integer
    Dim MyWS As Workspace
    Dim myDB As Database
    Dim TxHeader, TxDetails, TxSalePerson As Recordset
    Dim MyCriteria As String

    ' Varify some important entries
    ' If anyone failed, stop update
    ' 1. Staff  2. Supplier  3. Gird Empty  4. Grid Editing
    If Not IsFound("Staff", "StaffFullName", dbcStaffFullName.Text, vbYes) Or _
       Not IsFound("Supplier", "SupplierName", dbcSupplierName.Text, vbYes) Or _
       IsGridEmpty(dbgTxBody, vbYes) Or _
       IsGridEditing(dbgTxBody, vbYes) Then
        SetEditMode (mModeAdd)
        Exit Sub
    End If
    
    Screen.MousePointer = vbHourglass
    
    ' Calculate totals
    Call CalcTotals
    
    ' Start prepare to update entries
    ' Updates the TxHeader, TxDetails, and TxSalePerson
    MyCriteria = "SKU = '" & " " & "'"      ' Set the criteria.
    MyControlNumber = GetNextControlNumber
    mTxNumber = GetNextTxNumber("RJ")
    
    '
    ' Write entries into Tx files and pass control to OLTP for posting
    '
    Set MyWS = Workspaces(0)
    Set myDB = MyWS.OpenDatabase("SynergyV.mdb")                           ' Open database
    Set TxHeader = myDB.OpenRecordset("TxHeader", dbOpenDynaset, dbAppendOnly)      ' Open table for append only
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbAppendOnly)    ' Open table for append only
    Set TxSalePerson = myDB.OpenRecordset("TxSalePerson", dbOpenDynaset, dbAppendOnly)      ' Open table for append only
    '
    'On Error GoTo RollbackSaveEntries
'    MyWS.BeginTrans
    ' Write TxHeader
    intTotalQty = (0 - txtTotalQty.Text)        ' Convert into -ve value
    curTotalAmount = (0 - txtTotalAmount.Text)  ' Convert into -ve value
    With TxHeader
        .AddNew
        !ControlNumber = MyControlNumber
        !TxType = Left(mTxNumber, 2)
        !TxNumber = mTxNumber
        !DateOfEntry = calTxDate.Text
        !DateOfCreation = Now
        !RefNumber = txtInvoiceNumber.Text
        !Particulars = txtParticular.Text
        !SupplierCode = dbcSupplierName.BoundText
        !TotalCost = curTotalAmount
        !GrossSale = curTotalAmount
        !TotalAmount = curTotalAmount
        !TotalQty = intTotalQty
        .Update
    End With
    ' Write TxSalePerson
    With TxSalePerson
        .AddNew
        !TxNumber = mTxNumber
        !SalesRowNo = 1
        !StaffCode = dbcStaffFullName.BoundText
        .Update
    End With
    ' Write TxDetails
    With TxBody
    For i = 0 To .MaxRow - 1
        strSKU = .GridArray(mColIndexSKU, i)
        If strSKU <> "" Then
            '
            intQty = (0 - TxBody.GridArray(mColIndexQty, i))           ' Convert to -ve value
            curUnitAmount = (0 - TxBody.GridArray(mColIndexUnitAmt, i))    ' Convert to -ve value
            curAmount = (0 - TxBody.GridArray(mColIndexAmount, i))        ' Convert to -ve value
            With TxDetails
                .AddNew
                !ControlNumber = MyControlNumber
                !TxType = Left(mTxNumber, 2)
                !TxNumber = mTxNumber
                !DateOfEntry = calTxDate.Text
                !RowNo = (i + 1)
                !SKU = strSKU
                !Qty = intQty
                !UnitCost = curUnitAmount
                !UnitLSP = GetLSP(strSKU)
                !Amount = curAmount
                .Update
            End With
        End If
    Next i
    End With
    '
'    MyWS.CommitTrans
    
    ' Activate OLTP to post transaction
    OLTP_IC (mTxNumber)
    
    '
    Screen.MousePointer = vbDefault
    ofx_DoMessageBox "Save is done." & Chr$(13) & _
                     "Please stamp your document with the Tx Number: " & mTxNumber & Chr(13) & _
                     "for later reference."
    Exit Sub

RollbackSaveEntries:
'    MyWS.Rollback
    Screen.MousePointer = vbDefault
    ofx_DoMessageBox "Error Detected.  Current Save was aborted."
    Exit Sub

End Sub

Private Sub SetEditMode(iMode As Integer)
    mCurrentMode = iMode
    Call SetMenuButton(iMode)
End Sub




Private Sub FillPLU()
    Dim myCol As Columns
    Dim strSQL, strPrompt, strDummy As String

    Set myCol = dbgTxBody.Columns
    
    ' Find the SKU for this line
    ' If not found then terminate sub
    If Not LookupPLU(myCol("SKU")) Then
        MsgBox "Invalid SKU!"
        Exit Sub
    End If
    
    With dtcInventory.Recordset
        ' Warn the operator if the default supplier of the Inventory
        ' no equals the Supplier in the header
        If !SupplierName <> dbcSupplierName Then
            strPrompt = "Warning!" & Chr(13) & Chr(13) & _
                        "This is to remind you that," & Chr(13) & _
                        "the Original Supplier of SKU " & !SKU & Chr(13) & _
                        "is not the current supplier."
            strDummy = MsgBox(strPrompt, vbExclamation)
        End If
    
    ' Fill the PLU for this line
'        myCol("Supplier") = !SupplierName
        myCol("Brand") = !BrandDescription
        myCol("Model/Style") = !Model
        myCol("Category") = ofx_CStr(!CategoryName)
        myCol("Material") = ofx_CStr(!MaterialDescription)
        myCol("Color") = ofx_CStr(!Color)
        myCol("Size") = ofx_CStr(!Size)
        myCol("Sphere") = ofx_CSng(!Sphere)
        myCol("Cylinder") = ofx_CSng(!Cylinder)
        myCol("Base Curve") = ofx_CSng(!BaseCurve)
        myCol("Qty") = 1
        myCol("Unit Amount") = !AverageCost
        myCol("Amount") = !AverageCost
    End With
End Sub

Private Sub FrameDisable()
    fraHeader.Enabled = False
    fraMiniTools.Enabled = False
    fraTotal.Enabled = False
    dbgTxBody.Enabled = False
End Sub

Private Sub FrameEnable()
    fraHeader.Enabled = True
    fraMiniTools.Enabled = True
    fraTotal.Enabled = True
    dbgTxBody.Enabled = True
End Sub


Private Sub SetMenuButton(intMode As Integer)
    With tbrStockReject
    Select Case intMode
        Case mModeIdle
                .Buttons(mButtonIndex_Add).Enabled = True
                .Buttons(mButtonIndex_Undo).Enabled = False
                .Buttons(mButtonIndex_Save).Enabled = False
                .Buttons(mButtonIndex_Print).Enabled = False
                .Buttons(mButtonIndex_BarCode).Enabled = False
                .Buttons(mButtonIndex_FindSKU).Enabled = False
                .Buttons(mButtonIndex_AddSKU).Enabled = False
                .Buttons(mButtonIndex_Exit).Enabled = True
        Case mModeAdd
                .Buttons(mButtonIndex_Add).Enabled = False
                .Buttons(mButtonIndex_Undo).Enabled = True
                .Buttons(mButtonIndex_Save).Enabled = True
                .Buttons(mButtonIndex_Print).Enabled = False
                .Buttons(mButtonIndex_BarCode).Enabled = False
                .Buttons(mButtonIndex_FindSKU).Enabled = True
                .Buttons(mButtonIndex_AddSKU).Enabled = True
                .Buttons(mButtonIndex_Exit).Enabled = False
        Case mModeUndo
            Call SetMenuButton(mModeIdle)
        Case mModeSave
                .Buttons(mButtonIndex_Add).Enabled = True
                .Buttons(mButtonIndex_Undo).Enabled = False
                .Buttons(mButtonIndex_Save).Enabled = False
                .Buttons(mButtonIndex_Print).Enabled = True
                .Buttons(mButtonIndex_BarCode).Enabled = True
                .Buttons(mButtonIndex_FindSKU).Enabled = False
                .Buttons(mButtonIndex_AddSKU).Enabled = False
                .Buttons(mButtonIndex_Exit).Enabled = True
    End Select
    End With
End Sub

' Caller past the target SKU
' Function search the Table for the matched SKU
Private Function LookupPLU(mySKU As String) As Boolean
    Dim strSQL As String
    
    If IsEmpty(mySKU) Or IsNull(mySKU) Then
        LookupPLU = False
    Else
        strSQL = "SELECT * FROM [Inventory Query] " & _
                 "WHERE SKU = '" & mySKU & "'"
        With dtcInventory
            .RecordSource = strSQL
            .Refresh
            If IsTableEmpty(.Recordset) Then
                LookupPLU = False
            Else
                LookupPLU = True
            End If
        End With
    End If
End Function



' Calculate the Total Qty Rejected
' and the Total Amount Rejected
Private Sub CalcTotals()
    txtTotalQty = CalcTotalQty
    txtTotalAmount = CalcTotalAmount
    txtTotalQty.Refresh
    txtTotalAmount.Refresh
End Sub

Private Function GetLSP(ByVal mySKU As String) As Currency
    Dim strSQL As String
    
    strSQL = "SELECT * FROM [Inventory Query] " & _
             "WHERE SKU = '" & mySKU & "'"
    With dtcInventory
        .RecordSource = strSQL
        .Refresh
        If IsTableEmpty(.Recordset) Then
            GetLSP = 0
        Else
            GetLSP = .Recordset!LeastSellingPrice
        End If
    End With
End Function

Private Sub DoAdd()
    Call SetEditMode(mModeAdd)
    FrameEnable
    ClearAllEntries
End Sub

Private Sub DoUndo()
    Call SetEditMode(mModeUndo)
    ClearAllEntries
    FrameDisable
End Sub

Private Sub DoSave()
    Dim strDummy, strMessage As String
    
    ' Varify some important entries
    ' If anyone failed, stop Save
    ' 1. Staff  2. Supplier  3. Grid Empty  4. Grid Editing
    If Not IsFound("Staff", "StaffFullName", dbcStaffFullName.Text, vbYes) Or _
       Not IsFound("Supplier", "SupplierName", dbcSupplierName.Text, vbYes) Or _
       IsGridEmpty(dbgTxBody, vbYes) Or _
       IsGridEditing(dbgTxBody, vbYes) Then
        Call SetEditMode(mModeAdd)
        strMessage = "After corrected the error(s)," & Chr(13) & _
                     "toggle the Save button to resume Save."
        strDummy = MsgBox(strMessage, vbInformation)
        Exit Sub
    End If
    
    Call SetEditMode(mModeSave)
    SaveEntries
    FrameDisable
End Sub

Private Sub DoPrint()
    Dim strPrefix As String
    RptTxNumberFrom = mTxNumber
    strPrefix = Left(mTxNumber, 2)
    Call PrintStockTrans(strPrefix, 1, 0)
End Sub

Private Sub DoFindSKU()
    Clipboard.Clear
    If ofx_IsFormLoaded(frmInfoSKU) Then _
        Unload frmInfoSKU
    Screen.MousePointer = vbHourglass
    frmInfoSKU.Show vbModal
    If IsNull(Clipboard.GetText) Or Clipboard.GetText = "" Then
    Else
        dbgTxBody.Columns("SKU").Value = Clipboard.GetText
        Call FillPLU
    End If
End Sub

Private Sub DoAddSKU()
    Clipboard.Clear
    If ofx_IsFormLoaded(frmInvt) Then _
        Unload frmInvt
    Screen.MousePointer = vbHourglass
    frmInvt.Show vbModal
    If IsNull(Clipboard.GetText) Or Clipboard.GetText = "" Then
    Else
        dbgTxBody.Columns("SKU").Value = Clipboard.GetText
        Call FillPLU
    End If
End Sub

VERSION 4.00
Begin VB.Form frmStockReceived 
   Caption         =   "Stock Received"
   ClientHeight    =   6225
   ClientLeft      =   1485
   ClientTop       =   1875
   ClientWidth     =   8895
   Height          =   6630
   Left            =   1425
   LinkTopic       =   "Form1"
   ScaleHeight     =   0
   ScaleWidth      =   0
   Top             =   1530
   Width           =   9015
   Begin VB.Data dtcInvt 
      Caption         =   "Inventory"
      Connect         =   "Access"
      DatabaseName    =   "SynergyV.mdb"
      Exclusive       =   0   'False
      Height          =   315
      Left            =   3240
      Options         =   4
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT SKU, AverageCost FROM Inventory ORDER BY SKU"
      Top             =   3360
      Width           =   1935
   End
   Begin VB.TextBox txtParticular 
      Height          =   495
      Left            =   5640
      MultiLine       =   -1  'True
      TabIndex        =   6
      Top             =   1920
      Width           =   2415
   End
   Begin VB.Data dtcStaff 
      Caption         =   "Staff"
      Connect         =   "Access"
      DatabaseName    =   "Synergyv.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   6480
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT StaffFullName, StaffCode FROM Staff ORDER BY StaffFullName"
      Top             =   2700
      Visible         =   0   'False
      Width           =   1935
   End
   Begin VB.TextBox txtTotalQty 
      BackColor       =   &H0080FFFF&
      Enabled         =   0   'False
      Height          =   285
      Left            =   1920
      TabIndex        =   15
      TabStop         =   0   'False
      Top             =   5160
      Width           =   495
   End
   Begin VB.Data dtcSupplier 
      Caption         =   "Supplier"
      Connect         =   "Access"
      DatabaseName    =   "Synergyv.mdb"
      Exclusive       =   0   'False
      Height          =   300
      Left            =   6480
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT SupplierName, SupplierCode FROM Supplier ORDER BY SupplierName"
      Top             =   2460
      Visible         =   0   'False
      Width           =   1935
   End
   Begin VB.TextBox txtPONumber 
      Height          =   285
      Left            =   1320
      TabIndex        =   3
      Top             =   1860
      Width           =   1455
   End
   Begin VB.TextBox txtInvoiceNumber 
      Height          =   285
      Left            =   5640
      TabIndex        =   5
      Top             =   1560
      Width           =   1215
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   11
      Top             =   0
      Width           =   8895
      _Version        =   131073
      _ExtentX        =   15690
      _ExtentY        =   1906
      _StockProps     =   69
      BackColor       =   12632256
      FloatingCaption =   "SSToolbar1"
      AlreadyCreated  =   -1  'True
      Outline         =   0   'False
      ToolsetNumBtnStates=   3
      Btns            =   9
      ToolsetPicture  =   "frmStockReceived.frx":0000
      BC              =   9
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
      BtnToolNum(8)   =   8
      BtnPlaceHolder(8)=   0   'False
      ToolsetNumTools =   9
      ToolsetToolID(0)=   "ID_New"
      ToolsetToolHelp(0)=   "New entries"
      ToolsetToolMnemonic(0)=   "n"
      ToolsetToolGroup(0)=   1
      ToolsetToolID(1)=   "ID_Lookup"
      ToolsetToolHelp(1)=   "Lookup old record"
      ToolsetToolMnemonic(1)=   "l"
      ToolsetToolGroup(1)=   1
      ToolsetToolID(2)=   "ID_Save"
      ToolsetToolHelp(2)=   "Save this entries"
      ToolsetToolMnemonic(2)=   "s"
      ToolsetToolGroup(2)=   1
      ToolsetToolID(3)=   "ID_Clear"
      ToolsetToolHelp(3)=   "Clear entries"
      ToolsetToolMnemonic(3)=   "r"
      ToolsetToolGroup(3)=   1
      ToolsetToolID(4)=   "ID_Close"
      ToolsetToolHelp(4)=   "Close this job"
      ToolsetToolMnemonic(4)=   "c"
      ToolsetToolGroup(4)=   1
      ToolsetToolID(5)=   "ID_Print"
      ToolsetToolHelp(5)=   "Print Journal"
      ToolsetToolMnemonic(5)=   "p"
      ToolsetToolGroup(5)=   2
      ToolsetToolID(6)=   "ID_BarCode"
      ToolsetToolHelp(6)=   "Print Bar Code Label"
      ToolsetToolMnemonic(6)=   "b"
      ToolsetToolGroup(6)=   2
      ToolsetToolID(7)=   "ID_FindSKU"
      ToolsetToolHelp(7)=   "Find SKU Info"
      ToolsetToolMnemonic(7)=   "f"
      ToolsetToolGroup(7)=   2
      ToolsetToolID(8)=   "ID_AddSKU"
      ToolsetToolHelp(8)=   "Add a new SKU"
      ToolsetToolMnemonic(8)=   "a"
      ToolsetToolGroup(8)=   2
      MouseIcon       =   "frmStockReceived.frx":1B452
   End
   Begin Threed.SSFrame fraLookupWizard 
      Height          =   1935
      Left            =   5520
      TabIndex        =   19
      Top             =   2940
      Visible         =   0   'False
      Width           =   3135
      _Version        =   65536
      _ExtentX        =   5530
      _ExtentY        =   3413
      _StockProps     =   14
      Caption         =   "Lookup Wizard"
      Begin VB.TextBox txtLwInvoiceNumber 
         Height          =   285
         Left            =   1800
         MaxLength       =   10
         TabIndex        =   25
         Top             =   1080
         Width           =   1095
      End
      Begin VB.TextBox txtLwPONumber 
         Height          =   285
         Left            =   1800
         MaxLength       =   10
         TabIndex        =   24
         Top             =   720
         Width           =   1095
      End
      Begin VB.TextBox txtLwTxNumber 
         Height          =   285
         Left            =   1800
         MaxLength       =   10
         TabIndex        =   23
         Top             =   360
         Width           =   1095
      End
      Begin VB.OptionButton Option3 
         Caption         =   "By Invoice Number"
         Height          =   255
         Left            =   120
         TabIndex        =   22
         Top             =   1080
         Width           =   1695
      End
      Begin VB.OptionButton Option2 
         Caption         =   "By PO Number"
         Height          =   255
         Left            =   120
         TabIndex        =   21
         Top             =   720
         Width           =   1455
      End
      Begin VB.OptionButton Option1 
         Caption         =   "By Tx Number"
         Height          =   255
         Left            =   120
         TabIndex        =   20
         Top             =   360
         Width           =   1335
      End
      Begin Threed.SSCommand SSCommand4 
         Height          =   375
         Left            =   1920
         TabIndex        =   27
         Top             =   1440
         Width           =   975
         _Version        =   65536
         _ExtentX        =   1720
         _ExtentY        =   661
         _StockProps     =   78
         Caption         =   "Cancel"
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand SSCommand3 
         Height          =   375
         Left            =   240
         TabIndex        =   26
         Top             =   1440
         Width           =   975
         _Version        =   65536
         _ExtentX        =   1720
         _ExtentY        =   661
         _StockProps     =   78
         Caption         =   "OK"
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin Threed.SSCommand SSCommand8 
      Height          =   315
      Left            =   8400
      TabIndex        =   31
      TabStop         =   0   'False
      Top             =   1200
      Width           =   375
      _Version        =   65536
      _ExtentX        =   661
      _ExtentY        =   556
      _StockProps     =   78
      BevelWidth      =   1
      Outline         =   0   'False
      Picture         =   "frmStockReceived.frx":1B46E
   End
   Begin Threed.SSCommand SSCommand7 
      Height          =   195
      Left            =   4080
      TabIndex        =   30
      TabStop         =   0   'False
      Top             =   2220
      Width           =   180
      _Version        =   65536
      _ExtentX        =   318
      _ExtentY        =   344
      _StockProps     =   78
      BevelWidth      =   0
      Outline         =   0   'False
      AutoSize        =   2
      Picture         =   "frmStockReceived.frx":1BA00
   End
   Begin Threed.SSCommand SSCommand6 
      Height          =   180
      Left            =   3840
      TabIndex        =   29
      TabStop         =   0   'False
      Top             =   2220
      Width           =   195
      _Version        =   65536
      _ExtentX        =   344
      _ExtentY        =   318
      _StockProps     =   78
      BevelWidth      =   0
      Outline         =   0   'False
      AutoSize        =   2
      Picture         =   "frmStockReceived.frx":1BED6
   End
   Begin Threed.SSCommand SSCommand5 
      Height          =   285
      Left            =   3480
      TabIndex        =   28
      TabStop         =   0   'False
      Top             =   2160
      Width           =   315
      _Version        =   65536
      _ExtentX        =   556
      _ExtentY        =   503
      _StockProps     =   78
      BevelWidth      =   0
      Outline         =   0   'False
      AutoSize        =   2
      Picture         =   "frmStockReceived.frx":1C3A0
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   315
      Left            =   3720
      TabIndex        =   18
      TabStop         =   0   'False
      Top             =   1500
      Width           =   360
      _Version        =   65536
      _ExtentX        =   635
      _ExtentY        =   556
      _StockProps     =   78
      BevelWidth      =   1
      Outline         =   0   'False
      Picture         =   "frmStockReceived.frx":1C91E
   End
   Begin VB.Label Label7 
      Caption         =   "Particular"
      Height          =   255
      Left            =   4440
      TabIndex        =   17
      Top             =   1920
      Width           =   735
   End
   Begin MSDBCtls.DBCombo dbcStaffFullName 
      Bindings        =   "frmStockReceived.frx":1CEEC
      Height          =   315
      Left            =   1320
      TabIndex        =   2
      Top             =   1500
      Width           =   2415
      _Version        =   65536
      _ExtentX        =   4260
      _ExtentY        =   556
      _StockProps     =   77
      ForeColor       =   0
      BackColor       =   16777215
      ListField       =   "StaffFullName"
      BoundColumn     =   "StaffCode"
   End
   Begin VB.Label Label6 
      Caption         =   "Received by"
      Height          =   255
      Left            =   120
      TabIndex        =   16
      Top             =   1500
      Width           =   975
   End
   Begin VB.Label Label4 
      Caption         =   "Total Qty"
      Height          =   255
      Left            =   1200
      TabIndex        =   14
      Top             =   5160
      Width           =   735
   End
   Begin TrueDBGrid.TDBGrid dbgTxTotal 
      Height          =   915
      Left            =   2880
      OleObjectBlob   =   "frmStockReceived.frx":1CEFD
      TabIndex        =   13
      Top             =   5160
      Width           =   2895
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   315
      Left            =   8040
      TabIndex        =   12
      TabStop         =   0   'False
      Top             =   1200
      Width           =   360
      _Version        =   65536
      _ExtentX        =   635
      _ExtentY        =   556
      _StockProps     =   78
      BevelWidth      =   1
      Outline         =   0   'False
      Picture         =   "frmStockReceived.frx":1E2B5
   End
   Begin MSDBCtls.DBCombo dbcSupplierName 
      Bindings        =   "frmStockReceived.frx":1E883
      Height          =   315
      Left            =   5640
      TabIndex        =   4
      Top             =   1200
      Width           =   2415
      _Version        =   65536
      _ExtentX        =   4260
      _ExtentY        =   556
      _StockProps     =   77
      ForeColor       =   0
      BackColor       =   16777215
      ListField       =   "SupplierName"
      BoundColumn     =   "SupplierCode"
   End
   Begin VB.Label Label5 
      Caption         =   "Invoice Number"
      Height          =   255
      Left            =   4440
      TabIndex        =   10
      Top             =   1560
      Width           =   1215
   End
   Begin TrueDBGrid.TDBGrid dbgTxBody 
      Height          =   2535
      Left            =   120
      OleObjectBlob   =   "frmStockReceived.frx":1E897
      TabIndex        =   7
      Top             =   2520
      Width           =   5775
   End
   Begin VB.Label Label3 
      Caption         =   "Purchase Order Number"
      Height          =   495
      Left            =   120
      TabIndex        =   9
      Top             =   1860
      Width           =   1095
   End
   Begin VB.Label Label2 
      Caption         =   "Supplier Name"
      Height          =   255
      Left            =   4440
      TabIndex        =   8
      Top             =   1200
      Width           =   1095
   End
   Begin SSCalendarWidgets_A.SSDateCombo calTxDate 
      Height          =   255
      Left            =   1320
      TabIndex        =   1
      Top             =   1200
      Width           =   2055
      _Version        =   65536
      _ExtentX        =   3625
      _ExtentY        =   450
      _StockProps     =   77
      Format          =   "MMMM DD, YYYY"
      ShowCentury     =   -1  'True
   End
   Begin VB.Label Label1 
      Caption         =   "Received on"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   1200
      Width           =   1095
   End
End
Attribute VB_Name = "frmStockReceived"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Option Explicit

Dim TxBody      As UnboundGrids ' TxBody grid data source
Dim TxTotal     As UnboundGrids ' TxTotal grid data source
Dim MyEditMode  As Byte         ' Current Edit Mode
Dim MyNewMode   As Byte
Dim MySaveMode  As Byte
Dim MyClearMode As Byte
Dim MyTxNumber  As String       ' Current Tx Number



Private Sub dbgTxBody_AfterColUpdate(ByVal ColIndex As Integer)
    
    ' Calculate the Net Cost if Qty, Unit Cost, or Markdown is changed
    If dbgTxBody.Columns(ColIndex).Caption = "Qty" Or _
       dbgTxBody.Columns(ColIndex).Caption = "Unit Cost" Or _
       dbgTxBody.Columns(ColIndex).Caption = "Markdown $" Or _
       dbgTxBody.Columns(ColIndex).Caption = "Markdown %" Then
        CalcNetCost
    End If
    
End Sub

Private Sub dbgTxBody_BeforeColUpdate(ByVal ColIndex As Integer, _
    OldValue As Variant, Cancel As Integer)
    Dim strSQL As String
    
    ' Varify the SKU
    ' If valid, move to next cell; else remains on current cell
    If dbgTxBody.Col = dbgTxBody.Columns("SKU").ColIndex And _
       dbgTxBody.Columns(ColIndex).Value <> "" Then
        strSQL = "SKU = '" & dbgTxBody.Columns("SKU").Value & "'"
        With dtcInvt.Recordset
            .FindFirst strSQL
            If .NoMatch Then
                MsgBox "Invalid SKU!"
                Cancel = True
            Else
'                dbgTxBody.Columns("Qty").Value = 1
                dbgTxBody.Columns("Unit Cost").Value = !AverageCost
            End If
        End With
    End If
    
    ' Varify the Qty
    If dbgTxBody.Col = dbgTxBody.Columns("Qty").ColIndex Then
        If dbgTxBody.Columns(ColIndex).Value < 0 Then
            ofx_DoMessageBox "You're not allowed to enter a negative Qty"
            Cancel = True
        End If
    End If
    
    ' Varify the Unit Cost
    If dbgTxBody.Col = dbgTxBody.Columns("Unit Cost").ColIndex Then
        If dbgTxBody.Columns(ColIndex).Value < 0 Then
            ofx_DoMessageBox "You're not allowed to enter a negative Unit Cost"
            Cancel = True
        End If
    End If
    
    ' Varify the Markdown $
    If dbgTxBody.Col = dbgTxBody.Columns("Markdown $").ColIndex Then
        If dbgTxBody.Columns("Markdown $").Value < 0 Or _
           dbgTxBody.Columns("Markdown $").Value > dbgTxBody.Columns("Unit Cost").Value Then
            ofx_DoMessageBox "Markdown $ should not negative nor greater than Unit Cost"
            Cancel = True
        End If
    End If
    
    ' Varify the Markdown %
    If dbgTxBody.Col = dbgTxBody.Columns("Markdown %").ColIndex Then
        If dbgTxBody.Columns(ColIndex).Value < 0 Or _
           dbgTxBody.Columns(ColIndex).Value > 100 Then
            ofx_DoMessageBox "Markdown % must between 0 to 100"
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

    ' Calculate the Total Qty Received
    txtTotalQty = CalcTotalQty
    
End Sub

Private Sub dbgTxBody_RowColChange(LastRow As Variant, ByVal LastCol As Integer)

    ' If current columns is Net Cost,
    ' advance to beginning of next row.
    If dbgTxBody.Columns(dbgTxBody.Col).Caption = "Net Cost" Then
        SendKeys "{RIGHT}", True
    End If
    
    ' SKU column must be filled
    If Not (dbgTxBody.Col = dbgTxBody.Columns("SKU").ColIndex) Then
        If dbgTxBody.Columns("SKU").Value = "" Then
            ofx_DoMessageBox "You must enter a valid SKU"
            dbgTxBody.Col = dbgTxBody.Columns("SKU").ColIndex
        End If
    End If

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

Private Sub dbgTxTotal_ClassicAdd(NewRowBookmark As Variant, ByVal Col As Integer, Value As Variant)
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
       NewRowBookmark = GetNewBookmark(TxTotal)
    End If
    
    ' Now store the new value.
    If Not StoreUserData(NewRowBookmark, Col, Value, TxTotal) Then
            ' Storage of the data has failed.  Delete the
            ' added row using a VB function, DeleteRow,
            ' which takes a bookmark as an argument.  Also,
            ' fail the update by setting NewRowBookmark to
            ' Null.
            NewRowBookmark = DeleteRow(NewRowBookmark, TxTotal)
            NewRowBookmark = Null   'Tell the grid the
                                    ' update failed.
    End If

End Sub

Private Sub dbgTxTotal_ClassicDelete(Bookmark As Variant)
    ' ClassicDelete is fired when the user deletes an
    ' existing row in the Unbound grid.  This event
    ' alerts the user that the program must delete the
    ' row specified by the Bookmark parameter from the
    ' dataset.  Here, an auxiliary function (DeleteRow)
    ' is used to do this.

    If Not DeleteRow(Bookmark, TxTotal) Then Bookmark = Null

End Sub


Private Sub dbgTxTotal_ClassicRead(Bookmark As Variant, ByVal Col As Integer, Value As Variant)
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
    
    Value = GetUserData(Bookmark, Col, TxTotal)

End Sub

Private Sub dbgTxTotal_ClassicWrite(Bookmark As Variant, ByVal Col As Integer, Value As Variant)
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

    If Not StoreUserData(Bookmark, Col, Value, TxTotal) Then
        Bookmark = Null   ' Tell the grid the update failed.
    End If

End Sub

Private Sub dbgTxTotal_GotFocus()
    ' Fill the Net Purchase amount and re-position cursor
    dbgTxTotal.row = 0
    dbgTxTotal.Columns(1) = CalcNetPurchase
    SendKeys "{RIGHT}", True
End Sub

Private Sub dbgTxTotal_RowColChange(LastRow As Variant, ByVal LastCol As Integer)
    ' If current columns is Title Column, advance to next column.
    If dbgTxTotal.Col = 0 Then
        SendKeys "{RIGHT}", True
    End If
    
    ' If current position is NetPurchase, advance to next column
    If dbgTxTotal.Col = 1 And dbgTxTotal.row = 0 Then
        SendKeys "{RIGHT}", True
    End If
    
    ' If current position is GrossPurchase, enable button Save
    ' and advance to next control
    If dbgTxTotal.Col = 1 And dbgTxTotal.row = 3 Then
        dbgTxTotal.Columns(1).Value = CalcGrossPurchase
        dbgTxTotal.Update
        SendKeys "{Tab}", True
    End If
End Sub

Private Sub dbgTxTotal_UnboundGetRelativeBookmark(StartLocation As Variant, ByVal OffSet As Long, NewLocation As Variant, ApproximatePosition As Long)
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
    NewLocation = GetRelativeBookmark(StartLocation, OffSet, TxTotal)
    
    ' If we are on a valid data row (i.e., not at BOF or
    ' EOF), then set the ApproximatePosition (the ordinal
    ' row number) to improve scroll bar accuracy.  We can
    ' call IndexFromBookmark to do this.
    If Not IsNull(NewLocation) Then
       ApproximatePosition = IndexFromBookmark(NewLocation, 0, TxTotal)
    End If

End Sub

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)

    ' Set Grid TXBody X-Y value
    TxBody.MaxCol = 6
    TxBody.MaxRow = 0
    ' Set Grid TxTotal X-Y value
    TxTotal.MaxCol = 2
    TxTotal.MaxRow = 4
    InitTxTotal
    ' Disable some of the buttons
    SSToolbar1.Buttons(1).Enabled = True   ' Lookup
    SSToolbar1.Buttons(2).Enabled = False   ' Save
    SSToolbar1.Buttons(5).Enabled = False   ' Print
    SSToolbar1.Buttons(6).Enabled = False   ' BarCode
    
    ' Default Edit Mode as Clear at the beginning
    MyClearMode = 0
    MyNewMode = 1
    MySaveMode = 2
    SetEditMode (MyClearMode)
    
    ' Default TxBody uses Markdown %
    dbgTxBody.Columns("Markdown $").Visible = False
    
End Sub



Private Sub CalcNetCost()
    ' Calculate the NetCost
    Dim intQty      As Integer
    Dim curUnitCost As Currency
    Dim curMarkDnD  As Currency
    Dim curMarkDnP  As Currency
    Dim curNetCost  As Currency
    
    intQty = dbgTxBody.Columns("Qty").Value
    curUnitCost = ofx_CCur(dbgTxBody.Columns("Unit Cost").Value)
    If dbgTxBody.Columns("Markdown $").Visible Then
        curMarkDnD = ofx_CCur(dbgTxBody.Columns("Markdown $").Value)
        If curMarkDnD <> 0 Then
            curMarkDnP = (ofx_CInt((curMarkDnD * 10000) / curUnitCost) / 100)
            dbgTxBody.Columns("Markdown %").Value = curMarkDnP
        Else
            dbgTxBody.Columns("Markdown %").Value = 0
        End If
    End If
    If dbgTxBody.Columns("Markdown %").Visible Then
        curMarkDnP = ofx_CCur(dbgTxBody.Columns("Markdown %").Value)
        If curMarkDnP <> 0 Then
            curMarkDnD = (ofx_CInt(curUnitCost * curMarkDnP) / 100)
            dbgTxBody.Columns("Markdown $").Value = curMarkDnD
        Else
            dbgTxBody.Columns("Markdown $").Value = 0
        End If
    End If
    curNetCost = intQty * (curUnitCost - curMarkDnD)
    dbgTxBody.Columns("Net Cost").Value = curNetCost

End Sub

Private Sub Option1_Click()
    txtLwTxNumber.Enabled = True
    txtLwPONumber.Enabled = False
    txtLwInvoiceNumber.Enabled = False
    txtLwTxNumber.SetFocus
End Sub

Private Sub Option2_Click()
    txtLwTxNumber.Enabled = False
    txtLwPONumber.Enabled = True
    txtLwInvoiceNumber.Enabled = False
    txtLwPONumber.SetFocus
End Sub

Private Sub Option3_Click()
    txtLwTxNumber.Enabled = False
    txtLwPONumber.Enabled = False
    txtLwInvoiceNumber.Enabled = True
    txtLwInvoiceNumber.SetFocus
End Sub

Private Sub SSCommand1_Click()
    If ofx_IsFormLoaded(frmSupplier) Then _
        Unload frmSupplier
    Screen.MousePointer = vbHourglass
    frmSupplier.Show vbModal
    dtcSupplier.Refresh
    dtcSupplier.UpdateControls
End Sub



' Calculate the Net Purchase by adding all Net Cost
Private Function CalcNetPurchase() As Currency

    Dim i As Integer
    Dim curNetPurchase As Currency
    
    For i = 0 To (TxBody.MaxRow - 1)
        curNetPurchase = ofx_CCur(TxBody.GridArray((TxBody.MaxCol - 1), i)) + curNetPurchase
    Next i
    CalcNetPurchase = curNetPurchase
    
End Function

' Calculate the Gross Purchase
Private Function CalcGrossPurchase() As Currency
    Dim curNetPurchase, curTotalTax, curOtherCharges As Currency
    Dim curGrossPurchase As Currency
    curNetPurchase = ofx_CCur(TxTotal.GridArray(1, 0))
    curTotalTax = ofx_CCur(TxTotal.GridArray(1, 1))
    curOtherCharges = ofx_CCur(TxTotal.GridArray(1, 2))
    CalcGrossPurchase = (curNetPurchase + curTotalTax + curOtherCharges)
End Function













' Clear TxTotal columns and set first column lable names
Private Sub InitTxTotal()
    ' Set array to all Null
    ReDim Preserve TxTotal.GridArray(0 To TxTotal.MaxCol - 1, 0 _
            To TxTotal.MaxRow - 1)
    Dim i, j As Integer
    For i = 0 To (TxTotal.MaxCol - 1)
        For j = 0 To (TxTotal.MaxRow - 1)
            TxTotal.GridArray(i, j) = Null
        Next j
    Next i
    
    ' Set first cloumn title names
    TxTotal.GridArray(0, 0) = "Net Purchase"
    TxTotal.GridArray(0, 1) = "Total Tax"
    TxTotal.GridArray(0, 2) = "Other Charges"
    TxTotal.GridArray(0, 3) = "Gross Purchase"
    
    ' Set first column to title column style
    Dim MyStyle As Style
    Set MyStyle = dbgTxTotal.Styles("TitleColumn")
    dbgTxTotal.Columns(0).Style = MyStyle
End Sub

Private Function CalcTotalQty() As Integer
    Dim i As Integer
    Dim intTotalQty As Integer

    For i = 0 To (TxBody.MaxRow - 1)
        intTotalQty = ofx_CInt(TxBody.GridArray(1, i)) + intTotalQty
    Next i
    CalcTotalQty = intTotalQty
End Function

Private Sub SSCommand2_Click()
    If ofx_IsFormLoaded(frmStaff) Then _
        Unload frmStaff
    Screen.MousePointer = vbHourglass
    frmStaff.Show vbModal
    dtcStaff.Refresh
    dtcStaff.UpdateControls
End Sub

Private Sub SSCommand3_Click()
    Dim strTxNumber, strPrefix As String
    
    strTxNumber = ofx_CStr(txtLwTxNumber.Text)
    
    fraLookupWizard.Visible = False
    
    If Option1.Value = True Then
        RptTxNumberFrom = strTxNumber
        strPrefix = Left(strTxNumber, 2)
        Call PrintStockTrans(strPrefix, 1, 0)
    ElseIf Option2.Value = True Then
        ofx_DoMessageBox "Function not yet available"
    ElseIf Option3.Value = True Then
        ofx_DoMessageBox "Function not yet available"
    End If
End Sub

Private Sub SSCommand4_Click()
    fraLookupWizard.Visible = False
End Sub

Private Sub SSCommand5_Click()
        Dim RetVal As Variant
        RetVal = Shell("Calc.Exe", 1)
End Sub

Private Sub SSCommand6_Click()
    ' Change TxBody to Markdown %
    dbgTxBody.Columns("Markdown $").Visible = False
    dbgTxBody.Columns("Markdown %").Visible = True
End Sub

Private Sub SSCommand7_Click()
    ' Change TxBody to Markdown $
    dbgTxBody.Columns("Markdown $").Visible = True
    dbgTxBody.Columns("Markdown %").Visible = False
End Sub

Private Sub SSCommand8_Click()
    If ofx_IsFormLoaded(frmInfoSupplier) Then _
        Unload frmInfoSupplier
    Screen.MousePointer = vbHourglass
    frmInfoSupplier.Show vbModal
'    dbgTxBody.Columns("SKU").Value = Clipboard.GetText
End Sub

' Buttons: New, Lookup, Save, Clear, Close. Print, BarCode, Find SKU, Add SKU.
Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)
    Dim strPrefix As String
    
    Select Case ToolID
    Case "ID_New"
        SetEditMode (MyNewMode)
        ClearAllEntries
    Case "ID_Lookup"
        fraLookupWizard.Visible = True
        fraLookupWizard.ZOrder
    Case "ID_Save"
        SetEditMode (MySaveMode)
        SaveEntries
    Case "ID_Clear"
        SetEditMode (MyClearMode)
        ClearAllEntries
    Case "ID_Close"
        Unload Me
    Case "ID_Print"
        RptTxNumberFrom = MyTxNumber
        strPrefix = Left(MyTxNumber, 2)
        Call PrintStockTrans(strPrefix, 1, 0)
    Case "ID_BarCode"
        RptTxNumberFrom = MyTxNumber
        Call PrintBarCode(1, 1)
        SSToolbar1.Buttons(6).Enabled = False   ' Print once only
    Case "ID_FindSKU"
        Clipboard.Clear
        If ofx_IsFormLoaded(frmInfoSKU) Then _
            Unload frmInfoSKU
        Screen.MousePointer = vbHourglass
        frmInfoSKU.Show vbModal
        dbgTxBody.Columns("SKU").Value = Clipboard.GetText
    Case "ID_AddSKU"
        Clipboard.Clear
        If ofx_IsFormLoaded(frmInvt) Then _
            Unload frmInvt
        Screen.MousePointer = vbHourglass
        frmInvt.Show vbModal
        dbgTxBody.Columns("SKU").Value = Clipboard.GetText
    End Select
End Sub



' This subroutine would clear all the current entries
Private Sub ClearAllEntries()
    Dim i, j As Integer
    
    ' Clear TxHeader
    dbcStaffFullName.Text = ""
    txtPONumber.Text = ""
    dbcSupplierName.Text = ""
    txtInvoiceNumber.Text = ""
    txtParticular.Text = ""
    txtTotalQty.Text = ""
    
    ' Clear TxBody
    For i = 0 To (TxBody.MaxCol - 1)
        For j = 0 To (TxBody.MaxRow - 1)
            TxBody.GridArray(i, j) = ""
        Next j
    Next i
    dbgTxBody.Refresh
    
    ' Clear TxTotal, keep cloumn 0
    For j = 0 To (TxTotal.MaxRow - 1)
        TxTotal.GridArray(1, j) = ""
    Next j
    dbgTxTotal.Refresh
    
    ' Reset Current Tx Number to Null
    MyTxNumber = ""
    
    ' Return focus to first entry field
    calTxDate.SetFocus
End Sub


Private Sub SaveEntries()

    ' Varify some important entries
    ' If anyone failed, stop update
    If Not IsFound("Staff", "StaffFullName", dbcStaffFullName.Text, vbYes) Or _
       Not IsFound("Supplier", "SupplierName", dbcSupplierName.Text, vbYes) Then
        SetEditMode (MyNewMode)
        Exit Sub
    End If
    
    ' Start prepare to update entries
    ' Updates the TxHeader, TxDetails, and TxSalePerson
    Screen.MousePointer = vbHourglass
    Dim MyControlNumber As String
    Dim curNetPurchase, curTotalTax, curOtherCharges, curGrossPurchase As Currency
    Dim i As Integer
    Dim MyWS As Workspace
    Dim myDB As Database
    Dim TxHeader, TxDetails, TxSalePerson As Recordset
    Dim MyCriteria As String
    MyCriteria = "SKU = '" & " " & "'"      ' Set the criteria.
    MyControlNumber = GetNextControlNumber
    MyTxNumber = GetNextTxNumber("SR")
    curNetPurchase = ofx_CCur(TxTotal.GridArray(1, 0))
    curTotalTax = ofx_CCur(TxTotal.GridArray(1, 1))
    curOtherCharges = ofx_CCur(TxTotal.GridArray(1, 2))
    curGrossPurchase = ofx_CCur(TxTotal.GridArray(1, 3))
    
    '
    ' Write entries into Tx files and pass control to OLTP for posting
    '
    Set MyWS = Workspaces(0)
    Set myDB = MyWS.OpenDatabase("SynergyV.mdb")                           ' Open database
    Set TxHeader = myDB.OpenRecordset("TxHeader", dbOpenTable, dbAppendOnly)      ' Open table for append only
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenTable, dbAppendOnly)    ' Open table for append only
    Set TxSalePerson = myDB.OpenRecordset("TxSalePerson", dbOpenTable, dbAppendOnly)      ' Open table for append only
    '
    'On Error GoTo RollbackSaveEntries
    MyWS.BeginTrans
    ' Write TxHeader
    TxHeader.AddNew
    TxHeader!ControlNumber = MyControlNumber
    TxHeader!TxType = Left(MyTxNumber, 2)
    TxHeader!TxNumber = MyTxNumber
    TxHeader!DateOfEntry = calTxDate.Text
    TxHeader!DateOfCreation = Now
    TxHeader!RefNumber = txtInvoiceNumber.Text
    TxHeader!TrackingNumber = txtPONumber.Text
    TxHeader!Particulars = txtParticular.Text
    TxHeader!SupplierCode = dbcSupplierName.BoundText
    TxHeader!TotalCost = curNetPurchase
    TxHeader!TaxA = curTotalTax
    TxHeader!OtherCharges = curOtherCharges
    TxHeader!GrossSale = curGrossPurchase
    TxHeader!TotalAmount = curGrossPurchase
    TxHeader!TotalQty = ofx_CInt(txtTotalQty.Text)
    TxHeader.Update
    ' Write TxSalePerson
    TxSalePerson.AddNew
    TxSalePerson!TxNumber = MyTxNumber
    TxSalePerson!SalesRowNo = 1
    TxSalePerson!StaffCode = dbcStaffFullName.BoundText
    TxSalePerson.Update
    ' Write TxDetails
    For i = 0 To TxBody.MaxRow - 1
        If TxBody.GridArray(0, i) <> "" Then
            TxDetails.AddNew
            TxDetails!ControlNumber = MyControlNumber
            TxDetails!TxType = Left(MyTxNumber, 2)
            TxDetails!TxNumber = MyTxNumber
            TxDetails!DateOfEntry = calTxDate.Text
            TxDetails!RowNo = (i + 1)
            TxDetails!SKU = TxBody.GridArray(0, i)
            TxDetails!Qty = ofx_CInt(TxBody.GridArray(1, i))
            TxDetails!UnitCost = ofx_CCur(TxBody.GridArray(2, i))
            TxDetails!MarkDownAmount = ofx_CCur(TxBody.GridArray(3, i))
            TxDetails!MarkDownPercent = ofx_CSng(TxBody.GridArray(4, i))
            TxDetails!Amount = ofx_CCur(TxBody.GridArray(5, i))
            TxDetails.Update
        End If
    Next i
    '
    MyWS.CommitTrans
    
    ' Activate OLTP to post transaction
    OLTP_IC (MyTxNumber)
    
    '
    Screen.MousePointer = vbDefault
    ofx_DoMessageBox "Save is done." & Chr$(13) & _
                     "Please stamp your document with the Tx Number: " & MyTxNumber & Chr(13) & _
                     "for later reference."
    Exit Sub

RollbackSaveEntries:
    MyWS.Rollback
    Screen.MousePointer = vbDefault
    ofx_DoMessageBox "Error Detected.  Current Save was aborted."
    Exit Sub
End Sub

Private Sub txtLwInvoiceNumber_Change()
    txtLwInvoiceNumber.SelStart = 0
    txtLwInvoiceNumber.SelLength = Len(txtLwInvoiceNumber.Text)
End Sub

Private Sub txtLwPONumber_GotFocus()
    txtLwPONumber.SelStart = 0
    txtLwPONumber.SelLength = Len(txtLwPONumber.Text)
End Sub


Private Sub txtLwTxNumber_GotFocus()
    ' Auto-select the whole field
    txtLwTxNumber.SelStart = 0
    txtLwTxNumber.SelLength = Len(txtLwTxNumber.Text)
End Sub



Private Sub SetEditMode(CurrentMode As Byte)
    Select Case CurrentMode
    Case MyClearMode
        SSToolbar1.Buttons(2).Enabled = False   ' Button Save
        SSToolbar1.Buttons(3).Enabled = False   ' Button Clear
        SSToolbar1.Buttons(5).Enabled = False   ' Button Print
        SSToolbar1.Buttons(6).Enabled = False   ' Button Bar Code
    Case MyNewMode
        SSToolbar1.Buttons(2).Enabled = True    ' Button Save
        SSToolbar1.Buttons(3).Enabled = True    ' Button Clear
        SSToolbar1.Buttons(5).Enabled = False   ' Button Print
        SSToolbar1.Buttons(6).Enabled = False   ' Button Bar Code
    Case MySaveMode
        SSToolbar1.Buttons(2).Enabled = False   ' Button Save
        SSToolbar1.Buttons(3).Enabled = True    ' Button Clear
        SSToolbar1.Buttons(5).Enabled = True    ' Button Print
        SSToolbar1.Buttons(6).Enabled = True    ' Button Bar Code
    End Select
    MyEditMode = CurrentMode
End Sub




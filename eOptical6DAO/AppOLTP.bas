Attribute VB_Name = "AppOLTP"
Option Explicit

' OLTP for Inventory Control
' Applies to:
'  Stock Received
'  Stock Rejected
'  Stock Adjustment
Public Sub OLTP_IC(strTxNumber As String)
    Dim strTxType As String
    
    strTxType = Left(strTxNumber, 2)
    
    If strTxType = "SJ" Then
       ' Ignor Supplier Summary
    Else
        Call PromptStatusBar(frmMain.statMain, "Posting STK Supplier Summary")
        OLTP_IC_SupplierSummary (strTxNumber)       ' Post the Supplier Summary
    End If
    Call PromptStatusBar(frmMain.statMain, "Posting STK Inventory Summary")
    OLTP_IC_InvtSummary (strTxNumber)           ' Post the Inventory Summary
    Call PromptStatusBar(frmMain.statMain, "Posting STK Inventory Lot")
    OLTP_IC_InvtLotRecord (strTxNumber)         ' Post the Inventory Lot Record
    Call PromptStatusBar(frmMain.statMain, "Posting STK Inventory")
    OLTP_IC_Inventory (strTxNumber)             ' Post the Inventory Record
    Call PromptStatusBar(frmMain.statMain, "Posting STK Category Summary")
    OLTP_IC_Category (strTxNumber)              ' Post the Category Summary Record
    Call PromptStatusBar(frmMain.statMain, "Posting STK Class Summary")
    OLTP_IC_Class (strTxNumber)                 ' Post the Class Summary Record
    Call PromptStatusBar(frmMain.statMain, "Posting STK Department Summary")
    OLTP_IC_Dept (strTxNumber)                  ' Post the Dept Summary Record
    If strTxType = "SR" Then
        Call PromptStatusBar(frmMain.statMain, "Posting Barcode Pool")
        OLTP_IC_BarCode (strTxNumber)           ' Post the BarCode Pool
    End If

    Call PromptStatusBar(frmMain.statMain, pyUserName)
End Sub

' Post IC Transaction to the SupplierSummary table
' One Transaction each call
Private Sub OLTP_IC_SupplierSummary(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim TxHeader, TargetRS As Recordset
    Dim MyCriteria As String
    MyCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    If strTxType = "SJ" Then Exit Sub   ' Ignor Stock Adjustment
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxHeader = myDB.OpenRecordset("TxHeader", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxHeader.FindFirst MyCriteria       ' Find the record
    If TxHeader.NoMatch Then            ' Terminate process if record is not found.
        TxHeader.Close                  '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    MyCriteria = "SupplierCode = '" & TxHeader!SupplierCode & "' And "
    MyCriteria = MyCriteria & "Year = " & Year(TxHeader!DateOfEntry) & " And "
    MyCriteria = MyCriteria & "Month = " & Month(TxHeader!DateOfEntry)
    Set TargetRS = myDB.OpenRecordset("SupplierSummary", dbOpenDynaset)
    TargetRS.FindFirst MyCriteria
    If TargetRS.NoMatch Then
        TargetRS.AddNew
        TargetRS!SupplierCode = TxHeader!SupplierCode
        TargetRS!Year = Year(TxHeader!DateOfEntry)
        TargetRS!Month = Month(TxHeader!DateOfEntry)
        TargetRS!FirstDateOfMonth = DateSerial(Year(TxHeader!DateOfEntry), Month(TxHeader!DateOfEntry), 1)
    Else
        TargetRS.Edit
    End If
    Select Case strTxType
    Case "SR"       ' Stock Received from Supplier
        TargetRS!QtyPurchased = TargetRS!QtyPurchased + TxHeader!TotalQty
        TargetRS!AmtPurchased = TargetRS!AmtPurchased + TxHeader!TotalAmount
    Case "RJ"       ' Stock Rejected to Supplier
        TargetRS!QtyRejected = TargetRS!QtyRejected + TxHeader!TotalQty
        TargetRS!AmtRejected = TargetRS!AmtRejected + TxHeader!TotalAmount
    Case "SJ"       ' Stock Adjustment (decr/incr)
        ' Do nothing
    End Select
    TargetRS.Update
    TargetRS.Close
    TxHeader.Close                      ' Close table.
    myDB.Close                          ' Close database.

End Sub

' Post IC Transaction to the InventorySummary table
' Multilines per Transaction
Private Sub OLTP_IC_InvtSummary(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxDetails.FindFirst PriCriteria      ' Find the record
    If TxDetails.NoMatch Then           ' Terminate process if record is not found.
        TxDetails.Close                 '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    Set TargetRS = myDB.OpenRecordset("InvtSummary", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    SecCriteria = "SKU = '" & TxDetails!SKU & "' And "
    SecCriteria = SecCriteria & "Year = " & Year(TxDetails!DateOfEntry) & " And "
    SecCriteria = SecCriteria & "Month = " & Month(TxDetails!DateOfEntry)
    TargetRS.FindFirst SecCriteria
    If TargetRS.NoMatch Then
        TargetRS.AddNew
        TargetRS!SKU = TxDetails!SKU
        TargetRS!Year = Year(TxDetails!DateOfEntry)
        TargetRS!Month = Month(TxDetails!DateOfEntry)
        TargetRS!FirstDateOfMonth = DateSerial(Year(TxDetails!DateOfEntry), Month(TxDetails!DateOfEntry), 1)
    Else
        TargetRS.Edit
    End If
    Select Case strTxType
    Case "SR"       ' Stock Received from Supplier
        TargetRS!qtyCD = TargetRS!qtyCD + TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD + TxDetails!Amount
        TargetRS!QtyPurchased = TargetRS!QtyPurchased + TxDetails!Qty
        TargetRS!AmtPurchased = TargetRS!AmtPurchased + TxDetails!Amount
    Case "RJ"       ' Stock Rejected to Supplier
        TargetRS!qtyCD = TargetRS!qtyCD + TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD + TxDetails!Amount
        TargetRS!QtyRejected = TargetRS!QtyRejected + TxDetails!Qty
        TargetRS!AmtRejected = TargetRS!AmtRejected + TxDetails!Amount
    Case "SJ"       ' Stock Adjustment (decr/incr)
        TargetRS!qtyCD = TargetRS!qtyCD + TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD + TxDetails!Amount
        If TxDetails!Qty < 0 Then
            TargetRS!QtyAdjDecr = TargetRS!QtyAdjDecr + TxDetails!Qty
            TargetRS!AmtAdjDecr = TargetRS!AmtAdjDecr + TxDetails!Amount
        Else
            TargetRS!QtyAdjIncr = TargetRS!QtyAdjIncr + TxDetails!Qty
            TargetRS!AmtAdjIncr = TargetRS!AmtAdjIncr + TxDetails!Amount
        End If
    End Select
    TargetRS.Update
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    TxDetails.Close                      ' Close table.
    myDB.Close                          ' Close database.

End Sub


Private Sub OLTP_IC_InvtLotRecord(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim Inventory, Category As Recordset
    Dim TxHeader, TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxHeader = myDB.OpenRecordset("TxHeader", dbOpenDynaset, dbReadOnly)      ' Open table read only
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxHeader.FindFirst PriCriteria      ' Find the record
    If TxHeader.NoMatch Then            ' Terminate process if record is not found.
        TxHeader.Close                  '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    TxDetails.FindFirst PriCriteria     ' Find the record. Assume always found
    Set Inventory = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)
    Set Category = myDB.OpenRecordset("Category", dbOpenDynaset, dbReadOnly)
    Set TargetRS = myDB.OpenRecordset("InvtLotRecord", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    SecCriteria = "SKU = '" & TxDetails!SKU & "'"
    Inventory.FindFirst SecCriteria     ' Assume always found
    SecCriteria = "DepartmentCode = '" & Inventory!DepartmentCode & "' And " & _
                  "ClassCode = '" & Inventory!ClassCode & "' And " & _
                  "CategoryCode = '" & Inventory!CategoryCode & "'"
    Category.FindFirst SecCriteria      ' Assume always found
    Select Case strTxType
    Case "SR"       ' Stock Received from Supplier
        ' 20030725 Allow duplicated SKU within same transaction
        SecCriteria = "SKU = '" & TxDetails!SKU & "' AND LotNo = '" & TxHeader!ControlNumber & "'"
        TargetRS.FindFirst SecCriteria
        If TargetRS.NoMatch Then
            TargetRS.AddNew
            TargetRS!SKU = TxDetails!SKU
            TargetRS!LotNo = TxHeader!ControlNumber
            TargetRS!DateReceived = TxHeader!DateOfEntry
            TargetRS!SupplierCode = TxHeader!SupplierCode
            TargetRS!QtyPurchased = TxDetails!Qty
            TargetRS!QtyOnHand = TxDetails!Qty
            TargetRS!UnitAmountPurchased = TxDetails!UnitCost - TxDetails!MarkDownAmount
            TargetRS!TotalAmountPurchased = TxDetails!Amount
        Else
            TargetRS.Edit
'            TargetRS!SKU = TxDetails!SKU
'            TargetRS!LotNo = TxHeader!ControlNumber
'            TargetRS!DateReceived = TxHeader!DateOfEntry
'            TargetRS!SupplierCode = TxHeader!SupplierCode
            TargetRS!QtyPurchased = TargetRS!QtyPurchased + TxDetails!Qty
            TargetRS!QtyOnHand = TargetRS!QtyOnHand + TxDetails!Qty
'            TargetRS!UnitAmountPurchased = TxDetails!UnitCost - TxDetails!MarkDownAmount
            TargetRS!TotalAmountPurchased = TargetRS!TotalAmountPurchased + TxDetails!Amount
        End If
    Case Else       ' Stock Rejected to Supplier Or Stock Adjustment (decr/incr)
        SecCriteria = "SKU = '" & TxDetails!SKU & "'"
        Select Case Category!CostingMethod
        Case "2"    ' LIFO
            TargetRS.FindLast SecCriteria
        Case Else   ' Average & FIFO
            TargetRS.FindFirst SecCriteria
        End Select
        If TargetRS.NoMatch Then
            TargetRS.AddNew
            TargetRS!SKU = TxDetails!SKU
            TargetRS!LotNo = TxHeader!ControlNumber
            TargetRS!DateReceived = TxHeader!DateOfEntry
            Select Case strTxType
                Case "RJ"   ' Reject to Supplier
                    TargetRS!SupplierCode = TxHeader!SupplierCode
                Case "SJ"   ' Adjustment
                    TargetRS!SupplierCode = Inventory!SupplierCode
            End Select
            TargetRS!QtyPurchased = TxDetails!Qty
            TargetRS!QtyOnHand = TxDetails!Qty
            TargetRS!UnitAmountPurchased = TxDetails!UnitCost - TxDetails!MarkDownAmount
            TargetRS!TotalAmountPurchased = TxDetails!Amount
        Else
            TargetRS.Edit
            TargetRS!QtyUsed = TargetRS!QtyUsed + TxDetails!Qty         ' TxDetails!Qty is -ve
            TargetRS!QtyOnHand = TargetRS!QtyOnHand + TxDetails!Qty
        End If
    End Select
    TargetRS.Update
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    Category.Close
    Inventory.Close
    TxDetails.Close                     ' Close table.
    TxHeader.Close                      ' Close table.
    myDB.Close                          ' Close database.

End Sub

Private Sub OLTP_IC_Inventory(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxDetails.FindFirst PriCriteria     ' Find the record. Assume always found
    If TxDetails.NoMatch Then           ' Terminate process if record is not found.
        TxDetails.Close                 '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    Set TargetRS = myDB.OpenRecordset("Inventory Query", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    SecCriteria = "SKU = '" & TxDetails!SKU & "'"
    TargetRS.FindFirst SecCriteria      ' Assume always found
    TargetRS.Edit
    Select Case strTxType
    Case "SR"       ' Stock Received from Supplier
        If (TargetRS!QtyTotalOnhand + TxDetails!Qty) <> 0 And TargetRS!AverageCost > 0 Then
            TargetRS!AverageCost = (TxDetails!Amount + _
                                    TargetRS!AverageCost * TargetRS!QtyTotalOnhand) / _
                                   (TargetRS!QtyTotalOnhand + TxDetails!Qty)
        Else
            TargetRS!AverageCost = TxDetails!UnitCost - TxDetails!MarkDownAmount
        End If
        TargetRS!AverageCost = Abs(TargetRS!AverageCost)
        '
        If (TargetRS!QtyTotalOnhand + TxDetails!Qty) <> 0 And TargetRS!LeastSellingPrice > 0 Then
            TargetRS!LeastSellingPrice = ((TxDetails!UnitLSP * TxDetails!Qty) + _
                                    TargetRS!LeastSellingPrice * TargetRS!QtyTotalOnhand) / _
                                   (TargetRS!QtyTotalOnhand + TxDetails!Qty)
        Else
            TargetRS!LeastSellingPrice = TxDetails!UnitLSP
        End If
        TargetRS!LeastSellingPrice = Abs(TargetRS!LeastSellingPrice)
        '
        TargetRS!QtyTotalOnhand = TargetRS!QtyTotalOnhand + TxDetails!Qty
        If TargetRS!QtyPurchaseOrder > TxDetails!Qty Then
            TargetRS!QtyPurchaseOrder = TargetRS!QtyPurchaseOrder + TxDetails!Qty
        Else
            TargetRS!QtyPurchaseOrder = 0
        End If
        If IsNull(TargetRS!DateLastReceived) Or _
                  TargetRS!DateLastReceived < TxDetails!DateOfEntry Then
            TargetRS!DateLastReceived = TxDetails!DateOfEntry
        End If
    Case "RJ"       ' Stock Rejected to Supplier
        TargetRS!QtyTotalOnhand = TargetRS!QtyTotalOnhand + TxDetails!Qty   ' TxDetails!Qty is -ve
        If IsNull(TargetRS!DateLastIssued) Or _
                  TargetRS!DateLastIssued < TxDetails!DateOfEntry Then
            TargetRS!DateLastIssued = TxDetails!DateOfEntry
        End If
    Case "SJ"       ' Stock Adjustment (decr/incr)
        TargetRS!QtyTotalOnhand = TargetRS!QtyTotalOnhand + TxDetails!Qty
    End Select
    TargetRS.Update
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    TxDetails.Close                     ' Close table.
    myDB.Close                          ' Close database.

End Sub

Private Sub OLTP_IC_Category(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim Inventory, TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxDetails.FindFirst PriCriteria     ' Find the record. Assume always found
    If TxDetails.NoMatch Then            ' Terminate process if record is not found.
        TxDetails.Close                  '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    Set Inventory = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)
    Set TargetRS = myDB.OpenRecordset("CategorySummary", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    SecCriteria = "SKU = '" & TxDetails!SKU & "'"
    Inventory.FindFirst SecCriteria     ' Assume always found
    SecCriteria = "DepartmentCode = '" & Inventory!DepartmentCode & "' And " & _
                  "ClassCode = '" & Inventory!ClassCode & "' And " & _
                  "CategoryCode = '" & Inventory!CategoryCode & "' And " & _
                  "Year = " & Year(TxDetails!DateOfEntry) & " And " & _
                  "Month = " & Month(TxDetails!DateOfEntry)
    TargetRS.FindFirst SecCriteria
    If TargetRS.NoMatch Then
        TargetRS.AddNew
        TargetRS!DepartmentCode = Inventory!DepartmentCode
        TargetRS!ClassCode = Inventory!ClassCode
        TargetRS!CategoryCode = Inventory!CategoryCode
        TargetRS!Year = Year(TxDetails!DateOfEntry)
        TargetRS!Month = Month(TxDetails!DateOfEntry)
        TargetRS!FirstDateOfMonth = DateSerial(Year(TxDetails!DateOfEntry), Month(TxDetails!DateOfEntry), 1)
    Else
        TargetRS.Edit
    End If
    Select Case strTxType
    Case "SR"       ' Stock Received from Supplier
        TargetRS!qtyCD = TargetRS!qtyCD + TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD + TxDetails!Amount
        TargetRS!QtyPurchased = TargetRS!QtyPurchased + TxDetails!Qty
        TargetRS!AmtPurchased = TargetRS!AmtPurchased + TxDetails!Amount
    Case "RJ"       ' Stock Rejected to Supplier
        TargetRS!qtyCD = TargetRS!qtyCD + TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD + TxDetails!Amount
        TargetRS!QtyRejected = TargetRS!QtyRejected + TxDetails!Qty
        TargetRS!AmtRejected = TargetRS!AmtRejected + TxDetails!Amount
    Case "SJ"       ' Stock Adjustment (decr/incr)
        TargetRS!qtyCD = TargetRS!qtyCD + TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD + TxDetails!Amount
        If TxDetails!Qty < 0 Then
            TargetRS!QtyAdjustedDecr = TargetRS!QtyAdjustedDecr + TxDetails!Qty
            TargetRS!AmtAdjustedDecr = TargetRS!AmtAdjustedDecr + TxDetails!Amount
        Else
            TargetRS!QtyAdjustedIncr = TargetRS!QtyAdjustedIncr + TxDetails!Qty
            TargetRS!AmtAdjustedIncr = TargetRS!AmtAdjustedIncr + TxDetails!Amount
        End If
    End Select
    TargetRS.Update
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    Inventory.Close
    TxDetails.Close                     ' Close table.
    myDB.Close                          ' Close database.

End Sub

Private Sub OLTP_IC_Class(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim Inventory, TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxDetails.FindFirst PriCriteria     ' Find the record. Assume always found
    If TxDetails.NoMatch Then            ' Terminate process if record is not found.
        TxDetails.Close                  '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    Set Inventory = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)
    Set TargetRS = myDB.OpenRecordset("ClassSummary", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    SecCriteria = "SKU = '" & TxDetails!SKU & "'"
    Inventory.FindFirst SecCriteria     ' Assume always found
    SecCriteria = "DepartmentCode = '" & Inventory!DepartmentCode & "' And " & _
                  "ClassCode = '" & Inventory!ClassCode & "' And " & _
                  "Year = " & Year(TxDetails!DateOfEntry) & " And " & _
                  "Month = " & Month(TxDetails!DateOfEntry)
    TargetRS.FindFirst SecCriteria
    If TargetRS.NoMatch Then
        TargetRS.AddNew
        TargetRS!DepartmentCode = Inventory!DepartmentCode
        TargetRS!ClassCode = Inventory!ClassCode
        TargetRS!Year = Year(TxDetails!DateOfEntry)
        TargetRS!Month = Month(TxDetails!DateOfEntry)
        TargetRS!FirstDateOfMonth = DateSerial(Year(TxDetails!DateOfEntry), Month(TxDetails!DateOfEntry), 1)
    Else
        TargetRS.Edit
    End If
    Select Case strTxType
    Case "SR"       ' Stock Received from Supplier
        TargetRS!qtyCD = TargetRS!qtyCD + TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD + TxDetails!Amount
        TargetRS!QtyPurchased = TargetRS!QtyPurchased + TxDetails!Qty
        TargetRS!AmtPurchased = TargetRS!AmtPurchased + TxDetails!Amount
    Case "RJ"       ' Stock Rejected to Supplier
        TargetRS!qtyCD = TargetRS!qtyCD + TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD + TxDetails!Amount
        TargetRS!QtyRejected = TargetRS!QtyRejected + TxDetails!Qty
        TargetRS!AmtRejected = TargetRS!AmtRejected + TxDetails!Amount
    Case "SJ"       ' Stock Adjustment (decr/incr)
        TargetRS!qtyCD = TargetRS!qtyCD + TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD + TxDetails!Amount
        If TxDetails!Qty < 0 Then
            TargetRS!QtyAdjustedDecr = TargetRS!QtyAdjustedDecr + TxDetails!Qty
            TargetRS!AmtAdjustedDecr = TargetRS!AmtAdjustedDecr + TxDetails!Amount
        Else
            TargetRS!QtyAdjustedIncr = TargetRS!QtyAdjustedIncr + TxDetails!Qty
            TargetRS!AmtAdjustedIncr = TargetRS!AmtAdjustedIncr + TxDetails!Amount
        End If
    End Select
    TargetRS.Update
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    Inventory.Close
    TxDetails.Close                     ' Close table.
    myDB.Close                          ' Close database.

End Sub

Private Sub OLTP_IC_Dept(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim Inventory, TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxDetails.FindFirst PriCriteria     ' Find the record. Assume always found
    If TxDetails.NoMatch Then            ' Terminate process if record is not found.
        TxDetails.Close                  '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    Set Inventory = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)
    Set TargetRS = myDB.OpenRecordset("DeptSummary", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    SecCriteria = "SKU = '" & TxDetails!SKU & "'"
    Inventory.FindFirst SecCriteria     ' Assume always found
    SecCriteria = "DepartmentCode = '" & Inventory!DepartmentCode & "' And " & _
                  "Year = " & Year(TxDetails!DateOfEntry) & " And " & _
                  "Month = " & Month(TxDetails!DateOfEntry)
    TargetRS.FindFirst SecCriteria
    If TargetRS.NoMatch Then
        TargetRS.AddNew
        TargetRS!DepartmentCode = Inventory!DepartmentCode
        TargetRS!Year = Year(TxDetails!DateOfEntry)
        TargetRS!Month = Month(TxDetails!DateOfEntry)
        TargetRS!FirstDateOfMonth = DateSerial(Year(TxDetails!DateOfEntry), Month(TxDetails!DateOfEntry), 1)
    Else
        TargetRS.Edit
    End If
    Select Case strTxType
    Case "SR"       ' Stock Received from Supplier
        TargetRS!qtyCD = TargetRS!qtyCD + TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD + TxDetails!Amount
        TargetRS!QtyPurchased = TargetRS!QtyPurchased + TxDetails!Qty
        TargetRS!AmtPurchased = TargetRS!AmtPurchased + TxDetails!Amount
    Case "RJ"       ' Stock Rejected to Supplier
        TargetRS!qtyCD = TargetRS!qtyCD + TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD + TxDetails!Amount
        TargetRS!QtyRejected = TargetRS!QtyRejected + TxDetails!Qty
        TargetRS!AmtRejected = TargetRS!AmtRejected + TxDetails!Amount
    Case "SJ"       ' Stock Adjustment (decr/incr)
        TargetRS!qtyCD = TargetRS!qtyCD + TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD + TxDetails!Amount
        If TxDetails!Qty < 0 Then
            TargetRS!QtyAdjustedDecr = TargetRS!QtyAdjustedDecr + TxDetails!Qty
            TargetRS!AmtAdjustedDecr = TargetRS!AmtAdjustedDecr + TxDetails!Amount
        Else
            TargetRS!QtyAdjustedIncr = TargetRS!QtyAdjustedIncr + TxDetails!Qty
            TargetRS!AmtAdjustedIncr = TargetRS!AmtAdjustedIncr + TxDetails!Amount
        End If
    End Select
    TargetRS.Update
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    Inventory.Close
    TxDetails.Close                     ' Close table.
    myDB.Close                          ' Close database.

End Sub

Private Sub OLTP_IC_BarCode(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    Dim i As Integer
    
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxDetails.FindFirst PriCriteria     ' Find the record. Assume always found
    If TxDetails.NoMatch Then            ' Terminate process if record is not found.
        TxDetails.Close                  '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    Set TargetRS = myDB.OpenRecordset("BarCodePool", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    For i = 1 To TxDetails!Qty
        TargetRS.AddNew
        TargetRS!TxNumber = strTxNumber
        TargetRS!DateOfEntry = TxDetails!DateOfEntry
        TargetRS!SKU = TxDetails!SKU
        TargetRS!Qty = 1                ' Default for CyrstalReports, else = TxDetails!Qty
        TargetRS.Update
    Next
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    TxDetails.Close                     ' Close table.
    myDB.Close                          ' Close database.

End Sub


' OLTP for Point-of-Sale
' Applies to:
'  Sales Order Billing (Retail Invoicing)
Public Sub OLTP_PoS(strTxNumber As String)
    OLTP_PoS_CustomerSummary (strTxNumber)       ' Post the Supplier Summary
    OLTP_PoS_InvtSummary (strTxNumber)           ' Post the Inventory Summary
    OLTP_PoS_InvtLotRecord (strTxNumber)         ' Post the Inventory Lot Record
    OLTP_PoS_Inventory (strTxNumber)             ' Post the Inventory Record
    OLTP_PoS_Category (strTxNumber)              ' Post the Category Summary Record
    OLTP_PoS_Class (strTxNumber)                 ' Post the Class Summary Record
    OLTP_PoS_Dept (strTxNumber)                  ' Post the Dept Summary Record
End Sub

Public Sub OLTP_PoS_CustomerSummary(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim TxHeader, TargetRS As Recordset
    Dim MyCriteria As String
    MyCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    If strTxType = "WC" Or _
       strTxType = "WR" Then
        Exit Sub    ' Ignor Customer Summary
    End If
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxHeader = myDB.OpenRecordset("TxHeader", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxHeader.FindFirst MyCriteria       ' Find the record
    If TxHeader.NoMatch Then            ' Terminate process if record is not found.
        TxHeader.Close                  '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    MyCriteria = "CustomerID = " & TxHeader!CustomerID
    Set TargetRS = myDB.OpenRecordset("CustomerAccounts", dbOpenDynaset)
    TargetRS.FindFirst MyCriteria
    If TargetRS.NoMatch Then
        TargetRS.AddNew
        TargetRS!CustomerID = TxHeader!CustomerID
        TargetRS!JointDate = TxHeader!DateOfEntry
        '   WA edited on Nov 12 1997
        TargetRS!LastPurchaseDate = TxHeader!DateOfEntry
    Else
        TargetRS.Edit
    End If
    Select Case strTxType
    Case "RC"       ' Retail Invoice
        TargetRS!YTDAmtPurchased = TargetRS!YTDAmtPurchased + TxHeader!TotalSale
        '   WA edited on Nov 12 1997
        If (TargetRS!LastPurchaseDate > TxHeader!DateOfEntry) Then
            TargetRS!LastPurchaseDate = TxHeader!DateOfEntry
        End If
    Case "RS"       ' Customer Refund
        TargetRS!TTLAmtRefund = TargetRS!TTLAmtRefund + TxHeader!TotalSale
    End Select
    TargetRS.Update
    TargetRS.Close
    TxHeader.Close                      ' Close table.
    myDB.Close                          ' Close database.
End Sub

Public Sub OLTP_PoS_InvtSummary(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxDetails.FindFirst PriCriteria      ' Find the record
    If TxDetails.NoMatch Then           ' Terminate process if record is not found.
        TxDetails.Close                 '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    Set TargetRS = myDB.OpenRecordset("InvtSummary", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    SecCriteria = "SKU = '" & TxDetails!SKU & "' And "
    SecCriteria = SecCriteria & "Year = " & Year(TxDetails!DateOfEntry) & " And "
    SecCriteria = SecCriteria & "Month = " & Month(TxDetails!DateOfEntry)
    TargetRS.FindFirst SecCriteria
    If TargetRS.NoMatch Then
        TargetRS.AddNew
        TargetRS!SKU = TxDetails!SKU
        TargetRS!Year = Year(TxDetails!DateOfEntry)
        TargetRS!Month = Month(TxDetails!DateOfEntry)
        TargetRS!FirstDateOfMonth = DateSerial(Year(TxDetails!DateOfEntry), Month(TxDetails!DateOfEntry), 1)
    Else
        TargetRS.Edit
    End If
    Select Case strTxType
    Case "RC", "WC"       ' Retail Invoice & Wholesale Invoice
        TargetRS!qtyCD = TargetRS!qtyCD - TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD - TxDetails!Amount
        TargetRS!QtySold = TargetRS!QtySold + TxDetails!Qty
        TargetRS!AmtSold = TargetRS!AmtSold + TxDetails!Amount
        TargetRS!AmtCostOfGoodsSold = TargetRS!AmtCostOfGoodsSold + _
                                      TxDetails!Qty * TxDetails!UnitCost
    Case "RS", "WR"       ' Customer Refund & Wholesale Return
        TargetRS!qtyCD = TargetRS!qtyCD - TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD - TxDetails!Amount
        TargetRS!QtyRestocked = TargetRS!QtyRestocked + TxDetails!Qty
        TargetRS!AmtRestocked = TargetRS!AmtRestocked + TxDetails!Amount
    End Select
    TargetRS.Update
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    TxDetails.Close                      ' Close table.
    myDB.Close                          ' Close database.
End Sub

Public Sub OLTP_PoS_InvtLotRecord(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim Inventory, Category As Recordset
    Dim TxHeader, TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxHeader = myDB.OpenRecordset("TxHeader", dbOpenDynaset, dbReadOnly)      ' Open table read only
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxHeader.FindFirst PriCriteria      ' Find the record
    If TxHeader.NoMatch Then            ' Terminate process if record is not found.
        TxHeader.Close                  '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    TxDetails.FindFirst PriCriteria     ' Find the record. Assume always found
    Set Inventory = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)
    Set Category = myDB.OpenRecordset("Category", dbOpenDynaset, dbReadOnly)
    Set TargetRS = myDB.OpenRecordset("InvtLotRecord", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    SecCriteria = "SKU = '" & TxDetails!SKU & "'"
    Inventory.FindFirst SecCriteria     ' Assume always found
    SecCriteria = "DepartmentCode = '" & Inventory!DepartmentCode & "' And " & _
                  "ClassCode = '" & Inventory!ClassCode & "' And " & _
                  "CategoryCode = '" & Inventory!CategoryCode & "'"
    Category.FindFirst SecCriteria      ' Assume always found
    Select Case strTxType
    Case "RC", "WC"       ' Retail Invoice & Wholesale Invoice
        SecCriteria = "SKU = '" & TxDetails!SKU & "'"
        Select Case Category!CostingMethod
        Case "2"    ' LIFO
            TargetRS.FindLast SecCriteria
        Case Else   ' Average & FIFO
            TargetRS.FindFirst SecCriteria
        End Select
        If TargetRS.NoMatch Then
            TargetRS.AddNew
            TargetRS!SKU = TxDetails!SKU
            TargetRS!LotNo = TxHeader!ControlNumber
            TargetRS!DateReceived = TxHeader!DateOfEntry
            TargetRS!SupplierCode = Inventory.SupplierCode
            TargetRS!QtyUsed = (0 - TxDetails!Qty)
            TargetRS!QtyOnHand = (0 - TxDetails!Qty)
            TargetRS!UnitAmountPurchased = TxDetails!UnitCost
            TargetRS!TotalAmountPurchased = TxDetails!Amount
        Else
            TargetRS.Edit
            TargetRS!QtyUsed = TargetRS!QtyUsed - TxDetails!Qty
            TargetRS!QtyOnHand = TargetRS!QtyOnHand - TxDetails!Qty
        End If
    Case "RS", "WR"       ' Customer Refund
        SecCriteria = "SKU = '" & TxDetails!SKU & "'"
        Select Case Category!CostingMethod
        Case "2"    ' LIFO
            TargetRS.FindLast SecCriteria
        Case Else   ' Average & FIFO
            TargetRS.FindFirst SecCriteria
        End Select
        If TargetRS.NoMatch Then
            TargetRS.AddNew
            TargetRS!SKU = TxDetails!SKU
            TargetRS!LotNo = TxHeader!ControlNumber
            TargetRS!DateReceived = TxHeader!DateOfEntry
            TargetRS!SupplierCode = Inventory.SupplierCode
            TargetRS!QtyPurchased = (0 - TxDetails!Qty)
            TargetRS!QtyOnHand = (0 - TxDetails!Qty)
            TargetRS!UnitAmountPurchased = TxDetails!UnitCost
            TargetRS!TotalAmountPurchased = TxDetails!Amount
        Else
            TargetRS.Edit
            TargetRS!QtyUsed = TargetRS!QtyUsed - TxDetails!Qty         ' TxDetails!Qty is -ve
            TargetRS!QtyOnHand = TargetRS!QtyOnHand + TxDetails!Qty
        End If
    End Select
    TargetRS.Update
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    Category.Close
    Inventory.Close
    TxDetails.Close                     ' Close table.
    TxHeader.Close                      ' Close table.
    myDB.Close                          ' Close database.
End Sub

Public Sub OLTP_PoS_Inventory(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxDetails.FindFirst PriCriteria     ' Find the record. Assume always found
    If TxDetails.NoMatch Then           ' Terminate process if record is not found.
        TxDetails.Close                 '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    Set TargetRS = myDB.OpenRecordset("Inventory", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    SecCriteria = "SKU = '" & TxDetails!SKU & "'"
    TargetRS.FindFirst SecCriteria      ' Assume always found
    TargetRS.Edit
    Select Case strTxType
' 20030725 Corrected
'    Case "RC"       ' Sale Order
    Case "SA"       ' Sale Order
        TargetRS!QtySaleOrder = TargetRS!QtySaleOrder + TxDetails!Qty
    Case "RC", "WC"       ' Retail Invoice
        TargetRS!QtyTotalOnhand = TargetRS!QtyTotalOnhand - TxDetails!Qty
        If TargetRS!QtySaleOrder > TxDetails!Qty Then
            TargetRS!QtySaleOrder = TargetRS!QtySaleOrder - TxDetails!Qty
        Else
            TargetRS!QtySaleOrder = 0
        End If
        If IsNull(TargetRS!DateLastIssued) Or _
                  TargetRS!DateLastIssued < TxDetails!DateOfEntry Then
            TargetRS!DateLastIssued = TxDetails!DateOfEntry
        End If
    Case "RS", "WR"       ' Customer Refund
        TargetRS!QtyTotalOnhand = TargetRS!QtyTotalOnhand - TxDetails!Qty
        If IsNull(TargetRS!DateLastReceived) Or _
                  TargetRS!DateLastReceived < TxDetails!DateOfEntry Then
            TargetRS!DateLastReceived = TxDetails!DateOfEntry
        End If
    End Select
    TargetRS.Update
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    TxDetails.Close                     ' Close table.
    myDB.Close                          ' Close database.
End Sub

Public Sub OLTP_PoS_Category(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim Inventory, TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxDetails.FindFirst PriCriteria     ' Find the record. Assume always found
    If TxDetails.NoMatch Then            ' Terminate process if record is not found.
        TxDetails.Close                  '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    Set Inventory = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)
    Set TargetRS = myDB.OpenRecordset("CategorySummary", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    SecCriteria = "SKU = '" & TxDetails!SKU & "'"
    Inventory.FindFirst SecCriteria     ' Assume always found
    SecCriteria = "DepartmentCode = '" & Inventory!DepartmentCode & "' And " & _
                  "ClassCode = '" & Inventory!ClassCode & "' And " & _
                  "CategoryCode = '" & Inventory!CategoryCode & "' And " & _
                  "Year = " & Year(TxDetails!DateOfEntry) & " And " & _
                  "Month = " & Month(TxDetails!DateOfEntry)
    TargetRS.FindFirst SecCriteria
    If TargetRS.NoMatch Then
        TargetRS.AddNew
        TargetRS!DepartmentCode = Inventory!DepartmentCode
        TargetRS!ClassCode = Inventory!ClassCode
        TargetRS!CategoryCode = Inventory!CategoryCode
        TargetRS!Year = Year(TxDetails!DateOfEntry)
        TargetRS!Month = Month(TxDetails!DateOfEntry)
        TargetRS!FirstDateOfMonth = DateSerial(Year(TxDetails!DateOfEntry), Month(TxDetails!DateOfEntry), 1)
    Else
        TargetRS.Edit
    End If
    Select Case strTxType
    Case "RC", "WC"       ' Retail Invoice
        TargetRS!qtyCD = TargetRS!qtyCD - TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD - TxDetails!Amount
        TargetRS!QtySold = TargetRS!QtySold + TxDetails!Qty
        TargetRS!AmtSold = TargetRS!AmtSold + TxDetails!Amount
        TargetRS!AmtCostOfGoodsSold = TargetRS!AmtCostOfGoodsSold + _
                                      TxDetails!Qty * TxDetails!UnitCost
    Case "RS", "WR"       ' Customer Refund
        TargetRS!qtyCD = TargetRS!qtyCD - TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD - TxDetails!Amount
        TargetRS!QtyRestocked = TargetRS!QtyRestocked + TxDetails!Qty
        TargetRS!AmtRestocked = TargetRS!AmtRestocked + TxDetails!Amount
    End Select
    TargetRS.Update
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    Inventory.Close
    TxDetails.Close                     ' Close table.
    myDB.Close                          ' Close database.
End Sub

Public Sub OLTP_PoS_Class(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim Inventory, TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxDetails.FindFirst PriCriteria     ' Find the record. Assume always found
    If TxDetails.NoMatch Then            ' Terminate process if record is not found.
        TxDetails.Close                  '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    Set Inventory = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)
    Set TargetRS = myDB.OpenRecordset("ClassSummary", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    SecCriteria = "SKU = '" & TxDetails!SKU & "'"
    Inventory.FindFirst SecCriteria     ' Assume always found
    SecCriteria = "DepartmentCode = '" & Inventory!DepartmentCode & "' And " & _
                  "ClassCode = '" & Inventory!ClassCode & "' And " & _
                  "Year = " & Year(TxDetails!DateOfEntry) & " And " & _
                  "Month = " & Month(TxDetails!DateOfEntry)
    TargetRS.FindFirst SecCriteria
    If TargetRS.NoMatch Then
        TargetRS.AddNew
        TargetRS!DepartmentCode = Inventory!DepartmentCode
        TargetRS!ClassCode = Inventory!ClassCode
        TargetRS!Year = Year(TxDetails!DateOfEntry)
        TargetRS!Month = Month(TxDetails!DateOfEntry)
        TargetRS!FirstDateOfMonth = DateSerial(Year(TxDetails!DateOfEntry), Month(TxDetails!DateOfEntry), 1)
    Else
        TargetRS.Edit
    End If
    Select Case strTxType
    Case "RC", "WC"       ' Retail Invoice
        TargetRS!qtyCD = TargetRS!qtyCD - TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD - TxDetails!Amount
        TargetRS!QtySold = TargetRS!QtySold + TxDetails!Qty
        TargetRS!AmtSold = TargetRS!AmtSold + TxDetails!Amount
        TargetRS!AmtCostOfGoodsSold = TargetRS!AmtCostOfGoodsSold + _
                                      TxDetails!Qty * TxDetails!UnitCost
    Case "RS", "WR"       ' Customer Refund
        TargetRS!qtyCD = TargetRS!qtyCD - TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD - TxDetails!Amount
        TargetRS!QtyRestocked = TargetRS!QtyRestocked + TxDetails!Qty
        TargetRS!AmtRestocked = TargetRS!AmtRestocked + TxDetails!Amount
    End Select
    TargetRS.Update
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    Inventory.Close
    TxDetails.Close                     ' Close table.
    myDB.Close                          ' Close database.
End Sub

Public Sub OLTP_PoS_Dept(strTxNumber As String)
    Dim strTxType As String
    Dim myDB As Database
    Dim Inventory, TxDetails, TargetRS As Recordset
    Dim PriCriteria, SecCriteria As String
    PriCriteria = "TxNumber = '" & strTxNumber & "'"        ' Set the search criteria.
    strTxType = Left(strTxNumber, 2)
    
    '
    ' Lookup the record from Table
    '
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxDetails = myDB.OpenRecordset("TxDetails", dbOpenDynaset, dbReadOnly)      ' Open table read only
    TxDetails.FindFirst PriCriteria     ' Find the record. Assume always found
    If TxDetails.NoMatch Then            ' Terminate process if record is not found.
        TxDetails.Close                  '  Close table.
        myDB.Close                      '  Close database.
        Exit Sub
    End If
    Set Inventory = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)
    Set TargetRS = myDB.OpenRecordset("DeptSummary", dbOpenDynaset)
Do While Not TxDetails.NoMatch
    SecCriteria = "SKU = '" & TxDetails!SKU & "'"
    Inventory.FindFirst SecCriteria     ' Assume always found
    SecCriteria = "DepartmentCode = '" & Inventory!DepartmentCode & "' And " & _
                  "Year = " & Year(TxDetails!DateOfEntry) & " And " & _
                  "Month = " & Month(TxDetails!DateOfEntry)
    TargetRS.FindFirst SecCriteria
    If TargetRS.NoMatch Then
        TargetRS.AddNew
        TargetRS!DepartmentCode = Inventory!DepartmentCode
        TargetRS!Year = Year(TxDetails!DateOfEntry)
        TargetRS!Month = Month(TxDetails!DateOfEntry)
        TargetRS!FirstDateOfMonth = DateSerial(Year(TxDetails!DateOfEntry), Month(TxDetails!DateOfEntry), 1)
    Else
        TargetRS.Edit
    End If
    Select Case strTxType
    Case "RC", "WC"       ' Retail Invoice
        TargetRS!qtyCD = TargetRS!qtyCD - TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD - TxDetails!Amount
        TargetRS!QtySold = TargetRS!QtySold + TxDetails!Qty
        TargetRS!AmtSold = TargetRS!AmtSold + TxDetails!Amount
        TargetRS!AmtCostOfGoodsSold = TargetRS!AmtCostOfGoodsSold + _
                                      TxDetails!Qty * TxDetails!UnitCost
    Case "RS", "WR"       ' Customer Refund
        TargetRS!qtyCD = TargetRS!qtyCD - TxDetails!Qty
        TargetRS!AmtCD = TargetRS!AmtCD - TxDetails!Amount
        TargetRS!QtyRestocked = TargetRS!QtyRestocked + TxDetails!Qty
        TargetRS!AmtRestocked = TargetRS!AmtRestocked + TxDetails!Amount
    End Select
    TargetRS.Update
    TxDetails.FindNext PriCriteria      ' Find the next record
Loop
    TargetRS.Close
    Inventory.Close
    TxDetails.Close                     ' Close table.
    myDB.Close                          ' Close database.
End Sub

' Caller supplies Original Order Number
' This module would generate a Refund transaction
'   against the Order Number
' Assumption:
'   Every items in the Order is refunded
Public Sub PoS_Refund(myOrderNumber As String)
    Dim myRefundNumber As String
    Dim MyControlNumber As String
    
    myRefundNumber = GetNextTxNumber("RS")
    MyControlNumber = GetNextControlNumber
    
    Call PoS_Refund_TxHeader(myOrderNumber, myRefundNumber, MyControlNumber)
    Call PoS_Refund_TxDetails(myOrderNumber, myRefundNumber, MyControlNumber)
    Call PoS_Refund_TxSalesPerson(myOrderNumber, myRefundNumber)     '
    Call PoS_Refund_TxPayment(myOrderNumber, myRefundNumber)         '
    Call PoS_Refund_TxSOrderExtra(myOrderNumber, myRefundNumber)     '
End Sub

Private Sub PoS_Refund_TxHeader(strFromTarget As String, strToTarget As String, _
                                strNewControlNumber As String)
    Dim myDB As Database
    Dim FromRS, ToRS As Recordset
    Dim strSQL As String
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")               ' Open database
    Set FromRS = myDB.OpenRecordset("TxHeader", dbOpenDynaset)        ' Open table read only
    Set ToRS = FromRS.Clone()
    
    strSQL = "TxNumber = '" & strFromTarget & "'"
    FromRS.FindFirst strSQL
    If Not FromRS.NoMatch Then
        With ToRS
            .AddNew
            !ControlNumber = strNewControlNumber
            !TxType = "RS"
            !TxNumber = strToTarget
' !DateOfEntry =
            !DateOfCreation = Now
            !RefNumber = FromRS!RefNumber
            !TrackingNumber = strFromTarget
            !CustomerID = FromRS!CustoemrID
            !SupplierCode = FromRS!SupplierCode
            !SecondDate = FromRS!DateOfEntry
            !Particulars = FromRS!Particulars
            !TotalCost = FromRS!TotalCost
            !TotalSale = (0 - FromRS!TotalSale)
            !TaxA = (0 - FromRS!TaxA)
            !TaxB = (0 - FromRS!TaxB)
            !TaxC = (0 - FromRS!TaxC)
            !OtherCharges = (0 - FromRS!OtherCharges)
            !GrossSale = (0 - FromRS!GrossSale)
            !SalesDiscount = (0 - FromRS!SalesDiscount)
            !TotalAmount = (0 - FromRS!TotalAmount)
            !TotalQty = (0 - FromRS!TotalQty)
            !PreviousPaid = 0
            !ThisPaid = (0 - FromRS!GrossSale)
            !PaymentLink = FromRS!PaymentLink
            !SalesPersonLink = FromRS!SalesPersonLink
            !Status = FromRS!Status
            .Update
        End With
    End If
    
    ToRS.Close
    FromRS.Close
End Sub

Private Sub PoS_Refund_TxDetails(strFromTarget As String, strToTarget As String, _
                                 strNewControlNumber As String)
    Dim myDB As Database
    Dim FromRS, ToRS As Recordset
    Dim strSQL As String
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")               ' Open database
    Set FromRS = myDB.OpenRecordset("TxDetails", dbOpenDynaset)        ' Open table read only
    Set ToRS = FromRS.Clone()
    
    strSQL = "TxNumber = '" & strFromTarget & "'"
    FromRS.FindFirst strSQL
    If Not FromRS.EOF Then
        If FromRS!Qty <> 0 Then
            With ToRS
                .AddNew
                !ControlNumber = strNewControlNumber
                !TxType = "RS"
' DateOfEntry
                !RowNo = FromRS!RowNo
                !SKU = FromRS!SKU
                !Remarks = FromRS!Remarks
                !PrescriptionLensFlag = FromRS!PrescriptionLensFlag
                !PrescriptionContactFlag = FromRS!PrescriptionContactFlag
                !Qty = (0 - FromRS!Qty)
                !UnitAmount = FromRS!UnitAmount
                !UnitCost = FromRS!UnitCost
                !MarkDownPercent = FromRS!MarkDownPercent
                !MarkDownAmount = FromRS!MarkDownAmount
                !Amount = (0 - FromRS!Amount)
                !TaxCode = FromRS!TaxCode
                .Update
            End With
        End If
        FromRS.FindNext
    End If
    
    ToRS.Close
    FromRS.Close
End Sub

Private Sub PoS_Refund_TxPayment(strFromTarget As String, strToTarget As String)
    Dim myDB As Database
    Dim FromRS, ToRS As Recordset
    Dim strSQL As String
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")               ' Open database
    Set FromRS = myDB.OpenRecordset("TxPayment", dbOpenDynaset)        ' Open table read only
    Set ToRS = FromRS.Clone()
    
    strSQL = "TxNumber = '" & strFromTarget & "'"
    FromRS.FindFirst strSQL
    If Not FromRS.EOF Then
        If FromRS!AmountTender <> 0 Then
            With ToRS
                .AddNew
                !TxNumber = strToTarget
                !PaymentLineNo = FromRS!PaymentLineNo
                !Type = FromRS!Type
                !CardNumber = FromRS!CardNumber
                !AuthorizationCode = FromRS!AuthorizationCode
                !AmountTender = FromRS!AmountTender
                !ExchangeRate = FromRS!ExchangeRate
                !EqAmount = FromRS!EqAmount
                !Surcharge = FromRS!Surchage
                !TotalThisPay = FromRS!TotalThisPay
                .Update
            End With
        End If
        FromRS.FindNext
    End If
    
    ToRS.Close
    FromRS.Close
End Sub

Private Sub PoS_Refund_TxSalesPerson(strFromTarget As String, strToTarget As String)
    Dim myDB As Database
    Dim FromRS, ToRS As Recordset
    Dim strSQL As String
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")               ' Open database
    Set FromRS = myDB.OpenRecordset("TxSalePerson", dbOpenDynaset)        ' Open table read only
    Set ToRS = FromRS.Clone()
    
    strSQL = "TxNumber = '" & strFromTarget & "'"
    FromRS.FindFirst strSQL
    If Not FromRS.NoMatch Then
        With ToRS
            .AddNew
            !TxNumber = strToTarget
            !SalesRowNo = 1
            !StaffCode = FromRS!StaffCode
            .Update
        End With
    End If
    
    ToRS.Close
    FromRS.Close
End Sub

Private Sub PoS_Refund_TxSOrderExtra(strFromTarget As String, strToTarget As String)
    Dim myDB As Database
    Dim FromRS, ToRS As Recordset
    Dim strSQL As String
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")               ' Open database
    Set FromRS = myDB.OpenRecordset("TxSOrderExtra", dbOpenDynaset)        ' Open table read only
    Set ToRS = FromRS.Clone()
    
    strSQL = "TxNumber = '" & strFromTarget & "'"
    FromRS.FindFirst strSQL
    If Not FromRS.NoMatch Then
        With ToRS
            .AddNew
            !TxNumber = strToTarget
            !Redo = FromRS!Redo
            !Warranty = FromRS!Warranty
            !Mail = FromRS!Mail
            !Msd = FromRS!Msd
            !Remarks = FromRS!Remarks
            .Update
        End With
    End If
    
    ToRS.Close
    FromRS.Close
End Sub

' Caller supply the TxNumber
' Would lookup the TxNumber and update payment tender into Payment Summary
' Payment Tender is +ve for Order, Invoice
' Payment Tender is -ve for Void
Public Sub OLTP_PoS_PaymentSummary(MyTxNumber As String)
    Dim myDB As Database
    Dim TxPayment, PaymentSummary As Recordset
    Dim strSQL1, strSQL2 As String
    Dim dtmDate As Date
    
    Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                   ' Open database
    Set TxPayment = myDB.OpenRecordset("qryTxPayment", dbOpenDynaset, dbReadOnly)      ' Open table read only
    Set PaymentSummary = myDB.OpenRecordset("PaymentSummary", dbOpenDynaset, dbOptimistic)      ' Open table read only

    strSQL1 = "TxNumber = '" & MyTxNumber & "'"
    TxPayment.FindFirst strSQL1
    Do While Not TxPayment.NoMatch
        dtmDate = Format(TxPayment!DateOfEntry, "MM/DD/YYYY")
        strSQL2 = "PaymentCode = '" & TxPayment!Type & "' And " & _
                 "[Date] = #" & dtmDate & "#"
        With PaymentSummary
            .FindFirst strSQL2
            If .NoMatch Then
                .AddNew
                !PaymentCode = TxPayment!Type
                !Date = Format(TxPayment!DateOfEntry, "MM/DD/YYYY")
                If TxPayment!AmountTender > 0 Then
                    !AmtSold = TxPayment!AmountTender
                    !NumberOfSold = 1
                Else
                    !AmtRefund = TxPayment!AmountTender
                    !NumberOfRefund = 1
                End If
            Else
                .Edit
                If TxPayment!AmountTender > 0 Then
                    !AmtSold = !AmtSold + TxPayment!AmountTender
                    !NumberOfSold = !NumberOfSold + 1
                Else
                    !AmtRefund = !AmtRefund + TxPayment!AmountTender
                    !NumberOfRefund = !NumberOfRefund + 1
                End If
            End If
            !ExchangeRate = TxPayment!ExchangeRate
            .Update
        End With
        TxPayment.FindNext strSQL1
    Loop
    
    ' Add Change if any
    ' Assume local currency uses Code zero '0'
    If TxPayment!Change <> 0 Then
        strSQL1 = "PaymentCode = '0' And " & _
                 "Date = #" & Format(TxPayment!DateOfEntry, "MM/DD/YYYY") & "#"
        With PaymentSummary
            .FindFirst strSQL1
            If .NoMatch Then
                .AddNew
                !PaymentCode = TxPayment!Type
                !Date = Format(TxPayment!DateOfEntry, "MM/DD/YYYY")
                !AmtChanged = TxPayment!Change
                !NumberOfSold = 1
            Else
                .Edit
                !AmtChanged = !AmtChanged + TxPayment!Change
                !NumberOfChange = !NumberOfChange + 1
            End If
            !ExchangeRate = TxPayment!ExchangeRate
           .Update
        End With
    End If
    
    PaymentSummary.Close
    TxPayment.Close
    myDB.Close
End Sub

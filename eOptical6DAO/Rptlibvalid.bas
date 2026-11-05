Attribute VB_Name = "basRptLibvalid"
Option Explicit

Public CrwRptName As String
Public sDBName As String
Public SynergyIcon As String
Public CurrentDate As Date
Public loctext$
Public RptTxNumberFrom As String
Public RptTxNumberTo As String
'------------------------------
' Procedure:  KeyNumbers
' Purpose:    TBD
' Params:
' Returns:
'------------------------------
Public Function KeyNumbers(nKeyValue As Integer) As Integer
    On Error GoTo KeyNumbers_Err
    '
    Dim cValid As String
    '
    cValid = "0123456789+-."
    '
    If nKeyValue > 26 Then ' if it's not a control code
        If InStr(cValid, Chr(nKeyValue)) = 0 Then
            nKeyValue = 0
        End If
    End If
    KeyNumbers = nKeyValue
KeyNumbers_Exit:
    On Error Resume Next
    Exit Function
KeyNumbers_Err:
    MsgBox Error
    Resume KeyNumbers_Exit
End Function


'------------------------------
' Procedure:  KeyUpperNumber
' Purpose:    TBD
' Params:
' Returns:
'------------------------------
Public Function KeyUpperNumber(nKeyValue As Integer) As Integer
    On Error GoTo KeyUpperNumber_Err
    '
    ' passes uppercase letters
    ' converts lowercase to uppercase
    ' passes 0123456789 and control codes
    ' rejects all else
    '
    If nKeyValue > 26 Then
        If Chr(nKeyValue) >= "a" And Chr(nKeyValue) <= "z" Then
            nKeyValue = nKeyValue - 32
        End If
        '
        If Chr(nKeyValue) >= "A" And Chr(nKeyValue) <= "Z" Then
            nKeyValue = nKeyValue
        Else
            nKeyValue = KeyNumbers(nKeyValue)
        End If
    End If
    KeyUpperNumber = nKeyValue
KeyUpperNumber_Exit:
    On Error Resume Next
    Exit Function
KeyUpperNumber_Err:
    MsgBox Error
    Resume KeyUpperNumber_Exit
End Function

'------------------------------
' Procedure:  InRange
' Purpose:    TBD
' Params:
' Returns:
'------------------------------
Public Function InRange(ctlName As Control, cfieldname As String, _
    vHigh As Variant, vLow As Variant, nMsg As Integer) As Integer
    On Error GoTo InRange_Err
    '
    ' ctlName       = name of control to check
    ' cFieldname    = name of field to display
    ' vHigh         = high end of range
    ' vLow          = low end of range
    ' nMsg          = flag to show message
    '
    'Debug.Print ctlName, ctlName.Text, vLow, vHigh
    
    If Val(ctlName.Text) < vLow Or Val(ctlName.Text) > vHigh Then
        If nMsg = True Then
            Beep
            MsgBox cfieldname + " must be between " + Str(vLow) + _
                " and " + Str(vHigh), 0, "Validation Error"
        End If
        ctlName.SetFocus
        InRange = False
    Else
        InRange = True
    End If
   ' Debug.Print InRange
InRange_Exit:
    On Error Resume Next
    Exit Function
InRange_Err:
    MsgBox Error
    Resume InRange_Exit
End Function

'------------------------------
' Procedure:  IsValid
' Purpose:    TBD
' Params:
' Returns:    TRUE if successful, else FALSE
'------------------------------
Public Function IsValid(ctlName As Control, cfieldname As String, _
    nMsg As Integer) As Integer
    On Error GoTo IsValid_Err
    If Len(Trim(ctlName.Text)) = 0 Then
        If nMsg = True Then
            Beep
            MsgBox cfieldname + " is a required field.", _
                0, "Validation Error"
        End If
        ctlName.SetFocus
        IsValid = False
    Else
        IsValid = True
    End If
IsValid_Exit:
    On Error Resume Next
    Exit Function
IsValid_Err:
    MsgBox Error
    Resume IsValid_Exit
End Function

'------------------------------
' Procedure:  CheckSize
' Purpose:    TBD
' Params:
' Returns:    TRUE if successful, else FALSE
'------------------------------
Public Function CheckSize(ctlName As Control, cfieldname As String, _
    nMinLen As Integer, nMaxLen As Integer, nMsg As Integer) As Integer
    On Error GoTo CheckSize_Err
    Dim nLen As Integer
    
    nLen = Len(ctlName.Text)    ' get length for checking
    If nLen < nMinLen Or nLen > nMaxLen Then
        If nMsg = True Then
            Beep
            MsgBox cfieldname + " must be between " + Str(nMinLen) + _
             " and " + Str(nMaxLen) + " bytes long.", 0, "Validation Error"
        End If
        ctlName.SetFocus
        CheckSize = False
    Else
        CheckSize = True
    End If
CheckSize_Exit:
    On Error Resume Next
    Exit Function
CheckSize_Err:
    MsgBox Error
    Resume CheckSize_Exit
End Function

'------------------------------
' Procedure:  IsConditional
' Purpose:    TBD
' Params:
' Returns:
'------------------------------
Public Function IsConditional(ctlMaster As Control, cFldMaster As String, _
    ctlChild As Control, cFldChild As String, nMsg As Integer) As Integer
    
    On Error GoTo IsConditional_Err
    
    Dim nMaster As Integer
    Dim nChild As Integer
    
    nMaster = IsValid(ctlMaster, cFldMaster, False)
    nChild = IsValid(ctlChild, cFldChild, False)
    If nMaster And Not nChild Then
        If nMsg = True Then
            Beep
            MsgBox "If " + cFldMaster + " is filled then " + _
                cFldChild + " must be filled in."
            ctlChild.SetFocus
        End If
        IsConditional = False
    Else
        IsConditional = True
    End If
IsConditional_Exit:
    On Error Resume Next
    Exit Function
IsConditional_Err:
    MsgBox Error
    Resume IsConditional_Exit
End Function





'------------------------------
' Procedure:  SetRptFileName
' Purpose:    TBD
' Params:
' Returns:
'------------------------------
Public Function SetRptFileName(ctlName As Variant, _
    intDest As Integer)
    
    On Error GoTo SetRptFileName_Err
    
    If sDBName = "" Then
        Call SetSDBName
    End If
    
    Dim SRptName As String
    Dim i As Integer
    
    CrwRptName = ctlName
    SRptName = loctext$ & "Rpt odbc\" & CrwRptName & ".rpt"     ' ODBC Reports (default)
    If Dir(SRptName) = "" Then
        SRptName = loctext$ & "Rpt\" & CrwRptName & ".rpt"      ' DAO Reports
    End If
    
    If Dir(SRptName) = "" Then
        Beep
        MsgBox CrwRptName & " Not Found", vbCritical + vbOKOnly, "Error"
        SetRptFileName = False
        'If intDest = 0 Then ctlName.SetFocus
    Else
        '   Close previous report if any
        frmCtlCrw.CrystalReport1.ReportFileName = ""
    
        '   Initiliaze CrystalReport ActiveX parameters
        '   intDest = 0         to Window
        '           = 1         to Printer
        '           = 2         to File
        frmCtlCrw.CrystalReport1.Destination = intDest
        If Not (SRptName Like "*odbc*") Then
            frmCtlCrw.CrystalReport1.DataFiles(0) = sDBName
        End If
        frmCtlCrw.CrystalReport1.WindowHeight = 600
        frmCtlCrw.CrystalReport1.WindowWidth = 800
        frmCtlCrw.CrystalReport1.WindowLeft = 0
        frmCtlCrw.CrystalReport1.WindowTop = 0
        frmCtlCrw.CrystalReport1.ReportFileName = SRptName
        frmCtlCrw.CrystalReport1.WindowTitle = CrwRptName
        frmCtlCrw.CrystalReport1.SelectionFormula = ""
        For i = 0 To 4
            frmCtlCrw.CrystalReport1.Formulas(i) = ""
        Next
        SetRptFileName = True
    End If
SetRptFileName_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Function         ' SDVB autocode
SetRptFileName_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume SetRptFileName_Exit
End Function




Public Sub InitPrintEngine()

    On Error GoTo InitPrintEngine_Err

    ' Flush engine with any report name to make it ready for use
    CrwRptName = "Order"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    Call SetRptFileName(CrwRptName, 0)

InitPrintEngine_Exit:                                ' SDVB autocode
    On Error Resume Next                             ' SDVB autocode
    Exit Sub                                         ' SDVB autocode
InitPrintEngine_Err:                                 ' SDVB autocode
    Call ofx_GenericError("InitPrintEngine()", Err)  ' SDVB autocode
    Resume InitPrintEngine_Exit

End Sub

Public Sub SetSDBName()

    On Error GoTo SetSDBName_Err

    CurrentDate = Date

    '   Set location of the database file to the location from
    '   which the user ran the app
    loctext$ = LCase(App.Path)
    If Right$(App.Path, 1) <> "\" Then loctext$ = loctext$ + "\"  'handles the root
  
    sDBName = loctext$ & "synergyv.mdb"
    If Dir(sDBName) = "" Then
        MsgBox "SynergyV Database Not Found", vbCritical + vbOKOnly, "Error"
        End
    End If
     

SetSDBName_Exit:                                ' SDVB autocode
    On Error Resume Next                        ' SDVB autocode
    Exit Sub                                    ' SDVB autocode
SetSDBName_Err:                                 ' SDVB autocode
    Call ofx_GenericError("SetSDBName()", Err)  ' SDVB autocode
    Resume SetSDBName_Exit

End Sub


Public Sub PrintStockTrans(strTxPrefix As String, _
    intAuto As Integer, intDest As Integer)

    On Error GoTo PrintStockTrans_Err

    
    Screen.MousePointer = vbDefault
    
    If strTxPrefix <> "RJ" And _
       strTxPrefix <> "SJ" And _
       strTxPrefix <> "SR" Then Exit Sub
    
    If strTxPrefix = "RJ" Then
        CrwRptName = "Stock Rejected"
    ElseIf strTxPrefix = "SJ" Then
        CrwRptName = "Stock Adjustment"
    ElseIf strTxPrefix = "SR" Then
        CrwRptName = "Stock Received"
    End If
       
    If intAuto <> 1 Then
        Dim Message As String
        Dim Title As String

        Message = "Enter " & CrwRptName & " No."
        Title = CrwRptName & " Reference Number"
        ' Display message, title
        RptTxNumberFrom = InputBox(Message, Title)
        If RptTxNumberFrom = "" Then
            Exit Sub
        End If
'        Message = strTxPrefix & "*"
'        If Not RptTxNumberFrom Like Message Then
        RptTxNumberFrom = strTxPrefix & RptTxNumberFrom
 '       End If
    End If
    
    'frmCtlCrw.txtCrwRptName = CrwRptName
    
    If SetRptFileName(CrwRptName, intDest) Then
    '   Set location of the database file to the location from
            '   Invoice
        RptTxNumberTo = RptTxNumberFrom
        frmCtlCrw.CrystalReport1.Formulas(2) = "AskTxNumberFrom = '" & _
                        RptTxNumberFrom & "'"
        frmCtlCrw.CrystalReport1.Formulas(3) = "AskTxNumberTo = '" & _
                        RptTxNumberTo & "'"
        frmCtlCrw.CrystalReport1.SelectionFormula = "{TxHeader.TxNumber} " & _
                "= '" & RptTxNumberFrom & "' "
            Screen.MousePointer = vbHourglass
            'MsgBox RptTxNumberFrom
            frmCtlCrw.CrystalReport1.Action = 1
            Screen.MousePointer = vbDefault
            
     End If

PrintStockTrans_Exit:                                ' SDVB autocode
    On Error Resume Next                             ' SDVB autocode
    Exit Sub                                         ' SDVB autocode
PrintStockTrans_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintStockTrans()", Err)  ' SDVB autocode
    Resume PrintStockTrans_Exit

End Sub

Public Sub PrintOrder(intAuto As Integer, intDest As Integer)

    On Error GoTo PrintOrder_Err
    
    Dim Message As String
    Dim Title As String
    Dim XWildcard As Boolean
    
    Screen.MousePointer = vbDefault
    If intAuto <> 1 Then
        Message = "Enter Order No."
        Title = "Order Number" ' Set title.
        ' Display message, title, and default value.
        RptTxNumberFrom = InputBox(Message, Title)
        If RptTxNumberFrom = "" Then
            Exit Sub
        End If
'        ElseIf Not RptTxNumberFrom Like "SA*" Then
            RptTxNumberFrom = "SA" & RptTxNumberFrom
 '       End If
    Else
        If RptTxNumberFrom = "" Then Exit Sub
    End If
    
    Message = Right(RptTxNumberFrom, 1)
    If Message = "*" Then
      XWildcard = True
    Else
      XWildcard = False
    End If
    
    CrwRptName = "Order"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
    '   Set location of the database file to the location from
            '   Order
        RptTxNumberTo = RptTxNumberFrom
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskTxNumberFrom = '" & _
                        RptTxNumberFrom & "'"
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskTxNumberTo = '" & _
                        RptTxNumberTo & "'"
        If XWildcard Then
            frmCtlCrw.CrystalReport1.SelectionFormula = "{TxHeader.TxNumber} " & _
                "like '" & RptTxNumberFrom & "' "
        Else
            frmCtlCrw.CrystalReport1.SelectionFormula = "{TxHeader.TxNumber} " & _
                "= '" & RptTxNumberFrom & "' "
        End If
            Screen.MousePointer = vbHourglass
            frmCtlCrw.CrystalReport1.Action = 1
            Screen.MousePointer = vbDefault
     End If

PrintOrder_Exit:                                ' SDVB autocode
    On Error Resume Next                        ' SDVB autocode
    Exit Sub                                    ' SDVB autocode
PrintOrder_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintOrder()", Err)  ' SDVB autocode
    Resume PrintOrder_Exit

End Sub

Public Sub PrintInvoice(intAuto As Integer, intDest As Integer)

    On Error GoTo PrintInvoice_Err

    Dim Message As String
    Dim Title As String
    
    Screen.MousePointer = vbDefault
    If intAuto <> 1 Then
        Message = "Enter Invoice No."
        Title = "Invoice Number" ' Set title.
        ' Display message, title, and default value.
        RptTxNumberFrom = InputBox(Message, Title)
        If RptTxNumberFrom = "" Then
            Exit Sub
        End If
     '   If RptTxNumberFrom Like "RC*" Then
        RptTxNumberFrom = "00000000" & RptTxNumberFrom
        RptTxNumberFrom = Right(RptTxNumberFrom, 8)
        RptTxNumberFrom = "RC" & RptTxNumberFrom
    Else
        If RptTxNumberFrom = "" Then Exit Sub
    End If
    
    CrwRptName = "Invoice"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
    '   Set location of the database file to the location from
            '   Order
        RptTxNumberTo = RptTxNumberFrom
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskTxNumberFrom = '" & _
                        RptTxNumberFrom & "'"
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskTxNumberTo = '" & _
                        RptTxNumberTo & "'"
        frmCtlCrw.CrystalReport1.SelectionFormula = "{TxHeader.TxNumber} " & _
                "= '" & RptTxNumberFrom & "' "
            Screen.MousePointer = vbHourglass
            frmCtlCrw.CrystalReport1.Action = 1
            Screen.MousePointer = vbDefault
     End If

PrintInvoice_Exit:                                ' SDVB autocode
    On Error Resume Next                          ' SDVB autocode
    Exit Sub                                      ' SDVB autocode
PrintInvoice_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintInvoice()", Err)  ' SDVB autocode
    Resume PrintInvoice_Exit

End Sub

Public Sub PrintRxTxNum(intAuto As Integer, intDest As Integer)

    On Error GoTo PrintRxTxNum_Err

    Dim Message As String
    Dim Title As String
    
    Screen.MousePointer = vbDefault
    If intAuto <> 1 Then
        Message = "Enter Reference No."
        Title = "Reference Number" ' Set title.
        ' Display message, title, and default value.
        RptTxNumberFrom = InputBox(Message, Title)
        If RptTxNumberFrom = "" Then
            Exit Sub
        End If
        If RptTxNumberFrom Like "RC*" Then
            RptTxNumberFrom = "00000000" & Mid(RptTxNumberFrom, 3)
            RptTxNumberFrom = Right(RptTxNumberFrom, 8)
            RptTxNumberFrom = "RC" & RptTxNumberFrom
        End If
    Else
        If RptTxNumberFrom = "" Then Exit Sub
    End If
    
    CrwRptName = "RxTxNum"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
    '   Set location of the database file to the location from
            '   Order
        RptTxNumberTo = RptTxNumberFrom
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskTxNumberFrom = '" & _
                        RptTxNumberFrom & "'"
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskTxNumberTo = '" & _
                        RptTxNumberTo & "'"
        frmCtlCrw.CrystalReport1.SelectionFormula = "{TxHeader.TxNumber} " & _
                "= '" & RptTxNumberFrom & "' "
            Screen.MousePointer = vbHourglass
            frmCtlCrw.CrystalReport1.Action = 1
            Screen.MousePointer = vbDefault
     End If

PrintRxTxNum_Exit:                                ' SDVB autocode
    On Error Resume Next                          ' SDVB autocode
    Exit Sub                                      ' SDVB autocode
PrintRxTxNum_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintRxTxNum()", Err)  ' SDVB autocode
    Resume PrintRxTxNum_Exit

End Sub


Public Sub PrintRxCust(intAuto As Integer, intDest As Integer)

    On Error GoTo PrintRxCust_Err

    Dim Message As String
    Dim Title As String
    
    Screen.MousePointer = vbDefault
    If intAuto <> 1 Then
        Message = "Enter Customer No."
        Title = "Customer Number" ' Set title.
        ' Display message, title, and default value.
        RptTxNumberFrom = InputBox(Message, Title)
        If RptTxNumberFrom = "" Then
            Exit Sub
        End If
    Else
        If RptTxNumberFrom = "" Then Exit Sub
    End If
    
    CrwRptName = "RxCust"
    If SetRptFileName(CrwRptName, intDest) Then
        RptTxNumberTo = RptTxNumberFrom
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskCustomerFrom = " & _
                        RptTxNumberFrom
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskCustomerTo = " & _
                        RptTxNumberTo
        frmCtlCrw.CrystalReport1.SelectionFormula = "{Customer.ID} " & _
                "=" & RptTxNumberFrom
            Screen.MousePointer = vbHourglass
            'MsgBox frmCtlCrw.CrystalReport1.SelectionFormula
            frmCtlCrw.CrystalReport1.Action = 1
            Screen.MousePointer = vbDefault
     End If

PrintRxCust_Exit:                                 ' SDVB autocode
    On Error Resume Next                          ' SDVB autocode
    Exit Sub                                      ' SDVB autocode
PrintRxCust_Err:                                  ' SDVB autocode
    Call ofx_GenericError("PrintRxCust()", Err)   ' SDVB autocode
    Resume PrintRxCust_Exit

End Sub



Public Sub PrintRBICWorkBook(intDest As Integer)

    On Error GoTo PrintRBICWorkBook_Err

    Dim Message As String
    Dim Title As String
    
    Screen.MousePointer = vbDefault
    CrwRptName = "RBIC WorkBook"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
    '   Set location of the database file to the location from
            '   Order
        RptTxNumberTo = RptTxNumberFrom
            Screen.MousePointer = vbHourglass
            frmCtlCrw.CrystalReport1.Action = 1
            Screen.MousePointer = vbDefault
     End If

PrintRBICWorkBook_Exit:                                ' SDVB autocode
    On Error Resume Next                               ' SDVB autocode
    Exit Sub                                           ' SDVB autocode
PrintRBICWorkBook_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintRBICWorkBook()", Err)  ' SDVB autocode
    Resume PrintRBICWorkBook_Exit

End Sub


Public Sub PrintClaimReceipt(intAuto As Integer, intDest As Integer)

    On Error GoTo PrintClaimReceipt_Err

    Dim Message As String
    Dim Title As String
    
    Screen.MousePointer = vbDefault
    If intAuto <> 1 Then
        Message = "Enter Order/Invoice No."
        Title = "Order/Invoice Number" ' Set title.
        ' Display message, title, and default value.
        RptTxNumberFrom = InputBox(Message, Title)
        If RptTxNumberFrom = "" Then
            Exit Sub
        End If
        If RptTxNumberFrom Like "RC*" Then
            RptTxNumberFrom = "00000000" & Mid(RptTxNumberFrom, 3)
            RptTxNumberFrom = Right(RptTxNumberFrom, 8)
            RptTxNumberFrom = "RC" & RptTxNumberFrom
        End If
    End If
    CrwRptName = "Claims Receipt"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
    '   Set location of the database file to the location from
            '   Order
        RptTxNumberTo = RptTxNumberFrom
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskTxNumberFrom = '" & _
                        RptTxNumberFrom & "'"
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskTxNumberTo = '" & _
                        RptTxNumberTo & "'"
        frmCtlCrw.CrystalReport1.SelectionFormula = "{RPTCLAIMRECEIPT.TxNumber} " & _
                "= '" & RptTxNumberFrom & "' "
            Screen.MousePointer = vbHourglass
            frmCtlCrw.CrystalReport1.Action = 1
            Screen.MousePointer = vbDefault
     End If

PrintClaimReceipt_Exit:                                ' SDVB autocode
    On Error Resume Next                          ' SDVB autocode
    Exit Sub                                      ' SDVB autocode
PrintClaimReceipt_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintClaimReceipt()", Err)  ' SDVB autocode
    Resume PrintClaimReceipt_Exit

End Sub


Public Sub PrintBarCode(intAuto As Integer, intDest As Integer)

    On Error GoTo PrintBarCode_Err

    Dim Message As String
    Dim Title As String
    
    Screen.MousePointer = vbDefault
    If intAuto <> 1 Then
        Message = "Enter Stock Received No."
        Title = "Stock Received Number" ' Set title.
        ' Display message, title, and default value.
        RptTxNumberFrom = InputBox(Message, Title)
        If RptTxNumberFrom = "" Then
            Exit Sub
        End If
     '   If Not RptTxNumberFrom Like "RC*" Then
        RptTxNumberFrom = "SR" & RptTxNumberFrom
    End If
    CrwRptName = "Bar Code Tag"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
    '   Set location of the database file to the location from
            '   Order
        RptTxNumberTo = RptTxNumberFrom
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskTxNumberFrom = '" & _
                        RptTxNumberFrom & "'"
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskTxNumberTo = '" & _
                        RptTxNumberTo & "'"
        frmCtlCrw.CrystalReport1.SelectionFormula = "{BarCodePool.TxNumber} " & _
                "= '" & RptTxNumberFrom & "' "
            Screen.MousePointer = vbHourglass
            frmCtlCrw.CrystalReport1.Action = 1
            Screen.MousePointer = vbDefault
     End If

PrintBarCode_Exit:                                ' SDVB autocode
    On Error Resume Next                          ' SDVB autocode
    Exit Sub                                      ' SDVB autocode
PrintBarCode_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintBarCode()", Err)  ' SDVB autocode
    Resume PrintBarCode_Exit

End Sub


Public Sub PrintIt()

    On Error GoTo PrintIt_Err
    
'    If ofx_IsFormLoaded(frmReports) Then frmReports.Hide
    
'    With frmPrintIt
'        .Caption = "Preveiwing " & CrwRptName
'        .Show
'        frmCtlCrw.CrystalReport1.WindowParentHandle = .hWnd
        Screen.MousePointer = vbHourglass
        frmCtlCrw.CrystalReport1.Action = 1
        Screen.MousePointer = vbDefault
'    End With
    
PrintIt_Exit:                                ' SDVB autocode
    On Error Resume Next                     ' SDVB autocode
    Exit Sub                                 ' SDVB autocode
PrintIt_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintIt()", Err)  ' SDVB autocode
    Resume PrintIt_Exit

End Sub

Public Sub PrintSKULedger(intAuto As Integer, intDest As Integer)

    On Error GoTo PrintSKULedger_Err

    Dim Message, Title As String
    
    Screen.MousePointer = vbDefault
    If intAuto <> 1 Then
        Message = "Enter SKU No."
        Title = "Print SKU Year-to-date Transaction Summary" ' Set title.
        ' Display message, title, and default value.
        RptTxNumberFrom = InputBox(Message, Title)
        If RptTxNumberFrom = "" Then
            Exit Sub
        End If
    Else
        If RptTxNumberFrom = "" Then Exit Sub
    End If
    
    CrwRptName = "SKULedger"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
    '   Set location of the database file to the location from
            '   Order
        RptTxNumberTo = RptTxNumberFrom
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskTxNumberFrom = '" & _
                        RptTxNumberFrom & "'"
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskTxNumberTo = '" & _
                        RptTxNumberTo & "'"
        frmCtlCrw.CrystalReport1.Formulas(2) = "AskXDispCost = " & pyUserHasCostLevel
        frmCtlCrw.CrystalReport1.SelectionFormula = "{Inventory.SKU} " & _
                "= '" & RptTxNumberFrom & "' "
        Call PrintIt
     End If

PrintSKULedger_Exit:                                ' SDVB autocode
    On Error Resume Next                            ' SDVB autocode
    Exit Sub                                        ' SDVB autocode
PrintSKULedger_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintSKULedger()", Err)  ' SDVB autocode
    Resume PrintSKULedger_Exit

End Sub


Public Sub PrintWholesalesInvoice(intAuto As Integer, intDest As Integer, Optional intPkList As Variant)

    On Error GoTo PrintWholesalesInvoice_Err

    Dim Message As String
    Dim Title As String
    Dim TxNumber    As String
    
    Screen.MousePointer = vbDefault
    If intAuto <> 1 Then
        Message = "Enter Wholesales Invoice No."
        Title = "Wholesales Invoice Number" ' Set title.
        ' Display message, title, and default value.
        TxNumber = InputBox(Message, Title)
        If TxNumber = "" Then
            Exit Sub
        End If
        
        RptTxNumberFrom = "WC" & TxNumber
        If Not IsFound("TxHeader", "TxNumber", RptTxNumberFrom, True) Then
            RptTxNumberFrom = "00000000" & TxNumber
            RptTxNumberFrom = "WC" & Right(RptTxNumberFrom, 8)
        End If
    Else
        If RptTxNumberFrom = "" Then Exit Sub
    End If
    
    CrwRptName = "Wholesales Invoice"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
    '   Set location of the database file to the location from
            '   Order
        RptTxNumberTo = RptTxNumberFrom
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskTxNumberFrom = '" & _
                        RptTxNumberFrom & "'"
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskTxNumberTo = '" & _
                        RptTxNumberTo & "'"
        frmCtlCrw.CrystalReport1.SelectionFormula = "{TxHeader.TxNumber} " & _
                "= '" & RptTxNumberFrom & "' "
        Call PrintIt
     End If
     
     If Not IsMissing(intPkList) Then
        CrwRptName = "Wholesales Packing List"
        If SetRptFileName(CrwRptName, intDest) Then
            RptTxNumberTo = RptTxNumberFrom
            frmCtlCrw.CrystalReport1.Formulas(0) = "AskTxNumberFrom = '" & _
                        RptTxNumberFrom & "'"
            frmCtlCrw.CrystalReport1.Formulas(1) = "AskTxNumberTo = '" & _
                        RptTxNumberTo & "'"
            frmCtlCrw.CrystalReport1.SelectionFormula = "{TxHeader.TxNumber} " & _
                        "= '" & RptTxNumberFrom & "' "
            Call PrintIt
        End If
     End If
       
PrintWholesalesInvoice_Exit:                                ' SDVB autocode
    On Error Resume Next                                    ' SDVB autocode
    Exit Sub                                                ' SDVB autocode
PrintWholesalesInvoice_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintWholesalesInvoice()", Err)  ' SDVB autocode
    Resume PrintWholesalesInvoice_Exit

End Sub

Public Sub PrintWholesalesReturn(intAuto As Integer, intDest As Integer)

    On Error GoTo PrintWholesalesReturn_Err

    Dim Message As String
    Dim Title As String
    Dim TxNumber    As String
    
    Screen.MousePointer = vbDefault
    If intAuto <> 1 Then
        Message = "Enter Wholesales Return No."
        Title = "Wholesales Return Number" ' Set title.
        ' Display message, title, and default value.
        TxNumber = InputBox(Message, Title)
        If TxNumber = "" Then
            Exit Sub
        End If
        
        RptTxNumberFrom = "WR" & TxNumber
        If Not IsFound("TxHeader", "TxNumber", RptTxNumberFrom, True) Then
            RptTxNumberFrom = "00000000" & TxNumber
            RptTxNumberFrom = "WR" & Right(RptTxNumberFrom, 8)
        End If
    Else
        If RptTxNumberFrom = "" Then Exit Sub
    End If
    
    CrwRptName = "Wholesales Return"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
    '   Set location of the database file to the location from
            '   Order
        RptTxNumberTo = RptTxNumberFrom
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskTxNumberFrom = '" & _
                        RptTxNumberFrom & "'"
        frmCtlCrw.CrystalReport1.Formulas(1) = "AskTxNumberTo = '" & _
                        RptTxNumberTo & "'"
        frmCtlCrw.CrystalReport1.SelectionFormula = "{TxHeader.TxNumber} " & _
                "= '" & RptTxNumberFrom & "' "
        Call PrintIt
     End If

PrintWholesalesReturn_Exit:                                ' SDVB autocode
    On Error Resume Next                                   ' SDVB autocode
    Exit Sub                                               ' SDVB autocode
PrintWholesalesReturn_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintWholesalesReturn()", Err)  ' SDVB autocode
    Resume PrintWholesalesReturn_Exit

End Sub


'------------------------------
' Procedure:  PrintSTImportError
' Purpose:    Printing Stock Take Import Data Error
' Params:
' Returns:    N/A
'------------------------------
Public Sub PrintSTImportError(intDest As Integer, Optional srcHeaderID As Variant)

    On Error GoTo PrintSTImportError_Err
    Dim Message, Style, Title, tagHeaderID As String
    
    Screen.MousePointer = vbDefault
    If IsMissing(srcHeaderID) Then
        Message = "Enter Stock Take Header No."
        Title = "Stock Take Import Error" ' Set title.
        ' Display message, title, and default value.
        tagHeaderID = InputBox(Message, Title)
        If Trim(tagHeaderID) = "" Then
            Exit Sub
        End If
    Else
        tagHeaderID = srcHeaderID
        If Trim(tagHeaderID) = "" Then Exit Sub
        Message = "Found some bad imported data." & Chr(10) & _
                    "Going to send a report to printer." & Chr(10) & _
                    Chr(10) & "Load paper and press OK to continue"   ' Define message.
        Style = vbOKOnly + vbExclamation + vbApplicationModal  ' Define buttons.
        Title = "Import Data Error"  ' Define title.
        Call MsgBox(Message, Style, Title)
    End If
    
    CrwRptName = "ST Import Error"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskHeaderID = " & _
                                                tagHeaderID
        frmCtlCrw.CrystalReport1.SelectionFormula = "(({InvtSTImport.HeaderID} =" & _
                                                     tagHeaderID & _
                                                    ") and ({InvtSTImport.Status} <> 0))"
        Call PrintIt
     End If


PrintSTImportError_Exit:                                ' SDVB autocode
    On Error Resume Next                                ' SDVB autocode
    Exit Sub                                            ' SDVB autocode
PrintSTImportError_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintSTImportError()", Err)  ' SDVB autocode
    Resume PrintSTImportError_Exit
End Sub

Public Sub PrintSTImportData(intDest As Integer, Optional srcHeaderID As Variant)

    On Error GoTo PrintSTImportData_Err

    Dim Message, Title, tagHeaderID As String
    
    Screen.MousePointer = vbDefault
    If IsMissing(srcHeaderID) Then
        Message = "Enter Stock Take Header No."
        Title = "Stock Take Import Data" ' Set title.
        ' Display message, title, and default value.
        tagHeaderID = InputBox(Message, Title)
        If Trim(tagHeaderID) = "" Then
            Exit Sub
        End If
    Else
        tagHeaderID = srcHeaderID
        If Trim(tagHeaderID) = "" Then Exit Sub
    End If
    
    CrwRptName = "ST Import Data"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskHeaderID = " & _
                                                tagHeaderID
        frmCtlCrw.CrystalReport1.SelectionFormula = "{InvtSTImport.HeaderID} =" & _
                                                        tagHeaderID
        Call PrintIt
     End If

PrintSTImportData_Exit:                                ' SDVB autocode
    On Error Resume Next                               ' SDVB autocode
    Exit Sub                                           ' SDVB autocode
PrintSTImportData_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintSTImportData()", Err)  ' SDVB autocode
    Resume PrintSTImportData_Exit

End Sub

'------------------------------
' Procedure:  PrintSTExceptional
' Purpose:    Printing Stock Take Exceptional Report
' Params:
' Returns:    N/A
'------------------------------
Public Sub PrintSTExceptional(intDest As Integer, Optional srcHeaderID As Variant)

    On Error GoTo PrintSTExceptional_Err

    Dim Message, Title, tagHeaderID As String
    
    Screen.MousePointer = vbDefault
    If IsMissing(srcHeaderID) Then
        Message = "Enter Stock Take Header No."
        Title = "Stock Take Exceptional" ' Set title.
        ' Display message, title, and default value.
        tagHeaderID = InputBox(Message, Title)
        If Trim(tagHeaderID) = "" Then
            Exit Sub
        End If
    Else
        tagHeaderID = srcHeaderID
        If Trim(tagHeaderID) = "" Then Exit Sub
    End If
    
    CrwRptName = "ST Exceptional Report"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskHeaderID = " & _
                                                tagHeaderID
        frmCtlCrw.CrystalReport1.SelectionFormula = "{InvtSTDetails.HeaderID} = " & _
                    tagHeaderID & " and {InvtSTDetails.ComputerQty} <> {InvtSTDetails.PhysicalQty}"
        Call PrintIt
     End If

PrintSTExceptional_Exit:                                ' SDVB autocode
    On Error Resume Next                                ' SDVB autocode
    Exit Sub                                            ' SDVB autocode
PrintSTExceptional_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintSTExceptional()", Err)  ' SDVB autocode
    Resume PrintSTExceptional_Exit
End Sub

'------------------------------
' Procedure:  PrintSTJournal
' Purpose:    Printing Stock Take Journal
' Params:
' Returns:    N/A
'------------------------------
Public Sub PrintSTJournal(intDest As Integer, Optional srcHeaderID As Variant)

    On Error GoTo PrintSTJournal_Err

    Dim Message, Title, tagHeaderID As String
    
    Screen.MousePointer = vbDefault
    If IsMissing(srcHeaderID) Then
        Message = "Enter Stock Take Header No."
        Title = "Stock Take Journal" ' Set title.
        ' Display message, title, and default value.
        tagHeaderID = InputBox(Message, Title)
        If Trim(tagHeaderID) = "" Then
            Exit Sub
        End If
    Else
        tagHeaderID = srcHeaderID
        If Trim(tagHeaderID) = "" Then Exit Sub
    End If
    
    CrwRptName = "ST Journal"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskHeaderID = " & _
                                                tagHeaderID
        frmCtlCrw.CrystalReport1.SelectionFormula = "{InvtSTDetails.HeaderID} = " & _
                                                     tagHeaderID
        Call PrintIt
     End If

PrintSTJournal_Exit:                                ' SDVB autocode
    On Error Resume Next                            ' SDVB autocode
    Exit Sub                                        ' SDVB autocode
PrintSTJournal_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintSTJournal()", Err)  ' SDVB autocode
    Resume PrintSTJournal_Exit
End Sub

'------------------------------
' Procedure:  PrintSTWorkBook
' Purpose:    Printing Stock Take WorkBook
' Params:
' Returns:    N/A
'------------------------------
Public Sub PrintSTWorkBook(intDest As Integer, Optional srcHeaderID As Variant)

    On Error GoTo PrintSTWorkBook_Err

    Dim Message, Title, tagHeaderID As String
    
    Screen.MousePointer = vbDefault
    If IsMissing(srcHeaderID) Then
        Message = "Enter Stock Take Header No."
        Title = "Stock Take WorkBook" ' Set title.
        ' Display message, title, and default value.
        tagHeaderID = InputBox(Message, Title)
        If Trim(tagHeaderID) = "" Then
            Exit Sub
        End If
    Else
        tagHeaderID = srcHeaderID
        If Trim(tagHeaderID) = "" Then Exit Sub
    End If
    
    CrwRptName = "ST WorkBook"
    'frmCtlCrw.txtCrwRptName = CrwRptName
    If SetRptFileName(CrwRptName, intDest) Then
        frmCtlCrw.CrystalReport1.Formulas(0) = "AskHeaderID = " & _
                                                tagHeaderID
        frmCtlCrw.CrystalReport1.SelectionFormula = "{InvtSTDetails.HeaderID} = " & _
                                                     tagHeaderID
        Call PrintIt
     End If


PrintSTWorkBook_Exit:                                ' SDVB autocode
    On Error Resume Next                             ' SDVB autocode
    Exit Sub                                         ' SDVB autocode
PrintSTWorkBook_Err:                                 ' SDVB autocode
    Call ofx_GenericError("PrintSTWorkBook()", Err)  ' SDVB autocode
    Resume PrintSTWorkBook_Exit
End Sub

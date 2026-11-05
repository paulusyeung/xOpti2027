Attribute VB_Name = "AppInfoExchange"
Option Explicit


' Move target result into the Xchg Control
Public Sub SetXchgCustomer(strCustomerName As String, strCustomerID As Long)

    On Error GoTo SetXchgCustomer_Err

    XchgCustomer.Text = strCustomerName
    XchgCustomer.Tag = strCustomerID

SetXchgCustomer_Exit:                                ' SDVB autocode
    On Error Resume Next                             ' SDVB autocode
    Exit Sub                                         ' SDVB autocode
SetXchgCustomer_Err:                                 ' SDVB autocode
    If Err = 91 Or Err = 438 Then
        MsgBox "Error 91"
    Else
        Call ofx_GenericError("SetXchgCustomer()", Err)  ' SDVB autocode
    End If
    Resume SetXchgCustomer_Exit

End Sub

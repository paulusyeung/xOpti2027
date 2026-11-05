Attribute VB_Name = "OfxControlUtilities"
'------------------------------------------------------------------------------
' Module:   Ofx - Control Utilities
'
' Purpose:  Control utility functions.
'------------------------------------------------------------------------------

Option Compare Text
Option Explicit


'-----  ListBox_FindString() and ListBox_SelectString()

#If Win32 Then
Declare Function Listbox_SendMessage Lib "user32" Alias "SendMessageA" (ByVal hWnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal sFindText As String) As Long
Public Const LB_FINDSTRING = &H18F
Public Const LB_SELECTSTRING = &H18C
Public Const CB_FINDSTRING = &H14C
Public Const CB_SELECTSTRING = &H14D
#Else
Declare Function Listbox_SendMessage Lib "user" Alias "SendMessage" (ByVal hWnd As Integer, ByVal wMsg As Integer, ByVal wParam As Integer, ByVal sFindText As String) As Long
Global Const WM_USER = &H400
Global Const LB_FINDSTRING = (WM_USER + 16)
Global Const LB_SELECTSTRING = (WM_USER + 13)
Global Const CB_FINDSTRING = (WM_USER + 12)
Global Const CB_SELECTSTRING = (WM_USER + 13)
#End If

'----- Listbox Return Values

Global Const LB_ERR = (-1)
Global Const CB_ERR = (-1)


'------------------------------------------------------------------------------
' Sub:      ofx_SelectText
'
' Purpose:  Use when a textbox or combo box gets the focus to select the text.
'           This way, it works like a normal dialog box.
'
' Params:   ctrl    (I/O) Control for which to select text.
'------------------------------------------------------------------------------
#If Not MSA Then
    Public Sub ofx_SelectText(ctrl As Control)
        ctrl.SelStart = 0
        ctrl.SelLength = Len(ctrl.Text)
    End Sub
#End If

'------------------------------------------------------------------------------
' Function: ofx_ListBoxAddString
'
' Purpose:  Inserts a string AND item data and returns the index.
'
' Params:   ctrl        (I/O) The list box or combo box control
'           sString     (I) String to add
'           nItemData   (I) The numeric datum associated with the string
'
' Returns:  The index of the inserted item, LB_ERR on error
'------------------------------------------------------------------------------
Public Function ofx_ListBoxAddString(ctrl As Control, sString As String, nItemData As Long) As Integer
    On Error GoTo ofx_ListBoxAddString_Err
    
    Dim nIndex As Integer
    
    nIndex = LB_ERR             'assume error
    
    ctrl.AddItem sString
    nIndex = ctrl.NewIndex
    ctrl.ItemData(nIndex) = nItemData
    
ofx_ListBoxAddString_Exit:
    ofx_ListBoxAddString = nIndex
    Exit Function
    
ofx_ListBoxAddString_Err:
    nIndex = LB_ERR
    Resume ofx_ListBoxAddString_Exit
End Function


'------------------------------------------------------------------------------
' Function: ofx_ListBoxFindString
'
' Purpose:  Finds a string in a list or combo box control.
'
' Params:   ctrl        (I) The list box or combo box control
'           sSearch     (I) String for which to search
'
' Returns:  The index of the found string, LB_ERR/CB_ERR on error.
'           Note that zero is a valid return (index of first item in list).
'
' See also: ofx_ListBoxSelectString() which finds AND selects the item.
'------------------------------------------------------------------------------
Public Function ofx_ListBoxFindString(ctrl As Control, sSearch As String) As Integer
    On Error Resume Next

#If Win32 Then
    Dim nMsg As Integer
#Else
    Dim nMsg As Long
#End If

    If TypeOf ctrl Is ListBox Then
        nMsg = LB_FINDSTRING
    ElseIf TypeOf ctrl Is ComboBox Then
        nMsg = CB_FINDSTRING
    Else
        Exit Function
    End If
    
    ofx_ListBoxFindString = Listbox_SendMessage((ctrl.hWnd), nMsg, -1, sSearch)
    
End Function

'------------------------------------------------------------------------------
' Function: ofx_ListBoxGetItemData
'
' Purpose:  Get the item data associated with the currently selected item.
'
' Params:   ctrl    (I) The list box or combo box control
'
' Returns:  Item data for current item in list, 0 on error.
'------------------------------------------------------------------------------
Public Function ofx_ListBoxGetItemData(ctrl As Control) As Long

    On Error Resume Next
    
    Dim nIndex As Integer
    
    nIndex = ctrl.ListIndex
    If (nIndex >= 0) Then
        ofx_ListBoxGetItemData = ctrl.ItemData(nIndex)
    End If

End Function

'------------------------------------------------------------------------------
' Function: ofx_ListBoxReplaceString
'
' Purpose:  Replace the list item at nIndex with the new string.
'
' Params:   ctrl        (I/O) The list box or combo box control
'           nIndex      (I) Index of item to replace
'           sNewItem    (I) New string to replace existing
'
' Returns:  Index of new item (index may differ from old if list is sorted).
'------------------------------------------------------------------------------
Public Function ofx_ListBoxReplaceString(ctrl As Control, nIndex As Integer, sNewItem As String) As Integer
    On Error Resume Next
    
    Dim nData As Long
    
    '----- If the strings match then don't do the replace
    
    If (0 = StrComp((ctrl.list(nIndex)), sNewItem, 0)) Then GoTo ofx_ListBoxReplaceString_Exit
    
    '----- Get data associated with item and remove item
    
    nData = ctrl.ItemData(nIndex)
    ctrl.RemoveItem nIndex

    '----- Add item and its associated data.  Unless list sorted, put it at
    '----- same index as removed item.
    
    If (ctrl.Sorted) Then
        nIndex = ofx_ListBoxAddString(ctrl, sNewItem, nData)
    Else
        ctrl.AddItem sNewItem, nIndex
        ctrl.ItemData(ctrl.NewIndex) = nData
    End If
    
    '----- Select new item
    
    ctrl.ListIndex = nIndex
    
ofx_ListBoxReplaceString_Exit:
    ofx_ListBoxReplaceString = nIndex
    
End Function

'------------------------------------------------------------------------------
' Function: ofx_ListBoxSelectString
'
' Purpose:  Finds a string in a list or combo box control and selects it.
'
' Params:   ctrl        (I/O) The list box or combo box control
'           sSearch     (I) String for which to search
'
' Returns:  The index of the found string, LB_ERR/CB_ERR on error.
'           Note that zero is a valid return (index of first item in list).
'
' See also: ofx_ListBoxFindString() which finds but does not select the item.
'------------------------------------------------------------------------------
Public Function ofx_ListBoxSelectString(ctrl As Control, sSearch As String) As Integer
    
    On Error Resume Next
    
#If Win32 Then
    Dim nMsg As Integer
#Else
    Dim nMsg As Long
#End If
    
    If TypeOf ctrl Is ListBox Then
        nMsg = LB_SELECTSTRING
    ElseIf TypeOf ctrl Is ComboBox Then
        nMsg = CB_SELECTSTRING
    Else
        Exit Function
    End If
    
    ofx_ListBoxSelectString = Listbox_SendMessage((ctrl.hWnd), nMsg, -1, sSearch)

End Function




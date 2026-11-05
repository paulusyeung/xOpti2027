Attribute VB_Name = "AppUnboundGrids"
' This module is used by UnboundGrids

' UnboundGrids define the necessory variables used in DBGrids mode 3
' Special Note:  Variables that store Row indices will be
' of data type Long (It is reasonable to assume there may
' be larger than 32,767 rows).  Those storing Column
' indices will be of type Integer. (It is very unlikely
' there will be more than 32,767 columns.)
Public Type UnboundGrids
    MaxCol As Integer           ' Number of columns
    MaxRow As Long              ' Number of rows
    GridArray() As Variant      ' Array to store the data source
End Type


' Unbound Grid using DataMode 3
' We want to re-use this function for each grid object.
' This function now accept and delete only the caller grid object
Public Function DeleteRow(Bookmark As Variant, Caller As UnboundGrids) As Boolean
    ' DeleteRow is called to logically delete a record
    ' (row) from the array.  The row to be deleted is
    ' given by the Bookmark parameter.

    Dim i As Long, Index As Long
    Dim j As Integer

    ' Figure out which row index the bookmark refers to
    Index = IndexFromBookmark(Bookmark, 0, Caller)
    
    If Index < 0 Or Index >= Caller.MaxRow Then
        'Row index is invalid, so exit the delete,
        ' indicating failure.
        DeleteRow = False
        Exit Function
    End If
    
    ' Decrement the number of rows in the dataset
    Caller.MaxRow = Caller.MaxRow - 1
    
    ' Shift the data in the array to fill the empty
    ' space vacated by the deleted row
    For i = Index To Caller.MaxRow - 1
        For j = 0 To Caller.MaxCol - 1
            Caller.GridArray(j, i) = Caller.GridArray(j, i + 1)
        Next j
    Next i
    
    ' Resize array to free storage space used by deleted
    ' row
    If Caller.MaxRow > 0 Then
        ' If MaxRow = 0, then (MaxRow - 1) equals -1.
        ' This causes an error in the statement below, so
        ' we handle this special case in the Else clause.
        ReDim Preserve Caller.GridArray(0 To Caller.MaxCol - 1, 0 _
              To Caller.MaxRow - 1)
    Else
        ReDim Preserve Caller.GridArray(0 To Caller.MaxCol - 1, 0)
    End If
    DeleteRow = True
'    Call FillLineNumber(Caller)
    
    ' Calibrate scroll bars based on new dataset size
    ' TDBGrid1.ApproxCount = Caller.MaxRow
    ' Removed, as this line only works with the specific grid object
    
End Function


' Unbound Grid using DataMode 3
' We want to re-use this function for each grid object.
' This function now accept and delete only the caller grid object
Public Function GetNewBookmark(Caller As UnboundGrids) As Variant
    ' GetNewBookmark is called when we need to create
    ' a bookmark for a newly added record (row).

    ' Reserve space for the new row in the array
    ReDim Preserve Caller.GridArray(0 To Caller.MaxCol - 1, 0 To Caller.MaxRow)
    
    ' Since the row index of the last record is
    ' (MaxRow - 1), the next available index for the row
    ' to be added is (MaxRow), so create a bookmark for
    ' the new row using MaxRow as an index.
    GetNewBookmark = MakeBookmark(Caller.MaxRow)
    
    ' Increment the number of rows in our dataset
    Caller.MaxRow = Caller.MaxRow + 1
    
    ' Calibrate the scroll bars based on the new dataset size.
    ' TDBGrid1.ApproxCount = MaxRow
    ' Removed, as this line only works with the specific grid object
    
End Function


' Unbound Grid using DataMode 3
' We want to re-use this function for each grid object.
' This function now accept and delete only the caller grid object
Public Function GetRelativeBookmark(Bookmark As Variant, _
        OffSet As Long, Caller As UnboundGrids) As Variant
    ' GetRelativeBookmark is used to get a bookmark for
    ' a row that is a specified number of rows away from
    ' the given row.  Offset specifies the number of rows
    ' to move.  A positive Offset indicates that the
    ' desired row is after the one referred to by Bookmark,
    ' and a negative Offset means it is before the one
    ' referred to by Bookmark.
    
    Dim Index As Long
    
    ' Compute the row index for the desired row
    Index = IndexFromBookmark(Bookmark, OffSet, Caller)
    If Index < 0 Or Index >= Caller.MaxRow Then
        ' Index refers to a row before the first or
        ' after the last, so just return Null.
        GetRelativeBookmark = Null
    Else
        GetRelativeBookmark = MakeBookmark(Index)
    End If
End Function


' Unbound Grid using DataMode 3
' We want to re-use this function for each grid object.
' This function now accept and delete only the caller grid object
Public Function GetUserData(Bookmark As Variant, _
        Col As Integer, Caller As UnboundGrids) As Variant
    ' In this example, GetUserData is called by
    ' UnboundReadData to ask the user what data should
    ' be displayed in a specific cell in the grid.  The
    ' grid row the cell is in is the one referred to by
    ' the Bookmark parameter, and the column it is in it
    ' given by the Col parameter.  GetUserData is called
    ' on a cell-by-cell basis.
    
    Dim Index As Long
        
    ' Figure out which row the bookmark refers to
    Index = IndexFromBookmark(Bookmark, 0, Caller)
    
    If Index < 0 Or Index >= Caller.MaxRow Or Col < 0 Or _
       Col >= Caller.MaxCol Then
        ' Cell position is invalid, so just return null
        ' to indicate failure
        GetUserData = Null
    Else
        GetUserData = Caller.GridArray(Col, Index)
    End If
End Function


' Unbound Grid using DataMode 3
' We want to re-use this function for each grid object.
' This function now accept and delete only the caller grid object
Public Function IndexFromBookmark(Bookmark As Variant, _
        OffSet As Long, Caller As UnboundGrids) As Long
    ' This support function is used only by the remaining
    ' support functions.  It is not used directly by the
    ' unbound events.
    
    ' IndexFromBookmark computes the row index that
    ' corresponds to a row that is (Offset) rows from the
    ' row specified by the Bookmark parameter.  For
    ' example, if Bookmark refers to the index 50 of the
    ' dataset array and Offset = -10, then
    ' IndexFromBookmark will return 50 + (-10), or 40.
    ' Thus to get the index of the row specified by the
    ' bookmark itself, call IndexFromBookmark with an
    ' Offset of 0.  If the given Bookmark is Null, it
    ' refers to BOF or EOF.  If Offset < 0, the grid is
    ' requesting rows before the row specified by
    ' Bookmark, and so we must be at EOF because prior
    ' rows do not exist for BOF.  Conversely, if
    ' Offset > 0, we are at BOF.
    
    Dim Index As Long
    
    If IsNull(Bookmark) Then
        If OffSet < 0 Then
            ' Bookmark refers to EOF.  Since (MaxRow - 1)
            ' is the index of the last record, we can use
            ' an index of (MaxRow) to represent EOF.
            Index = Caller.MaxRow + OffSet
        Else
            ' Bookmark refers to BOF.  Since 0 is the index
            ' of the first record, we can use an index of
            ' -1 to represent BOF.
            Index = -1 + OffSet
        End If
    Else
        ' Convert string to long integer
        Index = Val(Bookmark) + OffSet
    End If
    
    ' Check to see if the row index is valid:
    '  (0 <= Index < MaxRow).
    ' If not, set it to a large negative number to
    ' indicate that it is invalid.
    If Index >= 0 And Index < Caller.MaxRow Then
       IndexFromBookmark = Index
    Else
       IndexFromBookmark = -9999
    End If
End Function


Public Function MakeBookmark(Index As Long) As Variant
    ' This support function is used only by the remaining
    ' support functions.  It is not used directly by the
    ' unbound events.  It is a good idea to create a
    ' MakeBookmark function such that all bookmarks can
    ' be created in the same way.  Thus the method by
    ' which bookmarks are created is consistent and easy
    ' to modify.  This function creates a bookmark when
    ' given an array row index.

    ' Since we have data stored in an array, we will just
    ' use the array index as our bookmark.  We will convert
    ' it to a string first, using the Str$ function.  Thus,
    ' if Index = 27, the Bookmark that is created is the
    ' string " 27".  (Str$ always leaves a leading space
    ' for the sign of the number.)
    
    MakeBookmark = Str$(Index)
End Function


' Unbound Grid using DataMode 3
' We want to re-use this function for each grid object.
' This function now accept and delete only the caller grid object
Public Function StoreUserData(Bookmark As Variant, _
        Col As Integer, Userval As Variant, _
        Caller As UnboundGrids) As Boolean
    ' StoreUserData is called from UnboundWriteData to
    ' write the newly changed information in the grid
    ' to the array.  This function is called once for
    ' each field that needs to be stored.  The grid
    ' cell that this function is called to store is
    ' referenced in the same way as in GetUserData.

    Dim Index As Long
    
    ' Figure out which row the bookmark refers to
    Index = IndexFromBookmark(Bookmark, 0, Caller)
    
    If Index < 0 Or Index >= Caller.MaxRow Or Col < 0 Or _
       Col >= Caller.MaxCol Then
        ' Cell position is invalid, so just return null
        ' to indicate failure
        StoreUserData = False
    Else
        StoreUserData = True
        Caller.GridArray(Col, Index) = Userval
    End If
End Function


' Assume the first column is used for row number
' Used when ClassicDelete is called
Public Sub RowNumberReset(ubgTarget As UnboundGrids)
    Dim i As Integer
    
    With ubgTarget
        For i = 1 To .MaxRow
            .GridArray(0, i - 1) = i
        Next i
    End With
End Sub

' Easiest way to clear the grid
' DataModes = 2 or 3
Public Sub ClearGrid(dbgTarget As TDBGrid, ubgTarget As UnboundGrids)
    With ubgTarget
        .MaxRow = 0
        ReDim .GridArray(0 To .MaxCol - 1, 0)
    End With
    '
    With dbgTarget
        .Bookmark = Null
        .ReBind
    End With
End Sub

' The subroutine is called by RowColChange
' It will step over those Locked columns
Public Sub SetColFocus(dbgTarget As TDBGrid, ubgTarget As UnboundGrids, _
                       LastRow As Variant, ByVal LastCol As Integer)
    Dim blnForward As Boolean
    Dim intRow, intCol As Integer
    Dim intOldXY, intNewXY As Integer
    intRow = dbgTarget.row
    intCol = dbgTarget.Col
    
    ' Determine the direction of movement
    intOldXY = ofx_CInt(LastRow) * ubgTarget.MaxCol + LastCol
    intNewXY = intRow * ubgTarget.MaxCol + intCol
    If intNewXY > intOldXY Then
        blnForward = True
    Else
        blnForward = False
    End If
    
    ' If within X-Y Area, skip locked columns
    If (intRow >= 0 And intRow < (ubgTarget.MaxRow + 1)) And _
       (intCol >= 0 And intCol < ubgTarget.MaxCol) Then
        If dbgTarget.Columns(intCol).Locked = True Then
            If blnForward Then
                SendKeys "{RIGHT}", True
            Else
                SendKeys "{LEFT}", True
            End If
        End If
    End If
End Sub

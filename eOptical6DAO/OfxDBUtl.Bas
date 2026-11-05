Attribute VB_Name = "OfxDatabaseUtilities"
'------------------------------------------------------------------------
' Module:   Ofx - Database Utilities
'
' Purpose:  Database utility functions primarily providing the following
'           functionality for different database API's:
'
'           Lookup      Similar functionality to the MS Access DLookup()
'                       function.  Basically provides for a lookup of a
'                       single value from a table.
'           FillList    Fills a list/combo box control with query results
'
' Notes:    The functions are provided for 4 different database access API's:
'
'           Jet     The Microsoft Jet interface native to MS Access
'           ODBC    The Open Database Connectivity interface available
'                   for a wide range of databases including SQL Server
'                   Sybase, and Oracle.
'           RDO     Remote Data Objects interface (an OLE automation layer over ODBC).
'           VBSQL   A OLE control database interface to DB-library (for SQL Server).
'------------------------------------------------------------------------

Option Explicit

'------------------------------------------------------------------------
' Function: ofx_SplitDSN
'
' Purpose:  Split the database connection string into its constituent parts.
'
' Params:   sConnect    (I) Connection string to split
'           sDatabase   (O) Database name
'           sDSN        (O) Data Source Name (DSN)
'           sUserName   (O) User name
'           sPassword   (O) Password
'------------------------------------------------------------------------
Sub ofx_SplitDSN(sConnect As String, ByRef sDatabase As String, ByRef sDSN As String, ByRef sUserName As String, ByRef sPassword As String)
    On Error GoTo ofx_SplitDSN_Err

    Const sDB As String = "DATABASE="
    Const sDBQ As String = "DBQ="
    Const sDataSourceName As String = "DSN="
    Const sUID As String = "UID="
    Const sPWD As String = "PWD="

    'Database
    If (InStr(sConnect, sDB)) Then
        sDatabase = Mid$(sConnect, InStr(sConnect, sDB) + Len(sDB))
        If (InStr(sDatabase, ";")) Then
            sDatabase = Left$(sDatabase, InStr(sDatabase, ";"))
        End If
    End If
    
    'DBQ for Jet databases
    If (InStr(sConnect, sDBQ)) Then
        sDatabase = Mid$(sConnect, InStr(sConnect, sDBQ) + Len(sDBQ))
        If (InStr(sDatabase, ";")) Then
            sDatabase = Left$(sDatabase, InStr(sDatabase, ";") - 1)
        End If
    End If
    
    'DSN
    If (InStr(sConnect, sDataSourceName)) Then
        sDSN = Mid$(sConnect, InStr(sConnect, sDataSourceName) + Len(sDataSourceName))
        If (InStr(sDSN, ";")) Then
            sDSN = Left$(sDSN, InStr(sDSN, ";") - 1)
        End If
    End If
    
    'UID
    If (InStr(sConnect, sUID)) Then
        sUserName = Mid$(sConnect, InStr(sConnect, sUID) + Len(sUID))
        If (InStr(sUserName, ";")) Then
            sUserName = Left$(sUserName, InStr(sUserName, ";") - 1)
        End If
    End If
    
    'PWD
    If (InStr(sConnect, sPWD)) Then
        sPassword = Mid$(sConnect, InStr(sConnect, sPWD) + Len(sPWD))
        If (InStr(sPassword, ";")) Then
            sPassword = Left$(sPassword, InStr(sPassword, ";") - 1)
        End If
    End If

ofx_SplitDSN_Exit:
    On Error Resume Next
    Exit Sub
ofx_SplitDSN_Err:
    Call ofx_GenericError("ofx_SplitDSN()", Err)
    Resume ofx_SplitDSN_Exit
End Sub


#If DBOPT_RDO And Win32 Then
'------------------------------------------------------------------------
' Function: ofx_rdoFillList
'
' Purpose:  Fill a list or combo box control with the results of a query.
'
' Params:   db      (I) RDO database connection
'           ctrl    (I/O) Control to fill
'           sSql    (I) Query to use
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_rdoLookup(),
'           ofx_jetFillList(), ofx_odbcFillList(), ofx_vbsqlFillList().
'------------------------------------------------------------------------
Public Function ofx_rdoFillList(db As rdoConnection, ctrl As Control, sSql As String) As Boolean
    On Error GoTo ofx_rdoFillList_Error
    
    Dim rs As rdoResultset
    
    If ((Not (db Is Nothing))) Then

        Set rs = db.OpenResultset(sSql, rdOpenForwardOnly, rdConcurReadOnly)
        
        If (Not (rs.BOF)) Then
        
            Dim strAdd As String
            Dim bHasID As Boolean
            Dim i As Integer
            Dim nColumns As Integer
            Dim nStart As Integer
            
            nColumns = rs.rdoColumns.Count
            
            'If the first column in the select list is a "Long" (INTEGER)
            'then we assume that the user wants to store this as item data
            'in the list, not show the number as an item.
            bHasID = (rdTypeINTEGER = rs.rdoColumns(0).Type)
            nStart = IIf(bHasID, 1, 0)
            Do
                
                For i = nStart To nColumns - 1
                    strAdd = strAdd & Nz(rs.rdoColumns(i).Value, "")
                    If (i < (nColumns - 1)) Then strAdd = strAdd & Chr$(9)
                Next i
                            
                ctrl.AddItem strAdd
                strAdd = ""
                            
                If (bHasID) Then
                    ctrl.ItemData(ctrl.NewIndex) = CLng(Nz(rs.rdoColumns(0).Value))
                End If
                
                rs.MoveNext
            Loop Until rs.EOF
        End If
    
    End If
    ofx_rdoFillList = True
    
ofx_rdoFillList_Exit:
    If (Not (rs Is Nothing)) Then rs.Close
    Exit Function
ofx_rdoFillList_Error:
    ofx_GenericError "ofx_rdoFillList()"
    Resume ofx_rdoFillList_Exit
End Function


'------------------------------------------------------------------------
' Function: ofx_rdoLookup
'
' Purpose:  Query (lookup) a single value from a database.
'
' Params:   db      (I) RDO database connection
'           sSql    (I) Query to use
'
' Returns:  The first column of the first row of the results set, else NULL.
'
' See also: ofx_rdoFillList(),
'           ofx_jetLookup(), ofx_odbcLookup(), ofx_vbsqlLookup().
'------------------------------------------------------------------------
Public Function ofx_rdoLookup(db As rdoConnection, sSql As String) As Variant
    On Error GoTo ofx_rdoLookup_Err

    ofx_rdoLookup = Null
    
    Dim rs As rdoResultset
    
    If (Not (db Is Nothing)) Then
        Set rs = db.OpenResultset(sSql, rdOpenForwardOnly, rdConcurReadOnly)
        If (Not (rs.BOF)) Then
            ofx_rdoLookup = rs(0)
        End If
    End If

ofx_rdoLookup_Exit:
    On Error Resume Next
    Exit Function
ofx_rdoLookup_Err:
    Call ofx_GenericError("ofx_rdoLookup()", Err)
    Resume ofx_rdoLookup_Exit
End Function
#End If



#If DBOPT_ODBC Then
'------------------------------------------------------------------------
' Function: ofx_odbcFillList
'
' Purpose:  Fill a list or combo box control with the results of a query.
'
' Params:   hDbc    (I) ODBC database handle
'           ctrl    (I/O) Control to fill
'           sSql    (I) Query to use
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_odbcLookup(),
'           ofx_jetFillList(), ofx_rdoFillList(), ofx_vbsqlFillList().
'------------------------------------------------------------------------
Public Function ofx_odbcFillList(hdbc As Long, ctrl As Control, sSql As String) As Boolean
    On Error GoTo ofx_odbcFillList_Error
        
    Dim nRetCode As Integer
    Dim hstmt As Long
    
    Dim sBuf As String
    sBuf = String$(256, 0)
    
    If (0 = hdbc) Then Exit Function
        
    nRetCode = SQLAllocStmt(hdbc, hstmt)
    If (SQL_SUCCESS = nRetCode) Then
    
        Dim i As Integer
        Dim nID As Long
        Dim strAdd As String
        Dim nStart As Integer

        nRetCode = SQLExecDirect(hstmt, sSql, SQL_NTS)
        If (SQL_SUCCESS = nRetCode) Then
            
            Dim nColumns As Integer
            nRetCode = SQLNumResultCols(hstmt, nColumns)
           
            ReDim nColumnLen(nColumns) As Long
            
            Dim sCol1 As String
            Dim cbBytes As Long
 
            Dim nType As Long
            nRetCode = SQLColAttributes(hstmt, 1, _
                    SQL_COLUMN_TYPE, 0&, 0&, 0&, nType)
            If (SQL_SUCCESS = nRetCode) Then
            
                Dim bHasID As Boolean
                bHasID = (SQL_C_LONG = nType)
                
                'If the first column in the select list is a "Long" (INTEGER)
                'then we assume that the user wants to store this as item data
                'in the list, not show the number as an item.
                nStart = IIf(bHasID, 1, 0)
    
                For i = nStart To nColumns - 1
                    Dim nLen As Long
                    nRetCode = SQLColAttributes(hstmt, (i + 1), _
                        SQL_COLUMN_LENGTH, 0&, 0&, 0&, nColumnLen(i))
                Next
    
                Do
                
                    nRetCode = SQLFetch(hstmt)
                    If (SQL_SUCCESS = nRetCode Or SQL_SUCCESS_WITH_INFO = nRetCode) Then
                                
                        For i = nStart To nColumns - 1
                            
                            nRetCode = SQLGetData(hstmt, (i + 1), _
                                SQL_C_CHAR, sBuf, 256, cbBytes)
                                
                            If (SQL_SUCCESS = nRetCode Or SQL_SUCCESS_WITH_INFO = nRetCode) Then
                                                    
                                'Check for NULL
                                If (SQL_NULL_DATA <> cbBytes) Then
                                    strAdd = strAdd & Left$(sBuf, cbBytes)
                                End If
        
                                If (i < (nColumns - 1)) Then
                                    strAdd = strAdd & Chr$(9)
                                End If
                            Else
                                ofx_odbcReportError hdbc, hstmt
                            End If
                        Next
                        
                        ctrl.AddItem strAdd
                        
                        If (bHasID) Then
                            If (SQL_SUCCESS = SQLGetNumericData(hstmt, 1, _
                                SQL_C_LONG, nID, 4, cbBytes)) Then

                                ctrl.ItemData(ctrl.NewIndex) = nID
                            End If
                        End If
    
                        strAdd = ""
                    
                    ElseIf (SQL_NO_DATA_FOUND = nRetCode) Then
                    
                        '// no match
                    
                    ElseIf (SQL_ERROR = nRetCode) Then
                        'SQLFetch error
                        ofx_odbcReportError hdbc, hstmt
                    End If
                        
                Loop While (SQL_SUCCESS = nRetCode)

            End If      'SQLColAttributes
                        
        Else
            ' Error in SQLExecDirect
            ofx_odbcReportError hdbc, hstmt
        End If 'SQLExecDirect
        
    End If  'SQLAllocStatement

    ofx_odbcFillList = True
    
ofx_odbcFillList_Exit:
    If (hstmt) Then
        nRetCode = SQLFreeStmt(hstmt, SQL_DROP)
    End If
    
    Exit Function
ofx_odbcFillList_Error:
    ofx_GenericError "ofx_odbcFillList()"
    Resume ofx_odbcFillList_Exit
End Function






'------------------------------------------------------------------------
' Function: ofx_odbcLookup
'
' Purpose:  Query (lookup) a single value from a database.
'
' Params:   hDbc    (I) ODBC database handle
'           sSql    (I) Query to use
'
' Returns:  The first column of the first row of the results set, else NULL.
'
' See also: ofx_odbcFillList(),
'           ofx_jetLookup(), ofx_rdoLookup(), ofx_vbsqlLookup().
'------------------------------------------------------------------------
Public Function ofx_odbcLookup(hdbc As Long, sSql As String) As Variant
    On Error GoTo ofx_odbcLookup_Err

    Dim nRetCode As Integer
    Dim hstmt As Long
    Dim cbBytes As Long
    
    ofx_odbcLookup = Null
    
    If (Not (hdbc)) Then Exit Function
    
    nRetCode = SQLAllocStmt(hdbc, hstmt)
    If (SQL_SUCCESS = nRetCode) Then
        
        nRetCode = SQLExecDirect(hstmt, sSql, SQL_NTS)
        If (SQL_SUCCESS = nRetCode) Then
            
            Dim nColumns As Integer
            nRetCode = SQLNumResultCols(hstmt, nColumns)
            
            Dim nRows As Long
            nRetCode = SQLRowCount(hstmt, nRows)
            
            Dim nType As Long
            nRetCode = SQLColAttributes(hstmt, 1, _
                    SQL_COLUMN_TYPE, 0&, 0&, 0&, nType)
                    
            If (nColumns = 1) Then
                    
                Dim nLen As Long
                nRetCode = SQLColAttributes(hstmt, 1, _
                    SQL_COLUMN_LENGTH, ByVal 0&, 0, ByVal 0&, nLen)
                
                nRetCode = SQLFetch(hstmt)
                If (SQL_SUCCESS = nRetCode Or SQL_SUCCESS_WITH_INFO = nRetCode) Then
                    
                    Dim sBuf As String
                    sBuf = String$(nLen + 1, 0)
                    If (SQL_SUCCESS = SQLGetData(hstmt, 1, _
                        SQL_C_CHAR, sBuf, nLen, cbBytes)) Then
                        
                            ofx_odbcLookup = CVar(Left$(sBuf, cbBytes))
                                        
                    ElseIf (SQL_NO_DATA_FOUND = nRetCode) Then
                        'no match, keep the null
                    ElseIf (SQL_ERROR = nRetCode) Then
                        ofx_odbcReportError hdbc, hstmt
                    End If
                    
                End If  'SQLFetch

            End If 'If (nColumns = 1 And nRows = 1) Then
                       
        ElseIf (SQL_ERROR = nRetCode) Then
            ofx_odbcReportError hdbc, hstmt
        End If 'SQLExecDirect
        
        SQLFreeStmt hstmt, SQL_DROP
    
    End If  'SQLAllocStatement

ofx_odbcLookup_Exit:
    On Error Resume Next
    Exit Function
ofx_odbcLookup_Err:
    Call ofx_GenericError("ofx_odbcLookup()", Err)
    Resume ofx_odbcLookup_Exit
End Function



'------------------------------------------------------------------------
' Sub: ofx_odbcReportError
'
' Purpose:  Displays a message box with the current ODBC error.
'
' Params:   hDbc    (I) ODBC HDBC handle.
'           hStmt   (I) ODBC HSTMT handle.
'
' Notes:    This function uses the class CDBException (OfxDBExcp.cls) to
'           display the current ODBC error. See the CDBException implementation
'           for more detail.
'
' See Also: class CDBException
'------------------------------------------------------------------------
Public Sub ofx_odbcReportError(hdbc As Long, hstmt As Long)
    On Error Resume Next
    Dim e As New CDBException
    e.BuildErrorString ofxApp.dbState.hEnv, hdbc, hstmt
    e.ReportError
    Set e = Nothing
End Sub

#End If


#If DBOPT_JET Then
'------------------------------------------------------------------------
' Function: ofx_jetFillList
'
' Purpose:  Fill a list or combo box control with the results of a query.
'
' Params:   db      (I) Database
'           ctrl    (I/O) Control to fill
'           sSql    (I) Query to use
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_jetLookup(),
'           ofx_rdoFillList(), ofx_odbcFillList(), ofx_vbsqlFillList().
'------------------------------------------------------------------------
Public Function ofx_jetFillList(db As Database, ctrl As Control, sSql As String) As Boolean
    On Error GoTo ofx_jetFillList_Error
    
    Dim rs As Recordset
    
    If (Not (db Is Nothing)) Then

        'dbSQLPassThrough has no effect on Jet databases
        Set rs = db.OpenRecordset(sSql, dbOpenSnapshot, dbForwardOnly Or dbSQLPassThrough)
        
        If (Not (rs.BOF)) Then
        
            Dim strAdd As String
            Dim bHasID As Boolean
            Dim i As Integer
            
            'Assume that the first column is meant as ItemData
            bHasID = ((dbLong = rs.Fields(0).Type) And (rs.Fields.Count > 1))
            Do
                For i = IIf(bHasID, 1, 0) To rs.Fields.Count - 1
                    strAdd = strAdd & CStr(Nz(rs(i), ""))
                    If (i < (rs.Fields.Count - 1)) Then strAdd = strAdd & Chr$(9)
                Next i
                            
                ctrl.AddItem strAdd
                strAdd = ""
                            
                If (bHasID) Then
                    ctrl.ItemData(ctrl.NewIndex) = rs(0)
                End If
                
                rs.MoveNext
            Loop Until rs.EOF
        End If
    
    End If
       
    ofx_jetFillList = True
    
ofx_jetFillList_Exit:
    If (Not (rs Is Nothing)) Then rs.Close
    Exit Function
ofx_jetFillList_Error:
    ofx_GenericError "ofx_jetFillList()"
    Resume ofx_jetFillList_Exit
End Function




'------------------------------------------------------------------------
' Function: ofx_jetLookup
'
' Purpose:  Query (lookup) a single value from a database.
'
' Params:   db      (I) Database
'           sSql    (I) Query to use
'
' Returns:  The first column of the first row of the results set, else NULL.
'
' See also: ofx_jetFillList(),
'           ofx_rdoLookup(), ofx_odbcLookup(), ofx_vbsqlLookup().
'------------------------------------------------------------------------
Public Function ofx_jetLookup(db As Database, sSql As String) As Variant
    On Error GoTo ofx_jetLookup_Err
            
    ofx_jetLookup = Null
    
    Dim rs As Recordset
    
    If (Not (db Is Nothing)) Then
        Set rs = db.OpenRecordset(sSql, dbOpenSnapshot, dbForwardOnly)
        If (Not (rs.BOF)) Then
            ofx_jetLookup = rs(0)
        End If
    End If
    
ofx_jetLookup_Exit:
    On Error Resume Next
    If (Not (rs Is Nothing)) Then rs.Close
    Exit Function
ofx_jetLookup_Err:
    Call ofx_GenericError("ofx_jetLookup()", Err)
    Resume ofx_jetLookup_Exit
End Function

#End If



#If DBOPT_VBSQL Then
'------------------------------------------------------------------------
' Function: ofx_vbsqlFillList
'
' Purpose:  Fill a list or combo box control with the results of a query.
'
' Params:   sqlConn     (I) VBSQL database connection
'           ctrl        (I/O) Control to fill
'           sSql        (I) Query to use
'
' Returns:  TRUE on success, else FALSE.
'
' See also: ofx_vbsqlLookup(),
'           ofx_jetFillList(), ofx_odbcFillList(), ofx_rdoFillList().
'------------------------------------------------------------------------
#If Win32 Then
Public Function ofx_vbsqlFillList(SqlConn As Long, ctrl As Control, sSql As String) As Boolean
#Else
Public Function ofx_vbsqlFillList(SqlConn As Integer, ctrl As Control, sSql As String) As Boolean
#End If
    On Error GoTo ofx_vbsqlFillList_Error
    
    Dim nRetCode As Long
    
    If (SqlConn) Then
    
        OFXVBSQLTRY SqlConn, SqlSendCmd(SqlConn, sSql)
        If (NOMORERESULTS <> (OFXVBSQLTRY(SqlConn, SqlResults(SqlConn)))) Then
                
            Dim nColumns As Long
            nColumns = OFXVBSQLTRY(SqlConn, SqlNumCols(SqlConn))
            If (nColumns > 0) Then
            
                Dim strAdd As String
                Dim bHasID As Boolean
                Dim i As Integer
            
                'Assume that the first column is meant as ItemData
                bHasID = ((SQLINT4 = OFXVBSQLTRY(SqlConn, SqlColType(SqlConn, 1))) And (nColumns > 1))
            
                Do Until (NOMOREROWS = OFXVBSQLTRY(SqlConn, SqlNextRow(SqlConn)))
             
                    For i = IIf(bHasID, 2, 1) To nColumns
                        strAdd = strAdd & SqlData(SqlConn, i)
                        If (i < nColumns) Then strAdd = strAdd & Chr$(9)
                    Next
                    
                    ctrl.AddItem strAdd
                    strAdd = ""
                                
                    If (bHasID) Then
                        ctrl.ItemData(ctrl.NewIndex) = CLng(SqlData(SqlConn, 1))
                    End If
                    
                Loop
            
            End If 'column count > 0
            
        End If
    
    End If
       
    ofx_vbsqlFillList = True
    
ofx_vbsqlFillList_Exit:
    Exit Function
ofx_vbsqlFillList_Error:
    ofx_GenericError "ofx_vbsqlFillList()"
    SqlCancelResults SqlConn
    Resume ofx_vbsqlFillList_Exit
End Function




'------------------------------------------------------------------------
' Function: ofx_vbsqlLookup
'
' Purpose:  Query (lookup) a single value from a database.
'
' Params:   sqlConn     (I) VBSQL database connection
'           sSql        (I) Query to use
'
' Returns:  The first column of the first row of the results set, else NULL.
'
' See also: ofx_vbsqlFillList(),
'           ofx_jetLookup(), ofx_odbcLookup(), ofx_rdoLookup().
'------------------------------------------------------------------------
#If Win32 Then
Public Function ofx_vbsqlLookup(SqlConn As Long, sSql As String) As Variant
#Else
Public Function ofx_vbsqlLookup(SqlConn As Integer, sSql As String) As Variant
#End If
    On Error GoTo ofx_vbsqlLookup_Err
            
    ofx_vbsqlLookup = Null
    
    If (SqlConn) Then
                
        If (ofx_sqlOpenResultset(SqlConn, sSql)) Then
            ofx_vbsqlLookup = ofx_sqlGetData(SqlConn, 1)
        End If
            
        'process (and discard) all following results
        Do Until (NOMOREROWS = OFXVBSQLTRY(SqlConn, SqlNextRow(SqlConn)))
            #If DBG Then
                Debug.Print "Query returned more than one value."
            #End If
        Loop

    End If
    
ofx_vbsqlLookup_Exit:
    On Error Resume Next
    Exit Function
ofx_vbsqlLookup_Err:
    Call ofx_GenericError("ofx_vbsqlLookup()", Err)
    SqlCancelResults SqlConn
    Resume ofx_vbsqlLookup_Exit
End Function


#End If         'DBOPT_VBSQL


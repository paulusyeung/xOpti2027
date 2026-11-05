Attribute VB_Name = "AppData"
'------------------------------------------------------------------------------
' Module:   AppData
'
' Some general considerations:
'
' In most applications, there will only be 1 "database" created at a time.
' While the framework actually supports many databases of ANY
' of the four main types (Jet, ODBC, RDO, VBSQL),
' in practice, we would assume that no more than 1 or 2 would be created
' during a single version of an application.
'
' A much more common senario is that you may want to change your database protocol in a
' new version of your application, and this can be a tricky task.  (At least)
'
' This is the idea behind the CDatabaseHolder class.  A database holder helps make storing
' settings, connecting, disconnecting, creating environments, ... easier and quite a bit safer.
' You should be able to use the current implementation to store persistant data about the database
' (in the registry or INI file), Open all application specific databases, and safely manage security,
' environments, Connection and Disconnection.
' The only thing you may want to do is add a way to "get" a database object, or, in the case of
' everything BUT Jet, a way to get right to the database handle (HDBC).
'
' So, there are a couple of procedures here that may require some slight customization
' by the developer, and some that may seem downright wacky.  So, before you get
' bored and start ripping out code, ...
'
' Procedures you may need to change for your implementation:
'
'   IsDatabaseOpen()
'       You may want to change it to return True only if one database is open, not all of them.
'       or you may get slightly better performance if you just want to check for
'       ofxApp.dbList.Item(0).IsOpen = True, and not iterate through the list.
'
'   GetDB()
'
'       So, the basic idea is:
'           1. You call PopulateDatabaseList in InitInstance()
'           2. In your OnFileOpen() procedure (or some equivelent)
'              You call OpenDatabase( <ofxApp.dbList.Item.DatabaseName> ) for each of the databases
'              that you intend to open.
'           3. Inside OpenDatabase, you get the correct username/password by calling OnLogon()
'           4. You call (CDatabaseHolder)dbList.Item.CreateEnvironment member (done in OpenDatabase() in this module)
'           5. Then, if CreateEnvironment works, you call (CDatabaseHolder)dbList.Item.OpenDatabase()
'           6. If OpenDatabase works, then you call (CDatabseHolder)dbList.Item.GetDatabase or GetDB() to work
'              with the actual database.
'
'       Note:
'           Its not as bad as it seems.  The big bang here is:  you get an easy, inexpensive way to get to
'           ANY type of database, and, there is already an implementation for you.
'------------------------------------------------------------------------------

Option Explicit

'This app constants
Public Const dbErrNoOpenDatabases As Integer = 1007
Public Const dbErrNoOpenDatabasesMsg As String = "There are no open databases."


'------------------------------------------------------------------------------
' Function: IsDatabaseOpen
'
' Purpose:  Determine if database(s) is/are open.
'
' Returns:  True if all databases in the global ofxApp.dbList are open
'------------------------------------------------------------------------------
Public Function IsDatabaseOpen() As Boolean
    On Error Resume Next
    
    If (Not (ofxApp.dbList Is Nothing)) Then
        
        'If ONE of the databases is NOT open, then bail
        Dim dbHolder As CDatabaseHolder
        For Each dbHolder In ofxApp.dbList
            If (Not (dbHolder.IsOpen)) Then Exit Function
        Next dbHolder
        
        IsDatabaseOpen = True
    End If
    
End Function


'------------------------------------------------------------------------------
' Function: GetDB
'
' Purpose:  Works sort of like an array operator, use to get the Database Holder object
'           represented by sName
'
' Example:  Dim db as CDatabaseHolder
'           Set db = GetDB("Database 1")
'
'           OR just use the return value
'
'           GetDB("Database 1").FillList frmMain.List1, "SELECT cust_name FROM tbl_customers ORDER BY cust_name"
'
'           OR (if there is only 1 database
'
'           Same thing as:
'
'           Dim db as CDatabaseHolder
'           Set db = ofxApp.dbList.Item("Database 1")
'           (but with error checking)
'------------------------------------------------------------------------------
Public Function GetDB(Optional vNameOrIndex As Variant) As CDatabaseHolder
    'NO Error handling, we want to 'bubble up'
    
    Dim dbHolder As CDatabaseHolder
       
    
    If (ofxApp.nDbCount) Then
        'may throw an error
        If (Not (IsMissing(vNameOrIndex))) Then
            Set dbHolder = ofxApp.dbList(vNameOrIndex)
        Else
            Set dbHolder = ofxApp.dbList(1)
        End If
        
        Set GetDB = dbHolder
    Else
        Err.Clear
        Err.Raise dbErrNoOpenDatabases, ofxApp.sAppName, dbErrNoOpenDatabasesMsg
    End If
    
End Function

'------------------------------------------------------------------------------
' Function: OnLogon
'
' Purpose: Gets the user/pwd for the database
'------------------------------------------------------------------------------
Public Function OnLogon(ByVal nType As Integer, ByVal sDatabaseName As String, ByRef sUserName As String, ByRef sPassword As String) As Boolean
    On Error GoTo OnLogon_Error
    
    'TO DO: Implement database type specific logon procedures
    Select Case nType
        
        'You don't "have" to ask for a username/password for
        'jet databases, but in this case, it may be a good idea
        
        Case dbHolderTypeJet, dbHolderTypeVBSQL, dbHolderTypeODBC, dbHolderTypeRDO
            
            dlgLogon.UserName = sUserName
            dlgLogon.Password = sPassword
            dlgLogon.DatabaseName = sDatabaseName   'Displayed in the dlgLogon caption
            
            If (ofx_DoModal(dlgLogon)) Then
                sUserName = dlgLogon.UserName
                sPassword = dlgLogon.Password
                ofx_CloseForm dlgLogon
                
                OnLogon = True
            End If

        Case Else
            OnLogon = True
    End Select
    
   
OnLogon_Exit:
    Exit Function
OnLogon_Error:
    ofx_GenericError "OnLogon()"
    Resume OnLogon_Exit
End Function

'------------------------------------------------------------------------------
' Function: OpenDatabase
'
' Purpose:  Open a database of any type.
'------------------------------------------------------------------------------
Public Function OpenDatabase(sName As String) As Boolean
    On Error GoTo OpenDatabase_Error
    
    Dim dbHolder As CDatabaseHolder
    Set dbHolder = GetDB(sName)
       
    If (dbHolder.IsOpen) Then
        OpenDatabase = True
    Else
    
        Dim sUserName As String, sPassword As String
    
        If (dbHolder.GetSettings()) Then    'gets the DSN, DBQ, Database, UserName
            
            sUserName = dbHolder.UserName
            
            Do While (OnLogon(dbHolder.DatabaseType, dbHolder.Name, sUserName, sPassword))
                'Set the user, password
                If (dbHolder.CreateEnvironment(sUserName, sPassword)) Then
                    
                    'actually open the database
                    If (dbHolder.OpenDatabase()) Then
                        OpenDatabase = True
                        Exit Do
                    End If
                End If
            Loop
        Else
            MsgBox "Error retrieving registry settings for " & dbHolder.Name, vbInformation
        End If
    End If
    
OpenDatabase_Exit:
    Exit Function
OpenDatabase_Error:
    ofx_GenericError "AppMain::OpenDatabase()"
    Resume OpenDatabase_Exit
End Function
'------------------------------------------------------------------------------
' Function: PopulateDatabaseList
'
' Purpose:  Initilizes the global ofxApp.dbList Collection.
'
'           This procedure is left in the AppMain module because we thought that
'           many developers would want to have control over this function, the default implementation
'           is complete, it reads the registry for the "names" and "types" of databases to open,
'           then constructs a CDatabaseHolder object for each one.
'------------------------------------------------------------------------------
Public Function PopulateDatabaseList() As Boolean
    On Error GoTo PopulateDatabaseList_Error
    
    #If DBG Then
        ASSERT (ofxApp.dbList Is Nothing), "AppMain::PopulateDatabaseList()", "PopulateDatabaseList is being called a second time!"
    #End If
    
    'list of the Databases keys
    Dim sDatabaseSecs() As String
    
    
    'registry is like this
    '   HKEY_LOCAL_MACHINE\Software\<App.CompanyName>\<App.ProductName>\Databases
    '           (value names under this section, 1 for each "database" section, all should be REG_SZ (Win32))
    '       <Database 1 name>
    '       <Database 2 name>
    '       ...
    '
    '      each database section may have the following values
    '           HKEY_LOCAL_MACHINE\Software\<App.CompanyName>\<App.ProductName>\Databases\<Database 1 name>
    '               (REG_DWORD) Type = dbHolderTypeJet, dbHolderTypeODBC, dbHolderTypeRDO, dbHolderTypeVBSQL
    '               (REG_SZ) Database =
    '                       if 'Type' is dbHolderTypeJet, <c:\myapp\...db1.mdb>
    '                       if 'Type' is dbHolderTypeODBC or dbHolderTypeRDO, <depends on the driver>
    '                       if 'Type' is dbHolderTypeVBSQL, <database name>
    '               (REG_SZ) DSN =
    '                       Applies only if 'Type' is dbHolderTypeODBC or dbHoderTypeRDO
    
    
    'So, first get the list of Databases
    Dim nDbCount As Integer
    nDbCount = ofx_ProfileEnumKeys("Databases", sDatabaseSecs())
    
    If (nDbCount) Then
    
        'construct the global collection
        Set ofxApp.dbList = New Collection
        
        Dim i As Integer
        
        For i = 1 To nDbCount
            
            'create a New instance each time, then clobber it after the add
            Dim dbHolder As New CDatabaseHolder
            
            'Name is the section name in the INI/Registry
            dbHolder.Name = sDatabaseSecs(i - 1)
            'Type MUST be one of the legal types dbHolderType<Jet,RDO,ODBC,VBSQL>
            dbHolder.DatabaseType = ofx_ProfileGetInt(sDatabaseSecs(i - 1), "Type", dbHolderTypeJet)
            
            ofxApp.dbList.Add dbHolder, dbHolder.Name
            Set dbHolder = Nothing
            
        Next
        
        ofxApp.nDbCount = ofxApp.dbList.Count
    
    End If
    
    PopulateDatabaseList = True
    
PopulateDatabaseList_Exit:
    Exit Function
PopulateDatabaseList_Error:
    ofx_GenericError "PopulateDatabaseList()"
    Resume PopulateDatabaseList_Exit
End Function





'------------------------------------------------------------------------------
' Function: CloseAllDatabases
'
' Purpose:  Close all open databases.
'
' Returns:  TRUE on success, else FALSE.
'------------------------------------------------------------------------------
Function CloseAllDatabases() As Boolean
    On Error GoTo CloseAllDatabases_Error
    
    If ((Not (ofxApp.dbList Is Nothing)) And (ofxApp.nDbCount > 0)) Then
        
        'normal clean up...
        'Close database, free environment...
        Dim dbHolder As CDatabaseHolder
        For Each dbHolder In ofxApp.dbList
            dbHolder.CloseDatabase
        Next dbHolder
        
        Dim i As Integer
        For i = 1 To ofxApp.dbList.Count
            ofxApp.dbList.Remove 1
        Next i
        
        ofxApp.nDbCount = 0
        Set ofxApp.dbList = Nothing
        
    End If
    
    CloseAllDatabases = True        'No errors
    
CloseAllDatabases_Exit:
    Exit Function
CloseAllDatabases_Error:
    ofx_GenericError "CloseAllDatabases()"
    Resume CloseAllDatabases_Exit
End Function





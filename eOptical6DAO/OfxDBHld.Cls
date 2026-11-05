VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CDatabaseHolder"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
'------------------------------------------------------------------------------
' Class:    CDatabaseHolder
'
' Purpose:  Encapsulates the functionality of a database.
'
' Notes:    This class supports any one of the four Framework supported database types
'           with one "virtual" interface.
'
' Example:  Dim dbHolder As CDatabaseHolder
'           Set dbHolder = GetDB(sName)
'
'           Dim sUserName As String, sPassword As String
'
'           'gets the Name, DSN or Filename, Server, Database, UserName from the Profile file
'           If (dbHolder.GetSettings()) Then
'
'               'Set the user, password (use the default user (from the profile ))
'               If (dbHolder.CreateEnvironment(dbHolder.UserName, sPassword)) Then
'
'                   'actually open the database
'                   If (dbHolder.OpenDatabase()) Then'
'                      ... now do something with the database
'                   End If
'               End If
'           End If
'
'           Other "virtual" methods
'
'           FillList
'           OpenRecordset
'           DLookup
'           Execute
'
'           BeginTrans
'           EndTrans
'           CommitTrans
'
'           OpenDatabase
'           CloseDatabase
'
'           CreateEnvironment
'           GetSettings
'
'           GetDatabase
'           GetEnvironment
'------------------------------------------------------------------------------

Option Explicit

'Private stuff, Let/Get procedures are at the end of this module


Private m_sUserName As String               'Stored with CreateEnvironment
Private m_sPassword As String               'Stored with CreateEnvironment

Private m_sName As String                   'This name is also the Section in the INI/Registry file
Private m_nType As Integer                  'MUST be one of the 4 defined types
                                            'dbHolderType* (Jet, ODBC, VBSQL, RDO)

Private m_bIsOpen As Boolean                'True if OpenDatabase() has been called at least once succesfully
Private m_bIsConstructed As Boolean         'CreateEnvironment has been called

Private m_sDSN As String
Private m_sDatabase As String
Private m_sServer As String
Private m_sConnect As String

' Only valid after an Execute
Private m_nRowsAffected As Long

' generic to all types
Private m_nLoginTimeout As Long
Private m_nQueryTimeout As Long

' Only include the variables we are going to use
Private m_sSystemDB As String               'Jet ONLY, the system database

Private m_sDriver As String                 'RDO AND ODBC

#If DBOPT_JET Then
    Private m_wsJet As Workspace
    Private m_dbJet As Database
    Private m_bUseOdbc As Boolean
#End If

#If DBOPT_ODBC Then
    'one instance for the whole app, no matter how many CDatabase objects opened
    Private m_dbState As CDBState
    Private m_dbODBC As CDatabase
#End If

#If DBOPT_RDO And Win32 Then
    Private m_dbRdoEnv As rdoEnvironment
    Private m_dbRdoConn As rdoConnection
#End If

#If DBOPT_VBSQL Then
    'there is no "environment" really, just a version string
    Private m_sDBLibVersion As String
#If Win32 Then
    Private m_vbsqlConn As Long
#Else
    Private m_vbsqlConn As Integer
#End If
#End If


'------------------------------------------------------------------------------
' Method:   GetDatabase
'
' Purpose:  Returns the specific database object
'
' Returns:  The "real" database object.
'
' Notes:    The database "object" in the case of VBSQL is actually a Connection
'           handle (long).  This makes the code slightly less polymorphic, but also
'           easier to use.
'------------------------------------------------------------------------------
Public Function GetDatabase() As Variant

    On Error GoTo GetDatabase_Err

    Select Case m_nType
    
    #If DBOPT_JET Then
        Case dbHolderTypeJet
            Set GetDatabase = m_dbJet
    #End If
    
    #If DBOPT_ODBC Then
        Case dbHolderTypeODBC
            Set GetDatabase = m_dbODBC
    #End If
    
    #If DBOPT_RDO And Win32 Then
        Case dbHolderTypeRDO
            Set GetDatabase = m_dbRdoConn
    #End If
    
    #If DBOPT_VBSQL Then
        Case dbHolderTypeVBSQL
            GetDatabase = m_vbsqlConn
    #End If
    
    End Select


GetDatabase_Exit:
    On Error Resume Next
    Exit Function
GetDatabase_Err:
    Call ofx_GenericError("GetDatabase()", Err)
    Resume GetDatabase_Exit

End Function

'------------------------------------------------------------------------------
' Method:   GetEnvironment
'
' Purpose:  Returns the "real" environment object
'
' Notes:    Note that in the case of VBSQL, the database object is
'           actually a string returned by SQLInit().
'------------------------------------------------------------------------------
Public Function GetEnvironment() As Variant

    On Error GoTo GetEnvironment_Err

    Select Case m_nType
    
    #If DBOPT_JET Then
        Case dbHolderTypeJet
            Set GetEnvironment = m_wsJet
    #End If
    
    #If DBOPT_ODBC Then
        Case dbHolderTypeODBC
            Set GetEnvironment = m_dbState
    #End If
    
    #If DBOPT_RDO And Win32 Then
        Case dbHolderTypeRDO
            Set GetEnvironment = m_dbRdoEnv
    #End If
    
    #If DBOPT_VBSQL Then
        Case dbHolderTypeVBSQL
            GetEnvironment = m_sDBLibVersion
    #End If
    
    End Select


GetEnvironment_Exit:
    On Error Resume Next
    Exit Function
GetEnvironment_Err:
    Call ofx_GenericError("GetEnvironment()", Err)
    Resume GetEnvironment_Exit

End Function


'------------------------------------------------------------------------------
' Method:   CreateEnvironment
'
' Purpose:  Creates the "environment" specific to the type of database.
'
' Params:   opvsUserName  (I) The user name.
'           opvsPassword  (I) The password.
'
' Returns:  True if successful, False otherwise.
'
' Notes:    In the case of Jet/DAO, the environment may be the default
'           workspace.  If you need to create a secure workspace, then
'           you MUST supply the SystemDB in the registry under the database "key"
'
'           When using the Framework ODBC classes, this function will initialize the
'           global CDBState object.
'------------------------------------------------------------------------------
Public Function CreateEnvironment(Optional opvsUserName As Variant, Optional opvsPassword As Variant) As Boolean
    On Error GoTo CreateEnvironment_Error
    
    'strictly speaking, the username, password are not required for Jet databases
    If (Not (IsMissing(opvsUserName))) Then
        m_sUserName = opvsUserName
    End If
    If (Not (IsMissing(opvsPassword))) Then
        m_sPassword = opvsPassword
    End If
    
        
    If (0 = m_nType) Then
        Err.Clear
        Err.Raise dbHolderErrTypeNotSet, App.Title, dbHolderErrTypeNotSetMsg
        Exit Function
    End If
    
    
    Select Case m_nType
    
    #If DBOPT_JET Then
        Case dbHolderTypeJet
        
            If (Not (m_bIsConstructed)) Then
            
                If (Not (m_wsJet Is Nothing)) Then
                    If (m_wsJet.Databases.Count = 0) Then
                        m_wsJet.Close
                    End If
                    Set m_wsJet = Nothing
                End If
                            
                'if we want to use Jet security, then we have to setup the
                'workspace, in Win32, DAO needs a location to the system DB in the Registry
                'in Win16, we need an [Options] section in OUR .INI file.
                
                'Important:  The FIRST data access statement MUST be DBEngine.INIPath!
                If (ofx_FileExists(m_sSystemDB)) Then
                    #If Win32 Then
                        ofx_ProfileWriteString "Engines\Jet", "SystemDB", m_sSystemDB
                        DBEngine.IniPath = "HKEY_LOCAL_MACHINE\Software\" & ofxApp.sCompany & "\" & ofxApp.sAppName
                    #Else
                        ofx_ProfileWriteString "Options", "SystemDB", m_sSystemDB
                        DBEngine.IniPath = ofxApp.sIniFile
                    #End If
                
                    Set m_wsJet = CreateWorkspace(m_sName, m_sUserName, m_sPassword)
                Else
                    Set m_wsJet = DBEngine(0)
                End If
            
            End If
            
            'set every time
            DBEngine.LoginTimeout = m_nLoginTimeout
            
            m_bIsConstructed = True
    #End If
    
    #If DBOPT_ODBC Then
        Case dbHolderTypeODBC
            
            'Only 1 HENV for the WHOLE app, so only CreateEnvironment it ONCE
            If (ofxApp.dbState Is Nothing) Then
                Set ofxApp.dbState = New CDBState
                ofxApp.dbState.Name = m_sName
                ofxApp.dbState.UserName = m_sUserName
                ofxApp.dbState.Password = m_sPassword
            End If
            
            Set m_dbState = ofxApp.dbState
            If (m_dbODBC Is Nothing) Then
                Set m_dbODBC = New CDatabase
            End If
            
            m_dbODBC.hEnv = m_dbState.hEnv
            m_dbODBC.UserName = m_sUserName
            m_dbODBC.Password = m_sPassword
            
            m_bIsConstructed = True
    #End If
    
    #If DBOPT_RDO And Win32 Then
        Case dbHolderTypeRDO
            rdoEngine.rdoDefaultUser = m_sUserName
            rdoEngine.rdoDefaultPassword = m_sPassword
            rdoEngine.rdoDefaultCursorDriver = rdUseIfNeeded
            
            If (m_dbRdoEnv Is Nothing) Then
                Set m_dbRdoEnv = rdoEngine(0)
            End If
            
            m_dbRdoEnv.LoginTimeout = m_nLoginTimeout
            
            m_bIsConstructed = True
    #End If
    
    #If DBOPT_VBSQL Then
        Case dbHolderTypeVBSQL
    
        ' Initialize the SQL Server Libraries and it returns
        ' the version of DB-Lib we are using. It will return a blank
        ' string if the call fails.
        If (0 = Len(m_sDBLibVersion)) Then
            m_sDBLibVersion = SqlInit()
        End If
        m_bIsConstructed = (Len(m_sDBLibVersion) > 0)
        
    #End If
    
    End Select
        
    CreateEnvironment = m_bIsConstructed
    
CreateEnvironment_Exit:
    Exit Function
CreateEnvironment_Error:
    ofx_GenericError "CDatabaseHolder::CreateEnvironment()"
    Resume CreateEnvironment_Exit
End Function

'------------------------------------------------------------------------------
' Method:   OpenDatabase
'
' Purpose:  Open a database.
'
' Params:   optFileOrDSN (I) Filename or DSN  (Ignored with VBSQL)
'           param1       (I) With Jet, the ReadOnly flag, with RDO and ODBC, the DriverCompletion flag
'           param2       (I) With Jet, the exclusive flag. with RDO and ODBC, The ReadOnly flag
'           param3       (I) The connect string
'
' Returns:  True if successful, False otherwise
'
' Notes:    All parameters are ignored with VBSQL.
'           For the simplest way to use this method,
'           you should call this method from the OpenDatabase() function
'           in the AppData.bas module.
'
'           Note that the parameters have slightly different meanings depending on the
'           DatabaseType.
'------------------------------------------------------------------------------
Public Function OpenDatabase(Optional optFileOrDSN As Variant, Optional param1 As Variant, Optional param2 As Variant, Optional param3 As Variant) As Boolean
    On Error GoTo OpenDatabase_Error
    
    CloseDatabase
        
    Dim sFileOrDSN As String
    Dim bReadOnly As Boolean
    Dim fDriverCompleteFlag As Long
    
    
    'name is EITHER a file or DSN
    If (Not (IsMissing(optFileOrDSN))) Then
        sFileOrDSN = optFileOrDSN
    End If

    Select Case m_nType
    
    #If DBOPT_JET Then
        Case dbHolderTypeJet
        
            If (0 = Len(sFileOrDSN)) Then
                sFileOrDSN = m_sDatabase
            End If
            
            
            If (m_bUseOdbc) Then
                If (Len(m_sDSN) > 0) Then
                    m_sConnect = "ODBC;DSN=" & m_sDSN & IIf(Len(m_sDatabase) > 0, ";DATABASE=" & m_sDatabase, "")
                    m_sConnect = m_sConnect & ";UID=" & m_sUserName & ";PWD=" & m_sPassword
                Else
                    'prompt
                    m_sConnect = "ODBC;"
                End If
                
                Set m_dbJet = m_wsJet.OpenDatabase("", False, False, m_sConnect)
                m_sConnect = m_dbJet.Connect
            Else
                Set m_dbJet = m_wsJet.OpenDatabase(sFileOrDSN, param1, param2, param3)
            End If
            
            
            m_dbJet.QueryTimeout = m_nQueryTimeout
            m_bIsOpen = (Not (m_dbJet Is Nothing))
    #End If
    
    #If DBOPT_ODBC Then
        Case dbHolderTypeODBC
            
            If (0 = Len(sFileOrDSN)) Then
                sFileOrDSN = m_sDSN
            End If
           
            If (IsMissing(param1)) Then
                bReadOnly = False
            Else
                bReadOnly = param1
            End If
            
            If (IsMissing(param2)) Then
                fDriverCompleteFlag = SQL_DRIVER_NOPROMPT
            Else
                fDriverCompleteFlag = param2
            End If
                                    
            If (IsMissing(param3)) Then
                If (Not (BuildConnectString())) Then
                    fDriverCompleteFlag = SQL_DRIVER_PROMPT
                End If
            Else
                m_sConnect = param3
            End If
                        
            m_bIsOpen = m_dbODBC.OpenConnection(sFileOrDSN, fDriverCompleteFlag, bReadOnly, m_sConnect)
            
            m_sConnect = m_dbODBC.Connect
    #End If
    
    #If DBOPT_RDO And Win32 Then
        Case dbHolderTypeRDO
            
            If (0 = Len(sFileOrDSN)) Then
                sFileOrDSN = m_sDSN
            End If
                       
            If (IsMissing(param1)) Then
                fDriverCompleteFlag = rdDriverNoPrompt
            Else
                fDriverCompleteFlag = param1
            End If
            
            If (IsMissing(param2)) Then
                bReadOnly = False
            Else
                bReadOnly = param2
            End If
            
            If (IsMissing(param3)) Then
                'if there is a DSN, then use it, otherwise, use DRIVER/SERVER
                If (Not (BuildConnectString())) Then
                    fDriverCompleteFlag = rdDriverPrompt
                End If
            Else
                m_sConnect = param3
            End If
            
            m_dbRdoEnv.UserName = m_sUserName
            m_dbRdoEnv.Password = m_sPassword
            
            Set m_dbRdoConn = m_dbRdoEnv.OpenConnection("", fDriverCompleteFlag, bReadOnly, m_sConnect)
            
            m_sConnect = m_dbRdoConn.Connect
            
            m_dbRdoConn.QueryTimeout = m_nQueryTimeout
            
            m_bIsOpen = (Not (m_dbRdoConn Is Nothing))
            
    #End If
    
    #If DBOPT_VBSQL Then
        Case dbHolderTypeVBSQL
            
            m_vbsqlConn = 0
            
            If (0 = Len(m_sDBLibVersion)) Then
                If (Not (CreateEnvironment())) Then
                    Exit Function
                End If
            End If
            
            ' Default login timeout
            OFXVBSQLTRY 0, SqlSetLoginTime(m_nLoginTimeout)
            
            If (Len(sFileOrDSN) > 0) Then
                m_sServer = sFileOrDSN
            End If
                   
            If (ofx_sqlOpenConnection(m_sServer, m_sUserName, m_sPassword, m_vbsqlConn)) Then
                
                ' If the login was successful, then set the default time that a query
                ' can run before it times out. This will insure you don't have runaway
                ' queries lasting hours.
            
                m_bIsOpen = True
                Call OFXVBSQLTRY(m_vbsqlConn, (SqlUse(m_vbsqlConn, m_sDatabase)))      'same as ANSI 'USE'
                Call OFXVBSQLTRY(m_vbsqlConn, SqlSetTime(m_nQueryTimeout))    'query timeout
                
            End If

    #End If
    
    End Select
    
    OpenDatabase = m_bIsOpen
    
    SaveSettings
    
OpenDatabase_Exit:
    Exit Function
OpenDatabase_Error:
    
    Select Case m_nType
        
        #If DBOPT_JET Then
            Case dbHolderTypeJet
        #End If
        
        #If DBOPT_ODBC Then
            Case dbHolderTypeODBC
        #End If
        
        #If DBOPT_RDO And Win32 Then
            Case dbHolderTypeRDO
                MsgBox Err.Description, vbInformation
                Resume OpenDatabase_Exit
        #End If
        
        #If DBOPT_VBSQL Then
            Case dbHolderTypeVBSQL
                MsgBox Err.Description, vbInformation
                Resume OpenDatabase_Exit
        #End If
    
    End Select

    ofx_GenericError "CDatabaseHolder::OpenDatabase()"
    Resume OpenDatabase_Exit
End Function



'------------------------------------------------------------------------------
' Method:   SaveSettings
'
' Purpose:  Saves the current properties to the Registry/INI
'
' Notes:    The OpenDatabase function in the AppData.bas module uses the registry
'           settings to determine which database to open and how to construct the
'           CDatabaseHolder object.
'------------------------------------------------------------------------------
Private Sub SaveSettings()
    On Error GoTo SaveSettings_Error
 
    ' Always write the [Databases] entry
    ofx_ProfileWriteString "Databases", m_sName, ""
    
    ' Always
    ofx_ProfileWriteInt m_sName, "QueryTimeout", CLng(m_nQueryTimeout)
    ofx_ProfileWriteInt m_sName, "LoginTimeout", CLng(m_nLoginTimeout)
    
    If (m_bIsOpen) Then
        Select Case m_nType
            
            Case dbHolderTypeJet
                #If DBOPT_JET Then
                    m_sUserName = m_wsJet.UserName
                    m_sDatabase = m_dbJet.Name
                    If (ofx_FileExists(m_sSystemDB)) Then
                        ofx_ProfileWriteString m_sName, "SystemDB", m_sSystemDB
                        ofx_ProfileWriteString "Engines\Jet", "SystemDB", m_sSystemDB
                    End If
                    ofx_ProfileWriteInt m_sName, "UseODBC", CLng(m_bUseOdbc)

                #End If
            
            Case dbHolderTypeODBC
                #If DBOPT_ODBC Then
                    m_sUserName = m_dbODBC.UserName
                    m_sDatabase = m_dbODBC.Database
                    ofx_ProfileWriteString m_sName, "DSN", ofx_C2ABStr(m_sDSN)
                #End If
                
            
            Case dbHolderTypeRDO
                #If DBOPT_RDO And Win32 Then
                    ofx_SplitDSN m_dbRdoConn.Connect, m_sDatabase, m_sDSN, m_sUserName, m_sPassword
                    ofx_ProfileWriteString m_sName, "DSN", ofx_C2ABStr(m_sDSN)
                #End If
                
                
            Case dbHolderTypeVBSQL
                #If DBOPT_VBSQL Then
                    ofx_ProfileWriteString m_sName, "Server", ofx_C2ABStr(m_sServer)
                #End If
            
        End Select
        
        ofx_ProfileWriteString m_sName, "UserName", ofx_C2ABStr(m_sUserName)
        ofx_ProfileWriteString m_sName, "Database", ofx_C2ABStr(m_sDatabase)
        ofx_ProfileWriteInt m_sName, "Type", m_nType
        
    End If
    
    
    
SaveSettings_Exit:
    Exit Sub
SaveSettings_Error:
    ofx_GenericError "CDatbaseHolder::SaveSettings()"
    Resume SaveSettings_Exit
End Sub

'------------------------------------------------------------------------------
' Method:   CloseDatabase
'
' Purpose:  Closes the current database (connection) and frees any unused resources.
'
' Notes:    This function can safely be called even if the database is not currently open.
'------------------------------------------------------------------------------
Public Sub CloseDatabase()
    On Error GoTo CloseDatabase_Error
    
    If (Not (m_bIsOpen)) Then Exit Sub
    
    Select Case m_nType
    #If DBOPT_JET Then
        Case dbHolderTypeJet
            If (Not (m_dbJet Is Nothing)) Then
                m_dbJet.Close
            End If
            Set m_dbJet = Nothing
    #End If
    
    #If DBOPT_ODBC Then
        Case dbHolderTypeODBC
            If (Not (m_dbODBC Is Nothing)) Then
                m_dbODBC.CloseConnection
            End If
            Set m_dbODBC = Nothing
    #End If
    
    #If DBOPT_RDO And Win32 Then
        Case dbHolderTypeRDO
            If (Not (m_dbRdoConn Is Nothing)) Then
                m_dbRdoConn.Close
                DoEvents
            End If
            Set m_dbRdoConn = Nothing
    #End If
    
    #If DBOPT_VBSQL Then
        Case dbHolderTypeVBSQL
            '
            ' This call closes a single named connection (m_vbsqlConn in this case)
            ' and no other communications can take place until m_vbsqlConn is linked
            ' with SQL Server again via the OpenDatabase method.
            If (m_vbsqlConn) Then
                'SqlClose is a SUB! Don't use OFXVBSQLTRY()
                SqlClose m_vbsqlConn
                m_vbsqlConn = 0
            End If
    #End If
    
    End Select
    
    m_bIsOpen = False
    m_sConnect = ""
    m_sDSN = ""
    m_sDatabase = ""
    
CloseDatabase_Exit:
    Exit Sub
CloseDatabase_Error:
    ofx_GenericError "CDatabaseHolder::CloseDatabase()"
    Resume CloseDatabase_Exit
End Sub


'------------------------------------------------------------------------------
' Method:   Class_Initialize
'
' Purpose:  Initializes this instance of the class.
'------------------------------------------------------------------------------
Private Sub Class_Initialize()
    On Error GoTo Class_Initialize_Err

    m_nType = 0
    m_bIsOpen = False
    m_nRowsAffected = -1                    'out of range
    m_nLoginTimeout = 30                    '30 seconds by default

Class_Initialize_Exit:
    On Error Resume Next
    Exit Sub
Class_Initialize_Err:
    Call ofx_GenericError("Class_Initialize()", Err)
    Resume Class_Initialize_Exit
End Sub

'------------------------------------------------------------------------------
' Method:   Class_Terminate
'
' Purpose:  Performs class instance cleanup.
'
' Notes:    Jet and RDO each have an "environment" for each connection.
'           While not strictly necessary, this allows for quite a bit
'           more flexabiltiy for the developer.
'------------------------------------------------------------------------------
Private Sub Class_Terminate()
    On Error GoTo Class_Terminate_Err

    CloseDatabase
    
    Select Case m_nType
    #If DBOPT_JET Then
        Case dbHolderTypeJet
            If (Not (m_wsJet Is Nothing)) Then
                'Close has no effect on the default workspace
                m_wsJet.Close
            End If
            Set m_wsJet = Nothing
    #End If
    
    #If DBOPT_ODBC Then
        Case dbHolderTypeODBC
            
    #End If
    
    #If DBOPT_RDO And Win32 Then
        Case dbHolderTypeRDO
            If (Not (m_dbRdoEnv Is Nothing)) Then
                m_dbRdoEnv.Close
            End If
            Set m_dbRdoEnv = Nothing
    #End If
    
    #If DBOPT_VBSQL Then
        Case dbHolderTypeVBSQL
            'nothing to do
    #End If
    
    End Select

Class_Terminate_Exit:
    On Error Resume Next
    Exit Sub
Class_Terminate_Err:
    Call ofx_GenericError("Class_Terminate()", Err)
    Resume Class_Terminate_Exit
End Sub

'------------------------------------------------------------------------------
' Method:   GetSettings
'
' Purpose:  Reads the "settings" from the Registry/INI file.
'
' Returns:  True if the minimum settings are read and valid, false
'------------------------------------------------------------------------------
Public Function GetSettings() As Boolean
    On Error GoTo GetSettings_Error
    
    'All types save a user name and Database
    'don't localize this!
    m_sUserName = ofx_ProfileGetString(m_sName, "UserName", "")
    m_sDatabase = ofx_ProfileGetString(m_sName, "Database", "")
    
    m_nQueryTimeout = ofx_ProfileGetInt(m_sName, "QueryTimeout", 20)
    m_nLoginTimeout = ofx_ProfileGetInt(m_sName, "LoginTimeout", 20)
        
    Select Case m_nType
    
        #If DBOPT_JET Then
            Case dbHolderTypeJet
                m_sSystemDB = ofx_ProfileGetString(m_sName, "SystemDB", "")
                
                'If the UseODBC flag is set in the INI/registry (UseODBC == 1)
                'Then we need to look for a DSN
                m_sDSN = ofx_ProfileGetString(m_sName, "DSN", "")
                m_bUseOdbc = ((Len(m_sDSN) > 0) And (0 <> ofx_ProfileGetInt(m_sName, "UseODBC", 0)))
                
                If (Not (m_bUseOdbc)) Then
                    GetSettings = ofx_FileExists(m_sDatabase)
                Else
                    GetSettings = True
                End If
        #End If
        
        #If DBOPT_ODBC Or DBOPT_RDO Then
            Case dbHolderTypeODBC, dbHolderTypeRDO
                m_sDSN = ofx_ProfileGetString(m_sName, "DSN", "")
                                
                'optional
                m_sServer = ofx_ProfileGetString(m_sName, "Server", "")
                m_sDriver = ofx_ProfileGetString(m_sName, "Driver", "")
                
                GetSettings = (((Len(m_sDSN) > 0) Or ((Len(m_sServer) > 0) And (Len(m_sDriver)) > 0)) And (Len(m_sDatabase) > 0))
        #End If
        
        #If DBOPT_VBSQL Then
            Case dbHolderTypeVBSQL
                m_sServer = ofx_ProfileGetString(m_sName, "Server", "")
                GetSettings = ((Len(m_sDatabase) > 0) And (Len(m_sServer) > 0))
        #End If
    
    End Select
    
    
    
GetSettings_Exit:
    Exit Function
GetSettings_Error:
    ofx_GenericError "CDatabaseHolder::GetSettings()"
    Resume GetSettings_Exit
End Function














'------------------------------------------------------------------------------
' Method:   Execute
'
' Purpose:  Executes an SQL statement.
'
' Params:   sSql    (I) The SQL statement to execute
'           Options (I) For Jet and RDO, see the Execute method for a possible list of these options.
'
' Returns:  True if the statement executed successfully (no errors), False otherwise.
'------------------------------------------------------------------------------
Public Function Execute(sSql As String, Optional Options As Variant) As Boolean
    On Error GoTo Execute_Error
    
    ofx_WaitCursor True
    
    Select Case m_nType
    
        #If DBOPT_JET Then
            Case dbHolderTypeJet
                m_dbJet.Execute sSql, Options
                m_nRowsAffected = m_dbJet.RecordsAffected
        #End If
        
        #If DBOPT_ODBC Then
            Case dbHolderTypeODBC
                Execute = m_dbODBC.Execute(sSql, Options)
                m_nRowsAffected = m_dbODBC.RowsAffected
        #End If
        
        #If DBOPT_RDO And Win32 Then
            Case dbHolderTypeRDO
                m_dbRdoConn.Execute sSql, Options
                m_nRowsAffected = m_dbRdoConn.RowsAffected
                Execute = True
        #End If
        
        #If DBOPT_VBSQL Then
            Case dbHolderTypeVBSQL
                If (SUCCEED = SqlSendCmd(m_vbsqlConn, sSql)) Then
                    m_nRowsAffected = SqlRows(m_vbsqlConn)
                    
                    'discard the results
                    Do Until (NOMORERESULTS = SqlResults(m_vbsqlConn))
                        Do Until (NOMOREROWS = SqlNextRow(m_vbsqlConn))
                        Loop
                    Loop

                    Execute = True
                End If
        #End If
    
    End Select
    
    

Execute_Exit:
    ofx_WaitCursor False
    Exit Function
Execute_Error:
    ofx_GenericError "Execute()"
    Exit Function
End Function



'------------------------------------------------------------------------------
' Method:   DLookup
'
' Purpose:  Looks up a single value in a table.
'
' Params:   sColumn  (I) The column name
'           sDomain  (I) The "domain" (either a table or view)
'           sWhere   (I) The where clause without the word "WHERE".
'
' Returns:  The value that was "looked up"
'
' Notes:    This function constructs a SQL String in the following form:
'
'           SELECT <sColumn> FROM <sDomain> WHERE <sWhere>
'
' See Also: OfxDatabaseUtilities module.
'------------------------------------------------------------------------------
Public Function DLookup(sColumn As String, sDomain As String, sWhere As String) As Variant
    On Error GoTo DLookup_Err
    
    ofx_WaitCursor True
    
    Dim sSql As String
    sSql = "SELECT " & sColumn & " FROM " & sDomain & " WHERE " & sWhere
    
    
    Select Case m_nType
    
        #If DBOPT_JET Then
            Case dbHolderTypeJet
                DLookup = ofx_jetLookup(m_dbJet, sSql)
        #End If
        
        #If DBOPT_ODBC Then
            Case dbHolderTypeODBC
                DLookup = ofx_odbcLookup(m_dbODBC.hDbc, sSql)
        #End If
        
        #If DBOPT_RDO And Win32 Then
            Case dbHolderTypeRDO
                DLookup = ofx_rdoLookup(m_dbRdoConn, sSql)
        #End If
        
        #If DBOPT_VBSQL Then
            Case dbHolderTypeVBSQL
                DLookup = ofx_vbsqlLookup(m_vbsqlConn, sSql)
        #End If
    
    End Select
    
    
DLookup_Exit:
    On Error Resume Next
    ofx_WaitCursor False
    Exit Function
DLookup_Err:
    ofx_GenericError "DLookup()"
    Resume DLookup_Exit:
End Function



'------------------------------------------------------------------------------
' Method:   FillList
'
' Purpose:  Fills a list or combo box with the results of a query.
'
' Params:   ctrl (I) The control object (either a list or combo box)
'           sSql (I) The SQL statement to use to fill the list.
'
' Returns:  True if successful, false otherwise.
'
' See also: The OfxDatabaseUtilities module for a detailed reference.
'------------------------------------------------------------------------------
Public Function FillList(ctrl As Control, sSql As String) As Boolean
    On Error GoTo FillList_Err
    
    ofx_WaitCursor True

    Select Case m_nType
    
        #If DBOPT_JET Then
            Case dbHolderTypeJet
                FillList = ofx_jetFillList(m_dbJet, ctrl, sSql)
        #End If
        
        #If DBOPT_ODBC Then
            Case dbHolderTypeODBC
                FillList = ofx_odbcFillList(m_dbODBC.hDbc, ctrl, sSql)
        #End If
        
        #If DBOPT_RDO And Win32 Then
            Case dbHolderTypeRDO
                FillList = ofx_rdoFillList(m_dbRdoConn, ctrl, sSql)
        #End If
        
        #If DBOPT_VBSQL Then
            Case dbHolderTypeVBSQL
                 FillList = ofx_vbsqlFillList(m_vbsqlConn, ctrl, sSql)
        #End If
    
    End Select

FillList_Exit:
    On Error Resume Next
    ofx_WaitCursor False
    Exit Function
FillList_Err:
    Call ofx_GenericError("FillList()", Err)
    Resume FillList_Exit
End Function




'------------------------------------------------------------------------------
' Method:   OpenRecordset
'
' Purpose:  Opens a result set.
'
' Params:   sSource     (I) The statement to "open"
'           nType       (I) The type argument passed to Jet/RDO type databases (Ignored otherwise)
'           nOptions    (I) The options argument passed to Jet/RDO type databases. (Ignored otherwise.)
'
' Returns:  A reference to the recordset object (as a variant)
'
' Notes:    This function may return a reference to an Object.  In this case, you will
'           need to use the "Set" keyword to assign the variable.
'
' Example:  Dim rs as Variant
'           Set rs = dbHolder.OpenRecordset(...)
'------------------------------------------------------------------------------
Public Function OpenRecordset(sSource As String, Optional nType As Variant, Optional nOptions As Variant) As Variant
    'No error handling, all errors thrown back to caller

    If (m_bIsOpen) Then
    
        Select Case m_nType
        
            #If DBOPT_JET Then
                Case dbHolderTypeJet
                    Set OpenRecordset = m_dbJet.OpenRecordset(sSource, nType, nOptions)
            #End If
            
            #If DBOPT_ODBC Then
                Case dbHolderTypeODBC
                    
                    Dim rs As New CResultset
                    rs.QueryTimeout = m_nQueryTimeout
                    rs.OpenResultset m_dbODBC.hDbc, sSource
                    Set OpenRecordset = rs
            #End If
            
            #If DBOPT_RDO And Win32 Then
                Case dbHolderTypeRDO
                    Set OpenRecordset = m_dbRdoConn.OpenResultset(sSource, nType, nOptions)
            #End If
            
            #If DBOPT_VBSQL Then
                Case dbHolderTypeVBSQL
                    'Not implemented
            #End If
        
        End Select
    Else
        Err.Clear
        Err.Raise dbHolderErrNoDatabaseOpen, "CDatbaseHolder.OpenRecordset", dbHolderErrNoDatabaseOpenMsg
    End If
    

End Function



'------------------------------------------------------------------------------
' Method:   BeginTrans
'
' Purpose:  Begins a transaction
'
' Returns:  True if successful, False otherwise.
'
' Notes:    This method is not implemented with VBSQL, you should use direct SQL to implement
'           transactions with VBSQL.
'------------------------------------------------------------------------------
Public Function BeginTrans() As Boolean
    'No error handling.
    If (m_bIsOpen) Then
    
        Select Case m_nType
        
            #If DBOPT_JET Then
                Case dbHolderTypeJet
                    m_wsJet.BeginTrans
                    BeginTrans = True
            #End If
            
            #If DBOPT_ODBC Then
                Case dbHolderTypeODBC
                    m_dbODBC.BeginTrans
                    BeginTrans = True
            #End If
            
            #If DBOPT_RDO And Win32 Then
                Case dbHolderTypeRDO
                    'Transactions at the environment level
                    m_dbRdoEnv.BeginTrans
                    BeginTrans = True
            #End If
            
            #If DBOPT_VBSQL Then
                Case dbHolderTypeVBSQL
                    'Not implemented
            #End If
        
        End Select
    Else
        Err.Clear
        Err.Raise dbHolderErrNoDatabaseOpen, "CDatbaseHolder.OpenRecordset", dbHolderErrNoDatabaseOpenMsg
    End If
    
End Function

'------------------------------------------------------------------------------
' Method:   CommitTrans
'
' Purpose:  Commits a pending transaction.
'
' Notes:    This method is not implemented for VBSQL DatabaseTypes.
'------------------------------------------------------------------------------
Public Function CommitTrans() As Boolean
    'No error handling.
    If (m_bIsOpen) Then
    
        Select Case m_nType
        
            #If DBOPT_JET Then
                Case dbHolderTypeJet
                    m_wsJet.CommitTrans
                    CommitTrans = True
            #End If
            
            #If DBOPT_ODBC Then
                Case dbHolderTypeODBC
                    m_dbODBC.CommitTrans
                    CommitTrans = True
            #End If
            
            #If DBOPT_RDO And Win32 Then
                Case dbHolderTypeRDO
                    'Transactions at the environment level
                    m_dbRdoEnv.CommitTrans
                    CommitTrans = True
            #End If
            
            #If DBOPT_VBSQL Then
                Case dbHolderTypeVBSQL
                    'Not implemented
            #End If
        
        End Select
    Else
        Err.Clear
        Err.Raise dbHolderErrNoDatabaseOpen, "CDatbaseHolder.OpenRecordset", dbHolderErrNoDatabaseOpenMsg
    End If
    
End Function

'------------------------------------------------------------------------------
' Method:   Rollback
'
' Purpose:  Rolls back a pending transaction.
'
' Notes:    This method is not implemented for VBSQL DatabaseTypes.
'------------------------------------------------------------------------------
Public Function Rollback() As Boolean
    'No error handling.
    If (m_bIsOpen) Then
    
        Select Case m_nType
        
            #If DBOPT_JET Then
                Case dbHolderTypeJet
                    m_wsJet.Rollback
                    Rollback = True
            #End If
            
            #If DBOPT_ODBC Then
                Case dbHolderTypeODBC
                    m_dbODBC.Rollback
                    Rollback = True
            #End If
            
            #If DBOPT_RDO And Win32 Then
                Case dbHolderTypeRDO
                    'Transactions at the environment level
                    m_dbRdoEnv.RollbackTrans
                    Rollback = True
            #End If
            
            #If DBOPT_VBSQL Then
                Case dbHolderTypeVBSQL
                    'Not implemented
            #End If
        
        End Select
    Else
        Err.Clear
        Err.Raise dbHolderErrNoDatabaseOpen, "CDatbaseHolder.OpenRecordset", dbHolderErrNoDatabaseOpenMsg
    End If
    
End Function



'------------------------------------------------------------------------------
' Property: DatabaseType
'
' Purpose:  Sets the database type.
'
' Notes:    The database type MUST be one of the valid values:
'           dbHolderType* Jet
'                         RDO
'                         ODBC
'                         VBSQL
'------------------------------------------------------------------------------
Public Property Get DatabaseType() As Integer
    DatabaseType = m_nType
End Property

Public Property Let DatabaseType(vNewValue As Integer)
    'No error handling.
    
    'Type may only be set when the database is CLOSED, otherwise, ASSERT
#If DBG Then
    ASSERT ((0 = m_nType) Or (Not (m_bIsOpen))), TypeName(Me) & ".DatabaseType", dbHolderErrTypeAlreadySetMsg
#End If
    
    'before we set the type, make sure it is legal
    
    If (Not (vNewValue = dbHolderTypeJet Or _
        vNewValue = dbHolderTypeRDO Or _
        vNewValue = dbHolderTypeODBC Or _
        vNewValue = dbHolderTypeVBSQL)) Then
        Err.Clear
        Err.Raise dbHolderErrBadType, App.Title, dbHolderErrBadTypeMsg
    Else

        m_nType = CInt(vNewValue)
        
        'if jet is defined, then default the user name to Admin, no password
        'this lets us construct a workspace for the caller without any SYSTEM database
        If (dbHolderTypeJet = m_nType) Then
            m_sUserName = "Admin"
        End If
        
    End If
    
End Property


'------------------------------------------------------------------------------
' Property: DSN
'
' Purpose:  Sets/Returns the datasource name.  Jet/RDO/ODBC only.
'------------------------------------------------------------------------------
Public Property Get DSN() As String
    DSN = m_sDSN
End Property
Public Property Let DSN(vNewValue As String)
    m_sDSN = vNewValue
End Property

'------------------------------------------------------------------------------
' Property: Database
'
' Purpose: Sets/Returns the database name.
'------------------------------------------------------------------------------
Public Property Get Database() As String
    Database = m_sDatabase
End Property

Public Property Let Database(vNewValue As String)
    m_sDatabase = vNewValue
End Property

'------------------------------------------------------------------------------
' Property: UserName
'
' Purpose:  Sets/Returns the User name.
'
' Notes:    The user name is used when opening the database.
'------------------------------------------------------------------------------
Public Property Get UserName() As String
    UserName = m_sUserName
End Property
Public Property Let UserName(vNewValue As String)
    m_sUserName = vNewValue
End Property

'------------------------------------------------------------------------------
' Property: Password
'
' Purpose:  Sets/Returns the password
'------------------------------------------------------------------------------
Public Property Get Password() As String
    Password = m_sPassword
End Property

Public Property Let Password(vNewValue As String)
    m_sPassword = vNewValue
End Property

'------------------------------------------------------------------------------
' Property: Name
'
' Purpose:  Sets/Gets the name of the environment.
'
' Notes:    This property is used as an environment name (for Jet, RDO, and ODBC).  It is
'           not used with VBSQL
'------------------------------------------------------------------------------
Public Property Get Name() As String
    Name = m_sName
End Property

Public Property Let Name(vNewValue As String)
#If DBG Then
    'name may only be set when closed, otherwise, ASSERT
    ASSERT (0 = Len(m_sName) Or False = m_bIsOpen), TypeName(Me) & ".Name", dbHolderErrNameAlreadySetMsg
#End If
    
    m_sName = vNewValue
    
End Property

'------------------------------------------------------------------------------
' Property: IsOpen
'
' Purpose:  Returns the Open status of the underlying database object.
'
' Notes:    This property is read only
'------------------------------------------------------------------------------
Public Property Get IsOpen() As Boolean
    IsOpen = m_bIsOpen
End Property

'------------------------------------------------------------------------------
' Property: Connect
'
' Purpose:  Returns the connect string.
'
' Notes:    This property is read only.
'           Also, this property is filled out only for ODBC connections.
'------------------------------------------------------------------------------
Public Property Get Connect() As String
    Connect = m_sConnect
End Property




'------------------------------
' Property:  Server
'
' Purpose:   Returns the name of the server.
'
' Notes:    This property is read/write
'------------------------------
Public Property Get Server() As String
    Server = m_sServer
End Property
Public Property Let Server(sServer As String)
    m_sServer = sServer
End Property



'------------------------------
' Property:  UseODBC
'
' Purpose:   Returns/Sets the Jet(DAO) m_bUseODBC flag.
'
' Notes:    This property is read/write
'------------------------------
Public Property Get UseODBC() As Boolean
#If DBOPT_JET Then
    UseODBC = m_bUseOdbc
#End If
End Property
Public Property Let UseODBC(vNewValue As Boolean)
#If DBG Then
    ASSERT (Not (m_bIsOpen)), TypeName(Me) & ".UseODBC", "You may only set this property when the database is closed."
#End If
#If DBOPT_JET Then
    m_bUseOdbc = vNewValue
#End If
End Property



'------------------------------
' Function:  BuildConnectString
'
' Purpose:   Builds the connect string for ODBC/RDO database connections
'
' Notes:     This function may build into the connect string
'            A DRIVER/SERVER keyword pair.  This is ONLY done
'            if the DSN name (either supplied to OpenDatabase() or stored in the Profile)
'            is an empty string (or missing from the profile.)
'
' Returns:   True if the connection string was built
'            False otherwise.  (In this case the DriverPrompt argument should be "Prompt")
'------------------------------
Private Function BuildConnectString() As Boolean
    On Error Resume Next
    
    ' Clear every time
    m_sConnect = ""
    
    If (0 = Len(m_sDSN) And (0 = Len(m_sServer) And (0 = Len(m_sDriver)))) Then
        BuildConnectString = False
    Else
    
        If (Len(m_sDSN) > 0) Then
            m_sConnect = "DSN=" & m_sDSN
        Else
            'Only use the SERVER/DRIVER if DSN == ""
            If (0 = InStr(1, m_sConnect, "SERVER", 1) And Len(m_sServer) > 0) Then
                m_sConnect = m_sConnect & IIf(Len(m_sConnect) > 0, ";", "") & "SERVER=" & m_sServer
            End If
            If (0 = InStr(1, m_sConnect, "DRIVER", 1) And Len(m_sDriver) > 0) Then
                m_sConnect = m_sConnect & IIf(Len(m_sConnect) > 0, ";", "") & "DRIVER={" & m_sDriver & "}"
            End If
        End If
        
        If (0 = InStr(1, m_sConnect, "PWD", 1)) Then
            m_sConnect = m_sConnect & IIf(Len(m_sConnect) > 0, ";", "") & "PWD=" & m_sPassword
        End If
        If (0 = InStr(1, m_sConnect, "UID", 1)) Then
            m_sConnect = m_sConnect & IIf(Len(m_sConnect) > 0, ";", "") & "UID=" & m_sUserName
        End If
        If (0 = InStr(1, m_sConnect, "DATABASE", 1) And Len(m_sDatabase) > 0) Then
            m_sConnect = m_sConnect & IIf(Len(m_sConnect) > 0, ";", "") & "DATABASE=" & m_sDatabase
        End If
        
        BuildConnectString = True

    End If
End Function

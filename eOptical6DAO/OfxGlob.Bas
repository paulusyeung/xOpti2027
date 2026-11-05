Attribute VB_Name = "OfxGlobals"
'   Ofx - Globals
' ***********************************************************************
'
'   This module contains global definitions used by the framework.
'
' ***********************************************************************

Option Compare Text
Option Explicit

'----- Framework String Constants

#If MSA Then
    Public Const ofxVersion% = 1
    Public Const ofxCompanyName% = 9998
    Public Const ofxRegKeyRoot% = 9999
    Public Const ofxAppName% = 10000
    Public Const ofxErrorTableName% = 10001
    Public Const ofxEventTableName% = 10002
    Public Const ofxConfirmDelete% = 10003
    Public Const ofxUpdateLinks% = 10004
    Public Const ofxRefreshQueryDefs% = 10005
    Public Const ofxNoOperation% = 10006
    Public Const ofxAcountExists% = 10007
    Public Const ofxAccountNotFound% = 10008
    Public Const ofxNoFileToOpen% = 10009
    Public Const ofxFileDoesNotExist% = 10010
    Public Const ofxErrorActivatingWord% = 10011
    Public Const ofxErrorCreatingWordObject% = 10012
    Public Const ofxErrorActivatingExcel% = 10013
    Public Const ofxErrorCreateObjectExcel% = 10014
    Public Const ofxODBCConnectFailed% = 10015
    Public Const ofxLinkTableError% = 10016
    Public Const ofxErrorAddingUser% = 10017
    Public Const ofxDatabaseMissing% = 10018
    Public Const ofxAskForBrowse% = 10019
#Else
    Public Const ofxErrorCreatingWordObject$ = "Could not create the Word for Windows OLE automation object. Check to make sure that Word for Windows is properly installed."
    Public Const ofxErrorCreateObjectExcel$ = "Could not create the Microsoft Excel OLE automation object. Check to make sure that Microsoft Excel is properly installed."
#End If


'----- This structure contains all global variables in the framework.
'----- Do not add any application specific globals into this one as
'----- they would be clobbered if you upgrade to a newer version of
'----- the framework.

Type TYPE_OFX_APP_GLOBALS
    sCompany As String          'Company name
    sAppName As String          'App Name
    sRegKeyRoot As String       'Root registry key, by default, the same as AppName
    sUserID As String           'The user name
    sIniFile As String          'Name of private .INI file
    
#If MSA Then
    wsThis As Workspace         'Current workspace (for transactions, opendatabase, ...)
    dbThis As Database          'Current database  (Use for OpenRecordset, Execute, ...)
    dbRemote() As Database      'List of attached databases
#Else
    
#If Not MSA And Not VB3 Then
    dbList As Collection        'list of CDatabaseHolder objects
    nDbCount As Integer         'number of databases in the dbList
#End If                         '(the dbList member may actually be Nothing, so you can't just use .Count)

    #If DBOPT_ODBC Then
        dbState As CDBState     'ODBC hEnv
    #End If
    
    
    bRunAutomated As Boolean    'running as a OLE server
    hWndParent As Long          'handle to the callers main window
#End If

' OLE automation ONLY
#If OFXOPT_AUTOMATION Or MSA Then

    oWord As Object             'OLE automation (Microsoft Word)
    oExcel As Object            'OLE automation (Microsoft Excel)
    oProject As Object          'OLE automation (Microsoft Project)
    
    #If Not MSA Then
        oAccess As Object           'OLE automation (Microsoft Access)
    #End If

#End If
    
    
#If Win32 Then
    'Internet session handle, automatically closed in the exit procedure
    hInternetSession As Long
#End If
    
End Type

Public ofxApp As TYPE_OFX_APP_GLOBALS


'Constants used by the CDatabaseHolder class
Public Const dbHolderTypeJet As Integer = 1
Public Const dbHolderTypeODBC As Integer = 2
Public Const dbHolderTypeRDO As Integer = 3
Public Const dbHolderTypeVBSQL As Integer = 4

Public Const dbHolderErrTypeAlreadySet As Integer = 1001
Public Const dbHolderErrTypeNotSet As Integer = 1002

Public Const dbHolderErrNameAlreadySet As Integer = 1003
Public Const dbHolderErrNameNoteSet As Integer = 1004

Public Const dbHolderErrTypeAlreadySetMsg As String = "The DatabaseType has already been set."
Public Const dbHolderErrTypeNotSetMsg As String = "The DatabaseType has not been set."

Public Const dbHolderErrNameAlreadySetMsg As String = "The DatabaseName has already been set."
Public Const dbHolderErrNameNotSetMsg As String = "The DatabaseName has not been set."

Public Const dbHolderErrReadOnlyProp As Integer = 1005
Public Const dbHolderErrReadOnlyPropMsg As String = "This property is read-only."

Public Const dbHolderErrBadType As Integer = 1006
Public Const dbHolderErrBadTypeMsg As String = "DatabaseType is invalid."

Public Const dbHolderErrNoDatabaseOpen As Integer = 1007
Public Const dbHolderErrNoDatabaseOpenMsg As String = "Database is not open."

Public Const dbOdbcTranLevelErr As Integer = 2001
Public Const dbOdbcTranLevelErrMsg As String = "Only one level of transactions are supported."

Public Const dbOdbcNoPendingTranErr As Integer = 2002
Public Const dbOdbcNoPendingTranErrMsg As String = ""

Public Const dbObjectInitErr As Integer = 3001
Public Const dbObjectInitErrMsg As String = "Object is not initialized."



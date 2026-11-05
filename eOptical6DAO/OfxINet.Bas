Attribute VB_Name = "OfxInternet"
#If OFXOPT_INET Then

'------------------------------------------------------------------------------
' Module:   Ofx - Internet
'
' Purpose:  Contains manifests, macros, types and prototypes for Microsoft Windows
'           Internet Extensions.
'------------------------------------------------------------------------------

Option Explicit

'typedef LPVOID HINTERNET;
'typedef HINTERNET * LPHINTERNET;

'typedef WORD INTERNET_PORT;
'typedef INTERNET_PORT * LPINTERNET_PORT;

'constants
Private Const INTERNET_INVALID_PORT_NUMBER = 0      '// use the protocol-specific default

Private Const INTERNET_DEFAULT_FTP_PORT = 21               '// default for FTP servers
Private Const INTERNET_DEFAULT_GOPHER_PORT = 70            '//    "     "  gopher "
Private Const INTERNET_DEFAULT_HTTP_PORT = 80              '//    "     "  HTTP   "

'//
'// maximum field lengths (arbitrary)
'//

Private Const INTERNET_MAX_HOST_NAME_LENGTH = 256
Private Const INTERNET_MAX_USER_NAME_LENGTH = 128
Private Const INTERNET_MAX_PASSWORD_LENGTH = 128
Private Const INTERNET_MAX_PORT_NUMBER_LENGTH = 5          '// INTERNET_PORT is unsigned short
Private Const INTERNET_MAX_PORT_NUMBER_VALUE = 65535       '// maximum unsigned short value
Private Const INTERNET_MAX_PATH_LENGTH = 1024
Private Const INTERNET_MAX_PROTOCOL_NAME = "gopher"        '// longest protocol name
Private Const INTERNET_MAX_URL_LENGTH = INTERNET_MAX_PATH_LENGTH + 9

'//
'// values returned by InternetQueryOption() with INTERNET_OPTION_KEEP_CONNECTION:
'//

Private Const INTERNET_KEEP_ALIVE_UNKNOWN = -1&
Private Const INTERNET_KEEP_ALIVE_ENABLED = 1
Private Const INTERNET_KEEP_ALIVE_DISABLED = 0

'//
'// flags returned by InternetQueryOption() with INTERNET_OPTION_REQUEST_FLAGS
'//

Private Const INTERNET_REQFLAG_FROM_CACHE = &H1&
Private Const INTERNET_REQFLAG_ASYNC = &H2&

'//
'// flags common to open functions (not InternetOpen()):
'//

Private Const INTERNET_FLAG_RELOAD = &H80000000              '// retrieve the original item

'//
'// flags for InternetOpenUrl():
'//

Private Const INTERNET_FLAG_RAW_DATA = &H40000000            '// receive the item as raw data
Private Const INTERNET_FLAG_EXISTING_CONNECT = &H20000000    '// do not create new connection object

'//
'// flags for InternetOpen():
'//

Private Const INTERNET_FLAG_ASYNC = &H10000000               '// this request is asynchronous (where supported)

'//
'// protocol-specific flags:
'//

Private Const INTERNET_FLAG_PASSIVE = &H8000000              '// used for FTP connections

'//
'// additional cache flags
'//

Private Const INTERNET_FLAG_DONT_CACHE = &H4000000          '// don't add this item to the cache
Private Const INTERNET_FLAG_MAKE_PERSISTENT = &H2000000     '// make this item persistent in cache

Private Const INTERNET_FLAG_OFFLINE = &H1000000             '// use offline semantics

Private Const INTERNET_FLAG_SECURE = &H800000               '// use PCT/SSL if applicable (HTTP)

Private Const INTERNET_FLAG_NO_CLOSE_CALLBACK = &H400000    '// no callbacks after handle closed

Private Const INTERNET_FLAG_NO_AUTO_REDIRECT = &H200000     '// don't handle redirections automatically

'//
'// flags field masks
'//

Private Const INTERNET_FLAGS_MASK = INTERNET_FLAG_RELOAD + INTERNET_FLAG_EXISTING_CONNECT + INTERNET_FLAG_ASYNC + INTERNET_FLAG_PASSIVE + INTERNET_FLAG_DONT_CACHE + INTERNET_FLAG_MAKE_PERSISTENT + INTERNET_FLAG_OFFLINE + INTERNET_FLAG_SECURE

Private Const INTERNET_OPTIONS_MASK = Not INTERNET_FLAGS_MASK

'//
'// INTERNET_NO_CALLBACK - if this value is presented as the dwContext parameter
'// then no call-backs will be made for that API
'//

Private Const INTERNET_NO_CALLBACK As Long = 0

'//
'// structures/types
'//

Private Const INTERNET_SCHEME_DEFAULT As Integer = 0
Private Const INTERNET_SCHEME_FTP As Integer = 1
Private Const INTERNET_SCHEME_GOPHER As Integer = 2
Private Const INTERNET_SCHEME_HTTP As Integer = 3
Private Const INTERNET_SCHEME_HTTPS As Integer = 4

Private Declare Function InternetOpen Lib "wininet.dll" Alias "InternetOpenA" (ByVal lpszAgent As String, ByVal dwAccessType As Long, ByVal lpszProxy As String, ByVal lpszProxyBypass As String, ByVal dwFlags As Long) As Long

Private Const INTERNET_OPEN_TYPE_PRECONFIG = 0     '// use registry configuration
Private Const INTERNET_OPEN_TYPE_DIRECT = 1        '// direct to net
Private Const INTERNET_OPEN_TYPE_PROXY = 3         '// via named proxy

Private Const PRE_CONFIG_INTERNET_ACCESS = INTERNET_OPEN_TYPE_PRECONFIG
Private Const LOCAL_INTERNET_ACCESS = INTERNET_OPEN_TYPE_DIRECT
Private Const GATEWAY_INTERNET_ACCESS = 2                                '// Internet via gateway
Private Const CERN_PROXY_INTERNET_ACCESS = INTERNET_OPEN_TYPE_PROXY

Private Declare Function InternetCloseHandle Lib "wininet.dll" (ByVal hInternet As Long) As Boolean

Private Const INTERNET_SERVICE_FTP = 1
Private Const INTERNET_SERVICE_GOPHER = 2
Private Const INTERNET_SERVICE_HTTP = 3

'INTERNETAPI
'hInternet
'WINAPI
'InternetOpenUrlA(
'    IN HINTERNET hInternet,
'    IN LPCSTR lpszUrl,
'    IN LPCSTR lpszHeaders OPTIONAL,
'    IN DWORD dwHeadersLength,
'    IN DWORD dwFlags,
'    IN DWORD dwContext
'    );
    
Private Declare Function InternetOpenUrl Lib "wininet.dll" Alias "InternetOpenUrlA" (ByVal hInternet As Long, ByVal lpszUrl As String, ByVal lpszHeaders As String, ByVal dwHeadersLength As Long, ByVal dwFlags As Long, ByVal dwContext As Long) As Long


'INTERNETAPI
'BOOL
'WINAPI
'InternetReadFile(
'    IN HINTERNET hFile,
'    IN LPVOID lpBuffer,
'    IN DWORD dwNumberOfBytesToRead,
'    OUT LPDWORD lpdwNumberOfBytesRead
'    );
    
Private Declare Function InternetReadFile Lib "wininet.dll" (ByVal hFile As Long, ByVal lpData As String, ByVal dwNumberOfBytesToRead As Long, lpdwNumberOfBytesRead As Long) As Boolean


'INTERNETAPI
'BOOL
'WINAPI
'InternetSetOption(
'    IN HINTERNET hInternet OPTIONAL,
'    IN DWORD dwOption,
'    IN LPVOID lpBuffer,
'    IN DWORD dwBufferLength
'    );

Private Declare Function InternetSetOption _
    Lib "wininet.dll" _
    Alias "InternetSetOptionA" (ByVal hInternet As Long, ByVal dwOption As Long, lpBuffer As Long, ByVal dwBufferLength As Long) As Boolean
Private Declare Function InternetQueryOption _
    Lib "wininet.dll" _
    Alias "InternetQueryOptionA" (ByVal hInternet As Long, ByVal dwOption As Long, lpBuffer As Long, dwBufferLength As Long) As Boolean
    
    
Private Declare Function InternetCanonicalizeUrl Lib "wininet.dll" Alias "InternetCanonicalizeUrlA" (ByVal lpszIN As String, ByVal lpszOUT As String, dwLength As Long, dwReserved As Long) As Boolean

Private Declare Function InternetGetLastResponseInfo Lib "wininet.dll" Alias "InternetGetLastResponseInfoA" (lpdwError As Long, ByVal lpszBuffer As String, lpdwBufferLength As Long) As Boolean

Private Const INTERNET_OPTION_CALLBACK  As Long = 1
Private Const INTERNET_OPTION_CONNECT_TIMEOUT  As Long = 2
Private Const INTERNET_OPTION_CONNECT_RETRIES  As Long = 3
Private Const INTERNET_OPTION_CONNECT_BACKOFF  As Long = 4
Private Const INTERNET_OPTION_SEND_TIMEOUT  As Long = 5
Private Const INTERNET_OPTION_CONTROL_SEND_TIMEOUT  As Long = INTERNET_OPTION_SEND_TIMEOUT
Private Const INTERNET_OPTION_RECEIVE_TIMEOUT  As Long = 6
Private Const INTERNET_OPTION_CONTROL_RECEIVE_TIMEOUT  As Long = INTERNET_OPTION_RECEIVE_TIMEOUT
Private Const INTERNET_OPTION_DATA_SEND_TIMEOUT  As Long = 7
Private Const INTERNET_OPTION_DATA_RECEIVE_TIMEOUT  As Long = 8
Private Const INTERNET_OPTION_HANDLE_TYPE  As Long = 9
Private Const INTERNET_OPTION_CONTEXT_VALUE  As Long = 10
Private Const INTERNET_OPTION_NAME_RES_THREAD  As Long = 11
Private Const INTERNET_OPTION_READ_BUFFER_SIZE  As Long = 12
Private Const INTERNET_OPTION_WRITE_BUFFER_SIZE  As Long = 13
Private Const INTERNET_OPTION_GATEWAY_NAME  As Long = 14
Private Const INTERNET_OPTION_ASYNC_ID  As Long = 15
Private Const INTERNET_OPTION_ASYNC_PRIORITY  As Long = 16
Private Const INTERNET_OPTION_ASYNC_REQUEST_COUNT  As Long = 17
Private Const INTERNET_OPTION_MAXIMUM_WORKER_THREADS  As Long = 18
Private Const INTERNET_OPTION_ASYNC_QUEUE_DEPTH  As Long = 19
Private Const INTERNET_OPTION_WORKER_THREAD_TIMEOUT  As Long = 20
Private Const INTERNET_OPTION_PARENT_HANDLE  As Long = 21
Private Const INTERNET_OPTION_KEEP_CONNECTION  As Long = 22
Private Const INTERNET_OPTION_REQUEST_FLAGS  As Long = 23
Private Const INTERNET_OPTION_EXTENDED_ERROR  As Long = 24
Private Const INTERNET_OPTION_RECEIVE_ALL_MODE  As Long = 25
Private Const INTERNET_OPTION_OFFLINE_MODE  As Long = 26
Private Const INTERNET_OPTION_CACHE_STREAM_HANDLE  As Long = 27
Private Const INTERNET_OPTION_USERNAME  As Long = 28
Private Const INTERNET_OPTION_PASSWORD  As Long = 29
Private Const INTERNET_OPTION_ASYNC  As Long = 30
Private Const INTERNET_OPTION_SECURITY_KEY_BITNESS  As Long = 31
Private Const INTERNET_OPTION_SECURITY_CERTIFICATE  As Long = 32

Private Const INTERNET_FIRST_OPTION  As Long = INTERNET_OPTION_CALLBACK
Private Const INTERNET_LAST_OPTION  As Long = INTERNET_OPTION_SECURITY_CERTIFICATE



Const INTERNET_ERROR_BASE = 12000

Private Const ERROR_INTERNET_OUT_OF_HANDLES = (INTERNET_ERROR_BASE + 1)
Private Const ERROR_INTERNET_TIMEOUT = (INTERNET_ERROR_BASE + 2)
Private Const ERROR_INTERNET_EXTENDED_ERROR = (INTERNET_ERROR_BASE + 3)
Private Const ERROR_INTERNET_INTERNAL_ERROR = (INTERNET_ERROR_BASE + 4)
Private Const ERROR_INTERNET_INVALID_URL = (INTERNET_ERROR_BASE + 5)
Private Const ERROR_INTERNET_UNRECOGNIZED_SCHEME = (INTERNET_ERROR_BASE + 6)
Private Const ERROR_INTERNET_NAME_NOT_RESOLVED = (INTERNET_ERROR_BASE + 7)
Private Const ERROR_INTERNET_PROTOCOL_NOT_FOUND = (INTERNET_ERROR_BASE + 8)
Private Const ERROR_INTERNET_INVALID_OPTION = (INTERNET_ERROR_BASE + 9)
Private Const ERROR_INTERNET_BAD_OPTION_LENGTH = (INTERNET_ERROR_BASE + 10)
Private Const ERROR_INTERNET_OPTION_NOT_SETTABLE = (INTERNET_ERROR_BASE + 11)
Private Const ERROR_INTERNET_SHUTDOWN = (INTERNET_ERROR_BASE + 12)
Private Const ERROR_INTERNET_INCORRECT_USER_NAME = (INTERNET_ERROR_BASE + 13)
Private Const ERROR_INTERNET_INCORRECT_PASSWORD = (INTERNET_ERROR_BASE + 14)
Private Const ERROR_INTERNET_LOGIN_FAILURE = (INTERNET_ERROR_BASE + 15)
Private Const ERROR_INTERNET_INVALID_OPERATION = (INTERNET_ERROR_BASE + 16)
Private Const ERROR_INTERNET_OPERATION_CANCELLED = (INTERNET_ERROR_BASE + 17)
Private Const ERROR_INTERNET_INCORRECT_HANDLE_TYPE = (INTERNET_ERROR_BASE + 18)
Private Const ERROR_INTERNET_INCORRECT_HANDLE_STATE = (INTERNET_ERROR_BASE + 19)
Private Const ERROR_INTERNET_NOT_PROXY_REQUEST = (INTERNET_ERROR_BASE + 20)
Private Const ERROR_INTERNET_REGISTRY_VALUE_NOT_FOUND = (INTERNET_ERROR_BASE + 21)
Private Const ERROR_INTERNET_BAD_REGISTRY_PARAMETER = (INTERNET_ERROR_BASE + 22)
Private Const ERROR_INTERNET_NO_DIRECT_ACCESS = (INTERNET_ERROR_BASE + 23)
Private Const ERROR_INTERNET_NO_CONTEXT = (INTERNET_ERROR_BASE + 24)
Private Const ERROR_INTERNET_NO_CALLBACK = (INTERNET_ERROR_BASE + 25)
Private Const ERROR_INTERNET_REQUEST_PENDING = (INTERNET_ERROR_BASE + 26)
Private Const ERROR_INTERNET_INCORRECT_FORMAT = (INTERNET_ERROR_BASE + 27)
Private Const ERROR_INTERNET_ITEM_NOT_FOUND = (INTERNET_ERROR_BASE + 28)
Private Const ERROR_INTERNET_CANNOT_CONNECT = (INTERNET_ERROR_BASE + 29)
Private Const ERROR_INTERNET_CONNECTION_ABORTED = (INTERNET_ERROR_BASE + 30)
Private Const ERROR_INTERNET_CONNECTION_RESET = (INTERNET_ERROR_BASE + 31)
Private Const ERROR_INTERNET_FORCE_RETRY = (INTERNET_ERROR_BASE + 32)
Private Const ERROR_INTERNET_ZONE_CROSSING = (INTERNET_ERROR_BASE + 33)
Private Const ERROR_INTERNET_MIXED_SECURITY = (INTERNET_ERROR_BASE + 34)
Private Const ERROR_INTERNET_SSL_CERT_CN_INVALID = (INTERNET_ERROR_BASE + 35)
Private Const ERROR_INTERNET_HANDLE_EXISTS = (INTERNET_ERROR_BASE + 36)

'//
'// FTP API errors
'//

Private Const ERROR_FTP_TRANSFER_IN_PROGRESS = (INTERNET_ERROR_BASE + 110)
Private Const ERROR_FTP_DROPPED = (INTERNET_ERROR_BASE + 111)

'//
'// gopher API errors
'//

Private Const ERROR_GOPHER_PROTOCOL_ERROR = (INTERNET_ERROR_BASE + 130)
Private Const ERROR_GOPHER_NOT_FILE = (INTERNET_ERROR_BASE + 131)
Private Const ERROR_GOPHER_DATA_ERROR = (INTERNET_ERROR_BASE + 132)
Private Const ERROR_GOPHER_END_OF_DATA = (INTERNET_ERROR_BASE + 133)
Private Const ERROR_GOPHER_INVALID_LOCATOR = (INTERNET_ERROR_BASE + 134)
Private Const ERROR_GOPHER_INCORRECT_LOCATOR_TYPE = (INTERNET_ERROR_BASE + 135)
Private Const ERROR_GOPHER_NOT_GOPHER_PLUS = (INTERNET_ERROR_BASE + 136)
Private Const ERROR_GOPHER_ATTRIBUTE_NOT_FOUND = (INTERNET_ERROR_BASE + 137)
Private Const ERROR_GOPHER_UNKNOWN_LOCATOR = (INTERNET_ERROR_BASE + 138)

'//
'// HTTP API errors
'//

Private Const ERROR_HTTP_HEADER_NOT_FOUND = (INTERNET_ERROR_BASE + 150)
Private Const ERROR_HTTP_DOWNLEVEL_SERVER = (INTERNET_ERROR_BASE + 151)
Private Const ERROR_HTTP_INVALID_SERVER_RESPONSE = (INTERNET_ERROR_BASE + 152)
Private Const ERROR_HTTP_INVALID_HEADER = (INTERNET_ERROR_BASE + 153)
Private Const ERROR_HTTP_INVALID_QUERY_REQUEST = (INTERNET_ERROR_BASE + 154)
Private Const ERROR_HTTP_HEADER_ALREADY_EXISTS = (INTERNET_ERROR_BASE + 155)

'get last error
Declare Function GetLastError Lib "kernel32" () As Long

'local time-out value (in case someone won't call ofx_InetSetTimeout
Private s_nTimeout As Long

'------------------------------------------------------------------------------
' Function: ofx_InetOpenURL
'
' Purpose:  This function begins reading an FTP, Gopher, or HTTP Universal
'           Resource Locator (URL).
'
' Params:   sURL    (I) The full URL (www.mossmicro.com)
'
' Returns:  A string with the contents of the URL (more than likely in the form
'           of HTML).
'
' Notes:    Use this function to get the contents of a URL from a remote server.
'           Note that the function expects the sURL parameter to start with a protocol
'           specifier (HTTP://, FTP://, GOPHER://) otherwise, the function will fail.
'------------------------------------------------------------------------------
Function ofx_InetOpenURL(sURL As String) As String
    On Error GoTo ofx_InetOpenURL_Error
    
    Dim hInternet As Long
    
    If (0& = ofxApp.hInternetSession) Then
        If (Not (ofx_InetOpenSession(ofxApp.hInternetSession))) Then
            Exit Function
        End If
    End If
    
    Dim nFlags As Long
    nFlags = INTERNET_FLAG_EXISTING_CONNECT Or INTERNET_FLAG_RELOAD Or INTERNET_FLAG_DONT_CACHE Or INTERNET_FLAG_RAW_DATA
    
    Const BUF_SIZE = 1024
    
    Dim dwBytesRead As Long
    Dim lpszBuf As String * BUF_SIZE
    Dim bRead As Boolean
    Dim strData As String
    
    hInternet = InternetOpenUrl(ofxApp.hInternetSession, sURL, _
        vbNullString, 0, nFlags, 0)
       
    If (hInternet) Then
        
        Do
            bRead = InternetReadFile(hInternet, lpszBuf, BUF_SIZE, dwBytesRead)
                                   
            If (bRead And dwBytesRead > 0) Then
                strData = strData + Left$(lpszBuf, dwBytesRead)
            End If
            
        Loop While (bRead And dwBytesRead > 0 And (dwBytesRead = BUF_SIZE And dwBytesRead > 0))
                   
        InternetCloseHandle hInternet
    
        ofx_InetOpenURL = strData
    
    Else
        Dim dwError As Long
        dwError = GetLastError()
                
        MsgBox "Could not open URL: " & sURL
    End If
    
ofx_InetOpenURL_Exit:
    Exit Function
ofx_InetOpenURL_Error:
    Call ofx_GenericError("ofx_InetOpenURL()", Err)
    Resume ofx_InetOpenURL_Exit
End Function


'------------------------------------------------------------------------------
' Function: ofx_InetOpenSession
'
' Purpose:  Open an Internet session.
'
' Params:   hSession    (O) HINTERNET session handle
'
' Returns:  True if the session was opened successfully
'
' Notes:    The Framework keeps a global Internet session handle in the ofxApp
'           variable. This function is called the first time ofx_InetOpenURL() is called,
'           so you will not normally have to call this one by yourself.
'------------------------------------------------------------------------------
Public Function ofx_InetOpenSession(hSession As Long) As Boolean
    
    If (0 = s_nTimeout) Then
        ofx_InetSetTimeout 10        '30 seconds
    End If
    
    hSession = InternetOpen(App.Title, _
            PRE_CONFIG_INTERNET_ACCESS, vbNullString, _
            INTERNET_INVALID_PORT_NUMBER, INTERNET_NO_CALLBACK)
            
    ofx_InetOpenSession = (hSession <> 0&)
    
End Function

'------------------------------------------------------------------------------
' Sub:      ofx_InetCloseSession
'
' Purpose:  Closes the Internet session.
'
' Params:   hSession    (I) HINTERNET session handle
'
' Notes:    The Framework keeps a global Internet session handle in the ofxApp
'           variable. Normally, this function will be called in the
'           ofx_Uninitialize() procedure in module OfxInitExit.
'------------------------------------------------------------------------------
Public Sub ofx_InetCloseSession(hSession As Long)
    If (hSession) Then
        Debug.Print InternetCloseHandle(hSession)
    End If
    hSession = 0&
End Sub



'------------------------------------------------------------------------------
' Function: ofx_InetSetTimeout
'
' Purpose:  Sets the time-out (in milliseconds) that the Internet functions wait
'           before returning an error.
'
' Params:   ms  (I) The number of Milliseconds to set as the time-out
'
' Returns:  True or False (True if it worked)
'
' Notes:    The default time-out is infinity, so this would normally be a good
'           function to call.
'------------------------------------------------------------------------------
Public Function ofx_InetSetTimeout(ms As Long) As Boolean

    'local to this module
    s_nTimeout = ms
    
    Dim dwLen As Long
    dwLen = 4&
    Dim hNull As Long
    hNull = 0&
    
    Debug.Print InternetSetOption(hNull, INTERNET_OPTION_SEND_TIMEOUT, ms, dwLen)
    Debug.Print InternetSetOption(hNull, INTERNET_OPTION_SEND_TIMEOUT, ms, dwLen)
    Debug.Print InternetSetOption(hNull, INTERNET_OPTION_RECEIVE_TIMEOUT, ms, dwLen)
    Debug.Print InternetSetOption(hNull, INTERNET_OPTION_CONNECT_TIMEOUT, ms, dwLen)
    Debug.Print InternetSetOption(hNull, INTERNET_OPTION_DATA_SEND_TIMEOUT, ms, dwLen)
    Debug.Print InternetSetOption(hNull, INTERNET_OPTION_DATA_RECEIVE_TIMEOUT, ms, dwLen)
            
    ofx_InetSetTimeout = True
    
End Function

'------------------------------------------------------------------------------
' Function: ofx_InetCanonicalizeUrl
'
' Purpose:  Converts a URL to a canonical form.
'
' Params:   sStringIN   (I) The string to "Canonicalize"
'
' Returns:  The "Canonicalized" string.
'
' Notes:    You should use this function to make strings that occur AFTER the
'           URL portion of the command you are sending to ofx_InetOpenUrl().
'
' Example:  This URL will bomb:
'
'           http://www.mossmicro.com/queries?Param1=Blue Ice Cream!&Param2=Green Ice Cream!
'
'           You should first "Canonicalize" the part AFTER the question mark.
'           Then you could send:
'
'           http://www.mossmicro.com/queries?Param1%3DBlue%20Ice%20Cream%21%26Param2%3DGreen%20Ice%20Cream%21
'------------------------------------------------------------------------------
Public Function ofx_InetCanonicalizeUrl(sStringIn As String) As String
    On Error GoTo ofx_InetCanonicalizeUrl_Err
    
    Dim sStringOut As String
    
    'The OUT string could potentially be 3 times as large as the IN string
    sStringOut = String$(Len(sStringIn) * 3, 0)
    
    Dim dwResult As Long, dwLength As Long
    dwLength = Len(sStringIn) * 3
    
    If (InternetCanonicalizeUrl(sStringIn, sStringOut, dwLength, 0)) Then
        ofx_InetCanonicalizeUrl = Left$(sStringOut, dwLength)
    End If
    
ofx_InetCanonicalizeUrl_Exit:
    On Error Resume Next
    Exit Function
ofx_InetCanonicalizeUrl_Err:
    ofx_GenericError "ofx_InetCanonicalizeUrl()"
    Resume ofx_InetCanonicalizeUrl_Exit
End Function

#End If     ' OFXOPT_INET


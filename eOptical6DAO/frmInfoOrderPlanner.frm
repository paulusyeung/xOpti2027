VERSION 5.00
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Object = "{E8671A8B-E5DD-11CD-836C-0000C0C14E92}#1.0#0"; "SSCALA32.OCX"
Begin VB.Form frmInfoOrderPlanner 
   Caption         =   "Order Planner"
   ClientHeight    =   6780
   ClientLeft      =   1140
   ClientTop       =   1290
   ClientWidth     =   10395
   LinkTopic       =   "Form1"
   MouseIcon       =   "frmInfoOrderPlanner.frx":0000
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6780
   ScaleWidth      =   10395
   Begin TrueDBGrid50.TDBGrid dbgDailyOrder 
      Bindings        =   "frmInfoOrderPlanner.frx":030A
      Height          =   1635
      Left            =   0
      OleObjectBlob   =   "frmInfoOrderPlanner.frx":0326
      TabIndex        =   1
      Top             =   5100
      Width           =   9255
   End
   Begin VB.Data dtcDailyOrder 
      Caption         =   "DailyOrder"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   7680
      Options         =   4
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   5640
      Visible         =   0   'False
      Width           =   2655
   End
   Begin VB.Data dtcAllOrder 
      Caption         =   "AllOrder"
      Connect         =   "Access 2000;"
      DatabaseName    =   "SynergyV.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   315
      Left            =   7680
      Options         =   4
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   5280
      Visible         =   0   'False
      Width           =   2655
   End
   Begin Threed.SSFrame fraOptions 
      Height          =   1935
      Left            =   8040
      TabIndex        =   6
      Top             =   1980
      Visible         =   0   'False
      Width           =   2175
      _ExtentX        =   3836
      _ExtentY        =   3413
      _Version        =   131074
      ForeColor       =   0
      Enabled         =   0   'False
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Caption         =   "Options"
      Begin VB.CheckBox chkVoidedOrder 
         Caption         =   "Voided Order"
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   1080
         Width           =   1575
      End
      Begin VB.CheckBox chkCompletedOrder 
         Caption         =   "Completed Order"
         Height          =   255
         Left            =   120
         TabIndex        =   8
         Top             =   720
         Width           =   1575
      End
      Begin VB.CheckBox chkOutstandingOrder 
         Caption         =   "Outstanding Order"
         Height          =   255
         Left            =   120
         TabIndex        =   7
         Top             =   360
         Value           =   1  'Checked
         Width           =   1695
      End
      Begin Threed.SSCommand cmdCancel 
         Height          =   375
         Left            =   1200
         TabIndex        =   11
         Top             =   1440
         Width           =   855
         _ExtentX        =   1508
         _ExtentY        =   661
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "Cancel"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
      Begin Threed.SSCommand cmdOK 
         Height          =   375
         Left            =   120
         TabIndex        =   10
         Top             =   1440
         Width           =   855
         _ExtentX        =   1508
         _ExtentY        =   661
         _Version        =   131074
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Caption         =   "OK"
         ButtonStyle     =   2
         BevelWidth      =   1
         Outline         =   0   'False
      End
   End
   Begin SSCalendarWidgets_A.SSMonth calMonthPlanner 
      Height          =   5055
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   9255
      _Version        =   65543
      _ExtentX        =   16325
      _ExtentY        =   8916
      _StockProps     =   76
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      stylesets.count =   2
      stylesets(0).Name=   "HasOrder"
      stylesets(0).Picture=   "frmInfoOrderPlanner.frx":3EBC
      stylesets(1).Name=   "Sunday"
      stylesets(1).ForeColor=   255
      stylesets(1).Picture=   "frmInfoOrderPlanner.frx":41D6
      DayNumberAlignment=   0
      ShowCentury     =   -1  'True
   End
   Begin Threed.SSCommand cmdOptions 
      Height          =   375
      Left            =   9600
      TabIndex        =   5
      ToolTipText     =   "Options"
      Top             =   1380
      Width           =   495
      _ExtentX        =   873
      _ExtentY        =   661
      _Version        =   131074
      PictureFrames   =   1
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Picture         =   "frmInfoOrderPlanner.frx":41F2
      ButtonStyle     =   2
      BevelWidth      =   0
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdTake2 
      Height          =   435
      Left            =   9600
      TabIndex        =   4
      ToolTipText     =   "About Preview Product"
      Top             =   6240
      Width           =   495
      _ExtentX        =   873
      _ExtentY        =   767
      _Version        =   131074
      PictureFrames   =   1
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Picture         =   "frmInfoOrderPlanner.frx":4644
      ButtonStyle     =   2
      BevelWidth      =   0
      Outline         =   0   'False
   End
   Begin Threed.SSRibbon cmdDualPage 
      Height          =   435
      Left            =   9600
      TabIndex        =   3
      ToolTipText     =   "Toggle 1/2 Month Planner"
      Top             =   720
      Width           =   495
      _ExtentX        =   873
      _ExtentY        =   767
      _Version        =   131074
      BackColor       =   12632256
      PictureFrames   =   1
      Picture         =   "frmInfoOrderPlanner.frx":4F1E
      ButtonStyle     =   2
      BevelWidth      =   0
      PictureDnFrames =   1
      Outline         =   0   'False
      PictureDn       =   "frmInfoOrderPlanner.frx":5848
   End
   Begin Threed.SSCommand cmdClose 
      Height          =   435
      Left            =   9600
      TabIndex        =   2
      ToolTipText     =   "Quit Order Planner"
      Top             =   180
      Width           =   495
      _ExtentX        =   873
      _ExtentY        =   767
      _Version        =   131074
      PictureFrames   =   1
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Picture         =   "frmInfoOrderPlanner.frx":6172
      ButtonStyle     =   2
      BevelWidth      =   0
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmInfoOrderPlanner"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub calMonthPlanner_Click()
    Call RetrieveDailyOrder
End Sub

Private Sub calMonthPlanner_InitMonth(MonthNum As Integer, YearNum As Integer, RtnCancel As Integer)
    Call RetrieveAllOrder
End Sub

Private Sub calMonthPlanner_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    frmInfoOrderPlanner.MousePointer = vbDefault

End Sub


Private Sub cmdCancel_Click()
    fraOptions.Visible = False
    fraOptions.Enabled = False
End Sub

Private Sub cmdClose_Click()
    Unload Me
End Sub



Private Sub cmdDualPage_Click(Value As Integer)
    If cmdDualPage.Value Then
        calMonthPlanner.NumberOfMonths = 2
        calMonthPlanner.FontName = "Arial"
        calMonthPlanner.FontSize = 8.25
    Else
        calMonthPlanner.NumberOfMonths = 1
        calMonthPlanner.FontName = "Arial"
        calMonthPlanner.FontSize = 9.75
    End If
End Sub


Private Sub cmdOK_Click()
    fraOptions.Visible = False
    fraOptions.Enabled = False
    Call RetrieveAllOrder
End Sub

Private Sub cmdOptions_Click()
    fraOptions.Visible = True
    fraOptions.Enabled = True
    chkOutstandingOrder.SetFocus
End Sub

Private Sub cmdTake2_Click()
    MsgBox "This is a Product Preview." & Chr(13) & _
           "Would be available in next version." & Chr(13) & Chr(13) & _
           "Check this out with our Sales Department."
End Sub

Private Sub dbgDailyOrder_DblClick()
    Dim strTxNumber As String
    
    strTxNumber = ofx_CStr(dbgDailyOrder.Columns("Order Number").Value)
    If strTxNumber <> "" Then
        RptTxNumberFrom = strTxNumber
        Screen.MousePointer = vbHourGlasses
        Call PrintOrder(1, 0)
    End If
End Sub


Private Sub dbgDailyOrder_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    frmInfoOrderPlanner.MousePointer = vbCustom
End Sub


Private Sub Form_Activate()
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
End Sub




Private Sub RetrieveAllOrder()
    Dim dtmFromDate, dtmToDate As Date
    Dim intdatyCount As Integer
    Dim strOption, strSQL As String
    Dim strFromDate, strToDate As String
    
    Screen.MousePointer = vbHourglass
    ' Get the Date range from the visible month(s)
    dtmFromDate = calMonthPlanner.VisibleMonth(0).Day(1).Date
    If calMonthPlanner.NumberOfMonths = 1 Then
        ' One Month Planner
        intDayCount = calMonthPlanner.VisibleMonth(0).DayCount
        dtmToDate = calMonthPlanner.VisibleMonth(0).Day(intDayCount).Date
'        calMonthPlanner.VisibleMonth(0).Day(1).StyleSet = "HasOrder"
    Else
        ' Two Month Planner
        intDayCount = calMonthPlanner.VisibleMonth(1).DayCount
        dtmToDate = calMonthPlanner.VisibleMonth(1).Day(intDayCount).Date
'        calMonthPlanner.VisibleMonth(1).Day(1).StyleSet = "HasOrder"
    End If
    
    strFromDate = ofx_CStr(dtmFromDate)
    strToDate = ofx_CStr(dtmToDate)
    '
    strOption = ""
    If chkOutstandingOrder.Value Then
        strOption = "'0','1'"
    End If
    If chkVoidedOrder.Value Then
        If strOption = "" Then
            strOption = strOption & "'2'"
        Else
            strOption = strOption & ",'2'"
        End If
    End If
    If chkCompletedOrder.Value Then
        If strOption = "" Then
            strOption = strOption & "'3'"
        Else
            strOption = strOption & ",'3'"
        End If
    End If
    '
    strSQL = "SELECT DISTINCTROW DateOfEntry FROM TxHeader " & _
             "WHERE DateOfEntry >= #" & dtmFromDate & "#" & _
             " And DateOfEntry <= #" & dtmToDate & "#" & _
             " And TxType = 'SA' " & _
             " And Status In (" & strOption & ") " & _
             "ORDER BY DateOfEntry"
    dtcAllOrder.RecordSource = strSQL
    dtcAllOrder.Refresh
    dtcAllOrder.UpdateControls
    
    Call MarkDayWithOrder
    Screen.MousePointer = vbDefault
End Sub






Private Sub RetrieveDailyOrder()
    Dim SelectedDate As Date
    Dim strOption, strSQL, strDate As String
    
    Screen.MousePointer = vbHourglass
'    SelectedDate = calMonthPlanner.SelectedDays(0).Date
    If calMonthPlanner.SelectedDays.Count = 0 Then Exit Sub
    strDate = ofx_CStr(calMonthPlanner.SelectedDays(0).Date)
    '
    strOption = ""
    If chkOutstandingOrder.Value Then
        strOption = "'0','1'"
    End If
    If chkVoidedOrder.Value Then
        If strOption = "" Then
            strOption = strOption & "'2'"
        Else
            strOption = strOption & ",'2'"
        End If
    End If
    If chkCompletedOrder.Value Then
        If strOption = "" Then
            strOption = strOption & "'3'"
        Else
            strOption = strOption & ",'3'"
        End If
    End If
    '
    strSQL = "SELECT * FROM qrySOrderSimple " & _
             "WHERE DateOfEntry = #" & strDate & "# " & _
             " And [TxHeader].[Status] In (" & strOption & ") " & _
             "ORDER BY TxNumber"
    dtcDailyOrder.RecordSource = strSQL
    dtcDailyOrder.Refresh
    dtcDailyOrder.UpdateControls
    dbgDailyOrder.Refresh
    Screen.MousePointer = vbDefault
End Sub

Private Sub MarkDayWithOrder()
    If IsTableEmpty(dtcAllOrder.Recordset) Then Exit Sub
    
    Dim i As Integer
    
    For i = 1 To (calMonthPlanner.VisibleMonth(0).DayCount)
        calMonthPlanner.Day(i).StyleSet = ""
    Next i

'    calMonthPlanner.SelectionType = 1
    With dtcAllOrder.Recordset
        .MoveFirst
        Do While Not .EOF
'            intDay = DatePart("d", !DateOfEntry)
            calMonthPlanner.Day(DatePart("d", !DateOfEntry)).StyleSet = "HasOrder"
'            calMonthPlanner.SelectedDays.Add !DateOfEntry
'            calMonthPlanner.DayofWeek(1).StyleSet = "Sunday"
            .MoveNext
        Loop
    End With
'    calMonthPlanner.SelectionType = 1
    
'    For i = 0 To (calMonthPlanner.SelectedDays.Count - 1)
'        calMonthPlanner.SelectedDays(i).StyleSet = "HasOrder"
'    Next i
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Me.MousePointer = vbDefault

End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

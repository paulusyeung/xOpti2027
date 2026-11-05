VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmClass 
   Caption         =   "Class"
   ClientHeight    =   4515
   ClientLeft      =   1455
   ClientTop       =   2595
   ClientWidth     =   8955
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4515
   ScaleWidth      =   8955
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Bindings        =   "frmClass.frx":0000
      Height          =   2055
      Left            =   120
      OleObjectBlob   =   "frmClass.frx":0017
      TabIndex        =   6
      TabStop         =   0   'False
      Top             =   2280
      Width           =   5535
   End
   Begin VB.Data dtcDepartment 
      Caption         =   "Department"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   6240
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "SELECT DepartmentCode, DepartmentName FROM Department"
      Top             =   2640
      Visible         =   0   'False
      Width           =   2295
   End
   Begin VB.Data dtcClass 
      Caption         =   "Class"
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   6240
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   3000
      Visible         =   0   'False
      Width           =   2295
   End
   Begin VB.TextBox txtFields 
      DataField       =   "ClassName"
      DataSource      =   "dtcClass"
      Height          =   285
      Index           =   2
      Left            =   1320
      MaxLength       =   30
      TabIndex        =   2
      Top             =   1875
      Width           =   2775
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   7
      Top             =   0
      Width           =   8955
      _Version        =   131073
      _ExtentX        =   15796
      _ExtentY        =   1906
      _StockProps     =   69
      BackColor       =   12632256
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      FloatingCaption =   "SSToolbar1"
      AlreadyCreated  =   -1  'True
      Outline         =   0   'False
      BackColorHelp   =   12648447
      ToolsetNumBtnStates=   3
      BtnGroupSpacing =   4
      BtnSpacing      =   0
      Btns            =   9
      ToolsetPicture  =   "frmClass.frx":2960
      BC              =   9
      BtnToolNum(0)   =   0
      BtnPlaceHolder(0)=   0   'False
      BtnToolNum(1)   =   1
      BtnPlaceHolder(1)=   0   'False
      BtnToolNum(2)   =   2
      BtnPlaceHolder(2)=   0   'False
      BtnToolNum(3)   =   3
      BtnPlaceHolder(3)=   0   'False
      BtnToolNum(4)   =   4
      BtnPlaceHolder(4)=   0   'False
      BtnToolNum(5)   =   5
      BtnPlaceHolder(5)=   0   'False
      BtnToolNum(6)   =   6
      BtnPlaceHolder(6)=   0   'False
      BtnToolNum(7)   =   7
      BtnPlaceHolder(7)=   0   'False
      BtnToolNum(8)   =   8
      BtnPlaceHolder(8)=   0   'False
      ToolsetNumTools =   9
      ToolsetToolID(0)=   "ID_Add"
      ToolsetToolHelp(0)=   "Add Record"
      ToolsetToolMnemonic(0)=   "a"
      ToolsetToolGroup(0)=   1
      ToolsetToolID(1)=   "ID_Delete"
      ToolsetToolHelp(1)=   "Delete Record"
      ToolsetToolMnemonic(1)=   "d"
      ToolsetToolGroup(1)=   1
      ToolsetToolID(2)=   "ID_Undo"
      ToolsetToolHelp(2)=   "Undo Edit"
      ToolsetToolMnemonic(2)=   "u"
      ToolsetToolGroup(2)=   1
      ToolsetToolID(3)=   "ID_Save"
      ToolsetToolHelp(3)=   "Save Record"
      ToolsetToolMnemonic(3)=   "s"
      ToolsetToolGroup(3)=   1
      ToolsetToolID(4)=   "ID_First"
      ToolsetToolHelp(4)=   "First Record"
      ToolsetToolMnemonic(4)=   "f"
      ToolsetToolGroup(4)=   2
      ToolsetToolID(5)=   "ID_Previous"
      ToolsetToolHelp(5)=   "Previous Record"
      ToolsetToolMnemonic(5)=   "p"
      ToolsetToolGroup(5)=   2
      ToolsetToolID(6)=   "ID_Next"
      ToolsetToolHelp(6)=   "Next Record"
      ToolsetToolMnemonic(6)=   "n"
      ToolsetToolGroup(6)=   2
      ToolsetToolID(7)=   "ID_Last"
      ToolsetToolHelp(7)=   "Last Record"
      ToolsetToolMnemonic(7)=   "l"
      ToolsetToolGroup(7)=   2
      ToolsetToolID(8)=   "ID_Exit"
      ToolsetToolHelp(8)=   "Exit Task"
      ToolsetToolMnemonic(8)=   "x"
      ToolsetToolGroup(8)=   3
      MouseIcon       =   "frmClass.frx":101F2
   End
   Begin MSMask.MaskEdBox mskClassCode 
      DataField       =   "ClassCode"
      DataSource      =   "dtcClass"
      Height          =   255
      Left            =   1320
      TabIndex        =   1
      Top             =   1560
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   450
      _Version        =   393216
      PromptInclude   =   0   'False
      MaxLength       =   2
      Format          =   "Null String (default)"
      Mask            =   ">??"
      PromptChar      =   "_"
   End
   Begin MSDBCtls.DBCombo dbcDepartment 
      Bindings        =   "frmClass.frx":1020E
      Height          =   315
      Left            =   1320
      TabIndex        =   5
      TabStop         =   0   'False
      Top             =   1200
      Width           =   2775
      _ExtentX        =   4895
      _ExtentY        =   556
      _Version        =   393216
      BackColor       =   16777215
      ForeColor       =   0
      ListField       =   "DepartmentName"
      BoundColumn     =   "DepartmentCode"
      Text            =   "dbcDepartment"
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   315
      Left            =   4080
      TabIndex        =   8
      Top             =   1200
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   556
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
      Picture         =   "frmClass.frx":1022A
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin VB.Label lblLabels 
      Caption         =   "Class Name:"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   4
      Top             =   1905
      Width           =   975
   End
   Begin VB.Label lblLabels 
      Caption         =   "Class Code:"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   3
      Top             =   1575
      Width           =   975
   End
   Begin VB.Label lblLabels 
      Caption         =   "Department:"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   0
      Top             =   1200
      Width           =   975
   End
End
Attribute VB_Name = "frmClass"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------
' Procedure: cmdAdd_Click
' Purpose:   TBD
' Params:    None
' Returns:   N/A
'-----------------------
Private Sub cmdAdd_Click()

    On Error GoTo cmdAdd_Click_Err

    
cmdAdd_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                          ' Tutorial Autocode
    Exit Sub                                      ' Tutorial Autocode
cmdAdd_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdAdd_Click()", Err)  ' Tutorial Autocode
    Resume cmdAdd_Click_Exit

End Sub

'-----------------------
' Procedure: cmdDelete_Click
' Purpose:   TBD
' Params:    None
' Returns:   N/A
'-----------------------
Private Sub cmdDelete_Click()

    On Error GoTo cmdDelete_Click_Err


cmdDelete_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                             ' Tutorial Autocode
    Exit Sub                                         ' Tutorial Autocode
cmdDelete_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdDelete_Click()", Err)  ' Tutorial Autocode
    Resume cmdDelete_Click_Exit

End Sub

'-----------------------
' Procedure: cmdRefresh_Click
' Purpose:   TBD
' Params:    None
' Returns:   N/A
'-----------------------
Private Sub cmdRefresh_Click()

    On Error GoTo cmdRefresh_Click_Err


cmdRefresh_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
cmdRefresh_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdRefresh_Click()", Err)  ' Tutorial Autocode
    Resume cmdRefresh_Click_Exit

End Sub

'-----------------------
' Procedure: cmdUpdate_Click
' Purpose:   TBD
' Params:    None
' Returns:   N/A
'-----------------------
Private Sub cmdUpdate_Click()

    On Error GoTo cmdUpdate_Click_Err
    

cmdUpdate_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                             ' Tutorial Autocode
    Exit Sub                                         ' Tutorial Autocode
cmdUpdate_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdUpdate_Click()", Err)  ' Tutorial Autocode
    Resume cmdUpdate_Click_Exit

End Sub

'-----------------------
' Procedure: cmdClose_Click
' Purpose:   TBD
' Params:    None
' Returns:   N/A
'-----------------------
Private Sub cmdClose_Click()

    On Error GoTo cmdClose_Click_Err

  Unload Me

cmdClose_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                            ' Tutorial Autocode
    Exit Sub                                        ' Tutorial Autocode
cmdClose_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdClose_Click()", Err)  ' Tutorial Autocode
    Resume cmdClose_Click_Exit

End Sub

'-----------------------
' Procedure: Data1_Error
' Purpose:   TBD
' Params:    DataErr  -
'            Response -
' Returns:   N/A
'-----------------------
Private Sub Data1_Error(DataErr As Integer, Response As Integer)

    On Error GoTo Data1_Error_Err

  'This is where you would put error handling code
  'If you want to ignore errors, comment out the next line
  'If you want to trap them, add code here to handle them
  MsgBox "Data error event hit err:" & Error$(DataErr)
  Response = 0  'throw away the error

Data1_Error_Exit:                                ' Tutorial Autocode
    On Error Resume Next                         ' Tutorial Autocode
    Exit Sub                                     ' Tutorial Autocode
Data1_Error_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("Data1_Error()", Err)  ' Tutorial Autocode
    Resume Data1_Error_Exit

End Sub

'-----------------------
' Procedure: Data1_Reposition
' Purpose:   TBD
' Params:    None
' Returns:   N/A
'-----------------------
Private Sub Data1_Reposition()
  Screen.MousePointer = vbDefault
  On Error Resume Next
  'This will display the current record position
  'for dynasets and snapshots
  Data1.Caption = "Record: " & (Data1.Recordset.AbsolutePosition + 1)
  'for the table object you must set the index property when
  'the recordset gets created and use the following line
  'Data1.Caption = "Record: " & (Data1.Recordset.RecordCount * (Data1.Recordset.PercentPosition * 0.01)) + 1
End Sub

'-----------------------
' Procedure: Data1_Validate
' Purpose:   TBD
' Params:    Action -
'            Save   -
' Returns:   N/A
'-----------------------
Private Sub Data1_Validate(Action As Integer, Save As Integer)

    On Error GoTo Data1_Validate_Err

  'This is where you put validation code
  'This event gets called when the following actions occur
  Select Case Action
    Case vbDataActionMoveFirst
    Case vbDataActionMovePrevious
    Case vbDataActionMoveNext
    Case vbDataActionMoveLast
    Case vbDataActionAddNew
    Case vbDataActionUpdate
    Case vbDataActionDelete
    Case vbDataActionFind
    Case vbDataActionBookmark
    Case vbDataActionClose
  End Select
  'Screen.MousePointer = vbHourglass

Data1_Validate_Exit:                                ' Tutorial Autocode
    On Error Resume Next                            ' Tutorial Autocode
    Exit Sub                                        ' Tutorial Autocode
Data1_Validate_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("Data1_Validate()", Err)  ' Tutorial Autocode
    Resume Data1_Validate_Exit

End Sub

Private Sub dbcDepartment_Click(intArea As Integer)

    On Error GoTo dbcDepartment_Click_Err

    If intArea = dbcAreaList Then
        Dim strSQL As String
        strSQL = "SELECT * FROM Class WHERE Department = '" _
            & dbcDepartment.BoundText & "'"
        dtcClass.RecordSource = strSQL
        dtcClass.Refresh
        dtcClass.UpdateControls
    End If

dbcDepartment_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                                 ' Tutorial Autocode
    Exit Sub                                             ' Tutorial Autocode
dbcDepartment_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dbcDepartment_Click()", Err)  ' Tutorial Autocode
    Resume dbcDepartment_Click_Exit

End Sub


Private Sub dtcClass_Validate(Action As Integer, Save As Integer)

    On Error GoTo dtcClass_Validate_Err



dtcClass_Validate_Exit:                                ' Tutorial Autocode
    On Error Resume Next                               ' Tutorial Autocode
    Exit Sub                                           ' Tutorial Autocode
dtcClass_Validate_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("dtcClass_Validate()", Err)  ' Tutorial Autocode
    Resume dtcClass_Validate_Exit

End Sub

Private Sub Form_Activate()

    On Error GoTo Form_Activate_Err

    Screen.MousePointer = vbDefault
    
    'Initialize the dbcDepartment
    dbcDepartment.SetFocus
    SendKeys "{F4}{Enter}", True
    Call dbcDepartment_Click(2)

Form_Activate_Exit:                                ' Tutorial Autocode
    On Error Resume Next                           ' Tutorial Autocode
    Exit Sub                                       ' Tutorial Autocode
Form_Activate_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("Form_Activate()", Err)  ' Tutorial Autocode
    Resume Form_Activate_Exit

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)

End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub SSCommand1_Click()
    frmDept.Show vbModal
    dtcDepartment.Refresh
    dtcDepartment.UpdateControls
End Sub

Private Sub SSRibbon1_Click(Value As Integer)
    Select Case Value
    Case True
        SSRibbon1.BackColor = &HFFFFFF      ' White
    Case False
        SSRibbon1.BackColor = &HC0C0C0      ' Gray
    End Select
End Sub

Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

'    On Error GoTo SSToolbar1_Click_Err

    Select Case ToolID
        Case "ID_Add"
            Call DoAdd
        Case "ID_Delete"
            'this may produce an error if you delete the last
            'record or the only record in the recordset
            dtcClass.Recordset.Delete
            dtcClass.Recordset.MoveNext
        Case "ID_Undo"
            'this is really only needed for multi user apps
            dtcClass.Refresh
        Case "ID_Save"
            ' If new record, auto-fill the department code
            If IsNull(dtcClass.Recordset("Department")) Or _
                dtcClass.Recordset("Department") = "" Then
                dtcClass.Recordset("Department") = dbcDepartment.BoundText
            End If
            dtcClass.UpdateRecord
            dtcClass.Recordset.Bookmark = dtcClass.Recordset.LastModified
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            dtcClass.Recordset.MoveFirst
        Case "ID_Next"
            dtcClass.Recordset.MoveNext
            ' Prevent the Blank Record
            If dtcClass.Recordset.EOF Then
                Beep
                dtcClass.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcClass.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcClass.Recordset.BOF Then
                Beep
                dtcClass.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcClass.Recordset.MoveLast
    End Select

SSToolbar1_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSToolbar1_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSToolbar1_Click()", Err)  ' Tutorial Autocode
    Resume SSToolbar1_Click_Exit

End Sub


Private Sub DoAdd()
    With dtcClass.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    dtcClass.Recordset.AddNew
    mskClassCode.SetFocus
End Sub

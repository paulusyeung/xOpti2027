VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmDept 
   Caption         =   "Department"
   ClientHeight    =   3930
   ClientLeft      =   1710
   ClientTop       =   2835
   ClientWidth     =   8970
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3930
   ScaleWidth      =   8970
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Bindings        =   "frmDept.frx":0000
      Height          =   1935
      Left            =   120
      OleObjectBlob   =   "frmDept.frx":0014
      TabIndex        =   4
      TabStop         =   0   'False
      Top             =   1800
      Width           =   5295
   End
   Begin VB.Data Data1 
      Connect         =   "Access 2000;"
      DatabaseName    =   "Synergyv.mdb"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   6000
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "Department"
      Top             =   2280
      Visible         =   0   'False
      Width           =   2775
   End
   Begin VB.TextBox txtFields 
      DataField       =   "DepartmentName"
      DataSource      =   "Data1"
      Height          =   285
      Index           =   1
      Left            =   1800
      MaxLength       =   30
      TabIndex        =   2
      Top             =   1440
      Width           =   3375
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   5
      Top             =   0
      Width           =   8970
      _Version        =   131073
      _ExtentX        =   15822
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
      BackColorHelp   =   14286847
      ToolsetNumBtnStates=   3
      BtnGroupSpacing =   4
      BtnSpacing      =   0
      Btns            =   9
      ToolsetPicture  =   "frmDept.frx":2531
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
      MouseIcon       =   "frmDept.frx":FDC3
   End
   Begin MSMask.MaskEdBox MaskEdBox1 
      DataField       =   "DepartmentCode"
      DataSource      =   "Data1"
      Height          =   255
      Left            =   1800
      TabIndex        =   1
      Top             =   1140
      Width           =   615
      _ExtentX        =   1085
      _ExtentY        =   450
      _Version        =   393216
      PromptInclude   =   0   'False
      MaxLength       =   2
      Mask            =   ">??"
      PromptChar      =   "_"
   End
   Begin VB.Label lblLabels 
      Caption         =   "Department Name:"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   3
      Top             =   1455
      Width           =   1695
   End
   Begin VB.Label lblLabels 
      Caption         =   "Department Code:"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   0
      Top             =   1140
      Width           =   1695
   End
End
Attribute VB_Name = "frmDept"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdAdd_Click()

    On Error GoTo cmdAdd_Click_Err


cmdAdd_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                          ' Tutorial Autocode
    Exit Sub                                      ' Tutorial Autocode
cmdAdd_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdAdd_Click()", Err)  ' Tutorial Autocode
    Resume cmdAdd_Click_Exit

End Sub

Private Sub cmdDelete_Click()

    On Error GoTo cmdDelete_Click_Err


cmdDelete_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                             ' Tutorial Autocode
    Exit Sub                                         ' Tutorial Autocode
cmdDelete_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdDelete_Click()", Err)  ' Tutorial Autocode
    Resume cmdDelete_Click_Exit

End Sub

Private Sub cmdRefresh_Click()

    On Error GoTo cmdRefresh_Click_Err


cmdRefresh_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
cmdRefresh_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdRefresh_Click()", Err)  ' Tutorial Autocode
    Resume cmdRefresh_Click_Exit

End Sub

Private Sub cmdUpdate_Click()

    On Error GoTo cmdUpdate_Click_Err


cmdUpdate_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                             ' Tutorial Autocode
    Exit Sub                                         ' Tutorial Autocode
cmdUpdate_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdUpdate_Click()", Err)  ' Tutorial Autocode
    Resume cmdUpdate_Click_Exit

End Sub

Private Sub cmdClose_Click()

    On Error GoTo cmdClose_Click_Err


cmdClose_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                            ' Tutorial Autocode
    Exit Sub                                        ' Tutorial Autocode
cmdClose_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdClose_Click()", Err)  ' Tutorial Autocode
    Resume cmdClose_Click_Exit

End Sub

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

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault

End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)

End Sub


Private Sub Form_Unload(Cancel As Integer)
    Call ofx_CloseForm(Me)
End Sub

Private Sub SSToolbar1_Click(ToolID As String, ToolNum As Integer, Btn As Integer, Value As Integer)

    On Error GoTo SSToolbar1_Click_Err

    Select Case ToolID
        Case "ID_Add"
            Call DoAdd
        Case "ID_Delete"
            'this may produce an error if you delete the last
            'record or the only record in the recordset
            Data1.Recordset.Delete
            Data1.Recordset.MoveNext
        Case "ID_Undo"
            'this is really only needed for multi user apps
            Data1.Refresh
        Case "ID_Save"
            Data1.UpdateRecord
            Data1.Recordset.Bookmark = Data1.Recordset.LastModified
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            Data1.Recordset.MoveFirst
        Case "ID_Next"
            Data1.Recordset.MoveNext
            If Data1.Recordset.EOF Then
                Beep
                Data1.Recordset.MoveLast
            End If
        Case "ID_Previous"
            Data1.Recordset.MovePrevious
            ' Prevent the Blank Record
            If Data1.Recordset.BOF Then
                Beep
                Data1.Recordset.MoveFirst
            End If
        Case "ID_Last"
            Data1.Recordset.MoveLast
    End Select

SSToolbar1_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSToolbar1_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSToolbar1_Click()", Err)  ' Tutorial Autocode
    Resume SSToolbar1_Click_Exit

End Sub



Private Sub DoAdd()
    With Data1.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    Data1.Recordset.AddNew
End Sub

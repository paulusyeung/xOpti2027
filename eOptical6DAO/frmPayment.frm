VERSION 5.00
Object = "{E79FB9BF-ECDA-11CD-956C-0000C04E4C0A}#2.0#0"; "ssdock32.ocx"
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{00028C4A-0000-0000-0000-000000000046}#5.0#0"; "TDBG5.OCX"
Begin VB.Form frmPayment 
   Caption         =   "PaymentMethods"
   ClientHeight    =   5640
   ClientLeft      =   1470
   ClientTop       =   2100
   ClientWidth     =   8955
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5640
   ScaleWidth      =   8955
   Begin TrueDBGrid50.TDBGrid TDBGrid1 
      Bindings        =   "frmPayment.frx":0000
      Height          =   2655
      Left            =   120
      OleObjectBlob   =   "frmPayment.frx":0019
      TabIndex        =   10
      TabStop         =   0   'False
      Top             =   2880
      Width           =   5895
   End
   Begin VB.TextBox Text2 
      DataField       =   "PaymentNameLong"
      DataSource      =   "dtcPayment"
      Height          =   285
      Left            =   2040
      TabIndex        =   2
      Text            =   "Text2"
      Top             =   1440
      Width           =   3375
   End
   Begin VB.Data dtcPayment 
      Connect         =   "Access 2000;"
      DatabaseName    =   "SYNERGYV.MDB"
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   5760
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   "PaymentMethods"
      Top             =   1920
      Visible         =   0   'False
      Width           =   3000
   End
   Begin VB.TextBox txtFields 
      DataField       =   "AlertLevel"
      DataSource      =   "dtcPayment"
      Height          =   285
      Index           =   3
      Left            =   2040
      MaxLength       =   4
      TabIndex        =   5
      Top             =   2445
      Width           =   1575
   End
   Begin VB.TextBox txtFields 
      DataField       =   "ExchangeRate"
      DataSource      =   "dtcPayment"
      Height          =   285
      Index           =   2
      Left            =   2040
      MaxLength       =   9
      TabIndex        =   4
      Top             =   2160
      Width           =   1575
   End
   Begin SSDesignerWidgetsToolbar.SSToolbar SSToolbar1 
      Align           =   1  'Align Top
      Height          =   1080
      Left            =   0
      TabIndex        =   11
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
      ToolsetPicture  =   "frmPayment.frx":277E
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
      MouseIcon       =   "frmPayment.frx":10010
   End
   Begin MSMask.MaskEdBox mskPaymentNameShort 
      DataField       =   "PaymentNameShort"
      DataSource      =   "dtcPayment"
      Height          =   255
      Left            =   2040
      TabIndex        =   3
      Top             =   1800
      Width           =   495
      _ExtentX        =   873
      _ExtentY        =   450
      _Version        =   393216
      PromptInclude   =   0   'False
      MaxLength       =   3
      Mask            =   ">???"
      PromptChar      =   "_"
   End
   Begin MSMask.MaskEdBox mskPaymentCode 
      DataField       =   "PaymentCode"
      DataSource      =   "dtcPayment"
      Height          =   255
      Left            =   2040
      TabIndex        =   1
      Top             =   1080
      Width           =   375
      _ExtentX        =   661
      _ExtentY        =   450
      _Version        =   393216
      PromptInclude   =   0   'False
      MaxLength       =   1
      Mask            =   ">a"
      PromptChar      =   "_"
   End
   Begin VB.Label Label1 
      Caption         =   "Payment Name Short"
      Height          =   255
      Left            =   120
      TabIndex        =   9
      Top             =   1800
      Width           =   1815
   End
   Begin VB.Label lblLabels 
      Caption         =   "Alert Level: ($)"
      Height          =   255
      Index           =   3
      Left            =   120
      TabIndex        =   8
      Top             =   2460
      Width           =   1815
   End
   Begin VB.Label lblLabels 
      Caption         =   "Exchange Rate:"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   7
      Top             =   2145
      Width           =   1815
   End
   Begin VB.Label lblLabels 
      Caption         =   "Payment Name: Long"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   6
      Top             =   1455
      Width           =   1815
   End
   Begin VB.Label lblLabels 
      Caption         =   "Payment Code:"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   0
      Top             =   1140
      Width           =   1815
   End
End
Attribute VB_Name = "frmPayment"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdAdd_Click()

    On Error GoTo cmdAdd_Click_Err

  Data1.Recordset.AddNew

cmdAdd_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                          ' Tutorial Autocode
    Exit Sub                                      ' Tutorial Autocode
cmdAdd_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdAdd_Click()", Err)  ' Tutorial Autocode
    Resume cmdAdd_Click_Exit

End Sub

Private Sub cmdDelete_Click()

    On Error GoTo cmdDelete_Click_Err

  'this may produce an error if you delete the last
  'record or the only record in the recordset
  Data1.Recordset.Delete
  Data1.Recordset.MoveNext

cmdDelete_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                             ' Tutorial Autocode
    Exit Sub                                         ' Tutorial Autocode
cmdDelete_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdDelete_Click()", Err)  ' Tutorial Autocode
    Resume cmdDelete_Click_Exit

End Sub

Private Sub cmdRefresh_Click()

    On Error GoTo cmdRefresh_Click_Err

  'this is really only needed for multi user apps
  Data1.Refresh

cmdRefresh_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
cmdRefresh_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdRefresh_Click()", Err)  ' Tutorial Autocode
    Resume cmdRefresh_Click_Exit

End Sub

Private Sub cmdUpdate_Click()

    On Error GoTo cmdUpdate_Click_Err

  Data1.UpdateRecord
  Data1.Recordset.Bookmark = Data1.Recordset.LastModified

cmdUpdate_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                             ' Tutorial Autocode
    Exit Sub                                         ' Tutorial Autocode
cmdUpdate_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("cmdUpdate_Click()", Err)  ' Tutorial Autocode
    Resume cmdUpdate_Click_Exit

End Sub

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
            dtcPayment.Recordset.Delete
            dtcPayment.Recordset.MoveNext
        Case "ID_Undo"
            dtcPayment.Refresh
        Case "ID_Save"
            dtcPayment.UpdateRecord
            dtcPayment.Recordset.Bookmark = dtcPayment.Recordset.LastModified
        Case "ID_Exit"
            Unload Me
        Case "ID_First"
            dtcPayment.Recordset.MoveFirst
        Case "ID_Next"
            dtcPayment.Recordset.MoveNext
            If dtcPayment.Recordset.EOF Then
                Beep
                dtcPayment.Recordset.MoveLast
            End If
        Case "ID_Previous"
            dtcPayment.Recordset.MovePrevious
            ' Prevent the Blank Record
            If dtcPayment.Recordset.BOF Then
                Beep
                dtcPayment.Recordset.MoveFirst
            End If
        Case "ID_Last"
            dtcPayment.Recordset.MoveLast
    End Select

SSToolbar1_Click_Exit:                                ' Tutorial Autocode
    On Error Resume Next                              ' Tutorial Autocode
    Exit Sub                                          ' Tutorial Autocode
SSToolbar1_Click_Err:                                 ' Tutorial Autocode
    Call ofx_GenericError("SSToolbar1_Click()", Err)  ' Tutorial Autocode
    Resume SSToolbar1_Click_Exit

End Sub



Private Sub DoAdd()
    With dtcPayment.Recordset
        Select Case .EditMode
            Case dbEditAdd
                Exit Sub
            Case dbEditInProgress
                .Refresh
            Case Else
        End Select
    End With
    dtcPayment.Recordset.AddNew
    mskPaymentCode.SetFocus
End Sub

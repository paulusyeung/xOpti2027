VERSION 5.00
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Begin VB.Form frmMenuIC 
   BorderStyle     =   0  'None
   Caption         =   "Inventory Control"
   ClientHeight    =   3705
   ClientLeft      =   3585
   ClientTop       =   2970
   ClientWidth     =   6120
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3705
   ScaleWidth      =   6120
   ShowInTaskbar   =   0   'False
   Begin Threed.SSCommand cmdPrintWSReturn 
      Height          =   555
      Left            =   4200
      TabIndex        =   7
      Top             =   2940
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   979
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
      Picture         =   "frmMenuIC.frx":0000
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdPrintWSInvoice 
      Height          =   555
      Left            =   2160
      TabIndex        =   6
      Top             =   2940
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   979
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
      Picture         =   "frmMenuIC.frx":0664
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdWSReturn 
      Height          =   1035
      Left            =   4200
      TabIndex        =   5
      Top             =   1920
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   1826
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
      Caption         =   "Wholesale Return"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand cmdWSInvoice 
      Height          =   1035
      Left            =   2160
      TabIndex        =   4
      Top             =   1920
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   1826
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
      Caption         =   "Wholesale Invoice"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   1575
      Left            =   120
      TabIndex        =   3
      Top             =   1920
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Stock Take"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand4 
      Height          =   1575
      Left            =   4200
      TabIndex        =   2
      Top             =   120
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Stock Adjustment"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   1575
      Left            =   2160
      TabIndex        =   1
      Top             =   120
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Stock Rejected"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   1575
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   2778
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
      Caption         =   "Stock Received"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmMenuIC"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdPrintWSInvoice_Click()
    On Error GoTo SSCommand3_Click_Err

    Dim Msg, Title As String
    Dim Style As Integer
    
        Msg = "Including packing list with invoice?"   ' Define message.
        Style = vbYesNo + vbQuestion + vbDefaultButton2 ' Define buttons.
        Title = "Printing Wholesales Invoice"  ' Define title.
        If MsgBox(Msg, Style, Title) = vbYes Then
            Call PrintWholesalesInvoice(0, 0, "wfPkList")  ' User chose Yes.
        Else
            Call PrintWholesalesInvoice(0, 0)
        End If

SSCommand3_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                              ' SDVB autocode
    Exit Sub                                          ' SDVB autocode
SSCommand3_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("SSCommand3_Click()", Err)  ' SDVB autocode
    Resume SSCommand3_Click_Exit
End Sub

Private Sub cmdPrintWSReturn_Click()
    On Error GoTo SSCommand5_Click_Err

    Call PrintWholesalesReturn(0, 0)

SSCommand5_Click_Exit:                                ' SDVB autocode
    On Error Resume Next                              ' SDVB autocode
    Exit Sub                                          ' SDVB autocode
SSCommand5_Click_Err:                                 ' SDVB autocode
    Call ofx_GenericError("SSCommand5_Click()", Err)  ' SDVB autocode
    Resume SSCommand5_Click_Exit
End Sub

Private Sub cmdWSInvoice_Click()
    If ofx_IsFormLoaded(frmWholesaleInvoice) Then
        frmWholesaleInvoice.SetFocus
        frmWholesaleInvoice.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmWholesaleInvoice.Show
    End If
End Sub

Private Sub cmdWSReturn_Click()
    If ofx_IsFormLoaded(frmWholesaleReturn) Then
        frmWholesaleReturn.SetFocus
        frmWholesaleReturn.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmWholesaleReturn.Show
    End If
End Sub

Private Sub Form_Load()
'    Call ofx_RestoreFormPosition(Me, True)
    Call ofx_CenterForm(Me)
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call ofx_SaveFormPosition(Me)
    Call ofx_CloseForm(Me)
End Sub

Private Sub SSCommand1_Click()
    If ofx_IsFormLoaded(frmStockRecEnhanced) Then
        frmStockRecEnhanced.SetFocus
        frmStockRecEnhanced.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmStockRecEnhanced.Show
    End If
End Sub


Private Sub SSCommand1_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand2_Click()
    If ofx_IsFormLoaded(frmStockReject) Then
        frmStockReject.SetFocus
        frmStockReject.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmStockReject.Show
    End If
End Sub


Private Sub SSCommand2_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand3_Click()

    If ofx_IsFormLoaded(frmStockTake) Then
        frmStockTake.SetFocus
        frmStockTake.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmStockTake.Show
    End If

End Sub

Private Sub SSCommand3_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

Private Sub SSCommand4_Click()
    If ofx_IsFormLoaded(frmStockAdjustment) Then
        frmStockAdjustment.SetFocus
        frmStockAdjustment.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmStockAdjustment.Show
    End If
End Sub




Private Sub SSCommand6_Click()
    If ofx_IsFormLoaded(frmStockRecEnhanced) Then
        frmStockRecEnhanced.SetFocus
        frmStockRecEnhanced.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmStockRecEnhanced.Show
    End If
End Sub


Private Sub SSCommand5_Click()
    frmRBIC_PostEntry.Show
End Sub


Private Sub SSCommand4_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Call SetCursorToHand
End Sub

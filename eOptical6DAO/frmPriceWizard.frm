VERSION 5.00
Object = "{C932BA88-4374-101B-A56C-00AA003668DC}#1.1#0"; "MSMASK32.OCX"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Begin VB.Form frmPriceWizard 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Price Wizard"
   ClientHeight    =   2820
   ClientLeft      =   3615
   ClientTop       =   4080
   ClientWidth     =   2895
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   2820
   ScaleWidth      =   2895
   Begin Threed.SSFrame SSFrame1 
      Height          =   2715
      Left            =   120
      TabIndex        =   0
      Top             =   0
      Width           =   2655
      _ExtentX        =   4683
      _ExtentY        =   4789
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
      Begin Threed.SSFrame SSFrame2 
         Height          =   795
         Left            =   120
         TabIndex        =   2
         Top             =   540
         Width           =   2415
         _ExtentX        =   4260
         _ExtentY        =   1402
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
         Caption         =   "Sales Tax"
         Begin VB.OptionButton optTaxNotIncluded 
            Caption         =   "Not Included"
            Height          =   195
            Left            =   240
            TabIndex        =   4
            Top             =   540
            Width           =   1215
         End
         Begin VB.OptionButton optTaxIncluded 
            Caption         =   "Included"
            Height          =   255
            Left            =   240
            TabIndex        =   3
            Top             =   240
            Width           =   1215
         End
      End
      Begin Threed.SSFrame SSFrame3 
         Height          =   735
         Left            =   120
         TabIndex        =   5
         Top             =   1380
         Width           =   2415
         _ExtentX        =   4260
         _ExtentY        =   1296
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
         Caption         =   "Selection"
         Begin VB.OptionButton optSelectSome 
            Caption         =   "Selected Items"
            Height          =   195
            Left            =   240
            TabIndex        =   7
            Top             =   480
            Width           =   1455
         End
         Begin VB.OptionButton optSelectAll 
            Caption         =   "All Items"
            Height          =   195
            Left            =   240
            TabIndex        =   6
            Top             =   240
            Width           =   1335
         End
      End
      Begin MSMask.MaskEdBox mskPriceWanted 
         Height          =   315
         Left            =   1320
         TabIndex        =   8
         Top             =   240
         Width           =   1215
         _ExtentX        =   2143
         _ExtentY        =   556
         _Version        =   393216
         Format          =   "$#,##0.00"
         PromptChar      =   "_"
      End
      Begin Threed.SSCommand cmdCancel 
         Height          =   375
         Left            =   1440
         TabIndex        =   10
         Top             =   2220
         Width           =   975
         _ExtentX        =   1720
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
         Left            =   240
         TabIndex        =   9
         Top             =   2220
         Width           =   1095
         _ExtentX        =   1931
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
      Begin VB.Label Label1 
         Caption         =   "Price Wanted:"
         Height          =   255
         Left            =   120
         TabIndex        =   1
         Top             =   240
         Width           =   1095
      End
   End
End
Attribute VB_Name = "frmPriceWizard"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdCancel_Click()
    Unload Me
    Set frmPriceWizard = Nothing
End Sub

Private Sub cmdOK_Click()
    If mskPriceWanted.Text <> "" Then Call CalcBegins
    Unload Me
    Set frmPriceWizard = Nothing
End Sub

Private Sub Form_Activate()
    ' Jump to Start Point
    mskPriceWanted.SetFocus
End Sub

Private Sub Form_Load()
    Call ofx_RestoreFormPosition(Me, True)
    
    ' Set default OptionButtons
    optTaxIncluded = True
    optSelectAll = True
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call ofx_SaveFormPosition(Me)
End Sub

Private Sub mskPriceWanted_GotFocus()
    Call AutoSelect(mskPriceWanted)
End Sub


Private Sub CalcBegins()
    If optSelectAll Then Call CalcAll
    If optSelectSome Then Call CalcSome
    frmSalesOrder.tdbgTxBody.Refresh
End Sub

Private Sub CalcAll()
    Dim curOldPrice As Currency
    curOldPrice = CalcAll_GetPrice
    Call CalcAll_SetPrice(curOldPrice)
End Sub

Private Sub CalcSome()
    Dim curOldPrice As Currency
    curOldPrice = CalcSome_GetPrice
    Call CalcSome_SetPrice(curOldPrice)
End Sub

Private Function CalcSome_GetPrice() As Currency
    Dim mySB As SelBookmarks
    Dim myCol As Columns
    Dim i As Integer
    Dim OrgTotalPrice As Currency
    
    Set mySB = frmSalesOrder.tdbgTxBody.SelBookmarks
    Set myCol = frmSalesOrder.tdbgTxBody.Columns
    
    ' Get the original total price
    For i = 0 To mySB.Count - 1
        OrgTotalPrice = OrgTotalPrice + ofx_CCur(myCol("Amount").CellValue(mySB(i)))
    Next i
    
    ' Return calculated value
    CalcSome_GetPrice = OrgTotalPrice
End Function

Private Sub CalcSome_SetPrice(myOrgPrice As Currency)
    Dim myDBG As TDBGrid
    Dim mySB As SelBookmarks
    Dim myCol As Columns
    Dim i As Integer
    Dim NewTotalPrice, NewAmount, NewMarkdown As Currency
    Dim OldQty As Integer
    Dim OldUnitPrice, OldAmount As Currency
    
    Set myDBG = frmSalesOrder.tdbgTxBody
    Set mySB = frmSalesOrder.tdbgTxBody.SelBookmarks
    Set myCol = frmSalesOrder.tdbgTxBody.Columns
    NewTotalPrice = ofx_CCur(mskPriceWanted.Text)
    
    ' Set the new price for each selected item
    For i = 0 To mySB.Count - 1
        myDBG.row = mySB(i)
        OldQty = ofx_CInt(myCol("Qty"))
        OldUnitPrice = ofx_CCur(myCol("Unit Price"))
        OldAmount = ofx_CCur(myCol("Amount"))
        
        NewAmount = OldAmount / myOrgPrice * NewTotalPrice
        If optTaxIncluded Then
            Select Case myCol("Tax")
                Case "N"    ' Tax Excluded
                    NewAmount = NewAmount
                Case "B"    ' Both GST and PST
                    NewAmount = NewAmount / 1.145
                Case "G"    ' GST only
                    NewAmount = NewAmount / 1.07
                Case "P"    ' PST only
                    NewAmount = NewAmount / 1.075
                Case "g"    ' GST Included
                    NewAmount = NewAmount
                Case "p"    ' PST on GST
                    NewAmount = NewAmount / 1.15
            End Select
        End If
        NewAmount = Format(NewAmount, "####0.00")
        NewMarkdown = (OldUnitPrice - (NewAmount / OldQty))
        NewMarkdown = Format(NewMarkdown, "####0.00")
        ' Write new values
        myCol("Markdown") = NewMarkdown
        myCol("Amount") = NewAmount
    Next i
End Sub

Private Function CalcAll_GetPrice() As Currency
    Dim myDBG As TDBGrid
    Dim mySB As SelBookmarks
    Dim myCol As Columns
    Dim i As Integer
    Dim OrgTotalPrice As Currency
    
    Set myDBG = frmSalesOrder.tdbgTxBody
    Set mySB = frmSalesOrder.tdbgTxBody.SelBookmarks
    Set myCol = frmSalesOrder.tdbgTxBody.Columns
    
    ' Get the original total price
    For i = 0 To myDBG.VisibleRows - 1
        myDBG.row = i
        OrgTotalPrice = OrgTotalPrice + ofx_CCur(myCol("Amount"))
    Next i
    
    ' Return calculated value
    CalcAll_GetPrice = OrgTotalPrice
End Function

Private Sub CalcAll_SetPrice(myOrgPrice As Currency)
    Dim myDBG As TDBGrid
    Dim mySB As SelBookmarks
    Dim myCol As Columns
    Dim i As Integer
    Dim NewTotalPrice, NewAmount, NewMarkdown As Currency
    Dim OldQty As Integer
    Dim OldUnitPrice, OldAmount As Currency
    
    Set myDBG = frmSalesOrder.tdbgTxBody
    Set mySB = frmSalesOrder.tdbgTxBody.SelBookmarks
    Set myCol = frmSalesOrder.tdbgTxBody.Columns
    NewTotalPrice = ofx_CCur(mskPriceWanted.Text)
    
    ' Set the new price for each item in the grid
    For i = 0 To myDBG.VisibleRows - 1
        myDBG.row = i
        OldQty = ofx_CInt(myCol("Qty"))
        OldUnitPrice = ofx_CCur(myCol("Unit Price"))
        OldAmount = ofx_CCur(myCol("Amount"))
        
        If Not (OldQty <= 0) Then
            NewAmount = OldAmount / myOrgPrice * NewTotalPrice
            If optTaxIncluded Then
                Select Case myCol("Tax")
                    Case "N"    ' Tax Excluded
                        NewAmount = NewAmount
                    Case "B"    ' Both GST and PST
                        NewAmount = NewAmount / 1.145
                    Case "G"    ' GST only
                        NewAmount = NewAmount / 1.07
                    Case "P"    ' PST only
                        NewAmount = NewAmount / 1.075
                    Case "g"    ' GST Included
                        NewAmount = NewAmount
                    Case "p"    ' PST on GST
                        NewAmount = NewAmount / 1.15
                End Select
            End If
            NewAmount = Format(NewAmount, "####0.00")
            NewMarkdown = (OldUnitPrice - (NewAmount / OldQty))
            NewMarkdown = Format(NewMarkdown, "####0.00")
            ' Write new values
            myCol("Markdown") = NewMarkdown
            myCol("Amount") = NewAmount
        End If
    Next i
End Sub

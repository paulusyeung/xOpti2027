VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Object = "{0BA686C6-F7D3-101A-993E-0000C0EF6F5E}#2.0#0"; "THREED20.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form frmReports 
   BorderStyle     =   0  'None
   Caption         =   "Reports"
   ClientHeight    =   4905
   ClientLeft      =   2790
   ClientTop       =   2280
   ClientWidth     =   6120
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4905
   ScaleWidth      =   6120
   ShowInTaskbar   =   0   'False
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   5400
      Top             =   3600
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin MSComctlLib.TreeView TreeView1 
      Height          =   4695
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   4935
      _ExtentX        =   8705
      _ExtentY        =   8281
      _Version        =   393217
      LabelEdit       =   1
      Style           =   7
      ImageList       =   "ImageList1"
      Appearance      =   1
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
   Begin MSComctlLib.ImageList ImageList1 
      Left            =   5400
      Top             =   4080
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      MaskColor       =   12632256
      _Version        =   393216
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   375
      Left            =   5160
      TabIndex        =   2
      Top             =   600
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
      Caption         =   "Printer"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   375
      Left            =   5160
      TabIndex        =   1
      Top             =   120
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
      Caption         =   "Close"
      ButtonStyle     =   2
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmReports"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Load()
    On Error GoTo Form_Load_Err

'    Call mnu_CenterForm(Me)
    Call ofx_CenterForm(Me)
    
    ' ********************************************************
    ' Prepare the Tree View of Report Centre
    ' ********************************************************
    ' Load pictures into ImageList control.
    Dim imgI As ListImage   ' Create Image variable.
    ' Image 1: Open folder, key = "open."
    Set imgI = ImageList1.ListImages.Add _
    (, "open", LoadPicture(App.Path + "\open.bmp"))
    ' Image 2: Closed folder, key = "closed."
    Set imgI = ImageList1.ListImages.Add _
    (, "closed", LoadPicture(App.Path + "\closed.bmp"))
    ' Image 3: document, key = "leaf."
    Set imgI = ImageList1.ListImages.Add _
    (, "leaf", LoadPicture(App.Path + "\leaf.bmp"))
    
    ' Set TreeView control properties.
    TreeView1.ImageList = ImageList1    ' Initialize ImageList.
    TreeView1.Style = tvwTreelinesPlusMinusPictureText ' Style 7
    TreeView1.LineStyle = tvwRootLines  ' Linestyle 1

    ' Add Node objects.
    Dim nodX As Node    ' Create variable.
    
    ' First node with 'Root' as text, image 2 ("closed") for Image.
    Set nodX = TreeView1.Nodes.Add(, , "ps", "Sales", "closed")
    nodX.ExpandedImage = "open"  ' Open folder for expanded node.
    
    ' Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_01", "Cash Register Receipts (By Date)", "leaf")
    ' Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_02", "Cash Register Receipts (by Payment Method)", "leaf")
    Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_03", "Cost and Margin of Goods Sold", "leaf")
    Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_07", "Daily Cash Receipts", "leaf")
    Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_04", "Exceptional Sales Report", "leaf")
    Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_05", "Invoice List (By Date)", "leaf")
    Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_14", "Invoice List (By Invoice No.)", "leaf")
    ' Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_06", "Monthly Commission List", "leaf")
    Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_09", "Orders Report (By Date)", "leaf")
    Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_10", "Orders Report (By Order No.)", "leaf")
    Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_08", "Outstanding Orders on hand", "leaf")
    Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_11", "Receipts Report", "leaf")
    Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_13", "Sales Return Journal", "leaf")
    Set nodX = TreeView1.Nodes.Add("ps", tvwChild, "Sales_12", "Sales Report", "leaf")

    ' Second node has 'Parent' as text, image 2 for Image.
    Set nodX = TreeView1.Nodes.Add(, , "c", "Customer", "closed")
    nodX.ExpandedImage = "open"  ' Open folder for expanded node.
    Set nodX = TreeView1.Nodes.Add("c", tvwChild, "Customer_01", "Birthday Reminder", "leaf")
    Set nodX = TreeView1.Nodes.Add("c", tvwChild, "Customer_02", "Customer Listing (Active)", "leaf")
    Set nodX = TreeView1.Nodes.Add("c", tvwChild, "Customer_03", "Customer Listing (General)", "leaf")
    Set nodX = TreeView1.Nodes.Add("c", tvwChild, "Customer_04", "Customer Listing (Inactive)", "leaf")
    Set nodX = TreeView1.Nodes.Add("c", tvwChild, "Customer_08", "Insurance Reminder", "leaf")
    Set nodX = TreeView1.Nodes.Add("c", tvwChild, "Customer_05", "Prescription Reminder", "leaf")
    Set nodX = TreeView1.Nodes.Add("c", tvwChild, "Customer_06", "VIP Listing (Inactive)", "leaf")
    ' Set nodX = TreeView1.Nodes.Add("c", tvwChild, "Customer_07", "VIP Qualify Listing", "leaf")
    
    Set nodX = TreeView1.Nodes.Add(, , "i", "Inventory", "closed")
    nodX.ExpandedImage = "open"  ' Open folder for expanded node.
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_11", "Insufficient Stock Listing", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_01", "Inventory Ledger", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_02", "Inventory Listing (By LSP)", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_03", "Inventory Listing (Short)", "leaf")
    'Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_10", "Inventory On Hand by Category", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_12", "Inventory On Hand Summary", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_13", "Inventory Special On Hand Analysis", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_14", "Inventory Special Purchase Analysis", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_04", "Re-stocking Report", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_06", "Sales by Category", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_07", "Slow Movement Inventory Listing", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_05", "Stock Adjustment", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_08", "Stock Received", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_15", "Stock Received (By Supplier)", "leaf")
    Set nodX = TreeView1.Nodes.Add("i", tvwChild, "Inventory_09", "Stock Rejected", "leaf")
    
    Set nodX = TreeView1.Nodes.Add(, , "e", "Employee", "closed")
    nodX.ExpandedImage = "open"  ' Open folder for expanded node.
    Set nodX = TreeView1.Nodes.Add("e", tvwChild, "e1", "Employee Listing", "leaf")

    Set nodX = TreeView1.Nodes.Add(, , "Code", "Coding", "closed")
    nodX.ExpandedImage = "open"  ' Open folder for expanded node.
    Set nodX = TreeView1.Nodes.Add("Code", tvwChild, "Coding_01", "Add Code Listing", "leaf")
    Set nodX = TreeView1.Nodes.Add("Code", tvwChild, "Coding_02", "Brand Code Listing", "leaf")
    Set nodX = TreeView1.Nodes.Add("Code", tvwChild, "Coding_03", "Category Code Listing", "leaf")
    Set nodX = TreeView1.Nodes.Add("Code", tvwChild, "Coding_04", "Class Code Listing", "leaf")
    Set nodX = TreeView1.Nodes.Add("Code", tvwChild, "Coding_05", "Department Code Listing", "leaf")
    Set nodX = TreeView1.Nodes.Add("Code", tvwChild, "Coding_06", "Material Code Listing", "leaf")
    
    Set nodX = TreeView1.Nodes.Add(, , "ws", "WholeSales", "closed")
    nodX.ExpandedImage = "open"  ' Open folder for expanded node.
    Set nodX = TreeView1.Nodes.Add("ws", tvwChild, "Wholesales_01", "Wholesales Summary (By Date)", "leaf")
    Set nodX = TreeView1.Nodes.Add("ws", tvwChild, "Wholesales_02", "Wholesales Summary (By No.)", "leaf")
    
    ' WA added on Nov 14, 1997  - Users with cost level may select
    If pyUserHasCostLevel Then
        Set nodX = TreeView1.Nodes.Add(, , "SP", "Various Special Reports", "closed")
        nodX.ExpandedImage = "open"
        Set nodX = TreeView1.Nodes.Add("SP", tvwChild, "SpecialReport_01", "Various Special Reports", "leaf")
    End If

    ' Ensure all nodes are sorted
    TreeView1.Sorted = True

'    nodX.EnsureVisible ' Expand tree to see all nodes

    ' **********************************************************
    ' End of Prepare Tree View of Report Centre
    ' **********************************************************
    
Form_Load_Exit:                                ' SDVB autocode
    On Error Resume Next                       ' SDVB autocode
    Exit Sub                                   ' SDVB autocode
Form_Load_Err:                                 ' SDVB autocode
    Call ofx_GenericError("Form_Load()", Err)  ' SDVB autocode
    Resume Form_Load_Exit
End Sub



Private Sub SSCommand1_Click()
    Unload Me
End Sub


Private Sub SSCommand2_Click()
    CommonDialog1.Flags = &H40
    CommonDialog1.ShowPrinter
End Sub


Private Sub TreeView1_Collapse(ByVal Node As MSComctlLib.Node)
    ' Sorted all children
    If Node.Children <> 0 Then Node.Sorted = True

End Sub

Private Sub TreeView1_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)
    ' Set DropHighlight to the mouse's coordinates.
    Set TreeView1.DropHighlight = TreeView1.HitTest(x, Y)

End Sub

Private Sub TreeView1_NodeClick(ByVal Node As Node)

    On Error GoTo TreeView1_NodeClick_Err

    With Node
        ' else abort NodeClick event if click on folder
        If .Children <> 0 Then
            Node.Sorted = True
            Exit Sub
        End If
        If .Key = "SpecialReport_01" Then
            frmSpecialReports.Show vbModal
            Exit Sub
        End If
        'If .Key = "ps" Or _
        '    .Key = "c" Or _
        '    .Key = "i" Or _
        '    .Key = "e" Or _
        '    .Key = "Code" Then Exit Sub
        Screen.MousePointer = vbHourglass
        ' Set the public variable
        CrwRptName = .Text
    
        If SetRptFileName(CrwRptName, 0) Then
            '   frmAskDays
            If .Text = "Slow Movement Inventory Listing" Then
                Screen.MousePointer = vbHourglass
                frmAskDays.Show vbModal
           
            '   frmAskDateRange
            ElseIf .Text = "Daily Cash Receipts" Or _
                .Text = "Sales Report" Or _
                .Text = "Invoice List (By Date)" Or _
                .Text = "Outstanding Orders on hand" Or _
                .Text = "Wholesales Summary (By Date)" Or _
                .Text = "Orders Report (By Date)" Then
                Screen.MousePointer = vbHourglass
                frmAskDateRange.Show vbModal
                
            '   Still frmAskDateRange as too many multi-lines
            ElseIf .Text = "Receipts Report" Or _
                .Text = "Re-stocking Report" Or _
                .Text = "Stock Adjustment" Or _
                .Text = "Stock Received" Or _
                .Text = "Stock Rejected" Or _
                .Text = "Sales Return Journal" Then  ' Node.Text = "Sales by Category" Or
                Screen.MousePointer = vbHourglass
                frmAskDateRange.Show vbModal
              
            '   frmAskTxNumber
            ElseIf .Text = "Invoice List (By Invoice No.)" Or _
                .Text = "Wholesales Summary (By No.)" Or _
                .Text = "Orders Report (By Order No.)" Then
                Screen.MousePointer = vbHourglass
                frmAskTxNumber.Show vbModal
            
            '   frmCustAskDays
            ElseIf .Text = "Birthday Reminder" Or _
                .Text = "Insurance Reminder" Or _
                .Text = "Customer Listing (Active)" Or _
                .Text = "Customer Listing (Inactive)" Or _
                .Text = "VIP Listing (Inactive)" Then
                Screen.MousePointer = vbHourglass
                frmCustAskDays.Show vbModal
           
            '   frmCustGeneral
            ElseIf .Text = "Customer Listing (General)" Then
                Screen.MousePointer = vbHourglass
                frmCustGeneral.Show vbModal
            
            '   frmHiLowDateRange
            ElseIf .Text = "Exceptional Sales Report" Then
                Screen.MousePointer = vbHourglass
                frmHiLowDateRange.Show vbModal
            
            '   frmInventoryChoice
            ElseIf .Text = "Cost and Margin of Goods Sold" Or _
                .Text = "Insufficient Stock Listing" Or _
                .Text = "Inventory Ledger" Or _
                .Text = "Inventory Listing (By LSP)" Or _
                .Text = "Inventory Listing (Short)" Then
                Screen.MousePointer = vbHourglass
                frmInventoryChoice.Show vbModal
                    
            '   frmRptOHSpecial
            ElseIf .Text = "Inventory Special On Hand Analysis" Then
                Screen.MousePointer = vbHourglass
                frmRptOHSpecial.Show vbModal
            
            '   frmRptPurSpecial
            ElseIf .Text = "Inventory Special Purchase Analysis" Then
                Screen.MousePointer = vbHourglass
                frmRptPurSpecial.Show vbModal
            
            '   frmRptSRbySupplier
            ElseIf .Text = "Stock Received (By Supplier)" Then
                Screen.MousePointer = vbHourglass
                frmRptSRbySupplier.Show vbModal
            
            Else    '   If me.cboRptName = "Prescription Reminder" & all other code listing
                If .Text = "Inventory On Hand Summary" Then
                        frmCtlCrw.CrystalReport1.Formulas(0) = "AskNoCost =" & Not (pyUserHasCostLevel)
                        If pyUserHasCostLevel Then
                            If MsgBox("Including LSP cost in Inventory On Hand Summary, Y/N ?", _
                                vbYesNo + vbQuestion + vbDefaultButton2, "") = vbNo Then
                                    frmCtlCrw.CrystalReport1.Formulas(1) = "AskNoLSP =" & True
                            Else
                                    frmCtlCrw.CrystalReport1.Formulas(1) = "AskNoLSP =" & False
                            End If
                        End If
                End If
                Call PrintIt
            End If
        End If
    End With
    
    'frmPrintIt.Show
    

TreeView1_NodeClick_Exit:                                ' SDVB autocode
    On Error Resume Next                                 ' SDVB autocode
    Screen.MousePointer = vbDefault
    Exit Sub                                             ' SDVB autocode
TreeView1_NodeClick_Err:                                 ' SDVB autocode
    Call ofx_GenericError("TreeView1_NodeClick()", Err)  ' SDVB autocode
    Resume TreeView1_NodeClick_Exit

End Sub


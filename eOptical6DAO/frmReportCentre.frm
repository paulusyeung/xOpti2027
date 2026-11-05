VERSION 4.00
Begin VB.Form frmReportCentre 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Report Centre"
   ClientHeight    =   4350
   ClientLeft      =   1485
   ClientTop       =   2070
   ClientWidth     =   6510
   Height          =   4755
   Icon            =   "frmReportCentre.frx":0000
   Left            =   1425
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4350
   ScaleWidth      =   6510
   Top             =   1725
   Width           =   6630
   Begin VB.ComboBox cboRptName 
      Height          =   315
      Left            =   1800
      Sorted          =   -1  'True
      TabIndex        =   0
      Text            =   "combo1"
      Top             =   960
      Width           =   4200
   End
   Begin VB.Frame frmReport 
      Caption         =   "Report Selection:"
      Height          =   3735
      Left            =   240
      TabIndex        =   1
      Top             =   360
      Width           =   6015
      Begin VB.CommandButton cmdPrnSetup 
         Caption         =   "&Setup"
         Height          =   330
         Left            =   4500
         TabIndex        =   7
         Top             =   3000
         Width           =   1200
      End
      Begin VB.CommandButton cmdOK 
         Caption         =   "&OK"
         Height          =   330
         Left            =   240
         TabIndex        =   3
         Top             =   3000
         Width           =   1200
      End
      Begin VB.CommandButton cmdExit 
         Caption         =   "&Exit"
         Height          =   330
         Left            =   2880
         TabIndex        =   5
         Top             =   3000
         Width           =   1200
      End
      Begin VB.CommandButton cmdReset 
         Caption         =   "&Reset"
         Height          =   330
         Left            =   1560
         TabIndex        =   4
         Top             =   3000
         Width           =   1200
      End
      Begin VB.Frame Frame1 
         Caption         =   "Command"
         Height          =   735
         Left            =   120
         TabIndex        =   6
         Top             =   2760
         Width           =   4095
      End
      Begin VB.Frame Frame2 
         Caption         =   "Printer"
         Height          =   735
         Left            =   4320
         TabIndex        =   8
         Top             =   2760
         Width           =   1575
      End
      Begin VB.Label lblRptName 
         Caption         =   "Report Name:"
         Height          =   315
         Left            =   240
         TabIndex        =   2
         Top             =   600
         Width           =   1335
      End
   End
End
Attribute VB_Name = "frmReportCentre"
Attribute VB_Creatable = False
Attribute VB_Exposed = False

Private Sub cmdExit_Click()

    On Error GoTo cmdExit_Click_Err
    ' close the report
    frmCtlCrw.crystalReport1.ReportFileName = ""
    End

cmdExit_Click_Exit:       ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdExit_Click_Err:        ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdExit_Click_Exit

End Sub


Private Sub cmdOK_Click()

    On Error GoTo cmdOK_Click_Err
    Screen.MousePointer = 11
    
    '   OLAP
    If Me.cboRptname = "OLAP" Then
            'frmReportCentre.Hide
            Call OLAPMain
            'frmReportCentre.Show
    
    '   Set CrystalReport Parameters
    ElseIf SetRptFileName(Me.cboRptname, 1) Then
        
        Screen.MousePointer = 13
        
        '   frmCustAskDays
        If Me.cboRptname = "Birthday Reminder" Or _
          Me.cboRptname = "Customer Listing (Active)" Or _
          Me.cboRptname = "Customer Listing (Inactive)" Or _
          Me.cboRptname = "VIP Listing (Inactive)" Then
          ' Me.cboRptname = "Insurance Reminder" Or (No selection need)
            Screen.MousePointer = 11
            frmCustAskDays.Show vbModal
        
        '   frmCustGeneral
        ElseIf Me.cboRptname = "Customer Listing (General)" Then
            Screen.MousePointer = 11
            frmCustGeneral.Show vbModal
        
        '   frmAskDays
        ElseIf Me.cboRptname = "Slow Movement Inventory Listing" Then
            Screen.MousePointer = 11
            frmAskDays.Show vbModal
        
        '   frmAskDateRange
        ElseIf Me.cboRptname = "Daily Cash Receipts" Or _
               Me.cboRptname = "Invoice Summary (By Date)" Or _
               Me.cboRptname = "Orders in Progress" Or _
               Me.cboRptname = "Orders Summary (By Date)" Then
            Screen.MousePointer = 11
            frmAskDateRange.Show vbModal
        
        '   Still frmAskDateRange as too many multi-lines
        ElseIf Me.cboRptname = "Payment Summary" Or _
               Me.cboRptname = "Re-stocking Report" Or _
               Me.cboRptname = "Reject to Supplier Journal" Or _
               Me.cboRptname = "Sales by Category" Or _
               Me.cboRptname = "Sales Return Journal" Then
            Screen.MousePointer = 11
            frmAskDateRange.Show vbModal
        
        '   frmAskTxNumber
        ElseIf Me.cboRptname = "Invoice Summary (By Invoice No.)" Or _
               Me.cboRptname = "Orders Summary (By Order No.)" Or _
               Me.cboRptname = "Bar Code Tag" Then
               
            Screen.MousePointer = 11
            frmAskTxNumber.Show vbModal
        
        '   frmInventoryChoice
        ElseIf Me.cboRptname = "Cost and Margin of Goods Sold" Or _
               Me.cboRptname = "Inventory Ledger" Or _
               Me.cboRptname = "Inventory Listing (Short)" Or _
               Me.cboRptname = "Inventory Retail Price Listing" Then
            Screen.MousePointer = 11
            frmInventoryChoice.Show vbModal
        
        '   frmHiLowDateRange
        ElseIf Me.cboRptname = "Exceptional Sales Report" Then
            Screen.MousePointer = 11
            frmHiLowDateRange.Show vbModal
        
        Else    '   If me.cboRptName = "Prescription Reminder" & all other code listing
             Screen.MousePointer = 11
             frmCtlCrw.crystalReport1.Action = 1
             Screen.MousePointer = 0
        End If
    End If
cmdOK_Click_Exit:         ' SDVB autocode
    Screen.MousePointer = 0
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdOK_Click_Err:          ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdOK_Click_Exit
End Sub

Private Sub cmdPrnSetup_Click()

    On Error GoTo cmdPrnSetup_Click_Err

    frmCtlCrw.CommonDialog1.Flags = &H40  'force the printers setup dialog box
    frmCtlCrw.CommonDialog1.Action = 5    'run the printer setup

cmdPrnSetup_Click_Exit:   ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdPrnSetup_Click_Err:    ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdPrnSetup_Click_Exit

End Sub


Private Sub cmdReset_Click()

    On Error GoTo cmdReset_Click_Err

    Me.cboRptname.Text = Me.cboRptname.List(0)
    Me.cboRptname.SetFocus

cmdReset_Click_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdReset_Click_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdReset_Click_Exit

End Sub


Private Sub Form_Load()

    On Error GoTo Form_Load_Err
    
    Center Me
    Me.Icon = LoadPicture(SynergyIcon)
    '
    ' load dropdown list
    Me.cboRptname.AddItem "Add Code Listing"
    Me.cboRptname.AddItem "Bar Code Tag"
    Me.cboRptname.AddItem "Birthday Reminder"
    Me.cboRptname.AddItem "Brand Code Listing"
    Me.cboRptname.AddItem "Category Code Listing"
    Me.cboRptname.AddItem "Class Code Listing"
    Me.cboRptname.AddItem "Cost and Margin of Goods Sold"
    Me.cboRptname.AddItem "Customer Listing (Active)"
    Me.cboRptname.AddItem "Customer Listing (Inactive)"
    Me.cboRptname.AddItem "Customer Listing (General)"
    Me.cboRptname.AddItem "Daily Cash Receipts"
    Me.cboRptname.AddItem "Department Code Listing"
    Me.cboRptname.AddItem "Employee Listing"
    Me.cboRptname.AddItem "Exceptional Sales Report"
    Me.cboRptname.AddItem "Insurance Reminder"
    Me.cboRptname.AddItem "Inventory Listing (Short)"
    Me.cboRptname.AddItem "Inventory Ledger"
    Me.cboRptname.AddItem "Inventory Retail Price Listing"
    Me.cboRptname.AddItem "Invoice Summary (By Date)"
    Me.cboRptname.AddItem "Invoice Summary (By Invoice No.)"
    Me.cboRptname.AddItem "Material Code Listing"
    Me.cboRptname.AddItem "OLAP"
    Me.cboRptname.AddItem "Orders in Progress"
    Me.cboRptname.AddItem "Orders Summary (By Date)"
    Me.cboRptname.AddItem "Orders Summary (By Order No.)"
    Me.cboRptname.AddItem "Payment Summary"
    Me.cboRptname.AddItem "Prescription Reminder"
    Me.cboRptname.AddItem "Reject to Supplier Journal"
    Me.cboRptname.AddItem "Re-stocking Report"
    Me.cboRptname.AddItem "Sales by Category"
    Me.cboRptname.AddItem "Sales Return Journal"
    Me.cboRptname.AddItem "Slow Movement Inventory Listing"
    Me.cboRptname.AddItem "Supplier Code Listing (Short)"
    Me.cboRptname.AddItem "Supplier Listing (Detailed)"
    Me.cboRptname.AddItem "VIP Listing (Inactive)"
    Me.cboRptname.AddItem "VIP Qualify Listing"

    
    
    '
    ' set first list member
    Me.cboRptname.Text = Me.cboRptname.List(0)

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub


Private Sub Form_Unload(Cancel As Integer)

    On Error GoTo Form_Unload_Err

    cmdExit_Click

Form_Unload_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Unload_Err:          ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Unload_Exit

End Sub



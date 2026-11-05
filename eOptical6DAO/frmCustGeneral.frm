VERSION 5.00
Object = "{FAEEE763-117E-101B-8933-08002B2F4F5A}#1.1#0"; "DBLIST32.OCX"
Begin VB.Form frmCustGeneral 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Customer Listing (General)"
   ClientHeight    =   5940
   ClientLeft      =   285
   ClientTop       =   2280
   ClientWidth     =   6885
   Icon            =   "frmCustGeneral.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5940
   ScaleWidth      =   6885
   ShowInTaskbar   =   0   'False
   Begin VB.Frame Frame4 
      Caption         =   "Printer"
      Height          =   735
      Left            =   4800
      TabIndex        =   13
      Top             =   4920
      Width           =   1455
      Begin VB.CommandButton cmdPrtSetup 
         Caption         =   "&Setup"
         Height          =   330
         Left            =   120
         TabIndex        =   5
         Top             =   240
         Width           =   1200
      End
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "&Exit"
      Height          =   330
      Left            =   3360
      TabIndex        =   4
      Top             =   5160
      Width           =   1200
   End
   Begin VB.CommandButton cdmReset 
      Caption         =   "&Reset"
      Height          =   330
      Left            =   2040
      TabIndex        =   3
      Top             =   5160
      Width           =   1200
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   330
      Left            =   720
      TabIndex        =   2
      Top             =   5160
      Width           =   1200
   End
   Begin VB.Frame Frame1 
      Caption         =   "Select Country"
      Height          =   1695
      Left            =   600
      TabIndex        =   8
      Top             =   480
      Width           =   5670
      Begin VB.TextBox txtFile1Code 
         Enabled         =   0   'False
         Height          =   285
         Left            =   3160
         TabIndex        =   14
         Text            =   "<ALL>"
         Top             =   840
         Visible         =   0   'False
         Width           =   735
      End
      Begin VB.TextBox txtFile1From 
         Height          =   285
         Left            =   3160
         TabIndex        =   0
         Text            =   "<ALL>"
         Top             =   480
         Width           =   2295
      End
      Begin VB.Data dtcFileName1 
         Caption         =   "Customer Home Country"
         Connect         =   "Access 2000;"
         DatabaseName    =   ""
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   240
         Options         =   0
         ReadOnly        =   -1  'True
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "RptCustomerHomeCountry"
         Top             =   1320
         Visible         =   0   'False
         Width           =   5175
      End
      Begin MSDBCtls.DBList dbFile1List 
         Bindings        =   "frmCustGeneral.frx":068A
         DataField       =   "Countrycode"
         DataSource      =   "dtcFileName1"
         Height          =   840
         Left            =   240
         TabIndex        =   6
         Top             =   480
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   1482
         _Version        =   393216
         MatchEntry      =   -1  'True
         BackColor       =   -2147483643
         ForeColor       =   -2147483640
         ListField       =   "CountryName"
         BoundColumn     =   "CountryCode"
      End
      Begin VB.Label Label1 
         Caption         =   "In:"
         Height          =   255
         Left            =   2280
         TabIndex        =   10
         Top             =   480
         Width           =   495
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Select Customer Last Name"
      Height          =   1695
      Left            =   600
      TabIndex        =   9
      Top             =   2760
      Width           =   5670
      Begin VB.TextBox txtFile2From 
         Height          =   285
         Left            =   3160
         TabIndex        =   1
         Text            =   "<ALL>"
         Top             =   480
         Width           =   2175
      End
      Begin VB.Data dtcFileName2 
         Caption         =   "Customer Last Name"
         Connect         =   "Access 2000;"
         DatabaseName    =   ""
         DefaultCursorType=   0  'DefaultCursor
         DefaultType     =   2  'UseODBC
         Exclusive       =   0   'False
         Height          =   300
         Left            =   240
         Options         =   0
         ReadOnly        =   -1  'True
         RecordsetType   =   1  'Dynaset
         RecordSource    =   "select distinct customer.lastname from Customer order by customer.lastname"
         Top             =   1320
         Visible         =   0   'False
         Width           =   5175
      End
      Begin MSDBCtls.DBList dbFile2List 
         Bindings        =   "frmCustGeneral.frx":06A5
         DataField       =   "LastName"
         DataSource      =   "dtcFileName2"
         Height          =   840
         Left            =   240
         TabIndex        =   7
         Top             =   480
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   1482
         _Version        =   393216
         MatchEntry      =   -1  'True
         BackColor       =   -2147483643
         ForeColor       =   -2147483640
         ListField       =   "LastName"
         BoundColumn     =   "LastName"
      End
      Begin VB.Label Label3 
         Caption         =   "In:"
         Height          =   255
         Left            =   2280
         TabIndex        =   11
         Top             =   480
         Width           =   855
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   "Command"
      Height          =   735
      Left            =   600
      TabIndex        =   12
      Top             =   4920
      Width           =   4095
   End
End
Attribute VB_Name = "frmCustGeneral"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cdmReset_Click()

    On Error GoTo cdmReset_Click_Err

    Me.txtFile1From = "<ALL>"
    Me.txtFile2From = "<ALL>"
    Me.txtFile1From.SetFocus

cdmReset_Click_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cdmReset_Click_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cdmReset_Click_Exit

End Sub

Private Sub cmdExit_Click()

    On Error GoTo cmdExit_Click_Err
    Unload Me

cmdExit_Click_Exit:       ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdExit_Click_Err:        ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdExit_Click_Exit

End Sub


Private Sub cmdOK_Click()

    On Error GoTo cmdOK_Click_Err

    Screen.MousePointer = vbArrowHourglass
 
    '   Set Formula
    frmCtlCrw.CrystalReport1.Formulas(0) = "AskCountryFrom = '" & Me.txtFile1From.Text & "'"
    frmCtlCrw.CrystalReport1.Formulas(1) = "AskCountryTo = '" & Me.txtFile1Code.Text & "'"
    frmCtlCrw.CrystalReport1.Formulas(2) = "AskCustomerFrom = '" & Me.txtFile2From.Text & "'"
    frmCtlCrw.CrystalReport1.Formulas(3) = "AskCustomerTo = '" & Me.txtFile2From.Text & "'"
    If Me.txtFile1From.Text = "<ALL>" And Me.txtFile2From.Text = "<ALL>" Then
    ElseIf Me.txtFile1From.Text = "<ALL>" Then
    ' If txtFile2From.Text <> "" Then
        frmCtlCrw.CrystalReport1.SelectionFormula = "{Customer.LastName} = '" & _
                                    Me.txtFile2From.Text & "'"
    ElseIf Me.txtFile2From.Text = "<ALL>" Then
       frmCtlCrw.CrystalReport1.SelectionFormula = "{Customer.HomeCountry} = '" & _
                                    Me.txtFile1Code.Text & "'"
    Else
       frmCtlCrw.CrystalReport1.SelectionFormula = "{Customer.HomeCountry} = '" & _
                                    Me.txtFile1Code.Text & "' AND {Customer.LastName} = '" & _
                                    Me.txtFile2From.Text & "'"
    End If
    Screen.MousePointer = vbHourglass
    'MsgBox frmCtlCrw.crystalreport1.SelectionFormula
    'MsgBox frmCtlCrw.CrystalReport1.Formulas(1)
    'MsgBox frmCtlCrw.CrystalReport1.Formulas(2)
    'MsgBox frmCtlCrw.CrystalReport1.Formulas(3)
    Unload Me
    frmCtlCrw.CrystalReport1.Action = 1
    Screen.MousePointer = vbDefault
    
cmdOK_Click_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdOK_Click_Err:          ' SDVB autocode
    Screen.MousePointer = vbDefault
    MsgBox Error          ' SDVB autocode
    Resume cmdOK_Click_Exit

End Sub


Private Sub cmdPrtSetup_Click()

    On Error GoTo cmdPrtSetup_Click_Err

    frmCtlCrw.CommonDialog1.Flags = &H40  'force the printers setup dialog box
    frmCtlCrw.CommonDialog1.Action = 5    'run the printer setup

cmdPrtSetup_Click_Exit:   ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdPrtSetup_Click_Err:    ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdPrtSetup_Click_Exit

End Sub

Private Sub dbFile1List_Click()
    txtFile1from_Click
End Sub

Private Sub dbFile2list_Click()
    txtFile2From_Click
End Sub


Private Sub Form_Load()

    On Error GoTo Form_Load_Err

    Call ofx_CenterForm(Me)
    Screen.MousePointer = vbDefault
    Me.Caption = CrwRptName
    Me.Icon = LoadPicture(SynergyIcon)
    
    Me.dtcFileName1.DatabaseName = sDBName
    Me.dtcFileName2.DatabaseName = sDBName
 
Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub






Private Sub txtFile1from_Click()
    Me.txtFile1From = dbFile1List.Text
    Me.txtFile1Code = dbFile1List.BoundText
End Sub

Private Sub txtFile2From_Click()
     Me.txtFile2From = dbFile2List.BoundText
End Sub


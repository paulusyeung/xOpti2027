VERSION 5.00
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "TABCTL32.OCX"
Begin VB.Form frmDCProp 
   AutoRedraw      =   -1  'True
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Synergy V Properties"
   ClientHeight    =   4215
   ClientLeft      =   1785
   ClientTop       =   1860
   ClientWidth     =   6690
   Icon            =   "OLAPProperty.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4215
   ScaleWidth      =   6690
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton cmdApply 
      Caption         =   "&Apply"
      Height          =   375
      Left            =   5400
      TabIndex        =   3
      Top             =   3720
      Width           =   1215
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "&Cancel"
      Height          =   375
      Left            =   4080
      TabIndex        =   2
      Top             =   3720
      Width           =   1215
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   375
      Left            =   2760
      TabIndex        =   1
      Top             =   3720
      Width           =   1215
   End
   Begin TabDlg.SSTab tabProperty 
      Height          =   3495
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   6495
      _ExtentX        =   11456
      _ExtentY        =   6165
      _Version        =   327680
      Style           =   1
      Tabs            =   5
      Tab             =   4
      TabsPerRow      =   5
      TabHeight       =   529
      TabCaption(0)   =   "Data Source"
      TabPicture(0)   =   "OLAPProperty.frx":068A
      Tab(0).ControlCount=   3
      Tab(0).ControlEnabled=   0   'False
      Tab(0).Control(0)=   "lblTag(0)"
      Tab(0).Control(0).Enabled=   -1  'True
      Tab(0).Control(1)=   "fraGroup(0)"
      Tab(0).Control(1).Enabled=   -1  'True
      Tab(0).Control(2)=   "cboConnectType"
      Tab(0).Control(2).Enabled=   -1  'True
      TabCaption(1)   =   "Layout"
      TabPicture(1)   =   "OLAPProperty.frx":06A6
      Tab(1).ControlCount=   4
      Tab(1).ControlEnabled=   0   'False
      Tab(1).Control(0)=   "lstColFields"
      Tab(1).Control(0).Enabled=   -1  'True
      Tab(1).Control(1)=   "lstRowFields"
      Tab(1).Control(1).Enabled=   -1  'True
      Tab(1).Control(2)=   "lstDataFields"
      Tab(1).Control(2).Enabled=   -1  'True
      Tab(1).Control(3)=   "lstAllFields"
      Tab(1).Control(3).Enabled=   -1  'True
      TabCaption(2)   =   "Fields"
      TabPicture(2)   =   "OLAPProperty.frx":06C2
      Tab(2).ControlCount=   2
      Tab(2).ControlEnabled=   0   'False
      Tab(2).Control(0)=   "fraGroup(1)"
      Tab(2).Control(0).Enabled=   -1  'True
      Tab(2).Control(1)=   "lstFields"
      Tab(2).Control(1).Enabled=   -1  'True
      TabCaption(3)   =   "Preferences"
      TabPicture(3)   =   "OLAPProperty.frx":06DE
      Tab(3).ControlCount=   3
      Tab(3).ControlEnabled=   0   'False
      Tab(3).Control(0)=   "fraGroup(4)"
      Tab(3).Control(0).Enabled=   -1  'True
      Tab(3).Control(1)=   "fraGroup(5)"
      Tab(3).Control(1).Enabled=   -1  'True
      Tab(3).Control(2)=   "fraGroup(3)"
      Tab(3).Control(2).Enabled=   -1  'True
      TabCaption(4)   =   "Printer"
      TabPicture(4)   =   "OLAPProperty.frx":06FA
      Tab(4).ControlCount=   4
      Tab(4).ControlEnabled=   -1  'True
      Tab(4).Control(0)=   "fraGroup(9)"
      Tab(4).Control(0).Enabled=   0   'False
      Tab(4).Control(1)=   "fraGroup(8)"
      Tab(4).Control(1).Enabled=   0   'False
      Tab(4).Control(2)=   "fraGroup(7)"
      Tab(4).Control(2).Enabled=   0   'False
      Tab(4).Control(3)=   "fraGroup(6)"
      Tab(4).Control(3).Enabled=   0   'False
      Begin VB.Frame fraGroup 
         Height          =   975
         Index           =   6
         Left            =   120
         TabIndex        =   60
         Top             =   360
         Width           =   6255
         Begin VB.TextBox txtHeader 
            Height          =   285
            Left            =   720
            TabIndex        =   66
            Top             =   240
            Width           =   2175
         End
         Begin VB.TextBox txtFooter 
            Height          =   285
            Left            =   720
            TabIndex        =   65
            Top             =   600
            Width           =   2175
         End
         Begin VB.TextBox txtHdrMargin 
            Height          =   285
            Left            =   3600
            TabIndex        =   64
            Top             =   240
            Width           =   375
         End
         Begin VB.TextBox txtFtrMargin 
            Height          =   285
            Left            =   3600
            TabIndex        =   63
            Top             =   600
            Width           =   375
         End
         Begin VB.ComboBox cboHdrJust 
            Height          =   315
            ItemData        =   "OLAPProperty.frx":0716
            Left            =   5040
            List            =   "OLAPProperty.frx":0723
            Style           =   2  'Dropdown List
            TabIndex        =   62
            Top             =   240
            Width           =   1095
         End
         Begin VB.ComboBox cboFtrJust 
            Height          =   315
            ItemData        =   "OLAPProperty.frx":0748
            Left            =   5040
            List            =   "OLAPProperty.frx":0755
            Style           =   2  'Dropdown List
            TabIndex        =   61
            Top             =   600
            Width           =   1095
         End
         Begin VB.Label lblTag 
            Caption         =   "Header:"
            Height          =   255
            Index           =   18
            Left            =   120
            TabIndex        =   72
            Top             =   240
            Width           =   975
         End
         Begin VB.Label lblTag 
            Caption         =   "Footer:"
            Height          =   255
            Index           =   19
            Left            =   120
            TabIndex        =   71
            Top             =   600
            Width           =   975
         End
         Begin VB.Label lblTag 
            Caption         =   "Margin:"
            Height          =   255
            Index           =   20
            Left            =   3000
            TabIndex        =   70
            Top             =   240
            Width           =   615
         End
         Begin VB.Label lblTag 
            Caption         =   "Margin:"
            Height          =   255
            Index           =   21
            Left            =   3000
            TabIndex        =   69
            Top             =   600
            Width           =   615
         End
         Begin VB.Label lblTag 
            Caption         =   "Justification:"
            Height          =   255
            Index           =   22
            Left            =   4080
            TabIndex        =   68
            Top             =   240
            Width           =   975
         End
         Begin VB.Label lblTag 
            Caption         =   "Justification:"
            Height          =   255
            Index           =   23
            Left            =   4080
            TabIndex        =   67
            Top             =   600
            Width           =   975
         End
      End
      Begin VB.Frame fraGroup 
         Caption         =   "Margins"
         Height          =   1935
         Index           =   7
         Left            =   120
         TabIndex        =   51
         Top             =   1440
         Width           =   2895
         Begin VB.TextBox txtMargin 
            Height          =   285
            Index           =   0
            Left            =   960
            TabIndex        =   55
            Top             =   240
            Width           =   855
         End
         Begin VB.TextBox txtMargin 
            Height          =   285
            Index           =   1
            Left            =   960
            TabIndex        =   54
            Top             =   600
            Width           =   855
         End
         Begin VB.TextBox txtMargin 
            Height          =   285
            Index           =   2
            Left            =   960
            TabIndex        =   53
            Top             =   960
            Width           =   855
         End
         Begin VB.TextBox txtMargin 
            Height          =   285
            Index           =   3
            Left            =   960
            TabIndex        =   52
            Top             =   1320
            Width           =   855
         End
         Begin VB.Label lblTag 
            Caption         =   "Top:"
            Height          =   255
            Index           =   24
            Left            =   120
            TabIndex        =   59
            Top             =   240
            Width           =   975
         End
         Begin VB.Label lblTag 
            Caption         =   "Left:"
            Height          =   255
            Index           =   25
            Left            =   120
            TabIndex        =   58
            Top             =   600
            Width           =   975
         End
         Begin VB.Label lblTag 
            Caption         =   "Bottom:"
            Height          =   255
            Index           =   26
            Left            =   120
            TabIndex        =   57
            Top             =   960
            Width           =   975
         End
         Begin VB.Label lblTag 
            Caption         =   "Right:"
            Height          =   255
            Index           =   27
            Left            =   120
            TabIndex        =   56
            Top             =   1320
            Width           =   975
         End
      End
      Begin VB.Frame fraGroup 
         Caption         =   "Page Break Level"
         Height          =   975
         Index           =   8
         Left            =   3120
         TabIndex        =   46
         Top             =   1440
         Width           =   3255
         Begin VB.TextBox txtBreakLevel 
            Height          =   285
            Index           =   0
            Left            =   1680
            TabIndex        =   48
            Top             =   240
            Width           =   855
         End
         Begin VB.TextBox txtBreakLevel 
            Height          =   285
            Index           =   1
            Left            =   1680
            TabIndex        =   47
            Top             =   600
            Width           =   855
         End
         Begin VB.Label lblTag 
            Caption         =   "Row:"
            Height          =   255
            Index           =   28
            Left            =   120
            TabIndex        =   50
            Top             =   240
            Width           =   975
         End
         Begin VB.Label lblTag 
            Caption         =   "Column:"
            Height          =   255
            Index           =   29
            Left            =   120
            TabIndex        =   49
            Top             =   600
            Width           =   975
         End
      End
      Begin VB.Frame fraGroup 
         Caption         =   "Repeat Headings on Every Page"
         Height          =   975
         Index           =   9
         Left            =   3120
         TabIndex        =   43
         Top             =   2400
         Width           =   3255
         Begin VB.CheckBox chkRepeatHeadings 
            Caption         =   "Row Headings"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   45
            Top             =   240
            Width           =   3015
         End
         Begin VB.CheckBox chkRepeatHeadings 
            Caption         =   "Column Headings"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   44
            Top             =   600
            Width           =   3015
         End
      End
      Begin VB.Frame fraGroup 
         Caption         =   "Alignment"
         Height          =   1335
         Index           =   3
         Left            =   -74880
         TabIndex        =   36
         Top             =   360
         Width           =   3135
         Begin VB.ComboBox cboAlign 
            Height          =   315
            Index           =   0
            ItemData        =   "OLAPProperty.frx":077A
            Left            =   1320
            List            =   "OLAPProperty.frx":0799
            Style           =   2  'Dropdown List
            TabIndex        =   39
            Top             =   240
            Width           =   1695
         End
         Begin VB.ComboBox cboAlign 
            Height          =   315
            Index           =   1
            ItemData        =   "OLAPProperty.frx":083E
            Left            =   1320
            List            =   "OLAPProperty.frx":085D
            Style           =   2  'Dropdown List
            TabIndex        =   38
            Top             =   600
            Width           =   1695
         End
         Begin VB.ComboBox cboOutlineIconAlign 
            Height          =   315
            ItemData        =   "OLAPProperty.frx":0902
            Left            =   1320
            List            =   "OLAPProperty.frx":0912
            Style           =   2  'Dropdown List
            TabIndex        =   37
            Top             =   960
            Width           =   1695
         End
         Begin VB.Label lblTag 
            Caption         =   "Column:"
            Height          =   255
            Index           =   11
            Left            =   120
            TabIndex        =   42
            Top             =   240
            Width           =   1095
         End
         Begin VB.Label lblTag 
            Caption         =   "Row:"
            Height          =   255
            Index           =   12
            Left            =   120
            TabIndex        =   41
            Top             =   600
            Width           =   1215
         End
         Begin VB.Label lblTag 
            Caption         =   "Outline Icon:"
            Height          =   255
            Index           =   17
            Left            =   120
            TabIndex        =   40
            Top             =   960
            Width           =   975
         End
      End
      Begin VB.Frame fraGroup 
         Caption         =   "Style"
         Height          =   1695
         Index           =   5
         Left            =   -74880
         TabIndex        =   27
         Top             =   1680
         Width           =   3135
         Begin VB.ComboBox cboStyle 
            Height          =   315
            Index           =   0
            ItemData        =   "OLAPProperty.frx":0951
            Left            =   1320
            List            =   "OLAPProperty.frx":0964
            Style           =   2  'Dropdown List
            TabIndex        =   31
            Top             =   240
            Width           =   1695
         End
         Begin VB.ComboBox cboStyle 
            Height          =   315
            Index           =   1
            ItemData        =   "OLAPProperty.frx":09BA
            Left            =   1320
            List            =   "OLAPProperty.frx":09CD
            Style           =   2  'Dropdown List
            TabIndex        =   30
            Top             =   600
            Width           =   1695
         End
         Begin VB.ComboBox cboCursorStyle 
            Height          =   315
            ItemData        =   "OLAPProperty.frx":0A23
            Left            =   1320
            List            =   "OLAPProperty.frx":0A2D
            Style           =   2  'Dropdown List
            TabIndex        =   29
            Top             =   960
            Width           =   1695
         End
         Begin VB.ComboBox cboGridStyle 
            Height          =   315
            ItemData        =   "OLAPProperty.frx":0A47
            Left            =   1320
            List            =   "OLAPProperty.frx":0A57
            Style           =   2  'Dropdown List
            TabIndex        =   28
            Top             =   1320
            Width           =   1695
         End
         Begin VB.Label lblTag 
            Caption         =   "Column:"
            Height          =   255
            Index           =   13
            Left            =   120
            TabIndex        =   35
            Top             =   240
            Width           =   1095
         End
         Begin VB.Label lblTag 
            Caption         =   "Row:"
            Height          =   255
            Index           =   14
            Left            =   120
            TabIndex        =   34
            Top             =   600
            Width           =   1095
         End
         Begin VB.Label lblTag 
            Caption         =   "Cursor:"
            Height          =   255
            Index           =   15
            Left            =   120
            TabIndex        =   33
            Top             =   960
            Width           =   1095
         End
         Begin VB.Label lblTag 
            Caption         =   "Grid:"
            Height          =   255
            Index           =   16
            Left            =   120
            TabIndex        =   32
            Top             =   1320
            Width           =   1095
         End
      End
      Begin VB.Frame fraGroup 
         Caption         =   "Flags"
         Height          =   1335
         Index           =   4
         Left            =   -71640
         TabIndex        =   23
         Top             =   360
         Width           =   3015
         Begin VB.CheckBox chkFlags 
            Caption         =   "Allow Filtering"
            Height          =   285
            Index           =   0
            Left            =   120
            TabIndex        =   26
            Top             =   240
            Width           =   2775
         End
         Begin VB.CheckBox chkFlags 
            Caption         =   "Allow Pivoting"
            Height          =   285
            Index           =   1
            Left            =   120
            TabIndex        =   25
            Top             =   600
            Width           =   2775
         End
         Begin VB.CheckBox chkFlags 
            Caption         =   "Auto Data Refresh"
            Height          =   285
            Index           =   2
            Left            =   120
            TabIndex        =   24
            Top             =   960
            Width           =   2775
         End
      End
      Begin VB.ListBox lstFields 
         Height          =   2790
         Left            =   -74880
         TabIndex        =   22
         Top             =   480
         Width           =   1935
      End
      Begin VB.ComboBox cboConnectType 
         Enabled         =   0   'False
         Height          =   315
         ItemData        =   "OLAPProperty.frx":0A87
         Left            =   -73320
         List            =   "OLAPProperty.frx":0A97
         Style           =   2  'Dropdown List
         TabIndex        =   10
         Top             =   540
         Width           =   2535
      End
      Begin VB.Frame fraGroup 
         Height          =   2895
         Index           =   1
         Left            =   -72840
         TabIndex        =   9
         Top             =   420
         Width           =   4215
      End
      Begin VB.ListBox lstAllFields 
         Height          =   2835
         IntegralHeight  =   0   'False
         Left            =   -74880
         TabIndex        =   8
         Top             =   420
         Width           =   1935
      End
      Begin VB.ListBox lstDataFields 
         Height          =   2175
         IntegralHeight  =   0   'False
         Left            =   -71280
         TabIndex        =   7
         Top             =   1080
         Width           =   2655
      End
      Begin VB.ListBox lstRowFields 
         Height          =   2175
         IntegralHeight  =   0   'False
         Left            =   -72840
         TabIndex        =   6
         Top             =   1080
         Width           =   1455
      End
      Begin VB.ListBox lstColFields 
         Columns         =   10
         Height          =   570
         IntegralHeight  =   0   'False
         Left            =   -72840
         TabIndex        =   5
         Top             =   420
         Width           =   4215
      End
      Begin VB.Frame fraGroup 
         Height          =   2535
         Index           =   0
         Left            =   -74880
         TabIndex        =   4
         Top             =   840
         Width           =   6255
         Begin VB.TextBox txtQueryTimeout 
            Enabled         =   0   'False
            Height          =   285
            Left            =   5520
            MaxLength       =   3
            TabIndex        =   21
            Top             =   600
            Width           =   615
         End
         Begin VB.TextBox txtOptions 
            Enabled         =   0   'False
            Height          =   285
            Left            =   5520
            MaxLength       =   3
            TabIndex        =   18
            Top             =   240
            Width           =   615
         End
         Begin VB.TextBox txtRecordSource 
            Enabled         =   0   'False
            Height          =   1215
            Left            =   120
            MultiLine       =   -1  'True
            ScrollBars      =   2  'Vertical
            TabIndex        =   16
            Top             =   1200
            Width           =   6015
         End
         Begin VB.TextBox txtDBName 
            Enabled         =   0   'False
            Height          =   285
            Left            =   1560
            MaxLength       =   255
            TabIndex        =   14
            Top             =   600
            Width           =   2535
         End
         Begin VB.ComboBox cboConnect 
            Enabled         =   0   'False
            Height          =   315
            ItemData        =   "OLAPProperty.frx":0AFB
            Left            =   1560
            List            =   "OLAPProperty.frx":0B38
            TabIndex        =   12
            Top             =   240
            Width           =   2535
         End
         Begin VB.Label lblTag 
            Caption         =   "dcQueryTimeout"
            Height          =   255
            Index           =   5
            Left            =   4200
            TabIndex        =   20
            Top             =   600
            Width           =   1335
         End
         Begin VB.Label lblTag 
            Caption         =   "dcOptions:"
            Height          =   255
            Index           =   4
            Left            =   4200
            TabIndex        =   19
            Top             =   240
            Width           =   1335
         End
         Begin VB.Label lblTag 
            Caption         =   "dcRecordSource:"
            Height          =   255
            Index           =   3
            Left            =   120
            TabIndex        =   17
            Top             =   960
            Width           =   1335
         End
         Begin VB.Label lblTag 
            Caption         =   "dcDatabaseName:"
            Height          =   255
            Index           =   2
            Left            =   120
            TabIndex        =   15
            Top             =   600
            Width           =   1335
         End
         Begin VB.Label lblTag 
            Caption         =   "dcConnect:"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   13
            Top             =   240
            Width           =   1335
         End
      End
      Begin VB.Label lblTag 
         Caption         =   "dcConnectType:"
         Height          =   255
         Index           =   0
         Left            =   -74760
         TabIndex        =   11
         Top             =   600
         Width           =   1335
      End
   End
End
Attribute VB_Name = "frmDCProp"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private bDirty As Boolean

Private Sub cmdApply_Click()

    On Error GoTo cmdApply_Click_Err

    dcCurrent.ColAlignment = cboAlign(0).ListIndex
    dcCurrent.RowAlignment = cboAlign(1).ListIndex
    dcCurrent.OutlineIconAlignment = cboOutlineIconAlign.ListIndex
    dcCurrent.ColStyle = cboStyle(0).ListIndex
    dcCurrent.RowStyle = cboStyle(1).ListIndex
    
    dcCurrent.GridStyle = cboGridStyle.ListIndex
    dcCurrent.CursorStyle = cboCursorStyle.ListIndex
    
    dcCurrent.HeaderCaption = txtHeader
    dcCurrent.FooterCaption = txtFooter
    dcCurrent.HeaderMargin = txtHdrMargin
    dcCurrent.FooterMargin = txtFtrMargin
    dcCurrent.HeaderJustification = cboHdrJust.ListIndex
    dcCurrent.FooterJustification = cboFtrJust.ListIndex
    dcCurrent.TopMargin = txtMargin(0)
    dcCurrent.LeftMargin = txtMargin(1)
    dcCurrent.BottomMargin = txtMargin(2)
    dcCurrent.RightMargin = txtMargin(3)
    dcCurrent.AllowFiltering = (chkFlags(0).Value = 1)
    dcCurrent.AllowUserPivotFields = (chkFlags(1).Value = 1)
    dcCurrent.AutoDataRefresh = (chkFlags(2).Value = 1)
    
    dcCurrent.Refresh

cmdApply_Click_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdApply_Click_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdApply_Click_Exit

End Sub

Private Sub cmdCancel_Click()

    On Error GoTo cmdCancel_Click_Err

    Unload Me

cmdCancel_Click_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdCancel_Click_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdCancel_Click_Exit

End Sub

Private Sub cmdOK_Click()

    On Error GoTo cmdOK_Click_Err

    dcCurrent.ColAlignment = cboAlign(0).ListIndex
    dcCurrent.RowAlignment = cboAlign(1).ListIndex
    dcCurrent.OutlineIconAlignment = cboOutlineIconAlign.ListIndex
    dcCurrent.ColStyle = cboStyle(0).ListIndex
    dcCurrent.RowStyle = cboStyle(1).ListIndex
    
    dcCurrent.GridStyle = cboGridStyle.ListIndex
    dcCurrent.CursorStyle = cboCursorStyle.ListIndex
    
    dcCurrent.HeaderCaption = txtHeader
    dcCurrent.FooterCaption = txtFooter
    dcCurrent.HeaderMargin = txtHdrMargin
    dcCurrent.FooterMargin = txtFtrMargin
    dcCurrent.HeaderJustification = cboHdrJust.ListIndex
    dcCurrent.FooterJustification = cboFtrJust.ListIndex
    dcCurrent.TopMargin = txtMargin(0)
    dcCurrent.LeftMargin = txtMargin(1)
    dcCurrent.BottomMargin = txtMargin(2)
    dcCurrent.RightMargin = txtMargin(3)
    dcCurrent.AllowFiltering = (chkFlags(0).Value = 1)
    dcCurrent.AllowUserPivotFields = (chkFlags(1).Value = 1)
    dcCurrent.AutoDataRefresh = (chkFlags(2).Value = 1)
    
    dcCurrent.Refresh
    
    Unload Me

cmdOK_Click_Exit:         ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdOK_Click_Err:          ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdOK_Click_Exit

End Sub

Private Sub Form_Load()

    On Error GoTo Form_Load_Err
    Left = (Screen.Width - Width) / 2   ' Center form horizontally.
    Top = (Screen.Height - Height) / 2  ' Center form vertically.
    Dim i As Integer
    cboConnectType.ListIndex = dcCurrent.DCConnectType
    cboConnect = dcCurrent.DCConnect
    txtDBName = dcCurrent.DCDatabaseName
    txtRecordSource = dcCurrent.DCRecordSource
    txtOptions = dcCurrent.DCOptions
    txtQueryTimeout = dcCurrent.DCQueryTimeOut
    
    For i = 0 To dcCurrent.ColFields.Count - 1
        lstColFields.AddItem dcCurrent.ColFields(i).Name
    Next
    
    For i = 0 To dcCurrent.RowFields.Count - 1
        lstRowFields.AddItem dcCurrent.RowFields(i).Name
    Next
    
    For i = 0 To dcCurrent.DataFields.Count - 1
        lstDataFields.AddItem dcCurrent.DataFields(i).Name
    Next

    For i = 0 To dcCurrent.Fields.Count - 1
        lstAllFields.AddItem dcCurrent.Fields(i).Name
        lstFields.AddItem dcCurrent.Fields(i).Name
    Next
    
    cboAlign(0).ListIndex = dcCurrent.ColAlignment
    cboAlign(1).ListIndex = dcCurrent.RowAlignment
    cboOutlineIconAlign.ListIndex = dcCurrent.OutlineIconAlignment
    cboStyle(0).ListIndex = dcCurrent.ColStyle
    cboStyle(1).ListIndex = dcCurrent.RowStyle
    
    cboGridStyle.ListIndex = dcCurrent.GridStyle
    cboCursorStyle.ListIndex = dcCurrent.CursorStyle
    
    txtHeader = dcCurrent.HeaderCaption
    txtFooter = dcCurrent.FooterCaption
    txtHdrMargin = dcCurrent.HeaderMargin
    txtFtrMargin = dcCurrent.FooterMargin
    cboHdrJust.ListIndex = dcCurrent.HeaderJustification
    cboFtrJust.ListIndex = dcCurrent.FooterJustification
    txtMargin(0) = dcCurrent.TopMargin
    txtMargin(1) = dcCurrent.LeftMargin
    txtMargin(2) = dcCurrent.BottomMargin
    txtMargin(3) = dcCurrent.RightMargin
    If dcCurrent.AllowFiltering Then chkFlags(0).Value = 1
    If dcCurrent.AllowUserPivotFields Then chkFlags(1).Value = 1
    If dcCurrent.AutoDataRefresh Then chkFlags(2).Value = 1

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub


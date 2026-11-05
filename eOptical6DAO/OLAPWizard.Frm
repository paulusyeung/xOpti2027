VERSION 4.00
Begin VB.Form frmWizard 
   Caption         =   "Synergy V  Wizard"
   ClientHeight    =   4620
   ClientLeft      =   1380
   ClientTop       =   1980
   ClientWidth     =   6810
   Height          =   5025
   Icon            =   "OLAPWizard.frx":0000
   Left            =   1320
   LinkTopic       =   "Form1"
   ScaleHeight     =   4620
   ScaleWidth      =   6810
   Top             =   1635
   Width           =   6930
   Begin VB.CommandButton cmdFinish 
      Caption         =   "&Finish"
      Enabled         =   0   'False
      Height          =   375
      Left            =   5520
      TabIndex        =   3
      Top             =   4200
      Width           =   1215
   End
   Begin VB.CommandButton cmdNext 
      Caption         =   "&Next  >"
      Height          =   375
      Left            =   4200
      TabIndex        =   2
      Top             =   4215
      Width           =   1215
   End
   Begin VB.CommandButton cmdPrev 
      Caption         =   "<  &Previous"
      Enabled         =   0   'False
      Height          =   375
      Left            =   2880
      TabIndex        =   1
      Top             =   4200
      Width           =   1215
   End
   Begin TabDlg.SSTab tabWizard 
      Height          =   3975
      Left            =   120
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   120
      Width           =   6615
      _Version        =   65536
      _ExtentX        =   11668
      _ExtentY        =   7011
      _StockProps     =   15
      Caption         =   "3"
      TabsPerRow      =   4
      Tab             =   3
      TabOrientation  =   0
      Tabs            =   4
      Style           =   1
      TabMaxWidth     =   0
      TabHeight       =   353
      ShowFocusRect   =   0   'False
      WordWrap        =   0   'False
      TabCaption(0)   =   "0"
      TabPicture(0)   =   "OLAPWizard.frx":068A
      Tab(0).ControlCount=   3
      Tab(0).ControlEnabled=   0   'False
      Tab(0).Control(0)=   "lstTables"
      Tab(0).Control(1)=   "imgSideBar"
      Tab(0).Control(2)=   "lblStep(0)"
      TabCaption(1)   =   "1"
      TabPicture(1)   =   "OLAPWizard.frx":06A6
      Tab(1).ControlCount=   6
      Tab(1).ControlEnabled=   0   'False
      Tab(1).Control(0)=   "fraGroup(0)"
      Tab(1).Control(1)=   "cmdData"
      Tab(1).Control(2)=   "cmdRow"
      Tab(1).Control(3)=   "cmdCol"
      Tab(1).Control(4)=   "lstAllFields"
      Tab(1).Control(5)=   "lblStep(1)"
      TabCaption(2)   =   "2"
      TabPicture(2)   =   "OLAPWizard.frx":06C2
      Tab(2).ControlCount=   3
      Tab(2).ControlEnabled=   0   'False
      Tab(2).Control(0)=   "Frame1"
      Tab(2).Control(1)=   "lstFields"
      Tab(2).Control(2)=   "lblStep(2)"
      TabCaption(3)   =   "3"
      TabPicture(3)   =   "OLAPWizard.frx":06DE
      Tab(3).ControlCount=   3
      Tab(3).ControlEnabled=   -1  'True
      Tab(3).Control(0)=   "lblStep(3)"
      Tab(3).Control(1)=   "fraGroup(5)"
      Tab(3).Control(2)=   "fraGroup(3)"
      Begin VB.Frame fraGroup 
         Height          =   3255
         Index           =   0
         Left            =   -72720
         TabIndex        =   31
         Top             =   600
         Width           =   4215
         Begin VB.ListBox lstColFields 
            Columns         =   4
            Height          =   615
            IntegralHeight  =   0   'False
            Left            =   1800
            TabIndex        =   34
            Top             =   240
            Width           =   2295
         End
         Begin VB.ListBox lstRowFields 
            Height          =   2160
            IntegralHeight  =   0   'False
            Left            =   120
            TabIndex        =   33
            Top             =   960
            Width           =   1575
         End
         Begin VB.ListBox lstDataFields 
            Height          =   2175
            IntegralHeight  =   0   'False
            Left            =   1800
            TabIndex        =   32
            Top             =   960
            Width           =   2295
         End
      End
      Begin VB.CommandButton cmdData 
         Caption         =   "Data"
         Height          =   255
         Left            =   -73440
         TabIndex        =   30
         Top             =   3600
         Width           =   615
      End
      Begin VB.CommandButton cmdRow 
         Caption         =   "Row"
         Height          =   255
         Left            =   -74160
         TabIndex        =   29
         Top             =   3600
         Width           =   615
      End
      Begin VB.CommandButton cmdCol 
         Caption         =   "Col"
         Height          =   255
         Left            =   -74880
         TabIndex        =   28
         Top             =   3600
         Width           =   615
      End
      Begin VB.Frame fraGroup 
         Caption         =   "Alignment"
         Height          =   1335
         Index           =   3
         Left            =   120
         TabIndex        =   21
         Top             =   720
         Width           =   3135
         Begin VB.ComboBox cboAlign 
            Height          =   315
            Index           =   0
            ItemData        =   "OLAPWizard.frx":06FA
            Left            =   1320
            List            =   "OLAPWizard.frx":0719
            Style           =   2  'Dropdown List
            TabIndex        =   24
            Top             =   240
            Width           =   1695
         End
         Begin VB.ComboBox cboAlign 
            Height          =   315
            Index           =   1
            ItemData        =   "OLAPWizard.frx":07BE
            Left            =   1320
            List            =   "OLAPWizard.frx":07DD
            Style           =   2  'Dropdown List
            TabIndex        =   23
            Top             =   600
            Width           =   1695
         End
         Begin VB.ComboBox cboOutlineIconAlign 
            Height          =   315
            ItemData        =   "OLAPWizard.frx":0882
            Left            =   1320
            List            =   "OLAPWizard.frx":0892
            Style           =   2  'Dropdown List
            TabIndex        =   22
            Top             =   960
            Width           =   1695
         End
         Begin VB.Label lblTag 
            Caption         =   "Column:"
            Height          =   255
            Index           =   11
            Left            =   120
            TabIndex        =   27
            Top             =   240
            Width           =   1095
         End
         Begin VB.Label lblTag 
            Caption         =   "Row:"
            Height          =   255
            Index           =   12
            Left            =   120
            TabIndex        =   26
            Top             =   240
            Width           =   1215
         End
         Begin VB.Label lblTag 
            Caption         =   "Outline Icon:"
            Height          =   255
            Index           =   17
            Left            =   120
            TabIndex        =   25
            Top             =   960
            Width           =   975
         End
      End
      Begin VB.Frame fraGroup 
         Caption         =   "Style"
         Height          =   1695
         Index           =   5
         Left            =   120
         TabIndex        =   12
         Top             =   2160
         Width           =   3135
         Begin VB.ComboBox cboStyle 
            Height          =   315
            Index           =   0
            ItemData        =   "OLAPWizard.frx":08D1
            Left            =   1320
            List            =   "OLAPWizard.frx":08E4
            Style           =   2  'Dropdown List
            TabIndex        =   16
            Top             =   240
            Width           =   1695
         End
         Begin VB.ComboBox cboStyle 
            Height          =   315
            Index           =   1
            ItemData        =   "OLAPWizard.frx":093A
            Left            =   1320
            List            =   "OLAPWizard.frx":094D
            Style           =   2  'Dropdown List
            TabIndex        =   15
            Top             =   600
            Width           =   1695
         End
         Begin VB.ComboBox cboCursorStyle 
            Height          =   315
            ItemData        =   "OLAPWizard.frx":09A3
            Left            =   1320
            List            =   "OLAPWizard.frx":09AD
            Style           =   2  'Dropdown List
            TabIndex        =   14
            Top             =   960
            Width           =   1695
         End
         Begin VB.ComboBox cboGridStyle 
            Height          =   315
            ItemData        =   "OLAPWizard.frx":09C7
            Left            =   1320
            List            =   "OLAPWizard.frx":09D7
            Style           =   2  'Dropdown List
            TabIndex        =   13
            Top             =   1320
            Width           =   1695
         End
         Begin VB.Label lblTag 
            Caption         =   "Column:"
            Height          =   255
            Index           =   13
            Left            =   120
            TabIndex        =   20
            Top             =   240
            Width           =   1095
         End
         Begin VB.Label lblTag 
            Caption         =   "Row:"
            Height          =   255
            Index           =   14
            Left            =   120
            TabIndex        =   19
            Top             =   600
            Width           =   1095
         End
         Begin VB.Label lblTag 
            Caption         =   "Cursor:"
            Height          =   255
            Index           =   15
            Left            =   120
            TabIndex        =   18
            Top             =   960
            Width           =   1095
         End
         Begin VB.Label lblTag 
            Caption         =   "Grid:"
            Height          =   255
            Index           =   16
            Left            =   120
            TabIndex        =   17
            Top             =   1320
            Width           =   1095
         End
      End
      Begin VB.Frame Frame1 
         Height          =   3255
         Left            =   -72600
         TabIndex        =   10
         Top             =   555
         Width           =   4095
         Begin VB.Frame fraGroupFooter 
            Caption         =   "Group Footer"
            Height          =   1095
            Left            =   120
            TabIndex        =   41
            Top             =   1560
            Width           =   3855
            Begin VB.OptionButton optGFType 
               Caption         =   "Count"
               Height          =   255
               Index           =   3
               Left            =   2880
               TabIndex        =   48
               Top             =   720
               Width           =   855
            End
            Begin VB.OptionButton optGFType 
               Caption         =   "Average"
               Height          =   255
               Index           =   2
               Left            =   1800
               TabIndex        =   47
               Top             =   720
               Width           =   975
            End
            Begin VB.OptionButton optGFType 
               Caption         =   "Sum"
               Height          =   255
               Index           =   1
               Left            =   960
               TabIndex        =   46
               Top             =   720
               Width           =   855
            End
            Begin VB.OptionButton optGFType 
               Caption         =   "None"
               Height          =   255
               Index           =   0
               Left            =   120
               TabIndex        =   45
               Top             =   720
               Width           =   855
            End
            Begin VB.TextBox txtGFCaption 
               Height          =   285
               Left            =   1200
               TabIndex        =   42
               Top             =   240
               Width           =   2535
            End
            Begin VB.Label lblTag 
               Caption         =   "Caption:"
               Height          =   255
               Index           =   1
               Left            =   120
               TabIndex        =   44
               Top             =   240
               Width           =   1095
            End
         End
         Begin VB.Frame fraOrinetation 
            Caption         =   "&Orientation"
            Height          =   615
            Left            =   120
            TabIndex        =   36
            Top             =   840
            Width           =   3855
            Begin VB.OptionButton optOrient 
               Caption         =   "Data"
               Height          =   255
               Index           =   3
               Left            =   2895
               TabIndex        =   40
               Top             =   240
               Width           =   855
            End
            Begin VB.OptionButton optOrient 
               Caption         =   "Row"
               Height          =   255
               Index           =   2
               Left            =   1980
               TabIndex        =   39
               Top             =   240
               Width           =   780
            End
            Begin VB.OptionButton optOrient 
               Caption         =   "Column"
               Height          =   255
               Index           =   1
               Left            =   1080
               TabIndex        =   38
               Top             =   240
               Width           =   855
            End
            Begin VB.OptionButton optOrient 
               Caption         =   "Hidden"
               Height          =   255
               Index           =   0
               Left            =   120
               TabIndex        =   37
               Top             =   240
               Width           =   855
            End
         End
         Begin VB.TextBox txtFldCaption 
            Height          =   285
            Left            =   1320
            TabIndex        =   35
            Top             =   240
            Width           =   2655
         End
         Begin VB.Label lblFldName 
            Height          =   255
            Left            =   1320
            TabIndex        =   50
            Top             =   600
            Width           =   2655
         End
         Begin VB.Label lblTag 
            Caption         =   "Name:"
            Height          =   255
            Index           =   2
            Left            =   120
            TabIndex        =   49
            Top             =   600
            Width           =   1095
         End
         Begin VB.Label lblTag 
            Caption         =   "Caption:"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   43
            Top             =   240
            Width           =   1095
         End
      End
      Begin VB.ListBox lstFields 
         Height          =   3150
         IntegralHeight  =   0   'False
         Left            =   -74880
         TabIndex        =   8
         Top             =   675
         Width           =   2175
      End
      Begin VB.ListBox lstAllFields 
         DragIcon        =   "OLAPWizard.frx":0A07
         Height          =   2820
         IntegralHeight  =   0   'False
         Left            =   -74880
         TabIndex        =   7
         Top             =   675
         Width           =   2055
      End
      Begin VB.ListBox lstTables 
         Height          =   3135
         IntegralHeight  =   0   'False
         Left            =   -73920
         Sorted          =   -1  'True
         TabIndex        =   5
         Top             =   675
         Width           =   2415
      End
      Begin VB.Label lblStep 
         Caption         =   "Step 4. Preferences"
         BeginProperty Font 
            name            =   "Arial"
            charset         =   0
            weight          =   700
            size            =   9.75
            underline       =   0   'False
            italic          =   0   'False
            strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   3
         Left            =   120
         TabIndex        =   11
         Top             =   360
         Width           =   6375
      End
      Begin VB.Label lblStep 
         Caption         =   "Step 3. Do you want to change any field default properties?"
         BeginProperty Font 
            name            =   "Arial"
            charset         =   0
            weight          =   700
            size            =   9.75
            underline       =   0   'False
            italic          =   0   'False
            strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   2
         Left            =   -74880
         TabIndex        =   9
         Top             =   315
         Width           =   6375
      End
      Begin VB.Image imgSideBar 
         Height          =   915
         Left            =   -74880
         Picture         =   "OLAPWizard.frx":0E49
         Top             =   675
         Width           =   930
      End
      Begin VB.Label lblStep 
         Caption         =   "Step 2. How would you like the view to look?"
         BeginProperty Font 
            name            =   "Arial"
            charset         =   0
            weight          =   700
            size            =   9.75
            underline       =   0   'False
            italic          =   0   'False
            strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   1
         Left            =   -74880
         TabIndex        =   6
         Top             =   315
         Width           =   6375
      End
      Begin VB.Label lblStep 
         Caption         =   "Step 1. Which table do you want to use?"
         BeginProperty Font 
            name            =   "Arial"
            charset         =   0
            weight          =   700
            size            =   9.75
            underline       =   0   'False
            italic          =   0   'False
            strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   0
         Left            =   -74880
         TabIndex        =   4
         Top             =   315
         Width           =   6375
      End
   End
End
Attribute VB_Name = "frmWizard"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Dim ws As Workspace
Dim db As Database
Dim rs As Recordset
Dim aFields() As udtField

Private Sub LoadCubeFields()

    On Error GoTo LoadCubeFields_Err

Dim i As Integer
Dim iFields As Integer
Dim iField As Integer

    iFields = lstColFields.ListCount + lstRowFields.ListCount + lstDataFields.ListCount
    ReDim aFields(iFields - 1)
    
    lstFields.Clear
    iField = 0
    For i = 0 To lstColFields.ListCount - 1
        lstFields.AddItem lstColFields.List(i)
        aFields(iField).Name = lstColFields.List(i)
        aFields(iField).Caption = lstColFields.List(i)
        aFields(iField).Orient = 1
        aFields(iField).GFCaption = "Sum of " & aFields(iField).Name
        aFields(iField).GFType = 1
        iField = iField + 1
    Next
    For i = 0 To lstRowFields.ListCount - 1
        lstFields.AddItem lstRowFields.List(i)
        aFields(iField).Name = lstRowFields.List(i)
        aFields(iField).Caption = lstRowFields.List(i)
        aFields(iField).Orient = 2
        aFields(iField).GFCaption = "Sum of " & aFields(iField).Name
        aFields(iField).GFType = 1
        iField = iField + 1
    Next
    For i = 0 To lstDataFields.ListCount - 1
        lstFields.AddItem lstDataFields.List(i)
        aFields(iField).Name = lstDataFields.List(i)
        aFields(iField).Caption = lstDataFields.List(i)
        aFields(iField).Orient = 3
        iField = iField + 1
    Next
    lstFields.ListIndex = 0

LoadCubeFields_Exit:      ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
LoadCubeFields_Err:       ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume LoadCubeFields_Exit

End Sub

Private Sub LoadFields(sTblName As String)

    On Error GoTo LoadFields_Err

    lstAllFields.Clear
    lstRowFields.Clear
    lstColFields.Clear
    lstDataFields.Clear
    Set rs = db.OpenRecordset(sTblName)
    For i = 0 To rs.Fields.Count - 1
        lstAllFields.AddItem rs.Fields(i).Name
        If rs.Fields(i).Type = dbDate Then
            lstAllFields.AddItem "Year of " & rs.Fields(i).Name
            lstAllFields.AddItem "Quarter of " & rs.Fields(i).Name
            lstAllFields.AddItem "Month of " & rs.Fields(i).Name
            lstAllFields.AddItem "Week of " & rs.Fields(i).Name
        End If
    Next

LoadFields_Exit:          ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
LoadFields_Err:           ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume LoadFields_Exit

End Sub

Private Sub cmdFinish_Click()

    On Error GoTo cmdFinish_Click_Err

Dim i As Integer
    ' Let's Create a new Cube
    With frmPlay.dcOLAP
        ' Set up data source
        .DCConnectType = DCCT_DAO
        .DCConnect = "Access"
        .DCDatabaseName = loctext$ & "synergyv.mdb"
        .DCRecordSource = lstTables.List(lstTables.ListIndex)
        For i = 0 To UBound(aFields)
            Set oFld = .Fields.Add(aFields(i).Name, aFields(i).Caption, aFields(i).Orient)
            If oFld.Orientation = 3 Then    ' if not a data field
                oFld.AggregateFunc = DC_SUM
            Else
                oFld.GroupFooterType = aFields(i).GFType
                oFld.GroupFooterCaption = aFields(i).GFCaption
            End If
        Next
        .ColAlignment = cboAlign(0).ListIndex
        .RowAlignment = cboAlign(0).ListIndex
        .OutlineIconAlignment = cboOutlineIconAlign.ListIndex
        .ColStyle = cboStyle(0).ListIndex
        .RowStyle = cboStyle(1).ListIndex
        .CursorStyle = cboCursorStyle.ListIndex
        .GridStyle = cboGridStyle.ListIndex
    End With
    Unload Me
    frmPlay.Show vbModal
    ' Unload Me

cmdFinish_Click_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdFinish_Click_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdFinish_Click_Exit

End Sub

Private Sub cmdNext_Click()

    On Error GoTo cmdNext_Click_Err

    Select Case tabWizard.Tab
    Case 0: ' Table select
        If lstTables.ListIndex >= 0 Then
            ' Load the fields
            LoadFields lstTables.List(lstTables.ListIndex)
            ' Move to the next page
            tabWizard.Tab = 1
            ' Enable the previous
            cmdPrev.Enabled = True
        End If
    Case 1: ' Layout
        If lstColFields.ListCount > 0 And lstRowFields.ListCount > 0 And lstDataFields.ListCount > 0 Then
            LoadCubeFields
            tabWizard.Tab = 2
            cmdFinish.Enabled = True
        End If
    Case 2: ' Fields
        cmdNext.Enabled = False
        tabWizard.Tab = 3
    End Select

cmdNext_Click_Exit:       ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdNext_Click_Err:        ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdNext_Click_Exit

End Sub

Private Sub cmdPrev_Click()

    On Error GoTo cmdPrev_Click_Err

    Select Case tabWizard.Tab
    Case 1:
        cmdPrev.Enabled = False
        cmdFinish.Enabled = False
        tabWizard.Tab = 0
    Case 2:
        tabWizard.Tab = 1
    Case 3:
        cmdNext.Enabled = True
        tabWizard.Tab = 2
    End Select

cmdPrev_Click_Exit:       ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdPrev_Click_Err:        ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdPrev_Click_Exit

End Sub

Private Sub Form_Load()

    On Error GoTo Form_Load_Err

    Left = (Screen.Width - Width) / 2   ' Center form horizontally.
    Top = (Screen.Height - Height) / 2  ' Center form vertically.
    InitWizard

Form_Load_Exit:           ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
Form_Load_Err:            ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume Form_Load_Exit

End Sub


Private Sub InitWizard()

    On Error GoTo InitWizard_Err

Dim i As Integer
    Set ws = DBEngine.Workspaces(0)
    Set db = ws.OpenDatabase(loctext$ & "synergyv.mdb")
    For i = 0 To db.TableDefs.Count - 1
        If (db.TableDefs(i).Attributes And dbSystemObject) = 0 Then
             lstTables.AddItem db.TableDefs(i).Name
        End If
    Next
    
    For i = 0 To db.QueryDefs.Count - 1
        lstTables.AddItem db.QueryDefs(i).Name
    Next
    cboAlign(0).ListIndex = 0
    cboAlign(1).ListIndex = 0
    cboOutlineIconAlign.ListIndex = 1
    cboStyle(0).ListIndex = 0
    cboStyle(1).ListIndex = 0
    cboCursorStyle.ListIndex = 0
    cboGridStyle.ListIndex = 1
    
    tabWizard.TabHeight = 1
    tabWizard.Tab = 0

InitWizard_Exit:          ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
InitWizard_Err:           ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume InitWizard_Exit

End Sub

Private Sub cmdCol_Click()

    On Error GoTo cmdCol_Click_Err

    If lstAllFields.ListIndex > -1 Then
        lstColFields.AddItem lstAllFields.List(lstAllFields.ListIndex)
        lstAllFields.RemoveItem lstAllFields.ListIndex
    End If
    lstAllFields.SetFocus

cmdCol_Click_Exit:        ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdCol_Click_Err:         ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdCol_Click_Exit

End Sub

Private Sub cmdData_Click()

    On Error GoTo cmdData_Click_Err

    If lstAllFields.ListIndex > -1 Then
        lstDataFields.AddItem lstAllFields.List(lstAllFields.ListIndex)
    End If
    lstAllFields.SetFocus

cmdData_Click_Exit:       ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdData_Click_Err:        ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdData_Click_Exit

End Sub

Private Sub cmdRow_Click()

    On Error GoTo cmdRow_Click_Err

    If lstAllFields.ListIndex > -1 Then
        lstRowFields.AddItem lstAllFields.List(lstAllFields.ListIndex)
        lstAllFields.RemoveItem lstAllFields.ListIndex
    End If
    lstAllFields.SetFocus

cmdRow_Click_Exit:        ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
cmdRow_Click_Err:         ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume cmdRow_Click_Exit

End Sub

Private Sub Form_Unload(Cancel As Integer)
    On Error Resume Next
    rs.Close
    db.Close
    ws.Close
End Sub

Private Sub lstFields_Click()

    On Error GoTo lstFields_Click_Err

Dim i As Integer
    txtFldCaption = aFields(lstFields.ListIndex).Caption
    lblFldName = aFields(lstFields.ListIndex).Name
    optOrient(aFields(lstFields.ListIndex).Orient).Value = 1
    If aFields(lstFields.ListIndex).Orient = 3 Then
        txtGFCaption = ""
        For i = 0 To 3: optGFType(i).Value = 0: Next
        fraGroupFooter.Enabled = False
    Else
        fraGroupFooter.Enabled = True
        txtGFCaption = aFields(lstFields.ListIndex).GFCaption
        optGFType(aFields(lstFields.ListIndex).GFType).Value = 1
    End If

lstFields_Click_Exit:     ' SDVB autocode
    On Error Resume Next  ' SDVB autocode
    Exit Sub              ' SDVB autocode
lstFields_Click_Err:      ' SDVB autocode
    MsgBox Error          ' SDVB autocode
    Resume lstFields_Click_Exit

End Sub

Private Sub optGFType_LostFocus(Index As Integer)

    On Error GoTo optGFType_LostFocus_Err

    If optGFType(Index).Value = 1 And aFields(lstFields.ListIndex).GFType <> Index Then
        aFields(lstFields.ListIndex).GFType = Index
    End If

optGFType_LostFocus_Exit:  ' SDVB autocode
    On Error Resume Next   ' SDVB autocode
    Exit Sub               ' SDVB autocode
optGFType_LostFocus_Err:   ' SDVB autocode
    MsgBox Error           ' SDVB autocode
    Resume optGFType_LostFocus_Exit

End Sub

Private Sub optOrient_LostFocus(Index As Integer)

    On Error GoTo optOrient_LostFocus_Err

    If optOrient(Index).Value = 1 And aFields(lstFields.ListIndex).Orient <> Index Then
        aFields(lstFields.ListIndex).Orient = Index
    End If

optOrient_LostFocus_Exit:  ' SDVB autocode
    On Error Resume Next   ' SDVB autocode
    Exit Sub               ' SDVB autocode
optOrient_LostFocus_Err:   ' SDVB autocode
    MsgBox Error           ' SDVB autocode
    Resume optOrient_LostFocus_Exit

End Sub

Private Sub txtFldCaption_LostFocus()

    On Error GoTo txtFldCaption_LostFocus_Err

    If aFields(lstFields.ListIndex).Caption <> txtFldCaption.Text Then
        aFields(lstFields.ListIndex).Caption = txtFldCaption.Text
    End If

txtFldCaption_LostFocus_Exit:  ' SDVB autocode
    On Error Resume Next       ' SDVB autocode
    Exit Sub                   ' SDVB autocode
txtFldCaption_LostFocus_Err:   ' SDVB autocode
    MsgBox Error               ' SDVB autocode
    Resume txtFldCaption_LostFocus_Exit

End Sub

VERSION 4.00
Begin VB.Form frmMenuRBIC 
   Caption         =   "Re-Build Inventory Cost"
   ClientHeight    =   3780
   ClientLeft      =   3375
   ClientTop       =   2820
   ClientWidth     =   6480
   Height          =   4185
   Left            =   3315
   LinkTopic       =   "Form1"
   ScaleHeight     =   3780
   ScaleWidth      =   6480
   Top             =   2475
   Width           =   6600
   Begin Threed.SSCommand SSCommand5 
      Height          =   1635
      Left            =   4320
      TabIndex        =   4
      Top             =   1980
      Width           =   1935
      _Version        =   65536
      _ExtentX        =   3413
      _ExtentY        =   2884
      _StockProps     =   78
      Caption         =   "Post WorkBook"
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand4 
      Height          =   1635
      Left            =   2160
      TabIndex        =   3
      Top             =   1980
      Width           =   1935
      _Version        =   65536
      _ExtentX        =   3413
      _ExtentY        =   2884
      _StockProps     =   78
      Caption         =   "Print Journal"
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand3 
      Height          =   1635
      Left            =   120
      TabIndex        =   2
      Top             =   1980
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2884
      _StockProps     =   78
      Caption         =   "Enter Cost"
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand2 
      Height          =   1635
      Left            =   2160
      TabIndex        =   1
      Top             =   120
      Width           =   1935
      _Version        =   65536
      _ExtentX        =   3413
      _ExtentY        =   2884
      _StockProps     =   78
      Caption         =   "Print WorkBook"
      BevelWidth      =   1
      Outline         =   0   'False
   End
   Begin Threed.SSCommand SSCommand1 
      Height          =   1635
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1815
      _Version        =   65536
      _ExtentX        =   3201
      _ExtentY        =   2884
      _StockProps     =   78
      Caption         =   "Collect SKU Data"
      BevelWidth      =   1
      Outline         =   0   'False
   End
End
Attribute VB_Name = "frmMenuRBIC"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Activate()
    Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Load()
    Call ofx_CenterForm(Me)
End Sub


Private Sub SSCommand1_Click()
    Call DoCollectData
End Sub



Private Sub DoCollectData()
    Dim intChoice As Integer
    Dim myDB As Database
    Dim RSInventory, RSReBuildCost As Recordset
    
    intChoice = MsgBox("Are you sure to start?", vbYesNo, "Collect SKU Data")
    Select Case intChoice
        Case vbYes
            Screen.MousePointer = vbHourglass
            Set myDB = Workspaces(0).OpenDatabase("SynergyV.mdb")                           ' Open database
            Set RSInventory = myDB.OpenRecordset("Inventory", dbOpenDynaset, dbReadOnly)    ' Open table read only
            Set RSReBuildCost = myDB.OpenRecordset("ReBuildCost", dbOpenDynaset)            ' Open table read/write
            Do While Not RSInventory.EOF
                Me.Caption = RSInventory!SKU
                With RSReBuildCost
                    .AddNew
                    !SKU = RSInventory!SKU
                    .Update
                End With
                RSInventory.MoveNext
            Loop
            RSInventory.Close
            RSReBuildCost.Close
            myDB.Close
            Screen.MousePointer = vbDefault
        Case vbNo
            MsgBox "Job Aborted!"
    End Select
End Sub

Private Sub SSCommand2_Click()
    Call PrintRBICWorkBook(0)
End Sub


Private Sub SSCommand3_Click()
    If ofx_IsFormLoaded(frmRBIC_EnterCost) Then
        frmRBIC_EnterCost.SetFocus
        frmRBIC_EnterCost.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmRBIC_EnterCost.Show
    End If
End Sub


Private Sub SSCommand4_Click()
    CurrentDate = Date
    loctext$ = LCase(App.Path)
    If Right$(App.Path, 1) <> "\" Then loctext$ = loctext$ + "\"  'handles the root
    sDBName = loctext$ & "synergyv.mdb"
    SynergyIcon = loctext$ & "synergy.ico"
    CrwRptName = "RBIC WorkBook Result"
'    SRptName = loctext$ & "rpt\" & CrwRptName & ".rpt"      ' DAO Reports
    If Not SetRptFileName(CrwRptName, 0) Then Exit Sub
    
    Screen.MousePointer = vbHourglass
    frmInventoryChoice.Show vbModal
    Screen.MousePointer = vbDefault
End Sub


Private Sub SSCommand5_Click()
    If ofx_IsFormLoaded(frmRBIC_PostEntry) Then
        frmRBIC_PostEntry.SetFocus
        frmRBIC_PostEntry.ZOrder
        SendKeys "% R", True
    Else
        Screen.MousePointer = vbHourglass
        frmRBIC_PostEntry.Show
    End If
End Sub



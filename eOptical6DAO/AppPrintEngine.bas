Attribute VB_Name = "Module1"
Option Explicit

Declare Function PEOpenEngine Lib "crpe32.dll" () As Integer
Declare Sub PECloseEngine Lib "crpe32.dll" ()


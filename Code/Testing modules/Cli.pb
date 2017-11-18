;-TOP
; NetworkData Client Example v1.11

IncludeFile "Modul_NetworkData.pbi"

Enumeration ;Window
  #Main
EndEnumeration

Enumeration ; Menu
  #Menu
EndEnumeration

Enumeration ; MenuItems
  #MenuSend1
  #MenuSend2
  #MenuSend3
  #MenuSend4
  #MenuExit
EndEnumeration

Enumeration ; Gadgets
  #List
EndEnumeration

Enumeration ; Statusbar
  #Status
EndEnumeration

Procedure.s Chars(Lenght, Char.s)
  Protected result.s
  result = Space(Lenght)
  ReplaceString(result, " ", Char, #PB_String_InPlace)
  ProcedureReturn result
EndProcedure

; Global Variable
Global exit

Global text.s
Global *RawData.NetworkData::udtAny
Global NewList Text.s()

*RawData = AllocateMemory(30000)
FillMemory(*RawData, MemorySize(*RawData), $A0A0A0A0, #PB_Long)
*RawData\bVal[1024] = 14

; Functions

Procedure NewData(SEvent, ConnectionID, *NewData.NetworkData::udtDataset)
  
  UseModule NetworkData
  
  If SEvent = #PB_NetworkEvent_Disconnect
    Logging("Callback: Server disconnected: ID " + Str(ConnectionID))
    exit = 1
    ProcedureReturn 0
  EndIf
  
  With *NewData
    Logging("Callback: New data from ConnectionID " + Str(ConnectionID) + ": DataID " + Str(\DataID))
    Select \Type
      Case #NetInteger
        Logging("Callback: Result = " + Str(\Integer))
        
      Case #NetString
        Logging("Callback: Result = " + \String)
        
      Case #NetData
        Debug "Data"
         
    EndSelect
    
  EndWith
  
  ProcedureReturn 0
  
  UnuseModule NetworkData

EndProcedure

Structure udtData
  ConnectionID.i
  Filename.s
EndStructure

Procedure thSendFile(*thData.udtData)
  Static DataID = 500
  DataID + 1
  If DataID >= 600
    DataID = 501
  EndIf
  With *thData
    NetworkData::SendString(\ConnectionID, DataID, GetFilePart(\filename))
    NetworkData::SendFile(\ConnectionID, DataID, \filename)
  EndWith
EndProcedure

Procedure UpdateWindow()
  
  Protected x, y, dx, dy, menu, status
  
  menu = MenuHeight()
  If IsStatusBar(#Status)
    status = StatusBarHeight(#Status)
  Else
    status = 0
  EndIf
  x = 0
  y = 0
  dx = WindowWidth(#Main)
  dy = WindowHeight(#Main) - menu - status
  ResizeGadget(#List, x, y, dx, dy)
  
EndProcedure

; Main
Procedure Main()
  
  Protected event, style, ConnectionID, timer, filename.s, SendFileData.udtData
  
  style = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
  dx = 600
  dy = 400
  
  If OpenWindow(#Main, #PB_Ignore, #PB_Ignore, dx, dy, "Client", style)
    
    ; Enable Fullscreen
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
      Protected NewCollectionBehaviour
      NewCollectionBehaviour = CocoaMessage(0, WindowID(#Main), "collectionBehavior") | $80
      CocoaMessage(0, WindowID(#Main), "setCollectionBehavior:", NewCollectionBehaviour)
    CompilerEndIf
    
    ; Menu
    CreateMenu(#Menu, WindowID(#Main))
    MenuTitle("Common")
    MenuItem(#MenuSend1, "Send Text")
    MenuItem(#MenuSend2, "Send Data")
    MenuItem(#MenuSend3, "Send List")
    MenuItem(#MenuSend4, "Send File")
    MenuBar()
    MenuItem(#MenuExit, "E&xit")
    ; Gadgets
    ListViewGadget(#List, 0, 0, dx, dy)
    
    ; Statusbar
    CreateStatusBar(#Status, WindowID(#Main))
    AddStatusBarField(#PB_Ignore)
    
    UpdateWindow()
    
    NetworkData::BindLogging(#PB_Event_FirstCustomValue, #List)
    ConnectionID = NetworkData::InitClient("192.168.0.4", 6037, @NewData())
    ;ConnectionID = NetworkData::InitClient("Michaels-Mac", 6037, @NewData())
    If Not ConnectionID
      Debug "Server not Found"
      End
    EndIf
    
    ; Main Loop
    Repeat
      event = WaitWindowEvent(10)
      Select event
        Case #PB_Event_Menu
          Select EventMenu()
              CompilerIf #PB_Compiler_OS = #PB_OS_MacOS   
              Case #PB_Menu_About
                
              Case #PB_Menu_Preferences
                
              Case #PB_Menu_Quit
                NetworkData::CloseClient(ConnectionID)
                exit = #True
                
              CompilerEndIf
              
            Case #MenuExit
              NetworkData::CloseClient(ConnectionID)
              exit = #True
              
            Case #MenuSend1
              text = "String: " + " (" + Chars(Random(200000, 1), "x") + ")"
              NetworkData::SendString(ConnectionID, 101, text)
              NetworkData::SendInteger(ConnectionID, 101, Len(text))
              
            Case #MenuSend2
              NetworkData::SendData(ConnectionID, 102, *RawData, MemorySize(*RawData))
              NetworkData::SendInteger(ConnectionID, 102, MemorySize(*RawData))
              
            Case #MenuSend3
              ClearList(Text())
              count =  10 ;Random(10, 1)
              For i = 1 To count
                AddElement(Text())
                Text() = "Text: Nummer " + Str(i) + " (" + Chars(Random(100000), "x") + ")"
              Next
              NetworkData::SendList(ConnectionID, 103, Text())
              NetworkData::SendInteger(ConnectionID, 103, count)
              
            Case #MenuSend4
              filename = OpenFileRequester("Send File", "*.*", "", 0)
              If filename
                SendFileData\ConnectionID = ConnectionID
                SendFileData\Filename = filename
                CreateThread(@thSendFile(), SendFileData)
              EndIf
              
          EndSelect
          
          
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #List
          EndSelect
          
        Case #PB_Event_SizeWindow
          Select EventWindow()
            Case #Main
              UpdateWindow()
          EndSelect
          
        Case #PB_Event_CloseWindow
          Select EventWindow()
            Case #Main
              NetworkData::CloseClient(ConnectionID)
              exit = #True
          EndSelect
          
      EndSelect
      
    Until exit
    
  EndIf
  
EndProcedure : Main()

End
; IDE Options = PureBasic 5.60 (Windows - x64)
; CursorPosition = 182
; Folding = w-
; EnableThread
; EnableXP
; Executable = servcheck.exe
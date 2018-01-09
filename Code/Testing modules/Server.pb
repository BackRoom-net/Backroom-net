;-TOP
; NetworkData Server Example v1.10

Enumeration ;Window
  #Main
EndEnumeration

Enumeration ; Menu
  #Menu
EndEnumeration

Enumeration ; MenuItems
  #MenuExit
EndEnumeration

Enumeration ; Gadgets
  #List
EndEnumeration

Enumeration ; Statusbar
  #Status
EndEnumeration

; Global Variable
Global exit

IncludeFile "Modul_NetworkData.pbi"

; NewData Callback
Procedure NewData(SEvent, ConnectionID, *NewData.NetworkData::udtDataset)
  
  UseModule NetworkData

  Protected ip.s, result.s
  
  If SEvent = #PB_NetworkEvent_Connect
    ip = IPString(GetClientIP(ConnectionID))
    ;Logging("Callback: Client connected: IP " + ip)
    ProcedureReturn 0
  ElseIf SEvent = #PB_NetworkEvent_Disconnect
    ;Logging("Callback: Client disconnected ID " + Str(ConnectionID))
    ProcedureReturn 0
  EndIf
  
  With *NewData
    ip = IPString(GetClientIP(ConnectionID))
    Logging("Callback: New data from ID " + Str(ConnectionID) + " (" + ip + "): DataID " + Str(\DataID))
    Select \Type
      Case #NetInteger
        result = "Ok:" + Str(\Integer)
        
      Case #NetString
        result = "Size of String = " + Str(Len(\String))
        Debug \String
        
      Case #NetData
        result = "Size of RawData = " + Str(MemorySize(\Data))
        
      Case #NetList
        result = "Count of List = " + Str(ListSize(\Text()))
        
      Case #NetFile
        If \String
          result = GetPathPart(\Filename) + \String
          RenameFile(\Filename, result)
        EndIf
        result = "File: " + result
        Debug \String
        Debug \filename
        Debug result
        
    EndSelect
    
    SendString(ConnectionID, \DataID, result)
    
    ProcedureReturn 0
    
  EndWith
  
  UnuseModule NetworkData

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
  
  Protected event, style
  
  style = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
  dx = 640
  dy = 480
  
  If OpenWindow(#Main, #PB_Ignore, #PB_Ignore, dx, dy, "Server", style)
    
    ; Enable Fullscreen
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
      Protected NewCollectionBehaviour
      NewCollectionBehaviour = CocoaMessage(0, WindowID(#Main), "collectionBehavior") | $80
      CocoaMessage(0, WindowID(#Main), "setCollectionBehavior:", NewCollectionBehaviour)
    CompilerEndIf
    
    ; Menu
    CreateMenu(#Menu, WindowID(#Main))
    MenuTitle("Common")
    MenuItem(#MenuExit, "E&xit")
    ; Gadgets
    ListViewGadget(#List, 0, 0, dx, dy)
    
    ; Statusbar
    CreateStatusBar(#Status, WindowID(#Main))
    AddStatusBarField(#PB_Ignore)
    
    UpdateWindow()
    
    NetworkData::BindLogging(#PB_Event_FirstCustomValue, #List)
    ServerID = NetworkData::InitServer(6037, @NewData())
    CreateDirectory("Data")
    NetworkData::SetDataFolder("Data\")
    
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
                NetworkData::CloseServer(ServerID)
                exit = #True
                
              CompilerEndIf
              
            Case #MenuExit
              NetworkData::CloseServer(ServerID)
              exit = #True
              
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
              NetworkData::CloseServer(ServerID)
              exit = #True
              
          EndSelect
          
      EndSelect
      
    Until exit
    
  EndIf
  
EndProcedure : Main()

End
; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 135
; FirstLine = 39
; Folding = m
; EnableThread
; EnableXP
; Executable = S.exe
DeclareModule CliNode
  Global NewList AllClients.i()
  Declare Connect(Node_Address$)
EndDeclareModule

Module CliNode
  
  Declare NewData(SEvent, ConnectionID, *NewData.NetworkData::udtDataset)
  
  Procedure Connect(Node_Address$)
    ConnectionID = NetworkData::InitClient(Node_Address$, 4455, @NewData())
    If Not ConnectionID
      Log::GenLogadd("ConCon","NODE_ERROR","Could not Connect to Node:"+Node_Address$,"NODE_ClientMgr_Connect()")
    Else
      InsertElement(AllClients())
      AllClients() = ConnectionID
    EndIf
    
  EndProcedure
  
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
        
      Case #NetFile
        
    EndSelect
    
  EndWith
  
  ProcedureReturn 0
  
  UnuseModule NetworkData

EndProcedure
  
  
  
  
EndModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 14
; Folding = -
; EnableXP
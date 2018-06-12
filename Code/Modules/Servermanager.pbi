DeclareModule NodeServer
  Declare.i createserver(port)
  
  
EndDeclareModule

Module NodeServer
  Declare NewData(SEvent, ConnectionID, *NewData.NetworkData::udtDataset)
  Declare ClientNew(ConnectionID)
  NewList Connected.i()
  
  Procedure.i createserver(port)
    UseModule NetworkData
    ServerID = InitServer(port, @NewData())
    ProcedureReturn ServerID
    UnuseModule NetworkData
  EndProcedure
  
  
  Procedure NewData(SEvent, ConnectionID, *NewData.NetworkData::udtDataset)
  
  UseModule NetworkData

  Protected ip.s, result.s
  
  If SEvent = #PB_NetworkEvent_Connect
    ip = IPString(GetClientIP(ConnectionID))
    SendString(ConnectionID, 0, "Server Hello")
    
   If ClientNew(ConnectionID)
    UseModule ConnectionMgr
    AddConnection(1,ip)
    UnuseModule ConnectionMgr
  EndIf
  
    
    Logging("NODE_SERVER: Client connected: IP " + ip)
    ProcedureReturn 0
  ElseIf SEvent = #PB_NetworkEvent_Disconnect
    Logging("NODE_SERVER: Client disconnected ID " + Str(ConnectionID))
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

Procedure.i clientNew(ConnectionID)
  Input()
  NewList TempCli.s()
  UseModule SQuery
  raw = GetClientIP(ConnectionID)
  IP$ = IPString(raw)
  
  SQLQuerySelect(1,"IP","'KnownClients'",0,TempCli.s())
  
  If FirstElement(TempCli())
    If TempCli() = IP$
      ProcedureReturn #False
    Else
      While TempCli() <> IP$
      NextElement(TempCli())  
    Wend
  EndIf
  
    If TempCli() = IP$
      ProcedureReturn #False
    Else
      ProcedureReturn #True
    EndIf
  Else
    ProcedureReturn #True
  EndIf


EndProcedure

 
EndModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 83
; FirstLine = 64
; Folding = -
; EnableXP
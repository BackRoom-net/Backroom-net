DeclareModule network
    Global NewList AllClients.i()
  Declare Connect(Node_Address$)
Declare AddConnection(cat,Val.s)
Declare ReconnectAll()
Declare.i createserver(port)
EndDeclareModule

Module network

;--Client stuff
 
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
;--Server stuff

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
;--General Connections

  Procedure AddConnection(cat,Val.s)
    Request$ = SQFormat::SQLInsert(Request$,"'KnownClients'","IP, Ping, HandShakeSuccessful, AESCatch, SHA1, SHA2, SHA3, MD5, CRC32, Base64Master, Base64Key, MasterKey, Key","'"+Val.s+"', '0', '12', '0', 'NS', 'NS', 'NS', 'NS', 'NS', 'NS', 'NS', 'NS', 'NS'",1)
    Debug Request$
    SQFormat::SQLCommit(1,Request$)
    CliNode::Connect(Val.s)
  EndProcedure
  
  Procedure ReconnectAll()
    UseModule CliNode
    NewList Output.s()
    SQuery::SQLQuerySelect(1,"IP","'KnownClients'",0,Output.s())
    PrintN("Nodes to connect too: "+Str(ListSize(Output())))
    If FirstElement(Output.s())
      Address$ = Output()
      Connect(Address$)
      While NextElement(Output())
        Address$ = Output()
        Connect(Address$)
      Wend
      Else
      Log::GenLogadd("Recon","Info","Database Indicates there are no known clients. Could not connect to any Nodes.","NODE_ConnectionMgr_ReconnectAll()")
    EndIf
  EndProcedure
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 4
; Folding = D5
; EnableXP
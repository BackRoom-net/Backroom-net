DeclareModule ConnectionMgr
  Declare AddConnection(cat,Val.s)
  Declare ReconnectAll()
EndDeclareModule

  
Module ConnectionMgr
  
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
; CursorPosition = 19
; Folding = -
; EnableXP
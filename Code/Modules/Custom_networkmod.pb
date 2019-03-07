DeclareModule net
  Declare.i StartServer(port)
  ;Declare.i StartClient(serveraddress$,port)
  ;- Server Globals
  Global NewList serverIDs.i()
  Global servername$ = ""
  Global mapaccess = CreateMutex()
  Global mapmemlis = CreateMutex()
  Global memthread = CreateMutex()
  Global sql = CreateMutex()
  Global NewMap Threads.i()
  Global NewMap Memlist.i()
  
  ;- Client Globals
  Declare.i StartClient(ClientAgent,Address$,port)
  Declare.s ClientSendDataWait(ClientAgent,String$)
  Declare ClientSend(ClientAgent,String$)
  Structure liz
    Address.s
    port.i
    ThreadID.i
    Status.i
  EndStructure
  Structure xob
    ClientAgent.i
    returncode.s
    message.s
  EndStructure
  Structure dbox
    ClientAgent.i
    MemoryAddress.i
  EndStructure
  
  Global NewMap Clients.liz()
  Global ClientlizMutx = CreateMutex()
  Global sendmutex = CreateMutex()
  Global inmutex = CreateMutex()
  Global datmutex = CreateMutex()
  Global NewList Outbox.xob()
  Global NewList Inbox.xob()
  Global NewList Databox.dbox()
  
EndDeclareModule


Module net
  Declare serverthread(port)
  Declare ServerIndividualThread(ClientID)
  Declare ClientThread(ClientAgent)
  Declare ServerSend(ClientID,retco$,message$)
  Declare.s ServerExtractData(FormedMessage$)
  Declare ClientLayer(ClientAgent)
  Declare.s commandMath(String$)
  ;Declare ClientSendData(ClientAgent,String$)
  InitNetwork()
  
  ;- Server
  
  Procedure.i StartServer(port)
    CreateThread(@serverthread(),port)
    ;serverthread(port)
  EndProcedure
  
  Procedure serverthread(port)
;     Structure lz
;     address.i
;     status.i
;     EndStructure
    UseModule Log
    Debug "Server Started"
    ServerID = Random(9999,0)
    Debug ServerID
    CreateNetworkServer(ServerID,port)
    
    Repeat
      
      ServerEvent = NetworkServerEvent()
      
      If ServerEvent
        ClientID = EventClient()
        Select ServerEvent
            
          Case #PB_NetworkEvent_Connect
            Debug "Client connected."
            Thread = CreateThread(@ServerIndividualThread(),ClientID)
            ResetMap(Threads())
            AddMapElement(Threads(),Str(ClientID))
            Threads() = Thread
            ;GenLogadd("serverthread"+Str(ServerID),"THREAD","ServerID: "+Str(ServerID)+" Client connected. New ID: "+Str(ClientID),"serverthread() - main")
            
            
          Case #PB_NetworkEvent_Disconnect
            Debug "Client: "+Str(ClientID)+" Disconnected."
            LockMutex(mapaccess)
            ;Debug Str(Threads(Str(ClientID)))+" Is the Thread ID."
            KillThread(Threads(Str(ClientID)))
            DeleteMapElement(Threads(),Str(ClientID))
            UnlockMutex(mapaccess)
            ;Debug "killed thread"
            ;GenLogadd("serverthread"+Str(ServerID),"THREAD","ServerID: "+Str(ServerID)+" Client disconnected. Client: "+Str(ClientID)+" Thread killed.","serverthread() - main")
            
          Case #PB_NetworkEvent_Data
            *ReceiveBuffer = AllocateMemory(65536)
            ReceiveNetworkData(ClientID,*ReceiveBuffer,65536)
            LockMutex(mapmemlis)
            AddMapElement(Memlist(),Str(ClientID))
            Memlist(Str(ClientID)) = *ReceiveBuffer
            UnlockMutex(mapmemlis)
            ;GenLogadd("serverthread"+Str(ServerID),"THREAD","ServerID: "+Str(ServerID)+" Received data from: "+Str(ClientID)+" Memory address reserved: "+*ReceiveBuffer,"serverthread() - main")
            
        EndSelect
      Else
        Delay(1)
      EndIf
      
;       ; thread memory check.
;       LockMutex(mapmemlis)
;       ResetMap(Memlist)
;       While NextMapElement(Memlist())
;         If Memlist() \status = 1
;           Debug "Freeing memory: "+Memlist()
;           FreeMemory(Memlist())
;         EndIf
;       Wend
;       UnlockMutex(mapmemlis)
;       ;

    ForEver

  EndProcedure
  
  Procedure ServerIndividualThread(ClientID)
    Debug "Individual thread started."
    UseModule Log
    NewList ToBeFree.i()
    NewList listoutput.s()
    
    Repeat  
      Delay(5)
      If FindMapElement(Memlist(),Str(ClientID)) 
        LockMutex(mapmemlis)
        ResetMap(MemList())
        FindMapElement(Memlist(),Str(ClientID)) 
        memory = Memlist(Str(ClientID))
        received$ = PeekS(memory,65536,#PB_UTF8)
        FreeMemory(memory)
        DeleteMapElement(Memlist(),Str(ClientID))
        UnlockMutex(mapmemlis)
        message$ = StringField(received$,2,"<sep-ret*message>")
        retco$ = StringField(received$,1,"<sep-ret*message>")
        ;GenLogadd("ServerThread"+Str(ClientID),"THREAD","Received data raw: "+received$+" From memory address: "+Str(memory),"ServerIndividualThread("+Str(ClientID)+")")
    ;- custom commands section
    
   If message$ <> "" 
    Select message$
      Case "Client hello"
        ServerSend(ClientID,retco$,"Server hello")
        
        Case "SendBuff"
        SendNetworkString(ClientID,"This should be readable")
        ;GenLogadd("ServerThread"+Str(ClientID),"THREAD","Sent Client "+Str(ClientID)+" A test buffer.","ServerIndividualThread("+Str(ClientID)+")")
        
      Default
        If FindString(message$,"Math")
          out$ = commandMath(message$)
          ServerSend(ClientID,retco$,out$)
        EndIf
    EndSelect
  EndIf

  
    ;- end of custom commands section
    message$ = ""
    Command$ = ""
    ClearList(listoutput())

  EndIf
   fail:
      Delay(1)

    Until exit = 1
  EndProcedure
  
  Procedure.s commandMath(String$)
    strlen = Len(String$)
    RealMath$ = Right(String$,strlen-5)
    totalLen = Len(RealMath$)
    Debug String$
    Debug RealMath$
    do1 = FindString(RealMath$, "+")
    do2 = FindString(RealMath$, "-")
    do3 = FindString(RealMath$, "/")
    do4 = FindString(RealMath$, "*")
    
    ;do = 2
    
    If do1 Or do2 Or do3 Or do4
      do = do1+do2+do3+do4
      first = totalLen - do
      str2$ = Mid(RealMath$,do+1)
      str2len = (Len(str2$)+1)-totalLen
      str1$ = Mid(RealMath$,1,totalLen)
      Debug str1$
      Debug str2$
      
      If str1$ = ""
        ProcedureReturn "value one has no integer value"
      ElseIf str2$ = ""
        ProcedureReturn "value two has no integer value"
      EndIf
      
      If do1
        ans = Val(str1$)+Val(str2$)
      ElseIf do2
        ans = Val(str1$)-Val(str2$)
      ElseIf do3
        ansd.d = Val(str1$)/Val(str2$)
        ProcedureReturn Str(ansd.d)
      ElseIf do4
        ans = Val(str1$)*Val(str2$)
      EndIf
      ProcedureReturn Str(ans)
    Else
      ProcedureReturn "Unsupported"
    EndIf
  EndProcedure
  
  
  Procedure ServerSend(ClientID,retco$,message$)
    SendNetworkString(ClientID,retco$+"<sep-ret*message>"+message$,#PB_UTF8)
  EndProcedure
  
  Procedure.s ServerExtractData(FormedMessage$)
;     Actual$ = StringField(FormedMessage$,2,"(")
;     actlen = Len(actual$)
;     Actual$ = Left(Actual$,actlen-1)
    
    count = Len(FormedMessage$)
    open = FindString(FormedMessage$,"(")
    extract = count-open
    Semi$ = Right(FormedMessage$,extract)
    Actual$ = Left(Semi$,extract-1)
    
    
    ProcedureReturn Actual$
  EndProcedure
  
  
  ;- Client
  
  Procedure.i StartClient(ClientAgent,Address$,port)
    LockMutex(ClientlizMutx)
    If FindMapElement(Clients(),Str(ClientAgent))
      If Clients() \Status = 0
        Clients() \Address = Address$
        Clients() \port = port
        Thread = CreateThread(@ClientThread(),ClientAgent)
        ;Input()
        ;ClientThread(ClientAgent)
        Clients() \ThreadID = Thread
        UnlockMutex(ClientlizMutx)
      Else
        Debug "ClientAgent Number already in use."
      EndIf
      Else
    AddMapElement(Clients(),Str(ClientAgent))
    Clients() \Address = Address$
    Clients() \port = port
    Thread = CreateThread(@ClientThread(),ClientAgent)
        ;Input()
        ;ClientThread(ClientAgent)
    Clients() \ThreadID = Thread
    UnlockMutex(ClientlizMutx)
    ProcedureReturn Thread
  EndIf
  
  EndProcedure
  
  Procedure ClientThread(ClientAgent)
    UseModule Log
    LockMutex(ClientlizMutx)
    If FindMapElement(Clients(),Str(ClientAgent))
      ConnAddress$ = Clients() \Address
      ConnPort = Clients() \port
      Clients() \Status = 1
      UnlockMutex(ClientlizMutx)
    Else
      Clients() \Status = 0
      UnlockMutex(ClientlizMutx)
      Debug "Error. Could not find Client Agent Map element."
    EndIf
    
    ConnectionID = OpenNetworkConnection(ConnAddress$,ConnPort)
    If ConnectionID
      ClientLayer = CreateThread(@ClientLayer(),ClientAgent)
      Repeat
        ; send out any data so that it is possible we can get data back quicker.
        LockMutex(sendmutex)
        ResetList(Outbox())
        While NextElement(Outbox())
          If Outbox() \ClientAgent = ClientAgent
            retco$ = Outbox() \returncode
            Message$ = Outbox() \message
            UnlockMutex(sendmutex)
            SendNetworkString(ConnectionID,retco$+"<sep-ret*message>"+Message$)
            GenLogAdd("send","THREAD","Sent message to server: "+retco$+"<sep-ret*message>"+Message$,"ClientThread("+Str(ClientAgent)+")")
            LockMutex(sendmutex)
            DeleteElement(Outbox())
          EndIf
        Wend
        UnlockMutex(sendmutex)
        
        
        
        ; Check for incoming data.
        CliEvent = NetworkClientEvent(ConnectionID)
        If CliEvent
          Select CliEvent
              
            Case #PB_NetworkEvent_Data
              Debug "Client has received data."
              *ReceiveBuffer = AllocateMemory(65536)
              ReceiveNetworkData(ConnectionID,*ReceiveBuffer,65536)
              Received$ = PeekS(*ReceiveBuffer,65536,#PB_UTF8)

              LockMutex(datmutex)
              AddElement(Databox())
              Databox() \ClientAgent = ClientAgent
              Databox() \MemoryAddress = *ReceiveBuffer
              UnlockMutex(datmutex)
            
            Case #PB_NetworkEvent_Disconnect
              exit = 1
              LockMutex(ClientlizMutx)
              DeleteMapElement(Clients(),Str(ClientAgent))
              UnlockMutex(ClientlizMutx)
              KillThread(ClientLayer)
          EndSelect
        Else
          Delay(1)
        EndIf
        
          
        Until exit = 1
    Else
      LockMutex(ClientlizMutx)
      Clients(Str(ClientAgent)) \Status = 0
      UnlockMutex(ClientlizMutx)
      Debug "Error, Was unable to connect to server."
    EndIf
 
  EndProcedure
  
  Procedure ClientLayer(ClientAgent)
    Repeat
      LockMutex(datmutex)
      While NextElement(Databox())
        memory = Databox() \MemoryAddress
        If FindString(PeekS(memory,65536,#PB_UTF8),"<sep-ret*message>")
          retco$ = StringField(Received$,1,"<sep-ret*message>")
          message$ = StringField(Received$,2,"<sep-ret*message>")
          retco$ = StringField(Received$,1,"<sep-ret*message>")
        EndIf
      Wend
      Delay(5)
    ForEver
  EndProcedure
  
  
  Procedure.s ClientSendDataWait(ClientAgent,String$)
    returncode$ = Str(Random(9999,0))
    LockMutex(sendmutex)
    InsertElement(Outbox())
    Outbox() \ClientAgent = ClientAgent
    Outbox() \message = String$
    Outbox() \returncode = returncode$
    UnlockMutex(sendmutex)
    
    retry:
    LockMutex(inmutex)
    ResetList(Inbox())
    ForEach Inbox()
      If Inbox() \ClientAgent = ClientAgent
        Debug "Looking for "+Str(ClientAgent)+" found "+Inbox() \ClientAgent
        If Inbox() \returncode = returncode$
          Message$ = Inbox() \message
          DeleteElement(Inbox())
          Break
        EndIf
      EndIf
      If ListIndex(Inbox()) = ListSize(Inbox())
        ResetList(Inbox())
        UnlockMutex(inmutex)
        Delay(5)
        LockMutex(inmutex)
      EndIf
    Next
    UnlockMutex(Inmutex)
    Delay(12)
    If message$ = ""
      counter+1
      If counter = 1000
        Goto fail
      EndIf
      Goto retry
    EndIf
      ProcedureReturn Message$  
      fail:
      ProcedureReturn "fail"
      
  EndProcedure
  
  Procedure ClientSend(ClientAgent,String$)
    returncode$ = Str(Random(9999,0))
    LockMutex(sendmutex)
    InsertElement(Outbox())
    Outbox() \ClientAgent = ClientAgent
    Outbox() \message = String$
    Outbox() \returncode = returncode$
    UnlockMutex(sendmutex)
  EndProcedure
  
  
  
  
EndModule 

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 357
; FirstLine = 208
; Folding = PY+
; EnableXP
; Executable = ServerTest.exe
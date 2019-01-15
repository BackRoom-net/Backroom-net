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
  Declare clientmaster(ClientAgent)
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
            GenLogadd("serverthread"+Str(ServerID),"THREAD","ServerID: "+Str(ServerID)+" Client connected. New ID: "+Str(ClientID),"serverthread() - main")
            
            
          Case #PB_NetworkEvent_Disconnect
            Debug "Client: "+Str(ClientID)+" Disconnected."
            LockMutex(mapaccess)
            Debug Str(Threads(Str(ClientID)))+" Is the Thread ID."
            KillThread(Threads(Str(ClientID)))
            DeleteMapElement(Threads(),Str(ClientID))
            UnlockMutex(mapaccess)
            Debug "killed thread"
            GenLogadd("serverthread"+Str(ServerID),"THREAD","ServerID: "+Str(ServerID)+" Client disconnected. Client: "+Str(ClientID)+" Thread killed.","serverthread() - main")
            
          Case #PB_NetworkEvent_Data
            *ReceiveBuffer = AllocateMemory(65536)
            ReceiveNetworkData(ClientID,*ReceiveBuffer,65536)
            LockMutex(mapmemlis)
            AddMapElement(Memlist(),Str(ClientID))
            Memlist(Str(ClientID)) = *ReceiveBuffer
            UnlockMutex(mapmemlis)
            GenLogadd("serverthread"+Str(ServerID),"THREAD","ServerID: "+Str(ServerID)+" Received data from: "+Str(ClientID)+" Memory address reserved: "+*ReceiveBuffer,"serverthread() - main")
            
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
        message$ = StringField(received$,2,"<sep-ret*message>")
        retco$ = StringField(received$,1,"<sep-ret*message>")
        GenLogadd("ServerThread"+Str(ClientID),"THREAD","Received data raw: "+received$+" From memory address: "+Str(memory),"ServerIndividualThread("+Str(ClientID)+")")
    ;- custom commands section
    
   If message$ <> "" 
    Select message$
      Case "Client hello"
        ServerSend(ClientID,retco$,"Server hello")
        
        Case "SendBuff"
        SendNetworkString(ClientID,"This should be readable")
        GenLogadd("ServerThread"+Str(ClientID),"THREAD","Sent Client "+Str(ClientID)+" A test buffer.","ServerIndividualThread("+Str(ClientID)+")")
        
      Default
        Command$ = StringField(message$,1,"(")
    EndSelect
  EndIf
  Command$ = StringField(message$,1,"(")
  If command$ <> ""
    Select Command$
        Case "Client hello"
        ServerSend(ClientID,retco$,"Server hello")
        
        Case "SendBuff"
        SendNetworkString(ClientID,"This should be readable")
        GenLogadd("ServerThread"+Str(ClientID),"THREAD","Sent Client "+Str(ClientID)+" A test buffer.","ServerIndividualThread("+Str(ClientID)+")")
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
  
  Procedure ServerSend(ClientID,retco$,message$)
    SendNetworkString(ClientID,retco$+"<sep-ret*message>"+message$,#PB_Unicode)
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
      CreateThread(@clientmaster(),ClientAgent)
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
              Debug Received$
              
              retco$ = StringField(Received$,1,"<sep-ret*message>")
              message$ = StringField(Received$,2,"<sep-ret*message>")
              
            If retco$
              LockMutex(inmutex)
              AddElement(inbox())
              Inbox() \ClientAgent = ClientAgent
              Inbox() \message = Message$
              Inbox() \returncode = retco$
              UnlockMutex(inmutex)
            Else
              LockMutex(datmutex)
              AddElement(Databox())
              Databox() \ClientAgent = ClientAgent
              Databox() \MemoryAddress = *ReceiveBuffer
              UnlockMutex(datmutex)
            EndIf
            
            Case #PB_NetworkEvent_Disconnect
              exit = 1
              LockMutex(ClientlizMutx)
              DeleteMapElement(Clients(),Str(ClientAgent))
              UnlockMutex(ClientlizMutx)
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
        Delay(100)
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
  
  
  Procedure clientmaster(ClientAgent)
    CreateDirectory("StreamTemp")
    CreateDirectory("StreamTemp\"+Str(ClientAgent))
    GenLogadd("TamalKings","THREAD","Initialized Directory: "+"StreamTemp\"+Str(ClientAgent),"clientmaster("+Str(ClientAgent)+")")
    Repeat
      LockMutex(ClientlizMutx)
      If Clients(Str(ClientAgent)) \Status = 1
        UnlockMutex(ClientlizMutx) 
        
      LockMutex(datmutex)
      ForEach Databox()
        If Databox() \ClientAgent = ClientAgent
          OpenFile(1,"StreamTemp\"+Str(ClientAgent)+"\Stream.file",#PB_File_Append)
          *Buff = Databox() \MemoryAddress
          WriteData(1,*Buff,65536)
          FreeMemory(*Buff)
          DeleteElement(Databox())
        EndIf
      Next
      UnlockMutex(datmutex)
      Delay(5)
      
    Else
      GenLogadd("TamalKings","THREAD","Client Status not 1","clientmaster("+Str(ClientAgent)+")")
        DeleteMapElement(Clients(),Str(ClientAgent))
        exit = 1
      EndIf
    Until exit = 1
    
  EndProcedure
  
  
EndModule 

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 130
; FirstLine = 127
; Folding = b9-
; EnableXP
; Executable = ServerTest.exe
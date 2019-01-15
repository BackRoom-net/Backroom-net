;   Description: Main Program
;        Author: Ruben Rodriguez
;          Date: 11/13/17
;            OS: Windows/XP/Vista/7/10



;
;- Includes
;
 
 InitNetwork()
 
IncludePath "C:\Users\Ruben\Documents\GitHub\Backroom-net\Code\Modules"
XIncludeFile "Proforma_mod.pbi"
XIncludeFile "ThreadBranch_mod.pbi"
IncludePath "C:\Users\Ruben\Documents\GitHub\Backroom-net\Code\Application"
XIncludeFile "log.pbi"
IncludePath "C:\Users\Ruben\Documents\GitHub\Backroom-net\Code\Modules"
;XIncludeFile "Preferences.pbi"
XIncludeFile "FileUtil_mod.pbi"
XIncludeFile "bip_data_handler.pb"
XIncludeFile "Custom_networkmod.pb"
UseModule Proforma
;UseModule FileUtil
;
;- Declares
;
Declare Initialize()
Declare DetectSystem()
Declare CleanShutDown()
Declare ViewCurrentConnections()
;
;- Structures
;



;
;- Variables
;
Global KeyboardMode.i
Global msg$, conplace
Global App_Version.s = "1.0.0" 
Global Memory_Override = 1
Global LogExist

If FileSize(FormatDate("%yy.%mm.%dd", Date())+".log") > 1
  LogExist = 1
Else 
  LogExist = 0
EndIf


;
;- Maps






;
;- Procedures
;
;------------


  

DisableExplicit
Procedure Initialize()
  
Log::GenLogadd("Init56","Info","Beginning of log----","Initialize()")



UseModule net
StartServer(4455)
StartServer(4456)
Delay(1000)
Log::GenLogadd("Init57","Info","Main Thread created two server threads.","Initialize()")
StartClient(1,"127.0.0.1",4455)
Delay(1000)
Debug ClientSend(1,"SendBuff")
Input()
Delay(1000)



; Mainserver = createserver(4455)
; If Mainserver
;   log::GenLogadd("MainServer","Info","Main Node server ID = "+Mainserver,"Initialize()")
; Else
;   Text$ = "Could not create a Main Node server. Check your firewall settings and restart the program."
;   MessageRequester("Network Error",Text$,#PB_MessageRequester_Error)
; EndIf



; AddThreadMember(Thread1)
; AddThreadMember(Thread2)
; AddThreadMember(Thread3)
; AddThreadMember(Thread4)
; AddThreadMember(Thread5)
; AddThreadMember(Thread6)
; AddThreadMember(Thread7)
; AddThreadMember(Thread8)
; AddThreadMember(Thread9)
;WaitThreadBranchGraphical("Waiting On Database Initilization...",900,7000)





EndProcedure

Procedure DetectSystem()
  
  Total = MemoryStatus(#PB_System_TotalPhysical)
  Current = MemoryStatus(#PB_System_FreePhysical)
  Debug Total
  Debug Current
  If Total > 4200000000 ;anything above 4gb
    SysSpecTotal = 1
    ElseIf Total > 4100000000 ;4gb
      SysSpecTotal = 2
    ElseIf Total < 2000000000 ;below 2gb
      SysSpecTotal = 0
    EndIf
    Tolog$ = Str(SysSpecTotal)+" Was returned when Reading memory total of: "+Str(Total)+" Bytes"
    Log::GenLogadd("Detectinf1","Info",Tolog$,"DetectSystem()")
    
    If Current > 4200000000 ;anything above 4gb
    SysSpecCurr = 1
    ElseIf Current > 4100000000 ;4gb
      SysSpecCurr = 2
    ElseIf Current < 2000000000 ;below 2gb
      SysSpecCurr = 0
    ElseIf Current > 2000000000 ;Just above 2gb
      SysSpecCurr = 3
    EndIf
    Tolog$ = Str(SysSpecTotal)+" Was returned when Reading memory current of: "+Str(Current)+" Bytes"
    Log::GenLogadd("DetectInf","Info",Tolog$,"DetectSystem()")
    
    Debug SysSpecTotal
    Debug SysSpecCurr
    If SysSpecTotal = 0
      If Memory_Override = 0
        MessageRequester("System","System does not have Minimum Requeseted memory. Program will not run.",#PB_MessageRequester_Error)
      EndIf
          Tolog$ = "System failed reccomended system spec."
          Log::GenLogadd("Detect0","Error",Tolog$,"DetectSystem()")
          If Memory_Override = 0
            End
          EndIf
  EndIf
  
    
  If SysSpecCurr = 0
    If Memory_Override = 0
      MessageRequester("System","System does not currently have enough memory to Run program. Try exiting some programs.",#PB_MessageRequester_Error)
      EndIf
                Tolog$ = "System does not have enough free memory."
                Log::GenLogadd("Detect1","Error",Tolog$,"DetectSystem()")
                If Memory_Override = 0
                  End
                EndIf
                
    EndIf
    
    If SysSpecCurr = 3
      If Memory_Override = 0
        Result = MessageRequester("System","System is Low on memory. Are you sure you would like to continue running the program?"+Chr(13)+"If Chrome is detected, we will close it for you.",#PB_MessageRequester_Warning | #PB_MessageRequester_YesNo)
      EndIf
      
      Tolog$ = "System Low on memory."
          Log::GenLogadd("Detect3","Warning",Tolog$,"DetectSystem()")
          If Result = #PB_MessageRequester_Yes
            PrintN("Please wait while Chrome Processes are killed...")
            RunProgram("c:\windows\system32\taskkill.exe","/IM chrome.exe /F","", #PB_Program_Wait | #PB_Program_Hide)
            ClearConsole()
          Else
            If Memory_Override = 1
              Else
                End
              EndIf
              
      EndIf
    EndIf
    If LogExist = 1
      Log::GenLogadd("Detect1","Info","Skipped over system detect because of existing records.","DetectSystem()")
    Else
    PrintN("Please Wait while loading System information...")
    Tolog$ = "---Beginning of system exploration---"+Chr(13)
    Tolog$ = Tolog$+"CPU Name: "+CPUName()+Chr(13)
    Tolog$ = ToLog$+"CPU Cores:"+Str(CountCPUs(#PB_System_CPUs))+Chr(13)
    Tolog$ = ToLog$+"Loading system Information from windows..."+Chr(13)
    
    prog = RunProgram("c:\windows\system32\systeminfo.exe","","", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
    
   If prog
    While ProgramRunning(prog)
      Error$ = ReadProgramError(prog) 
      If Error$
        Output$ = Output$ + Error$
      EndIf
      If AvailableProgramOutput(prog)
        Output$ + ReadProgramString(prog) + Chr(13)
      EndIf
    Wend
    Output$ + Chr(13) + Chr(13)
  EndIf
  CloseProgram(prog)
  
  ToLog$ = ToLog$+Output$+Chr(13)
    ToLog$ = ToLog$+"---End of system exploration---"
    Log::GenLogadd("Detect0","Info",Tolog$,"DetectSystem()")
  EndIf
  
 
EndProcedure



;--------
;- GUI functions
;--------


Procedure CleanShutDown()
  EnableGraphicalConsole(1)
  UseModule Proforma
  ;UseModule Prefs
  ClearConsole()
  PrintN("Please Wait...")
  SpillProforma()
;   If PrefChk()
;     DeleteFile("Data\Preferences.xml")
;   EndIf
;   PrefExport()
;   CloseDatabase(1)
  Log::GenLogadd("Shutdown","SHUTDOWN","Program is shutting down...","CleanShutDown()")
  PrintN("Connecting to FTP server...")
  If OpenFTP(1,"www.wow-interesting.com","loguploads@wow-interesting.com","plzupload")
    PrintN("Connected Successfully. Getting ready to send Anonymous log files...")
    PrintN("Please wait while Generating ID...")
    ID$ = Str(Random(2147483647,0))
    While SetFTPDirectory(1,ID$)
      SetFTPDirectory(1,"..")
      ID$ = Str(Random(2147483647,0))
      count = count+1
      If count = 5
        PrintN("Error - Could not Send.")
        Log::GenLogadd("Shutdown","SHUTDOWN ERROR","Could not generate valid log send ID that was not taken.","CleanShutDown()")
        Goto fail
      Else
        PrintN("Random ID already exists. Retrying...")
      EndIf
    Wend 
    PrintN("Generating Entry...")
    CreateFTPDirectory(1,ID$)
    SetFTPDirectory(1,ID$)
    PrintN("Gathering Log files...")
    Delay(1000)
    Home$ = GetCurrentDirectory()
    ExamineDirectory(1,Home$,"*.log")
    While NextDirectoryEntry(1)
      Filename$ = DirectoryEntryName(1)
      FullPath$ = Home$+Filename$
      Print("Uploading: "+Filename$)
      If SendFTPFile(1,FullPath$,Filename$)
        PrintN(" Done.")
      Else
        PrintN(" Fail.")
      EndIf
    Wend
    PrintN("Please wait while sending database...")
    SendFTPFile(1,Home$+"Data\Main.db","Database.db")
    
    PrintN("Please wait while Performance report file is sent...")
    SendFTPFile(1,Home$+"Proforma_Mem_Dump.txt","Proforma_mem_dump.txt")
    
  Else
    Log::GenLogadd("Shutdown","SHUTDOWN ERROR","Was Unable to connect to the log server.","CleanShutDown()")
    PrintN("Was unable to connect to the logging server... Upload Failed.")
    Delay(1200)
    Goto fail
  EndIf
  
    
    
  CloseFTP(1)
  PrintN("Completed Upload.")
  Delay(2000)
  fail:
  ClearConsole()
  PrintN("GoodBye.")
  Delay(1500)
  End
EndProcedure

Procedure ViewPackProcess()
  UseModule FileUtil
  ConX = 0
  ConY = 0
  Structure watc
    posy.i
    Process.s
    job.s
    stat.s
    msg.s
    Drawn.i
  EndStructure
  NewMap Watcher.watc()
  
  
  EnableGraphicalConsole(1)
  ClearConsole()
  While Inkey() <> Chr(27)
  LockMutex(ThreadStatMutex)
  While NextMapElement(FileThreads()) 
    ProcessID$ = FileThreads() \ID
    JobCurr$ = FileThreads() \Job
    StatCurr$ = FileThreads() \Status
    MsgCurr$ = FileThreads() \Message
    
    ProIDlen = Len(ProcessID$)
    Joblen = Len(JobCurr$)
    Statlen = Len(StatCurr$)
    Msglen = Len(MsgCurr$)
    
    
    ProcessForm$ = "Process: "+FileThreads() \ID
    JobForm$ = "Job: "+FileThreads() \Job +"Status: "+FileThreads() \Status
    InfoForm$ = "Info: "+FileThreads() \Message
    
    If FindMapElement(Watcher(),ProcessID$)
      If Watcher() \Drawn = 1
       curpos.i = Watcher() \posy
       
       If MsgCurr$ <> Watcher() \msg
         Fill$ = Space(150)
         ConsoleLocate(0,curpos+2)
         Print(Fill$)
         ConsoleLocate(0,curpos+2)
         Print(InfoForm$)
       EndIf
       
       If StatCurr$ <> Watcher() \stat Or JobCurr$ <> Watcher() \job
         Fill$ = Space(90)
         ConsoleLocate(0,curpos+1)
         Print(Fill$)
         ConsoleLocate(0,curpos+1)
         Print(JobForm$)
       EndIf
       
       If ProcessID$ = ""
         ResetMap(Watcher())
         While NextMapElement(Watcher())
           DeleteMapElement(Watcher())
         Wend
         ClearConsole()
       Else
        If FindMapElement(Watcher(),ProcessID$)
         If Not FindMapElement(FileThreads(), ProcessID$)
           DeleteMapElement(Watcher())
           ResetMap(Watcher())
           While NextMapElement(Watcher())
             Posincon = Watcher() \posy
             If Posincon <> 0
               Watcher() \posy = Posincon-4
               Watcher() \Drawn = 0
             EndIf
           Wend
           ResetMap(Watcher())
           ClearConsole()
         EndIf
       EndIf
       EndIf
       
        
     Else
       ConsoleLocate(ConX,ConY)
       watcher() \posy = ConY
        PrintN(ProcessForm$)
        PrintN(JobForm$)
        PrintN(InfoForm$)
        watcher() \Drawn = 1
        ConY = ConY+4
      EndIf
  Else
    Watcher(ProcessID$) \Drawn = 0
    Watcher() \Process = ProcessID$
    Watcher() \job = JobCurr$
    Watcher() \stat = StatCurr$
    Watcher() \msg = MsgCurr$
  EndIf
  
    
      
  Wend
  ResetMap(FileThreads())
  If NextMapElement(FileThreads())
    ResetMap(FileThreads())
  Else
    Delay(500)
    ClearConsole()
    PrintN("No Current Jobs Running.")
    PrintN("Press Esc. to exit.")
    UnlockMutex(ThreadStatMutex)
  EndIf
  
  UnlockMutex(ThreadStatMutex)
  Delay(36)
Wend

EndProcedure

Procedure ConnectToNode(IP.s)
;   UseModule Log
;   UseModule Network
;   
;   If Len(IP.s) = 0
;   ClearConsole()
;   PrintN("Enter a Valid IP address of the node you Wish to connect too.")
;   PrintN("(Please note that Discovering other Nodes may take some time)")
;   PrintN("IP:")
;   ValidIP$ = Input()
;   If ValidIP$ = "localhost" Or ValidIP$ = "127.0.0.0"
;     PrintN("Error, this address is Invalid.")
;     Else
;       UseModule NetworkData
;       
;       AddConnection(1,ValidIP$)
;       
;   If ConnectedClient 
;     PrintN("The Node you have specified has connected.")
;     Delay(1000)
;   Else
;     PrintN("Error when Connecting to Node.")
;   EndIf
; EndIf
;  Else 
;    UseModule NetworkData
;    
;    AddConnection(1,ValidIP$)
;    
;   If ConnectedClient 
;     PrintN("The Node you have specified has connected.")
;     Delay(1000)
;   Else
;     GenLogadd("Node_Error","NODE_ERROR","Error when connecting to node: "+IP.s,"NODE_CONNECT")
;   EndIf
; EndIf




EndProcedure

Procedure ViewCurrentConnections()
  ; this will happen some time later.
EndProcedure


;-------------
;- Program side
;




OpenConsole("BackRoom-Net")
DetectSystem()
EnableGraphicalConsole(1)
If Initialize()
 Debug "1"
EndIf




men:
EnableGraphicalConsole(1)
ClearConsole()
PrintN("Welcome to Backroom-Beta-1.0.0!")
PrintN(" ")
PrintN("Press 1 To create a new package")
PrintN("Press 2 To view current packaging processes")
PrintN("Press 3 To view current connections")
PrintN("Press 4 To connect to a new node")
PrintN("Press 5 To view download list")
PrintN("Press escape to exit")

Repeat
  msg$ = Inkey()
  If msg$ <> ""
    If msg$ = Chr(27)
      MessageRequester("BackRoom-Alpha-0.0.1","User Hit Escape Key. Please Wait for shutdown.")
      CleanShutDown()
    EndIf
       If msg$ = Chr(49)
          ;SpredDir(EncryptStorage() \MasterMem, *keyMem)
          ClearConsole()
          Goto men
        EndIf
        If msg$ = Chr(50)
          ;ViewPackProcess()
          Goto men
        EndIf
        If msg$ = Chr(51)
          ;ViewCurrentConnections()
          Goto men
        EndIf
        If msg$ = Chr(52)
          ;ConnectToNode("")
          Goto men
        EndIf
        
  EndIf
  
  Delay(1)
Until Exit = 1








Input()
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 84
; FirstLine = 67
; Folding = D-
; EnableThread
; EnableXP
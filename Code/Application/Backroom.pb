;   Description: Main Program
;        Author: Ruben Rodriguez
;          Date: 11/13/17
;            OS: Windows/XP/Vista/7/10

; Code is currently being reworked!! I will get back to you!!!

;
;- Declares
;
Global Log = CreateMutex() ; must be called up here so Log mutex is enabled. 

IncludePath "C:\Intel\Git\Backroom-net\Code\Modules\"
IncludeFile "Crypto_mod.pbi"
IncludeFile "Database_mod.pbi"
IncludeFile "FileUtil_mod.pbi"
IncludeFile "Modul_NetworkData.pbi"
IncludeFile "Proforma_mod.pbi"
;IncludeFile "Console_Interactive_mod.pbi"
IncludeFile "ThreadBranch_mod.pbi"
IncludeFile "Prefrences.pbi"
UseModule Proforma
UseModule Cipher
UseModule FileUtil
;
;
;
Declare Keyboard(conplace)
Declare InitializeDatabase()
Declare DetectSystem()
Declare CreatePrettystuff()
Declare CleanShutDown()
Declare Logt(Subsystem$,Text$)
Declare Logfinal(*logmemory)
;
;- Structures
;


;; No structures Rn... =(  
  
;
;- Variables
;
Global KeyboardMode.i
Global msg$, conplace

;
;- Maps

; Map cap at 6mill
ProformaMakeInst("Memory-Map-Ini")
ProformaS("Memory-Map-Ini")
Global NewMap Keys.s(6000000)
ProformaE("Memory-Map-Ini")

;
;- Procedures
;
;------------

Procedure.i keyboard(conplace)
  ;//InKey() is used to check for keyboard presses
  ;//and should be used in a loop.
  ;//in other words, use the procedure in a loop.
  
  ;// Output mode 1 for regular output to msg$ or 2 for Key string output to msg$
  
  KeyPressed$ = Inkey()
  
  Select KeyboardMode.i
      Case 1
  If KeyPressed$ <> ""      ;// This If is used to check if no key was pressed
    If KeyPressed$ = Chr(13)   ;// Right here is to check if enter was pressed
      ConsoleLocate(0,conplace)
      PrintN(msg$+Chr(13))     ;// If so it will print the current message
      msg$ = ""                ;// Erase from the variable
      conplace = conplace + 1  ;// and manually set the console position
    Else
      If KeyPressed$ = Chr(8)     ;// Here is the if the backspace was pressed
        lent = Len(msg$)           ;//Get the lenght of the message
        msg$ = Left(msg$,lent - 1) ;//Removes the deleted letter from msg$
        ConsoleLocate(0,conplace)
        tover = 0                 ;//safe guard to make sure variable is reset.
        over$ = ""                ;//another safe guard.
        If lent > 0              ;// if the lenghth of msg$ is over 0 go to next step.
        Repeat             ;//next step makes padding of null to cover message to print new message.
          over$ = over$+" " ;//adds padding to over$ to go over the message.
          tover = tover + 1 ;//counts  the ammount of padding needed to cover the message space
        Until tover = lent ;// until the whole place in the console is covered
        Print(over$)         ;// print the padding over the message.
        ConsoleLocate(0,conplace) ;// reset write head so its ready to write again.
        Print(msg$+Chr(0))       ;// print the modified msg$ with one less letter
        Debug msg$
        Debug over$
      EndIf                 ;//self explainatory. 
      
    Else                    ;// if any other event is needed, its costom and added below.
                              ;//Costom events------
      msg$ = msg$+KeyPressed$
      If msg$ = "!rp"
        Debug "in rp mode"
        ConsoleLocate(0,conplace)
        Print("   ")
        msg$ = ""
      EndIf
                             ;//-------------------
                             ;//end of costom events//
      ConsoleLocate(0,conplace) ;// reset console position just incase
      
      Print(msg$)            ;// if the events above where not true but there was a key press, it will be printed in now.
      
      
    EndIf   ;//end of backspace event
  EndIf     ;//end of enter keypress event
EndIf       ;//end of key press check
Delay(1)
If KeyPressed$ = Chr(27) ;// if the escape key was pressed, 
  result = 27
Else
  result = 1
EndIf
ProcedureReturn(result)

Case 2
  If KeyPressed$ <> ""
    If KeyPressed$ = Chr(13)
      msg$ = "enter"
      ProcedureReturn #True
      Else
      If KeyPressed$ = Chr(8)
        msg$ = "bspace"
        ProcedureReturn #True
      Else
        If KeyPressed$ = Chr(27)
          msg$ = "esc"
          ProcedureReturn #True
        Else
          msg$ = keypressed$
          ProcedureReturn #True
      EndIf
      
    
    
    EndIf
  EndIf
Else
  ProcedureReturn #False
EndIf
EndSelect

EndProcedure 

Procedure InitializeDatabase()
  CreateDirectory("Data")
UseModule SQLDatabase
UseModule SQFormat
UseModule SQuery
UseModule ThreadBranch
Initlogging(1,"")
Initdatabase(1,"Data\Main.db")
CloseC1$ = SQFCreateTable(CloseC1$,"CloseClients")
CloseC1$ = SQFOpen(CloseC1$)
CloseC1$ = SQFMakeField(CloseC1$,"ClientNumber",1,1,1,1,1,0)          ;To be under "Close Clients" Ping < 15ms
CloseC1$ = SQFclose(CloseC1$)

CloseC2$ = SQFCreateTable(CloseC2$,"KnownClients")                    ;All Clients
CloseC2$ = SQFOpen(CloseC2$)
CloseC2$ = SQFMakeField(CloseC2$,"ClientNumber",1,1,1,1,1,1)
CloseC2$ = SQFMakeField(CloseC2$,"IP",2,1,0,0,1,1)
CloseC2$ = SQFMakeField(CloseC2$,"Ping",1,1,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"HandShakeSuccessful",1,0,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"AESCatch",2,1,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"SHA1",2,1,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"SHA2",2,1,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"SHA3",2,1,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"MD5",2,1,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"CRC32",2,1,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"Base64Master",2,1,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"Base64Key",2,1,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"MasterKey",2,1,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"Key",2,1,0,0,0,0)
CloseC2$ = SQFclose(CloseC2$)


CloseC3$ = SQFCreateTable(CloseC3$,"FriendlyClients")                   ;Clients that we have downloaded from before
CloseC3$ = SQFOpen(CloseC3$)                                          ; It puts them at priority Refresh rate
CloseC3$ = SQFMakeField(CloseC3$,"ClientNumber",1,1,1,1,0,1)
CloseC3$ = SQFMakeField(CloseC3$,"IP",2,1,0,0,1,1)
CloseC3$ = SQFMakeField(CloseC3$,"Ping",1,1,0,0,0,0)
CloseC3$ = SQFclose(CloseC3$)


CloseC4$ = SQFCreateTable(CloseC4$,"ActiveRfrClients")                ;When Active Refresh Is required. (Ex. Every second or so.)
CloseC4$ = SQFOpen(CloseC4$)
CloseC4$ = SQFMakeField(CloseC4$,"ClientNumber",1,1,1,1,0,0)
CloseC4$ = SQFclose(CloseC4$)


CloseC5$ = SQFCreateTable(CloseC5$,"PackagesOnHost")
CloseC5$ = SQFOpen(CloseC5$)
CloseC5$ = SQFMakeField(CloseC5$,"PackageNumber",1,1,1,1,0,1)
CloseC5$ = SQFMakeField(CloseC5$,"PackageHash",2,1,0,0,0,1)
CloseC5$ = SQFMakeField(CloseC5$,"ChunksInPackage",1,1,0,0,0,1)
CloseC5$ = SQFMakeField(CloseC5$,"InProgress",1,0,0,0,0,1)
CloseC5$ = SQFMakeField(CloseC5$,"Progress",1,0,0,0,0,1)
CloseC5$ = SQFMakeField(CloseC5$,"Lock",1,0,0,0,0,0)
CloseC5$ = SQFclose(CloseC5$)


CloseC6$ = SQFCreateTable(CloseC6$,"PackSummary")
CloseC6$ = SQFOpen(CloseC6$)
CloseC6$ = SQFMakeField(CloseC6$,"PackageNumber",1,1,0,0,0,1)
CloseC6$ = SQFMakeField(CloseC6$,"Tags",2,1,0,0,0,1)
CloseC6$ = SQFMakeField(CloseC6$,"SubTrees",2,0,0,0,0,1)
CloseC6$ = SQFMakeField(CloseC6$,"Name",2,0,0,0,0,0)                ;Your name or user to display
CloseC6$ = SQFclose(CloseC6$)

CloseC7$ = SQFCreateTable(CloseC7$,"Downloadhistory")                   ;Clients that have downloaded before
CloseC7$ = SQFOpen(CloseC7$)                                          ; It puts them at priority Refresh rate
CloseC7$ = SQFMakeField(CloseC7$,"ClientNumber",1,1,1,1,0,1)
CloseC7$ = SQFMakeField(CloseC7$,"IP",2,1,0,0,1,1)
CloseC7$ = SQFMakeField(CloseC7$,"Ping",1,1,0,0,0,0)
CloseC7$ = SQFclose(CloseC7$)

CloseC8$ = SQFCreateTable(CloseC8$,"PackageOnServer")
CloseC8$ = SQFOpen(CloseC8$)
CloseC8$ = SQFMakeField(CloseC8$,"PackageNumber",1,1,1,1,0,1)
CloseC8$ = SQFMakeField(CloseC8$,"PackageHash",2,1,0,0,0,1)
CloseC8$ = SQFMakeField(CloseC8$,"ChunksInPackage",1,1,0,0,0,1)
CloseC8$ = SQFMakeField(CloseC8$,"InProgress",1,0,0,0,0,1)
CloseC8$ = SQFMakeField(CloseC8$,"Progress",1,0,0,0,0,0)
CloseC8$ = SQFclose(CloseC8$)

CloseC9$ = SQFCreateTable(CloseC9$,"PackServerSummary")
CloseC9$ = SQFOpen(CloseC9$)
CloseC9$ = SQFMakeField(CloseC9$,"PackageNumber",1,1,0,0,0,1)
CloseC9$ = SQFMakeField(CloseC9$,"Tags",2,1,0,0,0,1)
CloseC9$ = SQFMakeField(CloseC9$,"SubTrees",2,0,0,0,0,1)
CloseC9$ = SQFMakeField(CloseC9$,"Name",2,0,0,0,0,0)                ;Your name or user to display
CloseC9$ = SQFclose(CloseC9$)


Thread1 = SQLCommit(1,CloseC1$)
Thread2 = SQLCommit(1,CloseC2$)
Thread3 = SQLCommit(1,CloseC3$)
Thread4 = SQLCommit(1,CloseC4$)
Thread5 = SQLCommit(1,CloseC5$)
Thread6 = SQLCommit(1,CloseC6$)
Thread7 = SQLCommit(1,CloseC7$)
Thread8 = SQLCommit(1,CloseC8$)
Thread9 = SQLCommit(1,CloseC9$)
AddThreadMember(Thread1)
AddThreadMember(Thread2)
AddThreadMember(Thread3)
AddThreadMember(Thread4)
AddThreadMember(Thread5)
AddThreadMember(Thread6)
AddThreadMember(Thread7)
AddThreadMember(Thread8)
AddThreadMember(Thread9)
WaitThreadBranchGraphical("Waiting On Database Initilization...",900,7000)
ProcedureReturn #True
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
    Logt("DetectSystem",Tolog$)
    
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
    Logt("DetectSystem",Tolog$)
    
    Debug SysSpecTotal
    Debug SysSpecCurr
    If SysSpecTotal = 0
      MessageRequester("System","System does not have Minimum Requeseted memory. Program will not run.",#PB_MessageRequester_Error)
          Tolog$ = "System failed reccomended system spec."
           Logt("DetectSystem",Tolog$)
      End
    EndIf
    
    If SysSpecCurr = 0
      MessageRequester("System","System does not currently have enough memory to Run program. Try exiting some programs.",#PB_MessageRequester_Error)
                Tolog$ = "System does not have enough free memory."
           Logt("DetectSystem",Tolog$)
      End
    EndIf
    
    If SysSpecCurr = 3
      Result = MessageRequester("System","System is Low on memory. Are you sure you would like to continue running the program?",#PB_MessageRequester_Warning | #PB_MessageRequester_YesNo)
      Tolog$ = "System Low on memory."
           Logt("DetectSystem",Tolog$)
    If Result = #PB_MessageRequester_Yes
    Else
      End
      EndIf
    EndIf
    
    Tolog$ = "---Beginning of system exploration---"+Chr(12)
    Tolog$ = Tolog$+"CPU Name: "+CPUName()+Chr(12)
    Tolog$ = ToLog$+"CPU Cores:"+Str(CountCPUs(#PB_System_CPUs))+Chr(12)
    ToLog$ = "---End of system exploration---"
    Logt("DetectSystem",Tolog$)
    
    
    
    
    
    

EndProcedure

Procedure CreatePrettystuff()
  LoadImage(1,"favicon.ico")
  
  
EndProcedure

Procedure CleanShutDown()
  EnableGraphicalConsole(1)
  UseModule Proforma
  ClearConsole()
  PrintN("Please Wait...")
  SpillProforma()
  ClearConsole()
  PrintN("GoodBye.")
  Delay(1500)
  End
EndProcedure

Procedure ViewPackProcess()
  Input()
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
         InfoFormLen = Len(MsgCurr$)
         InfoPrvLen = Len(Watcher() \msg)
         InfoPrvLen+6
         InfoFormLen+6
         Diff.i = InfoFormLen-InfoPrvLen
         If Diff.i > 0
           InfoFormLen = InfoformLen+Diff
         EndIf
         
         Fill$ = Space(InfoFormLen)
         ConsoleLocate(0,curpos+2)
         Print(Fill$)
         ConsoleLocate(0,curpos+2)
         Print(InfoForm$)
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
  
    
      
          

    ;PrintN("Process: "+FileThreads() \ID)
    ;PrintN("Job: "+FileThreads() \Job +"Status: "+FileThreads() \Status)
    ;PrintN("Info: "+FileThreads() \Message)
    ;PrintN("")
  Wend
  ResetMap(FileThreads())
  If NextMapElement(FileThreads())
    ResetMap(FileThreads())
  Else
    PrintN("No Current Jobs Running.")
    PrintN("Press Esc. to exit.")
    UnlockMutex(ThreadStatMutex)
  EndIf
  UnlockMutex(ThreadStatMutex)
  Delay(36)
Wend

EndProcedure


Procedure Logt(Subsystem$,Text$)  ;Thread maker for Logs
    If logmode > 0 ;If the Log setting is not Null.
  *logmemory = AllocateMemory(StringByteLength(Subsystem$+": "+Text$)+16)
  PokeS(*logmemory,Subsystem$+": "+Text$)
  logtl = CreateThread(@Logfinal(),*logmemory)
EndIf

EndProcedure

Procedure Logfinal(*logmemory) ;Thread for Logging
  If logmode > 0
  tofile$ = PeekS(*logmemory) ; Get Data from Memory address passed to the thread.
  Date$ = FormatDate("%yy.%mm.%dd", Date()) ;  Get Date.
  Time$ = FormatDate("%hh:%ii:%ss", Date()) ; Get time.
  LockMutex(Log)                            ; Lock the mutex
  OpenFile(1,logdir+Date$+".log",#PB_File_Append) ; Open the Log file.
  WriteStringN(1,Time$+":"+tofile$)               ; Write data and Date and formatted time/
  CloseFile(1)   
  UnlockMutex(Log)
  FreeMemory(*logmemory)
  EndIf
EndProcedure

;-------------
;- Program side
;
; Make Proforma Instances
ProformaMakeInst("Database-Ini")
;
KeyboardMode.i = 2
OpenConsole("BackRoom-Net")
DetectSystem()
EnableGraphicalConsole(1)
ProformaS("Database-Ini")
If InitializeDatabase()
 Debug "1"
EndIf
ProformaE("Database-Ini")

ProformaMakeInst("Cipher-Gen")
ProformaS("Cipher-Gen")
GenerateKeySequence("Main")
ProformaE("Cipher-Gen")
*KeyMem = EncryptStorage("Main") \keymem

men:
EnableGraphicalConsole(1)
ClearConsole()
PrintN("Welcome to Backroom-Beta-1.0.0!")
PrintN(" ")
PrintN("Press 1 To create a new package")
PrintN("Press 2 To view current packaging processes")
PrintN("Press escape to exit")

Repeat
  msg$ = Inkey()
  If msg$ <> ""
    If msg$ = Chr(27)
      MessageRequester("BackRoom-Beta-1.0.0","User Hit Escape Key. Please Wait for shutdown.")
      CleanShutDown()
    EndIf
       If msg$ = Chr(49)
          SpredDir(EncryptStorage() \MasterMem, *keyMem)
          ClearConsole()
          Goto men
        EndIf
        If msg$ = Chr(50)
          ViewPackProcess()
          Goto men
        EndIf
        
  EndIf
  
  Delay(1)
Until Exit = 1








Input()





; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 20
; Folding = A9
; EnableThread
; EnableXP
; EnableUser
; EnableOnError
; Executable = Test.exe
; CompileSourceDirectory
; EnablePurifier
; EnableUnicode
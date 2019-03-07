DeclareModule ThreadBranch
  Structure tl
    Thread.i 
  EndStructure
  
  Structure ThrdJob
    ID.s
    Job.s
    Status.s
    Message.s
  EndStructure
  
  
  Declare SelfTest()
  Declare WaitThreadBranch()
  Declare WaitThreadBranchGraphical(Title$,EndDelay,WarningTime)
  Declare AddThreadMember(ThreadID)
  Declare ViewThreadProcess()
  Global NewMap ThreadMap.tl()
  ; -
  ; process threads here ___
  Global NewMap processThrds.ThrdJob()
  Global ThreadStatMutex = CreateMutex()
EndDeclareModule

Module ThreadBranch
Declare TestThread(var)
Global ThreadCount = 0
Global LastThreadCount = 0
Global LogCount = 0

;- >wait on threads utility
  Procedure AddThreadMember(ThreadID)
    If FindMapElement(ThreadMap(),Str(ThreadID))
      ProcedureReturn #False
    Else
      Debug ThreadID
      ThreadMap(Str(ThreadID))
      ThreadMap() \Thread = ThreadID
      ThreadCount = ThreadCount+1
    EndIf
  EndProcedure
  
  Procedure.i WaitThreadBranch()
    ResetMap(ThreadMap())
    While NextMapElement(ThreadMap())
      ThreadCheck = ThreadMap() \Thread
      If IsThread(ThreadCheck)
        ;Debug Str(ThreadCheck)+" Is Still Running!"
      Else
        Debug Str(ThreadCheck)+" Just Finished!"
        DeleteMapElement(ThreadMap(),Str(ThreadCheck))
        LastThreadCount = LastThreadCount+1
        EndIf
      Wend
      If LastThreadCount = ThreadCount
        ThreadCount = 0
        LastThreadCount = 0
        Progress = 100
      Else
        If LastThreadCount = LogCount.i
          ;Skip Calculation
        Else
        Done.d = LastThreadCount/ThreadCount
        Progress.i = Done.d*100
        EndIf
      EndIf
      ProcedureReturn Progress.i
    EndProcedure
    
  Procedure.i WaitThreadBranchGraphical(Title$,EndDelay,WarningTime)
      EnableGraphicalConsole(1)
      ClearConsole()
      ConX = 1
      ConY = 1 
      ConsoleColor(7,0)
      PrintN("Waiting On Job: "+Title$)
      Print("[")
      While Progress.i <> 100
        Delay(1)
        If WarningTime = CountingTime
          ConsoleLocate(0,2)
          ConsoleColor(12,0)
          Print("Warning: Threads May be Unresponsive - Press Escape To Stop Job")
          If Inkey() = Chr(27)
            ClearConsole()
            EnableGraphicalConsole(0)
            ProcedureReturn #False
          EndIf
        Else
          CountingTime = CountingTime+1
        EndIf
        
 
      ResetMap(ThreadMap())
    While NextMapElement(ThreadMap())
      ThreadCheck = ThreadMap() \Thread
      If IsThread(ThreadCheck)
        ;Debug Str(ThreadCheck)+" Is Still Running!"
      Else
        Debug Str(ThreadCheck)+" Just Finished!"
        DeleteMapElement(ThreadMap(),Str(ThreadCheck))
        LastThreadCount = LastThreadCount+1
        EndIf
      Wend
      If LastThreadCount = ThreadCount
        ThreadCount = 0
        LastThreadCount = 0
        Progress = 100
   
      Else
        If LastThreadCount = LogCount.i
          ;Skip Calculation
        Else
        Done.d = LastThreadCount/ThreadCount
        Progress.i = Done.d*100
        EndIf
      EndIf
      
      ConsoleColor(2,0)

      Select Progress.i
          
          Case 5
          ConsoleLocate(ConX,ConY)
            Print("=")
          
        Case 10
          ConsoleLocate(ConX,ConY)
          Print("==")
          
          Case 15
          ConsoleLocate(ConX,ConY)
            Print("===")
            
          Case 20
            ConsoleLocate(ConX,ConY)
            Print("====")
            
            Case 25
          ConsoleLocate(ConX,ConY)
            Print("=====")
            
           Case 30
            ConsoleLocate(ConX,ConY)
            Print("======")
            
            Case 35
          ConsoleLocate(ConX,ConY)
            Print("=======")
            
            Case 40
            ConsoleLocate(ConX,ConY)
            Print("=========")
            
            Case 45
          ConsoleLocate(ConX,ConY)
            Print("==========")
            
            Case 50
            ConsoleLocate(ConX,ConY)
            Print("===========")
            
            Case 55
          ConsoleLocate(ConX,ConY)
            Print("============")
            
            Case 60
            ConsoleLocate(ConX,ConY)
            Print("=============")
            
            Case 65
          ConsoleLocate(ConX,ConY)
            Print("==============")
            
            Case 70
            ConsoleLocate(ConX,ConY)
            Print("===============")
            
            Case 75
          ConsoleLocate(ConX,ConY)
            Print("================")
            
            Case 80
            ConsoleLocate(ConX,ConY)
            Print("=================")
            
            Case 85
          ConsoleLocate(ConX,ConY)
            Print("==================")
            
            Case 90
            ConsoleLocate(ConX,ConY)
            Print("===================")
            
            Case 95
          ConsoleLocate(ConX,ConY)
            Print("====================")
            
            Case 100
            ConsoleLocate(ConX,ConY)
            Print("=====================")
            ConsoleColor(7,0)
            Print("]")
            ConsoleColor(2,0)
            Print(" OK")
            ConsoleColor(7,0)
        EndSelect
        
      
      Wend
      Delay(EndDelay)
      ClearConsole()
      EnableGraphicalConsole(0)
      ProcedureReturn Progress
  EndProcedure
  
  Procedure SelfTest()
    OpenConsole()
    Repeat
      Thread = CreateThread(@TestThread(),67)
      Debug Str(Thread)+" Is was Created!"
      AddThreadMember(Thread)
      Delay(10)
      count = count + 1
    Until count = 8
  
 
      Prog = WaitThreadBranchGraphical("Waiting for self test...",1000,4000)
      Debug Prog
      
  EndProcedure
  
  Procedure TestThread(var)
    Repeat
      Count = Count + 1
    Until Count = 2000000
    Delay(Random(4000))
  EndProcedure
  
  ;- >Thread tracking utility
  
  Procedure ViewThreadProcess()
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
  While NextMapElement(processThrds()) 
    ProcessID$ = processThrds() \ID
    JobCurr$ = processThrds() \Job
    StatCurr$ = processThrds() \Status
    MsgCurr$ = processThrds() \Message
    
    ProIDlen = Len(ProcessID$)
    Joblen = Len(JobCurr$)
    Statlen = Len(StatCurr$)
    Msglen = Len(MsgCurr$)
    
    
    ProcessForm$ = "Process: "+processThrds() \ID
    JobForm$ = "Job: "+processThrds() \Job +"Status: "+processThrds() \Status
    InfoForm$ = "Info: "+processThrds() \Message
    
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
         If Not FindMapElement(processThrds(), ProcessID$)
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
  ResetMap(processThrds())
  If NextMapElement(processThrds())
    ResetMap(processThrds())
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

  Procedure.i updateThrdJob(Uniq_ID,Job$,Status$,Message$)
    If Uniq_ID = 0
      ProcedureReturn 0
    EndIf
    
    LockMutex(ThreadStatMutex)
    If FindMapElement(processThrds(),Str(Uniq_ID))
      If Job$ <> ""
        processThrds(Str(Uniq_ID)) \Job = Job$
      EndIf
      If Status$ <> ""
        processThrds(Str(Uniq_ID)) \Status = Status$
      EndIf
      If Message$ <> ""
        processThrds(Str(Uniq_ID)) \Message = Message$
      EndIf
      UnlockMutex(ThreadStatMutex)
      ProcedureReturn 1
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  Procedure.i newThrdJob(Uniq_ID,Job$,Status$,Message$)
    redo:
    If Uniq_ID = 0
      Uniq_ID = Random(999999,1)+Random(999999,1)
      LockMutex(ThreadStatMutex)
      ResetMap(processThrds())
      If FindMapElement(processThrds(),Str(Uniq_ID))
        Uniq_ID = 0
        Goto redo
      EndIf
      ResetMap(processThrds())
      UnlockMutex(ThreadStatMutex)
    EndIf
    
    LockMutex(ThreadStatMutex)
    processThrds(Str(Uniq_ID)) \ID = Str(Uniq_ID)
    processThrds() \Job = Job$
    processThrds() \Status = Status$
    UnlockMutex(ThreadStatMutex)
    
    ProcedureReturn Uniq_ID  
  EndProcedure
  
  Procedure.i closeThrdJob(Uniq_ID)
    LockMutex(ThreadStatMutex)
    If FindMapElement(processThrds(),Str(Uniq_ID))
      DeleteMapElement(processThrds(),Str(Uniq_ID))
      UnlockMutex(ThreadStatMutex)
      ProcedureReturn 1
    Else
      UnlockMutex(ThreadStatMutex)
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  

EndModule

;UseModule ThreadBranch
;SelfTest()


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 397
; FirstLine = 156
; Folding = Dq
; EnableXP
DeclareModule ThreadBranch
  Structure tl
    Thread.i 
  EndStructure
  Declare SelfTest()
  Declare WaitThreadBranch()
  Declare WaitThreadBranchGraphical(Title$,EndDelay,WarningTime)
  Declare AddThreadMember(ThreadID)
  Global NewMap ThreadMap.tl()
EndDeclareModule

Module ThreadBranch
Declare TestThread(var)
Global ThreadCount = 0
Global LastThreadCount = 0
Global LogCount = 0
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
          Print("Warning: Threads My be Unresponsive - Press Escape To Stop Job")
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
  
 
      Prog = WaitThreadBranchGraphical("Waiting for self test...",1000,2000)
      Debug Prog
    Input()
      
  EndProcedure
  
  Procedure TestThread(var)
    Repeat
      Count = Count + 1
    Until Count = 2000000
    Delay(Random(4000))
  EndProcedure
  
  
EndModule

UseModule ThreadBranch
SelfTest()


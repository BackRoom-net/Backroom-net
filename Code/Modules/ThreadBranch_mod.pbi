DeclareModule ThreadBranch
  Structure tl
    Thread.i 
  EndStructure
  Declare SelfTest()
  Declare WaitThreadBranch()
  Declare WaitThreadBranchGraphical(Title$)
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
    
    Procedure.i WaitThreadBranchGraphical(Title$)
      EnableGraphicalConsole(1)
      ClearConsole()
      ConX = 1
      ConY = 1 
      PrintN("Waiting On Job: "+Title$)
      Print("[")
      ConsoleLocate(ConX,ConY)
      ConsoleColor(2,0)
      While Progress.i <> 100
      ResetMap(ThreadMap())
    While NextMapElement(ThreadMap())
      ThreadCheck = ThreadMap() \Thread
      If IsThread(ThreadCheck)
        ;Debug Str(ThreadCheck)+" Is Still Running!"
      Else
        ;Debug Str(ThreadCheck)+" Just Finished!"
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
      
      
      
      
      
      
      
      
      
      
      
      
      Wend
      
      Input()
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
    Until count = 10
  
    Repeat 
      Input()
      Prog = WaitThreadBranchGraphical("Calculation finish")
      Debug Prog
    Until Prog = 100
    Input()
      
  EndProcedure
  
  Procedure TestThread(var)
    Repeat
      Count = Count + 1
    Until Count = 2000000
  EndProcedure
  
  
EndModule

UseModule ThreadBranch
SelfTest()

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 89
; FirstLine = 58
; Folding = --
; EnableThread
; EnableXP
DeclareModule ThreadBranch
  Structure tl
    Thread.i 
  EndStructure
  
  Global NewMap ThreadMap.tl()
EndDeclareModule

Module ThreadBranch
Global ThreadCount = 0
Global LastThreadCount = 0
  Procedure AddThreadMember(ThreadID)
    If FindMapElement(ThreadMap(),Str(ThreadID))
      ProcedureReturn #False
    Else
      ThreadMap(Str(ThreadID))
    EndIf
  EndProcedure
  
  Procedure WaitThreadBranch()
    ResetMap(ThreadMap())
    While NextMapElement(ThreadMap())
      ThreadCheck = ThreadMap() \Thread
      If IsThread(ThreadCheck)
      Else
        DeleteMapElement(ThreadMap(),Str(ThreadCheck))
        LastThreadCount = LastThreadCount+1
        Done.d = LastThreadCount/ThreadCount
        Progress.i = Done.d*100
      Wend
  EndProcedure
  
  
EndModule

  
; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 29
; Folding = -
; EnableXP
EnableExplicit

DeclareModule Log
  Declare AddMsg(msg.s)
  Declare DumpToFile()
EndDeclareModule

Module Log
  
  Global mutex=CreateMutex()
  Global NewList messages.s()
  
  Procedure AddMsg(msg.s)
    LockMutex(mutex)
    LastElement(messages())
    If AddElement(messages())
      messages()=msg.s
    EndIf
    UnlockMutex(mutex)
  EndProcedure
  
  Procedure DumpToFile()
    CompilerIf #PB_Compiler_Debugger
      LockMutex(mutex)
      ResetList(messages())
      Debug "-----"
      Debug "WRITE LOG CONTENTS TO FILE:"
      ForEach messages()
        Debug messages()
      Next
      Debug "-----"
      UnlockMutex(mutex)
      ProcedureReturn
    CompilerEndIf
    
    Protected f=CreateFile(#PB_Any,"log.txt")
    If f=0
      ProcedureReturn
    EndIf
    LockMutex(mutex)
    ResetList(messages())
    ForEach messages()
      If WriteStringN(f,messages())=0
        Break
      EndIf
    Next
    UnlockMutex(mutex)
    CloseFile(f)
    ProcedureReturn
  EndProcedure
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 50
; Folding = g
; EnableXP
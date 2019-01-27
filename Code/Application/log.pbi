

DeclareModule Log
  Declare AddMsg(msg.s)
  Declare DumpToFile()
  Declare GenLogadd(Unique$,type$,message$,from$)
  Declare loggingthread(Nullval)
;   Declare NonThreadLogging(Unique$,type$,message$,from$)
EndDeclareModule

Module Log
  
Structure maplog
  type.s
  message.s
  from.s
EndStructure
  Global mutex=CreateMutex()
  Global NewList messages.s()
  Global NewMap Logging.maplog()
  Global Log = CreateMutex()
  Global Unique$, type$, message$, from$
  Global threadnumberlogging
    Global LogThread = CreateMutex()
  
  Procedure GenLogadd(Unique$,type$,message$,from$)
;   If Prefs::retPrefI("LogThreadSync") 
;     Switch = Prefs::retPrefI("LogThreadSync")
;     If Switch = 1
;       Sync = 1
;       NonRet = 1
;     Else
;       Sync = 0
;       NonRet = 1
;     EndIf
;   Else
;     Sync = 0
;     NonRet = 1
;   EndIf
;   
;   If Sync = 0
    LockMutex(Log)
    ResetMap(Logging())
  Logging(Unique$) \from = from$
  Logging(Unique$) \message = message$
  Logging(Unique$) \type = type$
  If IsThread(threadnumberlogging)
  Else
    threadnumberlogging = CreateThread(@Loggingthread(),0)
  EndIf
  UnlockMutex(log)
; ElseIf Sync = 1
;   NonThreadLogging(Unique$,type$,message$,from$)
; EndIf

EndProcedure

Procedure Loggingthread(Nullval)
  Date$ = FormatDate("%yy.%mm.%dd", Date())
  LockMutex(Log)
  If OpenFile(1,Date$+".log",#PB_File_Append)
    CloseFile(1)
    main:
    While NextMapElement(Logging())
      OpenFile(1,Date$+".log",#PB_File_Append)
      Type$ = Logging() \type
      message$ = Logging() \message
      Moddule$ = Logging() \from
  Date$ = FormatDate("%yy.%mm.%dd", Date()) 
  Time$ = FormatDate("%hh:%ii:%ss", Date()) 
  If Type$ = "THREAD"
    OpenFile(2,Date$+"_Thread"+".log",#PB_File_Append)
    WriteStringN(2,Time$+": "+Moddule$+">"+Type$+": "+message$)  
    CloseFile(2)
    Else
      WriteStringN(1,Time$+": "+Moddule$+">"+Type$+": "+message$)   
    EndIf
    CloseFile(1)
  DeleteMapElement(Logging())
Wend
ResetMap(Logging())
UnlockMutex(Log)
Delay(50)
Goto main
Else
  MessageRequester("Internal Error","Could not read Log file. Please check if other applications are using it. Logging will be resumed as soon as the File is freed.")
  Repeat 
    Status = OpenFile(1,Date$+".log",#PB_File_Append)
    Delay(500)
    CloseFile(1)
  Until Status = #True
EndIf
EndProcedure
  
; Procedure NonThreadLogging(Unique$,type$,message$,from$)
;     Date$ = FormatDate("%yy.%mm.%dd", Date())
;   If OpenFile(1,Date$+".log",#PB_File_Append)
;     CloseFile(1)
;     LockMutex(log)
;       OpenFile(1,Date$+".log",#PB_File_Append)
;   Date$ = FormatDate("%yy.%mm.%dd", Date()) 
;   Time$ = FormatDate("%hh:%ii:%ss", Date()) 
;   WriteStringN(1,Time$+": "+from$+">"+type$+": "+message$)               
;   CloseFile(1) 
; 
; UnlockMutex(log)
; Delay(500)
; Goto main
; Else
;   MessageRequester("Internal Error","Could not read Log file. Please check if other applications are using it. Logging will be resumed as soon as the File is freed.")
;   MessageRequester("Internal Message","Application frozen because of Log file. (Log Thread Synchronization is enabled.)")
;   Repeat 
;     Status = OpenFile(1,Date$+".log",#PB_File_Append)
;     Delay(500)
;   Until Status = #True
; EndIf
; EndProcedure

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
; CursorPosition = 86
; FirstLine = 55
; Folding = P+
; EnableXP
; Executable = Backroom-net.exe
; CPU = 1
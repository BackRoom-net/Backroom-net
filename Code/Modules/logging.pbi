EnableExplicit

DeclareModule log
  Structure maplog
  type.s
  message.s
  from.s
EndStructure
  Declare GenLogadd(Unique$,type$,message$,from$)
  Declare loggingthread()
  Global NewMap Logging.maplog()
  Global Log = CreateMutex()
  Global Unique$, type$, message$, from$
  Global threadnumberlogging
EndDeclareModule


Module log
  
Procedure GenLogadd(Unique$,type$,message$,from$)
  LockMutex(Log)
  Logging(Unique$) \from = from$
  Logging() \message = message$
  Logging() \type = type$
  UnlockMutex(log)
  If IsThread(threadnumberlogging)
  Else
    threadnumberlogging = CreateThread(@Loggingthread(),0)
  EndIf
EndProcedure

Procedure Loggingthread()
  Date$ = FormatDate("%yy.%mm.%dd", Date())
  If OpenFile(1,Date$+".log",#PB_File_Append)
    CloseFile(1)
    main:
    LockMutex(log)
    While NextMapElement(Logging())
      OpenFile(1,Date$+".log",#PB_File_Append)
      Type$ = Logging() \type
      message$ = Logging() \message
      Moddule$ = Logging() \from
  Date$ = FormatDate("%yy.%mm.%dd", Date()) 
  Time$ = FormatDate("%hh:%ii:%ss", Date()) 
  WriteStringN(1,Time$+": "+Moddule$+">"+Type$+": "+message$)               
  CloseFile(1) 
  DeleteMapElement(Logging())
Wend
ResetMap(Logging())
UnlockMutex(log)
Delay(500)
Goto main
Else
  MessageRequester("Internal Error","Could not read Log file. Please check if other applications are using it. Logging will be resumed as soon as the File is freed.")
  Repeat 
    Status = OpenFile(1,Date$+".log",#PB_File_Append)
    Delay(500)
  Until Status = #True
EndIf
EndProcedure
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 17
; Folding = 4
; EnableXP
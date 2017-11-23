CompilerIf #PB_Compiler_Thread <> 1
  CompilerError "Use Compiler option - Threadsafe!"
CompilerEndIf

DeclareModule SQLDatabase
  Global db = CreateMutex()
  Global Log = CreateMutex()
  Global Logmode.i
  Global Logdir.s
  Declare initLogging(Setting,Directory$)
 

EndDeclareModule



Module SQLDatabase
  Declare Logfinal(*Logmemory)
  Declare Logt(Subsystem$,Text$)
  
  Procedure initLogging(Setting,Directory$)

    If Setting
      If Directory$ = "" Or Directory$ = " "
        Directory$ = GetCurrentDirectory()
        rez.q = FileSize(Directory$)
        If rez.q = -2
          Logdir.s = Directory$
          If setting 
            Debug Directory$ 
            Debug Logdir
            Debug rez.q
            Goto set
          EndIf
        Else
          MessageRequester("Error:Database_mod-Logging","Directory Bad.")
          ProcedureReturn #False
          End
        EndIf
      Else
        set:
        If FileSize(Logdir+"Sqlog.log") = -1
          CreateFile(1,Logdir+"Sqlog.log")
        Else
          Debug FileSize(Logdir+"Sqlog.log")
        EndIf
      Select Setting
        Case 1
          Logmode.i = 1 ;general
          Logt("InitLogging","Logging set to 1")
          ProcedureReturn #True
        Case 2
          Logmode.i = 2 ;extended
          ProcedureReturn #True
        Case 3
          Logmode.i = 3 ;Only on error
          ProcedureReturn #True
      EndSelect
    EndIf
  Else
    Logmode.i = 0
    ProcedureReturn #True
  EndIf
  EndProcedure
  
  Procedure Logt(Subsystem$,Text$)
    Debug "Logt------"
  *logmemory = AllocateMemory(StringByteLength(Subsystem$+": "+Text$))
  Debug PokeS(*logmemory,Subsystem$+": "+Text$)
  Debug *logmemory
  Debug "thread----"
  logtl = CreateThread(@Logfinal(),*logmemory)
  WaitThread(logtl)
  Debug PeekS(*logmemory)
EndProcedure

Procedure Logfinal(*logmemory)
  tofile$ = PeekS(*logmemory)
  Debug tofile$
  
  
  Date$ = FormatDate("%yy.%mm.%dd", Date())
  Time$ = FormatDate("%hh:%ii:%ss", Date())
  
  LockMutex(Log)
  Debug OpenFile(1,logdir+Date$+".log",#PB_File_Append)
  Debug Logdir
  WriteStringN(1,Time$+":"+tofile$)
  CloseFile(1)
  UnlockMutex(Log)
  ReAllocateMemory(*logmemory,12)
  PokeS(*Logmemory,"1")
EndProcedure
  
  
  
EndModule

; IDE Options = PureBasic 5.60 (Windows - x64)
; CursorPosition = 89
; FirstLine = 63
; Folding = --
; EnableXP
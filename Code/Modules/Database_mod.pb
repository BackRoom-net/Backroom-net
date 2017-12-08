; CompilerIf #PB_Compiler_Thread <> 1
;   CompilerError "Use Compiler option - Threadsafe!"
; CompilerEndIf

DeclareModule SQLDatabase
  UseSQLiteDatabase()
  Global db = CreateMutex()
  Global Log = CreateMutex()
  Global Logmode.i
  Global Logdir.s
  Declare initLogging(Setting,Directory$)
  Declare.i initdatabase(database,Name$)
 

EndDeclareModule



Module SQLDatabase
  Declare Logfinal(*Logmemory)
  Declare Logt(Subsystem$,Text$)
  ;------------------------------------
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

      Select Setting
        Case 1
          Logmode.i = 1 ;general
          Logt("InitLogging","Logging set to 1")
          ProcedureReturn #True
        Case 2
          Logmode.i = 2 ;extended
          Logt("InitLogging","Logging set to 2")
          ProcedureReturn #True
        Case 3
          Logmode.i = 3 ;Only on error
          Logt("InitLogging","Logging set to error only.")
          ProcedureReturn #True
      EndSelect
    EndIf
  Else
    Logmode.i = 0
    ProcedureReturn #True
  EndIf
  EndProcedure
  
Procedure Logt(Subsystem$,Text$)
    If logmode > 0
  *logmemory = AllocateMemory(StringByteLength(Subsystem$+": "+Text$))
  PokeS(*logmemory,Subsystem$+": "+Text$)
  logtl = CreateThread(@Logfinal(),*logmemory)
   WaitThread(logtl)
   Debug "Done"
  ;Logfinal(*logmemory)
EndIf

EndProcedure

Procedure Logfinal(*logmemory)
  If logmode > 0
  tofile$ = PeekS(*logmemory)
  Date$ = FormatDate("%yy.%mm.%dd", Date())
  Time$ = FormatDate("%hh:%ii:%ss", Date())
  LockMutex(Log)
  OpenFile(1,logdir+Date$+".log",#PB_File_Append)
  WriteStringN(1,Time$+":"+tofile$)
  CloseFile(1)
  UnlockMutex(Log)
  FreeMemory(*logmemory)
  EndIf
EndProcedure
;------------------------------------
Procedure.i initdatabase(database,Name$)
 If Name$ = ":memory:"
   If OpenDatabase(database,Name$, "", "")
     If DatabaseUpdate(database, "CREATE TABLE info (test VARCHAR(255));")
       Debug "Memory table created"
    EndIf
  Else
    ProcedureReturn #False
  EndIf
  Else
  If CreateFile(0,Name$)
    CloseFile(0)
  EndIf 
  If OpenDatabase(database,Name$, "", "")
    If DatabaseUpdate(database, "CREATE TABLE info (test VARCHAR(255));")
    EndIf
  Else
    ProcedureReturn #False
  EndIf
EndIf

ProcedureReturn #True
EndProcedure

  
EndModule




; IDE Options = PureBasic 5.60 (Windows - x64)
; CursorPosition = 95
; FirstLine = 42
; Folding = u-
; EnableThread
; EnableXP
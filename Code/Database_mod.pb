CompilerIf #PB_Compiler_Thread <> 1
  CompilerError "Use Compiler option - Threadsafe!"
CompilerEndIf

DeclareModule SQLDatabase
  Global db = CreateMutex()
  Declare initLogging(Setting,[Directory$])
  Declare Logging(system$,stat$,msg$)

EndDeclareModule



Module SQLDatabase
  Global Logmode.i
  Global Logdir.s
  
  
  Procedure initLogging(Setting,[Directory$]
    If Setting
      If Directory$ = "" Or Directory$ = " "
        Directory$ = GetCurrentDirectory()
        rez.q = FileSize(Directory$)
        If rez.q = -2
          Logdir.s = Directory$
          ProcedureReturn #True
        Else
          MessageRequester("Error:Database_mod-Logging","Directory Bad.")
          ProcedureReturn #False
          End
        EndIf
      Else
      Select Setting
        Case 1
          Logmode.i = 1 ;general
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
  
  Procedure Logging(system$,stat$,msg$)
    
  EndProcedure
  
  
  
EndModule

; IDE Options = PureBasic 5.60 (Windows - x64)
; CursorPosition = 53
; Folding = -
; EnableXP
 CompilerIf #PB_Compiler_Thread <> 1
   CompilerError "Use Compiler option - Threadsafe!"
 CompilerEndIf

DeclareModule SQLDatabase  
  UseSQLiteDatabase()                      ;If Called more then Two times causes Memory access Violation.
  Global Log = CreateMutex()
  Global Logmode.i
  Global Logdir.s
  Global SQLAccess = CreateMutex()
  Declare initLogging(Setting,Directory$)
  Declare.i initdatabase(database,Name$)

EndDeclareModule

Module SQLDatabase
  Declare Logfinal(*Logmemory)
  Declare Logt(Subsystem$,Text$)
  ;------------------------------------
Procedure initLogging(Setting,Directory$)     ;Creates Log For MySql.

    If Setting                                ;Check Setting
      If Directory$ = "" Or Directory$ = " "  ;If no Directory is specified
        Directory$ = GetCurrentDirectory()    ;Get the current Directory.
        rez.q = FileSize(Directory$)          ;Check if its not a file. (For Protection)
        If rez.q = -2                         ;If its not a File,
          Logdir.s = Directory$               ;Set the Log Dir.
          If setting                          ;Check the Setting once again,
            Debug Directory$                  ;Debug like everything.
            Debug Logdir
            Debug rez.q
            Goto set
          EndIf
        Else
          MessageRequester("Error:Database_mod-Logging","Directory Bad.") ;If the directory does not work for some reason, Error.
          ProcedureReturn #False
          End
        EndIf
      Else
        set:

      Select Setting ;Select Setting
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
  
Procedure Logt(Subsystem$,Text$)  ;Thread maker for Logs
    If logmode > 0 ;If the Log setting is not Null.
  *logmemory = AllocateMemory(StringByteLength(Subsystem$+": "+Text$))
  PokeS(*logmemory,Subsystem$+": "+Text$)
  logtl = CreateThread(@Logfinal(),*logmemory)
EndIf

EndProcedure

Procedure Logfinal(*logmemory) ;Thread for Logging
  If logmode > 0
  tofile$ = PeekS(*logmemory) ; Get Data from Memory address passed to the thread.
  Date$ = FormatDate("%yy.%mm.%dd", Date()) ;  Get Date.
  Time$ = FormatDate("%hh:%ii:%ss", Date()) ; Get time.
  LockMutex(Log)                            ; Lock the mutex
  OpenFile(1,logdir+Date$+".log",#PB_File_Append) ; Open the Log file.
  WriteStringN(1,Time$+":"+tofile$)               ; Write data and Date and formatted time/
  CloseFile(1)   
  UnlockMutex(Log)
  FreeMemory(*logmemory)
  EndIf
EndProcedure
;------------------------------------
Procedure.i initdatabase(database,Name$) ;Creates A database.
 If Name$ = ":memory:"  ;Checks if the Application wants to make a database in memory for some odd reason.
   If OpenDatabase(database,Name$, "", "") ;Just open the database.
     If DatabaseUpdate(database, "CREATE TABLE info (test VARCHAR(255));") ; Test writing to the database.
       ;Debug "Memory table created"
       Logt("Database_mod-InitDatabase","Opened Database Successfully: "+Name$)
       Else
       Logt("Database_mod-InitDatabase","Failed to open database: "+Name$)
    EndIf
  Else
    ProcedureReturn #False
  EndIf
Else
  If FileSize(Name$) = -1
  If CreateFile(0,Name$)
    Logt("Database_mod-InitDatabase","Created Database File: "+Name$)
    CloseFile(0)
  EndIf 
Else
  Logt("Database_mod-InitDatabase","Found Database File: "+Name$)
EndIf
  If OpenDatabase(database,Name$, "", "")
    If DatabaseUpdate(database, "CREATE TABLE info (test VARCHAR(255));")
    Logt("Database_mod-InitDatabase","Opened Database File: "+Name$)
    EndIf
  Else
    ProcedureReturn #False
  EndIf
EndIf

ProcedureReturn #True
EndProcedure

Procedure.i iniopendatabase(Database,Name$)
EndProcedure

EndModule

DeclareModule SQFormat
  Global Str$
  Global SQLT = CreateMutex()
  Global CommitMutex_Database = CreateMutex()
  Declare.s SQFCreateTable(Str$,Name$)
  Declare.s SQFMakeField(Str$,Name$,Type,Notnull,PK,AI,Unique,Comma)
  Declare.s SQFOpen(Str$)
  Declare.s SQFClose(Str$)
  Declare.i SQLCommit(Database,Str$)
  Declare.s SQLInsert(Str$,Table$,Column_s$,Value_s$,Close)
EndDeclareModule

Module SQFormat
  Structure Strcu
    IntoDb.s
    dbnumb.i
  EndStructure
  
  Global Str$
  Declare SQLDbUpdate(UdbNumb)
  Declare Logfinal(*Logmemory)
  Declare Logt(Subsystem$,Text$)
  Global NewMap CommitThread.Strcu()
  
  ;-------- Table Functions
  Procedure.s SQFCreateTable(Str$,Name$)
    SQLForm$ = "CREATE TABLE "
    Str$ = SQLForm$+"'"+Name$+"'"
    ProcedureReturn Str$
  EndProcedure
  
  Procedure.s SQFMakeField(Str$,Name$,Type,Notnull,PK,AI,Unique,Comma)
    Select type
      Case 1
        SQT$ = "INTEGER"
      Case 2
        SQT$ = "TEXT"
      Case 3
        SQT$ = "BLOB"
      Case 4
        SQT$ = "REAL"
      Case 5
        SQT$ = "NUMERIC"
    EndSelect
    SQMatt$ = "'"+Name$+"' "+SQT$+" "
    If Notnull = 1
      SQMatt$ = SQMatt$+"NOT NULL "
    EndIf  
   If PK = 1 And AI = 1
      SQmatt$ = SQMatt$+"PRIMARY KEY AUTOINCREMENT "
    Else
    If PK = 1
      SQmatt$ = SQMatt$+"PRIMARY KEY "
    ElseIf AI = 1
      SQmatt$ = SQMatt$+"PRIMARY KEY AUTOINCREMENT "
    EndIf
  EndIf
  Str$ = Str$+Chr(10)+SQmatt$
  If comma = 1
    Str$ = Str$ + ","
  EndIf
  ProcedureReturn Str$  
  LogDebug$ = "SQL Formatted:"+Chr(32)
  LogDebug$ = LogDebug$ + "Table Type:"+SQT$+Chr(32)
  LogDebug$ = LogDebug$ + "Table Name:"+Name$+Chr(32)
  LogDebug$ = LogDebug$ + "NotNull:"+Str(NotNull)+Chr(32)
  LogDebug$ = LogDebug$ + "Primary Key:"+Str(PK)+Chr(32)
  LogDebug$ = LogDebug$ + "Comma Added:"+Str(Comma)
  Logt("Database_mod-SQLFormatter",LogDebug$)
  EndProcedure
  
  Procedure.s SQFOpen(Str$)
    Str$ = Str$+" ("
    ProcedureReturn Str$
  EndProcedure
  
  Procedure.s SQFClose(Str$)
    Str$ = Str$+Chr(10)+");"
    ProcedureReturn Str$
  EndProcedure
  
  Procedure.i SQLCommit(Database,Str$)
    UdbNumb = Random(99999,0)
    While FindMapElement(CommitThread(),Str(UdbNumb))
      Delay(12)
      UdbNumb = Random(99999,0)
    Wend
    LockMutex(CommitMutex_Database)
    CommitThread(Str(UdbNumb))
    CommitThread() \dbnumb = Database
    CommitThread() \IntoDb = Str$
    UnlockMutex(CommitMutex_Database)
    Delay(1)
    Thread = CreateThread(@SQLDbUpdate(),UdbNumb)
    Str$ = ""
      ProcedureReturn Thread
  EndProcedure
  
  Procedure SQLDbUpdate(UdbNumb)
    LockMutex(CommitMutex_Database)
    CommitThread(Str(UdbNumb))
    Db = CommitThread() \dbnumb
    Dbc$ = CommitThread() \IntoDb
    DeleteMapElement(CommitThread(),Str(UdbNumb))
    UnlockMutex(CommitMutex_Database)
    LockMutex(SQLT)
    stat = DatabaseUpdate(Db,Dbc$)
    UnlockMutex(SQLT)
  EndProcedure
  ;-------- Table Functions
  ;-------- Input Functions
  Procedure.s SQLInsert(Str$,Table$,Column_s$,Value_s$,Close)
    Str$ = Str$+"INSERT INTO "+Table$+" ("+Column_s$+") VALUES ("+Value_s$+")"
    If Close = 1
      Str$ = Str$+";"
    Else
      Str$ = Str$+","+Chr(10)
    EndIf
    ProcedureReturn Str$
  EndProcedure
  
 Procedure Logt(Subsystem$,Text$)  ;Thread maker for Logs
    If logmode > 0 ;If the Log setting is not Null.
  *logmemory = AllocateMemory(StringByteLength(Subsystem$+": "+Text$))
  PokeS(*logmemory,Subsystem$+": "+Text$)
  logtl = CreateThread(@Logfinal(),*logmemory)
EndIf

EndProcedure

Procedure Logfinal(*logmemory) ;Thread for Logging
  If logmode > 0
  tofile$ = PeekS(*logmemory) ; Get Data from Memory address passed to the thread.
  Date$ = FormatDate("%yy.%mm.%dd", Date()) ;  Get Date.
  Time$ = FormatDate("%hh:%ii:%ss", Date()) ; Get time.
  LockMutex(Log)                            ; Lock the mutex
  OpenFile(1,logdir$+Date$+".log",#PB_File_Append) ; Open the Log file.
  WriteStringN(1,Time$+":"+tofile$)               ; Write data and Date and formatted time/
  CloseFile(1)   
  UnlockMutex(Log)
  FreeMemory(*logmemory)
  EndIf
EndProcedure

  
EndModule

DeclareModule SQuery
  Declare.s SQLQuerySelect(Database,Columns$,Table$,Column, List Output.s())
  Declare.s SQLQuerySelectWhere(Database,Columns$,Table$,WhereRow$,WhereValue$,Column, List Output.s())
EndDeclareModule

Module SQuery
  
  Procedure.s SQLQuerySelect(Database,Columns$,Table$,Column, List Output.s())
   Debug DatabaseQuery(Database,"SELECT "+Columns$+" FROM "+Table$+";")
    While NextDatabaseRow(Database)
      gotdat$ = GetDatabaseString(Database,Column)
      AddElement(Output())
      Output() = gotdat$
      Wend
      ProcedureReturn gotdat$
    EndProcedure
    
  
    Procedure.s SQLQuerySelectWhere(Database,Columns$,Table$,WhereRow$,WhereValue$,Column, List Output.s())
    DatabaseQuery(Database,"SELECT "+Columns$+" FROM "+Table$+" WHERE "+WhereRow$+"="+WhereValue$+";")
    While NextDatabaseRow(Database)
      gotdat$ = GetDatabaseString(Database,Column)
      AddElement(Output())
      Output() = gotdat$
      Wend
      ProcedureReturn gotdat$
  EndProcedure


EndModule












; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 104
; FirstLine = 82
; Folding = -PO0
; EnableThread
; EnableXP
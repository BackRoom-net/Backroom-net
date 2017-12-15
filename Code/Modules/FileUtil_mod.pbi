DeclareModule SQLDatabase
  UseSQLiteDatabase()
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

DeclareModule SQFormat
  Global Str$
  Global SQLT = CreateMutex()
  Declare.s SQFCreateTable(Str$,Name$)
  Declare.s SQFMakeField(Str$,Name$,Type,Notnull,PK,AI,Unique,Comma)
  Declare.s SQFOpen(Str$)
  Declare.s SQFClose(Str$)
  Declare.i SQLCommit(Database,Str$)
EndDeclareModule

Module SQFormat
  Global Str$
  Declare SqlDbUpdate(*DbMem)
  
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
    ByteLen = StringByteLength(Str$+"/*/-^#*"+Str(Database))
    Str$ = Str$+"/*/-^#*"+Str(Database)
    *DbMem = AllocateMemory(500)
    PokeS(*DbMem,Str$)
    Thread = CreateThread(@SQLDbUpdate(),*Dbmem)
    ProcedureReturn Thread
  EndProcedure
  
  Procedure SQLDbUpdate(*DbMem)
    LockMutex(SQLT)
    Str$ = PeekS(*Dbmem)
    Dbc$ = StringField(Str$,1,"/*/-^#*")
    Db$ = StringField(Str$,2,"/*/-^#*")
    stat = DatabaseUpdate(Val(Db$),Dbc$)
    FreeMemory(*DbMem)
    UnlockMutex(SQLT)
  EndProcedure
  
EndModule





DeclareModule FileUtil
  CreateDirectory("FileSpreadTmp")
  Declare SpredFile(File$)
EndDeclareModule

Module FileUtil
  UseModule SQLDatabase
  UseModule SQFormat
  Procedure SpredFile(File$)
    
    Initdatabase(1,"FileSpreadTmp\Info.db")
    Command$ = SQFCreatetable(Command$,"Files")
    Command$ = SQFOpen(Command$)
    Command$ = SQFMakefield(Command$,"Part",1,1,0,0,0,1)
    Command$ = SQFmakefield(Command$,"FileName",2,1,0,0,0,0)
    Command$ = SQFClose(Command$)
    CommThread = SQLCommit(1,Command$)
    Debug command$
    Debug CommThread
    
    
    
    
    
    
Size.i = 1024*4000
Debug Size.i
;--------------
OpenFile(0,File$)
FileSize.i = Lof(0)
Parts.d = Filesize.i/Size.i
;---------------
Debug Size.i
Debug Parts.d
Debug Round(Parts.d,#PB_Round_Up)
Parts = Round(Parts.d,#PB_Round_Up)
Debug filesize.i
;---------------
*Split = AllocateMemory(Size.i)
WaitThread(CommThread)
redo:
Repeat
  TmpFile$ = "FileSpreadTmp\"+Str(Random(9999999,0))
  If FileSize(TmpFile$) <> -1
    Goto redo
  Else
 If OpenFile(2,TmpFile$)
    Actread = ReadData(0,*Split,Size.i)
    WriteData(2,*Split,Actread)
    Partcount = Partcount+1
    CloseFile(2)
    FillMemory(*Split,Size.i)
 Else
 MessageRequester("Error","Could not read data from file")
 End
EndIf
EndIf

Until Eof(0)
FreeMemory(*Split)

    
    
  EndProcedure
  
  
  
  
  
  
EndModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 234
; FirstLine = 21
; Folding = 998
; EnableXP
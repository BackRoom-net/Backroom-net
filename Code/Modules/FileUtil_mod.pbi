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
  Declare.s SQLInsert(Str$,Table$,Column_s$,Value_s$,Close)
EndDeclareModule

Module SQFormat
  Global Str$
  Declare SQLDbUpdate(*DbMem)
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
    *DbMem = AllocateMemory(ByteLen)
    PokeS(*DbMem,Str$)
    Thread = CreateThread(@SQLDbUpdate(),*Dbmem)
    Str$ = ""
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
  
  
EndModule

DeclareModule SQuery

EndDeclareModule

Module SQuery
  
  Procedure.s SQLQuerySelect(Database,Columns$,Table$,Column)
    DatabaseQuery(0,"SELECT "+Columns$+" FROM "+Table$+";")
    While NextDatabaseRow(0)
        gotdat$ = GetDatabaseString(Database,Column)
      Wend
      ProcedureReturn gotdat$
    EndProcedure
    
  
    Procedure.s SQLQuerySelectWhere(Database,Columns$,Table$,WhereRow$,WhereValue$,Column)
    DatabaseQuery(0,"SELECT "+Columns$+" FROM "+Table$+" WHERE "+WhereRow$+"="+WhereValue$+";")
    While NextDatabaseRow(0)
        gotdat$ = GetDatabaseString(Database,Column)
      Wend
      ProcedureReturn gotdat$
  EndProcedure


EndModule

;---------------
;---------------
;---------------



DeclareModule FileUtil
  CreateDirectory("FileTmp")
  Declare SpredFile(File$,*AESKey,*IniVector)
EndDeclareModule

Module FileUtil
  UseModule SQLDatabase
  UseModule SQFormat
  Procedure SpredFile(File$,*AESKey,*IniVector)
    UseCRC32Fingerprint()
    UseSHA3Fingerprint()
    UseZipPacker()
    Initdatabase(1,"FileTmp\Info.db")
    Command$ = SQFCreatetable(Command$,"Files")
    Command$ = SQFOpen(Command$)
    Command$ = SQFMakefield(Command$,"Part",1,1,0,0,0,1)
    Command$ = SQFmakefield(Command$,"FileName",2,1,0,0,0,1)
    Command$ = SQFMakeField(Command$,"IsCompressed",1,1,0,0,0,1)
    Command$ = SQFmakeField(Command$,"Checksum",2,1,0,0,0,0)
    Command$ = SQFClose(Command$)
    CommThread = SQLCommit(1,Command$)
    Debug command$
    Debug CommThread
    
  
Size.i = 1024*4000
Debug Size.i
; --------------
OpenFile(0,File$)
FileSize.i = Lof(0)
Parts.d = Filesize.i/Size.i
; ---------------
Debug Size.i
Debug Parts.d
Debug Round(Parts.d,#PB_Round_Up)
Parts = Round(Parts.d,#PB_Round_Up)
Debug filesize.i


WaitThread(CommThread)
redo:
Repeat
  *Split = AllocateMemory(Size.i)
  Actread = ReadData(0,*Split,Size.i)
  FileFinger$ = Fingerprint(*Split,Actread,#PB_Cipher_CRC32)
  CheckSum$ = Fingerprint(*Split,ActRead,#PB_Cipher_SHA3)
  If FileSize(FileFinger$) = -1
    *Encoded = AllocateMemory(Actread+32)
    *Compressed = AllocateMemory(Actread+32)
    OpenFile(2,"FileTmp\"+FileFinger$)
    Compdata = CompressMemory(*Split,Actread+32,*Compressed,Actread+32,#PB_PackerPlugin_Zip,9)
    If Compdata = 0
      Compdata = AESEncoder(*Split,*Encoded,Actread,*AESKey,256,*IniVector)
    Else
      Compressed = 1
     AESEncoder(*Compressed,*Encoded,Actread,*AESKey,256,*IniVector)
   EndIf
   
    
    WriteData(2,*Encoded,Compdata)
    Partcount = Partcount+1
    CloseFile(2)
    Compdata = 0
  Else
    MessageRequester("Internal Error","CRC32 Data match. Internal error, Parts: "+Str(Partcount))
    End
  EndIf
  Debug "Compressed: "+Compressed
  
  Form$ = SQLInsert(Form$,"Files","Part,FileName,IsCompressed,Checksum","'"+Str(Partcount)+"','"+FileFinger$+"','"+Str(Compressed)+"','"+CheckSum$+"'",1)
  Compressed = 0
  SQLCommit(1,Form$)
  Form$ = ""
  FreeMemory(*Split)
  FreeMemory(*Compressed)
  FreeMemory(*Encoded)
Until Eof(0)


    
    
  EndProcedure
  
  
  
  
  
  
EndModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 304
; FirstLine = 108
; Folding = 9+n-
; EnableThread
; EnableXP
; Executable = ..\Testing modules\Filetest.exe
; Warnings = Error
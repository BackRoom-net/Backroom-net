OpenConsole()
IncludePath "C:\Users\noisy\OneDrive\Documents\GitHub\Backroom-net\Code\Modules"
IncludeFile "Database_mod.pbi"
UseModule SQLDatabase
UseModule SQFormat
UseModule SQuery
Input()


Initlogging(1,"")
Initdatabase(1,"Testdb.db")

Form$ = SQFCreateTable(Form$,"test")
Form$ = SQFOpen(Form$)
Form$ = SQFMakeField(Form$,"TestTable",1,1,1,0,1,1)
Form$ = SQFMakeField(Form$,"String",2,1,0,0,0,0)
Form$ = SQFclose(Form$)
Debug Form$
Thread = SQLCommit(1,Form$)
Form$ = ""
Form$ = SQLInsert(Form$,"test","String","'Data'",1)
WaitThread(Thread)
Thread = SQLCommit(1,Form$)
Form$ = ""
WaitThread(Thread)

Input()
; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 23
; EnableThread
; EnableXP
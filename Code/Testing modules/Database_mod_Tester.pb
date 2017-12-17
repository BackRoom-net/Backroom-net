OpenConsole()
IncludeFile "C:\Users\Ruben\Documents\GitHub\Backroom-net\Code\Modules\Database_mod.pb"
UseModule SQLDatabase
UseModule SQFormat
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

WaitThread(Thread)
Input()
; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 18
; EnableThread
; EnableXP
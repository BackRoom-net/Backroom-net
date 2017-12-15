OpenConsole()
IncludeFile "C:\Users\noisy\OneDrive\Documents\GitHub\Backroom-net\Code\Modules\Database_mod.pb"
UseModule SQLDatabase
UseModule SQFormat
Input()


Initlogging(1,"")
Initdatabase(1,"Testdb.db")

Form$ = SQFCreateTable(Form$,"test")
Form$ = SQFOpen(Form$)
Form$ = SQFMakeField(Form$,"TestTable",1,1,1,0,1,0)
Form$ = SQFclose(Form$)
Thread = SQLCommit(1,Form$)
Form$ = ""


WaitThread(Thread)
Input()
; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 17
; EnableThread
; EnableXP
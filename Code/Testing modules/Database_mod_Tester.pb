OpenConsole()
IncludeFile "C:\Users\noisy\OneDrive\Documents\GitHub\Backroom-net\Code\Modules\Database_mod.pb"
UseModule SQLDatabase
UseModule SQFormat
Initlogging(1,"")
Start = ElapsedMilliseconds()
Initdatabase(1,"Testdb.db")
Point1 = ElapsedMilliseconds()
Result = Point1-Start
Debug result

Start = ElapsedMilliseconds()
Form$ = SQFCreateTable(Form$,"test")
Form$ = SQFOpen(Form$)
Form$ = SQFMakeField(Form$,"TestTable",1,1,1,1,1)
Form$ = SQFclose(Form$)
SQLCommit(1,Form$)
Form$ = ""
Point1 = ElapsedMilliseconds()
Result = Point1-Start
Debug result

Form$ = SQFCreateTable(Form$,"test2")
Form$ = SQFOpen(Form$)
Form$ = SQFMakeField(Form$,"TestTable",1,1,1,1,1)
Form$ = SQFclose(Form$)
SQLCommit(1,Form$)
Form$ = ""

Form$ = SQFCreateTable(Form$,"test3")
Form$ = SQFOpen(Form$)
Form$ = SQFMakeField(Form$,"TestTable",1,1,1,1,1)
Form$ = SQFclose(Form$)
SQLCommit(1,Form$)
Form$ = ""

Input()
; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 20
; EnableThread
; EnableXP
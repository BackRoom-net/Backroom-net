OpenConsole()
IncludeFile "C:\Users\noisy\OneDrive\Documents\GitHub\Backroom-net\Code\Modules\Database_mod.pb"
UseModule SQLDatabase
UseModule SQFormat
Initlogging(1,"")
Initdatabase(1,"Testdb.db")
Form$ = SQFCreateTable(Form$,"test")
Form$ = SQFOpen(Form$)
Form$ = SQFMakeField(Form$,"TestTable",1,1,1,1,1)
Form$ = SQFclose(Form$)
Address = SQLCommit(1,Form$)
Debug form$
Input()
; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 10
; EnableThread
; EnableXP
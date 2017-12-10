OpenConsole()
IncludeFile "C:\Users\noisy\OneDrive\Documents\GitHub\Backroom-net\Code\Modules\Database_mod.pb"
IncludeFile "C:\Users\noisy\OneDrive\Documents\GitHub\Backroom-net\Code\Modules\Proforma_mod.pbi"
UseModule SQLDatabase
UseModule SQFormat
UseModule Proforma
Input()
ProformaMakeInst("ProgramWhole")
ProformaMakeInst("InitDb")
ProformaMakeInst("MakeForm")
ProformaMakeInst("SQLCommit")


ProformaS("ProgramWhole")
Initlogging(1,"")
ProformaS("InitDb")
Initdatabase(1,"Testdb.db")
Debug ProformaE("InitDb")

Debug result



ProformaS("MakeForm")
Form$ = SQFCreateTable(Form$,"test")
Form$ = SQFOpen(Form$)
Form$ = SQFMakeField(Form$,"TestTable",1,1,1,1,1)
Form$ = SQFclose(Form$)
Debug ProformaE("MakeForm")
ProformaS("SQLCommit")
SQLCommit(1,Form$)
Debug ProformaE("SQLCommit")
Form$ = ""


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
Debug ProformaE("ProgramWhole")

Input()
; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 28
; FirstLine = 5
; EnableThread
; EnableXP
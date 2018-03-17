EnableExplicit

IncludeFile "log.pbi"
IncludeFile "module1.pbi"
IncludeFile "module2.pbi"

Log::AddMsg("hello from outside of module")

Module1::DoSomething()
Module2::DoSomething()

Log::AddMsg("hello again from outside of module")

Log::DumpToFile()
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 8
; EnableXP
; DisableDebugger
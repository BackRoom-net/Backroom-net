EnableExplicit

DeclareModule Module2
  Declare DoSomething()
EndDeclareModule

Module Module2
  
  Procedure DoSomething()
    Log::AddMsg("hello from Module2")
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 12
; Folding = -
; EnableXP
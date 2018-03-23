EnableExplicit

DeclareModule Module1
  Declare DoSomething()
EndDeclareModule

Module Module1
  
  Procedure DoSomething()
    Log::AddMsg("hello from Module1")
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 13
; Folding = -
; EnableXP
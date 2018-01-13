DeclareModule ConsInteract
  EnableGraphicalConsole(1)
  Declare StatShow(Map ThreadMemAccess())
  
Global Structure stat
Precent.s
Job.s
extrainfo.s
Code.i
EndStructure

 Global Map ThreadStat.stat
EndDeclareModule


Module ConsInteract
  
Procedure StatShow(Map ThreadMemAccess()) ;Yes, thats a map.
 
EndProcedure
  
EndDeclareModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 4
; Folding = -
; EnableXP
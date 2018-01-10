DeclareModule ConsInteract
  EnableGraphicalConsole(1)
  declare StatShow(Map ThreadMemAccess())
Struture Stat
Precent.s
Job.s
extrainfo.s
Code.i
endstructure
 Global map ThreadStat.stat
EndDeclareModule


Module ConsInteract
  
Procedure StatShow(Map ThreadMemAccess()) ;Yes, thats a map.
  ;This in here will be where I Work my magic.
EndProcedure
  
EndDeclareModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 8
; Folding = -
; EnableXP

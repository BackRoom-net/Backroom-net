DeclareModule Proforma
  Structure Proforma_Strc
    Tick.i
    Start.i
    Stop.i
    Sum.i
  EndStructure
  Global ProformaAccess = CreateMutex()
  Declare ProformaS(Instance$)
  Declare ProformaE(Instance$)
  Declare PromormaMakeInst(Instance$)
  Declare ProformaEraseInst(Instance$)
  Declare SpillProforma()
  Declare.i NextProformaTick()
  Global NewMap Proforma.Proforma_Strc(5012)
EndDeclareModule

Module Proforma
  
  Procedure.i NextProformaTick()
    While Proforma() 
      Debug Proforma() \Tick
      Tick = Proforma() \Tick
      If NextMapElement(Proforma())
      Else
        Goto Noelement
      EndIf
    Wend
    Noelement:
    Debug "End Tick: "+Tick
    Tick+1
    Debug "Next Tick: "+Tick
    ProcedureReturn Tick
  
  EndProcedure
  
Procedure ProformaS(Instance$)
    
EndProcedure
  
Procedure ProformaE(Instance$)
    
EndProcedure
    
Procedure PromormaMakeInst(Instance$)
  Proforma(Instance$) \tick = 0
  Tickplace = NextProformaTick()
  Proforma(Instance$) \tick = Tickplace
EndProcedure

Procedure ProformaEraseInst(Instance$)
    
EndProcedure

Procedure SpillProforma()
    
EndProcedure
  
  
EndModule

OpenConsole()

UseModule proforma
PromormaMakeInst("Start")
PromormaMakeInst("Middle")
PromormaMakeInst("End")
NextProformaTick()

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 62
; FirstLine = 23
; Folding = --
; EnableXP
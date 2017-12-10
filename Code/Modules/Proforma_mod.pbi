﻿DeclareModule Proforma
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
  Declare.i ProformaSpillResult(Instance$)
  Global NewMap Proforma.Proforma_Strc(5012)
EndDeclareModule

Module Proforma
  
  Procedure.i NextProformaTick()
    ForEach Proforma()
      Debug Proforma() \Tick
      Tick = Proforma() \Tick
      If Tick > FinalTick
        FinalTick = Tick
      EndIf
    Next
    
    Debug "End Tick: "+FinalTick
    FinalTick+1
    Debug "Next Tick: "+FinalTick
    ProcedureReturn FinalTick
  
  EndProcedure
  
Procedure ProformaS(Instance$)
  If Proforma(Instance$)
    Time = ElapsedMilliseconds()
    Proforma() \Start = Time
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
  
Procedure ProformaE(Instance$)
  If proforma(Instance$)
    ETime = ElapsedMilliseconds()
    STime = Proforma(Instance$) \Start
    TTime = ETime-STime
    Proforma(Instance$) \Stop = Stime
    Proforma(Instance$) \Sum = TTime
    ProcedureReturn TTime
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
    
Procedure PromormaMakeInst(Instance$)
  Tickplace = NextProformaTick()
  Proforma(Instance$) \tick = Tickplace
EndProcedure

Procedure ProformaEraseInst(Instance$)
  If Proforma(Instance$)
    If DeleteMapElement(Proforma(),Instance$)
      ProcedureReturn #False
    Else
      ProcedureReturn #True
    EndIf
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure SpillProforma()
  ; I will make this part later
  ;
  ; This is just suppose to 
  ; Dump the contents of Proforma
  ; Into memory or something. 
  ;
EndProcedure

Procedure.i ProformaSpillResult(Instance$)
  If proforma(Instance$)
     Result = Proforma(Instance$) \Sum
    Else
    ProcedureReturn #False
  EndIf
  ProcedureReturn Result
EndProcedure

EndModule
; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 93
; Folding = D5
; EnableXP
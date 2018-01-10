; If your Using this in threads, Remember to make a seperet mutex to avoid memory access violations!!

DeclareModule Proforma
  Structure Proforma_Strc                    ;declare the structure for the Proforma memory map
    Tick.i
    Start.i
    Stop.i
    Sum.i
  EndStructure
  Global ProformaAccess = CreateMutex()
  Declare ProformaS(Instance$)
  Declare ProformaE(Instance$)
  Declare ProformaMakeInst(Instance$)
  Declare ProformaEraseInst(Instance$)
  Declare SpillProforma()
  Declare.i NextProformaTick()
  Declare.i ProformaSpillResult(Instance$)
  Global NewMap Proforma.Proforma_Strc(5012)
EndDeclareModule

Module Proforma
  
  Procedure.i NextProformaTick()             ;This Procedure is to find the next internal Proforma Instance tick
                                             ;This procedure also may take lots of CPU time If measuring
                                             ;Statistics on big programs. 
    ForEach Proforma()                       ;Looks at each Memory Entry 
      ;Debug Proforma() \Tick                ;Un-Comment for debug results.
      Tick = Proforma() \Tick                ;Loads the Tick into a variable
      If Tick > FinalTick                    ; It will see if the last tick was the absolute last tick
        FinalTick = Tick                     ; If the last tick was greater, we replace it.
      EndIf
    Next                                     ;Repeat over and over Until we reach the last memory entry.
    
    ;Debug "End Tick: "+FinalTick            ;Un-comment to see the debug result
    FinalTick+1                              ;This is where the "Next Tick" comes in
    ;Debug "Next Tick: "+FinalTick           ;Un-Comment to see the debug result
    ProcedureReturn FinalTick                ; This procedure outputs the Next tick in the sequence.
  
  EndProcedure
  
Procedure ProformaS(Instance$)               ;This Procedure Creates A new Proforma Instance By string.
  If Proforma(Instance$)                    1;Checks if the instance Exists already
    Time = ElapsedMilliseconds()             ;Checks the current time in milliseconds
    Proforma() \Start = Time                 ;Puts that into the memory map
    ProcedureReturn #True                    ;Returns True for sucessful operation.
  Else                                      
    ProcedureReturn #False                  1;If Find it, Return false. It already exists.
  EndIf
EndProcedure
  
Procedure ProformaE(Instance$)               ;This procedure Records the end of a profroma instance and 
                                             ;Sums the operation.
  If proforma(Instance$)                    1;If we can find the open instance
    ETime = ElapsedMilliseconds()            ;Set the end time to now
    STime = Proforma(Instance$) \Start       ;Retrive the Start Time
    TTime = ETime-STime                      ;Find the total Time it took
    Proforma(Instance$) \Stop = Stime        ;Enter the Stop Time into Memory
    Proforma(Instance$) \Sum = TTime         ;Enter the sum Time into Memory
    ProcedureReturn TTime                    ;Return the total time from the procedure.
  Else                                      1; If we cant find it, there is data to use to find the total amount of time.
    ProcedureReturn #False                  1; Duh..
  EndIf
EndProcedure
    
Procedure ProformaMakeInst(Instance$)        ;This procedure creates a new Profoma Instance
  Tickplace = NextProformaTick()             ;Find a new instance Tick
  Proforma(Instance$) \tick = Tickplace      ;Enter the next tick place into the Tick memory.
EndProcedure

Procedure ProformaEraseInst(Instance$)       
  If Proforma(Instance$)                     
    If DeleteMapElement(Proforma(),Instance$)
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure SpillProforma() ; This part is complete
  If CreateXML(0)     
    InsertXMLMap(RootXMLNode(0), Proforma())
    FormatXML(0, #PB_XML_ReFormat)
    SaveXML(0,"Proforma_Mem_Dump.txt")
  EndIf
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
; CursorPosition = 10
; Folding = j5
; EnableXP

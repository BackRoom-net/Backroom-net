DeclareModule Prefs
  Declare.i InsertPrefS(Name$,Value$)
  Declare.i InsertPrefi(Name$,Value)
  Declare.s retPrefS(Name$)
  Declare.i retPrefI(Name$)
  Declare PrefExport()
  Declare ImprortPrefs()
  Declare PrefChk()
EndDeclareModule

Module Prefs
   Structure Prefs
    Name.s
    Value.s
    Number.i
  EndStructure
   Global NewMap Prefs.Prefs()
   
  Procedure.i InsertPrefS(Name$,Value$)
    If FindMapElement(Prefs(),Name$)
      ProcedureReturn #False
    Else
      Prefs(Name$) \Name = Name$
      Prefs(Name$) \Value = Value$
    EndIf
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i InsertPrefi(Name$,Value)
    If FindMapElement(Prefs(),Name$)
      ProcedureReturn #False
    Else
      PrefS(Name$) \Name = Name$
      PrefS(Name$) \Number = Value
    EndIf
    ProcedureReturn #True
  EndProcedure
  
  Procedure.s retPrefS(Name$)
    If FindMapElement(Prefs(),Name$)
      StrRet$ = Prefs(Name$) \Value
      ProcedureReturn StrRet$
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  
  Procedure.i retPrefI(Name$) 
     If FindMapElement(Prefs(),Name$)
      StrRet = PrefS(Name$) \Number
      ProcedureReturn StrRet
    Else
      ProcedureReturn False
    EndIf
   EndProcedure
   
  Procedure PrefExport()
   If CreateXML(0)     
    InsertXMLMap(RootXMLNode(0), Prefs())
    FormatXML(0, #PB_XML_ReFormat)
    SaveXML(0,"Data\Preferences.xml")
  EndIf
EndProcedure

  Procedure ImprortPrefs()
  LoadXML(2,"Data\Preferences.xml")
  ExtractXMLMap(MainXMLNode(0), Prefs())
  FreeXML(2)
EndProcedure

  Procedure PrefChk()
    If ReadFile(1,"Data\Preferences.xml")
      CloseFile(1)
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

  
EndModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 64
; FirstLine = 11
; Folding = v8
; EnableXP
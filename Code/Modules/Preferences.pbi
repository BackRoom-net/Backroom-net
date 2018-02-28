DeclareModule
  Structure Prefs
    Name.s
    Value.s
  EndStructure
  
  Structure Prefi
    Name.s
    Value.i
  EndStructure
  
  Declare.i InsertPrefS(Name$,Value$)
  Declare.i InsertPrefi(Name$,Value)
  Declare.s retPrefS(Name$)
  Declare.i retPrefI(Name$)
  Declare PrefExport(File$)
  Declare ImprortPrefs(File$)
EndDeclareModule

Module Prefs
   NewMap Prefs.Prefs()
   NewMap Prefi.Prefi() 
   
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
      Prefi(Name$) \Name = Name$
      Prefi(Name$) \Value = Value
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
      StrRet = Prefs(Name$) \Value
      ProcedureReturn StrRet
    Else
      ProcedureReturn False
    EndIf
   EndProcedure
   
  Procedure PrefExport(File$)
   If CreateXML(0)     
    InsertXMLMap(RootXMLNode(0), Prefs())
    FormatXML(0, #PB_XML_ReFormat)
    SaveXML(0,"Data\Preferences.xml")
  EndIf
EndProcedure

  Procedure ImprortPrefs(File$)
  LoadXML(2,"Data\Preferences.xml")
  ExtractXMLMap(MainXMLNode(0), Prefs()))
  FreeXML(2)
EndProcedure

  Procedure PrefChk()
  If ReadFile(1,"Data\Preferences.xml")
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

  
EndModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 75
; Folding = D5
; EnableXP
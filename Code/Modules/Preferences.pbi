EnableExplicit

DeclareModule Prefs
  Declare.i InsertPrefS(Name$,Value$)
  Declare.i InsertPrefi(Name$,Value)
  Declare.s retPrefS(Name$)
  Declare.i retPrefI(Name$)
  Declare PrefExport()
  Declare ImprortPrefs()
  Declare PrefChk()
  Declare PrefIsStr(Name$,Value$)
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
      If Value$ = ""
        Prefs(Name$) \Name = Name$
        Prefs(Name$) \Value = "Null"
      Else
      Prefs(Name$) \Name = Name$
      Prefs(Name$) \Value = Value$
    EndIf
    ProcedureReturn #True
    EndIf
  EndProcedure
  
  Procedure.i InsertPrefi(Name$,Value)
    If FindMapElement(Prefs(),Name$)
      ProcedureReturn #False
    Else
      PrefS(Name$) \Name = Name$
      PrefS(Name$) \Number = Value
      PrefS(Name$) \Value = "Null"
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
      ProcedureReturn #False
    EndIf
   EndProcedure
   
   Procedure PrefExport()
     Proforma::ProformaMakeInst("XMLPrefSave")
  Proforma::ProformaS("XMLPrefSave")
   If CreateXML(0)     
    InsertXMLMap(RootXMLNode(0), Prefs())
    FormatXML(0, #PB_XML_ReFormat)
    SaveXML(0,"Data\Preferences.xml")
  EndIf
  Proforma::ProformaE("XMLPrefSave")  
EndProcedure

Procedure ImprortPrefs()
  Proforma::ProformaMakeInst("XMLPrefLoad")
  Proforma::ProformaS("XMLPrefLoad")  
  If FileSize("Data\Preferences.xml") <> -1
     OpenFile(45,"Data\Preferences.xml")
     TrueBytes = FileSize("Data\Preferences.xml")
     *Tempmem = AllocateMemory(TrueBytes)
     ReadData(45,*Tempmem,TrueBytes)
     CloseFile(45)
     If CatchXML(1,*Tempmem,TrueBytes)
    InsertXMLMap(RootXMLNode(1),Prefs())
    FreeXML(1)
    Else
      MessageRequester("XML Pref Manager","Error when Reading XML Memory.",#PB_MessageRequester_Error)
      End
    EndIf
  Else
    Log::Genlogadd("XMLMgr1","Info","New XML Preferences file will be created.","ImportPrefs()")
  EndIf
  
  Proforma::ProformaE("XMLPrefLoad")  
  ;Old method
  ;LoadXML(2,"Data\Preferences.xml")
  ;ExtractXMLMap(MainXMLNode(0), Prefs())
  ;FreeXML(2)
EndProcedure

  Procedure PrefChk()
    If ReadFile(1,"Data\Preferences.xml")
      CloseFile(1)
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure.i PrefIsStr(Name$,Value$)
  If FindMapElement(Prefs(),Name$)
    If Prefs(Name$) \Value = "Null"
      ProcedureReturn #False
    Else
      ProcedureReturn #True
    EndIf
  Else
    ProcedureReturn #False
  EndIf
EndProcedure


EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 72
; FirstLine = 21
; Folding = Dz
; EnableXP
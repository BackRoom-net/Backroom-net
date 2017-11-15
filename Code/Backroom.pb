;Code is really Incomplete... Just a jumbled mess.


OpenConsole("BackRoom 1.0")

;This is the next step.

; If ReadFile(1,"ClientData.bin")
;   OpenFile(1,"ClientData.bin")
; ;   While Not Eof(1)
; ;     
; ;   Wend
; Else
;   MessageRequester("Network Connection")
; EndIf





DeclareModule Ciphersuite
  Declare.i CreateNetkey(*mem)
  Declare.i Decryptkey(*mem)
  Declare.i Genhex(*in)
EndDeclareModule

Module Ciphersuite
  
 Procedure.i CreateNetkey(*mem)
 OpenCryptRandom()
 *dem = AllocateMemory(128)
 *alf = AllocateMemory(128)
  CryptRandomData(*dem,16)
  CopyMemory(*dem,*alf,128)
  Debug PeekS(*dem,128,#PB_UTF8)
   *hex = Genhex(*dem)
   Hex$ = peeks(*hex,150,#PB_Utf8)
    Base64Encoder(*dem,16,*mem,128)
    Base64Decoder(*mem,128,*alf,16)
    Debug Hex$
    Debug PeekS(*mem,128,#PB_UTF8)
    checkalf$ = PeekS(*alf,128,#PB_UTF8)
    checkdem$ = PeekS(*Dem,128,#PB_UTF8)
    If checkalf$ = checkdem$
      Debug "ENCODE OK."
      ;Forming an address list...
      Rawdata$ = str(
    Else
      Debug "BAD ENCODE."
      MessageRequester("Internal Error","Failed to Generate a secure varification key.")
    EndIf
    
  EndProcedure
  
  Procedure.i GenHex(*in)
    For i = 0 To 15
      Text$ + " " + RSet(Hex(PeekB(*in+i), #PB_Byte), 2, "0")
    Next i
    *Out = AllocateMemory(150)
    PokeS(*Out,Text$)
    Freememory(*in)
   Procedurereturn *out
  EndProcedure
  
    
Procedure.i Decryptkey(*mem)
  If Base64Decoder(*mem,128,*alf,16)
    
  
EndProcedure
  
  
EndModule

; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableUnicode
; EnableXP

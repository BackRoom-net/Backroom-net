;   *Key = AllocateMemory(16)
;   
;   If OpenCryptRandom() And *Key
;     CryptRandomData(*Key, 16)
;     
;     Text$ = "Generated Key:"
;     For i = 0 To 15
;       Text$ + " " + PeekS(*Key)
;     Next i     
;     
;     CloseCryptRandom()
;   Else
;     Text$ = "Key generation is not available"
;   EndIf
;   
;   MessageRequester("Example", Text$)


; *mem = AllocateMemory(128)
; 
;  OpenCryptRandom()
;  *dem = AllocateMemory(128)
;  *alf = AllocateMemory(128)
;   CryptRandomData(*dem,16)
;   CopyMemory(*dem,*alf,128)
;   Debug PeekS(*dem,128,#PB_UTF8)
;   For i = 0 To 15
;       Text$ + " " + RSet(Hex(PeekB(*dem+i), #PB_Byte), 2, "0")
;     Next i
;     
;     Base64Encoder(*dem,16,*mem,128)
;     Base64Decoder(*mem,128,*alf,16)
;     Debug Text$
;     Debug PeekS(*mem,128,#PB_UTF8)
;     checkalf$ = PeekS(*alf,128,#PB_UTF8)
;     checkdem$ = PeekS(*Dem,128,#PB_UTF8)
;     If checkalf$ = checkdem$
;       Debug "ENCODE OK."
;     Else
;       Debug "BAD ENCODE."
;     EndIf
;     
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 33
; EnableUnicode
; EnableXP

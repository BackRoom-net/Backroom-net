;Code is really Incomplete... Just a jumbled mess.
;I'm really working on it.



OpenConsole("BackRoom 1.0")

If ReadFile(1,"ClientData.bin")
  OpenFile(1,"ClientData.bin")
  While Not Eof(1)
    
  Wend
Else
  MessageRequester("Network Connection")
EndIf




Procedure CreateNetkey(*mem)
  OpenCryptRandom()
  *dem = AllocateMemory(128)
  CryptRandomData(*dem,16)
  For i = 0 To 15
      Text$ + " " + RSet(Hex(PeekB(*dem+i), #PB_Byte), 2, "0")
    Next i
    
    Base64Encoder(*dem,16,*mem,128)
    Debug PeekS(*mem)
  
EndProcedure

  

; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableUnicode
; EnableXP
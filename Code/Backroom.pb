;Code is really Incomplete... Just a jumbled mess.
;However! Its time to annotate!!



 Declare.s CreateNetkey(*mem)
  Declare.i Decryptkey(*mem)
  Declare.i Genhex(*in)

OpenConsole("BackRoom 1.0")
Global *Alocmem, *dem          ;Test for The encrypt key!
*Alocmem = AllocateMemory(128) ; Litterly nothing else works! ;This memory should always be set to 128 Bytes to avoid overflow.
Input()
Hex$ = CreateNetkey(*Alocmem)         ; Will create a key inside the memory we specified.
Debug PeekS(*Alocmem,128,#PB_UTF8)
                               ; The main code has nothing else so far!

;This is the next step.

; If ReadFile(1,"ClientData.bin")
;   OpenFile(1,"ClientData.bin")
; ;   While Not Eof(1)
; ;     
; ;   Wend
; Else
;   MessageRequester("Network Connection")
; EndIf




  
 Procedure.s CreateNetkey(*mem)
   OpenCryptRandom()  ; First we open the Crypto engine...
   
 ;Crypt memory
 *dem = AllocateMemory(128)
 *alf = AllocateMemory(128)
 ; ----------
 
 ; Generate 16-byte long random data and put into *dem
 CryptRandomData(*dem,16)
 ;
 
 ; Copy that over and Debug its Contents into the IDE Debug window.
  CopyMemory(*dem,*alf,128)
  Debug PeekS(*dem,128,#PB_UTF8)
  ;
  
  ; after that we will generate the Hex value of that memory.
  *hex = Genhex(*dem)
  *dem = AllocateMemory(128)
  ; Copy the original back into the *dem memory slot since Genhex() Destroys the data.
  CopyMemory(*alf,*dem,128)
  ;
  
  ; Read that into a variable.
  Hex$ = PeekS(*hex)
  Debug Hex$ ; Debug the value.
  
    ; We will now input the *dem (Random Block) into a Base64 encoder.
    Base64Encoder(*dem,16,*mem,128)
    Base64Decoder(*mem,128,*alf,16)
    ; This basically just encodes and decodes the random block.
    
    ; We will debug 
    Debug PeekS(*mem,128,#PB_UTF8)
    ; The we will put the Encoded data and the decoded data into variables to check!
    checkalf$ = PeekS(*alf,128,#PB_UTF8)
    checkdem$ = PeekS(*Dem,128,#PB_UTF8)
    If checkalf$ = checkdem$   ; This also serves for some good debug.
      Debug "ENCODE OK."

    Else
      Debug "BAD ENCODE."
      MessageRequester("Internal Error","Failed to Generate a secure varification key.")
    EndIf
    
    FreeMemory(*dem)  ; Cant afford any memory leaks!
    FreeMemory(*hex)  ;
    FreeMemory(*alf)  ;
    ProcedureReturn Hex$ ; Return the hex value.
  EndProcedure
  
  Procedure.i GenHex(*dem)
    For i = 0 To 15
      Text$ + " " + RSet(Hex(PeekB(*dem+i), #PB_Byte), 2, "0")
    Next i
    *Out = AllocateMemory(150)
    PokeS(*Out,Text$)
    Debug PeekS(*Out)
    FreeMemory(*dem)
   ProcedureReturn *Out
  EndProcedure
  
    
Procedure.i Decryptkey(*mem)
  If Base64Decoder(*mem,128,*alf,16)
    
  EndIf
  
EndProcedure
  
  


; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 14
; FirstLine = 4
; Folding = -
; EnableUnicode
; EnableXP
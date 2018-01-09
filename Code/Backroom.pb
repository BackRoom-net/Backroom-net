;   Description: Main Program
;        Author: Ruben Rodriguez
;          Date: 11/13/17
;            OS: Windows/XP/Vista/7/10

; Code is currently being reworked!! I will get back to you!!!

;
;- Declares
;
IncludePath "C:\Users\Ruben\Documents\GitHub\Backroom-net\Code\Modules\"
IncludeFile "Crypto_mod.pbi"
IncludeFile "Database_mod.pbi"
IncludeFile "FileUtil_mod.pbi"
IncludeFile "Modul_NetworkData.pbi"
IncludeFile "Proforma_mod.pbi"
;
;
;
Declare GenerateKey(Name$)
Declare GetKey(Name$)
Declare KillKey(Name$)
;
;- Structures
;


;; No structures Rn... =(  
  
;
;- Variables
;



;
;- Maps
; Map cap at 6mill

Global NewMap Keys.s(6000000)


;
;- Procedures
;
;------------

Procedure GenerateKey(ID$)
  UseModule Cipher
  
  
  
  
EndProcedure

Procedure KillKey(ID$)
  UseModule Cipher
  
EndProcedure

Procedure IsKey(ID$)
  UseModule Cipher
  
EndProcedure


;-------------
;- Program side
;
UseModule Proforma
; Make Proforma Instances
ProformaMakeInst("KeyGen")
ProformaMakeInst("Startup")


;
OpenConsole("BackRoom-Net")









Input()





; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 57
; FirstLine = 33
; Folding = -
; EnableXP
; Executable = Test.exe
; EnableUnicode
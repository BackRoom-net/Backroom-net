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
IncludeFile "Console_Interactive_mod.pbi"
;
;
;
Declare Keyboard()

;
;- Structures
;


;; No structures Rn... =(  
  
;
;- Variables
;
Global KeyboardMode.i
Global msg$, conplace

;
;- Maps
; Map cap at 6mill

Global NewMap Keys.s(6000000)


;
;- Procedures
;
;------------

Procedure.i keyboard(conplace)
  ;//InKey() is used to check for keyboard presses
  ;//and should be used in a loop.
  ;//in other words, use the procedure in a loop.
  
  ;// Output mode 1 for regular output to msg$ or 2 for Key string output to msg$
  
  KeyPressed$ = Inkey()
  
  Select KeyboardMode.i
      Case 1
  If KeyPressed$ <> ""      ;// This If is used to check if no key was pressed
    If KeyPressed$ = Chr(13)   ;// Right here is to check if enter was pressed
      ConsoleLocate(0,conplace)
      PrintN(msg$+Chr(13))     ;// If so it will print the current message
      msg$ = ""                ;// Erase from the variable
      conplace = conplace + 1  ;// and manually set the console position
    Else
      If KeyPressed$ = Chr(8)     ;// Here is the if the backspace was pressed
        lent = Len(msg$)           ;//Get the lenght of the message
        msg$ = Left(msg$,lent - 1) ;//Removes the deleted letter from msg$
        ConsoleLocate(0,conplace)
        tover = 0                 ;//safe guard to make sure variable is reset.
        over$ = ""                ;//another safe guard.
        If lent > 0              ;// if the lenghth of msg$ is over 0 go to next step.
        Repeat             ;//next step makes padding of null to cover message to print new message.
          over$ = over$+" " ;//adds padding to over$ to go over the message.
          tover = tover + 1 ;//counts  the ammount of padding needed to cover the message space
        Until tover = lent ;// until the whole place in the console is covered
        Print(over$)         ;// print the padding over the message.
        ConsoleLocate(0,conplace) ;// reset write head so its ready to write again.
        Print(msg$+Chr(0))       ;// print the modified msg$ with one less letter
        Debug msg$
        Debug over$
      EndIf                 ;//self explainatory. 
      
    Else                    ;// if any other event is needed, its costom and added below.
                              ;//Costom events------
      msg$ = msg$+KeyPressed$
      If msg$ = "!rp"
        Debug "in rp mode"
        ConsoleLocate(0,conplace)
        Print("   ")
        msg$ = ""
      EndIf
                             ;//-------------------
                             ;//end of costom events//
      ConsoleLocate(0,conplace) ;// reset console position just incase
      
      Print(msg$)            ;// if the events above where not true but there was a key press, it will be printed in now.
      
      
    EndIf   ;//end of backspace event
  EndIf     ;//end of enter keypress event
EndIf       ;//end of key press check
Delay(1)
If KeyPressed$ = Chr(27) ;// if the escape key was pressed, 
  result = 27
Else
  result = 1
EndIf
ProcedureReturn(result)

Case 2
  If KeyPressed$ <> ""
    If KeyPressed$ = Chr(13)
      msg$ = "enter"
      ProcedureReturn #True
      Else
      If KeyPressed$ = Chr(8)
        msg$ = "bspace"
        ProcedureReturn #True
      Else
        If KeyPressed$ = Chr(27)
          msg$ = "esc"
          ProcedureReturn #True
        Else
          keypressed$ = msg$
          ProcedureReturn #True
      EndIf
      
    
    
    EndIf
  EndIf
Else
  ProcedureReturn #True
EndIf

EndProcedure 

;-------------
;- Program side
;
UseModule Proforma
; Make Proforma Instances
ProformaMakeInst(Instance$)
;
KeyboardMode.i = 2
OpenConsole("BackRoom-Net")
EnableGraphicalConsole(1)

Repeat
  If Keyboard()
  
  
  
Until Exit = 1








Input()





; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 143
; FirstLine = 24
; Folding = +
; EnableXP
; Executable = Test.exe
; EnableUnicode
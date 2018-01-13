;   Description: Interactive Console Typing Extention.
;        Author: Ruben Rodriguez
;          Date: 8/25/17
;            OS: Windows/XP/Vista/7/10

OpenConsole()
Global Dim Console.s(200)
Global msg$, int, conplace, lines, before$
Declare keyboard(conplace)
Declare conmove(lines,before$)
conx = 0
cony = 24
conplace = 0

EnableGraphicalConsole(1)

Repeat 
  If keyboard(conplace) = 27
    End
  EndIf
  If msg$ = "hello"
    conplace = conplace + 1
    ConsoleLocate(0,conplace)
    conplace = conplace + 1
    msg$ = ""
    PrintN("hi there!")
  EndIf
Until zzmr = 1



;//Keyboard Function. 
Procedure.i keyboard(conplace)
  ;//InKey() is used to check for keyboard presses
  ;//and should be used in a loop.
  ;//in other words, use the procedure in a loop.
  
  KeyPressed$ = Inkey()
  
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
EndProcedure 
;// Conplace Global is used to manually set the console position
;// Its reccomended that you go in intervals with the Conmove-
;// Function.



Procedure conmove(lines,before$)
  conplace = conplace + lines
  lent = Len(msg$)
  Repeat             
    over$ = over$+" " 
    tover = tover + 1 
  Until tover = lent 
  Print(before$)
ConsoleLocate(0,conplace)
 Print(msg$)
EndProcedure

  
  

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 40
; Folding = -
; EnableXP
; Executable = typetest.exe
; EnableUnicode
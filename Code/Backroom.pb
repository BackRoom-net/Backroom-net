;   Description: Main Program
;        Author: Ruben Rodriguez
;          Date: 11/13/17
;            OS: Windows/XP/Vista/7/10

; Code is currently being reworked!! I will get back to you!!!

;
;- Declares
;
IncludePath "C:\Users\noisy\OneDrive\Documents\GitHub\Backroom-net\Code\Modules\"
IncludeFile "Crypto_mod.pbi"
IncludeFile "Database_mod.pbi"
IncludeFile "FileUtil_mod.pbi"
IncludeFile "Modul_NetworkData.pbi"
IncludeFile "Proforma_mod.pbi"
;IncludeFile "Console_Interactive_mod.pbi"
IncludeFile "ThreadBranch_mod.pbi"
;
;
;
Declare Keyboard(conplace)
Declare InitializeDatabase()
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
EndSelect

EndProcedure 

Procedure InitializeDatabase()
  CreateDirectory("Data")
UseModule SQLDatabase
UseModule SQFormat
UseModule SQuery
UseModule ThreadBranch
Initlogging(1,"")
Initdatabase(1,"Data\Main.db")
CloseC1$ = SQFCreateTable(CloseC1$,"CloseClients")
CloseC1$ = SQFOpen(CloseC1$)
CloseC1$ = SQFMakeField(CloseC1$,"ClientNumber",1,1,1,1,1,1)
CloseC1$ = SQFMakeField(CloseC1$,"IP",2,1,0,0,1,1)
CloseC1$ = SQFMakeField(CloseC1$,"Ping",1,1,0,0,0,0)          ;To be under "Close Clients" Ping < 15ms
CloseC1$ = SQFclose(CloseC1$)
Debug CloseC1$
Input()
CloseC2$ = SQFCreateTable(CloseC2$,"KnownClients")
CloseC2$ = SQFOpen(CloseC2$)
CloseC2$ = SQFMakeField(CloseC2$,"ClientNumber",1,1,1,1,1,1)
CloseC2$ = SQFMakeField(CloseC2$,"IP",2,1,0,0,1,1)
CloseC2$ = SQFMakeField(CloseC2$,"Ping",1,1,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"HandShakeSuccessful",1,0,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"AESCatch",2,0,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"SHA1",2,0,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"SHA2",2,0,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"SHA3",2,0,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"MD5",2,0,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"CRC32",2,0,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"Base64Master",2,0,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"Base64Key",2,0,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"MasterKey",2,0,0,0,0,1)
CloseC2$ = SQFMakeField(CloseC2$,"Key",2,0,0,0,0,0)
CloseC2$ = SQFclose(CloseC2$)
Debug CloseC2$

CloseC3$ = SQFCreateTable(CloseC3$,"SharedClients")
CloseC3$ = SQFOpen(CloseC3$)
CloseC3$ = SQFMakeField(CloseC3$,"ClientNumber",1,1,1,1,1,1)
CloseC3$ = SQFMakeField(CloseC3$,"IP",2,1,0,0,1,1)
CloseC3$ = SQFMakeField(CloseC3$,"Ping",1,1,0,0,0,0)
CloseC3$ = SQFclose(CloseC3$)
Debug CloseC3$

CloseC4$ = SQFCreateTable(CloseC4$,"SharedClients")
CloseC4$ = SQFOpen(CloseC4$)
CloseC4$ = SQFMakeField(CloseC4$,"ClientNumber",1,1,1,1,1,1)
CloseC4$ = SQFMakeField(CloseC4$,"IP",2,1,0,0,1,1)
CloseC4$ = SQFMakeField(CloseC4$,"Ping",1,1,0,0,0,0)
CloseC4$ = SQFclose(CloseC4$)
Debug CloseC4$

Thread1 = SQLCommit(1,CloseC1$)
Thread2 = SQLCommit(1,CloseC2$)
Thread3 = SQLCommit(1,CloseC3$)
Thread4 = SQLCommit(1,CloseC4$)
AddThreadMember(Thread1)
AddThreadMember(Thread2)
AddThreadMember(Thread3)
AddThreadMember(Thread4)
WaitThreadBranchGraphical("Waiting On Database Initilization...",900,7000)
ProcedureReturn #True
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

If InitializeDatabase()
 Debug "1"
EndIf





Repeat
  If Keyboard(conplace)
    If msg$ = "esc"
      Exit = 1
    EndIf
  EndIf
  
Until Exit = 1








Input()





; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 151
; FirstLine = 63
; Folding = +
; EnableThread
; EnableXP
; Executable = Test.exe
; EnableUnicode
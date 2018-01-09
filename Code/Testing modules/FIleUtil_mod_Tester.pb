OpenConsole()
Input()
IncludeFile "C:\Users\Ruben\Documents\GitHub\Backroom-net\Code\Modules\FileUtil_mod.pbi"
IncludeFile "C:\Users\Ruben\Documents\GitHub\Backroom-net\Code\Modules\Crypto_Mod.pbi"
UseModule FileUtil
UseModule Cipher

GenerateKeySequence("Master")
File$ = OpenFileRequester("Please Choose a file","","*.*",0)
Input()
*KeyMem = EncryptStorage("Master") \keymem
SpredFile(File$,EncryptStorage() \AESMem,*Keymem,0)

Input()



; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 11
; EnableThread
; EnableXP
; Executable = ..\Filetest.exe
; CPU = 1
; Debugger = IDE
; EnablePurifier = 1,1,1,0
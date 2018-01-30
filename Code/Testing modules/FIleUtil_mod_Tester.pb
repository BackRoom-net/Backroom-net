OpenConsole()
Input()
IncludeFile "C:\Intel\Git\Backroom-net\Code\Modules\FileUtil_mod.pbi"
IncludeFile "C:\Intel\Git\Backroom-net\Code\Modules\Crypto_Mod.pbi"
UseModule FileUtil
UseModule Cipher

GenerateKeySequence("Master")
File$ = PathRequester("path","C:\")
*KeyMem = EncryptStorage("Master") \keymem

SpredDir(File$,EncryptStorage() \AESMem,*Keymem)

Input()



; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 8
; EnableThread
; EnableXP
; Executable = ..\Filetest.exe
; CPU = 1
; CompileSourceDirectory
; Debugger = IDE
; EnablePurifier = 1,1,1,0
OpenConsole()
IncludeFile "C:\Users\noisy\OneDrive\Documents\GitHub\Backroom-net\Code\Modules\FileUtil_mod.pbi"
UseModule FileUtil
Input()
File$ = OpenFileRequester("Please Choose a file","","*.*",0)
SpredFile(File$)
Input()



; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 5
; EnableThread
; EnableXP
; Executable = J:\Filetest.exe
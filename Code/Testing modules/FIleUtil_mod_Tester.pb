OpenConsole()
IncludeFile "C:\Users\Ruben\Documents\GitHub\Backroom-net\Code\Modules\FileUtil_mod.pbi"
UseModule FileUtil
File$ = OpenFileRequester("Please Choose a file","","*.*",0)
Input()
SpredFile(File$)
Input()



; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 1
; EnableThread
; EnableXP
; Executable = J:\Filetest.exe
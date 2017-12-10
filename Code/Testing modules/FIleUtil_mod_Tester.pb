OpenConsole()
IncludeFile "C:\Users\noisy\OneDrive\Documents\GitHub\Backroom-net\Code\Modules\FileUtil_mod.pbi"
Input()
UseModule FileUtil
File$ = OpenFileRequester("Please Choose a file","","*.*",0)
SpredFile(File$)
Input()



; IDE Options = PureBasic 5.61 (Windows - x64)
; EnableXP
; Executable = J:\Filetest.exe
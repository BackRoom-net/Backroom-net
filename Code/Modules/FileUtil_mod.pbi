DeclareModule FileUtil
  CreateDirectory("FileSpreadTmp")
  Declare SpredFile(File$)
  
  
  
EndDeclareModule

Module FileUtil
  
  Procedure SpredFile(File$)
Size.i = 1024*4000
Debug Size.i
;--------------
OpenFile(0,File$)
FileSize.i = Lof(0)
Parts.d = Filesize.i/Size.i
;---------------
Debug Size.i
Debug Parts.d
Debug Round(Parts.d,#PB_Round_Up)
Parts = Round(Parts.d,#PB_Round_Up)
Debug filesize.i
;---------------

*Split = AllocateMemory(Size.i)
Repeat
 If OpenFile(2,"FileSpreadTmp\"+Str(Random(9999,0)))
    Actread = ReadData(0,*Split,Size.i)
   OpenFile(3,"FileSpreadTmp\Recreate.dat",#PB_File_Append)
   WriteData(2,*Split,Actread)
   WriteData(3,*Split,Actread)
  Partcount = Partcount+1
  CloseFile(2)
  CloseFile(3)
  FillMemory(*Split,Size.i)
 Else
 MessageRequester("Error","Could not read data from file")
 End
EndIf
Until Eof(0)
FreeMemory(*Split)

    
    
  EndProcedure
  
  
  
  
  
  
EndModule


; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 41
; FirstLine = 7
; Folding = -
; EnableXP
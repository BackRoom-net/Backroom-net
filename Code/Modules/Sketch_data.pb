Size.i = 1024*1024
Size.i = Size*2
;--------------
Openfile(0,"(Some file)")
FileSize.i = Lof(0)
Parts.i = Filesize.q/Size.i
;---------------
Debug Size.i
Debug Parts.i
Debug filesize.i
;---------------

Repeat
 *Split = Allowcatememory(Size.i)
 If ReadData(0,*Split,Size.i)
  Openfile(2,"Randomly generated name")
  Writedata(2,*Split)
  Partcount = Partcount+1
  Closefile(2)
 Else
 MessageRequester("Error","Could not read data from file")
 End
Endif
Until Eof(0)

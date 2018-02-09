

DeclareModule FileUtil
  CreateDirectory("FileTmp")
  CreateDirectory("Package")
  Declare SpredFile(File$,*AESKey,*IniVector,*ProgressOut)
  Declare SpredDir(File$,*AESKey,*IniVector)
  Global FileSpreadMutex = CreateMutex()
  
  Structure part
    Checksum.s
    filefinger.s
    Compressed.i
  EndStructure
  
  
  
EndDeclareModule

Module FileUtil

  Procedure SpredFile(File$,*AESKey,*IniVector,*ProgressOut)
    NewMap Files.part(2000000)
    UseCRC32Fingerprint()
    UseSHA3Fingerprint()
    UseZipPacker()
 
Size.i = 1024*4000
; --------------
OpenFile(0,File$)
Filename$ = GetFilePart(File$)
FileSize.i = Lof(0)
Parts.d = Filesize.i/Size.i
; ---------------
PrintN(Filename$)
PrintN(Str(Parts.d))
Parts = Round(Parts.d,#PB_Round_Up)
PrintN(Str(parts))
PrintN(Str(Filesize.i))
PrintN(File$)
If parts = 0 
  MessageRequester("Internal Error","Package does not meet size requirements.")
  ProcedureReturn #False
EndIf


redo:
Repeat
  *Split = AllocateMemory(Size.i)
  Actread = ReadData(0,*Split,Size.i)
  FileFinger$ = Fingerprint(*Split,Actread,#PB_Cipher_CRC32)
  CheckSum$ = Fingerprint(*Split,ActRead,#PB_Cipher_SHA3)
  If FileSize(FileFinger$) = -1
    *Encoded = AllocateMemory(Actread+32)
    *Compressed = AllocateMemory(Actread+32)
    OpenFile(2,"FileTmp\"+FileFinger$)
    Compdata = CompressMemory(*Split,Actread+32,*Compressed,Actread+32,#PB_PackerPlugin_Zip,9)
    If Compdata = 0
      Compdata = AESEncoder(*Split,*Encoded,Actread,*AESKey,256,*IniVector)
    Else
      Compressed = 1
     AESEncoder(*Compressed,*Encoded,Actread,*AESKey,256,*IniVector)
   EndIf
   
    
    WriteData(2,*Encoded,Compdata)
    Partcount = Partcount+1
    CloseFile(2)
    Compdata = 0
  Else
    MessageRequester("Internal Error","CRC32 Data match. Internal error, Parts: "+Str(Partcount))
    End
  EndIf
  
  
  files(Str(Partcount)) \Checksum = CheckSum$
  Files() \Compressed = Compressed
  Files() \filefinger = FileFinger$
  

  Compressed = 0
  Form$ = ""
  FreeMemory(*Split)
  FreeMemory(*Compressed)
  FreeMemory(*Encoded)
  
  Done.d = Partcount/parts
  FinalProgress.i = Done.d*100
  If BeforeProgress = FinalProgress.i
    
    Else
      Debug Str(FinalProgress)+"%"
      BeforeProgress = FinalProgress
    EndIf
    
  Until Eof(0)
  CloseFile(0)
  ProcedureReturn #True
  EndProcedure
  
  Procedure SpredDir(File$,*AESKey,*IniVector)
    Global Dim dirs.s(98000)
    Global Dim file.s(980000)
    CurrDir$ = GetCurrentDirectory()
InitialPath$ = "C:\"   ; set initial path to display (could also be blank)
Path$ = PathRequester("Create Package:", InitialPath$)
Base$ = Path$
If CurrDir$ = Base$
  MessageRequester("Error","Current directory select not allowed.")
  ProcedureReturn #False
EndIf
PrintN("Print: "+Base$)
PrintN("Please wait while scanning directory...")
dirs(0) = Path$
scan = 0
scanto = 1
filesindim = 0
  
 While Not scan = scanto
  If ExamineDirectory(0, path$, "*.*")  
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File
        Type$ = "[File] "
        Size$ = " (Size: " + DirectoryEntrySize(0) + ")"
        filename$ = DirectoryEntryName(0)
        file(filesindim) = path$+filename$
        filesindim = filesindim+1
        ;PrintN("File: "+path$+filename$+" Size:"+Size$)
        
      Else
        Type$ = "[Directory] "
        Size$ = "" ; A directory doesn't have a size
        dirname$ = DirectoryEntryName(0)
        If dirname$ = "." Or dirname$ = ".."
          Goto enddir
        EndIf
        
        ;PrintN("Directory: "+path$+dirname$+"\")
        dirs(scanto) = path$+dirname$+"\"
        scanto = scanto + 1
        enddir:
      EndIf
      
      Debug Type$ + DirectoryEntryName(0) + Size$
    Wend
    FinishDirectory(0)
    scan = scan + 1
  Else
    PrintN("Error: Directory Can't be read :"+path$+dirname$+"\")
    scan = scan + 1
    path$ = dirs(scan)
  EndIf
  path$ = dirs(scan)
  If path$ = ""
    Goto out
  EndIf
Wend
out:

ClearConsole()
PrintN("Please wait while adding Files to combined file...")
UseTARPacker()
Filename$ = Str(Random(99999))+"BR"+Str(Random(99999))+".tar"
Debug CreatePack(1,"Package\"+filename$)
While file(dimnumb)
  dimnumb = dimnumb+1
  Fileselect$ = file(dimnumb)
  FileTarPath$ = RemoveString(Fileselect$,Base$)
  FileTarPath$ = LTrim(FileTarPath$)
  Debug FileTarPath$
  AddPackFile(1,Fileselect$,FileTarPath$)
Wend
PrintN(Str(dimnumb))
ClosePack(1)
PrintN("Creating Encypted package...")
If SpredFile("Package\"+Filename$,*AESKey,*IniVector,*ProgressOut)
PrintN("Cleaning up...")
DeleteFile("Package\"+Filename$)
PrintN("Done.")
ProcedureReturn #True
Else
  PrintN("Error, Spread File did not finish.")
  ProcedureReturn #False
EndIf

  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 172
; FirstLine = 135
; Folding = -
; EnableThread
; EnableXP
; Executable = ..\Testing modules\Filetest.exe


DeclareModule FileUtil
  CreateDirectory("FileTmp")
  CreateDirectory("FileTmp\InProgress")
  CreateDirectory("FileTmp\Processing")
  CreateDirectory("Package")
  Declare SpredFile(File$,*AESKey,*IniVector,*ProgressOut)
  Declare SpredDir(*AESKey,*IniVector)
  Declare FileThreadWatcher(NullVar)
  Global FileTarMutex = CreateMutex()
  Global FileZipMutex = CreateMutex()
  Global InfoPassMutex = CreateMutex()
  Global ThreadStatMutex = CreateMutex()
  Structure part
    Checksum.s
    filefinger.s
    Compressed.i
  EndStructure
  
  Structure SprdDirPassInfo
    File.s
    aesmem.i
    Inivect.i
  EndStructure
  
  Structure ThrdJob
    ID.s
    Job.s
    Status.s
    Message.s
  EndStructure
  
  Global NewMap FileInfopass.SprdDirPassInfo()
  Global NewMap FileThreads.ThrdJob()
  CreateThread(@FileThreadWatcher(),46)
  
EndDeclareModule

Module FileUtil
  Declare SpredDirThread(ProcessID)
  
  Procedure FileThreadWatcher(NullVar)
    Begin:
    LockMutex(ThreadStatMutex)
    While NextMapElement(FileThreads())
      Status$ = Filethreads() \Status
      If Status$ = "Close"
        DeleteMapElement(FileThreads())
      EndIf
    Wend
    ResetMap(FileThreads())
    UnlockMutex(ThreadStatMutex)
    Delay(800)
    Goto begin
  EndProcedure
  
  
  Procedure SpredDir(*AESKey,*IniVector)
    InitialPath$ = "C:\"   ; set initial path to display (could also be blank)
    Path$ = PathRequester("Create Package:", InitialPath$)
    ProcessID = Random(99999)+Random(99999)
    FileInfopass(Str(ProcessID)) \aesmem = *AESKey
    FileInfopass() \File = Path$
    FileInfopass() \Inivect = *IniVector
    thread = CreateThread(@SpredDirThread(),ProcessID)
    ProcedureReturn ProcessID
  EndProcedure
  
  Procedure SpredFile(File$,*AESKey,*IniVector,*ProgressOut)
    NewMap Files.part(2000000)
    UseCRC32Fingerprint()
    UseSHA3Fingerprint()
    UseZipPacker()
    UniNumber = Random(1000)
 Debug File$
Size.i = 1024*4000
; --------------
OpenFile(UniNumber,File$)
Filename$ = GetFilePart(File$)
CreateDirectory("FileTmp\Processing\"+Filename$)
FileSize.i = Lof(UniNumber)
Parts.d = Filesize.i/Size.i
; ---------------
Parts = Round(Parts.d,#PB_Round_Up)
If parts = 0 
  MessageRequester("Internal Error","Package does not meet size requirements.")
  ProcedureReturn #False
EndIf

CmpressFile = Random(1000)

redo:
Repeat
  *Split = AllocateMemory(Size.i)
  Actread = ReadData(UniNumber,*Split,Size.i)
  FileFinger$ = Fingerprint(*Split,Actread,#PB_Cipher_CRC32)
  CheckSum$ = Fingerprint(*Split,ActRead,#PB_Cipher_SHA3)
  If FileSize(FileFinger$) = -1
    *Encoded = AllocateMemory(Actread+32)
    *Compressed = AllocateMemory(Actread+32)
    OpenFile(CmpressFile,"FileTmp\Processing\"+Filename$+"\"+FileFinger$)
    Compdata = CompressMemory(*Split,Actread+32,*Compressed,Actread+32,#PB_PackerPlugin_Zip,9)
    If Compdata = 0
      Compdata = AESEncoder(*Split,*Encoded,Actread,*AESKey,256,*IniVector)
    Else
      Compressed = 1
     AESEncoder(*Compressed,*Encoded,Actread,*AESKey,256,*IniVector)
   EndIf
   
    
    WriteData(CmpressFile,*Encoded,Compdata)
    Partcount = Partcount+1
    CloseFile(CmpressFile)
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
      ;Debug Str(FinalProgress)+"%"
      BeforeProgress = FinalProgress
    EndIf
    
  Until Eof(UniNumber)
  CloseFile(UniNumber)
  ProcedureReturn #True
  EndProcedure
  
  Procedure SpredDirThread(ProcessID)
    LockMutex(InfoPassMutex)
    Path$ = FileInfopass(Str(ProcessID)) \File 
    *AESKey = FileInfopass() \aesmem
    *IniVector = FileInfopass() \Inivect
    DeleteMapElement(FileInfopass(),Str(ProcessID))
    UnlockMutex(InfoPassMutex)
    
    LockMutex(ThreadStatMutex)
    Filethreads(Str(ProcessID)) \ID = Str(ProcessID)
    Filethreads() \Job = "Scanning Directory"
    Filethreads() \Status = "Processing..."
    Filethreads() \Message = ""
    UnlockMutex(ThreadStatMutex)
     Dim dirs.s(98000)
     Dim file.s(980000)
    CurrDir$ = GetCurrentDirectory()
Base$ = Path$
If CurrDir$ = Base$
  MessageRequester("Error","Current directory select not allowed.")
EndIf
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
        
        LockMutex(ThreadStatMutex)
        Filethreads() \Message = Filename$
        UnlockMutex(ThreadStatMutex)
        
      Else
        Type$ = "[Directory] "
        Size$ = "" ; A directory doesn't have a size
        dirname$ = DirectoryEntryName(0)
        If dirname$ = "." Or dirname$ = ".."
          Goto enddir
        EndIf
        
        dirs(scanto) = path$+dirname$+"\"
        scanto = scanto + 1
        enddir:
      EndIf
      
      ;Debug Type$ + DirectoryEntryName(0) + Size$
    Wend
    FinishDirectory(0)
    scan = scan + 1
  Else
    scan = scan + 1
    path$ = dirs(scan)
  EndIf
  path$ = dirs(scan)
  If path$ = ""
    Goto out
  EndIf
Wend
out:

    LockMutex(ThreadStatMutex)
    Filethreads(Str(ProcessID)) \ID = Str(ProcessID)
    Filethreads() \Job = "Packing Tar..."
    Filethreads() \Status = "Packing..."
    Filethreads() \Message = ""
    UnlockMutex(ThreadStatMutex)

UseTARPacker()
Filename$ = Str(Random(99999))+"BR"+Str(Random(99999))+".tar"
UniNumber = Random(1000)
CreatePack(UniNumber,"FileTmp\InProgress\"+Filename$)
While file(dimnumb)
  dimnumb = dimnumb+1
  Fileselect$ = file(dimnumb)
  FileTarPath$ = RemoveString(Fileselect$,Base$)
  FileTarPath$ = LTrim(FileTarPath$)
  LockMutex(ThreadStatMutex)
  Writestrmem$ = "Writing: "+FileTarPath$
  Filethreads(Str(ProcessID)) \Message = Writestrmem$
  UnlockMutex(ThreadStatMutex)
  AddPackFile(UniNumber,Fileselect$,FileTarPath$)
Wend
ClosePack(UniNumber)

If SpredFile("FileTmp\InProgress\"+Filename$,*AESKey,*IniVector,*ProgressOut)
  ;DeleteFile("FileTmp\InProgress\"+Filename$)
  LockMutex(ThreadStatMutex)
  Filethreads(Str(ProcessID)) \Status = "Close"
  UnlockMutex(ThreadStatMutex)
ProcedureReturn #True
Else
  LockMutex(ThreadStatMutex)
  Filethreads(Str(ProcessID)) \Status = "Error."
  UnlockMutex(ThreadStatMutex)
  ProcedureReturn #False
EndIf

  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 232
; FirstLine = 129
; Folding = v-
; EnableThread
; EnableXP
; EnableOnError
; Executable = ..\Testing modules\Filetest.exe
; Debugger = Console
; EnablePurifier
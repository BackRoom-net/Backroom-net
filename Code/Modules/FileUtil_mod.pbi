

DeclareModule FileUtil
  CreateDirectory("FileTmp")
  CreateDirectory("FileTmp\InProgress")
  CreateDirectory("FileTmp\Processing")
  CreateDirectory("Package")
  Declare SpredFile(File$,*AESKey,*IniVector,*ProgressOut,ProcessID)
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
    EnableGraphicalConsole(1)
    ClearConsole()
    PrintN("(Use < And > To move through items. Press enter to change value.)")
    Delay(1500)
    cony = 1
    RotoPos = 0
    max = 1
    ConsoleLocate(0,cony)
    ClearConsole()
    Repeat
    key$ = Inkey()
    If key$ <> ""
      If key$ = ","
        If Rotopos <> 0
          Rotopos = Rotopos-1
        EndIf
      EndIf
      
      If key$ = "."
        If Rotopos <> max
          Rotopos = Rotopos+1
        EndIf
      EndIf
      
      If Asc(Key$) = 13
      ClearConsole()  
      Select RotoPos
          
        Case 0
          Print("New Value:")
          New$ = Input()
          Prefs::InsertPrefS("LastPckName",New$,1)
          
        Case 1
          ClearConsole()
          Break
      EndSelect
      
      EndIf
      
    Select RotoPos
        
      Case 0
        ClearConsole()
        Print("Name:"+Prefs::retPrefS("LastPckName"))
        
      Case 1
        ClearConsole()
        Print("Continue")
    EndSelect
  Else
    Delay(90)
  EndIf
    Until Close = 1  
      
    InitialPath$ = "C:\"   ; set initial path to display (could also be blank)
    Path$ = PathRequester("Create Package:", InitialPath$)
    ProcessID = Random(99999)+Random(99999)
    Debug ProcessID
    FileInfopass(Str(ProcessID)) \aesmem = *AESKey
    FileInfopass() \File = Path$
    FileInfopass() \Inivect = *IniVector
    thread = CreateThread(@SpredDirThread(),ProcessID)
    ProcedureReturn ProcessID
  EndProcedure
  
  Procedure SpredFile(File$,*AESKey,*IniVector,*ProgressOut,ProcessID)
    Structure plc
      file.s
      compressed.i
      actual.i
      CheckSum.s
    EndStructure
    
    NewMap compfile.plc()
    NewMap Files.part(2000000)
    UseCRC32Fingerprint()
    UseSHA3Fingerprint()
    UseZipPacker()
    UniNumber = Random(1000)
    Debug File$
    PackageName$ = Str(ProcessID)
Size.i = 1024*4000
; --------------
OpenFile(UniNumber,File$)
Filename$ = GetFilePart(File$)
CreateDirectory("FileTmp\Processing\"+PackageName$)
FileSize.i = Lof(UniNumber)
Parts.d = Filesize.i/Size.i
Megs = Filesize.i/1000000
Debug megs
; --------------


Message$ = "New Package process: "+Str(UniNumber)+Chr(10)
Message$ = Message$+"File to encrypt: "+File$+Chr(10)
Message$ = Message$+"File Parts calculated: "+Str(Round(Parts.d,#PB_Round_Up))
Debug Message$
Log::GenLogadd(Str(UniNumber),"THREAD",Message$,"SpreadFile()")
Proforma::ProformaMakeinst("FileUtil_"+Str(UniNumber))
Proforma::ProformaS("FileUtil_"+Str(UniNumber))


; ---------------


Parts = Round(Parts.d,#PB_Round_Up)
If parts = 0 
  MessageRequester("Internal Error","Package does not meet size requirements.")
  ProcedureReturn #False
EndIf

CmpressFile = Random(1000)
LockMutex(ThreadStatMutex)
Filethreads(Str(ProcessID)) \Job = "Encrypting..."
Filethreads() \Status = "Starting up.."
UnlockMutex(ThreadStatMutex)



redo:
Repeat
  *Split = AllocateMemory(Size.i)
  Actread = ReadData(UniNumber,*Split,Size.i)
  FileFinger$ = Fingerprint(*Split,Actread,#PB_Cipher_CRC32)
  CheckSum$ = Fingerprint(*Split,ActRead,#PB_Cipher_SHA3)
  If FileSize(FileFinger$) = -1
    *Encoded = AllocateMemory(Actread+32)
    *Compressed = AllocateMemory(Actread+32)
    OpenFile(CmpressFile,"FileTmp\Processing\"+PackageName$+"\"+FileFinger$)
    ProcessingString$ = "FileTmp\Processing\"+PackageName$+"\"+FileFinger$
     LockMutex(ThreadStatMutex)
     Filethreads(Str(ProcessID)) \Message = ProcessingString$
     Filethreads() \Status = "Encrypting File: "+Str(parts)+"/"+Str(Partcount)
     UnlockMutex(ThreadStatMutex)
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
    
    compfile(Str(Partcount)) \CheckSum = Checksum$
    compfile() \compressed = Compdata
    Compfile() \file = FileFinger$
    Compfile() \actual = Actread
    
    Compdata = 0
  Else
    MessageRequester("Internal Error","CRC32 Data match. Internal error, Parts: "+Str(Partcount))
    End
  EndIf
  
  
  files(Str(Partcount)) \Checksum = CheckSum$
  Files() \Compressed = Compdata
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
  If CreateJSON(0)
    InsertJSONMap(JSONValue(0), compfile())
    SaveJSON(0,"FileTmp\Processing\"+PackageName$+"\Order.json", #PB_JSON_PrettyPrint)
  EndIf
  FreeMap(compfile())
  Proforma::ProformaE("FileUtil_"+Str(UniNumber))
  ms.i = Proforma::ProformaSpillResult("FileUtil_"+Str(UniNumber))
  Log::GenLogadd(Str(UniNumber),"THREAD","File Process "+Str(Uninumber)+" Finished after "+Str(ms)+" ms","SpreadFile()")
  Proforma::ProformaEraseInst("FileUtil_"+Str(UniNumber))
  ProcedureReturn #True
  EndProcedure
  
  Procedure SpredDirThread(ProcessID)
    ;- > Beginning of thread
    ;- > Get info from memory
    LockMutex(InfoPassMutex)
    Path$ = FileInfopass(Str(ProcessID)) \File 
    *AESKey = FileInfopass() \aesmem
    *IniVector = FileInfopass() \Inivect
    DeleteMapElement(FileInfopass(),Str(ProcessID))
    UnlockMutex(InfoPassMutex)
    
    
    ;- > Scan direcotory
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
        
      Else
        Type$ = "[Directory] "
        Size$ = "" ; A directory doesn't have a size
        dirname$ = DirectoryEntryName(0)
        If dirname$ = "." Or dirname$ = ".."
          Goto enddir
        EndIf
        LockMutex(ThreadStatMutex)
        Filethreads(Str(ProcessID)) \Message = Filename$
        UnlockMutex(ThreadStatMutex)
        
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



;- > Send status to external
    LockMutex(ThreadStatMutex)
    Filethreads(Str(ProcessID)) \ID = Str(ProcessID)
    Filethreads() \Job = "Packing Tar..."
    Filethreads() \Status = "Packing..."
    Filethreads() \Message = ""
    UnlockMutex(ThreadStatMutex)
    
    ;- > Pack Tar __________
    ;- filenames
UseTARPacker()
Filename$ = Str(Random(99999))+"BR"+Str(Random(99999))+".tar"     ;setting filenames for later
FilenameNull$ = Str(Random(99999))+"BR"+Str(Random(99999))+".tar" ;more filenames
UniNumber = Random(1000)                                          ;random number for opening a pack.
                                                             ; I do this because there can be problems with using the some numbers.

;- create pack
CreatePack(UniNumber,"FileTmp\InProgress\"+Filename$)        ;create temp Tar file.
CreateDirectory("FileTmp\Processing\"+Str(ProcessID))        ;Create a directory in temp for later.
OpenFile(45,"FileTmp\InProgress\TarDef."+FilenameNull$+".ls"); Opens the directory index for the Tar file.


While file(dimnumb)                                   ;while there are files in the directory listing
  dimnumb = dimnumb+1                                 ;add 1 to dimnumb
  Fileselect$ = file(dimnumb)                         ;put the directory in a variable for modifying.
  FileTarPath$ = RemoveString(Fileselect$,Base$)      ; Modifying stuff.
  FileTarPath$ = LTrim(FileTarPath$)
  LockMutex(ThreadStatMutex)
  Writestrmem$ = "Writing: "+FileTarPath$
  Filethreads(Str(ProcessID)) \Message = Writestrmem$
  UnlockMutex(ThreadStatMutex)
  AddPackFile(UniNumber,Fileselect$,FileTarPath$)
  WriteStringN(45,FileTarPath$)
Wend
ClosePack(UniNumber)
CloseFile(45)
tardp = Random(9999,1)
CreatePack(tardp,"FileTmp\Processing\"+Str(ProcessID)+"\defdir.packed")
AddPackFile(tardp,"FileTmp\InProgress\TarDef."+FilenameNull$+".ls","Fs.dat")
DeleteFile("FileTmp\InProgress\TarDef."+FilenameNull$+".ls")
ClosePack(tardp)

If SpredFile("FileTmp\InProgress\"+Filename$,*AESKey,*IniVector,*ProgressOut,ProcessID)
  DeleteFile("FileTmp\InProgress\"+Filename$)
  LockMutex(ThreadStatMutex)
  Filethreads(Str(ProcessID)) \Status = "Close"
  FreeArray(file())
  FreeArray(file())
  UnlockMutex(ThreadStatMutex)
ProcedureReturn #True
Else
  LockMutex(ThreadStatMutex)
  Filethreads(Str(ProcessID)) \Status = "Logged Fatal Error"
  UnlockMutex(ThreadStatMutex)
  ProcedureReturn #False
EndIf

  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 209
; FirstLine = 57
; Folding = y-
; EnableThread
; EnableXP
; EnableOnError
; Executable = ..\Testing modules\Filetest.exe
; Debugger = Console
; EnablePurifier
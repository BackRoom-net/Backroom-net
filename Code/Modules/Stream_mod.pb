DeclareModule stream
  Declare.i CreateStreamSingle(Name_opt$,FilePath$,Writeout_opt$,compression)
  Declare.i LoadStreamSequence(StreamID,Path$)
  Declare.i GetStreamPartAmmount(StreamID)
  Declare.s LoadStreamPiece(StreamID,num)
  Declare.i RetrieveMemAddress(FromLoadStream$)
  Declare.i RetrieveActRead(FromLoadStream$)
  Declare.s CreateTempfolder()
  Declare.s RetrieveStreamFileName(StreamID) 
  Declare CreateStreamPack(Name_opt$,DirPath$,Writeout_opt$,compression)
  Declare.i calculateParts(FilePath$)
  Structure pf
    parts.i
    files.s
    Path.s
    Location.s
  EndStructure
  Global NewMap StreamMap.pf()
EndDeclareModule

Module stream
  
  ; Creating Stream Files
  
 Procedure.i CreateStreamSingle(Name_opt$,FilePath$,Writeout_opt$,compression)
 UseTARPacker()
    UseBriefLZPacker()
    UseLZMAPacker()
    
    ; compression is 1-4
    ; 1 uses TAR and no compression
    ; 2 uses Breif with medium compression
    ; 3 uses LZMA with low compression
    ; 4 uses LAMA with High compression
    
    If FileSize(FilePath$) < 0
      ProcedureReturn 0
    EndIf
    

    
    ; now post precessing.
    OpenFile(1,Writeout_opt$+Name_opt$+".stream")
    WriteStringN(1,Name_opt$)
    
      Select compression
          Case 1
            CreatePack(1,Writeout_opt$+Name_opt$+".pack",#PB_PackerPlugin_Tar,1)
          Case 2
            CreatePack(1,Writeout_opt$+Name_opt$+".pack",#PB_PackerPlugin_BriefLZ,5)
          Case 3
            CreatePack(1,Writeout_opt$+Name_opt$+".pack",#PB_PackerPlugin_Lzma,3)
          Case 4
            CreatePack(1,Writeout_opt$+Name_opt$+".pack",#PB_PackerPlugin_Lzma,9)
        EndSelect
        
      WriteStringN(1,"package")


        localfile$ = GetFilePart(FilePath$)
        PrintN(localfile$)
        AddPackFile(1,FilePath$,localfile$)
        WriteStringN(1,localfile$)

    CloseFile(1)
    ClosePack(1)
    ProcedureReturn 1
  EndProcedure
  
  Procedure.i LoadStreamSequence(StreamID, FileLocation$)
    Debug "Loading Stream Sequence..."
    If FindMapElement(StreamMap(), Str(StreamID))
      ProcedureReturn 0
    Else
      
     If OpenFile(1,FileLocation$)
       FilePath$ = GetPathPart(FileLocation$)
       packname$ = GetFilePart(FileLocation$,#PB_FileSystem_NoExtension)
       If OpenFile(2,FilePath$+packname$+".pack")
         CloseFile(2)
        Parts = calculateParts(FilePath$+packname$+".pack")
        AddMapElement(StreamMap(),Str(StreamID))
        StreamMap(Str(StreamID))\Path = FilePath$
        StreamMap(Str(StreamID))\parts = Parts
        StreamMap(Str(StreamID))\Location = FilePath$+packname$+".pack"
        ; test stream file
        OpenFile(1,FileLocation$)
        validate_name$ = ReadString(1)
        If validate_name$ = packname$
          Debug "Pack name valid"
        Else
          Debug "Error. Pack not validated."
        EndIf
        ReadString(1) ;to get rid of extra line that says "package"
        
        While Not Eof(1)
          file$ = ReadString(1)
          StreamMap(Str(StreamID))\files = StreamMap(Str(StreamID))\files+file$+"|"
        Wend
        
        CloseFile(1)
        ; 
      Else
         Debug "Invalid File"
         ; Leave open for return value
         End
       EndIf
     Else
       MessageRequester("Invalid package","Was unable to read "+Path$+".stream If this looks wrong, it has been reported in the log.")
     EndIf


  
  
EndIf
  EndProcedure
  
  Procedure.s LoadStreamPiece(StreamID,num)
    parts = GetStreamPartAmmount(StreamID)
    pathToFile$ = StreamMap(Str(StreamID))\Location
    If parts < num
      ProcedureReturn "0"
    EndIf
    
    
    Pos = 65535*num
    If OpenFile(1,pathToFile$)
      FileSeek(1,Pos)
      *PieceMemory = AllocateMemory(65535)
      actread = ReadData(1,*PieceMemory,65535)
      CloseFile(1)
      ProcedureReturn Str(*PieceMemory)+"-"+Str(actread)
    Else
      ProcedureReturn "0"
    EndIf
    
      
  EndProcedure
  
  Procedure.i GetStreamPartAmmount(StreamID)
    If FindMapElement(StreamMap(),Str(StreamID))
      parts = StreamMap(Str(StreamID))\parts
      ProcedureReturn parts
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
  
  ; Creating Stream Pack
  
  Procedure CreateStreamPack(Name_opt$,DirPath$,Writeout_opt$,compression)
    UseTARPacker()
    UseBriefLZPacker()
    UseLZMAPacker()
    
    ; compression is 1-4
    ; 1 uses TAR and no compression
    ; 2 uses Breif with medium compression
    ; 3 uses LZMA with low compression
    ; 4 uses LAMA with High compression
    
    
    If FileSize(DirPath$) = -2
      Path$ = DirPath$
      baselen = Len(Path$)
       Dim dirs.s(980000)
       Dim file.s(980000)
       Dim local.s(980000)
       CurrDir$ = GetCurrentDirectory()
       Base$ = Path$
        If CurrDir$ = Base$
          MessageRequester("Error","Current directory select not allowed.")
          End
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
        thislen = Len(path$+filename$)
        localpath$ = Right(path$+filename$,thislen-baselen)
        local(filesindim) = localpath$
        filesindim = filesindim+1
        
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
    Else
      Debug "Not a directory"
    EndIf
    
    ; now post precessing.
    PrintN("post processing...")
    OpenFile(1,Writeout_opt$+Name_opt$+".stream")
    WriteStringN(1,Name_opt$)
    
      Select compression
        Case 0
          compress_false = 1
          Case 1
            CreatePack(1,Writeout_opt$+Name_opt$+".pack",#PB_PackerPlugin_Tar,1)
          Case 2
            CreatePack(1,Writeout_opt$+Name_opt$+".pack",#PB_PackerPlugin_BriefLZ,5)
          Case 3
            CreatePack(1,Writeout_opt$+Name_opt$+".pack",#PB_PackerPlugin_Lzma,3)
          Case 4
            CreatePack(1,Writeout_opt$+Name_opt$+".pack",#PB_PackerPlugin_Lzma,9)
        EndSelect
        
      WriteStringN(1,"package")
    
    
    
    cycle = 0
    While file(cycle) <> ""
      process$ = file(cycle)
      localfile$ = local(cycle)

        PrintN(localfile$)
        AddPackFile(1,process$,localfile$)
        WriteStringN(1,localfile$)

      cycle+1
    Wend
    CloseFile(1)
    ClosePack(1)
    

    FreeArray(file())
    FreeArray(dirs())
    FreeArray(local())
    
    
  EndProcedure
  
  
  ; Utility 
  
  Procedure.i RetrieveMemAddress(FromLoadStream$)
    If FromLoadStream$ = "0"
      Debug "Error, Load Stream Piece threw error: 0"
      ProcedureReturn 0
    Else
      memaddress = Val(StringField(FromLoadStream$,1,"-"))
      ProcedureReturn memaddress
    EndIf
    
  EndProcedure
  
  Procedure.i RetrieveActRead(FromLoadStream$)
    If FromLoadStream$ = "0"
      Debug "Error, Load Stream Piece threw error: 0"
      ProcedureReturn 0
    Else
      actread = Val(StringField(FromLoadStream$,2,"-"))
      ProcedureReturn actread
    EndIf
  EndProcedure
  
  Procedure.s RetrieveStreamFileName(StreamID)  
    If FindMapElement(StreamMap(),Str(StreamID))
      FullPath$ = StreamMap(Str(StreamID))\Path
      FileName$ = GetFilePart(FullPath$)
      ProcedureReturn FileName$
    Else
      ProcedureReturn "0"
    EndIf
  EndProcedure
  
  Procedure.s CreateTempfolder()
    checks:
    tempfolder$ = Str(Random(999999))
    If FileSize("temp\") = -2
      If FileSize("temp\"+tempfolder$) = -1
        CreateDirectory("temp\"+tempfolder$)
        ProcedureReturn "temp\"+tempfolder$+"\"
      Else
        Goto checks
      EndIf
    Else
      CreateDirectory("temp\")
      Goto checks
    EndIf
    
      
  EndProcedure
  
  Procedure.i calculateParts(FilePath$)
Maxbytes = 65535
Filepos = 0

If OpenFile(1,Filepath$)
  filebytes = Lof(1)
  parts.f = filebytes / Maxbytes
  pieces = Round(parts.f,#PB_Round_Up )
Else
  Debug "Couldn't open file"
  ProcedureReturn 0
EndIf
CloseFile(1)

    ProcedureReturn pieces
  EndProcedure
  
    
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 123
; FirstLine = 20
; Folding = zA-
; EnableXP
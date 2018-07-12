
;   Description: Encryption Module
;        Author: Ruben Rodriguez
;          Date: 11/13/17
;            OS: Windows/XP/Vista/7/10
;    Notes:
;    Please Do not Distribute. - Do not Edit.
;    Module is crucial to User Security.

DeclareModule Cipher
  Structure CipherSuite ; Structure...
    KeyMem.i
    MasterMem.i
    Base64key.s         ;Structure...
    Base64Master.s
    MasterCRC32.s
    MasterMD5.s         ;God
    MasterSHA1.s        ;I 
    MasterSHA2.s        ;Love
    MasterSHA3.s        ;Structures
  EndStructure          ;Message me if you get it.
  OpenCryptRandom()
  UseSHA1Fingerprint()
  UseSHA2Fingerprint()
  UseSHA3Fingerprint()
  UseMD5Fingerprint()
  UseCRC32Fingerprint()
  Global NewMap EncryptStorage.CipherSuite()  ;The map where all of our Ciphers are stored.
  Declare GenerateKeySequence(ID$)
EndDeclareModule

Module Cipher
  ;--
  Procedure GenerateKeySequence(ID$)
    ;Generation of Initial 16-Byte key
    *Key = AllocateMemory(16)           ; extra Bytes to avoid overflow from full memory
    Debug CryptRandomData(*Key,16)
    OpenFile(1,"IniVect.key")
    WriteData(1,*Key,16)
    CloseFile(1)
    ; --------
    ;Generation of 28-byte Master key
    *Master = AllocateMemory(29)        ; extra one byte to avoid overflow
    Debug CryptRandomData(*Master,28)
    OpenFile(1,"Master.key")
    WriteData(1,*Master,29)
    CloseFile(1)
    ; --------
    ;Generation of Base64 key
    Base64Key$ = Base64Encoder(*key,16)
    ; --------
    ;Generation of Base64 Master Key
    base64Master$ = Base64Encoder(*Master,28)
    ; --------
    ; --------
    MasterCRC32$ = Fingerprint(*Master,28,#PB_Cipher_CRC32)   ;Lots of fingerprints...
    MasterMD5$ = Fingerprint(*Master,28,#PB_Cipher_MD5)
    MasterSHA1$ = Fingerprint(*Master,28,#PB_Cipher_SHA1)
    MasterSHA2$ = Fingerprint(*Master,28,#PB_Cipher_SHA2,512)
    MasterSHA3$ = Fingerprint(*Master,28,#PB_Cipher_SHA3,512)
    
    EncryptStorage(ID$) \KeyMem = *key
    EncryptStorage() \MasterMem = *Master
    EncryptStorage() \Base64key = Base64Key$
    EncryptStorage() \Base64Master = base64Master$
    EncryptStorage() \MasterCRC32 = MasterCRC32$
    EncryptStorage() \MasterMD5 = MasterMD5$
    EncryptStorage() \MasterSHA1 = MasterSHA1$
    EncryptStorage() \MasterSHA2 = MasterSHA2$
    EncryptStorage() \MasterSHA3 = MasterSHA3$
    

    
    
    
    

    
  EndProcedure
  ;--
  
  
EndModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 38
; FirstLine = 22
; Folding = -
; EnableXP
; CompileSourceDirectory
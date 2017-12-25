DeclareModule Cipher
  Structure CipherSuite
    KeyMem.i
    MasterMem.i
    Base64key.s
    Base64Master.s
    MasterCRC32.s
    MasterMD5.s
    MasterSHA1.s
    MasterSHA2.s
    MasterSHA3.s
    AESMem.i
  EndStructure
  OpenCryptRandom()
  UseSHA1Fingerprint()
  UseSHA2Fingerprint()
  UseSHA3Fingerprint()
  UseMD5Fingerprint()
  UseCRC32Fingerprint()
  Global NewMap EncryptStorage.CipherSuite()
  Declare GenerateKeySequence()
EndDeclareModule

Module Cipher
  ;--
  Procedure GenerateKeySequence()
    ;Generation of Initial 16-Byte key
    *Key = AllocateMemory(17)
    Debug CryptRandomData(*Key,16)
    ; --------
    ;Generation of 28-byte Master key
    *Master = AllocateMemory(29)
    Debug CryptRandomData(*Key,28)
    ; --------
    ;Generation of Base64 key
    Base64Key$ = Base64Encoder(*key,16)
    ; --------
    ;Generation of Base64 Master Key
    base64Master$ = Base64Encoder(*Master,28)
    ; --------
    ; --------
    MasterCRC32$ = Fingerprint(*Master,28,#PB_Cipher_CRC32)
    MasterMD5$ = Fingerprint(*Master,28,#PB_Cipher_MD5)
    MasterSHA1$ = Fingerprint(*Master,28,#PB_Cipher_SHA1)
    MasterSHA2$ = Fingerprint(*Master,28,#PB_Cipher_SHA2,512)
    MasterSHA3$ = Fingerprint(*Master,28,#PB_Cipher_SHA3,512)
    
    EncryptStorage("Master") \KeyMem = *key
    EncryptStorage() \MasterMem = *Master
    EncryptStorage() \Base64key = Base64Key$
    EncryptStorage() \Base64Master = base64Master$
    EncryptStorage() \MasterCRC32 = MasterCRC32$
    EncryptStorage() \MasterMD5 = MasterMD5$
    EncryptStorage() \MasterSHA1 = MasterSHA1$
    EncryptStorage() \MasterSHA2 = MasterSHA2$
    EncryptStorage() \MasterSHA3 = MasterSHA3$
    
    *AESMem = AllocateMemory(32)
    *Base64Key = AllocateMemory(24)
    PokeS(*Base64Key,Base64Key$)
    
    If AESEncoder(*Master,*AESMem,28,*Base64Key,256,*Key)
      EncryptStorage() \AESMem = *AESMem
    Else
      Debug "Error"
    EndIf
    
  EndProcedure
  ;--
  
  
EndModule

; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 35
; FirstLine = 27
; Folding = -
; EnableXP
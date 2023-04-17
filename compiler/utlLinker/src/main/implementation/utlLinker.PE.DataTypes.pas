(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.PE.DataTypes;

interface

const
  cZeroByte : uint8     = $00;
  cZeroWord : uint16    = $0000;
  cDOSPageSize          = $200;
  cParagraphSize        = $10;
  cMZHeaderSizeBytes    = $40;
  cDOSMagic    : uint16 = $5A4D;
  cPESignature : uint32 = $4550;

const
  cIMAGE_NT_OPTIONAL_HDR32_MAGIC: uint16 = $010B;
  cIMAGE_NT_OPTIONAL_HDR64_MAGIC: uint16 = $020B;

const //- Machine types
  cIMAGE_FILE_MACHINE_UNKNOWN     = $0000; // The content of this field is assumed to be applicable to any machine type
  cIMAGE_FILE_MACHINE_I860        = $014d;
  cIMAGE_FILE_MACHINE_ALPHA       = $0184;
  cIMAGE_FILE_MACHINE_ALPHA64     = $0284;
  cIMAGE_FILE_MACHINE_AM33        = $01D3; // Matsushita AM33
  cIMAGE_FILE_MACHINE_AMD64       = $8664; // x64
  cIMAGE_FILE_MACHINE_ARM         = $01C0; // ARM little endian
  cIMAGE_FILE_MACHINE_ARM64       = $AA64; // ARM64 little endian
  cIMAGE_FILE_MACHINE_ARMNT       = $01C4; // ARM Thumb-2 little endian
  cIMAGE_FILE_MACHINE_EBC         = $0EBC; // EFI byte code
  cIMAGE_FILE_MACHINE_I386        = $014C; // Intel 386 or later processors and compatible processors
  cIMAGE_FILE_MACHINE_IA64        = $0200; // Intel Itanium processor family
  cIMAGE_FILE_MACHINE_LOONGARCH32 = $6232; // LoongArch 32-bit processor family
  cIMAGE_FILE_MACHINE_LOONGARCH64 = $6264; // LoongArch 64-bit processor family
  cIMAGE_FILE_MACHINE_M32R        = $9041; // Mitsubishi M32R little endian
  cIMAGE_FILE_MACHINE_MIPS16      = $0266; // MIPS16
  cIMAGE_FILE_MACHINE_MIPSFPU     = $0366; // MIPS with FPU
  cIMAGE_FILE_MACHINE_MIPSFPU16   = $0466; // MIPS16 with FPU
  cIMAGE_FILE_MACHINE_POWERPC     = $01F0; // Power PC little endian
  cIMAGE_FILE_MACHINE_POWERPCFP   = $01F1; // Power PC with floating point support
  cIMAGE_FILE_MACHINE_R3000       = $0162;
  cIMAGE_FILE_MACHINE_R4000       = $0166; // MIPS little endian
  cIMAGE_FILE_MACHINE_R10000      = $0168;
  cIMAGE_FILE_MACHINE_RISCV32     = $5032; // RISC-V 32-bit address space
  cIMAGE_FILE_MACHINE_RISCV64     = $5064; // RISC-V 64-bit address space
  cIMAGE_FILE_MACHINE_RISCV128    = $0512; // RISC-V 128-bit address space
  cIMAGE_FILE_MACHINE_SH3         = $01A2; // Hitachi SH3
  cIMAGE_FILE_MACHINE_SH3DSP      = $01A3; // Hitachi SH3 DSP
  cIMAGE_FILE_MACHINE_SH3E        = $01A4;
  cIMAGE_FILE_MACHINE_SH4         = $01A6; // Hitachi SH4
  cIMAGE_FILE_MACHINE_SH5         = $01A8; // Hitachi SH5
  cIMAGE_FILE_MACHINE_THUMB       = $01C2; // Thumb
  cIMAGE_FILE_MACHINE_WCEMIPSV2   = $0169; // MIPS little-endian WCE v2
  cIMAGE_FILE_MACHINE_TRICORE     = $0520;
  cIMAGE_FILE_MACHINE_CEF         = $0CEF;
  cIMAGE_FILE_MACHINE_CEE         = $C0EE;

const //- PE file characteristics
  cIMAGE_FILE_RELOCS_STRIPPED          : uint16 = $0001;
  cIMAGE_FILE_EXECUTABLE_IMAGE         : uint16 = $0002;
  cIMAGE_FILE_LINE_NUMS_STRIPPED       : uint16 = $0004;
  cIMAGE_FILE_LOCAL_SYMS_STRIPPED      : uint16 = $0008;
  cIMAGE_FILE_AGGRESSIVE_WS_TRIM       : uint16 = $0010;
  cIMAGE_FILE_LARGE_ADDRESS_AWARE      : uint16 = $0020;
  cIMAGE_FILE_BYTES_REVERSED_LO        : uint16 = $0080;
  cIMAGE_FILE_32BIT_MACHINE            : uint16 = $0100;
  cIMAGE_FILE_DEBUG_STRIPPED           : uint16 = $0200;
  cIMAGE_FILE_REMOVABLE_RUN_FROM_SWAP  : uint16 = $0400;
  cIMAGE_FILE_NET_RUN_FROM_SWAP        : uint16 = $0800;
  cIMAGE_FILE_SYSTEM                   : uint16 = $1000;
  cIMAGE_FILE_DLL                      : uint16 = $2000;
  cIMAGE_FILE_UP_SYSTEM_ONLY           : uint16 = $4000;
  cIMAGE_FILE_BYTES_REVERSED_HI        : uint16 = $8000;

const //- DLL Characteristics
  cIMAGE_DLLCHARACTERISTICS_HIGH_ENTROPY_VA       = $0020;
  cIMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE          = $0040;
  cIMAGE_DLLCHARACTERISTICS_FORCE_INTEGRITY       = $0080;
  cIMAGE_DLLCHARACTERISTICS_NX_COMPAT             = $0100;
  cIMAGE_DLLCHARACTERISTICS_NO_ISOLATION          = $0200;
  cIMAGE_DLLCHARACTERISTICS_NO_SEH                = $0400;
  cIMAGE_DLLCHARACTERISTICS_NO_BIND               = $0800;
  cIMAGE_DLLCHARACTERISTICS_APPCONTAINER          = $1000;
  cIMAGE_DLLCHARACTERISTICS_WDM_DRIVER            = $2000;
  cIMAGE_DLLCHARACTERISTICS_GUARD_CF              = $4000;
  cIMAGE_DLLCHARACTERISTICS_TERMINAL_SERVER_AWARE = $8000;

const //- Windows subsystems
  cIMAGE_SUBSYSTEM_UNKNOWN                      = 00;
  cIMAGE_SUBSYSTEM_NATIVE                       = 01;
  cIMAGE_SUBSYSTEM_WINDOWS_GUI                  = 02;
  cIMAGE_SUBSYSTEM_WINDOWS_CUI                  = 03;
  cIMAGE_SUBSYSTEM_OS2_CUI                      = 05;
  cIMAGE_SUBSYSTEM_POSIX_CUI                    = 07;
  cIMAGE_SUBSYSTEM_NATIVE_WINDOWS               = 08;
  cIMAGE_SUBSYSTEM_WINDOWS_CE_GUI               = 09;
  cIMAGE_SUBSYSTEM_EFI_APPLICATION              = 10;
  cIMAGE_SUBSYSTEM_EFI_BOOT_SERVICE_DRIVER      = 11;
  cIMAGE_SUBSYSTEM_EFI_RUNTIME_DRIVER           = 12;
  cIMAGE_SUBSYSTEM_EFI_ROM                      = 13;
  cIMAGE_SUBSYSTEM_XBOX                         = 14;
  cIMAGE_SUBSYSTEM_WINDOWS_BOOT_APPLICATION     = 16;

const //- Data directory indicies
  cIMAGE_DIRECTORY_ENTRY_EXPORT                 = 00;
  cIMAGE_DIRECTORY_ENTRY_IMPORT                 = 01;
  cIMAGE_DIRECTORY_ENTRY_RESOURCE               = 02;
  cIMAGE_DIRECTORY_ENTRY_EXCEPTION              = 03;
  cIMAGE_DIRECTORY_ENTRY_SECURITY               = 04;
  cIMAGE_DIRECTORY_ENTRY_BASERELOC              = 05;
  cIMAGE_DIRECTORY_ENTRY_DEBUG                  = 06;
  cIMAGE_DIRECTORY_ENTRY_COPYRIGHT              = 07;
  cIMAGE_DIRECTORY_ENTRY_GLOBALPTR              = 08;
  cIMAGE_DIRECTORY_ENTRY_TLS                    = 09;
  cIMAGE_DIRECTORY_ENTRY_LOAD_CONFIG            = 10;
  cIMAGE_DIRECTORY_ENTRY_BOUND_IMPORT           = 11;
  cIMAGE_DIRECTORY_ENTRY_IAT                    = 12;
  cIMAGE_DIRECTORY_ENTRY_DELAY_IMPORT           = 13;
  cIMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR         = 14;

const
  cIMAGE_SCN_TYPE_REG               = $00000000;
  cIMAGE_SCN_TYPE_DSECT             = $00000001;
  cIMAGE_SCN_TYPE_NOLOAD            = $00000002;
  cIMAGE_SCN_TYPE_GROUP             = $00000004;
  cIMAGE_SCN_TYPE_NO_PAD            = $00000008;
  cIMAGE_SCN_TYPE_COPY              = $00000010;
  cIMAGE_SCN_CNT_CODE               = $00000020;
  cIMAGE_SCN_CNT_INITIALIZED_DATA   = $00000040;
  cIMAGE_SCN_CNT_UNINITIALIZED_DATA = $00000080;
  cIMAGE_SCN_LNK_OTHER              = $00000100;
  cIMAGE_SCN_LNK_INFO               = $00000200;
  cIMAGE_SCN_TYPE_OVER              = $00000400;
  cIMAGE_SCN_LNK_REMOVE             = $00000800;
  cIMAGE_SCN_LNK_COMDAT             = $00001000;
  cIMAGE_SCN_MEM_PROTECTED          = $00004000;
  cIMAGE_SCN_NO_DEFER_SPEC_EXC      = $00004000;
  cIMAGE_SCN_GPREL                  = $00008000;
  cIMAGE_SCN_MEM_FARDATA            = $00008000;
  cIMAGE_SCN_MEM_SYSHEAP            = $00010000;
  cIMAGE_SCN_MEM_PURGEABLE          = $00020000;
  cIMAGE_SCN_MEM_16BIT              = $00020000;
  cIMAGE_SCN_MEM_LOCKED             = $00040000;
  cIMAGE_SCN_MEM_PRELOAD            = $00080000;
  cIMAGE_SCN_ALIGN_1BYTES           = $00100000;
  cIMAGE_SCN_ALIGN_2BYTES           = $00200000;
  cIMAGE_SCN_ALIGN_4BYTES           = $00300000;
  cIMAGE_SCN_ALIGN_8BYTES           = $00400000;
  cIMAGE_SCN_ALIGN_16BYTES          = $00500000;
  cIMAGE_SCN_ALIGN_32BYTES          = $00600000;
  cIMAGE_SCN_ALIGN_64BYTES          = $00700000;
  cIMAGE_SCN_ALIGN_128BYTES         = $00800000;
  cIMAGE_SCN_ALIGN_256BYTES         = $00900000;
  cIMAGE_SCN_ALIGN_512BYTES         = $00A00000;
  cIMAGE_SCN_ALIGN_1024BYTES        = $00B00000;
  cIMAGE_SCN_ALIGN_2048BYTES        = $00C00000;
  cIMAGE_SCN_ALIGN_4096BYTES        = $00D00000;
  cIMAGE_SCN_ALIGN_8192BYTES        = $00E00000;
  cIMAGE_SCN_ALIGN_MASK             = $00F00000;
  cIMAGE_SCN_LNK_NRELOC_OVFL        = $01000000;
  cIMAGE_SCN_MEM_DISCARDABLE        = $02000000;
  cIMAGE_SCN_MEM_NOT_CACHED         = $04000000;
  cIMAGE_SCN_MEM_NOT_PAGED          = $08000000;
  cIMAGE_SCN_MEM_SHARED             = $10000000;
  cIMAGE_SCN_MEM_EXECUTE            = $20000000;
  cIMAGE_SCN_MEM_READ               = $40000000;
  cIMAGE_SCN_MEM_WRITE              = $80000000;

const
  cDefaultDOSStub: array of uint8 = [
    $0E, $1F, $BA, $0E, $00, $B4, $09, $CD, $21, $B8, $01, $4C, $CD, $21, $54, $68,
    $69, $73, $20, $70, $72, $6F, $67, $72, $61, $6D, $20, $63, $61, $6E, $6E, $6F,
    $74, $20, $62, $65, $20, $72, $75, $6E, $20, $69, $6E, $20, $44, $4F, $53, $20,
    $6D, $6F, $64, $65, $2E, $0D, $0D, $0A, $24, $00, $00, $00, $00, $00, $00, $00,
    $05, $FA, $1C, $BE, $41, $9B, $72, $ED, $41, $9B, $72, $ED, $41, $9B, $72, $ED,
    $55, $F0, $77, $EC, $40, $9B, $72, $ED, $55, $F0, $71, $EC, $43, $9B, $72, $ED,
    $55, $F0, $76, $EC, $50, $9B, $72, $ED, $41, $9B, $73, $ED, $62, $9B, $72, $ED,
    $55, $F0, $73, $EC, $46, $9B, $72, $ED, $55, $F0, $7A, $EC, $43, $9B, $72, $ED,
    $55, $F0, $8D, $ED, $40, $9B, $72, $ED, $55, $F0, $70, $EC, $40, $9B, $72, $ED,
    $52, $69, $63, $68, $41, $9B, $72, $ED, $00, $00, $00, $00, $00, $00, $00, $00
  ];

type
  // https://docs.microsoft.com/en-us/windows/win32/debug/pe-format?redirectedfrom=MSDN#ms-dos-stub-image-only
  IMAGE_DOS_HEADER = packed record // DOS .EXE header
    e_magic                     : uint16;                   // Magic number  (0x5A4D = ascii for 'MZ; for Mark Zbikowski')
    e_cblp                      : uint16;                   // Bytes on last page of file
    e_cp                        : uint16;                   // Pages in file
    e_crlc                      : uint16;                   // Relocations
    e_cparhdr                   : uint16;                   // Size of header in paragraphs
    e_minalloc                  : uint16;                   // Minimum extra paragraphs needed
    e_maxalloc                  : uint16;                   // Maximum extra paragraphs needed
    e_ss                        : uint16;                   // Initial (relative) SS value
    e_sp                        : uint16;                   // Initial SP value
    e_csum                      : uint16;                   // Checksum
    e_ip                        : uint16;                   // Initial IP value
    e_cs                        : uint16;                   // Initial (relative) CS value
    e_lfarlc                    : uint16;                   // File address of relocation table
    e_ovno                      : uint16;                   // Overlay number
    e_res                       : array[ 0..3 ] of uint16;  // Reserved words
    e_oemid                     : uint16;                   // OEM identifier (for e_oeminfo)
    e_oeminfo                   : uint16;                   // OEM information; e_oemid specific
    e_res2                      : array[ 0..9 ] of uint16;  // Reserved words
    e_lfanew                    : uint32;                   // File address of new exe header ( PE signature )
  end;

  IMAGE_PE_SIGNATURE = uint32;

  // https://docs.microsoft.com/en-us/windows/win32/debug/pe-format?redirectedfrom=MSDN#coff-file-header-object-and-image
  IMAGE_FILE_HEADER = packed record
    Machine                     : uint16;
    NumberOfSections            : uint16;
    TimeDateStamp               : uint32;
    PointerToSymbolTable        : uint32;
    NumberOfSymbols             : uint32;
    SizeOfOptionalHeader        : uint16;
    Characteristics             : uint16;
  end;

  // https://docs.microsoft.com/en-us/windows/win32/debug/pe-format?redirectedfrom=MSDN#optional-header-image-only
  IMAGE_OPTIONAL_HEADER_32 = packed record
    Magic                       : uint16;
    MajorLinkerVersion          : uint8;
    MinorLinkerVersion          : uint8;
    SizeOfCode                  : uint32;
    SizeOfInitializedData       : uint32;
    SizeOfUninitializedData     : uint32;
    AddressOfEntryPoint         : uint32;
    BaseOfCode                  : uint32;
    BaseOfData                  : uint32;
    ImageBase                   : uint32;
    SectionAlignment            : uint32;
    FileAlignment               : uint32;
    MajorOperatingSystemVersion : uint16;
    MinorOperatingSystemVersion : uint16;
    MajorImageVersion           : uint16;
    MinorImageVersion           : uint16;
    MajorSubsystemVersion       : uint16;
    MinorSubsystemVersion       : uint16;
    Reserved1                   : uint32;
    SizeOfImage                 : uint32;
    SizeOfHeaders               : uint32;
    CheckSum                    : uint32;
    Subsystem                   : uint16;
    DllCharacteristics          : uint16;
    SizeOfStackReserve          : uint32;
    SizeOfStackCommit           : uint32;
    SizeOfHeapReserve           : uint32;
    SizeOfHeapCommit            : uint32;
    LoaderFlags                 : uint32;
    NumberOfRvaAndSizes         : uint32;
  end;

  IMAGE_OPTIONAL_HEADER_64 = packed record
    Magic                       : uint16;
    MajorLinkerVersion          : uint8;
    MinorLinkerVersion          : uint8;
    SizeOfCode                  : uint32;
    SizeOfInitializedData       : uint32;
    SizeOfUninitializedData     : uint32;
    AddressOfEntryPoint         : uint32;
    BaseOfCode                  : uint32;
    ImageBase                   : uint64;
    SectionAlignment            : uint32;
    FileAlignment               : uint32;
    MajorOperatingSystemVersion : uint16;
    MinorOperatingSystemVersion : uint16;
    MajorImageVersion           : uint16;
    MinorImageVersion           : uint16;
    MajorSubsystemVersion       : uint16;
    MinorSubsystemVersion       : uint16;
    Reserved1                   : uint32;
    SizeOfImage                 : uint32;
    SizeOfHeaders               : uint32;
    CheckSum                    : uint32;
    Subsystem                   : uint16;
    DllCharacteristics          : uint16;
    SizeOfStackReserve          : uint64;
    SizeOfStackCommit           : uint64;
    SizeOfHeapReserve           : uint64;
    SizeOfHeapCommit            : uint64;
    LoaderFlags                 : uint32;
    NumberOfRvaAndSizes         : uint32;
  end;

  // https://docs.microsoft.com/en-us/windows/win32/debug/pe-format?redirectedfrom=MSDN#optional-header-data-directories-image-only
  IMAGE_DATA_DIRECTORY = packed record
    VirtualAddress              : uint32;
    Size                        : uint32;
  end;

  // https://docs.microsoft.com/en-us/windows/win32/debug/pe-format?redirectedfrom=MSDN
  // https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-image_section_header
  IMAGE_SECTION_HEADER = packed record
    Name                      : array[ 0..7 ] of uint8; //  An 8-byte, null-padded UTF-8 encoded string. If the string is exactly 8 characters long, there is no terminating null.
    VirtualSize               : uint32;
    VirtualAddress            : uint32;
    SizeOfRawData             : uint32;
    PointerToRawData          : uint32;
    PointerToRelocations      : uint32;
    PointerToLinenumbers      : uint32;
    NumberOfRelocations       : uint16;
    NumberOfLinenumbers       : uint16;
    Characteristics           : uint32;
  end;

  // https://docs.microsoft.com/en-us/windows/win32/debug/pe-format#import-directory-table
  IMPORT_DIRECTORY_TABLE_ENTRY = packed record
    ImportLookupTableRVA      : uint32;
    TimeDateStamp             : uint32;
    ForwarderChain            : uint32;
    NameRVA                   : uint32;
    ThunkTableRVA             : uint32;
  end;

implementation

end.

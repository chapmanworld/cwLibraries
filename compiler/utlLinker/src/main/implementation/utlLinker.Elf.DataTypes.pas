(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.Elf.DataTypes;

interface

const
  cElfMagic            = $464C457F;  // Little endian for 0x7F, 0x45, 0x4C, 0x46 == 0x7F, 'E', 'L' 'F'

const
  ELF64_R_TYPE_SHIFT = $00;
  ELF64_R_TYPE_MASK  = $FF;
  ELF32_R_TYPE_SHIFT = $00;
  ELF32_R_TYPE_MASK  = $0F;
  ELF64_R_SYM_SHIFT  = 32;
  ELF64_R_SYM_MASK   = $FFFFFFFF;
  ELF32_R_SYM_SHIFT  = 8;
  ELF32_R_SYM_MASK   = $FFFFFF;

{$region ' ABI Constants'}

const
  ABI_SystemV          = $00;
  ABI_HPUX             = $01;
  ABI_NetBSD           = $02;
  ABI_Linux            = $03;
  ABI_GNUHurd          = $04;
  ABI_Solaris          = $06;
  ABI_AIX              = $07;
  ABI_IRIX             = $08;
  ABI_FreeBSD          = $09;
  ABI_Tru64            = $0A;
  ABI_NovellModesto    = $0B;
  ABI_OpenBSD          = $0C;
  ABI_OpenVMS          = $0D;
  ABI_NonStopKernel    = $0E;
  ABI_AROS             = $0F;
  ABI_FenixOS          = $10;
  ABI_NuxiCloudABI     = $11;
  ABI_OpenVOS          = $12;

{$endregion}
{$region ' Relocation type constants '}

const
  {$region 'x86' }
    R_386_NONE         = 00; // Field: none    Calculation: none
    R_386_32           = 01; // Field: word32  Calculation: S + A
    R_386_PC32         = 02; // Field: word32  Calculation: S + A - P
    R_386_GOT32        = 03; // Field: word32  Calculation: G + A
    R_386_PLT32        = 04; // Field: word32  Calculation: L + A - P
    R_386_COPY         = 05; // Field: none    Calculation: none
    R_386_GLOB_DAT     = 06; // Field: word32  Calculation: S
    R_386_JMP_SLOT     = 07; // Field: word32  Calculation: S
    R_386_RELATIVE     = 08; // Field: word32  Calculation: B + A
    R_386_GOTOFF       = 09; // Field: word32  Calculation: S + A - GOT
    R_386_GOTPC        = 10; // Field: word32  Calculation: GOT + A - P
    R_386_32PLT        = 11; // Field: word32  Calculation: L + A
  {$endregion}

  {$region 'x86_64'}
    R_X86_64_NONE      = 00; // Field: none    Calculation: none
    R_X86_64_64        = 01; // Field: word64  Calculation: S + A
    R_X86_64_PC32      = 02; // Field: word32  Calculation: S + A - P
    R_X86_64_GOT32     = 03; // Field: word32  Calculation: G + A
    R_X86_64_PLT32     = 04; // Field: word32  Calculation: L + A - P
    R_X86_64_COPY      = 05; // Field: none    Calculation: none
    R_X86_64_GLOB_DAT  = 06; // Field: word64  Calculation: S
    R_X86_64_JUMP_SLOT = 07; // Field: word64  Calculation: S
    R_X86_64_RELATIVE  = 08; // Field: word64  Calculation: B + A
    R_X86_64_GOTPCREL  = 09; // Field: word32  Calculation: G + GOT + A - P
    R_X86_64_32        = 10; // Field: word32  Calculation: S + A
    R_X86_64_32S       = 11; // Field: word32  Calculation: S + A
    R_X86_64_16        = 12; // Field: word16  Calculation: S + A
    R_X86_64_PC16      = 13; // Field: word16  Calculation: S + A - P
    R_X86_64_8         = 14; // Field: word8   Calculation: S + A
    R_X86_64_PC8       = 15; // Field: word8   Calculation: S + A - P
    R_X86_64_DPTMOD64  = 16; // Field: word64  Calculation:
    R_X86_64_DTPOFF64  = 17; // Field: word64  Calculation:
    R_X86_64_TPOFF64   = 18; // Field: word64  Calculation:
    R_X86_64_TLSGD     = 19; // Field: word32  Calculation:
    R_X86_64_TLSLD     = 20; // Field: word32  Calculation:
    R_X86_64_DTPOFF32  = 21; // Field: word32  Calculation:
    R_X86_64_GOTTPOFF  = 22; // Field: word32  Calculation:
    R_X86_64_TPOFF32   = 23; // Field: word32  Calculation:
    R_X86_64_PC64      = 24; // Field: word64  Calculation: S + A - P
    R_X86_64_GOTOFF64  = 25; // Field: word64  Calculation: S + A - GOT
    R_X86_64_GOTPC32   = 26; // Field: word32  Calculation: GOT + A - P
    R_X86_64_SIZE32    = 32; // Field: word32  Calculation: Z + A
    R_X86_64_SIZE64    = 33; // Field: word64  Calculation: Z +
  {$endregion}

{$endregion}
{$region ' Elf file type constants '}

const
  ET_NONE              = $0000;
  ET_REL               = $0001;
  ET_EXEC 	           = $0002;  // Executable file.
  ET_DYN 	             = $0003;  // Shared object.
  ET_CORE 	           = $0004;  // Core file.
  ET_LOOS              = $FE00;  // Reserved inclusive range. Operating system specific.
  ET_HIOS              = $FEFF;  // Reserved inclusive range. Operating system specific.
  ET_LOPROC            = $FF00;  // Reserved inclusive range. Processor specific.
  ET_HIPROC            = $FFFF;  // Reserved inclusive range. Processor specific.

{$endregion}
{$region ' Instruction set constants '}

const
  IS_Unspecified       = $0000;
  IS_SPARC             = $0002;
  IS_x86               = $0003;
  IS_MC68K             = $0004;
  IS_MC88k             = $0005;
  IS_MIPS              = $0008;
  IS_PowerPC           = $0014;
  IS_PowerPC64         = $0015;
  IS_Arm7Aarch32       = $0028;  // Upto arm-v7 / aarch32
  IS_SPARC_V9          = $002B;
  IS_IA_64             = $0032;
  IS_AMDx86_64         = $003E;
  IS_Armv8_AArch64     = $00B7;
  IS_RISC_V            = $00F3;  // and many more

{$endregion}
{$region ' Program type constants '}

const
  PT_NULL              = $00000000;  // Program header table entry unused.
  PT_LOAD 	           = $00000001;  // Loadable segment.
  PT_DYNAMIC           = $00000002;  // Dynamic linking information.
  PT_INTERP            = $00000003;  // Interpreter information.
  PT_NOTE 	           = $00000004;  // Auxiliary information.
  PT_SHLIB             = $00000005;  // Reserved.
  PT_PHDR              = $00000006;  // Segment containing program header table itself.
  PT_TLS 	             = $00000007;  // Thread-Local Storage template.
  PT_LOOS              = $60000000;  // Reserved inclusive range. Operating system specific.
  PT_HIOS              = $6FFFFFFF;  // Reserved inclusive range. Operating system specific.
  PT_LOPROC            = $70000000;	// Reserved inclusive range. Processor specific.
  PT_HIPROC            = $7FFFFFFF;  // Reserved inclusive range. Processor specific.

{$endregion}
{$region ' Section Header Type constants '}

const
  SHT_NULL             = $00000000;  // Section header table entry unused
  SHT_PROGBITS         = $00000001;  // Program data
  SHT_SYMTAB           = $00000002;  // Symbol table
  SHT_STRTAB           = $00000003;  // String table
  SHT_RELA 	           = $00000004;  // Relocation entries with addends
  SHT_HASH 	           = $00000005;  // Symbol hash table
  SHT_DYNAMIC          = $00000006;	 // Dynamic linking information
  SHT_NOTE 	           = $00000007;  // Notes
  SHT_NOBITS 	         = $00000008;  // Program space with no data (bss)
  SHT_REL 	           = $00000009;  // Relocation entries, no addends
  SHT_SHLIB            = $0000000A;  // Reserved
  SHT_DYNSYM           = $0000000B;  // Dynamic linker symbol table
  SHT_INIT_ARRAY       = $0000000E;	 // Array of constructors
  SHT_FINI_ARRAY       = $0000000F;	 // Array of destructors
  SHT_PREINIT_ARRAY    = $00000010;  // Array of pre-constructors
  SHT_GROUP            = $00000011;	 // Section group
  SHT_SYMTAB_SHNDX     = $00000012;	 // Extended section indices
  SHT_NUM              = $00000013;	 // Number of defined types.
  SHT_LOOS             = $60000000;	 // Start OS-specific.

{$endregion}
{$region ' Section header flags constants '}

const
  SHF_WRITE            = $00000001;  // Writable
  SHF_ALLOC            = $00000002;  // Occupies memory during execution
  SHF_EXECINSTR        = $00000004;  // Executable
  SHF_MERGE            = $00000010;  // Might be merged
  SHF_STRINGS          = $00000020;  // Contains null-terminated strings
  SHF_INFO_LINK        = $00000040;  // 'sh_info' contains SHT index
  SHF_LINK_ORDER       = $00000080;  // Preserve order after combining
  SHF_OS_NONCONFORMING = $00000100;  // Non-standard OS specific handling required
  SHF_GROUP            = $00000200;  // Section is member of a group
  SHF_TLS              = $00000400;  // Section hold thread-local data
  SHF_MASKOS           = $0FF00000;  // OS-specific
  SHF_ORDERED          = $04000000;  // Special ordering requirement (Solaris)
  SHF_EXCLUDE          = $08000000;  // Section is excluded unless referenced or allocated (Solaris)

{$endregion}
{$region ' Symbol bind visibility constants '}

const
  STB_LOCAL            = $00;
  STB_GLOBAL           = $01;
  STB_WEAK             = $02;
  STB_LOOS             = $10;

{$endregion}
{$region ' Symbol bind type constants '}

const
  STT_NOTYPE           = 0;
  STT_OBJECT           = 1;
  STT_FUNC             = 2;
  STT_SECTION          = 3;
  STT_FILE             = 4;
  STT_COMMON           = 5;

{$endregion}
{$region ' Symbol visibility constants '}

const
  STV_DEFAULT          = 0;
  STV_INTERNAL         = 1;
  STV_HIDDEN           = 2;
  STV_PROTECTED        = 3;

{$endregion}
{$region ' TElfIdent '}

type
  TElfIdent = packed record
    e_magic      : uint32;                  // See 'cElfMagic'
    e_class      : uint8;                   // 1 = 32-bit, 2 = 64-bit
    e_endian     : uint8;                   // 1 = little-endian, 2 = big-endian
    e_version    : uint8;                   // Always 1, the original and current elf version.
    e_osabi      : uint8;                   // The operating system ABI, see TElfABI
    e_abivers    : uint8;                   // ABI version, platform specific.
    e_pad        : array[ 0..6 ] of uint8;  // Padding should be zero.
  end;

{$endregion}
{$region ' TElfHeader32 '}

type
  TElfHeader32 = packed record
    e_type       : uint16;                  // The type of elf file, see TElfType
    e_machine    : uint16;
    e_version    : uint32;
    e_entry      : uint32;                  // Entrypoint
    e_phoff      : uint32;                  // Program header offset
    e_shoff      : uint32;                  // Section headers offset
    e_flags      : uint32;                  // Interpretation of this field depends on the target architecture.
    e_ehsize     : uint16;                  // Contains the size of this header, normally 64 Bytes for 64-bit and 52 Bytes for 32-bit format.
    e_phentsize  : uint16;	                // Contains the size of a program header table entry.
    e_phnum      : uint16;                  // Contains the number of entries in the program header table.
    e_shentsize  : uint16;                  // Contains the size of a section header table entry.
    e_shnum      : uint16;                  // Contains the number of entries in the section header table.
    e_shstrndx   : uint16;
  end;

{$endregion}
{$region ' TElfHeader64 '}

type
  TElfHeader64 = packed record
    e_type       : uint16;                  // The type of elf file, see TElfType
    e_machine    : uint16;
    e_version    : uint32;
    e_entry      : uint64;                  // Entrypoint
    e_phoff      : uint64;                  // Program header offset
    e_shoff      : uint64;                  // Section headers offset
    e_flags      : uint32;                  // Interpretation of this field depends on the target architecture.
    e_ehsize     : uint16;                  // Contains the size of this header, normally 64 Bytes for 64-bit and 52 Bytes for 32-bit format.
    e_phentsize  : uint16;	                // Contains the size of a program header table entry.
    e_phnum      : uint16;                  // Contains the number of entries in the program header table.
    e_shentsize  : uint16;                  // Contains the size of a section header table entry.
    e_shnum      : uint16;                  // Contains the number of entries in the section header table.
    e_shstrndx   : uint16;
  end;

{$endregion}
{$region ' TElfProgramHeader32 '}

type
  TElfProgramHeader32 = packed record
    p_type       : uint32;                  // Identifies the type of the segment (see TElfProgramType)
    p_offset     : uint32;                  // Offset of the segment in the file image.
    p_vaddr      : uint32;                  // Virtual address of the segment in memory.
    p_paddr      : uint32;                  // On systems where physical address is relevant, reserved for segment's physical address.
    p_filesz     : uint32;                  // Size in bytes of the segment in the file image. May be 0.
    p_memsz      : uint32;                  // Size in bytes of the segment in memory. May be 0.
    p_flags      : uint32;                  // Segment-dependent flags (position for 32-bit structure).
    p_align      : uint32;                  // 0 and 1 specify no alignment. Otherwise should be a positive, integral power of 2, with p_vaddr equating p_offset modulus p_align.
  end;

{$endregion}
{$region ' TElfProgramHeader64 '}

type
  TElfProgramHeader64 = packed record
    p_type       : uint32;                  // Identifies the type of the segment (see TElfProgramType)
    p_flags      : uint32;                  // Segment-dependent flags (position for 64-bit structure).
    p_offset     : uint64;                  // Offset of the segment in the file image.
    p_vaddr      : uint64;                  // Virtual address of the segment in memory.
    p_paddr      : uint64;                  // On systems where physical address is relevant, reserved for segment's physical address.
    p_filesz     : uint64;                  // Size in bytes of the segment in the file image. May be 0.
    p_memsz      : uint64;                  // Size in bytes of the segment in memory. May be 0.
    p_align      : uint64;                  // 0 and 1 specify no alignment. Otherwise should be a positive, integral power of 2, with p_vaddr equating p_offset modulus p_align.
  end;

{$endregion}
{$region ' TElfSectionHeader32 '}

type
  TElfSectionHeader32 = packed record
    sh_name      : uint32;                  // An offset to a string in the .shstrtab section that represents the name of this section.
    sh_type      : uint32;                  // Identifies the type of this header. ( see TElfSectionHeaderType )
    sh_flags     : uint32;                  // Identifies the attributes of the section. ( see TElfSectionHeaderFlags )
    sh_addr      : uint32;                  // Virtual address of the section in memory, for sections that are loaded.
    sh_offset    : uint32;                  // Offset of the section in the file image.
    sh_size      : uint32;                  // Size in bytes of the section in the file image. May be 0.
    sh_link      : uint32;                  // Contains the section index of an associated section. This field is used for several purposes, depending on the type of section.
    sh_info      : uint32;                  // Contains extra information about the section. This field is used for several purposes, depending on the type of section.
    sh_addralign : uint32;                  // Contains the required alignment of the section. This field must be a power of two.
    sh_entsize   : uint32;                  // Contains the size, in bytes, of each entry, for sections that contain fixed-size entries. Otherwise, this field contains zero.
  end;

{$endregion}
{$region ' TElfSectionHeader64 '}

type
  TElfSectionHeader64 = packed record
    sh_name      : uint32;                  // An offset to a string in the .shstrtab section that represents the name of this section.
    sh_type      : uint32;                  // Identifies the type of this header. ( see TElfSectionHeaderType )
    sh_flags     : uint64;                  // Identifies the attributes of the section. ( see TElfSectionHeaderFlags )
    sh_addr      : uint64;                  // Virtual address of the section in memory, for sections that are loaded.
    sh_offset    : uint64;                  // Offset of the section in the file image.
    sh_size      : uint64;                  // Size in bytes of the section in the file image. May be 0.
    sh_link      : uint32;                  // Contains the section index of an associated section. This field is used for several purposes, depending on the type of section.
    sh_info      : uint32;                  // Contains extra information about the section. This field is used for several purposes, depending on the type of section.
    sh_addralign : uint64;                  // Contains the required alignment of the section. This field must be a power of two.
    sh_entsize   : uint64;                  // Contains the size, in bytes, of each entry, for sections that contain fixed-size entries. Otherwise, this field contains zero.
  end;

{$endregion}
{$region ' TElf32_Sym '}

type
  TElf32_Sym = packed record
    st_name      : uint32;
    st_value     : uint32;
    st_size      : uint32;
    st_info      : uint8;
    st_other     : uint8;
    st_shndx     : uint16;
  end;

{$endregion}
{$region ' TElf64_sym ' }

type
  TElf64_Sym = packed record
    st_name      : uint32;
    st_info      : uint8;
    st_other     : uint8;
    st_shndx     : uint16;
    st_value     : uint64;
    st_size      : uint64;
  end;

{$endregion}
{$region ' TElf32_Rel '}

type
  TElf32_Rel = packed record
    r_offset     : uint32;
    r_info       : uint32;
  end;

{$endregion}
{$region ' TElf32_Rela '}

type
  TElf32_Rela = packed record
    r_offset     : uint32;
    r_info       : uint32;
    r_addend     : int32;
  end;

{$endregion}
{$region ' TElf64_Rel '}

type
  TElf64_Rel = packed record
    r_offset     : uint64;
    r_info       : uint64;
  end;

{$endregion}
{$region ' TElf64_Rela '}

type
  TElf64_Rela = packed record
    r_offset     : uint64;
    r_info       : uint64;
    r_addend     : int64;
  end;

{$endregion}

function ELF32_R_TYPE( const info: uint32 ): uint32;
function ELF64_R_SYM( const info: uint64 ): uint32;
function ELF64_R_TYPE( const info: uint64 ): uint32;
function ELF32_R_SYM( const info: uint32 ): uint32;

implementation

function ELF64_R_TYPE( const info: uint64 ): uint32;
begin
  Result := (info shr ELF64_R_TYPE_SHIFT) and ELF64_R_TYPE_MASK;
end;

function ELF64_R_SYM( const info: uint64 ): uint32;
begin
  Result := (info shr ELF64_R_SYM_SHIFT) and ELF64_R_SYM_MASK;
end;

function ELF32_R_TYPE( const info: uint32 ): uint32;
begin
  Result := (info shr ELF32_R_TYPE_SHIFT) and ELF32_R_TYPE_MASK;
end;

function ELF32_R_SYM( const info: uint32 ): uint32;
begin
  Result := (info shr ELF32_R_SYM_SHIFT) and ELF32_R_SYM_MASK;
end;

end.

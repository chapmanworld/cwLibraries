(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.Elf.Reader;

interface
uses
  utlStatus
, utlLog
, utlIO
, utlCollections
, utlLinker.Elf.DataTypes
, utlLinker.BinaryImage
, utlLinker
;

{$region ' Supporting types '}

type
  TSectionRecord = record
    // The offset into a string-table section in which the name of this section can be found
    NameOffset: TFileLocation;
    // The file offset of the data for the section.
    FileOffset: TFileLocation;
    // The size of the data for the sectoin as stored on disk.
    SizeOnDisk: TFileLocation;
    // The section type.
    SectionType: uint32;
    // The section flags
    Flags: uint64;
    // The section that items in this section 'link' to, used in relocations to link to a symbol table.
    LinkSection: uint32;
    // Copy of the sh_info field, mainly used by relocations to target a section.
    Info: uint32;
    // Index in binary image is only relevant for data sections and string-table sections.
    // If this section is a data section, it is added to fBinaryImage.Sections[], and this provides its index.
    // If this section is a string-table section, it is added to fBinaryImage.StringLists[], and this provides its index.
    IndexInBinaryImage: nativeuint;
    // As symbols are loaded, the fBinaryImage.Symbols[] index of the first symbol in this section is set here (will be zero otherwise)
    FirstSymbol: nativeuint;
  end;

  TSymbolType = (
      symAbsolute
    , symCommon
    , symUndef
    , symRelative
   );

  TSymbolRecord = record
    // The section that the symbol name is in.
    NameSectionIdx: nativeuint;
    // An index within a string list to name this symbol.
    NameIdx: nativeuint;
    // An enumeration indicating the type of symbol (all but symRelative do not have associated sections).
    SymbolType: TSymbolType;
    // The actual section index of the symbol (to be resolved to a loaded section)
    SectionIndex: nativeuint;
  end;

  TRelocationRecord = record
    TargetSection : uint32;
    LinkSection   : uint32;
    r_offset      : uint64;
    r_type        : uint32;
    r_symbol      : uint32;
    r_addend      : int64;
  end;

type
  (*  The section headers of the elf file necessitate several passes to parse
      them. This is because the names of sections, symbols and other items are
      stored as offsets into string tables, which themselves are sections.
      In order to resolve names, the sections must first be parsed and
      their string table offsets stored. After the sections are loaded, the
      string data is available, and so a second pass can read the names and
      back-fill them based on the stored offsets.
      There are a lot of pieces involved in this process, as sections, symbols
      and relocations all need to be resolved using data which spans several
      string tables. A single function to do all of this work becomes large
      and would be difficult to maintain.
      In order to break the process into smaller functions, multiple pieces
      of information must be passed between those functions, making parameter
      lists long. The solution is to pass these parameters between the
      several functions using a container of some kind. This record is that
      container.
  *)
  TSectionPassRecord = record
    SectionHeaderOffset: TFileLocation;      // Where can we find section headers in the file? (from elf header)
    NameSectionIdx: uint32;                  // What is the index of the string table containing section names? (again from elf header)
    Sections: array of TSectionRecord;       // Records for the sections, indexed as in file, containing indices to sections in the binary image / string lists in the bianry image, according to need based on section type.
    Symbols: IList< TSymbolRecord >;         // As each symbol is read in, we store some information about it, required to recover its name and section name later.
    Relocations: IList< TRelocationRecord >; // As each relocation is read in, we store some information about it, required to resolve its symbol and section later.
  end;

{$endregion}

type
  TElfReader = class
  private
    fLog: ILog;
    fSourceStream: IReadOnlyUnicodeStream; // Set at constructor
    fBinaryImage: IBinaryImage;   // Set at start of Read() image in construction.
  private
    function ElfFlagsToAttributes( const Flags: uint64 ): TSectionAttributes;
    function StringListOf( const SectionPass: TSectionPassRecord; const Index: nativeuint ): IStringList;
    function SectionOf( const SectionPass: TSectionPassRecord; const Index: nativeuint ): ISection;
  private
    function VerifyIdent: TStatus;
    function VerifyClass( const e_class: uint8 ): TStatus;
    function VerifyEndian( const e_endian: uint8 ): TStatus;
    function ReadHeader( out SectionHeaderOffset: uint64; out SectionCount: uint32; out SectionNamesIdx: uint32 ): TStatus;
    function BindAttributesFromSymbol( const value: uint8 ): TSymbolBindAttributes;
    function VisibilityFromSymbol( const value: uint8 ): TSymbolVisibility;
    function FindSectionByName( const SectionName: string ): ISection;
    function ParseSymbolTable( var SectionPass: TSectionPassRecord; const NamesSectionIdx: nativeuint; const Stream: IReadOnlyUnicodeStream ): TStatus;
    function ParseStringTable( const Stream: IReadOnlyUnicodeStream ): TStatus;
    function ParseRelocationTable( const TargetSection: nativeuint; const LinkSection: nativeuint; const WithAddend: boolean; var SectionPass: TSectionPassRecord; const Stream: IReadOnlyUnicodeStream ): TStatus;
    function ReadSectionHeaders( var SectionPass: TSectionPassRecord ): TStatus;
    function ResolveSectionNames( var SectionPass: TSectionPassRecord ): TStatus;
    function ResolveSymbolNames( var SectionPass: TSectionPassRecord ): TStatus;
    function ResolveRelocations( var SectionPass: TSectionPassRecord ): TStatus;
    function ReadSections( const SectionHeaderOffset: uint32; const SectionCount: uint32; const NameSectionIdx: uint32 ): TStatus;
  public
    class function IsElf( const FileStream: IReadOnlyUnicodeStream ): boolean; static;
    function Read( const BinaryImage: IBinaryImage ): TStatus;
    constructor Create( const Log: ILog; const SourceStream: IReadOnlyUnicodeStream ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  SysUtils
, utlTypes
, utlUnicode
;

constructor TElfReader.Create( const Log: ILog; const SourceStream: IReadOnlyUnicodeStream );
begin
  inherited Create;
  fLog           := Log;
  fBinaryImage   := nil;
  fSourceStream  := SourceStream;
  fSourceStream.Position := 0;
end;

destructor TElfReader.Destroy;
begin
  fSourceStream := nil;
  fBinaryImage   := nil;
  inherited Destroy;
end;

function TElfReader.ElfFlagsToAttributes( const Flags: uint64 ): TSectionAttributes;
begin
  Result := [];
  Result := [ saReadable ];
  if ( Flags and SHF_WRITE            ) = SHF_WRITE             then Result := Result + [ saWritable ];
  if ( Flags and SHF_ALLOC            ) = SHF_ALLOC             then ; // ignored
  if ( Flags and SHF_EXECINSTR        ) = SHF_EXECINSTR         then Result := Result + [ saExecutable ];
  if ( Flags and SHF_MERGE            ) = SHF_MERGE             then ; // ignored
  if ( Flags and SHF_STRINGS          ) = SHF_STRINGS           then ; // ignored
  if ( Flags and SHF_INFO_LINK        ) = SHF_INFO_LINK         then ; // ignored
  if ( Flags and SHF_LINK_ORDER       ) = SHF_LINK_ORDER        then ; // ignored
  if ( Flags and SHF_OS_NONCONFORMING ) = SHF_OS_NONCONFORMING  then ; // ignored
  if ( Flags and SHF_GROUP            ) = SHF_GROUP             then ; // ignored
  if ( Flags and SHF_TLS              ) = SHF_TLS               then ; // ignored
  if ( Flags and SHF_MASKOS           ) = SHF_MASKOS            then ; // ignored
  if ( Flags and SHF_ORDERED          ) = SHF_ORDERED           then ; // ignored
  if ( Flags and SHF_EXCLUDE          ) = SHF_EXCLUDE           then ; // ignored
end;

class function TElfReader.IsElf( const FileStream: IReadOnlyUnicodeStream ): boolean;
var
  Ident: TElfIdent;
begin
  Result := False;
  try
    if FileStream.Read( @Ident, sizeof( TElfIdent ) ) <> sizeof( TElfIdent ) then exit;
    if Ident.e_magic <> cElfMagic then exit;
    Result := true;
  except
    on E: Exception do ;
  end;
end;

function TElfReader.VerifyClass( const e_class: uint8 ): TStatus;
begin
  case e_class of
    1: fBinaryImage.Bittedness := TBittedness.bits32;
    2: fBinaryImage.Bittedness := TBittedness.bits64;
    else exit( fLog.Insert( stInvalidElfFile, lsError, [ 'Unable to determine elf file class.', fBinaryImage.FilePath ] ) );
  end;
  Result := stSuccess;
end;

function TElfReader.VerifyEndian( const e_endian: uint8 ): TStatus;
begin
  case e_endian of
    1: fBinaryImage.Endianness := enLittle;
    2: fBinaryImage.Endianness := enBig;
    else exit( fLog.Insert( stInvalidElfFile, lsError, [ 'Unable to determine if elf file is big-endian or little-endian.', fBinaryImage.FilePath ] ) );
  end;
  Result := stSuccess;
end;

function TElfReader.VerifyIdent: TStatus;
var
  Ident: TElfIdent;
begin
  if fSourceStream.Read( @Ident, sizeof( TElfIdent ) ) <> sizeof( TElfIdent ) then exit( fLog.Insert( stInvalidElfFile, lsError, [ 'Failed to read ident', fBinaryImage.FilePath ] ) );
  if Ident.e_magic <> cElfMagic then exit( fLog.Insert( stInvalidElfFile, lsError, [ 'Invalid signature (magic) value, is file ELF?', fBinaryImage.FilePath ] ) );
  Result := VerifyClass( Ident.e_class );
  if not Result then exit;
  Result := VerifyEndian( Ident.e_endian );
  if not Result then exit;
  if Ident.e_version <> 1 then exit( fLog.Insert( stInvalidElfFile, lsError, [ 'Unsupported elf version.', fBinaryImage.FilePath ] ) );
  Result := stSuccess;
end;

function TElfReader.ReadHeader( out SectionHeaderOffset: uint64; out SectionCount: uint32; out SectionNamesIdx: uint32 ): TStatus;
var
  Header32: TElfHeader32;
  Header64: TElfHeader64;
begin
  case fBinaryImage.Bittedness of
    bits32: begin
      if fSourceStream.Read( @Header32, sizeof( TElfHeader32 ) ) <> sizeof( TElfHeader32 ) then exit( fLog.Insert( stInvalidElfFile, lsError, [ 'Failed to read elf header.', fBinaryImage.FilePath ] ) );
      if Header32.e_type <> ET_REL then exit( fLog.Insert( stInvalidElfFile, lsError, [ 'Not a relocatable linkable elf file.', fBinaryImage.FilePath ] ) );
      SectionHeaderOffset := Header32.e_shoff;
      SectionCount := Header32.e_shnum;
      SectionNamesIdx := Header32.e_shstrndx;
    end;
    bits64: begin
      if fSourceStream.Read( @Header64, sizeof( TElfHeader64 ) ) <> sizeof( TElfHeader64 ) then exit( fLog.Insert( stInvalidElfFile, lsError, [ 'Failed to read elf header.', fBinaryImage.FilePath ] ) );
      if Header64.e_type <> ET_REL then exit( fLog.Insert( stInvalidElfFile, lsError, [ 'Not a relocatable linkable elf file.', fBinaryImage.FilePath ] ) );
      SectionHeaderOffset := Header64.e_shoff;
      SectionCount := Header64.e_shnum;
      SectionNamesIdx := Header64.e_shstrndx;
    end;
  end;
  // Extract necessary parameters.
  Result := stSuccess;
end;

function TElfReader.ParseStringTable( const Stream: IReadOnlyUnicodeStream ): TStatus;
var
  StringList: IStringList;
  StartOffset: nativeuint;
  EndOffset: nativeuint;
  S: string;
begin
  Stream.Position := 0;
  StringList := fBinaryImage.StringLists.Add;
  if Stream.Size = 0 then exit( stSuccess );
  while not Stream.EndOfStream do begin
    StartOffset := Stream.Position;
    S := Stream.ReadString( TUnicodeFormat.utf8, True, Stream.Size - Stream.Position );
    EndOffset := Stream.Position;
    StringList.Add( S, StartOffset, EndOffset );
  end;
  Result := stSuccess;
end;

function TElfReader.BindAttributesFromSymbol( const value: uint8 ): TSymbolBindAttributes;
var
  test: uint8;
begin
  if ( value and STB_LOCAL  ) = STB_LOCAL   then Result := Result + [ baLocal  ];
  if ( value and STB_GLOBAL ) = STB_GLOBAL  then Result := Result + [ baGlobal ];
  if ( value and STB_WEAK   ) = STB_WEAK    then Result := Result + [ baWeak   ];
  test := value and $0F;
  if test = STT_NOTYPE   then Result := Result + [ baUntyped      ];
  if test = STT_OBJECT   then Result := Result + [ baVariableType ];
  if test = STT_FUNC     then Result := Result + [ baFunctionType ];
  if test = STT_SECTION  then Result := Result + [ baSectionType  ];
  if test = STT_FILE     then Result := Result + [ baFileType     ];
  if test = STT_Common   then Result := Result + [ baCommonType   ];
end;

function TElfReader.VisibilityFromSymbol( const value: uint8 ): TSymbolVisibility;
var
  test: uint8;
begin
  Result := svDefault;
  test := value and $03;
  if test = STV_DEFAULT   then Result := svDefault;
  if test = STV_INTERNAL  then Result := svInternal;
  if test = STV_HIDDEN    then Result := svHidden;
  if test = STV_PROTECTED then Result := svProtected;
end;

function TElfReader.ParseSymbolTable( var SectionPass: TSectionPassRecord; const NamesSectionIdx: nativeuint; const Stream: IReadOnlyUnicodeStream ): TStatus;
var
  Sym32: TElf32_Sym;
  Sym64: TElf64_Sym;
  NewSymbol: ISymbol;
  SymbolRecord: TSymbolRecord;
  S: string;
begin
  if not assigned( Stream ) then exit( stSuccess );
  if ( fBinaryImage.Bittedness <> bits32 ) and
     ( fBinaryImage.Bittedness <> bits64 ) then raise TStatus.CreateException( stElfParseError, [ 'Unable to parse symbol table.' ] );
  Stream.Position := 0;
  while not Stream.EndOfStream do begin
    case fBinaryImage.Bittedness of
      bits32: begin
        if Stream.Read( @Sym32, sizeof( TElf32_Sym ) ) <> sizeof( TElf32_Sym ) then raise TStatus.CreateException( stStreamReadError, [] );
        NewSymbol := fBinaryImage.AddSymbol('');
        NewSymbol.BindAttributes := BindAttributesFromSymbol( Sym32.st_info );
        NewSymbol.Visibility := VisibilityFromSymbol( Sym32.st_other );
        NewSymbol.Value := Sym32.st_Value;
        SymbolRecord.NameSectionIdx := NamesSectionIdx;
        SymbolRecord.NameIdx := Sym32.st_name;
        case Sym32.st_shndx of
          $0000 : SymbolRecord.SymbolType := symUndef;
          $FFF1 : SymbolRecord.SymbolType := symAbsolute;
          $FFF2 : SymbolRecord.SymbolType := symCommon;
          else SymbolRecord.SymbolType := symRelative;
        end;
        if SymbolRecord.SymbolType = symRelative then begin
          SymbolRecord.SectionIndex := Sym32.st_shndx;
        end;
        SectionPass.Symbols.Add( SymbolRecord );
      end;
      bits64: begin
        if Stream.Read( @Sym64, sizeof( TElf64_Sym ) ) <> sizeof( TElf64_Sym ) then raise TStatus.CreateException( stStreamReadError, [] );
        NewSymbol := fBinaryImage.AddSymbol('');
        NewSymbol.BindAttributes := BindAttributesFromSymbol( Sym64.st_info );
        NewSymbol.Visibility := VisibilityFromSymbol( Sym64.st_other );
        NewSymbol.Value := Sym64.st_Value;
        SymbolRecord.NameSectionIdx := NamesSectionIdx;
        SymbolRecord.NameIdx := Sym64.st_name;
        case Sym64.st_shndx of
          $0000 : SymbolRecord.SymbolType := symUndef;
          $FFF1 : SymbolRecord.SymbolType := symAbsolute;
          $FFF2 : SymbolRecord.SymbolType := symCommon;
          else SymbolRecord.SymbolType := symRelative;
        end;
        if SymbolRecord.SymbolType = symRelative then begin
          SymbolRecord.SectionIndex := Sym64.st_shndx;
        end;
        SectionPass.Symbols.Add( SymbolRecord );
      end;
      else continue; // we checked for this above.
    end;
  end;
end;

function TElfReader.ParseRelocationTable( const TargetSection: nativeuint; const LinkSection: nativeuint; const WithAddend: boolean; var SectionPass: TSectionPassRecord; const Stream: IReadOnlyUnicodeStream ): TStatus;
var
  Rel32: TElf32_RelA;
  Rel64: TElf64_RelA;
  RelocationRecord: TRelocationRecord;
begin
  if not assigned( Stream ) then exit( stSuccess );
  if ( fBinaryImage.Bittedness <> bits32 ) and
     ( fBinaryImage.Bittedness <> bits64 ) then raise TStatus.CreateException( stElfParseError, [ 'Unable to parse symbol table.' ] );
  Stream.Position := 0;
  while not Stream.EndOfStream do begin
    FillChar( RelocationRecord, sizeof( TRelocationRecord ), 0 );
    RelocationRecord.LinkSection := LinkSection;
    RelocationRecord.TargetSection := TargetSection;
    case fBinaryImage.Bittedness of
      bits32: begin
        if WithAddend then begin
          if Stream.Read( @Rel32, sizeof( TElf32_RelA ) ) <> sizeof( TElf32_RelA ) then raise TStatus.CreateException( stStreamReadError, [] );
          RelocationRecord.r_addend := Rel32.r_addend;
        end else begin
          if Stream.Read( @Rel32, sizeof( TElf32_Rel ) ) <> sizeof( TElf32_Rel ) then raise TStatus.CreateException( stStreamReadError, [] );
          RelocationRecord.r_addend := 0;
        end;
        RelocationRecord.r_offset := Rel32.r_offset;
        RelocationRecord.r_type   := ELF32_R_TYPE( Rel32.r_info );
        RelocationRecord.r_symbol := ELF32_R_SYM( Rel32.r_info );
      end;
      bits64: begin
        if WithAddend then begin
          if Stream.Read( @Rel64, sizeof( TElf64_RelA ) ) <> sizeof( TElf64_RelA ) then raise TStatus.CreateException( stStreamReadError, [] );
          RelocationRecord.r_addend := Rel64.r_addend;
        end else begin
          if Stream.Read( @Rel64, sizeof( TElf64_Rel ) ) <> sizeof( TElf64_Rel ) then raise TStatus.CreateException( stStreamReadError, [] );
          RelocationRecord.r_addend := 0;
        end;
        RelocationRecord.r_offset := Rel64.r_offset;
        RelocationRecord.r_type   := ELF64_R_TYPE( Rel64.r_info );
        RelocationRecord.r_symbol := ELF64_R_SYM( Rel64.r_info );
      end;
      else continue; // we checked for this above.
    end;
    SectionPass.Relocations.Add( RelocationRecord );
  end;
  Result := stSuccess;
end;

function TElfReader.ReadSectionHeaders( var SectionPass: TSectionPassRecord ): TStatus;
var
  idx: uint32;
  Header32: TElfSectionHeader32;
  Header64: TElfSectionHeader64;
  Section: ISection;
  FoundSectionNames: boolean;
begin
  // Move to start of section headers, and initialize fSections
  fSourceStream.Position := SectionPass.SectionHeaderOffset;
  FoundSectionNames := False;
  // The first loop of section headers creates instances of ISection for most
  // sections, but skips this for others. For instance, no section is created
  // for string tables, instead, the string tables are added to
  // fBinaryImages.StringLists. In this loop, neither the sections nor the
  // string lists (or other) are given names because we must first load the
  // string-table sections to acquire the names. A second loop resolves names.
  for idx := 0 to pred( Length( SectionPass.Sections ) ) do begin
    SectionPass.Sections[ idx ].IndexInBinaryImage := idx; //unless changed.
    {$region ' Read the header '}
    case fBinaryImage.Bittedness of

      bits32: begin
        if fSourceStream.Read( @Header32, sizeof( TElfSectionHeader32 ) ) <> sizeof( TElfSectionHeader32 ) then exit( fLog.Insert( stInvalidElfFile, lsError, [ 'Failed to read section headers.', fBinaryImage.FilePath ] ) );
        SectionPass.Sections[ idx ].Flags       := Header32.sh_flags;
        SectionPass.Sections[ idx ].LinkSection := Header32.sh_link;
        SectionPass.Sections[ idx ].Info        := Header32.sh_info;
        SectionPass.Sections[ idx ].FileOffset  := Header32.sh_offset;
        SectionPass.Sections[ idx ].SizeOnDisk  := Header32.sh_size;
        SectionPass.Sections[ idx ].SectionType := Header32.sh_type;
        SectionPass.Sections[ idx ].NameOffset   := Header32.sh_name;
      end;

      bits64: begin
        if fSourceStream.Read( @Header64, sizeof( TElfSectionHeader64 ) ) <> sizeof( TElfSectionHeader64 ) then exit( fLog.Insert( stInvalidElfFile, lsError, [ 'Failed to read section headers.', fBinaryImage.FilePath ] ) );
        SectionPass.Sections[ idx ].Flags       := Header64.sh_flags;
        SectionPass.Sections[ idx ].LinkSection := Header64.sh_link;
        SectionPass.Sections[ idx ].Info        := Header64.sh_info;
        SectionPass.Sections[ idx ].FileOffset  := Header64.sh_offset;
        SectionPass.Sections[ idx ].SizeOnDisk  := Header64.sh_size;
        SectionPass.Sections[ idx ].SectionType := Header64.sh_type;
        SectionPass.Sections[ idx ].NameOffset  := Header64.sh_name;
      end;

      else begin
        // [ TODO ] Insert appropriate error.
      end;

    end; {case}
    {$endregion}
    {$region ' Create the structures (un-named, will be named in pass two)' }
    case SectionPass.Sections[ idx ].SectionType of

      SHT_STRTAB: begin
        // If the section is a string table, we don't actually load it into the binary image, but instead we parse it into
        // a string list on the binary image, and if its the section names, keep a reference to it in order to resolve the
        // names later.
        SectionPass.Sections[ idx ].IndexInBinaryImage := fBinaryImage.StringLists.Count;
        Result := ParseStringTable( TPartialStream.Create( fSourceStream as IReadOnlyUnicodeStream, SectionPass.Sections[ idx ].FileOffset, SectionPass.Sections[ idx ].SizeOnDisk ) );
        if not Result then exit;
        if idx = SectionPass.NameSectionIdx then FoundSectionNames := True;
      end;

      SHT_SYMTAB: begin
        SectionPass.Sections[ idx ].FirstSymbol := fBinaryImage.Symbols.Count;
        Result := ParseSymbolTable( SectionPass, SectionPass.Sections[ idx ].LinkSection, TPartialStream.Create( fSourceStream as IReadOnlyUnicodeStream, SectionPass.Sections[ idx ].FileOffset, SectionPass.Sections[ idx ].SizeOnDisk ) );
        if not Result then exit;
      end;

      SHT_REL: begin
        Result := ParseRelocationTable(
           SectionPass.Sections[ idx ].Info,
           SectionPass.Sections[ idx ].LinkSection, False,
           SectionPass,
           TPartialStream.Create(
               fSourceStream as IReadOnlyUnicodeStream,
               SectionPass.Sections[ idx ].FileOffset,
               SectionPass.Sections[ idx ].SizeOnDisk
           )
        );
        if not Result then exit;
      end;

      SHT_RELA: begin
        Result := ParseRelocationTable(
            SectionPass.Sections[ idx ].Info,
            SectionPass.Sections[ idx ].LinkSection, True,
            SectionPass,
            TPartialStream.Create(
                fSourceStream as IReadOnlyUnicodeStream,
                SectionPass.Sections[ idx ].FileOffset,
                SectionPass.Sections[ idx ].SizeOnDisk
            )
        );
        if not Result then exit;
      end;

      SHT_NULL: continue;

      SHT_PROGBITS: begin
        SectionPass.Sections[ idx ].IndexInBinaryImage := fBinaryImage.Sections.Count;
        Section := fBinaryImage.AddContentSection(
            TPartialStream.Create(
                fSourceStream as IReadOnlyUnicodeStream,
                SectionPass.Sections[ idx ].FileOffset,
                SectionPass.Sections[ idx ].SizeOnDisk
            )
        );
        Section.Attributes := ElfFlagsToAttributes( SectionPass.Sections[ idx ].Flags );
      end;

      else begin
        // If we didn't recognize the section type, we don't care about it.
        // Set it's type in our SectionPass record to null, it'll be ignored by
        // subsequent passes over the section headers.
        SectionPass.Sections[ idx ].SectionType := SHT_NULL;
      end;

    end;
    {$endregion}
  end;
  if not FoundSectionNames then exit( fLog.Insert( stElfSectionNamesMissing, lsError ) );
  Result := stSuccess;
end;

function TElfReader.StringListOf( const SectionPass: TSectionPassRecord; const Index: nativeuint ): IStringList;
begin
  Result := fBinaryImage.StringLists[ SectionPass.Sections[ Index ].IndexInBinaryImage ];
end;

function TElfReader.SectionOf( const SectionPass: TSectionPassRecord; const Index: nativeuint ): ISection;
begin
  Result := fBinaryImage.Sections[ SectionPass.Sections[ Index ].IndexInBinaryImage ];
end;

function TElfReader.ResolveSectionNames( var SectionPass: TSectionPassRecord ): TStatus;
var
  idx: uint32;
  FoundStr: string;
  SectionNamesList: IStringList;
  StringListIdx: nativeuint;
  Section: ISection;
begin
  // This is pass two, we have the sections, string tables, and symbols loaded
  // into the binary image, but none of them have names. We're here to resolve
  // the section names, and string list names.
  StringListIdx := 0;
  SectionNamesList := StringListOf( SectionPass, SectionPass.NameSectionIdx );
  for idx := 0 to pred( Length( SectionPass.Sections ) ) do begin
    if not SectionNamesList.StringByOffset( SectionPass.Sections[ idx ].NameOffset, FoundStr ) then continue;
    {$region ' Handle the naming of things '}
    case SectionPass.Sections[ idx ].SectionType of
      SHT_STRTAB: begin
        fBinaryImage.StringLists[ StringListIdx ].Name := FoundStr;
        inc( StringListIdx );
      end;
      SHT_PROGBITS: begin
        Section := SectionOf( SectionPass, idx );
        Section.Name := FoundStr;
        if Section.Name='.idata' then Section.Attributes := Section.Attributes + [ saIData ];
      end;
      else continue; // It's not a section we care to load into binary image, so it doesn't matter.
    end;
    {$endregion}
  end;
  Result := stSuccess;
end;

function TElfReader.ResolveSymbolNames( var SectionPass: TSectionPassRecord ): TStatus;
var
  idx: nativeuint;
  FoundStr: string;
  SectionList: IStringList;
  StringList: IStringList;
  Symbol: ISymbol;
begin
  if fBinaryImage.Symbols.Count = 0 then exit( stSuccess );
  // This is pass three, we have sections, string tables, and symbols loaded
  // into the binary image. We're here to resolve symbol names.
  SectionList := StringListOf( SectionPass, SectionPass.NameSectionIdx );
  for idx := 0 to pred( fBinaryImage.Symbols.Count ) do begin
    Symbol := fBinaryImage.Symbols[ idx ];
    if not assigned( Symbol ) then continue;
    StringList := StringListOf( SectionPass, SectionPass.Symbols[ idx ].NameSectionIdx );
    if StringList.StringByOffset( SectionPass.Symbols[ idx ].NameIdx, FoundStr ) then begin
    Symbol.Name := FoundStr;
    end;
    if SectionPass.Symbols[ idx ].SymbolType = symRelative then begin
      Symbol.Section := SectionOf( SectionPass, SectionPAss.Symbols[ idx ].SectionIndex );
    end;
      if ( baSectionType in Symbol.BindAttributes ) and assigned( Symbol.Section ) then begin
        Symbol.Name := Symbol.Section.Name;
      end;
  end;
  Result := stSuccess;
end;

function TElfReader.FindSectionByName( const SectionName: string ): ISection;
var
  Section: ISection;
begin
  Result := nil;
  for Section in fBinaryImage.Sections do begin
    if Section.Name = SectionName then exit( Section );
  end;
end;

function TElfReader.ResolveRelocations( var SectionPass: TSectionPassRecord ): TStatus;
var
  idx: nativeuint;
  Reloc: TRelocationRecord;
  NewRelocation: IRelocation;
  SymbolIdx: nativeuint;
begin
  if SectionPass.Relocations.Count = 0 then exit( stSuccess );
  for idx := 0 to pred( SectionPass.Relocations.Count ) do begin
    Reloc := SectionPass.Relocations[ idx ];
    NewRelocation := fBinaryImage.AddRelocation;
    // Find the relocation symbol.
    SymbolIdx := SectionPass.Sections[ Reloc.LinkSection ].FirstSymbol + Reloc.r_symbol;
    NewRelocation.Symbol := fBinaryImage.Symbols[ SymbolIdx ];
    //- Set fields
    NewRelocation.RelocationType := Reloc.r_type;
    NewRelocation.Section := SectionOf( SectionPass, Reloc.TargetSection );
    NewRelocation.Offset := Reloc.r_offset;
    NewRelocation.Addend := Reloc.r_addend;
//    fLog.Insert( stLinkerVerbose, lsVerbose, [
//      'Relocation (' + idx.AsString + ') in "' + NewRelocation.Section.Name + '" offset: 0x' + uint64(NewRelocation.Offset).AsHex + ' relates to symbol "' +
//      NewRelocation.Symbol.Name + '" in section "' +
//      NewRelocation.Symbol.Section.Name + '"' ]
//    );
  end;
  Result := stSuccess;
end;

function TElfReader.ReadSections( const SectionHeaderOffset: uint32; const SectionCount: uint32; const NameSectionIdx: uint32 ): TStatus;
var
  SectionPass: TSectionPassRecord;
  FoundIdx: nativeuint;
begin
  if SectionCount = 0 then exit( stSuccess );
  // Set up the section pass record
  SectionPass.SectionHeaderOffset := SectionHeaderOffset;
  SectionPass.NameSectionIdx := NameSectionIdx;
  SetLength( SectionPass.Sections, SectionCount );
  FillChar( SectionPass.Sections[ 0 ], SectionCount * sizeof( TSectionRecord ), 0 );
  SectionPass.Symbols := TList< TSymbolRecord >.Create;
  SectionPass.Relocations := TList< TRelocationRecord >.Create;
  try
    // Prepare the binary image
    fBinaryImage.Sections.Clear;
    fBinaryImage.StringLists.Clear;
    fBinaryImage.Symbols.Clear;
    // Pass one, load in the sections
    Result := ReadSectionHeaders( SectionPass );
    if not Result then exit;
    // Pass two, resolve section names.
    Result := ResolveSectionNames( SectionPass );
    if not Result then exit;
    // Pass three, resolve symbol names.
    Result := ResolveSymbolNames( SectionPass );
    if not Result then exit;
    // Pass four, resolve relocatoins
    Result := ResolveRelocations( SectionPass );
  finally
    SetLength( SectionPass.Sections, 0 );
    SectionPass.Relocations := nil;
    SectionPass.Symbols := nil;
  end;
end;

function TElfReader.Read( const BinaryImage: IBinaryImage ): TStatus;
var
  SectionHeaderOffset: uint64;
  SectionCount: uint32;
  NameSectionIdx: uint32;
begin
  // Initialize read.
  fSourceStream.Position := 0;
  fBinaryImage := BinaryImage;
  fBinaryImage.Sections.Clear;
  // Read at least the ident.
  Result := VerifyIdent();
  if not Result then exit;
  // Read the header.
  Result := ReadHeader( SectionHeaderOffset, SectionCount, NameSectionIdx );
  if not Result then exit;
  // Read the section headers.
  Result := ReadSections( SectionHeaderOffset, SectionCount, NameSectionIdx );
//  if not Result then exit;
end;

end.

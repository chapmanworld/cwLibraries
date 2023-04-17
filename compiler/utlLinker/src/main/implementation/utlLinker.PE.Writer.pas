(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.PE.Writer;

interface
uses
  utlStatus
, utlLog
, utlCollections
, utlIO
, utlLinker
, utlLinker.PE.DataTypes
, utlLinker.BinaryImage
;

type
  TPEWriter = class
  private
    fLog: ILog;
    fStream: IUnicodeStream;
    fBinaryImage: IBinaryImage;
    fDataDirectory: array of IMAGE_DATA_DIRECTORY;
    fEntryPoint: TVirtualAddress;
  private
    function RelocationsInSection( const Section: ISection ): IReadOnlyList<IRelocation>;
    function FindSymbolByName( const Name: string ): ISymbol;
    function SectionAttributesToCharacteristics( const Attributes: TSectionAttributes ): uint32;
    function WritePaddingUntil( const Position: uint64 ): TStatus;
    function UninitializedDataSize: TVirtualAddress;
    function SizeOfDOSHeader: uint64;
    function CodeRVA: TVirtualAddress;
    function DataRVA: TVirtualAddress;
    function FindEntryPoint: TStatus;
    function SizeOfImage: TVirtualAddress;
    function SizeOfSectionHeaders: uint64;
    function SizeOfHeaders: uint64;
  private
    function WriteMZHeader: TStatus;
    function WritePESignature: TStatus;
    function WriteImageHeader: TStatus;
    function WritePEHeader32: TStatus;
    function WritePEHeader64: TStatus;
    function WritePEHeader: TStatus;
    function ConfigureImports: TStatus;
    function WriteDataDirectoryTable: TStatus;
    function WriteSectionHeaders: TStatus;
    function WriteSections: TStatus;
  public
    function FirstSection: TVirtualAddress;
    function SectionAlignment: TVirtualAddress;
  public
    function Write( const BinaryImage: IBinaryImage; const Target: IUnicodeStream ): TStatus;
  public
    constructor Create( const Log: ILog ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  SysUtils
, utlTypes
, utlCompile
, utlLinker.Utils
, utlUnicode
, utlLinker.BinaryImage.x86Relocator
, utlLinker.BinaryImage.x8664Relocator
;

const
  cDefaultDataDirectorySize = 16;
  cMajorLinkerVersion = 1;
  cMinorLinkerVersion = 0;
  cDefaultFileAlignment    = $200;
  cDefaultIDataSectionCharacteristics = cIMAGE_SCN_CNT_INITIALIZED_DATA or cIMAGE_SCN_MEM_READ or cIMAGE_SCN_MEM_WRITE;
  cDefaultTextSectionCharacteristics  = cIMAGE_SCN_CNT_CODE or cIMAGE_SCN_MEM_EXECUTE or cIMAGE_SCN_MEM_READ;
  cDefaultDataSectionCharacteristics  = cIMAGE_SCN_CNT_INITIALIZED_DATA or cIMAGE_SCN_MEM_READ or cIMAGE_SCN_MEM_WRITE;
  cDefaultBBSSectionCharacteristics   = 0; // [ TODO ] Fix this

constructor TPEWriter.Create( const Log: ILog );
begin
  inherited Create;
  fLog := Log;
  fStream := nil;
  fBinaryImage := nil;
end;

destructor TPEWriter.Destroy;
begin
  fStream := nil;
  fBinaryImage := nil;
  fLog := nil;
  inherited Destroy;
end;

function TPEWriter.FirstSection: TVirtualAddress;
begin
  Result := $1000;
end;

function TPEWriter.SectionAlignment: TVirtualAddress;
begin
  Result := $1000;
end;

function TPEWriter.SizeOfDOSHeader: uint64;
var
  NumberOfRelocations: uint16;
  TotalDosHeadersSize: uint32;
  TotalDosSize: uint32;
begin
  NumberOfRelocations       := 0;
  TotalDosHeadersSize       := sizeof( IMAGE_DOS_HEADER ) + ( sizeof( uint16 ) * NumberOfRelocations );
  TotalDosSize              := TotalDosHeadersSize + Length( cDefaultDOSStub );
  Result := TLinkerUtils.Align( TotalDosSize, 8 ); // Dos header aligns to 8-bytes
end;

function TPEWriter.WriteMZHeader: TStatus;
var
  Header: IMAGE_DOS_HEADER;
begin
  Header.e_magic            := cDOSMagic;                                // MZ signature ( the ascii 'MZ' )
  Header.e_cblp             := SizeOfDOSHeader mod cDOSPageSize;         // Bytes on last page of dos program
  if Header.e_cblp > 0 then begin
    Header.e_cp             := succ( SizeOfDOSHeader div cDOSPageSize ); // Pages in file (add a page if division is not even)
  end else begin
    Header.e_cp             := SizeOfDOSHeader div cDOSPageSize;         // Pages in file
  end;
  Header.e_crlc             := 0;                                        // Number of Relocations (unused)
  Header.e_cparhdr          := SizeOfDOSHeader div cParagraphSize;       // Size of header in paragraphs
  if ( SizeOfDOSHeader mod cParagraphSize ) > 0 then begin               // Increment header paragraph count if division not even
    inc( Header.e_cparhdr );
  end;
  Header.e_minalloc         := $0000;                                    // Minimum extra paragraphs needed
  Header.e_maxalloc         := $FFFF;                                    // Maximum extra paragraphs needed
  Header.e_ss               := $0006;                                    // Initial (relative) SS value
  Header.e_sp               := $00B8;                                    // Initial SP value
  Header.e_csum             := $0000;                                    // Checksum
  Header.e_ip               := $0014;                                    // Initial IP value
  Header.e_cs               := $0000;                                    // Initial (relative) CS value
  Header.e_lfarlc           := $0000;                                    // File address of relocation table
  Header.e_ovno             := $0000;                                    // Overlay number
  Header.e_res[ 0 ]         := $0000;                                    // Reserved words
  Header.e_res[ 1 ]         := $0000;
  Header.e_res[ 2 ]         := $0000;
  Header.e_oemid            := $0000;                                    // OEM identifier (for e_oeminfo)
  Header.e_oeminfo          := $0000;                                    // OEM information; e_oemid specific
  Header.e_res2[ 0 ]        := $0000;                                    // Reserved words
  Header.e_res2[ 1 ]        := $0000;
  Header.e_res2[ 2 ]        := $0000;
  Header.e_res2[ 3 ]        := $0000;
  Header.e_res2[ 4 ]        := $0000;
  Header.e_res2[ 5 ]        := $0000;
  Header.e_res2[ 6 ]        := $0000;
  Header.e_res2[ 7 ]        := $0000;
  Header.e_res2[ 8 ]        := $0000;
  Header.e_res2[ 9 ]        := $0000;
  // Finally, a pointer to the PE signature, which must fall on an 8-byte alignment.
  Header.e_lfanew           := SizeOfDOSHeader;
  // Now write the header, and the stub program + any alignment padding.
  if fStream.Write( @Header, sizeof( IMAGE_DOS_HEADER ) ) <> sizeof( IMAGE_DOS_HEADER ) then exit( stStreamWriteError );
  if fStream.Write( @cDefaultDOSStub[ 0 ], Length( cDefaultDOSStub ) ) <> Length( cDefaultDOSStub ) then exit( stStreamWriteError );
  while fStream.Position < Header.e_lfanew do begin
    if fStream.Write( @cZeroByte, sizeof( uint8 ) ) <> sizeof( uint8 ) then exit( stStreamWriteError );
  end;
  // We're done here.
  Result := stSuccess;
end;

function TPEWriter.WritePESignature: TStatus;
var
  Signature: IMAGE_PE_SIGNATURE;
begin
  Signature := cPESignature;
  if fStream.Write( @Signature, sizeof( IMAGE_PE_SIGNATURE ) ) <> sizeof( IMAGE_PE_SIGNATURE ) then exit( stStreamWriteError );
  Result := stSuccess;
end;

function TPEWriter.WriteImageHeader: TStatus;
var
  Header: IMAGE_FILE_HEADER;
begin
  Header.Characteristics          := cIMAGE_FILE_RELOCS_STRIPPED or
                                     cIMAGE_FILE_EXECUTABLE_IMAGE or
                                     cIMAGE_FILE_LINE_NUMS_STRIPPED or
                                     cIMAGE_FILE_LARGE_ADDRESS_AWARE;
  case fBinaryImage.Bittedness of   // [ TODO ] Introduce propper archtecture awareness to include arm/aarch and others.

    bits32: begin
      Header.Machine              := cIMAGE_FILE_MACHINE_I386;
      Header.Characteristics      := Header.Characteristics or cIMAGE_FILE_32BIT_MACHINE;
      Header.SizeOfOptionalHeader := sizeof( IMAGE_OPTIONAL_HEADER_32 ) + ( Length( fDataDirectory ) * sizeof( IMAGE_DATA_DIRECTORY ) );
    end;

    bits64: begin
      Header.Machine              := cIMAGE_FILE_MACHINE_AMD64;
      Header.SizeOfOptionalHeader := sizeof( IMAGE_OPTIONAL_HEADER_64 ) + ( Length( fDataDirectory ) * sizeof( IMAGE_DATA_DIRECTORY ) );
    end;

    else exit( stInvalidTarget );
  end;
  Header.NumberOfSections     := fBinaryImage.Sections.Count;
  Header.TimeDateStamp        := 0;
  Header.PointerToSymbolTable := 0;
  Header.NumberOfSymbols      := 0;
  if fStream.Write( @Header, sizeof( IMAGE_FILE_HEADER ) ) <> sizeof( IMAGE_FILE_HEADER ) then exit( stStreamWriteError );
end;

function TPEWriter.WritePEHeader: TStatus;
begin
  case fBinaryImage.Bittedness of   // [ TODO ] Introduce propper archtecture awareness to include arm/aarch and others.
    bits32 : Result := WritePEHeader32;
    bits64 : Result := WritePEHeader64;
    else exit( stInvalidTarget );
  end;
end;

function TPEWriter.UninitializedDataSize: TVirtualAddress;
var
  Section: ISection;
begin
  //[ TODO ] - Improve section identification
  Result := 0;
  for Section in fBinaryImage.Sections do begin
    if Supports( Section, IVirtualSection ) then Result := Result + ( Section as IVirtualSection ).Size;
  end;
end;

function TPEWriter.CodeRVA: TVirtualAddress;
var
  Section: ISection;
begin
  //[ TODO ] - Improve section identification
  Result := 0;
  for Section in fBinaryImage.Sections do begin
    if (saExecutable in Section.Attributes) then exit( Section.RVA );
  end;
end;

function TPEWriter.DataRVA: TVirtualAddress;
var
  Section: ISection;
begin
  //[ TODO ] - Improve section identification
  Result := 0;
  for Section in fBinaryImage.Sections do begin
    if (saExecutable in Section.Attributes) then exit( Section.RVA );
  end;
end;

function TPEWriter.SizeOfImage: TVirtualAddress;
var
  Highest: TVirtualAddress;
  HighestSize: TVirtualAddress;
  Section: ISection;
begin
  Result := 0;
  Highest := 0;
  HighestSize := 0;
  for Section in fBinaryImage.Sections do begin
    if Section.RVA > Highest then begin
      Highest := Section.RVA;
      if Supports( Section, IContentSection ) then begin
        HighestSize := TLinkerUtils.Align( ( Section as IContentSection ).Content.Size, SectionAlignment );
      end else begin
        HighestSize := TLinkerUtils.Align( ( Section as IVirtualSection ).Size, SectionAlignment );
      end;
    end;
  end;
  Result := Highest + HighestSize;
end;

function TPEWriter.SizeOfSectionHeaders: uint64;
begin
  Result := ( fBinaryImage.Sections.Count * sizeof( IMAGE_SECTION_HEADER ) );
end;

function TPEWriter.SizeOfHeaders: uint64;
begin
  {$warnings off}
  Result := SizeOfDosHeader +
            ( Length( fDataDirectory ) * sizeof( IMAGE_DATA_DIRECTORY ) ) +
            SizeOfSectionHeaders +
            sizeof( IMAGE_PE_SIGNATURE )
  ;
 {$warnings on}
  case fBinaryImage.Bittedness of
    bits32: Result := Result + sizeof( IMAGE_OPTIONAL_HEADER_32 );
    bits64: Result := Result + sizeof( IMAGE_OPTIONAL_HEADER_64 );
    else raise TStatus.CreateException( stInvalidTarget );
  end;
end;

function TPEWriter.WritePEHeader32: TStatus;
var
  Header: IMAGE_OPTIONAL_HEADER_32;
begin
  Header.Magic                       := cIMAGE_NT_OPTIONAL_HDR32_MAGIC;
  Header.MajorLinkerVersion          := cMajorLinkerVersion;
  Header.MinorLinkerVersion          := cMinorLinkerVersion;
  Header.SizeOfCode                  := $1000; // [TODO] Fix me!
  Header.SizeOfInitializedData       := $00;   // [TODO] Fix me!
  Header.SizeOfUninitializedData     := UninitializedDataSize;
  Header.AddressOfEntryPoint         := fEntryPoint;
  Header.BaseOfCode                  := CodeRVA;
  Header.BaseOfData                  := DataRVA;
  Header.ImageBase                   := fBinaryImage.PreferredAddress;
  Header.SectionAlignment            := SectionAlignment;
  Header.FileAlignment               := cDefaultFileAlignment;
  Header.MajorOperatingSystemVersion := $06;  // [TODO] Find appropriate constant
  Header.MinorOperatingSystemVersion := $00;
  Header.MajorImageVersion           := $00;
  Header.MinorImageVersion           := $00;
  Header.MajorSubsystemVersion       := $06;  // [TODO] Find appropriate constant
  Header.MinorSubsystemVersion       := $00;
  Header.Reserved1                   := $00;
  Header.SizeOfImage                 := SizeOfImage;
  Header.SizeOfHeaders               := TLinkerUtils.Align( SizeOfHeaders, cDefaultFileAlignment );
  Header.CheckSum                    := $00;
  Header.Subsystem                   := $03;  // [TODO] This should be 3 for CUI and 2 for GUI, set to appropriate constant/setting
  Header.DllCharacteristics          := $00;
  Header.SizeOfStackReserve          := $00;
  Header.SizeOfStackCommit           := $00;
  Header.SizeOfHeapReserve           := $00;
  Header.SizeOfHeapCommit            := $00;
  Header.LoaderFlags                 := $00;
  Header.NumberOfRvaAndSizes         := Length( fDataDirectory );
  if fStream.Write( @Header, sizeof( IMAGE_OPTIONAL_HEADER_32 ) ) <> sizeof( IMAGE_OPTIONAL_HEADER_32 ) then exit( stStreamWriteError );
  Result := stSuccess;
end;

function TPEWriter.WritePEHeader64: TStatus;
var
  Header: IMAGE_OPTIONAL_HEADER_64;
begin
  Header.Magic                       := cIMAGE_NT_OPTIONAL_HDR64_MAGIC;
  Header.MajorLinkerVersion          := cMajorLinkerVersion;
  Header.MinorLinkerVersion          := cMinorLinkerVersion;
  Header.SizeOfCode                  := $1000; // [TODO] Fix me!
  Header.SizeOfInitializedData       := $00;   // [TODO] Fix me!
  Header.SizeOfUninitializedData     := UninitializedDataSize;
  Header.AddressOfEntryPoint         := fEntryPoint;
  Header.BaseOfCode                  := CodeRVA;
  Header.ImageBase                   := fBinaryImage.PreferredAddress;
  Header.SectionAlignment            := SectionAlignment;
  Header.FileAlignment               := cDefaultFileAlignment;
  Header.MajorOperatingSystemVersion := $06;  // [TODO] Find appropriate constant
  Header.MinorOperatingSystemVersion := $00;
  Header.MajorImageVersion           := $00;
  Header.MinorImageVersion           := $00;
  Header.MajorSubsystemVersion       := $06;  // [TODO] Find appropriate constant
  Header.MinorSubsystemVersion       := $00;
  Header.Reserved1                   := $00;
  Header.SizeOfImage                 := SizeOfImage;
  Header.SizeOfHeaders               := TLinkerUtils.Align( SizeOfHeaders, cDefaultFileAlignment );
  Header.CheckSum                    := $00;
  Header.Subsystem                   := $03;  // [TODO] This should be 3 for CUI and 2 for GUI, set to appropriate constant/setting
  Header.DllCharacteristics          := $00;
  Header.SizeOfStackReserve          := $00;
  Header.SizeOfStackCommit           := $00;
  Header.SizeOfHeapReserve           := $00;
  Header.SizeOfHeapCommit            := $00;
  Header.LoaderFlags                 := $00;
  Header.NumberOfRvaAndSizes         := Length( fDataDirectory );
  if fStream.Write( @Header, sizeof( IMAGE_OPTIONAL_HEADER_64 ) ) <> sizeof( IMAGE_OPTIONAL_HEADER_64 ) then exit( stStreamWriteError );
  Result := stSuccess;
end;

function TPEWriter.FindEntryPoint: TStatus;
var
  Section: ISection;
  Symbol: ISymbol;
begin
  //- For executables, the entry point is defined by symbol '_start'
  for Symbol in fBinaryImage.Symbols do begin
    if ( Symbol.Name = '_start' ) and ( assigned( Symbol.Section ) ) then begin
      fEntryPoint := Symbol.Section.RVA + Symbol.Value;
      exit( stSuccess );
    end;
  end;
  //- If we got here, and this is an executable, set the entry point to the first
  //- code section.
  for Section in fBinaryImage.Sections do begin
    if TLinkerUtils.IsCodeSection( Section ) then begin
      fEntryPoint := Section.RVA;
      exit( stSuccess );
    end;
  end;
  Result := fLog.Insert( stCannotLocateEntryPoint, lsError );
end;

function TPEWriter.WriteDataDirectoryTable: TStatus;
var
  DirectoryTableSize: nativeuint;
begin
  DirectoryTableSize := sizeof( IMAGE_DATA_DIRECTORY ) * Length( fDataDirectory );
  if fStream.Write( @fDataDirectory[ 0 ], DirectoryTableSize ) <> DirectoryTableSize then exit( stStreamWriteError );
  Result := stSuccess;
end;

function TPEWriter.SectionAttributesToCharacteristics( const Attributes: TSectionAttributes ): uint32;
begin
  Result := 0;
  if saReadable in Attributes then begin
    Result := Result or cIMAGE_SCN_MEM_READ;
  end;
  if saWritable in Attributes then begin
    Result := Result or cIMAGE_SCN_MEM_WRITE;
  end;
  if saExecutable in Attributes then begin
    Result := Result or cIMAGE_SCN_CNT_CODE;
    Result := Result or cIMAGE_SCN_MEM_EXECUTE;
  end;
  if saIData in Attributes then begin
    Result := Result or cIMAGE_SCN_MEM_READ;
    Result := Result or cIMAGE_SCN_CNT_INITIALIZED_DATA;
  end;
end;

function TPEWriter.WriteSectionHeaders: TStatus;
var
  Section: ISection;
  Header: IMAGE_SECTION_HEADER;
  utfString: IUnicodeString;
  S: string;
  FilePtr: uint64;
begin
  FilePtr := SizeOfHeaders + SizeOfSectionHeaders;
  FilePtr := TLinkerUtils.Align( FilePtr, cDefaultFileAlignment );
  // We loop through the section records and create
  // headers for each.
  for Section in fBinaryImage.Sections do begin
//    if not assigned( Section.Content ) then continue;
//    if SectionRec.Content.Size = 0 then continue;
    FillChar( Header, sizeof( IMAGE_SECTION_HEADER ), 0 );
    // Deal with encoding the header name.
    S := Section.Name;
    if S.Length > 8 then S := S.Left( 8 );
    utfString := TUnicodeString.Create( S, TUnicodeFormat.utfANSI );
    Move( utfString.AsPointer^, Header.Name, utfString.Length );
    utfString := nil;
    {$region ' Size of various section types '}
    if Supports( Section, IContentSection ) then begin
      if assigned( ( Section as IContentSection ).Content ) then begin
        Header.SizeOfRawData := TLinkerUtils.Align( ( Section as IContentSection ).Content.Size, cDefaultFileAlignment );
      end;
    end else if Supports( Section, IVirtualSection ) then begin
        Header.SizeOfRawData := TLinkerUtils.Align( ( Section as IVirtualSection ).Size, cDefaultFileAlignment );
    end;
    if Header.SizeOfRawData <> 0 then begin
      Header.VirtualSize := TLinkerUtils.Align( Header.SizeOfRawData, SectionAlignment );
    end;
    {$endregion}
    Header.VirtualAddress := Section.RVA;
    Header.PointerToRawData := FilePtr;
    FilePtr := FilePtr + Header.SizeOfRawData;
//    FilePtr := Align( FilePtr, cDefaultFileAlignment );
    Header.Characteristics := SectionAttributesToCharacteristics( Section.Attributes );
    if fStream.Write( @Header, sizeof( IMAGE_SECTION_HEADER ) ) <> sizeof( IMAGE_SECTION_HEADER ) then exit( stStreamWriteError );
  end;
  Result := stSuccess;
end;

function TPEWriter.WritePaddingUntil( const Position: uint64 ): TStatus;
var
  ZeroBuffer: array[ 0..511 ] of uint8;
  Remaining: uint64;
  BytesToWrite: uint64;
  BytesWritten: uint64;
begin
  if fStream.Position >= Position then exit( stSuccess );
  FillChar( ZeroBuffer, Length( ZeroBuffer ), 0 );
  Remaining := Position - fStream.Position;
  repeat
    BytesToWrite := Remaining;
    if BytesToWrite > Length( ZeroBuffer ) then BytesToWRite := Length( ZeroBuffer );
    BytesWritten := fStream.Write( @ZeroBuffer[ 0 ], BytesToWrite );
    Remaining := Remaining - BytesWritten;
  until Remaining = 0;
  Result := stSuccess;
end;

function TPEWriter.RelocationsInSection( const Section: ISection ): IReadOnlyList< IRelocation >;
var
  List: IList< IRelocation >;
  Relocation: IRelocation;
begin
  List := TList< IRelocation >.Create;
  Result := List.getAsReadOnly;
  for Relocation in fBinaryImage.Relocations do begin
    if Relocation.Section = Section then List.Add( Relocation );
  end;
end;

function TPEWriter.WriteSections: TStatus;
var
  Section: ISection;
  Relocator: IRelocator;
begin
  for Section in fBinaryImage.Sections do begin
    if not supports( Section, IContentSection ) then continue;
    case fBinaryImage.Bittedness of  // [ TODO ] Enahance to cover other targets
      bits32: Relocator := Tx86Relocator.Create;
      bits64: Relocator := Tx8664Relocator.Create( fLog, fBinaryImage.PreferredAddress );
    end;
    Result := fBinaryImage.WriteSectionContent( Relocator, fStream, ( Section as IContentSection ), RelocationsInSection( Section ) );
    if not Result then exit;
    Result := WritePaddingUntil( TLinkerUtils.Align( fStream.Position, cDefaultFileAlignment ) );
    if not Result then exit;
  end;
end;

function TPEWriter.FindSymbolByName( const Name: string ): ISymbol;
var
  Symbol: ISymbol;
begin
  Result := nil;
  for Symbol in fBinaryImage.Symbols do begin
    if Symbol.Name = Name then exit( Symbol );
  end;
end;

function TPEWriter.ConfigureImports: TStatus;
var
  iltstart: ISymbol;
  iltend: ISymbol;
  Size: TVirtualAddress;
begin
  // Find the ILT start and ILT End
  iltstart := FindSymbolByName( 'ilt_start' );
  if not assigned( iltstart ) then exit( fLog.Insert( stCannotLocateILT, lsError ) );
  iltend := FindSymbolByName( 'ilt_end' );
  if not assigned( iltend ) then exit( fLog.Insert( stCannotLocateILT, lsError ) );
  if not assigned( iltstart.section ) then exit( fLog.Insert( stCannotLocateILT, lsError ) );
  if not assigned( iltend.section ) then exit( fLog.Insert( stCannotLocateILT, lsError ) );
  // Calculate size of ILT/IAT
  Size := ( iltend.section.rva + iltend.value ) - ( iltstart.section.rva + iltstart.value );
  //- Setup entries
  fDataDirectory[ cIMAGE_DIRECTORY_ENTRY_IMPORT ].VirtualAddress := iltstart.section.RVA;
  fDataDirectory[ cIMAGE_DIRECTORY_ENTRY_IMPORT ].Size := iltstart.value;
  fDataDirectory[ cIMAGE_DIRECTORY_ENTRY_IAT ].VirtualAddress := CodeRVA;
  fDataDirectory[ cIMAGE_DIRECTORY_ENTRY_IAT ].Size := Size;
  Result := stSuccess;
end;

function TPEWriter.Write( const BinaryImage: IBinaryImage; const Target: IUnicodeStream ): TStatus;
begin
  // Set up some necessary class members
  fStream := Target;
  fBinaryImage := BinaryImage;
  SetLength( fDataDirectory, cDefaultDataDirectorySize ); // [ TODO ] This may not need to be a full 16?
  try
    //- Ensure we know where the entry point is.
    Result := FindEntryPoint;
    if not Result then exit;
    //- Generate a DOS header
    Result := WriteMZHeader;
    if not Result then exit;
    //- Write the PE signature.
    Result := WritePESignature;
    if not Result then exit;
    //- Write the COFF/PE image header.
    Result := WriteImageHeader;
    if not Result then exit;
    //- Write the Optional PE header.
    Result := WritePEHeader;
    if not Result then exit;
    //- Before writing the data directory, set the entries for the IAT and ILT.
    Result := ConfigureImports;
    if not Result then exit;
    //- Write the Data Directory Table
    Result := WriteDataDirectoryTable;
    if not Result then exit;
    //- Write the section headers.
    Result := WriteSectionHeaders;
    if not Result then exit;
    //- Pad out to file alignment
    WritePaddingUntil( TLinkerUtils.Align( fStream.Position, cDefaultFileAlignment ) );
    //- Write the sections.
    Result := WriteSections;
  finally
    // Some clean up.
    SetLength( fDataDirectory, 0 );
  end;
end;

end.

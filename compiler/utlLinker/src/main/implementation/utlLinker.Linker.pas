(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.Linker;

interface
uses
  utlStatus
, utlLog
, utlIO
, utlCollections
, utlLinker
, utlLinker.BinaryImage
;

type
  TLinker = class( TInterfacedObject, ILinker )
  private
    fLog: ILog;
    fInputImages: IList< IBinaryImage >;
  private
    function MergeImages( const TargetImage: IBinaryImage ): TStatus;
    function InternalLink( const BinaryImage: IBinaryImage; const FirstSection: TVirtualAddress; const SectionAlignment: TVirtualAddress ): TStatus;
    function SortSections( const BinaryImage: IBinaryImage ): TStatus;
    function IdentifyFileType( const FileStream: IReadOnlyUnicodeStream ): TFileType;
    function LoadElfFile( const InputStream: IReadOnlyUnicodeStream; const BinaryImage: IBinaryImage ): TStatus;
    function AlignSections( const BinaryImage: IBinaryImage; const FirstSection: TVirtualAddress; const SectionAlignment: TVirtualAddress ): TStatus;
  strict private //- ILinker -//
    function LoadInputFile( const InputFilepath: string ): TStatus;
    function LinkPEFile( const TargetFilepath: string; const Bittedness: TBittedness; const Endianness: TEndianness; const PreferredAddress: TVirtualAddress ): TStatus;
  public
    constructor Create( const Log: ILog ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  SysUtils
, utlLinker.Elf.Reader
, utlLinker.PE.Writer
, utlLinker.Utils
;

constructor TLinker.Create( const Log: ILog );
begin
  inherited Create;
  fLog := Log;
  fInputImages := TList< IBinaryImage >.Create;
end;

destructor TLinker.Destroy;
begin
  fInputImages := nil;
  fLog := nil;
  inherited Destroy;
end;

function TLinker.IdentifyFileType( const FileStream: IReadOnlyUnicodeStream ): TFileType;
var
  StorePosition: nativeuint;
begin
  Result := ftUnspecified;
  StorePosition := FileStream.Position;
  try
    if TElfReader.IsElf( FileStream ) then exit( ftElf );
  finally
    FileStream.Position := StorePosition;
  end;
end;

function TLinker.SortSections( const BinaryImage: IBinaryImage ): TStatus;
const  //- Describes the sort order -//
  Code  = 0;
  IData = 1;
  Data  = 2;
  Other = 3;
begin
  BinaryImage.Sections.Sort(
      function ( const A: ISection; const B: ISection ): TCompareResult
      var
        aA: integer;
        aB: integer;
      begin
        if TLinkerUtils.IsCodeSection(  A ) then aA := Code  else
        if TLinkerUtils.IsIDataSection( A ) then aA := IData else
        if TLinkerUtils.IsDataSection(  A ) then aA := Data  else aA := Other;

        if TLinkerUtils.IsCodeSection(  B ) then aB := Code  else
        if TLinkerUtils.IsIDataSection( B ) then aB := IData else
        if TLinkerUtils.IsDataSection(  B ) then aB := Data  else aB := Other;

        if aA < aB then Result := crAIsLess else
        if aB < aA then Result := crBIsLEss else Result := crEqual;
      end
  );
  Result := stSuccess;
end;

function TLinker.AlignSections( const BinaryImage: IBinaryImage; const FirstSection: TVirtualAddress; const SectionAlignment: TVirtualAddress ): TStatus;
var
  CurrentAlignment: TVirtualAddress;
  Section: ISection;
begin
  CurrentAlignment := FirstSection;
  for Section in BinaryImage.Sections do begin
    Section.RVA := CurrentAlignment;
    if Supports( Section, IVirtualSection ) then begin
      CurrentAlignment := CurrentAlignment + ( Section as IVirtualSection ).Size;
    end else begin
      if not assigned( ( Section as IContentSection ).Content ) then continue;
      CurrentAlignment := CurrentAlignment + ( Section as IContentSection ).Content.Size;
    end;
    CurrentAlignment := TLinkerUtils.Align( CurrentAlignment, SectionAlignment );
  end;
  Result := stSuccess;
end;

function TLinker.MergeImages( const TargetImage: IBinaryImage ): TStatus;
var
  InputImage    : IBinaryImage;
  Section       : ISection;
  Symbol        : ISymbol;
  Relocation    : IRelocation;
begin
  // Copy all sections, Symbols and Relocations from input images to output image.
  // Note, we're copying by reference, thus, symbols and relocations remain unaffected.
  for InputImage in fInputImages do begin
    for Section in InputImage.Sections do TargetImage.Sections.Add( Section );
    for Symbol in InputImage.Symbols do TargetImage.Symbols.Add( Symbol );
    for Relocation in InputImage.Relocations do TargetImage.Relocations.Add( Relocation );
  end;
  Result := stSuccess;
end;

function TLinker.InternalLink( const BinaryImage: IBinaryImage; const FirstSection: TVirtualAddress; const SectionAlignment: TVirtualAddress ): TStatus;
var
  InputImage: IBinaryImage;
  Section: ISection;
begin
  // Verify that all input files are of the same bittedness and endianness as our output file.
  for InputImage in fInputImages do begin
    if ( InputImage.Bittedness <> BinaryImage.Bittedness ) or
       ( InputImage.Bittedness = bitsUnspecified ) then begin
      Result := fLog.Insert( stBitwidthMissmatchOnLink, lsError, [ InputImage.Filepath ] );
      exit;
    end;
    if ( InputImage.Endianness <> BinaryImage.Endianness ) or
       ( InputImage.Endianness = enUnspecified ) then begin
      Result := fLog.Insert( stEndianMissmatchOnLink, lsError, [ InputImage.Filepath ] );
      exit;
    end;
  end;
  // Merge the input images.
  Result := MergeImages( BinaryImage );
  if not Result then exit;
  // We can now dispose the input images, we're done with them.
  fInputImages := nil;
  // Sort all sections in our output image.
  Result := SortSections( BinaryImage );
  if not Result then exit;
  // Align the sections
  Result := AlignSections( BinaryImage, FirstSection, SectionAlignment );
end;

function TLinker.LinkPEFile( const TargetFilepath: string; const Bittedness: TBittedness; const Endianness: TEndianness; const PreferredAddress: TVirtualAddress ): TStatus;
var
  BinaryImage: IBinaryImage;
  Target: IUnicodeStream;
  PEWriter: TPEWriter;
begin
  // Create the target file stream.
  if FileExists( TargetFilepath ) then DeleteFile( TargetFilePath );
  Target := TFileStream.Create( TargetFilepath, FALSE );
  // Create a binary image to link.
  BinaryImage := TBinaryImage.Create( TargetFilepath );
  BinaryImage.Bittedness := Bittedness;
  BinaryImage.Endianness := Endianness;
  BinaryImage.PreferredAddress := PreferredAddress;
  // Write the binary image to file.
  PEWriter := TPEWriter.Create( fLog );
  try
    Result := InternalLink( BinaryImage, PEWriter.FirstSection, PEWriter.SectionAlignment );
    if not Result then exit;
    Result := PEWriter.Write( BinaryImage, Target );
  finally
    PEWriter.Free;
  end;
end;

function TLinker.LoadElfFile( const InputStream: IReadOnlyUnicodeStream; const BinaryImage: IBinaryImage ): TStatus;
var
  ELFReader: TElfReader;
begin
  // Create an ELF reader to read in the file.
  ElfReader := TElfReader.Create( fLog, InputStream );
  try
    Result := ElfReader.Read( BinaryImage );
  finally
    ElfReader.Free;
  end;
end;

function TLinker.LoadInputFile( const InputFilepath: string ): TStatus;
var
  InputStream: IReadOnlyUnicodeStream;
  BinaryImage: IBinaryImage;
  FileType: TFileType;
begin
  // Create a binary image instance to load into.
  BinaryImage := TBinaryImage.Create( InputFilepath );

  // Open the file as a stream.
  if not FileExists( InputFilepath ) then exit( TStatus.Return( stIOFileNotFound, [ InputFilepath ] ) );
  InputStream := TFileStream.Create( InputFilePath, True ) as IReadOnlyUnicodeStream;

  // Get the type of file we're dealing with.
  FileType := IdentifyFileType( InputStream );

  // Act based on file type
  case FileType of
    ftElf: Result := LoadElfFile( InputStream, BinaryImage );
    //ftPE: ;
    else Result := fLog.Insert( stUnknownInputFileType, lsError, [ InputFilePath ] );
  end;
  if not Result then exit;

  //- Add the loaded image to our input images list.
  fInputImages.Add( BinaryImage );
  Result := stSuccess;
end;

end.

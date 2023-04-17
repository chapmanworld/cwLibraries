(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.BinaryImage.Standard;

interface
uses
  utlStatus
, utlIO
, utlCollections
, utlLinker
, utlLinker.BinaryImage
;

type
  TBinaryImage = class( TInterfacedObject, IBinaryImage )
  private
    fFilepath: string;
    fEndianness: TEndianness;
    fBittedness: TBittedness;
    fPreferredAddress: TVirtualAddress;
    fSections: IList< ISection >;
    fSymbols: IList< ISymbol >;
    fRelocations: IList< IRelocation >;
    fStringLists: IStringLists;
  strict private //- Utils
    function CopyBytes( const SourceStream: IReadOnlyStream; const TargetStream: IStream; const Count: nativeuint ): TStatus;
    function SortRelocations( const Relocations: IReadOnlyList<IRelocation> ): IReadOnlyList< IRelocation >;
  strict private //- IBinaryImage -//
    function getFilepath: string;
    procedure setFilepath( const value: string );
    function getEndianness: TEndianness;
    procedure setEndianness( const value: TEndianness );
    function getBittedness: TBittedness;
    procedure setBittedness( const value: TBittedness );
    function getPreferredAddress: TVirtualAddress;
    procedure setPreferredAddress( const value: TVirtualAddress );
    function Sections: IList< ISection >;
    function AddVirtualSection( const Size: TVirtualSize ): IVirtualSection;
    function AddContentSection( const Content: IReadOnlyUnicodeStream ): IContentSection;
    function Symbols: IList< ISymbol >;
    function AddSymbol( const Name: string ): ISymbol;
    function Relocations: IList< IRelocation >;
    function AddRelocation: IRelocation;
    function StringLists: IStringLists;
    function WriteSectionContent( const Relocator: IRelocator; const TargetStream: IStream; const Section: IContentSection; const Relocations: IReadOnlyList< IRelocation > ): TStatus;
  public
    constructor Create( const Filepath: string ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  utlLinker.BinaryImage.StringLists
, utlLinker.BinaryImage.VirtualSection
, utlLinker.BinaryImage.ContentSection
, utlLinker.BinaryImage.Symbol
, utlLinker.BinaryImage.Relocation
;

function TBinaryImage.AddContentSection( const Content: IReadOnlyUnicodeStream ): IContentSection;
begin
  Result := TContentSection.Create( Content );
  fSections.Add( Result );
end;

function TBinaryImage.AddRelocation: IRelocation;
begin
  Result := TRelocation.Create;
  fRelocations.Add( Result );
end;

function TBinaryImage.AddSymbol( const Name: string ): ISymbol;
begin
  Result := TSymbol.Create;
  Result.Name := Name;
  fSymbols.Add( Result );
end;

function TBinaryImage.AddVirtualSection( const Size: TVirtualSize ): IVirtualSection;
begin
  Result := TVirtualSection.Create;
  Result.Size := Size;
  fSections.Add( Result );
end;

constructor TBinaryImage.Create( const Filepath: string );
begin
  inherited Create;
  fPreferredAddress := $400000;
  fFilepath         := Filepath;
  fEndianness       := TEndianness.enUnspecified;
  fBittedness       := TBittedness.bitsUnspecified;
  fSections         := TList< ISection >.Create;
  fSymbols          := TList< ISymbol >.Create;
  fRelocations      := TList< IRelocation >.Create;
  fStringLists      := TStringLists.Create;
end;

destructor TBinaryImage.Destroy;
begin
  fSections    := nil;
  fRelocations := nil;
  fSymbols     := nil;
  fStringLists := nil;
  inherited Destroy;
end;

function TBinaryImage.getBittedness: TBittedness;
begin
  Result := fBittedness;
end;

function TBinaryImage.getEndianness: TEndianness;
begin
  Result := fEndianness;
end;

function TBinaryImage.getFilepath: string;
begin
  Result := fFilepath;
end;

function TBinaryImage.getPreferredAddress: TVirtualAddress;
begin
  Result := fPreferredAddress;
end;

function TBinaryImage.Relocations: IList<IRelocation>;
begin
  Result := fRelocations;
end;

function TBinaryImage.Sections: IList< ISection >;
begin
  Result := fSections;
end;

procedure TBinaryImage.setBittedness( const value: TBittedness );
begin
  fBittedness := value;
end;

procedure TBinaryImage.setEndianness( const value: TEndianness );
begin
  fEndianness := value;
end;

procedure TBinaryImage.setFilepath( const value: string );
begin
  fFilePath := Value;
end;

procedure TBinaryImage.setPreferredAddress( const value: TVirtualAddress );
begin
  fPreferredAddress := value;
end;

function TBinaryImage.StringLists: IStringLists;
begin
  Result := fStringLists;
end;

function TBinaryImage.Symbols: IList< ISymbol >;
begin
  Result := fSymbols;
end;

function TBinaryImage.SortRelocations( const Relocations: IReadOnlyList< IRelocation > ): IReadOnlyList< IRelocation >;
var
  idx: nativeuint;
  List: IList< IRelocation >;
begin
  List := TList< IRelocation >.Create;
  Result := List.getAsReadOnly;
  if Relocations.Count = 0 then exit;
  if Relocations.Count = 1 then begin
    List.Add( Relocations[ 0 ] );
    exit;
  end;
  // Sort the list.
  List.Copy( Relocations );
  List.Sort(
      function ( const A: IRelocation; const B: IRelocation ): TCompareResult
      begin
        if A.Offset < B.Offset then Result := crAIsLess else
        if B.Offset < A.Offset then Result := crBIsLess else Result := crEqual;
      end
   );
end;

function TBinaryImage.CopyBytes( const SourceStream: IReadOnlyStream; const TargetStream: IStream; const Count: nativeuint ): TStatus;
var
  Buffer: IBuffer;
begin
  Buffer := TBuffer.Create( Count );
  try
    if SourceStream.Read( Buffer.DataPtr, Buffer.Size ) <> Buffer.Size then exit( stStreamReadError );
    if TargetSTream.Write( Buffer.DataPtr, Buffer.Size ) <> Buffer.Size then exit( stStreamWriteError );
    Result := stSuccess;
  finally
    Buffer := nil;
  end;
end;

function TBinaryImage.WriteSectionContent( const Relocator: IRelocator; const TargetStream: IStream; const Section: IContentSection; const Relocations: IReadOnlyList< IRelocation > ): TStatus;
var
  SortedRelocations: IReadOnlyList< IRelocation >;
  Relocation: IRelocation;
  Offset: nativeuint;
  RelocationIdx: nativeuint;
  TempList: IList< IRelocation >;
  Delta: nativeuint;
begin
  // If there is no data, there is nothing to write, we're done.
  if Section.Content.Size = 0 then exit( stSuccess );
  Section.Content.Position := 0;
  // First, a get out free clause - if there are no relocations we just write the data.
  if Relocations.Count = 0 then begin
    TargetStream.CopyFrom( Section.Content );
    exit( stSuccess );
  end;
  // We need a list of relocations sorted by offset.
  SortedRelocations := SortRelocations( Relocations );
  RelocationIdx := 0;
  repeat
    //- Get the first relocation
    Offset := SortedRelocations[ RelocationIdx ].Offset;

    //- Write the stream until offset.
    if Offset >= Section.Content.Size then begin
      exit( stUnknown ); // [ TODO ] Relocation out of bounds error
    end;
    if Offset > Section.Content.Position then begin
      Result := CopyBytes( Section.Content, TargetStream, Offset - Section.Content.Position );
    end;

    //- We're at the offset, get all sorted locations with matching index.
    TempList := TList< IRelocation >.Create;
    try
      for Relocation in SortedRelocations do begin
        if Relocation.Offset = Offset then TempList.Add( Relocation );
      end;
      Delta := TargetStream.Position;
      try
        Result := Relocator.Relocate( TempList, TargetStream );
      finally
        Delta := TargetStream.Position - Delta;
      end;
      Section.Content.Position := Section.Content.Position + Delta; // Skip original unrelocated bytes.
    finally
      TempList := nil;
    end;

    //- increment RelocationIdx until past offset
    inc( relocationIdx );
    while ( RelocationIdx < SortedRelocations.Count ) and
          ( SortedRelocations[ RelocationIdx ].Offset = Offset ) do inc( relocationIdx );
  until RelocationIdx >= SortedRelocations.Count;

  // Copy whatever remains of the section content.
  if not Section.Content.EndOfStream then TargetStream.CopyFrom( Section.Content );
end;

end.

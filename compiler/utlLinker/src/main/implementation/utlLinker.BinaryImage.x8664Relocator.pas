(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.BinaryImage.x8664Relocator;

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
  Tx8664Relocator = class( TInterfacedObject, IRelocator )
  private
    fLog: ILog;
    fBaseAddress: TVirtualAddress;
  strict private //- IRelocator -//
    function Relocate( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
  private
    function Reloc_X86_64_16(        const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_32(        const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_32S(       const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_64(        const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_8(         const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_COPY(      const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_DPTMOD64(  const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_DTPOFF32(  const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_DTPOFF64(  const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_GLOB_DAT(  const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_GOT32(     const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_GOTOFF64(  const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_GOTPC32(   const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_GOTPCREL(  const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_GOTTPOFF(  const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_JUMP_SLOT( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_PC16(      const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_PC32(      const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_PC64(      const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_PC8(       const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_PLT32(     const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_RELATIVE(  const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_SIZE32(    const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_SIZE64(    const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_TLSGD(     const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_TLSLD(     const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_TPOFF32(   const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
    function Reloc_X86_64_TPOFF64(   const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
  public
    constructor Create( const Log: ILog; const BaseAddress: TVirtualAddress ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  utlTypes
, utlLinker.Elf.Datatypes
;

function Tx8664Relocator.Reloc_X86_64_64( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
var
  u64: uint64;
begin
  (* Special handling for relocations in the .idata section, or that target the .idata section *)
  if ( Relocations[ 0 ].Section.Name = '.idata' ) or ( Relocations[ 0 ].Symbol.Section.Name = '.idata' ) then begin
    {$warnings off} u64 := Relocations[ 0 ].Symbol.Value + Relocations[ 0 ].Symbol.Section.RVA + Relocations[ 0 ].Addend; {$warnings on}
  end else begin
    {$warnings off} u64 := fBaseAddress + Relocations[ 0 ].Symbol.Value + Relocations[ 0 ].Symbol.Section.RVA + Relocations[ 0 ].Addend; {$warnings on}
  end;
  if TargetStream.Write( @u64, sizeof( uint64 ) ) <> sizeof( uint64 ) then exit( stStreamWriteError );
  Result := stSuccess;
end;

function Tx8664Relocator.Reloc_X86_64_PC32( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_GOT32( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_PLT32( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_COPY( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_GLOB_DAT( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_JUMP_SLOT( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_RELATIVE( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_GOTPCREL( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_32( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
var
  u32: uint32;
  SymbolValue: uint32;
  SymbolSectionRVA: uint32;
begin
  if not assigned( Relocations[ 0 ].Symbol.Section ) then begin
    {$warnings off} u32 := Relocations[ 0 ].Symbol.Value + Relocations[ 0 ].Addend; {$warnings on}
    exit;
  end;
  if ( Relocations[ 0 ].Section.Name = '.idata' ) or ( Relocations[ 0 ].Symbol.Section.Name = '.idata' ) then begin
    {$warnings off} u32 := Relocations[ 0 ].Symbol.Value + Relocations[ 0 ].Symbol.Section.RVA + Relocations[ 0 ].Addend; {$warnings on}
  end else begin
    {$warnings off} u32 := Relocations[ 0 ].Symbol.Value + Relocations[ 0 ].Symbol.Section.RVA + Relocations[ 0 ].Addend; {$warnings on}
  end;
  if TargetStream.Write( @u32, sizeof( uint32 ) ) <> sizeof( uint32 ) then exit( stStreamWriteError );
  Result := stSuccess;
end;

function Tx8664Relocator.Reloc_X86_64_32S( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
var
  i32: int32;
begin
  // This is signed relative from PC.
  {$warnings off} i32 := fBaseAddress + ( Relocations[ 0 ].Symbol.Value + Relocations[ 0 ].Symbol.Section.RVA + Relocations[ 0 ].Addend ); {$warnings on}
  if TargetStream.Write( @i32, sizeof( int32 ) ) <> sizeof( int32 ) then exit( stStreamWriteError );
  Result := stSuccess;
end;

function Tx8664Relocator.Reloc_X86_64_16( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_PC16( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_8( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_PC8( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_DPTMOD64( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_DTPOFF64( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_TPOFF64( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_TLSGD( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_TLSLD( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_DTPOFF32( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_GOTTPOFF( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_TPOFF32( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_PC64( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_GOTOFF64( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_GOTPC32( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_SIZE32( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

function Tx8664Relocator.Reloc_X86_64_SIZE64( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
begin
  Result := fLog.Insert( stUnknownRelocationType, lsError );
end;

constructor Tx8664Relocator.Create( const Log: ILog; const BaseAddress: TVirtualAddress );
begin
  inherited Create;
  fLog := Log;
  fBaseAddress := BaseAddress;
end;

destructor Tx8664Relocator.Destroy;
begin
  fLog := nil;
  inherited Destroy;
end;

function Tx8664Relocator.Relocate( const Relocations: IReadOnlyList<IRelocation>; const TargetStream: IStream ): TStatus;
var
  Relocation: IRelocation;
begin
  for Relocation in Relocations do begin
//    fLog.Insert( stLinkerVerbose, lsVerbose, [
//      'Relocation in ' + Relocation.Section.Name + ' at 0x' + Relocation.Offset.AsHex +
//      ' references symbol "' + Relocation.Symbol.Name +'" in section ' +
//      Relocation.Symbol.Section.Name + ' with value ' + Relocation.Symbol.Value.AsString +
//      ' + 0x' + Relocation.Addend.AsHex ] );
  end;
  case Relocations[0].RelocationType of
    R_X86_64_NONE      : exit( stSuccess );
    R_X86_64_64        : Result := Reloc_X86_64_64        ( Relocations, TargetStream );
    R_X86_64_PC32      : Result := Reloc_X86_64_PC32      ( Relocations, TargetStream );
    R_X86_64_GOT32     : Result := Reloc_X86_64_GOT32     ( Relocations, TargetStream );
    R_X86_64_PLT32     : Result := Reloc_X86_64_PLT32     ( Relocations, TargetStream );
    R_X86_64_COPY      : Result := Reloc_X86_64_COPY      ( Relocations, TargetStream );
    R_X86_64_GLOB_DAT  : Result := Reloc_X86_64_GLOB_DAT  ( Relocations, TargetStream );
    R_X86_64_JUMP_SLOT : Result := Reloc_X86_64_JUMP_SLOT ( Relocations, TargetStream );
    R_X86_64_RELATIVE  : Result := Reloc_X86_64_RELATIVE  ( Relocations, TargetStream );
    R_X86_64_GOTPCREL  : Result := Reloc_X86_64_GOTPCREL  ( Relocations, TargetStream );
    R_X86_64_32        : Result := Reloc_X86_64_32        ( Relocations, TargetStream );
    R_X86_64_32S       : Result := Reloc_X86_64_32S       ( Relocations, TargetStream );
    R_X86_64_16        : Result := Reloc_X86_64_16        ( Relocations, TargetStream );
    R_X86_64_PC16      : Result := Reloc_X86_64_PC16      ( Relocations, TargetStream );
    R_X86_64_8         : Result := Reloc_X86_64_8         ( Relocations, TargetStream );
    R_X86_64_PC8       : Result := Reloc_X86_64_PC8       ( Relocations, TargetStream );
    R_X86_64_DPTMOD64  : Result := Reloc_X86_64_DPTMOD64  ( Relocations, TargetStream );
    R_X86_64_DTPOFF64  : Result := Reloc_X86_64_DTPOFF64  ( Relocations, TargetStream );
    R_X86_64_TPOFF64   : Result := Reloc_X86_64_TPOFF64   ( Relocations, TargetStream );
    R_X86_64_TLSGD     : Result := Reloc_X86_64_TLSGD     ( Relocations, TargetStream );
    R_X86_64_TLSLD     : Result := Reloc_X86_64_TLSLD     ( Relocations, TargetStream );
    R_X86_64_DTPOFF32  : Result := Reloc_X86_64_DTPOFF32  ( Relocations, TargetStream );
    R_X86_64_GOTTPOFF  : Result := Reloc_X86_64_GOTTPOFF  ( Relocations, TargetStream );
    R_X86_64_TPOFF32   : Result := Reloc_X86_64_TPOFF32   ( Relocations, TargetStream );
    R_X86_64_PC64      : Result := Reloc_X86_64_PC64      ( Relocations, TargetStream );
    R_X86_64_GOTOFF64  : Result := Reloc_X86_64_GOTOFF64  ( Relocations, TargetStream );
    R_X86_64_GOTPC32   : Result := Reloc_X86_64_GOTPC32   ( Relocations, TargetStream );
    R_X86_64_SIZE32    : Result := Reloc_X86_64_SIZE32    ( Relocations, TargetStream );
    R_X86_64_SIZE64    : Result := Reloc_X86_64_SIZE64    ( Relocations, TargetStream );
    else begin
      Result := fLog.Insert( stUnknownRelocationType, lsError );
    end;
  end;
end;

end.


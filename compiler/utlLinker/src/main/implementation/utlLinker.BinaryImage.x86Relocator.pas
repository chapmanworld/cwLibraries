(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.BinaryImage.x86Relocator;

interface
uses
  utlStatus
, utlIO
, utlCollections
, utlLinker
, utlLinker.BinaryImage
;

type
  Tx86Relocator = class( TInterfacedObject, IRelocator )
  strict private //- IRelocator -//
    function Relocate( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
  end;

implementation

function Tx86Relocator.Relocate( const Relocations: IReadOnlyList<IRelocation>; const TargetStream: IStream ): TStatus;
begin

end;

end.

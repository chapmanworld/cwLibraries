(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCompile.ArchetypeMember;

interface
uses
  utlIO
, utlCollections
, utlCompile
, utlCompile.Reflection
;

{$region ' TArchetypeMember '}

type
  TArchetypeMember = class( TInterfacedObject, IArchetypeMember )
  private
    fOffset: uint64;
    fDataType: TArchetypeMemberType;
    fDisplayName: string;
  private
    function getBaseAddress( const ModelInstance: IModelInstance; const Representation: IInterface ): nativeuint;
  strict private //- IArchetypeMember -//
    function Offset: uint64;
    function DataType: TArchetypeMemberType;
    function DisplayName: string;
    procedure setOffset( const Value: uint64 );
    function AsInt8( const ModelInstance: IModelInstance; const Representation: IInterface ): int8;
    function AsInt16( const ModelInstance: IModelInstance; const Representation: IInterface ): int16;
    function AsInt32( const ModelInstance: IModelInstance; const Representation: IInterface ): int32;
    function AsInt64( const ModelInstance: IModelInstance; const Representation: IInterface ): int64;
    function AsUInt8( const ModelInstance: IModelInstance; const Representation: IInterface ): uint8;
    function AsUInt16( const ModelInstance: IModelInstance; const Representation: IInterface ): uint16;
    function AsUInt32( const ModelInstance: IModelInstance; const Representation: IInterface ): uint32;
    function AsUInt64( const ModelInstance: IModelInstance; const Representation: IInterface ): uint64;
    function AsSingle( const ModelInstance: IModelInstance; const Representation: IInterface ): single;
    function AsDouble( const ModelInstance: IModelInstance; const Representation: IInterface ): double;
    function AsGUID( const ModelInstance: IModelInstance; const Representation: IInterface ): TGUID;
    function AsBoolean( const ModelInstance: IModelInstance; const Representation: IInterface ): boolean;
    function AsStringList( const ModelInstance: IModelInstance; const Representation: IInterface ): IReadOnlyList< string >;
    function AsUnicodeStream( const ModelInstance: IModelInstance; const Representation: IInterface ): IUnicodeStream;
    function AsCursor( const ModelInstance: IModelInstance; const Representation: IInterface ): ICursor;
    function AsSingleReference( const ModelInstance: IModelInstance; const Representation: IInterface ): IInterface;
    procedure SetSingleReference( const ModelInstance: IModelInstance; const Representation: IInterface; const Value: IInterface );
    function AsReferenceList( const ModelInstance: IModelInstance; const Representation: IInterface ): IReadOnlyList< IInterface >;
    procedure AddToReferenceList( const ModelInstance: IModelInstance; const Representation: IInterface; const Item: IInterface );
    function AsString( const ModelInstance: IModelInstance; const Representation: IInterface ): string;

    function IsSingleReference( const ModelInstance: IModelInstance; const Representation: IInterface ): boolean;
    function IsReferenceList( const ModelInstance: IModelInstance; const Representation: IInterface ): boolean;
  public
    constructor Create( const Offset: uint64; const DataType: TArchetypeMemberType; const DisplayName: string ); reintroduce;
  end;

{$endregion}

implementation
uses
  sysutils
, utlStatus
, utlTypes
, utlCompile.ModelStorage
, utlCompile.Representation
;

procedure TArchetypeMember.AddToReferenceList( const ModelInstance: IModelInstance; const Representation: IInterface; const Item: IInterface );
var
  PtrData: pointer;
  Ref: IInterface;
  L: IList< IInterface >;
begin
  if not IsReferenceList( ModelInstance, Representation ) then exit;
  if not assigned( Representation ) then exit;
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Ref := IInterface( ptrData^ );
  if not assigned( Ref ) then exit;
  L := IList< IInterface >( ptrData^ );
  if not assigned( L ) then exit;
  L.Add( Item );
end;

function TArchetypeMember.AsBoolean( const ModelInstance: IModelInstance; const Representation: IInterface ): boolean;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := boolean( PtrData^ );
end;

function TArchetypeMember.AsCursor( const ModelInstance: IModelInstance; const Representation: IInterface ): ICursor;
var
  PtrData: pointer;
  Ref: IInterface;
begin
  Result := nil;
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Ref := IInterface( ptrData^ );
  if not assigned( Ref ) then exit;
  Result := Ref as ICursor;
end;

function TArchetypeMember.AsDouble( const ModelInstance: IModelInstance; const Representation: IInterface ): double;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := double( PtrData^ );
end;

function TArchetypeMember.AsGUID( const ModelInstance: IModelInstance; const Representation: IInterface ): TGUID;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := TGUID( PtrData^ );
end;

function TArchetypeMember.AsInt16( const ModelInstance: IModelInstance; const Representation: IInterface ): int16;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := int16( PtrData^ );
end;

function TArchetypeMember.AsInt32( const ModelInstance: IModelInstance; const Representation: IInterface ): int32;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := int32( PtrData^ );
end;

function TArchetypeMember.AsInt64( const ModelInstance: IModelInstance; const Representation: IInterface ): int64;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := int64( PtrData^ );
end;

function TArchetypeMember.AsInt8( const ModelInstance: IModelInstance; const Representation: IInterface ): int8;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := int8( PtrData^ );
end;

function TArchetypeMember.AsReferenceList( const ModelInstance: IModelInstance; const Representation: IInterface ): IReadOnlyList< IInterface >;
var
  PtrData: pointer;
  Ref: IInterface;
  L: IList< IInterface >;
  List: IList< IInterface >;
  I: IInterface;
  FoundIdx: uint64;
begin
  List := TList< IInterface >.Create;
  Result := List.getAsReadOnly;
  if not IsReferenceList( ModelInstance, Representation ) then exit( nil );
  if not assigned( Representation ) then exit;
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Ref := IInterface( ptrData^ );
  if not assigned( Ref ) then exit;
  L := IList< IInterface >( ptrData^ );
  if not assigned( L ) then exit;
  for I in L do begin
    if not ( ( ModelInstance as IReflection ).FindRepresentationByObjectReference( I, FoundIdx ) ) then continue;
    List.Add( ( ModelInstance as IReflection ).RepresentationInstances[ FoundIdx ] );
  end;
end;

function TArchetypeMember.AsSingle( const ModelInstance: IModelInstance; const Representation: IInterface ): single;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := single( PtrData^ );
end;

function TArchetypeMember.AsSingleReference( const ModelInstance: IModelInstance; const Representation: IInterface ): IInterface;
var
  PtrData: pointer;
begin
  if not IsSingleReference( ModelInstance, Representation ) then exit( nil );
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := IInterface( ptrData^ );
end;

function TArchetypeMember.AsString( const ModelInstance: IModelInstance; const Representation: IInterface ): string;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := string( PtrData^ );
end;

function TArchetypeMember.AsStringList( const ModelInstance: IModelInstance; const Representation: IInterface ): IReadOnlyList< string >;
var
  PtrData: pointer;
  Ref: IInterface;
  SL: IList< string >;
  List: IList< string >;
  S: string;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Ref := IInterface( ptrData^ );
  List := TList< string >.Create;
  Result := List.getAsReadOnly;
  SL := IList< string >( ptrData^ );
  for S in SL do List.Add( S );
end;

function TArchetypeMember.AsUInt16( const ModelInstance: IModelInstance; const Representation: IInterface ): uint16;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := uint16( PtrData^ );
end;

function TArchetypeMember.AsUInt32( const ModelInstance: IModelInstance; const Representation: IInterface ): uint32;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := uint32( PtrData^ );
end;

function TArchetypeMember.AsUInt64( const ModelInstance: IModelInstance; const Representation: IInterface ): uint64;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := uint64( PtrData^ );
end;

function TArchetypeMember.AsUInt8( const ModelInstance: IModelInstance; const Representation: IInterface ): uint8;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := uint8( PtrData^ );
end;

function TArchetypeMember.AsUnicodeStream( const ModelInstance: IModelInstance; const Representation: IInterface ): IUnicodeStream;
var
  PtrData: pointer;
begin
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Result := IUnicodeStream( ptrData^ );
end;

constructor TArchetypeMember.Create( const Offset: uint64; const DataType: TArchetypeMemberType; const DisplayName: string );
begin
  inherited Create;
  fOffset := Offset;
  fDataType := DataType;
  fDisplayName := DisplayName;
end;

function TArchetypeMember.DisplayName: string;
begin
  Result := fDisplayName;
end;

function TArchetypeMember.getBaseAddress( const ModelInstance: IModelInstance; const Representation: IInterface ): nativeuint;
var
  Reflection: IReflection;
  Storage: IStorage;
begin
  Reflection := ModelInstance as IReflection;
  Storage := Reflection.GetStorage( Representation );
  Result := ( Storage as IInternalStorage ).getBase;
end;

function TArchetypeMember.IsReferenceList( const ModelInstance: IModelInstance; const Representation: IInterface ): boolean;
var
  Ref: IInterface;
  PtrData: pointer;
begin
  Result := False;
  if not assigned( Representation ) then exit;
  if not assigned( ( ModelInstance as IReflection ).GetStorage( Representation ) ) then exit;
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Ref := IInterface( ptrData^ );
  if not assigned( Ref ) then exit;
  Result := Supports( Ref, IList< IInterface > );
end;

function TArchetypeMember.IsSingleReference( const ModelInstance: IModelInstance; const Representation: IInterface ): boolean;
var
  Ref: IInterface;
  PtrData: pointer;
begin
  Result := False;
  if not assigned( Representation ) then exit( false );
  if not assigned( ( ModelInstance as IReflection ).GetStorage( Representation ) ) then exit;
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  Ref := IInterface( ptrData^ );
  if not assigned( Ref ) then exit;
  Result := ( fDataType = mtReference ) and ( not Supports( Ref, IList< IInterface > ) );
end;

function TArchetypeMember.DataType: TArchetypeMemberType;
begin
  Result := fDataType;
end;

function TArchetypeMember.Offset: uint64;
begin
  Result := fOffset;
end;

procedure TArchetypeMember.setOffset( const value: uint64 );
begin
  fOffset := Value;
end;

procedure TArchetypeMember.SetSingleReference( const ModelInstance: IModelInstance; const Representation: IInterface; const Value: IInterface );
var
  PtrData: pointer;
begin
  if not IsSingleReference( ModelInstance, Representation ) then exit;
  PtrData := nativeuint( getBaseAddress( ModelInstance, Representation ) - fOffset ).AsPointer;
  IInterface( ptrData^ ) := Value;
end;


end.

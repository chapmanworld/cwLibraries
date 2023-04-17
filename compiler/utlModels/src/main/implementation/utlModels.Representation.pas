(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlModels.Representation;

interface
uses
  utlModels
;

{$region ' IRepresentation '}

type
  IRepresentation = interface
  ['{0119EFCF-C442-4AFD-AC95-2FFA555E301C}']

    // Returns the archetypeID guid.
    function getArchetypeID: TGUID;

    // Returns the base address of the instance object (IInterface)
    function getIdentAddress: nativeuint;

    // Gets the stored reference to the representation instance.
    function getRepresentationInstance: IInterface;

    // Gets the reference to IStorage
    function getStorage: IStorage;
  end;

{$endregion}

{$region ' TRepresentation '}

type
  TRepresentation = class( TInterfacedObject, IRepresentation )
  private
    fIdentAddress: nativeuint;
    fArchetypeID: TGUID;
    fRepresentationInstance: IInterface;
    fStorage: IStorage;
  strict private //- IRepresentation -//
    function getArchetypeID: TGUID;
    function getRepresentationInstance: IInterface;
    function getStorage: IStorage;
    function getIdentAddress: nativeuint;
  public
    constructor Create( const ArchetypeID: TGUID; const RepresentationInstance: IInterface; const IdentAddress: nativeuint; const Storage: IStorage ); reintroduce;
    destructor Destroy; override;
  end;

{$endregion}

implementation

constructor TRepresentation.Create( const ArchetypeID: TGUID; const RepresentationInstance: IInterface; const IdentAddress: nativeuint; const Storage: IStorage );
begin
  inherited Create;
  fIdentAddress := IdentAddress;
  fArchetypeID := ArchetypeID;
  fRepresentationInstance := RepresentationInstance;
  fStorage := Storage;
end;

destructor TRepresentation.Destroy;
begin
  fRepresentationInstance := nil;
  fStorage := nil;
  inherited Destroy;
end;

function TRepresentation.getArchetypeID: TGUID;
begin
  Result := fArchetypeID;
end;

function TRepresentation.getIdentAddress: nativeuint;
begin
  Result := fIdentAddress;
end;

function TRepresentation.getRepresentationInstance: IInterface;
begin
  Result := fRepresentationInstance;
end;

function TRepresentation.getStorage: IStorage;
begin
  Result := fStorage;
end;

end.

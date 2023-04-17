(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlModels.Model;

interface
uses
  utlModels
, utlCollections
, utlModels.Instance
, utlModels.Archetype
, utlModels.Reflection
;

type
  TModel = class( TInterfacedObject, IModel )
  private
    fModelName: string;
    fArchetypes: IGuidDictionary< IArchetype >;
  strict private //- IModel -//
    procedure RegisterArchetype( const ArchetypeID: TGUID; const Factory: TRepresentationFactory; const DisplayName: string );
    function CreateInstance: IModelInstance;
  public
    constructor Create( const ModelName: string ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  utlStatus
, utlTypes
;

constructor TModel.Create( const ModelName: string );
begin
  inherited Create;
  fModelName := ModelName;
  fArchetypes := TGuidDictionary< IArchetype >.Create;
end;

function TModel.CreateInstance: IModelInstance;
begin
  Result := TInstance.Create( fModelName, fArchetypes.getAsReadOnly );
end;

destructor TModel.Destroy;
begin
  fArchetypes := nil;
  inherited Destroy;
end;

procedure TModel.RegisterArchetype( const ArchetypeID: TGUID; const Factory: TRepresentationFactory; const DisplayName: string );
var
  Archetype: IArchetype;
begin
  if fArchetypes.KeyExists( ArchetypeID ) then begin
    raise TStatus.CreateException( stArchetypeAlreadyRegistered, [ DisplayName ] );
  end;
  Archetype := TArchetype.Create( ArchetypeID, Factory, DisplayName );
  fArchetypes[ ArchetypeID ]  := Archetype;
end;

end.

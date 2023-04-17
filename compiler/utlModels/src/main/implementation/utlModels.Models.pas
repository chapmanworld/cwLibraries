(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlModels.Models;

interface
uses
  utlModels
, utlModels.Model
, utlCollections
;

type
  TModels = class( TInterfacedObject, IModels )
  private
    fModels: IStringDictionary< IModel >;
  strict private //- IModels -//
    function getModel( const Name: string ): IModel;
    function RegisterModel( const Name: string ): IModel;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  utlStatus
;

constructor TModels.Create;
begin
  inherited Create;
  fModels := TStringDictionary< IModel >.Create;
end;

destructor TModels.Destroy;
begin
  fModels := nil;
  inherited Destroy;
end;

function TModels.getModel( const Name: string ): IModel;
begin
  if not fModels.KeyExists( Name ) then exit( nil );
  Result := fModels[ Name ];
end;

function TModels.RegisterModel( const Name: string ): IModel;
begin
  if fModels.KeyExists( Name ) then begin
    Result := nil;
    raise TStatus.CreateException( stModelAlreadyRegistered, [ Name ] );
  end;
  Result := TModel.Create( Name );
  fModels[ Name ] := Result;
end;

end.

(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.BinaryImage.StringLists;

interface
uses
  utlLinker
, utlLinker.BinaryImage
, utlCollections
;

type
  TStringLists = class( TInterfacedObject, IStringLists )
  private
    fStringLists: IList< IStringList >;
  strict private //- IStringLists -//
    procedure Clear;
    function getStringListByIndex( const value: nativeuint ): IStringList;
    function getStringListByName( const value: string ): IStringList;
    function Count: nativeuint;
    function Add: IStringList;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  utlLinker.BinaryImage.StringList
;

function TStringLists.Add: IStringList;
begin
  Result := TStringList.Create;
  fStringLists.Add( Result );
end;

procedure TStringLists.Clear;
begin
  fStringLists.Clear;
end;

function TStringLists.Count: nativeuint;
begin
  Result := fStringLists.Count;
end;

constructor TStringLists.Create;
begin
  inherited Create;
  fStringLists := TList< IStringList >.Create;
end;

destructor TStringLists.Destroy;
begin
  fStringLists := nil;
  inherited Destroy;
end;

function TStringLists.getStringListByIndex( const value: nativeuint ): IStringList;
begin
  if value >= fStringLists.Count then exit( nil );
  Result := fStringLists[ value ];
end;

function TStringLists.getStringListByName( const value: string ): IStringList;
var
  StringList: IStringList;
begin
  Result := nil;
  for StringList in fStringLists do begin
    if StringList.Name = value then exit( StringList );
  end;
end;

end.

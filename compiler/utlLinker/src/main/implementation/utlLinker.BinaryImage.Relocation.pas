(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.BinaryImage.Relocation;

interface
uses
  utlLinker
, utlLinker.BinaryImage
;

type
  TRelocation = class( TInterfacedObject, IRelocation )
  private
    fOffset: TVirtualAddress;
    fSymbol: ISymbol;
    fSection: ISection;
    fAddend: int64;
    fType: uint32;
  strict private //- IRelocation -//
    function getOffset: TVirtualAddress;
    procedure setOffset( const value: TVirtualAddress );
    function getSymbol: ISymbol;
    procedure setSymbol( const value: ISymbol );
    function getSection: ISection;
    procedure setSection( const value: ISection );
    function getAddend: int64;
    procedure setAddend( const value: int64 );
    function getRelocationType: uint32;
    procedure setRelocationType( const Value: uint32 );
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TRelocation.Create;
begin
  inherited Create;
  fAddend := 0;
  fOffset := 0;
  fType   := 0;
  fSymbol := nil;
  fSection := nil;
end;

destructor TRelocation.Destroy;
begin
  fSymbol := nil;
  fSection := nil;
  inherited Destroy;
end;

function TRelocation.getAddend: int64;
begin
  Result := fAddend;
end;

function TRelocation.getOffset: TVirtualAddress;
begin
  Result := fOffset;
end;

function TRelocation.getRelocationType: uint32;
begin
  Result := fType;
end;

function TRelocation.getSection: ISection;
begin
  Result := fSection;
end;

function TRelocation.getSymbol: ISymbol;
begin
  Result := fSymbol;
end;

procedure TRelocation.setAddend( const value: int64 );
begin
  fAddend := value;
end;

procedure TRelocation.setOffset( const value: TVirtualAddress );
begin
  fOffset := Value;
end;

procedure TRelocation.setRelocationType( const Value: uint32 );
begin
  fType := Value;
end;

procedure TRelocation.setSection( const value: ISection );
begin
  fSection := value;
end;

procedure TRelocation.setSymbol( const value: ISymbol );
begin
  fSymbol := Value;
end;

end.

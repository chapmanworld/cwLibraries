(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.BinaryImage.Symbol;

interface
uses
  utlLinker
, utlLinker.BinaryImage
;

type
  TSymbol = class( TInterfacedObject, ISymbol )
  private
    fName: string;
    fAttributes: TSectionAttributes;
    fTime: TSymbolTime;
    fBindAttributes: TSymbolBindAttributes;
    fVisibility: TSymbolVisibility;
    fSection: ISection;
    fValue: TVirtualAddress;
  strict private //- ISymbol -//
    function getName: string;
    procedure setName( const value: string );
    function getTime: TSymbolTime;
    procedure setTime( const value: TSymbolTime );
    function getBindAttributes: TSymbolBindAttributes;
    procedure setBindAttributes( const value: TSymbolBindAttributes );
    function getVisibility: TSymbolVisibility;
    procedure setVisibility( const value: TSymbolVisibility );
    function getSection: ISection;
    procedure setSection( const value: ISection );
    function getValue: TVirtualAddress;
    procedure setValue( const value: TVirtualAddress );
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

constructor TSymbol.Create;
begin
  inherited Create;
  fName           := '';
  fAttributes     := [];
  fTime           := stStatic;
  fBindAttributes := [];
  fVisibility     := svDefault;
  fSection        := nil;
  fValue          := 0;
end;

destructor TSymbol.Destroy;
begin
  fSection := nil;
  inherited Destroy;
end;

function TSymbol.getBindAttributes: TSymbolBindAttributes;
begin
  Result := fBindAttributes;
end;

function TSymbol.getName: string;
begin
  Result := fName;
end;

function TSymbol.getSection: ISection;
begin
  Result := fSection;
end;

function TSymbol.getTime: TSymbolTime;
begin
  Result := fTime;
end;

function TSymbol.getValue: TVirtualAddress;
begin
  Result := fValue;
end;

function TSymbol.getVisibility: TSymbolVisibility;
begin
  Result := fVisibility;
end;

procedure TSymbol.setBindAttributes( const value: TSymbolBindAttributes );
begin
  fBindAttributes := value;
end;

procedure TSymbol.setName( const value: string );
begin
  fName := Value;
end;

procedure TSymbol.setSection( const value: ISection );
begin
  fSection := Value;
end;

procedure TSymbol.setTime( const value: TSymbolTime );
begin
  fTime := Value;
end;

procedure TSymbol.setValue( const value: TVirtualAddress );
begin
  fValue := Value;
end;

procedure TSymbol.setVisibility( const value: TSymbolVisibility );
begin
  fVisibility := Value;
end;

end.

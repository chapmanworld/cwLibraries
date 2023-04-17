(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC. <br/>
  PROPERTY OF: ChapmanWorld LLC. <br/>
  ALL RIGHTS RESERVED. <br/>
*)
unit utlCompile.Symbols;

interface
uses
  utlCompile
, utlCollections
;


{$region ' ISymbolRecord '}

type
  (* Used internally to track identifiers and their symbols *)
  ISymbolRecord = interface
    ['{2E08752F-A790-46B2-92C5-2135195AFBCA}']
    function Identifier: string;
    function Symbol: IScopedSymbol;
  end;

{$endregion}

type
  TScopedSymbols = class( TInterfacedObject, IScopedSymbols )
  private
    fSymbolCounter: uint64;
    fSymbols: IList< ISymbolRecord >;
    fScope: IStack< nativeuint >;
  private
    function GenerateNewPostfix: string;
  strict private //- ISymbols -//
    function SymbolLookup( const Identifier: string ): IScopedSymbol;
    procedure IncrementScope;
    procedure DecrementScope;
    function AddLabelSymbol( const Identifier: string ): IScopedSymbol;
    function AddNumericSymbol( const Identifier: string; const Value: uint64 ): IScopedSymbol;
  public
    constructor Create;
    destructor Destroy; override;

  end;

implementation
uses
  utlTypes
;

{$region ' TSymbolRecord '}

type
  TSymbolRecord = class( TInterfacedObject, ISymbolRecord )
  private
    fIdentifier: string;
    fSymbol: IScopedSymbol;
  strict private
    function Identifier: string;
    function Symbol: IScopedSymbol;
  public
    constructor Create( const Identifier: string; const Symbol: IScopedSymbol ); reintroduce;
  end;

constructor TSymbolRecord.Create( const Identifier: string; const Symbol: IScopedSymbol );
begin
  inherited Create;
  fIdentifier := Identifier;
  fSymbol := Symbol;
end;

function TSymbolRecord.Identifier: string;
begin
  Result := fIdentifier;
end;

function TSymbolRecord.Symbol: IScopedSymbol;
begin
  Result := fSymbol;
end;

{$endregion}

{$region ' TLabelSymbol '}

type
  TLabelSymbol = class( TInterfacedObject, IScopedSymbol, ILabelSymbol )
  private
    fLabel: string;
  strict private //- ILabelSymbol -//
    function SourceLabel: string;
  public
    constructor Create( const SourceLabel: string );
  end;

constructor TLabelSymbol.Create( const SourceLabel: string );
begin
  inherited Create;
  fLabel := SourceLabel;
end;

function TLabelSymbol.SourceLabel: string;
begin
  Result := fLabel;
end;

{$endregion}

{$region ' TNumericSymbol '}

type
  TNumericSymbol = class( TInterfacedObject, IScopedSymbol, INumericSymbol )
  private
    fValue: uint64;
  strict private //- INumericSymbol -//
    function Value: uint64;
  public
    constructor Create( const Value: uint64 );
  end;

constructor TNumericSymbol.Create( const Value: uint64 );
begin
  inherited Create;
  fValue := Value;
end;

function TNumericSymbol.Value: uint64;
begin
  Result := fValue;
end;

{$endregion}

function TScopedSymbols.GenerateNewPostfix: string;
begin
  Result := '_' + fSymbolCounter.AsString;
  inc( fSymbolCounter );
end;

function TScopedSymbols.AddLabelSymbol( const Identifier: string ): IScopedSymbol;
begin
  Result := TLabelSymbol.Create( Identifier + GenerateNewPostfix );
  fSymbols.Add( TSymbolRecord.Create( Identifier, Result ) );
end;

function TScopedSymbols.AddNumericSymbol( const Identifier: string; const Value: uint64 ): IScopedSymbol;
begin
  Result := TNumericSymbol.Create( Value );
  fSymbols.Add( TSymbolRecord.Create( Identifier, Result ) );
end;

constructor TScopedSymbols.Create;
begin
  inherited Create;
  fSymbolCounter := 1;
  fSymbols := TList< ISymbolRecord >.Create;
  fScope := TStack< nativeuint >.Create;
end;

procedure TScopedSymbols.DecrementScope;
var
  ListSize: nativeuint;
begin
  if fScope.Count = 0 then exit;
  ListSize := fScope.Pull;
  while fSymbols.Count > ListSize do fSymbols.RemoveItem( pred( fSymbols.Count ) );
end;

destructor TScopedSymbols.Destroy;
begin
  fScope := nil;
  fSymbols := nil;
  inherited Destroy;
end;

function TScopedSymbols.SymbolLookup( const Identifier: string ): IScopedSymbol;
var
  idx: nativeuint;
begin
  // Search backwards to account for vanishing scopes.
  if fSymbols.Count = 0 then exit;
  for idx := pred( fSymbols.Count ) downto 0 do begin
    if fSymbols[ idx ].Identifier = Identifier then begin
      Result := fSymbols[ idx ].Symbol;
      exit;
    end;
  end;
end;

procedure TScopedSymbols.IncrementScope;
begin
  fScope.Push( fSymbols.Count );
end;


end.

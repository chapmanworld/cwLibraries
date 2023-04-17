(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.BinaryImage.StringList;

interface
uses
  utlLinker
, utlLinker.BinaryImage
, utlCollections
;

type
  TStringList = class( TInterfacedObject, IStringList )
  private
    fName: string;
    fStrings: IList< string >;
    fHasOffsets: IList< boolean >;
    fLowerOffsets: IList< nativeuint >;
    fUpperOffsets: IList< nativeuint >;
  strict private //- IStringList -//
    function getItemByIndex( const Idx: nativeuint ): string;
    function getName: string;
    procedure setName( const value: string );
    procedure Clear;
    function Count: nativeuint;
    function Add( const value: string ): nativeuint; overload;
    function Add( const value: string; const LowerOffset: nativeuint; const UpperOffset: nativeuint ): nativeuint; overload;
    function StringByOffset( const Offset: nativeuint; out S: string ): boolean;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  utlTypes
;

function TStringList.Add( const value: string ): nativeuint;
begin
  Result := fStrings.Add( value );
  fLowerOffsets.Add( 0 );
  fUpperOffsets.Add( 0 );
  fHasOffsets.Add( False );
end;

function TStringList.Add( const value: string; const LowerOffset, UpperOffset: nativeuint ): nativeuint;
begin
  Result := fStrings.Add( value );
  fLowerOffsets.Add( LowerOffset );
  fUpperOffsets.Add( UpperOffset );
  fHasOffsets.Add( True );
end;

procedure TStringList.Clear;
begin
  fStrings.Clear;
  fHasOffsets.Clear;
  fLowerOffsets.Clear;
  fUpperOffsets.Clear;
end;

function TStringList.Count: nativeuint;
begin
  Result := fStrings.Count;
end;

constructor TStringList.Create;
begin
  inherited Create;
  fName := '';
  fStrings := TList< string >.Create;
  fHasOffsets := TList< boolean >.Create;
  fLowerOffsets := TList< nativeuint >.Create;
  fUpperOffsets := TList< nativeuint >.Create;
end;

destructor TStringList.Destroy;
begin
  fStrings := nil;
  fHasOffsets := nil;
  fLowerOffsets := nil;
  fUpperOffsets := nil;
  inherited Destroy;
end;

function TStringList.getItemByIndex( const Idx: nativeuint ): string;
begin
  if Idx >= fStrings.Count then exit( '' );
  Result := fStrings[ idx ];
end;

function TStringList.getName: string;
begin
  Result := fName;
end;

//function TStringList.IndexByOffset( const Offset: nativeuint; out FoundIdx: nativeuint ): boolean;
//var
//  idx: nativeuint;
//begin
//  Result := False;
//  if fStrings.Count = 0 then exit;
//  for idx := 0 to pred( fStrings.Count ) do begin
//    if not fHasOffsets[ idx ] then continue;
//    if ( Offset >= fLowerOffsets[ idx ] ) and ( Offset < fUpperOffsets[ idx ] ) then begin
//      FoundIdx := idx;
//      exit( true );
//    end;
//  end;
//end;

procedure TStringList.setName( const value: string );
begin
  fName := Value;
end;

function TStringList.StringByOffset( const Offset: nativeuint; out S: string ): boolean;
var
  idx: nativeuint;
  aStr: string;
begin
  Result := False;
  if fStrings.Count = 0 then exit;
  for idx := 0 to pred( fStrings.Count ) do begin
    if not fHasOffsets[ idx ] then continue;
    if ( Offset >= fLowerOffsets[ idx ] ) and ( Offset < fUpperOffsets[ idx ] ) then begin
      aStr := getItemByIndex( idx );
      if Offset = fLowerOffsets[ idx ] then begin
        S := aStr;
        exit( true );
      end;
      if Offset = fUpperOffsets[ idx ] then begin
        S := '';
        exit( true );
      end;
      S := aStr.Right( pred( fUpperOffsets[ idx ] - Offset ) );
      exit( true );
    end;
  end;
end;


end.


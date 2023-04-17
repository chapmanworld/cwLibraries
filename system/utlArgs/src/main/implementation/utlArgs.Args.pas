(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC. <br/>
  PROPERTY OF: ChapmanWorld LLC. <br/>
  ALL RIGHTS RESERVED. <br/>
*)
unit utlArgs.Args;

interface
uses
  utlArgs
, utlCollections
;

type
  TCommandLineComponent = record
    IsValue: boolean;
    SwitchChars: string;
    ValueChars: string;
  end;

type
  TArguments = class( TInterfacedObject, IArguments )
  private
    fParameters: IList< string >;
    fComponents: IList< TCommandLineComponent >;
    fFoundSwitches: IList< string >;
    fFoundValues: IStringDictionary< string >;
  strict private  //- IArgs -//
    procedure AddString( const S: string );
    function Switch( const SwitchName: string ): boolean;
    function Value( const Key: string; out Value: string ): boolean;
    function Parameters: IReadOnlyList< string >;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation
uses
  SysUtils
,  utlTypes
;

const
  cSwitchChar = '-';

procedure TArguments.AddString( const S: string );
const
  cWhitespace = [ ' ', TAB, CR, LF ];
var
  idx: nativeuint;
  WithinSwitch: boolean;
  WithinValue: boolean;
  WithinQuote: boolean;
  Escape: boolean;
  QuoteChar: char;
  CurrentComponent: TCommandLineComponent;
begin
  if S.Length = 0 then exit;
  QuoteChar := ' '; // prevent warning
  WithinSwitch := False;
  WithinValue := False;
  WithinQuote := False;
  Escape := False;
  CurrentComponent.SwitchChars := '';
  CurrentComponent.ValueChars := '';
  CurrentComponent.IsValue := False;
  for idx := 1 to S.Length do begin

    // Detect start of quoted string.
    if ( not WithinQuote ) and ( WithinValue ) and ( ( S[ idx ] = '"'  ) or ( S[ idx ] = '''' ) ) then begin
      WithinQuote := True;
      QuoteChar := S[ idx ];
      continue;
    end;

    // If we're within a quoted string...
    if ( WithinQuote ) then begin
      if ( ( not Escape ) and ( S[ idx ] = '\' ) ) then begin
        Escape := True;
        continue;
      end;
      if Escape then begin
        CurrentComponent.ValueChars := CurrentComponent.ValueChars + S[ idx ];
        Escape := False;
        continue;
      end;
      if S[ idx ] = QuoteChar then begin
        WithinQuote := False;
        continue;
      end;
      CurrentComponent.ValueChars := CurrentComponent.ValueChars + S[ idx ];
      continue;
    end;

    // Skip whitespace
    if CharInSet( S[ idx ], cWhitespace ) then continue;

    // Detect start of a switch.
    if ( S[ idx ] = cSwitchChar ) then begin
      if WithinSwitch then begin
        fComponents.Add( CurrentComponent );
        WithinValue := False;
        CurrentComponent.SwitchChars := '';
        CurrentComponent.ValueChars := '';
        CurrentComponent.IsValue := False;
      end else begin
        WithinSwitch := True;
      end;
      continue;
    end;

    // Detect start of a value
    if ( not WithinValue ) and ( WithinSwitch ) and ( S[ idx ] = '=' ) then begin
      CurrentComponent.IsValue := True;
      WithinValue := True;
      continue;
    end;

    // Collect switch chars
    if ( WithinSwitch ) and ( not WithinValue ) then begin
      CurrentComponent.SwitchChars := CurrentComponent.SwitchChars + S[ idx ];
      continue;
    end;

    // Collect value chars
    if ( WithinValue ) then begin
      CurrentComponent.ValueChars := CurrentComponent.ValueChars + S[ idx ];
      continue;
    end;

  end;
  if CurrentComponent.SwitchChars <> '' then begin
    fComponents.Add( CurrentComponent );
  end;
end;

constructor TArguments.Create;
var
  idx: uint32;
  P: string;
begin
  inherited Create;
  fParameters := TList< string >.Create;
  fComponents := TList< TCommandLineComponent >.Create;
  fFoundSwitches := TList< string >.Create;
  fFoundValues := TStringDictionary< string >.Create;
  if ParamCount > 0 then begin
    for idx := 1 to ParamCount do begin
      P := string( ParamStr( idx ) ).TrimLeft;
      if ( P.Length > 0 ) and ( P[ 1 ] = '-' ) then AddString( ParamStr( idx ) ) else if ( P.Length > 0 ) then fParameters.Add( P );
    end;
  end;
end;

destructor TArguments.Destroy;
begin
  fParameters := nil;
  fComponents := nil;
  fFoundSwitches := nil;
  fFoundValues := nil;
  inherited Destroy;
end;

function TArguments.Parameters: IReadOnlyList<string>;
begin
  Result := fParameters;
end;

function TArguments.Switch( const SwitchName: string ): boolean;
var
  S: string;
  idx: nativeuint;
  NewComponent: TCommandLineComponent;
begin
  Result := False;
  //- Check for it in fFoundSwitches.
  for S in fFoundSwitches do if S = SwitchName then exit( true );
  //- Check for it in fComponents
  if fComponents.Count = 0 then exit;
  for idx := 0 to pred( fComponents.Count ) do begin
    if fComponents[ idx ].IsValue then continue;
    if Pos( SwitchName, fComponents[ idx ].SwitchChars ) > 0 then begin
      // It is found in components, move it to found switches.
      fFoundSwitches.Add( SwitchName );
      // Remove it from components.
      if fComponents[ idx ].SwitchChars = SwitchName then begin
        fComponents.RemoveItem( idx );
        exit( true );
      end else begin
        NewComponent.IsValue := False;
        NewComponent.SwitchChars := fComponents[ idx ].SwitchChars.Replace( SwitchName, '' );
        NewComponent.ValueChars := fComponents[ idx ].ValueChars;
        fComponents.RemoveItem( idx );
        fComponents.Add( NewComponent );
        exit( true );
      end;
    end;
  end;
end;

function TArguments.Value( const Key: string; out Value: string ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  //- Check for it in fFoundValues.
  if fFoundValues.KeyExists( Key ) then begin
    Value := fFoundValues[ Key ];
    exit( true );
  end;
  //- Check for it in fComponents
  if fComponents.Count = 0 then exit;
  for idx := 0 to pred( fComponents.Count ) do begin
    if not fComponents[ idx ].IsValue then continue;
    if Key = fComponents[ idx ].SwitchChars then begin
      // It is found in components, move it to found values.
      Value := fComponents[ idx ].ValueChars;
      fFoundValues[ Key ] := fComponents[ idx ].ValueChars;
      fComponents.RemoveItem( idx );
      exit( true );
    end;
  end;
end;

end.

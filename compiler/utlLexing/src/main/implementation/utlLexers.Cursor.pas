(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLexers.Cursor;

interface
uses
  utlStatus
, utlLexers
;

type
  TCursor = class( TInterfacedObject, ICursor, IAsString )
  private
    fFilename: string;
    fLineNumber: nativeuint;
    fLinePosition: nativeuint;
  strict private //- IAsString -//
    function AsString: string;
  strict private //- ICursor -//
    function Filename: string;
    function LineNumber: nativeuint;
    function LinePosition: nativeuint;
    procedure Assign( const SourceCursor: ICursor );
  public
    constructor Create( const Filename: string; const LineNumber: nativeuint; const LinePosition: nativeuint );
  end;

implementation
uses
  utlTypes
;

function TCursor.AsString: string;
begin
  Result := fFilename + ' at ' + fLineNumber.AsString + 'x' + fLinePosition.AsString;
end;

function TCursor.Filename: string;
begin
  Result := fFilename;
end;

function TCursor.LineNumber: nativeuint;
begin
  Result := fLineNumber;
end;

function TCursor.LinePosition: nativeuint;
begin
  Result := fLinePosition;
end;

procedure TCursor.Assign( const SourceCursor: ICursor );
begin
  fFilename     := SourceCursor.Filename;
  fLineNumber   := SourceCursor.LineNumber;
  fLinePosition := SourceCursor.LinePosition;
end;

constructor TCursor.Create( const Filename: string; const LineNumber: nativeuint; const LinePosition: nativeuint );
begin
  inherited Create;
  fFilename     := Filename;
  fLineNumber   := LineNumber;
  fLinePosition := LinePosition;
end;

end.






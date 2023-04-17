(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLexers.Common;

interface

(*
   This unit contains internally used types and functions to provide
   the lexers singleton ( because Delphi's generics implementation is so
   borked that it can be done here, but not in utlLexers. )
*)

type
  TLexerRecord = record
    Name: string;
    Factory: pointer;
    Equality: pointer;
  end;

function FindLexerRecord( const Name: string; out FoundIdx: nativeuint ): boolean;
function LexerRecordByIndex( const Index: nativeuint ): TLexerRecord;
procedure AddLexerRecord( const LexerRecord: TLexerRecord );

implementation
uses
  utlCollections
;

var
  SingletonLexers: IList< TLexerRecord > = nil;

procedure EnsureLexers;
begin
  if assigned( SingletonLexers ) then exit;
  SingletonLexers := TList< TLexerRecord >.Create;
end;

function FindLexerRecord( const Name: string; out FoundIdx: nativeuint ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  EnsureLexers;
  if SingletonLexers.Count = 0 then exit;
  for idx := 0 to pred( SingletonLexers.Count ) do begin
    if SingletonLexers[ idx ].Name = Name then begin
      FoundIdx := idx;
      exit( true );
    end;
  end;
end;

function LexerRecordByIndex( const Index: nativeuint ): TLexerRecord;
begin
  EnsureLexers;
  Result := SingletonLexers[ Index ];
end;

procedure AddLexerRecord( const LexerRecord: TLexerRecord );
begin
  EnsureLexers;
  SingletonLexers.Add( LexerRecord );
end;

initialization
  SingletonLexers := nil;

finalization
  SingletonLexers := nil;

end.

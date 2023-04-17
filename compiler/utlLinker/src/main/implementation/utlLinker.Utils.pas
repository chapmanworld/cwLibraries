(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.Utils;

interface
uses
  utlLinker
, utlLinker.BinaryImage
;

type
  TLinkerUtils = record
    class function Align( const Address: TVirtualAddress; const Alignment: TVirtualAddress ): uint64; static;
    class function IsCodeSection( const Section: ISection ): boolean; static;
    class function IsDataSection( const Section: ISection ): boolean; static;
    class function IsBBSSection( const Section: ISection ): boolean; static;
    class function IsIDataSection( const Section: ISection ): boolean; static;
  end;

implementation
uses
  SysUtils
;

class function TLinkerUtils.Align( const Address: TVirtualAddress; const Alignment: TVirtualAddress ): uint64;
var
  Count: nativeuint;
begin
  if Address = 0 then exit( Alignment );
  Count := Address div Alignment;
  Result := Count * Alignment;
  if Result < Address then Result := Result + Alignment;
end;

class function TLinkerUtils.IsBBSSection( const Section: ISection ): boolean;
begin
  Result := Supports( Section, IVirtualSection );
end;

class function TLinkerUtils.IsCodeSection( const Section: ISection ): boolean;
begin
  Result := ( saExecutable in Section.Attributes ) and
            ( Supports( Section, IContentSection ) );
end;

class function TLinkerUtils.IsDataSection( const Section: ISection ): boolean;
begin
  Result := ( Section.Name = '.idata' ) and
            ( Supports( Section, IContentSection ) ) and
            ( not ( saExecutable in Section.Attributes ) );
end;

class function TLinkerUtils.IsIDataSection( const Section: ISection ): boolean;
begin
  Result := Supports( Section, IContentSection ) and
            ( not ( saExecutable in Section.Attributes ) ) and
            ( Section.Name <> '.idata' );
end;

end.

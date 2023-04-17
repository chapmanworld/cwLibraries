(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.BinaryImage.VirtualSection;

interface
uses
  utlLinker
, utlLinker.BinaryImage
;

type
  TVirtualSection = class( TInterfacedObject, ISection, IVirtualSection )
  private
    fName: string;
    fSize: TVirtualSize;
    fRVA: TVirtualAddress;
    fAttributes: TSectionAttributes;
  strict private //- ISection -//
    function getName: string;
    procedure setName( const Value: string );
    function getRVA: TVirtualAddress;
    procedure setRVA( const Value: TVirtualAddress );
    function getAttributes: TSectionAttributes;
    procedure setAttributes( const value: TSectionAttributes );
  strict private //- IVirtualSection -//
    function getSize: TVirtualSize;
    procedure setSize( const Value: TVirtualSize );
  public
    constructor Create; reintroduce;
  end;


implementation

constructor TVirtualSection.Create;
begin
  inherited Create;
  fAttributes := [];
  fSize := 0;
  fRVA := 0;
end;

function TVirtualSection.getAttributes: TSectionAttributes;
begin
  Result := fAttributes;
end;

function TVirtualSection.getName: string;
begin
  Result := fName;
end;

function TVirtualSection.getSize: TVirtualSize;
begin
  Result := fSize;
end;

function TVirtualSection.getRVA: TVirtualAddress;
begin
  Result := fRVA;
end;

procedure TVirtualSection.setAttributes( const value: TSectionAttributes );
begin
  fAttributes := value;
end;

procedure TVirtualSection.setName( const Value: string );
begin
  fName := Value;
end;

procedure TVirtualSection.setSize( const Value: TVirtualSize );
begin
  fSize := Value;
end;

procedure TVirtualSection.setRVA( const Value: TVirtualAddress );
begin
  fRVA := Value;
end;

end.

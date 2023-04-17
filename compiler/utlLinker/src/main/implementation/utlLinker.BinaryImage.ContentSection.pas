(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.BinaryImage.ContentSection;

interface
uses
  utlIO
, utlLinker
, utlLinker.BinaryImage
;

type
  TContentSection = class( TInterfacedObject, ISection, IContentSection )
  private
    fRVA: TVirtualAddress;
    fName: string;
    fContent: IReadOnlyUnicodeStream;
    fAttributes: TSectionAttributes;
  strict private //- ISection -//
    function getName: string;
    procedure setName( const Value: string );
    function getRVA: TVirtualAddress;
    procedure setRVA( const Value: TVirtualAddress );
    function getAttributes: TSectionAttributes;
    procedure setAttributes( const value: TSectionAttributes );
  strict private //- IContentSection -//
    function getContent: IReadOnlyUnicodeStream;
    procedure setContent( const Value: IReadOnlyUnicodeStream );
  public
    constructor Create( const SourceStream: IReadOnlyUnicodeStream = nil ); reintroduce;
  end;

implementation

constructor TContentSection.Create( const SourceStream: IReadOnlyUnicodeStream = nil );
begin
  inherited Create;
  fRVA := 0;
  fName := '';
  fContent := SourceStream;
  fAttributes := [];
end;

function TContentSection.getAttributes: TSectionAttributes;
begin
  Result := fAttributes;
end;

function TContentSection.getContent: IReadOnlyUnicodeStream;
begin
  Result := fContent;
end;

function TContentSection.getName: string;
begin
  Result := fName;
end;

function TContentSection.getRVA: TVirtualAddress;
begin
  Result := fRVA;
end;

procedure TContentSection.setAttributes( const value: TSectionAttributes );
begin
  fAttributes := value;
end;

procedure TContentSection.setContent( const Value: IReadOnlyUnicodeStream );
begin
  fContent := Value;
end;

procedure TContentSection.setName( const Value: string );
begin
  fName := Value;
end;

procedure TContentSection.setRVA( const Value: TVirtualAddress );
begin
  fRVA := Value;
end;

end.

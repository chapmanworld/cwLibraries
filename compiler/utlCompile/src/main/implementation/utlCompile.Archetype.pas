(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCompile.Archetype;

interface
uses
  utlCompile
, utlCompile.ArchetypeMember
, utlCompile.Reflection
, utlCollections
;

{$region ' TArchetype '}

type
  TArchetype = class( TInterfacedObject, IArchetype )
  private
    fArchetypeID: TGUID;
    fDisplayName: string;
    fFactory: TRepresentationFactory;
    fMembers: IList< IArchetypeMember >;
  strict private //- IArchetype -//
    function ArchetypeID: TGUID;
    function getFactory: TRepresentationFactory;
    function getDisplayName: string;
    function MemberExists( const ArchetypeMember: IArchetypeMember ): boolean;
    procedure AddMember( const ArchetypeMember: IArchetypeMember );
    function Members: IReadOnlyList< IArchetypeMember >;
  public
    constructor Create( const ArchetypeID: TGUID; const Factory: TRepresentationFactory; const DisplayName: string ); reintroduce;
    destructor Destroy; override;
  end;

{$endregion}

implementation
uses
  utlStatus
;

constructor TArchetype.Create( const ArchetypeID: TGUID; const Factory: TRepresentationFactory; const DisplayName: string );
begin
  inherited Create;
  fMembers := TList< IArchetypeMember >.Create;
  fArchetypeID := ArchetypeID;
  fDisplayName := DisplayName;
  fFactory := Factory;
end;

destructor TArchetype.Destroy;
begin
  fMembers := nil;
  inherited Destroy;
end;

procedure TArchetype.AddMember( const ArchetypeMember: IArchetypeMember );
begin
  if MemberExists( ArchetypeMember ) then begin
    raise TStatus.CreateException( stArchetypeMemberClash, [ ArchetypeMember.DisplayName, fDisplayName ] );
  end;
  fMembers.Add( ArchetypeMember );
end;

function TArchetype.ArchetypeID: TGUID;
begin
  Result := fArchetypeID;
end;

function TArchetype.getDisplayName: string;
begin
  Result := fDisplayName;
end;

function TArchetype.getFactory: TRepresentationFactory;
begin
  Result := fFactory;
end;

function TArchetype.MemberExists( const ArchetypeMember: IArchetypeMember ): boolean;
var
  ExistingMember: IArchetypeMember;
begin
  for ExistingMember in fMembers  do begin
    if ExistingMember.Offset = ArchetypeMember.Offset then exit( true );
  end;
  Result := False;
end;

function TArchetype.Members: IReadOnlyList< IArchetypeMember >;
begin
  Result := fMembers.getAsReadOnly;
end;

end.

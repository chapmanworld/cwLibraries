(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker;

interface
uses
  utlStatus
, utlLog
;

{$region ' Status messages '}

const
  stNothingToLink           : TGUID = '{761B33A0-35AB-48A1-802D-9C8E0EEC5ED5}';
  stInvalidElfFile          : TGUID = '{3BF9B741-C9F9-4FAE-987B-7AE103EE4855}';
  stElfParseError           : TGUID = '{AD1A7E94-823D-4516-B3E6-767A31AD66BA}';
  strSectionIsNotStrTab     : TGUID = '{4F56F8B9-C0FD-493F-B1BD-D150561CF200}';
  stUnknownInputFileType    : TGUID = '{B9DDEE7D-7928-4A21-B997-151798E79AC1}';
  stBitwidthMissmatchOnLink : TGUID = '{DE09A222-5935-4A30-956A-7EA0E7B0BEA2}';
  stEndianMissmatchOnLink   : TGUID = '{057372FA-B4C6-43DD-A2EC-E54514FDF37C}';
  stElfSectionNamesMissing  : TGUID = '{3206E7EB-1301-4120-867C-D1A6D423EBFB}';
  stCannotLocateEntryPoint  : TGUID = '{F62D5756-387C-441E-BE88-7C40F85FB2B5}';
  stCannotLocateILT         : TGUID = '{B71DAB28-45D0-40DD-A9BF-5D453E1A67F5}';
  stUnknownRelocationType   : TGUID = '{20D5DAD7-FD3E-4595-BBBA-5BCBCEB46CC5}';

{$endregion}

{$region ' Supporting Types '}

type
  TVirtualAddress = uint64;
  TVirtualSize = TVirtualAddress;
  TFileLocation = uint64;
  TFileSize = TFileLocation;


type
  ///  <summary>
  ///    Enumerates the known/supported object file formats.
  ///  </summary>
  TFileType = (
      ftUnspecified
    , ftElf
    , ftPE
  );

type
  ///  <summary>
  ///    Used to indicate the 'bit-width' of a pointer on the
  ///    target archetecture.
  ///  </summary>
  TBittedness = (
      bitsUnspecified
    , bits32
    , bits64
  );

type
  ///  <summary>
  ///    Used to determine if the target archetecture is big-endian or
  ///    little endian.
  ///  </summary>
  TEndianness = (
      enUnspecified
    , enLittle
    , enBig
  );

{$endregion}

{$region ' ILinker '}

type
  ///  <summary>
  ///    This is our linker.
  ///    Responsible for arranging sections in order of their type, and
  ///    for determining their target virtual addresses, for applying
  ///    relocations, and resolving symbols, and ultimately for writing
  ///    the output image file. <br/>
  ///    Actually, does not currently perform symbol resolution, instead
  ///    bawlks on unresolved symbols. This is because symbol resolution is
  ///    not required by the precedent compiler at this time.
  ///  </summary>
  ILinker = interface
  ['{FF701419-0626-487F-A5DA-E5055CECFF5D}']

    ///  <summary>
    ///    Opens an input file for linking and appends it to the internal
    ///    binary image representation. <br/>
    ///    Currently only supports ELF files (32/64-bit).
    ///  </summary>
    function LoadInputFile( const InputFilepath: string ): TStatus;

    ///  <summary>
    ///    Attempts to generate a PE/PE+32 format image file based on the
    ///    loaded input files.
    ///  </summary>
    function LinkPEFile( const TargetFilepath: string; const Bittedness: TBittedness; const Endianness: TEndianness; const PreferredAddress: TVirtualAddress = $400000 ): TStatus;

  end;

{$endregion}

{$region ' TLinker (factory) '}

type
  ///  <summary>
  ///    A factory record for instancing TLinker.
  ///  </summary>
  TLinker = record
    class function Create( const Log: ILog ): ILinker; static;
  end;

{$endregion}

implementation
uses
  utlLinker.Linker
;

class function TLinker.Create( const Log: ILog ): ILinker;
begin
  Result := utlLinker.Linker.TLinker.Create( Log );
end;

initialization
  TStatus.Register( stNothingToLink           , 'Internal Error: No input files provided for linker to link.' );
  TStatus.Register( stInvalidElfFile          , 'Internal Error: Invalid elf file: "(%%)" in "(%%)"' );
  TStatus.Register( stElfParseError           , 'Internal Error: Elf Parse Error: "(%%)"' );
  TStatus.Register( strSectionIsNotStrTab     , 'Internal Error: Section is not a string table "(%%)"' );
  TStatus.Register( stUnknownInputFileType    , 'Internal Error: Unknown file type "(%%)"' );
  TStatus.Register( stBitwidthMissmatchOnLink , 'Internal Error: Input file "(%%)" bit-width does not match desired output.' );
  TStatus.Register( stEndianMissmatchOnLink   , 'Internal Error: Input file "(%%)" has different endian property to desired output.' );
  TStatus.Register( stElfSectionNamesMissing  , 'Internal Error: Section names not found.' );
  TStatus.Register( stCannotLocateEntryPoint  , 'Internal Error: Unable to locate entry point. ' );
  TStatus.Register( stCannotLocateILT         , 'Internal Error: Portable-Executable ILT/IAT missing.' );
  TStatus.Register( stUnknownRelocationType   , 'Internal Error: Encountered unknown or unsupported relocation type.' );

end.

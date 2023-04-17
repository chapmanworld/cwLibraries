(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC. <br/>
  PROPERTY OF: ChapmanWorld LLC. <br/>
  ALL RIGHTS RESERVED. <br/>
*)
unit utlCompile;

interface
uses
  utlStatus
, utlLog
, utlCollections
, utlModels
;

{$region ' Usage information '}
(*

  A compiler consists of many different components which are called upon
  to process source code through to the final output. That output may be
  source code for some other compiler (transpiler), or may be a binary
  executable file (compiler), or may take another form.

  This usage information will describe the components of a compiler
  to take some higher level language as input, and generate a binary
  executable as output. This use case is best for describing the usage of
  the utlCompile library, because it involves all of the components that may
  be used as part of a compiler project. The "precedent" compiler will be
  the example.

  The precedent compiler supports multiple targets and multiple platforms,
  and thus, the route from source code to binary executable output will
  take different paths. For instance, the output of compilation for
  an Intel x86_64 target for the Windows Platform is a Portable Executable (PE)
  file, while the output for an Intel x86_64 target for the Linux platform is
  an Extensible Linkable Format (ELF) file. Clearly the compiler must take
  different paths to generate these two files.

  The chain of operations for this compiler is as follows.

    1) Parser - The parser instances a precedent language specific lexer,
                and converts the tokens generated by that lexer into a
                high-level model (AST).

    2) Transitions - At least one transition must be used to transition the
                     high-level model that was generated by the parser, to
                     a low-level model. Additional transitions may optionally
                     be used to valdidate and optimize either the high or
                     low level models, we'll not be discussing those any
                     further here.

    3) CodeGenerator - A code generator takes the low-level model that results
                       from calling the transition(s), and uses it to write an
                       assembler file.

    4) PostProcess - A post-process calls an external assembler and linker to
                     assemble and link the assembler file (generated by the
                     code generator) to create the final binary executable.

  In order to support multiple targets and platforms, a different code generator
  is required, because there will be slightly different assembler required
  to create windows executables than is required to create linux executables.

  -=[ As a matter of fact, the same code generator is used for both
     windows and linux, however, the generator class is instanced with
     a parameter to tell it which platform it is generating for. So while
     technically the same code generator class is used, we consider this to
     be two code generators based on the instances having different
     configurations. ]=-

  The post process will also differ between different targets and platforms.
  For example, when using the GNU binutils as the external assembler and
  linker, different executables from the package are used. There is an
  x86_64_Windows build of the assembler, and an x86_64_Linux build of the
  assembler. The same is true for the linker. For this reason, the post
  process of our compiler must also differ based on the target and platform.

  Differences in the compilation process are not limited to target or platform
  options, and are not limited to the code-generator or post-process either.
  There may well be different optimizations possible for a given target or
  platform, or a different parser may be selected in order to support a
  different input syntax.

  In order to account for all of this flexibility, utlCompile employs the
  concept of 'CompileChains'.  A compile chain is a record of which parser
  should be used, which transitions, which code generator, and which
  post-processes, in order to compile source code for a given input
  language, target and platform. Essentially, we have a dictionary which is
  keyed on the source language + target + platform, and which holds as its
  value, a record of factory methods that can be called upon to instance each
  of the required components for that key. A singleton instance of this
  dictionary can be obtained by calling the CompileChains() method.

  The compiler application is able to interrogate the CompileChains dictionary,
  to determine which source language, target, and platform combinations are
  available, and then based on user selection, call upon CompileChains() to
  create an instance of 'ICompileChain'. This isntance of ICompileChain may
  then be used to process the compilation of source code through to binary.

*)
{$endregion}

{$region ' Status messages '}

const
  ///  <summary>
  ///    stDone is returned by a compile chain as a success code which indicates
  ///    that the compilation process, as defined within the chain setup, is
  ///    complete.
  ///  </summary>
  stDone                   : TGUID = '{D334EEA9-6929-4FD0-9C2E-E475AC51CAD8}';
  stSourceNotParsed        : TGUID = '{BC331C3F-9A51-46BE-A059-9709D34AD257}';
  stModelNotTransitioned   : TGUID = '{9B6069CC-937D-464D-B296-3C450E8B06A6}';
  stNotGenerated           : TGUID = '{D3D84C48-22FF-4614-A485-F191F7728157}';
  stChainAlreadyRegistered : TGUID = '{AEBEBC3F-279C-479D-963A-A4343E0D2AC8}';


const // Some status messages that may be useful in transitions / generators.
  stVerbose                  : TGUID = '{BF97014F-169F-4685-A246-683A1A178787}';
  stSourceModelIsInvalid     : TGUID = '{C2E179A1-B0D6-4B21-88BC-54C8BD764FFE}';
  stSourceModelIsMissingRoot : TGUID = '{282E3CF1-6197-4BE2-9FCC-2F9BB428DA57}';
  stInvalidTarget            : TGUID = '{10E9A27F-859B-4633-AFFA-3957B93C6F2E}';
  stInvalidPlatform          : TGUID = '{633DB6B3-C965-4ADC-A8AC-A9B9C2572406}';

{$endregion}

{$region ' TTarget '}

type
  ///  <summary>
  ///    An enumeration of targets that may be
  ///    supported by a compiler based on utlCompile. <br/>
  ///    More may be added as needed. The registration of
  ///    compile chains will determine which are supported
  ///    by any given compiler.
  ///  </summary>
  {Z4}
  TTarget = (
      tgt_UnSet
    , tgt_x86
    , tgt_x86_64
    , tgt_arm
    , tgt_Aarch64
    , tgt_RISC_V
    , tgt_SPIRV
  );


{$endregion}

{$region ' TPlatform '}

type
  ///  <summary>
  ///    An enumeration of platforms that may be
  ///    supported by a compiler based on utlCompile. <br/>
  ///    More may be added as needed. The registration of
  ///    compile chains will determine which are supported
  ///    by any given compiler.
  ///  </summary>
  {Z4}
  TPlatform = (
      pl_Unset
    , pl_Windows
    , pl_Linux
    , pl_BSD
    , pl_Android
    , pl_IOS
  );

{$endregion}

{$region ' IParser '}

type
  ///  <summary>
  ///    Represents a user supplied parser.
  ///  </summary>
  IParser = interface
    ['{C841F2D9-CCCC-4E3D-BD66-D02A51962633}']

    ///  <sumamry>
    ///    Your parser should accept a source code file in its constructor,
    ///    (or via config model, see precedent parser for example). When the
    ///    Parse() method is called, the parser should read the source file
    ///    and generate the expected output model instance.
    ///  </summary>
    function Parse( out ModelInstance: IModelInstance ): TStatus;
  end;

{$endregion}

{$region ' ITransition '}

type
  ///  <summary>
  ///    Represents a user supplied model transition. <br/>
  ///    Which ever parser or transition which comes before this one in the
  ///    compile chain, will generate the model which this transition takes
  ///    as its 'SourceModel'.  Your transition should generate a new model
  ///    on the out 'TargetModel' parameter. Transitions might be as simple
  ///    as a single optimization of the source, or might transition from
  ///    one model to an entirely different model, it's up to you to provide
  ///    what is needed for your compile chain.
  ///  </summary>
  ITransition = interface
    ['{5DE89ED2-B618-41E4-BFCB-FF5CDD804094}']

    ///  <summary>
    ///    Transition the source model to a target model.
    ///  </summary>
    function Transition( const SourceModel: IModelInstance; out TargetModel: IModelInstance ): TStatus;
  end;

{$endregion}

{$region ' ICodeGenerator '}

type
  ///  <summary>
  ///    A CodeGenerator takes a model (the product of parsing or transitioning)
  ///    as its input, and generates one or more output files. Typically the
  ///    output file will be source-code for some other tool, such as an assembler
  ///    for instance.
  ///  </summary>
  ICodeGenerator = interface
    ['{C7F5ED2C-0A29-49AD-BCE8-7F8F125030C7}']

    ///  <summary>
    ///    Transition the source model to one or more output files. <br/>
    ///    SourceModel - The model to generate code from. <br/>
    ///  </summary>
    function Generate( const SourceModel: IModelInstance ): TStatus;
  end;

{$endregion}

{$region ' IPostProcess '}

type
  ///  <summary>
  ///    A post process is an optional step in the compile chain, after a
  ///    code generator has been called to generate output, the post process
  ///    may be called to operate on that output. For instance, a code
  ///    generator might generate an assembler source file, the post process
  ///    could call on an external assembler to assemble the source,
  ///    and then call an external linker to generate the final executable. <br/>
  ///    The code generator may use the config model instance to forward
  ///    information to the post-process, such as the names of the files
  ///    that it generated to be operated on.
  ///  </summary>
  IPostProcess = interface
    ['{302EC0EA-3D21-451B-9EFA-42F7F4422411}']
    function Run(): TStatus;
  end;

{$endregion}

{$region ' ICompileChain '}

type
  ///  <summary>
  ///    A compile chain represents a collection of various compiler components
  ///    to transition source code to the final output. It will always have
  ///    at least a parser and a code generator. It may also contain one or
  ///    more transitions, and may contain one or more post processes. <br/>
  ///    Compile chains are registered with the 'CompileChains' singleton
  ///    in order that the compiler application be able to determine which
  ///    chains are available, and call upon them as requested by the user.
  ///  </summary>
  ICompileChain = interface
    ['{D2838329-44C2-472E-A9D7-A80D84FEBEE9}']

    ///  <summary>
    ///    All compilers have different configurations, and so an interface
    ///    reference is configured to represent the configuration. Each
    ///    component of the chain may cast this interface to the appropriate
    ///    configuration type.
    ///  </summary>
    function Configuration: IInterface;

    ///  <summary>
    ///    The compile chain will progress the compilation process from the
    ///    initial parsing phase, through any number of transitions, to the
    ///    code generation phase, and then any number of post processes which
    ///    may be required to complete compilation. <br/>
    ///    Immediately after Parse(), if successful, this method will return
    ///    the model in its current state, and will continue to return the
    ///    current state of the model after each successive call to
    ///    Transition(). When all transforms have been applied, a call to
    ///    Generate() is made, at which point this method will return nil. <br/>
    ///    This is because the model will have been disposed, it is no
    ///    longer required after the code generator has used it to generate
    ///    an assembler file. <br/>
    ///    This method exists to aid in debugging the compiler, and has no use
    ///    in a production build.
    ///  </sumamry>
    function Model: IModelInstance;

    ///  <summary>
    ///    Attempts to parse the configured source code file. <br/>
    ///    Note: This is step-1 of the compilation process, and will set the
    ///    internal transition counter to zero, and reinitialize the model
    ///    which is returned by the Model() method above. <br/>
    ///  </summary>
    function Parse: TStatus;

    ///  <summary>
    ///    After parsing, the model may be passed through several transitions
    ///    before being passed to the generate phase. The Transition() method
    ///    must be called repeatedly until it returns either an error status,
    ///    or the stDone status, indicating that there are no further
    ///    transition in the compile chain.
    ///  </summary>
    function Transition: TStatus;

    ///  <summary>
    ///    The Generate stage may be called only when all transitions have
    ///    been made. An error will be returned if transitioning is incomplete
    ///    when Generate is called. <br/>
    ///    The Generate method will use the internal model to generate one or
    ///    more output files which may be the final result of compilation, or
    ///    which may be required as input to post processes (such as assemble
    ///    and link phases). <br/>
    ///  </summary>
    function Generate: TStatus;

    ///  <summary>
    ///    PostProcess should be called after Generate() has completed
    ///    successfully. Attempting to call PostProcess before Generate is
    ///    called will cause an error to be returned. <br/>
    ///    As with Transition(), PostProcess() should be called repeatedly
    ///    until it returns stDone. There may be several post processing
    ///    steps required to transform the output of Generate into the
    ///    final product of compilation.  Examples of post processes are
    ///    to call an assembler, and linker to take the output of Generate
    ///    and produce an executable for the selected target.
    ///  </summary>
    function PostProcess: TStatus;

  end;

{$endregion}

{$region ' Factories for parser, transitions, code generators, and post processes. '}

type
  ///  <summary>
  ///    A factory method capable of instancing a parser. <br/>
  ///    Provided to ICompileChains.RegisterChain().
  ///  </summary>
  TParserFactory = function ( const Log: ILog; const Config: IInterface ): IParser;

  ///  <summary>
  ///    A factory method capable of instancing a transition. <br/>
  ///    Provided to ICompileChains.RegisterChain().
  ///  </summary>
  TTransitionFactory = function ( const Log: ILog; const Config: IInterface ): ITransition;

  ///  <summary>
  ///    A composite of a factory for a transition, and it's usage value.
  ///    This record exists as a convenience for registering transitions
  ///    with a compile chain, see ICompileChains.RegisterChain().
  ///  </summary>
  TTransitionRecord = record
    Factory: TTransitionFactory;
    OutputName: string;
  public
    class function Create( const OutputName: string; const Factory: TTransitionFactory ): TTransitionRecord; static;
  end;

  ///  <summary>
  ///    A factory method capable of instancing a code generator. <br/>
  ///    Provided to ICompileChains.RegisterChain().
  ///  </summary>
  TCodeGeneratorFactory = function ( const Log: ILog; const Config: IInterface ): ICodeGenerator;

  ///  <summary>
  ///    A factory method capable of instancing a post process. <br/>
  ///    Provided to ICompileChians.RegisterChain().
  ///  </summary>
  TPostProcessFactory = function ( const Log: ILog; const Config: IInterface ): IPostProcess;

{$endregion}

{$region ' ICompileChains '}

type
  ///  <summary>
  ///    A factory which is able to instance a configuration model for
  ///    a compile chain.
  ///  </summary>
  TConfigFactory = reference to function( const Platform: TPlatform; const Target: TTarget ): IInterface;

type
  ///  <summary>
  ///    A configuration handler is a function/method which takes an existing
  ///    instance of the configuration model, and adjusts the configuration
  ///    upon the creation of a compile chain.
  ///  </summary>
  TConfigurationHandler = reference to procedure( const ConfigModel: IInterface );

type
  ///  <summary>
  ///    A collection representing the installed compile chains that the
  ///    compiler application may select from in order to compile a source
  ///    file. <br/> This interface provides access to the functionality of
  ///    the singleton 'CompileChains'.
  ///  </summary>
  ICompileChains = interface
    ['{484327C6-4E5E-49B3-93EB-4325207440EF}']

    ///  <summary>
    ///    For each chain created, register a factory method which can be
    ///    used to instance the chain.
    ///  </summary>
    function RegisterChain( const SourceSyntax: string;
                            const Platform: TPlatform;
                            const Target: TTarget;
                            const Parser: TParserFactory;
                            const Transitions: array of TTransitionRecord;
                            const CodeGenerator: TCodeGeneratorFactory;
                            const PostProcesses: array of TPostProcessFactory;
                            const ConfigFactory: TConfigFactory
                          ): ICompileChain;

    ///  <summary>
    ///    Selects a compile chain using the SourceSyntax, Target and Platform
    ///    parameters to identify which chain to create. <br/>
    ///    After your compile chain has been instanced and returned, be sure to
    ///    set up its configuration (see ICompileChain.Configuration ), before
    ///    attempting to perform compilation. At minimum you should create the
    ///    configuration root representation, and set some member of it which
    ///    the parser will understand to be the source code file/stream.
    ///  </summary>
    function CreateChain( const Log: ILog;
                          const SourceSyntax: string;
                          const Platform: TPlatform;
                          const Target: TTarget;
                          const ConfigHandler: TConfigurationHandler ): ICompileChain;

    ///  <summary>
    ///    Returns a list of available input syntax based on what has been
    ///    registered.
    ///  </summary>
    function InputSyntax: IReadOnlyList< string >;

    ///  <summary>
    ///    Returns a list of available platforms for a given input
    ///    syntax, based on what has been registered.
    ///  </summary>
    function Platforms( const InputSyntax: string ): IReadOnlyList< TPlatform >;

    ///  <summary>
    ///    Returns a list of target archetectures for a given input
    ///    syntax and platform, based on what has been registered.
    ///  </summary>
    function Targets( const InputSyntax: string; const Platform: TPlatform ): IReadOnlyList< TTarget >;

    ///  <summary>
    ///    Returns a list of names identifying the output after each transition
    ///    for a given input syntax, platform and target. These names are
    ///    arbitrarily defined when registering transitions, and are used
    ///    exclusively for debugging purposes. Do not rely on these to be
    ///    unique, or to follow any identifier rules.
    ///  </summary>
    function ModelNames( const InputSyntax: string; const Platform: TPlatform; const Target: TTarget ): IReadOnlyList< string >;
  end;

{$endregion}

{$region ' ISymbols '}

type
  ///  <summary>
  ///    A base interface for ILabelSymbol and INumericSymbol.
  ///  </summary>
  IScopedSymbol = interface
  ['{9C7AC085-E23A-4701-804A-C26FC1315A2B}']
  end;

  ///  <summary>
  ///    A symbol that reflects a label in the target assembler source file.
  ///  </summary>
  ILabelSymbol = interface( IScopedSymbol )
  ['{C7979AF3-105A-4429-AEA9-65100B3C2CB8}']

    ///  <summary>
    ///    Returns the assembler file source label for this symbol.
    ///  </summary>
    function SourceLabel: string;
  end;

  ///  <summary>
  ///    A symbol that reflects a numeric value, such as an offset from the
  ///    stack frame base.
  ///  </summary>
  INumericSymbol = interface( IScopedSymbol )
  ['{53174387-B00D-4AB1-BDC3-645AF1436FFF}']

    ///  <summary>
    ///     Returns the numeric value for this symbol.
    ///  </summary>
    function Value: uint64;
  end;

type
  ///  <summary>
  ///    As a utility for use in transitions / code generation, the ISymbolTree
  ///    interface represents a scope-enabled tree of symbols which reflect
  ///    identifiers in the source code. This tree allows generation of code
  ///    using globally unique symbols to identify items in the final output,
  ///    which might otherwise have colliding identifiers dependant on scope.
  ///  </summary>
  IScopedSymbols = interface
    ['{4DCF2116-37EB-4397-86B7-27FDD98A30DA}']

    ///  <summary>
    ///    Increments the level of scope such that new symbols may be added.
    ///  </summary>
    procedure IncrementScope;

    ///  <summary>
    ///    Decrements the level of scope. Any symbols created at the current
    ///    scope level before decrement will no longer be accessible via
    ///    local identifier as they have "gone out of scope."
    ///  </summary>
    procedure DecrementScope;

    ///  <summary>
    ///    Adds a label symbol at the current scope level, using the provided
    ///    identifier as its key. Note that the symbol will be automatically
    ///    generated in order to ensure that it is globally unique.
    ///  </summary>
    function AddLabelSymbol( const Identifier: string ): IScopedSymbol;

    ///  <summary>
    ///    Adds a numeric symbol at the current level of scope, using the
    ///    provided identifier as its key.
    ///  </summary>
    function AddNumericSymbol( const Identifier: string; const Value: uint64 ): IScopedSymbol;

    ///  <summary>
    ///    Recursing up the levels of scope, locates a symbol by its identifier. <br/>
    ///    If not nil, the returned symbol must be inspected to determine if it
    ///    is an ILabelSymbol or an INumericSymbol.
    ///  </summary>
    function SymbolLookup( const Identifier: string ): IScopedSymbol;
  end;

type
  TScopedSymbols = record
    class function Create: IScopedSymbols; static;
  end;

{$endregion}

///  <summary>
///    Returns a singleton instance of ICompileChains which represents the
///    collection of available compiler chains.
///  </summary>
function CompileChains: ICompileChains;

///  <summary>
///    Utility to return a TTarget as a string.
///  </summary>
function TargetName( const Target: TTarget ): string;

///  <summary>
///    Utility to return a TTarget given its string representation.
///  </summary>
function TargetFromName( const Name: string ): TTarget;

///  <summary>
///    Utility to return a TPlatform as a string.
///  </summary>
function PlatformName( const Platform: TPlatform ): string;

///  <summary>
///    Utility to return a TPlatform given it's string representation.
///  </summary>
function PlatformFromName( const Name: string ): TPlatform;

implementation
uses
  System.TypInfo
, utlTypes
, utlCompile.CompileChains
, utlCompile.Symbols
;

var
  SingletonCompileChains: ICompileChains = nil;

function TargetName( const Target: TTarget ): string;
begin
  Result := GetEnumName( System.TypeInfo( TTarget ), ord( Target ) ).Replace( 'tgt_', '' );
end;

function PlatformName( const Platform: TPlatform ): string;
begin
  Result := GetEnumName( System.TypeInfo( TPlatform ), ord( Platform ) ).Replace( 'pl_', '' );;
end;

function TargetFromName( const Name: string ): TTarget;
var
  utName: string;
begin
  utName := Name.UppercaseTrim;
  for Result := Low( TTarget ) to High( TTarget ) do begin
    if TargetName( Result ).UppercaseTrim = utName then exit;
  end;
  Result := tgt_Unset;
end;

function PlatformFromName( const Name: string ): TPlatform;
var
  utName: string;
begin
  utName := Name.UppercaseTrim;
  for Result := Low( TPlatform ) to High( TPlatform ) do begin
    if PlatformName( Result ).UppercaseTrim = utName then exit;
  end;
  Result := pl_Unset;
end;



function CompileChains: ICompileChains;
begin
  if not assigned( SingletonCompileChains ) then begin
    SingletonCompileChains := TCompileChains.Create;
  end;
  Result := SingletonCompileChains;
end;

class function TTransitionRecord.Create( const OutputName: string; const Factory: TTransitionFactory ): TTransitionRecord;
begin
  Result.OutputName := OutputName;
  Result.Factory := Factory;
end;

class function TScopedSymbols.Create: IScopedSymbols;
begin
  Result := utlCompile.Symbols.TScopedSymbols.Create;
end;

initialization
  SingletonCompileChains := nil;
  TStatus.Register( stDone                     , '' );
  TStatus.Register( stSourceNotParsed          , 'Internal Error: Attempt to call transition, generate, or post-process before source has been parsed.' );
  TStatus.Register( stModelNotTransitioned     , 'Internal Error: Attempt to call generate or post-process before completing transitions. ');
  TStatus.Register( stNotGenerated             , 'Internal Error: Attempt to call post-process before code is generated. ');
  TStatus.Register( stChainAlreadyRegistered   , 'Internal Error: A compile-chain for "(%%)" to target "(%%)"."(%%)" is already registered.' );
  TStatus.Register( stSourceModelIsInvalid     , 'Internal Error: The transition or generator source model is not valid.' );
  TStatus.Register( stSourceModelIsMissingRoot , 'Internal Error: The transition or generator source model is missing its root node.' );
  TStatus.Register( stInvalidTarget            , 'Internal Error: Invalid target for operation.' );
  TStatus.Register( stInvalidPlatform          , 'Internal Error: Invalid platform for operation.' );

finalization
  SingletonCompileChains := nil;

end.
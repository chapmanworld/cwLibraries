(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlIO;

interface
uses
  utlStatus
, utlUnicode
;

{$region ' Status values '}

const
  stCannotResizeFixedBuffer        : TGUID = '{CB3C254C-A651-4B15-854B-D5613DBBDCED}';
  stIOFileNotFound                 : TGUID = '{5D9DE059-4A5C-47CB-9B89-2BD3CEF8AF8F}';
  stIOPathNotFound                 : TGUID = '{69FF48D2-83C5-416D-9230-F48DF381B157}';
  stIOTooManyOpenFiles             : TGUID = '{9A46A51C-7002-46EB-8B6C-BCE624F732B2}';
  stIOFileAccessDenied             : TGUID = '{8990EAD4-3B67-446B-8DA4-FF553189AA88}';
  stIOInvalidFileHandle            : TGUID = '{370D1AC8-6AF1-4152-8ABB-96EB4827E66B}';
  stIOInvalidFileAccessMode        : TGUID = '{B764EFFB-AA10-43F4-A6B8-E824AFE3B841}';
  stIOInvalidDiskNumber            : TGUID = '{AEABE379-9C70-442B-968B-11F506A11DAF}';
  stIOCannotRemoveCurrentDirectory : TGUID = '{30925D3C-0E3E-49DF-A414-9CBD7998F537}';
  stIOCannotRenameAcrossVolumes    : TGUID = '{81C21AEB-8A32-4106-A4D5-537224F5AA6B}';
  stIOErrorReadingFromDisk         : TGUID = '{76FC2686-11A3-47B5-B40D-1583F8F6B1B2}';
  stIOErrorWritingToDisk           : TGUID = '{200716C8-71A1-4BD0-A099-EDF50761C7DE}';
  stIOFileNotAssigned              : TGUID = '{B0AD0A1D-F0E1-4404-BE3B-57A8147E601E}';
  stIOFileNotOpen                  : TGUID = '{28FC2B51-37DD-4742-BFBD-8C41E9B2F44E}';
  stIOFileNotOpenedForInput        : TGUID = '{1285498C-8DEB-422E-859D-7CB8A0E1FF36}';
  stIOFileNotOpenedForOutput       : TGUID = '{B3DE0AAC-4828-4FC4-A8F7-C3CE41F17991}';
  stIOInvalidNumber                : TGUID = '{C542658B-58A6-407D-9C4B-94017231EB4E}';
  stIODiskIsWriteProtected         : TGUID = '{C9BB7AB7-D979-4665-B484-D3EA47CEB986}';
  stIOUnknownDevice                : TGUID = '{2D6A17D3-EC03-49CB-A6D0-FA500A55E546}';
  stIODriveNotReady                : TGUID = '{047FD27F-F34A-469A-B493-6A029738BCD4}';
  stIOUnknownCommand               : TGUID = '{3CBCB971-9DC2-4527-9FA0-B5251A753A65}';
  stIOCRCCheckFailed               : TGUID = '{DF01BF76-FABC-4161-9F1D-FD2ECFAF490E}';
  stIOInvalidDriveSpecified        : TGUID = '{7B143164-B58E-4F94-837B-69A55137A013}';
  stIOSeekErrorOnDisk              : TGUID = '{6E9CAF1E-DA43-42CF-86B8-ABBA5DF88B14}';
  stIOInvalidMediaType             : TGUID = '{A9D45170-55D0-4D76-9AEF-5AD3B2C700C3}';
  stIOSectorNotFound               : TGUID = '{16498253-360C-4600-A460-ADCDE76DC9BB}';
  stIOPrinterOutOfPaper            : TGUID = '{07758254-A226-4974-9808-7A079551C094}';
  stIOErrorWritingToDevice         : TGUID = '{6327A78E-81BC-4DC6-A68C-697DFC60FF77}';
  stIOErrorReadingFromDevice       : TGUID = '{5B5C3F2E-26CC-4977-B60E-175E2D9A06CC}';
  stIOHardwareFailure              : TGUID = '{600E4603-7450-4915-AEAE-017D979EF5E9}';
  stIOUnkownError                  : TGUID = '{DEF570E5-7ADF-4FD2-8582-23C4DC6FB6EF}';
  stUnableToDetermineUnicodeFormat : TGUID = '{E3F092F9-A132-45A1-B234-EEC2DA053996}';
  stStreamWriteError               : TGUID = '{73E56719-7C32-4F20-A5E2-1EB672225A43}';
  stStreamReadError                : TGUID = '{56CD6E39-640E-4A14-8540-09F1440F9208}';

{$endregion}

{$region ' Supporting Types '}

type
  ///  <summary>
  ///    Alias from utlUnicode for convenience, so that uses utlUnicode
  ///    is not required in order to use unicode streams.
  ///  </summary>
  TUnicodeFormat = utlUnicode.TUnicodeFormat;

{$endregion}

{$region ' IReadOnlyStream '}

type
  /// <summary>
  ///   Represents a read-only stream, such as a file stream for exmple.
  /// </summary>
  IReadOnlyStream = interface
    ['{952E1034-0508-4D61-9597-918191DE06AE}']

    /// <summary>
    ///   Returns true if the cursor is currently positioned at the end of the
    ///   stream.
    /// </summary>
    /// <returns>
    ///   True if the cursor is currently positioned at the end of the stream,
    ///   otherwise returns false.
    /// </returns>
    function EndOfStream: boolean;

    /// <summary>
    ///   Get the current cursor position within the stream.
    /// </summary>
    /// <returns>
    ///   index of the cursor within the stream from zero, in bytes.
    /// </returns>
    function getPosition: nativeuint;

    /// <summary>
    ///   Set the cursor position within the stream.
    /// </summary>
    /// <param name="newPosition">
    ///   The index from zero at which to position the cursor, in bytes.
    /// </param>
    /// <remarks>
    ///   Some streams do not support setting the cursor position. In such
    ///   cases, the cursor position will remain unchanged. You should test
    ///   getPosition() to confirm that the move was successful.
    /// </remarks>
    procedure setPosition( const newPosition: nativeuint );

    ///  <summary>
    ///    Returns the number of bytes remaining on the stream.
    ///  </summary>
    ///  <remarks>
    ///    Some streams do not support reporting the cursor position, and so,
    ///    the remaining number of bytes may be unknown. In such cases, this
    ///    method will return zero.
    ///  </remarks>
    function getRemainingBytes: nativeuint;

    /// <summary>
    ///   Reads an arbritrary number of bytes from the stream. <br />
    /// </summary>
    /// <param name="p">
    ///   Pointer to a buffer with sufficient space to store the bytes read
    ///   from the stream.
    /// </param>
    /// <param name="Count">
    ///   The maximum number of bytes to read from the stream (size of the
    ///   buffer).
    /// </param>
    /// <returns>
    ///   The number of bytes actually read from the stream, which may differ
    ///   from the number requested in the count parameter. See remarks.
    /// </returns>
    /// <remarks>
    ///   <para>
    ///     When reading from streams, a number of conditions may prevent the
    ///     read operation from returning the number of bytes requested.
    ///   </para>
    ///   <para>
    ///     Examples Include:
    ///   </para>
    ///   <list type="bullet">
    ///     <item>
    ///       Request is for more bytes than remain in the datasource of
    ///       the stream. In this case, the remaining data bytes are
    ///       returned, and the return value of the Read() method will
    ///       reflect the number of bytes actually returned. <br /><br />
    ///     </item>
    ///     <item>
    ///       The stream does not support read operations. Some streams are
    ///       unidirectional. If this stream does not support reading
    ///       operations, the read() method will return zero.
    ///     </item>
    ///   </list>
    /// </remarks>
    function Read( const p: pointer; const Count: nativeuint ): nativeuint; overload;

    ///  <summary>
    ///    This overload of Read() returns a signed int8 from the stream.
    ///  </sumary>
    function Read( out Value: int8 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Read() returns a signed int16 from the stream.
    ///  </sumary>
    function Read( out Value: int16 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Read() returns a signed int32 from the stream.
    ///  </sumary>
    function Read( out Value: int32 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Read() returns a signed int64 from the stream.
    ///  </sumary>
    function Read( out Value: int64 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Read() returns an unsigned uint8 from the stream.
    ///  </sumary>
    function Read( out Value: uint8 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Read() returns an unsigned uint16 from the stream.
    ///  </sumary>
    function Read( out Value: uint16 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Read() returns an unsigned uint32 from the stream.
    ///  </sumary>
    function Read( out Value: uint32 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Read() returns an unsigned uint64 from the stream.
    ///  </sumary>
    function Read( out Value: uint64 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Read() returns single precision floating point from the stream.
    ///  </sumary>
    function Read( out Value: single ): TStatus; overload;

    ///  <summary>
    ///    This overload of Read() returns double precision floating point from the stream.
    ///  </sumary>
    function Read( out Value: double ): TStatus; overload;

    ///  <summary>
    ///    This overload of Read() returns boolean from the stream.
    ///  </sumary>
    function Read( out Value: boolean ): TStatus; overload;

    ///  <summary>
    ///    This overload of Read() returns string from the stream. <br/>
    ///    Note: This overload reads a string in utf8 format, and which is
    ///    preceeded by a uint64 containing the size of the string data in
    ///    bytes (not codepoints). This method is the counterpart to the
    ///    equivolent overload of the Write() method on writable
    ///    stream interfaces.
    ///  </sumary>
    function Read( out Value: string ): TStatus; overload;

    ///  <summary>
    ///    This overload of Read() returns guid from the stream.
    ///  </sumary>
    function Read( out Value: TGUID ): TStatus; overload;

    /// <summary>
    ///   Returns the size of the stream in bytes.
    /// </summary>
    function Size: nativeuint;

    ///  <summary>
    ///    Reads a single byte from the stream.
    ///  </summary>
    function ReadByte: uint8;

    ///  <summary>
    ///    Get or Set the current cursor position within the stream.
    ///  </summary>
    property Position: nativeuint read getPosition write setPosition;
  end;

{$endregion}

{$region ' IStream '}

type
  /// <summary>
  ///   Represents a readable / writable stream.
  /// </summary>
  IStream = interface( IReadOnlyStream )
    ['{08852882-39D7-4CC1-8E1E-D5F323E47421}']

    ///  <summary>
    ///    For streams which support the method, clear will empty all content
    ///    from the stream and reset the position to zero.
    ///    For streams which do not support clear, an error is inserted into
    ///    the log. (lsFatal)
    ///  </summary>
    procedure Clear;

    /// <summary>
    ///   Writes an arbritrary number of bytes to the stream.
    /// </summary>
    /// <param name="p">
    ///   A pointer to a buffer from which bytes will be written onto the
    ///   stream.
    /// </param>
    /// <param name="Count">
    ///   The number of bytes to write onto the stream.
    /// </param>
    /// <returns>
    ///   Returns the number of bytes actually written to the stream, which may
    ///   differ from the number specified in the Count parameter. See remarks.
    /// </returns>
    /// <remarks>
    ///   <para>
    ///     A number of conditions can prevent writing data to a stream, in
    ///     which case, the number of bytes written may differ from the
    ///     number specified in the count parameter.
    ///   </para>
    ///   <para>
    ///     Examples include:
    ///   </para>
    ///   <list type="bullet">
    ///     <item>
    ///       There is insufficient space left in the stream target for
    ///       additional data. In this case, the maximum amount of data
    ///       that can be written, will be written, and the return value of
    ///       the Write() method reflects the number of bytes actually
    ///       written. <br /><br />
    ///     </item>
    ///     <item>
    ///       The stream does not support writing. Some streams are
    ///       unidirectional and therefore may not support writing
    ///       operations. In this case, the Write() method will return
    ///       zero.
    ///     </item>
    ///   </list>
    /// </remarks>
    function Write( const p: pointer; const Count: nativeuint ): nativeuint; overload;

    ///  <summary>
    ///    This overload of Write() stores a signed int8 into the stream.
    ///  </sumary>
    function Write( const Value: int8 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Write() stores a signed int16 into the stream.
    ///  </sumary>
    function Write( const Value: int16 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Write() stores a signed int32 into the stream.
    ///  </sumary>
    function Write( const Value: int32 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Write() stores a signed int64 into the stream.
    ///  </sumary>
    function Write( const Value: int64 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Write() stores an unsigned uint8 into the stream.
    ///  </sumary>
    function Write( const Value: uint8 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Write() stores an unsigned uint16 into the stream.
    ///  </sumary>
    function Write( const Value: uint16 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Write() stores an unsigned uint32 into the stream.
    ///  </sumary>
    function Write( const Value: uint32 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Write() stores an unsigned uint64 into the stream.
    ///  </sumary>
    function Write( const Value: uint64 ): TStatus; overload;

    ///  <summary>
    ///    This overload of Write() stores a single precision float into the stream.
    ///  </sumary>
    function Write( const Value: single ): TStatus; overload;

    ///  <summary>
    ///    This overload of Write() stores a double precision float into the stream.
    ///  </sumary>
    function Write( const Value: double ): TStatus; overload;

    ///  <summary>
    ///    This overload of Write() stores a boolean into the stream.
    ///  </sumary>
    function Write( const Value: boolean ): TStatus; overload;

    ///  <summary>
    ///    This overload of Write() stores a string into the stream. <br/>
    ///    Note: This overload stores a string in utf8 format with
    ///    a preceeding uint64 containing the size of the string data in
    ///    bytes (not codepoints). This method is the counterpart to
    ///    the equivolent overload of the Read() method.
    ///  </sumary>
    function Write( const Value: string ): TStatus; overload;

    ///  <summary>
    ///    This overload of Write() stores a guid into the stream.
    ///  </sumary>
    function Write( const Value: TGUID ): TStatus; overload;

    /// <summary>
    ///   Copies the contents of another stream to this one.
    /// </summary>
    /// <param name="Source">
    ///   The stream to copy data from.
    /// </param>
    /// <returns>
    ///   <para>
    ///     Returns the number of bytes copied from the source stream to this
    ///     one. A number of conditions could prevent successful copying of
    ///     one stream to another.
    ///   </para>
    ///   <para>
    ///     Examples include
    ///   </para>
    ///   <list type="bullet">
    ///     <item>
    ///       The target stream is not writable. In this case, the
    ///       CopyFrom() method will return zero. <br /><br />
    ///     </item>
    ///     <item>
    ///       The source stream is not readable. In this case the
    ///       CopyFrom() method will return zero. <br /><br />
    ///     </item>
    ///     <item>
    ///       The target stream has insufficient storage space for the data
    ///       being copied from the source stream. In this case, the
    ///       maximum number of bytes that can be copied will be copied,
    ///       and the return value of the CopyFrom() method will reflect
    ///       the number of bytes actually copied.
    ///     </item>
    ///   </list>
    /// </returns>
    function CopyFrom( const Source: IReadOnlyStream ): nativeuint;

    ///  <summary>
    ///    Writes a single byte to the stream.
    ///  </summary>
    procedure WriteByte( const value: uint8 );

    ///  <summary>
    ///    Writes an array of bytes to the stream.
    ///  </summary>
    procedure WriteBytes( const value: array of uint8 );

  end;

{$endregion}

{$region ' IReadOnlyUnicodeStream '}

type
  /// <summary>
  ///   A stream which supports the IReadOnlyUnicodeStream is able to read data from
  ///   a stream containing unicode data.
  /// </summary>
  IReadOnlyUnicodeStream = interface( IReadOnlyStream )
    ['{29E281F2-FC97-41E1-954C-B3A44FD5E3CB}']

    /// <summary>
    ///   <para>
    ///     This method attempts to read the unicode BOM (byte-order-mark) of
    ///     the specified unicode format, and returns TRUE if the BOM is
    ///     found or else returns FALSE. <br />
    ///     Warning, the BOM for UTF16-LE will match when the BOM for UTF32-LE
    ///     is present, because the first two bytes of the UTF32-LE BOM match
    ///     those of the UTF-16LE BOM.  Similarly the UTF32-BE BOM will match
    ///     for UTF16-BE. In order to determine the unicode format from the BOM
    ///     values, these values must be tested in order of length, starting
    ///     with the highest. i.e. Test of UTF32-LE and only if that fails to
    ///     match, test for UTF-16LE.
    ///     The Determine unicode format tests BOM's in order to determine the
    ///     unicode format from the BOM.
    ///   </para>
    ///   <para>
    ///     If the BOM is found, the stream position is advanced, but if the
    ///     BOM is not found, the stream position does not change.
    ///   </para>
    /// </summary>
    /// <param name="Format">
    ///   Specifies the unicode format for which a byte-order-mark is expected
    ///   on the stream.
    /// </param>
    /// <returns>
    ///   Returns TRUE if the BOM is discovered on the stream at the current
    ///   position, otherwise returns FALSE.
    /// </returns>
    function ReadBOM( const Format: TUnicodeFormat ): boolean;

    /// <summary>
    ///   This method looks for a unicode BOM (byte-order-mark), and if one is
    ///   found, the appropriate unicode format enumeration is returned. <br />
    ///   If no unicode BOM is found, this function returns utfUnknown and you
    ///   should default to the most appropriate format. In most cases UTF-8 is
    ///   a good default option due to it's compatability with ANSI. <br />
    /// </summary>
    /// <returns>
    ///   The TdeUnicodeFormat enum which indicates the BOM which was
    ///   discovered, or else utfUnknown is returned if no appropriate BOM is
    ///   found.
    /// </returns>
    function DetermineUnicodeFormat: TUnicodeFormat;

    ///  <summary>
    ///    This method reads a single character from the stream using the
    ///    specified unicode format.
    ///  </summary>
    ///  <param name="Format">
    ///    The unicode format to use to decode the character being read from
    ///    the stream.
    ///  </param>
    ///  <returns>
    ///    Returns the next character from the unicode encoded stream.
    ///  </returns>
    function ReadChar( const Format: TUnicodeFormat ): char;

    /// <summary>
    ///   This method reads a string of characters from the stream in the
    ///   specified unicode format, translating them to a TString UTF-16LE. <br />
    /// </summary>
    /// <param name="Format">
    ///   The unicode format to use when reading the characters <br />from the
    ///   stream.
    /// </param>
    /// <param name="ZeroTerm">
    ///   Optional parameter. Terminate reading characters from the stream when
    ///   a zero character is found?
    /// </param>
    /// <param name="Max">
    ///   Optional parameter. The maximum number of unicode characters to read
    ///   from the stream.
    /// </param>
    /// <returns>
    ///   The string of characters read from the stream, converted to <br />
    ///   TdeString (UTF-16LE)
    /// </returns>
    /// <remarks>
    ///   <para>
    ///     This method, by default, will read characters from the stream
    ///     until the stream has been exhausted.
    ///   </para>
    ///   <para>
    ///     You can tell the stream to terminate early using the two optional
    ///     parameters. <br /><br />
    ///   </para>
    ///   <para>
    ///     Setting ZeroTerm to true causes the method to stop reading when a
    ///     code-point is discovered with the value of zero. This is useful
    ///     for reading zero terminated strings from the stream. The zero
    ///     will be removed from the stream, but not added to the string.
    ///   </para>
    ///   <para>
    ///     Alternatively, you can set the Max parameter to limit the number
    ///     of characters that will be read from the stream.
    ///   </para>
    /// </remarks>
    function ReadString( const Format: TUnicodeFormat; const ZeroTerm: boolean = False; const Max: int32 = -1 ): string;

  end;

{$endregion}

{$region ' IUnicodeStream '}

type
  /// <summary>
  ///   A stream which supports the IUnicodeStream is able to read data from a stream
  //    containing unicode data, and/or write unicode data to the stream.
  /// </summary>
  IUnicodeStream = interface( IStream )
    ['{BA3588F0-32A4-4039-A212-389C630BB2E4}']

    /// <summary>
    ///   <para>
    ///     This method attempts to read the unicode BOM (byte-order-mark) of
    ///     the specified unicode format, and returns TRUE if the BOM is
    ///     found or else returns FALSE. <br />
    ///     Warning, the BOM for UTF16-LE will match when the BOM for UTF32-LE
    ///     is present, because the first two bytes of the UTF32-LE BOM match
    ///     those of the UTF-16LE BOM.  Similarly the UTF32-BE BOM will match
    ///     for UTF16-BE. In order to determine the unicode format from the BOM
    ///     values, these values must be tested in order of length, starting
    ///     with the highest. i.e. Test of UTF32-LE and only if that fails to
    ///     match, test for UTF-16LE.
    ///     The Determine unicode format tests BOM's in order to determine the
    ///     unicode format from the BOM.
    ///   </para>
    ///   <para>
    ///     If the BOM is found, the stream position is advanced, but if the
    ///     BOM is not found, the stream position does not change.
    ///   </para>
    /// </summary>
    /// <param name="Format">
    ///   Specifies the unicode format for which a byte-order-mark is expected
    ///   on the stream.
    /// </param>
    /// <returns>
    ///   Returns TRUE if the BOM is discovered on the stream at the current
    ///   position, otherwise returns FALSE.
    /// </returns>
    function ReadBOM( const Format: TUnicodeFormat ): boolean;

    /// <summary>
    ///   This method looks for a unicode BOM (byte-order-mark), and if one is
    ///   found, the appropriate unicode format enumeration is returned. <br />
    ///   If no unicode BOM is found, this function returns utfUnknown and you
    ///   should default to the most appropriate format. In most cases UTF-8 is
    ///   a good default option due to it's compatability with ANSI. <br />
    /// </summary>
    /// <returns>
    ///   The TdeUnicodeFormat enum which indicates the BOM which was
    ///   discovered, or else utfUnknown is returned if no appropriate BOM is
    ///   found.
    /// </returns>
    function DetermineUnicodeFormat: TUnicodeFormat;

    ///  <summary>
    ///    This method reads a single character from the stream using the
    ///    specified unicode format.
    ///  </summary>
    ///  <param name="Format">
    ///    The unicode format to use to decode the character being read from
    ///    the stream.
    ///  </param>
    ///  <returns>
    ///    Returns the next character from the unicode encoded stream.
    ///  </returns>
    function ReadChar( const Format: TUnicodeFormat ): char;

    /// <summary>
    ///   This method reads a string of characters from the stream in the
    ///   specified unicode format, translating them to a TString UTF-16LE. <br />
    /// </summary>
    /// <param name="Format">
    ///   The unicode format to use when reading the characters <br />from the
    ///   stream.
    /// </param>
    /// <param name="ZeroTerm">
    ///   Optional parameter. Terminate reading characters from the stream when
    ///   a zero character is found?
    /// </param>
    /// <param name="Max">
    ///   Optional parameter. The maximum number of unicode characters to read
    ///   from the stream.
    /// </param>
    /// <returns>
    ///   The string of characters read from the stream, converted to <br />
    ///   TdeString (UTF-16LE)
    /// </returns>
    /// <remarks>
    ///   <para>
    ///     This method, by default, will read characters from the stream
    ///     until the stream has been exhausted.
    ///   </para>
    ///   <para>
    ///     You can tell the stream to terminate early using the two optional
    ///     parameters. <br /><br />
    ///   </para>
    ///   <para>
    ///     Setting ZeroTerm to true causes the method to stop reading when a
    ///     code-point is discovered with the value of zero. This is useful
    ///     for reading zero terminated strings from the stream. The zero
    ///     will be removed from the stream, but not added to the string.
    ///   </para>
    ///   <para>
    ///     Alternatively, you can set the Max parameter to limit the number
    ///     of characters that will be read from the stream.
    ///   </para>
    /// </remarks>
    function ReadString( const Format: TUnicodeFormat; const ZeroTerm: boolean = False; const Max: int32 = -1 ): string;

    /// <summary>
    ///   <para>
    ///     This method will write the Byte-Order-Mark of the specified
    ///     unicode text format onto the stream.
    ///   </para>
    ///   <para>
    ///     Formats of unknown and ansi will do nothing as there is no BOM
    ///     for these formats.
    ///   </para>
    /// </summary>
    /// <param name="Format">
    ///   Format The unicode format to write a BOM for.
    /// </param>
    procedure WriteBOM( const Format: TUnicodeFormat );

    ///  <summary>
    ///    This method writes a character to the stream in the specified
    ///    unicode format.
    ///  </summary>
    ///  <param name="aChar">
    ///    The character to write to the stream.
    ///  </param>
    ///  <param name="Format">
    ///    The unicode format used to encode the character onto the stream.
    ///  </param>
    procedure WriteChar( const aChar: char; const Format: TUnicodeFormat );

    /// <summary>
    ///   This method writes the string of characters to the stream in <br />
    ///   the specified unicode format. <br/>
    ///   Optionally writes a zero terminator for the string, in the size of
    ///   the code-point encoding.
    /// </summary>
    /// <param name="aString">
    ///   The string of characters to write to the stream.
    /// </param>
    /// <param name="Format">
    ///   The unicode format to use when writing the characters to the stream.
    /// </param>
    procedure WriteString( const aString: string; const Format: TUnicodeFormat; const ZeroTerm: boolean = FALSE );

  end;

{$endregion}

{$region ' IBuffer '}

type
  /// <summary>
  ///   IBuffer provides methods for manipulating the data content of a memory buffer.
  /// </summary>
  /// <seealso cref="de.buffers|TBuffer">
  ///   TBuffer
  /// </seealso>
  IBuffer = interface
    ['{115CCCF5-4F51-425E-9A00-3CEB8E6E19E6}']

    ///  <summary>
    ///    Fills the entire buffer with the value passed in the 'value' parameter.
    ///    Useful for clearing the buffer for example.
    ///  </summary>
    ///  <param name="value">
    ///    The value to fill the buffer with.
    ///  </param>
    procedure FillMem( const value: uint8 );

    /// <summary>
    ///   Loads 'Bytes' bytes of data from the stream into the buffer.
    /// </summary>
    /// <param namme="Stream">
    ///   The stream to load data from.
    /// </param>
    /// <param name="Bytes">
    ///   The number of bytes to load from the stream.
    /// </param>
    /// <returns>
    ///   The number of bytes actually read from the stream.
    /// </returns>
    function LoadFromStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;

    /// <summary>
    ///   Saves 'Bytes' bytes of data from the buffer into the stream.
    /// </summary>
    /// <param name="Stream">
    ///   The stream to save bytes into.
    /// </param>
    /// <param name="Bytes">
    ///   The number of bytes to write into the stream.
    /// </param>
    /// <returns>
    ///   The number of bytes actually written to the stream.
    /// </returns>
    function SaveToStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;

    /// <summary>
    ///   Copy the data from another buffer to this one. <br />The size of the
    ///   buffer will be appropriately altered to match that of the buffer
    ///   being copied.
    /// </summary>
    /// <param name="Buffer">
    ///   The buffer to copy data from.
    /// </param>
    /// <remark>
    ///   This method is destructive to existing data in the buffer.
    /// </remark>
    procedure Assign( const Buffer: IBuffer );

    /// <summary>
    ///   Insert data from another memory location into this buffer.
    ///   There must be sufficient space in the buffer to store the inserted
    ///   data at the specified offset. <br/>
    ///   Optionally, setting the 'MakeSpace' parameter to TRUE will cause the
    ///   buffer size to be increased in order to accomodate the new data at
    ///   the offset possition. If 'MakeSpace' is omitted (default to FALSE),
    ///   the inserted data will overwrite the data at the offset location.
    /// </summary>
    /// <param name="Buffer">
    ///   This is a pointer to the memory location that data should be copied
    ///   from.
    /// </param>
    /// <param name="Bytes">
    ///   Specifies the number of bytes to read from the memory location.
    /// </param>
    /// <param name="MakeSpace">
    ///   Optional parameter: When set FALSE (the default) the inserted
    ///   data will overwrite existing data at the Offset location in the
    ///   buffer.  When set TRUE, the buffer size will be increased such
    ///   that the new data may be inserted at the Offset location, and
    ///   the remaining data in the buffer moved up to accomodate the
    ///   insertion.
    /// </param>
    /// <remarks>
    ///   When the optional 'MakeSpace' parameter is FALSE, this
    ///   method is destructive to existing data in the buffer.
    /// </remarks>
    procedure InsertData( const Buffer: Pointer; const Offset: nativeuint; const Bytes: nativeuint; MakeSpace: boolean = FALSE );

    ///  <summary>
    ///    Chops out / Removes a piece of the buffer at the specified
    ///    offset, of the specified size in bytes. If the size in bytes
    ///    added to the offset, exceeds the existing buffer size, then
    ///    the number of bytes removed is reduced to the end of the buffer.
    ///  </summary>
    procedure DeleteData( const Offset: nativeuint; const Bytes: nativeuint );

    /// <summary>
    ///   Appends data from another memory location to the end of this buffer.
    /// </summary>
    /// <param name="Buffer">
    ///   A pointer to the memory location that data should be copied from.
    /// </param>
    /// <param name="Bytes">
    ///   Specifies the number of bytes to add to the buffer from the memory
    ///   location specified in the buffer parameter.
    /// </param>
    /// <returns>
    ///   Pointer to the newly appended data.
    /// </returns>
    function AppendData( const Buffer: Pointer; const Bytes: nativeuint ): pointer; overload;

    ///  <summary>
    ///    Appends data from another memory location to the end of this buffer.
    ///    The data to be appended must be zero-terminated.
    ///    If the size of the buffer to be appended is known, see the other
    ///    overload of AppendData().
    ///  </summary>
    function AppendData( const Buffer: pointer ): pointer; overload;

    ///  <summary>
    ///    Appends data from another buffer.
    ///  </summary>
    procedure AppendData( const Buffer: IBuffer ); overload;

    /// <summary>
    ///   Extract data to another memory location from this buffer.
    /// </summary>
    /// <param name="Buffer">
    ///   This is a pointer to the memory location that data should be copied
    ///   to
    /// </param>
    /// <param name="Bytes">
    ///   This is the number of bytes that should be copied from this buffer.
    /// </param>
    procedure ExtractData( const Buffer: Pointer; const Offset: nativeuint; const Bytes: nativeuint );

    /// <summary>
    ///   Returns a void pointer to the buffer data.
    /// </summary>
    function getDataPointer: pointer;

    /// <summary>
    ///   Returns the size of the buffer in bytes.
    /// </summary>
    function getSize: nativeuint;

    /// <summary>
    ///    Returns the value of the byte specified by index (offset within the buffer)
    ///  </summary>
    ///  <param name="idx">
    ///    An offset into the buffer.
    ///  </param>
    function getByte( const idx: nativeuint ): uint8;

    /// <summary>
    ///    Sets the value of the byte specified by index (offset within the buffer)
    ///  </summary>
    ///  <param name="idx">
    ///    An offset into the buffer.
    ///  </param>
    ///  <param>
    ///    The value to set.
    ///  </param>
    procedure setByte( const idx: nativeuint; const value: uint8 );

    /// <summary>
    ///   Sets the size of the buffer in bytes.
    /// </summary>
    /// <param name="aSize">
    ///   The new buffer size in bytes.
    /// </param>
    /// <remarks>
    ///   This function will retain any existing data, up-to the new size of
    ///   the buffer.
    /// </remarks>
    procedure setSize( const aSize: nativeuint );

    /// <summary>
    ///   Get or Set the size of the data in this buffer, in bytes.
    ///   When setting to a larger size, any data already within the buffer
    ///   is preserved. If decreasing the size, as much data as can be
    ///   preserved will be.
    /// </summary>
    property Size: nativeuint read getSize write setSize;

    ///  <summary>
    ///    Returns a vanilla pointer to the data within the buffer.
    ///  </summary>
    property DataPtr: pointer read getDataPointer;

    ///  <summary>
    ///    Provides array-style access to the bytes within the buffer.
    ///  </summary>
    property Bytes[ const idx: nativeuint ]: uint8 read getByte write setByte;
  end;

{$endregion}

{$region ' ICyclicBuffer '}

type
  ///  <summary>
  ///    Provides for a limited sized buffer with both read and write
  ///    cursors. As data is read from the read cursor, the space it
  ///    occupied is available for writing to at the write cursor.
  ///  </summary>
  ICyclicBuffer = interface
    ['{42C239B3-36F7-4618-B4BD-929C53DFF75C}']

    /// <summary>
    ///   Simply resets the buffer pointers.
    /// </summary>
    procedure Clear;

    /// <summary>
    ///   Write 'Count' bytes into the buffer. If there is insufficient space in
    ///   the buffer, this method will return a <0 error code. Otherwise the
    ///   number of bytes added is returned.
    /// </summary>
    function Write( const DataPtr: Pointer; const Count: nativeuint ): nativeuint;

    /// <summary>
    ///   Read 'Count' bytes from the buffer. If there is insufficient data to
    ///   return the number of bytes requested, the maximum available bytes
    ///   will be read. This method returns the number of bytes read from
    ///   the buffer.
    /// </summary>
    function Read( const DataPtr: Pointer; const Count: nativeuint ): nativeuint;

    ///  <summary>
    ///    Reads 'Size' bytes from the buffer, but doesn't remove that data from
    ///    the buffer as Read does.
    ///  </summary>
    function Peek( const DataPtr: Pointer; const Count: nativeuint ): nativeuint;

    /// <summary>
    ///   Loads 'Bytes' bytes of data from the stream into the buffer.
    /// </summary>
    function LoadFromStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;

    /// <summary>
    ///   Saves 'Bytes' bytes of data from the buffer into the stream.
    /// </summary>
    function SaveToStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;

    /// <summary>
    ///   Returns the number of bytes that are freely available in the buffer.
    /// </summary>
    function GetFreeBytes: nativeuint;

    /// <summary>
    ///   Returns the number of bytes that are currently occupied in the buffer.
    /// </summary>
    function GetUsedBytes: nativeuint;
  end;

{$endregion}

{$region ' IUnicodeBuffer '}

type
  ///  <summary>
  ///    Provides methods for working with buffers containing unicode text.
  ///  </summary>
  IUnicodeBuffer = interface( IBuffer )
    ['{E0472DB1-CDE7-4FD1-BB02-00291C0342F6}']

    ///  <summary>
    ///    Returns the entire buffer as a string, assuming that the data in
    ///    the buffer is encoded as UTF16-LE (the default string type).
    ///  </summary>
    function getAsString: string;

    ///  <summary>
    ///    Sets the buffer length to be sufficient to store the string in
    ///    UTF16-LE format internally.
    ///  </summary>
    procedure setAsString( const value: string );

    ///  <summary>
    ///    Attempts to read the byte-order-mark of the specified unicode format.
    ///    Returns true if the requested BOM is present at the beginning of
    ///    the buffer, else returns false.
    ///  </summary>
    function ReadBOM( const Format: TUnicodeFormat ): boolean;

    ///  <summary>
    ///    Writes the specified unicode byte-order-mark to the beginning of the
    ///    buffer.
    ///  </summary>
    procedure WriteBOM( const Format: TUnicodeFormat );

    ///  <summary>
    ///    Attempts to identify the unicode format of the data in the buffer
    ///    by inspecting the byte-order-mark or other attributes of the data.
    ///  </summary>
    function DetermineUnicodeFormat: TUnicodeFormat;

    ///  Returns length of string written to buffer, in bytes.
    ///  The buffer size is set to match the length of the string after encoding.
    ///  If the optional ZeroTerm parameter is set true, a zero terminator is
    ///  added to the string and returned byte-count. This may only be useful
    ///  when writing ANSI or UTF8 format strings as other formats do not
    ///  typically use zero termination.
    function WriteString( const aString: string; const Format: TUnicodeFormat; ZeroTerm: boolean = FALSE ): nativeuint;

    ///  Max when not -1, is length of TString in characters
    function ReadString( const Format: TUnicodeFormat; const ZeroTerm: boolean = False; const Max: int32 = -1 ): string;

    ///  <summary>
    ///    When setting, will set the length of the buffer to the required number
    ///    of bytes to contain the string in UTF16-LE format internally.
    ///    When getting, the entire buffer will be returned as a string.
    ///  </summary>
    property AsString: string read getAsString write setAsString;
  end;

{$endregion}

{$region ' TMemoryStream (factory) '}

type
  ///  <summary>
  ///    Factory record to create instances of IStream / IUnicodeStream in memory.
  ///  </summary>
  TMemoryStream = record
    class function Create( const BufferGranularity: uint64 = 0 ): IUnicodeStream; static;
  end;

{$endregion}

{$region ' TFileStream (factory) '}

type
  ///  <summary>
  ///    Factory record to create instances of IStream / IUnicodeStream to disk file.
  ///  </summary>
  TFileStream = record
    class function Create( const Filepath: string; const ReadOnly: boolean ): IUnicodeStream; static;
  end;

{$endregion}

{$region ' TPartialStream (factory) '}

type
  ///  <summary>
  ///    Factory record to create instances of IReadOnlyStream / IReadOnlyUnicodeStream, which are
  ///    sub-streams within other streams.
  ///  </summary>
  TPartialStream = record
    ///  <summary>
    ///    Provide a source stream containing the actual content, and both an offset and size ( byte count )
    ///    within that stream. The return value is a read only stream which manages its own cursor such that
    ///    position zero is actually the 'Offset' within the source stream. <br/>
    ///  </summary>
    class function Create( const SourceStream: IReadOnlyUnicodeStream; const Offset: nativeuint; const Size: nativeuint ): IReadOnlyUnicodeStream; static;
  end;

{$endregion}

{$region ' TCyclicBuffer (factory) '}

type
  ///  <summary>
  ///    Factory record to create instances of ICyclicBuffer.
  ///  </summary>
  TCyclicBuffer = record
    class function Create( const Size: nativeuint = 0 ): ICyclicBuffer; static;
  end;

{$endregion}

{$region ' TBuffer (factory) '}

type
  ///  <summary>
  ///    Factory record to create instances of IBuffer / IUnicodeBuffer.
  ///  </summary>
  TBuffer = record

    ///  <summary>
    ///    Creates a new instance of a buffer with the size specified in
    ///    the aSize parameter. Optionally, you may 16-byte align the buffer
    ///    by setting the Align16 optional parameter to TRUE.
    ///  </summary>
    class function Create( const aSize: nativeuint = 0; const Align16: boolean = FALSE ): IUnicodeBuffer; static;

    ///  <summary>
    ///    Create a buffer of a fixed size. <br/>
    ///    The size of the buffer is specified using the aSize parameter. <br/>
    ///    Any attempt to resize a buffer which has a fixed size will result in
    ///    an exception being raised. <br/>
    ///    You may also optionally provide the DataPtr parameter which fixes
    ///    the buffer to a particular memory location. If the DataPtr parameter
    ///    is provided, this instance of TBuffer will neither allocate nor
    ///    deallocate the buffer, allowing the buffer to point at a pre-existing
    ///    buffer.
    ///  </summary>
    class function CreateFixed( const aSize: nativeuint = 0; const DataPtr: pointer = nil ): IUnicodeBuffer; static;
  end;

{$endregion}

function CreateTemporaryFilename( const Ext: string; const Subdir: string = '' ): string;

implementation
uses
  SysUtils
, System.IOUtils
, utlIO.Buffer
, utlIO.CyclicBuffer
, utlIO.MemoryStream
, utlIO.FileStream
, utlIO.PartialStream
;

function CreateTemporaryFilename( const Ext: string; const Subdir: string = '' ): string;
var
  GUID: TGUID;
  Filename: string;
  C: char;
  Path: string;
begin
  CreateGUID( GUID );
  Filename := '';
  for C in GuidToString( GUID ) do begin
    if CharInSet( C, [ 'a'..'f', 'A'..'f', '0'..'9' ] ) then Filename := Filename + C;
  end;
  Filename := '_' + Filename + '.' + Ext;
  Path := TPath.Combine( TPath.GetTempPath, subdir );
  ForceDirectories( Path );
  Result := TPath.Combine( Path, Filename );
end;


{$region ' TMemoryStream (factory) '}

class function TMemoryStream.Create(const BufferGranularity: uint64): IUnicodeStream;
begin
  Result := TStandardMemoryStream.Create(BufferGranularity);
end;

{$endregion}

{$region ' TFileStream (factory) '}

class function TFileStream.Create(const Filepath: string; const ReadOnly: boolean): IUnicodeStream;
begin
  Result := TStandardFileStream.Create( Filepath, ReadOnly );
end;

{$endregion}

{$region ' TPartialStream (factory) '}

class function TPartialStream.Create( const SourceStream: IReadOnlyUnicodeStream; const Offset: nativeuint; const Size: nativeuint ): IReadOnlyUnicodeStream;
begin
  Result := utlIO.PartialStream.TPartialStream.Create( SourceStream, Offset, Size );
end;

{$endregion}

{$region ' TCyclicBuffer (factory) '}

class function TCyclicBuffer.Create(const Size: nativeuint = 0): ICyclicBuffer;
begin
  Result := TStandardCyclicBuffer.Create( Size );
end;

{$endregion}

{$region ' TBuffer (factory) '}

class function TBuffer.Create(const aSize: nativeuint = 0; const Align16: boolean = FALSE ): IUnicodeBuffer;
begin
  Result := TStandardBuffer.Create( aSize, Align16 );
end;

class function TBuffer.CreateFixed(const aSize: nativeuint; const DataPtr: pointer): IUnicodeBuffer;
begin
  Result := TStandardBuffer.CreateFixed( aSize, DataPtr );
end;

{$endregion}

initialization
  TStatus.Register( stCannotResizeFixedBuffer        , 'Cannot resize fixed-size buffer.' );
  TStatus.Register( stIOFileNotFound                 , 'IOError "File not found" occurred while accessing (%%)' );
  TStatus.Register( stIOPathNotFound                 , 'IOError "Path not found" occurred while accessing (%%)' );
  TStatus.Register( stIOTooManyOpenFiles             , 'IOError "Too many open files" occurred while accessing (%%)' );
  TStatus.Register( stIOFileAccessDenied             , 'IOError "File access denied" occurred while accessing (%%)' );
  TStatus.Register( stIOInvalidFileHandle            , 'IOError "Invalid file handle" occurred while accessing (%%)' );
  TStatus.Register( stIOInvalidFileAccessMode        , 'IOError "Invalid file access mode" occurred while accessing (%%)' );
  TStatus.Register( stIOInvalidDiskNumber            , 'IOError "Invalid disk number" occurred while accessing (%%)' );
  TStatus.Register( stIOCannotRemoveCurrentDirectory , 'IOError "Cannot remove current directory" occurred while accessing (%%)' );
  TStatus.Register( stIOCannotRenameAcrossVolumes    , 'IOError "Cannot rename across volumes" occurred while accessing (%%)' );
  TStatus.Register( stIOErrorReadingFromDisk         , 'IOError "Error reading from disk" occurred while accessing (%%)' );
  TStatus.Register( stIOErrorWritingToDisk           , 'IOError "Error writing to disk" occurred while accessing (%%)' );
  TStatus.Register( stIOFileNotAssigned              , 'IOError "File not assigned" occurred while accessing (%%)' );
  TStatus.Register( stIOFileNotOpen                  , 'IOError "File not open" occurred while accessing (%%)' );
  TStatus.Register( stIOFileNotOpenedForInput        , 'IOError "File not opened for input" occurred while accessing (%%)' );
  TStatus.Register( stIOFileNotOpenedForOutput       , 'IOError "File not opened for output" occurred while accessing (%%)' );
  TStatus.Register( stIOInvalidNumber                , 'IOError "Invalid number" occurred while accessing (%%)' );
  TStatus.Register( stIODiskIsWriteProtected         , 'IOError "Disk is write protected" occurred while accessing (%%)' );
  TStatus.Register( stIOUnknownDevice                , 'IOError "Unknown device" occurred while accessing (%%)' );
  TStatus.Register( stIODriveNotReady                , 'IOError "Drive not ready" occurred while accessing (%%)' );
  TStatus.Register( stIOUnknownCommand               , 'IOError "Unknown command" occurred while accessing (%%)' );
  TStatus.Register( stIOCRCCheckFailed               , 'IOError "CRC Check failed" occurred while accessing (%%)' );
  TStatus.Register( stIOInvalidDriveSpecified        , 'IOError "Invalid drive specified" occurred while accessing (%%)' );
  TStatus.Register( stIOSeekErrorOnDisk              , 'IOError "Seek error on disk" occurred while accessing (%%)' );
  TStatus.Register( stIOInvalidMediaType             , 'IOError "Invalid media type" occurred while accessing (%%)' );
  TStatus.Register( stIOSectorNotFound               , 'IOError "Sector not found" occurred while accessing (%%)' );
  TStatus.Register( stIOPrinterOutOfPaper            , 'IOError "Printer out of paper" occurred while accessing (%%)' );
  TStatus.Register( stIOErrorWritingToDevice         , 'IOError "Error writing to device" occurred while accessing (%%)' );
  TStatus.Register( stIOErrorReadingFromDevice       , 'IOError "Error reading from device" occurred while accessing (%%)' );
  TStatus.Register( stIOHardwareFailure              , 'IOError "Hardware failure" occurred while accessing (%%)' );
  TStatus.Register( stIOUnkownError                  , 'IOError "Unknown error" occurred while accessing (%%)' );
  TStatus.Register( stUnableToDetermineUnicodeFormat , 'Unable to determine unicode format.' );
  TStatus.Register( stStreamWriteError               , 'Error writing data to stream.' );
  TStatus.Register( stStreamReadError                , 'Error reading data from stream.' );

end.

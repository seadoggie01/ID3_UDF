#include-once
#include <Array.au3> ;need for UnSynchronisation
#include <String.au3>
; #INDEX# =======================================================================================================================
; Title .........: ID3 UDF
; AutoIt Version : v3.3.8.0
; Language ......: English
; Description ...: Functions that Read/Write ID3v1.1 ID3v2.3, ID3v2.4 and APEv2 Tags in MP3 files.
; Description ...: No Dll required
; Author(s) .....: Joe Begnoche (joeyb1275)
; UDF Forum Link.: http://www.autoitscript.com/forum/index.php?showtopic=43950&st=0
; Feature List...:
;					Added ID3v2.4 read/write compatability
;					Added reading/writing of ID3v1.1+ Extended Tags
;					Added ability to read/write multiple frameIDs (ID3v2 allows multiple TXXX,WXXX frames and others)
;					Improved time to read tags for all versions by about 80%
;					Added AlbumArt reading for jpeg and png
;					Added _APEv2 functions _APEv2Tag_GetTagSize() _APEv2Tag_GetVersion() and _APEv2Tag_GetItemCount()
;					Added _MPEG_... functions
;					Tested Reading Tags from
;						-Tag&Rename - ID3v1.1 & ID3v2.3
;						-mp3Tag Pro - ID3v1.1 & ID3v2.3
;						-Mp3tag - ID3v1.1, ID3v2.3 & APEv2
;						-iTunes - APEv2 TagSize which includes header (Not to standard)
; Function List..:
;					MAIN UDF FUNCTION LIST
;						_ID3ReadTag()
;						_ID3GetTagField()
;						_ID3SetTagField()
;						_ID3WriteTag()
;						_ID3RemoveTag()
;						_ID3CreateTag()
;						_ID3DeleteFiles()
;					ID3v1 EXTENDED FUNCTION LIST
;						_ID3v1Tag_ReadFromFile()
;						_ID3v1Tag_GetVersion()
;						_ID3v1Field_GetString()
;						_ID3v1Field_SetString()
;						_ID3v1Tag_WriteToFile()
;					ID3v2 EXTENDED FUNCTION LIST
;						_ID3v2Tag_ReadFromFile()
;						_ID3v2Tag_WriteToFile()
;						_ID3v2Tag_RemoveFrame()
;						_ID3v2Tag_GetVersion()
;						_ID3v2Tag_GetHeaderFlags()
;						_ID3v2Tag_GetTagSize()
;						_ID3v2Tag_GetExtendedHeader()
;						_ID3v2Tag_GetFooter()
;						_ID3v2Tag_GetZPAD()
;						_ID3v2Frame_GetBinary()
;						_ID3v2Frame_SetBinary()
;						_ID3v2Frame_GetFields()
;						_ID3v2Frame_SetFields()
;					MPEG FUNCTION LIST
;						_MPEG_GetFrameHeader()
;						_MPEG_IsValidHeader()
;						_MPEG_GetVersion()
;						_MPEG_GetLayer()
;						_MPEG_GetBitRate()
;						_MPEG_GetSampleRate()
;						_MPEG_GetChannelMode()
;						_MPEG_GetChannelModeEx()
;					APEv2 FUNCTION LIST
;						_APEv2Tag_ReadFromFile()
;						_APEv2Tag_GetTagSize()
;						_APEv2_GetItemKeys()
;						_APEv2_GetItemValueBinary()
;						_APEv2_GetItemValueString()
;						_APEv2_RemoveTag()
;
;					ID3v1 HELPER FUNCTION LIST
;						_h_ID3v1_GetGenreFromID()
;						_h_ID3v1_GetGenreID()
;					ID3v2 HELPER FUNCTION LIST
;						_h_ID3v2Tag_EnumerateFrameIDs()
;						_h_ID3v2FrameHeader_GetFrameID()
;						_h_ID3v2FrameHeader_GetFrameSize()
;						_h_ID3v2FrameHeader_GetFlags()
;						_h_ID3v2_GetFrameT000_TZZZ()
;						_h_ID3v2_CreateFrameT000_TZZZ()
;						_h_ID3v2_GetFrameTXXX()
;						_h_ID3v2_CreateFrameTXXX()
;						_h_ID3v2_GetFrameW000_WZZZ()
;						_h_ID3v2_CreateFrameW000_WZZZ()
;						_h_ID3v2_GetFrameWXXX()
;						_h_ID3v2_CreateFrameWXXX()
;						_h_ID3v2_GetFrameCOMM()
;						_h_ID3v2_CreateFrameCOMM()
;						_h_ID3v2_GetFrameAPIC()
;						_h_ID3v2_CreateFrameAPIC()
;						_h_ID3v2_GetFrameUSLT()
;						_h_ID3v2_CreateFrameUSLT()
;						_h_ID3v2_GetFramePCNT()
;						_h_ID3v2_CreateFramePCNT()
;						_h_ID3v2_GetFrameUFID()
;						_h_ID3v2_CreateFrameUFID()
;						_h_ID3v2_GetFramePOPM()
;						_h_ID3v2_CreateFramePOPM()
;						_h_ID3v2_GetFramePRIV()
;						_h_ID3v2_CreateFramePRIV()
;						_h_ID3v2_GetFrameRGAD()
;						_h_ID3v2_DecodeTextToString()
;						_h_ID3v2_EncodeStringToBinary()
;						_h_ID3v2_ConvertFrameID()
; Latest Version.: Release 3.4.0  - 20120610
;				   	-Added resetting of all global ID3 variables in _ID3ReadTag() to make sure they are set back to the default values and ready to read a new file
;				   	-changed _ID3WriteTag() to determine what tags have been read and to only write back those version if $iTagVersion=-1, edited _ID3WriteTag() comments
;				   	-added $iReturnTypeFlag to _ID3GetTagField() inputs for ID3v2 functions
;				   	-fixed _ID3GetTagField() so that @extended is set to the Number of frames that exist with same $sFrameIDRequest
;				   	-fixed _h_ID3v2_EncodeStringToBinary() variable typo ($FrameData should be $bFrameData), thanks BrewManNH!
; Latest Version.: Release 3.4.1  - 2013
;					-removed File.au3, String.au3 & Array.au3 dependencies
; ToDo List......:
;				-working to fix RemoveUnsynchronization() functions, testing with COMM frame from Foobar2000 v2.4
;				-TODO -ID3v2.4 - work with COMM frame from Foobar2000
;				-TODO -_ID3RemoveTag add save raw MPEG data mode
;				-TODO -ID3v2.4 add ability to remove unsychronization of each frame
;
;				-TODO -MPEG - handle VBR MP3 properly (XING Header) and (VBRI Header)
;						-http://www.codeproject.com/Articles/8295/MPEG-Audio-Frame-Header#SideInfo
;				-TODO -ID3v1 - Test Read/write of TAG+ Extended Tags
;				-TODO -ID3v2 - Add reading of extended header
;				-TODO -add error flow up from _ID3v1 and _ID3v2 functions to _ID3 functions
;				-TODO Clean up code comments
;				-TODO check if File.au3 is actually needed by _h_ID3v2_CreateFrameAPIC
;			Release 3.5 TODO
;			   -TODO -MPEG - handle VBR MP3 properly (XING Header) and (VBRI Header)
;				  -http://www.codeproject.com/Articles/8295/MPEG-Audio-Frame-Header#SideInfo
;			   -TODO -ID3v2.4 - work with COMM frame from Foobar2000
;			   -TODO -ID3v1 - Test Read/write of TAG+ Extended Tags
;			   -TODO -ID3v2 - Add reading of extended header
;			   -TODO -ID3v2.4 add ability to remove unsychronization of each frame
;			   -TODO -add error flow up from _ID3v1 and _ID3v2 functions to _ID3 functions
;			   -TODO Clean up code comments
; ===============================================================================================================================



#cs #ID3.au3 ID3v2 FrameID Definitions# ;========================================================================================

	FrameIDs as of ID3v2.3,ID3v2.2 (not all may work in UDF)
	AENC,CRA	Audio encryption
	APIC,PIC 	Attached picture
	COMM,COM 	Comments
	COMR 		Commercial frame.
	CRM 		Encrypted meta frame (ID3v2.2 only)
	ENCR 		Encryption method registration
	EQUA,EQU 	Equalization
	ETCO,ETC 	Event timing codes
	GEOB,GEO 	General encapsulated object
	GRID 		Group identification registration
	IPLS,IPL 	Involved people list
	LINK,LNK 	Linked information
	MCDI,MCI 	Music CD identifier
	MLLT,MLL 	MPEG location lookup table
	OWNE 		Ownership frame
	PRIV 		Private frame
	PCNT,CNT 	Play counter
	POPM,POP 	Popularimeter
	POSS 		Position synchronisation frame
	RBUF,BUF	Recommended buffer size
	RVAD,RVA 	Relative volume adjustment
	RVRB,REV 	Reverb
	SYLT,SLT 	Synchronized lyric/text
	SYTC,STC 	Synchronized tempo codes
	TALB,TAL 	Album/Movie/Show title
	TBPM,TBP 	BPM (beats per minute)
	TCOM,TCM 	Composer
	TCON,TCO 	Content type
	TCOP,TCR 	Copyright message
	TDAT,TDA 	Date
	TDLY,TDY 	Playlist delay
	TENC,TEN 	Encoded by
	TEXT,TXT 	Lyricist/Text writer
	TFLT,TFT 	File type
	TIME,TIM 	Time
	TIT1,TT1 	Content group description
	TIT2,TT2 	Title/songname/content description
	TIT3,TT3 	Subtitle/Description refinement
	TKEY,TKE 	Initial key
	TLAN,TLA 	Language(s)
	TLEN,TLE 	Length
	TMED,TMT 	Media type
	TOAL,TOT 	Original album/movie/show title
	TOFN,TOF 	Original filename
	TOLY,TOL 	Original lyricist(s)/text writer(s)
	TOPE,TOA 	Original artist(s)/performer(s)
	TORY,TOR 	Original release year
	TOWN 		File owner/licensee
	TPE1,TP1 	Lead performer(s)/Soloist(s)
	TPE2,TP2 	Band/orchestra/accompaniment
	TPE3,TP3 	Conductor/performer refinement
	TPE4,TP4 	Interpreted, remixed, or otherwise modified by
	TPOS,TPA 	Part of a set
	TPUB,TPB 	Publisher
	TRCK,TRK 	Track number/Position in set
	TRDA,TRD 	Recording dates
	TRSN 		Internet radio station name
	TRSO 		Internet radio station owner
	TSIZ,TSI 	Size
	TSRC,TRC	ISRC - International Standard Recording Code
	TSSE,TSS 	Software/Hardware and settings used for encoding
	TYER,TYE 	Year
	TXXX,TXX 	User defined text information frame
	UFID,UFI	Unique file identifier
	USER 		Terms of use
	USLT,ULT	Unsychronized lyric/text transcription
	WCOM,WCM 	Commercial information
	WCOP,WCP 	Copyright/Legal information
	WOAF,WAF	Official audio file webpage
	WOAR,WAR	Official artist/performer webpage
	WOAS,WAS	Official audio source webpage
	WORS 		Official internet radio station homepage
	WPAY 		Payment
	WPUB,WPB 	Publishers official webpage
	WXXX,WXX 	User defined URL link frame
	Unofficial Frames Seen in the Wild:
	These are frames that are not in the specs that programs are writing:
	http://www.id3.org/Developer_Information
	COMM 		w. desc="iTunNORM": iTunes Normalization settings
	RGAD 		Replay Gain Adjustment (This is not widely supported and I think it has been superseded by RVA2 in ID3v2.4 (and the XRVA tag for 2.3 compatibility).)
	TCMP 		iTunes Compilation Flag
	TSO2 		iTunes uses this for Album Artist sort order
	TSOC 		iTunes uses this for Composer sort order
	XRVA 		Experimental RVA2
	Deprecated ID3v2 frames (Not in ID3v2.4)
	EQUA 	 	Equalization (This frame is replaced by the EQU2 frame)
	IPLS 		Involved people list (This frame is replaced by the two frames TMCL, 'Musician credits list', and TIPL, 'Involved people list')
	RVAD  		Relative volume adjustment (This frame is replaced by the RVA2 frame, 'Relative volume adjustment (2)')
	TDAT  		Date (This frame is replaced by the TDRC frame, 'Recording time')
	TIME  		Time (This frame is replaced by the TDRC frame, 'Recording time')
	TORY  		Original release year (This frame is replaced by the TDOR frame, 'Original release time')
	TRDA  		Recording dates (This frame is replaced by the TDRC frame, 'Recording time')
	TSIZ  		Size (The information contained in this frame is in the general case either trivial to calculate for the player or impossible for the
					tagger to calculate. There is however no good use for such information. The frame is therefore completely deprecated.
	TYER  		Year (This frame is replaced by the TDRC frame, 'Recording time')
	New frames in ID3v2.4
	ASPI 		Audio seek point index
	EQU2 		Equalisation (2)
	RVA2 		Relative volume adjustment (2)
	SEEK 		Seek frame
	SIGN 		Signature frame
	TDEN 		Encoding time
	TDOR 		Original release time
	TDRC 		Recording time
	TDRL 		Release time
	TDTG 		Tagging time
	TIPL 		Involved people list
	TMCL 		Musician credits list
	TMOO 		Mood
	TPRO 		Produced notice
	TSOA 		Album sort order
	TSOP 		Performer sort order
	TSOT 		Title sort order
	TSST 		Set subtitle
#ce ;============================================================================================================================

#cs #ID3.au3 UDF Latest Changes.......: ;====================================================================
	Release 3.0 - 20120501
		-Code re-write to improve performance and increase features
		-Added ID3v2.4 read/write compatability
		-Added removal of Unsynchronisation (Needed for ID3v2.4 tags from Foobar2000)
		-Added reading/writing of ID3v1.1+ Extended Tags (Not Tested Yet) (http://en.wikipedia.org/wiki/ID3)
		-Added reading and removing of APEv2 Tags at the end of the file
		-Improved time to read tags for all versions by about 80%
		-Added ability to read/write multiple frameIDs (ID3v2 allows multiple TXXX,WXXX frames and others)
		-Added functions to read ID3v2 Header information
		-Added function to return binary data
		-Removed _ID3GetFrameDescription() (not needed for reading/writing of tags)
	Release 3.1 - 20120519
		-Fixed _h_ID3v2_GetFrameAPIC() to handle png file data properly
		-Added a check if ID3v2 exists and if not to add it in _ID3v2Frame_SetBinary() and _ID3v2Frame_SetFields()
		-Fixed removing ID3v1 Tag in _ID3v1Tag_RemoveTag(), changed first FileOpen to read mode instead of write mode
		-Fixed _APEv2Tag_ReadFromFile() when no ID3v1 tag exists
		-Added _h_ID3v2FrameHeader_GetFlags() functionality
		-Fixed _h_ID3v2_GetFrameAPIC() when reading an ID3v2.2 PIC frame
 	Release 3.2 - 20120529
	    -Fixed _ID3v2Tag_WriteToFile() to write new tag data
		-Changed _ID3v2Tag_GetFrameIDs() to _h_ID3v2Tag_EnumerateFrameIDs() because it should only be used as an internal helper function
		-Changed _ID3v2Tag_RemoveUnsynchronisation() to _h_ID3v2Tag_RemoveUnsynchronisation() because it should only be used as an internal helper function
		-Changed _MPEG_IsValidHeader() to _h_MPEG_IsValidHeader() because it should only be used as an internal helper function
		-Added _APEv2 functions _APEv2Tag_GetTagSize() _APEv2Tag_GetVersion() and _APEv2Tag_GetItemCount()
		-Fixed _APEv2Tag_ReadFromFile() to read in tag plus header
		-Changed _APEv2_GetItemKeys() to _h_APEv2_EnumerateItemKeys() because it should only be used as an internal helper function
		-Changed _APEv2_GetItemKeys() function return structure to be a delimited list of the ItemKeys or an array
		-Added support in _APEv2_GetItemValueString for reading of multiple values in one APEv2 ItemKey seperated by 0x00 (Support for Mp3tag)
		-Added support in _APEv2_GetItemValueString for reading Album Art
		-Added support for iTunes APEv2 TagSize which includes header (Not to standard)
		-Added _MPEG_... functions
		-Tested Reading Tags from
			-Tag&Rename - ID3v1.1 & ID3v2.3
			-mp3Tag Pro - ID3v1.1 & ID3v2.3
			-Mp3tag - ID3v1.1, ID3v2.3 & APEv2
    Release 3.3 - 20120608
	    -Fixed ID3v2 _ID3v2Frame_SetFields() and _ID3v2Tag_WriteToFile() if called when no tag exists
		-Added a check if tag exists in _ID3v1Field_SetString() and creates it if it does not exist
		-Changed _ID3v2Frame_SetFields() for TXXX so that the delimited string format is $sDescription:$sValue, where more then 1 field in string is passed in
		-Commented some message boxes used for debugging
	Release 3.4  - 20120610
		-Added resetting of all global ID3 variables in _ID3ReadTag() to make sure they are set back to the default values and ready to read a new file
		-changed _ID3WriteTag() to determine what tags have been read and to only write back those version if $iTagVersion=-1, edited _ID3WriteTag() comments
		-added $iReturnTypeFlag to _ID3GetTagField() inputs for ID3v2 functions
		-fixed _ID3GetTagField() so that @extended is set to the Number of frames that exist with same $sFrameIDRequest
		-fixed _h_ID3v2_EncodeStringToBinary() variable typo ($FrameData should be $bFrameData), thanks BrewManNH!
	Release 3.4.1  - 201312
		-removed File.au3 and String.au3 dependencies
		-fixed _ID3v2Frame_SetFields() for the POPM tag
    Working for 3.4.2 Release
		 -renaming variables with UDF naming rules
		 -merging in 3.4.2 from local and fixing bugs

		 Pushed Unsync work to another release
		 -working on _h_ID3v2Tag_RemoveUnsynchronisation()
			_h_ID3v2Frame_RemoveUnsynchronisation() needs to be finished
			Foobar2000 only added an unsync frame to the COMM frame
			need to check why the Tag Header flags show unsync = 1
#ce ;========================================================================================================

; #VARIABLES# ===================================================================================================================
Dim $sID3_TagFiles_Global = "" ;used to hold the filenames of Album Art jpg and/or the lyrics text file
Dim $bID3v1_RawTagData_Global = 0, $bID3v1Plus_RawTagData_Global = 0, $bID3v2_RawTagData_Global = 0, $bAPEv2_RawTagData_Global = 0
Dim $sID3v2_TagFrameIndex_Global = "", $sAPEv2_TagFrameIndex_Global = "", $iID3v2_OriginalTagSize_Global = 0
; ===============================================================================================================================


; #FUNCTION# ;===================================================================================================================
; Function Name....: _ID3ReadTag($Filename, $iVersion = 0)
; Description......: Reads ID3v1, ID3v2, and APEv2 binary data and stores them into global variables
; Parameter(s).....: $Filename     - Filename of mp3 file include full path
;					 $iTagVersion  - ID3 Version to read (Default: 0 => ID3v1 & ID3v2 & APEv2)
;										0 => Read ID3v1 & ID3v2 & APEv2 (Default)
;										1 => Read ID3v1 only
;										2 => Read ID3v2 only
;										3 => Read ID3v1 & ID3v2
;										4 => Read APEv2 only
; Requirement(s)...: This function must be used first in order to use other ID3.au3 functions.
; Return Value(s)..: On Success - Returns a string that denotes the tags and fields that exist in file.
;									@extended = (Can be a combination of the following:)
;											0 -> No Tags Found
;											1 -> ID3v1 Found
;											2 -> ID3v2 Found
;											4 -> APEv2 Found
;							   - Example Returned String,
;									"FilePath\Filename.mp3 @CRLF
;									 ID3v2.3.0|TIT2:1|TPE1:1|TALB:1|TRCK:1|TYER:1|COMM:2|APIC:1|... @CRLF
;									 ID3v1.1|Title|Artist|Album|Year|Comment|Track|Genre|... @CRLF
;									 APEv2|ARTIST|ALBUM|GENRE|..."
;										Note: for ID3v2 the number that follows the colon indicates the number of
;												Frames that were found with the same FrameIDs.
;                    On Failure - Returns 0 and @error = 1 for File not found
; Author ..........: joeyb1275
; Modified.........: 20120501 by joeyb1275
; ;==============================================================================================================================
Func _ID3ReadTag($Filename, $iTagVersion = 0)

	;Reset all global vairables
	;****************************************************************************************
	$sID3_TagFiles_Global = ""
	$bID3v1_RawTagData_Global = 0
	$bID3v1Plus_RawTagData_Global = 0
	$bID3v2_RawTagData_Global = 0
	$bAPEv2_RawTagData_Global = 0
	$sID3v2_TagFrameIndex_Global = ""
	$sAPEv2_TagFrameIndex_Global = ""
	$iID3v2_OriginalTagSize_Global = 0
	;****************************************************************************************

	;Setup the return string
	;****************************************************************************************
	Local $sID3_TagInfo_RetVal = $Filename & @CRLF, $iTagVersionsFound = 0
	$sID3v2_TagFrameIndex_Global = $Filename
	If Not (FileExists($Filename)) Then
		SetError(1)
		Return 0
	EndIf
	;****************************************************************************************

	;Read ID3 Data from file and store in $bID3v2_RawTagData_Global, $bID3v1_RawTagData_Global, $bAPEv2_RawTagData_Global
	;****************************************************************************************
	Switch $iTagVersion
		Case 0 ;ID3v1 & ID3v2 & APEv2

			Local $begin = TimerInit()
			$sID3_TagInfo_RetVal &= _ID3v2Tag_ReadFromFile($Filename)
			$iTagVersionsFound += @extended
			$TimeToReadTags = TimerDiff($begin)
			ConsoleWrite("Time To ID3v2ReadFile: " & Round($TimeToReadTags,2) & @CRLF)
			$begin = TimerInit()
			$sID3_TagInfo_RetVal &= _h_ID3v2Tag_EnumerateFrameIDs() ; takes most of the time
			$TimeToReadTags = TimerDiff($begin)
			ConsoleWrite("Time To ID3v2ReadFrames: " & Round($TimeToReadTags,2) & @CRLF)
			;MsgBox(0, "Time To ID3v2Tag", Round($TimeToReadTags,2))

			$sID3_TagInfo_RetVal &= _ID3v1Tag_ReadFromFile($Filename)
			$iTagVersionsFound += @extended
			$sID3_TagInfo_RetVal &= _APEv2Tag_ReadFromFile($Filename)
			$iTagVersionsFound += @extended
		Case 1 ;ID3v1 only
			$sID3_TagInfo_RetVal &= _ID3v1Tag_ReadFromFile($Filename)
			$iTagVersionsFound += @extended
		Case 2 ;ID3v2 only
			$sID3_TagInfo_RetVal &= _ID3v2Tag_ReadFromFile($Filename)
			$iTagVersionsFound += @extended
			$sID3_TagInfo_RetVal &= _h_ID3v2Tag_EnumerateFrameIDs()
		Case 3 ;ID3v1 & ID3v2
			$sID3_TagInfo_RetVal &= _ID3v2Tag_ReadFromFile($Filename)
			$iTagVersionsFound += @extended
			$sID3_TagInfo_RetVal &= _h_ID3v2Tag_EnumerateFrameIDs()
			$sID3_TagInfo_RetVal &= _ID3v1Tag_ReadFromFile($Filename)
			$iTagVersionsFound += @extended
		Case 4 ;APEv2 only
			$sID3_TagInfo_RetVal &= _APEv2Tag_ReadFromFile($Filename)
			$iTagVersionsFound += @extended
	EndSwitch
	;****************************************************************************************

	SetExtended($iTagVersionsFound)
	Return $sID3_TagInfo_RetVal

EndFunc   ;==>_ID3ReadTag


; #FUNCTION# ;===================================================================================================================
; Function Name:    _ID3GetTagField($sFrameIDRequest, $iFrameID_Index = 1)
; Description:      Returns a variant data type depending on $iReturnTypeFlag value that represents the ID3 Frame Data that cooresponds to the requested frame ID.
;						For ID3v2 FrameIDs that are not implimented within this UDF (ie. PRIV) use _ID3v2Frame_GetBinary() to get the raw frame data.
;						For APEv2 tag Strings use _APEv2_GetItemValueString()
; Parameter(s):     $sFrameIDRequest 	- ID3 FrameID String of the Field to return (ie. "TIT2" for ID3v2 Title or "Title" for ID3v1 Title)
;											Valid ID3v1 FrameIDs to Request,
;												Title | Artist | Album | Year | Comment | Track | Genre | Version1 | Speed | Start-Time | End-Time
;											Valid ID3v2 FrameIDs to Request - see specification for four character FrameIDs or list above
;					$iFrameID_Index		- Index number of ID3v2 FrameID, COMM, APIC and TXXX (and more) can exist multiple time in ID3v2 Tag
;					$iReturnTypeFlag	- Data type to return (Default: 0 )
;												0 => Returns simple text string that mostly describes the frame (Default)
;												1 => Returns Array of all items in ID3v2 frame
; Requirement(s):   Must call _ID3ReadTag() first.
; Return Value(s):  On Success - Returns a string.
;						@error = 0; @extended = Number of Frames that exist in the ID3v2 Tag with $sFieldIDRequest
;                   On Failure - Returns Empty String meaning $sFieldIDRequest did not match any IDs in the mp3 File
;						@error = 1; @extended = 0
; Author ........: joeyb1275
; Modified.......: 20120501 by joeyb1275
;============================================================================================
Func _ID3GetTagField($sFrameIDRequest, $iFrameID_Index = 1, $iReturnTypeFlag = 0)

	Local $vFrameString, $iNumFrames = 0, $iError = 0

	If StringInStr("|Title|Artist|Album|Year|Comment|Track|Genre|Version1|Speed|Start-Time|End-Time", $sFrameIDRequest, 1) Then
		$vFrameString = _ID3v1Field_GetString($sFrameIDRequest)
		$iError = @error
		$iNumFrames = 1
	Else
		$vFrameString = _ID3v2Frame_GetFields($sFrameIDRequest, $iFrameID_Index, $iReturnTypeFlag)
		$iNumFrames = @extended
		$iError = @error
	EndIf
	SetError($iError)
	SetExtended($iNumFrames)
	Return $vFrameString
EndFunc   ;==>_ID3GetTagField


; #FUNCTION# ;===================================================================================================================
; Function Name:    _ID3SetTagField()
; Description:      Sets a simple string to the requested Tag Frame/Field. Use _ID3WriteTag() to write updated tag to file.
;						For ID3v2 FrameIDs that are not implimented within this UDF (ie. PRIV) use _ID3v2Frame_SetBinary() to get the raw frame data.
;						APEv2 Tags not implimented yet.
; Parameter(s):     $sFieldIDRequest 	- ID3 Field ID String of the Field to return (ie. "TIT2" for ID3v2 Title or "Title" for ID3v1 Title)
;					$sFieldValue		- Simple text string (when $sFieldValue is set to "" a blank string frame will be removed from the ID3v2 Tag)
;					$iFrameID_Index		- Index number of ID3v2 FrameID, COMM, APIC and TXXX (and more) can exist multiple times in ID3v2 Tag
; Requirement(s):   Must call _ID3ReadTag() first or if $sFieldIDRequest does not exist it will be created and set to $sFieldValue.
;					Must call _ID3WriteTag() to save changes to the file.
; Return Value(s):  On Success - Returns 0.
;						@error = 0; @extended = 0
;                   On Failure - ???
;						@error = 1; @extended = 0
; Author ........: joeyb1275
; Modified.......: 20120501 by joeyb1275
;============================================================================================
Func _ID3SetTagField($sFrameIDRequest, $sFieldValue, $iFrameID_Index = 1)

	If StringInStr("|Title|Artist|Album|Year|Comment|Track|Genre|Version1|Speed|Start-Time|End-Time", $sFrameIDRequest, 1) Then
		_ID3v1Field_SetString($sFrameIDRequest, $sFieldValue)
		Return 0
	EndIf

	_ID3v2Frame_SetFields($sFrameIDRequest, $sFieldValue, $iFrameID_Index)
	Return 0
EndFunc   ;==>_ID3SetTagField



; #FUNCTION# ;===================================================================================================================
; Function Name:    _ID3WriteTag()
; Description:      Writes the ID3 Tag Data to the mp3 file
; Parameter(s):     $sFilename 			- Filename of mp3 file include full path
;					$iTagVersion		- Tag version to write (Default = -1, will try to determine what tag data exists and to write it)
; Requirement(s):   None
; Return Value(s):  On Success - Returns the versions that got written to the file ($iTagVersion), value of 0 means both ID3v1 and ID3v2.
;						@error = 0
;                   On Failure - Returns $iTagVersion
;						@error = 1
; Author ........: joeyb1275
; Modified.......: 20120609 by joeyb1275
;============================================================================================
Func _ID3WriteTag($sFilename, $iTagVersion = -1)

	;try to determine what tags have been read into memory
	If $iTagVersion = -1 Then
		Local $ID3v1_TagFound = False, $ID3v2_TagFound = False
		Local $ID3v1_ID = BinaryToString(BinaryMid($bID3v1_RawTagData_Global, 1, 3))
		If $ID3v1_ID == "TAG" Then
			$ID3v1_TagFound = True
			$iTagVersion = 1
		EndIf
		Local $sID3v2_TagID = BinaryToString(BinaryMid($bID3v2_RawTagData_Global, 1, 3))
		If $sID3v2_TagID == "ID3" Then
			$ID3v2_TagFound = True
			$iTagVersion = 2
		EndIf
		If $ID3v1_TagFound And $ID3v2_TagFound Then
			$iTagVersion = 0
		EndIf
	EndIf

	Switch $iTagVersion
		Case -1
			SetError(1)
		Case 0 ;Wite both ID3v1 and ID3v2 Tags
			_ID3v1Tag_WriteToFile($sFilename)
			_ID3v2Tag_WriteToFile($sFilename)
			SetError(0)
		Case 1 ;Wite ID3v1
			_ID3v1Tag_WriteToFile($sFilename)
			SetError(0)
		Case 2 ;Wite ID3v2
			_ID3v2Tag_WriteToFile($sFilename)
			SetError(0)
	EndSwitch

	Return $iTagVersion

EndFunc   ;==>_ID3WriteTag



; #FUNCTION# ;===================================================================================================================
; Function Name:    _ID3RemoveTag()
; Description:      Reads the ID3 Tag Data from an mp3 file and stores it in a Buffer and returns the Field Requested
; Parameter(s):     $sFilename 		- Filename of mp3 file including path
;					$iTagVersion  - ID3 Version to read (Default: 0 => ID3v1 & ID3v2 & APEv2)
;									   -1 => save only raw MPEG data to $sFilename (Removes any/all extra metadata/tags)
;										0 => Remove ID3v1 & ID3v2 & APEv2 (Default)
;										1 => Remove ID3v1 only
;										2 => Remove ID3v2 only
;										3 => Remove ID3v1 & ID3v2
;										4 => Remove APEv2 only
; Requirement(s):   None
; Return Value(s):  On Success - Returns Field String. If multiple fields found string is delimited with @CRLF.
;						@error = 0; @extended = Number of Frames that exist in the ID3v2 Tag with $sFieldIDRequest
;                   On Failure - Returns Empty String meaning $sFieldIDRequest did not match any IDs in the mp3 File
;						@error = 1; @extended = 0
; Author ........: joeyb1275
; Modified.......: 20120501 by joeyb1275
;================================================================================================================================
Func _ID3RemoveTag($sFilename, $iTagVersion=0)
	MsgBox(0,"$iTagVersion()",$iTagVersion)
	Switch $iTagVersion
		Case -1 ;save only raw MPEG data
			Local $Test = _MPEG_GetFrameHeader($sFilename)
			MsgBox(0,"_MPEG_GetFrameHeader()",$Test)
		Case 0 ;All Tags
			_ID3v1Tag_RemoveTag($sFilename)
			_ID3v2Tag_RemoveTag($sFilename)
			_APEv2_RemoveTag($sFilename)
		Case 1 ;ID3v1 only
			_ID3v1Tag_RemoveTag($sFilename)
		Case 2 ;ID3v2 only
			_ID3v2Tag_RemoveTag($sFilename)
		Case 3 ;ID3v1 and ID3v2 only
			_ID3v1Tag_RemoveTag($sFilename)
			_ID3v2Tag_RemoveTag($sFilename)
		Case 4 ;APEv2 only
			_APEv2_RemoveTag($sFilename)
	EndSwitch
EndFunc   ;==>_ID3RemoveTag



; #FUNCTION# ;===================================================================================================================
; Function Name:    _ID3CreateTag()
; Description:		Creates a new empty Tag (ID3v1 or ID3v2). Use _ID3WriteTag() to write new tag to file.
; Parameter(s):     $iTagVersion		- Filename of mp3 file include full path
; Requirement(s):   None
; Return Value(s):  On Success - Returns Field String. If multiple fields found string is delimited with @CRLF.
;						@error = 0; @extended = Number of Frames that exist in the ID3v2 Tag with $sFieldIDRequest
;                   On Failure - Returns Empty String meaning $sFieldIDRequest did not match any IDs in the mp3 File
;						@error = 1; @extended = 0
; Author ........: joeyb1275
; Modified.......: 20120501 by joeyb1275
;===============================================================================================================================
Func _ID3CreateTag($iTagVersion = 0, $iTagSubVersion = -1)
	Switch $iTagVersion
		Case 0 ;All Tags
			_ID3v1Tag_CreateTag()
			_ID3v2Tag_CreateTag(4)
			;TODO APEv2
		Case 1 ;ID3v1 only
			_ID3v1Tag_CreateTag()
		Case 2 ;ID3v2 only
			If $iTagSubVersion == -1 Then $iTagSubVersion = 4
			_ID3v2Tag_CreateTag($iTagSubVersion)
		Case 3 ;ID3v1 and ID3v2 only
			_ID3v1Tag_CreateTag()
			_ID3v2Tag_CreateTag(4)
		Case 4 ;APEv2 only
			;TODO
	EndSwitch
EndFunc   ;==>_ID3CreateTag



; #FUNCTION# ;===================================================================================================================
; Function Name:    _ID3DeleteFiles()
; Description:      Deletes any files created by ID3.au3 (ie. AlbumArt.jpeg and SongLyrics.txt)
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  On Success - Returns 1.
;                   On Failure - Returns 0
; Author ........: joeyb1275
; Modified.......: 20120501 by joeyb1275
;================================================================================================================================
Func _ID3DeleteFiles()

	If $sID3_TagFiles_Global == "" Then Return 1
	$aID3File = StringSplit($sID3_TagFiles_Global, "|")
	For $i = 1 To $aID3File[0]
		If FileExists($aID3File[$i]) Then
			$ret = FileDelete($aID3File[$i])
			If $ret = 0 Then Return 0
		EndIf
	Next
	$sID3_TagFiles_Global = ""

	Return 1

EndFunc   ;==>_ID3DeleteFiles







Func _ID3v1Tag_ReadFromFile($Filename)

	;TODO - SetExtended and SetError
	;Add reading of ID3v1 Extended Tag - http://en.wikipedia.org/wiki/ID3

	Local $sID3v1_TagInfo_RetVal = "", $ID3v1_TagFound = False, $ID3v1Plus_TagFound = False
	Local $hfile = FileOpen($Filename, 16) ;open in binary mode

	FileSetPos($hfile, -128, 2)
	$bID3v1_RawTagData_Global = FileRead($hfile)

	;ID3v1 Extended Tag Test Code
	FileSetPos($hfile, -(128 + 227), 2) ;include 227 bytes to check for Extended tag Header
	$bID3v1Plus_RawTagData_Global = FileRead($hfile, 227)
	FileClose($hfile)


	$ID3v1PlusID = BinaryToString(BinaryMid($bID3v1Plus_RawTagData_Global, 1, 4))
	If $ID3v1PlusID == "TAG+" Then
		$ID3v1Plus_TagFound = True
;~ 		MsgBox(0,"$ID3v1PlusID",$ID3v1PlusID)
	Else
		$bID3v1Plus_RawTagData_Global = Binary(0)
	EndIf


	Local $ID3v1_ID = BinaryToString(BinaryMid($bID3v1_RawTagData_Global, 1, 3))
	;MsgBox(0,"ID3v1 Tag ID",$ID3v1ID)
	If $ID3v1_ID == "TAG" Then
		$ID3v1_TagFound = True
	EndIf

	If $ID3v1_TagFound And Not $ID3v1Plus_TagFound Then
		$Version = _ID3v1Tag_GetVersion()
		$sID3v1_TagInfo_RetVal = "ID3v1." & $Version
		If $Version == "0" Then
			$sID3v1_TagInfo_RetVal &= "|Title|Artist|Album|Year|Comment|Genre|Version1" & @CRLF
		Else
			$sID3v1_TagInfo_RetVal &= "|Title|Artist|Album|Year|Comment|Track|Genre|Version1" & @CRLF
		EndIf
	ElseIf $ID3v1_TagFound And $ID3v1Plus_TagFound Then
		$Version = _ID3v1Tag_GetVersion()
		$sID3v1_TagInfo_RetVal = "ID3v1." & $Version & "+"
		If $Version == "0" Then
			$sID3v1_TagInfo_RetVal &= "|Title|Artist|Album|Year|Comment|Genre|Version1|Speed|Start-Time|End-Time" & @CRLF
		Else
			$sID3v1_TagInfo_RetVal &= "|Title|Artist|Album|Year|Comment|Track|Genre|Version1|Speed|Start-Time|End-Time" & @CRLF
		EndIf
	Else
		$bID3v1_RawTagData_Global = Binary(0)
	EndIf

	If $ID3v1_TagFound Then
		SetExtended(1)
	EndIf
	Return $sID3v1_TagInfo_RetVal

EndFunc   ;==>_ID3v1Tag_ReadFromFile
Func _ID3v1Tag_GetVersion()
	Local $Track = Dec(StringTrimLeft(BinaryMid($bID3v1_RawTagData_Global, 126, 2), 2))
	If $Track = 0 Then
		Return "0"
	Else
		Return "1"
	EndIf
EndFunc   ;==>_ID3v1Tag_GetVersion
Func _ID3v1Field_GetString($FieldName)
;~ ID3v1: 128 bytes
;~ Field		Length		Description
;~ header		3			"TAG"
;~ title		30			30 characters of the title
;~ artist		30			30 characters of the artist name
;~ album		30			30 characters of the album name
;~ year			4			A four-digit year
;~ comment		28 or 30	The comment.
;~ zero-byte	1			If a track number is stored, this byte contains a binary 0.
;~ track		1			The number of the track on the album, or 0. Invalid, if previous byte is not a binary 0.
;~ genre		1			Index in a list of genres, or 255


;~ Extended tag (placed before the ID3v1 tag): 227 bytes
;~ Field		Length	Description
;~ header		4		"TAG+"
;~ title		60		Next 60 characters of the title (90 characters total)
;~ artist		60		Next 60 characters of the artist name
;~ album		60		Next 60 characters of the album name
;~ speed		1		0=unset, 1=slow, 2= medium, 3=fast, 4=hardcore
;~ genre		30		A free-text field for the genre
;~ start-time	6		the start of the music as mmm:ss
;~ end-time		6		the end of the music as mmm:ss


	Local $FieldString = "", $ID3v1Plus_TagFound = False
	If BinaryLen($bID3v1_RawTagData_Global) <= 4 Then ;Tag does not exist
		Return $FieldString
	EndIf
	If BinaryLen($bID3v1Plus_RawTagData_Global) > 4 Then
		$ID3v1Plus_TagFound = True
	EndIf

	Switch $FieldName
		Case "Title"
			$FieldString = BinaryToString(BinaryMid($bID3v1_RawTagData_Global, 4, 30))
			If $ID3v1Plus_TagFound Then
				$FieldString &= BinaryToString(BinaryMid($bID3v1Plus_RawTagData_Global, 4, 60))
			EndIf
		Case "Artist"
			$FieldString = BinaryToString(BinaryMid($bID3v1_RawTagData_Global, 34, 30))
			If $ID3v1Plus_TagFound Then
				$FieldString &= BinaryToString(BinaryMid($bID3v1Plus_RawTagData_Global, 64, 60))
			EndIf
		Case "Album"
			$FieldString = BinaryToString(BinaryMid($bID3v1_RawTagData_Global, 64, 30))
			If $ID3v1Plus_TagFound Then
				$FieldString &= BinaryToString(BinaryMid($bID3v1Plus_RawTagData_Global, 124, 60))
			EndIf
		Case "Year"
			$FieldString = BinaryToString(BinaryMid($bID3v1_RawTagData_Global, 94, 4))
		Case "Comment"
			Local $Track = Dec(Hex(BinaryMid($bID3v1_RawTagData_Global, 126, 2)))
			If $Track < 1000 And $Track > 0 Then
				$FieldString = BinaryToString(BinaryMid($bID3v1_RawTagData_Global, 98, 28))
			Else
				$FieldString = BinaryToString(BinaryMid($bID3v1_RawTagData_Global, 98, 30))
			EndIf
		Case "Track"
			Local $Track = Dec(Hex(BinaryMid($bID3v1_RawTagData_Global, 126, 2)))
			If $Track < 1000 And $Track > 0 Then
				$FieldString = $Track
			Else
				$FieldString = ""
			EndIf
		Case "Genre"
			Local $GenreID = Dec(Hex(BinaryMid($bID3v1_RawTagData_Global, 128, 1)))
			$FieldString = _h_ID3v1_GetGenreFromID($GenreID)
			If $ID3v1Plus_TagFound Then
				$FieldString = BinaryToString(BinaryMid($bID3v1Plus_RawTagData_Global, 185, 30))
			EndIf
		Case "Version1"
			Local $Track = Dec(Hex(BinaryMid($bID3v1_RawTagData_Global, 126, 2)))
			If $Track = 0 Then
				$FieldString = "ID3v1.0"
			Else
				$FieldString = "ID3v1.1"
			EndIf
		Case "Speed" ;TAG+
			;0=unset, 1=slow, 2= medium, 3=fast, 4=hardcore
			If $ID3v1Plus_TagFound Then
				Switch BinaryMid($bID3v1Plus_RawTagData_Global, 184, 1)
					Case 0
						$FieldString = "unset"
					Case 1
						$FieldString = "slow"
					Case 2
						$FieldString = "medium"
					Case 3
						$FieldString = "fast"
					Case 4
						$FieldString = "hardcore"
					Case Else
						$FieldString = BinaryToString(BinaryMid($bID3v1Plus_RawTagData_Global, 184, 1))
				EndSwitch
			EndIf
		Case "Start-Time" ;TAG+
			If $ID3v1Plus_TagFound Then
				$FieldString = BinaryToString(BinaryMid($bID3v1Plus_RawTagData_Global, 215, 6))
			EndIf
		Case "End-Time" ;TAG+
			If $ID3v1Plus_TagFound Then
				$FieldString = BinaryToString(BinaryMid($bID3v1Plus_RawTagData_Global, 221, 6))
			EndIf
	EndSwitch

	Return $FieldString
EndFunc   ;==>_ID3v1Field_GetString
Func _ID3v1Field_SetString($sFieldName, $sFieldString, $iPaddingType = -1)
	;TODO  Add Comments
	;$iPaddingType = -1 -> uses existing padding type
	;$iPaddingType = 0 -> uses 0x00 to pad
	;$iPaddingType = 1 -> uses spaces to pad 0x20

	Local $bID3v1_RawDataBinary_Temp, $bPad


	;Create tag if it does not exist
	Local $ID3v1_ID = BinaryToString(BinaryMid($bID3v1_RawTagData_Global, 1, 3))
	If StringCompare($ID3v1_ID, "TAG") <> 0 Then
		_ID3v1Tag_CreateTag()
	EndIf



	Switch $iPaddingType
		Case 0
			$bPad = Binary("0x00")
			$sFieldString = StringStripWS($sFieldString, 2)
		Case 1
			$bPad = Binary("0x20")
		Case Else ;includes -1
			If StringCompare(StringRight($sFieldString, 1), " ") Then
				$bPad = Binary("0x20")
			Else
				$bPad = Binary("0x00")
			EndIf
	EndSwitch



	Switch $sFieldName
		Case "Title"
			$sFieldString = StringLeft($sFieldString, 30)
			$bID3v1_RawDataBinary_Temp = BinaryMid($bID3v1_RawTagData_Global, 1, 3) & Binary($sFieldString)
			For $iPAD = 1 To (30 - BinaryLen($sFieldString))
				$bID3v1_RawDataBinary_Temp &= $bPad
			Next
			$bID3v1_RawDataBinary_Temp &= BinaryMid($bID3v1_RawTagData_Global, 34)
			$bID3v1_RawTagData_Global = $bID3v1_RawDataBinary_Temp
		Case "Artist"
			$sFieldString = StringLeft($sFieldString, 30)
			$bID3v1_RawDataBinary_Temp = BinaryMid($bID3v1_RawTagData_Global, 1, 33) & Binary($sFieldString)
			For $iPAD = 1 To (30 - BinaryLen($sFieldString))
				$bID3v1_RawDataBinary_Temp &= $bPad
			Next
			$bID3v1_RawDataBinary_Temp &= BinaryMid($bID3v1_RawTagData_Global, 64)
			$bID3v1_RawTagData_Global = $bID3v1_RawDataBinary_Temp
		Case "Album"
			$sFieldString = StringLeft($sFieldString, 30)
			$bID3v1_RawDataBinary_Temp = BinaryMid($bID3v1_RawTagData_Global, 1, 63) & Binary($sFieldString)
			For $iPAD = 1 To (30 - BinaryLen($sFieldString))
				$bID3v1_RawDataBinary_Temp &= $bPad
			Next
			$bID3v1_RawDataBinary_Temp &= BinaryMid($bID3v1_RawTagData_Global, 94)
			$bID3v1_RawTagData_Global = $bID3v1_RawDataBinary_Temp
		Case "Year"
			$sFieldString = StringLeft($sFieldString, 4)
			$bID3v1_RawDataBinary_Temp = BinaryMid($bID3v1_RawTagData_Global, 1, 93) & Binary($sFieldString)
			For $iPAD = 1 To (4 - BinaryLen($sFieldString))
				$bID3v1_RawDataBinary_Temp &= $bPad
			Next
			$bID3v1_RawDataBinary_Temp &= BinaryMid($bID3v1_RawTagData_Global, 98)
			$bID3v1_RawTagData_Global = $bID3v1_RawDataBinary_Temp
		Case "Comment"
			$sFieldString = StringLeft($sFieldString, 28)
			$bID3v1_RawDataBinary_Temp = BinaryMid($bID3v1_RawTagData_Global, 1, 97) & Binary($sFieldString)
			For $iPAD = 1 To (28 - BinaryLen($sFieldString))
				$bID3v1_RawDataBinary_Temp &= $bPad
			Next
			$bID3v1_RawDataBinary_Temp &= BinaryMid($bID3v1_RawTagData_Global, 126)
			$bID3v1_RawTagData_Global = $bID3v1_RawDataBinary_Temp

		Case "Track"
			$sFieldString = Binary("0x" & Hex(Number($sFieldString), 4))
			$bID3v1_RawDataBinary_Temp = BinaryMid($bID3v1_RawTagData_Global, 1, 125) & $sFieldString
			For $iPAD = 1 To (2 - BinaryLen($sFieldString))
				$bID3v1_RawDataBinary_Temp &= $bPad
			Next
			$bID3v1_RawDataBinary_Temp &= BinaryMid($bID3v1_RawTagData_Global, 128)
			$bID3v1_RawTagData_Global = $bID3v1_RawDataBinary_Temp
		Case "Genre"
			Local $GenreID = _h_ID3v1_GetGenreID($sFieldString)
			$GenreID = Binary("0x" & Hex($GenreID, 2))
			$bID3v1_RawTagData_Global = BinaryMid($bID3v1_RawTagData_Global, 1, 127) & $GenreID
	EndSwitch
EndFunc   ;==>_ID3v1Field_SetString
Func _ID3v1Tag_WriteToFile($sFilename)

	Local $bID3v1TagToWrite = $bID3v1_RawTagData_Global, $iFileSetPos = 0

	;Check if tag exists
	If _ID3v1Tag_ReadFromFile($sFilename) <> "" Then
		$iFileSetPos = 128
	EndIf

	;Write MP3 Data
	$hfile = FileOpen($sFilename, 16 + 1) ;Open for write force binary
	$Test = FileSetPos($hfile, $iFileSetPos, 2) ;Go to End of File (-128 if tag exists)
	FileWrite($hfile, $bID3v1TagToWrite) ;Write new tag
	FileClose($hfile)

	$bID3v1_RawTagData_Global = $bID3v1TagToWrite

EndFunc   ;==>_ID3v1Tag_WriteToFile
Func _ID3v1Tag_RemoveTag($sFilename)

	Local $bFileData, $hOldFile, $hNewFile

	If _ID3v1Tag_ReadFromFile($sFilename) <> "" Then
		$bID3v1_RawTagData_Global = Binary("0x00")
		$hOldFile = FileOpen($sFilename, 16) ;Open for read force binary
		$bFileData = FileRead($hOldFile) ;Read all file data
		FileClose($hOldFile)
		$bFileData = BinaryMid($bFileData, 1, BinaryLen($bFileData) - 128) ;Remove ID3v1 Tag
		$hNewFile = FileOpen($sFilename, 2 + 8 + 16) ;Open File and Erase all
		FileWrite($hNewFile, $bFileData) ;Write all Data less ID3v1 Tag
		FileClose($hNewFile)
	EndIf

EndFunc   ;==>_ID3v1Tag_RemoveTag
Func _ID3v1Tag_CreateTag()
	;Creates an empty ID3v1 Tag
	$bID3v1_RawTagData_Global = Binary("TAG")
	For $i = 1 To 125
		$bID3v1_RawTagData_Global &= Binary("0x00")
	Next
EndFunc   ;==>_ID3v1Tag_CreateTag

Func _h_ID3v1_GetGenreFromID($iID)
	;Author: YDY (Lazycat)  Thank you for writing all this out
	Local $asGenre = StringSplit("Blues,Classic Rock,Country,Dance,Disco,Funk,Grunge,Hip-Hop," & _
			"Jazz,Metal,New Age, Oldies,Other,Pop,R&B,Rap,Reggae,Rock,Techno,Industrial,Alternative," & _
			"Ska,Death Metal,Pranks,Soundtrack,Euro-Techno,Ambient,Trip-Hop,Vocal,Jazz+Funk,Fusion," & _
			"Trance,Classical,Instrumental,Acid,House,Game,Sound Clip,Gospel,Noise,Alternative Rock," & _
			"Bass,Soul,Punk,Space,Meditative,Instrumental Pop,Instrumental Rock,Ethnic,Gothic,Darkwave," & _
			"Techno-Industrial,Electronic,Pop-Folk,Eurodance,Dream,Southern Rock,Comedy,Cult,Gangsta," & _
			"Top 40,Christian Rap,Pop/Funk,Jungle,Native US,Cabaret,New Wave,Psychadelic,Rave,Showtunes," & _
			"Trailer,Lo-Fi,Tribal,Acid Punk,Acid Jazz,Polka,Retro,Musical,Rock & Roll,Hard Rock,Folk," & _
			"Folk-Rock,National Folk,Swing,Fast Fusion,Bebob,Latin,Revival,Celtic,Bluegrass,Avantgarde," & _
			"Gothic Rock,Progressive Rock,Psychedelic Rock,Symphonic Rock,Slow Rock,Big Band,Chorus," & _
			"Easy Listening,Acoustic,Humour,Speech,Chanson,Opera,Chamber Music,Sonata,Symphony,Booty Bass," & _
			"Primus,Porn Groove,Satire,Slow Jam,Club,Tango,Samba,Folklore,Ballad,Power Ballad,Rhytmic Soul," & _
			"Freestyle,Duet,Punk Rock,Drum Solo,Acapella,Euro-House,Dance Hall,Goa,Drum & Bass,Club-House," & _
			"Hardcore,Terror,Indie,BritPop,Negerpunk,Polsk Punk,Beat,Christian Gangsta,Heavy Metal,Black Metal," & _
			"Crossover,Contemporary C,Christian Rock,Merengue,Salsa,Thrash Metal,Anime,JPop,SynthPop", ",")
	If ($iID >= 0) And ($iID < 148) Then Return $asGenre[$iID + 1]
	Return ("")
EndFunc   ;==>_h_ID3v1_GetGenreFromID
Func _h_ID3v1_GetGenreID($sGrenre)
	Local $asGenre = StringSplit("Blues,Classic Rock,Country,Dance,Disco,Funk,Grunge,Hip-Hop," & _
			"Jazz,Metal,New Age, Oldies,Other,Pop,R&B,Rap,Reggae,Rock,Techno,Industrial,Alternative," & _
			"Ska,Death Metal,Pranks,Soundtrack,Euro-Techno,Ambient,Trip-Hop,Vocal,Jazz+Funk,Fusion," & _
			"Trance,Classical,Instrumental,Acid,House,Game,Sound Clip,Gospel,Noise,Alternative Rock," & _
			"Bass,Soul,Punk,Space,Meditative,Instrumental Pop,Instrumental Rock,Ethnic,Gothic,Darkwave," & _
			"Techno-Industrial,Electronic,Pop-Folk,Eurodance,Dream,Southern Rock,Comedy,Cult,Gangsta," & _
			"Top 40,Christian Rap,Pop/Funk,Jungle,Native US,Cabaret,New Wave,Psychadelic,Rave,Showtunes," & _
			"Trailer,Lo-Fi,Tribal,Acid Punk,Acid Jazz,Polka,Retro,Musical,Rock & Roll,Hard Rock,Folk," & _
			"Folk-Rock,National Folk,Swing,Fast Fusion,Bebob,Latin,Revival,Celtic,Bluegrass,Avantgarde," & _
			"Gothic Rock,Progressive Rock,Psychedelic Rock,Symphonic Rock,Slow Rock,Big Band,Chorus," & _
			"Easy Listening,Acoustic,Humour,Speech,Chanson,Opera,Chamber Music,Sonata,Symphony,Booty Bass," & _
			"Primus,Porn Groove,Satire,Slow Jam,Club,Tango,Samba,Folklore,Ballad,Power Ballad,Rhytmic Soul," & _
			"Freestyle,Duet,Punk Rock,Drum Solo,Acapella,Euro-House,Dance Hall,Goa,Drum & Bass,Club-House," & _
			"Hardcore,Terror,Indie,BritPop,Negerpunk,Polsk Punk,Beat,Christian Gangsta,Heavy Metal,Black Metal," & _
			"Crossover,Contemporary C,Christian Rock,Merengue,Salsa,Thrash Metal,Anime,JPop,SynthPop", ",")

	For $i = 1 To $asGenre[0]
		If $sGrenre == $asGenre[$i] Then
			Return $i - 1
		EndIf
	Next

	Return 12 ;Other


EndFunc   ;==>_h_ID3v1_GetGenreID





Func _ID3v2Tag_ReadFromFile($sFilename)
   ;This function will open the file for reading and close it
   ;all reads should be performed here
	Local $bID3v2_TagData, $sID3v2_TagInfo_RetVal = ""

	Local $hID3v2_File = FileOpen($sFilename, 16) ;mode = Force binary

	$sID3v2_TagFrameIndex_Global = ""
	If Not (FileExists($sFilename)) Then
		SetError(1)
		Return $sID3v2_TagInfo_RetVal
	EndIf

    ;Read in first 10 bytes
	$bID3v2_RawTagData_Global = FileRead($hID3v2_File, 10)


	Local $sID3v2_TagID = BinaryToString(BinaryMid($bID3v2_RawTagData_Global, 1, 3))
	If Not ($sID3v2_TagID == "ID3") Then ;To do a case sensitive not equal comparison use Not ("string1" == "string2")
		FileClose($hID3v2_File)
		SetError(1)
		Return $sID3v2_TagInfo_RetVal
	EndIf


	If $bID3v2_RawTagData_Global = -1 Then ;ID3v2 Tag was not found
		FileClose($hID3v2_File)
		SetError(1)
		Return $sID3v2_TagInfo_RetVal
	EndIf

	Local $iID3v2_TagSize = _ID3v2Tag_GetTagSize()
	;MsgBox(0,"$iID3v2_TagSize",$iID3v2_TagSize)

	;Save the Original Size if tag is updated
	$iID3v2_OriginalTagSize_Global = $iID3v2_TagSize

	;Read in Rest of ID3v2 Tag Data
	$bID3v2_RawTagData_Global &= Binary(FileRead($hID3v2_File, $iID3v2_TagSize))

	FileClose($hID3v2_File)

	$sID3v2_TagInfo_RetVal = "ID3v2." & _ID3v2Tag_GetVersion()

	SetError(0)
	SetExtended(2)
	Return $sID3v2_TagInfo_RetVal

EndFunc   ;==>_ID3v2Tag_ReadFromFile
Func _h_ID3v2Tag_EnumerateFrameIDs()
   ;This function can be fast if the frames line-up with the reading of bytes
   ;Some error checking is built in but can slow down the reading of the frameIDs
   ;This function gets a list of all frame IDs -> TXXX:2
   ;This function sets $sID3v2_TagFrameIndex_Global

	Local $bFrameHeader, $iTagVersion = 3, $iFrameSize, $sFrameID = "", $iZPAD = 0, $sID3v2_FrameIDList_RetVal = ""
	Local $iReadBytesOffset = 10, $iFrameHeaderLen
	Local $iTagSize = _ID3v2Tag_GetTagSize()
	$sID3v2_TagFrameIndex_Global = ""

	If _ID3v2Tag_GetHeaderFlags("ExtendedHeader") <> 0 Then
		;ID3v2_TagSize include this ExtendedHeader
		$iReadBytesOffset += 10
	EndIf

   ;$iBytesRead is used to step through Tag data and is used to terminate loop
   Local $iBytesRead = $iReadBytesOffset

	;MsgBox(0,"Version",_ID3v2Tag_GetVersion())

   ;Set the header length depending on Tag Version
   ;****************************************************************************************
	Local $iTagVersion = Number(StringLeft(_ID3v2Tag_GetVersion(), 1))
	If $iTagVersion = 2 Then
		$iFrameHeaderLen = 6
	Else
		$iFrameHeaderLen = 10
	EndIf
   ;****************************************************************************************

	;Scan Tag for all Fields - takes most of the time!!!
	;Some have found errors in reading the tag size and this while loop will hang if thats wrong
	;need to clean this part of code up - use something other than while loop?
;~ 	Local $WhileLoopbegin = TimerInit()
   $iID3v2_RawTagDataLen = BinaryLen($bID3v2_RawTagData_Global)
   While ($iBytesRead < $iTagSize)
	  ;check if all the binary data has been scanned
	  If ($iBytesRead >= $iID3v2_RawTagDataLen) Then
		 ExitLoop
	  EndIf

	  ;First field should start right after 10 byte header
	  $bFrameHeader = BinaryMid($bID3v2_RawTagData_Global, $iBytesRead + 1, $iFrameHeaderLen)
	  $iBytesRead += $iFrameHeaderLen
	  $sFrameID = _h_ID3v2FrameHeader_GetFrameID($bFrameHeader)

	  ;Show that a Footer was found (I have not seen these in any tags yet)
	  If StringLeft($sFrameID, 3) == "3DI" Then
		 ConsoleWrite($sFrameID & ": Footer Found!!")
	  EndIf

	  ;Check for a valid frameID string
	  ;****************************************************************************************
	  If $sFrameID <> -1 Then
		 ;if frameID is good get FrameSize
		 $iFrameSize = _h_ID3v2FrameHeader_GetFrameSize($bFrameHeader)

	  Else
		 ;check for padding
		 If Dec(Hex(BinaryMid($bFrameHeader, 1, 2), 4)) = 0 Then
			$iZPAD = ($iTagSize + 10) - ($iBytesRead - $iFrameHeaderLen)
			$sID3v2_TagFrameIndex_Global &= "ZPAD" & "|" & String($iBytesRead - $iFrameHeaderLen + 1) & "|" & $iZPAD & @CRLF
			ExitLoop
		 Else
			;Need to error check and byte scan (This will slow down the frame enumeration)
			;****************************************************************************************
			;This could be ZPAD with first byte wrong (need exit loop if ZPAD is found during scan
			$iBytesRead -= Round(($iFrameSize / 8 + 2)) ;go back before starting the byte scan
			ConsoleWrite("Unexpected data found...")
			ConsoleWrite("Scanning bytes to correct...")
			For $itest = 1 To ($iBytesRead + $iFrameSize + 20)
			   $bFrameHeader = BinaryMid($bID3v2_RawTagData_Global, $iBytesRead + 1 + $itest, $iFrameHeaderLen)
			   $sFrameID = _h_ID3v2FrameHeader_GetFrameID($bFrameHeader)
			   If $sFrameID <> -1 Then
				  $iBytesRead += $itest
				  $iFrameSize = _h_ID3v2FrameHeader_GetFrameSize($bFrameHeader)
				  ConsoleWrite("Valid FrameID found during byte scan" & " => " & $FrameID & " at " & String($iBytesRead + 1 + $itest) & " bytes")
				  ExitLoop 1
			   EndIf
			Next
			;****************************************************************************************
		 EndIf
   EndIf
   ;****************************************************************************************

	  ;set line to the tag frame index string (used later if need to get frame data)
	  $sID3v2_TagFrameIndex_Global &= $sFrameID & "|" & String($iBytesRead + 1) & "|" & String($iFrameSize) & @CRLF

	  ;go to next frame
	  $iBytesRead += $iFrameSize

	  ;set return value $sID3v2_FrameIDList_RetVal for a simple return list of what is found
	  $sFrameIndex = StringInStr($sID3v2_FrameIDList_RetVal, $sFrameID)
	  If $sFrameIndex = 0 Then
		 $sID3v2_FrameIDList_RetVal &= "|" & $sFrameID & ":" & "1"
	  Else
		 $sFrameIndexEnd = StringInStr(StringMid($sID3v2_FrameIDList_RetVal, $sFrameIndex), ":")
		 $iNumFrameID = 1 + Number(StringMid($sID3v2_FrameIDList_RetVal, $sFrameIndex + $sFrameIndexEnd, 1))
		 $sNewFrameIDString = $sFrameID & ":" & $iNumFrameID
		 $sID3v2_FrameIDList_RetVal = StringReplace($sID3v2_FrameIDList_RetVal, $sFrameID & ":" & $iNumFrameID - 1, $sNewFrameIDString)
	  EndIf

   WEnd

;~    $WhileLoopTimeToReadTags = TimerDiff($WhileLoopbegin)
;~    MsgBox(0,"$SlowTimeToReadTags",Round($WhileLoopTimeToReadTags,2) & " ms")

   Return $sID3v2_FrameIDList_RetVal & @CRLF

EndFunc   ;==>_h_ID3v2Tag_EnumerateFrameIDs
Func _h_ID3v2Tag_RemoveUnsynchronisation()
	;The only purpose of the 'unsynchronisation scheme' is to make the ID3v2 tag as compatible
	;as possible with existing software. There is no use in 'unsynchronising' tags if the file
	;is only to be processed by new software. Unsynchronisation may only be made with MPEG 2
	;layer I, II and III and MPEG 2.5 files. Whenever a false synchronisation is found within
	;the tag, one zeroed byte is inserted after the first false synchronisation byte. The format
	;of a correct sync that should be altered by ID3 encoders is as follows:
	;		%11111111 111xxxxx
	;And should be replaced with:
	;		%11111111 00000000 111xxxxx
	;This has the side effect that all $FF 00 combinations have to be altered, so they won't be
	;affected by the decoding process. Therefore all the $FF 00 combinations have to be replaced
	;with the $FF 00 00 combination during the unsynchronisation.  To indicate usage of the
	;unsynchronisation, the first bit in 'ID3 flags' should be set. This bit should only be set if
	;the tag contains a, now corrected, false synchronisation. The bit should only be clear if the
	;tag does not contain any false synchronisations.

;~    I think the file I am testing with only has the COMM frame with unsync bytes
; looking at the spec again I found that the frame header flags also indicate unsync

	;Find all %11111111 00000000 111xxxxx = 0xFF 0x00 0xE0 and 0xFF 0x00 0x00
	Local $bID3v2_RawTagData_Global_Temp = BinaryMid($bID3v2_RawTagData_Global, 1, 5)
	Local $bCurrentTagFlags = BinaryMid($bID3v2_RawTagData_Global, 6, 1)
	$bID3v2_RawTagData_Global_Temp &= Binary("0x" & Hex(BitAND(127, Dec(Hex($bCurrentTagFlags, 2))), 2)) ;Clear unsynchronisation flag in Tag header
	Local $aIndex[1]
	$aIndex[0] = 0
	For $ibyte = 7 To BinaryLen($bID3v2_RawTagData_Global) - 1
;~ 		If BinaryMid($bID3v2_RawTagData_Global, $ibyte, 1) = Binary("0xFF") Then
;~ 			If BinaryMid($bID3v2_RawTagData_Global, $ibyte + 1, 1) = Binary("0x00") Then
;~ 				_ArrayAdd($aIndex, $ibyte)
;~ 				$aIndex[0] += 1
;~ 			EndIf
;~ 		EndIf

		 ;if 0x00 is found check bytes before and after
		If BinaryMid($bID3v2_RawTagData_Global, $ibyte, 1) = Binary("0x00") Then
			;then check the prev. byte for an FF
			If BinaryMid($bID3v2_RawTagData_Global, $ibyte-1, 1) == Binary("0xFF") Then
			   ;then check the next byte for > E0
			   If BinaryMid($bID3v2_RawTagData_Global, $ibyte+1, 1) < Binary("0xE0") Then
				  $bID3v2_RawTagData_Global_Temp &= BinaryMid($bID3v2_RawTagData_Global, $ibyte, 1)
			   Else
				  _ArrayAdd($aIndex,$ibyte)
			   EndIf
			Else
			   $bID3v2_RawTagData_Global_Temp &= BinaryMid($bID3v2_RawTagData_Global, $ibyte, 1)
			EndIf
		Else
			$bID3v2_RawTagData_Global_Temp &= BinaryMid($bID3v2_RawTagData_Global, $ibyte, 1)
		EndIf



	Next


;when i ignore unsync the APIC frame and ZPAD look OK but bad picture data
;When I allow the unsync of the bytes things get messed up after the COMM frame
	$bID3v2_RawTagData_Global = $bID3v2_RawTagData_Global_Temp

	_ArrayDisplay($aIndex)

;~ 	Local $bID3v2_RawTagData_Global_Temp = BinaryMid($bID3v2_RawTagData_Global, 1, 5)
;~ 	Local $bCurrentTagFlags = BinaryMid($bID3v2_RawTagData_Global, 6, 1)
;~ 	$bID3v2_RawTagData_Global_Temp &= Binary("0x" & Hex(BitAND(127, Dec(Hex($bCurrentTagFlags, 2))), 2)) ;Clear unsynchronisation flag in Tag header
;~
;~ 	$bID3v2_RawTagData_Global_Temp &= BinaryMid($bID3v2_RawTagData_Global, 7, $aIndex[1])
;~ 	Local $Start, $Length = $aIndex[1]
;~ 	For $ibyte = 1 To $aIndex[0] - 1
;~ 		$bID3v2_RawTagData_Global_Temp &= BinaryMid($bID3v2_RawTagData_Global, $aIndex[$ibyte] + 2, $aIndex[$ibyte + 1] - $aIndex[$ibyte] - 1)
;~ 	Next
;~ 	$bID3v2_RawTagData_Global_Temp &= BinaryMid($bID3v2_RawTagData_Global, $aIndex[$aIndex[0]] + 2)



EndFunc   ;==>_h_ID3v2Tag_RemoveUnsynchronisation
Func _ID3v2Tag_WriteToFile($sFilename)

	Local $hNewFile, $hfile
	Local $bNewFileData = $bID3v2_RawTagData_Global
	Local $bNewID3v2_RawDataBinary = $bID3v2_RawTagData_Global

	;Check if tag does not exist
	Local $sID3v2_TagID = BinaryToString(BinaryMid($bID3v2_RawTagData_Global, 1, 3))
	If (StringCompare($sID3v2_TagID, "ID3") <> 0) Then
		_ID3v2Tag_CreateTag(4)
	EndIf

	;Write MP3 Data
	;****************************************************************************************
	$hfile = FileOpen($sFilename, 16) ;Read mode force binary
	FileSetPos($hfile, $iID3v2_OriginalTagSize_Global, 0) ;Skip old tag data
	$bNewFileData &= FileRead($hfile) ;Read all file data after old tag
	FileClose($hfile)
	$hNewFile = FileOpen($sFilename, 2 + 8 + 16) ;Open File and Erase all
	FileWrite($hNewFile, $bNewFileData) ;Write New Tag Data and rest of old file data
	FileClose($hNewFile)
	;****************************************************************************************

	$bID3v2_RawTagData_Global = $bNewID3v2_RawDataBinary
EndFunc   ;==>_ID3v2Tag_WriteToFile
Func _ID3v2Tag_RemoveTag($sFilename)

	Local $bFileData, $hfile, $hNewFile
	If _ID3v2Tag_ReadFromFile($sFilename) <> -1 Then
		$hfile = FileOpen($sFilename, 16) ;Read mode force binary
		FileSetPos($hfile, _ID3v2Tag_GetTagSize(), 0) ;Skip old tag data
		$bFileData = FileRead($hfile) ;Read all file data after tag
		FileClose($hfile)
		$hNewFile = FileOpen($sFilename, 2 + 8 + 16) ;Open File and Erase all
		FileWrite($hNewFile, $bFileData) ;Write rest of file
		FileClose($hNewFile)
	EndIf

EndFunc   ;==>_ID3v2Tag_RemoveTag
Func _ID3v2Tag_CreateTag($iVersion)
	;Creates an empty ID3v2 Tag
	;ID3v2/file identifier 		"ID3"
	;ID3v2 version 				$03 00
	;ID3v2 flags 				%abc00000
	;ID3v2 size 			4 * %0xxxxxxx

	;ID3v2/file identifier
	$bID3v2_RawTagData_Global = Binary("ID3")

	;ID3v2 version
	Switch $iVersion
		Case 2
			$bID3v2_RawTagData_Global &= Binary("0x02")
		Case 3
			$bID3v2_RawTagData_Global &= Binary("0x03")
		Case 4
			$bID3v2_RawTagData_Global &= Binary("0x04")
	EndSwitch
	$bID3v2_RawTagData_Global &= Binary("0x00")

	;ID3v2 Flags set to zero
	$bID3v2_RawTagData_Global &= Binary("0x00")

	;ID3v2 Size (Tag Bytes - 10) not including tag header - SyncSafe integer
	$bID3v2_RawTagData_Global &= Binary("0x00") & Binary("0x00") & Binary("0x00") & Binary("0x00")

	;Could add ZPAD

	;Must have at least one frame
	_ID3v2Frame_SetFields("TIT2", " ")


EndFunc   ;==>_ID3v2Tag_CreateTag
Func _ID3v2Tag_RemoveFrame($sFrameID, $iFrameID_Index = 1)

	_ID3v2Frame_SetBinary($sFrameID, -1, $iFrameID_Index)

EndFunc   ;==>_ID3v2Tag_RemoveFrame

Func _ID3v2Tag_GetHeader($iReturnType = -1)
;~    The ID3v2 tag header, which should be the first information in the file, is 10 bytes as follows:
;~ 	  	ID3v2/file identifier 		"ID3"
;~ 	  	ID3v2 version 				$03 00
;~ 	  	ID3v2 flags 				%abc00000
;~ 	  	ID3v2 size 					4 * %0xxxxxxx

;~    The first three bytes of the tag are always "ID3" to indicate that this is an ID3v2 tag, directly followed by the two version bytes. The
;~ 	  	first byte of ID3v2 version is it's major version, while the second byte is its revision number. In this case this is ID3v2.3.0. All
;~ 	  	revisions are backwards compatible while major versions are not. If software with ID3v2.2.0 and below support should encounter version
;~ 	  	three or higher it should simply ignore the whole tag. Version and revision will never be $FF.
;~ 	  	The version is followed by one the ID3v2 flags field, of which currently only three flags are used.

   Local $vTagHeader ;variant type depending on $iReturnType
   Local $bTagHeader = BinaryMid($bID3v2_RawTagData_Global, 1, 10)
   Local $sTagHeader_Description = "File Identifier|Version|Flags|Size"
   Local $sTagHeader_Values=""
   Local $sID3v2_FileIdentifier = BinaryToString(BinaryMid($bID3v2_RawTagData_Global, 1, 3))
   Local $sID3v2_Version = String(BinaryMid($bID3v2_RawTagData_Global, 4, 1)) & " " & String(BinaryMid($bID3v2_RawTagData_Global, 5, 1))
   Local $sID3v2_Flags = String(BinaryMid($bID3v2_RawTagData_Global, 6, 1))
   Local $sID3v2_Size = String(_ID3v2Tag_GetTagSize())

;~    MsgBox(0,"$sID3v2_FileIdentifier",$sID3v2_FileIdentifier)
   If $iReturnType = 0 Then
	  $vTagHeader = $bTagHeader
	  Return $vTagHeader
   EndIf

   If $iReturnType = 1 Then ;2D Array
	  $aTagDesc = StringSplit($sTagHeader_Description,"|")
	  $vTagHeader = $aTagDesc[1] &  " = " & $sID3v2_FileIdentifier & @CRLF
	  $vTagHeader &= $aTagDesc[2] &  " = " &  $sID3v2_Version & @CRLF
	  $vTagHeader &= $aTagDesc[3] &  " = " &  $sID3v2_Flags & @CRLF
	  $vTagHeader &= $aTagDesc[4] &  " = " &  $sID3v2_Size
	  Return $vTagHeader
   EndIf

   If $iReturnType = 2 Then ;1D Array
	  $vTagHeader = StringSplit($sTagHeader_Description,"|")
	  $vTagHeader[1] &=  " = " & $sID3v2_FileIdentifier
	  $vTagHeader[2] &=  " = " &  $sID3v2_Version
	  $vTagHeader[3] &=  " = " &  $sID3v2_Flags
	  $vTagHeader[4] &=  " = " &  $sID3v2_Size
	  Return $vTagHeader
   EndIf

   If $iReturnType = 3 Then ;2D Array
	  $vTagHeader = StringSplit($sTagHeader_Description,"|")
	  _ArrayColInsert($vTagHeader,1)
	  $vTagHeader[0][1] =  $vTagHeader[0][0]
	  $vTagHeader[1][1] =  $sID3v2_FileIdentifier
	  $vTagHeader[2][1] =  $sID3v2_Version
	  $vTagHeader[3][1] =  $sID3v2_Flags
	  $vTagHeader[4][1] =  $sID3v2_Size
	  Return $vTagHeader
   EndIf


	If $iReturnType = -1 Then
		Return $bTagHeader
	EndIf

EndFunc
Func _ID3v2Tag_GetVersion()
	;Get Tag Version

	Local $sVersion = String(Number(BinaryMid($bID3v2_RawTagData_Global, 4, 1))) & "." & String(Number(BinaryMid($bID3v2_RawTagData_Global, 5, 1)))
;~ 	MsgBox(0,"$sVersion",$sVersion)

	Return $sVersion
EndFunc   ;==>_ID3v2Tag_GetVersion
Func _ID3v2Tag_GetHeaderFlags($sFlagReturnType = -1)
	;ID3v2/file identifier      "ID3"
	;ID3v2 version              $04 00
	;ID3v2 flags                %abcd0000
	;ID3v2 size             4 * %0xxxxxxx

	;ID3v2_Flags = %abc00000
	;a - Unsynchronisation
	;b - Extended header
	;c - Experimental indicator
	;d - Footer present (ID3v2.4)
	Local $bTagFlags = BinaryMid($bID3v2_RawTagData_Global, 6, 1)

	If $sFlagReturnType == "RawBinary" Then
		Return $bTagFlags
	EndIf

	Local $Unsynchronisation = BitShift(BitAND($bTagFlags, 128), 7)
	Local $ExtendedHeader = BitShift(BitAND($bTagFlags, 64), 6)
	Local $ExperimentalIndicator = BitShift(BitAND($bTagFlags, 32), 5)
	Local $Footer = BitShift(BitAND($bTagFlags, 16), 4)


;~ 	If Not Dec(Hex($bTagFlags)) == 0 Then
;~ 		MsgBox(0,"$ID3TagFlags", $bTagFlags) ;Test Code
;~ 	EndIf

	If $sFlagReturnType = -1 Then
		Return "Unsynchronisation" & "|" & $Unsynchronisation & @CRLF & _
				"ExtendedHeader" & "|" & $ExtendedHeader & @CRLF & _
				"ExperimentalIndicator" & "|" & $ExperimentalIndicator & @CRLF & _
				"Footer" & "|" & $Footer
	EndIf

	Switch $sFlagReturnType
		Case "Unsynchronisation"
			Return $Unsynchronisation
		Case "ExtendedHeader"
			Return $ExtendedHeader
		Case "ExperimentalIndicator"
			Return $ExperimentalIndicator
		Case "Footer"
			Return $Footer
		Case Else
			SetError(1)
			Return $bTagFlags
	EndSwitch

EndFunc   ;==>_ID3v2Tag_GetHeaderFlags
Func _ID3v2Tag_GetTagSize($bTagHeaderData = -1)
	;(ID3v2.3) The ID3v2 tag size is encoded with four bytes where the most
	;significant bit (bit 7) is set to zero in every byte, making a total
	;of 28 bits. The zeroed bits are ignored, so a 257 bytes long tag is
	;represented as $00 00 02 01.
	;(ID3v2.4) The ID3v2 tag size is stored as a 32 bit synchsafe integer (section
	;6.2), making a total of 28 effective bits (representing up to 256MB).
	;The ID3v2 tag size is the sum of the byte length of the extended
	;header, the padding and the frames after unsynchronisation. If a
	;footer is present this equals to ('total size' - 20) bytes, otherwise
	;('total size' - 10) bytes.

	;SyncSafe Integer
	;0444 4333  0333 3322  0222 2221  0111 1111
	;0000 4444  3333 3333  2222 2222  1111 1111  (28 bits)

	Local $byte1, $byte2, $byte3, $byte4

	If $bTagHeaderData = -1 Then
		If BinaryLen($bID3v2_RawTagData_Global) < 10 Then
			Return 0
		EndIf
		$byte1 = BitAND(BinaryMid($bID3v2_RawTagData_Global, 7, 1), 127)
		$byte2 = BitAND(BinaryMid($bID3v2_RawTagData_Global, 8, 1), 127)
		$byte3 = BitAND(BinaryMid($bID3v2_RawTagData_Global, 9, 1), 127)
		$byte4 = BitAND(BinaryMid($bID3v2_RawTagData_Global, 10, 1), 127)
	Else
		$byte1 = BitAND(BinaryMid($bTagHeaderData, 7, 1), 127)
		$byte2 = BitAND(BinaryMid($bTagHeaderData, 8, 1), 127)
		$byte3 = BitAND(BinaryMid($bTagHeaderData, 9, 1), 127)
		$byte4 = BitAND(BinaryMid($bTagHeaderData, 10, 1), 127)
	EndIf

	Local $bTagSize = BitShift($byte1, -21) + BitShift($byte2, -14) + BitShift($byte3, -7) + $byte4

	Return Dec(Hex($bTagSize), 2)
EndFunc   ;==>_ID3v2Tag_GetTagSize
Func _ID3v2Tag_GetExtendedHeader($sReturnType = -1)
	;From ID3v2.3 TagSpec
	;Extended header size   $xx xx xx xx
	;Extended Flags         $xx xx
	;Size of padding        $xx xx xx xx

	;From ID32.4 TagSpec
	;Extended header size   4 * %0xxxxxxx
	;Number of flag bytes       $01
	;Extended Flags             $xx
	;Where the 'Extended header size' is the size of the whole extended
	;header, stored as a 32 bit synchsafe integer. An extended header can
	;thus never have a size of fewer than six bytes.

	;Need To Test
	;check if extended header is valid in flag bits

	Local $bExtendedHeader, $sExtendedHeader = ""
	Local $iExtHeaderSize, $sExtFlagsbBin, $iSizeOfPadding, $iNumFlagBytes

	Switch _ID3v2Tag_GetVersion()
		Case "2.0"

		Case "3.0"
;~ 			$bExtendedHeader = BinaryMid($bID3v2_RawTagData_Global,11,10)
;~ 			$iExtHeaderSize = Number(BinaryMid($bID3v2_RawTagData_Global,11,4))
;~ 			$sExtFlagsBin = _HexToBin_ID3(StringTrimLeft(BinaryMid($bID3v2_RawTagData_Global,15,2),2))
;~ 			$iSizeOfPadding = Number(BinaryMid($bID3v2_RawTagData_Global,17,4))
;~ 			$sExtendedHeader = "ExtendedHeaderSize" & "|" & $iExtHeaderSize & @CRLF & _
;~ 							   "ExtendedFlags" & "|" & $sExtFlagsBin & @CRLF & _
;~ 							   "SizeOfPadding" & "|" & $iSizeOfPadding
		Case "4.0"
			$bExtendedHeader = BinaryMid($bID3v2_RawTagData_Global, 11, 10)
			;MsgBox(0,"$bExtendedHeader",$bExtendedHeader)
		Case Else

	EndSwitch


	If $sReturnType == "Binary" Then
		Return BinaryMid($bID3v2_RawTagData_Global, 11, 10)
	EndIf

	If $sReturnType = -1 Then
		Return $sExtendedHeader
	EndIf

EndFunc   ;==>_ID3v2Tag_GetExtendedHeader
Func _ID3v2Tag_GetFooter()
	;Need to Test

EndFunc   ;==>_ID3v2Tag_GetFooter
Func _ID3v2Tag_GetZPAD()
	Local $iFrameInfo = StringInStr($sID3v2_TagFrameIndex_Global, "ZPAD")
	Local $aFrameIDSplit = StringSplit($sID3v2_TagFrameIndex_Global, "ZPAD", 1)
	Local $iNumFrameIDs = $aFrameIDSplit[0] - 1
;~ 	_ArrayDisplay($aFrameIDSplit)

	Local $FrameInfoCut = StringMid($sID3v2_TagFrameIndex_Global, $iFrameInfo)
	Local $iFrameInfoEnd = StringInStr($FrameInfoCut, @CRLF)
	$FrameInfoCut = StringMid($FrameInfoCut, 1, $iFrameInfoEnd - 1)


	$Firstpipe = StringInStr($FrameInfoCut, '|')
	$Lastpipe = StringInStr($FrameInfoCut, '|', -1, -1)
	Local $FrameStart = Number(StringMid($FrameInfoCut, $Firstpipe + 1, ($Lastpipe) - ($Firstpipe + 1)))
	Local $FrameSize = Number(StringMid($FrameInfoCut, $Lastpipe + 1))

	Return $FrameSize

EndFunc   ;==>_ID3v2Tag_GetZPAD


Func _ID3v2Frame_GetBinary($sFrameID, $iFrameID_Index = 1, $fIncludeHeader = False)
	;Return just the binary data of the Frame
	;TODO include FRAMEID and Frame Header

	;First check to make sure the tag was scanned for FrameIDs
	Local $aFrameSplit = StringSplit($sID3v2_TagFrameIndex_Global, @CRLF, 1)
	Local $iNumFrames = $aFrameSplit[0]
	If $iNumFrames <= 1 Then
		_h_ID3v2Tag_EnumerateFrameIDs()
	EndIf


	;First Get Start Byte and Frame Length from $sID3v2_TagFrameIndex_Global
	Local $iFrameInfo = StringInStr($sID3v2_TagFrameIndex_Global, $sFrameID, -1, $iFrameID_Index)
	Local $aFrameIDSplit = StringSplit($sID3v2_TagFrameIndex_Global, $sFrameID, 1)
	Local $iNumFrameIDs = $aFrameIDSplit[0] - 1

	If $iFrameInfo = 0 Then ;$iFrameID_Index was higher then Number of Frames that Exist
		SetExtended($iNumFrameIDs)
		Return -1
	EndIf


	Local $FrameInfoCut = StringMid($sID3v2_TagFrameIndex_Global, $iFrameInfo)
	Local $iFrameInfoEnd = StringInStr($FrameInfoCut, @CRLF)
	$FrameInfoCut = StringMid($FrameInfoCut, 1, $iFrameInfoEnd - 1)


	$Firstpipe = StringInStr($FrameInfoCut, '|')
	$Lastpipe = StringInStr($FrameInfoCut, '|', -1, -1)
	Local $FrameStart = Number(StringMid($FrameInfoCut, $Firstpipe + 1, ($Lastpipe) - ($Firstpipe + 1)))
	Local $FrameSize = Number(StringMid($FrameInfoCut, $Lastpipe + 1))
;~ 	MsgBox(0,$sFrameID,"FrameStart = " & $FrameStart)
;~ 	MsgBox(0,"$FrameSize",$FrameSize)

	If $fIncludeHeader Then
		$FrameStart = $FrameStart - 10
		$FrameSize = $FrameSize + 10
	EndIf


	Local $bFrameData = BinaryMid($bID3v2_RawTagData_Global, $FrameStart, $FrameSize)

;~ 	MsgBox(0,"bFrameData",$bFrameData)

	If BinaryLen($bFrameData) <> 0 Then
		SetExtended($iNumFrameIDs)
		Return $bFrameData
	Else
		Return -1
	EndIf

EndFunc   ;==>_ID3v2Frame_GetBinary
Func _ID3v2Frame_SetBinary($sFrameID, $bNewFrameData, $iFrameID_Index = 1)
;~ 	If $bNewFrameData == -1 then tag is to be removed
	;$bNewFrameData must contain the header
	;First see if this is a frame update or a new frame to be added
	Local $bFrameData = _ID3v2Frame_GetBinary($sFrameID, $iFrameID_Index, True)
	Local $fAddNewFrame = False
	If $bFrameData = -1 Then
		$fAddNewFrame = True
	EndIf

	If ($bNewFrameData = -1) And $fAddNewFrame Then ;Frame does not exist and user is trying to remove it
		Return 0 ;do nothing
	EndIf

	;If ID3v2 does not exists then add new ID3v2.4 Tag
	If BinaryLen($bID3v2_RawTagData_Global) < 10 Then
		_ID3v2Tag_CreateTag(4)
	EndIf


	;Find differance in Frame Size to add or subtract from TagSize
	Local $iOldFrameSize = 0
	Local $iNewFrameSize = 0
	If $bNewFrameData <> -1 Then
		$iNewFrameSize = _h_ID3v2FrameHeader_GetFrameSize($bNewFrameData) + 10
	EndIf
	If Not $fAddNewFrame Then
		$iOldFrameSize = _h_ID3v2FrameHeader_GetFrameSize(BinaryMid($bFrameData, 1, 10)) + 10
	EndIf


	;Set New TagSize
	Local $iOldTagSize = _ID3v2Tag_GetTagSize()
	Local $iNewTagSize = $iOldTagSize - $iOldFrameSize + $iNewFrameSize
;~ 	MsgBox(0,"TagSize","$iOldTagSize = " & $iOldTagSize & @CRLF & "$iNewTagSize = " & $iNewTagSize)

	;Write TagSize (4 byte number)
	;****************************************************************************************
	;SyncSafe Integer
	;4444 4444  3333 3333  2222 2222  1111 1111
	;0444 4333  0333 3322  0222 2221  0111 1111
	Local $bTagSize = Binary("0x" & Hex($iNewTagSize, 8))
	Local $byte1 = BitAND(BinaryMid($bTagSize, 4, 1), 127)
	Local $byte2 = BitAND(BitShift(BinaryMid($bTagSize, 3, 1), -1) + BitShift(BinaryMid($bTagSize, 4, 1), 7), 127)
	Local $byte3 = BitAND(BitShift(BinaryMid($bTagSize, 2, 1), -2) + BitShift(BinaryMid($bTagSize, 3, 1), 6), 127)
	Local $byte4 = BitAND(BitShift(BinaryMid($bTagSize, 1, 1), -3) + BitShift(BinaryMid($bTagSize, 2, 1), 5), 127)
	Local $iTagSizeSyncSafe = BitShift($byte4, -24) + BitShift($byte3, -16) + BitShift($byte2, -8) + $byte1


	Local $bID3v2_RawTagData_Global_Temp = BinaryMid($bID3v2_RawTagData_Global, 1, 6)
	$bID3v2_RawTagData_Global_Temp &= Binary("0x" & Hex($iTagSizeSyncSafe, 8))


	If Not $fAddNewFrame Then
		;Find Old Frame and Replace
		Local $iFrameInfo = StringInStr($sID3v2_TagFrameIndex_Global, $sFrameID, -1, $iFrameID_Index)
		Local $aFrameIDSplit = StringSplit($sID3v2_TagFrameIndex_Global, $sFrameID, 1)
		Local $iNumFrameIDs = $aFrameIDSplit[0] - 1
		Local $FrameInfoCut = StringMid($sID3v2_TagFrameIndex_Global, $iFrameInfo)
		Local $iFrameInfoEnd = StringInStr($FrameInfoCut, @CRLF)
		$FrameInfoCut = StringMid($FrameInfoCut, 1, $iFrameInfoEnd - 1)
		$Firstpipe = StringInStr($FrameInfoCut, '|')
		$Lastpipe = StringInStr($FrameInfoCut, '|', -1, -1)
		Local $FrameStart = Number(StringMid($FrameInfoCut, $Firstpipe + 1, ($Lastpipe) - ($Firstpipe + 1)))
		Local $FrameSize = Number(StringMid($FrameInfoCut, $Lastpipe + 1))

		Local $bOldFrameData = BinaryMid($bID3v2_RawTagData_Global, $FrameStart, $FrameSize)

		If ($FrameStart - 20) > 1 Then
			$bID3v2_RawTagData_Global_Temp &= BinaryMid($bID3v2_RawTagData_Global, 11, $FrameStart - 21) ;read up to old frame
		EndIf
		If $bNewFrameData <> -1 Then
			$bID3v2_RawTagData_Global_Temp &= $bNewFrameData ;read in new Frame
		EndIf

;~ 		MsgBox(0,"Compare",$bID3v2_RawTagData_Global_Temp & @CRLF & @CRLF & BinaryMid($bID3v2_RawTagData_Global,1,$FrameStart + $iOldFrameSize - 1))


		$bID3v2_RawTagData_Global_Temp &= BinaryMid($bID3v2_RawTagData_Global, $FrameStart + $FrameSize) ;read in rest of TAG

	Else

		Local $FrameStart = $iOldTagSize + 10 + 1
		Local $iFrameInfo = StringInStr($sID3v2_TagFrameIndex_Global, "ZPAD")
		If $iFrameInfo <> 0 Then
			;Add New to end of frame before ZPAD
			Local $aFrameIDSplit = StringSplit($sID3v2_TagFrameIndex_Global, "ZPAD", 1)
			Local $iNumFrameIDs = $aFrameIDSplit[0] - 1
			Local $FrameInfoCut = StringMid($sID3v2_TagFrameIndex_Global, $iFrameInfo)
			Local $iFrameInfoEnd = StringInStr($FrameInfoCut, @CRLF)
			$FrameInfoCut = StringMid($FrameInfoCut, 1, $iFrameInfoEnd - 1)
			$Firstpipe = StringInStr($FrameInfoCut, '|')
			$Lastpipe = StringInStr($FrameInfoCut, '|', -1, -1)
			$FrameStart = Number(StringMid($FrameInfoCut, $Firstpipe + 1, ($Lastpipe) - ($Firstpipe + 1)))
		EndIf


		$bID3v2_RawTagData_Global_Temp &= BinaryMid($bID3v2_RawTagData_Global, 11, $FrameStart - 10 - 1) ;read up to ZPAD
		$bID3v2_RawTagData_Global_Temp &= $bNewFrameData ;read in new Frame
		$bID3v2_RawTagData_Global_Temp &= BinaryMid($bID3v2_RawTagData_Global, $FrameStart)

	EndIf
	;****************************************************************************************


	$bID3v2_RawTagData_Global = $bID3v2_RawTagData_Global_Temp
	_h_ID3v2Tag_EnumerateFrameIDs()

EndFunc   ;==>_ID3v2Frame_SetBinary
Func _ID3v2Frame_GetFields($sFrameID, $iFrameID_Index = 1, $iReturnTypeFlag = 0)

	;$iReturnTypeFlag
	;0 (Default) => Returns single text string that mostly describes the frame
	;1 => Returns Array of all items in frame
	;2 => Returns 2D Array of all items with descriptions

	;Will take advantage of the variant data type in AutoIt
	;20120327 change this function to return an array with all frame fields including FrameID

	Local $vFrameString = "", $vFrameStringDescrip = "", $iSetError = 0

	;If version = ID3v2.2 then convert FrameID
	Local $iTagVersion = Number(StringLeft(_ID3v2Tag_GetVersion(), 1))
	If $iTagVersion = 2 Then
		_h_ID3v2_ConvertFrameID($sFrameID)
	EndIf

	Local $bFrameData = _ID3v2Frame_GetBinary($sFrameID, $iFrameID_Index)
	Local $iNumFrameIDs = @extended

	;Check if FrameID was not found
	If $bFrameData = -1 Then
		$iSetError = 1
		If $iReturnTypeFlag = 1 Then
			Local $vFrameString[6] ;this will avoid errors if an array is expected
		EndIf
		SetError($iSetError)
		SetExtended($iNumFrameIDs)
		Return $vFrameString
	EndIf


	If (StringMid($sFrameID, 1, 1) == "T") And ($sFrameID <> "TXXX") And ($sFrameID <> "TXX") Then
		;Information | TextEncoding
		$vFrameStringDescrip = "Information|TextEncoding"
		$vFrameString = _h_ID3v2_GetFrameT000_TZZZ($bFrameData)
		If $iReturnTypeFlag = 0 Then
			$vFrameString = $vFrameString[1]
			If ($sFrameID == "TCON") Or ($sFrameID == "TCO") Then;Content Type/Genre
				If StringMid($vFrameString, 1, 1) == "(" Then ;check if first char is "("
					$closeparindex = StringInStr($vFrameString, ")")
					$GenreID = StringMid($vFrameString, 2, $closeparindex - 1)
					$vFrameString = _h_ID3v1_GetGenreFromID($GenreID)
				EndIf ;If no "(" then return the whole field as is
			EndIf
		EndIf
	ElseIf (StringMid($sFrameID, 1, 1) == "W") And ($sFrameID <> "WXXX") And ($sFrameID <> "WXX") Then
		$vFrameString = _h_ID3v2_GetFrameW000_WZZZ($bFrameData)
	Else
		Switch $sFrameID
			Case "TXXX", "TXX" ;User defined text information frame
				;Value | Description | TextEncoding
				$vFrameStringDescrip = "Value|Description|TextEncoding"
				$vFrameString = _h_ID3v2_GetFrameTXXX($bFrameData)
				If $iReturnTypeFlag = 0 Then
					$vFrameString = $vFrameString[1] ;Value
				EndIf
			Case "WXXX", "WXX" ;User defined URL link frame
				;URL | Description | TextEncoding
				$vFrameStringDescrip = "URL|Description|TextEncoding"
				$vFrameString = _h_ID3v2_GetFrameWXXX($bFrameData)
				If $iReturnTypeFlag = 0 Then
					$vFrameString = $vFrameString[1] ;URL
				EndIf
			Case "COMM", "COM" ;Comment
				;CommentText | Description | Language | TextEncoding
				$vFrameStringDescrip = "CommentText|Description|Language|TextEncoding"
				$vFrameString = _h_ID3v2_GetFrameCOMM($bFrameData)
				If $iReturnTypeFlag = 0 Then
					$vFrameString = $vFrameString[1] ;CommentText
				EndIf
			Case "APIC", "PIC" ;Attached picture
				;PictureFileName | Description | PictureType | MIMEType | TextEncoding
				$vFrameStringDescrip = "PictureFileName|Description|PictureType|MIMEType|TextEncoding"
				$vFrameString = _h_ID3v2_GetFrameAPIC($bFrameData)
				If $iReturnTypeFlag = 0 Then
					$vFrameString = $vFrameString[1] & Chr(0) & Number($vFrameString[3]);PictureFileName & chr(0) & PictureType
				EndIf
			Case "USLT", "ULT" ;Unsychronized lyric/text transcription
				;LyricsFilename | Description | Language | TextEncoding
				$vFrameStringDescrip = "LyricsFilename|Description|Language|TextEncoding"
				$vFrameString = _h_ID3v2_GetFrameUSLT($bFrameData)
				If $iReturnTypeFlag = 0 Then
					$vFrameString = $vFrameString[1] ;LyricsFilename
				EndIf
			Case "UFID", "UFI" ;Unique file identifier
				;OwnerIdentifier | Identifier
				$vFrameStringDescrip = "OwnerIdentifier|Identifier"
				$vFrameString = _h_ID3v2_GetFrameUFID($bFrameData)
				If $iReturnTypeFlag = 0 Then
					$vFrameString = $vFrameString[1] ;OwnerIdentifier
				EndIf
			Case "POPM", "POP" ;Popularimeter
				;Rating | EmailToUser | Counter
				$vFrameStringDescrip = "Rating|EmailToUser|Counter"
				$vFrameString = _h_ID3v2_GetFramePOPM($bFrameData)
				If $iReturnTypeFlag = 0 Then
					$vFrameString = $vFrameString[1] ;Rating
				EndIf
			Case "PRIV" ;Private frame
				;OwnerIdentifier | PrivateData
				$vFrameStringDescrip = "OwnerIdentifier|PrivateData"
				$vFrameString = _h_ID3v2_GetFramePRIV($bFrameData)
				If $iReturnTypeFlag = 0 Then
					$vFrameString = $vFrameString[1] ;OwnerIdentifier
				EndIf
			 Case "PCNT", "CNT" ;Play counter
				$vFrameStringDescrip = "PlayCount"
				$vFrameString = _h_ID3v2_GetFramePCNT($bFrameData) ;Counter
			 Case "MCDI", "MCI" ;Music CD identifier (Only contains binary data)
				$vFrameStringDescrip = "BinaryData"
				$vFrameString = $bFrameData
			Case "RGAD" ;Replay Gain Adjustment
				;PeakAmplitude | RadioReplayGainAdj | AudiophileReplayGainAdj
				$vFrameStringDescrip = "PeakAmplitude|RadioReplayGainAdj|AudiophileReplayGainAdj"
				$vFrameString = _h_ID3v2_GetFrameRGAD($bFrameData)
				If $iReturnTypeFlag = 0 Then
					$vFrameString = $vFrameString[1] ;PeakAmplitude
				EndIf
			Case Else
				$iSetError = 2
				$vFrameString = $bFrameData
		EndSwitch
	EndIf

   If $iReturnTypeFlag = 2 Then
	  _ArrayColInsert($vFrameString,0)
	  Dim $iColumn = StringSplit($vFrameStringDescrip,"|")
	  For $i=0 To $iColumn[0]
		 $vFrameString[$i][0] = $iColumn[$i]
	  Next
;~ 	  _ArrayDisplay($vFrameString,"$vFrameString After")
   EndIf


	SetError($iSetError)
	SetExtended($iNumFrameIDs)
	Return $vFrameString

EndFunc   ;==>_ID3v2Frame_GetFields
Func _ID3v2Frame_SetFields($sFrameID, $vNewFrameStrings, $iFrameID_Index = 1, $sDelimiter = -1)

	;If $vNewFrameStrings is an empty string of length=0 then frame will be removed

	;TODO if ID3v2 does not exist need to create header

	;$sDelimiter
	;-1 (Default) => If IsString($vNewFrameStrings) == True then $vNewFrameStrings is a simple text string that mostly describes the frame
	;If IsArray($vNewFrameStrings) == True then $vNewFrameStrings is an array of simple text strings for each field of frame in proper order
	;" " 		  => any string to be used as a delimiter for $vNewFrameStrings to contain main text fields of frame in proper order
	;Check if tag does not exist
	Local $sID3v2_TagID = BinaryToString(BinaryMid($bID3v2_RawTagData_Global, 1, 3))
	If (StringCompare($sID3v2_TagID, "ID3") <> 0) Then
		_ID3v2Tag_CreateTag(4)
	EndIf

	Local $bFrameData
	If (StringMid($sFrameID, 1, 1) == "T") And (StringLen($sFrameID) = 4) And ($sFrameID <> "TXXX") Then
		;_h_ID3v2_CreateFrameT000_TZZZ($sInformation, $iTextEncoding = 0)
		If IsString($sDelimiter) Then ;Complex Delimited String
			Local $aNewFrameStrings = StringSplit($vNewFrameStrings, $sDelimiter, 1)
			Switch $aNewFrameStrings[0]
				Case 1
					$bFrameData = _h_ID3v2_CreateFrameT000_TZZZ($aNewFrameStrings[1])
				Case 2
					$bFrameData = _h_ID3v2_CreateFrameT000_TZZZ($aNewFrameStrings[1], Number($aNewFrameStrings[2]))
				Case Else
					;Too many
			EndSwitch
		Else
			;Array
			If IsArray($vNewFrameStrings) Then
				$bFrameData = _h_ID3v2_CreateFrameT000_TZZZ($vNewFrameStrings[1], Number($vNewFrameStrings[2]))
			EndIf

			;Simple Text String
			If IsString($vNewFrameStrings) Then
				$bFrameData = _h_ID3v2_CreateFrameT000_TZZZ($vNewFrameStrings)
			EndIf

		EndIf
	ElseIf $sFrameID == "TXXX" Then
		;_h_ID3v2_CreateFrameTXXX($sValue,$sDescription = "",$iTextEncoding = 0)
		If IsString($sDelimiter) Then ;Complex Delimited String
			Local $aNewFrameStrings = StringSplit($vNewFrameStrings, $sDelimiter, 1)
			Switch $aNewFrameStrings[0]
				Case 1
					$bFrameData = _h_ID3v2_CreateFrameTXXX($aNewFrameStrings[1])
				Case 2
					$bFrameData = _h_ID3v2_CreateFrameTXXX($aNewFrameStrings[2], $aNewFrameStrings[1])
				Case 3
					$bFrameData = _h_ID3v2_CreateFrameTXXX($aNewFrameStrings[2], $aNewFrameStrings[1], Number($aNewFrameStrings[3]))
				Case Else
					;Too many
			EndSwitch
		Else
			;Array
			If IsArray($vNewFrameStrings) Then
				$bFrameData = _h_ID3v2_CreateFrameTXXX($vNewFrameStrings[1], $vNewFrameStrings[2], Number($vNewFrameStrings[3]))
			EndIf

			;Simple Text String
			If IsString($vNewFrameStrings) Then
				$bFrameData = _h_ID3v2_CreateFrameTXXX($vNewFrameStrings)
			EndIf

		EndIf

	ElseIf (StringMid($sFrameID, 1, 1) == "W") And (StringLen($sFrameID) = 4) And ($sFrameID <> "WXXX") Then
		;_h_ID3v2_CreateFrameW000_WZZZ($sURL)
		$bFrameData = _h_ID3v2_CreateFrameW000_WZZZ($vNewFrameStrings)
	ElseIf $sFrameID == "WXXX" Then
		;_h_ID3v2_CreateFrameWXXX($sURL,$sDescription = "",$iTextEncoding = 0)
		If IsString($sDelimiter) Then ;Complex Delimited String
			Local $aNewFrameStrings = StringSplit($vNewFrameStrings, $sDelimiter, 1)
			Switch $aNewFrameStrings[0]
				Case 1
					$bFrameData = _h_ID3v2_CreateFrameWXXX($aNewFrameStrings[1])
				Case 2
					$bFrameData = _h_ID3v2_CreateFrameWXXX($aNewFrameStrings[1], $aNewFrameStrings[2])
				Case 3
					$bFrameData = _h_ID3v2_CreateFrameWXXX($aNewFrameStrings[1], $aNewFrameStrings[2], Number($aNewFrameStrings[3]))
				Case Else
					;Too many
			EndSwitch
		Else

			;Array
			If IsArray($vNewFrameStrings) Then
				$bFrameData = _h_ID3v2_CreateFrameWXXX($vNewFrameStrings[1], $vNewFrameStrings[2], Number($vNewFrameStrings[3]))
			EndIf

			;Simple Text String
			If IsString($vNewFrameStrings) Then
				$bFrameData = _h_ID3v2_CreateFrameWXXX($vNewFrameStrings)
			EndIf

		EndIf

	Else
		Switch $sFrameID
			Case "COMM", "COM" ;Comment
				;_h_ID3v2_CreateFrameCOMM($sText,$sDescription = "",$sLanguage = "eng",$iTextEncoding = 0)
				If IsString($sDelimiter) Then ;Delimited String
					Local $aNewFrameStrings = StringSplit($vNewFrameStrings, $sDelimiter, 1)
					Switch $aNewFrameStrings[0]
						Case 1
							$bFrameData = _h_ID3v2_CreateFrameCOMM($aNewFrameStrings[1])
						Case 2
							$bFrameData = _h_ID3v2_CreateFrameCOMM($aNewFrameStrings[1], $aNewFrameStrings[2])
						Case 3
							$bFrameData = _h_ID3v2_CreateFrameCOMM($aNewFrameStrings[1], $aNewFrameStrings[2], $aNewFrameStrings[3])
						Case 4
							$bFrameData = _h_ID3v2_CreateFrameCOMM($aNewFrameStrings[1], $aNewFrameStrings[2], $aNewFrameStrings[3], Number($aNewFrameStrings[4]))
						Case Else
							;Too many
					EndSwitch
				Else

					;Array
					If IsArray($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFrameCOMM($vNewFrameStrings[1], $vNewFrameStrings[2], $vNewFrameStrings[3], Number($vNewFrameStrings[4]))
					EndIf

					;Simple Text String
					If IsString($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFrameCOMM($vNewFrameStrings)
					EndIf

				EndIf
			Case "APIC"
				;_h_ID3v2_CreateFrameAPIC($sPictureFilename,$sDescription = "",$iPictureType = 0,$sMIMEType = -1,$iTextEncoding = 0)
				If IsString($sDelimiter) Then ;Delimited String
					Local $aNewFrameStrings = StringSplit($vNewFrameStrings, $sDelimiter, 1)
					Switch $aNewFrameStrings[0]
						Case 1
							$bFrameData = _h_ID3v2_CreateFrameAPIC($aNewFrameStrings[1])
						Case 2
							$bFrameData = _h_ID3v2_CreateFrameAPIC($aNewFrameStrings[1], $aNewFrameStrings[2])
						Case 3
							$bFrameData = _h_ID3v2_CreateFrameAPIC($aNewFrameStrings[1], $aNewFrameStrings[2], Number($aNewFrameStrings[3]))
						Case 4
							$bFrameData = _h_ID3v2_CreateFrameAPIC($aNewFrameStrings[1], $aNewFrameStrings[2], Number($aNewFrameStrings[3]), $aNewFrameStrings[4])
						Case 5
							$bFrameData = _h_ID3v2_CreateFrameAPIC($aNewFrameStrings[1], $aNewFrameStrings[2], Number($aNewFrameStrings[3]), $aNewFrameStrings[4], Number($aNewFrameStrings[5]))
						Case Else
							;Too many
					EndSwitch
				Else

					;Array
					If IsArray($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFrameAPIC($vNewFrameStrings[1], $vNewFrameStrings[2], Number($vNewFrameStrings[3]), $vNewFrameStrings[4], Number($vNewFrameStrings[5]))
					EndIf

					;Simple Text String
					If IsString($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFrameAPIC($vNewFrameStrings)
					EndIf

				EndIf
			Case "USLT"
				;_h_ID3v2_CreateFrameUSLT($sLyricsFilename,$sDescription = "",$sLanguage = "eng",$iTextEncoding = 0)
				If IsString($sDelimiter) Then ;Delimited String
					Local $aNewFrameStrings = StringSplit($vNewFrameStrings, $sDelimiter, 1)
					Switch $aNewFrameStrings[0]
						Case 1
							$bFrameData = _h_ID3v2_CreateFrameUSLT($aNewFrameStrings[1])
						Case 2
							$bFrameData = _h_ID3v2_CreateFrameUSLT($aNewFrameStrings[1], $aNewFrameStrings[2])
						Case 3
							$bFrameData = _h_ID3v2_CreateFrameUSLT($aNewFrameStrings[1], $aNewFrameStrings[2], $aNewFrameStrings[3])
						Case 4
							$bFrameData = _h_ID3v2_CreateFrameUSLT($aNewFrameStrings[1], $aNewFrameStrings[2], $aNewFrameStrings[3], Number($aNewFrameStrings[4]))
						Case Else
							;Too many
					EndSwitch
				Else
					;Array
					If IsArray($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFrameUSLT($vNewFrameStrings[1], $vNewFrameStrings[2], $vNewFrameStrings[3], Number($vNewFrameStrings[4]))
					EndIf
					;Simple Text String
					If IsString($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFrameUSLT($vNewFrameStrings)
					EndIf
				EndIf
			Case "PCNT"
				;_h_ID3v2_CreateFramePCNT($iCounter = 0)
				;Simple Text String
				If IsString($vNewFrameStrings) Then
					$bFrameData = _h_ID3v2_CreateFramePCNT(Number($vNewFrameStrings))
				Else
					;$vNewFrameStrings is an integer
					$bFrameData = _h_ID3v2_CreateFramePCNT($vNewFrameStrings)
				EndIf
			Case "UFID"
				;_h_ID3v2_CreateFrameUFID($bIdentifier, $sOwnerIdentifier = "http://www.id3.org/dummy/ufid.html")
				If IsString($sDelimiter) Then ;Delimited String
					Local $aNewFrameStrings = StringSplit($vNewFrameStrings, $sDelimiter, 1)
					Switch $aNewFrameStrings[0]
						Case 1
							$bFrameData = _h_ID3v2_CreateFrameUFID($aNewFrameStrings[1])
						Case 2
							$bFrameData = _h_ID3v2_CreateFrameUFID($aNewFrameStrings[1], $aNewFrameStrings[2])
						Case Else
							;Too many
					EndSwitch
				Else
					;Array
					If IsArray($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFrameUFID($vNewFrameStrings[1], $vNewFrameStrings[2])
					EndIf
					;Simple Text String
					If IsString($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFrameUFID(0, $vNewFrameStrings)
					EndIf
					If IsBinary($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFrameUFID($vNewFrameStrings)
					EndIf
				EndIf
			Case "POPM" ;Popularimeter
				;_h_ID3v2_CreateFramePOPM($bRating,$sEmailToUser = "",$bCounter = 0)
				If IsString($sDelimiter) Then ;Delimited String
					Local $aNewFrameStrings = StringSplit($vNewFrameStrings, $sDelimiter, 1)
					Switch $aNewFrameStrings[0]
						Case 1
							$bFrameData = _h_ID3v2_CreateFramePOPM($aNewFrameStrings[1])
						Case 2
							$bFrameData = _h_ID3v2_CreateFramePOPM($aNewFrameStrings[1], $aNewFrameStrings[2])
						Case 3
							$bFrameData = _h_ID3v2_CreateFramePOPM($aNewFrameStrings[1], $aNewFrameStrings[2], $aNewFrameStrings[3])
						Case Else
							;Too many
					EndSwitch
				Else
					;Array
					If IsArray($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFramePOPM($vNewFrameStrings[1], $vNewFrameStrings[2], $vNewFrameStrings[3])
					EndIf
					;Simple Text String
					If IsString($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFramePOPM($vNewFrameStrings)
;~ 						MsgBox(0,"$vNewFrameStrings",$vNewFrameStrings)
					EndIf
					If IsBinary($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFramePOPM($vNewFrameStrings)
					EndIf
				EndIf
			Case "MCDI" ;contains only binary data
				If IsBinary($vNewFrameStrings) Then
					$bFrameData = $vNewFrameStrings
				Else
					$bFrameData = Binary($vNewFrameStrings)
				EndIf
			Case "PRIV"
				;_h_ID3v2_CreateFramePRIV($sOwnerIdentifier,$bPrivateData = 0)
				If IsString($sDelimiter) Then ;Delimited String
					Local $aNewFrameStrings = StringSplit($vNewFrameStrings, $sDelimiter, 1)
					Switch $aNewFrameStrings[0]
						Case 1
							$bFrameData = _h_ID3v2_CreateFrameUFID($aNewFrameStrings[1])
						Case 2
							$bFrameData = _h_ID3v2_CreateFrameUFID($aNewFrameStrings[1], $aNewFrameStrings[2])
						Case Else
							;Too many
					EndSwitch
				Else
					;Array
					If IsArray($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFrameUFID($vNewFrameStrings[1], $vNewFrameStrings[2])
					EndIf
					;Simple Text String
					If IsString($vNewFrameStrings) Then
						$bFrameData = _h_ID3v2_CreateFrameUFID($vNewFrameStrings)
					EndIf
				EndIf
			Case Else
				MsgBox(0, "_ID3v2Frame_SetFields Error", $sFrameID & " has not been implemented yet!")
				SetError(1)
				Return -1
		EndSwitch

	EndIf


	Local $NewFrameSize = BinaryLen($bFrameData)
	Local $iID3v2_Version = _ID3v2Tag_GetVersion()
	Local $bFrameSize = Binary("0x" & Hex($NewFrameSize, 8))

	If StringInStr($iID3v2_Version, "4.") Then ;ID3v2.4.X
		;SyncSafe Integer
		;4444 4444  3333 3333  2222 2222  1111 1111
		;0444 4333  0333 3322  0222 2221  0111 1111
		Local $byte1 = BitAND(BinaryMid($bFrameSize, 4, 1), 127)
		Local $byte2 = BitAND(BitShift(BinaryMid($bFrameSize, 3, 1), -1) + BitShift(BinaryMid($bFrameSize, 4, 1), 7), 127)
		Local $byte3 = BitAND(BitShift(BinaryMid($bFrameSize, 2, 1), -2) + BitShift(BinaryMid($bFrameSize, 3, 1), 6), 127)
		Local $byte4 = BitAND(BitShift(BinaryMid($bFrameSize, 1, 1), -3) + BitShift(BinaryMid($bFrameSize, 2, 1), 5), 127)
		Local $iSyncSafeFrameSize = BitShift($byte4, -24) + BitShift($byte3, -16) + BitShift($byte2, -8) + $byte1
		Local $bSyncSafeFrameSize = Binary("0x" & String(Hex($iSyncSafeFrameSize, 8)))
		$bFrameSize = $bSyncSafeFrameSize
	Else
;~ 		MsgBox(0,"Check Tag Version",$iID3v2_Version) ;Test Code
	EndIf


	Local $bNewFrameWithHeader = Binary($sFrameID) & $bFrameSize & Binary("0x00") & Binary("0x00") & $bFrameData
;~ 	MsgBox(0,"$bNewFrameWithHeader",$bNewFrameWithHeader)

	If (Not IsArray($vNewFrameStrings)) And (StringLen($vNewFrameStrings) = 0) Then
		_ID3v2Frame_SetBinary($sFrameID, -1, $iFrameID_Index) ;Remove Frame
	Else
		_ID3v2Frame_SetBinary($sFrameID, $bNewFrameWithHeader, $iFrameID_Index)
	EndIf

EndFunc   ;==>_ID3v2Frame_SetFields



Func _h_ID3v2FrameHeader_GetFrameID($bFrameHeaderData)

	Local $iFrameIDLen = 4, $bFrameID
	If StringInStr(_ID3v2Tag_GetVersion(), "2.") Then
		$iFrameIDLen = 3
	Else
		$iFrameIDLen = 4
	EndIf

	$bFrameID = BinaryMid($bFrameHeaderData, 1, $iFrameIDLen)


	Local $iASC = 0
	For $i = 1 To $iFrameIDLen
		$iASC = Asc(BinaryToString(BinaryMid($bFrameID, $i)))
		If $i = 1 Then
			If ($iASC < Asc("A")) Or ($iASC > Asc("Z")) Then
				Return -1
			EndIf
		Else
			If ($iASC < Asc("0")) Or ($iASC > Asc("9")) Then
				If ($iASC < Asc("A")) Or ($iASC > Asc("Z")) Then
					Return -1
				EndIf
			EndIf
		EndIf
	Next

	;Should check against exsisting FRAMEIDs - this will help fix bad/corrupt tags
	Return BinaryToString($bFrameID)

EndFunc   ;==>_h_ID3v2FrameHeader_GetFrameID
Func _h_ID3v2FrameHeader_GetFrameSize($bFrameHeaderData)
	;(ID3v2.2) Frame ID   $xx xx xx  (three characters)
	;Size     $xx xx xx
	;The three character frame identifier is followed by a three byte size
	;descriptor, making a total header size of six bytes in every frame.
	;The size is calculated as framesize excluding frame identifier and
	;size descriptor (frame size - 6).
	;(ID3v2.3) Frame ID   $xx xx xx xx  (four characters)
	;Size     $xx xx xx xx
	;Flags    $xx xx
	;The frame ID is followed by a size descriptor, making a total header
	;size of ten bytes in every frame. The size is calculated as frame
	;size excluding frame header (frame size - 10).
	;(ID3v2.4) Frame ID    $xx xx xx xx  (four characters)
	;Size      4 * %0xxxxxxx
	;Flags     $xx xx
	;The frame ID is followed by a size descriptor containing the size of
	;the data in the final frame, after encryption, compression and
	;unsynchronisation. The size is excluding the frame header ('total
	;frame size' - 10 bytes) and stored as a 32 bit synchsafe integer.


	Local $bFrameSize, $iFrameSize = 0
	Local $iID3v2_Version = _ID3v2Tag_GetVersion()
	If StringInStr($iID3v2_Version, "2.") Then ;ID3v2.2.X
		$bFrameSize = BinaryMid($bFrameHeaderData, 4, 3)
		$iFrameSize = Dec(Hex($bFrameSize))
;~ 		MsgBox(0,"$bFrameHeaderData",$bFrameHeaderData) ;Test Code
;~ 		MsgBox(0,"$iFrameSize",$iFrameSize) ;Test Code
	ElseIf StringInStr($iID3v2_Version, "3.") Then ;ID3v2.3.X
		$bFrameSize = BinaryMid($bFrameHeaderData, 5, 4)
		$iFrameSize = Dec(Hex($bFrameSize), 2)
	ElseIf StringInStr($iID3v2_Version, "4.") Then ;ID3v2.4.X
		$bFrameSize = BinaryMid($bFrameHeaderData, 5, 4)
		;SyncSafe Integer
		;0444 4333  0333 3322  0222 2221  0111 1111
		;0000 4444  3333 3333  2222 2222  1111 1111  (28 bits)
		Local $byte1 = BitAND(BinaryMid($bFrameSize, 1, 1), 127)
		Local $byte2 = BitAND(BinaryMid($bFrameSize, 2, 1), 127)
		Local $byte3 = BitAND(BinaryMid($bFrameSize, 3, 1), 127)
		Local $byte4 = BitAND(BinaryMid($bFrameSize, 4, 1), 127)
		$bFrameSize = BitShift($byte1, -21) + BitShift($byte2, -14) + BitShift($byte3, -7) + $byte4
		$iFrameSize = Dec(Hex($bFrameSize), 2)
	Else
;~ 		MsgBox(0,"Check Tag Version",$iID3v2_Version) ;Test Code
	EndIf

	Return $iFrameSize

EndFunc   ;==>_h_ID3v2FrameHeader_GetFrameSize
Func _h_ID3v2FrameHeader_GetFlags($bFrameHeaderData, $sFlagReturnType = -1)

	;ID3v2.4
	;Frame ID $xx xx xx xx (four characters)
	;Size 4 * %0xxxxxxx
	;Flags $xx xx

	;ID3v2_FrameHeaderFlags = %0abc0000 %0h00kmnp
	;a - Tag alter preservation
	;b - File alter preservation
	;c - Read only
	;h - Grouping identity
	;k - Compression
	;m - Encryption
	;n - Unsynchronisation
		 ;This flag indicates whether or not unsynchronisation was applied
		 ;to this frame. See section 6 for details on unsynchronisation.
		 ;If this flag is set all data from the end of this header to the
		 ;end of this frame has been unsynchronised. Although desirable, the
		 ;presence of a 'Data Length Indicator' is not made mandatory by
		 ;unsynchronisation.
		 ;	0 Frame has not been unsynchronised.
		 ;	1 Frame has been unsyrchronised.
	;p - Data length indicator
		 ;This flag indicates that a data length indicator has been added to
		 ;the frame. The data length indicator is the value one would write
		 ;as the 'Frame length' if all of the frame format flags were
		 ;zeroed, represented as a 32 bit synchsafe integer.
		 ;	0 There is no Data Length Indicator.
		 ;	1 A data length Indicator has been added to the frame

	Local $bFrameFlags = BinaryMid($bFrameHeaderData, 9, 2)

	If $sFlagReturnType == "RawBinary" Then
		Return $bFrameFlags
	EndIf

	Local $bFrameFlags_MSB = BinaryMid($bFrameHeaderData, 9, 1)
	Local $bFrameFlags_LSB = BinaryMid($bFrameHeaderData, 10, 1)

	Local $TagAlterPreservation = BitShift(BitAND($bFrameFlags_MSB, 64), 6)
	Local $FileAlterPreservation = BitShift(BitAND($bFrameFlags_MSB, 32), 5)
	Local $ReadOnly = BitShift(BitAND($bFrameFlags_MSB, 16), 4)

	Local $GroupingIdentity = BitShift(BitAND($bFrameFlags_LSB, 64), 6)
	Local $Compression = BitShift(BitAND($bFrameFlags_LSB, 8), 3)
	Local $Encryption = BitShift(BitAND($bFrameFlags_LSB, 4), 2)
	Local $Unsynchronisation = BitShift(BitAND($bFrameFlags_LSB, 2), 1)
	Local $DataLengthIndicator = BitShift(BitAND($bFrameFlags_LSB, 1), 0)


	If $sFlagReturnType = -1 Then
		Return "TagAlterPreservation" & "|" & $TagAlterPreservation & @CRLF & _
				"FileAlterPreservation" & "|" & $FileAlterPreservation & @CRLF & _
				"$ReadOnly" & "|" & $ReadOnly & @CRLF & _
				"GroupingIdentity" & "|" & $GroupingIdentity & @CRLF & _
				"Compression" & "|" & $Compression & @CRLF & _
				"Encryption" & "|" & $Encryption & @CRLF & _
				"Unsynchronisation" & "|" & $Unsynchronisation & @CRLF & _
				"DataLengthIndicator" & "|" & $DataLengthIndicator
	EndIf

	Switch $sFlagReturnType
		Case "TagAlterPreservation"
			Return $TagAlterPreservation
		Case "FileAlterPreservation"
			Return $FileAlterPreservation
		Case "$ReadOnly"
			Return $ReadOnly
		Case "GroupingIdentity"
			Return $GroupingIdentity
		Case "Compression"
			Return $Compression
		Case "Encryption"
			Return $Encryption
		Case "Unsynchronisation"
			Return $Unsynchronisation
		Case "DataLengthIndicator"
			Return $DataLengthIndicator
		Case Else
			SetError(1)
			Return $bFrameFlags
	EndSwitch
EndFunc   ;==>_h_ID3v2FrameHeader_GetFlags


Func _h_ID3v2Frame_RemoveUnsynchronisation() ;_h_ID3v2Frame_RemoveUnsynchronisation(ByRef $bFrameData)
   ;The only purpose of unsynchronisation is to make the ID3v2 tag as
   ;compatible as possible with existing software and hardware. There is
   ;no use in 'unsynchronising' tags if the file is only to be processed
   ;only by ID3v2 aware software and hardware. Unsynchronisation is only
   ;useful with tags in MPEG 1/2 layer I, II and III, MPEG 2.5 and AAC
   ;files
   ;To indicate usage of the unsynchronisation, the unsynchronisation
   ;flag in the frame header should be set. This bit MUST be set if the
   ;frame was altered by the unsynchronisation and SHOULD NOT be set if
   ;unaltered. If all frames in the tag are unsynchronised the
   ;unsynchronisation flag in the tag header SHOULD be set. It MUST NOT
   ;be set if the tag has a frame which is not unsynchronised.
   ;Assume the first byte of the audio to be $FF. The special case when
   ;the last byte of the last frame is $FF and no padding nor footer is
   ;used will then introduce a false synchronisation. This can be solved
   ;by adding a footer, adding padding or unsynchronising the frame and
   ;add $00 to the end of the frame data, thus adding more byte to the
   ;frame size than a normal unsynchronisation would. Although not
   ;preferred, it is allowed to apply the last method on all frames
   ;ending with $FF.
   ;It is preferred that the tag is either completely unsynchronised or
   ;not unsynchronised at all. A completely unsynchronised tag has no
   ;false synchonisations in it, as defined above, and does not end with
   ;$FF. A completely non-unsynchronised tag contains no unsynchronised
   ;frames, and thus the unsynchronisation flag in the header is cleared.
   ;Do bear in mind, that if compression or encryption is used, the
   ;unsynchronisation scheme MUST be applied afterwards. When decoding an
   ;unsynchronised frame, the unsynchronisation scheme MUST be reversed
   ;first, encryption and decompression afterwards.

	;$bFrameData does not include header

   ;Foobar2000 seems to just set every other byte to 0x00 so I need to check for this too

	Local $bFrameData_Temp = BinaryMid($bFrameData, 1, 1)

	For $ibyte = 7 To BinaryLen($bFrameData) - 1

		If BinaryMid($bFrameData, $ibyte, 1) = Binary("0x00") Then
			If BinaryMid($bFrameData, $ibyte-1, 1) <> Binary("0xFF") Then
				$bFrameData_Temp &= BinaryMid($bFrameData, $ibyte, 1)
			EndIf
		Else
			$bFrameData_Temp &= BinaryMid($bFrameData, $ibyte, 1)
		EndIf

	Next

	$bFrameData = $bFrameData_Temp

EndFunc   ;==>_h_ID3v2Frame_RemoveUnsynchronisation
Func _h_ID3v2_GetFrameT000_TZZZ(ByRef $bFrameData)
	;---------------------------------------------------------------------------------
	;<Header for 'Text information frame', ID: "T000" - "TZZZ", excluding "TXXX">
	;Text Encoding                $xx
	;Information                  <text string according to encoding>

	;ID3v2.2
	;Text information identifier  "T00" - "TZZ" , excluding "TXX"
	;Text encoding                $xx
	;Information                  <textstring>
	;---------------------------------------------------------------------------------
	;Information | TextEncoding

	Local $aFrameInfo[3]
	$aFrameInfo[0] = 2

	$aFrameInfo[1] = _h_ID3v2_DecodeTextToString(BinaryMid($bFrameData, 1, 1), BinaryMid($bFrameData, 2)) ;Information
	$aFrameInfo[2] = "0x" & Hex(BinaryMid($bFrameData, 1, 1), 2) ;Text Encoding

	Return $aFrameInfo
EndFunc   ;==>_h_ID3v2_GetFrameT000_TZZZ
Func _h_ID3v2_CreateFrameT000_TZZZ($sInformation, $iTextEncoding = 0)
	;---------------------------------------------------------------------------------
	;<Header for 'Text information frame', ID: "T000" - "TZZZ",
	;excluding "TXXX" described in 4.2.2.>
	;Text Encoding                $xx
	;Information                  <text string according to encoding>
	;---------------------------------------------------------------------------------

	Local $bFrameData = Binary("0x0" & String($iTextEncoding))
	$bFrameData &= _h_ID3v2_EncodeStringToBinary($iTextEncoding, $sInformation)
	Return $bFrameData

EndFunc   ;==>_h_ID3v2_CreateFrameT000_TZZZ
Func _h_ID3v2_GetFrameTXXX(ByRef $bFrameData)
	;---------------------------------------------------------------------------------
	;<Header for 'User defined text information frame', ID: "TXXX">
	;Text encoding     $xx
	;Description       <text string according to encoding> $00 (00)
	;Value             <text string according to encoding>
	;---------------------------------------------------------------------------------
	;Value | Description | TextEncoding

	Local $bText_Encoding, $sDescription, $sValue, $iDescriptionEndIndex
	Local $aFrameInfo[4]
	$aFrameInfo[0] = 3

	$bText_Encoding = BinaryMid($bFrameData, 1, 1)
	$iDescriptionEndIndex = StringInStr(BinaryToString(BinaryMid($bFrameData, 2)), Chr(0))
	$sDescription = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, 2, $iDescriptionEndIndex - 1))
	$sValue = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, $iDescriptionEndIndex + 2))



	$aFrameInfo[1] = $sValue
	$aFrameInfo[2] = $sDescription
	$aFrameInfo[3] = "0x" & Hex($bText_Encoding, 2)

	Return $aFrameInfo
EndFunc   ;==>_h_ID3v2_GetFrameTXXX
Func _h_ID3v2_CreateFrameTXXX($sValue, $sDescription = "", $iTextEncoding = 0)
	;---------------------------------------------------------------------------------
	;<Header for 'User defined text information frame', ID: "TXXX">
	;Text encoding     $xx
	;Description       <text string according to encoding> $00 (00)
	;Value             <text string according to encoding>
	;---------------------------------------------------------------------------------

	Local $bFrameData = Binary("0x0" & String($iTextEncoding))
	$bFrameData &= _h_ID3v2_EncodeStringToBinary($iTextEncoding, $sDescription) & Binary("0x00")
	$bFrameData &= _h_ID3v2_EncodeStringToBinary($iTextEncoding, $sValue)
	Return $bFrameData

EndFunc   ;==>_h_ID3v2_CreateFrameTXXX
Func _h_ID3v2_GetFrameW000_WZZZ(ByRef $bFrameData)
	;---------------------------------------------------------------------------------
	;<Header for 'URL link frame', ID: "W000" - "WZZZ", excluding "WXXX" described in 4.3.2.>
	;URL              <text string>
	;If nothing else is said, strings, including numeric strings and URLs
	;[URL], are represented as ISO-8859-1 [ISO-8859-1] characters in the
	;range $20 - $FF.
	;---------------------------------------------------------------------------------

	Local $bText_Encoding = Binary(Chr(0))

	$sFrameString = _h_ID3v2_DecodeTextToString($bText_Encoding, $bFrameData)

	Return $sFrameString

EndFunc   ;==>_h_ID3v2_GetFrameW000_WZZZ
Func _h_ID3v2_CreateFrameW000_WZZZ($sURL)
	;---------------------------------------------------------------------------------
	;<Header for 'URL link frame', ID: "W000" - "WZZZ", excluding "WXXX" described in 4.3.2.>
	;URL              <text string>
	;If nothing else is said, strings, including numeric strings and URLs
	;[URL], are represented as ISO-8859-1 [ISO-8859-1] characters in the
	;range $20 - $FF.
	;---------------------------------------------------------------------------------

	Local $bFrameData
	$bFrameData = _h_ID3v2_EncodeStringToBinary(0, $sURL)
	Return $bFrameData

EndFunc   ;==>_h_ID3v2_CreateFrameW000_WZZZ
Func _h_ID3v2_GetFrameWXXX(ByRef $bFrameData)
	;---------------------------------------------------------------------------------
	;<Header for 'User defined URL link frame', ID: "WXXX">
	;Text encoding     $xx
	;Description       <text string according to encoding> $00 (00)
	;URL               <text string>
	;---------------------------------------------------------------------------------
	;URL | Description | TextEncoding

	Local $bText_Encoding, $sDescription, $sURL, $iDescriptionEndIndex
	Local $aFrameInfo[4]
	$aFrameInfo[0] = 3

	$bText_Encoding = BinaryMid($bFrameData, 1, 1)
	$iDescriptionEndIndex = StringInStr(BinaryToString(BinaryMid($bFrameData, 2)), Chr(0))
	$sDescription = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, 2, $iDescriptionEndIndex - 1))
	$sURL = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, 2 + $iDescriptionEndIndex))

	$aFrameInfo[1] = $sURL
	$aFrameInfo[2] = $sDescription
	$aFrameInfo[3] = "0x" & Hex($bText_Encoding, 2)

	Return $aFrameInfo
EndFunc   ;==>_h_ID3v2_GetFrameWXXX
Func _h_ID3v2_CreateFrameWXXX($sURL, $sDescription = "", $iTextEncoding = 0)
	;---------------------------------------------------------------------------------
	;<Header for 'User defined URL link frame', ID: "WXXX">
	;Text encoding     $xx
	;Description       <text string according to encoding> $00 (00)
	;URL               <text string>
	;---------------------------------------------------------------------------------

	Local $bFrameData = Binary("0x0" & String($iTextEncoding))
	$bFrameData &= _h_ID3v2_EncodeStringToBinary($iTextEncoding, $sDescription) & Binary("0x00")
	$bFrameData &= _h_ID3v2_EncodeStringToBinary($iTextEncoding, $sURL)
	Return $bFrameData

EndFunc   ;==>_h_ID3v2_CreateFrameWXXX
Func _h_ID3v2_GetFrameCOMM(ByRef $bFrameData)
	;Newline characters are allowed in the comment text string. There may be more than one
	;comment frame in each tag, but only one with the same language and content descriptor.
	;Many of my files have c0 as content descrip. MP3TagPro reads content descrip. as comment text
	;MP3Tag reads content desrip. as part of FrameID (Comment C0) but adds more comment with same content descrip.
	;---------------------------------------------------------------------------------
	;<Header for 'Comment', ID: "COMM">
	;Text encoding          $xx
	;Language               $xx xx xx
	;Short content descrip. <text string according to encoding> $00 (00)
	;The actual text        <full text string according to encoding
	;---------------------------------------------------------------------------------
	;CommentText | Description | Language | TextEncoding

	Local $bText_Encoding, $sDescription, $sLanguage, $sCommentText, $iDescriptionEndIndex
	Local $aFrameInfo[5]
	$aFrameInfo[0] = 4

	$bText_Encoding = BinaryMid($bFrameData, 1, 1)
	$sLanguage = BinaryToString(BinaryMid($bFrameData, 2, 3))
	If $sLanguage <> "eng" Then
		;MsgBox(0,"Text may not be in English",$Language)
		;text may not be in English
	EndIf

	;Find the $00 at the end of Short content descrip.
	$iDescriptionEndIndex = StringInStr(BinaryToString(BinaryMid($bFrameData, 5)), Chr(0))

	;Decode the Text
	$sDescription = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, 5, $iDescriptionEndIndex - 4))
	$sCommentText = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, 5 + $iDescriptionEndIndex))

	$aFrameInfo[1] = $sCommentText
	$aFrameInfo[2] = $sDescription
	$aFrameInfo[3] = $sLanguage
	$aFrameInfo[4] = "0x" & Hex($bText_Encoding, 2)


	Return $aFrameInfo

EndFunc   ;==>_h_ID3v2_GetFrameCOMM
Func _h_ID3v2_CreateFrameCOMM($sText, $sDescription = "", $sLanguage = "eng", $iTextEncoding = 0)
	;---------------------------------------------------------------------------------
	;<Header for 'Comment', ID: "COMM">
	;Text encoding          $xx
	;Language               $xx xx xx
	;Short content descrip. <text string according to encoding> $00 (00)
	;The actual text        <full text string according to encoding
	;---------------------------------------------------------------------------------

	Local $bFrameData = Binary("0x0" & String($iTextEncoding))
	$bFrameData &= _h_ID3v2_EncodeStringToBinary($iTextEncoding, $sLanguage)
	$bFrameData &= _h_ID3v2_EncodeStringToBinary($iTextEncoding, $sDescription) & Binary("0x00")
	$bFrameData &= _h_ID3v2_EncodeStringToBinary($iTextEncoding, $sText)
	Return $bFrameData

EndFunc   ;==>_h_ID3v2_CreateFrameCOMM
Func _h_ID3v2_GetFrameAPIC(ByRef $bFrameData)
	;---------------------------------------------------------------------------------
	;ID3v2.3+ <Header for 'Attached picture', ID: "APIC">
	;Text encoding      $xx
	;MIME type          <text string> $00
	;Picture type       $xx
	;Description        <text string according to encoding> $00 (00)
	;Picture data       <binary data>

	;ID3v2.2 <Header for 'Attached picture', ID: "PIC">
	;Text encoding      $xx
	;Image format       $xx xx xx  				{Image format is preferably "PNG" [PNG] or "JPG" [JFIF]}
	;Picture type       $xx
	;Description        <textstring> $00 (00)
	;Picture data       <binary data>
	;---------------------------------------------------------------------------------
	;PictureFileName | Description | PictureType | MIMEType | TextEncoding

	Local $sPictureFileName, $sDescription, $iPictureType, $sMIMEType, $bText_Encoding, $iMIMETypeEndIndex, $iDescriptionEndIndex, $iBinaryStartIndex
	Local $aFrameInfo[6]
	$aFrameInfo[0] = 5

	$sPictureFileName = @ScriptDir & "\" & "AlbumArt"
	$sID3_TagFiles_Global &= $sPictureFileName & "|"
;~ 	MsgBox(0,"APIC",BinaryMid($bFrameData,1,32))

	$bText_Encoding = BinaryMid($bFrameData, 1, 1)

	;added this to handle ID3v2.2 PIC frame
	Local $iID3v2_Version = _ID3v2Tag_GetVersion()
	If StringInStr($iID3v2_Version, "2.") Then ;ID3v2.2.X
		$iMIMETypeEndIndex = 3
		$sMIMEType = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, 2, 3))
;~ 		MsgBox(0,"$sMIMEType",$sMIMEType)
	Else
		$iMIMETypeEndIndex = StringInStr(BinaryToString(BinaryMid($bFrameData, 2)), Chr(0))
		$sMIMEType = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, 2, $iMIMETypeEndIndex - 1))
		;Added this because Foobar2000 adds a field 0x01246600, not sure what this is for
		;Should these bytes be removed?? so that other software can read this APIC Frame?
		If StringInStr($sMIMEType, "image") = 0 Then
			Local $iMIMETypeBeginIndex = $iMIMETypeEndIndex + 2
			;find the next occurance of 0x00
			$iMIMETypeEndIndex = StringInStr(BinaryToString(BinaryMid($bFrameData, 2)), Chr(0), 0, 2)
			$sMIMEType = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, $iMIMETypeBeginIndex, $iMIMETypeEndIndex - $iMIMETypeBeginIndex + 1))
		EndIf
;~ 		MsgBox(0,"$sMIMEType",$sMIMEType)
	EndIf


	$iPictureType = BinaryMid($bFrameData, $iMIMETypeEndIndex + 2, 1)

	$iDescriptionEndIndex = StringInStr(BinaryToString(BinaryMid($bFrameData, $iMIMETypeEndIndex + 3)), Chr(0))
	$sDescription = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, $iMIMETypeEndIndex + 3, $iDescriptionEndIndex - 1))
	$iBinaryStartIndex = $iMIMETypeEndIndex + $iDescriptionEndIndex + 3

	;Check $iBinaryStartIndex shows the 0xFF 0xD8 for Start of image for JPEG SOI Segment
	If StringInStr($sMIMEType, "jpg") Or StringInStr($sMIMEType, "jpeg") Then
		Local $iBinaryStartIndex_Test = $iBinaryStartIndex, $SOI_NotFound = False
		While BinaryMid($bFrameData, $iBinaryStartIndex_Test, 2) <> Binary("0xFFD8")
			$iBinaryStartIndex_Test += 1
			If BinaryLen(BinaryMid($bFrameData, $iBinaryStartIndex_Test)) < 10 Then
				$SOI_NotFound = True
				ExitLoop
			EndIf
		WEnd
		If $SOI_NotFound = False Then
			If $iBinaryStartIndex <> $iBinaryStartIndex_Test Then
				$sDescription = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, $iMIMETypeEndIndex + 3, ($iBinaryStartIndex_Test - $iMIMETypeEndIndex - 3) - 1))
			EndIf
			$iBinaryStartIndex = $iBinaryStartIndex_Test
		EndIf
	EndIf


	If StringInStr($sMIMEType, "jpg") Or StringInStr($sMIMEType, "jpeg") Then
		$sPictureFileName &= ".jpg"
		$sID3_TagFiles_Global &= $sPictureFileName & "|"
	ElseIf StringInStr($sMIMEType, "png") Then
		$sPictureFileName &= ".png"
		$sID3_TagFiles_Global &= $sPictureFileName & "|"
	Else
		$sPictureFileName = "File Type Unknown"
	EndIf



	;Read Picture data to file
	;****************************************************************************************
	Local $PicFile_h = FileOpen($sPictureFileName, 2) ;Open for write and erase existing
	$WriteError = FileWrite($PicFile_h, BinaryMid($bFrameData, $iBinaryStartIndex))
	FileClose($PicFile_h)
	;****************************************************************************************


	$aFrameInfo[1] = $sPictureFileName
	$aFrameInfo[2] = $sDescription
	$aFrameInfo[3] = $iPictureType
	$aFrameInfo[4] = $sMIMEType
	$aFrameInfo[5] = "0x" & Hex($bText_Encoding, 2)

;~ 	_ArrayDisplay($aFrameInfo)

	Return $aFrameInfo;$sAlbumArtFilename & Chr(0) & Number($bPicture_Type)

EndFunc   ;==>_h_ID3v2_GetFrameAPIC
Func _h_ID3v2_CreateFrameAPIC($sPictureFileName, $sDescription = "", $iPictureType = 0, $sMIMEType = -1, $iTextEncoding = 0)
	;---------------------------------------------------------------------------------
	;<Header for 'Attached picture', ID: "APIC">
	;Text encoding      $xx
	;MIME type          <text string> $00
	;Picture type       $xx
	;Description        <text string according to encoding> $00 (00)
	;Picture data       <binary data>
	;---------------------------------------------------------------------------------
;~ 		Picture type:
;~ 			$00 Other
;~ 			$01 32x32 pixels 'file icon' (PNG only)
;~ 			$02 Other file icon
;~ 			$03 Cover (front)
;~ 			$04 Cover (back)
;~ 			$05 Leaflet page
;~ 			$06 Media (e.g. lable side of CD)
;~ 			$07 Lead artist/lead performer/soloist
;~ 			$08 Artist/performer
;~ 			$09 Conductor
;~ 			$0A Band/Orchestra
;~ 			$0B Composer
;~ 			$0C Lyricist/text writer
;~ 			$0D Recording Location
;~ 			$0E During recording
;~ 			$0F During performance
;~ 			$10 Movie/video screen capture
;~ 			$11 A bright coloured fish
;~ 			$12 Illustration
;~ 			$13 Band/artist logotype
;~ 			$14 Publisher/Studio logotype

	Local $bFrameData = Binary("0x0" & String($iTextEncoding))

	If $sMIMEType = -1 Then
		Local $pos = StringInStr($sPictureFileName, ".", 0, -1) ;search for . from right
		Local $szExt = StringRight($sPictureFileName, StringLen($sPictureFileName) - ($pos - 1))
		If StringInStr($szExt, "jpg") Or StringInStr($szExt, "jpeg") Then
			$sMIMEType = "image/jpeg"
		ElseIf StringInStr($szExt, "png") Then
			$sMIMEType = "image/png"
		Else
			$sMIMEType = ""
		EndIf
	EndIf
	$bFrameData &= _h_ID3v2_EncodeStringToBinary(0, $sMIMEType) & Binary("0x00")

	$bFrameData &= Binary("0x" & Hex($iPictureType, 2))

	$bFrameData &= _h_ID3v2_EncodeStringToBinary($iTextEncoding, $sDescription) & Binary("0x00")

	$PicFile_h = FileOpen($sPictureFileName, 16) ;force binary
	$bFrameData &= FileRead($PicFile_h)
	FileClose($PicFile_h)

	Return $bFrameData

EndFunc   ;==>_h_ID3v2_CreateFrameAPIC
Func _h_ID3v2_GetFrameUSLT(ByRef $bFrameData)
	;---------------------------------------------------------------------------------
	;<Header for 'Unsynchronised lyrics/text transcription', ID: "USLT">
	;Text encoding        $xx
	;Language             $xx xx xx
	;Content descriptor   <text string according to encoding> $00 (00)
	;Lyrics/text          <full text string according to encoding>
	;---------------------------------------------------------------------------------
	;LyricsFilename | Description | Language | TextEncoding

	Local $bText_Encoding, $sDescription, $sLanguage, $sLyricsFilename, $hLyricFile, $sLyricsText, $iDescriptionEndIndex
	Local $aFrameInfo[5]
	$aFrameInfo[0] = 4

	$sLyricsFilename = @ScriptDir & "\" & "SongLyrics.txt"
	$sID3_TagFiles_Global &= $sLyricsFilename & "|"

	$bText_Encoding = BinaryMid($bFrameData, 1, 1)
	$sLanguage = BinaryToString(BinaryMid($bFrameData, 2, 3))
	$iDescriptionEndIndex = StringInStr(BinaryToString(BinaryMid($bFrameData, 5)), Chr(0))
	$sDescription = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, 5, $iDescriptionEndIndex - 1))
	$sLyricsText = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, $iDescriptionEndIndex + 5))

	$hLyricFile = FileOpen($sLyricsFilename, 2) ;Open for write and erase existing
	FileWrite($hLyricFile, $sLyricsText)
	FileClose($hLyricFile)


	$aFrameInfo[1] = $sLyricsFilename
	$aFrameInfo[2] = $sDescription
	$aFrameInfo[3] = $sLanguage
	$aFrameInfo[4] = "0x" & Hex($bText_Encoding, 2)
	Return $aFrameInfo
EndFunc   ;==>_h_ID3v2_GetFrameUSLT
Func _h_ID3v2_CreateFrameUSLT($sLyricsFilename, $sDescription = "", $sLanguage = "eng", $iTextEncoding = 0)
	;---------------------------------------------------------------------------------
	;<Header for 'Unsynchronised lyrics/text transcription', ID: "USLT">
	;Text encoding        $xx
	;Language             $xx xx xx
	;Content descriptor   <text string according to encoding> $00 (00)
	;Lyrics/text          <full text string according to encoding>
	;---------------------------------------------------------------------------------

	Local $sLyrics = ""
	If FileExists($sLyricsFilename) Then
		$sLyrics = FileRead($sLyricsFilename)
	EndIf


	Local $bFrameData = Binary("0x0" & String($iTextEncoding))
	$bFrameData &= _h_ID3v2_EncodeStringToBinary($iTextEncoding, $sLanguage)
	$bFrameData &= _h_ID3v2_EncodeStringToBinary($iTextEncoding, $sDescription) & Binary("0x00")
	$bFrameData &= _h_ID3v2_EncodeStringToBinary($iTextEncoding, $sLyrics)

;~ 	MsgBox(0,"$bFrameData",$bFrameData)
	Return $bFrameData

EndFunc   ;==>_h_ID3v2_CreateFrameUSLT
Func _h_ID3v2_GetFramePCNT(ByRef $bFrameData)
	;---------------------------------------------------------------------------------
	;<Header for 'Play counter', ID: "PCNT">
	;Counter $xx xx xx xx (xx ...)
	;This is simply a counter of the number of times a file has been
	;played. The value is increased by one every time the file begins to
	;play. There may only be one "PCNT" frame in each tag. When the
	;counter reaches all one's, one byte is inserted in front of the
	;counter thus making the counter eight bits bigger. The counter must
	;be at least 32-bits long to begin with.
	;---------------------------------------------------------------------------------
	;Counter

	Local $iCounter = Dec(Hex(BinaryMid($bFrameData, 1)))
	;Hex function can only work up to 16 bytes
	;Dec will only work up to 64 bit signed integer

	Return $iCounter
EndFunc   ;==>_h_ID3v2_GetFramePCNT
Func _h_ID3v2_CreateFramePCNT($iCounter = 0)
	;---------------------------------------------------------------------------------
	;<Header for 'Play counter', ID: "PCNT">
	;Counter $xx xx xx xx (xx ...)
	;This is simply a counter of the number of times a file has been
	;played. The value is increased by one every time the file begins to
	;play. There may only be one "PCNT" frame in each tag. When the
	;counter reaches all one's, one byte is inserted in front of the
	;counter thus making the counter eight bits bigger. The counter must
	;be at least 32-bits long to begin with.
	;---------------------------------------------------------------------------------

	Local $bFrameData = Binary("0x" & Hex($iCounter))
	;Hex function can only work up to 16 bytes

	Return $bFrameData

EndFunc   ;==>_h_ID3v2_CreateFramePCNT
Func _h_ID3v2_GetFrameUFID(ByRef $bFrameData)
	;---------------------------------------------------------------------------------
	;<Header for 'Unique file identifier', ID: "UFID">
	;Owner identifier        <text string> $00
	;Identifier              <up to 64 bytes binary data>
	;This frame's purpose is to be able to identify the audio file in a database that may contain
	;more information relevant to the content. Since standardisation of such a database is beyond
	;this document, all frames begin with a null-terminated string with a URL [URL] containing an
	;email address, or a link to a location where an email address can be found, that belongs to
	;the organisation responsible for this specific database implementation. Questions regarding the
	;database should be sent to the indicated email address. The URL should not be used for the actual
	;database queries. The string "http://www.id3.org/dummy/ufid.html" should be used for tests. Software
	;that isn't told otherwise may safely remove such frames. The 'Owner identifier' must be non-empty
	;(more than just a termination). The 'Owner identifier' is then followed by the actual identifier,
	;which may be up to 64 bytes. There may be more than one "UFID" frame in a tag, but only one with
	;the same 'Owner identifier'.
	;---------------------------------------------------------------------------------
	;OwnerIdentifier | Identifier
	Local $aFrameInfo[3]
	$aFrameInfo[0] = 2

	Local $bText_Encoding = Binary(Chr(0))
	Local $iTextEndIndex = StringInStr(BinaryToString(BinaryMid($bFrameData, 1)), Chr(0))
	Local $sOwnerIdentifier = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, 1, $iTextEndIndex - 1))
	Local $bIdentifier = BinaryMid($bFrameData, $iTextEndIndex + 1)

	$aFrameInfo[1] = $sOwnerIdentifier
	$aFrameInfo[2] = $bIdentifier
	Return $aFrameInfo
EndFunc   ;==>_h_ID3v2_GetFrameUFID
Func _h_ID3v2_CreateFrameUFID($bIdentifier, $sOwnerIdentifier = "http://www.id3.org/dummy/ufid.html")
	;---------------------------------------------------------------------------------
	;<Header for 'Unique file identifier', ID: "UFID">
	;Owner identifier        <text string> $00
	;Identifier              <up to 64 bytes binary data>
	;This frame's purpose is to be able to identify the audio file in a database that may contain
	;more information relevant to the content. Since standardisation of such a database is beyond
	;this document, all frames begin with a null-terminated string with a URL [URL] containing an
	;email address, or a link to a location where an email address can be found, that belongs to
	;the organisation responsible for this specific database implementation. Questions regarding the
	;database should be sent to the indicated email address. The URL should not be used for the actual
	;database queries. The string "http://www.id3.org/dummy/ufid.html" should be used for tests. Software
	;that isn't told otherwise may safely remove such frames. The 'Owner identifier' must be non-empty
	;(more than just a termination). The 'Owner identifier' is then followed by the actual identifier,
	;which may be up to 64 bytes. There may be more than one "UFID" frame in a tag, but only one with
	;the same 'Owner identifier'.
	;---------------------------------------------------------------------------------

	Local $bFrameData = _h_ID3v2_EncodeStringToBinary(0, $sOwnerIdentifier) & Binary("0x00")
	$bFrameData &= $bIdentifier
	Return $bFrameData

EndFunc   ;==>_h_ID3v2_CreateFrameUFID
Func _h_ID3v2_GetFramePOPM(ByRef $bFrameData)
	;---------------------------------------------------------------------------------
	;<Header for 'Popularimeter', ID: "POPM">
	;Email to user   <text string> $00
	;Rating          $xx
	;Counter         $xx xx xx xx (xx ...)
	;If nothing else is said, strings, including numeric strings and URLs
	;[URL], are represented as ISO-8859-1 [ISO-8859-1] characters in the range $20 - $FF.
	;The rating is 1-255 where 1 is worst and 255 is best. 0 is unknown. If no personal counter is
	;wanted it may be omitted.  When the counter reaches all one's, one byte is inserted
	;in front of the counter thus making the counter eight bits bigger.
	;---------------------------------------------------------------------------------
	;Rating | EmailToUser | Counter
	Local $aFrameInfo[4]
	$aFrameInfo[0] = 3

	Local $bText_Encoding = Binary(Chr(0))
	Local $iTextEndIndex = StringInStr(BinaryToString(BinaryMid($bFrameData, 1)), Chr(0))
	Local $sEmailToUser = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, 1, $iTextEndIndex - 1))
	Local $bRating = BinaryMid($bFrameData, $iTextEndIndex + 1, 1)
	Local $bCounter = BinaryMid($bFrameData, $iTextEndIndex + 2)

	$aFrameInfo[1] = Dec(Hex($bRating))
	$aFrameInfo[2] = $sEmailToUser
	$aFrameInfo[3] = Dec(Hex($bCounter))
	Return $aFrameInfo
EndFunc   ;==>_h_ID3v2_GetFramePOPM
Func _h_ID3v2_CreateFramePOPM($bRating, $sEmailToUser = "", $iCounter = 0)
	;---------------------------------------------------------------------------------
	;<Header for 'Popularimeter', ID: "POPM">
	;Email to user   <text string> $00
	;Rating          $xx
	;Counter         $xx xx xx xx (xx ...)
	;If nothing else is said, strings, including numeric strings and URLs
	;[URL], are represented as ISO-8859-1 [ISO-8859-1] characters in the range $20 - $FF.
	;The rating is 1-255 where 1 is worst and 255 is best. 0 is unknown. If no personal counter is
	;wanted it may be omitted.  When the counter reaches all one's, one byte is inserted
	;in front of the counter thus making the counter eight bits bigger.
	;---------------------------------------------------------------------------------

	Local $bFrameData = _h_ID3v2_EncodeStringToBinary(0, $sEmailToUser) & Binary("0x00")
	$bFrameData &= BinaryMid($bRating, 1, 1) ;limit to one byte
	$bFrameData &= Binary("0x" & Hex($iCounter))
	;Hex function can only work up to 16 bytes

	MsgBox(0,"$bRating",$bRating)

	Return $bFrameData
EndFunc   ;==>_h_ID3v2_CreateFramePOPM
Func _h_ID3v2_GetFramePRIV(ByRef $bFrameData)
	;---------------------------------------------------------------------------------
	;<Header for 'Private frame', ID: "PRIV">
	;Owner identifier <text string> $00
	;The private data <binary data>
	;The 'Owner identifier' is a null-terminated string with a URL [URL] containing an email
	;address, or a link to a location where an email address can be found, that belongs to the
	;organisation responsible for the frame. Questions regarding the frame should be sent to the
	;indicated email address. The tag may contain more than one "PRIV" frame but only with different
	;contents. It is recommended to keep the number of "PRIV" frames as low as possible.
	;---------------------------------------------------------------------------------
	;OwnerIdentifier | PrivateData
	Local $aFrameInfo[3]
	$aFrameInfo[0] = 2

	Local $bText_Encoding = Binary(Chr(0))
	Local $iTextEndIndex = StringInStr(BinaryToString(BinaryMid($bFrameData, 1)), Chr(0))
	Local $sOwnerIdentifier = _h_ID3v2_DecodeTextToString($bText_Encoding, BinaryMid($bFrameData, 1, $iTextEndIndex - 1))
	Local $bPrivateData = BinaryMid($bFrameData, $iTextEndIndex + 1)

	$aFrameInfo[1] = $sOwnerIdentifier
	$aFrameInfo[2] = $bPrivateData
	Return $aFrameInfo
EndFunc   ;==>_h_ID3v2_GetFramePRIV
Func _h_ID3v2_CreateFramePRIV($sOwnerIdentifier, $bPrivateData = 0)
	;---------------------------------------------------------------------------------
	;<Header for 'Private frame', ID: "PRIV">
	;Owner identifier <text string> $00
	;The private data <binary data>
	;The 'Owner identifier' is a null-terminated string with a URL [URL] containing an email
	;address, or a link to a location where an email address can be found, that belongs to the
	;organisation responsible for the frame. Questions regarding the frame should be sent to the
	;indicated email address. The tag may contain more than one "PRIV" frame but only with different
	;contents. It is recommended to keep the number of "PRIV" frames as low as possible.
	;---------------------------------------------------------------------------------

	Local $bFrameData = _h_ID3v2_EncodeStringToBinary(0, $sOwnerIdentifier) & Binary("0x00")
	If Not IsBinary($bPrivateData) Then
		$bPrivateData = Binary($bPrivateData)
	EndIf
	$bFrameData &= $bPrivateData
	Return $bFrameData

EndFunc   ;==>_h_ID3v2_CreateFramePRIV
Func _h_ID3v2_GetFrameRGAD(ByRef $bFrameData)
	;---------------------------------------------------------------------------------
	;<Header for 'Replay Gain Adjustment', ID: "RGAD">
	;Peak Amplitude                          $xx $xx $xx $xx
	;Radio Replay Gain Adjustment            $xx $xx
	;Audiophile Replay Gain Adjustment       $xx $xx

	;Header consists of:
	;Frame ID                $52 $47 $41 $44 = "RGAD"
	;Size                    $00 $00 $00 $08
	;Flags                   $40 $00         (%01000000 %00000000)

	;In the RGAD frame, the flags state that the frame should be preserved if the ID3v2
	;tag is altered, but discarded if the audio data is altered.
	;---------------------------------------------------------------------------------
	;PeakAmplitude | RadioReplayGainAdj | AudiophileReplayGainAdj
	Local $aFrameInfo[4]
	$aFrameInfo[0] = 3

	Local $bPeakAmplitude = BinaryMid($bFrameData, 1, 4)
	Local $bRadioReplayGainAdj = BinaryMid($bFrameData, 5, 2)
	Local $bAudiophileReplayGainAdj = BinaryMid($bFrameData, 7, 2)

	$aFrameInfo[1] = $bPeakAmplitude
	$aFrameInfo[2] = $bRadioReplayGainAdj
	$aFrameInfo[3] = $bAudiophileReplayGainAdj
	Return $aFrameInfo
EndFunc   ;==>_h_ID3v2_GetFrameRGAD



Func _h_ID3v2_DecodeTextToString($bText_Encoding_Description_Byte, $bFrameTextBytes)

	;From ID3v2.4 TagSpec
;~ 		If nothing else is said, strings, including numeric strings and URLs
;~ 		[URL], are represented as ISO-8859-1 [ISO-8859-1] characters in the
;~ 		range $20 - $FF. Such strings are represented in frame descriptions
;~ 		as <text string>, or <full text string> if newlines are allowed. If
;~ 		nothing else is said newline character is forbidden. In ISO-8859-1 a
;~ 		newline is represented, when allowed, with $0A only.
;~ 		Frames that allow different types of text encoding contains a text
;~ 		encoding description byte. Possible encodings:
;~ 			$00   ISO-8859-1 [ISO-8859-1]. Terminated with $00.
;~ 			$01   UTF-16 [UTF-16] encoded Unicode [UNICODE] with BOM. All strings in the same frame SHALL have the same byteorder. Terminated with $00 00.
;~ 			$02   UTF-16BE [UTF-16] encoded Unicode [UNICODE] without BOM. Terminated with $00 00.
;~ 			$03   UTF-8 [UTF-8] encoded Unicode [UNICODE]. Terminated with $00.
;~ 		Strings dependent on encoding are represented in frame descriptions
;~ 		as <text string according to encoding>, or <full text string
;~ 		according to encoding> if newlines are allowed. Any empty strings of
;~ 		type $01 which are NULL-terminated may have the Unicode BOM followed
;~ 		by a Unicode NULL ($FF FE 00 00 or $FE FF 00 00).

	Local $BinaryToString_Flag = 1, $bUnicode_BOM, $BinaryToString_Flag, $iStartByte = 2 ;ANSI
;~ 		1, Default binary data is taken to be ANSI
;~ 		2, binary data is taken to be UTF16 Little Endian (BOM = FF FE)
;~ 		3, binary data is taken to be UTF16 Big Endian (BOM = FE FF)
;~ 		4, binary data is taken to be UTF8 (BOM = EF BB BF)
;~ 		NOTE: UTF8 is recommended not to use BOM in which case the default to read as ANSI works fine.


	Local $iText_Encoding_Description_Byte = Int($bText_Encoding_Description_Byte)
	Local $sFrameString = ""

	;check for NULL at begining of text
	;Found in some COMM tags
	For $ibin = 1 To BinaryLen($bFrameTextBytes)
		If BinaryToString(BinaryMid($bFrameTextBytes, 1, 1)) == Chr(0) Then
			$bFrameTextBytes = BinaryMid($bFrameTextBytes, 2)
		Else
			ExitLoop
		EndIf
	Next



	Switch $iText_Encoding_Description_Byte
		Case 0
			$BinaryToString_Flag = 1 ;ANSI
			$iStartByte = 1
		Case 1
			$bUnicode_BOM = BinaryMid($bFrameTextBytes, 1, 2)
			If $bUnicode_BOM = "0xFFFE" Then
				$BinaryToString_Flag = 2 ;UTF16 Little Endian
				$iStartByte = 3
			Else
				$BinaryToString_Flag = 1 ;ANSI
				$iStartByte = 1
			EndIf
		Case 2
			$bUnicode_BOM = BinaryMid($bFrameTextBytes, 1, 2)
			If $bUnicode_BOM = "0xFEFF" Then
				$BinaryToString_Flag = 3 ;UTF16 Big Endian
				$iStartByte = 3
			Else
				$BinaryToString_Flag = 1 ;ANSI
				$iStartByte = 1
			EndIf
		Case 3
			$bUnicode_BOM = BinaryMid($bFrameTextBytes, 1, 3)
			If StringCompare($bUnicode_BOM, "0xEFBBBF") == 0 Then
				$BinaryToString_Flag = 3 ;UTF8
				$iStartByte = 4
			Else
				$BinaryToString_Flag = 1 ;ANSI
				$iStartByte = 1
			EndIf
		Case Else
			$BinaryToString_Flag = 1 ;Assume ANSI
	EndSwitch
	$sFrameString = BinaryToString(BinaryMid($bFrameTextBytes, $iStartByte), $BinaryToString_Flag)

	Return $sFrameString
EndFunc   ;==>_h_ID3v2_DecodeTextToString
Func _h_ID3v2_EncodeStringToBinary($iText_Encoding_Description_Byte, $sFrameText)
;~ 		Frames that allow different types of text encoding contains a text
;~ 		encoding description byte. Possible encodings:
;~ 			$00   ISO-8859-1 [ISO-8859-1]. Terminated with $00.
;~ 			$01   UTF-16 [UTF-16] encoded Unicode [UNICODE] with BOM. All strings in the same frame SHALL have the same byteorder. Terminated with $00 00.
;~ 			$02   UTF-16BE [UTF-16] encoded Unicode [UNICODE] without BOM. Terminated with $00 00.
;~ 			$03   UTF-8 [UTF-8] encoded Unicode [UNICODE]. Terminated with $00.

;~ 	StringToBinary flag description
;~ 		flag [optional] Changes how the string is stored as binary:
;~ 		flag = 1 (default), binary data is ANSI
;~ 		flag = 2, binary data is UTF16 Little Endian
;~ 		flag = 3, binary data is UTF16 Big Endian
;~ 		flag = 4, binary data is UTF8

	Local $bFrameData
	Switch $iText_Encoding_Description_Byte
		Case 0 ;ISO-8859-1 [ISO-8859-1]. Terminated with $00
			$bFrameData = StringToBinary($sFrameText, 1) ;ANSI
		Case 1 ;UTF-16 [UTF-16] encoded Unicode [UNICODE] with BOM
			$bFrameData = StringToBinary($sFrameText, 2) ;UTF16 Little Endian
		Case 2 ;UTF-16BE [UTF-16] encoded Unicode [UNICODE] without BOM
			$bFrameData = StringToBinary($sFrameText, 3) ;UTF16 Big Endian
		Case 3 ;UTF-8 [UTF-8] encoded Unicode [UNICODE]. Terminated with $00
			$bFrameData = StringToBinary($sFrameText, 4) ;UTF8
		Case Else
			$bFrameData = StringToBinary($sFrameText, 1) ;ANSI
	EndSwitch
	Return $bFrameData

EndFunc   ;==>_h_ID3v2_EncodeStringToBinary
Func _h_ID3v2_ConvertFrameID(ByRef $sFrameID)

	$sFrameID = StringReplace($sFrameID, "AENC", "CRA");	Audio encryption
	$sFrameID = StringReplace($sFrameID, "APIC", "PIC");	Attached picture
	$sFrameID = StringReplace($sFrameID, "COMM", "COM"); 	Comments
	$sFrameID = StringReplace($sFrameID, "EQUA", "EQU"); 	Equalization
	$sFrameID = StringReplace($sFrameID, "ETCO", "ETC"); 	Event timing codes
	$sFrameID = StringReplace($sFrameID, "GEOB", "GEO"); 	General encapsulated object
	$sFrameID = StringReplace($sFrameID, "IPLS", "IPL"); 	Involved people list
	$sFrameID = StringReplace($sFrameID, "LINK", "LNK"); 	Linked information
	$sFrameID = StringReplace($sFrameID, "MCDI", "MCI"); 	Music CD identifier
	$sFrameID = StringReplace($sFrameID, "MLLT", "MLL"); 	MPEG location lookup table
	$sFrameID = StringReplace($sFrameID, "PCNT", "CNT"); 	Play counter
	$sFrameID = StringReplace($sFrameID, "POPM", "POP");	Popularimeter
	$sFrameID = StringReplace($sFrameID, "RBUF", "BUF");	Recommended buffer size
	$sFrameID = StringReplace($sFrameID, "RVAD", "RVA"); 	Relative volume adjustment
	$sFrameID = StringReplace($sFrameID, "RVRB", "REV"); 	Reverb
	$sFrameID = StringReplace($sFrameID, "SYLT", "SLT"); 	Synchronized lyric/text
	$sFrameID = StringReplace($sFrameID, "SYTC", "STC"); 	Synchronized tempo codes
	$sFrameID = StringReplace($sFrameID, "TALB", "TAL"); 	Album/Movie/Show title
	$sFrameID = StringReplace($sFrameID, "TBPM", "TBP"); 	BPM (beats per minute)
	$sFrameID = StringReplace($sFrameID, "TCOM", "TCM"); 	Composer
	$sFrameID = StringReplace($sFrameID, "TCON", "TCO"); 	Content type
	$sFrameID = StringReplace($sFrameID, "TCOP", "TCR"); 	Copyright message
	$sFrameID = StringReplace($sFrameID, "TDAT", "TDA"); 	Date
	$sFrameID = StringReplace($sFrameID, "TDLY", "TDY"); 	Playlist delay
	$sFrameID = StringReplace($sFrameID, "TENC", "TEN"); 	Encoded by
	$sFrameID = StringReplace($sFrameID, "TEXT", "TXT"); 	Lyricist/Text writer
	$sFrameID = StringReplace($sFrameID, "TFLT", "TFT"); 	File type
	$sFrameID = StringReplace($sFrameID, "TIME", "TIM"); 	Time
	$sFrameID = StringReplace($sFrameID, "TIT1", "TT1"); 	Content group description
	$sFrameID = StringReplace($sFrameID, "TIT2", "TT2"); 	Title/songname/content description
	$sFrameID = StringReplace($sFrameID, "TIT3", "TT3"); 	Subtitle/Description refinement
	$sFrameID = StringReplace($sFrameID, "TKEY", "TKE"); 	Initial key
	$sFrameID = StringReplace($sFrameID, "TLAN", "TLA"); 	Language(s)
	$sFrameID = StringReplace($sFrameID, "TLEN", "TLE"); 	Length
	$sFrameID = StringReplace($sFrameID, "TMED", "TMT"); 	Media type
	$sFrameID = StringReplace($sFrameID, "TOAL", "TOT"); 	Original album/movie/show title
	$sFrameID = StringReplace($sFrameID, "TOFN", "TOF"); 	Original filename
	$sFrameID = StringReplace($sFrameID, "TOLY", "TOL"); 	Original lyricist(s)/text writer(s)
	$sFrameID = StringReplace($sFrameID, "TOPE", "TOA"); 	Original artist(s)/performer(s)
	$sFrameID = StringReplace($sFrameID, "TORY", "TOR"); 	Original release year
	$sFrameID = StringReplace($sFrameID, "TPE1", "TP1"); 	Lead performer(s)/Soloist(s)
	$sFrameID = StringReplace($sFrameID, "TPE2", "TP2"); 	Band/orchestra/accompaniment
	$sFrameID = StringReplace($sFrameID, "TPE3", "TP3"); 	Conductor/performer refinement
	$sFrameID = StringReplace($sFrameID, "TPE4", "TP4"); 	Interpreted, remixed, or otherwise modified by
	$sFrameID = StringReplace($sFrameID, "TPOS", "TPA"); 	Part of a set
	$sFrameID = StringReplace($sFrameID, "TPUB", "TPB"); 	Publisher
	$sFrameID = StringReplace($sFrameID, "TRCK", "TRK"); 	Track number/Position in set
	$sFrameID = StringReplace($sFrameID, "TRDA", "TRD"); 	Recording dates
	$sFrameID = StringReplace($sFrameID, "TSIZ", "TSI"); 	Size
	$sFrameID = StringReplace($sFrameID, "TSRC", "TRC");	ISRC - International Standard Recording Code
	$sFrameID = StringReplace($sFrameID, "TSSE", "TSS"); 	Software/Hardware and settings used for encoding
	$sFrameID = StringReplace($sFrameID, "TYER", "TYE"); 	Year
	$sFrameID = StringReplace($sFrameID, "TXXX", "TXX"); 	User defined text information frame
	$sFrameID = StringReplace($sFrameID, "UFID", "UFI");	Unique file identifier
	$sFrameID = StringReplace($sFrameID, "USLT", "ULT");	Unsychronized lyric/text transcription
	$sFrameID = StringReplace($sFrameID, "WCOM", "WCM"); 	Commercial information
	$sFrameID = StringReplace($sFrameID, "WCOP", "WCP"); 	Copyright/Legal information
	$sFrameID = StringReplace($sFrameID, "WOAF", "WAF");	Official audio file webpage
	$sFrameID = StringReplace($sFrameID, "WOAR", "WAR");	Official artist/performer webpage
	$sFrameID = StringReplace($sFrameID, "WOAS", "WAS");	Official audio source webpage
	$sFrameID = StringReplace($sFrameID, "WPUB", "WPB"); 	Publishers official webpage
	$sFrameID = StringReplace($sFrameID, "WXXX", "WXX");	User defined URL link frame


EndFunc   ;==>_h_ID3v2_ConvertFrameID




Func _MPEG_GetFrameHeader($sFilename, $bRawRead = False)
	#cs #ID3.au3 UDF Latest Changes.......: ;================================
		http://www.mp3-tech.org/programmer/frame_header.html
		Frame Definition
		AAAAAAAA AAABBCCD EEEEFFGH IIJJKLMM
		A - Frame Sync 0xFFE0
		B - MPEG Audio version ID
		00 - MPEG Version 2.5 (later extension of MPEG 2)
		01 - reserved
		10 - MPEG Version 2 (ISO/IEC 13818-3)
		11 - MPEG Version 1 (ISO/IEC 11172-3)
		C - Layer description
		00 - reserved
		01 - Layer III
		10 - Layer II
		11 - Layer I
		D - Protection bit
		0 - Protected by CRC (16bit CRC follows header)
		1 - Not protected
		E - Bitrate index
		F - Sampling rate frequency index
		G - Padding bit
		H - Private bit. This one is only informative.
		I - Channel Mode
		J - Mode extension (Only used in Joint stereo)
		K - Copyright
		L - Original
		M - Emphasis
	#ce ;====================================================================

	Local $ByteOffset = 0
	If Not $bRawRead Then
		Local $hfile = FileOpen($sFilename, 16) ;open in binary mode
		Local $bID3v2_TagID = FileRead($hfile, 3)
		If BinaryToString($bID3v2_TagID) == "ID3" Then
			Local $bId3TagHeader = $bID3v2_TagID & FileRead($hfile, 7)
			$ByteOffset = _ID3v2Tag_GetTagSize($bId3TagHeader)
		EndIf
		FileClose($hfile)
	EndIf


	Local $SecondSync = 0
	Local $ThirdSync = 0
	Local $FourthSync = 0
	Local $FirstSync = _h_MPEG_ScanForFrame($sFilename, $ByteOffset)
	Local $EndFirstSyncOffset = $ByteOffset
	Local $FirstSyncFrameLen = _MPEG_GetFrameLengthBytes($FirstSync)
	If $FirstSyncFrameLen > 0 Then
		$ByteOffset = $ByteOffset + $FirstSyncFrameLen + 1 - 4
		If $ByteOffset < FileGetSize($sFilename) Then
			$SecondSync = _h_MPEG_GetNextFrame($sFilename, $ByteOffset)
		Else
			$SecondSync = 0
		EndIf
		$ByteOffset = $ByteOffset + $FirstSyncFrameLen + 1 - 4
		If $ByteOffset < FileGetSize($sFilename) Then
			$ThirdSync = _h_MPEG_GetNextFrame($sFilename, $ByteOffset)
		Else
			$ThirdSync = 0
		EndIf
		$ByteOffset = $ByteOffset + $FirstSyncFrameLen + 1 - 4
		If $ByteOffset < FileGetSize($sFilename) Then
			$FourthSync = _h_MPEG_GetNextFrame($sFilename, $ByteOffset)
		Else
			$FourthSync = 0
		EndIf
	EndIf
	$TryNum = 1
;~ 	MsgBox(0,"TryNum = " & $TryNum,$FirstSync & " , " & $SecondSync & " , " & $ThirdSync & " , " & $FourthSync)

	;TODO: Allow BitRates to be differant
	While (Not _h_MPEG_IsFrameEqual($FirstSync, $SecondSync) or Not _h_MPEG_IsFrameEqual($FirstSync, $ThirdSync) or Not _h_MPEG_IsFrameEqual($FirstSync, $FourthSync))
		$ByteOffset = $EndFirstSyncOffset
		$FirstSync = _h_MPEG_ScanForFrame($sFilename, $ByteOffset)
		$EndFirstSyncOffset = $ByteOffset
		$FirstSyncFrameLen = _MPEG_GetFrameLengthBytes($FirstSync)
		If $FirstSyncFrameLen > 0 Then
			$ByteOffset = $ByteOffset + $FirstSyncFrameLen + 1 - 4
			If $ByteOffset < FileGetSize($sFilename) Then
				$SecondSync = _h_MPEG_GetNextFrame($sFilename, $ByteOffset)
			Else
				$SecondSync = 0
			EndIf
			$ByteOffset = $ByteOffset + $FirstSyncFrameLen + 1 - 4
			If $ByteOffset < FileGetSize($sFilename) Then
				$ThirdSync = _h_MPEG_GetNextFrame($sFilename, $ByteOffset)
			Else
				$ThirdSync = 0
			EndIf
			$ByteOffset = $ByteOffset + $FirstSyncFrameLen + 1 - 4
			If $ByteOffset < FileGetSize($sFilename) Then
				$FourthSync = _h_MPEG_GetNextFrame($sFilename, $ByteOffset)
			Else
				$FourthSync = 0
			EndIf
		EndIf
		$TryNum += 1
;~ 		MsgBox(0,"TryNum = " & $TryNum,$FirstSync & " , " & $SecondSync & " , " & $ThirdSync & " , " & $FourthSync)
	WEnd

	Return $FirstSync

EndFunc   ;==>_MPEG_GetFrameHeader
Func _h_MPEG_ScanForFrame($sFilename, Byref $iOffsetByte)
	;returns next sync frame, it could be a false sync

	Local $hfile = FileOpen($sFilename, 16) ;open in binary mode
	Local $ReadError = 0
	Local $byteNum = 0
	Local $bTestSyncBytes = 0



	FileSetPos($hfile, $iOffsetByte, 0)
;~ 	MsgBox(0,"$iOffsetByte_Before",$iOffsetByte)

	$bTestSyncBytes = FileRead($hfile, 2)
	$ReadError = @error

	;Find valid MPEG Frame Sync ("0xFFE0"), first 11 bits are set to 1
	While $ReadError = 0
		$byteNum += 1
		$bTestSyncBytes = BinaryMid($bTestSyncBytes,2,1) ;trim byte
		$bTestSyncBytes &= FileRead($hfile, 1) ;add byte
		$ReadError = @error

		If BitAND($bTestSyncBytes, Binary("0xFFE0")) = Binary("0xFFE0") Then
			;Read in the rest of the MPEG Frame Header
			$bTestSyncBytes &= FileRead($hfile, 2)
;~ 			MsgBox(0,"$bTestSyncBytes",$bTestSyncBytes)
			If _h_MPEG_IsValidHeader($bTestSyncBytes) Then
;~ 				MsgBox(0,"$bTestSyncBytes",$bTestSyncBytes)
				ExitLoop
			Else
;~ 				MsgBox(0,"$bTestSyncBytes",$bTestSyncBytes)
				$bTestSyncBytes = BinaryMid($bTestSyncBytes,1,2) ;trim 2 bytes
				FileSetPos($hfile, -2, 1)
			EndIf

		EndIf

	WEnd

	;Frame Sync was found or there was a ReadError (could be end of file)
	If $ReadError = -1 Then ;End of File reached
		$bTestSyncBytes = 0
		FileClose($hfile)
		Return 0
	EndIf
	If $ReadError = 1 Then ;Other Read Error
		$bTestSyncBytes = 0
		FileClose($hfile)
		Return 0
	EndIf

	$iOffsetByte = FileGetPos($hfile)

	Return $bTestSyncBytes

EndFunc   ;==>_h_MPEG_ScanForFrame
Func _h_MPEG_GetNextFrame($sFilename, Byref $iOffsetByte)
	;returns next sync frame, it could be a false sync

	Local $hfile = FileOpen($sFilename, 16) ;open in binary mode
	Local $ReadError = 0
	Local $byteNum = 0
	Local $bTestSyncBytes = 0



	FileSetPos($hfile, $iOffsetByte, 0)
;~ 	MsgBox(0,"$iOffsetByte_Before",$iOffsetByte)

	$bTestSyncBytes = FileRead($hfile, 4)
	$ReadError = @error

	$iOffsetByte = FileGetPos($hfile)
	FileClose($hfile)
	Return $bTestSyncBytes


EndFunc   ;==>_h_MPEG_GetNextFrame
Func _h_MPEG_IsFrameEqual($bMPEGFrameHeader1,$bMPEGFrameHeader2)
	;TODO: FIX this is not working
	If $bMPEGFrameHeader1 = $bMPEGFrameHeader2 Then
		Return True
	Else
		;check if all is equal except BitRate for VBR
		Return False
	EndIf
EndFunc   ;==>_h_MPEG_IsFrameEqual
Func _h_MPEG_SyncToNextFrameOLD($sFilename, Byref $iOffsetByte)

	;returns next sync frame, it could be a false sync

	Local $hfile = FileOpen($sFilename, 16) ;open in binary mode
	Local $ReadError = 0
	Local $byteNum = 0
	Local $bTestSyncBytes = 0



	FileSetPos($hfile, $iOffsetByte, 0)
;~ 	MsgBox(0,"$iOffsetByte_Before",$iOffsetByte)

	$bTestSyncBytes = FileRead($hfile, 2)
	$ReadError = @error

	;Find valid MPEG Frame Sync ("0xFFE0"), first 11 bits are set to 1
	While $ReadError = 0
		$byteNum += 1
		$bTestSyncBytes = BinaryMid($bTestSyncBytes,2,1) ;trim byte
		$bTestSyncBytes &= FileRead($hfile, 1) ;add byte
		$ReadError = @error

		If BitAND($bTestSyncBytes, Binary("0xFFE0")) = Binary("0xFFE0") Then
			;Read in the rest of the MPEG Frame Header
			$bTestSyncBytes &= FileRead($hfile, 2)
			MsgBox(0,"$bTestSyncBytes",$bTestSyncBytes)
			If _h_MPEG_IsValidHeader($bTestSyncBytes) Then
;~ 				MsgBox(0,"$bTestSyncBytes",$bTestSyncBytes)
				ExitLoop
			Else
				MsgBox(0,"$bTestSyncBytes",$bTestSyncBytes)
				$bTestSyncBytes = BinaryMid($bTestSyncBytes,1,2) ;trim 2 bytes
				FileSetPos($hfile, -2, 1)
			EndIf

		EndIf


	WEnd

	;Frame Sync was found or there was a ReadError (could be end of file)
	If $ReadError = -1 Then ;End of File reached
		$bTestSyncBytes = 0
		FileClose($hfile)
		Return 0
	EndIf
	If $ReadError = 1 Then ;Other Read Error
		$bTestSyncBytes = 0
		FileClose($hfile)
		Return 0
	EndIf


	$iOffsetByte = FileGetPos($hfile)
;~ 	MsgBox(0,"$iOffsetByte_After",$iOffsetByte)

	;Read in the rest of the MPEG Frame Header
;~ 	$bTestSyncBytes &= FileRead($hfile, 2)
	MsgBox(0,"$bTestSyncBytes",$bTestSyncBytes & " (" & $iOffsetByte & ")")
	FileClose($hfile)

	Local $FrameLengthInBytes = Floor(144 * Number(_MPEG_GetBitRate($bTestSyncBytes))*1000 / Number(_MPEG_GetSampleRate($bTestSyncBytes)) + 0)
;~ 	MsgBox(0,"_MPEG_GetBitRate",Number(_MPEG_GetBitRate($bTestSyncBytes))*1000)
;~ 	MsgBox(0,"_MPEG_GetSampleRate",Number(_MPEG_GetSampleRate($bTestSyncBytes)))
	MsgBox(0,"$FrameLengthInBytes",$FrameLengthInBytes)
;~ 	$iOffsetByte + $FrameLengthInBytes+2
;~ 	MsgBox(0,"Next",$iOffsetByte + $FrameLengthInBytes + 1)
	$iOffsetByte = $iOffsetByte + $FrameLengthInBytes + 1 - 8

	Return $bTestSyncBytes


EndFunc   ;==>_h_MPEG_SyncToNextFrame
Func _h_MPEG_IsValidHeader($MPEGFrameSyncHex)

;~ 	MsgBox(0,"$MPEGFrameSyncHex",$MPEGFrameSyncHex)

	If _MPEG_GetVersion($MPEGFrameSyncHex) = "Reserved" Then
		Return 0 ;not valid
	EndIf
	If _MPEG_GetLayer($MPEGFrameSyncHex) = "Reserved" Then
		Return 0 ;not valid
	EndIf
	If _MPEG_GetBitRate($MPEGFrameSyncHex) = "bad" Then
		Return 0 ;not valid
	EndIf


	$MPEGFrameSyncUint32 = Dec(StringReplace($MPEGFrameSyncHex, "0x", ""), 2)
	If $MPEGFrameSyncUint32 > Dec("FFE00000", 2) Then
		If $MPEGFrameSyncUint32 < Dec("FFFFEC00", 2) Then
			If Not (StringMid($MPEGFrameSyncHex, 4, 1) == "0") Then
				If Not (StringMid($MPEGFrameSyncHex, 4, 1) == "1") Then
					If Not (StringMid($MPEGFrameSyncHex, 4, 1) == "9") Then
						;valid MPEG Header Found
						Return 1
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf


	Return 0

EndFunc   ;==>_h_MPEG_IsValidHeader
Func _MPEG_GetFrameLengthBytes($bMPEGFrameHeader)

	Local $Padding = BitShift(BitAND(2, BinaryMid($bMPEGFrameHeader, 3, 1)), 2)
	Local $BitRate = Number(_MPEG_GetBitRate($bMPEGFrameHeader))*1000
	Local $SampleRate = Number(_MPEG_GetSampleRate($bMPEGFrameHeader))
	Local $Layer = _MPEG_GetLayer($bMPEGFrameHeader)
	Local $FrameLengthInBytes = 0

	;TODO: Need to check this function is working???

	If $Layer = "Layer I" Then
		$FrameLengthInBytes = Floor((12 * $BitRate / $SampleRate + $Padding) * 4)
;~ 		MsgBox(0,"$Layer",$Layer)
	Else
		$FrameLengthInBytes = Floor(144 * $BitRate / $SampleRate + $Padding)
	EndIf

;~ 	$FrameLengthInBytes = Floor(144 * $BitRate / $SampleRate + 0)

	Return $FrameLengthInBytes
EndFunc

Func _MPEG_GetVersion($bMPEGFrameHeader)
	;AAAAAAAA AAABBCCD EEEEFFGH IIJJKLMM
	;B - MPEG Audio version ID
	;	00 - MPEG Version 2.5 (later extension of MPEG 2)
	;	01 - reserved
	;	10 - MPEG Version 2 (ISO/IEC 13818-3)
	;	11 - MPEG Version 1 (ISO/IEC 11172-3)

	Local $bMPEGVersion = BitShift(BitAND(24, BinaryMid($bMPEGFrameHeader, 2, 1)), 3)
	Local $sMPEGVersion = ""
	Switch $bMPEGVersion
		Case 0
			$sMPEGVersion = "MPEG Version 2.5"
		Case 1
			$sMPEGVersion = "Reserved"
		Case 2
			$sMPEGVersion = "MPEG Version 2"
		Case 3
			$sMPEGVersion = "MPEG Version 1"
	EndSwitch
;~ 	MsgBox(0,$bMPEGVersion,$sMPEGVersion)
	Return $sMPEGVersion
EndFunc   ;==>_MPEG_GetVersion
Func _MPEG_GetLayer($bMPEGFrameHeader)
	;AAAAAAAA AAABBCCD EEEEFFGH IIJJKLMM
	;C - Layer description
	;	00 - reserved
	;	01 - Layer III
	;	10 - Layer II
	;	11 - Layer I
	Local $bMPEGLayer = BitShift(BitAND(6, BinaryMid($bMPEGFrameHeader, 2, 1)), 1)
	Local $sMPEGLayer = ""
	Switch $bMPEGLayer
		Case 0
			$sMPEGLayer = "Reserved"
		Case 1
			$sMPEGLayer = "Layer III"
		Case 2
			$sMPEGLayer = "Layer II"
		Case 3
			$sMPEGLayer = "Layer I"
	EndSwitch
;~ 	MsgBox(0,$bMPEGLayer,$sMPEGLayer)
	Return $sMPEGLayer
EndFunc   ;==>_MPEG_GetLayer
Func _MPEG_GetBitRate($bMPEGFrameHeader)
	;AAAAAAAA AAABBCCD EEEEFFGH IIJJKLMM
	;E - Bitrate index
	;bits	V1,L1	V1,L2	V1,L3	V2,L1	V2, L2 & L3
	;0000	free	free	free	free	free
	;0001	32		32		32		32		8
	;0010	64		48		40		48		16
	;0011	96		56		48		56		24
	;0100	128		64		56		64		32
	;0101	160		80		64		80		40
	;0110	192		96		80		96		48
	;0111	224		112		96		112		56
	;1000	256		128		112		128		64
	;1001	288		160		128		144		80
	;1010	320		192		160		160		96
	;1011	352		224		192		176		112
	;1100	384		256		224		192		128
	;1101	416		320		256		224		144
	;1110	448		384		320		256		160
	;1111	bad		bad		bad		bad		bad
	;NOTES: All values are in kbps
	;	V1 - MPEG Version 1
	;	V2 - MPEG Version 2 and Version 2.5
	;	L1 - Layer I
	;	L2 - Layer II
	;	L3 - Layer III
	;	"free" means free format. The free bitrate must remain constant,
	;	an must be lower than the maximum allowed bitrate. Decoders are not
	;	required to support decoding of free bitrate streams. "bad" means that the value is unallowed.

	Local $bMPEGVersion = BitShift(BitAND(24, BinaryMid($bMPEGFrameHeader, 2, 1)), 3)
	Local $bMPEGLayer = BitShift(BitAND(6, BinaryMid($bMPEGFrameHeader, 2, 1)), 1)
	Local $bMPEGBitrateIndex = BitShift(BitAND(240, BinaryMid($bMPEGFrameHeader, 3, 1)), 4)
	Local $sMPEGBitrate = ""

	Switch $bMPEGBitrateIndex
		Case 0 ;0000	free	free	free	free	free
			$sMPEGBitrate = "free"
		Case 1 ;0001	32		32		32		32		8
			$sMPEGBitrate = "32"
			If ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "8"
			EndIf
		Case 2 ;0010	64		48		40		48		16
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "64"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "48"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "40"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "48"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "16"
			EndIf
		Case 3 ;0011	96		56		48		56		24
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "96"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "56"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "48"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "56"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "24"
			EndIf
		Case 4 ;0100	128		64		56		64		32
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "128"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "64"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "56"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "64"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "32"
			EndIf
		Case 5 ;0101	160		80		64		80		40
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "160"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "80"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "64"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "80"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "40"
			EndIf
		Case 6 ;0110	192		96		80		96		48
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "192"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "96"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "80"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "96"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "48"
			EndIf
		Case 7 ;0111	224		112		96		112		56
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "224"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "112"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "96"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "112"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "56"
			EndIf
		Case 8 ;1000	256		128		112		128		64
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "256"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "128"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "112"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "128"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "64"
			EndIf
		Case 9 ;1001	288		160		128		144		80
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "288"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "160"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "128"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "144"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "80"
			EndIf
		Case 10 ;1010	320		192		160		160		96
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "320"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "192"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "160"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "160"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "96"
			EndIf
		Case 11 ;1011	352		224		192		176		112
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "352"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "224"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "192"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "176"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "112"
			EndIf
		Case 12 ;1100	384		256		224		192		128
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "384"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "256"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "224"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "192"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "128"
			EndIf
		Case 13 ;1101	416		320		256		224		144
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "416"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "320"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "256"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "224"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "144"
			EndIf
		Case 14 ;1110	448		384		320		256		160
			If ($bMPEGVersion = 3) And ($bMPEGLayer = 3) Then ;V1,L1
				$sMPEGBitrate = "448"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 2) Then ;V1,L2
				$sMPEGBitrate = "384"
			ElseIf ($bMPEGVersion = 3) And ($bMPEGLayer = 1) Then ;V1,L3
				$sMPEGBitrate = "320"
			ElseIf ($bMPEGVersion = 2) And ($bMPEGLayer = 3) Then ;V2,L1
				$sMPEGBitrate = "256"
			ElseIf ($bMPEGVersion = 2) And (($bMPEGLayer = 2) Or ($bMPEGLayer = 1)) Then ;V2,L2 or V2,L3
				$sMPEGBitrate = "160"
			EndIf
		Case 15 ;1111	bad		bad		bad		bad		bad
			$sMPEGBitrate = "bad"
	EndSwitch

	Return $sMPEGBitrate

EndFunc   ;==>_MPEG_GetBitRate
Func _MPEG_GetSampleRate($bMPEGFrameHeader)
	;AAAAAAAA AAABBCCD EEEEFFGH IIJJKLMM
	;F - Sampling rate frequency index
	;bits	MPEG1		MPEG2		MPEG2.5
	;00		44100 Hz	22050 Hz	11025 Hz
	;01		48000 Hz	24000 Hz	12000 Hz
	;10		32000 Hz	16000 Hz	8000 Hz
	;11		reserv.		reserv.		reserv.

	Local $bMPEGVersion = BitShift(BitAND(24, BinaryMid($bMPEGFrameHeader, 2, 1)), 3)
	Local $bMPEGSampleRateIndex = BitShift(BitAND(12, BinaryMid($bMPEGFrameHeader, 3, 1)), 2)
	Local $sMPEGSampleRate = ""

	Switch $bMPEGSampleRateIndex
		Case 0
			Switch $bMPEGVersion
				Case 0 ;MPEG Version 2.5
					$sMPEGSampleRate = "11025 Hz"
				Case 2 ;MPEG Version 2
					$sMPEGSampleRate = "22050 Hz"
				Case 3 ;MPEG Version 1
					$sMPEGSampleRate = "44100 Hz"
			EndSwitch
		Case 1
			Switch $bMPEGVersion
				Case 0 ;MPEG Version 2.5
					$sMPEGSampleRate = "12000 Hz"
				Case 2 ;MPEG Version 2
					$sMPEGSampleRate = "24000 Hz"
				Case 3 ;MPEG Version 1
					$sMPEGSampleRate = "48000 Hz"
			EndSwitch
		Case 2
			Switch $bMPEGVersion
				Case 0 ;MPEG Version 2.5
					$sMPEGSampleRate = "8000 Hz"
				Case 2 ;MPEG Version 2
					$sMPEGSampleRate = "16000 Hz"
				Case 3 ;MPEG Version 1
					$sMPEGSampleRate = "32000 Hz"
			EndSwitch
		Case 3
			$sMPEGSampleRate = "Reserved"
	EndSwitch

	Return $sMPEGSampleRate

EndFunc   ;==>_MPEG_GetSampleRate
Func _MPEG_GetChannelMode($bMPEGFrameHeader)
	;AAAAAAAA AAABBCCD EEEEFFGH IIJJKLMM
	;I - Channel Mode
	;	00 - Stereo
	;	01 - Joint stereo (Stereo)
	;	10 - Dual channel (2 mono channels)
	;	11 - Single channel (Mono)

	Local $bMPEGChannelMode = BitShift(BitAND(192, BinaryMid($bMPEGFrameHeader, 4, 1)), 6)
	Local $sMPEGChannelMode = ""

	Switch $bMPEGChannelMode
		Case 0
			$sMPEGChannelMode = "Stereo"
		Case 1
			$sMPEGChannelMode = "Joint Stereo"
		Case 2
			$sMPEGChannelMode = "Dual Channel"
		Case 3
			$sMPEGChannelMode = "Single channel (Mono)"
	EndSwitch

	Return $sMPEGChannelMode

EndFunc   ;==>_MPEG_GetChannelMode
Func _MPEG_GetChannelModeEx($bMPEGFrameHeader)
	;TODO - Finish
	;AAAAAAAA AAABBCCD EEEEFFGH IIJJKLMM
	;J - Mode extension (Only used in Joint stereo)
	;Mode extension is used to join informations that are of no use for stereo effect,
	;thus reducing needed bits. These bits are dynamically determined by an encoder in
	;Joint stereo mode, and Joint Stereo can be changed from one frame to another, or
	;even switched on or off.
	;Complete frequency range of MPEG file is divided in subbands There are 32 subbands.
	;For Layer I & II these two bits determine frequency range (bands) where intensity
	;stereo is applied. For Layer III these two bits determine which type of joint stereo
	;is used (intensity stereo or m/s stereo). Frequency range is determined within decompression algorithm.

	;		Layer I and II					Layer III
	;value		Layer I & II		Intensity stereo	MS stereo
	;00			bands 4 to 31		off					off
	;01			bands 8 to 31		on					off
	;10			bands 12 to 31		off					on
	;11			bands 16 to 31		on					on

	Local $bMPEGLayer = BitShift(BitAND(6, BinaryMid($bMPEGFrameHeader, 2, 1)), 1)
	Local $bMPEGChannelModeEx = BitShift(BitAND(48, BinaryMid($bMPEGFrameHeader, 4, 1)), 4)
	Local $sMPEGChannelModeEx = ""

	Switch $bMPEGChannelModeEx
		Case 0
			$sMPEGChannelModeEx = ""
		Case 1
			$sMPEGChannelModeEx = ""
		Case 2
			$sMPEGChannelModeEx = ""
		Case 3
			$sMPEGChannelModeEx = ""
	EndSwitch

	Return $sMPEGChannelModeEx

EndFunc   ;==>_MPEG_GetChannelModeEx




Func _APEv2Tag_ReadFromFile($sFilename)

;~ 	This is how information is laid out in an APEv2 tag:
;~ 		APE Tags Header	 	32 bytes
;~ 		APE Tag Item 1		10.. bytes
;~ 		APE Tag Item 2	 	10.. bytes
;~ 			...	 		 	10.. bytes
;~ 		APE Tag Item n-1	10.. bytes
;~ 		APE Tag Item n		10.. bytes
;~		APE Tags Footer		32 bytes
;~ APE tag items should be sorted ascending by size. When streaming, parts of the
;~ APE tags can be dropped to reduce danger of drop outs between titles. This is
;~ not a must, but strongly recommended. Actually the items should be sorted by
;~ importance/byte, but this is not feasible. Only break this rule if you add less
;~ important small items and you don't want to rewrite the whole tag. An APE tag at
;~ the end of a file (strongly recommended) must have at least a footer, an APE tag
;~ in the beginning of a file (strongly unrecommended) must have at least a header.
;~ When located at the end of an MP3 file, an APE tag should be placed after the the
;~ last frame, just before the ID3v1 tag (if any).


	Local $APEv2_TAGINFO = "", $APE_TagFound = False, $hfile, $iID3v1_ByteOffset = 0
	Local $APE_Version, $APE_TagSize, $sAPE_ItemKeys = ""

	If _ID3v1Tag_ReadFromFile($sFilename) <> "" Then
		$iID3v1_ByteOffset = 128
	EndIf


	$hfile = FileOpen($sFilename, 16) ;open in binary mode
	FileSetPos($hfile, -($iID3v1_ByteOffset + 32), 2) ;include 32 bytes to check for APETAG Footer

	$APE_Footer = FileRead($hfile, 32)
	$APETAG_ID = BinaryToString(BinaryMid($APE_Footer, 1, 8))
	$sAPEv2_TagFrameIndex_Global = $sFilename
	;APE TAG Test Code
;~ 	MsgBox(0,"$APETAG_ID",$APETAG_ID)
	If $APETAG_ID == "APETAGEX" Then
		$APE_TagFound = True
		$APE_Version = Hex(BinaryMid($APE_Footer, 12, 1), 2)
		$APE_Version &= Hex(BinaryMid($APE_Footer, 11, 1), 2)
		$APE_Version &= Hex(BinaryMid($APE_Footer, 10, 1), 2)
		$APE_Version &= Hex(BinaryMid($APE_Footer, 9, 1), 2)
		$APE_Version = Dec($APE_Version)

		$APE_TagSize = Hex(BinaryMid($APE_Footer, 16, 1), 2)
		$APE_TagSize &= Hex(BinaryMid($APE_Footer, 15, 1), 2)
		$APE_TagSize &= Hex(BinaryMid($APE_Footer, 14, 1), 2)
		$APE_TagSize &= Hex(BinaryMid($APE_Footer, 13, 1), 2)
		$APE_TagSize = Dec($APE_TagSize, 2) ;APE_TagSize does not include 32 byte header but does include 32 byte footer

;~ 		MsgBox(0,"$APETAG",$APETAG_ID & @CRLF & "TagVersion = " & $APE_Version & @CRLF & "TagSize = " & $APE_TagSize)
		FileSetPos($hfile, -($iID3v1_ByteOffset + $APE_TagSize + 32), 2)
		$bAPEv2_RawTagData_Global = FileRead($hfile, $APE_TagSize)
;~ 		MsgBox(0,"$bAPEv2_RawTagData_Global",$bAPEv2_RawTagData_Global)
		FileClose($hfile)
		;iTunes TagSize includes header (Not to standard)
		Dim $iTunesTest = StringInStr(BinaryToString($bAPEv2_RawTagData_Global), "APETAGEX")
		$bAPEv2_RawTagData_Global = BinaryMid($bAPEv2_RawTagData_Global, $iTunesTest)
		$sAPE_ItemKeys = _h_APEv2_EnumerateItemKeys()
	Else
		$bAPEv2_RawTagData_Global = 0
	EndIf

	If $APE_TagFound Then
		$APEv2_TAGINFO &= "APEv" & String($APE_Version / 1000) & $sAPE_ItemKeys & @CRLF
	EndIf

	If $APE_TagFound Then
		SetExtended(4)
	EndIf

    FileClose($hfile)
	Return $APEv2_TAGINFO

EndFunc   ;==>_APEv2Tag_ReadFromFile
Func _h_APEv2_EnumerateItemKeys()
	Local $APE_TAGINFO = ""
	If BinaryLen($bAPEv2_RawTagData_Global) < 32 Then
		Return $APE_TAGINFO
	EndIf
	Local $APE_TagSize = _APEv2Tag_GetTagSize()
	Local $iStartByte = 32, $APE_ItemSize, $APE_ItemKeyterm, $APE_ItemKey
	While ($iStartByte + 1) < ($APE_TagSize - 32)
		$APE_ItemSize = Hex(BinaryMid($bAPEv2_RawTagData_Global, $iStartByte + 4, 1), 2)
		$APE_ItemSize &= Hex(BinaryMid($bAPEv2_RawTagData_Global, $iStartByte + 3, 1), 2)
		$APE_ItemSize &= Hex(BinaryMid($bAPEv2_RawTagData_Global, $iStartByte + 2, 1), 2)
		$APE_ItemSize &= Hex(BinaryMid($bAPEv2_RawTagData_Global, $iStartByte + 1, 1), 2)
		$APE_ItemSize = Dec($APE_ItemSize)
;~ 		MsgBox(0,"$APE_ItemSize",$APE_ItemSize)

		$APE_ItemKeyterm = StringInStr(BinaryToString(BinaryMid($bAPEv2_RawTagData_Global, $iStartByte + 9)), Chr(0))
		$APE_ItemKey = BinaryToString(BinaryMid($bAPEv2_RawTagData_Global, $iStartByte + 9, $APE_ItemKeyterm - 1))
;~ 		MsgBox(0,"$APE_ItemKey",$APE_ItemKey)
		$APE_TAGINFO &= "|" & $APE_ItemKey

		$sAPEv2_TagFrameIndex_Global &= @CRLF & $APE_ItemKey & "|" & String($iStartByte + $APE_ItemKeyterm + 9) & "|" & String($APE_ItemSize)

		$iStartByte = $iStartByte + 8 + $APE_ItemKeyterm + $APE_ItemSize
;~ 		MsgBox(0,"$iStartByte",$iStartByte & " of " & ($APE_TagSize-32))
	WEnd

;~ 	MsgBox(0,"$sAPEv2_TagFrameIndex_Global",$sAPEv2_TagFrameIndex_Global)
	Return $APE_TAGINFO
EndFunc   ;==>_h_APEv2_EnumerateItemKeys
Func _APEv2Tag_GetVersion()
	If BinaryLen($bAPEv2_RawTagData_Global) < 32 Then
		Return 0
	EndIf

	Local $APE_Version = BinaryMid($bAPEv2_RawTagData_Global, 9, 4)
	$APE_Version = Number($APE_Version)

	Return $APE_Version
EndFunc   ;==>_APEv2Tag_GetVersion
Func _APEv2Tag_GetTagSize()
	If BinaryLen($bAPEv2_RawTagData_Global) < 32 Then
		Return 0
	EndIf

	Local $APE_TagSize = BinaryMid($bAPEv2_RawTagData_Global, 13, 4)
	$APE_TagSize = Number($APE_TagSize)

	Return $APE_TagSize
EndFunc   ;==>_APEv2Tag_GetTagSize
Func _APEv2Tag_GetItemCount()
	If BinaryLen($bAPEv2_RawTagData_Global) < 32 Then
		Return 0
	EndIf

	Local $APE_ItemCount = BinaryMid($bAPEv2_RawTagData_Global, 17, 4)
	$APE_ItemCount = Number($APE_ItemCount)

	Return $APE_ItemCount
EndFunc   ;==>_APEv2Tag_GetItemCount
Func _APEv2_GetItemKeys($StringLineDelimiter = @CRLF)
	;If $StringLineDelimiter == -1 then return an array
	Local $vAPE_ItemKeys
	If BinaryLen($bAPEv2_RawTagData_Global) < 32 Then
		Return ""
	EndIf

	Local $sItemKeyList = StringSplit($sAPEv2_TagFrameIndex_Global, @CRLF, 1)
	If $StringLineDelimiter = -1 Then
		Dim $vAPE_ItemKeys[1]
		$vAPE_ItemKeys[0] = $sItemKeyList[0] - 1
	EndIf

	Local $aItemKey
	For $iKey = 2 To $sItemKeyList[0] - 1
		$aItemKey = StringSplit($sItemKeyList[$iKey], "|")
		If $StringLineDelimiter = -1 Then
			_ArrayAdd($vAPE_ItemKeys, $aItemKey[1])
		Else
			$vAPE_ItemKeys &= $aItemKey[1] & $StringLineDelimiter
		EndIf
	Next
	$aItemKey = StringSplit($sItemKeyList[$sItemKeyList[0]], "|")
	If $StringLineDelimiter = -1 Then
		_ArrayAdd($vAPE_ItemKeys, $aItemKey[1])
;~ 		_ArrayDisplay($vAPE_ItemKeys)
	Else
		$vAPE_ItemKeys &= $aItemKey[1]
;~ 		MsgBox(0,"$vAPE_ItemKeys",$vAPE_ItemKeys)
	EndIf

	Return $vAPE_ItemKeys
EndFunc   ;==>_APEv2_GetItemKeys
Func _APEv2_GetItemValueBinary($sAPE_ItemKey)
	;First Get Start Byte and Frame Length from $sID3v2_TagFrameIndex_Global
	Local $iFrameInfo = StringInStr($sAPEv2_TagFrameIndex_Global, $sAPE_ItemKey, -1)

	Local $FrameInfoCut = StringMid($sAPEv2_TagFrameIndex_Global, $iFrameInfo)
	Local $iFrameInfoEnd = StringInStr($FrameInfoCut, @CRLF)
	$FrameInfoCut = StringMid($FrameInfoCut, 1, $iFrameInfoEnd - 1)


	$Firstpipe = StringInStr($FrameInfoCut, '|')
	$Lastpipe = StringInStr($FrameInfoCut, '|', -1, -1)
	Local $FrameStart = Number(StringMid($FrameInfoCut, $Firstpipe + 1, ($Lastpipe) - ($Firstpipe + 1)))
	Local $FrameSize = Number(StringMid($FrameInfoCut, $Lastpipe + 1))
	;MsgBox(0,"$FrameStart",$FrameStart)
	;MsgBox(0,"$FrameSize",$FrameSize)

	Local $bItemValueData = BinaryMid($bAPEv2_RawTagData_Global, $FrameStart, $FrameSize)

;~ 	MsgBox(0,$sAPE_ItemKey,$bItemValueData)

	If BinaryLen($bItemValueData) <> 0 Then
		Return $bItemValueData
	Else
		Return -1
	EndIf
EndFunc   ;==>_APEv2_GetItemValueBinary
Func _APEv2_GetItemValueString($sAPE_ItemKey = -1, $StringLineDelimiter = @CRLF)
	;TODO Test when $sAPE_ItemKey = -1
	If BinaryLen($bAPEv2_RawTagData_Global) < 9 Then
		Return ""
	EndIf
	Local $iNumValues = 1
	Local $sAPEv2_ReturnString = ""
	If $sAPE_ItemKey = -1 Then
		Local $ataginfo = StringSplit($sAPEv2_TagFrameIndex_Global, @CRLF, 1)
		For $istr = 2 To $ataginfo[0]
			Dim $a2taginfo = StringSplit($ataginfo[$istr], "|")
			If $a2taginfo[0] > 1 Then
				Local $bValue = _APEv2_GetItemValueBinary($a2taginfo[1])
				Local $sImageCheck = StringStripWS(BinaryToString($bValue), 3)
;~ 				MsgBox(0,$sImageCheck,StringCompare($sImageCheck, ($a2taginfo[1] & ".jpg")))
				If StringInStr($sImageCheck, ".jpg") > 0 Then
;~ 					MsgBox(0,$sImageCheck,($a2taginfo[1] & ".jpg"))
					Local $iImageIndex = StringInStr(BinaryToString($bValue), Chr(0))
					Local $bImage = BinaryMid($bValue, $iImageIndex + 1)
					FileWrite($sImageCheck, $bImage)
					$sAPEv2_ReturnString &= $a2taginfo[1] & " = " & $sImageCheck & $StringLineDelimiter
				Else
					;Check if string has multiple values delimited by 0x00 (Mp3tag does this with multiple COMMENT Itemkeys)
					Local $aValues = StringSplit(BinaryToString($bValue), Chr(0))
					$iNumValues = $aValues[0]
;~ 					MsgBox(0,"$iNumValues",$iNumValues)
;~ 					_ArrayDisplay($aValues)
					If $aValues[0] > 0 Then
						For $i = 1 To $aValues[0]
							$sAPEv2_ReturnString &= $a2taginfo[1] & " = " & $aValues[$i] & $StringLineDelimiter
						Next
					Else
						$sAPEv2_ReturnString &= $a2taginfo[1] & " = " & BinaryToString($bValue) & $StringLineDelimiter
					EndIf
				EndIf
			EndIf
		Next
	Else
		Local $bValue = _APEv2_GetItemValueBinary($sAPE_ItemKey)
		Local $aValues = StringSplit(BinaryToString($bValue), Chr(0))
		$iNumValues = $aValues[0]
;~ 		_ArrayDisplay($aValues)
		If $aValues[0] > 0 Then
			If IsNumber($StringLineDelimiter) Then
				$sAPEv2_ReturnString = $aValues[$StringLineDelimiter]
			Else
				$sAPEv2_ReturnString = $aValues[1]
;~ 				For $i = 1 To $aValues[0]
;~ 					$sAPEv2_ReturnString &= $aValues[$i] & $StringLineDelimiter
;~ 				Next
			EndIf
		Else
			$sAPEv2_ReturnString = BinaryToString($bValue)
		EndIf

		If StringInStr($sAPEv2_ReturnString, ".jpg") > 0 Then
;~ 			MsgBox(0,$sAPE_ItemKey,$sAPEv2_ReturnString)
			Local $iImageIndex = StringInStr(BinaryToString($bValue), Chr(0))
			Local $bImage = BinaryMid($bValue, $iImageIndex + 1)
			FileWrite($sAPEv2_ReturnString, $bImage)
			$iNumValues = 1
		EndIf
	EndIf
;~ 	MsgBox(0,"$sAPE_ItemKey",$sAPEv2_ReturnString)
	SetExtended($iNumValues)
	Return $sAPEv2_ReturnString
EndFunc   ;==>_APEv2_GetItemValueString
Func _APEv2_RemoveTag($Filename)


	Local $sAPEv2_TagInfo = _APEv2Tag_ReadFromFile($Filename)
	If StringLen($sAPEv2_TagInfo) <= 1 Then
		Return -1
	EndIf

	Local $APE_TagSize = _APEv2Tag_GetTagSize()
	;need to check if ID3v1 Tag is present
	Local $StartOfTag = FileGetSize($Filename) - (128 + $APE_TagSize + 32)
	Local $EndOfTag = $StartOfTag + $APE_TagSize + 32
	Local $TagFilename = StringTrimRight($Filename, 4) & "_APETAG.mp3"

	;Open Tag File write mode, create file, binary mode
	$hTagFile = FileOpen($TagFilename, 2 + 8 + 16) ;erase all

	$hfile = FileOpen($Filename, 16) ;binary mode
	FileSetPos($hfile, 0, 0)


	FileWrite($hTagFile, FileRead($hfile, $StartOfTag)) ;read and write all data before APEv2 Tag
	FileSetPos($hfile, $EndOfTag, 0) ;Skip APEv2 Tag Data
	FileWrite($hTagFile, FileRead($hfile)) ;Write in rest of file

	FileClose($hTagFile)
	FileClose($hfile)


	FileCopy($TagFilename, $Filename, 1)
	FileDelete($TagFilename)


	$bAPEv2_RawTagData_Global = 0

EndFunc   ;==>_APEv2_RemoveTag




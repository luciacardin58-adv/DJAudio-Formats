"
AIFF binary layout:
- `FORM` header (big-endian throughout)
- `COMM` chunk — channels, sample frames, bit depth, 80-bit sample rate
- Text chunks: `NAME` → title, `AUTH` → artist, `ANNO` → comment
"
Class {
	#name : 'DJAiffAudioFormat',
	#superclass : 'DJAudioFormat',
	#category : 'DJAudio-Formats-Readers',
	#package : 'DJAudio-Formats',
	#tag : 'Readers'
}

{ #category : 'accessing' }
DJAiffAudioFormat >> fileExtensions [

	^#('.aif' '.aiff')
]

{ #category : 'accessing' }
DJAiffAudioFormat >> formatName [

	[^'AIFF']
]

{ #category : 'parsing' }
DJAiffAudioFormat >> parseAIFF: aStream into: info [ 
    self readFormHeaderFrom: aStream.
    [ aStream atEnd ] whileFalse: [
        self readNextChunkFrom: aStream into: info ]
]

{ #category : 'parsing' }
DJAiffAudioFormat >> parseChunk: chunkId size: chunkSize from: aStream into: info [ 
    chunkId = 'COMM' ifTrue: [
        ^ self parseCOMM: aStream size: chunkSize into: info ].
    chunkId = 'NAME' ifTrue: [
        ^ info metadata at: 'title'   put: (self readText: aStream size: chunkSize) ].
    chunkId = 'AUTH' ifTrue: [
        ^ info metadata at: 'artist'  put: (self readText: aStream size: chunkSize) ].
    chunkId = 'ANNO' ifTrue: [
        ^ info metadata at: 'comment' put: (self readText: aStream size: chunkSize) ].
    "unknown chunk — skip content only; padding handled by caller"
    aStream skip: chunkSize
]

{ #category : 'reading' }
DJAiffAudioFormat >> read80bitExtended: aStream [
    | sign exponent mantissa result bytes |
    bytes    := aStream next: 10.
    sign     := (bytes first) bitAnd: 16r80.
    exponent := ((bytes first) bitAnd: 16r7F) bitShift: 8.
    exponent := exponent + (bytes at: 2).
    mantissa := 0.
    3 to: 10 do: [ :i | mantissa := (mantissa bitShift: 8) + (bytes at: i) ].
    exponent = 0
        ifTrue:  [ result := 0.0 ]
        ifFalse: [
            result := mantissa asFloat * (2.0 raisedTo: exponent - 16383 - 63).
            sign ~= 0 ifTrue: [ result := result negated ] ].
    ^result
]

{ #category : 'reading' }
DJAiffAudioFormat >> readBigEndian16Signed: aStream [
    | val |
    val := (aStream next bitShift: 8) + aStream next.
    val >= 16r8000 ifTrue: [ val := val - 16r10000 ].
    ^val
]

{ #category : 'reading' }
DJAiffAudioFormat >> readBigEndian32: aStream [

    | b0 b1 b2 b3 |
    b0 := aStream next. b1 := aStream next.
    b2 := aStream next. b3 := aStream next.
    ^(b0 bitShift: 24) + (b1 bitShift: 16) + (b2 bitShift: 8) + b3
]

{ #category : 'parsing' }
DJAiffAudioFormat >> readFormHeaderFrom: aStream [ 
    (self readFourCC: aStream) = 'FORM'
        ifFalse: [ ^ self error: 'Not an AIFF file' ].
    self readBigEndian32: aStream.   "skip file size field"
    (#('AIFF' 'AIFC') includes: (self readFourCC: aStream))
        ifFalse: [ ^ self error: 'Not AIFF/AIFC form type' ]
]

{ #category : 'reading' }
DJAiffAudioFormat >> readFourCC: aStream [
    ^String new: 4 streamContents: [ :s |
        4 timesRepeat: [ s nextPut: (Character value: aStream next) ] ]
]

{ #category : 'accessing' }
DJAiffAudioFormat >> readInfoForm: aFileReference [

	  | info stream |
    info := DJAudioFileInfo new.
    info filePath: aFileReference fullName.
    [
        stream := aFileReference binaryReadStream.
        self parseAIFF: stream into: info.
    ] on: Error do: [ :e |
        Transcript show: 'DJAiffAudioFormat error: ' , e messageText; cr.
        ^nil
    ] ensure: [
        stream ifNotNil: [ stream close ]
    ].
    ^info
]

{ #category : 'parsing' }
DJAiffAudioFormat >> readNextChunkFrom: aStream into: info [ 
    | chunkId chunkSize |
    chunkId   := self readFourCC: aStream.
    chunkSize := self readBigEndian32: aStream.
    self parseChunk: chunkId size: chunkSize from: aStream into: info.
    "every odd-sized chunk is followed by one pad byte"
    (chunkSize odd and: [ aStream atEnd not ])
        ifTrue: [ aStream skip: 1 ]
]

{ #category : 'reading' }
DJAiffAudioFormat >> readText: aStream size: size [ 
    | bytes |
    bytes := aStream next: size.
    ^(bytes select: [ :b | b ~= 0 ]) asString trimmed
]

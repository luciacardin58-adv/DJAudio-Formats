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

	^ 'AIFF' 
]

{ #category : 'parsing' }
DJAiffAudioFormat >> parseAIFF: aStream into: info [ 
    self readFormHeaderFrom: aStream.
    [ aStream atEnd ] whileFalse: [
        self readNextChunkFrom: aStream into: info ]
]

{ #category : 'parsing' }
DJAiffAudioFormat >> parseCOMM: aStream size: chunkSize into: info [ 
    info numChannels:    (self readBigEndian16: aStream).
    info lengthInSamples: (self readBigEndian32: aStream).
    info bitsPerSample:  (self readBigEndian16Signed: aStream).
    info sampleRate:     (self read80bitExtendedFrom: aStream)
]

{ #category : 'parsing' }
DJAiffAudioFormat >> parseChunk: chunkId size: chunkSize from: aStream into: info [

	 chunkId = 'COMM' ifTrue: [
        ^ self parseCOMM: aStream size: chunkSize into: info ].
    chunkId = 'SSND' ifTrue: [
        ^ self parseSSND: aStream size: chunkSize into: info ].
    chunkId = 'NAME' ifTrue: [
        ^ info metadata at: 'title'   put: (self readText: aStream size: chunkSize) ].
    chunkId = 'AUTH' ifTrue: [
        ^ info metadata at: 'artist'  put: (self readText: aStream size: chunkSize) ].
    chunkId = 'ANNO' ifTrue: [
        ^ info metadata at: 'comment' put: (self readText: aStream size: chunkSize) ].
    "unknown chunk — skip content only; padding handled by caller"
    aStream skip: chunkSize
]

{ #category : 'parsing' }
DJAiffAudioFormat >> parseSSND: aStream size: chunkSize into: info [ 
    "SSND: offset(4) + blockSize(4) + PCM data, big-endian."
    self readBigEndian32: aStream.   "offset — usually 0"
    self readBigEndian32: aStream.   "blockSize — usually 0"
    info dataOffset: aStream position.   "first PCM byte, after the 8-byte header"
    info dataSize:   chunkSize - 8.      "chunkSize includes those 8 bytes"
    aStream skip: chunkSize - 8          "skip PCM — metadata-only parse"
]

{ #category : 'reading' }
DJAiffAudioFormat >> read80bitExtendedFrom: aStream [
	"Decode 80-bit IEEE 754 extended big-endian to an integer sample rate."
  | sign exponent mantissa result bytes |
    bytes    := aStream next: 10.
    sign     := (bytes first ) bitAnd: 16r80.
    exponent := ((bytes first) bitAnd: 16r7F) bitShift: 8.
    exponent := exponent + (bytes at: 2).
    mantissa := 0.
    3 to: 10 do: [ :i | mantissa := (mantissa bitShift: 8) + (bytes at: i) ].
    exponent = 0
        ifTrue:  [ result := 0.0 ]
        ifFalse: [
            result := mantissa asFloat * (2.0 raisedTo: exponent - 16383 - 63).
            sign ~= 0 ifTrue: [ result := result negated ] ].
    ^ result
]

{ #category : 'reading' }
DJAiffAudioFormat >> readBigEndian16: aStream [ 
    ^ (aStream next bitShift: 8) + aStream next
]

{ #category : 'reading' }
DJAiffAudioFormat >> readBigEndian16Signed: aStream [ 
    | val |
    val := self readBigEndian16: aStream.
    val >= 16r8000 ifTrue: [ val := val - 16r10000 ].
    ^ val
]

{ #category : 'reading' }
DJAiffAudioFormat >> readBigEndian32: aStream [ 
    ^ ((aStream next bitShift: 24)
        + (aStream next bitShift: 16)
        + (aStream next bitShift: 8)
        + aStream next)
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

{ #category : 'reading' }
DJAiffAudioFormat >> readInfoFrom: aFileReference [
 | info stream |
    info := DJAudioFileInfo new.
    info filePath: aFileReference fullName.
    stream := aFileReference binaryReadStream.
    [
        self parseAIFF: stream into: info
    ] on: Error do: [ :e |
        self inform: 'DJAiffAudioFormat error: ' , e messageText.
        stream close.
        ^ nil
    ].
    stream close.
    ^ info
 
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
DJAiffAudioFormat >> readSampleFrom: aStream bytes: n [ 
    "One signed big-endian PCM sample of n bytes."
    | value range |
    value := 0.
    n timesRepeat: [ value := (value bitShift: 8) + aStream next ].
    range := 1 bitShift: n * 8.
    ^ value >= (range // 2) ifTrue: [ value - range ] ifFalse: [ value ]
]

{ #category : 'reading' }
DJAiffAudioFormat >> readText: aStream size: size [ 
    | bytes |
    bytes := aStream next: size.
    ^(bytes select: [ :b | b ~= 0 ]) asString trimmed
]

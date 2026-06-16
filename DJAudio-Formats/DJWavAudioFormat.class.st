"
I read WAV (RIFF) files and return a DJAudioFileInfo.
 
 WAV binary layout (little-endian throughout):
   RIFF : container header
   fmt : audioFormat(LE16), channels(LE16), sampleRate(LE32), byteRate(LE32), blockAlign(LE16), bitsPerSample(LE16)
   LIST/INFO : optional metadata: INAM (title), IART (artist)
   data : audio samples; size used to compute lengthInSamples
 
 Inspired by JUCE's WavAudioFormat.
"
Class {
	#name : 'DJWavAudioFormat',
	#superclass : 'DJAudioFormat',
	#category : 'DJAudio-Formats-Readers',
	#package : 'DJAudio-Formats',
	#tag : 'Readers'
}

{ #category : 'accessing' }
DJWavAudioFormat >> fileExtensions [

 ^ #('.wav')
]

{ #category : 'accessing' }
DJWavAudioFormat >> formatName [

	^ 'WAV'
]

{ #category : 'parsing' }
DJWavAudioFormat >> parseChunk: chunkId size: chunkSize from: aStream into: info [ 
    chunkId = 'fmt ' ifTrue: [
        ^ self parseFMT: aStream size: chunkSize into: info ].
    chunkId = 'data' ifTrue: [
        ^ self parseDATA: aStream size: chunkSize into: info ].
    chunkId = 'LIST' ifTrue: [
        ^ self parseLIST: aStream size: chunkSize into: info ].
    "unknown chunk — skip"
    aStream skip: chunkSize
]

{ #category : 'parsing' }
DJWavAudioFormat >> parseDATA: aStream size: chunkSize into: info [ 
    | bytesPerSample |
    bytesPerSample := (info bitsPerSample + 7) // 8.
    info lengthInSamples: chunkSize // (bytesPerSample * info numChannels).
    aStream skip: chunkSize   "skip audio data — we read metadata only"
]

{ #category : 'parsing' }
DJWavAudioFormat >> parseFMT: aStream size: chunkSize into: info [ 
    | audioFormat |
    audioFormat := self readLittleEndian16: aStream.
    info numChannels:  (self readLittleEndian16: aStream).
    info sampleRate:   (self readLittleEndian32: aStream).
    self readLittleEndian32: aStream.   "byteRate — skip"
    self readLittleEndian16: aStream.   "blockAlign — skip"
    info bitsPerSample: (self readLittleEndian16: aStream).
    info usesFloatingPoint: (audioFormat = 3).
    "skip any extra fmt bytes (e.g. extensible format)"
    chunkSize > 16 ifTrue: [ aStream skip: chunkSize - 16 ]
]

{ #category : 'parsing' }
DJWavAudioFormat >> parseLIST: aStream size: chunkSize into: info [ 
    | listType startPos |
    listType := self readFourCC: aStream.
    listType = 'INFO' ifFalse: [
        "not an INFO list — skip remaining bytes"
        aStream skip: chunkSize - 4.
        ^ self ].
    startPos := aStream position.
    [ aStream position < (startPos + chunkSize - 4) ] whileTrue: [
        self readINFOSubchunkFrom: aStream into: info ]
]

{ #category : 'parsing' }
DJWavAudioFormat >> parseWAV: aStream into: info [ 
    self readRiffHeaderFrom: aStream.
    [ aStream atEnd ] whileFalse: [
        self readNextChunkFrom: aStream into: info ]

]

{ #category : 'reading' }
DJWavAudioFormat >> readFourCC: aStream [ 
    ^ String new: 4 streamContents: [ :s |
        4 timesRepeat: [ s nextPut: (Character value: aStream next) ] ]
]

{ #category : 'parsing' }
DJWavAudioFormat >> readINFOSubchunkFrom: aStream into: info [ 
    | subId subSize value |
    subId   := self readFourCC: aStream.
    subSize := self readLittleEndian32: aStream.
    value   := self readText: aStream size: subSize.
    subId = 'INAM' ifTrue: [ info metadata at: 'title'  put: value ].
    subId = 'IART' ifTrue: [ info metadata at: 'artist' put: value ].
    "pad to even boundary"
    (subSize odd and: [ aStream atEnd not ])
        ifTrue: [ aStream skip: 1 ]
]

{ #category : 'reading' }
DJWavAudioFormat >> readInfoFrom: aFileReference [

	 | info stream |
    info := DJAudioFileInfo new.
    info filePath: aFileReference fullName.
    stream := aFileReference binaryReadStream.
    [
        self parseWAV: stream into: info
    ] on: Error do: [ :e |
        self inform: 'DJWavAudioFormat error: ' , e messageText.
        stream close.
        ^ nil
    ].
    stream close.
    ^ info
]

{ #category : 'reading' }
DJWavAudioFormat >> readLittleEndian16: aStream [ 
    | b0 b1 |
    b0 := aStream next.
    b1 := aStream next.
    ^ (b1 bitShift: 8) + b0
]

{ #category : 'reading' }
DJWavAudioFormat >> readLittleEndian32: aStream [ 
    | b0 b1 b2 b3 |
    b0 := aStream next. b1 := aStream next.
    b2 := aStream next. b3 := aStream next.
    ^ (b3 bitShift: 24) + (b2 bitShift: 16) + (b1 bitShift: 8) + b0
]

{ #category : 'reading' }
DJWavAudioFormat >> readNextChunkFrom: aStream into: info [ 
    | chunkId chunkSize |
    chunkId   := self readFourCC: aStream.
    chunkSize := self readLittleEndian32: aStream.
    self parseChunk: chunkId size: chunkSize from: aStream into: info.
    "WAV chunks are also padded to even byte boundaries"
    (chunkSize odd and: [ aStream atEnd not ])
        ifTrue: [ aStream skip: 1 ]
]

{ #category : 'reading' }
DJWavAudioFormat >> readRiffHeaderFrom: aStream [ 
    (self readFourCC: aStream) = 'RIFF'
        ifFalse: [ ^ self error: 'Not a RIFF file' ].
    self readLittleEndian32: aStream.   "skip file size field"
    (self readFourCC: aStream) = 'WAVE'
        ifFalse: [ ^ self error: 'Not a WAVE file' ]

]

{ #category : 'reading' }
DJWavAudioFormat >> readText: aStream size: aSize [ 
    | bytes |
    bytes := aStream next: aSize.
    ^ (bytes select: [ :b | b ~= 0 ]) asString trimmed
]

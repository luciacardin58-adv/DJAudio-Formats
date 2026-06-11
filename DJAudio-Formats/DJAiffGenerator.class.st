"
I generate a silent but structurally valid AIFF file.
   - 3 seconds, 24-bit, 48 kHz, mono
   - Metadata: ANNO/NAME/AUTH chunks + ID3-style via MARK/APPLICATION
   We use standard AIFF text chunks:
     NAME  → track title
     AUTH  → artist
     ANNO  → comments, genre, album, year (one ANNO per value)
"
Class {
	#name : 'DJAiffGenerator',
	#superclass : 'Object',
	#category : 'DJAudio-Formats-Helpers',
	#package : 'DJAudio-Formats',
	#tag : 'Helpers'
}

{ #category : 'as yet unclassified' }
DJAiffGenerator class >> generateTo: aPathString [ 
    "Entry point. Write a silent 24-bit 48kHz mono AIFF to aPathString."
    | gen aStream |
    gen := self new.
    aStream := WriteStream on: ByteArray new.
    gen writeAiffTo: aStream .
    aPathString asFileReference
        binaryWriteStreamDo: [ :s | s nextPutAll: aStream contents ]
]

{ #category : 'writing' }
DJAiffGenerator >> buildAiffPayload [ 
    | aStream meta |
    aStream := WriteStream on: ByteArray new.
    meta := self metadata.
    self writeCOMMTo: aStream.
    self writeSSNDTo: aStream.
    self writeTextChunk: 'NAME' string: (meta at: 'title')   to: aStream.
    self writeTextChunk: 'AUTH' string: (meta at: 'artist')  to: aStream.
    self writeTextChunk: 'ANNO' string: (meta at: 'comment') to: aStream.
    self writeTextChunk: 'ANNO' string: 'Album: ' , (meta at: 'album') to: aStream.
    self writeTextChunk: 'ANNO' string: 'Year: '  , (meta at: 'year')  to: aStream.
    self writeTextChunk: 'ANNO' string: 'Genre: ' , (meta at: 'genre') to: aStream.
    ^ aStream contents
]

{ #category : 'parsing' }
DJAiffGenerator >> metadata [ 
    ^ Dictionary new
        at: 'artist'  put: 'Lucia Cardin';
        at: 'title'   put: 'DummyAiff';
        at: 'album'   put: 'DummyForTests';
        at: 'year'    put: '2026';
        at: 'genre'   put: 'Ambient';
        at: 'comment' put: 'Silent Test';
        yourself
]

{ #category : 'parsing' }
DJAiffGenerator >> readFormHeaderFrom: aStream [ 
    (self readFourCC: aStream) = 'FORM'
        ifFalse: [ ^ self error: 'Not an AIFF file' ].
    self readBigEndian32: aStream.   "skip file size field"
    (#('AIFF' 'AIFC') includes: (self readFourCC: aStream))
        ifFalse: [ ^ self error: 'Not AIFF/AIFC form type' ]
]

{ #category : 'parsing' }
DJAiffGenerator >> readNextChunkFrom: aStream into: info [ 
    | chunkId chunkSize |
    chunkId   := self readFourCC: aStream.
    chunkSize := self readBigEndian32: aStream.
    self parseChunk: chunkId size: chunkSize from: aStream into: info.
    "every odd-sized chunk is followed by one pad byte"
    (chunkSize odd and: [ aStream atEnd not ])
        ifTrue: [ aStream skip: 1 ]
]

{ #category : 'writing' }
DJAiffGenerator >> writeANNOTo: aStream string: aString [ 
    "ANNO chunk: free-form annotation"
    self writeTextChunk: 'ANNO' string: aString to: aStream
]

{ #category : 'writing' }
DJAiffGenerator >> writeAUTHTo: aStream [
    "AUTH chunk: artist"
    self writeTextChunk: 'AUTH' string: self artistName to: aStream 
]

{ #category : 'writing' }
DJAiffGenerator >> writeExtended: aNumber to: aStream [
    "Encode aNumber (a positive integer) as 80-bit IEEE 754 extended.
     Byte layout: sign+exponent (16 bits) | mantissa (64 bits, integer part explicit)."
    | value exp mantissa bytes |
    value := aNumber asFloat.
    value = 0.0 ifTrue: [
        10 timesRepeat: [ aStream nextPut: 0 ].
        ^ self ].
    exp := (value log: 2) floor.
    mantissa := (value / (2 raisedTo: exp) * (2 raisedTo: 63)) truncated.
    "biased exponent: bias = 16383"
    exp := exp + 16383.
    bytes := ByteArray new: 10.
    bytes at: 1 put: ((exp bitShift: -8) bitAnd: 16r7F).
    bytes at: 2 put: (exp bitAnd: 16rFF).
    "mantissa, big-endian, 8 bytes"
    1 to: 8 do: [ :i |
        bytes at: 10 - i + 1 put: ((mantissa bitShift: (i - 1) * 8) bitAnd: 16rFF) ].
    aStream nextPutAll: bytes
]

{ #category : 'writing' }
DJAiffGenerator >> writeFourCC: aString to: aStream [
"CC stands for Four Character Code: a 4-byte identifier used in chunk-based binary formats like AIFF and WAV to label each chunk. It's just 4 ASCII characters packed into 4 bytes. aString asByteArray converts 'COMM' into #[67 79 77 77] and writes it directly to the stream "
    aStream nextPutAll: aString asByteArray
]

{ #category : 'writing' }
DJAiffGenerator >> writeInt16BE: anInteger to: aStream [
    aStream nextPut: ((anInteger bitShift: -8) bitAnd: 16rFF).
    aStream nextPut:  (anInteger bitAnd: 16rFF)
]

{ #category : 'writing' }
DJAiffGenerator >> writeInt32BE: anInteger to: aStream [
    aStream nextPut: ((anInteger bitShift: -24) bitAnd: 16rFF).
    aStream nextPut: ((anInteger bitShift: -16) bitAnd: 16rFF).
    aStream nextPut: ((anInteger bitShift:  -8) bitAnd: 16rFF).
    aStream nextPut:  (anInteger                bitAnd: 16rFF)
]

{ #category : 'writing' }
DJAiffGenerator >> writeNAMETo: aStream [
    "NAME chunk: track title"
    self writeTextChunk: 'NAME' string: self trackTitle to: aStream 
]

{ #category : 'writing' }
DJAiffGenerator >> writeSSNDTo: aStream [
    | dataSize |
    dataSize := self numFrames * self bytesPerSample * self numChannels.
    self writeFourCC: 'SSND' to: aStream.
    self writeInt32BE: dataSize + 8 to: aStream.    "8 = offset(4) + blockSize(4)"
    self writeUInt32BE: 0 to: aStream.              "offset"
    self writeUInt32BE: 0 to: aStream.              "blockSize"
    dataSize timesRepeat: [ aStream nextPut: 0 ]   "silence = all zeros"
]

{ #category : 'writing' }
DJAiffGenerator >> writeTextChunk: fourCC string: aString to: aStream [
    "Write a text chunk with optional pad byte for even size."
    | bytes size |
    bytes := aString asByteArray.
    size  := bytes size.
    self writeFourCC: fourCC to: aStream.
    self writeInt32BE: size to: aStream .
    aStream nextPutAll: bytes.
    size odd ifTrue: [ aStream nextPut: 0 ]   "AIFF chunks must start on even boundary"
]

{ #category : 'writing' }
DJAiffGenerator >> writeUInt32BE: anInteger to: aStream [
    self writeInt32BE: anInteger to: aStream 
]

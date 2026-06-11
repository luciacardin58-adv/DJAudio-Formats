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
	#superclass : 'DJAudioFileGenerator',
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

{ #category : 'accessing' }
DJAiffGenerator >> bitsPerSample [ 
 
^ 24
]

{ #category : 'writing' }
DJAiffGenerator >> buildPayload [ 
    "Assemble all inner chunks."
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

{ #category : 'accessing' }
DJAiffGenerator >> bytesPerSample [ 
 ^ self bitsPerSample // 8 
]

{ #category : 'accessing' }
DJAiffGenerator >> durationInSeconds [ 
^ 3
]

{ #category : 'accessing' }
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

{ #category : 'accessing' }
DJAiffGenerator >> numChannels [ 
^ 1
]

{ #category : 'accessing' }
DJAiffGenerator >> numFrames [

	^ self sampleRate * self durationInSeconds
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

{ #category : 'accessing' }
DJAiffGenerator >> sampleRate [ 
^ 48000
]

{ #category : 'writing' }
DJAiffGenerator >> writeCOMMTo: aStream [ 
    "COMM: numChannels(2) + numFrames(4) + bitDepth(2) + sampleRate(10) = 18 bytes"
    self writeFourCC: 'COMM' to: aStream.
    self writeInt32BE: 18 to: aStream.
    self writeInt16BE: self numChannels   to: aStream.
    self writeUInt32BE: self numFrames    to: aStream.
    self writeInt16BE: self bitsPerSample to: aStream.
    self writeExtended: self sampleRate   to: aStream
]

{ #category : 'writing' }
DJAiffGenerator >> writeContainerTo: aStream [ 
    "Write FORM/AIFF container with all chunks to aStream."
    | payload |
    payload := self buildPayload.
    self writeFourCC: 'FORM' to: aStream.
    self writeInt32BE: payload size + 4 to: aStream.   "+4 for 'AIFF' tag"
    self writeFourCC: 'AIFF' to: aStream.
    aStream nextPutAll: payload
]

{ #category : 'writing' }
DJAiffGenerator >> writeSSNDTo: aStream [ 
    "SSND: offset(4) + blockSize(4) + silence."
    | dataSize |
    dataSize := self numFrames * self bytesPerSample * self numChannels.
    self writeFourCC: 'SSND' to: aStream.
    self writeInt32BE: dataSize + 8 to: aStream.
    self writeUInt32BE: 0 to: aStream.   "offset"
    self writeUInt32BE: 0 to: aStream.   "blockSize"
    aStream nextPutAll: (ByteArray new: dataSize)   "silence in one shot"

]

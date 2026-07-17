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
DJAiffGenerator class >> generateTo: aFileReference [ 
    "Entry point. Write a silent 24-bit 48kHz mono AIFF to aFileReference."
    | gen aStream |
    gen := self new.
    aStream := WriteStream on: ByteArray new.
    gen writeContainerTo: aStream.
    aFileReference binaryWriteStreamDo: [ :s |
        s nextPutAll: aStream contents ].
    ^ aFileReference
]

{ #category : 'writing' }
DJAiffGenerator >> buildPayload [
	"Assemble all inner chunks."
	| aStream meta |
	aStream := WriteStream on: ByteArray new.
	meta := self metadata.
	self writeCOMMTo: aStream.
	frequency
		ifNil:   [ self writeSSNDTo: aStream ]
		ifNotNil: [ self writeSineSSND: frequency to: aStream ].
	self writeTextChunk: 'NAME' string: (meta at: 'title') to: aStream.
	self writeTextChunk: 'AUTH' string: (meta at: 'artist') to: aStream.
	self writeTextChunk: 'ANNO' string: (meta at: 'comment') to: aStream.
	self
		writeTextChunk: 'ANNO'
		string: 'Album: ' , (meta at: 'album')
		to: aStream.
	self
		writeTextChunk: 'ANNO'
		string: 'Year: ' , (meta at: 'year')
		to: aStream.
	self
		writeTextChunk: 'ANNO'
		string: 'Genre: ' , (meta at: 'genre')
		to: aStream.
	^ aStream contents
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
DJAiffGenerator >> writeIntBE: anInteger bytes: n to: s [
	"n-byte big-endian, two's complement for negatives."

	n to: 1 by: -1 do: [ :i |
		s nextPut: ((anInteger bitShift: i - 1 * 8 negated) bitAnd: 16rFF) ]
			
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

{ #category : 'writing' }
DJAiffGenerator >> writeSineSSND: freq to: s [ 
    "SSND chunk: full-scale sine at freq Hz, big-endian, any bit depth."
    | dataSize amp nBytes |
    nBytes   := self bytesPerSample.
    dataSize := self numFrames * nBytes * self numChannels.
    amp      := (2 raisedTo: (nBytes * 8) - 1) - 1.
    self writeFourCC: 'SSND' to: s.
    self writeInt32BE: dataSize + 8 to: s.
    self writeUInt32BE: 0 to: s.
    self writeUInt32BE: 0 to: s.
    0 to: self numFrames - 1 do: [ :n |
        | value |
        value := (amp * (2 * Float pi * freq * n / self sampleRate) sin) rounded.
        self numChannels timesRepeat: [
            self writeIntBE: value bytes: nBytes to: s ] ]

]

"
Generates a silent but structurally valid WAV file for tests.
   - 3 seconds, 16-bit, 44100 Hz, stereo
   - Metadata via LIST/INFO chunk: title, artist
"
Class {
	#name : 'DJWavGenerator',
	#superclass : 'DJAudioFileGenerator',
	#category : 'DJAudio-Formats-Helpers',
	#package : 'DJAudio-Formats',
	#tag : 'Helpers'
}

{ #category : 'template method' }
DJWavGenerator class >> generateTo: aFileReference [ 
    "Entry point. Write a silent 24-bit 48kHz mono WAV to aFileReference."
    | gen aStream |
    gen := self new.
    aStream := WriteStream on: ByteArray new.
    gen writeContainerTo: aStream.
    aFileReference binaryWriteStreamDo: [ :s |
        s nextPutAll: aStream contents ].
    ^ aFileReference
]

{ #category : 'helpers' }
DJWavGenerator >> blockAlign [ 
^ self numChannels * self bytesPerSample 
]

{ #category : 'writing' }
DJWavGenerator >> buildDataChunk [ 
    "data chunk: silence."
    | dataSize aStream |
    dataSize := self numFrames * self numChannels * self bytesPerSample.
    aStream := WriteStream on: ByteArray new.
    self writeFourCC: 'data' to: aStream.
    self writeInt32LE: dataSize to: aStream.
    aStream nextPutAll: (ByteArray new: dataSize).   "silence in one shot"
    ^ aStream contents
]

{ #category : 'writing' }
DJWavGenerator >> buildFmtChunk [ 
    | aStream |
    aStream := WriteStream on: ByteArray new.
    self writeFourCC: 'fmt ' to: aStream.
    self writeInt32LE: 16                to: aStream.   "chunk size: PCM = 16"
    self writeInt16LE: 1                 to: aStream.   "audioFormat: 1 = PCM"
    self writeInt16LE: self numChannels  to: aStream.
    self writeInt32LE: self sampleRate   to: aStream.
    self writeInt32LE: self byteRate     to: aStream.
    self writeInt16LE: self blockAlign   to: aStream.
    self writeInt16LE: self bitsPerSample to: aStream.
    ^ aStream contents
]

{ #category : 'writing' }
DJWavGenerator >> buildListChunk [ 
    "LIST/INFO chunk carrying INAM (title) and IART (artist)."
    | inner aStream meta |
    meta  := self metadata.
    inner := WriteStream on: ByteArray new.
    self writeFourCC: 'INFO' to: inner.
    self writeInfoSubchunk: 'INAM' string: (meta at: 'title')  to: inner.
    self writeInfoSubchunk: 'IART' string: (meta at: 'artist') to: inner.
    aStream := WriteStream on: ByteArray new.
    self writeFourCC: 'LIST' to: aStream.
    self writeInt32LE: inner contents size to: aStream.
    aStream nextPutAll: inner contents.
    ^ aStream contents
]

{ #category : 'writing' }
DJWavGenerator >> buildSineDataChunk: freq [ 
    "data chunk: full-scale sine at freq Hz, little-endian, any bit depth."
    | dataSize aStream amp nBytes |
    nBytes   := self bytesPerSample.
    dataSize := self numFrames * self numChannels * nBytes.
    amp      := (2 raisedTo: (nBytes * 8) - 1) - 1.
    aStream  := WriteStream on: ByteArray new.
    self writeFourCC: 'data' to: aStream.
    self writeInt32LE: dataSize to: aStream.
    0 to: self numFrames - 1 do: [ :n |
        | value |
        value := (amp * (2 * Float pi * freq * n / self sampleRate) sin) rounded.
        self numChannels timesRepeat: [
            self writeIntLE: value bytes: nBytes to: aStream ] ].
    ^ aStream contents

]

{ #category : 'helpers' }
DJWavGenerator >> byteRate [ 
^ self sampleRate * self numChannels * self bytesPerSample 
]

{ #category : 'accessing' }
DJWavGenerator >> metadata [ 
    ^ Dictionary new
        at: 'artist' put: 'Lucia Cardin';
        at: 'title'  put: 'DummyWav';
        yourself
]

{ #category : 'writing' }
DJWavGenerator >> writeContainerTo: aStream [
	"Write RIFF/WAVE container with fmt, LIST/INFO, and data chunks."

	| fmtChunk listChunk dataChunk totalSize |
	fmtChunk := self buildFmtChunk.
	listChunk := self buildListChunk.
	dataChunk := frequency
		ifNil:   [ self buildDataChunk ]
		ifNotNil: [ self buildSineDataChunk: frequency ].
	totalSize := 4 + fmtChunk size + listChunk size + dataChunk size.
	self writeFourCC: 'RIFF' to: aStream.
	self writeInt32LE: totalSize to: aStream.
	self writeFourCC: 'WAVE' to: aStream.
	aStream nextPutAll: fmtChunk.
	aStream nextPutAll: listChunk.
	aStream nextPutAll: dataChunk
]

{ #category : 'writing' }
DJWavGenerator >> writeInfoSubchunk: fourCC string: aString to: aStream [ 
    "WAV INFO subchunks are null-terminated and padded to even size."
    | bytes size |
    bytes := aString asByteArray.
    size  := bytes size + 1.   "include null terminator"
    self writeFourCC: fourCC to: aStream.
    self writeInt32LE: size to: aStream.
    aStream nextPutAll: bytes.
    aStream nextPut: 0.        "null terminator"
    size odd ifTrue: [ aStream nextPut: 0 ]   "pad to even boundary"
]

{ #category : 'writing' }
DJWavGenerator >> writeIntLE: anInteger bytes: n to: aStream [ 
    "n-byte little-endian, two's complement for negatives."
    1 to: n do: [ :i |
        aStream nextPut: ((anInteger bitShift: (i - 1) * 8 negated) bitAnd: 16rFF)]
]

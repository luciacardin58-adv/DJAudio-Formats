"
Abstract base for programmatic audio file generators. Used exclusively in test.
 Subclasses must implement:
   metadata           — Dictionary with string keys
   writeContainerTo:  — write the full binary format to a WriteStream
 
 The factory method forFormat: returns the right concrete generator.
"
Class {
	#name : 'DJAudioFileGenerator',
	#superclass : 'Object',
	#category : 'DJAudio-Formats-Helpers',
	#package : 'DJAudio-Formats',
	#tag : 'Helpers'
}

{ #category : 'factory' }
DJAudioFileGenerator class >> forFormat: aFormatSymbol [ 
    "Return the concrete generator for aFormatSymbol (#aiff or #wav)."
    aFormatSymbol = #aiff ifTrue: [ ^ DJAiffGenerator new ].
    aFormatSymbol = #wav  ifTrue: [ ^ DJWavGenerator new ].
    ^ self error: 'Unknown format: ' , aFormatSymbol printString
]

{ #category : 'template method' }
DJAudioFileGenerator class >> generateTo: aFileReference [ 
    "Generate a test file at aFileReference. Returns aFileReference."
    ^ self new generateTo: aFileReference
]

{ #category : 'accessing' }
DJAudioFileGenerator >> bitsPerSample [ 
 
^ 24
]

{ #category : 'accessing' }
DJAudioFileGenerator >> bytesPerSample [ 
 ^ self bitsPerSample // 8 
]

{ #category : 'accessing' }
DJAudioFileGenerator >> durationInSeconds [ 
^ 3
]

{ #category : 'template method' }
DJAudioFileGenerator >> generateTo: aFileReference [ 
    "Write the binary content to aFileReference. Returns aFileReference."
    | stream |
    stream := WriteStream on: ByteArray new.
    self writeContainerTo: stream.
    aFileReference binaryWriteStreamDo: [ :aWriteStream |
        aWriteStream nextPutAll: stream contents ].
    ^ aFileReference
]

{ #category : 'accessing' }
DJAudioFileGenerator >> metadata [ 
^ self subclassResponsibility 
]

{ #category : 'accessing' }
DJAudioFileGenerator >> numChannels [ 
^ 1
]

{ #category : 'accessing' }
DJAudioFileGenerator >> numFrames [

	^ self sampleRate * self durationInSeconds
]

{ #category : 'accessing' }
DJAudioFileGenerator >> sampleRate [ 
^ 48000
]

{ #category : 'writing' }
DJAudioFileGenerator >> writeContainerTo: aStream [
"Write the full binary container (header + chunks) to aStream."
^ self subclassResponsibility
]

{ #category : 'writing' }
DJAudioFileGenerator >> writeExtended: aNumber to: aStream [ 
    "80-bit IEEE 754 extended big-endian — required for AIFF COMM sample rate."
    | value exp mantissa bytes |
    value := aNumber asFloat.
    value = 0.0 ifTrue: [
        10 timesRepeat: [ aStream nextPut: 0 ].
        ^ self ].
    exp      := (value log: 2) floor.
    mantissa := (value / (2 raisedTo: exp) * (2 raisedTo: 63)) truncated.
    exp      := exp + 16383.
    bytes    := ByteArray new: 10.
    bytes at: 1 put: ((exp bitShift: -8) bitAnd: 16r7F).
    bytes at: 2 put:  (exp               bitAnd: 16rFF).
    1 to: 8 do: [ :i |
        bytes at: 10 - i + 1
              put: ((mantissa bitShift: (i - 1) * 8) bitAnd: 16rFF) ].
    aStream nextPutAll: bytes
]

{ #category : 'writing' }
DJAudioFileGenerator >> writeFourCC: aString to: aStream [ 
    aStream nextPutAll: aString asByteArray
]

{ #category : 'writing' }
DJAudioFileGenerator >> writeInt16BE: anInteger to: aStream [ 
    aStream nextPut: ((anInteger bitShift: -8) bitAnd: 16rFF).
    aStream nextPut:  (anInteger bitAnd: 16rFF)
]

{ #category : 'writing' }
DJAudioFileGenerator >> writeInt16LE: anInteger to: aStream [

	aStream nextPut: (anInteger bitAnd: 16rFF).
	aStream nextPut: ((anInteger bitShift: -8) bitAnd: 16rFF)
]

{ #category : 'writing' }
DJAudioFileGenerator >> writeInt32BE: anInteger to: aStream [ 
    aStream nextPut: ((anInteger bitShift: -24) bitAnd: 16rFF).
    aStream nextPut: ((anInteger bitShift: -16) bitAnd: 16rFF).
    aStream nextPut: ((anInteger bitShift:  -8) bitAnd: 16rFF).
    aStream nextPut: ( anInteger bitAnd: 16rFF)
]

{ #category : 'writing' }
DJAudioFileGenerator >> writeInt32LE: anInteger to: aStream [ 
    aStream nextPut:  (anInteger                bitAnd: 16rFF).
    aStream nextPut: ((anInteger bitShift:  -8) bitAnd: 16rFF).
    aStream nextPut: ((anInteger bitShift: -16) bitAnd: 16rFF).
    aStream nextPut: ((anInteger bitShift: -24) bitAnd: 16rFF)
]

{ #category : 'writing' }
DJAudioFileGenerator >> writeTextChunk: fourCC string: aString to: aStream [ 
    | bytes |
    bytes := aString asByteArray.
    self writeFourCC: fourCC to: aStream.
    self writeInt32BE: bytes size to: aStream.
    aStream nextPutAll: bytes.
    bytes size odd ifTrue: [ aStream nextPut: 0 ]   "pad to even boundary"
]

{ #category : 'writing' }
DJAudioFileGenerator >> writeUInt32BE: anInteger to: aStream [ 
    self writeInt32BE: anInteger to: aStream
]

"
I am the abstract base for all audio format readers.

I define the interface that every concrete format (AIFF, WAV, MP3) must implement:
- fileExtensions — the file extensions this format handles
- formatName     — human-readable name e.g. ''AIFF''
- readInfoFrom:  — parse a file and return a DJAudioFileInfo

I also provide canHandleFile: as a concrete method that checks the file extension
against fileExtensions — subclasses do not need to override it.

Inspired by JUCE''s AudioFormat class.
"
Class {
	#name : 'DJAudioFormat',
	#superclass : 'Object',
	#instVars : [
		'formats'
	],
	#category : 'DJAudio-Formats-Readers',
	#package : 'DJAudio-Formats',
	#tag : 'Readers'
}

{ #category : 'accessing' }
DJAudioFormat >> canHandleFile: aFileReference [ 
"Mirrors JUCE AudioFormat::canHandleFile — checks extension only"
    | ext |
    ext := aFileReference extension asLowercase.
    ^self fileExtensions anySatisfy: [ :e | e = ('.' , ext) ]
]

{ #category : 'accessing' }
DJAudioFormat >> fileExtensions [ 

self subclassResponsibility 
]

{ #category : 'accessing' }
DJAudioFormat >> formatName [

	self subclassResponsibility
]

{ #category : 'accessing' }
DJAudioFormat >> formats [

	^ { DJAiffAudioFormat new . DJWavAudioFormat new }
]

{ #category : 'reading' }
DJAudioFormat >> readFourCC: aStream [ 
    ^ String new: 4 streamContents: [ :s |
        4 timesRepeat: [ s nextPut: (Character value: aStream next) ] ]
]

{ #category : 'reading' }
DJAudioFormat >> readInfoFrom: aFileReference [ 
    self subclassResponsibility
]

{ #category : 'reading' }
DJAudioFormat >> readInfoFromFile: aFileReference [ 
    formats do: [ :fmt |
        (fmt canHandleFile: aFileReference) ifTrue: [
            ^fmt readInfoFrom: aFileReference
        ]
    ].
    ^nil
]

{ #category : 'reading' }
DJAudioFormat >> readLittleEndian16: aStream [ 
    | b0 b1 |
    b0 := aStream next.
    b1 := aStream next.
    ^ (b1 bitShift: 8) + b0
]

{ #category : 'reading' }
DJAudioFormat >> readLittleEndian32: aStream [ 
    | b0 b1 b2 b3 |
    b0 := aStream next. b1 := aStream next.
    b2 := aStream next. b3 := aStream next.
    ^ (b3 bitShift: 24) + (b2 bitShift: 16) + (b1 bitShift: 8) + b0
]

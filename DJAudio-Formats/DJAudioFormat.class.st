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

{ #category : 'as yet unclassified' }
DJAudioFormat >> readInfoFrom: aFileReference [ 
    self subclassResponsibility
]

{ #category : 'as yet unclassified' }
DJAudioFormat >> readInfoFromFile: aFileReference [ 
    formats do: [ :fmt |
        (fmt canHandleFile: aFileReference) ifTrue: [
            ^fmt readInfoFrom: aFileReference
        ]
    ].
    ^nil
]

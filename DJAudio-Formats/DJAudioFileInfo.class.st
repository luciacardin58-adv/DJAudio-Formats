"
I  hold the result of reading an audio file header.

I store both technical properties (sampleRate, bitsPerSample, numChannels, lengthInSamples, usesFloatingPoint) and a metadata dictionary for tags such as title, artist, and BPM.

I am the Pharo equivalent of the public fields exposed by JUCE''s AudioFormatReader, factored out into a standalone object since Pharo''s reader does not stream samples.'
"
Class {
	#name : 'DJAudioFileInfo',
	#superclass : 'Object',
	#instVars : [
		'filePath',
		'sampleRate',
		'bitsPerSample',
		'lengthInSamples',
		'numChannels',
		'usesFloatingPoint',
		'metadata',
		'dataOffset',
		'dataSize'
	],
	#category : 'DJAudio-Formats-Readers',
	#package : 'DJAudio-Formats',
	#tag : 'Readers'
}

{ #category : 'query metadata' }
DJAudioFileInfo >> artist [ 
    ^metadata at: 'artist' ifAbsent: [ '' ]
]

{ #category : 'helpers' }
DJAudioFileInfo >> bitrateKbps [ 
    ^(sampleRate * bitsPerSample * numChannels / 1000) rounded
]

{ #category : 'accessing' }
DJAudioFileInfo >> bitsPerSample [

	^ bitsPerSample
]

{ #category : 'accessing' }
DJAudioFileInfo >> bitsPerSample: anInteger [

	bitsPerSample := anInteger
]

{ #category : 'query metadata' }
DJAudioFileInfo >> bpm [ 
    ^metadata at: 'bpm' ifAbsent: [ nil ]

]

{ #category : 'helpers' }
DJAudioFileInfo >> channelDescription [ 

"stereo or mono"
    numChannels = 1 ifTrue: [ ^'Mono' ].
    numChannels = 2 ifTrue: [ ^'Stereo' ].
    ^numChannels printString 
]

{ #category : 'accessing' }
DJAudioFileInfo >> dataOffset [ 

^ dataOffset
]

{ #category : 'accessing' }
DJAudioFileInfo >> dataOffset: anInteger [

dataOffset := anInteger 
]

{ #category : 'accessing' }
DJAudioFileInfo >> dataSize [ 

^ dataSize
]

{ #category : 'accessing' }
DJAudioFileInfo >> dataSize: anInteger [ 

dataSize := anInteger 
]

{ #category : 'helpers' }
DJAudioFileInfo >> duration [
	^ Duration seconds: self  durationInSeconds 
]

{ #category : 'helpers' }
DJAudioFileInfo >> durationInSeconds [
	 ^ self lengthInSamples / self sampleRate 
]

{ #category : 'accessing' }
DJAudioFileInfo >> filePath [

	^ filePath
]

{ #category : 'accessing' }
DJAudioFileInfo >> filePath: aFilePath [

	filePath := aFilePath
]

{ #category : 'initialization' }
DJAudioFileInfo >> initialize [ 
    metadata         := Dictionary new.
    usesFloatingPoint := false.
    sampleRate       := 44100.
    bitsPerSample    := 16.
    lengthInSamples  := 0.
    numChannels      := 2.
]

{ #category : 'accessing' }
DJAudioFileInfo >> lengthInSamples [

	^ lengthInSamples
]

{ #category : 'accessing' }
DJAudioFileInfo >> lengthInSamples: anInteger [

	lengthInSamples := anInteger
]

{ #category : 'accessing' }
DJAudioFileInfo >> metadata [

	^ metadata
]

{ #category : 'accessing' }
DJAudioFileInfo >> metadata: anObject [

	metadata := anObject
]

{ #category : 'accessing' }
DJAudioFileInfo >> numChannels [

	^ numChannels
]

{ #category : 'accessing' }
DJAudioFileInfo >> numChannels: anInteger [

	numChannels := anInteger
]

{ #category : 'printing' }
DJAudioFileInfo >> printOn: aStream [ 
    aStream
        nextPutAll: 'DJAudioFileInfo(';
        nextPutAll: self title;
        nextPutAll: ' | ';
        print: sampleRate;
        nextPutAll: 'Hz ';
        print: bitsPerSample;
        nextPutAll: 'bit ';
        nextPutAll: self channelDescription;
        nextPut: $)

]

{ #category : 'accessing' }
DJAudioFileInfo >> sampleRate [

	^ sampleRate
]

{ #category : 'accessing' }
DJAudioFileInfo >> sampleRate: anObject [

	sampleRate := anObject
]

{ #category : 'query metadata' }
DJAudioFileInfo >> title [  

    ^metadata at: 'title' ifAbsent: [
        filePath ifNil: [ '' ] ifNotNil: [ :p | p asFileReference basenameWithoutExtension ] ]

]

{ #category : 'accessing' }
DJAudioFileInfo >> usesFloatingPoint [

	^ usesFloatingPoint
]

{ #category : 'accessing' }
DJAudioFileInfo >> usesFloatingPoint: aBoolean [

	usesFloatingPoint := aBoolean
]

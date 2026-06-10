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
		'metadata'
	],
	#category : 'DJAudio-Formats',
	#package : 'DJAudio-Formats'
}

{ #category : 'accessing' }
DJAudioFileInfo >> bitsPerSample [

	^ bitsPerSample
]

{ #category : 'accessing' }
DJAudioFileInfo >> bitsPerSample: anInteger [

	bitsPerSample := anInteger
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

{ #category : 'accessing' }
DJAudioFileInfo >> sampleRate [

	^ sampleRate
]

{ #category : 'accessing' }
DJAudioFileInfo >> sampleRate: anObject [

	sampleRate := anObject
]

{ #category : 'accessing' }
DJAudioFileInfo >> usesFloatingPoint [

	^ usesFloatingPoint
]

{ #category : 'accessing' }
DJAudioFileInfo >> usesFloatingPoint: aBoolean [

	usesFloatingPoint := aBoolean
]

Class {
	#name : 'DJAudioFileInfoTest',
	#superclass : 'TestCase',
	#instVars : [
		'info'
	],
	#category : 'DJAudio-Formats-Tests',
	#package : 'DJAudio-Formats',
	#tag : 'Tests'
}

{ #category : 'running' }
DJAudioFileInfoTest >> setUp [
	super setUp.
info := DJAudioFileInfo  new.
]

{ #category : 'tests' }
DJAudioFileInfoTest >> testDuration [ 

"88200 samples at 44.1 kHz sample rate last 1 second"
info lengthInSamples: 88200.

self assert: info durationInSeconds equals: 2
]

{ #category : 'tests' }
DJAudioFileInfoTest >> testInitialize [ 
self assert: info sampleRate equals: 44100.
    self assert: info bitsPerSample equals: 16.
    self assert: info numChannels equals: 2.
    self assert: info lengthInSamples equals: 0.
    self deny: info usesFloatingPoint.
    self assert: info metadata isEmpty.
]

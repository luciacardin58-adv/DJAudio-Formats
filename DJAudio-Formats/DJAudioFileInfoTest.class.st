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

{ #category : 'accessing' }
DJAudioFileInfoTest >> testDuration [

info lengthInSamples: 44100 * 332.

self assert: info duration equals: (Duration seconds: 332).
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

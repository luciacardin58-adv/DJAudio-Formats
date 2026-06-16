Class {
	#name : 'DJWavAudioFormatsTest',
	#superclass : 'TestCase',
	#instVars : [
		'testFile',
		'info'
	],
	#category : 'DJAudio-Formats-Tests',
	#package : 'DJAudio-Formats',
	#tag : 'Tests'
}

{ #category : 'running' }
DJWavAudioFormatsTest >> setUp [ 
    super setUp.
    testFile := DJWavGenerator generateTo:
        FileLocator temp asFileReference / 'dj_test.wav'.
    info := DJWavAudioFormat new readInfoFrom: testFile
]

{ #category : 'running' }
DJWavAudioFormatsTest >> tearDown [ 
    testFile exists ifTrue: [ testFile delete ].
    super tearDown
]

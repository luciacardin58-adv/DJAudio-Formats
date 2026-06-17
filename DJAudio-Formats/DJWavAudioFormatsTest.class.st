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

{ #category : 'tests' }
DJWavAudioFormatsTest >> testBitrateKbps [
	"48000 * 24  / 1000 = 1411"

	self assert: info bitrateKbps equals: 1152.

]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testCanHandleWavExtension [ 
    self assert: (DJWavAudioFormat new canHandleFile: 'track.wav' asFileReference)
]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testCannotHandleAiffExtension [ 
    self deny: (DJWavAudioFormat new canHandleFile: 'track.aiff' asFileReference)
]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testCannotHandleMp3Extension [ 
    self deny: (DJWavAudioFormat new canHandleFile: 'track.mp3' asFileReference)
]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testChannelDescriptionStereo [

	self assert: info channelDescription equals: 'Mono'
]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testDurationInSeconds [

 self assert: info durationInSeconds equals: 3
]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testFilePathSet [ 
    self assert: info filePath equals: testFile fullName

]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testInfoNotNil [ 
    self assert: info notNil
]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testReadSampleRate [ 
self assert: info sampleRate equals: 48000
]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testReadsArtist [ 
    self assert: info artist equals: 'Lucia Cardin'
]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testReadsBitsPerSample [

	self assert: info bitsPerSample equals: 24
]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testReadsNumChannels [

	self assert: info numChannels equals: 1
]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testReadsNumFrames [
	"48000 Hz * 3 seconds = 144000 frames"

	self assert: info lengthInSamples equals: 144000
]

{ #category : 'tests' }
DJWavAudioFormatsTest >> testReadsTitle [ 
    self assert: info title equals: 'DummyWav'
]

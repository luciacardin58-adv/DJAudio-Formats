"
Reads back the file produced by DJAiffGenerator and asserts
 every field matches exactly what the generator wrote.
"
Class {
	#name : 'DJAiffAudioFormatsTests',
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
DJAiffAudioFormatsTests >> setUp [

	super setUp.
	testFile := DJAiffGenerator generateTo:
		            FileLocator temp / 'dj_test.aiff'.
	info := DJAiffAudioFormat new readInfoFrom: testFile
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> tearDown [ 
 testFile exists ifTrue: [ testFile delete ]
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffArtist [
    self assert: info artist equals: 'Lucia Cardin'
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffBitrateKbps [ 
    "48000 * 24 * 1 / 1000 = 1152"
   
    self assert: info bitrateKbps equals: 1152
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffBitsPerSample [ 
    self assert: info bitsPerSample equals: 24
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffCanHandleAifExtension [ 
    self assert: (DJAiffAudioFormat new canHandleFile:
        'track.aif' asFileReference)
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffCanHandleAiffExtension [ 
    self assert: (DJAiffAudioFormat new canHandleFile:
        'track.aiff' asFileReference)
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffCannotHandleMp3Extension [ 
    self deny: (DJAiffAudioFormat new canHandleFile:
        'track.mp3' asFileReference)
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffCannotHandleWavExtension [ 
    self deny: (DJAiffAudioFormat new canHandleFile:
        'track.wav' asFileReference)
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffChannelDescription [ 
    self assert: info channelDescription equals: 'Mono'
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffComment [ 
    self assert: (info metadata at: 'comment') equals: 'Silent Test'
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffDurationSeconds [ 
    self assert: info durationInSeconds equals: 3
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffNumChannels [
    self assert: info numChannels equals: 1
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffNumFrames [ 
    self assert: info lengthInSamples equals: 144000
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffReturnsNilForInvalidFile [
    | bogus result |
    bogus := FileLocator temp asFileReference / 'invalid.aiff'.
    bogus binaryWriteStreamDo: [ :aStream |
        aStream nextPutAll: #[0 0 0 0 0 0 0 0] ].
    result := DJAiffAudioFormat new readInfoFrom: bogus.
    bogus delete.
    self assert: result isNil
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffSampleRate [ 
    
    self assert: info sampleRate equals: 48000
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testAiffTitle [
    self assert: info title equals: 'DummyAiff'
]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testFilePathSet [ 
    self assert: (info filePath endsWith: 'dj_test.aiff')

]

{ #category : 'running' }
DJAiffAudioFormatsTests >> testInfoNotNil [ 
    self assert: info notNil

]

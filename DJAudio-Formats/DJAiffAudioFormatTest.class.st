"
Reads back the file produced by DJAiffGenerator and asserts
 every field matches exactly what the generator wrote.
"
Class {
	#name : 'DJAiffAudioFormatTest',
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
DJAiffAudioFormatTest >> setUp [

	super setUp.
	testFile := DJAiffGenerator generateTo:
		            FileLocator temp / 'dj_test.aiff'.
	info := DJAiffAudioFormat new readInfoFrom: testFile
]

{ #category : 'running' }
DJAiffAudioFormatTest >> tearDown [ 
 testFile exists ifTrue: [ testFile delete ]
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffArtist [
    self assert: info artist equals: 'Lucia Cardin'
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffBitrateKbps [ 
    "48000 * 24 * 1 / 1000 = 1152"
   
    self assert: info bitrateKbps equals: 1152
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffBitsPerSample [ 
    self assert: info bitsPerSample equals: 24
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffCanHandleAifExtension [ 
    self assert: (DJAiffAudioFormat new canHandleFile:
        'track.aif' asFileReference)
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffCanHandleAiffExtension [ 
    self assert: (DJAiffAudioFormat new canHandleFile:
        'track.aiff' asFileReference)
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffCannotHandleMp3Extension [ 
    self deny: (DJAiffAudioFormat new canHandleFile:
        'track.mp3' asFileReference)
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffCannotHandleWavExtension [ 
    self deny: (DJAiffAudioFormat new canHandleFile:
        'track.wav' asFileReference)
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffChannelDescription [ 
    self assert: info channelDescription equals: 'Mono'
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffComment [ 
    self assert: (info metadata at: 'comment') equals: 'Genre: Ambient'
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffDurationSeconds [ 
    self assert: info durationInSeconds equals: 3
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffNumChannels [
    self assert: info numChannels equals: 1
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffNumFrames [ 
    self assert: info lengthInSamples equals: 144000
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffReturnsNilForInvalidFile [
    | bogus result |
    bogus := FileLocator temp asFileReference / 'invalid.aiff'.
    bogus binaryWriteStreamDo: [ :aStream |
        aStream nextPutAll: #[0 0 0 0 0 0 0 0] ].
    result := DJAiffAudioFormat new readInfoFrom: bogus.
    bogus delete.
    self assert: result isNil
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffSampleRate [ 
    
    self assert: info sampleRate equals: 48000
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testAiffTitle [
    self assert: info title equals: 'DummyAiff'
]

{ #category : 'running' }
DJAiffAudioFormatTest >> testFilePathSet [ 
    self assert: (info filePath endsWith: 'dj_test.aiff')

]

{ #category : 'running' }
DJAiffAudioFormatTest >> testInfoNotNil [ 
    self assert: info notNil

]

{ #category : 'running' }
DJAiffAudioFormatTest >> testPeaksMatchFullScaleSine [ 
    | file info samples peaks |
    file    := DJWavGenerator new
                   "whatever your generator API is — sine, 1s, 44100, 16-bit, mono"
                   generateTo: (FileLocator temp asFileReference / 'peaks-test.wav').
    info    := DJWavAudioFormat new readInfoFrom: file.
    samples := DJWavAudioFormat new readSamplesFrom: file info: info.
    peaks   := DJWavAudioFormat new peaksFrom: samples buckets: 100.

    "each bucket spans many full cycles → hits both rails"
    peaks do: [ :each |
        self assert: (each second between: 0.9 and: 1.0).    "max near +1"
        self assert: (each first  between: -1.0 and: -0.9) ]. "min near -1"

]

Class {
	#name : 'DJSineGenerationTest',
	#superclass : 'TestCase',
	#category : 'DJAudio-Formats-Tests',
	#package : 'DJAudio-Formats',
	#tag : 'Tests'
}

{ #category : 'asserting' }
DJSineGenerationTest >> assertFullScalePeaks: peaks [

	 "Every bucket of a full-scale sine must reach both rails."
		peaks do: [ :each | "max near +1"
				self assert: (each first between: -1.0 and: -0.9). "min near -1"
				self assert: (each second between: 0.9 and: 1.0) ] 
]

{ #category : 'tests' }
DJSineGenerationTest >> testAiffSinePeaks [ 
    | gen stream file info samples peaks |
    gen := DJAiffGenerator new.
    gen frequency: 480.                    "48000 / 480 = 100 samples/cycle"
    stream := WriteStream on: ByteArray new.
    gen writeContainerTo: stream.
    file := FileLocator temp asFileReference / 'dj-aiff-sine.aiff'.
    file binaryWriteStreamDo: [ :s | s nextPutAll: stream contents ].
    [ info    := DJAiffAudioFormat new readInfoFrom: file.
      samples := DJAiffAudioFormat new readSamplesFrom: file info: info.
      peaks   := DJAiffAudioFormat new peaksFrom: samples buckets: 100.
      self assertFullScalePeaks: peaks ]
        ensure: [ file ensureDelete ]

]

{ #category : 'tests' }
DJSineGenerationTest >> testWavSinePeaks [ 
    | gen stream file info samples peaks |
    gen := DJWavGenerator new.
    gen frequency: 441.                    "44100 / 441 = 100 samples/cycle"
    stream := WriteStream on: ByteArray new.
    gen writeContainerTo: stream.
    file := FileLocator temp asFileReference / 'dj-wav-sine.wav'.
    file binaryWriteStreamDo: [ :s | s nextPutAll: stream contents ].
    [ info    := DJWavAudioFormat new readInfoFrom: file.
      samples := DJWavAudioFormat new readSamplesFrom: file info: info.
      peaks   := DJWavAudioFormat new peaksFrom: samples buckets: 100.
      self assertFullScalePeaks: peaks ]
        ensure: [ file ensureDelete ]

]

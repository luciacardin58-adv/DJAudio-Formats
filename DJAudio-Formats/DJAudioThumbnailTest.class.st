Class {
	#name : 'DJAudioThumbnailTest',
	#superclass : 'TestCase',
	#category : 'DJAudio-Formats-Tests',
	#package : 'DJAudio-Formats',
	#tag : 'Tests'
}

{ #category : 'tests' }
DJAudioThumbnailTest >> newThumbnailWith: sptS [
"Build a thumbnail with a given block size for tests."
	^ DJAudioThumbnail new samplesPerThumbSample: sptS; yourself
]

{ #category : 'tests' }
DJAudioThumbnailTest >> testComputeMinMaxPerBlock [
	| t |
	t := self newThumbnailWith: 4.
	t computeFrom: #(0.1 0.5 -0.2 -0.9  0.3 0.8 -0.1 -0.4).
	self assert: ((t peaks at: 1) x closeTo: -0.9).
	self assert: ((t peaks at: 1) y closeTo: 0.5).
	self assert: ((t peaks at: 2) x closeTo: -0.4).
	self assert: ((t peaks at: 2) y closeTo: 0.8)
]

{ #category : 'tests' }
DJAudioThumbnailTest >> testComputeOneThumbPerBlock [
	| t |
	t := self newThumbnailWith: 4.
	t computeFrom: #(0.1 0.5 -0.2 -0.9  0.3 0.8 -0.1 -0.4).
	self assert: t size equals: 2
]

{ #category : 'tests' }
DJAudioThumbnailTest >> testEmpty [
	| t |
	t := self newThumbnailWith: 4.
	self assert: (t peaksForColumns: 10) isEmpty.
	self assert: (t minMaxFrom: 1 to: 5) equals: 0.0 @ 0.0
]

{ #category : 'tests' }
DJAudioThumbnailTest >> testFromGeneratedFile [
	| file t |
	file := DJWavGenerator generateTo: (FileLocator temp asFileReference / 'thumb-test.wav').
	t := DJAudioThumbnail fromFile: file.
	self assert: t peaks notEmpty.
	self assert: t sampleRate equals: 48000.
	t peaks do: [ :p |
		self assert: p x >= -1.0.
		self assert: p y <= 1.0 ].
	file delete
]

{ #category : 'tests' }
DJAudioThumbnailTest >> testPartialFinalBlock [
	| t |
	t := self newThumbnailWith: 4.
	t computeFrom: #(0.1 0.5 -0.2 -0.9  0.3 0.8).  "6 samples -> 2 thumbs"
	self assert: t size equals: 2.
	self assert: ((t peaks at: 2) y closeTo: 0.8)
]

{ #category : 'tests' }
DJAudioThumbnailTest >> testPeaksForColumnsAggregates [
	| t cols |
	t := self newThumbnailWith: 1.
	t computeFrom: #(0.1 0.5  0.2 0.9  -0.3 -0.8  -0.1 -0.4).
	cols := t peaksForColumns: 4.
	self assert: cols size equals: 4.
	self assert: ((cols at: 1) x closeTo: 0.1).
	self assert: ((cols at: 1) y closeTo: 0.5).
	self assert: ((cols at: 3) x closeTo: -0.8).
	self assert: ((cols at: 3) y closeTo: -0.3)
]

{ #category : 'tests' }
DJAudioThumbnailTest >> testPeaksForColumnsCappedAtPeakCount [
	| t |
	t := self newThumbnailWith: 1.
	t computeFrom: #(0.1 0.5 0.2).
	self assert: (t peaksForColumns: 99) size equals: 3
]

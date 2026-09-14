Class {
	#name : 'DJOnsetEnvelopeTest',
	#superclass : 'TestCase',
	#instVars : [
		'testFile',
		'info'
	],
	#category : 'DJAudio-Formats-Tests',
	#package : 'DJAudio-Formats',
	#tag : 'Tests'
}

{ #category : 'accessing' }
DJOnsetEnvelopeTest >> clickTrainAt: aBpm seconds: nSeconds rate: aRate [
	"Decaying 64-sample bursts at aBpm, silence between. Short enough that
	 a burst sits inside one hop, so each click yields one envelope peak."

	| samples total period burst |
	burst := 64.
	total := aRate * nSeconds.
	period := (aRate * 60 / aBpm) rounded.
	samples := Float32Array new: total.
	0 to: total - burst by: period do: [ :offset |
		1 to: burst do: [ :k |
			samples at: offset + k put: 1.0 - (k / burst) ] ].
	^ samples
]

{ #category : 'accessing' }
DJOnsetEnvelopeTest >> peakIndicesOf: anEnvelope [
	"Frames above half the maximum. One per click, given the generator above."

	| frames threshold |
	frames := anEnvelope frames.
	threshold := (frames inject: 0 into: [ :a :b | a max: b ]) / 2.
	^ (1 to: frames size) select: [ :i | (frames at: i) > threshold ]
]

{ #category : 'accessing' }
DJOnsetEnvelopeTest >> testEnvelopeIsNonNegative [

	| env |
	env := DJOnsetEnvelope
		       on: (self clickTrainAt: 120 seconds: 6 rate: 44100)
		       rate: 44100.
	self deny: (env frames anySatisfy: [ :each | each < 0 ])
]

{ #category : 'accessing' }
DJOnsetEnvelopeTest >> testFrameRate [

	| env |
	env := DJOnsetEnvelope on: (Float32Array new: 44100) rate: 44100.
	self assert: env frameRate equals: 44100 / 512
]

{ #category : 'accessing' }
DJOnsetEnvelopeTest >> testPeaksAlignWithClicks [
	"120 BPM at 44100 with hop 512 is 22050 / 512 = 43.07 frames per beat,
	 so consecutive peaks sit 43 or 44 frames apart."

	| env peaks gaps |
	env := DJOnsetEnvelope
		       on: (self clickTrainAt: 120 seconds: 6 rate: 44100)
		       rate: 44100.
	peaks := self peakIndicesOf: env.
	gaps := (2 to: peaks size) collect: [ :i |
		        (peaks at: i) - (peaks at: i - 1) ].
	self assert: gaps notEmpty.
	self assert: (gaps allSatisfy: [ :each | each between: 42 and: 45 ])
]

{ #category : 'accessing' }
DJOnsetEnvelopeTest >> testShortInputIsEmpty [
	"Fewer than two hops: a difference needs two."

	| env |
	env := DJOnsetEnvelope on: (Float32Array new: 100) rate: 44100.
	self assert: env frames isEmpty
]

{ #category : 'accessing' }
DJOnsetEnvelopeTest >> testSilenceGivesZeroEnvelope [

	| env |
	env := DJOnsetEnvelope on: (Float32Array new: 44100) rate: 44100.
	self assert: (env frames allSatisfy: [ :each | each = 0 ])
]

{ #category : 'accessing' }
DJOnsetEnvelopeTest >> testSizeIsHopsMinusOne [

	| env |
	env := DJOnsetEnvelope on: (Float32Array new: 5120) rate: 44100.
	self assert: env size equals: 9
]

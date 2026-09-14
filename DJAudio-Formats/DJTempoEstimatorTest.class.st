Class {
	#name : 'DJTempoEstimatorTest',
	#superclass : 'TestCase',
	#category : 'DJAudio-Formats-Tests',
	#package : 'DJAudio-Formats',
	#tag : 'Tests'
}

{ #category : 'accessing' }
DJTempoEstimatorTest >> assertBpmOf: anEstimator isNear: aBpm [

	self assert: anEstimator hasResult.
	self assert: (anEstimator bpm - aBpm) abs < 0.1
]

{ #category : 'accessing' }
DJTempoEstimatorTest >> estimateAt: aBpm seconds: nSeconds [

	^ DJTempoEstimator on: (DJOnsetEnvelope
			   on: (DJTestSignals clickTrainAt: aBpm seconds: nSeconds rate: 44100)
			   rate: 44100)
]

{ #category : 'accessing' }
DJTempoEstimatorTest >> testCleanTrain [

	self assertBpmOf: (self estimateAt: 128 seconds: 20) isNear: 128
]

{ #category : 'accessing' }
DJTempoEstimatorTest >> testFastTempoIsNotHalved [
	"Regression: with octaveSigma at 0.9 this answered 75."

	self assertBpmOf: (self estimateAt: 150 seconds: 20) isNear: 150
]

{ #category : 'accessing' }
DJTempoEstimatorTest >> testLongTrackDoesNotDrift [
	"Regression: beats were predicted from an integer lag, which slides
	 about 0.4 frames per beat and lost lock past roughly 30 beats. A
	 four-minute track read 1.2 BPM high."

	self assertBpmOf: (self estimateAt: 128 seconds: 240) isNear: 128
]

{ #category : 'accessing' }
DJTempoEstimatorTest >> testPhaseFallsWithinFirstBeat [

	| estimator lag |
	estimator := self estimateAt: 128 seconds: 20.
	lag := estimator frameRate * 60 / estimator bpm.
	self assert: estimator phase >= 0.
	self assert: estimator phase < lag
]

{ #category : 'accessing' }
DJTempoEstimatorTest >> testShortEnvelopeHasNoResult [
	"Too few frames to autocorrelate at the slowest lag."

	| estimator |
	estimator := DJTempoEstimator on:
		             (DJOnsetEnvelope on: (Float32Array new: 44100) rate: 44100).
	self deny: estimator hasResult.
	self assert: estimator bpm isNil
]

{ #category : 'accessing' }
DJTempoEstimatorTest >> testSlowAndFastEndsOfRange [

	self assertBpmOf: (self estimateAt: 90 seconds: 20) isNear: 90.
	self assertBpmOf: (self estimateAt: 174 seconds: 20) isNear: 174
]

"
I reduce a mono sample array to an onset strength envelope: one non-negative value per hop of `hopSize` source samples, high where energy rises.

I am the input to **DJTempoEstimator**. I am Bloc-free and take a plain _Float32Array_, so I am testable headless against synthetic signals.

Method: mean square per hop, log, half-wave-rectified first difference.
The log makes me respond to relative rises, so a quiet intro and a loud drop contribute comparably. The rectification discards decays, which carry no onset information.

I answer frames size = hops - 1, since a difference needs two hops.
"
Class {
	#name : 'DJOnsetEnvelope',
	#superclass : 'Object',
	#instVars : [
		'hopSize',
		'frames',
		'frameRate'
	],
	#category : 'DJAudio-Formats-Analysis',
	#package : 'DJAudio-Formats',
	#tag : 'Analysis'
}

{ #category : 'instance creation' }
DJOnsetEnvelope class >> on: samples rate: aSampleRate [

	^ self new
		  computeFrom: samples rate: aSampleRate;
		  yourself
]

{ #category : 'computing' }
DJOnsetEnvelope >> computeFrom: samples rate: aSampleRate [
	"samples: mono Float32Array in -1.0..1.0. Answers the receiver."

	| numHops logEnergies result |
	frameRate := aSampleRate / hopSize.
	numHops := (samples size / hopSize) ceiling.
	numHops < 2 ifTrue: [
		frames := Array new.
		^ self ].
	logEnergies := self logEnergiesOf: samples hops: numHops.
	result := Array new: numHops - 1.
	1 to: numHops - 1 do: [ :i |
		result
			at: i
			put: (((logEnergies at: i + 1) - (logEnergies at: i)) max: 0) ].
	frames := result
]

{ #category : 'accessing' }
DJOnsetEnvelope >> frameRate [
	"Envelope frames per second. A lag of n frames is n / frameRate seconds."

	^ frameRate
]

{ #category : 'accessing' }
DJOnsetEnvelope >> frames [ 
^ frames 
]

{ #category : 'accessing' }
DJOnsetEnvelope >> hopSize [ 
^ hopSize 
]

{ #category : 'accessing' }
DJOnsetEnvelope >> hopSize: anInteger [
	"Set before computing. 512 gives about 86 frames/s at 44.1k."

	hopSize := anInteger
]

{ #category : 'initialization' }
DJOnsetEnvelope >> initialize [

	super initialize.
	hopSize := 512.
	frames := Array new.
	frameRate := 0
]

{ #category : 'computing' }
DJOnsetEnvelope >> logEnergiesOf: samples hops: numHops [
	"Log mean-square per hop. The floor keeps digital silence finite."

	| result |
	result := Array new: numHops.
	1 to: numHops do: [ :i |
		| start stop sum |
		start := i - 1 * hopSize + 1.
		stop := start + hopSize - 1 min: samples size.
		sum := 0.
		start to: stop do: [ :j | sum := sum + (samples at: j) squared ].
		result at: i put: (sum / (stop - start + 1) + 1e-10) ln ].
	^ result
]

{ #category : 'accessing' }
DJOnsetEnvelope >> size [

	^ frames size
]

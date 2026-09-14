"
I estimate a tempo, and a beat phase, from a DJOnsetEnvelope.

I autocorrelate the envelope over the lags corresponding to minBpm..maxBpm, weight each lag by a log-normal prior centred on 120 BPM to break octave ambiguity, take the strongest, and refine it by parabolic interpolation
between neighbouring lags. Integer lags alone give about 1.4 BPM ofresolution at 120; interpolation brings that under 0.1.

Phase is the offset, in envelope frames, at which a comb spaced by the winning lag best matches the envelope. It is the first beat, not a full beat grid: I assume one constant tempo for the whole track.

I answer nil for bpm when the envelope is too short to autocorrelate.

Narrowing minBpm..maxBpm is the same lever rekordbox exposes as its BPM range preference, and it is the most effective fix for an octave error.
"
Class {
	#name : 'DJTempoEstimator',
	#superclass : 'Object',
	#instVars : [
		'minBpm',
		'maxBpm',
		'bpm',
		'phase',
		'frames',
		'frameRate'
	],
	#category : 'DJAudio-Formats-Analysis',
	#package : 'DJAudio-Formats',
	#tag : 'Analysis'
}

{ #category : 'instance creation' }
DJTempoEstimator class >> on: aDJOnsetEnvelope [

	^ self new
		  computeFrom: aDJOnsetEnvelope;
		  yourself
]

{ #category : 'compute' }
DJTempoEstimator >> autocorrelationAt: aLag [
	"Divided by the number of terms, so lags are comparable to each other."

	| sum count |
	count := frames size - aLag.
	count <= 0 ifTrue: [ ^ 0 ].
	sum := 0.
	1 to: count do: [ :i |
		sum := sum + ((frames at: i) * (frames at: i + aLag)) ].
	^ sum / count
]

{ #category : 'accessing' }
DJTempoEstimator >> bpm [
	"A Float, or nil when the envelope was too short."

	^ bpm
]

{ #category : 'converting' }
DJTempoEstimator >> bpmForLag: aLag [

	^ frameRate * 60 / aLag
]

{ #category : 'compute' }
DJTempoEstimator >> computeFrom: aDJOnsetEnvelope [
	"Answers the receiver. bpm stays nil if the envelope is too short."

	| minLag maxLag scores bestIndex bestLag |
	frames := aDJOnsetEnvelope frames.
	frameRate := aDJOnsetEnvelope frameRate.
	bpm := nil.
	phase := nil.
	minLag := (self lagForBpm: maxBpm) floor max: 1.
	maxLag := (self lagForBpm: minBpm) ceiling.
	frames size < (maxLag * 2) ifTrue: [ ^ self ].
	scores := self scoresFrom: minLag to: maxLag.
	bestIndex := self indexOfMaximumIn: scores.
	bestLag := minLag + bestIndex - 1.
	bpm := (self bpmForLag:
			 bestLag + (self refinementOf: scores at: bestIndex)) asFloat.
	phase := self phaseForLag: bestLag
]

{ #category : 'testing' }
DJTempoEstimator >> hasResult [

	^ bpm notNil
]

{ #category : 'compute' }
DJTempoEstimator >> indexOfMaximumIn: aCollection [

	| best index |
	best := aCollection first.
	index := 1.
	2 to: aCollection size do: [ :i |
		(aCollection at: i) > best ifTrue: [
			best := aCollection at: i.
			index := i ] ].
	^ index
]

{ #category : 'initialization' }
DJTempoEstimator >> initialize [

	super initialize.
	minBpm := 60.
	maxBpm := 180
]

{ #category : 'compute' }
DJTempoEstimator >> interceptOf: positions against: beatNumbers slope: aSlope [
	"Position of beat zero implied by the fit."

	| sumT sumK |
	sumT := positions inject: 0 into: [ :a :b | a + b ].
	sumK := beatNumbers inject: 0 into: [ :a :b | a + b ].
	^ sumT - (aSlope * sumK) / beatNumbers size
]

{ #category : 'converting' }
DJTempoEstimator >> lagForBpm: aBpm [

	^ frameRate * 60 / aBpm
]

{ #category : 'accessing' }
DJTempoEstimator >> maxBpm [

^ maxBpm 
]

{ #category : 'accessing' }
DJTempoEstimator >> maxBpm: aNumber [ 

maxBpm := aNumber 
]

{ #category : 'accessing' }
DJTempoEstimator >> minBpm [
^ minBpm 
]

{ #category : 'accessing' }
DJTempoEstimator >> minBpm: aNumber [ 

minBpm := aNumber 
]

{ #category : 'compute' }
DJTempoEstimator >> observeBeatsFrom: anIntercept spacing: aSpacing window: aWindow limit: aLimit [
	"Answer { beat numbers . observed positions }. A predicted beat with no
	 peak above threshold near it is skipped, not invented."

	| threshold numbers positions k position |
	threshold := (frames inject: 0 into: [ :a :b | a max: b ]) * 0.1.
	numbers := OrderedCollection new.
	positions := OrderedCollection new.
	k := 0.
	position := anIntercept.
	[ position < (frames size - 1) and: [ k < aLimit ] ] whileTrue: [
		| observed |
		observed := self
			            peakNear: position rounded
			            within: aWindow
			            above: threshold.
		observed ifNotNil: [
			numbers add: k.
			positions add: observed ].
		k := k + 1.
		position := anIntercept + (k * aSpacing) ].
	^ {
		  numbers.
		  positions }
]

{ #category : 'accessing' }
DJTempoEstimator >> octaveSigma [
	"Prior width in octaves. Narrow: 0.9 halves 150 BPM, 0.45 doubles 174.
	 This is a compromise, not a solution. Set minBpm/maxBpm for real work."

	^ 0.55
]

{ #category : 'accessing' }
DJTempoEstimator >> phase [
	"First beat, in envelope frames."

	^ phase
]

{ #category : 'compute' }
DJTempoEstimator >> phaseForLag: aLag [
	"The offset, 0 to aLag - 1, where a comb spaced by aLag sums highest.
	 Bounded to a prefix: aLag is an integer, so over a long track the comb
	 drifts off the real beats and every offset scores alike."

	| bestOffset bestSum limit |
	limit := aLag * self seedBeats min: frames size.
	bestOffset := 0.
	bestSum := -1.
	0 to: aLag - 1 do: [ :offset |
		| sum index |
		sum := 0.
		index := offset + 1.
		[ index <= limit ] whileTrue: [
			sum := sum + (frames at: index).
			index := index + aLag ].
		sum > bestSum ifTrue: [
			bestSum := sum.
			bestOffset := offset ] ].
	^ bestOffset
]

{ #category : 'accessing' }
DJTempoEstimator >> phaseInSeconds [

	^ phase ifNil: [ nil ] ifNotNil: [ :each | (each / frameRate) asFloat ]
]

{ #category : 'compute' }
DJTempoEstimator >> refinedLagFrom: aLag [
"Iterated least-squares fit of beat position against beat number.Pass one is limited to seedBeats because it predicts from the integer aLag, which drifts. Later passes predict from the fractional slope, whose drift is negligible, and use the whole track. Also refines phase, so a beat grid starts from a sub-frame first beat."

	| slope intercept |
	slope := aLag.
	intercept := phase.
	1 to: self refinementPasses do: [ :pass |
		| beats numbers positions window limit newSlope |
		window := pass = 1
			          ifTrue: [ (aLag / 4) rounded max: 1 ]
			          ifFalse: [ (slope / 8) rounded max: 2 ].
		limit := pass = 1
			         ifTrue: [ self seedBeats ]
			         ifFalse: [ frames size ].
		beats := self
			         observeBeatsFrom: intercept
			         spacing: slope
			         window: window
			         limit: limit.
		numbers := beats first.
		positions := beats second.
		numbers size < 4 ifTrue: [ ^ aLag ].
		newSlope := self slopeOf: positions against: numbers.
		newSlope ifNil: [ ^ aLag ].
		slope := newSlope.
		intercept := self
			             interceptOf: positions
			             against: numbers
			             slope: slope ].
	(slope - aLag) abs / aLag > 0.1 ifTrue: [ ^ aLag ].
	phase := intercept.
	^ slope
]

{ #category : 'compute' }
DJTempoEstimator >> refinementOf: scores at: anIndex [
	"Parabolic interpolation through three points. Answers a fractional
	 lag offset between -0.5 and 0.5. Zero at either edge of the range."

	| left centre right denominator |
	(anIndex = 1 or: [ anIndex = scores size ]) ifTrue: [ ^ 0 ].
	left := scores at: anIndex - 1.
	centre := scores at: anIndex.
	right := scores at: anIndex + 1.
	denominator := left - (2 * centre) + right.
	denominator = 0 ifTrue: [ ^ 0 ].
	^ (left - right) / (2 * denominator)
]

{ #category : 'accessing' }
DJTempoEstimator >> refinementPasses [ 
^ 4
]

{ #category : 'compute' }
DJTempoEstimator >> scoresFrom: minLag to: maxLag [
	"Autocorrelation at each lag, tilted by the tempo prior."

	^ (minLag to: maxLag) collect: [ :lag |
		  (self autocorrelationAt: lag)
		  * (self weightForBpm: (self bpmForLag: lag)) ]
]

{ #category : 'accessing' }
DJTempoEstimator >> seedBeats [
	"Beats available to phase detection and to the first fit pass. Both
	 predict from an integer lag, so both must stay near the start."

	^ 24
]

{ #category : 'compute' }
DJTempoEstimator >> weightForBpm: aBpm [
	"Log-normal prior. Without it, 174 reads as 87 about as often as not."

	| octaves |
	octaves := (aBpm / 120) log: 2.
	^ ((octaves / self octaveSigma) squared / 2) negated exp
]

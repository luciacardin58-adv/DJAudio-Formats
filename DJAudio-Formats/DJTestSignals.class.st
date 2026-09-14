"
I synthesise signals with known properties for analysis tests.

Unlike DJAudioFileGenerator I write no file: I answer a Float32Array
directly, since the analysis classes take samples rather than paths.
"
Class {
	#name : 'DJTestSignals',
	#superclass : 'Object',
	#category : 'DJAudio-Formats-Helpers',
	#package : 'DJAudio-Formats',
	#tag : 'Helpers'
}

{ #category : 'accessing' }
DJTestSignals class >> clickTrainAt: aBpm seconds: nSeconds rate: aRate [
	"Decaying 64-sample bursts at aBpm, silence between. The true tempo is aRate * 60 / the rounded period, which is not exactly aBpm."

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

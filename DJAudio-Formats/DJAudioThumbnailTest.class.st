Class {
	#name : 'DJAudioThumbnailTest',
	#superclass : 'TestCase',
	#category : 'DJAudio-Formats-Tests',
	#package : 'DJAudio-Formats',
	#tag : 'Tests'
}

{ #category : 'tests' }
DJAudioThumbnailTest >> testFromGeneratedFile [
	| file t |
	file := DJWavGenerator generateTo: (FileLocator temp asFileReference / 'thumb-test.wav').
	t := DJAudioThummbnail fromFile: file.
	self assert: t peaks notEmpty.
	self assert: t sampleRate equals: 44100.
	t peaks do: [ :p |
		self assert: p x >= -1.0.
		self assert: p y <= 1.0 ].
	file delete
]

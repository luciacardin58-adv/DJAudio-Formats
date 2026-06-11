"
Abstract base for programmatic audio file generators. Used exclusively in test.
 Subclasses must implement:
   metadata           — Dictionary with string keys
   writeContainerTo:  — write the full binary format to a WriteStream
 
 The factory method forFormat: returns the right concrete generator.
"
Class {
	#name : 'DJAudioFileGenerator',
	#superclass : 'Object',
	#category : 'DJAudio-Formats-Helpers',
	#package : 'DJAudio-Formats',
	#tag : 'Helpers'
}

{ #category : 'as yet unclassified' }
DJAudioFileGenerator class >> forFormat: aFormatSymbol [ 
    "Return the concrete generator for aFormatSymbol (#aiff or #wav)."
    aFormatSymbol = #aiff ifTrue: [ ^ DJAiffGenerator new ].
    aFormatSymbol = #wav  ifTrue: [ ^ DJWavGenerator new ].
    ^ self error: 'Unknown format: ' , aFormatSymbol printString
]

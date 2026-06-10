"
I  hold the result of reading an audio file header.

I store both technical properties (sampleRate, bitsPerSample, numChannels, lengthInSamples, usesFloatingPoint) and a metadata dictionary for tags such as title, artist, and BPM.

I am the Pharo equivalent of the public fields exposed by JUCE''s AudioFormatReader, factored out into a standalone object since Pharo''s reader does not stream samples.'
"
Class {
	#name : 'DJAudioFileInfo',
	#superclass : 'Object',
	#instVars : [
		'filePath',
		'sampleRate',
		'bitsPerSample',
		'lengthInSamples',
		'numChannels',
		'usesFloatingPoint',
		'metadata'
	],
	#category : 'DJAudio-Formats',
	#package : 'DJAudio-Formats'
}

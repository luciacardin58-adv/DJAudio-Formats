"
Generates a silent but structurally valid WAV file for tests.
   - 3 seconds, 16-bit, 44100 Hz, stereo
   - Metadata via LIST/INFO chunk: title, artist
"
Class {
	#name : 'DJWavGenerator',
	#superclass : 'DJAudioFileGenerator',
	#category : 'DJAudio-Formats-Helpers',
	#package : 'DJAudio-Formats',
	#tag : 'Helpers'
}

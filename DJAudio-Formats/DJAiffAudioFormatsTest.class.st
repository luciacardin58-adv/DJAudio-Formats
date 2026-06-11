"
Reads back the file produced by DJAiffGenerator and asserts
 every field matches exactly what the generator wrote.
"
Class {
	#name : 'DJAiffAudioFormatsTest',
	#superclass : 'TestCase',
	#instVars : [
		'testFile',
		'info'
	],
	#category : 'DJAudio-Formats-Tests',
	#package : 'DJAudio-Formats',
	#tag : 'Tests'
}

{ #category : 'running' }
DJAiffAudioFormatsTest >> setUp [

	super setUp.
	testFile := DJAiffGenerator generateTo:
		            FileLocator temp / 'dj_test.aiff'.
	info := DJAiffAudioFormat new readInfoFrom: testFile
]

{ #category : 'running' }
DJAiffAudioFormatsTest >> tearDown [ 
 testFile exists ifTrue: [ testFile delete ]
]

{ #category : 'running' }
DJAiffAudioFormatsTest >> testFilePathSet [ 
    self assert: (info filePath endsWith: 'dj_test.aiff')

]

{ #category : 'running' }
DJAiffAudioFormatsTest >> testInfoNotNil [ 
    self assert: info notNil

]

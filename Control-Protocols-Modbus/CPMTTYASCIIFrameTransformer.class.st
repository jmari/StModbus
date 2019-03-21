Class {
	#name : #CPMTTYASCIIFrameTransformer,
	#superclass : #CPMFrameTransformer,
	#instVars : [
		'header'
	],
	#category : #'Control-Protocols-Modbus-FrameTransformers'
}

{ #category : #'as yet unclassified' }
CPMTTYASCIIFrameTransformer >> LRC [
	| nLRC |
	nLRC := 8r0.
	self modbusTelegram contents do:[:aByte | nLRC := nLRC + aByte].
	^  nLRC negated

 	
]

{ #category : #'as yet unclassified' }
CPMTTYASCIIFrameTransformer >> header [
	^ header ifNil:[ header:= ByteArray with: 16r3a]
]

{ #category : #'as yet unclassified' }
CPMTTYASCIIFrameTransformer >> telegram [
	frame ifNil:[ frame := ReadWriteStream on: OrderedCollection new].
	frame 
		nextPutAll:  self header;
		nextPutAll:  self modbusTelegram contents asByteString;
		nextPutAll:  self LRC asByteString;
		nextPutAll:  self trailer.
	^frame
]

{ #category : #'as yet unclassified' }
CPMTTYASCIIFrameTransformer >> trailer [
	^ String crlf
 	
]

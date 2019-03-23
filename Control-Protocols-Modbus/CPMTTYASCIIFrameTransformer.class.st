Class {
	#name : #CPMTTYASCIIFrameTransformer,
	#superclass : #CPMFrameTransformer,
	#instVars : [
		'header'
	],
	#category : #'Control-Protocols-Modbus-FrameTransformers'
}

{ #category : #'as yet unclassified' }
CPMTTYASCIIFrameTransformer class >> parseFromStream: aStream [
	| i frame crc baCrc|
	i := self new.
	frame := aStream upToEnd.
	frame isEmpty ifTrue:[^ nil].
	crc := frame copyFrom:(frame size -29) to: (frame size - 28).	
	frame := frame copyFrom:29 to: (frame size - 30).	
	baCrc := (CRC crc16FromCollection: frame) asByteArray.
	(((baCrc at:1) = (crc at:1)) and:[ ((baCrc at:2) = (crc at:2))])
		ifFalse:[CPMCRCException signal].
		
	i modbusFunction: (CPMModbusFunction parseFromStream: (ReadStream on:frame)) .

	^ i 
]

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

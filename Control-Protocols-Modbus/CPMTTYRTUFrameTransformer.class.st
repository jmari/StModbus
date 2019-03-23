Class {
	#name : #CPMTTYRTUFrameTransformer,
	#superclass : #CPMFrameTransformer,
	#instVars : [
		'header',
		'trailer'
	],
	#category : #'Control-Protocols-Modbus-FrameTransformers'
}

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameTransformer class >> parseFromStream: aStream [
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
CPMTTYRTUFrameTransformer >> CRC [
	^( CRC crc16FromCollection: self modbusTelegram  ) asByteArray
 	
]

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameTransformer >> header [
 	^ header ifNil:[ header:= ByteArray new: 28]
]

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameTransformer >> telegram [
	frame ifNil:[ frame := ReadWriteStream on: OrderedCollection new].
	frame 
		nextPutAll:  self header;
		nextPutAll:  self modbusTelegram;
		nextPutAll:  self CRC;
		nextPutAll:  self trailer.
	^frame contents asByteArray  
]

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameTransformer >> trailer [
	^ trailer ifNil:[ trailer := ByteArray new:28]
 	
]

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
	crc := frame copyFrom: (frame size -1) to: frame size.	
	frame := frame copyFrom:1 to: (frame size - 2).	
	baCrc := (CRC crc16FromModbusFrame: (frame copyFrom:1 to: frame size)) asByteArray.		
	i modbusFunction: (CPMModbusFunction parseFromStream: (ReadStream on:frame)) .
	(((baCrc at:1) = (crc at:2)) and:[ ((baCrc at:2) = (crc at:1))])
		ifFalse:[CPMCRCException signal].
	^ i 
]

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameTransformer >> CRC [
	| crcWord |
	crcWord := (CRC crc16FromModbusFrame: self modbusTelegram  ) asByteArray.
	^ Array with:(crcWord at:2) with:(crcWord at:1)
 	
]

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameTransformer >> header [
 	^ header ifNil:[ header:= ByteArray new: 28]
]

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameTransformer >> telegram [

	frame ifNil:[ frame := ReadWriteStream on: OrderedCollection new].
	self header.
	frame 
		nextPutAll:  self modbusTelegram;
		nextPutAll:  self CRC.
	self trailer.
	^frame contents asByteArray  
]

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameTransformer >> trailer [
	^ trailer ifNil:[ trailer := ByteArray new:28]
 	
]

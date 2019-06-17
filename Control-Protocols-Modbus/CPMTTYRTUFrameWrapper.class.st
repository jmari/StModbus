Class {
	#name : #CPMTTYRTUFrameWrapper,
	#superclass : #CPMFrameWrapper,
	#instVars : [
		'header',
		'trailer'
	],
	#category : #'Control-Protocols-Modbus-FrameWrappers'
}

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameWrapper class >> parseFromStream: aStream [
	| i frame crc baCrc|
	i := self new.
	frame := aStream upToEnd.
	frame isEmpty ifTrue:[^ nil].
	crc := frame copyFrom: (frame size -1) to: frame size.	
	frame := frame copyFrom:1 to: (frame size - 2).	
	baCrc := (CRC crc16FromModbusFrame: frame) asByteArray.		
	i modbusFunction: (CPMModbusFunction parseFromStream: (ReadStream on:frame)) .
	(((baCrc at:1) = (crc at:2)) and:[ ((baCrc at:2) = (crc at:1))])
		ifFalse:[CPMCRCException signal].
	^ i  
]

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameWrapper >> CRC [
	^ self CRC:self modbusTelegram 
 	
]

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameWrapper >> CRC: aByteArray [
	| crcWord |
	crcWord := (CRC crc16FromModbusFrame: aByteArray ) asByteArray.
	^ Array with:(crcWord at:2 ifAbsent:[0]) with:(crcWord at:1)
 	
]

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameWrapper >> header [
 	^ header ifNil:[ header:= ByteArray new: 28]
]

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameWrapper >> telegram [

	frame := ReadWriteStream on: OrderedCollection new.
	frame 
		nextPutAll:  self modbusTelegram;
		nextPutAll:  self CRC.

	^frame contents asByteArray  
]

{ #category : #'as yet unclassified' }
CPMTTYRTUFrameWrapper >> trailer [
	^ trailer ifNil:[ trailer := ByteArray new:28]
 	
]

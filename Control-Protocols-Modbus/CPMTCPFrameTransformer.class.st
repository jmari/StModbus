Class {
	#name : #CPMTCPFrameTransformer,
	#superclass : #CPMFrameTransformer,
	#instVars : [
		'transactionID',
		'protocolID'
	],
	#category : #'Control-Protocols-Modbus-FrameTransformers'
}

{ #category : #parsing }
CPMTCPFrameTransformer class >> parseFromStream: aStream [
	| i |
	i := self new.

	i transactionID: ((aStream next <<8) bitOr: (aStream next)).
	i protocolID: ((aStream next <<8) bitOr: (aStream next)).
	aStream 
		next;
		next.

	i modbusFunction: (CPMModbusFunction parseFromStream: aStream) .

	^ i 
]

{ #category : #'as yet unclassified' }
CPMTCPFrameTransformer >> header [
	| s |
	s :=ByteArray new:6.
	s at:1 put:  self transactionID >> 8.
	s at:2 put:  (self transactionID  bitAnd:16rFF).
	s at:3 put:  self protocolID >> 8.
	s at:4 put:  (self protocolID  bitAnd:16rFF).
	s at:5 put:  self modbusTelegram size >> 8.
	s at:6 put:  (self modbusTelegram size bitAnd:16rFF).


	^ s
 	
]

{ #category : #accessing }
CPMTCPFrameTransformer >> protocolID [
	^ protocolID ifNil:[0]
]

{ #category : #accessing }
CPMTCPFrameTransformer >> protocolID: twoBytes [
	protocolID := twoBytes
]

{ #category : #'as yet unclassified' }
CPMTCPFrameTransformer >> telegram [

	self modbusTelegram at:1 put: self unitID.
	frame := ReadWriteStream on: OrderedCollection new.
	frame
		nextPutAll:  self header;
		nextPutAll:  self modbusTelegram.
	^frame contents asByteArray   
]

{ #category : #'as yet unclassified' }
CPMTCPFrameTransformer >> trailer [
	^ String crlf asByteArray 
 	
]

{ #category : #accessing }
CPMTCPFrameTransformer >> transactionID [
	^ transactionID ifNil:[0]
]

{ #category : #accessing }
CPMTCPFrameTransformer >> transactionID: anObject [
	transactionID := anObject
]

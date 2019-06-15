Class {
	#name : #CPMFrameWrapper,
	#superclass : #Object,
	#instVars : [
		'frame',
		'modbusTelegram',
		'modbusFunction',
		'unitID'
	],
	#category : #'Control-Protocols-Modbus-FrameWrappers'
}

{ #category : #'as yet unclassified' }
CPMFrameWrapper class >> on:aModbusTelegram [

	^ self new modbusTelegram: aModbusTelegram
]

{ #category : #parsing }
CPMFrameWrapper class >> parseFromStream: aStream [
	"parse a received stream and extracts the ModbusFunction object"
	self subclassResponsibility 

]

{ #category : #accessing }
CPMFrameWrapper >> modbusFunction [

	^ modbusFunction
]

{ #category : #accessing }
CPMFrameWrapper >> modbusFunction: aModbusFunctionObject [
	modbusFunction := aModbusFunctionObject
]

{ #category : #accessing }
CPMFrameWrapper >> modbusTelegram [
	^ modbusTelegram
]

{ #category : #accessing }
CPMFrameWrapper >> modbusTelegram: aModbusFunctionTelegram [
	modbusTelegram := aModbusFunctionTelegram
]

{ #category : #'as yet unclassified' }
CPMFrameWrapper >> telegram [
	"Returns a telegram including protocol header, function telegram and trail depending on the fisical layer"
	self subclassResponsibility 
]

{ #category : #accessing }
CPMFrameWrapper >> unitID [
	^ unitID ifNil:[1]
]

{ #category : #accessing }
CPMFrameWrapper >> unitID: anObject [
	unitID := anObject
]

Class {
	#name : #CPMFrameTransformer,
	#superclass : #Object,
	#instVars : [
		'frame',
		'modbusTelegram',
		'modbusFunction'
	],
	#category : #'Control-Protocols-Modbus-FrameTransformers'
}

{ #category : #'as yet unclassified' }
CPMFrameTransformer class >> on:aModbusTelegram [

	^ self new modbusTelegram: aModbusTelegram
]

{ #category : #accessing }
CPMFrameTransformer >> modbusFunction [
	^ modbusFunction
]

{ #category : #accessing }
CPMFrameTransformer >> modbusFunction: anObject [
	modbusFunction := anObject
]

{ #category : #accessing }
CPMFrameTransformer >> modbusTelegram [
	^ modbusTelegram
]

{ #category : #accessing }
CPMFrameTransformer >> modbusTelegram: anObject [
	modbusTelegram := anObject
]

{ #category : #'as yet unclassified' }
CPMFrameTransformer >> telegram [
	self subclassResponsibility 
]
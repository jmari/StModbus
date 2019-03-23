Class {
	#name : #CPMException,
	#superclass : #Error,
	#instVars : [
		'slaveAddress',
		'queryFunction'
	],
	#category : #'Control-Protocols-Modbus-Exceptions'
}

{ #category : #'as yet unclassified' }
CPMException >> LRC [
"TODO compute the LRC"
]

{ #category : #'as yet unclassified' }
CPMException >> code [
	self subclassResponsibility 
]

{ #category : #'as yet unclassified' }
CPMException >> function [
	^ (16r80 bitOr: queryFunction function)
]

{ #category : #accessing }
CPMException >> queryFunction [
	^ queryFunction
]

{ #category : #accessing }
CPMException >> queryFunction: anObject [
	queryFunction := anObject
]

{ #category : #'as yet unclassified' }
CPMException >> responseTelegram [
	^  ByteArray 
		with: self slaveAddress
		with: (self queryFunction function bitOr: 16r80 )
		with: self code
	
]

{ #category : #'as yet unclassified' }
CPMException >> slaveAddress [
	"one bytes address"
	^ slaveAddress ifNil:[ slaveAddress := self queryFunction slaveAddress ]
]

{ #category : #'as yet unclassified' }
CPMException >> slaveAddress: oneByte [
	"one bytes address"
	slaveAddress := oneByte
]

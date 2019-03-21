Class {
	#name : #CPMReadWriteRegistersFunction,
	#superclass : #CPMReadHoldingRegistersFunction,
	#instVars : [
		'presetMultipleRegisterTelegram'
	],
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMReadWriteRegistersFunction class >> newFromStream: aStream [
	| bc instance|
	instance := self new.
	instance startingAddressHigh: aStream next low: aStream next.
	instance numberOfElementsHigh:  aStream next low: aStream next.
	instance presetMultipleRegisterTelegram startingAddressHigh: aStream next low: aStream next.
	instance presetMultipleRegisterTelegram numberOfElementsHigh:  aStream next low: aStream next. 
	bc := aStream next.
	instance presetMultipleRegisterTelegram data: aStream upToEnd.
	^  instance
]

{ #category : #'as yet unclassified' }
CPMReadWriteRegistersFunction >> executeFunctionOn: dataTable [
	[  super executeFunctionOn: dataTable.
		self presetMultipleRegisterTelegram executeFunctionOn: dataTable]
	on: CPMException 
	do: [ :e| 
		e queryFunction:self.
		e signal].
]

{ #category : #'as yet unclassified' }
CPMReadWriteRegistersFunction >> function [
	^function ifNil:[function:=self class readWriteRegisterFunctionCode ]
]

{ #category : #'as yet unclassified' }
CPMReadWriteRegistersFunction >> presetMultipleRegisterTelegram [
	^ presetMultipleRegisterTelegram ifNil:[ presetMultipleRegisterTelegram:= CPMPresetMultipleRegistersFunction new] 
]

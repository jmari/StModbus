Class {
	#name : #CPMForceSingleCoilFunction,
	#superclass : #CPMModbusSinglePresetFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMForceSingleCoilFunction >> executeFunctionOn: dataTable [
	[ dataTable forceCoilAt: self startingAddress put:((self data at:1) bitAnd: 16rFF)]
	on: CPMException 
	do: [ :e| 
		e queryFunction:self.
		e signal].
]

{ #category : #'as yet unclassified' }
CPMForceSingleCoilFunction >> function [
	^function ifNil:[function:=self class forceSingleCoilFunctionCode ] 
]

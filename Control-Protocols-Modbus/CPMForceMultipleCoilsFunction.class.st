Class {
	#name : #CPMForceMultipleCoilsFunction,
	#superclass : #CPMModbusMultiplePresetFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMForceMultipleCoilsFunction >> executeFunctionOn: dataTable [
	[dataTable forceCoilsStartingAt: self startingAddress data:self data numberOfCoils: self numberOfCoils]
	on: CPMException 
	do: [ :e| 
		e queryFunction:self.
		e signal]
]

{ #category : #'as yet unclassified' }
CPMForceMultipleCoilsFunction >> function [
	^function ifNil:[function:=self class forceMultipleCoilFunctionCode ]
]

Class {
	#name : #CPMReadInputStatusFunction,
	#superclass : #CPMModbusReadFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMReadInputStatusFunction >> executeFunctionOn: dataTable [
	[self data: ( dataTable readInputsStartingAt: self startingAddress  numberOfPoints: self numberOfCoils  ) ]	
	on: CPMException 
	do: [ :e| 
		e queryFunction:self.
		e signal].
]

{ #category : #'as yet unclassified' }
CPMReadInputStatusFunction >> function [
	^function ifNil:[function:=self class readInputStatusFunctionCode  ]
]

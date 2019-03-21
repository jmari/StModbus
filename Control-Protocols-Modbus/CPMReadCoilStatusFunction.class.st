Class {
	#name : #CPMReadCoilStatusFunction,
	#superclass : #CPMModbusReadFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMReadCoilStatusFunction >> executeFunctionOn: dataTable [
	[self data: ( dataTable readCoilsStartingAt: self startingAddress  numberOfPoints: self numberOfCoils ) ]
	on: CPMException 
	do: [ :e| 
		e queryFunction:self.
		e signal]
]

{ #category : #'as yet unclassified' }
CPMReadCoilStatusFunction >> function [
	^ function ifNil:[function:=self class readCoilFunctionCode] 
]

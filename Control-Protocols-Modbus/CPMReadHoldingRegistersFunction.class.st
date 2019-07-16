Class {
	#name : #CPMReadHoldingRegistersFunction,
	#superclass : #CPMModbusReadFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMReadHoldingRegistersFunction >> executeFunctionOn: dataTable [
	| c |
	[c := OrderedCollection new.
	(0 to: (self numberOfRegisters -1))
		do:[:offset| 
			|word|
			word :=dataTable 
				readHoldingRegisterAt: (self startingAddress + offset ).
			c add: word >>8.
			c add: (word bitAnd: 16rFF)].
	self data: c asByteArray ]
	
	on: CPMException 
	do: [ :e| 
		e queryFunction:self.
		e signal].
]

{ #category : #'as yet unclassified' }
CPMReadHoldingRegistersFunction >> function [
	^function ifNil:[function:=self class readHoldingRegistersFunctionCode ]
]

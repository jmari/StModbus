Class {
	#name : #CPMPresetMultipleRegistersFunction,
	#superclass : #CPMModbusMultiplePresetFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMPresetMultipleRegistersFunction >> executeFunctionOn: dataTable [

	[(0 to: (self numberOfRegisters -1))
		do:[:offset| 
			dataTable 
				presetHoldingRegisterAt: (self startingAddress + offset ) 
				put: (((self data at:  ((offset * 2) + 1) )  << 8 )
					bitOr:(self data at: ((offset * 2) + 2) ) )]]
	on: CPMException 
	do: [ :e| 
		e queryFunction:self.
		e signal]
	
]

{ #category : #'as yet unclassified' }
CPMPresetMultipleRegistersFunction >> function [
	^function ifNil:[function:=self class presetMultipleRegisterFunctionCode ] 
]

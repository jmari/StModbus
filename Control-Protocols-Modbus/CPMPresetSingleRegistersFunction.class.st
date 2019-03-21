Class {
	#name : #CPMPresetSingleRegistersFunction,
	#superclass : #CPMModbusSinglePresetFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMPresetSingleRegistersFunction >> executeFunctionOn: dataTable [
	 [dataTable presetHoldingRegisterAt: self startingAddress put: ( (self data at:1 )  << 8 bitOr:(self data at:2 ) )]
	on: CPMException 
	do: [ :e| 
		e queryFunction:self.
		e signal].
]

{ #category : #'as yet unclassified' }
CPMPresetSingleRegistersFunction >> function [
	^function ifNil:[function:=self class presetSingleRegisterFunctionCode  ]
]

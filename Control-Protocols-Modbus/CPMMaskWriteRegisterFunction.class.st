Class {
	#name : #CPMMaskWriteRegisterFunction,
	#superclass : #CPMPresetSingleRegistersFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMMaskWriteRegisterFunction >> executeFunctionOn: dataTable [
	 [dataTable 
			maskWriteRegisterAt: self startingAddress 
			and: ( (self data at:1 ) asWord << 8 bitOr:(self data at:2 ) )
			or: ( (self data at:3 ) asWord << 8 bitOr:(self data at:4 ) )]
	on: CPMException 
	do: [ :e| 
		e queryFunction:self.
		e signal].
]

{ #category : #'as yet unclassified' }
CPMMaskWriteRegisterFunction >> function [
	^function ifNil:[function:=self class maskWriteRegisterFunctionCode  ]
]

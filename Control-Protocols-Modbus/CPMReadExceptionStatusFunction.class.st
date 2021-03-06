Class {
	#name : #CPMReadExceptionStatusFunction,
	#superclass : #CPMModbusReadFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #private }
CPMReadExceptionStatusFunction class >> newFromStream:aStream [ 
	"for convenience, all the modbus function classes are instantiate by newFromStream: 
	 but CPMReadExceptionStatusFunction and CPMReportSlaveIDFunction"
	^ self new
]

{ #category : #'as yet unclassified' }
CPMReadExceptionStatusFunction >> executeFunctionOn: dataTable [
	[self data: dataTable exceptionStatus]
	on: CPMException 
	do: [ :e| 
		e queryFunction:self.
		e signal]
]

{ #category : #'as yet unclassified' }
CPMReadExceptionStatusFunction >> function [
	^function ifNil:[function:=self class readExceptionStatusFunctionCode ]
]

{ #category : #'as yet unclassified' }
CPMReadExceptionStatusFunction >> responseTelegram [
	| qf |
	qf:= ReadWriteStream on:OrderedCollection new.
	^(qf
		nextPut: self slaveAddress;
		nextPut: self function;
		nextPutAll: self data;
		contents ) asByteArray

]

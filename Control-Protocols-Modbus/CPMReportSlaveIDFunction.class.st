Class {
	#name : #CPMReportSlaveIDFunction,
	#superclass : #CPMModbusReadFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMReportSlaveIDFunction class >> newFromStream [
	self shouldBeImplemented
]

{ #category : #'as yet unclassified' }
CPMReportSlaveIDFunction >> executeFunctionOn: dataTable [
	[self data: (ByteArray with: 0 with: dataTable slaveId )]
	on: CPMException 
	do: [ :e| 
		e queryFunction:self.
		e signal].
]

{ #category : #'as yet unclassified' }
CPMReportSlaveIDFunction >> function [
	^function ifNil:[function:=self class reportSlaveIDFunctionCode  ]
]

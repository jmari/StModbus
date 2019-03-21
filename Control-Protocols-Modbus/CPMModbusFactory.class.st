Class {
	#name : #CPMModbusFactory,
	#superclass : #Object,
	#instVars : [
		'currentFunction',
		'dataTable',
		'timeout',
		'unitID'
	],
	#category : #'Control-Protocols-Modbus-Main'
}

{ #category : #'as yet unclassified' }
CPMModbusFactory >> connectionEstablished [
]

{ #category : #'as yet unclassified' }
CPMModbusFactory >> connectionRefused [
]

{ #category : #'as yet unclassified' }
CPMModbusFactory >> dataTable [
	^ dataTable ifNil:[ dataTable:= CPMModbusDataTable new slaveId:self unitID] 
]

{ #category : #functions }
CPMModbusFactory >> forceMultipleCoils [
	^ currentFunction :=  CPMForceMultipleCoilsFunction new.
]

{ #category : #functions }
CPMModbusFactory >> forceSingleCoil [
	^ currentFunction :=   CPMForceSingleCoilFunction new.
]

{ #category : #functions }
CPMModbusFactory >> presetMultipleRegisters [
	^ currentFunction :=   CPMPresetMultipleRegistersFunction new.
]

{ #category : #functions }
CPMModbusFactory >> presetSingleRegister [
	^ currentFunction :=   CPMPresetSingleRegistersFunction  new.
]

{ #category : #functions }
CPMModbusFactory >> readCoilStatus [
	^ currentFunction :=   CPMReadCoilStatusFunction  new.
]

{ #category : #functions }
CPMModbusFactory >> readExceptionStatus [
	^ currentFunction :=   CPMReadExceptionStatusFunction  new.
]

{ #category : #functions }
CPMModbusFactory >> readHoldingRegister [
	^ currentFunction :=   CPMReadHoldingRegistersFunction  new.
]

{ #category : #functions }
CPMModbusFactory >> readInputRegister [
	^ currentFunction :=  CPMReadInputRegistersFunction  new.
]

{ #category : #functions }
CPMModbusFactory >> readInputStatus [
	^ currentFunction :=   CPMReadInputStatusFunction  new.
]

{ #category : #functions }
CPMModbusFactory >> reportSlaveID [
	^ currentFunction :=   CPMReportSlaveIDFunction new.
]

{ #category : #'as yet unclassified' }
CPMModbusFactory >> timeout [
	^ timeout ifNil:[timeout := 2]
]

{ #category : #'as yet unclassified' }
CPMModbusFactory >> timeout: time [
	 timeout := time
]

{ #category : #'as yet unclassified' }
CPMModbusFactory >> unitID [

	^ unitID ifNil:[ 
			Smalltalk garbageCollect.
			unitID := self class allInstances size bitAnd:16r0F]
]

{ #category : #accessing }
CPMModbusFactory >> unitID: aOneByteID [

	unitID := aOneByteID
]

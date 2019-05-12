Class {
	#name : #CPMModbusFunction,
	#superclass : #Object,
	#instVars : [
		'slaveAddress',
		'function',
		'startingAddress',
		'numberOfRegisters',
		'data',
		'modbusStream'
	],
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'function-codes' }
CPMModbusFunction class >> forceMultipleCoilFunctionCode [
	^16r0F
]

{ #category : #'function-codes' }
CPMModbusFunction class >> forceSingleCoilFunctionCode [
	^16r05
]

{ #category : #'function-codes' }
CPMModbusFunction class >> maskWriteRegisterFunctionCode [
	^ 16r16
]

{ #category : #private }
CPMModbusFunction class >> newFromStream: aStream [
	| bc instance|
	instance := self new.
	instance startingAddressHigh: aStream next low: aStream next.
	instance numberOfElementsHigh:  aStream next low: aStream next.
	bc := aStream next.
	instance data: aStream upToEnd.
	^  instance
]

{ #category : #private }
CPMModbusFunction class >> newResponseFromStream: aStream [
	| bc instance|
	instance := self new.
	bc := aStream next.
	instance data: (aStream next:bc).
	^  instance
]

{ #category : #parsing }
CPMModbusFunction class >> parseFromStream:aStream [ 
	| i f instance|
	i := aStream next.
	f := aStream next.

	(f = self forceMultipleCoilFunctionCode  ) ifTrue:[ instance:= CPMForceMultipleCoilsFunction newFromStream:aStream  ].
	(f = self presetMultipleRegisterFunctionCode) ifTrue:[ instance:= CPMPresetMultipleRegistersFunction newFromStream:aStream ].
	(f = self readCoilFunctionCode   ) ifTrue:[ instance:= CPMReadCoilStatusFunction newFromStream:aStream  ].
	(f = self readExceptionStatusFunctionCode  ) ifTrue:[ instance:= CPMReadExceptionStatusFunction  new ].
	(f = self readHoldingRegisterFunctionCode  ) ifTrue:[ instance:= CPMReadHoldingRegistersFunction newFromStream:aStream  ].
	(f = self readInputRegisterFunctionCode  ) ifTrue:[ instance:= CPMReadInputRegistersFunction newFromStream:aStream  ].

	(f = self readInputStatusFunctionCode   ) ifTrue:[ instance:= CPMReadInputStatusFunction newFromStream:aStream  ].
	(f = self reportSlaveIDFunctionCode   ) ifTrue:[ instance := CPMReportSlaveIDFunction new ].
	(f = self forceSingleCoilFunctionCode  ) ifTrue:[ instance:= CPMForceSingleCoilFunction newFromStream:aStream ].
	(f = self presetSingleRegisterFunctionCode ) ifTrue:[ instance:= CPMPresetSingleRegistersFunction newFromStream:aStream  
].
	(f = self readWriteRegisterFunctionCode ) ifTrue:[ instance:= CPMReadWriteRegistersFunction  newFromStream:aStream  ].
	(f = self maskWriteRegisterFunctionCode ) ifTrue:[ instance:= CPMMaskWriteRegisterFunction newFromStream:aStream  ].


	instance ifNil:[ CPMIlegalFunctionException new 
									queryFunctionCode: (f ifNil:[0]);
									slaveAddress: i;
									data: aStream upToEnd; 
									signal]
			 ifNotNil:[instance slaveAddress: i ].
	^ instance 
	
	


	
	
]

{ #category : #'function-codes' }
CPMModbusFunction class >> presetMultipleRegisterFunctionCode [
	^16r10
]

{ #category : #'function-codes' }
CPMModbusFunction class >> presetSingleRegisterFunctionCode [
	^16r06
]

{ #category : #'function-codes' }
CPMModbusFunction class >> readCoilFunctionCode [

	^ 16r01
]

{ #category : #'function-codes' }
CPMModbusFunction class >> readExceptionStatusFunctionCode [

	^ 16r07
]

{ #category : #'function-codes' }
CPMModbusFunction class >> readHoldingRegisterFunctionCode [
	^16r03
]

{ #category : #'function-codes' }
CPMModbusFunction class >> readInputRegisterFunctionCode [
	^16r04
]

{ #category : #'function-codes' }
CPMModbusFunction class >> readInputStatusFunctionCode [
	
	^ 16r02
]

{ #category : #'function-codes' }
CPMModbusFunction class >> readWriteRegisterFunctionCode [
	^16r17
]

{ #category : #'function-codes' }
CPMModbusFunction class >> reportSlaveIDFunctionCode [
	^16r11
]

{ #category : #accessing }
CPMModbusFunction >> byteCount [
	^ data size > 255 ifTrue:[255] ifFalse:[data size]
]

{ #category : #accessing }
CPMModbusFunction >> data [
	^ data ifNil:[ data := WriteStream on: OrderedCollection new ]
]

{ #category : #accessing }
CPMModbusFunction >> data: anObject [
	data := anObject
]

{ #category : #'as yet unclassified' }
CPMModbusFunction >> executeFunctionOn: dataTable [
	self subclassResponsibility 
]

{ #category : #accessing }
CPMModbusFunction >> function [
	self subclassResponsibility 
]

{ #category : #'as yet unclassified' }
CPMModbusFunction >> function: aFunCode [
	"used to overwrite the code by Exception class"
	function := aFunCode
]

{ #category : #'as yet unclassified' }
CPMModbusFunction >> modbusStream [ 
	^ modbusStream ifNil:[ modbusStream := WriteStream on: OrderedCollection new]
]

{ #category : #accessing }
CPMModbusFunction >> numberOfCoils [
	^ self numberOfRegisters
]

{ #category : #accessing }
CPMModbusFunction >> numberOfCoils: twoBytes [
	"two bytes field"
	numberOfRegisters := twoBytes
]

{ #category : #accessing }
CPMModbusFunction >> numberOfElementsHigh: hByte low: lByte [
	"two bytes field"
	| sah sal  |
	sah := hByte << 8.
	sal := lByte.

	self numberOfRegisters: 	(sah bitOr: sal)
]

{ #category : #accessing }
CPMModbusFunction >> numberOfInputs: twoBytes [
	"two bytes field"
	self numberOfCoils: twoBytes
]

{ #category : #accessing }
CPMModbusFunction >> numberOfRegisters [
	"two bytes field"
	^( numberOfRegisters ifNil:[numberOfRegisters := 1]) 
]

{ #category : #accessing }
CPMModbusFunction >> numberOfRegisters: twoBytes [
	"two bytes field"
	numberOfRegisters := twoBytes
]

{ #category : #'as yet unclassified' }
CPMModbusFunction >> signalException:exCode [
	
	exCode = 1 ifTrue:[CPMIlegalFunctionException new 
												queryFunction: self;
												signal].
	exCode = 2 ifTrue:[CPMIlegalDataAddressException  new 
												queryFunction: self;
												signal].
	exCode = 3 ifTrue:[CPMIlegalDataValueException  new 
												queryFunction: self;
												signal].
	exCode = 4 ifTrue:[CPMSlaveDeviceFailureException  new 
												queryFunction: self;
												signal].		
	exCode = 5 ifTrue:[CPMAcknowledgeException  new 
												queryFunction: self;
												signal].	
	exCode = 6 ifTrue:[CPMSlaveDeviceBusyException  new 
												queryFunction: self;
												signal].
	exCode = 7 ifTrue:[CPMNegativeAcknowledgeException  new 
												queryFunction: self;
												signal].	
	exCode = 8 ifTrue:[CPMMemoryParityErrorException   new 
												queryFunction: self;
												signal].
											
]

{ #category : #accessing }
CPMModbusFunction >> slaveAddress [
	"one bytes address"
	^ slaveAddress ifNil:[slaveAddress := 1]
]

{ #category : #accessing }
CPMModbusFunction >> slaveAddress: oneByte [
	"one bytes address"
	slaveAddress := oneByte
]

{ #category : #accessing }
CPMModbusFunction >> startingAddress [
"two bytes field"	
	^ startingAddress ifNil:[ startingAddress:= 0]
]

{ #category : #accessing }
CPMModbusFunction >> startingAddress: twoBytes [
	"two bytes field"
	startingAddress := twoBytes
]

{ #category : #accessing }
CPMModbusFunction >> startingAddressHigh: hByte low: lByte [
	"two bytes field"
	| sah sal  |
	sah := hByte <<8.
	sal := lByte.

	self startingAddress: 	(sah bitOr: sal)
]

{ #category : #'as yet unclassified' }
CPMModbusFunction >> updateFromResponseStream: aStream [
	self subclassResponsibility 
	
]

Class {
	#name : #CPMModbusFrameTest,
	#superclass : #TestCase,
	#category : #'Control-Protocols-Modbus-Tests'
}

{ #category : #'as yet unclassified' }
CPMModbusFrameTest >> testForceSingleCoil [
	|modbusTable mf|
	
	modbusTable := CPMModbusDataTable new.
	mf := CPMReadCoilStatusFunction new. 



]

{ #category : #'as yet unclassified' }
CPMModbusFrameTest >> testReadCoilStatus [
	|modbusFrame mf memoryTable|
	
	memoryTable := CPMModbusDataTable new.


	modbusFrame := #( 16r11 16r01 16r00 16r00 16r00 16r25 16r01).
	mf := CPMModbusFunction parseFromStream: (ReadStream on:modbusFrame)	.

	self assert:(mf isKindOf: CPMReadCoilStatusFunction ).
	( 0 to: 4999 ) do:[:anAddress| memoryTable forceCoilAt: anAddress put: (anAddress % 2)] . 
	mf data: (memoryTable readCoilsStartingAt: mf startingAddress  numberOfPoints: mf numberOfCoils).
		
	self assert: ((mf data at:16r1) = 16rAA) 	

	
	

]

{ #category : #tests }
CPMModbusFrameTest >> testReadInputStatus [
	|modbusFrame mf memoryTable resp|
	
	memoryTable := CPMModbusDataTable new.

	"Read input status frame"
	modbusFrame := #( 16r11 16r02 16r00 16r00 16r00 16r25 16r01).
	mf := CPMModbusFunction parseFromStream: (ReadStream on:modbusFrame)	.

	self assert:(mf isKindOf: CPMReadInputStatusFunction ).
	( 0 to: 4999 ) do:[:anAddress| memoryTable setInputAt: anAddress put: (anAddress  % 2)] . 
	mf data: (memoryTable readInputsStartingAt: mf startingAddress  numberOfPoints: mf numberOfCoils).
			
	self assert: ((mf data at:16r1) = 16rAA). 	
	resp := CPMTCPFrameTransformer on: mf responseTelegram.

	
	
	

]

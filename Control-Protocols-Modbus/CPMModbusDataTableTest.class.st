Class {
	#name : #CPMModbusDataTableTest,
	#superclass : #TestCase,
	#category : #'Control-Protocols-Modbus-Tests'
}

{ #category : #tests }
CPMModbusDataTableTest >> testReadInput [
	|table|
	table:= CPMModbusDataTable new.
	table table at:10001 put: 16r01.
	self assert: ( (table readInputAt: 16r0 ) = 2r1).

]

{ #category : #'as yet unclassified' }
CPMModbusDataTableTest >> testWriteCoil [
	|table|
	table:= CPMModbusDataTable new.

	self assert: ( (table forceCoilAt: 16r0 put: 2r0) = (table readCoilAt:16r0) ).
	self assert: ( (table forceCoilAt: 16r3 put: 2r0) = (table readCoilAt:16r3) ).
	self assert: ( (table forceCoilAt: 16rFF put: 2r0) = (table readCoilAt:16rFF) )
]

{ #category : #tests }
CPMModbusDataTableTest >> testWriteCoilException [
	|table|
	table:= CPMModbusDataTable new.

	self shouldnt: [table forceCoilAt: ((9999 * 16) -1)  put: 2r0]
		  raise: CPMIlegalDataAddressException.
	self should: [table forceCoilAt: (9999 * 16)  put: 2r0]
		  raise: CPMIlegalDataAddressException.

]

{ #category : #'as yet unclassified' }
CPMModbusDataTableTest >> testWriteHoldingRegister [
	|table|
	table:= CPMModbusDataTable new.

	self assert: ( (table presetHoldingRegisterAt:  16r0 put: 16r0E) = (table readHoldingRegisterAt:16r0) ).

]

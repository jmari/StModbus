Class {
	#name : #CPMModbusReadFunction,
	#superclass : #CPMModbusFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMModbusReadFunction >> queryTelegram [
	| qf |
	qf:= ByteArray new:6.
	^qf
		at:1 put: self slaveAddress;
		at:2 put: self function;
		at:3 put: self startingAddress>>8;
		at:4 put: (self startingAddress bitAnd: 16rFF);
		at:5 put: self numberOfCoils>>8;
		at:6 put: (self numberOfCoils bitAnd: 16rFF);
		asByteArray
	
]

{ #category : #'as yet unclassified' }
CPMModbusReadFunction >> responseTelegram [
	| qf |
	qf:= ReadWriteStream on:OrderedCollection new.
	^(qf
		nextPut: self slaveAddress;
		nextPut: self function;
		nextPut: self byteCount;
		nextPutAll: self data;
		contents ) asByteArray

	
]

{ #category : #'as yet unclassified' }
CPMModbusReadFunction >> updateFromResponseStream: aStream [
	|bc fn sa exCode|

	sa := aStream next.
	fn := aStream next.
	(fn < 16r80)
		 ifTrue:[
			bc := aStream next.
			self data: (aStream next:bc)]
		ifFalse:[
			exCode:= fn bitAnd:16r0F.
			self signalException: exCode
		]		
]

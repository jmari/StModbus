Class {
	#name : #CPMModbusMultiplePresetFunction,
	#superclass : #CPMModbusFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMModbusMultiplePresetFunction >> queryTelegram [
	| qf |
	qf:= ReadWriteStream on:OrderedCollection new.
	^(qf
		nextPut: self slaveAddress;
		nextPut: self function;
		nextPut: self startingAddress >> 8;
		nextPut: (self startingAddress bitAnd: 16rFF);
		nextPut: self numberOfRegisters>>8; 
		nextPut: (self numberOfRegisters bitAnd: 16rFF);
		nextPut: self byteCount;
		nextPutAll: self data;
		contents)
		asByteArray


]

{ #category : #'as yet unclassified' }
CPMModbusMultiplePresetFunction >> responseTelegram [
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
CPMModbusMultiplePresetFunction >> updateFromResponseStream: aStream [
	|head sa fn  exCode|
	sa := aStream next.
	fn := aStream next.
	(fn < 16r80)
		 ifTrue:[
				head := aStream next:4.
				self data: (aStream upToEnd)]
		ifFalse:[
			exCode:= fn bitAnd:16r0F.
			self signalException: exCode
		]	

]

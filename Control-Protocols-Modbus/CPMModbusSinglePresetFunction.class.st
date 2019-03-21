Class {
	#name : #CPMModbusSinglePresetFunction,
	#superclass : #CPMModbusFunction,
	#category : #'Control-Protocols-Modbus-Functions'
}

{ #category : #'as yet unclassified' }
CPMModbusSinglePresetFunction class >> newFromStream: aStream [
	|  instance|
	instance := self new.
	instance startingAddressHigh: aStream next low: aStream next.
	instance data: aStream upToEnd.

	^  instance
]

{ #category : #'as yet unclassified' }
CPMModbusSinglePresetFunction >> queryTelegram [
	| qf |
	qf:= ReadWriteStream on:OrderedCollection new.
	^(qf
		nextPut: self slaveAddress;
		nextPut: self function;
		nextPut: self startingAddress >> 8;
		nextPut: (self startingAddress bitAnd: 16rFF);
		nextPutAll: self data;
		contents) asByteArray
]

{ #category : #'as yet unclassified' }
CPMModbusSinglePresetFunction >> responseTelegram [
	| qf |
	qf:= ReadWriteStream on:OrderedCollection new.

	^(qf
		nextPut: self slaveAddress;
		nextPut: self function;
		nextPut: self startingAddress >> 8;
		nextPut: (self startingAddress bitAnd: 16rFF);
		nextPutAll: self data;
		contents) asByteArray
]

{ #category : #'as yet unclassified' }
CPMModbusSinglePresetFunction >> updateFromResponseStream: aStream [
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

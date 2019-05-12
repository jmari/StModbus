Extension { #name : #CRC }

{ #category : #'*Control-Protocols-Modbus' }
CRC class >> crc16FromModbusFrame: aCollection [
	| instance |
	instance := 
		self new
			width: 16;
			lookupTable: self crc16Table;
			polynome: 16r8005;
			registerFill: 16rFFFF;
			reflectInput: true;
			reflectOutput: true;
			finallyXorWith: 16r0;
			message: aCollection;
			yourself.
			
	^ instance runRefInRefOut
]

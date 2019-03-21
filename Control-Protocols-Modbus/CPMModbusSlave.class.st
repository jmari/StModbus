Class {
	#name : #CPMModbusSlave,
	#superclass : #CPMModbusFactory,
	#category : #'Control-Protocols-Modbus-Main'
}

{ #category : #'as yet unclassified' }
CPMModbusSlave class >> quotedNew [
	|i|
	(self allInstances size <= 16rFF)
		ifTrue:[
			i := self new]
		ifFalse:[ CPMTooManySlaves signal].
	^ i
			
	
]

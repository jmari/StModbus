Class {
	#name : #CPMModbusMaster,
	#superclass : #CPMModbusFactory,
	#category : #'Control-Protocols-Modbus-Main'
}

{ #category : #'as yet unclassified' }
CPMModbusMaster >> connectionEstablished [
	^ self
]

{ #category : #'as yet unclassified' }
CPMModbusMaster >> connectionRefused [
	^ self
]

{ #category : #'connection open/close' }
CPMModbusMaster >> disconnect [ 	
	self subclassResponsibility 
]

{ #category : #sending }
CPMModbusMaster >> send [
	self subclassResponsibility 
]

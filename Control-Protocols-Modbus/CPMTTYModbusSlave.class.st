Class {
	#name : #CPMTTYModbusSlave,
	#superclass : #CPMModbusSlave,
	#instVars : [
		'socket',
		'connectionPool',
		'stop',
		'serverProcess',
		'port',
		'rtuMode',
		'serialPort'
	],
	#category : #'Control-Protocols-Modbus-Main'
}

{ #category : #defaults }
CPMTTYModbusSlave class >> defaultPort [
	^ '/dev/ttys001'
]

{ #category : #'as yet unclassified' }
CPMTTYModbusSlave class >> on: aPort [
	^ self quotedNew port:aPort
			
	
]

{ #category : #'as yet unclassified' }
CPMTTYModbusSlave class >> start [
	^ (self startOn: self defaultPort) 
]

{ #category : #'as yet unclassified' }
CPMTTYModbusSlave class >> startOn: aPort [
	^ ( self on:aPort) start
]

{ #category : #'as yet unclassified' }
CPMTTYModbusSlave >> ASCIIMode [
	rtuMode := false
]

{ #category : #'as yet unclassified' }
CPMTTYModbusSlave >> RTUMode [
	rtuMode := true
]

{ #category : #'connection open/close' }
CPMTTYModbusSlave >> disconnect [
	self serialPort close
	
	
]

{ #category : #initialization }
CPMTTYModbusSlave >> initialize [
	super initialize.
	rtuMode := true.
	stop := false.

	
]

{ #category : #'as yet unclassified' }
CPMTTYModbusSlave >> isRunning [ 
	^ stop 
		ifNil:[
			stop:=true.
			stop not] 
		ifNotNil:[ stop not].
]

{ #category : #'as yet unclassified' }
CPMTTYModbusSlave >> port [
	^ port ifNil:[port := self class defaultPort]
]

{ #category : #'as yet unclassified' }
CPMTTYModbusSlave >> port: aPort [
	port := aPort
]

{ #category : #'connection open/close' }
CPMTTYModbusSlave >> reconnect [
	self serialPort connectTo: port
	
	
]

{ #category : #accessing }
CPMTTYModbusSlave >> serialPort [
 	^ serialPort ifNil:[ serialPort := (SerialPort new )].
]

{ #category : #'as yet unclassified' }
CPMTTYModbusSlave >> serve [
	| modbusFunction response  transportFrame |
	
	[
	|d  bytesRead |
	d := Delay forMilliseconds: 100.
	self serialPort  openPort: port.
	[ stop ] whileFalse:[	
		bytesRead :=  self serialPort readByteArray.
		bytesRead  isEmpty
		ifTrue:[d wait.Processor yield]
		ifFalse: [
			[	transportFrame := rtuMode
											ifTrue:[	(CPMTTYRTUFrameTransformer  
												parseFromStream: (ReadStream  on: bytesRead ) binary)]
											ifFalse:[(CPMTTYASCIIFrameTransformer  
												parseFromStream: (ReadStream  on: bytesRead ) ascii)].									
				modbusFunction := transportFrame modbusFunction.
				modbusFunction slaveAddress = self unitID 
				ifTrue:[
					modbusFunction executeFunctionOn:self dataTable.		
					response := rtuMode
											ifTrue:[	(CPMTTYRTUFrameTransformer  on:  modbusFunction responseTelegram)
															unitID: transportFrame unitID]
											ifFalse:[(CPMTTYASCIIFrameTransformer  on:  modbusFunction responseTelegram)
															unitID: transportFrame unitID].
				]]
		on:CPMException 
		do:[:e| 
			response := ((CPMTCPFrameTransformer on:  e responseTelegram)
								transactionID: (((bytesRead at: 1) <<8) bitOr: (bytesRead at:2))).
			"change status register?"].	
		self serialPort  nextPutAll:response telegram].
		]
	] 
	ensure:[self disconnect].	 
]

{ #category : #accessing }
CPMTTYModbusSlave >> start [
	stop := false.
	[self serve] forkNamed: 'Serial Modbus Slave #', self unitID asString
]

{ #category : #'as yet unclassified' }
CPMTTYModbusSlave >> stop [
	stop := true.
	self disconnect.
	serverProcess 	ifNotNil:[ serverProcess terminate]. 
	serverProcess := nil
]

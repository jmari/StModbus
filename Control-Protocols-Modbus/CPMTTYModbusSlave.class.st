Class {
	#name : #CPMTTYModbusSlave,
	#superclass : #CPMTTYModbusFactory,
	#instVars : [
		'socket',
		'connectionPool',
		'stop',
		'serverProcess'
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

{ #category : #'connection open/close' }
CPMTTYModbusSlave >> disconnect [
	self serialPort close
	
	
]

{ #category : #accessing }
CPMTTYModbusSlave >> isRunning [ 
	^ stop 
		ifNil:[
			stop:=true.
			stop not] 
		ifNotNil:[ stop not].
]

{ #category : #lifecycle }
CPMTTYModbusSlave >> serve [
	| modbusFunction response  transportFrame |
	[
	|d  bytesRead |
	d := Delay forMilliseconds:  (self waitingTimeFor: 1.5).
	self connectTo: port.
	[ stop ] whileFalse:[	
		bytesRead :=  self readByteArray.
		bytesRead isEmpty
		ifFalse: [
			[	transportFrame := self isRTUMode
											ifTrue:[	(CPMTTYRTUFrameTransformer  
												parseFromStream: (ReadStream  on: bytesRead ) binary)]
											ifFalse:[(CPMTTYASCIIFrameTransformer  
												parseFromStream: (ReadStream  on: bytesRead ) ascii)].									
				modbusFunction := transportFrame modbusFunction.
				modbusFunction slaveAddress = self unitID 
				ifTrue:[
					modbusFunction executeFunctionOn:self dataTable.		
					response := self isRTUMode
											ifTrue:[	(CPMTTYRTUFrameTransformer  on:  modbusFunction responseTelegram)
															unitID: transportFrame unitID]
											ifFalse:[(CPMTTYASCIIFrameTransformer  on:  modbusFunction responseTelegram)
															unitID: transportFrame unitID].
				]]
		on: Exception
		do:[:e| 
			response:= (e isKindOf: CPMException) 
				ifTrue:[((CPMTCPFrameTransformer on:  (e 
																	slaveAddress: self unitID ;
																	responseTelegram))
								transactionID: (((bytesRead at: 1) <<8) bitOr: (bytesRead at:2))).
			"change status register?"]
				ifFalse:[
					Transcript show: e asString.nil]].	
		response ifNotNil:[
					self serialPort  nextPutAll:response telegram.
					]]
		]
	] 
	ensure:[self disconnect].	 
]

{ #category : #lifecycle }
CPMTTYModbusSlave >> start [
	stop := false.
	[self serve] forkNamed: 'Serial Modbus Slave #', self unitID asString
]

{ #category : #lifecycle }
CPMTTYModbusSlave >> stop [
	stop := true.
	self disconnect.
	serverProcess 	ifNotNil:[ serverProcess terminate]. 
	serverProcess := nil
]

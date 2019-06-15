Class {
	#name : #CPMTCPModbusSlave,
	#superclass : #CPMTCPModbusFactory,
	#instVars : [
		'socket',
		'connectionPool',
		'stop',
		'serverProcess',
		'port'
	],
	#category : #'Control-Protocols-Modbus-Main'
}

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave class >> on: aPort [
	^ self quotedNew port:aPort
			
	
]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave class >> quotedNew [
	|i|
	(self allInstances size <= 16rFF)
		ifTrue:[
			i := self new]
		ifFalse:[ CPMTooManySlaves signal].
	^ i
			
	
]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave class >> start [
	^ (self startOn: self defaultPort) 
]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave class >> startOn: aPort [
	^ ( self on:aPort) start
]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave >> disconnect [
	socket ifNotNil:[socket closeAndDestroy ].
	socket := nil
	
]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave >> initialize [
	super initialize.
	stop := false.

	
]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave >> isRunning [ 
	^ stop 
		ifNil:[
			stop:=true.
			stop not] 
		ifNotNil:[ stop not].
]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave >> listen [
	| connectionSocket interactionSocket |
	connectionSocket := self socket listenOn: self port  backlogSize: 10 interface: #[0 0 0 0]. 
	serverProcess :=
		[	[[ stop ] whileFalse:[		
				interactionSocket := connectionSocket waitForAcceptFor: 1 ifTimedOut:[nil] .
				interactionSocket ifNotNil:[self serve: interactionSocket]]]  
			ensure:[ self disconnect ] 
		] forkNamed: 'TCP Modbus Slave#' , self  unitID asString	
	

]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave >> port [
	^ port ifNil:[port := self class defaultPort]
]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave >> port: aPort [
	port := aPort
]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave >> serve:interactionSocket [
	| modbusFunction response data frameWrapper |
	
	[
	[ stop ] whileFalse:[	
		interactionSocket waitForDataIfClosed:[^self].
		data := interactionSocket  receiveData asByteArray.
		[	frameWrapper := (CPMTCPFrameWrapper  
							parseFromStream: (ReadStream  on: data ) binary).
							
			modbusFunction := frameWrapper modbusFunction.
			
			(modbusFunction slaveAddress = self unitID )
				ifTrue:[
					modbusFunction executeFunctionOn:self dataTable.	
					"TO-DO. Why do I have to create a new Frame Wrapper insted of using the same"
					response := ((CPMTCPFrameWrapper on:  modbusFunction responseTelegram)
								transactionID: frameWrapper transactionID; 
								protocolID: frameWrapper protocolID; 
								unitID: frameWrapper unitID)]]
		on:CPMException 
		do:[:e| 
			response := ((CPMTCPFrameWrapper on:  e responseTelegram)
								transactionID: (((data at: 1) <<8) bitOr: (data at:2))).
			"change status register?"].	
			interactionSocket sendData: response telegram]
	] 
	ensure:[interactionSocket closeAndDestroy].	
	
	 
]

{ #category : #accessing }
CPMTCPModbusSlave >> socket [
	^    socket := Socket newTCP 
]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave >> start [
	stop := false.
	self listen
]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave >> stop [
	stop := true.
	self disconnect.
	serverProcess 	ifNotNil:[ serverProcess terminate]. 
	serverProcess := nil
]

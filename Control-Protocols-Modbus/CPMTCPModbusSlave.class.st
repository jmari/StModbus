Class {
	#name : #CPMTCPModbusSlave,
	#superclass : #CPMModbusSlave,
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
CPMTCPModbusSlave class >> defaultPort [
	^ 1502
]

{ #category : #'as yet unclassified' }
CPMTCPModbusSlave class >> on: aPort [
	^ self quotedNew port:aPort
			
	
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
	| modbusFunction response data transportFrame |
	
	[
	[ stop ] whileFalse:[	
		interactionSocket waitForDataIfClosed:[^self].
		data := interactionSocket  receiveData asByteArray.
		[	transportFrame := (CPMTCPFrameTransformer  
							parseFromStream: (ReadStream  on: data ) binary).
							
			modbusFunction := transportFrame modbusFunction.

			(modbusFunction slaveAddress = self unitID )
				ifTrue:[
					modbusFunction executeFunctionOn:self dataTable.	
					response := ((CPMTCPFrameTransformer on:  modbusFunction responseTelegram)
								transactionID: transportFrame transactionID; 
								protocolID: transportFrame protocolID; 
								unitID: transportFrame unitID)]]
		on:CPMException 
		do:[:e| 
			response := ((CPMTCPFrameTransformer on:  e responseTelegram)
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

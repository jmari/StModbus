Class {
	#name : #CPMTCPModbusMaster,
	#superclass : #CPMModbusMaster,
	#instVars : [
		'connection',
		'socket',
		'mutex',
		'address',
		'port',
		'attempts',
		'connectionPool',
		'transactionID'
	],
	#category : #'Control-Protocols-Modbus-Main'
}

{ #category : #'as yet unclassified' }
CPMTCPModbusMaster class >> connectTo: anAddress [
	^ self new connectTo:anAddress port:self defaultPort
]

{ #category : #'as yet unclassified' }
CPMTCPModbusMaster class >> connectTo: anAddress port:aPort [
	^ self new connectTo:anAddress port:aPort
]

{ #category : #defaults }
CPMTCPModbusMaster class >> defaultPort [
	^ 1502
]

{ #category : #'as yet unclassified' }
CPMTCPModbusMaster >> attempts [
	^ attempts ifNil:[ attempts := 0] ifNotNil:[ attempts := attempts + 1 ]
]

{ #category : #'initialize-release' }
CPMTCPModbusMaster >> connectTo:anAddress port:aPort [
	address := anAddress.
	port := aPort.
	
	self reconnect
		
]

{ #category : #'as yet unclassified' }
CPMTCPModbusMaster >> disconnect [
	self socket closeAndDestroy.
	socket := nil
	
]

{ #category : #'as yet unclassified' }
CPMTCPModbusMaster >> dispose [
	connectionPool := nil.
	socket := nil.
	attempts:=0
]

{ #category : #accessing }
CPMTCPModbusMaster >> mutex [
	^ mutex ifNil:[mutex := Mutex new]
]

{ #category : #'connection open/close' }
CPMTCPModbusMaster >> reconnect [
	self socket isConnected ifFalse:[
		self socket 
			connectTo: address port:port;
			waitForConnectionFor: self timeout.
	
		self socket isConnected 
			ifTrue:[self connectionEstablished]
			ifFalse: [ self connectionRefused ]]
		
]

{ #category : #'old api' }
CPMTCPModbusMaster >> send [
	| data stream|

	^self socket isConnected 
		ifTrue:[
			self mutex critical:[
				stream := SocketStream on: self socket. 
				stream binary.
				stream nextPutAllFlush:((CPMTCPFrameTransformer on: currentFunction queryTelegram ) 
												transactionID: self transactionID; 
												unitID: currentFunction slaveAddress; 
												telegram).
				stream isDataAvailable  ifFalse:[(Delay forMilliseconds: 100) wait].
				(stream isDataAvailable ) ifTrue:[
					data := stream next:6.
					data := stream next: ((data at:5) << 8 bitOr:(data at:6)).
					self disconnect.
					currentFunction updateFromResponseStream: (ReadStream on: data).
					attempts := 0. 
					currentFunction]
				]] 
		ifFalse:[
			self reconnect.
			(self attempts < 10) 
				ifTrue:[ self send]
				ifFalse:[
					attempts := 0.
					self connectionRefused ] ].
	
 
]

{ #category : #accessing }
CPMTCPModbusMaster >> socket [
	^    socket ifNil:[
			"connectionpool is Empty" socket := Socket newTCP ]
]

{ #category : #'as yet unclassified' }
CPMTCPModbusMaster >> transactionID [
	^ transactionID ifNil:[transactionID := 1] ifNotNil:[transactionID := transactionID  + 1 ] 
]
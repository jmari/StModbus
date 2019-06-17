Class {
	#name : #CPMTTYModbusMaster,
	#superclass : #CPMTTYModbusFactory,
	#instVars : [
		'mutex'
	],
	#category : #'Control-Protocols-Modbus-Main'
}

{ #category : #'as yet unclassified' }
CPMTTYModbusMaster class >> connectTo: aSerialPort [
	^ self new connectTo:aSerialPort
]

{ #category : #'connection open/close' }
CPMTTYModbusMaster >> disconnect [
	self serialPort close
	
]

{ #category : #'connection open/close' }
CPMTTYModbusMaster >> reconnect [
	[self connectTo: self port.
	self connectionEstablished] 
	on:Error
	do: [self connectionRefused ]
		
]

{ #category : #sending }
CPMTTYModbusMaster >> send [
	| response bA d |
	"send query"
	d := Delay forMilliseconds:  (self waitingTimeFor: 3.5).
	self serialPort nextPutAll:
		(self isRTUMode 
			ifTrue:[
				(CPMTTYRTUFrameWrapper on: currentFunction queryTelegram ) 
												unitID: currentFunction slaveAddress; 
												telegram]
			ifFalse:[
				(CPMTTYASCIIFrameWrapper on: currentFunction queryTelegram ) 
												unitID: currentFunction slaveAddress; 
												telegram]).
	"read response"		
	d wait.
	(bA:= self readByteArray) isEmpty 
		ifFalse:[	
			response := self isRTUMode 
					ifTrue:[
						CPMTTYRTUFrameWrapper 
								parseFromStream: (ReadStream on:bA) binary]
					ifFalse:[
						CPMTTYASCIIFrameWrapper 
								parseFromStream: (ReadStream on:bA) ascii].
			^ currentFunction updateFromResponseStream: (ReadStream on: response modbusFunction responseTelegram)].
		^ nil 
]

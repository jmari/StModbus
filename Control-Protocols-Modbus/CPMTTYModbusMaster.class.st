Class {
	#name : #CPMTTYModbusMaster,
	#superclass : #CPMModbusMaster,
	#instVars : [
		'mutex',
		'port',
		'serialPort',
		'rtuMode'
	],
	#category : #'Control-Protocols-Modbus-Main'
}

{ #category : #'as yet unclassified' }
CPMTTYModbusMaster class >> connectTo: aSerialPort [
	^ self new connectTo:aSerialPort
]

{ #category : #'as yet unclassified' }
CPMTTYModbusMaster >> ASCIIMode [
	rtuMode := false
]

{ #category : #'as yet unclassified' }
CPMTTYModbusMaster >> RTUMode [
	rtuMode := true
]

{ #category : #'connection open/close' }
CPMTTYModbusMaster >> connectTo:aPort [
	port := aPort.
	self serialPort openPort: aPort
		
]

{ #category : #'as yet unclassified' }
CPMTTYModbusMaster >> disconnect [
	self serialPort close
	
]

{ #category : #initialization }
CPMTTYModbusMaster >> initialize [
	super initialize.
	rtuMode := true
]

{ #category : #'connection open/close' }
CPMTTYModbusMaster >> reconnect [
	self serialPort openPort: port
		
]

{ #category : #'old api' }
CPMTTYModbusMaster >> send [
	| response bA |

	self serialPort nextPutAll:
		(rtuMode 
			ifTrue:[
				(CPMTTYRTUFrameTransformer on: currentFunction queryTelegram ) 
												unitID: currentFunction slaveAddress; 
												telegram]
			ifFalse:[
				(CPMTTYASCIIFrameTransformer on: currentFunction queryTelegram ) 
												unitID: currentFunction slaveAddress; 
												telegram]).
										
	[(bA:= self serialPort readByteArray copy) isEmpty ] 
		whileTrue:[	(Delay forMilliseconds: 100) wait.
						Processor yield].
	response := rtuMode 
					ifTrue:[
						CPMTTYRTUFrameTransformer 
								parseFromStream: (ReadStream on:bA)]
					ifFalse:[
						CPMTTYASCIIFrameTransformer 
								parseFromStream: (ReadStream on:bA)].

	^ currentFunction updateFromResponseStream: (ReadStream on: response modbusFunction responseTelegram).
		
	

]

{ #category : #'as yet unclassified' }
CPMTTYModbusMaster >> serialPort [
 	^ serialPort ifNil:[ serialPort := SerialPort new].
]

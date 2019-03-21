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
	[self serialPort openPort: aPort] 
	on:Error do:[serialPort := aPort asFileReference writeStream]
		
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
	| response |

	self serialPort nextPutAll:
		(rtuMode 
			ifTrue:[
				(CPMTTYRTUFrameTransformer on: currentFunction queryTelegram ) 
												telegram]
			ifFalse:[
				((CPMTTYASCIIFrameTransformer on: currentFunction queryTelegram ) 
												telegram)]).
			
	response := rtuMode 
					ifTrue:[
						CPMTTYRTUFrameTransformer 
								parseFromStream: (ReadStream on:(self serialPort readByteArray ))]
					ifFalse:[
						CPMTTYASCIIFrameTransformer 
								parseFromStream: (ReadStream on:(self serialPort readByteArray ))].
	
	currentFunction updateFromResponseStream: (ReadStream on: response modbusTelegram).
		
	

]

{ #category : #'as yet unclassified' }
CPMTTYModbusMaster >> serialPort [
 	^ serialPort ifNil:[ serialPort := SerialPort new].
]

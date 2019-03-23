Class {
	#name : #CPMTTYModbusTest,
	#superclass : #TestCase,
	#instVars : [
		'tcpMaster',
		'tcpSlave'
	],
	#category : #'Control-Protocols-Modbus-Tests'
}

{ #category : #'as yet unclassified' }
CPMTTYModbusTest class >> test [
	self subclassResponsibility
]

{ #category : #initialization }
CPMTTYModbusTest >> setUp [
	tcpSlave := CPMTTYModbusSlave new.
	tcpSlave unitID: 1;
				port:'COM4'.
	tcpSlave serialPort     
        baudRate: 9600;
        dataBits: 8;
        stopBitsType: 1;
        parityType: 0.
	tcpSlave start.
	
	tcpMaster:= CPMTTYModbusMaster new.
	
	tcpMaster serialPort     
        baudRate: 9600;
        dataBits: 8;
        stopBitsType: 1;
        parityType: 0.
	tcpMaster connectTo: 'COM3'.

]

{ #category : #accessing }
CPMTTYModbusTest >> tcpMaster [

	^	 tcpMaster
]

{ #category : #'as yet unclassified' }
CPMTTYModbusTest >> tcpSlave [
	"starts a Modbus Slave (server) on default non privileged port"
	^ tcpSlave 
	
]

{ #category : #initialization }
CPMTTYModbusTest >> tearDown [

	tcpMaster disconnect.
	tcpMaster := nil.
	tcpSlave stop.
	tcpSlave := nil
]

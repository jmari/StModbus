Class {
	#name : #CPMTCPModbusTest,
	#superclass : #TestCase,
	#instVars : [
		'tcpMaster',
		'tcpSlave'
	],
	#category : #'Control-Protocols-Modbus-Tests'
}

{ #category : #'as yet unclassified' }
CPMTCPModbusTest class >> test [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
CPMTCPModbusTest >> remoteMaster [

	^	 CPMTCPModbusMaster connectTo:#[192 168 1 21] port:502.
]

{ #category : #initialization }
CPMTCPModbusTest >> setUp [
	tcpSlave := CPMTCPModbusSlave start.
	tcpSlave unitID: 1.
	"(Delay forMilliseconds: 2000) wait."
	tcpMaster:= CPMTCPModbusMaster connectTo: (NetNameResolver addressForName: 'localhost') port: CPMTCPModbusSlave defaultPort.

]

{ #category : #accessing }
CPMTCPModbusTest >> tcpMaster [

	^	 tcpMaster
]

{ #category : #'as yet unclassified' }
CPMTCPModbusTest >> tcpSlave [
	"starts a Modbus Slave (server) on default non privileged port"
	^ tcpSlave 
	
]

{ #category : #initialization }
CPMTCPModbusTest >> tearDown [
	tcpMaster disconnect.
	tcpMaster := nil.
	tcpSlave stop.

]

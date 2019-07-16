"
A CPMTCPModbusSlaveTest is a test class for testing the behavior of CPMTCPModbusSlave
"
Class {
	#name : #CPMTCPModbusMasterSlaveTest,
	#superclass : #CPMTCPModbusTest,
	#category : #'Control-Protocols-Modbus-Tests'
}

{ #category : #'as yet unclassified' }
CPMTCPModbusMasterSlaveTest class >> test [
	self new testPresetSingleHoldingRegister 
]

{ #category : #tests }
CPMTCPModbusMasterSlaveTest >> testForceMultipleCoils [
	| memoryTable checkSum response |
	
	memoryTable := CPMModbusDataTable new.
	0 to: 1024  do:[:anAddress| memoryTable setInputAt: anAddress put: anAddress  % 2 ] . 	
	
	self tcpMaster forceMultipleCoils 
		slaveAddress:16r1;
		startingAddress:16r1;
		data: (memoryTable readInputsStartingAt: 16r1 numberOfPoints:  1024);
		numberOfCoils:1024.
	response := self tcpMaster send.
	checkSum := 	self tcpSlave dataTable table inject: 0 into:[:chs :aRow| chs + aRow].
	self assert: checkSum equals: 2r1010101010101010 * 1024 / 16
					
]

{ #category : #tests }
CPMTCPModbusMasterSlaveTest >> testForceSingleCoil [
	| response checkSum |

	self tcpMaster forceSingleCoil 
		slaveAddress:16r1;
		startingAddress:16r1;
		data: #(16rFF 16r01). "we only force one bit 2"
	response := self tcpMaster send.
	self tcpMaster forceSingleCoil 
		slaveAddress:16r1;
		startingAddress:16r0;
		data: #(16r01).        "we only force one bit 1"
	response := self tcpMaster send.					
	checkSum := 	self tcpSlave dataTable table inject: 0 into:[:chs :aRow| chs + aRow].
	self assert: checkSum equals: 3
					
]

{ #category : #tests }
CPMTCPModbusMasterSlaveTest >> testIgnoreUnitID [
	| response checkSum |
	
	self tcpMaster  presetMultipleRegisters 
		slaveAddress:16r2;"different unitid, slave is 1"
		startingAddress:16r0;
		numberOfRegisters:10;
		data: #[0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10]. "array of Bytes"
	response := self tcpMaster send.	
								
	checkSum := 	self tcpSlave dataTable table inject: 0 into:[:chs :aRow| chs + aRow].
	self assert: checkSum equals: (10 + 9 + 8 + 7 + 6 + 5 + 4 + 3 + 2 + 1).
	
	
	"Now with checkUnitId"
	self tcpSlave verifyUnitId. 
	self tcpSlave dataTable reset.
	self tcpMaster  presetMultipleRegisters 
		slaveAddress:16r2;"different unitid, slave is 1"
		startingAddress:16r0;
		numberOfRegisters:10;
		data: #[0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10]. "array of Bytes"
	response := self tcpMaster send.	
								
	checkSum := 	self tcpSlave dataTable table inject: 0 into:[:chs :aRow| chs + aRow].
	self deny: checkSum equals: (10 + 9 + 8 + 7 + 6 + 5 + 4 + 3 + 2 + 1).	
	self assert: checkSum equals:0				
]

{ #category : #tests }
CPMTCPModbusMasterSlaveTest >> testPresetMultipleHoldingRegisters [
	| response checkSum |
	
	self tcpMaster  presetMultipleRegisters 
		slaveAddress:16r1;
		startingAddress:16r0;
		numberOfRegisters:10;
		data: #[0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10]. "array of Bytes"
	response := self tcpMaster send.	
								
	checkSum := 	self tcpSlave dataTable table inject: 0 into:[:chs :aRow| chs + aRow].
	self assert: checkSum equals: (10 + 9 + 8 + 7 + 6 + 5 + 4 + 3 + 2 + 1)
					
]

{ #category : #tests }
CPMTCPModbusMasterSlaveTest >> testPresetSingleHoldingRegister [
	| response checkSum |
	
	self tcpMaster presetSingleRegister 
		slaveAddress:16r1;
		startingAddress:16r01;
		data: #[1 0].
	response := self tcpMaster send.
			
								
	checkSum := 	self tcpSlave dataTable table inject: 0 into:[:chs :aRow| chs + aRow].
	self assert: checkSum equals: 256
					
]

{ #category : #tests }
CPMTCPModbusMasterSlaveTest >> testReadCoilStatus [
	| response memoryTable checkSum |

	memoryTable := CPMModbusDataTable new.
	( 0 to: 1024 ) do:[:anAddress| memoryTable setInputAt: anAddress put: anAddress  % 2 ] . 	
	
	self tcpMaster forceMultipleCoils 
											slaveAddress:16r1;
											startingAddress:16r0;
											data: (memoryTable readInputsStartingAt: 16r0 numberOfPoints:  1024);
											numberOfCoils:1024.
	self tcpMaster send.
	
	self tcpMaster readCoilStatus
											slaveAddress:16r1;
											startingAddress:16r0;
											numberOfCoils:1024.
	response := self tcpMaster send.

	"response data is a Byte Array"
	checkSum :=  response data inject: 0 into:[:chs :aRow| chs + aRow].		
	self assert: checkSum equals: 2r10101010 * 1024 / 8
	
]

{ #category : #tests }
CPMTCPModbusMasterSlaveTest >> testReadHoldingRegisters [
	| response checkSum |
	
	
	self tcpMaster  presetMultipleRegisters 
										slaveAddress:16r1;
										startingAddress:16r0;
										numberOfRegisters:10;
										data: #[0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10]. "array of Bytes"
	response := self tcpMaster send.		
	
	self tcpMaster readHoldingRegisters  
										slaveAddress:16r1;
										startingAddress:16r08.
	response := self tcpMaster send.

	checkSum := 	response data inject: 0 into:[:chs :aRow| chs + aRow].
	self assert: checkSum equals: 9
					
]

{ #category : #tests }
CPMTCPModbusMasterSlaveTest >> testReadInputStatus [
	| response checkSum |
	
	( 0 to: 1024 ) do:[:anAddress| 
		self tcpSlave dataTable setInputAt: anAddress put: anAddress  % 2 ]. 

	self tcpMaster readInputStatus 
							slaveAddress:16r1;
							startingAddress:16r0;
							numberOfInputs:1024.
							
	response := self tcpMaster send.	
	"response data is a Byte Array"
	checkSum :=  response data inject: 0 into:[:chs :aRow| chs + aRow].		
	self assert: checkSum equals: 2r10101010 * 1024 / 8
					
]

{ #category : #'test-only-remote' }
CPMTCPModbusMasterSlaveTest >> testRemotePresetAndReadHoldingRegister [
	"You shoud start a remote Modbus slave (server) put the IP adsress in #master superclass method"
	| response rm |

	rm :=self remoteMaster. 
	rm presetSingleRegister 
		slaveAddress:16r1;
		startingAddress:16r00;
		data: #[0 2].
	rm send.
	
	rm readHoldingRegisters 
		slaveAddress:16r1;
		startingAddress:16r00.
		
	response := rm send.
	self assert: (response data at:1 ) equals: 0.
	self assert: (response data at:2 ) equals: 2


]

{ #category : #'test-only-remote' }
CPMTCPModbusMasterSlaveTest >> testRemotePresetMultipleHoldingRegisters [
	| response |
	
	tcpMaster := self remoteMaster.
	tcpMaster  presetMultipleRegisters 
		slaveAddress:16r1;
		startingAddress:16r0;
		numberOfRegisters:10;
		data: #[0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10]. "array of Bytes"
	response := tcpMaster send.	
	response inspect.
	
]

{ #category : #'test-only-remote' }
CPMTCPModbusMasterSlaveTest >> testRemoteSetAndReadCoil [

	| response memoryTable checkSum |

	memoryTable := CPMModbusDataTable new.
	( 0 to: 1024 ) do:[:anAddress| memoryTable setInputAt: anAddress put: anAddress  % 2 ] . 	
	
	self remoteMaster forceMultipleCoils 
											slaveAddress:16r1;
											startingAddress:16r0;
											data: (memoryTable readInputsStartingAt: 16r0 numberOfPoints:  1024);
											numberOfCoils:1024.
	self remoteMaster send.
	
	self remoteMaster readCoilStatus
											slaveAddress:16r1;
											startingAddress:16r0;
											numberOfCoils:1024.
	response := self remoteMaster send.

	"response data is a Byte Array"
	checkSum :=  response data inject: 0 into:[:chs :aRow| chs + aRow].		
	self assert: checkSum equals: 2r10101010 * 1024 / 8
	

]

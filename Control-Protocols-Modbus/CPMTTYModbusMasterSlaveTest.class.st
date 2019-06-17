"
TTY still not working
"
Class {
	#name : #CPMTTYModbusMasterSlaveTest,
	#superclass : #CPMTTYModbusTest,
	#category : #'Control-Protocols-Modbus-Tests'
}

{ #category : #'as yet unclassified' }
CPMTTYModbusMasterSlaveTest class >> exampleOfInitializationMaster [
	| ttyMaster data |
   ttyMaster:= CPMTTYModbusMaster new.
	
	ttyMaster serialPort     
        baudRate: 9600;
        dataBits: 8;
        stopBitsType: 1;
        parityType: 0.
	ttyMaster connectTo: '/dev/tty.usbserial-AK072UFR'.


	ttyMaster presetSingleRegister 
		slaveAddress:16r1;
		startingAddress:16r00;
		data: #[0 2].
	ttyMaster send.
	
	ttyMaster readHoldingRegister 
		slaveAddress:16r1;
		startingAddress:16r00.
		
	data := ttyMaster send.
]

{ #category : #'as yet unclassified' }
CPMTTYModbusMasterSlaveTest class >> exampleOfInitializationSlave [

	| ttySlave |
	ttySlave := CPMTTYModbusSlave new.
	ttySlave unitID: 1;
				port:'/dev/tty.usbserial-AK072UEL'.
	ttySlave serialPort     
        baudRate: 9600;
        dataBits: 8;
        stopBitsType: 1;
        parityType: 0.
	ttySlave start.
	
	"STOP"
	ttySlave stop.
	ttySlave := nil.
	
]

{ #category : #'as yet unclassified' }
CPMTTYModbusMasterSlaveTest class >> test [
	self new testPresetSingleHoldingRegister 
]

{ #category : #tests }
CPMTTYModbusMasterSlaveTest >> testASCIIParse [
	|frameWrapper memoryTable f |
 	frameWrapper := CPMTTYASCIIFrameWrapper parseFromStream: (ReadStream on:#[58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10]).
	memoryTable := CPMModbusDataTable new.
	f := frameWrapper modbusFunction executeFunctionOn: memoryTable.
	self assert: (CPMTTYASCIIFrameWrapper on:f responseTelegram ) telegram  
		  equals: #[58 48 49 48 51 49 52 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 69 56 13 10]
]

{ #category : #tests }
CPMTTYModbusMasterSlaveTest >> testForceMultipleCoils [
	| response memoryTable checkSum |
	
	memoryTable := CPMModbusDataTable new.
	( 0 to: 1024 ) do:[:anAddress| memoryTable setInputAt: anAddress put: anAddress  % 2 ] . 	
	
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
CPMTTYModbusMasterSlaveTest >> testForceSingleCoil [
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
CPMTTYModbusMasterSlaveTest >> testLRC [

 self assert:(CPMTTYASCIIFrameWrapper new LRC: #[17 3 0 107 0 3]) equals: #[55 69] .
]

{ #category : #tests }
CPMTTYModbusMasterSlaveTest >> testPresetMultipleHoldingRegisters [
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
CPMTTYModbusMasterSlaveTest >> testPresetSingleHoldingRegister [
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
CPMTTYModbusMasterSlaveTest >> testReadCoilStatus [
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
CPMTTYModbusMasterSlaveTest >> testReadHoldingRegister [
	| response checkSum |
	
	
	self tcpMaster  presetMultipleRegisters 
										slaveAddress:16r1;
										startingAddress:16r0;
										numberOfRegisters:10;
										data: #[0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10]. "array of Bytes"
	response := self tcpMaster send.		
	
	self tcpMaster readHoldingRegister  
										slaveAddress:16r1;
										startingAddress:16r08.
	response := self tcpMaster send.

	checkSum := 	response data inject: 0 into:[:chs :aRow| chs + aRow].
	self assert: checkSum equals: 9
					
]

{ #category : #tests }
CPMTTYModbusMasterSlaveTest >> testReadInputStatus [
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

{ #category : #tests }
CPMTTYModbusMasterSlaveTest >> testRemotePresetAndReadHoldingRegister [
	"You shoud start a remote Modbus slave (server) put the IP adsress in #master superclass method"
	| response rm |

	rm :=self remoteMaster. 
	rm presetSingleRegister 
		slaveAddress:16r1;
		startingAddress:16r00;
		data: #[0 2].
	rm send.
	
	rm readHoldingRegister 
		slaveAddress:16r1;
		startingAddress:16r00.
		
	response := rm send.
	self assert: (response data at:1 ) equals: 0.
	self assert: (response data at:2 ) equals: 2


]

{ #category : #tests }
CPMTTYModbusMasterSlaveTest >> testRemotePresetMultipleHoldingRegisters [
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

{ #category : #tests }
CPMTTYModbusMasterSlaveTest >> testRemoteSetAndReadCoil [

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

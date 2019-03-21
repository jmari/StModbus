Class {
	#name : #CPMModbusDataTable,
	#superclass : #Object,
	#instVars : [
		'table',
		'slaveId',
		'exceptionStatus',
		'coilTableStart',
		'coilTableEnd',
		'inputTableStart',
		'inputTableEnd',
		'holdingRegisterTableStart',
		'holdingRegisterTableEnd',
		'inputRegisterTableStart',
		'inputRegisterTableEnd',
		'maxAddressSpace'
	],
	#category : #'Control-Protocols-Modbus-Data'
}

{ #category : #converting }
CPMModbusDataTable >> asString [
	^ self asStringFrom:0 to: self table size
]

{ #category : #converting }
CPMModbusDataTable >> asStringFrom: init to: end [
	| ws |
	ws := WriteStream on:String new.
	(self table copyFrom: init to: end)
	 doWithIndex:[:r :i|
		ws 
			nextPutAll: i asString;
			nextPut: Character tab.
		i asString size <4 ifTrue:[	ws	nextPut: Character tab].
		ws	 
			nextPut: $|;
			nextPut: Character space;  
			nextPutAll: ( r bitString copyFrom:46 to:61);
			nextPut: Character tab;  
			nextPut: $|;
			nextPut: Character space;  
			nextPutAll: r asString;
			nextPut: Character cr;
			nextPut: Character lf].
	^ ws contents
		
]

{ #category : #converting }
CPMModbusDataTable >> coilTableAsString [
	^ self asStringFrom: self coilTableStart to: self coilTableEnd
]

{ #category : #accessing }
CPMModbusDataTable >> coilTableEnd [
	^ coilTableEnd
]

{ #category : #accessing }
CPMModbusDataTable >> coilTableStart [
	^ coilTableStart
]

{ #category : #status }
CPMModbusDataTable >> exceptionStatus [
 ^ exceptionStatus ifNil:[ exceptionStatus := 0 asByte]
]

{ #category : #status }
CPMModbusDataTable >> exceptionStatus: aByte [
	exceptionStatus := aByte
]

{ #category : #coils }
CPMModbusDataTable >> forceCoilAt: bitPosition put:aBit [
	| bitAddress address bitPos |
	
	bitAddress := (bitPosition / 16r10 ) integerPart.
	(bitAddress >= 0  and:[ bitAddress <= maxAddressSpace ]) 
	ifTrue:[
		address := ((bitPosition) / 16r10) integerPart  + coilTableStart.
		bitPos := (bitPosition % 16r10) + 1.
		self table 
			at: address 
			put: ((self table at: address) bitAt:bitPos put:(aBit bitAt:1))]
	ifFalse:[CPMIlegalDataAddressException new
											address: bitPosition;
											signal].
	^ aBit
]

{ #category : #coils }
CPMModbusDataTable >> forceCoilsStartingAt: startingAddress data:data numberOfCoils: numberOfCoils [
	
	( 0 to:(numberOfCoils - 1)) 
		do:[:eachCoil| 
			self 
				forceCoilAt: (eachCoil + startingAddress) 
				put: ((data at: ((eachCoil  / 8) integerPart  + 1)) bitAt:( (eachCoil  % 8 )+ 1))].
		
]

{ #category : #converting }
CPMModbusDataTable >> holdingRegisterTableAsString [
	^ self asStringFrom: self holdingRegisterTableStart to: self holdingRegisterTableEnd
]

{ #category : #accessing }
CPMModbusDataTable >> holdingRegisterTableEnd [
	^ holdingRegisterTableEnd
]

{ #category : #accessing }
CPMModbusDataTable >> holdingRegisterTableStart [
	^ holdingRegisterTableStart
]

{ #category : #initalize }
CPMModbusDataTable >> initialize [
	super initialize.
	self separateMemorySpace 
]

{ #category : #converting }
CPMModbusDataTable >> inputRegisterTableAsString [
	^ self asStringFrom: self inputRegisterTableStart to: self inputRegisterTableEnd
]

{ #category : #accessing }
CPMModbusDataTable >> inputRegisterTableEnd [
	^ inputRegisterTableEnd
]

{ #category : #accessing }
CPMModbusDataTable >> inputRegisterTableStart [
	^ inputRegisterTableStart
]

{ #category : #converting }
CPMModbusDataTable >> inputTableAsString [
	^ self asStringFrom: self inputTableStart to: self inputTableEnd
]

{ #category : #accessing }
CPMModbusDataTable >> inputTableEnd [
	^ inputTableEnd
]

{ #category : #accessing }
CPMModbusDataTable >> inputTableStart [
	^ inputTableStart
]

{ #category : #registers }
CPMModbusDataTable >> maskWriteRegisterAt: anAddress and: andMask or: orMask [
	| address  register |

	(anAddress >=0 and:[ anAddress <=maxAddressSpace ]) 
	ifTrue:[
		address := anAddress + holdingRegisterTableStart.
		register := self table at: address.
		register := ((register bitAnd: andMask) bitOr:orMask).
		^ self table at: address put: register]
	ifFalse:[CPMIlegalDataAddressException new
											address:anAddress;
											signal]
]

{ #category : #initalize }
CPMModbusDataTable >> plainMemorySpace [
	"Coils - 0:1 to 0:65535
	Inputs - 1:1 to 1:65535
	Input Regs - 3:1 to 3:65535
	Output Regs - 4:1 to 4:65535"
	
	maxAddressSpace  := 65535.
	coilTableStart := 1.
	inputTableStart:= 1.
	holdingRegisterTableStart:= 1.
	inputRegisterTableStart:= 1.
	coilTableEnd := 65535.
	inputTableEnd:= 65535.
	holdingRegisterTableEnd:= 65535.
	inputRegisterTableEnd:= 65535.
]

{ #category : #registers }
CPMModbusDataTable >> presetHoldingRegisterAt: anAddress put: aWord [
	| address  |

	(anAddress >=0 and:[ anAddress <=maxAddressSpace ]) 
	ifTrue:[
		address := anAddress + holdingRegisterTableStart.
		^ self table at: address put:aWord]
	ifFalse:[CPMIlegalDataAddressException new
											address:anAddress;
											signal]
]

{ #category : #registers }
CPMModbusDataTable >> presetInputRegisterAt: anAddress put: aWord [
	| address  |
	
	(anAddress >=0 and:[ anAddress <=maxAddressSpace ]) 
	ifTrue:[
		address := anAddress + inputRegisterTableStart.
		^ self table at: address put:aWord]
	ifFalse:[CPMIlegalDataAddressException new
											address:anAddress;
											signal]
]

{ #category : #coils }
CPMModbusDataTable >> readCoilAt: bitPosition [
	| address bitPos bitAddress |
	
	bitAddress := (bitPosition / 16r10 ) integerPart.
	(bitAddress >= 0  and:[ bitAddress <= maxAddressSpace ]) 
	ifTrue:[
		address := ((bitPosition) / 16r10) integerPart+ coilTableStart.
		bitPos := (bitPosition  % 16r10) + 1.
		^ (self table at: address) bitAt:bitPos]
	ifFalse:[CPMIlegalDataAddressException new
											address: bitPosition;
											signal]
]

{ #category : #coils }
CPMModbusDataTable >> readCoilsStartingAt: anAddress numberOfPoints: twoBytesNumber [ 
	|buffer byte counter|
		"it must be optimized"
	buffer:= OrderedCollection new.
	counter := 0.

	( anAddress to:(anAddress + twoBytesNumber - 1) by:8) 
		do:[:eachCoil| 
			byte := 16r00.
			(0 to:7) do:[:offset|
				counter < twoBytesNumber 
					ifTrue:[ 
						byte := byte bitOr:((self readCoilAt: (eachCoil + offset) ) << offset)].
				counter := counter +1.
				].
			buffer add: byte].
				
	^ buffer asByteArray 
		
]

{ #category : #registers }
CPMModbusDataTable >> readHoldingRegisterAt: anAddress [
	| address  |
	
	(anAddress >=0 and:[ anAddress <= maxAddressSpace ]) 
	ifTrue:[
		address := anAddress + holdingRegisterTableStart.
		^ (self table at: address)]
	ifFalse:[CPMIlegalDataAddressException new
											address:anAddress;
											signal]
]

{ #category : #inputs }
CPMModbusDataTable >> readInputAt: bitPosition [
	| address bitPos bitAddress |
	
	bitAddress := (bitPosition / 16r10 ) integerPart.
	(bitAddress >= 0  and:[ bitAddress <= maxAddressSpace ]) 
	ifTrue:[
		address := ((bitPosition) / 16r10) integerPart  + inputTableStart.
		bitPos := (bitPosition % 16r10) + 1.
		^ (self table at: address) bitAt:bitPos]
	ifFalse:[CPMIlegalDataAddressException new
											address: bitPosition;
											signal]
]

{ #category : #registers }
CPMModbusDataTable >> readInputRegisterAt: anAddress [
	| address  |
	
	(anAddress >=0 and:[ anAddress <=maxAddressSpace]) 
	ifTrue:[
		address := anAddress + inputRegisterTableStart.
		^ (self table at: address)]
	ifFalse:[CPMIlegalDataAddressException new
											address:anAddress;
											signal]
]

{ #category : #inputs }
CPMModbusDataTable >> readInputsStartingAt: anAddress numberOfPoints: twoBytesNumber [ 
	|buffer byte counter|
		"it must be optimized"
	buffer:= OrderedCollection new.
	counter := 0.
	( anAddress to:(anAddress + twoBytesNumber - 1) by:8) 
		do:[:eachCoil| 
			byte := 16r00.
			(0 to:7) do:[:offset|
				counter < twoBytesNumber 
					ifTrue:[byte := byte bitOr:((self readInputAt: (eachCoil + offset) ) << offset)].
				counter := counter +1.
				].
			buffer add: byte].
				
	^ buffer asByteArray 
		
]

{ #category : #initalize }
CPMModbusDataTable >> separateMemorySpace [

"Output Coils are assigned the block 1-9999
Input Coils are assigned the block 10001-19999
Input Coils are assigned the block 10001-19999
Input Register are assigned the block 30001-39999
Output Register are assigned the block 40001-49999"

	maxAddressSpace:= 16r270E.
	coilTableStart := 1.
	inputTableStart:= 10001.
	inputRegisterTableStart:= 30001.
	holdingRegisterTableStart:= 40001.
	coilTableEnd:= inputTableStart - 1.
	inputTableEnd:= inputRegisterTableStart  - 1.
	inputRegisterTableEnd:= holdingRegisterTableStart  - 1.	
	holdingRegisterTableEnd:= holdingRegisterTableStart + maxAddressSpace
	


	

]

{ #category : #inputs }
CPMModbusDataTable >> setInputAt: bitPosition put:aBit [
	| address bitPos bitAddress |
	
	bitAddress := (bitPosition / 16r10 ) integerPart.
	(bitAddress >= 0  and:[ bitAddress <= maxAddressSpace ]) 
	ifTrue:[
		address := ((bitPosition) / 16r10) integerPart  + inputTableStart.
		bitPos := (bitPosition % 16r10) + 1.
		self table 
			at: address 
			put: ((self table at: address) bitAt:bitPos put:aBit)]
	ifFalse:[CPMIlegalDataAddressException new
											address: bitPosition;
											signal].
	^ aBit
]

{ #category : #config }
CPMModbusDataTable >> slaveId [
	^ slaveId ifNil:[slaveId := 01]
]

{ #category : #config }
CPMModbusDataTable >> slaveId: anId [
	slaveId := anId
]

{ #category : #table }
CPMModbusDataTable >> table [
	table ifNil:[ 
		table := Array new:65536.
		 1 to:65536  do:[:each| 
			table at:each put: 16r0000]].
	^table
]

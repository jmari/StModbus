Class {
	#name : #CPMTTYModbusFactory,
	#superclass : #CPMModbusFactory,
	#instVars : [
		'emptyArray',
		'serialPort',
		'port',
		'rtuMode'
	],
	#category : #'Control-Protocols-Modbus-Main'
}

{ #category : #modes }
CPMTTYModbusFactory >> ASCIIMode [
	rtuMode := false
]

{ #category : #modes }
CPMTTYModbusFactory >> RTUMode [
	rtuMode := true
]

{ #category : #'connection open/close' }
CPMTTYModbusFactory >> connectTo:aPort [
	port := aPort.
	self serialPort openPort: aPort
]

{ #category : #initialization }
CPMTTYModbusFactory >> initialize [ 
	super initialize.
	rtuMode :=true.
	emptyArray := Array new
]

{ #category : #modes }
CPMTTYModbusFactory >> isRTUMode [
	^ rtuMode
]

{ #category : #'as yet unclassified' }
CPMTTYModbusFactory >> port [
	^ port ifNil:[port := self class defaultPort]
]

{ #category : #'as yet unclassified' }
CPMTTYModbusFactory >> port: aPort [
	port := aPort
]

{ #category : #reading }
CPMTTYModbusFactory >> readByteArray [
   | buffer nRead started bytesRead timeout2 |

	buffer := ByteArray new: 256.
	timeout := self waitingTimeFor:10. "waiting time should be  3.5 chars in milliseconds"
	timeout2 := self waitingTimeFor:10. "waiting time should be  1.5 chars in milliseconds"
	started := Time millisecondClockValue.
	bytesRead := 0.
	[ Time millisecondClockValue - started < timeout]
   whileTrue:[
		nRead := self serialPort readInto: buffer startingAt: bytesRead + 1.
  		nRead isZero
            ifFalse: [
					bytesRead := bytesRead + nRead.
					started := Time millisecondClockValue.
					timeout:= timeout2
   ] ].
	^ bytesRead > 0 ifTrue:[buffer copyFrom: 1 to: bytesRead ] ifFalse:[emptyArray]	 	

]

{ #category : #accessing }
CPMTTYModbusFactory >> serialPort [
 	^ serialPort ifNil:[ serialPort := SerialPort new].
]

{ #category : #accessing }
CPMTTYModbusFactory >> waitingTimeFor:numberOfChars [ 
	|frameSize framesPerCharacters |
	frameSize := 1.
	self serialPort parityType == 0 ifFalse:[ frameSize := frameSize+ 1] .
	self serialPort stopBitsType == 0 ifFalse:[ frameSize := frameSize + 1.5].	
	self serialPort stopBitsType == 1 ifFalse:[ frameSize := frameSize + 1].
	self serialPort stopBitsType == 2 ifFalse:[ frameSize := frameSize + 2].
	framesPerCharacters := (8 * numberOfChars ) / self serialPort dataBits.
	framesPerCharacters :=(framesPerCharacters - framesPerCharacters asInteger) > 0 
									ifTrue:[ framesPerCharacters asInteger + 1]
									ifFalse:[framesPerCharacters asInteger].
	"shoud be self serialPort baudRate  but the timming seems to be a standard"
 ^  (((frameSize * framesPerCharacters) + (8*numberOfChars)) / 4800 )*1000

	"parity: 
		0 - no parity"
	"stopBits:
		0 - 1.5 stop bits
		1 - one stop bit
		2 - two stop bits" 
]

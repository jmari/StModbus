Class {
	#name : #CPMTTYASCIIFrameWrapper,
	#superclass : #CPMFrameWrapper,
	#instVars : [
		'header'
	],
	#category : #'Control-Protocols-Modbus-FrameWrappers'
}

{ #category : #'as yet unclassified' }
CPMTTYASCIIFrameWrapper class >> fromASCIItoByteArray: aCharArray [
"#(58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10 58 48 49 48 51 48 48 48 48 48 48 48 65 70 50 13 10)"
	| ws frame |
	ws := WriteStream on:OrderedCollection new.
	frame := aCharArray collect:[:aChar| (Integer readFrom: aChar asCharacter  asString base:16)].
	1 to: frame size -1 by:2 do:[:i|
		ws nextPut: (((frame at:i) <<4) bitOr: (frame at:i+1 ))].

	^ ws contents asByteArray 	
		
		
]

{ #category : #'as yet unclassified' }
CPMTTYASCIIFrameWrapper class >> parseFromStream: aStream [
	| i s frame lrc baLrc|
	i := self new.
	s := aStream upToEnd.
	frame := s copyFrom:2 to: s size -2.	 
	frame := self fromASCIItoByteArray: frame .
	frame isEmpty ifTrue:[^ nil].
	lrc := i toASCII: (frame copyFrom: frame size to: frame size).
	frame := frame copyFrom:1 to: (frame size - 1).		
	i modbusFunction: (CPMModbusFunction parseFromStream: (ReadStream on:frame)).
	baLrc := i LRC: frame.	
	baLrc  = lrc ifFalse:[CPMCRCException signal].
	^ i  
]

{ #category : #'as yet unclassified' }
CPMTTYASCIIFrameWrapper >> LRC [
	
	^ self LRC: self modbusTelegram contents 

 	
]

{ #category : #'as yet unclassified' }
CPMTTYASCIIFrameWrapper >> LRC: aByteArray [
	| nLRC |
	nLRC := 2r00000000.
	aByteArray do:[:aByte | nLRC := nLRC + aByte].
	^  self toASCII: {(nLRC bitAnd: 2r11111111) negated} 

 	
]

{ #category : #'as yet unclassified' }
CPMTTYASCIIFrameWrapper >> header [
	^ header ifNil:[ header:= ByteArray with: 16r3a]
]

{ #category : #'as yet unclassified' }
CPMTTYASCIIFrameWrapper >> telegram [
	| asciiTelegram |
	frame := ReadWriteStream on: OrderedCollection new.
	asciiTelegram := self toASCII: self modbusTelegram contents.

	frame 
		nextPutAll:  self header;
		nextPutAll:  asciiTelegram;
		nextPutAll:  self LRC;
		nextPutAll:  self trailer.
	^frame contents asByteArray 
]

{ #category : #private }
CPMTTYASCIIFrameWrapper >> toASCII: aByteArray [
	| ws  hexString |
	ws := WriteStream on:OrderedCollection new.
	aByteArray do:[:aByte| 
		hexString :=(aByte bitAnd:2r11111111) printStringHex.
		ws nextPutAll: (hexString size = 2 
											ifTrue:[hexString asByteArray  ]
											ifFalse: [ ('0', hexString)  asByteArray ])].
	^ ws contents asByteArray

]

{ #category : #'as yet unclassified' }
CPMTTYASCIIFrameWrapper >> trailer [
	^ String crlf asByteArray
 	
]

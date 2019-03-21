Class {
	#name : #CPMIlegalFunctionException,
	#superclass : #CPMException,
	#instVars : [
		'queryFunctionCode',
		'data'
	],
	#category : #'Control-Protocols-Modbus-Exceptions'
}

{ #category : #'as yet unclassified' }
CPMIlegalFunctionException >> code [
	^ 16r01
]

{ #category : #'as yet unclassified' }
CPMIlegalFunctionException >> data [
	^ data
]

{ #category : #'as yet unclassified' }
CPMIlegalFunctionException >> data: aByteArray [
	data:= aByteArray
]

{ #category : #'as yet unclassified' }
CPMIlegalFunctionException >> queryFunctionCode [
	^queryFunctionCode
]

{ #category : #'as yet unclassified' }
CPMIlegalFunctionException >> queryFunctionCode: aFunctionCode [
	queryFunctionCode := aFunctionCode
]

{ #category : #'as yet unclassified' }
CPMIlegalFunctionException >> responseTelegram [

	^  ByteArray 
		with: self slaveAddress
		with: (self queryFunctionCode bitOr: 16r80 )
		with: self code
	
]

Class {
	#name : #CPMIlegalDataAddressException,
	#superclass : #CPMException,
	#instVars : [
		'address'
	],
	#category : #'Control-Protocols-Modbus-Exceptions'
}

{ #category : #accessing }
CPMIlegalDataAddressException >> address [
	^ address
]

{ #category : #accessing }
CPMIlegalDataAddressException >> address: anObject [
	address := anObject
]

{ #category : #'as yet unclassified' }
CPMIlegalDataAddressException >> code [
	^16r02
]

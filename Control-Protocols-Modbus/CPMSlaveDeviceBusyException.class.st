Class {
	#name : #CPMSlaveDeviceBusyException,
	#superclass : #CPMException,
	#category : #'Control-Protocols-Modbus-Exceptions'
}

{ #category : #'as yet unclassified' }
CPMSlaveDeviceBusyException >> code [
	^ 16r06
]

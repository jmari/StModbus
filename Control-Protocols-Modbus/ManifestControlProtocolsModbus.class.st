"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestControlProtocolsModbus,
	#superclass : #PackageManifest,
	#category : #'Control-Protocols-Modbus-Manifest'
}

{ #category : #'code-critics' }
ManifestControlProtocolsModbus class >> ruleRBGuardingClauseRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#CPMTCPModbusMaster #reconnect #false)) #'2019-03-29T18:55:33.945273+01:00') )
]

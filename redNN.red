#! /usr/local/bin/red
Red [
	Title:   "Red Neural Network"
	Author:  "Francois Jouen"
	File: 	 %redNN.red
]
{This code is based on Back-Propagation Neural Networks 
by Neil Schemenauer <nas@arctrix.com>
Thanks to  Karl Lewin for the Rebol version}

; default number of input, hidden, and output nodes
nInput: 		2
nHidden: 		3
nOutput: 		1
; activations for nodes
aInput:			[]
aHidden:		[]
aOutput: 		[]
; weights matrices
wInput: 		[]
wOutput: 		[]
; matrices for last change in weights for momentum
cInput: 		[]
cOutput: 		[]

;calculate a random number where: a <= rand < b
rand: function [a [number!] b [number!]] [(b - a) * ((random 10000.0) / 10000.0) + a]

; Make matrices
make1DMatrix: function [mSize[integer!] value [number!] return: [block!]][
	m: copy []
	repeat i mSize [append m value]
	m
]
make2DMatrix: function [line [integer!] col [integer!] value [number!] return: [block!]][
	m: copy []
	repeat i line [
		blk: copy []
		repeat j col [append blk value]
		append/only m blk
	]
	m
]

;sigmoid function, tanh seems better than the standard 1/(1+e^-x)
tanh: function [x [number!] return: [number!]][ (EXP x - EXP negate x) / (EXP x + EXP negate x)]
sigmoid: function [x [number!] return: [number!]][tanh x]

;derivative of  sigmoid function
dsigmoid: function [y [number!] return: [number!]][1.0 - y * y]

createMatrices: func [] [
	aInput: 	make1DMatrix nInput	1.0
	aHidden:	make1DMatrix nHidden 1.0
	aOutput: 	make1DMatrix nOutput 1.0
	wInput: 	make2DMatrix nInput nHidden 0.0
	wOutput: 	make2DMatrix nHidden nOutput 0.0
	cInput:		make2DMatrix nInput nHidden 0.0
	cOutput:	make2DMatrix nHidden nOutput 0.0
	randomizeMatrix wInput -2.0 2.0
	randomizeMatrix wOutput -2.0 2.0
]

randomizeMatrix: function [mat [block!] v1 [number!] v2 [number!]][
	foreach elt mat [loop length? elt [elt: change/part elt rand v1 v2 1]]
]

computeMatrices: func [inputs [block!] /standard /sigmoidal return: [block!]] [
	; input activations
	repeat i (nInput - 1) [poke aInput i to float! inputs/:i]
	; hidden activations
	repeat j nHidden [
		sum: 0.0
		repeat i nInput [sum: sum + (aInput/:i * wInput/:i/:j)]
		if standard  [poke aHidden j 1 / (1 + EXP negate sum)]
		if sigmoidal [poke aHidden j sigmoid sum] 
	]
	; output activations
	repeat j nOutput [
		sum: 0.0
		repeat i nHidden [
		sum: sum + (aHidden/:i * wOutput/:i/:j)]
		if standard  [poke aOutput j 1 / (1 + EXP negate sum)]
		if sigmoidal [poke aOutput j sigmoid sum]
	]
	aOutput
]

backPropagation: func [targets [block!] lr [number!] mf [number!] /standard /sigmoidal return: [number!]] [
	; calculate error terms for output
	oDeltas: make1DMatrix  nOutput 0.0
	sum: 0.0
	repeat k nOutput [
		if sigmoidal [sum: targets/:k - aOutput/:k 
						poke oDeltas k (dsigmoid aOutput/:k) * sum
					]
		if standard [ao: aOutput/:k
		poke oDeltas k ao * (1 - ao) * (targets/:k - ao)]
	]
	; calculate error terms for hidden
	hDeltas: make1DMatrix  nHidden 0.0
	repeat j nHidden [
		sum: 0.0
		repeat k nOutput [sum: sum + (oDeltas/:k * wOutput/:j/:k)]
		if sigmoidal [poke hDeltas j (dsigmoid aHidden/:j) * sum]
		if standard [poke hDeltas j (aHidden/:j * (1 - aHidden/:j) * sum)]
	]
	; update output weights
	repeat j nHidden [
		repeat k nOutput [
			chnge: oDeltas/:k * aHidden/:j
			poke wOutput/:j k (wOutput/:j/:k + (lr * chnge) + (mf * cOutput/:j/:k))
			poke cOutput/:j k chnge
		]
	]
	; update hidden weights
	repeat i nInput [
		repeat j nHidden [
			chnge: hDeltas/:j * aInput/:i
			poke wInput/:i j (wInput/:i/:j + (lr * chnge) + (mf * cInput/:i/:j))
			poke cInput/:i j chnge
		]
	]
	; calculate error
	error: 0
	repeat k nOutput [error: error + (0.5 * ((targets/:k - aOutput/:k) ** 2))]
	error
]
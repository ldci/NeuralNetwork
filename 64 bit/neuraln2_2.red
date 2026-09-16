#! /usr/local/bin/red-view
Red [
	Title:   "Red Neural Network"
	Author:  "Francois Jouen"
	File: 	 %neuraln.red
	Needs:	 View
]

#include %redNN.red; all we need to create a neural network 
lr: 0.5			; learning rate 
mf: 0.1			; momentum factor
n: 	160			; n training sample
step: 		1;
nodeSize: 	140x50
isLearned: false
elapsed: none
tCount: 0

;OR by default pattern
pattern: [
	[[0 0] [0]]
	[[1 0] [1]]
	[[0 1] [1]]
	[[1 1] [1]]
]

changePattern: func [v1 v2 v3 v4][
	sbErr/text: copy ""
	result2/text: copy ""
	result1/text: copy ""
	inp1/text: copy ""
	inp2/text: copy ""
	wi1/text: copy ""
	wi2/text: copy ""
	wi3/text: copy ""
	hid1/text: copy "" 
	hid2/text: copy "" 
	hid3/text: copy ""
	wo/text: copy ""
	out1/text: copy ""
	result2/color: beige
	change second first pattern  v1 
	change second second pattern v2 
	change second third pattern  v3 
	change second fourth pattern v4
	append append result1/text form second first pattern newline
	append append result1/text form second second pattern newline
	append append result1/text form second third pattern newline
	append append result1/text form second fourth pattern newline
]

makeNetwork: func [ni [integer!] nh [integer!] no [integer!]] [
	random/seed now/time/precise
	nInput: 		ni + 1;+1 for bias node
	nHidden: 		nh
	nOutput: 		no
	createMatrices
	result2/text: copy ""
	sbcount/text: copy ""
	inp1/text: form first aInput
	inp2/text: form second aInput
	wi1/text: form  first wInput
	wi2/text: form second wInput
	wi3/text: form third wInput
	hid1/text: form first aHidden 
	hid2/text: form second aHidden 
	hid3/text: form third aHidden 
	wo/text: form wOutput
	out1/text: form first aOutPut
	result2/color: beige
]


trainNetwork: func [patterns[block!] iterations [number!] lr [number!] mf [number!] return: [block!]] [
	blk: copy []
	tcount: 0
	count: 0
	x: 10
	plot: compose [line-width 1 pen red line 0x230 660x230 pen green]
	clear sblearning/text
	t1: third now/time/precise
	repeat i iterations [
		sbcount/text: form i 
		error: 0.0
		foreach p patterns [
			either cb/data  [r: computeMatrices/sigmoidal p/1 
							error: error + backPropagation/sigmoidal p/2 lr mf]
						    [r: computeMatrices/standard p/1 
						    error: error + backPropagation/standard p/2 lr mf]
			inp1/text: form first p/1
			inp2/text: form second p/1
			wi1/text: form wInput/1
			wi2/text: form wInput/2
			wi3/text: form wInput/3
			hid1/text: form round/to aHidden/1 0.0001
			hid2/text: form round/to aHidden/2 0.0001
			hid3/text: form round/to aHidden/3 0.0001
			wo/text: form wOutput
			out1/text: form round/to first r 0.0001
			sberr/text: form round/to error 0.001
			do-events/no-wait
			append blk error
			count: count + 1
		]
		if (mod count step) = 0 [
				y: to integer! 230 - (error * 320)
				if x = 10 [append append plot 'line (as-pair x y)];'
				append plot (as-pair x y)
				x: x + 1	
		]
		visu/draw: plot
		testLearning pattern
		either isLearned [
			tCount: tCount + 1; for learning time
			if tCount = 1 [t2: third now/time/precise elapsed: (round/to t2 - t1 0.01) * 1000]
			sblearning/text: rejoin ["Pattern learned in " elapsed " msec"]]
						[sblearning/text: "Pattern not learned"]
	]
	blk;--errors block
]


testLearning: func [patterns [block!]] [ 

	result2/text: copy ""
	foreach p patterns [
		either cb/data  [r: computeMatrices/sigmoidal p/1]
						[r: computeMatrices/standard p/1] 
		append result2/text form to integer! round/half-ceiling first r 
		append result2/text newline
		either result1/text = result2/text [result2/color: green isLearned: true] 
								[result2/color: beige isLearned: false]
	] 
]

view win: layout [
	title "Back-Propagation Neural Network"
	text 60 "Pattern" 
	dpt: drop-down 70 
			data [ "OR" "XOR" "NOR" "AND" "NAND"]
			select 1
			on-change [
				switch face/text [
						"OR"  [changePattern 0 1 1 1]
						"XOR" [changePattern 0 1 1 0]
						"AND" [changePattern 0 0 0 1] 
						"NOR" [changePattern 1 0 0 0]
						"NAND"[changePattern 1 1 1 0]
				]	
			isCreated: false]
	text 55 "Sample"
	dp2: drop-down 70 
		data ["160" "320" "640" "1280" "2560"]
		select 1
		on-change [n: to integer! face/text step: (n / 640.0) * 4]	
	cb: check "Sigmoid" true
	button "Learn Pattern" [makeNetwork 2 3 1  trainNetwork pattern n lr mf
	]
	text 40 "Count" 	
	sbcount: base 50x20					 
	button 45 "Quit"			[quit]
	return 
	text 180 "Input Neurons"  
	text 210 "Hidden Neurons" 
	text 160 "Ouput Neuron"
	text  "Learning result"
	return
	text 50 "Input 1"	
	inp1: base 30x50 beige font-color black
	wi1: base ivory nodeSize font-color black wrap
	pad 0x12
	hid1: field 75
	return
	pad 100x0	
	wi2: base nodeSize ivory font-color black wrap
	pad 0x12
	hid2: field 75
	pad 10x-12
	wo: base nodeSize ivory font-color black wrap
	out1: base 75x50 beige font-color black
	return
	text 50 "Input 2"  
	inp2: base 30x50 beige font-color black
	wi3: base nodeSize ivory font-color black wrap
	pad 0x12
	hid3: field 75
	at 600x145 result1: area 35x65 green font-color black
	at 640x145 result2: area 35x65 beige font-color black
	return
	pad 102x0 text "Input matrices weights"
	pad 90x0  text "Output matrices weights"
	text "Error" sbErr: field 60
	return
	visu: base 660x240 black
	return
	sblearning: field 660
	
	do [changePattern 0 1 1 0]
]
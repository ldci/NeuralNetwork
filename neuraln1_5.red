#! /usr/local/bin/red
Red [
	Title:   "Red Neural Network"
	Author:  "Francois Jouen"
	File: 	 %neuraln.red
	Needs:	 View
]


#include %redNN.red; all we need to create a neural network 

lr: 0.5			; learning rate 
mf: 0.1			; momentum factor
n: 		640		; n training sample
netR: 	copy []	; learning result
step: 	4		; for visualization

;XOR pattern by default
pattern: [
	[[0 0] [0]]
	[[1 0] [1]]
	[[0 1] [1]]
	[[1 1] [0]]
]

changePattern: func [v1 v2 v3 v4][
	result2/text: copy ""
	result1/text: copy ""
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
	nInput: 		ni + 1 ;+1 for bias node
	nHidden: 		nh
	nOutput: 		no
	createMatrices
	s: copy "Neural Network created: "
	append append s form ni " input neurons "
	append append s form nh " hidden neurons "
	append append s form no " output neuron(s) "
	sb/text: s
	result2/text: copy ""
	sberr/text: copy ""
	sbcount/text: copy ""
]



trainNetwork: func [patterns[block!] iterations [number!] lr [number!] mf [number!] return: [block!]] [
	blk: copy []
	count: 0
	x: 10
	plot: compose [line-width 1 pen red line 0x230 660x230 pen green]
	repeat i iterations [
		sbcount/text: form i
		error: 0
		foreach p patterns [
			either cb/data  [r: computeMatrices/sigmoidal p/1 
							error: error + backPropagation/sigmoidal p/2 lr mf]
						    [r: computeMatrices/standard p/1 
						    error: error + backPropagation/standard p/2 lr mf]
			
			sberr/text: form round/to error 0.001
			if system/platform = 'Windows [do-events/no-wait];' win users
			do-events/no-wait
			append blk error
			count: count + 1
		]
		;visualization
		if (mod count step) = 0 [
			y: 230 - (error * 320)
			if x = 10 [append append plot 'line (as-pair x y)];'
			append plot (as-pair x y)
			x: x + 1	
		]
		visu/draw: plot
		do-events/no-wait
	]
	sb/text: copy "Neural Network rendered in: "
	blk
]

makeTraining: does [
	t1: now/time/precise				
	netR: trainNetwork pattern n lr mf	; network training
	t2: now/time/precise
	testLearning pattern				; test output values after training
	append sb/text form t2 - t1			;
]


testLearning: func [patterns [block!]] [ 
	result2/text: copy ""
	foreach p patterns [
		either cb/data  [r: computeMatrices/sigmoidal p/1]
						[r: computeMatrices/standard p/1] 
		append result2/text form to integer! round/half-ceiling first r 
		append result2/text newline
	] 
]




view win: layout [
	title "Back-Propagation Neural Network"
	text 60 "Pattern" 
	dpt: drop-down 70 
			data ["XOR" "OR" "NOR" "AND" "NAND"]
			select 1
			on-change [
				switch face/text [
						"XOR" [changePattern 0 1 1 0]
						"AND" [changePattern 0 0 0 1] 
						"OR"  [changePattern 0 1 1 1]
						"NOR" [changePattern 1 0 0 0]
						"NAND"[changePattern 1 1 1 0]
				]	
			isCreated: false]
	text 55 "Sample"
	dp2: drop-down 70 
		data ["640" "1280" "1920" "2560"]
		select 1
		on-change [n: to integer! face/text step: (n / 640) * 4 ]	
	cb: check "Sigmoid"
	button "Run Network" [makeNetwork 2 3 1 makeTraining]
	text 40 "Count" 	
	sbcount: field 50					 
	text 40 "Error"
	sberr: field 50
	
	return
	visu: base 660x240 black
	return
	sb: field 660
	button 45 "Quit"			[quit]
	
	at 670x50 text 60 "Expected"
	at 685x70 result1: area 35x80 
	at 670x150 text 65 "Computed"
	at 685x170 result2: area 35x80
	do [changePattern 0 1 1 0]
]

 



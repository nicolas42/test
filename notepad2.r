rebol []

sv: :system/view

select-line: func [/local a b] bind/copy [
	a: any [find/reverse back caret "^/" head caret]
	b: any [find caret "^/" tail caret]
	trim probe copy/part a b
] sv

select-highlight: does bind [
	copy/part highlight-start highlight-end
] sv

try*: func [
	{Quiet try. Doesn't halt execution.}
	a [string!]
][
	;try
	switch type?/word set/any 'a try [do a] [
		error! [a: disarm a] 
		unset! [a: none]
	]
	
	;mold
	case [
		none? :a [a: ""]
		not string? :a [a: mold :a] 
	]
	:a
	
	;highlight and insert caret
	do bind [ 
	
		insert caret :a
		highlight-start: caret
		caret: skip caret length? :a
		highlight-end: caret
		show focal-face
		
	] system/view
]

fac-text: {
fac/offset: 0x0 fac/size: win/size
601x570
fac/font/name: "fixedsys"
fac/colors: reduce [white white white]
fac/edge: none


test: func [a] [
 o: copy {}
 foreach a dump-obj a [
  append o a
 ]
 o
]

o: []
foreach w words-of system/words [if value? get :w [append o w]]

words-of system/words

system/words
asd fasdf asdf



fac/size: win/size

first system/words



}

win: layout [origin 0 fac: area fac-text]

view/options/new win [resize]

fac/feel: make object! bind/copy bind/copy [
    redraw: func [face act pos][
        if all [in face 'colors block? face/colors] [
            face/color: pick face/colors face <> focal-face
        ]
    ]
    detect: none
    over: none
    engage: func [face act event][
        switch act [
            down [
                either equal? face focal-face [unlight-text] [focus/no-show face]
                caret: offset-to-caret face event/offset
                show face
            ]
            over [
                if not-equal? caret offset-to-caret face event/offset [
                    if not highlight-start [highlight-start: caret]
                    highlight-end: caret: offset-to-caret face event/offset
                    show face
                ]
            ]
			alt-down [
				try* select-highlight
				show face
			]
            key [
				edit-text face event get in face 'action
				switch event/key [
					#"^M" #"^-" [
						try* select-line
						show face
					]
					#"^e" [
						try* select-highlight
						show face
					]
				]	
				
			]
        ]
    ]
] sv ctx-text

do-events


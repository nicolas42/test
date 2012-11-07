rebol[]

bitpattern: func [
	{the bitpattern of 3 is "00000011"}
	a
] [
	enbase/base to-binary to-char a 2
]

mask: func [
	{Filter block with a string of ones and zeroes
	e.g. mask [1 2 3] "010" => [2]}
	a b
][
	remove-each a copy a [#"0" = first+ b]
]

make-rule: funct [
	{Make Cellular Automaton Rule.
	for instance According to wolfram mathworld rule 30 is 100 011 010 001}
	a "number between 0 and 255"
][

	;make all rules
	r: copy []
	for n 7 0 -1 [
		bp: bitpattern n
		append r take/last/part bp 3
	]
	
	r: mask r bitpattern a
	probe reduce [n r]
	
	;make binary rule
	br: copy #{}
	foreach r r [
		foreach r r [
			append br switch r [
				#"1" [#{00000000}] ;black
				#"0" [#{ffffff00}] ;white 
			]
		]
	]
	br
]

if not exists? %library-utils.r [
	write %library-utils.r read http://www.fm.vslib.cz/~ladislav/rebol/library-utils.r
]

do %library-utils.r

;OMG works in linux (lubuntu)

if not exists? %cellular_automaton.so [
	call "gcc -shared cellular_automaton.c -o cellular_automaton.so"
]

lib: load/library %cellular_automaton.so
cellular_automaton: make routine! [a [integer!] la [int] r [integer!] lr [int] return: [integer!]] lib "cellular_automaton"

cellular-automaton: funct [n][

	;sz size, a argument, la length of argument, r rule, lr length rule, m memory, i image, fac interface
	;argument doesn't make sense, it's just legacy

	sz: 800x400
	la: sz/x * sz/y
	a: head insert/dup copy #{} #{ff ffff00} la		;make white binary 800*400 in length
	change/part (at a sz/x / 2 * 4) #{0000 0000} 4	;make black point top center
	
	r: make-rule n
	lr: (length? r) / 4 ;ints
	
	a: string-address? a
	r: string-address? r
	
	location: cellular_automaton a la r lr
	m: get-memory location la * 4  

	i: to-image m
	i/size: sz
	i
]

;cd "C:\6-Nov-2012"
secure [library allow]

n: 30
view layout [
	fac: image #" " 800x400 
	key keycode [right] [++ n fac/image: cellular-automaton n show fac]
	key keycode [left] [-- n fac/image: cellular-automaton n show fac]
	do [fac/image: cellular-automaton n show fac]
]


;it seems that since my machine is little endian, 
;the bytes in the integers in the c code are backwards relative to rebol

{

#include <windows.h> 
#define DLL_EXPORT __declspec(dllexport)  

DLL_EXPORT int cellular_automaton(int *a, int la, int *r, int lr) {
	
//100 011 010 001
//	int r[] = {0x00000000,0x00ffffff,0x00ffffff,    0x00ffffff,0x00000000,0x00000000,   0x00ffffff,0x00000000,0x00ffffff,   0x00ffffff,0x00ffffff,0x00000000}; 
//	int lr = 12;

	int i, j;
	for (i=0; i<(la-803); i=i+1) {
	for (j=0; j<lr; j=j+3) {
		if (a[i] == r[j] && a[i+1] == r[j+1] && a[i+2] == r[j+2]) {
			a[i+801] = 0x00000000;
		}
	}}
	return a;
}

}


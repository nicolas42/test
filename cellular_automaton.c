

#include <windows.h> 
#define DLL_EXPORT __declspec(dllexport)  

DLL_EXPORT int cellular_automaton(int *a, int la, int *r, int lr) {
	
	//100 011 010 001
//	int r[] = {0x00000000,0x00ffffff,0x00ffffff,    0x00ffffff,0x00000000,0x00000000,   0x00ffffff,0x00000000,0x00ffffff,   0x00ffffff,0x00ffffff,0x00000000}; 
//	int lr = 12;

	int i, j;
	
//	for (i=0; i<(la-803); i++) {a[i] = 0x00ffffff;}
	
	for (i=0; i<(la-803); i=i+1) {
	for (j=0; j<lr; j=j+3) {
		if (a[i] == r[j] && a[i+1] == r[j+1] && a[i+2] == r[j+2]) {
			a[i+801] = 0x00000000;
		}
	}}
	return a;
}

//my machine is little endian which means that the low order byte comes first, opposite to human notation. 

/*



do-it: does [
	cd %/c/programming/
	lib: load/library %dll.dll
	cellular-automaton: make routine! [a [integer!] la [int] return: [integer!]] lib "cellular_automaton"
	sz: 800x400
	la: sz/x * sz/y
	a: head insert/dup #{} #{ff ffff00} la
	change/part at a sz/x / 2 * 4 #{0000 0000} 4
	r: cellular-automaton string-address? a la
	m: get-memory r la * 4  

	i: to-image m
	i/size: sz
	view layout [image i]
	
]
do-it



*/

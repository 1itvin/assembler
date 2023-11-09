.486
.model flat, stdcall

option casemap: none

include windows.inc
include kernel32.inc
include masm32.inc

includelib kernel32.lib
includelib masm32.lib

.data
	enterX 			db "Enter x: "
	enterY 			db "Enter y: "
	res 			db "Result: "
	x 				dd 0
	y 				dd 0  
	max 			dd 0
	min 			dd 0
	tmp 			dd 0

.data?
	inputHandle 	dd ?
	outputHandle 	dd ?
	numberOfChars 	dd ?
	buffer 			db ?
	result 			db ?
	
.code

main:
;--------------------------------------------------------------------------------------------------- 
 
	push 	STD_INPUT_HANDLE
	call 	GetStdHandle
	mov 	inputHandle, EAX
	
	push 	STD_OUTPUT_HANDLE
	call 	GetStdHandle
	mov 	outputHandle, EAX   
	                     
;---------------------------------------------------------------------------------------------------
	                                                ; read x
	push 	NULL
	push 	offset numberOfChars
	push 	9
	push 	offset enterX
	push 	outputHandle
	call 	WriteConsole
	
	push 	NULL
	push 	offset numberOfChars
	push 	15
	push 	offset buffer
	push 	inputHandle
	call 	ReadConsole
	
	cmp 	buffer[0], '-'
	jne 	lblx
	mov 	buffer[0], 2d
	lblx:
	
	mov 	EDX, offset buffer
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EDX + EAX - 2 ], 0
	
	push 	offset buffer
	call 	atodw
	mov 	x, EAX   
	
;---------------------------------------------------------------------------------------------------
	                                                ; read y
	push 	NULL
	push 	offset numberOfChars
	push 	9
	push 	offset enterY
	push 	outputHandle
	call 	WriteConsole
	
	push 	NULL
	push 	offset numberOfChars
	push 	15
	push 	offset buffer
	push 	inputHandle
	call 	ReadConsole  
	
	cmp 	buffer[0], '-'
	jne 	lbly
	mov 	buffer[0], 2d
	lbly:
	
	mov 	EDX, offset buffer
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EDX + EAX - 2 ], 0
	
	push 	offset buffer
	call 	atodw
	mov 	y, EAX  
	
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	push 	NULL
   	push 	offset numberOfChars
	push 	8
   	push 	offset res
   	push 	outputHandle
   	call 	WriteConsole 
   	
;---------------------------------------------------------------------------------------------------
	
													; max(y, 5)
	cmp 	y, 5									; compare y and 5
	jg 		label1
													; if ( y <= 5 )
	mov 	max, 5									; max = 5
	jmp 	label2
	
	label1:   										; if ( y > 5 )
	mov 	EAX, y									; EAX = y
	mov	 	max, EAX                                ; max = EAX
	
	label2:											; max(x, 5)
	cmp 	x, 5  									; compare x and 5
	jl 		label3
	   												; if ( x > 5 )
	mov 	EAX, x									; EAX = x
	
	label3:											; if ( x < 5 )
	mov 	EAX, 5                                  ; EAX = 5
   													; min(max(x, 5), max(y, 5))
	cmp 	EAX, max								; compare EAX and max
	jg 		label4
													; if ( EAX <= max )
	mov 	min, EAX								; min = EAX
	jmp 	label5 
	
	label4:											; if ( EAX > max )
	mov 	EAX, max								; EAX = max
	mov 	min, EAX                                ; min = EAX
	
	label5:											; |x - y|
	mov 	EAX, x									; EAX = x
	sub 	EAX, y									; EAX = EAX - y									 
	
	cmp 	EAX, 0									; compare EAX and 0
	jge 	label6
													; if ( EAX < 0 )
	neg 	EAX                                     ; EAX = -EAX
	
	label6:									
													; min(10, |x - y|) 
	cmp 	EAX, 10									; compare EAX and 10
	jg 		label7
   													; if ( EAX < 10 )
	mov 	tmp, EAX								; tmp = EAX
	jmp 	label8 
	
	label7:											; if ( EAX > 10 )
	mov 	tmp, 10                                 ; tmp = 10
	
	label8:											; min / tmp 
	mov 	EAX, min                                ; EAX = min
	xor 	EDX, EDX   								; EDX = 0		
	idiv 	tmp                                     ; EAX = EAX / tmp, EDX = EAX % tmp
	
;---------------------------------------------------------------------------------------------------
	                                                ; output of result
	push 	offset result
	push 	EAX
	call 	dwtoa
	
	push 	offset result
	call 	lstrlen
	
	push 	NULL
	push 	offset numberOfChars
	push 	EAX
	push 	offset result
	push 	outputHandle
	call 	WriteConsole
	
;---------------------------------------------------------------------------------------------------
	
	push 	NULL
	push 	offset numberOfChars
	push 	1
	push 	offset buffer
	push 	inputHandle
	call 	ReadConsole
	
	push 	0
	call 	ExitProcess 
	
;---------------------------------------------------------------------------------------------------
end main
.486
.model flat, stdcall

option casemap : none

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
	
													; max(y, 10)  
	cmp 	y, 10                                   ; compare y and 10
	jl 		label1
													; if ( y >= 10 )   
   	mov 	EAX, y									; EAX = y
   	mov 	max, EAX                                ; max = EAX
   	jmp 	label2
   	
 	label1:											; if ( y < 10 )
 	mov 	max, 10
 	
 	label2:   æ
	mov 	EAX, x									; EAX = x
	mul 	EAX										; EAX = EAX * EAX
													; max(x^2, max(y, 10))
	cmp 	EAX, max								; compare EAX and max
	jl 		label3
													; if ( EAX >= max )
	mov 	max, EAX								; max = EAX
	
	label3:											; if ( EAX < max )   
	                                               	; max = previous max
   													; min(x, y)    
	mov 	EAX, y									; EAX = y
	cmp 	x, EAX									; compare x and EAX
	jl 		label4
													; if ( x >= y )
	mov 	min, EAX								; min = EAX
	jmp 	label5
	
	label4:											; if ( x < y )       
	mov 	EAX, x									; EAX = x
	mov 	min, EAX								; min = EAX
	                                				
	label5:										   	
	mov 	EAX, max								; EAX = max
	mov		EBX, min								; EBX = min
	cdq
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX 
	
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
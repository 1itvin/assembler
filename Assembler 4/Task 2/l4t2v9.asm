.486
.model flat, stdcall

option casemap : none

include windows.inc
include kernel32.inc
include masm32.inc

includelib kernel32.lib
includelib masm32.lib

.data
	enterA 			db "Enter a: "
	enterB 			db "Enter b: "
	res 			db "Result: "
	err				db "Error"
	a 				dd 0
	b 				dd 0

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
	                                                ; read a
	push 	NULL
	push 	offset numberOfChars
	push 	9
	push 	offset enterA
	push 	outputHandle
	call	WriteConsole
	
	push 	NULL
	push 	offset numberOfChars
	push 	15
	push 	offset buffer
	push 	inputHandle
	call 	ReadConsole
	
	cmp 	buffer[0], '-'
	jne 	lbla
	mov 	buffer[0], 2d
	lbla:
	
	mov 	EDX, offset buffer
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EDX + EAX - 2 ], 0
	
	push 	offset buffer
	call 	atodw
	mov 	a, EAX
	
;---------------------------------------------------------------------------------------------------
	
	cmp 	a, 0                                    ; compare a and 0
	jg 		gza
	je		error
	 												; if ( a < 0 )
	neg 	a                                       ; a = -a
	
;---------------------------------------------------------------------------------------------------
	                                                ; read b
	gza:
	
	push 	NULL
	push 	offset numberOfChars
	push 	9
	push 	offset enterB
	push 	outputHandle
	call 	WriteConsole 
	
	push 	NULL
	push 	offset numberOfChars
	push 	15
	push 	offset buffer
	push 	inputHandle
	call 	ReadConsole  
	
	cmp 	buffer[0], '-'
	jne 	lblb
	mov    	buffer[0], 2d
	lblb:
	
	mov 	EDX, offset buffer
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EDX + EAX - 2 ], 0
	
	push 	offset buffer
	call 	atodw
	mov 	b, EAX
	
;---------------------------------------------------------------------------------------------------
	
	cmp 	b, 0 									; compare b and 0	
	jg 		gzb
	je		error
	 												; if ( b < 0 )
	neg 	b                                       ; b = -b
	
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	gzb:
	
	push 	NULL
	push 	offset numberOfChars
	push 	8
	push 	offset res
	push 	outputHandle
	call 	WriteConsole

;---------------------------------------------------------------------------------------------------
   	
	startLoop:
   		cmp a, 0
		je endLoop
	
   		cmp b, 0
		je endLoop
	
		mov EAX, a									; EAX = a
		cmp EAX, b									; compare EAX and b
   		jl lbl
   	   												; if ( a >= b )
   		xor EDX, EDX								; EDX = 0
		idiv b                                      ; EAX = EAX / b, EDX = EAX % b
		mov a, EDX                                  ; a = EDX
		
		jmp startLoop
		
   		lbl:							
   		mov EAX, b									; EAX = b
		xor EDX, EDX                                ; EDX = 0
		idiv a                                      ; EAX = EAX / a, EDX = EAX % a
		mov b, EDX 									; b = EDX
		
    	jmp startLoop
	endLoop: 

	mov 	EAX, a									; EAX = a
	add 	EAX, b                                  ; EAX = EAX + b
	
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
	
	error:											; if ( a == 0 || b == 0 )  
	
	push	NULL
	push 	offset numberOfChars
	push	5
	push	offset err
	push 	outputHandle
	call	WriteConsole							; error message

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
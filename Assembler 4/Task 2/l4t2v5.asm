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
	res 			db "Result: "
	a 				dd 0
	sum 			dd 0

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
	call 	WriteConsole
	
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
													; if ( a <= 0 )
	neg 	a										; a = -a
	
	gza:

;--------------------------------------------------------------------------------------------------- 
	                                                ; write label	
	push 	NULL
	push 	offset numberOfChars
	push 	8
	push 	offset res
	push 	outputHandle
	call 	WriteConsole
	
;---------------------------------------------------------------------------------------------------
	
	mov 	EAX, a									; EAX = a
	mov 	EBX, 10									; EBX = 10

	startLoop:
   		cmp 	EAX, 0
		je 		endLoop
		
		xor 	EDX, EDX 							; EDX = 0
		idiv 	EBX									; EAX = EAX / EBX, EDX = EAX % EBX 
		add 	sum, EDX							; sum = sum + EDX
		
		jmp 	startLoop
	endLoop:
	
;---------------------------------------------------------------------------------------------------
	                                                ; output of result
	push 	offset result 
	push 	sum
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
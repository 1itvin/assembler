.486
.model flat, stdcall

option casemap : none

include windows.inc
include kernel32.inc
include masm32.inc

includelib kernel32.lib
includelib masm32.lib

.data
	enterN 			db "Enter n: " 
	res 			db "Result: "   
	err				db "Error"
	n 				dd 0
	cur 			dd 1
	prev 			dd 1

.data?
	inputHandle 	dd ?
	outputHandle 	dd ?
	numberOfChars 	dd ?
	buffer 			db ?
	result 	   		db ?
	
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
	                                                ; read n
	push 	NULL
	push 	offset numberOfChars
	push 	9
	push 	offset enterN  
	push 	outputHandle
	call 	WriteConsole
	
	push 	NULL
	push 	offset numberOfChars
	push 	15
	push 	offset buffer
	push 	inputHandle
	call 	ReadConsole 
	
	cmp		buffer[0], '-'
	jne		lbln
	mov		buffer[0], 2d
	lbln:
	
	mov 	EDX, offset buffer
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EDX + EAX - 2 ], 0
	
	push 	offset buffer
	call 	atodw
	mov 	n, EAX
	
;---------------------------------------------------------------------------------------------------
                                                    ; data verification
	cmp		n, 0
	jge		continue
	
	push	NULL
	push	offset numberOfChars
	push	5
	push	offset err
	push 	outputHandle
	call	WriteConsole
	
	jmp		exit	
	
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	continue:
	
	push 	NULL
   	push 	offset numberOfChars
	push 	8
   	push 	offset res
   	push 	outputHandle
   	call 	WriteConsole 
   	
;---------------------------------------------------------------------------------------------------
	                                                ; sum(n) = f(n + 2) - 1
	add 	n, 2									; n = n + 2 
    
	mov 	ECX, 1									; ECX = 1
	
	startLoop:
    	cmp 	ECX, n
    	je 		endLoop
    	
    	mov 	EAX, prev							; EAX = f(i - 2)
    	add 	EAX, cur 							; EAX = EAX + f(i - 1) 
    	mov 	EBX, cur  							; EBX = f(i - 1)
    	mov 	prev, EBX						   	; f(i - 2) = f(i - 1)
    	mov 	cur, EAX  							; f(i - 1) = EAX ( f(i) )
    	
    	inc 	ECX
    	
		jmp 	startLoop
	endLoop:

	sub 	EAX, 1   								; EAX = EAX - 1
	
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
	
	exit:
	
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
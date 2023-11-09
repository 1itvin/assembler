.486
.model flat, stdcall

option casemap : none

include windows.inc
include kernel32.inc
include masm32.inc

includelib kernel32.lib
includelib masm32.lib

.data
	enterN 			db "Enter a: "
	res 			db "Result: "
	err 			db "Error" 
	n 				dd 0

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
	
	cmp 	buffer[0], '-'
	jne 	lbln
	mov 	buffer[0], 2d
	lbln:
	
	mov 	EDX, offset buffer
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EDX + EAX - 2 ], 0
	
	push 	offset buffer
	call 	atodw
	mov 	n, EAX  
	
;---------------------------------------------------------------------------------------------------
                                                    ; write label
	push 	NULL
	push 	offset numberOfChars
	push 	8
	push 	offset res
	push 	outputHandle
	call 	WriteConsole
	
;---------------------------------------------------------------------------------------------------
	
	mov 	EAX, 1									; EAX = 1
	
	cmp 	n, 0									; compare n and 0
	jg 		gzn
	je 		endLoop
													; if ( n < 0 )
	push 	NULL
	push 	offset numberOfChars
	push 	5
	push 	offset err
	push 	outputHandle
	call 	WriteConsole							; error message
	
	jmp 	exit
   	
   	gzn: 											; if ( n > 0 )  											
   	mov 	ECX, 1                                  ; ECX = 1
   	
	startLoop:
		cmp 	ECX, n
		je 		endLoop
		  
		inc 	ECX									; increase ECX
		imul 	ECX 								; EAX = EAX * ECX
		
		jmp 	startLoop
	endLoop:
	
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
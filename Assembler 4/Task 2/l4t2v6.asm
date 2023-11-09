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
	err 			db "Error" 
	n  				dd 0
	nd2    			dd 0
	count 			dd 0

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
	mov	 	n, EAX
	
;---------------------------------------------------------------------------------------------------
	                                                ; data verification
	cmp 	n, 0									; comapare n and 0
	je 		ezn
	jg 		gzn
													; if ( n < 0 )
	push 	NULL
	push 	offset numberOfChars
	push 	5
	push 	offset err
	push 	outputHandle
	call 	WriteConsole							; error message
	
	jmp 	exit
	
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	gzn: 

	push 	NULL
	push 	offset numberOfChars
	push 	8
	push 	offset res
	push 	outputHandle
	call 	WriteConsole
	
;---------------------------------------------------------------------------------------------------
	
	mov 	EAX, n                                  ; EAX = n
	mov 	EBX, 2                                  ; EBX = 2
	xor 	EDX, EDX                                ; EDX = 0
	idiv	 EBX                                    ; EAX = EAX / EBX, EDX = EAX % EBX
	mov 	nd2, EAX								; nd2 = EAX
	
;--------------------------------------------------------------------------------------------------- 
	
	mov 	ECX, 1									; ECX = 1 ( 1|n )
   	  	
	startLoop:
   		cmp 	ECX, nd2
   		jg 		endLoop
   		
   		mov 	EAX, n 								; EAX = n
   		xor 	EDX, EDX							; EDX = 0
   		idiv 	ECX									; EAX = EAX / ECX, EDX = EAX % ECX  
   		
   		cmp 	EDX, 0								; compare EDX and 0
   		jne 	continue
   													; if ( EDX == 0 )
   		inc 	count   							; increase counter
   		
   		continue:
   		inc 	ECX 
   		
   		jmp 	startLoop
	endLoop:

	inc 	count									; increase counter ( reflexivity of division )
	
;--------------------------------------------------------------------------------------------------- 
	                                                ; output of result
	ezn:
	
	push 	offset result 
	push 	count
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
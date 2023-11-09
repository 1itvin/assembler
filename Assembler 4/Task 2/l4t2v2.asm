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
	enterN 			db "Enter n: "
	res 			db "Result: ", 0
	counter 		db "Count: ", 0
	err 			db "Error" 
	endl 			db 0ah
	a 				dd 0
	n 				dd 0
	count 			dd 0
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
	                                                ; read b
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
	                                                
	cmp 	n, 0									; compare n and 0	
	jg 		gzn
	jl 		lzn
													; if ( n == 0 )
	mov 	EAX, 1									; EAX = 0 
	mov 	count, 1								; count = 1
	jmp 	endLoop

	lzn:											; if ( n < 0 )
	push 	NULL
	push 	offset numberOfChars
	push 	5
	push 	offset err
	push 	outputHandle
	call 	WriteConsole							; error message
	
	jmp 	exit
	
	gzn:
	mov 	EAX, a									; EAX = a
	mov 	ECX, n									; ECX = n
	mov 	EBX, 2 									; EBX = 2
   	
	startLoop:
   		cmp 	ECX, 1
    	je 		endLoop
    
    	mov 	tmp, EAX							; save EAX value
    	mov 	EAX, ECX							; EAX = ECX
    	xor 	EDX, EDX							; EDX = 0
    	idiv 	EBX  								; EAX = EAX / EBX, EDX = EAX % EBX
       
    	cmp 	EDX, 0								; compare EDX and 0
    	jne 	odd
       												; if ( EDX == 0 )								
    	mov 	ECX, EAX							; ECX = EAX ( EAX = ECX / 2 )
    
    	mov 	EAX, tmp							; restore EAX value
    	imul 	a									; EAX = EAX * a	 
    	jmp 	continueLoop
    	
		odd:										; if ( EDX != 0 ) 
		dec 	ECX									; ECX = ECX - 1       
    	mov 	EAX, tmp                            ; restore EAX value
    	imul 	EAX                                 ; EAX = EAX * EAX
    	
		continueLoop: 
		   
		inc 	count								; increase counter
		    	
		jmp 	startLoop
	endLoop: 

;---------------------------------------------------------------------------------------------------      
	                                                ; output of result
	push 	offset result 
	push 	EAX
	call 	dwtoa
	
	push 	NULL
	push 	offset numberOfChars
	push 	8
	push 	offset res
	push 	outputHandle
	call 	WriteConsole      
	
	push 	offset result
	call 	lstrlen
	
	push 	NULL
	push 	offset numberOfChars
	push 	EAX
	push 	offset result
	push 	outputHandle
    call 	WriteConsole
    
;--------------------------------------------------------------------------------------------------- 
                                                    ; write label
    push 	NULL
    push 	offset numberOfChars
	push 	1	
	push 	offset endl
	push 	outputHandle
	call 	WriteConsole
	
	push 	NULL
	push 	offset numberOfChars
	push 	7
	push 	offset counter
	push 	outputHandle
	call 	WriteConsole
	
;---------------------------------------------------------------------------------------------------
	                                                ; output of result
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
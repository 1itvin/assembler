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
	sum 			db "a + b = "
	diff 			db "a - b = "
	comp 			db "a * b = "
	quo 			db "a / b = "
	endl 			db 0ah
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
    call 	WriteConsole
        
	push 	NULL
	push 	offset numberOfChars
	push 	15
	push 	offset buffer
	push 	inputHandle
	call 	ReadConsole
	
	cmp 	buffer[0], '-'
	jne 	labela
	mov 	buffer[0], 2d
	labela:
	
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
	jne 	labelb
	mov 	buffer[0], 2d
	labelb:
	
	mov 	EDX, offset buffer
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EDX + EAX - 2 ], 0
	
	push 	offset buffer
	call 	atodw
	mov 	b, EAX 

;---------------------------------------------------------------------------------------------------
	                                                ; write label
	push 	NULL
	push 	offset numberOfChars
	push	8
	push 	offset sum
	push 	outputHandle
	call 	WriteConsole    
	
;---------------------------------------------------------------------------------------------------
			                                        ; sum
	mov 	EAX, a    								; EAX = a
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
	
	push 	NULL
	push 	offset numberOfChars
	push 	1
	push 	offset endl
	push 	outputHandle
	call 	WriteConsole                                                                               
	
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	push 	NULL
	push 	offset numberOfChars
	push 	8
	push 	offset diff
	push 	outputHandle
	call 	WriteConsole     
	
;---------------------------------------------------------------------------------------------------
	                                                ; difference
	mov 	EAX, a                                 	; EAX = a
	sub 	EAX, b                                  ; EAX = EAX - b
	
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
	
	push 	NULL
	push 	offset numberOfChars
	push 	1
	push 	offset endl
	push 	outputHandle
	call 	WriteConsole
	                   
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	push 	NULL
	push 	offset numberOfChars
	push 	8
	push 	offset comp
	push 	outputHandle
	call 	WriteConsole    
	
;---------------------------------------------------------------------------------------------------
													; composition               
	mov 	EAX, a                                  ; EAX = a
	imul	b                                       ; EAX = EAX * b
	
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
	
	push 	NULL
	push 	offset numberOfChars
	push 	1
	push 	offset endl
	push 	outputHandle
	call 	WriteConsole     
	
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	push 	NULL
	push 	offset numberOfChars
	push 	8
	push 	offset quo
	push 	outputHandle
	call 	WriteConsole   
	
;---------------------------------------------------------------------------------------------------
													; quotient
	mov 	EAX, a                                  ; EAX = a
	cdq												
	idiv 	b                                    	; EAX = EAX / b, EDX = EAX % b
	
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
	
	push 	NULL
	push 	offset numberOfChars
	push 	1
	push 	offset endl
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
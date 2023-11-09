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
	a 				dd 0
	b 				dd 0
	tmp 			dd 0

.data?
	inputHandle 	dd ?
	outputHandle 	dd ?
	numberOfChars 	dd ?
	result 			db ?
	buffer 			db ?

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
	mov 	byte ptr [ EDX + EAX - 2], 0
	
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
	push 	8
   	push 	offset res
   	push 	outputHandle
   	call 	WriteConsole   
   	
;---------------------------------------------------------------------------------------------------

	mov 	EAX, b                                  ; EAX = b
	imul 	EAX                                     ; EAX = EAX * EAX
	mov 	EBX, 5                                  ; EBX = 5
	xor 	EDX, EDX                                ; EDX = 0
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX
	mov 	tmp, EAX                               	; tmp = EAX
	
	mov 	EAX, a    								; EAX = a
	imul 	EAX                                     ; EAX = EAX * EAX
	sub 	EAX, tmp                                ; EAX = EAX - tmp
	
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
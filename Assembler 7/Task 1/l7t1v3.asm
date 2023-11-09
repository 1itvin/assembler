.486
.model flat, stdcall

option casemap : none

include	windows.inc
include	kernel32.inc
include masm32.inc

includelib kernel32.lib
includelib masm32.lib

.data
	enterN			db "Enter n: "
	result			db "Result:  "
	err				db "Error"
    n				dd 0
	
.data
	inputHandle		dd ?
	outputHandle	dd ?
	numberOfChars	dd ?
	buffer			db ?
	
.code

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
     
; int factorial(int n)	maximum is 12!
factorial:
	push	EBP
	mov		EBP, ESP
	           
	cmp		dword ptr [ EBP + 8 ], 1                ; compare n and 1
	jg		g1n                                     
	                                                ; if ( n <= 1 )
	mov		EAX, 1                                  ; EAX = 1
	jmp 	continue
	
	g1n:
	
	mov		EBX, dword ptr [ EBP + 8 ]              ; EBX = n
	dec		EBX                                     
	
	push	EBX                                     
	call	factorial                               ; factorial(n - 1)
	
	mul		dword ptr [ EBP + 8 ]	                ; ( EAX = factorial(n - 1) ), EAX = EAX * n
	
	continue:
	
	pop		EBP
ret 4

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------

main:
   	 
;-----------------------------------------------------------------------------------------
	
	push	STD_INPUT_HANDLE
	call 	GetStdHandle
	mov		inputHandle, EAX
	
	push	STD_OUTPUT_HANDLE
	call	GetStdHandle
	mov		outputHandle, EAX
	
;-----------------------------------------------------------------------------------------
                                            		; read n
   	push 	NULL
   	push 	offset numberOfChars
   	push	9
   	push	offset enterN
   	push	outputHandle
   	call	WriteConsole
   	
   	push	NULL
   	push	offset numberOfChars
   	push	15
   	push	offset buffer
   	push	inputHandle
   	call 	ReadConsole
   	
   	cmp		buffer[0], '-'
   	jne		lbl
   	mov		buffer[0], 2d
   	lbl:
   	
   	mov		EDX, offset buffer
   	mov		EAX, numberOfChars
   	mov		byte ptr [ EDX + EAX - 2 ], 0
   	
   	push	offset buffer
   	call	atodw
   	mov		n, EAX
   	
;-----------------------------------------------------------------------------------------
                                                   	; if ( n < 0 )
	cmp		n, 0
	jge		find
	            
	push	NULL
	push	offset numberOfChars
	push	5
	push	offset err
	push	outputHandle
	call	WriteConsole
	
	jmp		exit 
   	
;-----------------------------------------------------------------------------------------
	
	find:   

	push	NULL
	push	offset numberOfChars
	push 	9
	push	offset result
	push	outputHandle
	call	WriteConsole   	

;-----------------------------------------------------------------------------------------

	push	n
	call	factorial           					; factorial(n)
	
;-----------------------------------------------------------------------------------------
                                                    ; output of result
    push	offset buffer
    push	EAX
    call	dwtoa
	
	push	offset buffer
	call 	lstrlen
	
	push	NULL
	push	offset numberOfChars
	push	EAX
	push	offset buffer
	push	outputHandle
	call	WriteConsole                                                                                      

;-----------------------------------------------------------------------------------------
	
	exit:	   	

	push	NULL
	push 	offset numberOfChars
	push 	1
	push	offset buffer
	push	inputHandle
	call	ReadConsole
	
	push	0
	call	ExitProcess
	
;-----------------------------------------------------------------------------------------
	   	
end main
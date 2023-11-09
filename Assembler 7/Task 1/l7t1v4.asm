.486
.model flat, stdcall

option casemap : none

include	windows.inc
include	kernel32.inc
include masm32.inc

includelib kernel32.lib
includelib masm32.lib

.data
	enterA			db "Enter a: "
	enterN			db "Enter n: "
	result			db "Result:  "
	err				db "Error"
	a				dd 0
    n				dd 0
	
.data
	inputHandle		dd ?
	outputHandle	dd ?
	numberOfChars	dd ?
	buffer			db ?
	
.code

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
     
; int power(int a, int n)
power:
	push	EBP
	mov		EBP, ESP
	
	cmp		dword ptr [ EBP + 12], 0				; compare n and 0
	jne		nezn
	                                                ; if ( n == 0 )
	mov		EAX, 1                                  ; EAX = 1
	jmp 	continue
	         
	nezn:                                           ; if ( n != 0 )
	cmp		dword ptr [ EBP + 12 ], 1             	; compare n and 1
	jne		ne1n                                     
	                                                ; if ( n == 1 )
	mov		EAX, dword ptr [ EBP + 8]               ; EAX = a
	jmp 	continue
	
	ne1n:											; if ( n != 1 )	
	mov		EBX, dword ptr [ EBP + 12 ]          	; EBX = n
	dec		EBX                                     
	
	push	EBX
	push	dword ptr [ EBP + 8 ]                                     
	call	power		                          	; power(a, n - 1)
	
	mul		dword ptr [ EBP + 8 ]	                ; ( EAX = power(a, n - 1) ), EAX = EAX * a
	
	continue:
	
	pop		EBP
ret 8

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
                                            		; read a
   	push 	NULL
   	push 	offset numberOfChars
   	push	9
   	push	offset enterA
   	push	outputHandle
   	call	WriteConsole
   	
   	push	NULL
   	push	offset numberOfChars
   	push	15
   	push	offset buffer
   	push	inputHandle
   	call 	ReadConsole
   	
   	cmp		buffer[0], '-'
   	jne		lbl1
   	mov		buffer[0], 2d
   	lbl1:
   	
   	mov		EDX, offset buffer
   	mov		EAX, numberOfChars
   	mov		byte ptr [ EDX + EAX - 2 ], 0
   	
   	push	offset buffer
   	call	atodw
   	mov		a, EAX
	
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
   	jne		lbl2
   	mov		buffer[0], 2d
   	lbl2:
   	
   	mov		EDX, offset buffer
   	mov		EAX, numberOfChars
   	mov		byte ptr [ EDX + EAX - 2 ], 0
   	
   	push	offset buffer
   	call	atodw
   	mov		n, EAX
   	
;-----------------------------------------------------------------------------------------
                                                   	
	cmp		a, 0
	jl		error
	cmp		n, 0
	jl		error
	jmp 	find	
	
	error:            
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
	push	a
	call	power          							; power(a, n)
	
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
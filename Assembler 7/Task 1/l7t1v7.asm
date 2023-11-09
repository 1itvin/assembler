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
	enterB			db "Enter b: "
	result			db "Result:  "
	a				dd 0
    b				dd 0
	
.data
	inputHandle		dd ?
	outputHandle	dd ?
	numberOfChars	dd ?
	buffer			db ?
	
.code

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
     
; int nod(int a, int b)
nod:
	push	EBP
	mov		EBP, ESP
	
	cmp		dword ptr [ EBP + 8 ], 0                ; compare a and 0
	jne		neza
	                                                ; if ( a == 0 )
	mov		EAX, dword ptr [ EBP + 12 ]             ; EAX = b
	jmp 	continue
	
	neza:                                     
	mov		EAX, dword ptr [ EBP + 12 ]       		; EAX = b
	mov		EBX, dword ptr [ EBP + 8 ]              ; EBX = a
	cdq
	idiv	EBX
	
	push	dword ptr [ EBP + 8 ]
	push	EDX 
	call	nod                                     ; nod(b % a, a)
	
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
                                            		; read b
   	push 	NULL
   	push 	offset numberOfChars
   	push	9
   	push	offset enterB
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
   	mov		b, EAX

;-----------------------------------------------------------------------------------------  

	push	NULL
	push	offset numberOfChars
	push 	9
	push	offset result
	push	outputHandle
	call	WriteConsole   	

;-----------------------------------------------------------------------------------------

	push	b
	push	a
	call	nod          							; nod(a, b)
	
;-----------------------------------------------------------------------------------------

	cmp		EAX, 0
	jge		output
	neg		EAX
	
;-----------------------------------------------------------------------------------------
                                                    ; output result
	output:
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
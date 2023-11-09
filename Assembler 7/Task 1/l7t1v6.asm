.486
.model flat, stdcall

option casemap : none

include	windows.inc
include	kernel32.inc
include masm32.inc

includelib kernel32.lib
includelib masm32.lib

.data
	enterK			db "Enter k: "
	enterN			db "Enter n: "
	result			db "Result:  "
	err				db "Error"
	k				dd 0
    n				dd 0
	
.data
	inputHandle		dd ?
	outputHandle	dd ?
	numberOfChars	dd ?
	buffer			db ?
	
.code

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
     
; int ank(int k, int n)
ank:
	push	EBP
	mov		EBP, ESP
	
	cmp		dword ptr [ EBP + 8], 0					; compare k and 0
	jne		nezn
	                                                ; if ( n == 0 )
	mov		EAX, 1                                  ; EAX = 1
	jmp 	continue
	         
	nezn:                                           ; if ( k != 0 )
	mov		EBX, dword ptr [ EBP + 12 ]          	; EBX = n
	dec		EBX                                     
	
	mov		EDX, dword ptr [ EBP + 8 ]              ; EDX = k
	dec		EDX
	
	push	EBX
	push	EDX                                    
	call	ank		                          		; ank(k - 1, n - 1)
	
	mul		dword ptr [ EBP + 12 ]	                ; ( EAX = ank(k - 1, n - 1) ), EAX = EAX * n
	
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
   	push	offset enterK
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
   	mov		k, EAX
	
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

    mov		EAX, k
    cmp		EAX, n
    jg		error                                               	
	cmp		k, 0
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
	push	k
	call	ank          							; ank(k, n)
	
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
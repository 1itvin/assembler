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
	res 			db "a * b = " 
	a 				dd 0
	b 				dd 0
	z 				db 0

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
	push 	8
   	push 	offset res
   	push 	outputHandle
   	call 	WriteConsole 
   	
;---------------------------------------------------------------------------------------------------
   
   	cmp		a, 0									; compare a and 0
   	je		ez		
   	
	cmp 	b, 0									; compare b and 0
	jg 		gz
	je 		ez
													; if ( b < 0 )
	neg 	b										; b = -b
	mov 	z, 1                                    ; z = 1
	jmp 	gz
	
	ez:												; if ( a == 0 || b == 0 )
	mov 	EAX, 0									; EAX = 0
	jmp 	endLoop
		
	gz:												 	
	mov 	EAX, a									; EAX = a
    mov 	ECX, 1                                  ; ECX = 1

	startLoop:
		cmp 	ECX, b
		je 		endLoop 
		
		add 	EAX, a								; EAX = EAX + a
		inc 	ECX
		
		jmp startLoop
	endLoop:

	cmp 	z, 0									; compare z and 0
	je 		lbl
													; if ( z != 0 )
	neg 	EAX										; EAX = -EAX
	
;---------------------------------------------------------------------------------------------------
	                                                ; output of result
	lbl:
	
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
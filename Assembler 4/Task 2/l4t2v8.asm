.486
.model flat, stdcall

option casemap : none

include windows.inc
include kernel32.inc
include masm32.inc

includelib kernel32.lib
includelib masm32.lib

.data 
	enterA 	   		db "Enter a: "
	enterB 			db "Enter b: "
	res 			db "a % b = " 
	err 			db "Error"
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
	
	cmp 	a, 0                                    ; compare a and 0
	jg 		gza
													; if ( a <= 0 )
	neg 	a 										; a = -a
	mov 	z, 1                                   	; z = 1

;---------------------------------------------------------------------------------------------------
	                                                ; read b
	gza: 
	
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
	jne 	lblb
	mov 	buffer[0], 2d
	lblb:
	
	mov 	EDX, offset buffer
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EDX + EAX - 2 ], 0
	
	push 	offset buffer
	call 	atodw
	mov 	b, EAX
	
;---------------------------------------------------------------------------------------------------
	
	cmp 	b, 0                                    ; compare b and 0
	jg 		gzb
	je 		ezb
													; if ( b < 0 )
	neg 	b    									; b = -b
	jmp 	gzb
	
	ezb:											; if ( b == 0 )
	push 	NULL
	push 	offset numberOfChars
	push 	5
	push 	offset err
	push 	outputHandle
	call 	WriteConsole 							; error message
	
	jmp 	exit
	
;---------------------------------------------------------------------------------------------------
                                                    ; write label
	gzb:
	
	push 	NULL
   	push 	offset numberOfChars
	push 	8
   	push 	offset res
   	push 	outputHandle
   	call 	WriteConsole
   	
;---------------------------------------------------------------------------------------------------

	mov 	EAX, a                                  ; EAX = a
	          
	startLoop:
   		cmp 	EAX, b
   		jl 		endLoop 
   		
		sub 	EAX, b								; EAX = EAX - b
	
		jmp 	startLoop
	endLoop:
	
	cmp 	z, 0									; compare z and 0				
	je 		lbl
	 												; if ( z != 0 )
	neg 	EAX                                     ; EAX = -EAX
	
;---------------------------------------------------------------------------------------------------	
	                                                ; output of reasult
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
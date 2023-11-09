.486
.model flat, stdcall

option casemap : none

include windows.inc
include kernel32.inc
include masm32.inc

includelib kernel32.lib
includelib masm32.lib

.data
	enterX 			db "Enter x: "
	enterY 			db "Enter y: "
	res 			db "Result: "  
	x 				dd 0
	y 				dd 0
	max 			dd 0
	min 			dd 0
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
	                                                ; read x
	push	NULL
	push 	offset numberOfChars
	push 	9
	push 	offset enterX
	push 	outputHandle
	call 	WriteConsole
	
	push	NULL
	push 	offset numberOfChars
	push 	15
	push 	offset buffer
	push 	inputHandle
	call 	ReadConsole
	
	cmp 	buffer[0], '-'
	jne 	lblx
	mov 	buffer[0], 2d
	lblx:
	
	mov 	EDX, offset buffer
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EDX + EAX - 2 ], 0
	
	push 	offset buffer
	call 	atodw
	mov 	x, EAX   
	
;---------------------------------------------------------------------------------------------------
	                                                ; read y
	push 	NULL
	push 	offset numberOfChars
	push 	9
	push 	offset enterY
	push 	outputHandle
	call 	WriteConsole
	
	push 	NULL
	push 	offset numberOfChars
	push 	15
	push 	offset buffer
	push 	inputHandle
	call 	ReadConsole
	
	cmp 	buffer[0], '-'
	jne 	lbly
	mov 	buffer[0], 2d
	lbly:
	
	mov 	EDX, offset buffer
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EDX + EAX - 2 ], 0
	
	push 	offset buffer
	call 	atodw
	mov 	y, EAX   
	
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	push 	NULL
   	push 	offset numberOfChars
	push 	8
   	push 	offset res
   	push 	outputHandle
   	call 	WriteConsole   
   	
;---------------------------------------------------------------------------------------------------
	
													; x % 10
	mov 	EAX, x									; EAX = x
	mov 	EBX, 10                                 ; EBX = 10
	cdq
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX
	mov 	tmp, EDX								; tmp = EDX
													; y % 10
	mov 	EAX, y                                  ; EAX = y
	mov		EBX, 10                                 ; EBX = 10
	cdq
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX
													; max(x % 10, y % 10)
	cmp 	tmp, EDX                                ; compare tmp and EDX
	jg 		label1
													; if ( tmp < EDX )
	mov 	max, EDX								; max = EDX
	jmp 	label2
	
	label1:											; if ( tmp > EDX )
	mov 	EAX, tmp                                ; EAX = tmp
	mov 	max, EAX                                ; max = EAX
	
	label2:											; 2 * x
	mov 	EAX, x                                  ; EAX = x
	mov 	EBX, 2                                  ; EBX = 2
	imul 	EBX										; EAX = EAX * EBX	   
													; 2 * x - y
	sub 	EAX, y                                  ; EAX = EAX - y
   													; max(2 * x - y, y)
	cmp 	EAX, y                                 	; compare EAX and y
	jg  	label3
													; if ( EAX < y )
	mov 	EAX, y                                  ; EAX = y
	
	label3:											
	mov 	tmp, EAX								; tmp = EAX
													; 2 * y
	mov 	EAX, y 									; EAX = y
	mov 	EBX, 2                                  ; EBX = 2
	imul 	EBX                                    	; EAX = EAX * EBX
   													; 2 * y - x
	sub 	EAX, x
   													; max(2 * y - x, x)
	cmp 	EAX, x                                  ; compare EAX and x
	jg 		label4
   													; if ( EAX < x )
	mov 	EAX, x                                  ; EAX = x
	
	label4:											; min(max(2 * x - y, y), max(2 * y - x, x))
	cmp 	tmp, EAX                                ; compare
	jg 		label5
													; if ( tmp < EAX )
	mov 	EAX, tmp								; EAX = tmp
	
	label5:											; min(...) / max(...) 
	cdq
	idiv 	max              						; EAX = EAX / max, EDX = EAX % max
	
;---------------------------------------------------------------------------------------------------
	                                                ; output of result
	push 	offset result 
	push 	EAX
	call	dwtoa
	
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
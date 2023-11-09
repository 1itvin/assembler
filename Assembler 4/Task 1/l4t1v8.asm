.486
.model flat, stdcall

option casemap: none

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
	tm 				dd 0
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
	push 	NULL
	push 	offset numberOfChars
	push 	9
	push 	offset enterX
	push 	outputHandle
	call 	WriteConsole
	
	push 	NULL
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
	
													; 2 * x
	mov 	EAX, x                                  ; EAX = x
	mov 	EBX, 2                                  ; EBX = 2
	imul 	EBX                                     ; EAX = EAX * EBX
													; 2 * x - y
	sub 	EAX, y									; EAX = EAX - y
	mov 	tmp, EAX	                            ; tmp = EAX
													; 2 * y
	mov 	EAX, y                                  ; EAX = y
	imul 	EBX	                                    ; EAX = EAX * y ( EBX = 2 )
   													; 2 * y - x
	sub 	EAX, x                                  ; EAX = EAX - x
													; max(2 * x - y, 2 * y - x)
	cmp 	EAX, tmp                                ; compare EAX and tmp
	jg 		label1
													; if ( EAX <= tmp )
	mov 	EAX, tmp                                ; EAX = tmp
	
	label1:											
	mov		max, EAX  	                            ; max = EAX 
													; x + y
	mov 	EAX, x                                  ; EAX = x
	add 	EAX, y                                  ; EAX = EAX + y 
	mov 	tmp, EAX                                ; tmp = EAX
													; x * y
	mov 	EAX, x                                  ; EAX = x
	imul 	y	                                    ; EAX = EAX * y
													; max(x + y, x * y)
	cmp 	tmp, EAX                               	; compare tmp and EAX
	jg 		label2
   													; if ( tmp <= EAX )
	mov 	tmp, EAX 
	
	label2:        									; 2 * y
	mov 	EAX, y                                  ; EAX = y
	mov 	EBX, 2                                  ; EBX = 2
	imul 	EBX                                     ; EAX = EAX * EBX 
													; 2 * y % x
	cdq
	idiv 	x                                    	; EAX = EAX / x, EDX = EAX % x
	mov		tm, EDX									; tm = EDX
													; 2 * x
	mov 	EAX, x 									; EAX = x
    mov 	EBX, 2                                  ; EBX = 2
	imul 	EBX                                     ; EAX = EAX * EBX
													; 2 * x + y
	add 	EAX, y    								; EAX = EAX + y
    												; max(2 * x + y, 2 * y % x)
    cmp 	EAX, tm                                 ; compare EAX and tm
    jg 		label3
    												; if ( EAX < tm )
    mov 	EAX, tm                                 ; EAX = tm
    
 	label3:	  										; min(max(x + y, x * y), max(2 * x + y, 2 * y % x))
 	cmp 	tmp, EAX								; compare tmp and EAX
 	jg 		label4 
 													; if ( tmp < EAX )
 	mov 	EAX, tmp                                ; EAX = tmp
 	
 	label4:											; min(...) / max(2 * x - y, 2 * y - x)
 	cdq
 	idiv 	max                                     ; EAX = EAX / max, EDX = EAX % max
 	
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
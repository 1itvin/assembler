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
	push	offset enterY
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
	
													; min(x, y)
	mov 	EAX, x                                  ; EAX = x
	cmp 	EAX, y                                  ; compare EAX and y
	jl 		label1
													; if ( EAX > y )
	mov 	EAX, y                                  ; EAX = y
	
	label1:				
    mov 	min, EAX								; min = EAX 
    												; max(x, y)
    mov 	EAX, x                                  ; EAX = x
    cmp 	EAX, y                                  ; compare EAX and y
    jg 		label2
    												; if ( EAX < y )
    mov 	EAX, y                                  ; AX = y
    
	label2:											
	mov 	max, EAX                                ; max = EAX
													; x - y
	mov 	EAX, x                                  ; EAX = x
	sub 	EAX, y									; EAX = EAX - y   
   													; |x - y|
	cmp 	EAX, 0                                	; compare EAX and 0
	jg 		label3
													; if ( EAX < 0 )
	neg 	EAX                                     ; EAX = -EAX
	
	label3:											; max(|x - y|, 10)
	cmp 	EAX, 10                                	; compare EAX and 10
	jg 		label4
													; if ( EAX < 10 )
	mov 	EAX, 10                                	; EAX = 10
	
	label4:											; min(max(|x - y|, 10), max(x, y))
	cmp 	EAX, max                                ; compare EAX and max
	jl 		label5
													; if ( EAX > max )
	mov 	EAX, max                                ; EAX = max
	
	label5:											; min(...) / min(x, y)
	mov		EBX, min                                ; EBX = min
	cdq
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX
	 
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
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
	
	mov	 	EDX, offset buffer
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EDX + EAX - 2 ], 0
	
	push 	offset buffer
	call 	atodw
	mov 	y, EAX   
	
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	push	NULL
   	push 	offset numberOfChars
	push 	8
   	push 	offset res
   	push 	outputHandle
   	call 	WriteConsole  
   	
;---------------------------------------------------------------------------------------------------
	
   													; max(y, 5)
	cmp 	y, 5									; compare y and 5
	jg 		label1
													; if ( y <= 5 )
	mov 	max, 5									; max = 5
	jmp 	label2 
	
	label1:   										; if ( y > 5 )
	mov 	EAX, y									; EAX = y
	mov 	max, EAX                                ; max = EAX
	
	label2:											; max(x, 5)
	cmp 	x, 5                                    ; compare x and 5
	jl 		label3
													; if ( x >= 5 )
	mov 	EAX, x    								; EAX = x
	jmp		label4
	
	label3:											; if ( x < 5 )
	mov 	EAX, 5                                  ; EAX = 5
	 
	label4:										 	; min(max(x, 5), max(y, 5))
	cmp 	EAX, max								; compare EAX and max
	jg 		label5
   													; if ( EAX <= max )
	mov 	min, EAX                                ; min = EAX
	jmp 	label6    
	
	label5:											; if ( EAX > max )
	mov 	EAX, max                                ; EAX = max
	mov 	min, EAX                                ; min = EAX
	
	label6:											; x % 5
	mov 	EAX, x                                  ; EAX = x
	mov 	EBX, 5                                  ; EBX = 5
	cdq
	xor 	EDX, EDX                                ; EAX = EAX / EBX, EDX = EAX % EBX
	idiv 	EBX  
											   		; min(y, x % 5)
	cmp 	y, EDX                                  ; compare y and EDX
	jg 		label7
   													; if ( y <= EDX )
	mov 	EAX, y         							; EAX = y
	mov 	tmp, EAX                                ; tmp = EAX
	jmp 	label8
	
	label7:											; if ( y > EDX )
	mov 	tmp, EDX                                ; tmp = EDX
	
	label8:											; min(x, 10)
	cmp 	x, 10                                  	; compare x and 10
	jg 		label9
   													; if ( x <= 10 )
	mov 	EAX, x                                  ; EAX = x
	jmp		label10
	
	label9:											; if ( x > 10 )
	mov 	EAX, 10	                                ; EAX = 10
   
	label10:										; max(min(x, 10), min(y, x % 5))
	cmp 	EAX, tmp                                ; compare EAX and tmp
	jg 		label11
   													; if ( EAX <= tmp )
	mov 	EAX, tmp                                ; EAX = tmp
		
	label11:	
	mov 	max, EAX                               	; max = EAX 
													; min / max
	mov 	EAX, min                                ; EAX = min
	mov		EBX, max                                ; EBX = max
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
	push	1
	push 	offset buffer
	push 	inputHandle
	call 	ReadConsole
	
	push 	0
	call 	ExitProcess  
	
;---------------------------------------------------------------------------------------------------
end main
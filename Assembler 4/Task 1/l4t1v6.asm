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
	res 	   		db "Result: "
	x 				dd 0
	y 				dd 0  
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
	mov		y, EAX    
	
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	push 	NULL
   	push 	offset numberOfChars
	push 	8
   	push 	offset res
   	push 	outputHandle
   	call 	WriteConsole   
   	
;---------------------------------------------------------------------------------------------------

   													; x % y
	mov 	EAX, x									; EAX = x 
	mov		EBX, y                                  ; EBX = y
	cdq
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX
	mov		tmp, EDX								; tmp = EDX
   													; y % x
	mov 	EAX, y                                  ; EAX = y     
	mov		EBX, x                                  ; EBX = x
	cdq
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX
													; min(x % y, y % x)
	cmp 	tmp, EDX                                ; compare tmp and EDX
	jg 		label1
													; if ( tmp < EDX )
	mov 	EAX, tmp 								; EAX = tmp
	mov 	min, EAX                                ; min = EAX
	jmp 	label2
	
	label1:											; if ( tmp > EDX )
	mov 	min, EDX                                ; min = EDX
	
	label2:											; y^4
	mov 	EAX, y                                  ; EAX = y
	imul 	EAX                                     ; EAX = EAX * EAX
	imul 	EAX	                                    ; EAX = EAX * EAX
													; min(y^4, 10)
	cmp 	EAX, 10 								; compare EAX and 10
	jg 		label3
   													; if ( EAX < 10 )
	mov 	tmp, EAX                                ; tmp = EAX
	jmp 	label4
	
	label3:											; if ( EAX > 10 )
	mov 	tmp, 10                                 ; tmp = 10
	
	label4:											; x^2
	mov 	EAX, x                                  ; EAX = x
	imul 	EAX                                     ; EAX = EAX * EAX
													; max(x^2, 10)
	cmp 	EAX, 10                                 ; compare EAX and 10
	jg 		label5
													; if ( EAX < 10 )
	mov 	EAX, 10                                 ; EAX = 10
	
	label5:											; min(max(x^2, 10), min(y^4, 10))
	cmp 	EAX, tmp                                ; compare EAX and tmp
	jl 		label6
													; if ( EAX > tmp )
	mov 	EAX, tmp                                ; EAX = tmp

	label6:											; EAX / min
	mov		EBX, min                                ; EBX = min
	cdq
	idiv 	EBX	                                    ; EAX = EAX / EBX, EDX = EAX % EBX
	
;---------------------------------------------------------------------------------------------------
                                                    ; output of result
	push	offset result
	push	EAX
	call	dwtoa
	
	push	offset result
	call	lstrlen
	
	push	NULL
	push	offset numberOfChars
	push	EAX
	push	offset result
	push	outputHandle
	call	WriteConsole

;---------------------------------------------------------------------------------------------------
	
	push NULL
	push offset numberOfChars
	push 1
	push offset buffer
	push inputHandle
	call ReadConsole
	
	push 0
	call ExitProcess
	
;---------------------------------------------------------------------------------------------------
end main
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
	sum 			dd 0
	comp 			dd 0
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
	mov		x, EAX   
	
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
	push	offset buffer
	push	inputHandle
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
	
													; |x|
	mov		EAX, x									; EAX = x
	cmp 	EAX, 0                                 	; compare EAX and 0
	jge 	label1
   													; if ( EAX < 0 )
	neg 	EAX                                     ; EAX = -EAX
	
	label1:                                     	
	mov 	tmp, EAX                                ; tmp = EAX
													; |y|
	mov 	EAX, y                                  ; EAX = y
	cmp 	EAX, 0                                  ; compare EAX and 0
	jge 	label2
													; if ( EAX < 0 )
	neg 	EAX                                     ; EAX = -EAX
	
	label2:											; max(|x|, |y|)
	cmp 	tmp, EAX                                ; tmp = EAX
	jg 		label3
   													; if ( tmp <= EAX  )
	mov 	max, EAX                                ; max = EAX
	jmp 	label4
	
	label3:			   								; if ( tmp > EAX )
	mov 	EAX, tmp                                ; EAX = tmp
	mov 	max, EAX                                ; max  = EAX
	
	label4:											; max + 1
	add 	max, 1                                  ; max = max + 1
													; x + y
	mov 	EAX, x                                  ; EAX = x
	add 	EAX, y                                  ; EAX = EAX + y
	mov 	sum, EAX                                ; sum = EAX
													; (x + y) % 10
	mov 	EBX, 10                                 ; EBX = 10
	cdq
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX
													; x * y
	mov 	EAX, x                                  ; EAX = x
	imul 	y                                       ; EAX = EAX * y
	mov 	comp, EAX                               ; comp = EAX
													; (x * y) % 10
	mov 	EBX, 10                                 ; EBX = 10
	cdq
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX
													; max((x + y) % 10, (x * y) % 10)
	cmp 	tmp, EDX                               	; compare tmp and EDX
	jg 		label5
													; if ( tmp <= EDX )
	mov 	tmp, EDX                                ; tmp = EDX
	
	label5:											; max(x + y, x * y)
	mov 	EAX, sum                               	; EAX = sum
	cmp 	EAX, comp                               ; compare EAX and comp
	jg 		label6
													; if ( EAX <= comp )
	mov 	EAX, comp                               ; EAX = comp
	
	label6:											; min(max(x + y, x * y), max((x + y) % 10, (x * y) % 10))
	cmp 	EAX, tmp                                ; compare EAX and tmp
	jl 		label7
													; if ( EAX >= tmp )
	mov 	EAX, tmp                                ; EAX = tmp
	
	label7:											; min(...) / max(...)
	cdq
	idiv 	max                                   	; EAX = EAX / max EDX = EAX % max
	
;---------------------------------------------------------------------------------------------------
	                                                ; output of result
	push 	offset result 
	push 	EAX
	call 	dwtoa
	
	push 	offset result
	call 	lstrlen
	
	push 	NULL
	push 	offset numberOfChars
	push	 EAX
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
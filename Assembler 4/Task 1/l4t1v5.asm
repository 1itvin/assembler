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
	sign			db 0

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
	
   													; y % 10
	mov 	EAX, y                                  ; EAX = y
	mov 	EBX, 10                                 ; EBX = 10
	cdq
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX
													; max(y % 10, 5)
	cmp 	EDX, 5                                  ; compare EDX and 5
	jg 		label1
													; if ( EDX < 5 )
	mov 	max, 5                                  ; max = 5
	jmp 	label2  
	
	label1:											; if ( EDX > 5 )
	mov 	max, EDX                                ; mxx = EDX
	
	label2:											; x % 10
	mov 	EAX, x                                  ; EAX = x
	mov		EBX, 10                                 ; EBX = 10
	cdq						
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX
													; max(x % 10, 5)
	cmp 	EDX, 5                                  ; compare EDX and 5
	jg 		label3
													; if ( EDX <= 5 )
	mov 	tmp, 5                                  ; tmp = 5
	jmp 	label4
	
	label3:											; if ( EDX > 5 )
	mov 	tmp, EDX                                ; tmp = EDX 
	
	label4:											; min(max(x % 10, 5), max(y % 10, 5))
	mov 	EAX, tmp								; EAX = tmp
	cmp 	max, EAX                                ; compare max and EAX
	jg 		label5
   													; if ( max <= EAX )
	mov 	EAX, max                                ; EAX = max
	
	label5:											
	mov 	min, EAX 								; min = EAX							
													; y % 4
	mov 	EAX, y                                  ; EAX = y
	mov 	EBX, 4                                  ; EBX = 4
	cdq	
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX
	
	mov 	tmp, EDX								; tmp = EDX
													; x % 4          
	mov 	EAX, x                                  ; EAX = x
	mov		EBX, 4                                  ; EBX = 4
	cdq
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX % EBX
													; min(x % 4, y % 4)
	cmp 	EDX, tmp								; compare EDX and tmp
	jg 		label6
													; if ( EDX < tmp )
	mov 	tmp, EDX
	
	label6:											; min / tmp
	mov 	EAX, min  								; EAX = min
	mov		EBX, tmp                                ; EBX = tmp
	cdq
	idiv 	EBX                                     ; EAX = EAX / EBX, EDX = EAX / EBX
	
;---------------------------------------------------------------------------------------------------
	                                                ; output of result
	push offset result
	push EAX
	call dwtoa
	
	push offset result
	call lstrlen
	
	push NULL
	push offset numberOfChars
	push EAX
	push offset result
	push outputHandle
	call WriteConsole  
	
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
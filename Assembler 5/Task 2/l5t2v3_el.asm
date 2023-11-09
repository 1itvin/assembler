.486
.model flat, stdcall

option casemap : none

include windows.inc
include kernel32.inc
include masm32.inc
include user32.inc

includelib kernel32.lib
includelib masm32.lib
includelib user32.lib

.data
	arr				db "Array: "
	sum 			db "Sum:   "
	endl			db 0ah      
	template		db "%d ", 0
	array 			dd 10 dup(0)


.data?
   	inputHandle 	dd ?
   	outputHandle 	dd ?
   	numberOfChars 	dd ?
   	buffer 			db ?
   	result			db ?

.code

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

; void initArray(int* array, int size)
initArray:
   	push 	EBP
   	mov	 	EBP, ESP
   	
    mov  	EAX, 1				                    ; EAX = 1
    mov  	EDX, 0                                  ; EDX = 0 ( change to skip fibo[0] )  
   	
	startLoopInit:
		cmp  	dword ptr [ EBP + 12 ], 0
		je 	 	endLoopInit
		
		mov  	EBX, dword ptr [ EBP + 8 ]			; EBX = offset array[i]
	   	mov  	dword ptr [ EBX ], EAX              ; array[i] = EAX
	   	
	   	mov  	ECX, EDX							; ECX = EDX ( EDX is array[i - 1] )
	   	mov  	EDX, EAX							; EDX = EAX ( EAX is array[i] )
	   	add  	EAX, ECX                            ; EAX = EAX + ECX ( EAX is array[i + 1] )
		
		add  	dword ptr [ EBP + 8 ], 4			; to next element
		dec  	dword ptr [ EBP + 12 ]
		
		jmp  	startLoopInit		
	endLoopInit:     
   	
   	pop  	EBP
ret 8                                                                                              

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

; void processArray(int* array, int size)
processArray:
	push 	EBP 
	mov  	EBP, ESP
	
	mov 	ECX, 1									; ECX = 1
	       
	startLoopProcess:
		cmp  	ECX, dword ptr [ EBP + 12 ]
		jg   	endLoopProcess
		
		mov  	EAX, ECX							; EAX = ECX
		mov  	EBX, 2                              ; EBX = 2
		xor  	EDX, EDX                            ; EDX = 0
		idiv 	EBX                                 ; EAX = EAX / EBX, EDX = EAX % EBX
		
		cmp  	EDX, 0								; comapare EDX and 0						
		jne   	continue  
													; if ( EDX == 0 )
		mov	 	EBX, dword ptr [ EBP + 8 ]			; EBX = offset array[i]
		mov 	EAX, dword ptr [ EBX ]              ; EAX = array[i]
		imul 	EAX                                 ; EAX = EAX * EAX
		mov 	dword ptr [ EBX ], EAX              ; array[i] = EAX
	         
	continue:
	
		add  	dword ptr [ EBP + 8 ], 4			; to next element
		inc 	ECX
		
		jmp  	startLoopProcess
	endLoopProcess:
	
	pop 	EBP	
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

; int findSum(int* array, int size)
findSum:
	push 	EBP
	mov  	EBP, ESP
	
	mov 	EAX, 0					                ; EAX = 0
	
	startLoopSum:
		cmp  	dword ptr [ EBP + 12 ], 0			
		je   	endLoopSum              
		
		mov  	EBX, dword ptr [ EBP + 8 ]			; EBX = offset array[i]
		
		add  	EAX, dword ptr [ EBX ]				; EAX = EAX + array[i]
		             
		add  	dword ptr [ EBP + 8 ], 4			; to next element
		dec  	dword ptr [ EBP + 12 ]
		
		jmp  	startLoopSum
	endLoopSum:
	
	pop  	EBP
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

; void arrayToStr(char* buffer, int* array, int size)
arrayToStr:
	push 	EBP
 	mov  	EBP, ESP
                   
	startLoopConvert:
    	cmp  	dword ptr [ EBP + 16 ], 0			
    	je   	endLoopConvert
    	                
    	mov  	EAX, dword ptr [ EBP + 12 ]         ; EAX = offset array[i]
    	
    	push 	dword ptr [ EAX ]
    	push 	offset template
    	push 	dword ptr [ EBP + 8 ]
    	call 	wsprintf							; form string
    	
    	add  	ESP, 12
    	
    	add  	dword ptr [ EBP + 8 ], EAX
    	add  	dword ptr [ EBP + 12 ], 4			; to next element
    	dec  	dword ptr [ EBP + 16 ]
    	
    	jmp  	startLoopConvert   
 	endLoopConvert:
      
 	pop  	EBP
ret 12

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

main:
;---------------------------------------------------------------------------------------------------
   
	push 	STD_INPUT_HANDLE
	call 	GetStdHandle
	mov  	inputHandle, EAX
	
	push 	STD_OUTPUT_HANDLE
	call 	GetStdHandle
	mov  	outputHandle, EAX
	
;---------------------------------------------------------------------------------------------------
	                                                ; initialize array
   	push 	10
   	push 	offset array
   	call 	initArray 
   	
;---------------------------------------------------------------------------------------------------
   	                                                ; write label
   	push 	NULL
   	push 	offset numberOfChars
   	push 	7
   	push 	offset arr
   	push 	outputHandle
   	call 	WriteConsole
   	
;---------------------------------------------------------------------------------------------------
	                                                ; convert array to string
	push 	10
	push 	offset array
	push 	offset result
	call 	arrayToStr
	
	push 	offset result
	call 	lstrlen
	
	push 	NULL
	push 	offset numberOfChars
	push 	EAX
	push 	offset result
	push 	outputHandle
	call 	WriteConsole
	
	push 	NULL
	push 	offset numberOfChars
	push 	1
	push 	offset endl
	push 	outputHandle
	call 	WriteConsole
	
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	push 	NULL
 	push 	offset numberOfChars
 	push 	7
 	push 	offset sum
 	push	outputHandle
 	call 	WriteConsole
 	
;---------------------------------------------------------------------------------------------------
	                                                ; find sum
	push 	10
	push 	offset array
	call 	findSum  
	
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
	                                                ; process array
   	push 	10
  	push 	offset array
  	call 	processArray
  	
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	push 	NULL
	push 	offset numberOfChars
	push 	1
	push 	offset endl
	push 	outputHandle
	call 	WriteConsole
	
	push 	NULL
   	push 	offset numberOfChars
   	push 	7
   	push 	offset arr
   	push 	outputHandle
   	call 	WriteConsole
   	
;---------------------------------------------------------------------------------------------------
	                                                ; convert array to string
	push 	10
	push 	offset array
	push 	offset result
	call 	arrayToStr
	
	push 	offset result
	call 	lstrlen
	
	push 	NULL
	push 	offset numberOfChars
	push 	EAX
	push 	offset result
	push 	outputHandle
	call 	WriteConsole
	
	push 	NULL
	push 	offset numberOfChars
	push 	1
	push 	offset endl
	push 	outputHandle
	call 	WriteConsole
	
;---------------------------------------------------------------------------------------------------
	                                                ; write label
	push 	NULL
 	push 	offset numberOfChars
 	push 	7
 	push 	offset sum
 	push 	outputHandle
 	call 	WriteConsole 
 	
;---------------------------------------------------------------------------------------------------
	                                                ; find sum
	push 	10
	push 	offset array
	call 	findSum   
	
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
	
	push 	NULL
	push 	offset numberOfChars
	push 	1
	push 	offset endl
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
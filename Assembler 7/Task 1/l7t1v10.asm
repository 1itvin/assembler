.486
.model flat, stdcall

option casemap : none

include	windows.inc
include	kernel32.inc
include masm32.inc 
include user32.inc

includelib kernel32.lib
includelib masm32.lib
includelib user32.lib

.data
	template		db "%d ", 0
	endl			db 0ah
	enterN			db "Enter n: "
	enterKey		db "Enter key: "
	enterArr		db "Enter array (sorted): ", 0ah
	result			db "Result:  "
	n				dd 0          
	key				dd 0
    array			dd 15 dup (0)
    
	
.data
	inputHandle		dd ?
	outputHandle	dd ?
	numberOfChars	dd ?
	buffer			db ?
	
.code

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------  

; void initArr(int* arr, int size)
initArr:
	push	EBP
	mov		EBP, ESP
	
	mov		ECX, 1
	           
	startLoopInit:
		cmp		ECX, dword ptr [ EBP + 12 ]
		jg		endLoopInit                         
		                     
		mov		EBX, dword ptr [ EBP + 8 ]
		mov		[ EBX ], ECX             			; array[i] = ECX						
		
		add		dword ptr [ EBP + 8 ], 4
		inc		ECX
		
	    jmp		startLoopInit
	endLoopInit:
	
	pop		EBP
ret 8

;-----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------- 

; void shift(int* array, int cur, int size)
shift:												
	push	EBP
	mov		EBP, ESP
                                            		                                   
	mov		EBX, dword ptr [ EBP + 8 ]
	mov		ECX, dword ptr [ EBP + 12 ]
	mov		EAX, dword ptr [ EBX + ECX * 4 ]        ; EAX = array[cur]
	
	inc		ECX
	
	startLoopShift:
		cmp		ECX, dword ptr [ EBP + 16 ]
		je 		endLoopShift  
		
		mov		EDX, dword ptr [ EBX + ECX * 4 ]	; EDX = array[i]	
		mov		dword ptr [ EBX + ECX * 4 - 4], EDX ; array[i - 1] = EDX
		
		inc		ECX
		
		jmp		startLoopShift
	endLoopShift:
	
	dec		ECX
	mov		dword ptr [ EBX + ECX * 4 ], EAX        ; array[size - 1] = EAX 
	
	pop		EBP
ret 12

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
     
; void printP(int* array, int cur, int n)
printP:
	push	EBP
	mov		EBP, ESP
	 
	mov		EAX, dword ptr [ EBP + 16 ]
	sub    	EAX, dword ptr [ EBP + 12 ]
	
	mov		ECX, 0
	
	startLoop:
		cmp		ECX, EAX
		je		endLoop
		                 
		mov		EBX, dword ptr [ EBP + 16]			; EBX = n
		sub		EBX, 2                              ; EBX = n - 2
		cmp		EBX, dword ptr [ EBP + 12]          ; compare EBX and cur
		jle		lecurn                              ; if ( EBX > cur )
		
		mov		EBX, dword ptr [ EBP + 12 ]         ; EBX = cur
		inc 	EBX                                 
		                                            
		push	EAX                                 ; save EAX in stack
		push	ECX                                 ; save ECX in stack
		
		push	dword ptr [ EBP + 16 ]
		push	EBX
		push	dword ptr [ EBP + 8 ]
		call	printP                				; printP(array, cur + 1, n)
		
		jmp		continue
		
		lecurn:										; if ( EBX <= cur )
		push	EAX                                 ; save EAX in stack
		push	ECX                                 ; sace ECX in stack
		
		push	dword ptr [ EBP + 16 ]
		push	dword ptr [ EBP + 8 ]
		push	offset buffer
		call	arrayToStr    						; convert array to string
		                                            ; output array
		push	offset buffer
		call	lstrlen
		
		push	NULL
		push	offset numberOfChars
		push	EAX
		push	offset buffer
		push	outputHandle
		call	WriteConsole
		                							
		push	NULL
		push	offset numberOfChars
		push	1
		push	offset endl
		push	outputHandle
		call	WriteConsole		
		
		continue:	
		push	dword ptr [ EBP + 16 ]				                    
		push	dword ptr [ EBP + 12 ]
		push	dword ptr [ EBP + 8 ]
		call	shift  								; shift(array, cur, n)
		
		pop		ECX                                 ; restore ECX value
		pop		EAX                                 ; restore EAX value
		
		inc		ECX		
		
		jmp		startLoop
	endLoop:
	
	pop		EBP
ret 12

;-----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------- 

; void arrayToStr(char* buffer, int* array, int size)
arrayToStr:
	push 	EBP
 	mov 	EBP, ESP
 	
  	startLoopConvert:
  		cmp 	dword ptr [ EBP + 16 ], 0
  		je 		endLoopConvert

		mov 	EAX, [ EBP + 12 ]                   
		         
		push 	[ EAX ]                                                      
		push 	offset template                                                      
		push 	[ EBP + 8 ]                                                    
		call 	wsprintf 
		add		ESP, 12                           
                 
		add 	[ EBP + 8 ], EAX                   
		add 	dword ptr [ EBP + 12 ], 4          
		dec 	dword ptr [ EBP + 16 ]
		    
		jmp 	startLoopConvert
	endLoopConvert:
        
	pop 	EBP
ret 12

;-----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------- 

main:
   	 
;-----------------------------------------------------------------------------------------
	
	push	STD_INPUT_HANDLE
	call 	GetStdHandle
	mov		inputHandle, EAX
	
	push	STD_OUTPUT_HANDLE
	call	GetStdHandle
	mov		outputHandle, EAX

;-----------------------------------------------------------------------------------------
                                            		; read n
   	push 	NULL
   	push 	offset numberOfChars
   	push	9
   	push	offset enterN
   	push	outputHandle
   	call	WriteConsole
   	
   	push	NULL
   	push	offset numberOfChars
   	push	15
   	push	offset buffer
   	push	inputHandle
   	call 	ReadConsole
   	
   	cmp		buffer[0], '-'
   	jne		lbl1
   	mov		buffer[0], 2d
   	lbl1:
   	
   	mov		EDX, offset buffer
   	mov		EAX, numberOfChars
   	mov		byte ptr [ EDX + EAX - 2 ], 0
   	
   	push	offset buffer
   	call	atodw
   	mov		n, EAX
	
;-----------------------------------------------------------------------------------------

	push	n
	push	offset array
	call	initArr

	push	n 
	push 	0
	push	offset array
	call	printP          						; printP(0, n)                                                                                    

;-----------------------------------------------------------------------------------------	   	

	push	NULL
	push 	offset numberOfChars
	push 	1
	push	offset buffer
	push	inputHandle
	call	ReadConsole
	
	push	0
	call	ExitProcess
	
;-----------------------------------------------------------------------------------------
	   	
end main
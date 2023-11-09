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

; structure declaration
list struct
	 hours			dd 0
	 minutes		dd 0
	 temperature	dq 0
list ends

.data
	template		db "Time: %d:%d, temperature: %s;", 0ah, 0
	enterN			db "Enter n: ", 0
	enterArrElem	db "Enter array element (h, m, t):", 0ah, 0
	try				db "Invalid input. Try again.", 0ah, 0
	byTime			db 0ah, "Sorted by time:", 0ah, 0
	byTemperature	db 0ah, "Sorted by temperature", 0ah, 0
	n				dd 0
	array			list 100 dup ( <> )

.data?
	inputHandle     dd ?
	outputHandle	dd ?
	numberOfChars	dd ?
	buffer			db 3000 dup (?)
	tmp				db 100 dup (?)

.code                                                                                               
;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

; void readList(list* array, int size)
readList:
	push	EBP
	mov		EBP, ESP
	           
	startLoopRead:
		cmp		dword ptr [ EBP + 12 ], 0
		je 		endLoopRead
		
		finit
		
        ;-------------------------------------------------------------------------------------------
        
        jmp		startRead
                                                                                                   
        retry:
        
        push	NULL
        push	offset numberOfChars
        push	26
        push	offset try
        push	outputHandle
        call	WriteConsole
        
        ;-------------------------------------------------------------------------------------------
        
        startRead:
		
		push	offset enterArrElem  
		call	lstrlen
		
		push	NULL
		push	offset numberOfChars
		push	EAX
		push	offset enterArrElem
		push	outputHandle
		call	WriteConsole
		
		;-------------------------------------------------------------------------------------------
		
		mov		EBX, dword ptr [ EBP + 8 ]			; EBX  = offset array		
		
		;-------------------------------------------------------------------------------------------
													; read list[i].hours
		push	NULL
		push	offset numberOfChars
		push	15
		push	offset buffer
		push	inputHandle
		call	ReadConsole
		
		cmp		buffer[0], '-'
		jne		lblhours
		mov		buffer[0], 2d
		lblhours:
		
		mov		EDX, offset buffer
		mov		EAX, numberOfChars
		mov		byte ptr [ EDX + EAX - 2], 0
		
		push	offset buffer
		call	atodw
		mov		dword ptr [ EBX ], EAX
		
		;-------------------------------------------------------------------------------------------
													; data verification                                                                                            
		cmp		dword ptr [ EBX ], 0
		jl		retry
		cmp		dword ptr [ EBX ], 24
		jge		retry
		
		;-------------------------------------------------------------------------------------------
													; read list[i].minutes
		push	NULL
		push	offset numberOfChars
		push	15
		push	offset buffer
		push	inputHandle
		call	ReadConsole
								
		cmp		buffer[0], '-'
		jne		lblminutes
		mov		buffer[0], 2d
		lblminutes:
		
		mov		EDX, offset buffer
		mov		EAX, numberOfChars
		mov		byte ptr [ EDX + EAX - 2], 0
		
		push	offset buffer
		call	atodw
		mov		dword ptr [ EBX + 4 ], EAX
		
		;-------------------------------------------------------------------------------------------
													; data verification                                                                                            
		cmp		dword ptr [ EBX + 4 ], 0
		jl		retry
		cmp		dword ptr [ EBX + 4 ], 60
		jge		retry
		
		;-------------------------------------------------------------------------------------------
													; read list[i].temperature
		push	NULL
		push	offset numberOfChars
		push	15
		push	offset buffer
		push	inputHandle
		call	ReadConsole
		
		mov		EDX, offset buffer
		mov		EAX, numberOfChars
		mov		byte ptr [ EDX + EAX - 2 ], 0
		
		add		EBX, 8
		
		push	EBX
		push	offset buffer
		call	StrToFloat 
		
		;-------------------------------------------------------------------------------------------
		
		mov		EBX, dword ptr [ EBP + 8 ]			; EBX = offset array
		                                                                                            
		finit                                       ; clear ST
		fldz                                        ; ST(0) = 0
		fld		qword ptr [ EBX + 8 ]               ; ST(0) -> ST(1), ST(0) = list[i].temperature
		fcom	ST(1)								; compare ST(0) and ST(1)
		fstsw	AX                                  ; save FPU flags in AX
		sahf                                        ; set CPU flags from AX
		jbe		retry
		
		;-------------------------------------------------------------------------------------------
		
		add		dword ptr [ EBP + 8 ], 16			; to next element
		dec 	dword ptr [ EBP + 12 ]                                  
		
		;-------------------------------------------------------------------------------------------
		
		jmp		startLoopRead
	endLoopRead:
	
	pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

; int listCompareByTime(list* first, list* second)
listCompareByTime:
	push	EBP
	mov		EBP, ESP     
               
	mov		EAX, dword ptr [ EBP + 8 ]				; EAX = offset first
	mov		EBX, dword ptr [ EBP + 12 ]             ; EBX  = offset second
	
	mov		EDX, dword ptr [ EAX ]                 	; EDX = first.hours
	cmp		EDX, dword ptr [ EBX ]                  ; compare EDX and second.hours
	jg		gcbt
	jl		lcbt
	
	mov		EDX, dword ptr [ EAX + 4 ]            	; EDX = first.minutes
	cmp		EDX, dword ptr [ EBX + 4 ]              ; compare edX and second.minutes
	jg		gcbt
	jl		lcbt
	                                               	; if ( first == second )
	mov		EAX, 0                                  ; return 0
	jmp		returnCBT
	
	gcbt:                                      		; if ( first > second )
	mov		EAX, 1                                  ; return 1
	jmp		returnCBT
	
	lcbt:                                      		; if ( first < second )
	mov		EAX, -1                                 ; return -1
	
	returnCBT:
	
    pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

; int listCompareByTemperature(list* first, list* second)
listCompareByTemperature:
	push	EBP
	mov		EBP, ESP
	                                            	
	finit											; clear ST	
	           
	mov		EAX, dword ptr [ EBP + 8 ]              ; EAX = offset first
	fld		qword ptr [ EAX + 8 ]	                ; ST(0) = first.temperature
	mov		EAX, dword ptr [ EBP + 12 ]            	; EAX = offset second 
	fcomp	qword ptr [ EAX + 8 ]                  	; compare ST(0) and second.temperature
	fstsw	AX                                      ; save FPU flags in AX
	sahf                                            ; set CPU flags from AX
	ja		acbte
	jb		bcbte
													; if ( first == second )
	mov		EAX, 0                                  ; return 0
	jmp		returnCBTe
	
	acbte: 											; if ( first > second )
	mov		EAX, 1                                 	; return 1
	jmp		returnCBTe
	
	bcbte:  										; if ( first < second )
	mov		EAX, -1                                 ; return -1
	
	returnCBTe:
		
	pop		EBP
ret 8 

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------
                                                                                              
; void swap(list* first, list* second)
swap:
	push	EBP
	mov		EBP, ESP
	           
	mov		EBX, dword ptr [ EBP + 8 ]				; EBX = offset first
	mov		EDX, dword ptr [ EBP + 12 ]             ; ECX = offset second
	
	mov		EAX, dword ptr [ EBX ]                  ; EAX = first.hours
	mov		ECX, dword ptr [ EDX ]                  ; ECX = second.hours
	mov		dword ptr [ EDX ], EAX                  ; second.hours = EAX
	mov		dword ptr [ EBX ], ECX                  ; first.hours = ECX    
	
	mov		EAX, dword ptr [ EBX + 4 ]				; EAX = first.minutes
	mov		ECX, dword ptr [ EDX + 4 ]              ; ECX = seccond.minutes
	mov		dword ptr [ EDX + 4 ], EAX              ; second.minutes = EAX
	mov		dword ptr [ EBX + 4 ], ECX              ; first.minutes = ECX
	
	finit 											; cleaeer ST
	fld		qword ptr [ EBX + 8 ]                   ; ST(0) = first.temperature
	fld		qword ptr [ EDX + 8 ]                   ; ST(0) -> ST(1), ST(0) = second.temperature
	fstp	qword ptr [ EBX + 8 ]                   ; first.temperature = ST(0), ST(1) -> ST(0)
	fstp	qword ptr [ EDX + 8 ]                   ; second.temperature = ST(0)
	
	pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------- 
                                                                                                    
; void	bubbleSort(list* array, int size, *)
bubbleSort:
	push	EBP
	mov		EBP, ESP
	              
	sub		ESP, 4									; reserve memory for local variable
	           
    mov		ECX, 1
    
    startLoopSort1:
       	cmp		ECX, dword ptr [ EBP + 12 ]			; for ( ECX = 1; ECX < size; ECX++ )
        je		endLoopSort1
       	
       	mov		EAX, dword ptr [ EBP + 12 ]			; EAX = size
       	sub		EAX, ECX                            ; EAX = EAX - ECX
       	mov		dword ptr [ EBP - 4 ], EAX 			; localVarible = EAX		
       	
       	push	ECX									; save ECX value in stack
    	mov		ECX, 0
    		 		             
    	startLoopSort2:
    		cmp		ECX, dword ptr [ EBP - 4 ]		; for ( ECX = 0; ECX < ( size - prev ECX ); ECX++ )
    		je 		endLoopSort2
    		           
    		push	ECX								; save ECX value in stack
    		
    		mov		EBX, dword ptr [ EBP + 8 ]		; EBX = offset array
    		
    		mov		EAX, 16							; EAX = 16
    		mul		ECX                             ; EAX = 16 * ECX ( element offset )
    		
    		add		EBX, EAX						; EBX = EBX + EAX ( array[ ECX ] )
    		push	EBX						
    		add		EBX, 16							; EBX = EBX + EAX + 16 ( array[ ECX + 1 ] )
    		push	EBX
    		call	dword ptr [ EBP + 16 ]			; call compare function
    		
    		pop		ECX								; restore ECX value
    	
    		cmp		EAX, 0							; compare return value and 0
    		jge		continueSort
    												; if ( array[ ECX ] > array[ ECX + 1 ] ) 
    		push	ECX								; save ECX value in stack
    		
    		mov		EBX, dword ptr [ EBP + 8 ]		; EBX = offset array
    		
    		mov		EAX, 16							; EAX = 16                     
    		mul		ECX								; EAX = 16 * ECX ( element offset )
    		
       		add		EBX, EAX						; EBX = EBX + EAX ( array[ ECX ] )						
    		push	EBX
    		add		EBX, 16							; EBX = EBX + EAX + 16 ( array[ ECX + 1 ] )
    		push	EBX
    		call	swap							; swap(array[ ECX + 1 ], array[ ECX ]) 
    		
    		pop		ECX								; restore ECX value
    		
    		continueSort:
    		
    		inc		ECX
    		
    		jmp		startLoopSort2
    	endLoopSort2:
        
        pop		ECX									; restore ECX value from stack
        inc		ECX
        
    	jmp		startLoopSort1
    endLoopSort1:
    
    add		ESP, 4									; clear memory
	
	pop		EBP
ret	12

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

; void listToStr(char* buffer, list* array, int size)
listToStr:
	push	EBP
	mov		EBP, ESP           

	startLoopConvert:		
		cmp		dword ptr [ EBP + 16 ], 0
		je		endLoopConvert 
		                        
	 	mov		EAX, dword ptr [ EBP + 12 ]			; EAX = offset array
		
		push	offset tmp
		push	dword ptr [ EAX + 12 ]
		push	dword ptr [ EAX + 8 ]
		call	FloatToStr							; convert array[i].temperature to string
		
	 	mov		EAX, dword ptr [ EBP + 12 ]			; EAX = offset array	 
		
	   	push	offset tmp
		push	dword ptr [ EAX + 4 ]
		push	dword ptr [ EAX ]
		push	offset template
		push	dword ptr [ EBP + 8 ]
		call	wsprintf							; form output string
			
		add		ESP, 20
		
		add		[ EBP + 8 ], EAX
		add		dword ptr [ EBP + 12 ], 16			; to next element
		dec		dword ptr [ EBP + 16 ]
		
		jmp		startLoopConvert 
	endLoopConvert:
	
	pop		EBP	
ret 16

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

main:
;--------------------------------------------------------------------------------------------------- 
                                                                                                    
	push	STD_INPUT_HANDLE
	call	GetStdHandle
	mov		inputHandle, EAX
	
	push	STD_OUTPUT_HANDLE
	call	GetStdHandle
	mov		outputHandle,EAX

;--------------------------------------------------------------------------------------------------- 
    												; read n
    tryN:												
                                                                                                     
	push	NULL
	push	offset numberOfChars
	push	9
	push	offset enterN
	push 	outputHandle
	call	WriteConsole
	
	push	NULL
	push	offset numberOfChars
	push	15
	push	offset buffer
	push	inputHandle
	call	ReadConsole
	
	cmp		buffer[0], '-'
	jne		lbln
	mov		buffer[0], 2d
	lbln:
	
	mov		EDX, offset buffer
	mov		EAX, numberOfChars
	mov		byte ptr [ EDX + EAX - 2 ], 0
	
	push	offset buffer
	call	atodw
	mov		n, EAX
	
	cmp		n, 0
	jle		tryN

;--------------------------------------------------------------------------------------------------- 
                                                                                                   
	push	n
	push	offset array
	call	readList								; readList(array, n)                                                                                
	
;---------------------------------------------------------------------------------------------------
                									; write label
	push	NULL
	push	offset numberOfChars
	push	23
	push	offset byTemperature
	push	outputHandle
	call	WriteConsole

;---------------------------------------------------------------------------------------------------
                                                                                                  
	push	listCompareByTemperature
	push	n
	push	offset array
	call	bubbleSort 								; bubbleSort(array, n, listCompareByTemperature)

;---------------------------------------------------------------------------------------------------
                                                                                                    
	push	n
	push	offset array
	push	offset buffer
	call	listToStr 								; convert array to string
	
	push	offset buffer
	call	lstrlen
	
	push	NULL
	push	offset numberOfChars
	push	EAX
	push	offset buffer
	push	outputHandle
	call	WriteConsole  
     		
;---------------------------------------------------------------------------------------------------
   													; write label
	push	NULL
	push	offset numberOfChars
	push	17
	push	offset byTime
	push	outputHandle
	call	WriteConsole

;---------------------------------------------------------------------------------------------------
                                                                                                 
	push	listCompareByTime
	push	n
	push	offset array
	call	bubbleSort           			   		; bubbleSort(array, n, listCompareByTime)

;---------------------------------------------------------------------------------------------------
                                                                                                    
	push	n
	push	offset array
	push	offset buffer
	call	listToStr 								; convert array to string
	
	push	offset buffer
	call	lstrlen
	
	push	NULL
	push	offset numberOfChars
	push	EAX
	push	offset buffer
	push	outputHandle
	call	WriteConsole
	
;---------------------------------------------------------------------------------------------------
	
	push	NULL
	push	offset numberOfChars
	push	1
	push	offset buffer
	push	inputHandle
	call	ReadConsole
	
	push	0
	call	ExitProcess
		
;---------------------------------------------------------------------------------------------------
end main 
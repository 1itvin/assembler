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
	 ip   			dd 4 dup (0)
	 frequency		dq 0 
list ends

.data
	template		db "IP: %d.%d.%d.%d, frequency: %s;", 0ah, 0
	enterN			db "Enter n: ", 0
	enterArrElem	db "Enter array element (ip(x.x.x.x), f):", 0ah, 0
	try				db "Invalid input. Try again.", 0ah, 0
	byIP			db 0ah, "Sorted by ip:", 0ah, 0
	byFrequency		db 0ah, "Sorted by frequency:", 0ah, 0
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
	
	sub		ESP, 4				                    ; reserve memory in stack for local variable
	           
	startLoopRead:
		cmp		dword ptr [ EBP + 12 ], 0
		je 		endLoopRead
		
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
		
		mov		EBX, dword ptr [ EBP + 8 ]			; EBX = offset array
		
		;-------------------------------------------------------------------------------------------
													; read ip string
		push	NULL
		push	offset numberOfChars
		push	15
		push	offset buffer
		push	inputHandle
		call	ReadConsole
		
		cmp		buffer[0], '-'
		je		retry
		
		mov		EDX, offset buffer
		mov		EAX, numberOfChars
		mov		byte ptr [ EDX + EAX - 2], 0
		
		;-------------------------------------------------------------------------------------------
		
		push	offset buffer
		call	lstrlen
													; check string length
		cmp		EAX, 7
		jl		retry
		cmp		EAX, 16
		jg		retry
		 
		mov		ECX, 0							 
		mov		EBX, offset buffer
		mov		EDX, dword ptr [ EBP + 8 ]			; EDX = offset array
		
		mov		dword ptr [ EBP - 4 ], 0   			; dotCounter = 0
		
		startLoopParse:
			cmp		byte ptr [ EBX + ECX ], 0		; end of string
			je		endLoopParse
			cmp		byte ptr [ EBX + ECX ], '.'		; buffer[i] == '.'
			jne		continueParse
			             
			push	EDX								; save EDX value in stack 
			push 	ECX    							; save ECX value in stack
			
			push	EBX					
			call	lstrlen 						; find current length of string
			
			mov		ECX, EAX 						; ECX = current length
			mov		ESI, EBX 						; ESI = current string
			mov		EDI, offset tmp                 ; EDI = temporary string
			rep		movsb                           ; copy from current string to temporary string 
			
			pop		ECX 							; restore ECX value from string           
			
			add		EBX, ECX						; move pointer 
			inc		EBX                             ; move pointer
			
			mov		EAX, offset tmp					
			mov		byte ptr [ EAX + ECX ], 0       ; delete needless string content
			
			push	offset tmp
			call	atodw          					; convert temporary string to integer
			
			pop 	EDX								; restore EDX value
													; data verification
			cmp		EAX, 0
			jl		retry
			cmp		EAX, 255
			jg		retry 
			
			mov		dword ptr [ EDX ], EAX			; list[i].ip[j] = EAX
			
			add		EDX, 4							; to next ip element
			inc		dword ptr [ EBP - 4 ]			; increase dotCounter
			
			mov		ECX, 0							
			
			jmp		startLoopParse
			
			continueParse:
			
			inc		ECX
			
			jmp		startLoopParse
		endLoopParse:
		
		push	EBX
		call	atodw 								; convert end of ip string to integer
													; data verification
		cmp		EAX, 0
		jl		retry
		cmp		EAX, 255
		jg		retry 
		
		cmp		dword ptr [ EBP - 4 ], 3 			; check dotCounter
		jne 	retry 
		
		mov		EDX, dword ptr [ EBP + 8 ]		
		mov		dword ptr [ EDX + 12 ], EAX			; list[i].ip[3] = EAX
	
		;-------------------------------------------------------------------------------------------
													; read list[i].frequency
		push	NULL
		push	offset numberOfChars
		push	15
		push	offset buffer
		push	inputHandle
		call	ReadConsole
		
		mov		EDX, offset buffer
		mov		EAX, numberOfChars
		mov		byte ptr [ EDX + EAX - 2 ], 0
		
		mov		EBX, dword ptr [ EBP + 8 ]
		add		EBX, 16
		
		push	EBX
		push	offset buffer
		call	StrToFloat 
		
		;-------------------------------------------------------------------------------------------
													; data verification				
		mov		EBX, dword ptr [ EBP + 8 ]          ; EBX = offset array
		                                                                                            
		finit										; clear ST
		fldz 										; ST(0) = 0
		fld		qword ptr [ EBX + 16 ]              ; ST(0) -> ST(1), ST(0) = list[i].frequency
		fcom	ST(1)								; compare ST(0) and ST(1)
		fstsw	AX                                  ; save FPU flags in AX
		sahf                                        ; set CPU flags from AX
		jbe		retry
		
		;-------------------------------------------------------------------------------------------
		
		add		dword ptr [ EBP + 8 ], 24			; to next element
		dec 	dword ptr [ EBP + 12 ]                                  
		
		;-------------------------------------------------------------------------------------------
		
		jmp		startLoopRead
	endLoopRead:
	
	add		ESP, 4									; clear memory
	
	pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

; int listCompareByIP(list* first, list* second)
listCompareByIP:
	push	EBP
	mov		EBP, ESP
	
	mov		ECX, 0								
	
	mov		EAX, dword ptr [ EBP + 8 ]				; EAX = offset first
	mov		EBX, dword ptr [ EBP + 12 ]             ; EBX = offset second
	
	startLoopCompare:
		cmp		ECX, 4                
	    je 		endLoopCompare
	                            
	    mov		EDX, dword ptr [ EAX + ECX * 4 ]	; EDX = first.ip[i]
	    cmp		EDX, dword ptr [ EBX + ECX * 4 ]    ; compare EDX and second.ip[i]
	    jg		gcbip
   		jl		lcbip
	    
	    inc		ECX
	    
	    jmp		startLoopCompare
	endLoopCompare:     
													; if ( first == second )
	mov		EAX, 0  								; return 0
	jmp		returnCBIP
	
	gcbip:											; if ( first > second )
	mov		EAX, 1                                  ; return 1
	jmp		returnCBIP
	
	lcbip:      									; if ( first < second )
	mov		EAX, -1                                 ; return -1
	
	returnCBIP:
	
    pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------
                                                                                                    
; int listCompareByFrequency(list* first, list* second)
listCompareByFrequency:
	push	EBP
	mov		EBP, ESP
	           
	mov		EAX, dword ptr [ EBP + 8 ]	   			; EAX = offset first
	mov		EBX, dword ptr [ EBP + 12 ]             ; EBX = ofsfet second
	
	finit                      						; clear ST
    fld		qword ptr [ EAX + 16 ]                  ; ST(0) = first.frequency
    fcom	qword ptr [ EBX + 16 ]					; compare ST(0) and second.frequency
	fstsw	AX  									; save FPU flags in AX
	sahf                     						; set CPU flags from AX
	ja		acbf
	jb		bcbf
													; if ( first == second )
	mov		EAX, 0   								; return 0
	jmp		returnCBF
	
	acbf:     										; if ( first > second )
	mov		EAX, 1                              	; return 1
	jmp		returnCBF
	
	bcbf:  	   										; if ( first < second )								
	mov		EAX, -1                                 ; return -1
	
	returnCBF:
		
	pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------
                                                                                              
; void swap(list* first, list* second)
swap:
	push	EBP
	mov		EBP, ESP
	           
	mov		EBX, dword ptr [ EBP + 8 ] 				; EBX = offset first
	mov		EDX, dword ptr [ EBP + 12 ]             ; EDX = offset second
	
	mov		EAX, dword ptr [ EBX ]					; EAX = first.ip[0]
	mov		ECX, dword ptr [ EDX ]                  ; ECX = second.ip[0]
	mov		dword ptr [ EDX ], EAX                  ; second.ip[0] = EAX
	mov		dword ptr [ EBX ], ECX                  ; first.ip[0] = ECX
	
	mov		EAX, dword ptr [ EBX + 4 ]				; EAX = first.ip[1]
	mov		ECX, dword ptr [ EDX + 4 ]              ; ECX = second.ip[1]
	mov		dword ptr [ EDX + 4 ], EAX              ; second.ip[1] = EAX
	mov		dword ptr [ EBX + 4 ], ECX              ; first.ip[1] = ECX
	
	mov		EAX, dword ptr [ EBX + 8 ]				; EAX = first.ip[2]
	mov		ECX, dword ptr [ EDX + 8 ]             	; ECX = second.ip[2]
	mov		dword ptr [ EDX + 8 ], EAX              ; second.ip[2] = EAX
	mov		dword ptr [ EBX + 8 ], ECX              ; first.ip[2] = ECX
	
	mov		EAX, dword ptr [ EBX + 12 ]				; EAX = first.ip[3]
	mov		ECX, dword ptr [ EDX + 12 ]             ; ECX = second.ip[3]
	mov		dword ptr [ EDX + 12 ], EAX             ; second.ip[3] = EAX
	mov		dword ptr [ EBX + 12 ], ECX             ; first.ip[3] = ECX       
	
	finit                   						; clear ST
	fld		qword ptr [ EBX + 16 ]                  ; ST(0) = first.frequency
	fld		qword ptr [ EDX + 16 ]                  ; ST(0) -> ST(1), ST(0) = second.frequency
	fstp	qword ptr [ EBX + 16 ]                 	; first.frequency = ST(0), ST(1) -> ST(0)
	fstp	qword ptr [ EDX + 16 ]                  ; second.frequency = ST(0)
	
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
    		
    		mov		EAX, 24							; EAX = 24
    		mul		ECX                             ; EAX = 24 * ECX ( element offset )
    		
    		add		EBX, EAX						; EBX = EBX + EAX ( array[ ECX ] )
    		push	EBX						
    		add		EBX, 24							; EBX = EBX + EAX + 24 ( array[ ECX + 1 ] )
    		push	EBX
    		call	dword ptr [ EBP + 16 ]			; call compare function
    		
    		pop		ECX								; restore ECX value
    	
    		cmp		EAX, 0							; compare return value and 0
    		jge		continueSort
    												; if ( array[ ECX ] > array[ ECX + 1 ] ) 
    		push	ECX								; save ECX value in stack
    		
    		mov		EBX, dword ptr [ EBP + 8 ]		; EBX = offset array
    		
    		mov		EAX, 24							; EAX = 24                     
    		mul		ECX								; EAX = 24 * ECX ( element offset )
    		
       		add		EBX, EAX						; EBX = EBX + EAX ( array[ ECX ] )						
    		push	EBX
    		add		EBX, 24							; EBX = EBX + EAX + 24 ( array[ ECX + 1 ] )
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
		                        
	 	mov		EAX, dword ptr [ EBP + 12 ]  		; EAX = offset array
	 
		push	offset tmp
		push	dword ptr [ EAX + 20 ]
		push	dword ptr [ EAX + 16 ]
		call	FloatToStr            				; convert array[i].frequency to string
		
	 	mov		EAX, dword ptr [ EBP + 12 ]			; EAX = offset array	 
		
	   	push	offset tmp           
	   	push	dword ptr [ EAX + 12 ]
	   	push	dword ptr [ EAX + 8 ]
	   	push	dword ptr [ EAX + 4 ]
		push	dword ptr [ EAX ]
		push	offset template
		push	dword ptr [ EBP + 8 ]
		call	wsprintf    						; form output string
			
		add		ESP, 28
		
		add		[ EBP + 8 ], EAX
		add		dword ptr [ EBP + 12 ], 24			; to next element
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
	call	readList  								; readList(array, n)                                                                              
	
;---------------------------------------------------------------------------------------------------
   													; write label
	push	NULL
	push	offset numberOfChars
	push	15
	push	offset byIP
	push	outputHandle
	call	WriteConsole

;---------------------------------------------------------------------------------------------------
                                                                                                   
	push	listCompareByIP
	push	n
	push	offset array
	call	bubbleSort								; bubbleSort(array, n, listCompareByIP)

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
	push	22
	push	offset byFrequency
	push	outputHandle
	call	WriteConsole

;---------------------------------------------------------------------------------------------------
                                                                                                
	push	listCompareByFrequency
	push	n
	push	offset array
	call	bubbleSort           			   		; bubbleSort(array, n, listCompareByFrequency)
                             		
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
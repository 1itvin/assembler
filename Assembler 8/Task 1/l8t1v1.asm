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
	day				dd 0
	month			dd 0
	year			dd 0
	weight			dq 0
list ends

.data
	template		db "Day: %d, month: %d, year: %d, weight: %s;", 0ah, 0
	enterN			db "Enter n: ", 0
	enterArrElem	db "Enter array element (d, m, y, w):", 0ah, 0
	try				db "Invalid input. Try again.", 0ah, 0
	byDate			db 0ah, "Sorted by date:", 0ah, 0
	byWeight		db 0ah, "Sorted by weight:", 0ah, 0
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
		                                            ; read list[i].day
		push	NULL
		push	offset numberOfChars
		push	15
		push	offset buffer
		push	inputHandle
		call	ReadConsole
		
		cmp		buffer[0], '-'
		jne		lblday
		mov		buffer[0], 2d
		lblday:
		
		mov		EDX, offset buffer
		mov		EAX, numberOfChars
		mov		byte ptr [ EDX + EAX - 2], 0
		
		push	offset buffer
		call	atodw
		mov		dword ptr [ EBX ], EAX
		
		;-------------------------------------------------------------------------------------------
		                                          	; data verification                                                   
		cmp		dword ptr [ EBX ], 0
		jle		retry
		cmp		dword ptr [ EBX ], 32
		jge		retry
		
		;-------------------------------------------------------------------------------------------
		                                           	; read list[i].month
		push	NULL
		push	offset numberOfChars
		push	15
		push	offset buffer
		push	inputHandle
		call	ReadConsole
		
		cmp		buffer[0], '-'
		jne		lblmonth
		mov		buffer[0], 2d
		lblmonth:
		
		mov		EDX, offset buffer
		mov		EAX, numberOfChars
		mov		byte ptr [ EDX + EAX - 2], 0
		
		push	offset buffer
		call	atodw
		mov		dword ptr [ EBX + 4 ], EAX
		
		;-------------------------------------------------------------------------------------------
		                                           	; data verification                                               
		cmp		dword ptr [ EBX + 4 ], 0
		jle		retry
		cmp		dword ptr [ EBX + 4 ], 13
		jge		retry
		
		;-------------------------------------------------------------------------------------------
		                                          	; read list[i].year
		push	NULL
		push	offset numberOfChars
		push	15
		push	offset buffer
		push	inputHandle
		call	ReadConsole
		
		cmp		buffer[0], '-'
		jne		lblyear
		mov		buffer[0], 2d
		lblyear:
		
		mov		EDX, offset buffer
		mov		EAX, numberOfChars
		mov		byte ptr [ EDX + EAX - 2], 0
		
		push	offset buffer
		call	atodw
		mov		dword ptr [ EBX + 8 ], EAX 
		
		;-------------------------------------------------------------------------------------------
		                                       		; data verification
		cmp		dword ptr [ EBX + 8 ], 0
		jl		retry   
		
		;-------------------------------------------------------------------------------------------
		                                        	; read list[i].weight
		push	NULL
		push	offset numberOfChars
		push	15
		push	offset buffer
		push	inputHandle
		call	ReadConsole
		
		mov		EDX, offset buffer
		mov		EAX, numberOfChars
		mov		byte ptr [ EDX + EAX - 2 ], 0
		
		add		EBX, 12
		
		push	EBX
		push	offset buffer
		call	StrToFloat 
		
		;-------------------------------------------------------------------------------------------
		                                   			; data verification
		mov		EBX, dword ptr [ EBP + 8 ]          ; EBX = offset array
		                                                                                            
		finit		  								; clear ST								
		fldz                                        ; ST(0) = 0
		fld		qword ptr [ EBX + 12 ]              ; ST(0) -> ST(1), ST(0) = list[i].weight
		fcom	ST(1)                               ; compare ST(0) and ST(1)
		fstsw	AX                                  ; save FPU flags in AX
		sahf                                        ; set CPU flags from AX
		jbe		retry
		
		;-------------------------------------------------------------------------------------------
		
		add		dword ptr [ EBP + 8 ], 20			; to next element
		dec 	dword ptr [ EBP + 12 ]                                  
		
		;-------------------------------------------------------------------------------------------
		
		jmp		startLoopRead
	endLoopRead:
	
	pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

; int listCompareByDate(list* first, list* second)
listCompareByDate:
	push	EBP
	mov		EBP, ESP     
                           							; EAX = offset first
	mov		EAX, dword ptr [ EBP + 8 ]             	; EBX = offset second
	mov		EBX, dword ptr [ EBP + 12 ]
	
	mov		EDX, dword ptr [ EAX + 8 ]  			; EDX = first.year
	cmp		EDX, dword ptr [ EBX + 8 ]              ; compare EDX and second.year
	jg		gcbd
	jl		lcbd
	
	mov		EDX, dword ptr [ EAX + 4 ]              ; EDX = first.month
	cmp		EDX, dword ptr [ EBX + 4 ]              ; compare EDX and second.month
	jg		gcbd
	jl		lcbd
	
	mov		EDX, dword ptr [ EAX ]               	; EDX = first.day
	cmp		EDX, dword ptr [ EBX ]                  ; compare EDX and second.day
	jg		gcbd
	jl		lcbd
	                                          		; if ( first == second )
	mov		EAX, 0                                  ; return 0
	jmp		returnCBD
	
	gcbd:          									; if ( first  > second )
	mov		EAX, 1                                  ; return 1
	jmp		returnCBD
	
	lcbd:      										; if ( first < second )
	mov		EAX, -1                                 ; return -1    
	
	returnCBD:
	
    pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

; int listCompareByWeight(list* first, list* second)
listCompareByWeight:
	push	EBP
	mov		EBP, ESP
	
	finit											; clear ST
	           
	mov		EAX, dword ptr [ EBP + 8 ]              ; EAX = offset first
	fld		qword ptr [ EAX + 12 ]	                ; ST(0) = first.weight
	mov		EAX, dword ptr [ EBP + 12 ]             ; EAX = offset second
	fcomp	qword ptr [ EAX + 12 ]                  ; compare ST(0) and second.weight
	fstsw	AX                                      ; save FPU flags in AX
	sahf                                            ; set CPU flags from AX
	ja		acbw
	jb		bcbw
	            									; if ( first == second )
	mov		EAX, 0                                  ; return 0
	jmp		returnCBW
	
	acbw:   										; if ( first > second )
	mov		EAX, 1                                  ; return 1
	jmp		returnCBW
	
	bcbw:                                       	; if ( first < second )
	mov		EAX, -1                                 ; return -1
	
	returnCBW:
		
	pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------
                                                                                                    
; list* findMin(list* arr, int size, *)
findMin:
	push	EBP
	mov		EBP, ESP
	           
	mov		EBX, dword ptr [ EBP + 8 ]				; EBX = offset arr
	
	mov		ESI, EBX								; ESI = offset arr[0]
	
	startLoopFindMin:
		cmp		dword ptr [ EBP + 12 ], 0
		je		endLoopFindMin

		push	EBX                                 ; save EBX value in stack
		                        
		push	ESI
		push	EBX
		call	dword ptr [ EBP + 16 ] 				; call function *(arr[i], min)
		
		pop		EBX                                 ; restore EBX value from stack

		cmp		EAX, 0                              ; compare return value and 0 
		jnl		continueFindMin
		                                            ; if ( EAX >= 0 )
		mov		ESI, EBX 							; ESI = offset arr[i]
		
		continueFindMin:
		add	 	EBX, 20								; to next element
		dec		dword ptr [ EBP  + 12 ]
		
		jmp		startLoopFindMin
	endLoopFindMin:
	
	mov		EAX, ESI								; return ESI
	
	pop		EBP
ret 12
             
;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------
                                                                                                    
; list* findMax(list* arr, int size, *)
findMax:
	push	EBP
	mov		EBP, ESP
	           
	mov		EBX, dword ptr [ EBP + 8 ]				; EBX = offset arr
	
	mov		ESI, EBX                               	; ESI = offset arr[0]
	
	startLoopFindMax:
		cmp		dword ptr [ EBP  + 12 ], 0
		je		endLoopFindMin
							
		push	EBX                                 ; save EBX value in stack
		                        
		push	ESI
		push	EBX
		call	dword ptr [ EBP + 16 ] 				; call function *(arr[i], max)
		
		pop		EBX                 				; restore EBX value from stack
		
		cmp		EAX, 0                              ; compare return value and 0
		jng		continueFindMax
		                                            ; if ( EAX <= 0 )
		mov		ESI, EBX                            ; ESI = offset arr[i]
		
		continueFindMax:
		add	 	EBX, 20								; to next element
		dec		dword ptr [ EBP + 12 ]
		
		jmp		startLoopFindMax
	endLoopFindMax:
	
	mov		EAX, ESI                             	; return ESI
	
	pop		EBP
ret 12

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------
                                                                                              
; void swap(list* first, list* second)
swap:
	push	EBP
	mov		EBP, ESP
	           
	mov		EBX, dword ptr [ EBP + 8 ]				; EBX = offset first
	mov		EDX, dword ptr [ EBP + 12 ]             ; EDX = offset second
	
	mov		EAX, dword ptr [ EBX ]                  ; EAX = first.day 
	mov		ECX, dword ptr [ EDX ]                  ; ECX = second.day
	mov		dword ptr [ EDX ], EAX                  ; second.day = EAX
	mov		dword ptr [ EBX ], ECX                  ; first.day = ECX    
	
	mov		EAX, dword ptr [ EBX + 4 ]				; EAX = first.month
	mov		ECX, dword ptr [ EDX + 4 ]              ; ECX = second.month
	mov		dword ptr [ EDX + 4 ], EAX              ; second.month = EAX
	mov		dword ptr [ EBX + 4 ], ECX              ; first.month = ECX
	
	mov		EAX, dword ptr [ EBX + 8 ]              ; EAX = first.year
	mov		ECX, dword ptr [ EDX + 8 ]              ; ECX = second.year
	mov		dword ptr [ EDX + 8 ], EAX              ; second.year = EAX
	mov		dword ptr [ EBX + 8 ], ECX              ; first.year = ECX
	
	finit                                           ; clear ST
	fld		qword ptr [ EBX + 12 ]                  ; ST(0) = first.weight
	fld		qword ptr [ EDX + 12 ]                  ; ST(0) -> ST(1), ST(0) = second.weight
	fstp	qword ptr [ EBX + 12 ]                  ; first.weight = ST(0), ST(1) -> ST(0)
	fstp	qword ptr [ EDX + 12 ]                  ; second.weight = ST(0)
	
	pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------- 
                                                                                                    
; void	selectionSort(list* array, int size, *, **)
selectionSort:
	push	EBP
	mov		EBP, ESP
	           
	startLoopSort:
		cmp		dword ptr [ EBP + 12 ], 1
		je 	    endLoopSort        
	                         
		mov		EBX, dword ptr [ EBP + 8]			; EBX = offset array
		
		push	EBX									; save EBX value in stack
		
		push	dword ptr [ EBP + 16 ]
		push	dword ptr [ EBP + 12 ]
		push	EBX
		call	dword ptr [ EBP + 20 ]             	; call function **(array, size, *) 
		
		pop		EBX									; restore EBX value from stack
		                                            
		push	EAX									; EAX = return value of **
		push	EBX
		call	swap                              	; swap(array[i], array[**])	                         	
		
		add		dword ptr [ EBP + 8 ], 20			; to next element
  		dec		dword ptr [ EBP + 12 ]
  		
	    jmp		startLoopSort
	endLoopSort:
	
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
		push	dword ptr [ EAX + 16 ]
		push	dword ptr [ EAX + 12 ]
		call	FloatToStr                      	; convert array[i].weight to string
		
	 	mov		EAX, dword ptr [ EBP + 12 ]	        ; EAX = offset array
		
	   	push	offset tmp
		push	dword ptr [ EAX + 8 ]
		push	dword ptr [ EAX + 4 ]
		push	dword ptr [ EAX ]
		push	offset template
		push	dword ptr [ EBP + 8 ]
		call	wsprintf                           	; form output string
			
		add		ESP, 24								
		
		add		[ EBP + 8 ], EAX
		add		dword ptr [ EBP + 12 ], 20			; to next element
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
	call	readList 								; readList(array, n)                                                                               
	
;---------------------------------------------------------------------------------------------------
   													; write label 
	push	NULL
	push	offset numberOfChars
	push	19
	push	offset byWeight
	push	outputHandle
	call	WriteConsole

;---------------------------------------------------------------------------------------------------
    	
    push	findMin                                                                                                
	push	listCompareByWeight
	push	n
	push	offset array
	call	selectionSort							; selectionSort(array, n, listCompareByWeight, findMin)

;---------------------------------------------------------------------------------------------------
    										                                                                                              
	push	n
	push	offset array
	push	offset buffer
	call	listToStr								; convert array to string
	
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
	push	offset byDate
	push	outputHandle
	call	WriteConsole

;---------------------------------------------------------------------------------------------------
    
    push	findMin                                                                                                
	push	listCompareByDate
	push	n
	push	offset array
	call	selectionSort							; selectionSort(array, n, listCompareByDate, findMin)

;---------------------------------------------------------------------------------------------------
                                                                                                    
	push	n
	push	offset array
	push	offset buffer
	call	listToStr								; convert array to string
	
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
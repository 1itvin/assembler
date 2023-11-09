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
	 numberOfSides	dd 0
	 lengthOfSide	dq 0 
list ends

.data
	template		db "Number of sides: %d, length: %s;", 0ah, 0
	enterN			db "Enter n: ", 0
	enterArrElem	db "Enter array element (n, l):", 0ah, 0
	try				db "Invalid input. Try again.", 0ah, 0
	byPerimeter		db 0ah, "Sorted by perimeter:", 0ah, 0
	byArea			db 0ah, "Sorted by area:", 0ah, 0
	n				dd 0
	two				dq 2.0
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
		
		mov		EBX, dword ptr [ EBP + 8 ]          ; EBX = offset array
		
		;-------------------------------------------------------------------------------------------
		          									; read list[i].numberOfSides
		push	NULL
		push	offset numberOfChars
		push	15
		push	offset buffer
		push	inputHandle
		call	ReadConsole
		
		cmp		buffer[0], '-'
		jne		lblnumber
		mov		buffer[0], 2d
		lblnumber:
		
		mov		EDX, offset buffer
		mov		EAX, numberOfChars
		mov		byte ptr [ EDX + EAX - 2], 0
		
		push	offset buffer
		call	atodw
		mov		dword ptr [ EBX ], EAX
		
		;-------------------------------------------------------------------------------------------
	   												; data verification	                                                                                            
		cmp		dword ptr [ EBX ], 2
		jle		retry
	
		;-------------------------------------------------------------------------------------------
													; read list[i].lengthOfSide
		push	NULL
		push	offset numberOfChars
		push	15
		push	offset buffer
		push	inputHandle
		call	ReadConsole
		
		mov		EDX, offset buffer
		mov		EAX, numberOfChars
		mov		byte ptr [ EDX + EAX - 2 ], 0
		
		add		EBX, 4
		
		push	EBX
		push	offset buffer
		call	StrToFloat 
		
		;-------------------------------------------------------------------------------------------
													; data verification
		mov		EBX, dword ptr [ EBP + 8 ]          ; EBX = offset array
		                                                                                            
		finit										; clear ST
		fldz                                        ; ST(0) = 0
		fld		qword ptr [ EBX + 4 ]               ; ST(0) -> ST(1), ST(0) = list[i].lengthOfSide 
		fcom	ST(1)								; compare ST(0) and ST(1)
		fstsw	AX                                  ; save FPU flags in AX
		sahf                                        ; set CPU flags from AX
		jbe		retry
		
		;-------------------------------------------------------------------------------------------
		
		add		dword ptr [ EBP + 8 ], 12 			; to next element
		dec 	dword ptr [ EBP + 12 ]                                  
		
		;-------------------------------------------------------------------------------------------
		
		jmp		startLoopRead
	endLoopRead:
	
	pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------

; int listCompareByPerimeter(list* first, list* second)
listCompareByPerimeter:
	push	EBP
	mov		EBP, ESP     
               
	mov		EAX, dword ptr [ EBP + 8 ]				; EAX = offset first
	mov		EBX, dword ptr [ EBP + 12 ]             ; EBX = offset second
	                                                ; P = numberOfSides * lengthOfSide
	finit                                        	; clear ST
	fld		qword ptr [ EBX + 4 ]                   ; ST(0) = second.lengthOfSide
	fild	dword ptr [ EBX ]   					; ST(0) -> ST(1), ST(0) = second.numberOfSides                   
	fmulp	ST(1), ST(0)                            ; ST(1) = ST(1) * ST(0), ST(1) -> ST(0)
	fld		qword ptr [ EAX + 4 ]                   ; ST(0) -> ST(1), ST(0) = first.lengthOdSide
	fild	dword ptr [ EAX ]                       ; ST(1) -> ST(2), ST(0) -> ST(1), ST(0) = first.numberOfSides
	fmulp	ST(1), ST(0)                            ; ST(1) = ST(1) * ST(0), ST(1) -> ST(0), ST(2) -> ST(1)
	fcom	ST(1)                                   ; compare ST(0) and ST(1)
	fstsw	AX  									; save FPU flags in AX
	sahf                                            ; set CPU flags from AX
	ja		acbp
	jb		bcbp		
	                                                ; if ( first == second )
	mov		EAX, 0                                  ; return 0
	jmp		returnCBP
	
	acbp:  											; if ( first > second )
	mov		EAX, 1                                  ; return 1
	jmp		returnCBP
	
	bcbp:                       					; if ( first < second )
	mov		EAX, -1                                 ; return -1
	
	returnCBP:
	
    pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------
                                                                                                    
; int listCompareByArea(list* first, list* second)
listCompareByArea:
	push	EBP
	mov		EBP, ESP
	           
	mov		EAX, dword ptr [ EBP + 8 ]				; EAX = offset first	
	mov		EBX, dword ptr [ EBP + 12 ]             ; EBX = offset second 
													; R = lengthOfSide / ( 2 * sin( pi / numberOfSides ) )
	                                                ; S = ( numberOfSides / 2 ) * R^2 * sin( 2*pi / numberOfSides ) 
	finit											; clear ST                                                 
    
	fld		qword ptr [ EBX + 4 ]					; ST(0) = second.lengthOfSide
	fldpi                                           ; ST(0) -> ST(1), ST(0) = pi
	fild	dword ptr [ EBX ]                       ; ST(1) -> ST(2), ST(0) -> ST(1), ST(0) = second.numberOfSides
	fdivp	ST(1), ST(0)                            ; ST(1) = ST(1) / ST(0), ST(1) -> ST(0), ST(2) -> ST(1)
	fsin                                           	; ST(0) = sin( ST(0) )
	fmul	two										; ST(0) = ST(0) * 2
	fdivp	ST(1), ST(0)							; ST(1) = ST(1) / ST(0), ST(1) -> ST(0)
	fmul	ST(0), ST(0)                            ; ST(0) = ST(0) * ST(0)
	fild	dword ptr [ EBX ]						; ST(0) -> ST(1), ST(0) = second.numberOfSides
	fmulp	ST(1), ST(0)                          	; ST(1) = ST(1) * ST(0), ST(1) -> ST(0)
	fdiv	two     								; ST(0) = ST(0) / 2
	fldpi											; ST(0) -> ST(1), ST(0) = pi   
	fmul	two 									; ST(0) = ST(0) * 2
	fild	dword ptr [ EBX ]    					; ST(1) -> ST(2), ST(0) -> ST(1), ST(0) = second.numberOfSides
	fdivp	ST(1), ST(0) 							; ST(1) = ST(1) / ST(0), ST(1) -> ST(0), ST(2) -> ST(1)
	fsin            								; ST(0) = sin( ST(0) )
	fmulp	ST(1), ST(0)                            ; ST(1) = ST(1) * ST(0), ST(1) -> ST(0)
	
	fld		qword ptr [ EAX + 4 ]					; ST(0) -> ST(1), ST(0) = first.lengthOfSide
	fldpi                                           ; ST(1) -> ST(2), ST(0) -> ST(1), ST(0) = pi
	fild	dword ptr [ EAX ]                       ; ST(2) -> ST(3), ST(1) -> ST(2), ST(0) -> ST(1), ST(0) = first.numberOfSides
	fdivp	ST(1), ST(0)							; ST(1) = ST(1) / ST(0), ST(1) -> ST(0), ST(2) -> ST(1), ST(3) -> ST(2) 
	fsin                                      		; ST(0) = sin( ST(0) )
	fmul	two 									; ST(0) = ST(0) * 2
	fdivp	ST(1), ST(0)                            ; ST(1) = ST(1) / ST(0), ST(1) -> ST(0), ST(2) -> ST(1)
	fmul	ST(0), ST(0)							; ST(0) = ST(0) * ST(0)
	fild	dword ptr [ EAX ]                       ; ST(1) -> ST(2), ST(0) -> ST(1), ST(0) = first.numberOfSides
	fmulp	ST(1), ST(0)							; ST(1) = ST(1) * ST(0), ST(1) -> ST(0), ST(2) -> ST(1)
	fdiv	two                                     ; ST(0) = ST(0) / 2
	fldpi                                           ; ST(1) -> ST(2), ST(0) -> ST(1), ST(0) = pi
	fmul	two                                     ; ST(0) = ST(0) * 2
	fild	dword ptr [ EAX ]                       ; ST(2) -> ST(3), ST(1) -> ST(2), ST(0) -> ST(1), ST(0) = first.numberOfSides
	fdivp	ST(1), ST(0)   							; ST(1) = ST(1) / ST(0), ST(1) -> ST(0), ST(2) -> ST(1), ST(3) -> ST(2)
	fsin  											; ST(0) = sin( ST(0) )
	fmulp	ST(1), ST(0) 							; ST(1) = ST(1) * ST(0), ST(1) -> ST(0), ST(2) -> ST(1)

	fcom	ST(1)									; compare ST(0) and ST(1)
	fstsw	AX               						; save FPU flags in AX
	sahf                                            ; set CPU flags from AX
	ja		acba
	jb		bcba
													; if ( first == second )
	mov		EAX, 0                                  ; return 0
	jmp		returnCBA
	
	acba: 											; if ( first > second )
	mov		EAX, 1                                  ; return 1
	jmp		returnCBA
	
	bcba:              								; if ( first < second )
	mov		EAX, -1                                 ; return -1
	
	returnCBA:
		
	pop		EBP
ret 8

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------
                                                                                                    
; list* findMin(list* arr, int size, *)
findMin:
	push	EBP
	mov		EBP, ESP
	           
	mov		EBX, dword ptr [ EBP + 8 ]				; EBX = offset arr	
	
	mov		ESI, EBX   								; ESi = offset arr[0]
	
	startLoopFindMin:
		cmp		dword ptr [ EBP + 12 ], 0
		je		endLoopFindMin

		push	EBX                                 ; save EBX value in stack
		                        
		push	ESI
		push	EBX
		call	dword ptr [ EBP + 16 ]				; call function *(arr[i], min)
		
		pop		EBX             					; restore EBX value from stack

		cmp		EAX, 0  							; compare return value and 0
		jnl		continueFindMin
	   												; if ( EAX >= 0 )	                
		mov		ESI, EBX                            ; ESI = offset arr[i]
		
		continueFindMin:
		add	 	EBX, 12								; to next element
		dec		dword ptr [ EBP + 12 ]
		
		jmp		startLoopFindMin
	endLoopFindMin:
	
	mov		EAX, ESI 								; return ESI
	
	pop		EBP
ret 12
             
;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------
                                                                                                    
; list* findMax(list* arr, int size, *)
findMax:
	push	EBP
	mov		EBP, ESP
	           
	mov		EBX, dword ptr [ EBP + 8 ]				; EBX = offset arr
	
	mov		ESI, EBX                                ; ESI = offset arr[0]
	
	startLoopFindMax:
		cmp		dword ptr [ EBP + 12 ], 0
		je		endLoopFindMin
		
		push	EBX                                 ; save EBX value in stack
		                        
		push	ESI
		push	EBX
		call	dword ptr [ EBP + 16 ]            	; call function *(arr[i], max) 
		
		pop		EBX                                 ; restore EBX value from stack

		cmp		EAX, 0								; compare return value and 0
		jng		continueFindMax       				
		                                            ; if ( EAX <= 0 )
		mov		ESI, EBX                            ; ESI = offset arr[i]
		
		continueFindMax:
		add	 	EBX, 12   							; to next element
		dec		dword ptr [ EBP + 12 ]
		
		jmp		startLoopFindMax
	endLoopFindMax:
	
	mov		EAX, ESI   								; return ESI
	
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
	
	mov		EAX, dword ptr [ EBX ]                 	; EAX = first.numberOfSides
	mov		ECX, dword ptr [ EDX ]                  ; ECX = second.numberOfSides
	mov		dword ptr [ EDX ], EAX                  ; second.numberOfSides = EAX
	mov		dword ptr [ EBX ], ECX                  ; first.numberOfSides = ECX    
	
	finit 											; clear ST
	fld		qword ptr [ EBX + 4 ]                   ; ST(0) = first.lengthOfSide
	fld		qword ptr [ EDX + 4 ]                   ; ST(0) -> ST(1), ST(0) = second.lengthOfSide
	fstp	qword ptr [ EBX + 4 ]                   ; first.lengthOfSide = ST(0), ST(1) -> ST(0)
	fstp	qword ptr [ EDX + 4 ]                   ; second.lengthOfSide = ST(0)
	
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
	                         
		mov		EBX, dword ptr [ EBP + 8] 			; EBX = offset array
	
		push	EBX									; save EBX value in stack
		
		push	dword ptr [ EBP + 16 ]
		push	dword ptr [ EBP + 12 ]
		push	EBX
		call	dword ptr [ EBP + 20 ]        		; call function **(array, size, *)
		
		pop		EBX									; restore EBX value from stack
		
		push	EAX 								; EAX = return calue of **
		push	EBX
		call	swap								; swap(array[i], array[**])	
		
		add		dword ptr [ EBP + 8 ], 12			; to next element
  		dec		dword ptr [ EBP + 12 ]
  		
	    jmp		startLoopSort
	endLoopSort:
	
	pop		EBP
ret	16

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
		push	dword ptr [ EAX + 8 ]
		push	dword ptr [ EAX + 4 ]
		call	FloatToStr   						; convert array[i].lengthOfSide to string
		
	 	mov		EAX, dword ptr [ EBP + 12 ]			; EAX = offset array	 
		
	   	push	offset tmp
		push	dword ptr [ EAX ]
		push	offset template
		push	dword ptr [ EBP + 8 ]
		call	wsprintf							; form output string
			
		add		ESP, 16
		
		add		[ EBP + 8 ], EAX
		add		dword ptr [ EBP + 12 ], 12 			; to next element
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
	push	22
	push	offset byPerimeter
	push	outputHandle
	call	WriteConsole

;---------------------------------------------------------------------------------------------------
    
    push	findMin                                                                                                
	push	listCompareByPerimeter
	push	n
	push	offset array
	call	selectionSort 							; selectionSort(array, n, listCompareByPerimeter, findMin)

;---------------------------------------------------------------------------------------------------
   						                                                                                                 
	push	n
	push	offset array
	push	offset buffer
	call	listToStr   							; converrt array to string
	
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
	push	offset byArea
	push	outputHandle
	call	WriteConsole

;---------------------------------------------------------------------------------------------------
    
    push	findMin                                                                                                
	push	listCompareByArea
	push	n
	push	offset array
	call	selectionSort							; selectioSort(array, n, listCompareByArea, findMin)

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
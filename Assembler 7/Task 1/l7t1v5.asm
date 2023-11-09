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
	enterN			db "Enter n: "
	enterKey		db "Enter key: "
	enterArr		db "Enter array (sorted): ", 0ah
	result			db "Result:  "
	n				dd 0          
	key				dd 0
    array			dd 100 dup (0)
    template db "%d ", 0
	
.data
	inputHandle		dd ?
	outputHandle	dd ?
	numberOfChars	dd ?
	buffer			db ?
	
.code 

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------

; void readArray(int* array, int size)
readArray:
	push	EBP
	mov		EBP, ESP
	
	startLoop:
		cmp		dword ptr [ EBP + 12 ], 0
		je		endLoop 
		                         					; read element
		push	NULL
		push	offset numberOfChars
		push	15
		push	offset buffer
		push	inputHandle
		call	ReadConsole
		
		cmp		buffer[0], '-'
		jne		neb
		mov		buffer[0], 2d
		neb:            
		
		mov		EDX, offset buffer
		mov		EAX, numberOfChars
		mov		byte ptr [ EDX + EAX - 2 ], 0
		         
		push	offset buffer
		call	atodw
		mov		EBX, dword ptr [ EBP + 8 ]			
		mov		[ EBX ], EAX
		                 
		add	 	dword ptr [ EBP + 8 ], 4            ; to next array element
		dec 	dword ptr [ EBP + 12 ]
		       	
		jmp		startLoop
	endLoop:
	
	pop		EBP
ret 8

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
     
; int binarySearch(int* array, int left, int right, int key)
binarySearch:
	push	EBP
	mov		EBP, ESP
	
	mov		EAX, dword ptr [ EBP + 16 ]				; EAX = right
	sub		EAX, dword ptr [ EBP + 12 ]             ; EAX = right - left
	mov		EBX, 2                                  ; EBX = 2
	xor		EDX, EDX                                ; clear EDX
	div		EBX                                     ; EAX / EBX
	add		EAX, dword ptr [ EBP + 12 ]
	
	mov		EDX, dword ptr [ EBP + 8 ]             	; EDX = offset array
	mov		EBX, dword ptr [ EDX + EAX * 4 ]        ; EBX = array[middle]
	cmp		EBX, dword ptr [ EBP + 20 ]             ; compare array[middle] and key
	je 		return                                  ; return EAX if equal
	                                                ; array[middle] <> key
	mov		EBX, dword ptr [ EBP + 12 ]             ; EBX = left
	cmp		EBX, dword ptr [ EBP + 16 ]				; comapare left and right ] <> key d
	jl		continue
													; if ( left >= right )
	mov		EAX, -1                                 ; EAX = -1
	jmp		return 
	
	continue: 										; if ( left < right && array[middle] != key )
	mov		EBX, dword ptr [ EBP + 20 ]				; EBX = key
	cmp		EBX, dword ptr [ EDX + EAX * 4 ]        ; compare key and array[middle]
	jl		lvi
	    											; if ( key > array[middle] )
	inc		EAX    											

	push	dword ptr [ EBP + 20 ]
	push	dword ptr [ EBP + 16 ]
	push	EAX
	push	dword ptr [ EBP + 8 ]
	call	binarySearch           					; binarySearch(array, middle + 1, right, key)
	
	jmp 	return
	                   
	lvi:											; if ( key < array[middle] )
	push	dword ptr [ EBP + 20]
	push	EAX
	push	dword ptr [ EBP + 12 ]
	push	dword ptr [ EBP + 8 ]
	call	binarySearch                            ; binarySearch(array, left, middle, key)
	
	return:
	
	pop		EBP
ret 16

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
                                            		; read key
   	push 	NULL
   	push 	offset numberOfChars
   	push	11
   	push	offset enterKey
   	push	outputHandle
   	call	WriteConsole
   	
   	push	NULL
   	push	offset numberOfChars
   	push	15
   	push	offset buffer
   	push	inputHandle
   	call 	ReadConsole
   	
   	cmp		buffer[0], '-'
   	jne		lbl2
   	mov		buffer[0], 2d
   	lbl2:
   	
   	mov		EDX, offset buffer
   	mov		EAX, numberOfChars
   	mov		byte ptr [ EDX + EAX - 2 ], 0
   	
   	push	offset buffer
   	call	atodw
   	mov		key, EAX

;-----------------------------------------------------------------------------------------  

   	push	NULL
	push	offset numberOfChars
	push 	23
	push	offset enterArr
	push	outputHandle
	call	WriteConsole
	
  	push	n
  	push	offset array
  	call	readArray	   	

;-----------------------------------------------------------------------------------------

	push	NULL
	push	offset numberOfChars
	push	9
	push	offset result
	push	outputHandle
	call	WriteConsole                                                                                          

;-----------------------------------------------------------------------------------------

	mov		EAX, n
	dec		EAX

	push	key
	push	EAX
	push	0
	push	offset array
	call	binarySearch          					; binarySearch(array, 0, n - 1, key)
	
;-----------------------------------------------------------------------------------------
                                                    ; output of result
    push	offset buffer
    push	EAX
    call	dwtoa
	
	push	offset buffer
	call 	lstrlen
	
	push	NULL
	push	offset numberOfChars
	push	EAX
	push	offset buffer
	push	outputHandle
	call	WriteConsole                                                                                      

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
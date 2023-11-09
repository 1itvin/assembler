.486
.model flat, stdcall

option casemap : none

include windows.inc
include kernel32.inc
include masm32.inc 
include	user32.inc

includelib kernel32.lib
includelib masm32.lib 
includelib user32.lib

node struct
	value			dd 0
	left			dd 0
	right			dd 0
node ends

.data
	enterN			db "Enter n: "  
	enterElements	db "Enter elements:", 0ah  
	sum				db "Sum: "				
	n				dd 0 
	tree			dd 0


.data?
	inputHandle		dd ?
	outputHandle	dd ?
	numberOfChars	dd ?
	buffer			db ?

.code

;--------------------------------------------------------------------------------------------------- 
;--------------------------------------------------------------------------------------------------- 
    
; node* addNode(int value, node* tree)
addNode: 
	push	EBP
	mov		EBP, ESP
                 
	mov		EBX, dword ptr [ EBP + 12 ]             ; EBX = offset tree
	
	cmp		EBX, 0									; compare EBX and 0
	jne		insert
	                 								; if ( EBX == 0 )
		call	GetProcessHeap                      ; get handle to heap of process
	
		push	12									
   		push	0
   		push	EAX
		call	HeapAlloc							; allocate a block of memory from a heap 
	
		mov		EBX, EAX							; EBX = EAX
		mov		EAX, dword ptr [ EBP + 8 ]          ; EAX = value
		mov		dword ptr [ EBX ], EAX              ; tree.value = EAX
   		mov		dword ptr [ EBX + 4 ], 0            ; tree.left = 0
   		mov		dword ptr [ EBX + 8 ], 0            ; tree.right = 0
	
		mov		EAX, EBX							; EAX = offset tree
	
		jmp		return	
	
	insert: 
	mov		EAX, dword ptr [ EBP + 8]				; EAX = value
	cmp		dword ptr [ EBX ], EAX					; compare tree.value and EAX
 	jl		lvv                                     ; if ( tree.value >= EAX )
   
   		mov		EAX, 0 								; EAX = 0				
   
   		push	dword ptr [ EBX + 4 ]	              
		push	dword ptr [ EBP + 8 ]
		call	addNode                             ; addNode(value, tree.left)
	
		cmp		EAX, 0								; compare EAX and 0
 		je		return
	                                  				; if ( EAX != 0 )
	   		mov		EBX, dword ptr [ EBP + 12 ]		; EBX = offset tree
			mov		dword ptr [ EBX + 4 ], EAX      ; tree.left = EAX
	   		mov		EAX, 0                          ; EAX = 0
	
		jmp		return
	
	lvv:											; if ( tree.value < EAX )
	mov		EAX, 0 									; EAX = 0
	
 	push	dword ptr [ EBX + 8 ]
 	push	dword ptr [ EBP + 8 ]
	call	addNode                                	; addNode(value, tree.right)
	
	cmp		EAX, 0									; compare EAX and 0
	je		return
	                                      			; if ( EAX != 0 )
		mov		EBX, dword ptr [ EBP + 12 ]         ; EBX = offset tree
		mov		dword ptr [ EBX + 8 ], EAX          ; tree.right = EAX
	 	mov		EAX, 0                              ; EAX = 0
	
	return:           
	
	pop		EBP
ret 8  
	

;--------------------------------------------------------------------------------------------------- 
;---------------------------------------------------------------------------------------------------

; int findSum(node* tree)
findSum:
	push	EBP
	mov		EBP, ESP 
	
	sub		ESP, 4                                  ; reserve memory in stack for local variable
	
	mov		EAX, 0									; EAX = 0
	
	mov		EBX, dword ptr [ EBP + 8 ]				; EBX = offset tree
	cmp		EBX, 0									; compare EBX and 0
	je		returnSum 
        											; if ( EBX != 0 ) 
 		add		EAX, dword ptr [ EBX ] 				; EAX = EAX + tree.value
		mov		dword ptr [ EBP - 4 ], EAX			; sum = EAX
    
   		push	EBX									; save EBX value in stack 
	    
		push	dword ptr [ EBX + 4 ]	
		call	findSum         					; findSum(tree.left)
		 
        add		dword ptr [ EBP - 4 ], EAX			; sum = sum + EAX
        
        pop		EBX   								; restore EBX value from stack
        
        push	dword ptr [ EBX + 8 ]
        call	findSum            					; findSum(tree.right)
		
		add		EAX, dword ptr [ EBP - 4 ]   		; EAX = EAX + sum
			
	returnSum:
	add		ESP, 4 									; cler memory
	
    pop		EBP
ret 4


;--------------------------------------------------------------------------------------------------- 
;--------------------------------------------------------------------------------------------------- 

; void clearMemory(node* tree)
clearMemory:
	push	EBP
	mov		EBP, ESP
	
	mov		EBX, dword ptr [ EBP + 8 ]              ; EBX = offset tree
	
	cmp		EBX, 0                                  ; compare EBX and 0
	je		returnClear
	               									; if ( EBX != 0 )
		push	EBX									; save EBX value in stack
	
		push	dword ptr [ EBX + 4 ]				
		call	clearMemory                         ; clearMemory(tree.left)
	
   		pop		EBX 								; restore EBX value from stack
	
		push 	dword ptr [ EBX + 8 ]
		call	clearMemory							; clearMemory(tree.right)
	
		call	GetProcessHeap						; get handle to heap of process
	
		push	dword ptr [ EBP + 8 ]
		push	0
		push	EAX
		call	HeapFree	 						; free a memory block						           
	
	returnClear:
    pop		EBP
ret 4

;--------------------------------------------------------------------------------------------------- 
;--------------------------------------------------------------------------------------------------- 

main:
;--------------------------------------------------------------------------------------------------- 
        
	push	STD_INPUT_HANDLE
	call	GetStdHandle
	mov		inputHandle, EAX
	
	push	STD_OUTPUT_HANDLE
	call	GetStdHandle
	mov		outputHandle, EAX

;---------------------------------------------------------------------------------------------------
                                                    ; read n
	tryN:
	push 	NULL
	push	offset numberOfChars
	push	9
	push	offset enterN
	push	outputHandle
	call	WriteConsole
	
	push	NULL
	push	offset numberOfChars
	push	15
	push	offset buffer
	push 	inputHandle
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
	jl		tryN	

;---------------------------------------------------------------------------------------------------
                                                    ; write label
	push	NULL
	push	offset numberOfChars
	push	16
	push	offset enterElements
	push	outputHandle
	call	WriteConsole
	
;---------------------------------------------------------------------------------------------------
    
	mov		ECX, 0  								; ECX = 0

	startLoop:
		cmp		ECX, n
		je		endLoop
		
		push	ECX									; save ECX value in stack
	    
	    push	NULL 								; read element
	    push	offset numberOfChars
	    push	15
	    push	offset buffer
	    push	inputHandle
	    call	ReadConsole
	    
	    cmp		buffer[0], '-'
	    jne		lbl
	    mov		buffer[0], 2d
	    lbl:
	    
	    mov		EDX, offset buffer
	    mov		EAX, numberOfChars
	    mov		byte ptr [ EDX + EAX - 2 ], 0
	    
	    push	offset buffer
	    call	atodw
	    
	    push	tree
	    push	EAX
	    call	addNode 							; addNode(EAX, tree)
	    
	    pop		ECX 								; restore ECX value from stack
	    
	    cmp		ECX, 0								; compare ECX and 0
	    jne		continue
	                          						; if ( ECX == 0 )
	    	mov		tree, EAX                       ; tree = EAX
	    
	    continue:
	    inc		ECX
	    
	    jmp		startLoop    
	endLoop:
	
;---------------------------------------------------------------------------------------------------
                                                    ; write label
	push	NULL
	push	offset numberOfChars
	push	5
	push	offset sum
	push	outputHandle
	call	WriteConsole
	
;---------------------------------------------------------------------------------------------------
                                                    ; find sum
	push	tree
	call	findSum
	
;---------------------------------------------------------------------------------------------------
                                                    ; output of result
	push	offset buffer
	push	EAX
	call	dwtoa
	
	push	offset buffer
	call	lstrlen
	
	push	NULL
	push	offset numberOfChars
	push	EAX
	push	offset buffer
	push 	outputHandle
	call	WriteConsole
	
;---------------------------------------------------------------------------------------------------
                                                    ; clear memory
	push	tree
	call	clearMemory

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
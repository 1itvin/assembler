.486
.model flat, stdcall

option casemap : none

include windows.inc
include kernel32.inc
include masm32.inc

includelib kernel32.lib
includelib masm32.lib

.data                   
	enterA			db "Enter a: "
	enterB			db "Enter b: "
	enterC			db "Enter c: "
	result			db "Result: "
	a				dd 0
	b				dd 0
	cc				dd 0  
	src				dq 0    
	res				dq 0

.data? 
	inputHandle		dd ?
	outputHandle	dd ?
	numberOfChars	dd ?
	buffer			db ?

.code

main:
;---------------------------------------------------------------------------------------------------
 
	push	STD_INPUT_HANDLE
	call	GetStdHandle
	mov		inputHandle,  EAX
	
	push	STD_OUTPUT_HANDLE
	call	GetStdHandle
	mov		outputHandle, EAX
	
;---------------------------------------------------------------------------------------------------
                                                    ; read a
	push	NULL
	push	offset numberOfChars
	push	9
	push	offset enterA
	push	outputHandle
	call	WriteConsole
	
	push	NULL
	push	offset numberOfChars
	push	15
	push	offset buffer
	push	inputHandle
	call	ReadConsole
	
	mov		EDX, offset buffer
	mov		EAX,numberOfChars
	mov		byte ptr [ EDX + EAX - 2 ], 0
	
	push	offset buffer
	call	atodw
	mov		a, EAX

;---------------------------------------------------------------------------------------------------
                                                    ; read b
	push	NULL
	push	offset numberOfChars
	push	9
	push	offset enterB
	push	outputHandle
	call	WriteConsole
	
	push	NULL
	push	offset numberOfChars
	push	15
	push	offset buffer
	push	inputHandle
	call	ReadConsole
	
	mov		EDX, offset buffer
	mov		EAX,numberOfChars
	mov		byte ptr [ EDX + EAX - 2 ], 0
	
	push	offset buffer
	call	atodw
	mov		b, EAX

;---------------------------------------------------------------------------------------------------
                                                    ; read c
	push	NULL
	push	offset numberOfChars
	push	9
	push	offset enterC
	push	outputHandle
	call	WriteConsole
	
	push	NULL
	push	offset numberOfChars
	push	15
	push	offset buffer
	push	inputHandle
	call	ReadConsole
	
	mov		EDX, offset buffer
	mov		EAX,numberOfChars
	mov		byte ptr [ EDX + EAX - 2 ], 0
	
	push	offset buffer
	call	atodw
	mov		cc, EAX
	
;---------------------------------------------------------------------------------------------------
                                                    ; write label
	push	NULL
	push	offset numberOfChars
	push	8
	push	offset result
	push	outputHandle
	call	WriteConsole

;---------------------------------------------------------------------------------------------------
                                                                                                    
	mov		EAX, b                                  ; EAX = b
	mov		EBX, 8                                 	; EBX = 8
	mul		EBX                                     ; EAX = EAX * EBX
	mov		b, EAX                                  ; b = EAX
	
	mov		EAX, a									; EAX = a
	cdq                                             ; convert to EDX:EAX 
	
	;-----------------------------------------------------------------------------------------------
	                                                ; a^2
	mov		dword ptr src, EAX                      ; src = EDX:EAX
	mov		dword ptr src[4], EDX
	
	mul		EAX     								; EAX = EAX * EAX 
	mov		dword ptr res, EAX                      ; res = EDX:EAX
	mov		dword ptr res[4], EDX
	mov		EAX, dword ptr src[4]  					; EAX = HIWORD( src )
	mul		dword ptr src 							; EAX = EAX * LOWORD( src )		
	add		dword ptr res[4], EAX					; HIWORD( res ) = HIWORD( res ) + EAX
	add		dword ptr res[4], EAX                   ; HIWORD( res ) = HIWORD( res ) + EAX
	
	mov		EAX, dword ptr res						; EDX:EAX = res
	mov		EDX, dword ptr res[4]  
	
	;-----------------------------------------------------------------------------------------------
	                                                ; a^3
 	mov		dword ptr src, EAX 						; src = EDX:EAX
	mov		dword ptr src[4], EDX
	
	mul		a   									; EAX = EAX * a
	mov		dword ptr res, EAX                      ; res = EDX:EAX
	mov		dword ptr res[4], EDX
	mov		EAX, dword ptr src[4]					; EAX = HIWORD( src )
	mul		a                                       ; EAX = EAX * a
	add		dword ptr res[4], EAX                   ; HIWORD( res ) = HIWORD( res ) + EAX
	
	mov		EAX, dword ptr res						; EDX:EAX = res
	mov		EDX, dword ptr res[4] 
	
	;-----------------------------------------------------------------------------------------------
	                                               	; a^6
	mov		dword ptr src, EAX                      ; src = EDX:EAX
	mov		dword ptr src[4], EDX
	
	mul		EAX     								; EAX = EAX * EAX 
	mov		dword ptr res, EAX                      ; res = EDX:EAX
	mov		dword ptr res[4], EDX
	mov		EAX, dword ptr src[4]  					; EAX = HIWORD( src )
	mul		dword ptr src 							; EAX = EAX * LOWORD( src )		
	add		dword ptr res[4], EAX					; HIWORD( res ) = HIWORD( res ) + EAX
	add		dword ptr res[4], EAX                   ; HIWORD( res ) = HIWORD( res ) + EAX
	
	mov		EAX, dword ptr res						; EDX:EAX = res
	mov		EDX, dword ptr res[4]
	
	;-----------------------------------------------------------------------------------------------                  
	                                                ; a^12
	mov		dword ptr src, EAX                      ; src = EDX:EAX
	mov		dword ptr src[4], EDX
	
	mul		EAX     								; EAX = EAX * EAX 
	mov		dword ptr res, EAX                      ; res = EDX:EAX
	mov		dword ptr res[4], EDX
	mov		EAX, dword ptr src[4]  					; EAX = HIWORD( src )
	mul		dword ptr src 							; EAX = EAX * LOWORD( src )		
	add		dword ptr res[4], EAX					; HIWORD( res ) = HIWORD( res ) + EAX
	add		dword ptr res[4], EAX                   ; HIWORD( res ) = HIWORD( res ) + EAX
	
	mov		EAX, dword ptr res						; EDX:EAX = res
	mov		EDX, dword ptr res[4]  
	
	;-----------------------------------------------------------------------------------------------
	
	add		EAX, b									; EAX = EAX + b
	adc		EDX, 0    								; EDX = EDX + carry
	
	div		cc										; EAX = EDX:EAX / c, EDX = EDX:EAX % c
	
	add		EAX, EDX								; EAX = EAX + EDX
	
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
.486
.model flat, stdcall 
 
option casemap : none 

include windows.inc
include kernel32.inc

includelib kernel32.lib

.data
	leftBracket 	db "{"
	rightBracket 	db "}"
	inputBuffer 	db 0
	
.data?
	inputHandle 	dd ?
	outputHandle 	dd ?
	numberOfChars 	dd ?   
	message 		db ?
	
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
	                                                ; read message
	push 	NULL
	push 	offset numberOfChars   
	push 	30
	push 	offset message
	push 	inputHandle
	call 	ReadConsole         
	
	mov		EDX, offset message
	mov		EAX, numberOfChars
	mov		byte ptr [ EDX + EAX - 2 ], 0   
	
;---------------------------------------------------------------------------------------------------
	                                                ; output of result
	push 	NULL
	push 	offset numberOfChars
	push 	1
	push 	offset leftBracket
	push 	outputHandle
	call 	WriteConsole
	
	push	offset message
	call	lstrlen
	
	push 	NULL
	push 	offset numberOfChars
	push 	EAX
	push 	offset message
	push 	outputHandle
	call 	WriteConsole
	
	push 	NULL
	push 	offset numberOfChars
	push 	1
	push 	offset rightBracket
	push 	outputHandle
	call 	WriteConsole    
	
;---------------------------------------------------------------------------------------------------
	
	push 	NULL
	push 	offset numberOfChars
	push 	1
	push 	offset inputBuffer
	push 	inputHandle
	call 	ReadConsole
	
 	push 	0
  	call 	ExitProcess 
 
;---------------------------------------------------------------------------------------------------	
end main
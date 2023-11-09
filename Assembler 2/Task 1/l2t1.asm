.486
.model flat, stdcall

option casemap : none 

include windows.inc
include kernel32.inc 

includelib kernel32.lib

.data
	messageString 	db "Hello, World!!!"
	inputBuffer 	db 0

.data?
	inputHandle 	dd ?
	outputHandle 	dd ?
	numberOfChars 	dd ?

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
	                                                ; output of message
	push 	NULL                 
	push 	offset numberOfChars
	push 	15                   
	push 	offset messageString 
	push 	outputHandle         
	call	 WriteConsole
	
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
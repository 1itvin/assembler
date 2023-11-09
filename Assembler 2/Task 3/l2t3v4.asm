.486
.model flat, stdcall

option casemap : none

include windows.inc
include kernel32.inc

includelib kernel32.lib

.data
	enterA			db "Enter a: "
	enterB			db "Enter b: "
	enterC			db "Enter c: "    
	firstLine		db 0dah, 0c4h, 0c4h, 0c4h, 0c4h,
					   0c4h, 0c4h, 0c4h, 0c4h, 0c4h,
					   0c4h, 0c2h, 0c4h, 0c4h, 0c4h,
					   0c4h, 0c4h, 0c4h, 0c4h, 0c4h,
					   0c4h, 0c4h, 0c2h, 0c4h, 0c4h,
					   0c4h, 0c4h, 0c4h, 0c4h, 0c4h,
					   0c4h, 0c4h, 0c4h, 0bfh, 0ah 
	leftA			db 0b3h
	rightA			db 0b3h, 0feh, 0feh, 0feh, 0feh,
					   0feh, 0feh, 0feh, 0feh, 0feh,
					   0feh, 0b3h, 0feh, 0feh, 0feh,
					   0feh, 0feh, 0feh, 0feh, 0feh,
					   0feh, 0feh, 0b3h, 0ah 
   	thirdFifthLine	db 0c3h, 0c4h, 0c4h, 0c4h, 0c4h,
   					   0c4h, 0c4h, 0c4h, 0c4h, 0c4h,
   					   0c4h, 0c5h, 0c4h, 0c4h, 0c4h,
   					   0c4h, 0c4h, 0c4h, 0c4h, 0c4h,
   					   0c4h, 0c4h, 0c5h, 0c4h, 0c4h,
   					   0c4h, 0c4h, 0c4h, 0c4h, 0c4h,
   					   0c4h, 0c4h, 0c4h, 0b4h, 0ah                  
   	leftB			db 0b3h, 0feh, 0feh, 0feh, 0feh,
   					   0feh, 0feh, 0feh, 0feh, 0feh,
   					   0feh, 0b3h
   	rightB			db 0b3h, 0feh, 0feh, 0feh, 0feh,
   					   0feh, 0feh, 0feh, 0feh, 0feh,
   					   0feh, 0b3h, 0ah  
   	leftC			db 0b3h, 0feh, 0feh, 0feh, 0feh,
   	 				   0feh, 0feh, 0feh, 0feh, 0feh,
   	 				   0feh, 0b3h, 0feh, 0feh, 0feh,
   	 				   0feh, 0feh, 0feh, 0feh, 0feh,
   	 				   0feh, 0feh, 0b3h
   	rightC			db 0b3h, 0ah
   	seventhLine		db 0c0h, 0c4h, 0c4h, 0c4h, 0c4h,
   					   0c4h, 0c4h, 0c4h, 0c4h, 0c4h,
   					   0c4h, 0c1h, 0c4h, 0c4h, 0c4h,
   					   0c4h, 0c4h, 0c4h, 0c4h, 0c4h,
   					   0c4h, 0c4h, 0c1h, 0c4h, 0c4h,
   					   0c4h, 0c4h, 0c4h, 0c4h, 0c4h,
   					   0c4h, 0c4h, 0c4h, 0d9h, 0ah	 
	aa 				db 100 dup (" ")
	bb 				db 100 dup (" ")
	cc 				db 100 dup (" ") 
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
                                                    ; read a
	push	NULL
	push	offset numberOfChars
	push	9
	push	offset enterA
	push	outputHandle
	call	WriteConsole
	
	push	NULL
	push 	offset numberOfChars
	push 	100
	push 	offset aa
	push 	inputHandle
	call 	ReadConsole
	
	mov 	EBX, offset aa
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EBX + EAX - 1 ], " "
	mov 	byte ptr [ EBX + EAX - 2 ], " "              
	
;---------------------------------------------------------------------------------------------------
                                                    ; read b
	push	NULL
	push	offset numberOfChars
	push	9
	push	offset enterB
	push	outputHandle
	call	WriteConsole	
				
	push 	NULL
	push 	offset numberOfChars
	push 	100
	push 	offset bb
	push 	inputHandle
	call 	ReadConsole
	
	mov 	EBX, offset bb
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EBX + EAX - 1 ], " "
	mov 	byte ptr [ EBX + EAX - 2 ], " " 
	
;---------------------------------------------------------------------------------------------------
	                                                ; read c
	push	NULL
	push	offset numberOfChars
	push	9
	push	offset enterC
	push	outputHandle
	call	WriteConsole
	
	push 	NULL
	push 	offset numberOfChars
	push 	100
	push 	offset cc
	push 	inputHandle
	call 	ReadConsole
	
	mov 	EBX, offset cc
	mov 	EAX, numberOfChars
	mov 	byte ptr [ EBX + EAX - 1 ], " "
	mov 	byte ptr [ EBX + EAX - 2 ], " "
	
;---------------------------------------------------------------------------------------------------
	                                                ; first line
    push	NULL
    push	offset numberOfChars
    push	35
    push	offset firstLine
    push	outputHandle
    call	WriteConsole
  
;---------------------------------------------------------------------------------------------------
                                                    ; second line
   	push	NULL
   	push	offset numberOfChars
   	push	1
   	push	offset leftA
   	push	outputHandle
   	call	WriteConsole
   	
   	push	NULL
   	push	offset numberOfChars
   	push	10
   	push	offset aa
   	push	outputHandle
   	call	WriteConsole
   	
   	push	NULL
   	push	offset numberOfChars
   	push	24
   	push	offset rightA
   	push	outputHandle
   	call	WriteConsole
   	
;---------------------------------------------------------------------------------------------------
                                                    ; third line
	push	NULL
	push	offset numberOfChars
	push	35
	push	offset thirdFifthLine
	push	outputHandle
	call	WriteConsole 
	
;---------------------------------------------------------------------------------------------------
                                                    ; fourth line
   	push	NULL
   	push	offset numberOfChars
   	push	12
   	push	offset leftB
   	push 	outputHandle
   	call	WriteConsole
   	
   	push	NULL
   	push	offset numberOfChars
   	push	10
   	push	offset bb
   	push	outputHandle
   	call	WriteConsole
   	
   	push	NULL
   	push	offset numberOfChars
   	push	13
   	push	offset rightB
   	push	outputHandle
   	call	WriteConsole
   	
;---------------------------------------------------------------------------------------------------
                                                    ; fifth line
	push	NULL
	push	offset numberOfChars
	push	35
	push	offset thirdFifthLine
	push	outputHandle
	call	WriteConsole
	
;---------------------------------------------------------------------------------------------------
                                                    ; sixth line
	push	NULL
	push	offset numberOfChars
	push	23
	push	offset leftC
	push	outputHandle
	call	WriteConsole
	
	push	NULL
	push	offset numberOfChars
	push	10
	push	offset cc
	push	outputHandle
	call	WriteConsole
	
	push	NULL
	push 	offset numberOfChars
	push	2
	push	offset rightC
	push	outputHandle
	call	WriteConsole
	
;---------------------------------------------------------------------------------------------------
                                                    ; seventh line
  	push	NULL
  	push	offset numberOfChars
  	push	35
  	push	offset seventhLine
  	push 	outputHandle
  	call	WriteConsole
    
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
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
	firstLine		db "       ", 
					   0c9h, 0cdh, 0cdh, 0cdh, 0cdh, 
					   0cdh, 0cdh, 0cdh, 0cdh, 0cdh,
					   0cdh, 0bbh, 0ah
	leftA			db "       ", 0bah
	rightA			db 0bah, 0ah
   	thirdLine		db "       ",
   					   0c8h, 0cdh, 0cdh, 0d1h, 0cdh,
   					   0cdh, 0cdh, 0cdh, 0d1h, 0cdh, 
   					   0cdh, 0bch, 0ah
   	fourthLine		db "          ",
   					   0b3h,
   					   "    ",
   					   0b3h, 0ah
   	fifthLine		db "     ",
   					   0dah, 0c4h, 0c4h, 0c4h, 0c4h,
   					   0d9h, 
   					   "    ",
   					   0c0h, 0c4h, 0c4h, 0c4h, 0c4h,
   					   0bfh, 0ah 
   	sixthLine		db "     ",
   					   0b3h,
   					   "              ",
   					   0b3h, 0ah
   	seventhLine		db 0c9h, 0cdh, 0cdh, 0cdh, 0cdh,
   					   0cfh, 0cdh, 0cdh, 0cdh, 0cdh,
   					   0cdh, 0bbh,
   					   "  ",
   					   0c9h, 0cdh, 0cdh, 0cdh, 0cdh,
   					   0cdh, 0cfh, 0cdh, 0cdh, 0cdh,
   					   0cdh, 0bbh, 0ah 				                    
   	left			db 0bah 
 	middle			db 0bah, "  ", 0bah
 	right           db 0bah, 0ah
 	ninthLine		db 0c8h, 0cdh, 0cdh, 0cdh, 0cdh,
 					   0cdh, 0cdh, 0cdh, 0cdh, 0cdh,
 					   0cdh, 0bch,
 					   "  ",
 					   0c8h, 0cdh, 0cdh, 0cdh, 0cdh,
 					   0cdh, 0cdh, 0cdh, 0cdh, 0cdh,
 					   0cdh, 0bch, 0ah
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
    push	20
    push	offset firstLine
    push	outputHandle
    call	WriteConsole
  
;---------------------------------------------------------------------------------------------------
                                                    ; second line
   	push	NULL
   	push	offset numberOfChars
   	push	8
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
   	push	2
   	push	offset rightA
   	push	outputHandle
   	call	WriteConsole
   	
;---------------------------------------------------------------------------------------------------
                                                    ; third line
	push	NULL
	push	offset numberOfChars
	push	20
	push	offset thirdLine
	push	outputHandle
	call	WriteConsole 
	
;---------------------------------------------------------------------------------------------------
                                                    ; fourth line
	push	NULL
	push	offset numberOfChars
	push    17
	push	offset fourthLine
	push	outputHandle
	call	WriteConsole

;---------------------------------------------------------------------------------------------------
                                                    ; fifth line
	push	NULL
	push	offset numberOfChars
	push	22
	push	offset fifthLine
	push 	outputHandle
	call	WriteConsole
	
;---------------------------------------------------------------------------------------------------
                                                    ; sixth line
	push	NULL
	push	offset numberOfChars
	push	22
	push	offset sixthLine
	push	outputHandle
	call	WriteConsole
	
;---------------------------------------------------------------------------------------------------
                                                    ; seventh line
  	push	NULL
  	push	offset numberOfChars
  	push	27
  	push	offset seventhLine
  	push 	outputHandle
  	call	WriteConsole
  	
;---------------------------------------------------------------------------------------------------
	                                                ; eight line
	push	NULL
	push	offset numberOfChars
	push	1
	push	offset left
	push	outputHandle
	call	WriteConsole
	
	push	NULL
	push	offset numberOfChars
	push 	10
	push	offset bb
	push 	outputHandle
	call	WriteConsole
	
	push	NULL
	push	offset numberOfChars
	push 	4
	push	offset middle
	push 	outputHandle
	call	WriteConsole
	
	push	NULL
	push	offset numberOfChars
	push	10
	push	offset cc
	push	outputHandle
	call	WriteConsole
	
	push	NULL
	push	offset numberOfChars 
	push	2
	push	offset right
	push	outputHandle
	call	WriteConsole

;---------------------------------------------------------------------------------------------------
													; ninth line
	push	NULL
	push	offset numberOfChars
	push	27
	push	offset ninthLine
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
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

.data
	template		db "%d ", 0
	array			dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

.data?
	inputHandle		dd ?
	outputHandle	dd ?
	numberOfChars 	dd ?
	buffer			db ?

.code

;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------
                                                                                                    
; void arrayToStr(char* buffer, int* array, int size)
arrayToStr:
	push	EBP
	mov		EBP, ESP
	
	startLoopConvert:
		cmp		dword ptr [ EBP + 16 ], 0
		je		endLoopConvert
		
		mov		EAX, dword ptr [ EBP + 12 ]         ; EAX = offset array[i]
		
		push	dword ptr [ EAX ]
		push	offset template
		push	dword ptr [ EBP + 8 ]
		call	wsprintf   							; form string
		
		add		ESp, 12
		
		add		dword ptr [ EBP + 8 ], EAX
		add		dword ptr [ EBP + 12 ], 4 			; to next element                       
		dec		dword ptr [ EBP + 16 ]
		
		jmp		startLoopConvert
	endLoopConvert:
	
	pop		EBP
ret 12

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
                                                    ; convert array to string
	push	10
	push	offset array
	push	offset buffer
	call	arrayToStr
	
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
TITLE Add and Subtract

; This program adds and subtracts 32-bit integers.
.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD
DumpRegs PROTO

.code
main PROC
	mov eax,10000h
	add eax,40000h
	sub eax,20000h
	call DumpRegs
	INVOKE ExitProcess,0
main ENDP
END main

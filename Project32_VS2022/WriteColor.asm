.386
.model flat,stdcall
.data?
char BYTE ?
.code
main proc
L1: mov ah,06h
; keyboard input
mov dl,0FFh
; don't wait for input
int 21h
jz L1
; no character? repeat loop
mov char,al
; character pressed: save it
call DumpRegs
; display registers
main endp
end main
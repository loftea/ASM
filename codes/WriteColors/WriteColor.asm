TITLE Writing Text Colors (WriteColors.asm)
INCLUDE Irvine32.inc
.data
         outHandle    HANDLE ?
         cellsWritten DWORD ?
         xyPos        COORD <30,3>
    ; Array of character codes:
         buffer       BYTE "Have a iridescent day!"
         BufSize      DWORD ($-buffer)
    ; Array of attributes:
         attributes   WORD 0Fh,0Eh,0Dh,0Ch,0Bh,0Ah,9,8,7,6
         WORD         5,4,3,2,1,2,3,4,5,6,7,8
.code
main PROC
    ; Get the Console standard output handle:
         INVOKE GetStdHandle,STD_OUTPUT_HANDLE
         mov    outHandle,eax
    ; Set the colors of adjacent cells:
         INVOKE WriteConsoleOutputAttribute,
outHandle, ADDR attributes,
BufSize, xyPos, ADDR cellsWritten
    ; Write character codes 1 through 20:
         INVOKE WriteConsoleOutputCharacter,
outHandle, ADDR buffer, BufSize,
xyPos, ADDR cellsWritten
         INVOKE ExitProcess,0
    ; end program
main ENDP
END main
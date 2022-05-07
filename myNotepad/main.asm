title MyNotepad (main.asm)

.386
.model flat, stdcall
include Irvine32.inc
include macros.inc
include SmallWin.inc
include GraphWin.inc// from Irvine32.lib

;======forward declarations=====
WinMain proto :dword, :dword, :dword, dword


;======constants and datra =====
WindowWidth equ 640
WindowHeight equ 480
BUFFER_SIZE equ 5000


;======data======
.data

Classname byte "MyWinClass", 0
AppName byte "MyNotepad",0
WindowName byte "MyNotepad",0

;=====data?=======
.data?
hInstance dword ?
hMainWnd dword ?

buffer byte BUFFER_SIZE dup(?)
filename byte 80 dup(?)
fileHandle HANDLE ?

;===========code==========

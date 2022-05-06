title windows application (winapp.asm)

.386
.model flat, stdcall
include GraphWin.inc
include SmallWin.inc

;======== data =======
.data
AppLoadMsgTitle	byte "Application Loaded",0
AppLoadMsgText	byte "This window displays when the WM_CREATE "
				byte "message is received", 0

PopupTitle	byte "Popup Window", 0
PopupText	byte "This window was activated by a "
			byte "WM_LBUTTONDOWN message", 0

GreetTitle	byte "Main Window Active", 0
GreetText	byte "This window is shown immediately after "
			byte "CreatedWindow and UpdateWindow are called.", 0

CloseMsg	byte "WM_CLOSE msg received", 0

ErrorTitle	byte "Error!",0
WindowName	byte "My windows app",0
className	byte "ASMWin",0

MainWin WNDCLASS <NULL,WinProc,NULL,NULL,NULL,NULL,NULL, \
	COLOR_WINDOW,NULL,className>

msg		MSGStruct <>
winRect	RECT <>
hMainWnd	dword ?
hInstance	dword ?

;========= code =======
.code
WinMain proc

	invoke	GetModuleHandle, NULL
	mov		hInstance, eax
	mov		MainWin.hInstance, eax

	invoke	LoadIcon, NULL, IDI_APPLICATION
	mov		MainWin.hIcon, eax
	invoke	LoadCursor, NULL, IDC_ARROW
	mov MainWin.hCursor, eax

	invoke RegisterClass, addr MainWin
	.if eax == 0
		call ErrorHandler
		jmp Exit_Program
	.endif

	invoke CreateWindowEx, 0, addr className,
		addr WindowName, MAIN_WINDOW_STYLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		CW_USEDEFAULT, NULL, NULL, hInstance, NULL
	.if eax == 0
		call ErrorHandler
		jmp Exit_Program
	.endif

	mov hMainWnd, eax
	invoke ShowWindow, hMainWnd, SW_SHOW
	invoke UpdateWindow, hMainWnd

	invoke MessageBox, hMainWnd, addr GreetText,
		addr GreetTitle, MB_OK

Message_Loop:
	invoke GetMessage, addr msg, NULL,NULL,NULL

	.if eax == 0
		jmp Exit_Program
	.endif

	invoke DispatchMessage, addr msg
	jmp Message_Loop

Exit_Program:
	invoke ExitProcess, 0
WinMain endp

;--------------------------
WinProc proc,
	hWnd:dword, localMsg, wParam, lParam:dword
;
;
;---------------------------
	mov eax, localMsg

	.if eax == WM_LBUTTONDOWN
		invoke MessageBox, hWnd, addr PopupText,
			addr PopupTitle, MB_OK
		jmp WinProcExit
	.elseif eax == WM_CREATE
		invoke MessageBox, hWnd, addr AppLoadMsgText,
			addr AppLoadMsgTitle, MB_OK
		jmp WinProcExit
	.elseif eax == WM_CLOSE
		invoke MessageBox, hWnd, addr CloseMsg,
			addr WindowName, MB_OK
		invoke PostQuitMessage, 0
		jmp WinProcExit
	.else
		invoke DefWindowProc, hWnd, localMsg, wParam, lParam
		jmp WinProcExit
	.endif

WinProcExit:
	ret
WinProc endp

;--------------------------
ErrorHandler proc
;
;--------------------------
.data
pErrorMsg dword ?
messageID dword ?
.code
	invoke GetLastError
	mov messageID, eax

	invoke FormatMessage, FORMAT_MESSAGE_ALLOCATE_BUFFER+\
		FORMAT_MESSAGE_FROM_SYSTEM,NULL,messageID,NULL,
		addr pErrorMsg,NULL,NULL

	invoke MessageBox, NULL,pErrorMsg,addr ErrorTitle,
		MB_ICONERROR+MB_OK

	invoke LocalFree, pErrorMsg
	ret
ErrorHandler endp
end WinMain
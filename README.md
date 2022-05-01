# 编译原理

这个库放置的是本人自学汇编原理的学习笔记，参考课程《汇编与编译原理 (44100593)》的课件，针对的是 MS 的 x86 处理器，其中伪指令集为 MASM。

## Part 1

### 寄存器

寄存器有如下的：

![image-20220501145811036](https://gitee.com/viatec/picture/raw/master/images/image-20220501145811036.png)



其中有一些约定俗成的用法：

- General-Purpose
  - EAX – accumulator
  - ECX – loop counter
  - ESP – stack pointer
  - ESI, EDI – index registers
  - EBP – extended frame pointer (stack)
- Segment
  - CS – code segment
  - DS – data segment
  - SS – stack segment
  - ES, FS, GS - additional segments
- EIP - instruction pointer
- EFLAGS
  - status and control flags
  - each flag is a single binary bit

### 一个汇编程序

我们看如下的汇编程序 AddSubAlt.asm：

```assembly
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

```

在编译的过程中，会先进行编译 (assembly) 然后通过链接 (linker) 得到可执行程序，最后通过 OS loader 得到输出。在编译过程中会产生 Listing File，这个文件可以用来观察程序如何编译的，其包含了以下的：

- 源代码
- 地址
- 目标代码（机器代码）
- 字段 (segment) 名字
- 符号

### 定义数据

内置类型有如下的：

- BYTE, SBYTE
- WORD, SWORD
- DWORD, SDWORD
- QWORD
- TBYTE
- REAL4, REAL8, REAL10

定义数据的语法如：

```assembly
[name] directive initializer [,initializer]...
```

实例如下：

```assembly
value1 BYTE 'A'		; character constant
value2 BYTE 0		; smallest unsigned byte
value3 BYTE 255		; largest unsigned byte
value4 SBYTE -128 	; smallest signed byte
value5 SBYTE +127	; largest signed byte
value6 BYTE ?		; uninitialized byte

list1 	BYTE 10,20,30,40
list2 	BYTE 10,20,30,40
		BYTE 50,60,70,80
		BYTE 81,82,83,84
list3 	BYTE ?,32,41h,00100010b
list4 	BYTE 0Ah,20h,‘A’,22h
```

如果声明字符串，则一般需要以 0 结尾 (null-terminated)，如果声明跨行，以逗号结尾。换行需要加两个字符，分别为 `0Dh, 0Ah` 表示先回车再换行，即 `\r\n`。

我们可以使用 `DUP` 操作符去声明重复的字符，如：

```assembly
var1 BYTE 20 DUP(0) 		; 20 bytes, all equal to zero
var2 BYTE 20 DUP(?) 		; 20 bytes, uninitialized
var3 BYTE 4 DUP("STACK") 	; 20 bytes: "STACKSTACKSTACKSTACK"
var4 BYTE 10, 3 DUP(0), 20 	; 5 bytes
```

存储的位节序分为两种，分别是小端序和大端序，分别表示低位在低位地址和高位在低位地址，x86 处理器属于前者。接下来我们可以用定义变量的方式来完善上面的程序，注意要把变量放到 `.data` 部分。

```assembly
TITLE Add and Subtract, Version 2 (AddSub2.asm)
; This program adds and subtracts 32-bit unsigned
; integers and stores the sum in a variable.
INCLUDE Irvine32.inc

.data
val1 DWORD 10000h
val2 DWORD 40000h
val3 DWORD 20000h
finalVal DWORD ?

.code
main PROC
mov eax,val1	; start with 10000h
add eax,val2	; add 40000h
sub eax,val3	; subtract 20000h
mov finalVal,eax; store the result (30000h)
call DumpRegs	; display the registers
exit
main ENDP
END main
```

使用 `.data?` 得到未初始化的数据字段，在字段内用 `DUP(?)` 得到未初始化的变量。

### 符号化常数 (symbolic constant)

避免扇形修改，我们可以使用符号化常数，格式为：

```assembly
name = expression
```

其中表达式的值为 32 位整数。

使用最近位置计数器 `$` 可以得到最近位置的地址，可以用来计算数列的长度：

```assembly
list BYTE 10,20,30,40
ListSize = ($ - list)
```

使用 `EQU` directive 可以定义不能更改的文字或数字表达式，如：（注意在 `.data` 前）

```assembly
PI EQU <3.1416>
pressKey EQU <"Press any key to continue...",0>
.data
prompt BYTE pressKey
```

相对应地，也可以在 `.data`  内使用 `TEXTEQU` 定义宏（不能定义浮点数！）：

```assembly
continueMsg TEXTEQU <"Do you wish to continue (Y/N)?">
rowSize = 5
.data
prompt1 BYTE continueMsg
count TEXTEQU %(rowSize * 2)	; evaluates the expression
setupAL TEXTEQU <mov al,count>

.code
setupAL		; generates: "mov al,10"
```

64 位的 MASM 不允许出现一些伪指令，如：INVOKE, ADDR, .model, .386, .stack 等。

```assembly
; AddTwoSum_64.asm - Chapter 3 example
ExitProcess PROTO
.data
sum QWORD 0
.code
main PROC
	mov rax,5
	add rax,6
	mov sum,rax
	
	mov ecx,0
	call ExitProcess
main ENDP
END
```

### 数据的运输

数据运输我们使用 `MOV` 语句。注意我们会有如下的规则：

- 语句中最多只有一个内存
- CS, EIP, IP 不能作为数据目标寄存器
- 目标和源类型应该对应
- 立即数不能在句段 `MOV` 操作中出现

我们可以使用 `MOVZX` 语句来进行高位补充 0 的移动操作：

```assembly
mov bl, 10001111b
movzx ax, bl
```

目标必须是寄存器，源不能是立即数。使用 `MOVSX` 则是高位补充 1。

`XCHG` 语句可以交换两个位置的值，其中之一必须为寄存器，立即数不能用于该语句。

直接偏移操作数：

```assembly
.data
arrayB BYTE 10h,20h,30h,40h
.code
mov al,arrayB+1		; AL = 20h
mov al,[arrayB+1]	; alternative notation
```

## Part 2

### 更多的操作

`INC` 和 `DEC` 操作分别表示自加 1 和自减 1：

```assembly
INC destination
DEC destination
```

`NEG` 操作表示取负。`ADD`,  `SUB` 都懂。

### FLAGS

- Zero flag `ZF`：表示目标数是否为 0
- Sign flag `SF`：表示目标数是否为负
- Carry flag `CF`：表示是否溢出（无符号整数）
- Overflow flag `OF`：表示是否超出范围（有符号整数）

### 涉及到地址的操作符

- `OFFSET`：表示字段内偏移量

- `PTR`：表示强制转换。注意如果我们使用该运算符去进行转换数列，结果和大小端有关系。如下：

  ```assembly
  .data
  myBytes BYTE 12h,34h,56h,78h
  .code
  mov ax,WORD PTR [myBytes]	; AX = 3412h
  mov ax,WORD PTR [myBytes+2]	; AX = 7856h
  mov eax,DWORD PTR myBytes	; EAX = 78563412h
  ```

- `TYPE` 操作符返回 $\frac{位数}{byte}$。

- `LENGTHOF` 操作符返回数列的长度（不需要乘以 byte 倍数）

- `SIZEOF` 操作符返回数列的大小（需要乘以 byte 倍数）

  - 注意这两个操作符对于不换行的声明只会读取第一行

- `LABEL` 伪指令，能够使用不同位数的某个变量：

  ```assembly
  .data
  dwList LABEL DWORD
  wordList LABEL WORD
  intList BYTE 00h,10h,00h,20h
  .code
  mov eax,dwList	; 20001000h
  mov cx,wordList	; 1000h
  mov dl,intList	; 00h
  ```

- 变址操作数 `[]`：使用 `[label+reg]` 或 `label[reg]`

### JMP 和 LOOP

```assembly
top:
	.
	.
	jmp top
```

  

```assembly
mov ax,0
mov ecx,5

L1:	add ax,cx
	loop L1
```

逻辑为 `ecx` 自减到 0 之前都会进行 `jmp` 操作。 

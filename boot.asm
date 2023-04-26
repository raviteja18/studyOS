ORG 0
BITS 16
_start:
	jmp short start
	nop
times 33 db 0
start:
	jmp 0x7c0:step2		;sets codesegment register to 0x7c0
	;; instruction pointer points to 0x7c0*16+step2
	;; we are initializing the programme and setting the segment registers

handle_zero:			;first interrupt sevice routine
	mov ah, 0eh
	mov al, 'A'
	mov bx, 0x00
	int 0x10
	iret
handle_one:
	mov ah, 0eh
	mov al, 'V'
	mov bx, 0x00
	int 0x10
	iret
step2:	
	cli			;clear interrupt flags
	mov ax, 0x7c0
	mov ds, ax
	mov es, ax
	mov ax, 0x00
	mov ss, ax
	mov sp, 0x7c00
	sti            		;Enable interrupts

	mov word[ss:0x00], handle_zero
	mov word[ss:0x02],0x7c0

	int 0

	mov word[ss:0x04], handle_one
	mov word[ss:0x06],0x7c0

	int 1
	;; mov ax, 0x00
	;; div ax
	
	mov si, message
	call print
	jmp $ 		;$ represents curernt location. jmps to same location

print:
	mov bx, 0
	; calculating the offset
	; 16*register_name + offset
.loop:
	;e.x lodsb: ds*16 + si = 0x7cxx wrt above code
	lodsb	;lodsb loads the value at si into al register (ds:si)
	cmp al, 0
	je .done
	call print_char
	jmp .loop
.done:
	ret

print_char:
	mov ah, 0eh
	int 0x10
	ret	

message: db "Hello,World!", 0

times 510 - ($ -$$) db 0
;dw 0xAA55  			;dw means define word in memory.
db 0x55
db 0xAA

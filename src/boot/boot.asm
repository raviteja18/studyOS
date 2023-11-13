ORG 0x7c00
BITS 16
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
	
_start:
	jmp short start
	nop
times 33 db 0 			;BIOS  parameter block
start:
	jmp 0:step2		;sets codesegment register to 0x7c0
	;; instruction pointer points to 0x7c0*16+step2
	;; we are initializing the programme and setting the segment registers

step2:	
	cli			;clear interrupt flags
	mov ax, 0		;ax register
	mov ds, ax		;data segment
	mov es, ax		;extra segment
	mov ss, ax		;stack segment
	mov sp, 0x7c00		;stack pointer
	sti            		;Enable interrupts
.load_protected:
	cli			;Clear interrupts
	lgdt[gdt_descriptor]
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax
	jmp CODE_SEG:load32
gdt_start:
gdt_null:
	dd 0x0
	dd 0x0
	;; offset 0x8
gdt_code:			;CS should point to this
	dw 0xffff		;segment limit first 0-15 bits
	dw 0			;Base 0-15 bits
	db 0			;Base 16-23 bits
	db 0x9a			;Access byte
	db 11001111b		;High four bit flags and low four bit flags
	db 0			;base 24-31 bits
	;; offset 0x10
gdt_data:			;DS, SS, GS, ES, FS
	dw 0xffff		;segment limit first 0-15 bits
	dw 0
	db 0
	db 0x92
	db 11001111b
	db 0
gdt_end:
gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start

BITS 32
load32:
	jmp $
	mov eax, 1		;load the first sector from storage medium.
	mov ecx, 100		;total number of sectors to read
	mov edi, 0x0100000	;load the data at the address 0x0100000
	call ata_lba_read
	jmp CODE_SEG:0x0100000
ata_lba_read:
	mov ebx, eax		;backup the LBA
	;; Sedning the highest 8 bits of the LBA
	shr eax, 24		;shift right by 24 bits
	or eax, 0xe0		;Selects the masters drive
	mov dx, 0x1f6		;out port
	out dx, al
	;; Finished sending the highest 8bits of the LBA

	;; Send the total sectors to read
	mov eax, ecx
	mov dx, 0x1f2
	out dx, al
	;; Finished sending total sectors to read

	;; Sending more bits of LBA
	mov dx, 0x1f4
	mov eax, ebx
	shr eax, 8
	out dx, al

	;; Send upper 16 bits of LBA
	mov dx, 0x1f5
	mov eax, ebx
	shr eax, 16
	out dx, al

	mov dx, 0x1f7
	mov al, 0x20
	out dx, al
.next_sector:
	push ecx
.try_again:
	mov dx, 0x1f7
	in al, dx
	test al, 8
	jz .try_again

	mov ecx, 256
	mov dx, 0x1f0
	rep insw
	pop ecx
	loop .next_sector
	;; end of reading sectors
	ret
times 510 - ($ -$$) db 0
dw 0xAA55  			;dw means define word in memory.
 				;db means define byte in memory
				;dd means define double word in memory	
;;; lodsb uses DS:SI combination 16*DS + SI

section .asm
global idt_load
global int21h	
global no_interrupt
global enable_interrupts
global disable_interrupts
	
extern int21h_handler
extern no_interrupt_handler

enable_interrupts:
	sti
	ret

disable_interrupts:
	cli
	ret

idt_load:
	push ebp
	mov ebp, esp

	mov ebx, [ebp+8]
	lidt [ebx]
	pop ebp
	ret

int21h:
	cli
	pushad
	call int21h_handler
	sti
	popad
	iret

no_interrupt:
	cli
	pushad
	call no_interrupt_handler
	sti
	popad
	iret

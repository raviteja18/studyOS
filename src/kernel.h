#ifndef KERNEL_H
#define KERNEL_H

#define TERMINAL_ADDRESS 0xB8000

#define RED 4
#define WHITE 15

#define VGA_WIDTH 80
#define VGA_HEIGHT 20

void kernel_main();
void print(char *str);

#endif

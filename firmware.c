/*
 * MiniSoC Firmware
 * Basic functionality for testing the MiniSoC design
 */

#include <stdint.h>

// Memory-mapped registers
#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data   (*(volatile uint32_t*)0x02000008)
#define reg_spictrl     (*(volatile uint32_t*)0x02000000)
#define reg_leds        (*(volatile uint32_t*)0x03000000)

// Simple UART functions
void my_putchar(char c) {
    if (c == '\n') my_putchar('\r');
    reg_uart_data = c;
}

void print(const char *str) {
    while (*str) my_putchar(*(str++));
}

void print_hex(uint32_t val, int digits) {
    for (int i = digits-1; i >= 0; i--) {
        char c = "0123456789abcdef"[(val >> (4*i)) & 0xF];
        my_putchar(c);
    }
}

// Memory test function
int memtest() {
    volatile uint32_t *mem = (uint32_t*)0x00000000;
    const int test_size = 64; // Test first 64 words
    
    // Write pattern
    for (int i = 0; i < test_size; i++) {
        mem[i] = 0xDEAD0000 + i;
    }
    
    // Verify pattern
    for (int i = 0; i < test_size; i++) {
        if (mem[i] != (0xDEAD0000 + i)) {
            return 0; // Test failed
        }
    }
    
    return 1; // Test passed
}

// Main function
void main() {
    // Initialize UART (assuming 12MHz clock, 115200 baud)
    reg_uart_clkdiv = 104; // 12MHz / 104 = ~115200 baud
    
    // Initialize SPI control
    reg_spictrl = 0;
    
    // LED test pattern
    for (int i = 0; i < 8; i++) {
        reg_leds = (1 << i);
        for (volatile int j = 0; j < 100000; j++); // Delay
    }
    reg_leds = 0;
    
    print("\nMiniSoC Firmware\n");
    print("===============\n\n");
    
    // Run memory test
    print("Running memory test... ");
    if (memtest()) {
        print("PASSED\n");
    } else {
        print("FAILED\n");
    }
    
    // Main loop
    while (1) {
        print("\nMenu:\n");
        print("1. Test UART echo\n");
        print("2. Read SPI control register\n");
        print("3. Toggle LEDs\n");
        print("Select option: ");
        
        // Wait for character
        char c;
        while (!(reg_uart_data & 0x80000000)); // Wait for data available
        c = reg_uart_data;
        my_putchar(c); // Echo
        
        print("\n");
        
        switch (c) {
            case '1':
                print("UART echo mode (send '!' to exit)\n");
                while (1) {
                    while (!(reg_uart_data & 0x80000000));
                    c = reg_uart_data;
                    my_putchar(c);
                    if (c == '!') break;
                }
                break;
                
            case '2':
                print("SPI control register: 0x");
                print_hex(reg_spictrl, 8);
                print("\n");
                break;
                
            case '3':
                reg_leds = ~reg_leds;
                print("LEDs toggled\n");
                break;
                
            default:
                print("Invalid option\n");
                break;
        }
    }
}

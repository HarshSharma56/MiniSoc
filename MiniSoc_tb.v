`timescale 1ns/1ps

module MiniSoc_tb;
    reg clk = 0;
    reg resetn = 0;
    wire ser_tx;
    
    // Instantiate MiniSoc
    MiniSoc uut (
        .clk(clk),
        .resetn(resetn),
        .ser_tx(ser_tx),
        .ser_rx(1'b0),  // No input
        // Flash interface (virtual)
        .flash_csb(),
        .flash_clk(),
        .flash_io0_oe(),
        .flash_io1_oe(),
        .flash_io2_oe(),
        .flash_io3_oe(),
        .flash_io0_do(),
        .flash_io1_do(),
        .flash_io2_do(),
        .flash_io3_do(),
        .flash_io0_di(1'b0),
        .flash_io1_di(1'b0),
        .flash_io2_di(1'b0),
        .flash_io3_di(1'b0),
        // IRQs
        .irq_5(1'b0),
        .irq_6(1'b0),
        .irq_7(1'b0)
    );
    
    // 10MHz clock
    always #5 clk = ~clk;
    
    // Virtual Flash Content
    reg [7:0] virtual_flash [0:256*1024-1]; // 256KB flash
    
    // UART Receiver
    reg [7:0] uart_rx_data;
    reg uart_rx_valid = 0;
    
    initial begin
        $dumpfile("minisoc1.vcd");
        $dumpvars(0, MiniSoc_tb);
        
        // Initialize virtual flash
        $readmemh("firmware.hex", virtual_flash);
        
        // Preload first 1KB to RAM (simulates bootloader)
        for (integer i = 0; i < 1024; i = i + 4) begin
            uut.memory.mem[i/4] = {virtual_flash[i+3], virtual_flash[i+2], 
                                  virtual_flash[i+1], virtual_flash[i]};
        end
        
        // Reset sequence
        #100 resetn = 1;
        
        // Run simulation
        #100000 $display("Simulation complete");
        $finish;
    end
    
    // Monitor UART output
    always @(posedge clk) begin
        if (uut.simpleuart.reg_dat_we) begin
            $write("%c", uut.simpleuart.reg_dat_di[7:0]);
            $fflush();
        end
    end
    
    // Simulate SPI Flash responses
    always @(posedge uut.flash_clk) begin
        if (!uut.flash_csb) begin
            // Simulate simple flash responses
            // (Replace with actual flash behavior if needed)
        end
    end
endmodule

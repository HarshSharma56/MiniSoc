`timescale 1ns/1ps

module tb_MiniSoc;

    // Clock and Reset
    reg clk = 0;
    reg resetn = 0;
    always #5 clk = ~clk;  // 100 MHz clock

    // DUT I/O
    wire        iomem_valid;
    wire        iomem_ready;
    wire [3:0]  iomem_wstrb;
    wire [31:0] iomem_addr;
    wire [31:0] iomem_wdata;
    wire [31:0] iomem_rdata;

    // IRQ inputs
    reg irq_5 = 0, irq_6 = 0, irq_7 = 0;

    // UART
    wire ser_tx;
    reg  ser_rx = 1;
	
    // SPI Flash
    wire flash_csb, flash_clk;
    wire flash_io0_oe, flash_io1_oe, flash_io2_oe, flash_io3_oe;
    wire flash_io0_do, flash_io1_do, flash_io2_do, flash_io3_do;
    reg  flash_io0_di = 0, flash_io1_di = 0, flash_io2_di = 0, flash_io3_di = 0;

    // Memory response
    reg [31:0] iomem_rdata_reg = 0;
    assign iomem_rdata = iomem_rdata_reg;
    assign iomem_ready = 1; // Always ready for test

    // Instantiate DUT
    MiniSoc uut (
        .clk(clk),
        .resetn(resetn),
        .iomem_valid(iomem_valid),
        .iomem_ready(iomem_ready),
        .iomem_wstrb(iomem_wstrb),
        .iomem_addr(iomem_addr),
        .iomem_wdata(iomem_wdata),
        .iomem_rdata(iomem_rdata),
        .irq_5(irq_5),
        .irq_6(irq_6),
        .irq_7(irq_7),
        .ser_tx(ser_tx),
        .ser_rx(ser_rx),
        .flash_csb(flash_csb),
        .flash_clk(flash_clk),
        .flash_io0_oe(flash_io0_oe),
        .flash_io1_oe(flash_io1_oe),
        .flash_io2_oe(flash_io2_oe),
        .flash_io3_oe(flash_io3_oe),
        .flash_io0_do(flash_io0_do),
        .flash_io1_do(flash_io1_do),
        .flash_io2_do(flash_io2_do),
        .flash_io3_do(flash_io3_do),
        .flash_io0_di(flash_io0_di),
        .flash_io1_di(flash_io1_di),
        .flash_io2_di(flash_io2_di),
        .flash_io3_di(flash_io3_di)
    );

    // Trace & stimulus
    initial begin
        $dumpfile("MiniSoc_tb.vcd");
        $dumpvars(0, tb_MiniSoc);

        $display("INFO: Starting simulation...");
        
        // Initialize inputs
        resetn = 0;
        ser_rx = 1;
        flash_io0_di = 1;
        flash_io1_di = 1;
        
        // Release reset
        #100 resetn = 1;
        $display("INFO: Reset released");

        // Test sequence
        test_memory_access();
        test_uart_communication();
        test_spi_flash();
        test_irq_handling();

        $display("INFO: Simulation completed");
        #100 $finish;
    end

    // ----------------------
    // Test Tasks
    // ----------------------

    task test_memory_access;
        begin
            $display("TEST: Memory Access Test");
            
            // Wait for memory access
            @(posedge iomem_valid);
            $display("PASS: Memory access detected at address 0x%h", iomem_addr);
            
            // Provide dummy response
            iomem_rdata_reg = 32'hDEADBEEF;
        end
    endtask

    task test_uart_communication;
        begin
            $display("TEST: UART Communication Test");
            
            // Wait for UART transmission
            wait(ser_tx !== 1'b1);
            $display("PASS: UART transmission started");
            
            // Simulate UART reception
            #100;
            ser_rx = 0; // Start bit
            #8680;
            ser_rx = 1; // Data bit 0 (LSB)
            #8680;
            ser_rx = 0; // Data bit 1
            #8680;
            ser_rx = 1; // Stop bit
            $display("INFO: Simulated UART byte received");
        end
    endtask

    task test_spi_flash;
        begin
            $display("TEST: SPI Flash Test");
            
            // Wait for SPI flash access
            wait(!flash_csb);
            $display("PASS: SPI Flash selected");
            
            // Simulate flash response
            repeat (10) @(posedge flash_clk)
                flash_io1_di = $random;
        end
    endtask

    task test_irq_handling;
        begin
            $display("TEST: IRQ Handling Test");
            
            // Trigger IRQ 5
            #1000;
            irq_5 = 1;
            #100;
            irq_5 = 0;
            $display("PASS: IRQ 5 triggered");
        end
    endtask

endmodule

# 🚀 Custom RISC-V SoC Design (Based on PicoSoC)

This project is a modified System-on-Chip (SoC) built on top of the **PicoSoC** architecture. It features a customized **PicoRV32** CPU core with changes to the control FSM and removal of the PCPI interface.
A new testbench has been written to verify the design under simulation using Verilog tools.

---

## 🔧 Key Highlights

- 🧠 **RISC-V Core**: Based on PicoRV32 (RV32IMC)
- ❌ **PCPI Removed**: Simplified datapath by eliminating the Pico Co-Processor Interface
- ⚙️ **FSM Tweaks**: Modified CPU control logic to suit custom use-case
- 🧪 **Testbench**: Written from scratch to verify SoC functionality
- 🧰 **Toolchain**: Verilog simulation with Icarus Verilog, GTKWave, RISC-V GCC

---

## 📁 File Overview

| File                     | Description                                  |
|--------------------------|----------------------------------------------|
| `MiniSoc.v`              | Top-level SoC design                          |
| `MiniSoc_tb.v`           | Custom testbench for simulation               |
| `picorv32.v`             | Modified RISC-V core (PCPI removed)           |
| `firmware.c`             | Bare-metal firmware for SoC                   |
| `linker_script.ld`       | Linker script for placing code in memory      |
| `simpleuart.v`           | UART peripheral                               |
| `spimemio.v`, `spiflash.v` | SPI flash interface                        |
| `testsoc.v`              | Additional test module                        |
| `MiniSoc_schematic.png`  | Schematic/block diagram of the SoC            |

---

## 🔬 How to Simulate

1. **Compile the firmware** using RISC-V GCC:
   ```bash
   riscv32-unknown-elf-gcc -o firmware.elf firmware.c -T linker_script.ld -nostartfiles -nostdlib
2. convert firmware to hex file :
   riscv32-unknown-elf-objcopy -O verilog firmware.elf firmware.hex
3. run simulation using icarus verilog :
    iverilog -o soc_sim.vvp MiniSoc.v picorv32.v MiniSoc_tb.v
    vvp soc_sim.vvp
4. view waveform :
    gtkwave dump.vcd

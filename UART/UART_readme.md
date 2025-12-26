## Notes

This repository does **not** provide a single command to automatically build and program the UART.v file - in it's current state the counter.v file will be built and programmed 

### Top Module Requirement
The Gowin synthesiser requires the top-level module to be named `top`.  
Before building, rename the module in `uart.v` from `uart` to `top`.

### Building and Programming
To build and program the design:
1. Open a new project.
2. Import all files from this folder into the project.
3. Use the FPGA Toolchain to Build and Program
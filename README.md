# FPGA 3Display

Final project for MIT 6.2050 Digital Systems Laboratory.
> Let's make a hologram!

*jtma, lkronman, nfelleke*

##  Vivado Compilation and FPGA Programming
Designed for CMOD-A7 35T FPGA. Compilation done remotely via MIT's [**lab-bc**](https://dspace.mit.edu/handle/1721.1/151412?show=full) (and on jts computer):
```
git clone https://github.com/liamkronman/FPGA-3Display.git
cd FPGA-3Display
lab-bc run .
openFPGALoader -b cmoda7_35t obj/final.bit
```
To flash instead of normal programming (for power through slip ring during rotation):
`openFPGALoader -b cmoda7_35t -f obj/final.bit`

## DEMO
[**Link.**](https://www.youtube.com/watch?v=dmettyEq79U)

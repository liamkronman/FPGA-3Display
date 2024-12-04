#!/usr/bin/env python3

import subprocess
import shutil
import argparse

VIVADO_PATH = '/tools/Xilinx/Vivado/2024.1/bin/vivado'
HAS_VIVADO = shutil.which(VIVADO_PATH) is not None

VIVADO_COMPILE = [f'{VIVADO_PATH} -mode batch -source build.tcl -nojournal -log ./log/vivado.log']
LAB_COMPILE = ['lab-bc run ./ obj']

TABLE_COMMANDS = ['./scripts/fill_tables.py']

def main():

    parser = argparse.ArgumentParser(description='Build script for FPGA project')
    parser.add_argument('-r', type=int, help='Resolution parameter')

    # Parse arguments
    args = parser.parse_args()
    resolution = args.r if args.r else 64

    # creates the /log and /obj directories
    subprocess.run('mkdir -p log obj', shell=True)

    if HAS_VIVADO:
        TABLE_COMMANDS.extend(VIVADO_COMPILE)
        print('Vivado found, using Vivado to build project')
    else:
        TABLE_COMMANDS.extend(LAB_COMPILE)
        print('Vivado not found, using Lab-BC to build project')

    for command in TABLE_COMMANDS:
        subprocess.run(command, shell=True)


if __name__ == '__main__':
    main()
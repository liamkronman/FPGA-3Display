#!/usr/bin/env python3

import subprocess
import shutil

VIVADO_PATH = '/tools/Xilinx/Vivado/2024.1/bin/vivado'

HAS_VIVADO = shutil.which(VIVADO_PATH) is not None

VIVADO_COMPILE = [f'{VIVADO_PATH} -mode batch -source build.tcl -nojournal -log ./log/vivado.log']
LAB_COMPILE = ['lab-bc run ./ obj']

TABLE_COMMANDS = ['./scripts/fill_tables.py']

def main():

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
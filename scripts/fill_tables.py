#!/usr/bin/env python3

import numpy as np

def arctan_2_lookup(resolution=64, ranges=32, filepath="./data/arctan2.mem"):
    """
    This function creates a lookup table for the arctan2 function.
    The table is a 2D array of size ranges*2 x ranges*2.
    All values are in the range [0, resolution], as opposed to [0, 2*pi].
    This function creates the table and saves it in the given filepath as a
    .mem file, in hex format
    
    Args:
    resolution: int, the resolution of the lookup table
    ranges: int, the range of the input values, from -ranges to ranges
    filepath: str, the path to save the lookup table

    Returns:
    None
    """

    table = np.zeros((ranges*2, ranges*2), dtype=int)

    for x in range(-ranges, ranges):
        for y in range(-ranges, ranges):
            table[x+ranges][y+ranges] = int((np.arctan2(y, x) + np.pi) \
                                             * resolution / (2*np.pi))

    with open(filepath, 'w') as f:
        for row in table:
            for value in row:
                f.write(f'{value:02x}\n')


def sqrt_lookup():
    pass

def main():
    arctan_2_lookup()
    sqrt_lookup()

if __name__ == '__main__':
    main()
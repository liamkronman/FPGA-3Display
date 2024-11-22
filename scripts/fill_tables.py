#!/usr/bin/env python3

import numpy as np
import matplotlib.pyplot as plt

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
    np.array: 2D numpy array, the lookup
    """

    table = np.zeros((ranges*2, ranges*2), dtype=int)

    for x in range(-ranges, ranges):
        for y in range(-ranges, ranges):
            table[x+ranges][y+ranges] = int((np.arctan2(x, y) + np.pi) \
                                             * (resolution-1) / (2*np.pi))

    with open(filepath, 'w') as f:
        for row in table:
            for value in row:
                f.write(f'{value:02x}\n')

    return table


def distance_2D(resolution=32, ranges=32, filepath="./data/distance_2D.mem"):
    """
    This function creates a lookup table for the distance from the origin.
    The table is a 2D array of size ranges x ranges.
    All values are in the range [0, resolution].
    This function creates the table and saves it in the given filepath as a
    .mem file, in hex format

    Args:
    resolution: int, the resolution of the lookup table
    ranges: int, the range of the input values, from -ranges to ranges
    filepath: str, the path to save the lookup table

    Returns:
    np.array: 2D numpy array, the lookup
    """

    table = np.zeros((ranges, ranges), dtype=int)

    for x in range(ranges):
        for y in range(ranges):
            table[x][y] = int(np.sqrt(x**2 + y**2) \
                                             * resolution / ranges)

    with open(filepath, 'w') as f:
        for row in table:
            for value in row:
                f.write(f'{value:02x}\n')
    return table


def show_table(array):

    fig, ax = plt.subplots()
    cax = ax.matshow(array, cmap='viridis')
    fig.colorbar(cax)

    plt.show()


def main():
    atan_table = arctan_2_lookup()
    # distance_origin_table = distance_origin_2D()
    distance_table = distance_2D()
    show_table(distance_table)

if __name__ == '__main__':
    main()
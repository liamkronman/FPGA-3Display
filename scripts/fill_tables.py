#!/usr/bin/env python3

import numpy as np
import matplotlib.pyplot as plt

from distribute_points import plot_fibonacci_spiral

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

def arctan_2_fibonacci_lookup(resolution=64, ranges=32, filepath="./data/arctan2_fibonacci.mem"):
    """
    This function creates a lookup table for the arctan2 function. This is
    different than a normal arctan2 lookup table in that it uses a fibonacci
    spiral to map the values. The result is better optimized for a rotary
    display.
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

    fib_thetas, fib_radii = plot_fibonacci_spiral(num_points=resolution,
                                                    radius=ranges,
                                                    constrain=True,
                                                    display=False)
    # Shift thetas cw by pi/2
    fib_thetas -= np.pi/2

    fib_thetas = fib_thetas[::-1]
    fib_radii = fib_radii[::-1]

    fib_points_cartesian = np.array([fib_radii * np.cos(fib_thetas),
                                     fib_radii * np.sin(fib_thetas)]).T

    table = np.zeros((ranges*2, ranges*2), dtype=int)

    for x in range(-ranges, ranges):
        for y in range(-ranges, ranges):
            closest_index = np.argmin(np.linalg.norm(fib_points_cartesian - np.array([x, y]), axis=1))
            # table[x+ranges][y+ranges] = int((closest_index) * (resolution-1) / 64) # WHY WOULD IT GENERATE THIS???
            table[x+ranges][y+ranges] = closest_index

    with open(filepath, 'w') as f:
        for row in table:
            for value in row:
                f.write(f'{value:02x}\n')

    return table, fib_thetas, fib_radii

def test_rot_frame_buffer(rotational_res=32, filepath="./data/rot_frame_buffer_2.mem"):
    """
    This function creates a lookup table for the rotational frame buffer.
    The table is a 1D array of size rotational_res.
    
    Args:
    rotational_res: int, the resolution of the lookup table
    filepath: str, the path to save the lookup table
    """

    data = [i + rotational_res//2 for i in range(rotational_res//2)]


    with open(filepath, 'w') as f:
        for value in data:
            f.write(f'{value:02x}\n')

    return data

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
    # atan_table = arctan_2_lookup()
    atan_fib_table, _, _ = arctan_2_fibonacci_lookup(resolution=64)
    # distance_origin_table = distance_origin_2D()
    distance_table = distance_2D()
    # frame_buffer = test_rot_frame_buffer()

    # show_table(atan_table)
    show_table(atan_fib_table)
    # show_table(distance_table)

if __name__ == '__main__':
    main()
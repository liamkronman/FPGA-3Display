import numpy as np
import matplotlib.pyplot as plt
from fill_tables import arctan_2_fibonacci_lookup
from bitarray import bitarray

def create_cube(size=32):
    """
    This function makes a list of points that
    make up the edges of a cube. The cube is centered at
    32, 32, 32, with a side length of 32
    """

    cube = []

    for i in range(size):
        cube.append([i, 0, 0])
        cube.append([i, size, 0])
        cube.append([i, 0, size])
        cube.append([i, size, size])

        cube.append([0, i, 0])
        cube.append([size, i, 0])
        cube.append([0, i, size])
        cube.append([size, i, size])

        cube.append([0, 0, i])
        cube.append([size, 0, i])
        cube.append([0, size, i])
        cube.append([size, size, i])

    for point in cube:
        for i in range(3):
            point[i] += 16

    return cube


def plot_cube():
    cube = create_cube()

    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')


    for point in cube:
        ax.scatter(point[0], point[1], point[2])

    plt.show()

    return cube


def fit_z(z, height=64):

    return 1<<z


def project_fibonacci(points, resolution=256):
    
    table, thetas, radii = arctan_2_fibonacci_lookup(resolution=resolution)
    # projected_points = np.zeros((len(thetas)), dtype=int)

    projected_points = [0 for _ in range(len(thetas))]
    radii = [int(radius) for radius in radii]

    table_radii = [radius<<64 for radius in radii]
    # print(table_radii)

    for x, y, z in points:
        idx = table[x][y]

        projected_points[idx] |= fit_z(z)

    # print(projected_points)

    projected_points = [point | table_radii[i] for i, point in enumerate(projected_points)]

    return projected_points


def decode_point(projected_point):
    # print(projected_point)
    radius = projected_point>>64
    # print(radius)

    z = []

    # for i in range(64):
    #     if (1 << i) & projected_point:
    #         z.append(i)

    # bits = bitarray(bin(projected_point)[2:].zfill(64))
    bits = bitarray(bin(projected_point)[2:].zfill(64+5))
    # print(bits)

    for i in range(64):
        if bits[i+5]:
            z.append(i)

    return radius, z

def plot_projected_fibonacci(projected_points):

    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')


    for theta, point in enumerate(projected_points):
        radius, z = decode_point(point)
        # print(z)

        theta = theta*2*np.pi/len(projected_points)

        for z_val in z:
            ax.scatter(radius*np.cos(theta), radius*np.sin(theta), z_val, color='r')

    plt.show()


def create_cube_fibonnacci_table(resolution=512, display=True, 
                                 filenames=("./data/cube_buffer_1.mem", "./data/cube_buffer_2.mem")):
    cube = create_cube()

    projected_points = project_fibonacci(cube, resolution=resolution)
    if display:
        plot_projected_fibonacci(projected_points)

    # first half stored in first file
    with open(filenames[0], 'w') as f:
        for point in projected_points[:len(projected_points)//2]:
            f.write(f'{point:02x}\n')

    # second half stored in second file
    with open(filenames[1], 'w') as f:
        for point in projected_points[len(projected_points)//2:]:
            f.write(f'{point:02x}\n')

    return projected_points


def main():
    # cube = plot_cube()

    # print(len(cube))
    create_cube_fibonnacci_table(1024)

if __name__ == "__main__":
    main()
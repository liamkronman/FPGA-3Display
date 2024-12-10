import numpy as np
import trimesh
import argparse

def obj_to_point_cloud(obj_file_name, grid_size=64):
    # Load the OBJ file
    mesh = trimesh.load(obj_file_name, force='mesh')

    # Extract vertex coordinates
    vertices = np.array(mesh.vertices)

    # Normalize coordinates to fit within the grid
    min_bounds = vertices.min(axis=0)
    max_bounds = vertices.max(axis=0)
    scale = (grid_size - 1) / (max_bounds - min_bounds)
    normalized_vertices = (vertices - min_bounds) * scale

    # Round to the nearest grid points and ensure integers
    grid_points = np.floor(normalized_vertices).astype(int)

    # Remove duplicate points
    unique_points = np.unique(grid_points, axis=0)

    # Clip points to ensure they are within bounds
    unique_points = np.clip(unique_points, 0, grid_size - 1)

    # Convert to a binary grid (optional visualization or processing)
    point_cloud_grid = np.zeros((grid_size, grid_size, grid_size), dtype=bool)
    for point in unique_points:
        point_cloud_grid[tuple(point)] = True

    # int cast all the points
    unique_points = unique_points.astype(int)

    return unique_points, point_cloud_grid


if __name__=="__main__":
    # specific to Liam's path
    argparser = argparse.ArgumentParser()
    # if the first arg is a 0, do the bunny. if it's a 1, do the tie fighter
    argparser.add_argument("arg1", type=int)
    args = argparser.parse_args()
    if args.arg1 == 0:
        obj_file = "/Users/liamkronman/Documents/GitHub/6.2050/3display/assets/stanford_bunny.obj"
        points, grid = obj_to_point_cloud(obj_file)
        print(points)
        # save grid to csv file. needs to be parsed from 2D numpy array
        np.savetxt("assets/bunny_point_cloud2.csv", grid.reshape(-1, grid.shape[-1]), delimiter=",", fmt="%d")
        np.savetxt("assets/bunny_point_cloud.csv", points, delimiter=",", fmt='%i')
        # np.save("assets/cube_point_cloud.npy", grid)
    elif args.arg1 == 1:
        obj_file = "/Users/liamkronman/Documents/GitHub/6.2050/3display/assets/tie_fighter.obj"
        points, grid = obj_to_point_cloud(obj_file)
        print(points)
        # save grid to csv file. needs to be parsed from 2D numpy array
        np.savetxt("assets/tie_fighter2.csv", grid.reshape(-1, grid.shape[-1]), delimiter=",", fmt="%d")
        np.savetxt("assets/tie_fighter.csv", points, delimiter=",", fmt='%i')
        # np.save("assets/cube_point_cloud.npy", grid)
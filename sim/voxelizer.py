import numpy as np
import trimesh

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

    return unique_points, point_cloud_grid


if __name__=="__main__":
    # specific to Liam's path
    obj_file = "/Users/liamkronman/Documents/GitHub/6.2050/3display/assets/stanford_bunny.obj"
    points, grid = obj_to_point_cloud(obj_file)
    print(points)
    np.save("cube_point_cloud.npy", grid)
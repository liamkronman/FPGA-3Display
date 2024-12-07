import numpy as np

def generate_voxel_sphere(radius, voxel_size=1):
    """
    Generate voxel points for a sphere centered at the origin.
    
    Parameters:
    -----------
    radius : float
        Radius of the sphere
    voxel_size : float, optional
        Size of each voxel (default is 1)
    
    Returns:
    --------
    numpy.ndarray
        Array of (x, y, z) coordinates representing points inside the sphere
    """
    # Calculate the range of coordinates to check
    # We'll use ceil to ensure we cover the entire sphere
    coord_range = int(np.ceil(radius / voxel_size))
    
    # Create lists to store voxel points
    sphere_points = []
    
    # Iterate through potential voxel coordinates
    for x in range(-coord_range, coord_range + 1):
        for y in range(-coord_range, coord_range + 1):
            for z in range(-coord_range, coord_range + 1):
                # Calculate the actual coordinates
                point_x = x * voxel_size
                point_y = y * voxel_size
                point_z = z * voxel_size
                
                # Check if point is inside the sphere
                # Use distance formula from origin
                distance = np.sqrt(point_x**2 + point_y**2 + point_z**2)
                
                # If distance is less than or equal to radius, include the point
                if round(distance) <= radius:
                    sphere_points.append((point_x, point_y, point_z))
    
    # Convert to numpy array for efficiency
    return np.array(sphere_points)

# Example usage
def main():
    # Generate a sphere with radius 5
    sphere_points = generate_voxel_sphere(radius=5)
    
    print(f"Total voxel points: {len(sphere_points)}")
    print("First 10 points:")
    print(sphere_points[:10])
    
    # Optional: Visualization example (requires matplotlib)
    try:
        import matplotlib.pyplot as plt
        from mpl_toolkits.mplot3d import Axes3D
        
        fig = plt.figure(figsize=(10, 8))
        ax = fig.add_subplot(111, projection='3d')
        
        # Scatter plot of sphere points
        ax.scatter(sphere_points[:, 0], 
                   sphere_points[:, 1], 
                   sphere_points[:, 2], 
                   c='blue', 
                   alpha=0.1, 
                   marker='o')
        
        ax.set_xlim(-32, 32)
        ax.set_ylim(-32, 32)
        ax.set_zlim(-32, 32)

        ax.set_box_aspect((1,1,1))

        
        ax.set_title('Voxelized Sphere')
        ax.set_xlabel('X')
        ax.set_ylabel('Y')
        ax.set_zlabel('Z')
        
        plt.show()
    except ImportError:
        print("Matplotlib not available for visualization")

if __name__ == "__main__":
    main()
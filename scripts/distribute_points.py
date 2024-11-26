import matplotlib.pyplot as plt
import numpy as np




def distribute_points(radius, outer_resolution):

    ratio = outer_resolution / radius
    points = []

    for c_radius in range(1, radius+1):

        num_points = int(ratio * c_radius)
        points.append(num_points)

    return points

def plot_distributed_points(points):

    radius = len(points)

    fig = plt.figure()
    ax = fig.add_subplot(111, projection='polar')

    outward_theta =2*np.pi/points[-1]
    theta_inc =outward_theta/len(points)

    for c_radius in range(radius):

        num_points = points[c_radius]
        theta = np.linspace(0, 2*np.pi, num_points) + c_radius*theta_inc
        r = np.ones(num_points) * (c_radius+1)

        ax.scatter(theta, r)

    plt.show()


def create_fibonacci_spiral(num_points):

    phi = (3 - np.sqrt(5)) * np.pi

    thetas = np.arange(0, num_points) * phi
    thetas %= 2 * np.pi
    
    radii = np.sqrt(np.arange(0, num_points)) / np.sqrt(num_points)

    combined = np.array([thetas, radii]).T

    #sort by ascending radii
    combined = combined[combined[:,0].argsort()]

    thetas = combined[:,0]
    
    radii = combined[:,1]


    return thetas, radii, 

def plot_fibonacci_spiral(num_points, radius, constrain=False, display=True):

    thetas, radii = create_fibonacci_spiral(num_points)

    max_radius = max(radii)
    # max_theta = max(thetas)

    if constrain:
        radii = radii / max_radius * (radius - 1)
        radii = radii.astype(int)

        # makes thetas a normal distribution up to 2pi
        thetas = np.linspace(0, 2*np.pi, num_points)


    if display:
        fig = plt.figure()
        ax = fig.add_subplot(111, projection='polar')

        ax.scatter(thetas, radii + 0.5)

        plt.show()

    return thetas, radii


def main():

    radius = 32
    # outer_resolution = 64
    num_points = 64

    thetas, radii = plot_fibonacci_spiral(num_points, radius, constrain=True)

    print(radii )

    print(thetas*num_points/(2*np.pi))



    return

    points = distribute_points(radius, outer_resolution)

    print(points)

    plot_distributed_points(points)

    # print(points)


if __name__ == "__main__":
    main()
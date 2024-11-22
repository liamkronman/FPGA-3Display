import matplotlib.pyplot as plt
import numpy as np


class Display:
    def __init__(self, angular_resolution=64):
        self.fig = plt.figure()
        self.ax = self.fig.add_subplot(111, projection='3d')
        self.angular_resolution = angular_resolution

    def plot_cartesian(self, x, y, z):
        self.ax.scatter(x, y, z, color='blue')

    def plot_cylindrical(self, r, theta, z):
        r_theta = theta/(self.angular_resolution) * 2 * np.pi + np.pi

        x = r * np.cos(r_theta) + 32
        y = r * np.sin(r_theta) + 32

        # plot the points in a red color
        self.ax.scatter(x, y, z, color='red')

    def show(self, show_cylinder=True):
        self.ax.set_xlim(0, 64)
        self.ax.set_ylim(0, 64)
        self.ax.set_zlim(0, 64)
        self.ax.set_xlabel('X')
        self.ax.set_ylabel('Y')
        self.ax.set_zlabel('Z')

        # plots a cylinder with radius 32 and height 64
        if show_cylinder:
            z = np.linspace(0, 64, 100)
            theta = np.linspace(0, 2*np.pi, 100)
            theta, z = np.meshgrid(theta, z)
            x = 32 * np.cos(theta) + 32
            y = 32 * np.sin(theta) + 32
            self.ax.plot_surface(x, y, z, alpha=0.2)

        plt.show()


def test_sphere():
    num_points = 1000
    r = np.random.randint(0, 32, num_points)
    theta = np.random.randint(0, 64, num_points)
    z = np.random.randint(0, 64, num_points)

    display = Display()

    display.plot_cylindrical(r, theta, z)

    display.show()

def test_arctan2():
    num_points = 1000
    x = np.random.randint(-32, 32, num_points)
    y = np.random.randint(-32, 32, num_points)

    display = Display()

    display.plot_cartesian(x, y, np.arctan2(y, x))

    display.show()


def main():
    # num_points = 1000
    # x = np.random.randint(0, 64, num_points)
    # y = np.random.randint(0, 64, num_points)
    # z = np.random.randint(0, 64, num_points)

    # display = Display()

    # display.plot_cartesian(x, y, z)

    # display.show()

    test_sphere()
    # test_arctan2()

if __name__ == "__main__":
    main()
import warnings

import matplotlib.image as mpimg
import numpy as np
from sklearn.cluster import MiniBatchKMeans


def extract_dominant_colors(image_path: str, n_colors: int):
    # Suppress FutureWarning
    warnings.simplefilter(action='ignore', category=FutureWarning)

    # Load the image using mpimg.imread()
    image = mpimg.imread(image_path)

    # Resize the image to reduce computation time
    image = image[::2, ::2]

    # Get the dimensions (width, height, and depth) of the image
    w, h, d = tuple(image.shape)

    # Reshape the image into a 2D array, where each row represents a pixel
    pixel = np.reshape(image, (w * h, d))

    # Create a MiniBatchKMeans model with the specified number of clusters and fit it to the pixels
    model = MiniBatchKMeans(n_clusters=n_colors, random_state=42, batch_size=1000).fit(pixel)

    # Get the cluster labels and counts
    labels, counts = np.unique(model.labels_, return_counts=True)

    # Get the cluster centers (representing colors) from the model
    colour_palette = np.uint8(model.cluster_centers_)

    # Convert RGB values to hex format
    hex_palette = ['#{:02x}{:02x}{:02x}'.format(r, g, b) for r, g, b in colour_palette]

    # Sort hex_palette based on counts in descending order
    sorted_hex_palette = [x for _, x in sorted(zip(counts, hex_palette), reverse=True)]

    return sorted_hex_palette


# region color
def hex_to_rgb(hex_color):
    """Convert hex color to RGB."""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))


def is_red(rgb):
    """Check if RGB values correspond to red."""
    r, g, b = rgb
    return r > 150 and g < 100 and b < 100


def is_pink(rgb):
    """Check if RGB values correspond to pink."""
    r, g, b = rgb
    return r > 200 and g < 150 and b > 150


def is_black(rgb):
    """Check if RGB values correspond to black."""
    r, g, b = rgb
    return r < 50 and g < 50 and b < 50


def is_yellow(rgb):
    """Check if RGB values correspond to yellow."""
    r, g, b = rgb
    return r > 150 and g > 150 and b < 100


def is_green(rgb):
    """Check if RGB values correspond to green."""
    r, g, b = rgb
    return r < 100 and g > 150 and b < 100


def is_white(rgb):
    """Check if RGB values correspond to white."""
    r, g, b = rgb
    return r > 200 and g > 200 and b > 200


def is_gray(rgb):
    """Check if RGB values correspond to gray."""
    r, g, b = rgb
    return r > 100 and r < 200 and g > 100 and g < 200 and b > 100 and b < 200


def is_blue(rgb):
    """Check if RGB values correspond to blue."""
    r, g, b = rgb
    return r < 100 and g < 100 and b > 150


def is_brown(rgb):
    """Check if RGB values correspond to brown."""
    r, g, b = rgb
    return r > 50 and r < 150 and g > 30 and g < 100 and b < 70


def color_name_from_hex(hex_color):
    """Get the name of the nearest common color from a hex color."""
    rgb = hex_to_rgb(hex_color)

    # Initialize variables to track the closest color
    min_distance = float('inf')
    closest_color_name = None

    # Check each predefined color
    for color_name, color_func in COLOR_FUNCTIONS.items():
        if color_func(rgb):
            return color_name
        else:
            # Calculate distance to this color
            distance = sum((rgb[i] - COMMON_COLORS[color_name][i]) ** 2 for i in range(3))
            if distance < min_distance:
                min_distance = distance
                closest_color_name = color_name

    return closest_color_name


# Dictionary mapping color names to their RGB values
COMMON_COLORS = {"Red": (255, 0, 0), "Pink": (255, 192, 203), "Black": (0, 0, 0), "Yellow": (255, 255, 0),
                 "Green": (0, 128, 0), "White": (255, 255, 255), "Gray": (128, 128, 128), "Blue": (0, 0, 255),
                 "Brown": (165, 42, 42), }

# Dictionary mapping color names to their detection functions
COLOR_FUNCTIONS = {"Red": is_red, "Pink": is_pink, "Black": is_black, "Yellow": is_yellow, "Green": is_green,
                   "White": is_white, "Gray": is_gray, "Blue": is_blue, "Brown": is_brown, }

# endregion


if __name__ == '__main__':
    # Example usage
    hex_color = "#15da41"
    print("Color:", is_yellow(hex_to_rgb(hex_color)))

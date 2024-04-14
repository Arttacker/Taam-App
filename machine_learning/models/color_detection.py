import warnings
from sklearn.cluster import MiniBatchKMeans
import numpy as np
import matplotlib.image as mpimg


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
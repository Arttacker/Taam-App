import warnings
from sklearn.cluster import MiniBatchKMeans
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import time

warnings.simplefilter(action='ignore', category=FutureWarning)
start_time = time.time()

# Load the image using mpimg.imread(). Use a raw string (prefix r) or escape the backslashes.
image = mpimg.imread(r'Path/to/image/file')

# Resize the image to reduce computation time
image = image[::2, ::2]

# Get the dimensions (width, height, and depth) of the image
w, h, d = tuple(image.shape)

# Reshape the image into a 2D array, where each row represents a pixel
pixel = np.reshape(image, (w * h, d))

# Set the desired number of colors for the image
n_colors = 5

# Create a MiniBatchKMeans model with the specified number of clusters and fit it to the pixels
model = MiniBatchKMeans(n_clusters=n_colors, random_state=42, batch_size=1000).fit(pixel)

# Get the cluster centers (representing colors) from the model
colour_palette = np.uint8(model.cluster_centers_)

# Convert RGB values to hex format
hex_palette = ['#{:02x}{:02x}{:02x}'.format(r, g, b) for r, g, b in colour_palette]

# Display the color palette as an image
plt.imshow([colour_palette])

# Show the plot
# plt.show()

end_time = time.time()
execution_time = end_time - start_time
print("Execution Time: {:.2f} seconds".format(execution_time))
print("Color Palette (RGB):", colour_palette)
print("Color Palette (Hex):", hex_palette)
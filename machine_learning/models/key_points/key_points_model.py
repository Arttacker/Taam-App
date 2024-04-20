from fastai.vision.all import *
from torch.nn import Module
import pathlib
from os import path
from machine_learning.global_paths import *

temp = pathlib.PosixPath
pathlib.PosixPath = pathlib.WindowsPath


def read_landmarks_for_category():
    pass


# Define a custom architecture for keypoints detection
class KeypointsModel(Module):
    def __init__(self):
        pass

    def forward(self, x):
        features = self.backbone(x)
        keypoints = self.head(features)
        return keypoints


def plot_image_with_landmarks(image, landmarks):
    plt.imshow(image)

    # Extract x, y coordinates from the first tensor in landmarks
    x_coordinates = landmarks[0][:, 0]  # Extract x coordinates
    y_coordinates = landmarks[0][:, 1]  # Extract y coordinates

    # Plot landmarks as red dots
    plt.scatter(x_coordinates, y_coordinates, color='red', marker='o', s=5)

    # Annotate each point with its index
    for i, (x, y) in enumerate(zip(x_coordinates, y_coordinates)):
        plt.text(x, y, str(i), fontsize=8, color='blue')

    plt.show()


def load_key_points_model(model):
    return load_learner(model, cpu=True)


def predict(image_path, model, img_size=224):
    # Load and preprocess the image
    image = Image.open(image_path)
    # Convert the image to RGB mode (if it's not already)
    image = image.convert('RGB')
    image = image.resize((img_size, img_size))
    image_np = np.array(image)

    # Make predictions
    landmarks_pred = model.predict(image)

    # Plot image with predicted landmarks
    plot_image_with_landmarks(image_np, landmarks_pred)
    return landmarks_pred[0].tolist()


if __name__ == '__main__':
    pass


import os
import requests
from ..models.image_search import image_search
from ..models import card_detection
from . import database


def is_image_already_exist(filename, dir) -> bool:
    existing_files = os.listdir(dir)
    if filename in existing_files:
        return True
    else:
        return False


def download_image(image_url, dest="machine_learning/images/") -> bool:
    # Send a GET request to the URL to download the image

    # Extract the filename from the URL
    filename = image_url.split('%')[1].split('?')[0][2:]
    if is_image_already_exist(filename, dest):
        return True
    else:
        response = requests.get(image_url)
        if response.status_code == 200:
            # Open the file in binary write mode and write the content of the response
            with open(dest + filename, "wb") as f:
                f.write(response.content)
            return True
        else:
            return False


def load_image_search_model():
    # Define paths
    model_architecture_path = 'machine_learning/models/image_search/mobilenet_model.json'
    model_weights_path = 'machine_learning/models/image_search/mobilenet_model_weights.weights.h5'
    # Load model
    model = image_search.load_model(model_architecture_path, model_weights_path)
    return model


def fill_database(model):
    # Initialize database connection
    conn, cursor = database.connect_to_database()
    database.create_images_table(cursor)

    # List all images
    images = os.listdir('machine_learning/images')
    for image_file in images:
        # Define paths
        img_path = os.path.join('machine_learning/images', image_file)

        # Extract features from image
        image_vector = image_search.extract_features(img_path, model)
        # Store in database
        database.insert_image(conn, cursor, img_path, image_vector)


# ######################################################################################################################
# from ..models.key_points.pickels.model_loader import get_learner, predict

# def calculate_size(image) -> tuple:
#     # Extracting the card from the image and Getting measurement of it
#     # card_measurement = card_detection.get_pixel_measure(image)
#     model = get_learner()
#     predict(image, model)
#     width = 0
#     height = 0
#     size = ''
#     return width, height, size


from fastapi import status, HTTPException
import os
import cv2
import requests
from PIL import Image
from io import BytesIO
from machine_learning.app import database
from machine_learning.models.image_search import image_search
import matplotlib.pyplot as plt
from machine_learning.models import card_detection
from machine_learning.models.key_points.key_points_model import *
from machine_learning.models.agrigorev.garments_classifier import *
from machine_learning.global_paths import (
    IMAGES,
    IMAGE_SEARCH_MODEL,
    KEY_POINTS_MODEL_long_sleeve_dress,
    KEY_POINTS_MODEL_long_sleeve_outwear,
    KEY_POINTS_MODEL_long_sleeve_top,
    KEY_POINTS_MODEL_short_sleeve_dress,
    KEY_POINTS_MODEL_short_sleeve_top,
    KEY_POINTS_MODEL_short_sleeve_outwear,
    KEY_POINTS_MODEL_shorts,
    KEY_POINTS_MODEL_skirt,
    KEY_POINTS_MODEL_sling,
    KEY_POINTS_MODEL_sling_dress,
    KEY_POINTS_MODEL_vest,
    KEY_POINTS_MODEL_vest_dress,
    KEY_POINTS_MODEL_trousers,
)


CATEGORIES = ['Top', 'Other', 'Hoodie', 'Body', 'Dress', 'Polo', 'Shorts', 'Shirt', 'Shoes', 'Undershirt',
              'Skip', 'Long Sleeve', 'Blouse', 'T-Shirt', 'Pants', 'Skirt', 'Outwear', 'Blazer', 'Hat']


MALE_CATEGORIES = categories = ['T-Shirt', 'Blazer', 'Shirt', 'Pants', 'Outwear', 'Polo', 'Hoodie', 'Shoes', 'Long Sleeve', 'Shorts']
FEMALE_CATEGORIES = ['Top', 'Body', 'Skirt', 'Dress', 'Blouse', 'Undershirt', 'Hat', 'Other', 'Skip']


SUMMER_SEASON = ['T-Shirt', 'Skirt', 'Polo', 'Shorts', 'Skirt', 'Shoes', 'Undershirt', 'Hat', 'Skip', 'Top', 'Outwear', 'Body', 'Dress']
WINTER_SEASON = ['Long Sleeve', 'Hoodie', 'Other', 'Pants', 'Blazer', 'Blouse']


def is_image_already_exist(filename, dir) -> bool:
    existing_files = os.listdir(dir)
    if filename in existing_files:
        return True
    else:
        return False


def download_image(image_url, dest=IMAGES) -> bool:
    # Send a GET request to the URL to download the image

    # Extract the filename from the URL
    filename = image_url.split('%')[1].split('?')[0][2:]
    if is_image_already_exist(filename, dest):
        return True
    else:
        response = requests.get(image_url)
        if response.status_code == 200:
            # Open the file in binary write mode and write the content of the response
            with open(path.join(dest, filename), "wb") as f:
                f.write(response.content)
            return True
        else:
            return False


def load_image_search_model():
    # Define paths
    model_architecture_path = os.path.join(IMAGE_SEARCH_MODEL, 'mobilenet_model.json')
    model_weights_path = os.path.join(IMAGE_SEARCH_MODEL, 'mobilenet_model_weights.weights.h5')
    # Load model
    model = image_search.load_model(model_architecture_path, model_weights_path)
    return model


def fill_database(model):
    # Initialize database connection
    conn, cursor = database.connect_database()
    database.create_images_table(cursor)

    # List all images
    images = os.listdir(IMAGES)
    for image_file in images:
        # Define paths
        img_path = os.path.join(IMAGES, image_file)

        # Extract features from image
        image_vector = image_search.extract_features(img_path, model)
        # Store in database
        database.insert_image(conn, cursor, img_path, image_vector)

    database.close_database_connection(conn)


def crop_image(image, bounding_box):
    # Crop image according to bounding box
    cropped_image = image.crop((bounding_box[0], bounding_box[1], bounding_box[2], bounding_box[3]))
    return cropped_image


def crop_image_for_color_detection(image_path, landmarks, img_size=224):
    image = Image.open(image_path)
    image = image.resize((img_size, img_size))
    x_coordinates = [point[0] for point in landmarks]
    y_coordinates = [point[1] for point in landmarks]

    # Filter Outliers
    filtered_x = sorted(set(x for x in x_coordinates if (x > img_size / 8 and x < img_size - img_size / 8)))
    filtered_y = sorted(set(y for y in y_coordinates if (y > img_size / 8 and y < img_size - img_size / 8)))

    x1 = np.mean(filtered_x[:4])
    y1 = np.mean(filtered_y[-4:])
    x2 = np.mean(filtered_x[-4:])
    y2 = np.mean(filtered_y[:4])

    points = [x1, y2, x2, y1]
    cropped_image = crop_image(image, points)

    # plt.imshow(cropped_image)
    # plt.show()

    return cropped_image


def classify_season(category) -> str:
    season = ''
    if category in SUMMER_SEASON:
        season = 'summer'
    elif category in WINTER_SEASON:
        season = 'winter'

    return season


def classify_gender(category) -> str:
    gender = ''
    if category in MALE_CATEGORIES:
        gender = 'male'
    elif category in FEMALE_CATEGORIES:
        gender = 'female'

    return gender


def get_waist(key_points, reference_width_measurement, real_standard_width_of_reference=8.5) -> float:

    """
    Calculate the waist width based on key points and card dimensions.

    :param key_points: A list of key points relevant to the measurement.
    :type key_points: list
    :param reference_width_measurement: Measurement of the width taken from a reference.
    :type reference_width_measurement: float
    :param real_standard_width_of_reference: the real width dimension of the reference
    :type real_standard_width_of_reference: float
    :return: The calculated waist length.
    :rtype: float

    """
    len_key_points = len(key_points)
    left_waist = right_waist = [0, 0]
    if len_key_points in [8, 10, 14]:  # 'skirt' & 'shorts' & 'trousers'
        left_waist = key_points[0]
        right_waist = key_points[2]
    elif len_key_points == 19:  # 'vest dress' & 'sling dress'
        left_waist = key_points[9]
        right_waist = key_points[15]
    elif len_key_points == 29:  # 'short sleeve dress'
        left_waist = key_points[14]
        right_waist = key_points[20]
    elif len_key_points == 37:  # 'long sleeve dress'
        left_waist = key_points[17]
        right_waist = key_points[25]
    elif len_key_points == 15:  # 'vest' & 'sling'
        left_waist = key_points[8]
        right_waist = key_points[12]

    waist_width = right_waist[0] - left_waist[0]
    waist_width = waist_width * real_standard_width_of_reference / reference_width_measurement
    return float("{:.4f}".format(waist_width))


def get_hips(key_points, reference_width_measurement, real_standard_width_of_reference=8.5) -> float:
    """

    Calculate the hips width based on key points and a reference dimensions.

    :param key_points: A list of key points relevant to the measurement.
    :type key_points: list
    :param reference_width_measurement: Measurement of the width taken from a reference.
    :type reference_width_measurement: float
    :param real_standard_width_of_reference: the real width dimension of the reference
    :type real_standard_width_of_reference: float
    :return: The calculated hips length.
    :rtype: float
    """
    hips_width = 0.0
    right_hip = left_hip = [0, 0]
    len_key_points = len(key_points)
    if len_key_points == 14:  # 'trousers'
        left_hip = key_points[3]
        right_hip = key_points[13]
    elif len_key_points == 10:  # 'shorts'
        left_hip = key_points[3]
        right_hip = key_points[9]
    elif len_key_points == 8:  # 'skirt'
        left_hip = key_points[3]
        right_hip = key_points[7]

    hips_width = right_hip[0] - left_hip[0]
    hips_width = hips_width * real_standard_width_of_reference / reference_width_measurement
    return float("{:.4f}".format(hips_width))


def get_chest_width(key_points, reference_width_measurement, real_standard_width_of_reference=8.5) -> float:
    """

    Calculate the chest width based on key points and a reference dimensions.

    :param key_points: A list of key points relevant to the measurement.
    :type key_points: list
    :param reference_width_measurement: Measurement of the width taken from a reference.
    :type reference_width_measurement: float
    :param real_standard_width_of_reference: the real width dimension of the reference
    :type real_standard_width_of_reference: float
    :return: The calculated hips length.
    :rtype: float
    """
    right_chest = left_chest = [0, 0]
    len_key_points = len(key_points)
    if len_key_points == 25:  # 'short sleeve top' & 'short sleeve outwear'
        left_chest = key_points[11]
        right_chest = key_points[19]

    elif len_key_points == 33:  # 'long sleeve top' & 'long short sleeve outwear'
        left_chest = key_points[15]
        right_chest = key_points[23]

    elif len_key_points == 15:  # 'vest' & 'sling'
        left_chest = key_points[7]
        right_chest = key_points[13]

    elif len_key_points == 29:  # 'short sleeve dress'
        left_chest = key_points[12]
        right_chest = key_points[22]

    elif len_key_points == 37:  # 'long sleeve dress'
        left_chest = key_points[16]
        right_chest = key_points[26]

    elif len_key_points == 19:  # 'vest dress' & 'sling dress'
        left_chest = key_points[7]
        right_chest = key_points[17]

    chest_width = right_chest[0] - left_chest[0]
    chest_width = chest_width * real_standard_width_of_reference / reference_width_measurement
    return float("{:.4f}".format(chest_width))


def get_height(key_points, reference_height_measurement, real_standard_height_of_reference=5.5) -> float:
    """

    Calculate the height based on the number of key points and a reference dimensions.

    :param key_points: A list of key points relevant to the measurement.
    :type key_points: list
    :param reference_height_measurement: Measurement taken from a card.
    :type reference_height_measurement: float
    :param real_standard_height_of_reference: the real height dimension of the reference
    :type real_standard_height_of_reference: float
    :return: The calculated waist length.
    :rtype: float
    """
    right_top = left_top = right_bottom = left_bottom = [0, 0]
    len_key_points = len(key_points)
    # Check the number of key_points to calculate the height accordingly

    if len_key_points == 25:  # 'short sleeve top' & 'short sleeve outwear'
        left_top = key_points[6]
        right_top = key_points[24]

        left_bottom = key_points[14]
        right_bottom = key_points[16]

    elif len_key_points == 31:  # 'long short sleeve outwear'
        left_top = key_points[6]
        right_top = key_points[24]

        left_bottom = key_points[14]
        right_bottom = key_points[16]

    elif len_key_points == 33:  # 'long sleeve top'
        left_top = key_points[6]
        right_top = key_points[32]

        left_bottom = key_points[18]
        right_bottom = key_points[20]

    elif len_key_points == 39:  # 'long short sleeve outwear'
        left_top = key_points[1]
        right_top = key_points[5]

        left_bottom = key_points[18]
        right_bottom = key_points[20]

    elif len_key_points == 15:  # 'vest' & 'sling'
        left_top = key_points[6]
        right_top = key_points[14]

        left_bottom = key_points[9]
        right_bottom = key_points[11]

    elif len_key_points == 10:  # 'shorts'
        left_top = key_points[0]
        right_top = key_points[2]

        left_bottom = key_points[4]
        right_bottom = key_points[8]

    elif len_key_points == 14:  # 'trousers'
        left_top = key_points[0]
        right_top = key_points[2]

        left_bottom = key_points[5]
        right_bottom = key_points[11]

    elif len_key_points == 8:  # 'skirt'
        left_top = key_points[0]
        right_top = key_points[2]

        left_bottom = key_points[5]
        right_bottom = key_points[6]

    elif len_key_points == 29:  # 'short sleeve dress'
        left_top = key_points[6]
        right_top = key_points[28]

        left_bottom = key_points[16]
        right_bottom = key_points[18]

    elif len_key_points == 37:  # 'long sleeve dress'
        left_top = key_points[6]
        right_top = key_points[36]

        left_bottom = key_points[20]
        right_bottom = key_points[22]

    elif len_key_points == 19:  # 'vest dress' & 'sling dress'
        left_top = key_points[6]
        right_top = key_points[18]

        left_bottom = key_points[11]
        right_bottom = key_points[13]

    left_height = left_bottom[1] - left_top[1]
    right_height = right_bottom[1] - right_top[1]
    # Getting the average of the two measures
    avg_height = (left_height + right_height) / 2
    piece_height = avg_height * real_standard_height_of_reference / reference_height_measurement
    return float("{:.4f}".format(piece_height))


def calculate_down_wear_size(key_points, reference_width_measurement, reference_height_measurement) -> tuple:
    waist = get_waist(key_points, reference_width_measurement)
    height = get_height(key_points, reference_height_measurement)

    if waist < 36.5:
        size = 'XS'
    elif 36.5 < waist < 40.5:
        size = 'S'
    elif 40.5 < waist < 44.5:
        size = 'M'
    elif 44.5 < waist < 48.5:
        size = 'L'
    elif 48.5 < waist < 52:
        size = 'XL'
    elif 52 < waist:
        size = 'XXL'
    return waist, height, size


def calculate_top_wear_size(key_points, reference_width_measurement, reference_height_measurement) -> tuple:
    chest = get_chest_width(key_points, reference_width_measurement)
    height = get_height(key_points, reference_height_measurement)
    if chest < 44.5:
        size = 'XS'
    elif 44.5 < chest < 48.5:
        size = 'S'
    elif 48.5 < chest < 52:
        size = 'M'
    elif 52 < chest < 56:
        size = 'L'
    elif 56 < chest < 59.5:
        size = 'XL'
    elif 59.5 < chest:
        size = 'XXL'
    return chest, height, size


def calculate_dress_size(key_points, reference_width_measurement, reference_height_measurement) -> tuple:
    waist = get_waist(key_points, reference_width_measurement)
    height = get_height(key_points, reference_height_measurement)
    if waist < 36.5:
        size = 'XS'
    elif 36.5 < waist < 40.5:
        size = 'S'
    elif 40.5 < waist < 44.5:
        size = 'M'
    elif 44.5 < waist < 48.5:
        size = 'L'
    elif 48.5 < waist < 52:
        size = 'XL'
    elif 52 < waist:
        size = 'XXL'
    return waist, height, size


def get_suitable_key_points_model(category):
    # Choosing the most suitable model to get the key points
    if category == 'Pants':
        return load_key_points_model(KEY_POINTS_MODEL_trousers)
    elif category == 'Shorts':
        return load_key_points_model(KEY_POINTS_MODEL_shorts)
    elif category == 'Skirt':
        return load_key_points_model(KEY_POINTS_MODEL_skirt)
    elif category == 'Dress':
        return load_key_points_model(KEY_POINTS_MODEL_sling_dress)
    elif category in ['Long Sleeve', 'Shirt', 'Blazer', 'Outwear', 'Hoodie']:
        return load_key_points_model(KEY_POINTS_MODEL_long_sleeve_top)
    elif category in ['T-Shirt', 'Polo', 'Blouse']:
        return load_key_points_model(KEY_POINTS_MODEL_short_sleeve_top)
    elif category in ['Body']:
        return load_key_points_model(KEY_POINTS_MODEL_vest)
    elif category in ['Top', 'Undershirt']:
        return load_key_points_model(KEY_POINTS_MODEL_sling)
    elif category in ['Skip', 'Other', 'Hat', 'Shoes']:
        return None
    else:
        return None


def calculate_size(image_path, category) -> tuple:
    # First Try Extracting the card from the image and Getting measurement of it
    try:
        # This code might raise the ValueError, if no cards detected in the given image.
        card_w, card_h = card_detection.get_pixel_measure(image_path)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No references detected in the image.")

    # Choosing the most suitable model to get the key points
    suitable_model = get_suitable_key_points_model(category)
    if suitable_model is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No suitable key points model found for the given category.")

    # Getting the key points of in the cloth after deciding the used model
    key_points = predict(image_path, suitable_model)

    # Checking the type of the clothes if it is top or down wear
    if category in ['Pants', 'Shorts', 'Skirt']:
        return calculate_down_wear_size(key_points, card_w, card_h), key_points
    elif category == 'Dress':
        return calculate_dress_size(key_points, card_w, card_h), key_points
    else:
        return calculate_top_wear_size(key_points, card_w, card_h), key_points


def remove_bg(image):
    # Remove the background
    output = remove(image)

    # Convert RGBA to RGB before saving as JPEG
    if output.mode == 'RGBA':
        output = output.convert('RGB')
    return output


def open_image_from_url(url):
    response = requests.get(url)
    image = Image.open(BytesIO(response.content))
    return image


if __name__ == '__main__':
    # Load the trained models
    # garment_model = load_garment_classifier_model(GARMENTS_CLASSIFIER_MODEL)
    # key_points_model = load_key_points_model(KEY_POINTS_MODEL_vest)
    # image_path = os.path.join(IMAGES, 'shoes3.jpg')
    # predict_category(image_path, garment_model)
    #
    # key_points = predict(image_path, key_points_model)
    # print(key_points)
    # crop_image_for_color_detection(image_path, key_points)
    # w, h = card_detection.get_pixel_measure(image_path)
    # piece_height = get_piece_height(key_points, h)
    # print(piece_height)
    pass
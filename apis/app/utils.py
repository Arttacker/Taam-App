from fastapi import status, HTTPException
from os import path
import cv2
import requests
from PIL import Image
from io import BytesIO
import numpy as np
from apis.app import database
from machine_learning.models.image_search import image_search
import matplotlib.pyplot as plt
from machine_learning.models import card_detection
from machine_learning.models.key_points.key_points_model import *
from machine_learning.models.agrigorev.garments_classifier import *
from apis.global_paths import *

CATEGORIES = ['Top', 'Other', 'Hoodie', 'Body', 'Dress', 'Polo', 'Shorts', 'Shirt', 'Shoes', 'Undershirt',
              'Skip', 'Long Sleeve', 'Blouse', 'T-Shirt', 'Pants', 'Skirt', 'Outwear', 'Blazer', 'Hat']
MALE_CATEGORIES = categories = ['T-Shirt', 'Blazer', 'Shirt',
                                'Pants', 'Outwear', 'Polo', 'Hoodie', 'Shoes', 'Long Sleeve', 'Shorts']
FEMALE_CATEGORIES = ['Top', 'Body', 'Skirt', 'Dress', 'Blouse',
                     'Undershirt', 'Hat', 'Other', 'Skip']
SUMMER_SEASON = ['T-Shirt', 'Skirt', 'Polo', 'Shorts', 'Skirt',
                 'Shoes', 'Undershirt', 'Hat', 'Skip', 'Top', 'Outwear', 'Body', 'Dress']
WINTER_SEASON = ['Long Sleeve', 'Hoodie', 'Other',
                 'Pants', 'Blazer', 'Blouse']


def is_image_already_exist(filename, dir) -> bool:
    existing_files = os.listdir(dir)
    if filename in existing_files:
        return True
    else:
        return False


def download_image(image_url, dest=IMAGES) -> bool:
    # Send a GET request to the URL to download the image

    # Extract the filename from the URL
    filename = extract_filename_from_url(image_url)
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


def remove_outliers(data, thresh=1):
    data = np.array(data)
    mean = np.mean(data)
    std_div = np.std(data)
    return [x for x in data if (abs(x - mean) / std_div) < thresh]


def get_width(key_points, reference_width_measurement, real_standard_width_of_reference=8.5) -> float:
    width_differences = []
    len_key_points = len(key_points)
    if len_key_points == 25:  # 'short sleeve top'

        left_p1 = key_points[6]
        right_p1 = key_points[24]
        width_differences.append(right_p1[0] - left_p1[0])

        left_p2 = key_points[11]
        right_p2 = key_points[19]
        width_differences.append(right_p2[0] - left_p2[0])

        left_p3 = key_points[12]
        right_p3 = key_points[18]
        width_differences.append(right_p3[0] - left_p3[0])

        left_p4 = key_points[13]
        right_p4 = key_points[17]
        width_differences.append(right_p4[0] - left_p4[0])

        left_p5 = key_points[14]
        right_p5 = key_points[16]
        width_differences.append(right_p5[0] - left_p5[0])

    elif len_key_points in [33, 39]:  # 'long sleeve top' & 'long sleeve outwear'
        left_p1 = key_points[6]
        right_p1 = key_points[32]
        width_differences.append(right_p1[0] - left_p1[0])

        left_p2 = key_points[15]
        right_p2 = key_points[23]
        width_differences.append(right_p2[0] - left_p2[0])

        left_p3 = key_points[16]
        right_p3 = key_points[22]
        width_differences.append(right_p3[0] - left_p3[0])

        left_p4 = key_points[17]
        right_p4 = key_points[21]
        width_differences.append(right_p4[0] - left_p4[0])

        left_p5 = key_points[18]
        right_p5 = key_points[20]
        width_differences.append(right_p5[0] - left_p5[0])

    elif len_key_points == 31:  # 'short sleeve outwear'

        left_p1 = key_points[6]
        right_p1 = key_points[24]
        width_differences.append(right_p1[0] - left_p1[0])

        left_p2 = key_points[11]
        right_p2 = key_points[19]
        width_differences.append(right_p2[0] - left_p2[0])

        left_p3 = key_points[12]
        right_p3 = key_points[18]
        width_differences.append(right_p3[0] - left_p3[0])

        left_p4 = key_points[13]
        right_p4 = key_points[17]
        width_differences.append(right_p4[0] - left_p4[0])

        left_p5 = key_points[14]
        right_p5 = key_points[16]
        width_differences.append(right_p5[0] - left_p5[0])

    elif len_key_points == 15:  # 'vest' & 'sling'

        left_p1 = key_points[6]
        right_p1 = key_points[14]
        width_differences.append(right_p1[0] - left_p1[0])

        left_p2 = key_points[7]
        right_p2 = key_points[13]
        width_differences.append(right_p2[0] - left_p2[0])

        left_p3 = key_points[8]
        right_p3 = key_points[12]
        width_differences.append(right_p3[0] - left_p3[0])

        left_p4 = key_points[9]
        right_p4 = key_points[11]
        width_differences.append(right_p4[0] - left_p4[0])

    elif len_key_points == 10:  # 'shorts'

        left_p1 = key_points[0]
        right_p1 = key_points[2]
        width_differences.append(right_p1[0] - left_p1[0])

        left_p2 = key_points[3]
        right_p2 = key_points[9]
        width_differences.append(right_p2[0] - left_p2[0])

        left_p3 = key_points[4]
        right_p3 = key_points[8]
        width_differences.append(right_p3[0] - left_p3[0])

    elif len_key_points == 14:  # 'trousers'

        left_p1 = key_points[0]
        right_p1 = key_points[2]
        width_differences.append(right_p1[0] - left_p1[0])

        left_p2 = key_points[3]
        right_p2 = key_points[13]
        width_differences.append(right_p2[0] - left_p2[0])

        left_p3 = key_points[4]
        right_p3 = key_points[12]
        width_differences.append(right_p3[0] - left_p3[0])

        left_p4 = key_points[5]
        right_p4 = key_points[11]
        width_differences.append(right_p4[0] - left_p4[0])

    elif len_key_points == 8:  # 'skirt'

        left_p1 = key_points[0]
        right_p1 = key_points[2]
        width_differences.append(right_p1[0] - left_p1[0])

        left_p2 = key_points[3]
        right_p2 = key_points[7]
        width_differences.append(right_p2[0] - left_p2[0])

    elif len_key_points == 29:  # 'short sleeve dress'

        left_p1 = key_points[11]
        right_p1 = key_points[23]
        width_differences.append(right_p1[0] - left_p1[0])

        left_p2 = key_points[12]
        right_p2 = key_points[22]
        width_differences.append(right_p2[0] - left_p2[0])

        left_p3 = key_points[13]
        right_p3 = key_points[21]
        width_differences.append(right_p3[0] - left_p3[0])

        left_p4 = key_points[14]
        right_p4 = key_points[20]
        width_differences.append(right_p4[0] - left_p4[0])

        left_p5 = key_points[15]
        right_p5 = key_points[19]
        width_differences.append(right_p5[0] - left_p5[0])

    elif len_key_points == 37:  # 'long sleeve dress'

        left_p1 = key_points[15]
        right_p1 = key_points[27]
        width_differences.append(right_p1[0] - left_p1[0])

        left_p2 = key_points[16]
        right_p2 = key_points[26]
        width_differences.append(right_p2[0] - left_p2[0])

        left_p3 = key_points[17]
        right_p3 = key_points[25]
        width_differences.append(right_p3[0] - left_p3[0])

        left_p4 = key_points[18]
        right_p4 = key_points[24]
        width_differences.append(right_p4[0] - left_p4[0])

        left_p5 = key_points[19]
        right_p5 = key_points[23]
        width_differences.append(right_p5[0] - left_p5[0])

    elif len_key_points == 19:  # 'vest dress & sling dress'

        left_p1 = key_points[6]
        right_p1 = key_points[18]
        width_differences.append(right_p1[0] - left_p1[0])

        left_p2 = key_points[7]
        right_p2 = key_points[17]
        width_differences.append(right_p2[0] - left_p2[0])

        left_p3 = key_points[8]
        right_p3 = key_points[16]
        width_differences.append(right_p3[0] - left_p3[0])

        left_p4 = key_points[9]
        right_p4 = key_points[15]
        width_differences.append(right_p4[0] - left_p4[0])

        left_p5 = key_points[10]
        right_p5 = key_points[14]
        width_differences.append(right_p5[0] - left_p5[0])

    without_outliers = remove_outliers(width_differences)

    width = np.mean(without_outliers)
    width = width * real_standard_width_of_reference / reference_width_measurement
    return float("{:.4f}".format(width))


def get_height(key_points, reference_height_measurement, real_standard_height_of_reference=5.0) -> float:
    height_differences = []
    len_key_points = len(key_points)
    if len_key_points == 25:  # 'short sleeve top'

        up_p1 = key_points[6]
        down_p1 = key_points[14]
        height_differences.append(down_p1[1] - up_p1[1])

        up_p2 = key_points[2]
        down_p2 = key_points[15]
        height_differences.append(down_p2[1] - up_p2[1])

        up_p3 = key_points[4]
        down_p3 = key_points[15]
        height_differences.append(down_p3[1] - up_p3[1])

        up_p4 = key_points[24]
        down_p4 = key_points[16]
        height_differences.append(down_p4[1] - up_p4[1])

    elif len_key_points == 33:  # 'long sleeve top'
        up_p1 = key_points[6]
        down_p1 = key_points[18]
        height_differences.append(down_p1[1] - up_p1[1])

        up_p2 = key_points[2]
        down_p2 = key_points[19]
        height_differences.append(down_p2[1] - up_p2[1])

        up_p3 = key_points[4]
        down_p3 = key_points[19]
        height_differences.append(down_p3[1] - up_p3[1])

        up_p4 = key_points[32]
        down_p4 = key_points[20]
        height_differences.append(down_p4[1] - up_p4[1])

    elif len_key_points == 39:  # 'long sleeve outwear'
        up_p1 = key_points[6]
        down_p1 = key_points[18]
        height_differences.append(down_p1[1] - up_p1[1])

        up_p2 = key_points[3]
        down_p2 = key_points[19]
        height_differences.append(down_p2[1] - up_p2[1])

        up_p3 = key_points[33]
        down_p3 = key_points[36]
        height_differences.append(down_p3[1] - up_p3[1])

        up_p4 = key_points[32]
        down_p4 = key_points[20]
        height_differences.append(down_p4[1] - up_p4[1])

    elif len_key_points == 31:  # 'short sleeve outwear'
        up_p1 = key_points[6]
        down_p1 = key_points[14]
        height_differences.append(up_p1[1] - down_p1[1])

        up_p2 = key_points[1]
        down_p2 = key_points[15]
        height_differences.append(up_p2[1] - down_p2[1])

        up_p3 = key_points[25]
        down_p3 = key_points[28]
        height_differences.append(up_p3[1] - down_p3[1])

        up_p4 = key_points[24]
        down_p4 = key_points[16]
        height_differences.append(up_p4[1] - down_p4[1])

    elif len_key_points == 15:  # 'vest' & 'sling'

        up_p1 = key_points[6]
        down_p1 = key_points[9]
        height_differences.append(down_p1[1] - up_p1[1])

        up_p2 = key_points[1]
        down_p2 = key_points[10]
        height_differences.append(down_p2[1] - up_p2[1])

        up_p3 = key_points[5]
        down_p3 = key_points[10]
        height_differences.append(down_p3[1] - up_p3[1])

        up_p4 = key_points[14]
        down_p4 = key_points[11]
        height_differences.append(down_p4[1] - up_p4[1])

    elif len_key_points == 10:  # 'shorts'

        up_p1 = key_points[0]
        down_p1 = key_points[4]
        height_differences.append(down_p1[1] - up_p1[1])

        up_p2 = key_points[1]
        down_p2 = key_points[5]
        height_differences.append(down_p2[1] - up_p2[1])

        up_p3 = key_points[1]
        down_p3 = key_points[7]
        height_differences.append(down_p3[1] - up_p3[1])

        up_p4 = key_points[2]
        down_p4 = key_points[8]
        height_differences.append(down_p4[1] - up_p4[1])

    elif len_key_points == 14:  # 'trousers'

        up_p1 = key_points[0]
        down_p1 = key_points[4]
        height_differences.append(down_p1[1] - up_p1[1])

        up_p2 = key_points[0]
        down_p2 = key_points[5]
        height_differences.append(down_p2[1] - up_p2[1])

        up_p3 = key_points[1]
        down_p3 = key_points[6]
        height_differences.append(down_p3[1] - up_p3[1])

        up_p4 = key_points[1]
        down_p4 = key_points[10]
        height_differences.append(down_p4[1] - up_p4[1])

    elif len_key_points == 8:  # 'skirt'

        up_p1 = key_points[0]
        down_p1 = key_points[4]
        height_differences.append(down_p1[1] - up_p1[1])

        up_p2 = key_points[1]
        down_p2 = key_points[5]
        height_differences.append(down_p2[1] - up_p2[1])

        up_p3 = key_points[2]
        down_p3 = key_points[6]
        height_differences.append(down_p3[1] - up_p3[1])

    elif len_key_points == 29:  # 'short sleeve dress'

        up_p1 = key_points[6]
        down_p1 = key_points[16]
        height_differences.append(down_p1[1] - down_p1[1])

        up_p2 = key_points[2]
        down_p2 = key_points[17]
        height_differences.append(down_p2[1] - up_p2[1])

        up_p3 = key_points[4]
        down_p3 = key_points[17]
        height_differences.append(down_p3[1] - up_p3[1])

        up_p4 = key_points[28]
        down_p4 = key_points[18]
        height_differences.append(down_p4[1] - up_p4[1])

    elif len_key_points == 37:  # 'long sleeve dress'

        up_p1 = key_points[6]
        down_p1 = key_points[20]
        height_differences.append(down_p1[1] - up_p1[1])

        up_p2 = key_points[2]
        down_p2 = key_points[21]
        height_differences.append(down_p2[1] - up_p2[1])

        up_p3 = key_points[4]
        down_p3 = key_points[21]
        height_differences.append(down_p3[1] - up_p3[1])

        up_p4 = key_points[36]
        down_p4 = key_points[22]
        height_differences.append(down_p4[1] - up_p4[1])

    elif len_key_points == 19:  # 'vest dress & sling dress'

        up_p1 = key_points[6]
        down_p1 = key_points[11]
        height_differences.append(down_p1[1] - up_p1[1])

        up_p2 = key_points[1]
        down_p2 = key_points[12]
        height_differences.append(down_p2[1] - up_p2[1])

        up_p3 = key_points[5]
        down_p3 = key_points[12]
        height_differences.append(down_p3[1] - up_p3[1])

        up_p4 = key_points[18]
        down_p4 = key_points[13]
        height_differences.append(down_p4[1] - up_p4[1])

    without_outliers = remove_outliers(height_differences)
    height = np.mean(without_outliers)
    height = height * real_standard_height_of_reference / reference_height_measurement
    return float("{:.4f}".format(height))


def calculate_down_wear_size(key_points, reference_width_measurement, reference_height_measurement) -> tuple:
    width = get_width(key_points, reference_width_measurement)
    height = get_height(key_points, reference_height_measurement)

    if width < 36.5:
        size = 'XS'
    elif 36.5 < width < 40.5:
        size = 'S'
    elif 40.5 < width < 44.5:
        size = 'M'
    elif 44.5 < width < 48.5:
        size = 'L'
    elif 48.5 < width < 52:
        size = 'XL'
    elif 52 < width:
        size = 'XXL'
    return width, height, size


def calculate_top_wear_size(key_points, reference_width_measurement, reference_height_measurement) -> tuple:
    width = get_width(key_points, reference_width_measurement)
    height = get_height(key_points, reference_height_measurement)
    if width < 44.5:
        size = 'XS'
    elif 44.5 < width < 48.5:
        size = 'S'
    elif 48.5 < width < 52:
        size = 'M'
    elif 52 < width < 56:
        size = 'L'
    elif 56 < width < 59.5:
        size = 'XL'
    elif 59.5 < width:
        size = 'XXL'
    return width, height, size


def calculate_dress_size(key_points, reference_width_measurement, reference_height_measurement) -> tuple:
    width = get_width(key_points, reference_width_measurement)
    height = get_height(key_points, reference_height_measurement)
    if width < 36.5:
        size = 'XS'
    elif 36.5 < width < 40.5:
        size = 'S'
    elif 40.5 < width < 44.5:
        size = 'M'
    elif 44.5 < width < 48.5:
        size = 'L'
    elif 48.5 < width < 52:
        size = 'XL'
    elif 52 < width:
        size = 'XXL'
    return width, height, size


def calculate_size(image_path, category, key_points) -> tuple:
    # First Try Extracting the card from the image and Getting measurement of it
    try:
        # This code might raise the ValueError, if no cards detected in the given image.
        card_w, card_h = card_detection.get_pixel_measure(image_path)

    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No references detected in the image")

    # Checking the type of the clothes if it is top or down wear
    if category in ['Pants', 'Shorts', 'Skirt']:
        return calculate_down_wear_size(key_points, card_w, card_h), key_points
    elif category == 'Dress':
        return calculate_dress_size(key_points, card_w, card_h), key_points
    else:
        return calculate_top_wear_size(key_points, card_w, card_h), key_points


def open_image_from_url(url):
    response = requests.get(url)
    image = Image.open(BytesIO(response.content))
    return image


def extract_filename_from_url(image_url):
    return image_url.split('%')[1].split('?')[0][2:]

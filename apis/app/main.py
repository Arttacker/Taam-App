from fastapi import FastAPI, status, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from os import path
from apis.app import schemas, utils, database
from machine_learning.models import color_detection, quality_assessment, card_detection
from machine_learning.models.image_search import image_search
from machine_learning.models.key_points.key_points_model import *
from machine_learning.models.agrigorev.garments_classifier import *
from apis.global_paths import *

import time

app = FastAPI()

# region Setting-up CORS Policy
origins = ["*"]

app.add_middleware(CORSMiddleware, allow_origins=origins, allow_credentials=True, allow_methods=["*"],
                   allow_headers=["*"])
# endregion

# Initialize the models
CATEGORY_MODEL = load_garment_classifier_model()
IMAGE_SEARCH_MODEL = utils.load_image_search_model()

KEY_POINTS_TROUSERS_MODEL = load_key_points_model(KEY_POINTS_MODEL_trousers)
KEY_POINTS_SHORTS_MODEL = load_key_points_model(KEY_POINTS_MODEL_shorts)
KEY_POINTS_SKIRT_MODEL = load_key_points_model(KEY_POINTS_MODEL_skirt)
KEY_POINTS_SLING_DRESS_MODEL = load_key_points_model(KEY_POINTS_MODEL_sling_dress)
KEY_POINTS_LONG_SLEEVE_TOP_MODEL = load_key_points_model(KEY_POINTS_MODEL_long_sleeve_top)
KEY_POINTS_SHORT_SLEEVE_TOP_MODEL = load_key_points_model(KEY_POINTS_MODEL_short_sleeve_top)
KEY_POINTS_VEST_MODEL = load_key_points_model(KEY_POINTS_MODEL_vest)
KEY_POINTS_SLING_MODEL = load_key_points_model(KEY_POINTS_MODEL_sling)


def get_suitable_key_points_model(category):
    """
    Returns the most suitable key points model based on the clothing category.

    Parameters:
    category (str): The category of the clothing item.

    Returns:
    model: The corresponding key points model, or None if no suitable model is found.
    """
    # Choosing the most suitable model to get the key points
    if category == 'Pants':
        return KEY_POINTS_TROUSERS_MODEL
    elif category == 'Shorts':
        return KEY_POINTS_SHORTS_MODEL
    elif category == 'Skirt':
        return KEY_POINTS_SKIRT_MODEL
    elif category == 'Dress':
        return KEY_POINTS_SLING_DRESS_MODEL
    elif category in ['Long Sleeve', 'Shirt', 'Blazer', 'Outwear', 'Hoodie']:
        return KEY_POINTS_LONG_SLEEVE_TOP_MODEL
    elif category in ['T-Shirt', 'Polo', 'Blouse']:
        return KEY_POINTS_SHORT_SLEEVE_TOP_MODEL
    elif category == 'Body':
        return KEY_POINTS_VEST_MODEL
    elif category in ['Top', 'Undershirt']:
        return KEY_POINTS_SLING_MODEL
    else:
        # If the category is 'Skip', 'Other', 'Hat', 'Shoes', or any unknown category
        return None


@app.post("/process-image", status_code=status.HTTP_200_OK, response_model=schemas.GeneralImageResponse,
          tags=['General Image Processing'])
def process_image(image: schemas.Image):
    # Reference the global variable within the local scope
    global CATEGORY_MODEL

    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = utils.extract_filename_from_url(image.url)

    # Preparing the destination for storing the image
    image_storing_path = path.join(IMAGES, filename)

    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)

    season = utils.classify_season(category)

    gender = utils.classify_gender(category)

    # Get suitable key points model
    key_points_model = get_suitable_key_points_model(category)
    if key_points_model is None:
        return {"color": None, "category": category, "gender": gender, "season": season,
                "width": None, "height": None, "size": None}

    key_points = predict(image_storing_path, key_points_model)

    try:
        width, height, size = utils.calculate_size(image_storing_path, category, key_points)[0]
    except Exception as e:
        print(str(e))
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='No reference detected')

    segmented_image = utils.crop_image_for_color_detection(image_storing_path, key_points)

    colors = color_detection.extract_dominant_colors_from_image(segmented_image, 3)

    data = {"color": colors[0], "category": category, "gender": gender, "season": season,
            "width": width, "height": height, "size": size}
    return data


@app.post("/quality", status_code=status.HTTP_200_OK, response_model=schemas.QualityResponse,
          tags=['Quality Validation'])
def check_quality(image: schemas.Image):
    # Reference the global variable within the local scope
    global CATEGORY_MODEL

    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = utils.extract_filename_from_url(image.url)
    # Preparing the destination for string the image
    image_storing_path = path.join(IMAGES, filename)

    # Assessing the quality of the image
    quality = quality_assessment.asses_image_quality(image_storing_path, thresh=90)

    data = {"quality": quality}

    return data


@app.post("/color", status_code=status.HTTP_200_OK, response_model=schemas.ColorResponse, tags=['Color Retrieval'])
def detect_color(image: schemas.Image):
    # Reference the global variable within the local scope
    global CATEGORY_MODEL

    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = utils.extract_filename_from_url(image.url)
    # Preparing the destination for string the image
    image_storing_path = path.join(IMAGES, filename)

    # Category Classification
    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)

    key_points_model = get_suitable_key_points_model(category)
    if key_points_model is None:
        return {"color": None}

    key_points = predict(image_storing_path, key_points_model)
    segmented_image = utils.crop_image_for_color_detection(image_storing_path, key_points)

    # Extracting the color from the image
    colors = color_detection.extract_dominant_colors_from_image(segmented_image, 3)

    data = {"color": colors[0]}
    return data


@app.post("/season", status_code=status.HTTP_200_OK, response_model=schemas.SeasonResponse, tags=['Season Retrieval'])
def detect_season(image: schemas.Image):
    # Reference the global variable within the local scope
    global CATEGORY_MODEL

    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = utils.extract_filename_from_url(image.url)
    # Preparing the destination for string the image
    image_storing_path = image_storing_path = path.join(IMAGES, filename)

    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)

    # Season classification
    season = utils.classify_season(category)

    data = {"season": season}
    return data


@app.post("/gender", status_code=status.HTTP_200_OK, response_model=schemas.GenderResponse, tags=['Gender Retrieval'])
def detect_gender(image: schemas.Image):
    # Reference the global variable within the local scope
    global CATEGORY_MODEL

    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = utils.extract_filename_from_url(image.url)
    # Preparing the destination for string the image
    image_storing_path = image_storing_path = path.join(IMAGES, filename)

    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)

    # Gender classification
    gender = utils.classify_gender(category)

    data = {"gender": gender}
    return data


@app.post("/category", status_code=status.HTTP_200_OK, response_model=schemas.CategoryResponse,
          tags=['Category Retrieval'])
def classify_category(image: schemas.Image):
    # Reference the global variable within the local scope
    global CATEGORY_MODEL

    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = utils.extract_filename_from_url(image.url)
    # Preparing the destination for string the image
    image_storing_path = image_storing_path = path.join(IMAGES, filename)

    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)

    data = {"category": category}
    return data


@app.post("/size", status_code=status.HTTP_200_OK, response_model=schemas.SizeResponse, tags=['Size Retrieval'])
def calc_size(image: schemas.Image):
    # Reference the global variable within the local scope
    global CATEGORY_MODEL

    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = utils.extract_filename_from_url(image.url)
    # Preparing the destination for string the image
    image_storing_path = path.join(IMAGES, filename)

    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)
    try:
        width, height, size = utils.calculate_size(image_storing_path, category)[0]
    except Exception as e:
        print(str(e))
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='No reference detected')

    data = {"width": width, "height": height, "size": size}
    return data


@app.post("/search", status_code=status.HTTP_200_OK, response_model=schemas.SearchResponse,
          tags=['Search Nearest Images'])
def search(image: schemas.Image):
    # Reference the global variableS within the local scope
    global CATEGORY_MODEL
    global IMAGE_SEARCH_MODEL

    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = utils.extract_filename_from_url(image.url)
    # Preparing the destination for string the image
    image_storing_path = path.join(IMAGES, filename)

    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)

    # Initialize database connection
    conn, cursor = database.connect_database()

    # Converting the downloaded image to a vector
    image_vector = image_search.extract_features(image_storing_path, IMAGE_SEARCH_MODEL)

    # Compare this vector against all the stored images vectors in the database
    nearest_images = database.retrieve_nearest_k_images(cursor, image_vector, category, k=10)

    data = {"nearest_images": [{"url": image[0], "rank": image[1]} for image in nearest_images]}
    return data


@app.put("/save-image", status_code=status.HTTP_201_CREATED, tags=['For saving the image in the database'])
def save_image(image: schemas.ImageSave):
    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Failed to download the image.")

    # Extract the filename from the URL
    filename = utils.extract_filename_from_url(image.url)
    img_path = path.join(IMAGES, filename)

    # Initialize database connection
    conn, cursor = database.connect_database()

    try:
        # Extract features from image
        image_vector = image_search.extract_features(img_path, IMAGE_SEARCH_MODEL)
        # Saving the image in the database table
        if not database.insert_image(conn, cursor, img_path, image_vector, image.url, image.category):
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                                detail="Error while storing the image.")
    except Exception as e:
        error_detail = f"Error occurred while processing the image: {str(e)}"
        print(error_detail)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_detail)
    finally:
        database.close_database_connection(conn)


@app.delete("/delete-image", status_code=status.HTTP_204_NO_CONTENT, tags=['For deleting the image from the database'])
def delete_image(image: schemas.Image):
    # Extract the filename from the URL
    filename = utils.extract_filename_from_url(image.url)
    image_path = os.path.join(IMAGES, filename)

    # Initialize database connection
    conn, cursor = database.connect_database()

    try:
        # Delete image from the database
        if not database.delete_image(conn, cursor, filename):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                                detail=f"Error deleting image: {filename} not found in the database.")

        # Delete image from the filesystem
        if os.path.exists(image_path):
            os.remove(image_path)
        else:
            pass
    except Exception as e:
        error_detail = f"Error occurred while deleting the image: {str(e)}"
        print(error_detail)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_detail)
    finally:
        database.close_database_connection(conn)


def test(image_storing_path):
    # Reference the global variable within the local scope
    MODEL = load_garment_classifier_model(GARMENTS_CLASSIFIER_MODEL)
    (category, _) = predict_category(image_storing_path, MODEL)
    try:
        width, height, size = utils.calculate_size(image_storing_path, category)[0]
    except Exception as e:
        print(str(e))
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='No reference detected')

    data = {"width": width, "height": height, "size": size}
    # print(data)
    return data


if __name__ == "__main__":
    conn, cursor = database.connect_database()
    database.create_images_table(cursor)
    uvicorn.run(app, host="0.0.0.0", port=8000)

    # region test
    # # Preparing the destination for string the image
    # image_storing_path = path.join(IMAGES, 's6.jpg')
    # print(test(image_storing_path))
    # endregion

    # region Filling database
    # Calling the function to fill the database
    # utils.fill_database(IMAGE_SEARCH_MODEL)
    # endregion

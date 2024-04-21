from fastapi import FastAPI, status, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from os import path
from machine_learning.app import schemas, utils, database
from machine_learning.models import color_detection, quality_assessment, card_detection
from machine_learning.models.image_search import image_search
from machine_learning.models.key_points.key_points_model import *
from machine_learning.models.agrigorev.garments_classifier import *
from machine_learning.global_paths import *
from time import sleep

app = FastAPI()

# region Setting-up CORS Policy
origins = ["*"]

app.add_middleware(CORSMiddleware, allow_origins=origins, allow_credentials=True, allow_methods=["*"],
                   allow_headers=["*"])
# endregion

# Initialize the global variables
CATEGORY_MODEL = None
IMAGE_SEARCH_MODEL = None


@app.get("/")
def test():
    return {"Hello": "World"}


@app.post("/process-image", status_code=status.HTTP_200_OK, response_model=schemas.GeneralImageResponse,
          tags=['General Image Processing'])
def process_image(image: schemas.Image):
    # Reference the global variable within the local scope
    global CATEGORY_MODEL

    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]

    # Preparing the destination for string the image
    image_storing_path = path.join(IMAGES, filename)

    # Category Classification
    if CATEGORY_MODEL is None:
        CATEGORY_MODEL = load_garment_classifier_model(GARMENTS_CLASSIFIER_MODEL)

    # Category Classification
    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)

    # Season classification
    season = utils.classify_season(category)

    # Gender classification
    gender = utils.classify_gender(category)

    key_points_model = utils.get_suitable_key_points_model(category)
    if key_points_model is None:
        return {"color": None, "category": category, "gender": gender, "season": season}

    key_points = predict(image_storing_path, key_points_model)

    # Extracting the color from the image
    segmented_image = utils.crop_image_for_color_detection(image_storing_path, key_points)

    # Extracting the color from the image
    colors = color_detection.extract_dominant_colors_from_image(segmented_image, 3)
    data = {"color": colors[0], "category": category, "gender": gender, "season": season}
    # print(data)
    return data


@app.post("/quality", status_code=status.HTTP_200_OK, response_model=schemas.QualityResponse,
          tags=['Quality Validation'])
def check_quality(image: schemas.Image):
    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = path.join(IMAGES, filename)

    # Assessing the quality of the image
    quality = quality_assessment.asses_image_quality(image_storing_path, thresh=50)

    data = {"quality": quality}
    # print(data)
    return data


@app.post("/color", status_code=status.HTTP_200_OK, response_model=schemas.ColorResponse, tags=['Color Retrieval'])
def detect_color(image: schemas.Image):
    # Reference the global variable within the local scope
    global CATEGORY_MODEL

    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = image_storing_path = path.join(IMAGES, filename)

    # Category Classification
    if CATEGORY_MODEL is None:
        CATEGORY_MODEL = load_garment_classifier_model(GARMENTS_CLASSIFIER_MODEL)

    # Category Classification
    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)

    key_points_model = utils.get_suitable_key_points_model(category)
    if key_points_model is None:
        return {"color": None}

    key_points = predict(image_storing_path, key_points_model)
    segmented_image = utils.crop_image_for_color_detection(image_storing_path, key_points)

    # Extracting the color from the image
    colors = color_detection.extract_dominant_colors_from_image(segmented_image, 3)

    data = {"color": colors[0]}
    print(data)
    return data


@app.post("/season", status_code=status.HTTP_200_OK, response_model=schemas.SeasonResponse, tags=['Season Retrieval'])
def detect_season(image: schemas.Image):
    # Reference the global variable within the local scope
    global CATEGORY_MODEL

    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = image_storing_path = path.join(IMAGES, filename)

    # Category Classification
    if CATEGORY_MODEL is None:
        CATEGORY_MODEL = load_garment_classifier_model(GARMENTS_CLASSIFIER_MODEL)

    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)

    # Season classification
    season = utils.classify_season(category)

    data = {"season": season}
    print(data)
    return data


@app.post("/gender", status_code=status.HTTP_200_OK, response_model=schemas.GenderResponse, tags=['Gender Retrieval'])
def detect_gender(image: schemas.Image):
    # Reference the global variable within the local scope
    global CATEGORY_MODEL

    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = image_storing_path = path.join(IMAGES, filename)

    # Category Classification
    if CATEGORY_MODEL is None:
        CATEGORY_MODEL = load_garment_classifier_model(GARMENTS_CLASSIFIER_MODEL)

    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)

    # Gender classification
    gender = utils.classify_gender(category)

    data = {"gender": gender}
    print(data)
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
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = image_storing_path = path.join(IMAGES, filename)

    print(CATEGORY_MODEL is None)
    # Category Classification
    if CATEGORY_MODEL is None:
        CATEGORY_MODEL = load_garment_classifier_model(GARMENTS_CLASSIFIER_MODEL)

    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)

    data = {"category": category}
    print(data)
    return data


@app.post("/size", status_code=status.HTTP_200_OK, response_model=schemas.SizeResponse, tags=['Size Retrieval'])
def calc_size(image: schemas.Image):
    # Reference the global variable within the local scope
    global CATEGORY_MODEL

    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = image_storing_path = path.join(IMAGES, filename)

    # Category Classification
    if CATEGORY_MODEL is None:
        CATEGORY_MODEL = load_garment_classifier_model(GARMENTS_CLASSIFIER_MODEL)

    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)
    try:
        width, height, size = utils.calculate_size(image_storing_path, category)[0]
    except Exception as e:
        print(str(e))
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='No reference detected')

    data = {"width": width, "height": height, "size": size}
    # print(data)
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
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = path.join(IMAGES, filename)

    # Category Classification
    if CATEGORY_MODEL is None:
        CATEGORY_MODEL = load_garment_classifier_model(GARMENTS_CLASSIFIER_MODEL)

    (category, _) = predict_category(image_storing_path, CATEGORY_MODEL)

    # Initialize database connection
    conn, cursor = database.connect_database()
    # Loading the image searching model
    if IMAGE_SEARCH_MODEL is None:
        IMAGE_SEARCH_MODEL = utils.load_image_search_model()
    # Converting the downloaded image to a vector
    image_vector = image_search.extract_features(image_storing_path, IMAGE_SEARCH_MODEL)

    # Compare this vector against all the stored images vectors in the database
    nearest_images = database.retrieve_nearest_k_images(cursor, image_vector, category, k=10)

    data = {"nearest_images": [{"url": image[0], "rank": image[1]} for image in nearest_images]}
    print(data)
    return data


@app.put("/save-image", status_code=status.HTTP_201_CREATED, tags=['For saving the image in the database'])
def save_image(image: schemas.ImageSave):
    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Failed to download the image.")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    img_path = path.join(IMAGES, filename)

    # Initialize database connection
    conn, cursor = database.connect_database()

    try:
        # Loading the image search model that is required to convert the image to a vector
        model = utils.load_image_search_model()
        # Extract features from image
        image_vector = image_search.extract_features(img_path, model)
        # Saving the image in the database table
        if not database.insert_image(conn, cursor, img_path, image_vector, image.url, image.category):
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                                detail="Error while storing the image.")
    except Exception as e:
        error_detail = f"Error occurred while processing the image: {str(e)}"
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_detail)
        print(error_detail)
    finally:
        database.close_database_connection(conn)


@app.delete("/delete-image", status_code=status.HTTP_204_NO_CONTENT, tags=['For deleting the image from the database'])
def delete_image(image: schemas.Image):
    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
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
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_detail)
    finally:
        database.close_database_connection(conn)


if __name__ == "__main__":
    conn, cursor = database.connect_database()
    database.create_images_table(cursor)
    uvicorn.run(app, host="0.0.0.0", port=8000)

    # region Filling database
    # Calling the function to fill the database
    # model = utils.load_image_search_model()
    # utils.fill_database(model)
    # endregion

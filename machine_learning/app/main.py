from fastapi import FastAPI, status, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware

from . import schemas, utils, database
from ..models import color_detection, quality_assessment
from ..models.image_search import image_search

app = FastAPI()

# region Setting-up CORS Policy
origins = ["*"]

app.add_middleware(CORSMiddleware, allow_origins=origins, allow_credentials=True, allow_methods=["*"],
    allow_headers=["*"])
# endregion


# region Filling database
# Calling the function to fill the database
# model = utils.load_image_search_model()
# utils.fill_database(model)
# endregion


MALE_CATEGORIES = {}
FEMALE_CATEGORIES = {}


SUMMER_SEASON = {}
WINTER_SEASON = {}


@app.post("/process-image", status_code=status.HTTP_200_OK, response_model=schemas.GeneralImageResponse,
          tags=['General Image Processing'])
def process_image(image: schemas.Image):
    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]

    # Preparing the destination for string the image
    image_storing_path = 'machine_learning/images/' + filename

    response_model = None  # Initialize response model

    # Assessing the quality of the image
    quality = quality_assessment.asses_image_quality(image_storing_path)

    if not quality:
        # If image quality is not valid, return QualityNotValidResponse
        return Response(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY)

    #  Continue processing to send the complete data
    ###################################################
    # [MISSING]: segment the image from the background
    ##################################################

    # Extracting the color from the image
    colors = color_detection.extract_dominant_colors(image_storing_path, 3)
    hex_color = colors[0]
    color = color_detection.color_name_from_hex(hex_color)
    hex_color = colors[0]
    color = {"name": color, "hex": hex_color}
    # Calculate the size of the cloth in the image
    width, height, size = utils.calculate_size(image_storing_path)

    return {
        "color": color,
        "width": width,
        "height": height,
        "size": size,
        "category": 'T-shirt',
        "gender": 'M',
        "season": 'summer'
    }


@app.post("/quality", status_code=status.HTTP_200_OK, response_model=schemas.QualityResponse,
          tags=['Quality Validation'])
def check_quality(image: schemas.Image):
    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = 'machine_learning/images/' + filename

    # Assessing the quality of the image
    quality = quality_assessment.asses_image_quality(image_storing_path)
    return {"quality": quality}


@app.post("/color", status_code=status.HTTP_200_OK, response_model=schemas.ColorResponse,
          tags=['Color Retrieval'])
def detect_color(image: schemas.Image):
    # Downloading the image

    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = 'machine_learning/images/' + filename

    ###################################################
    # [MISSING]: segment the image from the background
    ###################################################

    # Extracting the color from the image
    colors = color_detection.extract_dominant_colors(image_storing_path, 3)
    hex_color = colors[0]
    color = color_detection.color_name_from_hex(hex_color)
    color = {"name": color, "hex": hex_color}

    return {"color": color}


@app.post("/category", status_code=status.HTTP_200_OK, response_model=schemas.CategoryResponse,
          tags=['Category Retrieval'])
def classify_category(image: schemas.Image):
    return {"Hello": "World"}


@app.post("/size", status_code=status.HTTP_200_OK, response_model=schemas.SizeResponse,
          tags=['Size Retrieval'])
def calc_size(image: schemas.Image):
    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = 'machine_learning/images/' + filename

    return {"Hello": "World"}


@app.post("/search", status_code=status.HTTP_200_OK, response_model=schemas.SearchResponse,
          tags=['Search Nearest Images'])
def search(image: schemas.Image):
    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = 'machine_learning/images/' + filename

    # Assessing the quality of the image
    quality = quality_assessment.asses_image_quality(image_storing_path)

    if not quality:
        # If image quality is not valid, return QualityNotValidResponse
        return Response(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY)

    ###################################################
    # [MISSING]: classify the category of the cloth in the image
    category = None
    ###################################################
    # Initialize database connection
    conn, cursor = database.connect_to_database()
    # Loading the image searching model
    model = utils.load_image_search_model()
    # Converting the downloaded image to a vector
    image_vector = image_search.extract_features(image_storing_path, model)

    # Compare this vector against all the stored images vectors in the database
    nearest_images = database.retrieve_nearest_k_images(cursor, image_vector, category, k=5)

    return {"nearest_images": [
        {"name": image[0], "rank": image[1]} for image in nearest_images
    ]}





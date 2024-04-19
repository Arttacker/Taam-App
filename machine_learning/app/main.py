from fastapi import FastAPI, status, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from os import path
from machine_learning.app import schemas, utils, database
from machine_learning.models import color_detection, quality_assessment, card_detection
from machine_learning.models.image_search import image_search
from machine_learning.models.key_points.key_points_model import *
from machine_learning.global_paths import IMAGES

app = FastAPI()

# region Setting-up CORS Policy
origins = ["*"]

app.add_middleware(CORSMiddleware, allow_origins=origins, allow_credentials=True, allow_methods=["*"],
    allow_headers=["*"])
# endregion


@app.post("/process-image", status_code=status.HTTP_200_OK, response_model=schemas.GeneralImageResponse,
          tags=['General Image Processing'])
def process_image(image: schemas.Image):
    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]

    # Preparing the destination for string the image
    image_storing_path = path.join(IMAGES, filename)

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
    ###################################################
    # [MISSING]: classify the category of the cloth in the image
    category = ''
    ###################################################
    # Season classification
    season = utils.classify_season(category)
    # Gender classification
    gender = utils.classify_gender(category)
    # Calculate the size of the cloth in the image
    width, height, size = utils.calculate_size(image_storing_path, category)

    return {
        "color": color,
        "width": width,
        "height": height,
        "size": size,
        "category": category,
        "gender": gender,
        "season": season
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
    image_storing_path = path.join(IMAGES, filename)

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
    image_storing_path = image_storing_path = path.join(IMAGES, filename)

    ###################################################
    # [MISSING]: segment the image from the background
    ###################################################

    # Extracting the color from the image
    colors = color_detection.extract_dominant_colors(image_storing_path, 3)
    hex_color = colors[1]
    color = color_detection.color_name_from_hex(hex_color)
    color = {"name": color, "hex": hex_color}

    return {"color": color}


@app.post("/season", status_code=status.HTTP_200_OK, response_model=schemas.SeasonResponse,
          tags=['Season Retrieval'])
def detect_season(image: schemas.Image):
    # Downloading the image

    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = image_storing_path = path.join(IMAGES, filename)

    ###################################################
    # [MISSING]: classify the category of the cloth in the image
    category = ''
    ###################################################
    season = season = utils.classify_season(category)

    return {"season": season}


@app.post("/gender", status_code=status.HTTP_200_OK, response_model=schemas.GenderResponse,
          tags=['Gender Retrieval'])
def detect_season(image: schemas.Image):
    # Downloading the image

    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = image_storing_path = path.join(IMAGES, filename)

    ###################################################
    # [MISSING]: classify the category of the cloth in the image
    category = ''
    ###################################################
    gender = utils.classify_gender(category)

    return {"gender": gender}


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
    image_storing_path = image_storing_path = path.join(IMAGES, filename)
    ###################################################
    # [MISSING]: classify the category of the cloth in the image
    category = 'trousers'
    ###################################################
    utils.calculate_size(image_storing_path, category)
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
    image_storing_path = image_storing_path = path.join(IMAGES, filename)

    ###################################################
    # [MISSING]: classify the category of the cloth in the image
    category = ''
    ###################################################
    # Initialize database connection
    conn, cursor = database.connect_database()
    # Loading the image searching model
    model = utils.load_image_search_model()
    # Converting the downloaded image to a vector
    image_vector = image_search.extract_features(image_storing_path, model)

    # Compare this vector against all the stored images vectors in the database
    nearest_images = database.retrieve_nearest_k_images(cursor, image_vector, category, k=10)

    return {"nearest_images": [
        {"url": image[0], "rank": image[1]} for image in nearest_images
    ]}


@app.put("/save-image", status_code=status.HTTP_201_CREATED, tags=['For saving the image in the database'])
def save_image(image: schemas.Image):
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
        if not database.insert_image(conn, cursor, img_path, image_vector, image.url):
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                                detail="Error while storing the image.")
    except Exception as e:
        error_detail = f"Error occurred while processing the image: {str(e)}"
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_detail)
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
    # region Filling database
    # Calling the function to fill the database
    # model = utils.load_image_search_model()
    # utils.fill_database(model)
    # endregion

    conn, cursor = database.connect_database()
    database.create_images_table(cursor)
    uvicorn.run(app, host="0.0.0.0", port=8000)

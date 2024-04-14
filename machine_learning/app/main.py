from fastapi import FastAPI, status, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

from . import schemas
from . import utils
from ..models import color_detection, quality_assessment, card_detection

app = FastAPI()

# setting up the CORS Policy
origins = [
    "http://localhost:8080",  # insert only the domain the mobile app is running on
]

app.add_middleware(
    CORSMiddleware, allow_origins=origins, allow_credentials=True, allow_methods=["*"], allow_headers=["*"]
)


MALE_CATEGORIES = {}
FEMALE_CATEGORIES = {}

SUMMER_SEASON = {}
WINTER_SEASON = {}


@app.post("/process-image", status_code=status.HTTP_200_OK, response_model=schemas.GeneralImageResponse)
def read_root(image: schemas.Image):
    # Downloading the image
    if not utils.download_image(image_url=image.url):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Image Not Found")

    # Extract the filename from the URL
    filename = image.url.split('%')[1].split('?')[0][2:]
    # Preparing the destination for string the image
    image_storing_path = 'machine_learning/images/' + filename

    # Assessing the quality of the image
    quality = quality_assessment.asses_image_quality(image_storing_path)

    ###################################################
    # [MISSING]: segment the image from the background
    ###################################################

    # Extracting the color from the image
    colors = color_detection.extract_dominant_colors(image_storing_path, 1)

    # Extracting the card from the image and Getting measurement of it
    card_measurement = card_detection.get_pixel_measure(image_storing_path)
    print(card_measurement)

    return {"quality": quality,
            "color": colors[0],
            "width": 1.0,
            "height": 1.0,
            "size": 'L',
            "category": 'T-shirt',
            "gender": 'M',
            "season": 'summer'
            }


@app.post("/quality", status_code=status.HTTP_200_OK, response_model=schemas.QualityResponse)
def read_root(image: schemas.Image):
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


@app.post("/color", status_code=status.HTTP_200_OK, response_model=schemas.ColorResponse)
def read_root(image: schemas.Image):
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
    colors = color_detection.extract_dominant_colors(image_storing_path, 1)
    return {"color": colors[0]}


@app.post("/category", status_code=status.HTTP_200_OK, response_model=schemas.CategoryResponse)
def read_root(image: schemas.Image):
    return {"Hello": "World"}


@app.post("/size", status_code=status.HTTP_200_OK, response_model=schemas.SizeResponse)
def read_root(image: schemas.Image):
    return {"Hello": "World"}


@app.post("/search", status_code=status.HTTP_200_OK, response_model=schemas.SearchResponse)
def read_root(image: schemas.Image):
    return {"Hello": "World"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
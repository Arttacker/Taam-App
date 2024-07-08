from PIL import Image
from brisque import BRISQUE


def calculate_BRISQUE_score(image_path):
    # Create a BRISQUE object
    obj = BRISQUE()

    # Open the image
    image = Image.open(image_path)

    # Convert the image to a color image with three channels
    color_image = Image.new("RGB", image.size)
    color_image.paste(image)

    # Calculate the BRISQUE score for the color image
    score = obj.score(color_image)

    return score


def asses_image_quality(image_path: str, thresh=30) -> bool:
    score = calculate_BRISQUE_score(image_path)
    # print(score)
    return score < thresh




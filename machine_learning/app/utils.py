import os
import requests


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


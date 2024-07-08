from fastai.vision.all import *
from apis.global_paths import GARMENTS_CLASSIFIER_MODEL, IMAGES
import os
from PIL import Image
import pathlib

temp = pathlib.PosixPath
pathlib.PosixPath = pathlib.WindowsPath


CATEGORIES = ['Top', 'Other', 'Hoodie', 'Body', 'Dress', 'Polo', 'Shorts', 'Shirt', 'Shoes', 'Undershirt',
              'Skip', 'Long Sleeve', 'Blouse', 'T-Shirt', 'Pants', 'Skirt', 'Outwear', 'Blazer', 'Hat']


def load_garment_classifier_model(model=GARMENTS_CLASSIFIER_MODEL):
    return load_learner(model)


def predict_category(image_path, learner) -> tuple:
    """

    :param image_path: str
    :param learner: the model that will classify image
    :return: tuple consists of the predicted class name and the probability of confidence
    """
    img = PILImage.create(image_path)
    pred, pred_idx, probs = learner.predict(img)
    # plt.imshow(img.reshape(600, 600))
    # plt.title(f"{CATEGORIES[int(pred)]}, Probability: {probs[pred_idx]:.4f}")
    # plt.show()
    return CATEGORIES[int(pred)], float("{:.4f}".format(probs[pred_idx]))


# Function to check if a file has an image extension
def is_image_file(filename):
    image_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg', '.tif', '.tiff']
    _, extension = os.path.splitext(filename)
    return extension.lower() in image_extensions


def classify_all_test():
    number_of_true_classifications = 0
    number_of_false_classifications = 0
    total_number_of_test_samples = 0
    # Iterate over each file in the given dir and make the prediction on all images in this dir
    for filename in os.listdir('../input/new-images/'):
        if os.path.isfile('../input/new-images/' + filename) and is_image_file('../input/new-images/' + filename):
            total_number_of_test_samples += 1
            img = PILImage.create('../input/new-images/' + filename)
            pred, pred_idx, probs = learn.predict(img)
            if CATEGORIES[int(pred)] == filename.split(".")[0][:-1]:
                print(filename.split(".")[0][:-1])
                number_of_true_classifications += 1
            else:
                number_of_false_classifications += 1

        plt.imshow(img.reshape(600, 600))
        plt.title(f"{CATEGORIES[int(pred)]}, Probability: {probs[pred_idx]:.4f}")
        plt.show()

    # calculating accuricy for this local testing
    accuracy = (number_of_true_classifications / total_number_of_test_samples) * 100
    print("[+] Number of true classification: ", number_of_true_classifications)
    print("[+] Number of false classification: ", number_of_false_classifications)
    print("[+] Accuracy: ", accuracy)

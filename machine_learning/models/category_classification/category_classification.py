from fastai.vision.all import *
import torch
from apis.global_paths import IMAGES, CATEGORY_CLASSIFICATION_MODEL
import pathlib

temp = pathlib.PosixPath
pathlib.PosixPath = pathlib.WindowsPath


dataset_path = Path("/kaggle/input/deepfashion2-categorized-cropped")
img_size = 224
num_categories = 13
class_index = {'trousers':0, 'sling dress':1, 'short sleeve outwear':2, 'long sleeve top':3,
              'short sleeve top':4, 'sling':5, 'vest dress':6, 'vest':7, 'short sleeve dress':8,
              'long sleeve dress':9, 'shorts':10, 'skirt':11, 'long sleeve outwear':12}
class_names = list(class_index)


def plot_image_with_category(image, predicted_category):
    plt.imshow(image)
    plt.title(f"Predicted category: {predicted_category}")
    plt.show()


def get_category(img_path):
    pass


def load_category_classification_model(model):
    leaner = torch.load(model, map_location=torch.device('cpu'))
    return leaner


def predict(image_path, model):
    # Load and preprocess the image
    image = Image.open(image_path)
    image = image.resize((img_size, img_size))
    image_np = np.array(image)

    # Make predictions
    pred = model.predict(image)

    class_index = pred[1].item()
    probability = pred[2][class_index].item()

    for i in range(13):
        print(f'probability of class number{i+1} : {pred[2][i].item() * 100}')

    # Apply thresholding or reject option with confidence
    if probability < 0.3:
        predicted_category = "other"
    else:
        predicted_category = pred[0]

    # Plot image with predicted landmarks
    plot_image_with_category(image_np, predicted_category)

    return predicted_category


if __name__ == '__main__':
    from os import path
    model = load_category_classification_model(CATEGORY_CLASSIFICATION_MODEL)
    image1 = path.join(IMAGES, 'jacket1.jpg')
    image2 = path.join(IMAGES, 'long_S1.jpg')

    predict(image1, model)
    predict(image2, model)


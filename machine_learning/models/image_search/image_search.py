import numpy as np
from keras.applications.mobilenet import preprocess_input
from keras.models import model_from_json
from keras.preprocessing import image



def load_model(model_architecture_path, model_weights_path):
    """
    Load the model architecture and weights.

    Parameters:
        model_architecture_path (str): Path to the JSON file containing the model architecture.
        model_weights_path (str): Path to the HDF5 file containing the model weights.

    Returns:
        keras.Model: Loaded Keras model.
    """
    with open(model_architecture_path, 'r') as json_file:
        model_json = json_file.read()
    model = model_from_json(model_json)
    model.load_weights(model_weights_path)
    return model


def preprocess_image(img_path, target_size=(224, 224)):
    """
    Preprocess the input image.

    Parameters:
        img_path (str): Path to the input image file.
        target_size (tuple): Target size for resizing the image.

    Returns:
        np.ndarray: Preprocessed image array.
    """
    img = image.load_img(img_path, target_size=target_size)
    img_array = image.img_to_array(img)
    img_array_expanded = np.expand_dims(img_array, axis=0)
    preprocessed_img = preprocess_input(img_array_expanded)
    return preprocessed_img


def extract_features(img_path, model):
    """
    Extract features from an image using a pretrained model.

    Parameters:
        img_path (str): Path to the input image file.
        model (keras.Model): Pretrained Keras model.

    Returns:
        np.ndarray: Feature vector extracted from the image.
    """
    x = preprocess_image(img_path)
    features = model.predict(x)
    return features.flatten()  # Flatten to get 1D feature vector

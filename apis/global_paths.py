from os import path, pardir

API_ABS_PATH = path.dirname(path.abspath(__file__))
# Get the root directory of the project
PROJECT_APS_PATH = path.abspath(path.join(API_ABS_PATH, pardir))

IMAGES = path.join(API_ABS_PATH, 'images')
TEST_IMAGES = path.join(API_ABS_PATH, 'test_images')
IMAGES_DATABASE = path.join(API_ABS_PATH, 'app', 'database', 'images_database.db')

ML_MODELS = path.join(PROJECT_APS_PATH, 'machine_learning', 'models')
IMAGE_SEARCH_MODEL = path.join(ML_MODELS, 'image_search')
CATEGORY_CLASSIFICATION_MODEL = path.join(ML_MODELS, 'category_classification', 'deepfashion2-categories.pkl')
KEY_POINTS_MODEL = path.join(ML_MODELS, 'key_points', 'pickels')
KEY_POINTS_MODEL_long_sleeve_dress = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e040_long_sleeve_dress_lr0.0002290867705596611.pkl')
KEY_POINTS_MODEL_long_sleeve_outwear = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e040_long_sleeve_outwear_lr0.0004786300996784121.pkl')
KEY_POINTS_MODEL_long_sleeve_top = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e040_long_sleeve_top_lr0.00019054606673307717.pkl')
KEY_POINTS_MODEL_short_sleeve_dress = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e040_short_sleeve_dress_lr0.0002754228771664202.pkl')
KEY_POINTS_MODEL_short_sleeve_top = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e040_short_sleeve_top_lr0.0001.pkl')
KEY_POINTS_MODEL_short_sleeve_outwear = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e0100_short_sleeve_outwear_lr0.0003311311302240938.pkl')
KEY_POINTS_MODEL_shorts = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e040_shorts_lr9.120108734350652e-05.pkl')
KEY_POINTS_MODEL_skirt = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e040_skirt_lr9.120108734350652e-05.pkl')
KEY_POINTS_MODEL_sling = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e040_sling_lr0.00019054606673307717.pkl')
KEY_POINTS_MODEL_sling_dress = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e040_sling_dress_lr0.0003981071640737355.pkl')
KEY_POINTS_MODEL_vest = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e040_vest_lr0.0003981071640737355.pkl')
KEY_POINTS_MODEL_vest_dress = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e040_vest_dress_lr0.0005754399462603033.pkl')
KEY_POINTS_MODEL_trousers = path.join(KEY_POINTS_MODEL, 'landmarks_detection_resnet50_e040_trousers_lr0.00015848931798245758.pkl')
MULTI_TASK_MODEL = path.join(ML_MODELS, 'multi_task_model',  'multitask_model_architecture_resnet50_e045_lr0.0001_exported.pkl')
GARMENTS_CLASSIFIER_MODEL = path.join(ML_MODELS, 'agrigorev',  'garment_classifier_resnet34_e050.pkl')

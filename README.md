# Ta'am-App  
  
![](https://github.com/Arttacker/Taam-App/assets/99927650/ed54e482-e64f-4e26-b11c-2efee2573c0c)  
  
  
**Ta'am**  is a mobile application designed to facilitate the buying and selling of used clothes. By providing a platform for users to list their pre-loved items and browse for new additions to their wardrobe, Ta'am aims to promote sustainability, affordability, and convenience in the fashion industry.  
  
## Table of Contents  
  
- [Features](#features)  
- [Project Structure](#project-structure)  
- [Installation](#installation)  
- [Usage](#usage)  
- [Technologies Used](#technologies-used)  
- [About Us](#about-us)  
- [License](#license)  
  
  
## Features  
  
- **Upload and List Items:** Users can upload images of their clothes and specify details such as price, size, color, and category, etc....  
- **Search Functionality:** Users can search for specific items using text descriptions or images.  
- **Messaging System:** Buyers and sellers can communicate with each other through an in-app chat feature to negotiate and finalize transactions.  
- **AI-Powered Image Processing:** The app utilizes machine learning and deep learning techniques to evaluate the quality of uploaded images and extract relevant features for categorization and smart features extraction.  
  
## Project Structure  
  
```  
Taam-App/  
│  
├── app/ 
|   └──Taqam
│      ├── android/  
│      ├── screens/  
│      ├── windows/  
│      ├── web/  
|      └── ...
├── machine_learning/  
│   ├── models
│   ├── agrigorev/ 
│   ├── category_classification/
|   ├── image_search/
|   ├── key_points/
│   └── ...     
├── apis/
|   ├─── app
|   ├─── database
|   ├─── images
|   └─── test_images
├── documentation/
|   ├─── Ta'am IEEE paper conference.pdf
|   ├─── Ta'am-Documentation.pdf
|   ├─── Ta'am Poster.pdf
│   └── ... 
├── LICENSE  
└── README.md  
```  
  
## Installation
  
To set up the Ta'am app locally, follow these steps:

### 1. Setting up the API

1. Clone the repository to your local machine:  
```bash  
git clone https://github.com/Arttacker/Taam-App.git
```  
2. Install the requirements for the machine learning API:
```bash
pip install -r apis/requirements.txt 
```
3. Run the API:
```bash
python .\apis\app\main.py 
```
4. You can study the API documentation by visiting this url on your browser while running the API:
`http://127.0.0.1:8000/docs#/`

### 2. Setting up the Mobile App
#### Tools Required:

1. Android Studio
2. Flutter Source with Dart SDK version 3.13.6
    - Download from [flutter 3.13.6](https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.13.6-stable.zip)
#### Steps:

#### Setting Up Flutter and Dart in Android Studio

1. **Set Up Flutter Path:**
    
    - Open the folder where you downloaded Flutter.
    - Copy the path to the `bin` directory within the Flutter folder.
    - Go to your operating system’s "Edit the system environment variables" settings.
    - Replace the existing path with the new Flutter path.
2. **Open Android Studio.**
    
3. **Configure Flutter in Android Studio:**
    
    - Navigate to `Settings` > `Languages & Frameworks` > `Flutter`.
    - Set the Flutter SDK path to the `bin` directory path you copied earlier.
4. **Configure Dart SDK (if not automatically detected):**
    
    - Navigate to `Settings` > `Languages & Frameworks` > `Dart`.
    - Check the box for "Enable Dart support for the project 'Taqam'".
    - Set the Dart SDK path to `flutter/bin/cache/dart-sdk` within the Flutter folder.
5. **Install Dependencies:**
    
    - Open the terminal in Android Studio.
    - Run the command: 
	    - **`flutter pub get`**
6. **Select a Virtual Device or Connect Your Device:**
    
    - Choose a virtual device or connect a physical device to run your project.
7. **Run the Project:**
    
    - Run the Taqam project.

## Usage  
  
- Upon launching the app, users can register or log in to their accounts.  
- Sellers can upload images of their clothes and specify details for each item.  
- Buyers can search for items based on their preferences and initiate conversations with sellers through the in-app messaging system.  
- Once a transaction is agreed upon, users can arrange for payment and delivery outside the app.  
  
## Technologies Used  
- **Flutter**: Frontend & Backend framework for building the mobile app.  
- **FastAPI**: Web framework for building APIs.  
- **Torch**: Machine learning library.
- **OpenCV**: Computer Vision Library for Image processing.
- **Firebase**: Database for storing user and item information.  
- **Git/GitHub**: Version control and collaboration platform.  
  
## About Us  
  
We are a team of passionate Computer Science students at Ain Shams University dedicated to creating innovative solutions that address real-world challenges. With a shared commitment to sustainability and technology, we came together to develop Ta'am, a mobile app aimed at revolutionizing the way people buy and sell used clothes. Through our combined expertise in mobile app development, machine learning, and user experience design, we strive to make Ta'am a user-friendly platform that promotes environmental conservation and financial savings. Join us on this journey towards a more sustainable and accessible fashion industry.  
  
## License  
  
This project is licensed under the [MIT License](LICENSE).

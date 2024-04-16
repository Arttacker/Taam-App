import sqlite3

import numpy as np


def connect_to_database(database_name='machine_learning/app/database/images_database.db'):
    """
    Connect to the SQLite database.

    Parameters:
        database_name (str): The name of the SQLite database file.

    Returns:
        Connection: SQLite database connection object.
        Cursor: SQLite database cursor object.
    """
    conn = sqlite3.connect(database_name)
    cursor = conn.cursor()
    return conn, cursor


def create_images_table(cursor):
    """
    Create the 'images' table in the database if it does not exist.

    Parameters:
        cursor (Cursor): SQLite database cursor object.
    """
    cursor.execute('''CREATE TABLE IF NOT EXISTS images (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        filename TEXT NOT NULL UNIQUE,
                        vector TEXT NOT NULL,
                        category TEXT NOT NULL 
                    )''')


def insert_image(conn, cursor, image_path, vector, category='UNKNOWN') -> bool:
    """
    Insert an image (filename and vector) into the database.

    Parameters:
        conn (Connection): SQLite database connection object.
        cursor (Cursor): SQLite database cursor object.
        image_path (str): The filename of the image.
        vector (ndarray): The vector representation of the image.
        category (str): The category of the cloth in the image.
    """
    filename = image_path.split('/')[-1].split('\\')[-1]
    vector_str = ','.join(map(str, vector))  # Convert vector to string
    try:
        cursor.execute("INSERT INTO images (filename, vector, category) VALUES (?, ?, ?)",
                       (filename, vector_str, category))
        conn.commit()
        return True
    except sqlite3.IntegrityError as e:
        print("Error inserting image:", e)
        return False


def retrieve_vectors(cursor, category=None) -> list:
    """
    if category is given retrieve only vectors that are belongs to a given category from the 'images' table.
    else retrieve all vectors from the 'images' table.
    Parameters:
        cursor (Cursor): SQLite database cursor object.
        category (str): The needed category of cloths.
    Returns:
        list: A list of tuples containing filenames and vectors.
    """
    if category:
        cursor.execute("SELECT filename, vector FROM images WHERE category = ?", (category,))
        rows = cursor.fetchall()
        vectors = []
        for row in rows:
            filename, vector_str = row
            vector = np.array(list(map(float, vector_str.split(','))))  # Parse string to numpy array
            vectors.append((filename, vector))
    else:
        cursor.execute("SELECT filename, vector FROM images")
        rows = cursor.fetchall()
        vectors = []
        for row in rows:
            filename, vector_str = row
            vector = np.array(list(map(float, vector_str.split(','))))  # Parse string to numpy array
            vectors.append((filename, vector))
    return vectors


def compute_cosine_similarity(vector1, vectors):
    """
    Calculate the cosine similarity between vector1 and an array of vectors.

    Parameters:
        vector1 (ndarray): The vector to compare.
        vectors (ndarray): An array of vectors to compare against.

    Returns:
        ndarray: An array of cosine similarity scores.
    """
    # Normalize vectors
    vector1_norm = np.linalg.norm(vector1)
    vectors_norm = np.linalg.norm(vectors, axis=1)
    # Compute cosine similarity
    cosine_similarities = np.dot(vectors, vector1) / (vectors_norm * vector1_norm)
    return cosine_similarities


def retrieve_nearest_k_images(cursor, given_vector, category=None, k=5) -> list:
    """
    Retrieve the k nearest images from the database based on cosine similarity.

    Parameters:
        cursor (Cursor): SQLite database cursor object.
        given_vector (ndarray): The vector representation of the given image.
        category (str): The needed category of cloths.
        k (int): The number of nearest images to retrieve. Default is 5.

    Returns:
        list: A list of tuples containing filenames and cosine similarity scores.
    """
    vectors = retrieve_vectors(cursor, category)
    cosine_similarities = compute_cosine_similarity(given_vector, np.array([vector for _, vector in vectors]))
    top_k_indices = np.argsort(cosine_similarities)[-k:][::-1]
    nearest_images = [(vectors[i][0], cosine_similarities[i]) for i in top_k_indices]
    return nearest_images


def close_database_connection(conn):
    """
    Close the SQLite database connection.

    Parameters:
        conn (Connection): SQLite database connection object.
    """
    conn.close()

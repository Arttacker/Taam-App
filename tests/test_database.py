import unittest
from apis.app import database

valid_image_url = "https://firebasestorage.googleapis.com/v0/b/ta-am-2e7cf.appspot.com/o/posts%2Fscaled_d1.jpg?alt=media&token=06a5bb1f-09cd-4700-8a2d-7cf82eaee8b1"


class MyTestCase(unittest.TestCase):
    def test_insert_image(self):
        conn, cursor = database.connect_database()

        self.assertEqual(True, False)


if __name__ == '__main__':
    unittest.main()

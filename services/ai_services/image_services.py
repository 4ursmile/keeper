import base64
import io
from PIL import Image
import cv2
import numpy as np
from s3_services import S3Services
def stack_images(img1, img2):
    img1 = cv2.resize(img1, (300, 300))
    img2 = cv2.resize(img2, (300, 300))
    hstack = np.hstack((img1, img2))
    return hstack
def read_image(image_path):
    img = cv2.imread(image_path)
    # Convert the image from BGR color (OpenCV default) to RGB color
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    return img
def base64_to_image(base64_string):
    img = base64.b64decode(base64_string)
    img = Image.open(io.BytesIO(img))
    img = np.array(img)
    return img
def base64_to_cv2(base64_string):
    img = base64.b64decode(base64_string)
    img = Image.open(io.BytesIO(img))
    img = cv2.cvtColor(np.array(img), cv2.COLOR_BGR2RGB)
    return img
def write_image(image, image_path):
    cv2.imwrite(image_path, image)
class ImageUtils:
    def __init__(self):
        self.s3 = S3Services()
    def stack_images(self, img1, img2):
        return stack_images(img1, img2)
    def read_image(self, image_path):
        return read_image(image_path)
    def base64_to_image(self, base64_string):
        return base64_to_image(base64_string)
    def base64_to_cv2(self, base64_string):
        return base64_to_cv2(base64_string)
    def write_image(self, image, image_path):
        write_image(image, image_path)
    def stack_image_to_s3(self, img1, img2, unique_id):
        img = stack_images(img1, img2)
        img_path = f'{unique_id}_stacked_image.jpg'
        cv2.imwrite(img_path, img)
        url = self.s3.upload_image(img_path)
        return url
    def base64_to_s3(self, base64_string, unique_id):
        img = base64_to_cv2(base64_string)
        img_path = f'{unique_id}_image.jpg'
        cv2.imwrite(img_path, img)
        url = self.s3.upload_image(img_path)
        return url
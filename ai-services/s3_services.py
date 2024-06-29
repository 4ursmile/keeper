import boto3
from botocore.exceptions import NoCredentialsError
import os
from botocore.exceptions import ClientError
import logging
from PIL import Image
import requests
from config import Config
# Parameters
bucket_name = 'keeper-storage'
class S3Services:
    def __init__(self):
        cfg = Config()
        self.s3 = boto3.client(
            's3',
            aws_access_key_id=cfg.cfg['s3']['key'],
            aws_secret_access_key=cfg.cfg['s3']['secret_key'],
            region_name=cfg.cfg['s3']['region_name']  # Optional
        )
        self.bucket_name = bucket_name
        self.region_name = cfg.cfg['s3']['region_name']
    def upload_image(self, file_name):
        """Upload a file to an S3 bucket

        :param file_name: File to upload
        :param bucket: Bucket to upload to
        :param object_name: S3 object name. If not specified then file_name is used
        :return: True if file was uploaded, else False
        """
        # If S3 object_name was not specified, use file_name
        object_name = os.path.basename(file_name)
        object_name = f'img/{object_name}'
        # Upload the file
        try:
            response = self.s3.upload_file(file_name, self.bucket_name, object_name)
        except ClientError as e:
            logging.error(e)
            return None
        return f"https://{self.bucket_name}.s3.{self.region_name}.amazonaws.com/{object_name}"
        
    def download_image(self, url):
        img = Image.open(requests.get(url, stream=True).raw).convert('RGB')
        return img
    def download_image_from_s3(self, img_name):
        url = f"https://{self.bucket_name}.s3.{self.region_name}.amazonaws.com/img/{img_name}"
        img = Image.open(requests.get(url, stream=True).raw).convert('RGB')
        return img


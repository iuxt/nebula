# -*- coding=utf-8
from json import load

from urllib3 import Retry
from qcloud_cos import CosConfig
from qcloud_cos import CosS3Client
import sys
import logging
import time
import os
from dotenv import load_dotenv

load_dotenv()
now = time.strftime("%Y-%m-%d_%H%M%S", time.localtime())
filename = "halo-" + now + ".tar.gz"

def backup(src, dest):
    command = "tar zc --exclude=logs --exclude=.git " + src + " -f " + dest
    os.system(command)


def upload_cos(bucket, filename):
    # 正常情况日志级别使用INFO，需要定位时可以修改为DEBUG，此时SDK会打印和服务端的通信信息
    logging.basicConfig(level=logging.INFO, stream=sys.stdout)

    # 1. 设置用户属性, 包括 secret_id, secret_key, region等。Appid 已在CosConfig中移除，请在参数 Bucket 中带上 Appid。Bucket 由 BucketName-Appid 组成
    secret_id = os.getenv("secret_id")
    secret_key = os.getenv("secret_key")
    region = os.getenv("region")
    token = None
    scheme = 'https'

    config = CosConfig(Region=region, SecretId=secret_id, SecretKey=secret_key, Token=token, Scheme=scheme)
    client = CosS3Client(config, retry=5)

    # # 本地路径 简单上传
    # response = client.put_object_from_local_file(
    #     Bucket=bucket,
    #     LocalFilePath=filename,
    #     Key=filename,
    # )
    # print(response['ETag'])

    # 高级上传接口
    response = client.upload_file(
        Bucket=bucket,
        LocalFilePath=filename,
        Key=filename,
        PartSize=1,
        MAXThread=10,
        EnableMD5=False
    )

def clean_tmp(filename):
    os.remove(filename)

if __name__ == "__main__":
    try:
        backup(os.getenv("backup_dir"), filename)
        upload_cos(os.getenv("bucket"), filename)
    finally:
        clean_tmp(filename)

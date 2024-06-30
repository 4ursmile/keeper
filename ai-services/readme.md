# Read before go to AI services 
-----
# !!!ai_config.yaml!!! provided for judging.

First you need install requirements
```shell
pip install -r requirements.txt
```


### To use these services you need to create 'ai_config.yaml' file have format and attributes like below: 
```YAML
{
  's3': {
    'key': 'lorem',
    'secret_key': 'lorem',
    'region_name': 'lorem' 
  },
  'flow': {
    'api_key': 'lorem',
    'workflow_id': 'lorem',
    'base_url': 'https://api.workflowchef.ai'
  }
}
```
Change 'lorem' with specific value or contact me for real ai_config.yaml.

Create instance of specific services you want to use first then call their methods after!!!
Example
```python
from s3_services import S3Services
s3 = S3Services()
url = s3.upload_image('test.png')

### another one 
from img_text_services import  ImgTextServices
img_text = ImgTextServices()
result = await img_text.get_result('Lift all box to floor 7', 'https://keeper-storage.s3.ap-southeast-1.amazonaws.com/img/test.png', mode='init')
print(result)
```
## Enjoy!!!!


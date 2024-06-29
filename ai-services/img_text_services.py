import httpx
import asyncio
import json
from config import Config
import json
def ouput_extractor(result):
    result = result['output']
    result = result['content'].strip('```json\n')
    result = result.replace('\n', '')
    return json.loads(result)
class ImgTextServices:
    def __init__(self):
        cfg = Config()
        self.workflow_id = cfg.cfg['flow']['workflow_id']
        self.api_key = cfg.cfg['flow']['api_key']
        self.base_url = cfg.cfg['flow']['base_url']
    async def post_workflow_run(self, input_data):
        
        url = f"{self.base_url}/api/workflow_runs/"
        headers = {
            'Authorization': f'Bearer {self.api_key}',
            'Content-Type': 'application/json'
        }
        payload = {
            'workflow_id': self.workflow_id,
            'input': input_data
        }

        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(url, headers=headers, json=payload)
                response.raise_for_status()  # Raise an HTTPError if the HTTP request returned an unsuccessful status code
                workflow_run = response.json()
                return workflow_run
            except httpx.RequestError as e:
                print(e)
                return {
                    'message': 'Workflow run failed',
                    'status': 404
                }
    async def put_job_task_init_validate(self, description, img_url, mode):
        assert mode in ['init', 'validate'], "mode must be 'init' or 'validate'"
        if mode == 'init':
            input_data = {'question': f"""
You are a task judge. Your task is to determine whether the input image is relevant to the given task description to avoid fake tasks.
For example:
Task description: "Lift all boxes to floor 7"
If the image shows a dog, the image is not relevant. Your response should explain why it is not relevant and suggest taking a relevant image.
{{
  "result": "no",
  "reason": "The image shows a dog and is not relevant to the task.",
  "suggest": "Let's take an image of the stack of boxes that need to be lifted."
}}
If the image is relevant, return a positive result with the price you think the task deserves based on the context shown in the image.
{{
  "result": "yes",
  "price": 10,
  "context": "The image shows a table with some items on it, suggesting that it needs cleaning."
}}
Now, here is the description for the task: {description}."""
                    ,'img_url': img_url}
        elif mode == 'validate':
            input_data = {'question': f"""
You are a task judge. Your task is to determine whether a given task has been completed based on a description and a pair of images. The first image (on the left) shows the state before the task was performed, and the second image (on the right) shows the state after the task was performed.
If the two images demonstrate that the task described has been completed, return "yes" and a congratulatory message. If the task is not complete or the images do not appear to be from the same location, return "no" and explain why the task is not complete or why the images are not relevant.
Return the result in JSON format. For example:
Description: "clean the table"
If the left image shows a messy table with garbage and the right image shows the same table cleaned, return:
{{
  "result": "yes",
  "message": "Great, the table is so clean, you did a good job!"
}}
If the table is still dirty or there are inconsistencies between the images, return:
{{
  "result": "no",
  "message": "The table is still dirty, there are some nylon bags left. Keep going!"
}}
If the images do not seem to be from the same location, return:
{{
  "result": "no",
  "message": "It seems you took the wrong pictures. Let's try again."
}}
Now, here is the description for the task: "{description}".""",
                    'img_url': img_url}
        else:
            return {
                'message': 'Invalid mode',
                'status': 404
            }
        result = await self.post_workflow_run(input_data)
        return result
    async def get_workflow_run(self, id):
        
        url = f"{self.base_url}/api/workflow_runs/{id}"
        headers = {
            'Authorization': f'Bearer {self.api_key}'
        }

        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(url, headers=headers)
                response.raise_for_status()  # Raise an HTTPError if the HTTP request returned an unsuccessful status code
                workflow = response.json()
                return workflow
            except httpx.RequestError as e:
                print(e)
                return {
                    'message': 'Workflow run not found',
                    'status': 404
                }
    async def call_workflow_api(self, des, img_url, mode):
        assert mode in ['init', 'validate'], "mode must be 'init' or 'validate'"
        result = await self.put_job_task_init_validate(des, img_url, mode)
        w_id = result['id']
        limit_exceeded = 30000
        time = 0
        while True:
            workflow = await self.get_workflow_run(w_id)
            if workflow['status'] == 'success':
                return workflow
            await asyncio.sleep(5)
            time += 5
            if time >= limit_exceeded:
                return {
                    'message': 'Workflow run time exceeded',
                    'status': 404
                }
        return result
    async def get_result(self, des, img_url, mode):
        assert mode in ['init', 'validate'], "mode must be 'init' or 'validate'"
        result = await self.call_workflow_api(des, img_url, mode)
        return ouput_extractor(result)



from typing import List, Optional
from typing_extensions import Annotated
from fastapi import FastAPI, HTTPException, Path, Depends, Body, File, UploadFile, BackgroundTasks
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId,errors
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse,FileResponse
import urllib.parse
import dtdef as dt
import os
import queue
import asyncio
import boto3
import cv2

from structure import (
    ReviewCreate, ReviewInDB, Address, UserCreate, UserUpdate,
    UserInDB, QueueItem, Location2, TaskCreate2, Location, 
    TaskCreate, TakeTask, Transaction
)
# Running app command line
# python -m uvicorn main:app --reload --port 5000

# Set up the FastAPI app
IMAGEDIR = "../images/"
app = FastAPI()
# Set up the MongoDB client
MONGO_DETAILS = "mongodb+srv://lethanhminh0801:"+urllib.parse.quote('Minh@8@12@@3')+"@keeper.r1k11kt.mongodb.net/?retryWrites=true&w=majority&appName=keeper"
client = AsyncIOMotorClient(MONGO_DETAILS)
db = client.users_db
users_collection = db.get_collection("users")
reviews_collection = db.get_collection("reviews")
givetask_collection = db.get_collection("givetask")
taker_queue = []
giver_queue = []
taketask_queue = []

# Set up the S3 client
{
  's3': {
    'key': 'AKIATCKAMVAZJSJZWGWL',
    'secret_key': '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',
    'region_name': 'ap-southeast-1' 
  },
  'flow': {
    'api_key': 'qqr_16505d26c9a653c8b31bd713438969656aa2b04bf64586e296b3d635ff62462e1604c1fc4081995667b356daad3e5b3c',
    'workflow_id': '1c9fed59-dc11-47af-8678-73131c9dfcc7',
    'base_url': 'https://api.workflowchef.ai'
  }
}

@app.get("/getallfiles/", response_description="List all images in directory")
async def list_files():
    try:
        files = os.listdir(IMAGEDIR)
        image_files = [file for file in files if file.endswith((".jpg", ".jpeg", ".png"))]
        return {"images": image_files}
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="Image directory not found or check your directory path!")

@app.get("/getfile/")
async def read_file(name: str = "default.jpg"):
    files= os.listdir(IMAGEDIR)
    path = f"{IMAGEDIR}{name}"
    if name not in files:
        raise HTTPException(status_code=404, detail="File not found or check your file name again (jpg or png)!")
    return FileResponse(path)

@app.post("/upload/")
async def create_upload_file(file: UploadFile= File(...)):
    file.filename = f"{IMAGEDIR}{file.filename}"
    content = await file.read()
    # Save the file in server
    with open(file.filename, "wb") as f:
        f.write(content)
    return {"filename": file.filename}

@app.get("/users/email", response_description="Get a single user", response_model=UserInDB)
async def read_user(email: EmailStr):
    user = await db["users"].find_one({"email": email})
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user
# CRUD for user behavior
@app.post("/users/", response_description="Add new user", response_model=UserInDB)
async def create_user(user: UserCreate):
    user_exists = await users_collection.find_one({"username": user.username})
    if user_exists:
        raise HTTPException(status_code=400, detail="Username already exists")
    
    user_id = await users_collection.count_documents({}) + 1
    while await users_collection.find_one({"id": user_id}):  # Ensure no duplicate ID
        user_id += 1
    user_dict = user.dict()
    user_dict.update({
        "id": user_id,
        "rating": 0.0,
        "balance": 0.0,
        "reviewID": [],
        "transaction_history": []
    })
    user = jsonable_encoder(user_dict)
    new_user = await db["users"].insert_one(user)
    created_user = await db["users"].find_one({"_id": new_user.inserted_id})
    created_user["id"] = user_id
    return created_user



@app.put("/users/{user_id}", response_description="Update a user", response_model=UserInDB)
async def update_user(user_id: int, user: UserUpdate):
    existing_user = await db["users"].find_one({"id": user_id})
    if existing_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    update_data = {k: v for k, v in user.dict().items() if v is not None}
    if update_data:
        updated_user = await db["users"].update_one(
            {"id": user_id}, {"$set": update_data}
        )
        if updated_user.modified_count == 1:
            updated_user = await db["users"].find_one({"id": user_id})
            return updated_user

    return existing_user

@app.delete("/users/{user_id}", response_description="Delete a user")
async def delete_user(user_id: int):
    delete_result = await db["users"].delete_one({"id": user_id})
    if delete_result.deleted_count == 1:
        return {"status": "success", "message": f"User {user_id} deleted"}
    raise HTTPException(status_code=404, detail="User not found")

@app.get("/users/", response_description="List all users", response_model=List[UserInDB])
async def list_users():
    users = await db["users"].find().to_list(1000)
    return users

@app.get("/users/{user_id}", response_description="Get a single user", response_model=UserInDB)
async def read_user(user_id: int):
    user = await db["users"].find_one({"id": user_id})
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.get("/users/{user_id}/balance", response_description="Get user balance", response_model=dict)
async def get_balance(user_id: int):
    user = await db["users"].find_one({"id": user_id})
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return {"balance": user["balance"]}
### CRUD for review behavior    
@app.post("/reviews/", response_description="Submit a review", response_model=ReviewInDB)
async def create_review(review: ReviewCreate = Body(...), receiver_id: int = Body(..., embed=True)):
    print("Start Create_review")
    
    review_id = await reviews_collection.count_documents({}) + 1
    while await reviews_collection.find_one({"ReviewID": review_id}):
        review_id += 1

    review_dict = review.dict()
    review_dict.update({
        "ReviewID": review_id,
        "Date": datetime.now(),
        "Type": True,
    })
    review = jsonable_encoder(review_dict)
    new_review = await reviews_collection.insert_one(review)

    # Update receiver's rating
    user = await users_collection.find_one({"id": receiver_id})
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    rating = user["rating"]
    reviewID = user["reviewID"]
    new_rating = ((rating*len(reviewID) + review_dict["rate"]) / (len(reviewID) + 1))
    print(f"Lan luot la: {rating},{len(reviewID)},{review_dict['rate']}")
    
    # Update receiver's reviewID
    update_result = await users_collection.update_one(
        {"id": receiver_id},
        {
            "$push": {"reviewID": int(review_id)},
            "$set": {"rating": new_rating}
        }
    )
    
    if update_result.modified_count == 0:
        raise HTTPException(status_code=404, detail=f"User with ID {receiver_id} not found")
    else:
        print(f"Receiver id is: {receiver_id}")

    # Fetch the created review document to return
    created_review = await reviews_collection.find_one({"_id": new_review.inserted_id})
    return created_review

@app.put("/users/{user_id}/status", response_description="Update user status")
async def update_user_status(user_id:int, status: bool, receiver_id: int, item: QueueItem=Body(...)):
    global taker_queue  # Make taker_queue global to access and modify it
    giver_user = await db["users"].find_one({"id": receiver_id})
    for user_details in taker_queue:
        if user_details["userID"] == user_id and status:
            raise HTTPException(status_code=404, detail="Already has this user in queue")
    # If user confirms ready, add to queue
    if status:
        existing_user = await db["users"].find_one({"id": user_id})
        if existing_user is None:
            raise HTTPException(status_code=404, detail="User not found")
        
        user_details = {
            "userID": user_id,
            "address": giver_user['address'],  # Replace with actual user address
            "longitude": item.longitude,  # Replace with actual longitude
            "latitude": item.latitude,   # Replace with actual latitude
            "Rating": existing_user['rating'],  # Replace with actual user rating
            "Date": datetime.now()  # Add current date and time in "YYYY-MM-DD HH:MM:SS" format
        }
        taker_queue.append(user_details)  # Append user_details to taker_queue (list)
    else:
        # Remove user from queue if status is false
        taker_queue = [user for user in taker_queue if user["userID"] != user_id]
    
    for item in taker_queue:
        print(item)

    return {"message": f"User status updated in queue"}

@app.post("/users/{user_id}/download/")
async def read_file(name: str = "default.jpg"):
    files= os.listdir(IMAGEDIR)
    path = f"{IMAGEDIR}{name}"
    if name not in files:
        raise HTTPException(status_code=404, detail="File not found or check your file name again (jpg or png)!")
    return FileResponse(path)

from ai_services.s3_services import S3Services
@app.post("/users/{user_id}/upload/")
async def create_upload_file(user_id:int ,file: UploadFile= File(...)):
    file.filename = f"{IMAGEDIR}{file.filename}"
    content = await file.read()
    
    # Save the file in server
    with open(file.filename, "wb") as f:
        f.write(content)

    user = await users_collection.find_one({"id": user_id})
    if user is None:
        raise HTTPException(status_code=404, detail=f"User with ID {user_id} not found")

    # Upload the file to S3
    s3 = S3Services()
    image_url = s3.upload_image(file.filename) 

    # Update user's images field with the image URL
    user = await db["givetask"].update_one(
        {"giveruserID": user_id},
        {"$set": {"images": image_url}} 
    )
    return {"filename": file.filename}

@app.post("/users/{user_id}/tasks/", response_description="Create a task", response_model=TaskCreate)
async def create_task(user_id: int, user_note:str , task: TaskCreate = Body()):
    # Fetch user details from the database based on giveruserID
    global taker_queue
    user = await users_collection.find_one({"id": user_id})
    if user is None:
        raise HTTPException(status_code=404, detail=f"User with ID {user_id} not found")
    
    # Prepare task data with user's address details
    
    task_id = await givetask_collection.count_documents({}) + 1  # Automatically generate taskID
    while await givetask_collection.find_one({"taskID": task_id}):  # Ensure no duplicate taskID
        task_id += 1
    task_data = {
        "taskID": task_id,
        "images": task.images,
        "description": task.description,
        "location": {
            "country": user["address"]["country"],
            "city": user["address"]["city"],
            "district": user["address"]["district"],
            "ward": user["address"]["ward"],
            "longitude": task.location.longitude,
            "latitude": task.location.latitude,
            "note": task.location.note
        },
        "gmv": task.gmv,
        "discount": task.discount,
        "giveruserID": user_id,
        "note": user_note
    }
    giver_queue.append(task_data)
    # Insert task into givetask collection
    new_task = await givetask_collection.insert_one(task_data)
    
    # Fetch and return the created task document
    created_task = await givetask_collection.find_one({"_id": new_task.inserted_id})
    return created_task 

@app.put("/tasks/complete", response_description="Complete task")
async def complete_task(confirm: bool):
    global taketask_queue
    
    if not taketask_queue:
        raise HTTPException(status_code=404, detail="No tasks in queue")
    
    task = taketask_queue[0]
    
    if confirm:
        taketask_queue[0].status = "Completed"
        taketask_queue[0].completed_time = datetime.now()
        
        # Create and store transaction
        transaction = Transaction(
            sender_id=task.giverID,
            receiver_id=task.takerID,
            amount=task.gmv,
            time=datetime.now(),
            status=True  # Assuming 'True' indicates completed status
        )
        await db["transactions"].insert_one(transaction.dict())
        
        db["take_task"].insert_one(taketask_queue[0])
        return {"message": "Task completion processed"}
    else:
        taketask_queue[0].status = "Canceled"
        taketask_queue[0].completed_time = datetime.now()
        
        # Create and store transaction for cancellation
        transaction = Transaction(
            sender_id=task.giverID,
            receiver_id=task.takerID,
            amount=task.gmv,
            time=datetime.now(),
            status=False  # Assuming 'False' indicates canceled status
        )
        await db["transactions"].insert_one(transaction.dict())
        
        db["take_task"].insert_one(taketask_queue[0])
        taketask_queue.append(taketask_queue.pop(0))
        return {"message": "Task completion cancelled"}

# last event take task 
taketask_queue=[]
class TakeTask(BaseModel):
    taskID: int
    takerID: int
    giverID: int
    init_image: str
    justifyimage: str
    status: str
    note: str
    take_time: datetime
    arrive_time: Optional[datetime] = None
    completed_time: Optional[datetime] = None

@app.get("/users/tasks/", response_description="List all tasks", response_model=List[TaskCreate2])
async def list_tasks():
    return giver_queue

@app.put("/tasks/accept", response_description="Accept or reject task")
async def accept_task(accept_status: bool, taker_id: int):
    global taker_queue, giver_queue, taketask_queue
    
    if not taker_queue or not giver_queue:
        raise HTTPException(status_code=404, detail="No tasks or users in queue")

    taker = taker_queue[0]
    giver = giver_queue[0]
    
    if taker["userID"] != taker_id:
        raise HTTPException(status_code=400, detail="User ID mismatch")
    
    if accept_status:
        take_task_data = TakeTask(
            taskID=giver["taskID"],
            takerID=taker["userID"],
            giverID=giver["giveruserID"],
            init_image=giver["images"],
            status="Arriving",
            note=giver["note"],
            take_time=datetime.now()
        )
        taketask_queue.append(take_task_data)
        taker_queue.pop(0)
        giver_queue.pop(0)
    else:
        taker_queue.append(taker_queue.pop(0))
    return {"message": "Task acceptance processed"}

## done
@app.put("/tasks/arrive", response_description="Arrive at task location")
async def arrive_task(confirm: bool):
    global taketask_queue
    if not taketask_queue:
        raise HTTPException(status_code=404, detail="No tasks in queue")
    
    task = taketask_queue[0]
    if confirm:
        taketask_queue[0].status = "In Progress"
        taketask_queue[0].arrive_time = datetime.now()
        return {"message": "Arrival processed"}
    else: 
        taketask_queue[0].status = "Canceled"
        taketask_queue[0].completed_time = datetime.now()
        taketask_queue[0].arrive_time = datetime.now()
        db["take_task"].insert_one(taketask_queue[0])
        taketask_queue.append(taketask_queue.pop(0))
        return {"message": "Arrival cancelled"}

@app.put("/tasks/complete", response_description="Complete task")
async def complete_task(confirm: bool):
    global taketask_queue
    
    if not taketask_queue:
        raise HTTPException(status_code=404, detail="No tasks in queue")
    
    task = taketask_queue[0]
    
    if confirm:
        taketask_queue[0].status = "Completed"
        taketask_queue[0].completed_time = datetime.now()
        
        # Create and store transaction
        transaction = Transaction(
            sender_id=task.giverID,
            receiver_id=task.takerID,
            amount=task.gmv,
            time=datetime.now(),
            status=False  # False mean haven't paid yet
        )
        await db["transactions"].insert_one(transaction.dict())
        await db["take_task"].insert_one(taketask_queue[0])

        return {"message": "Task completion processed"}
    else:
        taketask_queue[0].status = "Canceled"
        taketask_queue[0].completed_time = datetime.now()
        
        
        await db["take_task"].insert_one(taketask_queue[0])
        taketask_queue.append(taketask_queue.pop(0))
        return {"message": "Task completion cancelled"}
    
@app.put("/tasks/image", response_description="Upload image")
async def upload_image_when_complete(file: UploadFile= File(...)):
    file.filename = f"{IMAGEDIR}{file.filename}"
    content = await file.read()
    
    # Save the file in server
    with open(file.filename, "wb") as f:
        f.write(content)
    # Upload the file to S3
    s3 = S3Services()
    image_url = s3.upload_image(file.filename)
    # Update task's justifyimage field with the image URL
    task = await db["take_task"].find_one({"taskID": taketask_queue[0].taskID})
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    task = await db["take_task"].update_one(
        {"taskID": taketask_queue[0].taskID},
        {"$set": {"justifyimage": image_url}})
    # haystack two image in taketask and upload to s3
    # then return url
    img1 = cv2.imread(taketask_queue[0].init_image)
    img2 = cv2.imread(taketask_queue[0].justifyimage)
    img = stack_images(img1, img2)
    img_path = f'{unique_id}_stacked_image.jpg'
    url = self.s3.upload_image(img_path)  
    

    return {"filename": file.filename}
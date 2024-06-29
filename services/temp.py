from typing import List, Optional
from typing_extensions import Annotated
from fastapi import FastAPI, HTTPException, Path, Depends, Body, File, UploadFile
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId,errors
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse,FileResponse
import urllib.parse
import dtdef as dt
import os

class ReviewCreate(BaseModel):
    rate: int = Field(..., ge=1, le=5, description="Rating from 1 to 5")
    comment: Optional[str] = Field(None, description="Optional comment from the user")
    giverID: int

class ReviewInDB(BaseModel):
    ReviewID: int
    rate: int
    Date: datetime
    comment: Optional[str]
    Type: bool
    giverID: int

class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid objectid")
        return ObjectId(v)

    @classmethod
    def __get_pydantic_json_schema__(cls, field_schema):
        field_schema.update(type="string")


class UserCreate(BaseModel):
    name: str
    email: EmailStr
    phone: str
    address: str
    username: str
    password: str

class UserUpdate(BaseModel):
    name: Optional[str]
    email: Optional[EmailStr]
    phone: Optional[str]
    address: Optional[str]
    password: Optional[str]

class UserInDB(BaseModel):
    id: int
    name: str
    email: EmailStr
    phone: str
    address: str
    username: str
    rating: float = 0
    balance: float = 0
    reviewID: Optional[List[int]] = []
    transaction_history: Optional[List[str]] = []

#get

# mongodb connection
from motor.motor_asyncio import AsyncIOMotorClient
from fastapi import FastAPI, HTTPException, Depends
import urllib.parse


MONGO_DETAILS = "mongodb+srv://lethanhminh0801:"+urllib.parse.quote('Minh@8@12@@3')+"@keeper.r1k11kt.mongodb.net/?retryWrites=true&w=majority&appName=keeper"
client = AsyncIOMotorClient(MONGO_DETAILS)
db = client.users_db
users_collection = db.get_collection("users")

app = FastAPI()
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse

# get file from fastapi
IMAGEDIR = "../images/"

@app.get("/getfiles/", response_description="List all images in directory")
async def list_files():
    try:
        files = os.listdir(IMAGEDIR)
        image_files = [file for file in files if file.endswith((".jpg", ".jpeg", ".png"))]
        return {"images": image_files}
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="Image directory not found or check your directory path!")

@app.get("/getfiles/")
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

# CRUD for user behavior
@app.post("/users/", response_description="Add new user", response_model=UserInDB)
async def create_user(user: UserCreate):
    user_exists = await users_collection.find_one({"username": user.username})
    if user_exists:
        raise HTTPException(status_code=400, detail="Username already exists")
    
    user_id = await users_collection.count_documents({}) + 1
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

reviews_collection = db.get_collection("reviews")

#### Reviews event


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

    # Update receiver's reviewID
    update_result = await users_collection.update_one(
        {"id": receiver_id},
        {"$push": {"reviewID": int(review_id)}}
    )
    
    if update_result.modified_count == 0:
        raise HTTPException(status_code=404, detail=f"User with ID {receiver_id} not found")
    else:
        print(f"Receiver id is: {receiver_id}")

    # Fetch the created review document to return
    created_review = await reviews_collection.find_one({"_id": new_review.inserted_id})
    return created_review
    

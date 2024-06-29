from typing import List, Optional
from fastapi import FastAPI, HTTPException, Path, Depends, Body, HTTPException
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId,errors
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
import urllib.parse
import dtdef as dt

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
    def __modify_schema__(cls, field_schema):
        field_schema.update(type="string")

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
    reviewID: Optional[List[str]] = []
    transaction_history: Optional[List[str]] = []

class User(BaseModel):
    user_id: Optional[int] = Field(default=None, alias="_id")
    username: str = Field(..., example="johndoe")
    password: str = Field(..., example="securepassword123")
    name: str = Field(..., example="John Doe")
    email: EmailStr = Field(..., example="johndoe@example.com")
    phone: str = Field(..., example="123-456-7890")
    address: str = Field(..., example="123 Main St")
    rating: Optional[float] = Field(default=None, example=4.5)
    review_ids: List[str] = Field(default_factory=list)
    balance: float = Field(default=0.0, example=100.0)
    transaction_history: List[str] = Field(default_factory=list)

    class Config:
        json_encoders = {
            ObjectId: str
        }

class ReviewCreate(BaseModel):
    rate: int = Field(..., ge=1, le=5, description="Rating from 1 to 5")
    comment: Optional[str] = Field(None, description="Optional comment from the user")

class ReviewInDB(BaseModel):
    ReviewID: int
    rate: int
    Date: datetime
    comment: Optional[str]
    Type: bool
    giverID: int
# MongoDB connection settings

app = FastAPI()
MONGO_DETAILS = "mongodb+srv://lethanhminh0801:"+urllib.parse.quote('Minh@8@12@@3')+"@keeper.r1k11kt.mongodb.net/?retryWrites=true&w=majority&appName=keeper"
client = AsyncIOMotorClient(MONGO_DETAILS)
database = client.users_db #database name
users_collection = database.get_collection("users") #collection name in database

### CRUD for user behavior 
@app.post("/users/", response_model=User)
def create_user(user: User = Body(...)):
    if users_collection.find_one({"username": user.username}):
        raise HTTPException(status_code=400, detail="Username already taken")
    while users_collection.find_one({"id": user.id}):
        user.id += 1
    user_dict = user.dict(by_alias=True)
    users_collection.insert_one(user_dict)
    user_dict["_id"] = str(user_dict["_id"])
    return user_dict

@app.get("/users/{user_id}", response_model=User)
def read_user(user_id: str):
    try:
        user = users_collection.find_one({"_id": PyObjectId(user_id)})
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        user["_id"] = str(user["_id"])
        return user
    except errors.InvalidId:
        raise HTTPException(status_code=400, detail="Invalid user ID")

@app.put("/users/{user_id}", response_model=User)
def update_user(user_id: str, user_update: User):
    try:
        user = users_collection.find_one({"_id": PyObjectId(user_id)})
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        user_dict = user_update.dict(exclude_unset=True, by_alias=True)
        if "username" in user_dict:
            raise HTTPException(status_code=400, detail="Username cannot be changed")
        users_collection.update_one({"_id": PyObjectId(user_id)}, {"$set": user_dict})
        updated_user = users_collection.find_one({"_id": PyObjectId(user_id)})
        updated_user["_id"] = str(updated_user["_id"])
        return updated_user
    except errors.InvalidId:
        raise HTTPException(status_code=400, detail="Invalid user ID")

@app.delete("/users/{user_id}", response_model=User)
def delete_user(user_id: str):
    try:
        user = users_collection.find_one({"_id": PyObjectId(user_id)})
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        users_collection.delete_one({"_id": PyObjectId(user_id)})
        user["_id"] = str(user["_id"])
        return user
    except errors.InvalidId:
        raise HTTPException(status_code=400, detail="Invalid user ID")

@app.get("/users/", response_model=List[User])
def list_users():
    users = list(users_collection.find())
    for user in users:
        user["_id"] = str(user["_id"])
    return users


@app.get("/users/{user_id}/balance", response_model=User)
def get_balance(user_id: str):
    try:
        user = users_collection.find_one({"_id": PyObjectId(user_id)})
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        user["_id"] = str(user["_id"])
        return user
    except errors.InvalidId:
        raise HTTPException(status_code=400, detail="Invalid user ID")

### CRUD for review behavior    
reviews_collection = database.get_collection("reviews")

#### Reviews event

@app.post("/reviews/", response_description="Submit a review", response_model=ReviewInDB)
async def create_review(review: ReviewCreate = Body(...), giver_id: int = Body(..., embed=True)):
    try:
        review_id = await reviews_collection.count_documents({}) + 1
        review_dict = review.dict()
        review_dict.update({
            "ReviewID": review_id,
            "Date": datetime.now(),
            "Type": True,  # Assuming 'Type' field should be a boolean value, setting it to True as an example
            "giverID": giver_id
        })
        review = jsonable_encoder(review_dict)
        new_review = await reviews_collection.insert_one(review)
        created_review = await reviews_collection.find_one({"_id": new_review.inserted_id})
        return created_review
    except errors.InvalidId:
        raise HTTPException(status_code=400, detail="Invalid giver ID")
from typing import List, Optional 
from pydantic import BaseModel,EmailStr, Field


class User(BaseModel):
    user_id: Optional[int] = Field(default=None, example=1)
    username: str = Field(..., example="johndoe")
    password: str = Field(..., example="securepassword123")
    name: str = Field(..., example="John Doe")
    email: EmailStr = Field(..., example="johndoe@example.com")
    phone: str = Field(..., example="123-456-7890")
    address: str = Field(..., example="123 Main St")
    rating: Optional[float] = Field(default=None, example=4.5)
    review_ids: List[int] = Field(default_factory=list)
    balance: float = Field(default=0.0, example=100.0)
    transaction_history: List[int] = Field(default_factory=list)

class UserUpdate(BaseModel):
    password: Optional[str] = Field(None, example="securepassword123")
    name: Optional[str] = Field(None, example="John Doe")
    email: Optional[EmailStr] = Field(None, example="johndoe@example.com")
    phone: Optional[str] = Field(None, example="123-456-7890")
    address: Optional[str] = Field(None, example="123 Main St")
    rating: Optional[float] = Field(None, example=4.5)
    review_ids: Optional[List[int]] = Field(default_factory=list)
    balance: Optional[float] = Field(None, example=100.0)
    transaction_history: Optional[List[int]] = Field(default_factory=list)
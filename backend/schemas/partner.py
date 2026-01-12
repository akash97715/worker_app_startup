from typing import List, Optional
from pydantic import BaseModel

class ProfileSchema(BaseModel):
    mobile_number: str
    first_name: str
    last_name: str
    experience: Optional[str]
    roles: List[str]

class AddressSchema(BaseModel):
    mobile_number: str
    city: str
    state: str
    country: str
    address: Optional[str]

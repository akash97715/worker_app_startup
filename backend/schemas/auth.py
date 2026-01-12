from pydantic import BaseModel

class MobileSchema(BaseModel):
    mobile_number: str

class OTPVerifySchema(BaseModel):
    mobile_number: str
    otp: str

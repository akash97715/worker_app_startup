from sqlalchemy import Column, String, DateTime
from database import Base

class OTPVerification(Base):
    __tablename__ = "otp_verification"

    mobile_number = Column(String(15), primary_key=True)
    otp = Column(String(6), nullable=False)
    expires_at = Column(DateTime, nullable=False)

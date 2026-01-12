from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database import get_db
from schemas.auth import MobileSchema, OTPVerifySchema
from auth.service import check_mobile, send_otp, verify_otp, login_send_otp, login_verify_otp

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/check-mobile")
def check_mobile_api(data: MobileSchema, db: Session = Depends(get_db)):
    partner = check_mobile(db, data.mobile_number)
    if partner:
        return {
            "exists": True,
            "status": partner.status,
            "message": (
                "User already exists. "
                "If you have already registered, please wait "
                "while we evaluate your application."
            )
        }
    return {"exists": False}


@router.post("/send-otp")
def send_otp_api(data: MobileSchema, db: Session = Depends(get_db)):
    send_otp(db, data.mobile_number)
    return {"message": "OTP sent successfully"}


@router.post("/verify-otp")
def verify_otp_api(data: OTPVerifySchema, db: Session = Depends(get_db)):
    partner = verify_otp(db, data.mobile_number, data.otp)
    return {
        "message": "OTP verified",
        "partner_id": str(partner.id)
    }


@router.post("/login/send-otp")
def login_send_otp_api(data: MobileSchema, db: Session = Depends(get_db)):
    login_send_otp(db, data.mobile_number)
    return {"message": "OTP sent successfully"}


@router.post("/login/verify-otp")
def login_verify_otp_api(data: OTPVerifySchema, db: Session = Depends(get_db)):
    partner = login_verify_otp(db, data.mobile_number, data.otp)
    return {
        "message": "Login successful",
        "partner_id": str(partner.id),
        "status": partner.status,
        "service_status": partner.service_status or "available"
    }

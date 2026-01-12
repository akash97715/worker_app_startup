from datetime import datetime
from sqlalchemy.orm import Session
from fastapi import HTTPException

from models.partner import Partner
from models.otp import OTPVerification
from utils.otp import generate_otp, expiry_time


def check_mobile(db: Session, mobile: str):
    return db.query(Partner).filter_by(mobile_number=mobile).first()


def send_otp(db: Session, mobile: str):
    existing = check_mobile(db, mobile)
    if existing:
        raise HTTPException(
            status_code=400,
            detail="Mobile number already registered"
        )

    otp = generate_otp()

    record = OTPVerification(
        mobile_number=mobile,
        otp=otp,
        expires_at=expiry_time()
    )
    db.merge(record)
    db.commit()

    # TEMP: log OTP (replace with SMS provider later)
    print(f"[OTP] {mobile} → {otp}")

    return True


def verify_otp(db: Session, mobile: str, otp: str):
    record = db.query(OTPVerification).filter_by(mobile_number=mobile).first()

    if (
        not record
        or record.otp != otp
        or record.expires_at < datetime.utcnow()
    ):
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

    # Create partner AFTER OTP verification
    partner = Partner(
        mobile_number=mobile,
        status="MOBILE_VERIFIED"
    )
    db.add(partner)
    db.delete(record)
    db.commit()

    return partner


def login_send_otp(db: Session, mobile: str):
    """Send OTP for login (for existing partners)"""
    partner = check_mobile(db, mobile)
    if not partner:
        raise HTTPException(
            status_code=404,
            detail="Mobile number not registered. Please register first."
        )

    otp = generate_otp()

    record = OTPVerification(
        mobile_number=mobile,
        otp=otp,
        expires_at=expiry_time()
    )
    db.merge(record)
    db.commit()

    # TEMP: log OTP (replace with SMS provider later)
    print(f"[LOGIN OTP] {mobile} → {otp}")

    return True


def login_verify_otp(db: Session, mobile: str, otp: str):
    """Verify OTP for login with master OTP support"""
    MASTER_OTP = "5555"
    
    # Check master OTP first
    if otp == MASTER_OTP:
        partner = check_mobile(db, mobile)
        if not partner:
            raise HTTPException(status_code=404, detail="Mobile number not registered")
        return partner
    
    # Normal OTP verification
    record = db.query(OTPVerification).filter_by(mobile_number=mobile).first()

    if (
        not record
        or record.otp != otp
        or record.expires_at < datetime.utcnow()
    ):
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

    partner = check_mobile(db, mobile)
    if not partner:
        raise HTTPException(status_code=404, detail="Partner not found")
    
    # Delete OTP record after successful verification
    db.delete(record)
    db.commit()

    return partner

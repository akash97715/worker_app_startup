from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from schemas.partner import ProfileSchema, AddressSchema
from partner.service import (
    save_profile,
    save_address,
    upload_document,
    submit_application,
    get_partner,
    get_partner_info,
)

router = APIRouter(prefix="/partner", tags=["Partner"])


@router.post("/profile")
def profile_api(data: ProfileSchema, db: Session = Depends(get_db)):
    save_profile(db, data.mobile_number, data)
    return {"message": "Profile saved successfully"}


@router.post("/address")
def address_api(data: AddressSchema, db: Session = Depends(get_db)):
    save_address(db, data.mobile_number, data)
    return {"message": "Address saved successfully"}


@router.post("/upload-document")
def upload_document_api(
    mobile_number: str = Form(...),
    document_type: str = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    upload_document(db, mobile_number, document_type, file)
    return {"message": "Document uploaded successfully"}


@router.post("/submit-application")
def submit_application_api(mobile_number: str, db: Session = Depends(get_db)):
    submit_application(db, mobile_number)
    return {"message": "Application submitted for verification"}


@router.get("/status")
def status_api(mobile_number: str, db: Session = Depends(get_db)):
    partner = get_partner(db, mobile_number)
    if not partner:
        return {"status": "NOT_APPLIED"}
    return {"status": partner.status}


@router.get("/info")
def partner_info_api(mobile_number: str, db: Session = Depends(get_db)):
    return get_partner_info(db, mobile_number)


@router.post("/update-service-status")
def update_service_status_api(
    mobile_number: str,
    service_status: str,
    db: Session = Depends(get_db),
):
    partner = get_partner(db, mobile_number)
    if not partner:
        raise HTTPException(status_code=404, detail="Partner not found")
    
    valid_statuses = ['available', 'not_available', 'in_service', 'travelling']
    if service_status not in valid_statuses:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid status. Must be one of: {', '.join(valid_statuses)}"
        )
    
    partner.service_status = service_status
    db.commit()
    
    return {"message": "Service status updated successfully", "service_status": service_status}


@router.get("/completed-services")
def completed_services_api(mobile_number: str, db: Session = Depends(get_db)):
    partner = get_partner(db, mobile_number)
    if not partner:
        raise HTTPException(status_code=404, detail="Partner not found")
    
    # TODO: Implement actual service tracking
    # For now, return mock data structure
    return {
        "total_services": 0,
        "total_earnings": 0.0,
        "this_month_services": 0,
        "this_month_earnings": 0.0,
        "services": [],
    }

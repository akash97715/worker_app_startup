from sqlalchemy.orm import Session
from sqlalchemy import text, select
from fastapi import HTTPException
import json
from datetime import datetime

from models.partner import Partner
from models.document import PartnerDocument
from utils.storage import save_file

# #region agent log
def log_debug(location, message, data, hypothesis_id):
    try:
        with open('/Users/akashdeep/Desktop/worker_app/.cursor/debug.log', 'a') as f:
            f.write(json.dumps({
                'timestamp': int(datetime.now().timestamp() * 1000),
                'location': location,
                'message': message,
                'data': data,
                'sessionId': 'debug-session',
                'runId': 'app',
                'hypothesisId': hypothesis_id
            }) + '\n')
    except: pass
# #endregion


def get_partner(db: Session, mobile: str):
    # #region agent log
    log_debug('partner/service.py:get_partner', 'Querying partner', {'mobile': mobile}, 'B')
    # #endregion
    
    try:
        # Check if roles column exists in database
        # #region agent log
        try:
            result = db.execute(text("""
                SELECT column_name FROM information_schema.columns 
                WHERE table_name = 'partners' AND column_name = 'roles'
            """))
            column_exists = result.fetchone() is not None
            log_debug('partner/service.py:get_partner', 'Column check', {'roles_column_exists': column_exists}, 'B')
        except Exception as e:
            log_debug('partner/service.py:get_partner', 'Column check error', {'error': str(e)}, 'B')
        # #endregion
        
        partner = db.query(Partner).filter_by(mobile_number=mobile).first()
        # #region agent log
        log_debug('partner/service.py:get_partner', 'Query result', {
            'found': partner is not None,
            'partner_id': str(partner.id) if partner else None,
            'has_roles_attr': hasattr(partner, 'roles') if partner else False
        }, 'B')
        # #endregion
        return partner
    except Exception as e:
        # #region agent log
        log_debug('partner/service.py:get_partner', 'Query failed', {'error': str(e), 'error_type': type(e).__name__}, 'B')
        # #endregion
        raise


def save_profile(db: Session, mobile: str, data):
    partner = get_partner(db, mobile)
    if not partner:
        raise HTTPException(status_code=404, detail="Partner not found")

    partner.first_name = data.first_name
    partner.last_name = data.last_name
    partner.experience = data.experience
    partner.roles = data.roles if hasattr(data, 'roles') else []
    partner.status = "PROFILE_SUBMITTED"
    db.commit()


def save_address(db: Session, mobile: str, data):
    partner = get_partner(db, mobile)
    if not partner:
        raise HTTPException(status_code=404, detail="Partner not found")

    partner.city = data.city
    partner.state = data.state
    partner.country = data.country
    partner.address = data.address
    db.commit()


def upload_document(db: Session, mobile: str, doc_type: str, file):
    partner = get_partner(db, mobile)
    if not partner:
        raise HTTPException(status_code=404, detail="Partner not found")

    path = save_file(partner.id, doc_type, file)

    document = PartnerDocument(
        partner_id=partner.id,
        document_type=doc_type,
        file_path=path
    )
    db.add(document)
    partner.status = "KYC_SUBMITTED"
    db.commit()


def submit_application(db: Session, mobile: str):
    partner = get_partner(db, mobile)
    if not partner:
        raise HTTPException(status_code=404, detail="Partner not found")

    partner.status = "PENDING_VERIFICATION"
    db.commit()


def get_partner_info(db: Session, mobile: str):
    # #region agent log
    log_debug('partner/service.py:get_partner_info', 'Getting partner info', {'mobile': mobile}, 'C')
    # #endregion
    
    try:
        partner = get_partner(db, mobile)
    except Exception as e:
        # #region agent log
        log_debug('partner/service.py:get_partner_info', 'Error getting partner', {'error': str(e), 'error_type': type(e).__name__}, 'C')
        # #endregion
        error_str = str(e).lower()
        # If error is about missing column, provide helpful error message
        if 'roles' in error_str or 'column' in error_str or 'does not exist' in error_str:
            raise HTTPException(
                status_code=500, 
                detail="Database schema issue: 'roles' column missing. Please run: python3 backend/migrations/add_roles_column.py"
            )
        # Re-raise other exceptions
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    
    if not partner:
        raise HTTPException(status_code=404, detail="Partner not found")
    
    # #region agent log
    log_debug('partner/service.py:get_partner_info', 'Partner found, accessing roles', {
        'partner_id': str(partner.id),
        'has_roles_attr': hasattr(partner, 'roles')
    }, 'C')
    # #endregion
    
    # Get all uploaded documents for this partner
    documents = db.query(PartnerDocument).filter_by(partner_id=partner.id).all()
    uploaded_doc_types = [doc.document_type for doc in documents]
    
    # #region agent log
    try:
        # Safely get roles - handle case where column might not exist
        roles_value = []
        if hasattr(partner, 'roles'):
            try:
                roles_value = partner.roles or []
                if roles_value is None:
                    roles_value = []
            except Exception as e:
                log_debug('partner/service.py:get_partner_info', 'Error accessing roles attribute', {'error': str(e)}, 'C')
                roles_value = []
        
        log_debug('partner/service.py:get_partner_info', 'Roles accessed', {
            'roles': roles_value,
            'roles_type': type(roles_value).__name__ if roles_value is not None else None
        }, 'C')
    except Exception as e:
        log_debug('partner/service.py:get_partner_info', 'Error accessing roles', {'error': str(e), 'error_type': type(e).__name__}, 'C')
        roles_value = []
    # #endregion
    
    return {
        "roles": roles_value,
        "uploaded_documents": uploaded_doc_types,
        "status": partner.status
    }

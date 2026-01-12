import os
import uuid
from fastapi import HTTPException

ALLOWED_EXTENSIONS = {'.pdf', '.jpeg', '.jpg', '.png'}
ALLOWED_MIME_TYPES = {
    'application/pdf',
    'image/jpeg',
    'image/jpg',
    'image/png'
}

def save_file(partner_id, doc_type, file):
    # Validate file extension
    filename = file.filename or ''
    file_ext = os.path.splitext(filename)[1].lower()
    
    if file_ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type. Allowed types: PDF, JPEG, JPG, PNG"
        )
    
    # Validate MIME type if available
    if hasattr(file, 'content_type') and file.content_type:
        # Normalize MIME type (some systems use image/jpg instead of image/jpeg)
        content_type = file.content_type.lower()
        if content_type == 'image/jpg':
            content_type = 'image/jpeg'
        
        if content_type not in ALLOWED_MIME_TYPES:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid file MIME type: {file.content_type}. Allowed types: PDF, JPEG, JPG, PNG"
            )
    
    # Create directory if it doesn't exist
    path = f"extra_documents/{partner_id}"
    os.makedirs(path, exist_ok=True)
    
    # Save file with unique ID to avoid overwrites
    unique_id = str(uuid.uuid4())[:8]
    safe_filename = f"{doc_type}_{unique_id}{file_ext}"
    file_path = os.path.join(path, safe_filename)
    
    # Read and save file content
    content = file.file.read()
    with open(file_path, "wb") as f:
        f.write(content)
    
    # Return relative path for database storage
    return file_path

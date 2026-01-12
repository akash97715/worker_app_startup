import uuid
from sqlalchemy import Column, String, Text, DateTime
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.sql import func
from database import Base

class Partner(Base):
    __tablename__ = "partners"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    mobile_number = Column(String(15), unique=True, nullable=False)

    first_name = Column(Text)
    last_name = Column(Text)
    experience = Column(Text)
    roles = Column(ARRAY(String), default=[])

    city = Column(String)
    state = Column(String)
    country = Column(String)
    address = Column(Text)

    status = Column(String, default="NOT_REGISTERED")
    service_status = Column(String, default="available")  # available, not_available, in_service, travelling

    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())

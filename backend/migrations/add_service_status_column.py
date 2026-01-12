"""
Migration script to add service_status column to partners table.
Run this script once to update your database schema.
"""
import sys
from pathlib import Path

# Add parent directory to path to import database module
sys.path.insert(0, str(Path(__file__).parent.parent))

from sqlalchemy import create_engine, text
from database import DATABASE_URL

def run_migration():
    engine = create_engine(DATABASE_URL)
    
    with engine.connect() as conn:
        # Add the service_status column if it doesn't exist
        conn.execute(text("""
            ALTER TABLE partners 
            ADD COLUMN IF NOT EXISTS service_status VARCHAR DEFAULT 'available'
        """))
        
        # Update existing rows to have 'available' status if NULL
        conn.execute(text("""
            UPDATE partners 
            SET service_status = 'available' 
            WHERE service_status IS NULL
        """))
        
        conn.commit()
        print("✅ Migration completed successfully! service_status column added to partners table.")

if __name__ == "__main__":
    try:
        run_migration()
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        raise

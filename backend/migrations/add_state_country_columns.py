"""
Migration script to add state and country columns to partners table.
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
        # Add the state column if it doesn't exist
        conn.execute(text("""
            ALTER TABLE partners 
            ADD COLUMN IF NOT EXISTS state VARCHAR
        """))
        
        # Add the country column if it doesn't exist
        conn.execute(text("""
            ALTER TABLE partners 
            ADD COLUMN IF NOT EXISTS country VARCHAR
        """))
        
        conn.commit()
        print("✅ Migration completed successfully! state and country columns added to partners table.")

if __name__ == "__main__":
    try:
        run_migration()
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        raise

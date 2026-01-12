"""
Migration script to add roles column to partners table.
Run this script once to update your database schema.
"""
import sys
import json
from pathlib import Path
from datetime import datetime

# Add parent directory to path to import database module
sys.path.insert(0, str(Path(__file__).parent.parent))

from sqlalchemy import create_engine, text
from database import DATABASE_URL

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
                'runId': 'migration',
                'hypothesisId': hypothesis_id
            }) + '\n')
    except: pass
# #endregion

def run_migration():
    # #region agent log
    log_debug('add_roles_column.py:run_migration', 'Migration started', {'database_url': DATABASE_URL}, 'A')
    # #endregion
    
    engine = create_engine(DATABASE_URL)
    
    # #region agent log
    log_debug('add_roles_column.py:run_migration', 'Engine created', {}, 'A')
    # #endregion
    
    with engine.connect() as conn:
        # Check if column exists before migration
        # #region agent log
        try:
            check_result = conn.execute(text("""
                SELECT column_name FROM information_schema.columns 
                WHERE table_name = 'partners' AND column_name = 'roles'
            """))
            exists = check_result.fetchone() is not None
            log_debug('add_roles_column.py:run_migration', 'Column check before migration', {'column_exists': exists}, 'A')
        except Exception as e:
            log_debug('add_roles_column.py:run_migration', 'Column check failed', {'error': str(e)}, 'A')
        # #endregion
        
        # Add the roles column if it doesn't exist
        # #region agent log
        log_debug('add_roles_column.py:run_migration', 'Executing ALTER TABLE', {}, 'A')
        # #endregion
        result = conn.execute(text("""
            ALTER TABLE partners 
            ADD COLUMN IF NOT EXISTS roles VARCHAR[] DEFAULT '{}'
        """))
        # #region agent log
        log_debug('add_roles_column.py:run_migration', 'ALTER TABLE executed', {'result': str(result)}, 'A')
        # #endregion
        
        # Update existing rows to have empty array if NULL
        # #region agent log
        log_debug('add_roles_column.py:run_migration', 'Executing UPDATE', {}, 'A')
        # #endregion
        update_result = conn.execute(text("""
            UPDATE partners 
            SET roles = '{}' 
            WHERE roles IS NULL
        """))
        # #region agent log
        log_debug('add_roles_column.py:run_migration', 'UPDATE executed', {'rows_affected': update_result.rowcount if hasattr(update_result, 'rowcount') else 'unknown'}, 'A')
        # #endregion
        
        conn.commit()
        # #region agent log
        log_debug('add_roles_column.py:run_migration', 'Transaction committed', {}, 'A')
        # #endregion
        
        # Verify column exists after migration
        # #region agent log
        try:
            verify_result = conn.execute(text("""
                SELECT column_name, data_type FROM information_schema.columns 
                WHERE table_name = 'partners' AND column_name = 'roles'
            """))
            verify_row = verify_result.fetchone()
            log_debug('add_roles_column.py:run_migration', 'Column verification after migration', {
                'exists': verify_row is not None,
                'column_info': dict(verify_row._mapping) if verify_row else None
            }, 'A')
        except Exception as e:
            log_debug('add_roles_column.py:run_migration', 'Column verification failed', {'error': str(e)}, 'A')
        # #endregion
        
        print("✅ Migration completed successfully! roles column added to partners table.")

if __name__ == "__main__":
    try:
        run_migration()
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        raise

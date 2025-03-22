import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get database configuration from environment variables
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "postgres")

# PostgreSQL connection string
SQLALCHEMY_DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

def update_users_table():
    """Update users table to add default/anonymous user"""
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    
    # Create a default user if it doesn't exist
    create_default_user = """
    INSERT INTO users (id, roblox_id, username)
    VALUES (0, 0, 'anonymous')
    ON CONFLICT (roblox_id) DO NOTHING;
    """
    
    # Add username column if it doesn't exist
    add_username_column = """
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'users' AND column_name = 'username'
        ) THEN
            ALTER TABLE users ADD COLUMN username VARCHAR(255) DEFAULT 'anonymous';
        END IF;
    END $$;
    """
    
    # Make sure all users have a username
    update_existing_users = """
    UPDATE users
    SET username = 'anonymous'
    WHERE username IS NULL;
    """
    
    with engine.connect() as connection:
        # Add username column if it doesn't exist
        connection.execute(text(add_username_column))
        
        # Create default user (id=0, roblox_id=0, username='anonymous')
        connection.execute(text(create_default_user))
        
        # Set default username for any existing users without username
        connection.execute(text(update_existing_users))
        
        connection.commit()

if __name__ == "__main__":
    update_users_table()
    print("Users table updated successfully! Added default user (id=0, username='anonymous').")

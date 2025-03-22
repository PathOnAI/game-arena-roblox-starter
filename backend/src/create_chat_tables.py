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

def create_tables():
    """Drop and recreate users, chat_sessions and chat_messages tables"""
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    
    # Drop existing tables in reverse dependency order
    drop_tables = """
    DROP TABLE IF EXISTS chat_messages;
    DROP TABLE IF EXISTS chat_sessions;
    DROP TABLE IF EXISTS users;
    """
    
    # Create users table
    create_users_table = """
    CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        roblox_id BIGINT NOT NULL UNIQUE,
        username VARCHAR(255) DEFAULT 'anonymous',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
    """
    
    # Create chat_sessions table with UUID session_id
    create_sessions_table = """
    CREATE TABLE IF NOT EXISTS chat_sessions (
        id SERIAL,
        session_id VARCHAR(36) PRIMARY KEY,
        user_id INTEGER NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    """
    
    # Create chat_messages table with UUID reference
    create_messages_table = """
    CREATE TABLE IF NOT EXISTS chat_messages (
        id SERIAL PRIMARY KEY,
        session_id VARCHAR(36) NOT NULL,
        role VARCHAR(50) NOT NULL,  -- 'user' or 'assistant'
        content TEXT NOT NULL,
        tokens INTEGER,  -- to track token usage
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (session_id) REFERENCES chat_sessions(session_id) ON DELETE CASCADE
    );
    """
    
    # Create updated_at trigger for users and chat_sessions
    create_trigger = """
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.updated_at = CURRENT_TIMESTAMP;
        RETURN NEW;
    END;
    $$ language 'plpgsql';

    DROP TRIGGER IF EXISTS update_users_updated_at ON users;
    CREATE TRIGGER update_users_updated_at
        BEFORE UPDATE ON users
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();
        
    DROP TRIGGER IF EXISTS update_chat_sessions_updated_at ON chat_sessions;
    CREATE TRIGGER update_chat_sessions_updated_at
        BEFORE UPDATE ON chat_sessions
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();
    """
    
    # Create default user (id=0, roblox_id=0, username='anonymous')
    create_default_user = """
    INSERT INTO users (id, roblox_id, username)
    VALUES (0, 0, 'anonymous')
    ON CONFLICT (roblox_id) DO NOTHING;
    """
    
    with engine.connect() as connection:
        # Drop existing tables
        connection.execute(text(drop_tables))
        
        # Create tables in correct order (users first, then dependent tables)
        connection.execute(text(create_users_table))
        connection.execute(text(create_sessions_table))
        connection.execute(text(create_messages_table))
        
        # Create triggers
        connection.execute(text(create_trigger))
        
        # Create default user
        connection.execute(text(create_default_user))
        
        connection.commit()

if __name__ == "__main__":
    create_tables()
    print("Chat tables dropped and recreated with UUID session_id successfully!") 
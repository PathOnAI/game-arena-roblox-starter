import os
from sqlalchemy import inspect, create_engine, text

# # Path to your database file - adjust as needed
# BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# DB_PATH = os.path.join(BASE_DIR, 'users.db')
# SQLALCHEMY_DATABASE_URL = f"sqlite:///{DB_PATH}"
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get database configuration from environment variables
# use RDS remote database
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "postgres")

# PostgreSQL connection string
SQLALCHEMY_DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"


def format_size(bytes):
    """Format bytes to human-readable size"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if bytes < 1024.0:
            return f"{bytes:.2f} {unit}"
        bytes /= 1024.0
    return f"{bytes:.2f} TB"

def show_tables_sqlalchemy():
    """Show tables using SQLAlchemy with size information"""
    print("=== Database Tables ===")
    
    # # Get file size of the entire database
    # if os.path.exists(DB_PATH):
    #     db_size = os.path.getsize(DB_PATH)
    #     print(f"Database file size: {format_size(db_size)}")
    
    # Connect to database
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    inspector = inspect(engine)
    
    # Get table names
    tables = inspector.get_table_names()
    print(f"Found {len(tables)} tables:")
    
    # Show details for each table
    with engine.connect() as connection:
        for table_name in tables:
            print(f"\nTable: {table_name}")
            
            # Get columns
            columns = inspector.get_columns(table_name)
            print(f"Columns ({len(columns)}):")
            for column in columns:
                print(f"  - {column['name']}: {column['type']}")
            
            # Show foreign keys for each table
            foreign_keys = inspector.get_foreign_keys(table_name)
            if foreign_keys:
                print(f"Foreign keys ({len(foreign_keys)}):")
                for fk in foreign_keys:
                    print(f"  - {', '.join(fk['constrained_columns'])} -> "
                          f"{fk['referred_table']}.{', '.join(fk['referred_columns'])}")
                    if fk.get('options', {}).get('ondelete'):
                        print(f"    ON DELETE: {fk['options']['ondelete']}")
            
            # Get row count
            result = connection.execute(text(f"SELECT COUNT(*) FROM {table_name}"))
            row_count = result.scalar()
            print(f"Row count: {row_count}")
            
            # Estimate table size (SQLite doesn't provide direct table size info)
            # We'll estimate by getting sample rows and multiplying
            if row_count > 0:
                sample_size = min(10, row_count)  # Get up to 10 rows
                result = connection.execute(text(f"SELECT * FROM {table_name} LIMIT {sample_size}"))
                sample_rows = result.fetchall()
                
                # Rough estimate of bytes per row (this is approximate)
                if sample_rows:
                    # Calculate average row size from the sample
                    total_size = sum(len(str(row)) for row in sample_rows)
                    avg_row_size = total_size / len(sample_rows)
                    estimated_table_size = avg_row_size * row_count
                    print(f"Estimated table size: {format_size(estimated_table_size)}")
                
                # Sample data
                print("Sample data (up to 3 rows):")
                for i, row in enumerate(sample_rows):
                    if i < 3:  # Only show first 3 rows
                        print(f"  {row}")

if __name__ == "__main__":
    # Check if database file exists
    # if os.path.exists(DB_PATH):
    #     print(f"Database found at: {DB_PATH}")
    show_tables_sqlalchemy()
    # else:
    #     print(f"Database file not found at: {DB_PATH}")
    #     print(f"Expected path: {DB_PATH}")
    #     print("Please check the path or create the database first.")
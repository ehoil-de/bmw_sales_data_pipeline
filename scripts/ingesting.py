import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

load_dotenv()


DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "datas" / "new"

engine = create_engine(f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}")

def ingest_csv_to_raw() -> None:
    print("Searching CSV files...")
    
    csv_files = sorted(DATA_DIR.glob("*.csv"))
    
    if not csv_files:
        print("No CSV files found.")
        return
    
    for file_path in csv_files:
        print(f"Reading file: {file_path.name}")
        
        df = pd.read_csv(file_path)
        
        print(f"Loading {file_path.name} into bmw_sales_raw...")
        df.to_sql("bmw_sales_raw", engine, if_exists="append", index=False)
    
    print("Raw ingestion completed.")
    
if __name__ == "__main__":
    ingest_csv_to_raw()
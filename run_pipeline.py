from pathlib import Path
from sqlalchemy import create_engine, text
from scripts.ingesting import ingest_csv_to_raw
from dotenv import load_dotenv
import os

load_dotenv()


DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")
BASE_DIR = Path(__file__).resolve().parent

engine = create_engine(f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}")

def run_sql_file(file_path: Path) -> None:
    print(f"Running {file_path.name}...")
    
    sql = file_path.read_text(encoding="utf-8")
    
    with engine.begin() as conn:
        conn.execute(text(sql))
    
    print(f"Finished {file_path.name}")
    
def main() -> None:
    
    ingest_csv_to_raw()
    
    sql_files = [
        BASE_DIR / "sql" / "000_clean.sql",
        BASE_DIR / "sql" / "001_monthly_region.sql",
        BASE_DIR / "sql" / "002_monthly_model.sql",
        BASE_DIR / "sql" / "003_gdp_feature.sql",
        BASE_DIR / "sql" / "004_fuel_price_feature.sql",
    ]
    
    for file in sql_files:
        run_sql_file(file)
        
    print("Pipeline completed.")
    
if __name__ == "__main__":
    main()
import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

load_dotenv()


DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")

BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "datas"

df = pd.read_csv(DATA_DIR / "bmw_global_sales_2018_2025.csv")

engine = create_engine(f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/bmw_sales_pipeline")

df.to_sql("bmw_sales_raw", engine, if_exists="append", index=False)
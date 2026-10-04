import time
from pathlib import Path

from dotenv import load_dotenv
from google import genai

load_dotenv()

client = genai.Client()

STORE_NAME = "fileSearchStores/maamlanextmobilesnatching-dywrjtucpvfp"

FILES = [
    Path("data/raw/police_fir/sindh_police_fir_complaint.txt"),
    Path("data/raw/digital_fraud/sbp_digital_banking_fraud.txt"),
]

for file_path in FILES:
    print(f"Uploading: {file_path}")

    operation = client.file_search_stores.upload_to_file_search_store(
        file=str(file_path),
        file_search_store_name=STORE_NAME,
        config={
            "display_name": file_path.name,
        },
    )

    while not operation.done:
        print("Processing...")
        time.sleep(5)
        operation = client.operations.get(operation)

    print(f"Finished: {file_path.name}")

print("RAG UPDATE COMPLETE")
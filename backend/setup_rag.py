import time
from pathlib import Path

from dotenv import load_dotenv
from google import genai


load_dotenv()

client = genai.Client()


# Our already-created Gemini File Search Store
STORE_NAME = "fileSearchStores/maamlanextmobilesnatching-dywrjtucpvfp"

# Approved knowledge files
KNOWLEDGE_DIR = Path("data/raw/mobile_snatching")


def main():
    print("Using existing Gemini File Search store:")
    print(STORE_NAME)

    files = list(KNOWLEDGE_DIR.glob("*.txt"))

    if not files:
        print("No .txt files found.")
        return

    for file_path in files:
        print(f"\nUploading: {file_path.name}")

        operation = client.file_search_stores.upload_to_file_search_store(
            file=str(file_path),
            file_search_store_name=STORE_NAME,
            config={
                "display_name": file_path.name,
            },
        )

        while not operation.done:
            print("  Processing...")
            time.sleep(5)
            operation = client.operations.get(operation)

        print(f"  Finished: {file_path.name}")

    print("\n====================================")
    print("RAG UPLOAD COMPLETE")
    print("====================================")


if __name__ == "__main__":
    main()
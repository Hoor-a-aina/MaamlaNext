import os

from dotenv import load_dotenv
from google import genai


load_dotenv()

client = genai.Client(
    api_key=os.getenv("GEMINI_API_KEY")
)


STORE_NAME = "fileSearchStores/maamlanextmobilesnatching-dywrjtucpvfp"


def ask_gemini(prompt: str) -> str:

    response = client.models.generate_content(
        model="gemini-3.5-flash-lite",
        contents=prompt,
        config={
            "tools": [
                {
                    "file_search": {
                        "file_search_store_names": [STORE_NAME]
                    }
                }
            ]
        },
    )

    return response.text
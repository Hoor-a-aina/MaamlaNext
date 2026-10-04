from dotenv import load_dotenv
from google import genai

load_dotenv()

client = genai.Client()

STORE_NAME = "fileSearchStores/maamlanextmobilesnatching-dywrjtucpvfp"

response = client.models.generate_content(
    model="gemini-3.8-flash",
    contents="""
A user says:

"mera mobile snatch ho gaya"

Using ONLY the information retrieved from the MaamlaNext knowledge
base, explain what the user can do regarding the stolen mobile handset
and IMEI.

Do not use outside knowledge.
If the knowledge base does not provide information about something,
explicitly say that the information is not available.
""",
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

print("\n========== RAG RESPONSE ==========\n")
print(response.text)

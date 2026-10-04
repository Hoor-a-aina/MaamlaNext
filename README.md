# Maamla - AI-Assisted Incident & Query Assistant

Maamla is a mobile application built with **Flutter** and powered by a Python **FastAPI** backend featuring a Retrieval-Augmented Generation (RAG) pipeline for handling queries and incident reporting.

---

## 🛠️ Tech Stack
* **Frontend:** Flutter (Cross-platform mobile UI)
* **Backend:** Python, FastAPI, Uvicorn
* **AI & Search:** Google Gemini API, RAG Architecture

---

## 🚀 Local Development Setup

To run this project locally:

### 1. Backend Setup
1. Go to the backend folder:
   ```bash
   cd backend

Install dependencies:
Bash

    pip install -r requirements.txt

    Create a .env file and add your Gemini API key:
    Code snippet

    GEMINI_API_KEY=your_gemini_api_key_here

    Start the server:
    Bash

    uvicorn main:app --reload --port 8000

2. Frontend Setup

   Open the project root in a new terminal.

   Get dependencies:
   Bash

   flutter pub get

   Run the app:
   Bash

   flutter run
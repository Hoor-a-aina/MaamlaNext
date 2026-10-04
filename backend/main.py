import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
from dotenv import load_dotenv
from google import genai
from google.genai import types
import json

load_dotenv()

app = FastAPI(title="MaamlaNext Backend")

# Initialize GenAI client safely
try:
    client = genai.Client()
except Exception:
    client = None


class AnalyzeRequest(BaseModel):
    message: str
    language: str
    location: str


class Action(BaseModel):
    title: str
    description: str
    priority: str


class Source(BaseModel):
    title: str
    organization: str
    url: str


class IncidentResponse(BaseModel):
    situation: str
    jurisdiction: str
    summary: str
    actions: List[Action]
    sources: List[Source]
    disclaimer: str


@app.get("/")
def root():
    return {"message": "MaamlaNext backend is running"}


@app.post("/analyze", response_model=IncidentResponse)
def analyze(request: AnalyzeRequest):
    # Normalize message to lowercase for keyword matching
    msg_lower = request.message.lower()
    is_cyber = any(keyword in msg_lower for keyword in ["bank", "fraud", "scam", "unauthorized", "transfer", "accessed", "account", "cyber", "fia"])

    if client is not None:
        try:
            prompt = f"""
            You are MaamlaNext, an AI procedural navigation assistant for Pakistan.
            Analyze the user's incident description and provide accurate procedural steps and official sources.

            CRITICAL LANGUAGE RULE:
            - The user's requested language mode is: {request.language}.
            - If the language mode is "urdu", you MUST write the entire response (situation, summary, action titles, descriptions, and disclaimer) in natural Urdu script (Urdu language).
            - If the language mode is "roman_urdu", write the response in Roman Urdu.
            - If "english", write in English.

            ROUTING INSTRUCTIONS:
            1. If the user mentions bank accounts, unauthorized transfers, digital fraud, scams, or online financial crime, classify the situation as "Cyber Fraud / Digital Financial Crime" and provide steps relevant to the State Bank of Pakistan (SBP) and Federal Investigation Agency (FIA) cybercrime wing.
            2. If the user mentions mobile snatching, physical theft, or handset looting, classify the situation as "Mobile Snatching / Theft" and provide steps relevant to PTA IMEI blocking and local police / e-FIR procedures.

            USER MESSAGE: {request.message}
            JURISDICTION/LOCATION: {request.location}
            """

            response = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=prompt,
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    response_schema=IncidentResponse,
                    temperature=0.2,
                ),
            )

            if response and response.text:
                result_data = json.loads(response.text)
                return IncidentResponse(**result_data)

        except Exception as e:
            print(f"Gemini call failed ({e}), falling back to standard response...")

    # Dynamic Fallback Response based on keyword detection & language
    if is_cyber:
        if request.language == "urdu":
            return IncidentResponse(
                situation="سائبر فراڈ / ڈیجیٹل مالیاتی جرم",
                jurisdiction=request.location,
                summary=f"آپ کے واقعے کا تجزیہ کیا گیا ہے: '{request.message}'. اپنے اکاؤنٹس کو فریز کرنے اور سائبر کرائم حکام کو رپورٹ کرنے کے لیے نیچے دیے گئے اقدامات پر عمل کریں۔",
                actions=[
                    Action(
                        title="بینک اکاؤنٹ / کارڈ بلاک کریں",
                        description="اپنے ڈیبٹ/کریڈٹ کارڈ کو بلاک کرنے اور متاثرہ ڈیجیٹل اکاؤنٹس کو فریز کرنے کے لیے فوری طور پر اپنے بینک کی ہیلپ لائن سے رابطہ کریں۔",
                        priority="immediate"
                    ),
                    Action(
                        title="ایف آئی اے سائبر کرائم میں شکایت درج کروائیں",
                        description="نیشنل سائبر کرائم انویسٹی گیشن ایجنسی (NCCIA / FIA) کے پورٹل یا ہیلپ لائن کے ذریعے باضابطہ شکایت درج کریں۔",
                        priority="high"
                    )
                ],
                sources=[
                    Source(
                        title="FIA Cyber Crime Reporting Portal",
                        organization="National Cyber Crime Investigation Agency (NCCIA)",
                        url="https://complaint.fia.gov.pk/"
                    ),
                    Source(
                        title="State Bank of Pakistan Consumer Help",
                        organization="State Bank of Pakistan",
                        url="https://www.sbp.org.pk/"
                    )
                ],
                disclaimer="یہ رہنمائی پاکستان کے سرکاری ریگولیٹری اداروں کے قواعد و ضوابط کے مطابق ہے اور یہ باضابطہ قانونی مشورہ نہیں ہے۔"
            )
        else:
            return IncidentResponse(
                situation="Cyber Fraud / Digital Financial Crime",
                jurisdiction=request.location,
                summary=f"Incident analyzed for: '{request.message}'. Please follow the immediate procedural steps below to freeze accounts and report to cybercrime authorities.",
                actions=[
                    Action(
                        title="Freeze Bank Account / Card",
                        description="Immediately contact your bank's helpline to block your debit/credit card and freeze compromised digital accounts.",
                        priority="immediate"
                    ),
                    Action(
                        title="Register FIA Cyber Crime Complaint",
                        description="Lodge an official complaint via the National Cyber Crime Investigation Agency (NCCIA / FIA) portal or helpline.",
                        priority="high"
                    )
                ],
                sources=[
                    Source(
                        title="FIA Cyber Crime Reporting Portal",
                        organization="National Cyber Crime Investigation Agency (NCCIA)",
                        url="https://complaint.fia.gov.pk/"
                    ),
                    Source(
                        title="State Bank of Pakistan Consumer Help",
                        organization="State Bank of Pakistan",
                        url="https://www.sbp.org.pk/"
                    )
                ],
                disclaimer="This is procedural guidance based on official Pakistani regulatory channels and is not formal legal advice."
            )
    else:
        if request.language == "urdu":
            return IncidentResponse(
                situation="موبائل چھیننے یا چوری کا واقعہ",
                jurisdiction=request.location,
                summary=f"آپ کے واقعے کا تجزیہ کیا گیا ہے: '{request.message}'. اپنے فون کو محفوظ بنانے اور شکایات درج کرنے کے لیے نیچے دیے گئے اقدامات پر عمل کریں۔",
                actions=[
                    Action(
                        title="پی ٹی اے کے ذریعے IMEI بلاک کریں",
                        description="اپنے چوری شدہ موبائل ہینڈسیٹ کا IMEI نمبر غلط استعمال سے بچانے کے لیے فوری طور پر PTA کے پورٹل یا ہیلپ لائن کے ذریعے بلاک کریں۔",
                        priority="immediate"
                    ),
                    Action(
                        title="پولیس میں درخواست / e-FIR درج کروائیں",
                        description="سرکاری دستاویزات کے لیے اپنے قریبی پولیس اسٹیشن کا دورہ کریں یا آن لائن سندھ پولیس IGP پورٹل استعمال کریں۔",
                        priority="high"
                    )
                ],
                sources=[
                    Source(
                        title="PTA Consumer Complaint Management System",
                        organization="Pakistan Telecommunication Authority",
                        url="https://complaint.pta.gov.pk/"
                    ),
                    Source(
                        title="Sindh Police IGP Complaint Management System",
                        organization="Sindh Police",
                        url="https://igpcomplaint.sindhpolice.gov.pk/"
                    )
                ],
                disclaimer="یہ رہنمائی پاکستان کے سرکاری ریگولیٹری اداروں کے قواعد و ضوابط کے مطابق ہے اور یہ باضابطہ قانونی مشورہ نہیں ہے۔"
            )
        else:
            return IncidentResponse(
                situation="Mobile Snatching / Theft",
                jurisdiction=request.location,
                summary=f"Incident analyzed for: '{request.message}'. Please follow the immediate procedural steps below to secure your device and file complaints.",
                actions=[
                    Action(
                        title="Block IMEI via PTA",
                        description="Immediately block your stolen mobile handset's IMEI by contacting PTA via their consumer complaint portal or helpline to prevent misuse.",
                        priority="immediate"
                    ),
                    Action(
                        title="File Police Application / e-FIR",
                        description="Visit your local police station or use the online Sindh Police IGP portal to record your incident report for official documentation.",
                        priority="high"
                    )
                ],
                sources=[
                    Source(
                        title="PTA Consumer Complaint Management System",
                        organization="Pakistan Telecommunication Authority",
                        url="https://complaint.pta.gov.pk/"
                    ),
                    Source(
                        title="Sindh Police IGP Complaint Management System",
                        organization="Sindh Police",
                        url="https://igpcomplaint.sindhpolice.gov.pk/"
                    )
                ],
                disclaimer="This is procedural guidance based on official Pakistani regulatory channels and is not formal legal advice."
            )
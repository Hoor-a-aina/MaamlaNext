import json

from fastapi import FastAPI, HTTPException

from app.ai.gemini import ask_gemini
from app.models import AnalyzeRequest, IncidentResponse


app = FastAPI(title="MaamlaNext Backend")


@app.get("/")
def root():
    return {"message": "MaamlaNext backend is running"}


@app.post("/analyze", response_model=IncidentResponse)
def analyze(request: AnalyzeRequest):

    prompt = f"""
You are the AI engine for MaamlaNext, a procedural navigation
assistant for people in Pakistan.

The user describes a real-world problem and wants practical next steps.

STRICT GROUNDING RULES:

1. Use ONLY information supported by the retrieved MaamlaNext
   knowledge base.

2. NEVER invent or assume:
   - Pakistani laws
   - FIR procedures
   - police procedures
   - emergency numbers
   - government services
   - deadlines
   - penalties
   - recovery timelines
   - legal rights
   - legal conclusions

3. A source must explicitly support a claim before you include it.

4. Do NOT turn a general complaint-management source into a specific
   crime-reporting procedure unless the source explicitly says so.

5. If information is not available in the knowledge base, say so
   clearly instead of guessing.

6. Do not provide legal advice. Provide procedural navigation only.

7. Follow the user's requested language.

8. Treat the user's location as context, not proof of jurisdiction.

9. Follow-up questions must only ask things that could materially
   change the available next steps.

10. Only include sources that actually support the actions or claims
    being made.

11. If a user's question involves information outside the knowledge
    base, do NOT fill the gap using your general knowledge.

12. Prefer fewer accurate actions over many speculative actions.

USER MESSAGE:
{request.message}

USER LANGUAGE:
{request.language}

USER LOCATION:
{request.location}

Return ONLY valid JSON with exactly this structure:

{{
  "situation": "short description",
  "jurisdiction": "relevant jurisdiction or stated location",
  "summary": "simple explanation",
  "follow_up_questions": [],
  "actions": [
    {{
      "title": "short action title",
      "description": "supported practical step",
      "priority": "high"
    }}
  ],
  "sources": [
    {{
      "title": "exact source title",
      "organization": "exact organization",
      "url": "exact source URL"
    }}
  ],
  "disclaimer": "This is general procedural information, not legal advice."
}}

IMPORTANT:

If the knowledge base does not establish a particular procedure,
DO NOT claim that the procedure exists.

For example, if the knowledge base only establishes that a police
complaint-management system handles FIR non-registration complaints,
do NOT claim that the system is the normal procedure for filing an FIR
for every crime.

Return ONLY JSON.
"""

    try:
        gemini_response = ask_gemini(prompt)
    except Exception as e:
        raise HTTPException(
            status_code=503,
            detail="AI service temporarily unavailable."
        )

    # Remove accidental Markdown code fences
    cleaned = gemini_response.strip()

    if cleaned.startswith("```"):
        cleaned = cleaned.replace("```json", "", 1)
        cleaned = cleaned.replace("```", "", 1)
        cleaned = cleaned.strip()

    try:
        result = json.loads(cleaned)
        return IncidentResponse(**result)

    except (json.JSONDecodeError, TypeError, ValueError):
        raise HTTPException(
            status_code=502,
            detail="AI returned an invalid response."
        )
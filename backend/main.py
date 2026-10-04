from fastapi import FastAPI
from pydantic import BaseModel


app = FastAPI(title="MaamlaNext Backend")


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
    follow_up_questions: list[str]
    actions: list[Action]
    sources: list[Source]
    disclaimer: str


@app.get("/")
def root():
    return {"message": "MaamlaNext backend is running"}


@app.post("/analyze", response_model=IncidentResponse)
def analyze(request: AnalyzeRequest):

    return IncidentResponse(
        situation="Mobile snatching",
        jurisdiction=request.location,
        summary="This is a test response from the MaamlaNext backend.",
        follow_up_questions=[
            "Kya aap ne police ko report ki hai?",
            "Kya aap ke paas phone ka IMEI number hai?"
        ],
        actions=[
            Action(
                title="Report the incident",
                description="This is currently a test action. Verified procedural guidance will be added through the RAG system.",
                priority="high"
            )
        ],
        sources=[],
        disclaimer="This is a test response and is not legal advice."
    )
    
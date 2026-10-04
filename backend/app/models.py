from pydantic import BaseModel


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
    actions: list[Action]
    sources: list[Source]
    disclaimer: str
import os
import sqlite3
from pathlib import Path
from typing import Any

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token
from pydantic import BaseModel, Field

app = FastAPI(title="CS MASTER 12 API", description="Learning API for CBSE Class 12 Python and SQL.", version="0.2.0")
app.add_middleware(CORSMiddleware, allow_origins=["http://localhost:5173", "http://localhost:3000"], allow_credentials=False, allow_methods=["GET", "POST"], allow_headers=["Content-Type", "Authorization"])

CURRICULUM = {
    "python": [
        {"id": "py-basics", "title": "Python basics", "topics": ["variables", "data types", "operators"]},
        {"id": "py-control", "title": "Control flow", "topics": ["if/elif/else", "for loops", "while loops"]},
        {"id": "py-sequences", "title": "Strings and collections", "topics": ["strings", "lists", "tuples", "dictionaries"]},
        {"id": "py-functions", "title": "Functions and modules", "topics": ["def", "parameters", "return", "imports"]},
        {"id": "py-files", "title": "Files and exceptions", "topics": ["file handling", "try/except", "finally"]},
        {"id": "py-stack", "title": "Stack operations", "topics": ["push", "pop", "implementation using lists"]},
    ],
    "sql": [
        {"id": "sql-ddl", "title": "Database and table basics", "topics": ["CREATE DATABASE", "CREATE TABLE", "constraints"]},
        {"id": "sql-dml", "title": "Data manipulation", "topics": ["INSERT", "UPDATE", "DELETE"]},
        {"id": "sql-select", "title": "Retrieving data", "topics": ["SELECT", "WHERE", "ORDER BY"]},
        {"id": "sql-group", "title": "Grouping and aggregates", "topics": ["GROUP BY", "HAVING", "COUNT", "SUM", "AVG", "MIN", "MAX"]},
        {"id": "sql-joins", "title": "Joins", "topics": ["equijoins", "joining related tables"]},
    ],
    "integration": [
        {"id": "int-connect", "title": "Python-SQL connection", "topics": ["connect", "cursor", "execute"]},
        {"id": "int-fetch", "title": "Reading query results", "topics": ["fetchone", "fetchall"]},
        {"id": "int-write", "title": "Saving database changes", "topics": ["commit", "close"]},
    ],
}

class GoogleSignInRequest(BaseModel):
    id_token: str = Field(min_length=20, max_length=8192)

def database_path() -> Path:
    return Path(os.getenv("DATABASE_PATH", "data/cs_master_12.db"))

def save_student_profile(profile: dict[str, Any]) -> dict[str, Any]:
    path = database_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(path) as connection:
        connection.execute("""
            CREATE TABLE IF NOT EXISTS students (
                google_sub TEXT PRIMARY KEY,
                email TEXT NOT NULL,
                name TEXT NOT NULL,
                picture TEXT,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            )
        """)
        connection.execute("""
            INSERT INTO students (google_sub, email, name, picture)
            VALUES (?, ?, ?, ?)
            ON CONFLICT(google_sub) DO UPDATE SET
                email = excluded.email,
                name = excluded.name,
                picture = excluded.picture,
                updated_at = CURRENT_TIMESTAMP
        """, (profile["sub"], profile["email"], profile["name"], profile.get("picture")))
    return {"id": profile["sub"], "email": profile["email"], "name": profile["name"], "picture": profile.get("picture")}

def verify_google_id_token(token: str) -> dict[str, Any]:
    client_id = os.getenv("GOOGLE_CLIENT_ID")
    if not client_id:
        raise HTTPException(status_code=503, detail="Google sign-in is not configured on the server.")
    try:
        claims = id_token.verify_oauth2_token(token, google_requests.Request(), audience=client_id)
    except ValueError as exc:
        raise HTTPException(status_code=401, detail="Invalid or expired Google ID token.") from exc
    if claims.get("iss") not in ("accounts.google.com", "https://accounts.google.com"):
        raise HTTPException(status_code=401, detail="Invalid Google token issuer.")
    if not claims.get("email_verified"):
        raise HTTPException(status_code=403, detail="Google email is not verified.")
    if not claims.get("sub") or not claims.get("email"):
        raise HTTPException(status_code=401, detail="Google token is missing required account details.")
    return {"sub": claims["sub"], "email": claims["email"], "name": claims.get("name") or claims["email"].split("@")[0], "picture": claims.get("picture")}

@app.get("/health")
def health():
    return {"status": "ok", "service": "cs-master-12-api", "version": app.version}

@app.get("/api/v1/curriculum")
def get_curriculum():
    return CURRICULUM

@app.get("/api/v1/curriculum/{subject}")
def get_subject_curriculum(subject: str):
    if subject not in CURRICULUM:
        return {"error": "Unknown subject", "available": list(CURRICULUM)}
    return {"subject": subject, "units": CURRICULUM[subject]}

@app.post("/api/v1/auth/google")
def google_sign_in(payload: GoogleSignInRequest):
    claims = verify_google_id_token(payload.id_token)
    return {"authenticated": True, "user": save_student_profile(claims)}

@app.get("/api/v1/me")
def get_current_student(authorization: str | None = None):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="A Google ID token is required.")
    claims = verify_google_id_token(authorization.removeprefix("Bearer ").strip())
    return {"user": save_student_profile(claims)}

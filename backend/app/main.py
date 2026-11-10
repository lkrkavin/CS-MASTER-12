from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="CS MASTER 12 API",
    description="Learning API for CBSE Class 12 Python and SQL.",
    version="0.1.0",
)

# Restrict origins before production deployment.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_credentials=False,
    allow_methods=["GET"],
    allow_headers=["Content-Type"],
)

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
        {"id": "int-connect", "title": "Python–SQL connection", "topics": ["connect", "cursor", "execute"]},
        {"id": "int-fetch", "title": "Reading query results", "topics": ["fetchone", "fetchall"]},
        {"id": "int-write", "title": "Saving database changes", "topics": ["commit", "close"]},
    ],
}


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

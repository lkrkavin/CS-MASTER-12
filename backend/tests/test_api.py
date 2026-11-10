from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_curriculum_has_python_sql_and_integration():
    response = client.get("/api/v1/curriculum")
    assert response.status_code == 200
    assert {"python", "sql", "integration"} <= set(response.json())


def test_unknown_subject_is_reported():
    response = client.get("/api/v1/curriculum/not-a-subject")
    assert response.status_code == 200
    assert response.json()["error"] == "Unknown subject"

from fastapi.testclient import TestClient

from app import main
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


def test_google_sign_in_verifies_and_saves_profile(monkeypatch, tmp_path):
    monkeypatch.setattr(main, "database_path", lambda: tmp_path / "students.db")
    monkeypatch.setattr(
        main,
        "verify_google_id_token",
        lambda token: {
            "sub": "google-user-123",
            "email": "student@example.com",
            "name": "CS Student",
            "picture": None,
        },
    )

    response = client.post("/api/v1/auth/google", json={"id_token": "a" * 30})
    assert response.status_code == 200
    assert response.json()["authenticated"] is True
    assert response.json()["user"]["email"] == "student@example.com"


def test_google_sign_in_rejects_short_token():
    response = client.post("/api/v1/auth/google", json={"id_token": "short"})
    assert response.status_code == 422


def test_me_requires_authorization_header():
    response = client.get("/api/v1/me")
    assert response.status_code == 401


def test_tutor_requires_valid_payload():
    response = client.post("/api/v1/tutor", json={"subject": "Python", "question": "hi"})
    assert response.status_code == 422


def test_tutor_reports_missing_provider_configuration(monkeypatch):
    monkeypatch.delenv("LLM_API_BASE_URL", raising=False)
    monkeypatch.delenv("LLM_API_KEY", raising=False)
    monkeypatch.delenv("LLM_MODEL", raising=False)
    response = client.post("/api/v1/tutor", json={"subject": "Python", "question": "Explain Python lists with an example."})
    assert response.status_code == 503
    assert "not configured" in response.json()["detail"]

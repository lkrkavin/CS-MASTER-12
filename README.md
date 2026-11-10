# CS MASTER 12

A cross-platform CBSE Class 12 Computer Science learning app focused on Python, SQL/MySQL, and Python–SQL integration.

## Project status

This repository is at the **foundation stage**. The initial scaffold is being built; planned features are not represented as complete until implemented and tested.

## Planned learning experience

- CBSE Class 12 Python lessons, examples, and practice
- SQL/MySQL lessons and query practice
- Python–SQL integration exercises
- Interactive coding labs with safe execution boundaries
- AI tutor for typed and image-based questions
- Student progress, saved programs, and notes
- Optional Google sign-in and cross-device sync
- User-controlled voice and screen-sharing assistance

## Architecture

- **Client:** Flutter (Android, iOS, Windows, macOS, Linux, and web)
- **API:** Python FastAPI
- **Learning data:** structured curriculum content
- **Local persistence:** offline-first storage (planned)
- **Execution:** isolated Python runner and SQL sandbox (planned; never execute untrusted code in the API process)

## Repository layout

- `app/` — Flutter client
- `backend/` — FastAPI service
- `.github/workflows/` — CI checks

## Development

Backend:

```bash
cd backend
python -m venv .venv
# Activate the virtual environment, then:
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Client (requires Flutter SDK):

```bash
cd app
flutter pub get
flutter run -d chrome
```

## Security notes

Do not commit API keys, OAuth client secrets, access tokens, or student personal data. Configure secrets through the deployment platform. Google sign-in must be verified server-side before account data is accepted. Code execution must be isolated from the API service.

## Verification

CI runs backend tests. Flutter analysis and tests run when the Flutter SDK is available in CI.

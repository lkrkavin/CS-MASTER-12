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

## Google sign-in setup

Google sign-in is implemented as an ID-token flow. The Flutter app obtains a Google ID token, and the FastAPI backend verifies its signature, issuer, expiry, and audience before creating/updating a minimal student profile in SQLite.

1. In Google Cloud Console, configure the OAuth consent screen.
2. Create an **Android OAuth client** for package `com.lkrkavin.cs_master_12` using the SHA-1 certificate fingerprint of the key that signs the installed APK.
3. Create a **Web application OAuth client**. Its client ID is used as the server client ID in Flutter and as the expected token audience in the backend.
4. Build Flutter with `--dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID` and `--dart-define=API_BASE_URL=https://YOUR_API_HOST`.
5. Set backend environment variable `GOOGLE_CLIENT_ID` to the same Web application client ID. Set `DATABASE_PATH` to a persistent writable path.
6. Deploy the API over HTTPS before using Google sign-in on a physical device. The default `http://10.0.2.2:8000` address is for an Android emulator talking to a development machine only.

The backend exposes `POST /api/v1/auth/google` with JSON `{"id_token":"..."}` and `GET /api/v1/me` with an Authorization bearer ID token. Student profiles currently store Google subject ID, email, display name, and profile image URL. Learning progress sync is not implemented yet.

## Security notes

Do not commit API keys, OAuth client secrets, access tokens, or student personal data. Configure secrets through the deployment platform. Google sign-in must be verified server-side before account data is accepted. Code execution must be isolated from the API service.

## Verification

CI runs backend tests. Flutter analysis and tests run when the Flutter SDK is available in CI.

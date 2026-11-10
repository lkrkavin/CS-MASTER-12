# CS MASTER 12

Flutter learning app for CBSE Class 12 Computer Science: Python, SQL/MySQL and Python–SQL integration.

## Included features
- Python and SQL lessons with worked examples and real-world context.
- Python–MySQL integration lesson using parameterized queries.
- Starter interactive quiz with scoring and explanations.
- Learning Studio: local progress checklist and XP, configurable AI tutor, camera/gallery question scanner with on-device OCR, output-prediction coding practice, 10-question CBSE starter mock, daily missions and text-to-speech read-aloud.
- Guest mode: bundled lessons and offline practice work without Google sign-in.

## Feature boundaries
- AI tutor requires a deployed backend and an OpenAI-compatible provider. Configure backend-only environment variables `LLM_API_BASE_URL`, `LLM_API_KEY`, and `LLM_MODEL`. Never put provider keys in Flutter or commit them.
- OCR runs on-device. Extracted text is sent to the tutor only after the student taps Ask tutor.
- Coding lab provides output-prediction and SQL reasoning exercises; it does not execute arbitrary code. Live execution needs a separate isolated sandbox service.
- Mock practice is a 10-question starter set, not a complete official 70-mark CBSE paper.
- Progress and XP use local SharedPreferences. Cross-device cloud sync is not enabled.
- Voice currently provides device text-to-speech; live speech recognition is not enabled.
- Camera, OCR and TTS should be verified on a physical Android device.

## AI tutor backend
Set `LLM_API_BASE_URL` to an OpenAI-compatible provider base URL (without `/chat/completions`), plus `LLM_API_KEY` and `LLM_MODEL`, on the backend host only. The API endpoint is `POST /api/v1/tutor`. Without these settings, the endpoint returns a clear 503 configuration response.

## Google sign-in
Google sign-in requires OAuth configuration and a deployed HTTPS backend. Android package: `com.lkrkavin.cs_master_12`. Register the SHA-1 fingerprint of the certificate that signs the installed APK. Set Flutter build variables `GOOGLE_WEB_CLIENT_ID` and `API_BASE_URL`; set backend `GOOGLE_CLIENT_ID` to the matching Web client ID. For reliable release OAuth, use a stable release keystore stored in GitHub Actions secrets, never committed to Git.

## Backend
Run from backend: `uvicorn app.main:app --host 0.0.0.0 --port 8000`.
Endpoints: `GET /health`, `GET /api/v1/curriculum`, `GET /api/v1/curriculum/{subject}`, `POST /api/v1/tutor`, `POST /api/v1/auth/google`, `GET /api/v1/me`.

## Verification
GitHub Actions runs backend tests, Flutter analysis and widget tests, and a separate Android APK build. Treat a feature as verified only after the latest workflow succeeds and device testing is complete.

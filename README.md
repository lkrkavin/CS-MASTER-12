# CS MASTER 12

A Flutter learning app for CBSE Class 12 Computer Science: Python, SQL/MySQL, and Python–SQL integration.

## Current working learning features

- Python lessons: variables, data types, operators, conditions, loops, strings, lists, dictionaries, functions, files, exceptions, and stack operations.
- SQL/MySQL lessons: databases, tables, INSERT, UPDATE, DELETE, SELECT, WHERE, ORDER BY, aggregates, GROUP BY, HAVING, joins, constraints and keys.
- Python + SQL worked example: connection, cursor, parameterized execute(), commit(), fetchone(), and closing resources.
- Interactive practice: six starter MCQs across Python, SQL and integration, with scoring and explanations.
- Guest mode: lessons and practice work without Google sign-in or a backend connection.

Lessons and quiz are bundled in the Flutter app. Code snippets are explanatory examples; this version does not execute arbitrary Python or SQL code inside the app.

## Google sign-in setup

Google sign-in needs OAuth clients in your Google Cloud project and a deployed HTTPS backend. Guest mode remains available until these are configured.

1. Configure the OAuth consent screen in Google Cloud Console.
2. Create an Android OAuth client with package name com.lkrkavin.cs_master_12.
3. Add the SHA-1 fingerprint of the certificate that signs the APK you install. A mismatched SHA-1 can cause ApiException 10 or DEVELOPER_ERROR.
4. Create a Web application OAuth client. Use its client ID as GOOGLE_WEB_CLIENT_ID.
5. Deploy the FastAPI backend over HTTPS. Set backend GOOGLE_CLIENT_ID to the same Web client ID and DATABASE_PATH to persistent writable storage.
6. In GitHub repository Settings, Secrets and variables, Actions, Variables, set GOOGLE_WEB_CLIENT_ID and API_BASE_URL (the deployed HTTPS API base URL, without a trailing slash).
7. Run the Android APK workflow again and install the new artifact.

The GitHub workflow currently builds a release APK using runner-generated Android signing configuration. For reliable Google sign-in, configure a stable release keystore as GitHub Actions secrets, update the workflow to sign with that keystore, and register its SHA-1 in the Android OAuth client. Never commit the keystore or passwords.

## Backend

Install dependencies from backend/requirements.txt and run: uvicorn app.main:app --host 0.0.0.0 --port 8000

Endpoints: GET /health, GET /api/v1/curriculum, GET /api/v1/curriculum/{subject}, POST /api/v1/auth/google, GET /api/v1/me.

The backend verifies Google ID tokens and stores a minimal student profile in SQLite. Learning progress sync, saved notes, cross-device sync, AI question scanning, voice tutor, and screen sharing are not implemented in this release.

## Python–MySQL flow

1. mysql.connector.connect(...) opens a connection to the school database.
2. con.cursor() creates a cursor.
3. cur.execute(INSERT, values) sends a parameterized query.
4. con.commit() saves the transaction.
5. cur.execute(SELECT, parameters) requests the record.
6. cur.fetchone() reads one row.
7. cur.close() and con.close() release resources.

Example values (101, 92) represent roll number 101 and marks 92. A real database must contain the matching Result table and columns.

## Verification

GitHub Actions runs backend tests, Flutter analysis and widget tests, and a separate Android release APK build. Check the latest workflow run before treating a build as verified.
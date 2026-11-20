# SmartFood AI — CHG-UI-006: Receipt OCR workflow

## Delivered

- Replaced the receipt placeholder in the Next.js application with a working upload, OCR review, correction, and import workflow.
- Added a binary image upload helper that sends PNG/JPEG bytes to the existing FastAPI receipt endpoint (maximum 5 MiB enforced by both UI and API).
- Displays the OCR source lines, duplicate-image warnings, and catalog suggestions.
- Requires the user to map each row to a catalog product and review quantity, compatible unit, received date, and expiry source/date.
- Persists the edited receipt draft through `PUT /api/households/{hid}/receipts/{rid}` and confirms through the existing atomic/idempotent receipt confirmation endpoint.
- Refreshes the workspace after import so Dashboard, inventory, and alerts show the newly imported batches.
- Provides a manual-entry fallback that imports reviewed rows through the existing inventory receive API when OCR is unavailable.
- Does not change the FastAPI receipt implementation, database schema, migrations, or existing business rules.

## OCR runtime constraint

The existing OCR adapter is Windows-only and uses Windows Runtime `Windows.Media.Ocr` through PowerShell. It depends on a suitable Windows OCR language pack. On non-Windows systems the API returns HTTP 503; users can still use the manual-entry fallback. OCR output is a draft only and is never imported without user review and confirmation.

## Run

Start the FastAPI backend from the project root:

```powershell
.\.venv\Scripts\python.exe -m uvicorn backend.main:app --host 127.0.0.1 --port 8000 --no-proxy-headers
```

Start the Next.js frontend in another terminal:

```powershell
cd frontend
npm install
npm run dev
```

Open `http://localhost:3000`, sign in, select **Quét hóa đơn**, and upload a clear PNG/JPEG image.

## Validation

- `python -m compileall -q backend`: passed.
- `python -m unittest discover -s tests -p 'test_*.py' -v`: 22 tests, 21 passed, 1 skipped (Windows-only OCR integration test).
- TypeScript/TSX transpile syntax check: 5 files, no syntax errors.
- Full `next build` was not run because npm dependencies are not installed in this build environment.

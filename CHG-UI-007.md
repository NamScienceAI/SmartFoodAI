# SmartFood AI — CHG-UI-007: AI Recipe Recommendation

## Delivered

- Replaced the recipe recommendation placeholder in the Next.js application with a working recommendation and meal-planning flow.
- Loads the reviewed recipe catalog from `GET /api/recipes` and the signed-in user's dietary profile from `GET /api/me/dietary`.
- Provides a dietary profile editor for verified allergen classes, tags present in the catalog, and liked catalog ingredients. Saves through `PUT /api/me/dietary`.
- Requests household recommendations through `POST /api/households/{hid}/recommendations` using the signed-in user as the participant and a configurable serving count.
- Supports both existing backend ranking methods: `multi` (combined stock coverage, near-expiry coverage and liked ingredients) and `content` (stock coverage and liked ingredients).
- Shows ranked results, match score, ingredient coverage, ingredients needed for the selected serving count, and missing ingredients.
- Converts backend storage ticks to the catalog base unit for ingredient quantities shown in the UI. Missing amounts are not fabricated; the API-provided missing ticks are used to identify which ingredients are short.
- Allows the selected recipe to be added to a meal plan through the existing `POST /api/households/{hid}/meals` endpoint. Planned meal demand is then available to the existing grocery shortage calculation.
- Uses existing backend eligibility checks for participant membership, dietary profiles, recipe completeness and verified allergen restrictions. The UI does not attempt to replace those checks.
- Does not modify FastAPI code, SQLite schema, migrations, seed recipes, or existing business rules.

## Current catalog and product limitations

- The initial migration seeds two local demonstration recipes. The UI renders the current API catalog and does not invent additional recipes.
- The recipe schema currently stores recipe name, allergen labels, tags, completeness, source, and ingredient quantities. It does not store cooking steps, preparation time, nutrition facts, photos, or AI-generated instructions. The UI explicitly identifies that limitation instead of fabricating cooking instructions.
- Recommendation ranking is the existing deterministic backend scoring algorithm, not a generative LLM. The `multi` method gives weight to stock coverage, near-expiry coverage, and liked ingredients; `content` uses stock coverage and liked ingredients.
- The current interface recommends for the signed-in user only. Household members must each save their own dietary profile before being included as participants in a future multi-person planning flow.
- Allergen filtering only treats the backend's verified classes as verified. This is not a substitute for checking product packaging or professional medical advice.

## API integration

- `GET /api/recipes`
- `GET /api/me/dietary`
- `PUT /api/me/dietary`
- `POST /api/households/{hid}/recommendations`
- `POST /api/households/{hid}/meals`

## Run

Start FastAPI from the project root:

```powershell
.\.venv\Scripts\python.exe -m uvicorn backend.main:app --host 127.0.0.1 --port 8000 --no-proxy-headers
```

Start Next.js in another terminal:

```powershell
cd frontend
npm install
npm run dev
```

Open `http://localhost:3000`, sign in, select **Gợi ý món ăn**, save a dietary profile, and request recommendations.

## Validation

- `python -m compileall -q backend`: passed.
- `python -m unittest discover -s tests -p 'test_*.py' -v`: 22 tests, 21 passed, 1 skipped (Windows-only OCR integration test).
- TypeScript/TSX transpile syntax check: passed for the changed React components.
- Full `next build` and browser E2E were not run because frontend npm dependencies are not installed in this build environment.

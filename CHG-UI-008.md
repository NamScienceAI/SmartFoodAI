# SmartFood AI — CHG-UI-008: Meal Planning & Smart Grocery Management

## Delivered

- Replaced the meal-planning and grocery placeholders in the Next.js application with a connected workflow using the existing FastAPI endpoints.
- Added a weekly meal planner with selectable date ranges, daily grouping, recipe names, meal slots, serving counts, and search.
- Added create, edit, and delete operations for planned meals. Create and update requests use unique idempotency keys and the signed-in user as the participant.
- Added live grocery shortage preview for the selected date range. The preview is calculated by the backend from planned recipe ingredient demand and usable household inventory batches.
- Added confirmation of a grocery list using the exact shortage payload returned by the API. The backend rechecks the shortage at save time and rejects stale payloads with HTTP 409.
- Added saved shopping-list history, progress percentage, and purchased/not-purchased toggles for each item.
- Connected both sidebar entries (**Kế hoạch bữa ăn** and **Danh sách mua sắm**) to the same integrated workspace with in-page navigation.
- Added responsive layouts for desktop, tablet, and mobile.
- Kept business rules and data authority in FastAPI. The UI does not independently calculate stock depletion or create fictional ingredient amounts.

## API integration

- `GET /api/recipes`
- `GET /api/catalog/products`
- `GET /api/households/{hid}/meals`
- `POST /api/households/{hid}/meals`
- `PUT /api/households/{hid}/meals/{mid}`
- `DELETE /api/households/{hid}/meals/{mid}`
- `GET /api/households/{hid}/groceries?start=YYYY-MM-DD&end=YYYY-MM-DD`
- `POST /api/households/{hid}/grocery-lists`
- `GET /api/households/{hid}/grocery-lists`
- `PUT /api/households/{hid}/grocery-lists/{lid}/items/{pid}`

## Data and behavior notes

- Meal plans currently include the signed-in user as the participant. Multi-member meal planning requires each participant to have a dietary profile accepted by the existing backend eligibility checks.
- The grocery shortage calculation is owned by the backend. It consumes eligible stock against planned demand and returns only missing ingredient amounts.
- A grocery list is saved only after the backend confirms that the submitted shortage data still matches the current plan and inventory. If data changed, the UI asks the user to refresh the preview.
- Marking an item as purchased updates the grocery-item status. The current API does not automatically receive the purchased item into inventory; that remains a separate inventory action.
- Saved grocery-list items store product IDs, quantities and purchase status. The UI resolves names and units from the current catalog; if a product is no longer available in the catalog, it displays the product ID as a fallback.
- The current schema supports one recipe per meal-plan row, date, meal slot, servings and participants. Drag-and-drop calendar rescheduling, recurring meals, meal instructions and multi-person dietary aggregation are not implemented in this change.
- Quantity display converts backend storage ticks using the catalog base-unit convention already used by the recipe UI; the backend remains authoritative for quantities and shortage calculation.

## Files changed

- `frontend/src/components/meal-planner-page.tsx` — integrated planner and grocery UI.
- `frontend/src/components/smartfood-app.tsx` — connected sidebar routes to the new module.
- `frontend/src/app/globals.css` — responsive Premium SaaS styling.
- `README.md` and `frontend/README.md` — updated project documentation.

No FastAPI modules, SQLite migrations, database schema, seed data, or existing business rules were changed.

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

Open `http://localhost:3000`, sign in, and choose **Kế hoạch bữa ăn** or **Danh sách mua sắm**.

## Validation

- `python -m compileall -q backend`: passed.
- `python -m unittest discover -s tests -p 'test_*.py' -v`: 22 tests, 21 passed, 1 skipped (Windows-only OCR integration test).
- TypeScript/TSX transpile syntax check: passed for the changed React components.
- Full `next build`, lint and browser E2E were not run because npm dependencies are not installed in the build environment.

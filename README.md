Vantage Life & Annuities — QA Automation Portfolio
Independent training simulation; not a proprietary Vantage system or a live insurer. Built from publicly styled life and annuity application structures using synthetic customer data only. Original PDFs, PII, signature images and real carrier disclosures are not part of this repository.
Architecture
Agent Portal / CRM / Funding / Product Catalog / Review (mock sources) → POST /integrations/events → PostgreSQL inbound_events

REST clients (Postman, pytest) → FastAPI app → PostgreSQL applications / beneficiaries / audit_events

The integration feed is ingested and deduplicated; automatic field mapping and reconciliation are planned follow-up work, not implemented.
Setup (Windows PowerShell)
1. Install Python 3.11+ and Docker Desktop (or PostgreSQL 14+).
2. Open this folder in VS Code. Create venv: python -m venv .venv; activate: .\.venv\Scripts\Activate.ps1.
3. Install dependencies: pip install -r requirements.txt.
4. Start database: docker compose up -d. If using existing PostgreSQL, run psql -d vantage -f db/schema.sql and set DATABASE_URL.
5. Start API: uvicorn app.main:app --reload. Visit http://localhost:8000/docs for interactive Swagger documentation.
6. In a second terminal, run python -m pytest -q.
7. For live integration tests: $env:VANTAGE_RUN_INTEGRATION='1'; python -m pytest -q.
8. SQL checks: docker compose exec -T db psql -U vantage -d vantage < db/qa_checks.sql (bash) or Get-Content db/qa_checks.sql | docker compose exec -T db psql -U vantage -d vantage (PowerShell).
9. Import postman/Vantage.postman_collection.json into Postman and run requests in order.
Documents
- docs/Life_Insurance_BRD.docx and docs/Annuity_BRD.docx: source-informed proposed requirements.
- docs/Test_Strategy.md, docs/Defect_Log.md, docs/Four_Day_Plan.md, docs/LinkedIn_Post.md.
Testing scope and limitations
Automated unit validation and opt-in live API workflow tests; PostgreSQL integrity and audit queries; Postman smoke tests. No Selenium UI, Karate suite, real insurer integrations, authentication or full suitability/underwriting engine in this MVP. Decisions and funding flags are simplified and not production safe. A test pass must be observed before claiming it.
Sample Git commands
git init → git add . → git commit -m "Initial Vantage QA portfolio" → create a GitHub repository → git remote add origin YOUR_REPOSITORY_URL → git push -u origin main (set branch first with git branch -M main). Do not upload original reference PDFs.
